# Multi-agent workflow

PD-SVAK uses AI agents (Claude Code subagents in `.claude/agents/` and scheduled GitHub Actions) to help 1–3 human maintainers. Agents propose changes and humans decide. Keep the agents focused on the tasks they do well.

## Research unit (used to produce `docs/research/`)

Five agents ran in parallel, one per area. Re-run them each quarter with the same prompts to refresh the strategy.

| Unit | Area | Output |
|---|---|---|
| 1 | Existing privacy and security ROMs, plus reusable components | `research/01-landscape.md` |
| 2 | AOSP status, choice of base, build, signing, OTA, kernels | `research/02-base-and-build.md` |
| 3 | Security and privacy feature catalog, forensics | `research/03-security.md` |
| 4 | Installer, app stores, developer verification, banking | `research/04-install-and-apps.md` |
| 5 | Devices, legal, AI workflow, funding, differentiation | `research/05-devices-legal-roadmap.md` |

## Engineering agents (`.claude/agents/`)

| Agent | Trigger | Does | Never does |
|---|---|---|---|
| `asb-tracker` | Monthly, plus on each Pixel or Android bulletin | Reads the bulletins, maps CVEs to our repos, opens an issue checklist | Decide whether a patch is "not applicable" without human sign-off |
| `rebase-assistant` | A new GrapheneOS stable tag appears | Rebases our patch set, drafts conflict fixes as draft PRs, summarizes upstream changes to files we patch | Merge, or touch SELinux or verified-boot code without flagging it |
| `build-triage` | A CI build fails | Reads the logs, finds the failing module, proposes a fix | Retry endlessly, or change signing config |
| `compat-triage` | A new app-compatibility issue | Labels and dedupes the issue, asks for repro details, updates the compatibility matrix | Recommend spoofing or rooting |
| `privacy-auditor` | Each release candidate | Diffs the first-boot traffic capture against the allowlist and flags new hosts | Add hosts to the allowlist itself |
| `docs-writer` | Each release | Drafts release notes, changelog and installer docs | Make security claims that aren't backed by a link |

## Hard limits

- **Signing keys:** agents never see or use signing keys, and never trigger signing.
- **Device testing:** real-device testing (radios, camera, relock, OTA) needs the hardware lab and a human.
- **Security-critical changes:** changes to memory safety, SELinux, verified boot or the kernel need expert human review.
- **Provenance:** agent-written code must have clear provenance. Never paste code of unknown origin or license.
