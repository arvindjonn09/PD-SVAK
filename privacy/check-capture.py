#!/usr/bin/env python3
"""Check a first-boot / idle traffic capture against privacy/allowed-hosts.txt.

Input is the field dump from tshark, one packet per line, tab-separated:

    tshark -r capture.pcapng -T fields \
        -e frame.time_epoch -e dns.qry.name -e tls.handshake.extensions_server_name \
        -e http.host -Y "dns.flags.response == 0 || tls.handshake.type == 1 || http.request" \
        > capture.tsv

Usage:
    privacy/check-capture.py capture.tsv [--allowlist privacy/allowed-hosts.txt]

Exit code 0 = PASS (every host is allowlisted), 1 = FAIL, 2 = bad input.
Allowlist lines are exact hostnames; a line starting with "*." also allows subdomains.
This script never edits the allowlist.
"""
import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

HOST_RE = re.compile(r"^(?=.{1,253}$)([a-z0-9_]([a-z0-9_-]{0,61}[a-z0-9_])?\.)+[a-z0-9-]{2,63}$")
GOOGLE_SUFFIXES = (
    "google.com", "googleapis.com", "gstatic.com", "gvt1.com", "gvt2.com", "gvt3.com",
    "googleusercontent.com", "android.com", "googlezip.net", "1e100.net", "doubleclick.net",
    "google-analytics.com", "app-measurement.com", "crashlytics.com", "firebaseio.com",
)


def load_allowlist(path):
    exact, wildcard = set(), set()
    for raw in Path(path).read_text(encoding="utf-8").splitlines():
        entry = raw.split("#", 1)[0].strip().lower().rstrip(".")
        if not entry:
            continue
        if entry.startswith("*."):
            wildcard.add(entry[2:])
        else:
            exact.add(entry)
    return exact, wildcard


def allowed(host, exact, wildcard):
    if host in exact:
        return True
    return any(host == w or host.endswith("." + w) for w in wildcard)


def is_google(host):
    return any(host == s or host.endswith("." + s) for s in GOOGLE_SUFFIXES)


def parse_capture(path):
    """Return {host: [first_seen_epoch, count]}."""
    seen = {}
    for lineno, line in enumerate(Path(path).read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip() or line.startswith("#"):
            continue
        fields = line.split("\t")
        ts = fields[0].strip()
        try:
            t = float(ts)
        except ValueError:
            raise SystemExit(f"error: line {lineno}: first field must be an epoch timestamp, got {ts!r}")
        for field in fields[1:]:
            # tshark joins repeated values with commas.
            for host in field.split(","):
                host = host.strip().lower().rstrip(".")
                if not host or not HOST_RE.match(host):
                    continue
                if host in seen:
                    seen[host][1] += 1
                else:
                    seen[host] = [t, 1]
    return seen


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("capture")
    ap.add_argument("--allowlist", default=str(Path(__file__).with_name("allowed-hosts.txt")))
    args = ap.parse_args()

    try:
        exact, wildcard = load_allowlist(args.allowlist)
        seen = parse_capture(args.capture)
    except OSError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2

    if not seen:
        print("error: no hostnames found in capture. Check the tshark field order.", file=sys.stderr)
        return 2

    start = min(t for t, _ in seen.values())
    bad = defaultdict(list)
    for host, (t, n) in sorted(seen.items(), key=lambda kv: kv[1][0]):
        if not allowed(host, exact, wildcard):
            bad["google" if is_google(host) else "other"].append((host, t - start, n))

    ok = len(seen) - sum(len(v) for v in bad.values())
    print(f"hosts seen: {len(seen)}   allowlisted: {ok}   unexpected: {len(seen) - ok}")
    for kind, title in (("google", "Google hosts (always a release blocker)"), ("other", "Other unexpected hosts")):
        if bad[kind]:
            print(f"\n{title}:")
            for host, offset, n in bad[kind]:
                print(f"  +{offset:>9.1f}s  {n:>5}x  {host}")

    if ok < len(seen):
        print("\nVERDICT: FAIL. Run the privacy-auditor agent to attribute each host; "
              "allowlist changes need a human-approved PR with a justification.")
        return 1
    print("\nVERDICT: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
