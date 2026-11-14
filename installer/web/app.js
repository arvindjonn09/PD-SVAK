// PD-SVAK web installer: step flow and safety checks.
// Rules enforced here (installer/README.md "Non-goals"):
//   - only devices with tier "launch" in devices.json can be flashed
//   - nothing is written until the image's metadata signature and SHA-256 both verify
//   - the flow is not finished until the bootloader is locked again
import { Phone } from "./fastboot-adapter.js";
import { RELEASE_METADATA_KEY, METADATA_BASE, CHANNEL } from "./release-key.js";

const ORDER = ["browser", "preflight", "unlock", "download", "flash", "key", "lock", "verify"];
const $ = (sel) => document.querySelector(sel);
const out = (name) => $(`[data-out="${name}"]`);
const btn = (name) => $(`[data-act="${name}"]`);

const state = { phone: null, device: null, meta: null, image: null, avbKey: null };

function activate(step) {
  const i = ORDER.indexOf(step);
  document.querySelectorAll("#steps > li").forEach((li) => {
    const j = ORDER.indexOf(li.dataset.step);
    li.classList.toggle("done", j < i);
    li.classList.toggle("active", j === i);
  });
  document.querySelectorAll("[data-act]").forEach((b) => (b.disabled = true));
  const b = btn(step === "preflight" ? "connect" : step);
  if (b) b.disabled = step === "preflight" ? !$('[data-in="preflight-ok"]').checked : false;
}

function say(name, msg, isErr = false) {
  const el = out(name);
  el.textContent = msg;
  el.classList.toggle("err", isErr);
}

// Runs a step's action; on error, reports it and lets the user retry the same step.
function step(name, fn) {
  btn(name).addEventListener("click", async () => {
    btn(name).disabled = true;
    try {
      await fn();
    } catch (e) {
      say(name, `${e.message || e} Try again; if it keeps failing, replug the cable or try another port.`, true);
      btn(name).disabled = false;
    }
  });
}

async function sha256Hex(buf) {
  const h = await crypto.subtle.digest("SHA-256", buf);
  return [...new Uint8Array(h)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function fetchChecked(url) {
  const r = await fetch(url, { cache: "no-store" });
  if (!r.ok) throw new Error(`Download failed (${r.status}) for ${url}.`);
  return r;
}

async function downloadWithProgress(url, size, bar) {
  const r = await fetchChecked(url);
  const reader = r.body.getReader();
  const chunks = [];
  let got = 0;
  bar.hidden = false;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    got += value.length;
    bar.value = size ? got / size : 0;
  }
  return new Blob(chunks);
}

async function loadSignedMetadata(codename) {
  if (!RELEASE_METADATA_KEY) throw new Error("This installer build has no release signing key configured, so it cannot verify images.");
  const base = `${METADATA_BASE}/${CHANNEL}/${codename}.json`;
  const [jsonBytes, sigB64] = await Promise.all([
    fetchChecked(base).then((r) => r.arrayBuffer()),
    fetchChecked(`${base}.sig`).then((r) => r.text()),
  ]);
  const key = await crypto.subtle.importKey("jwk", RELEASE_METADATA_KEY, { name: "ECDSA", namedCurve: "P-256" }, false, ["verify"]);
  const sig = Uint8Array.from(atob(sigB64.trim()), (c) => c.charCodeAt(0));
  const ok = await crypto.subtle.verify({ name: "ECDSA", hash: "SHA-256" }, key, sig, jsonBytes);
  if (!ok) throw new Error("Release metadata signature is INVALID. Not installing.");
  const meta = JSON.parse(new TextDecoder().decode(jsonBytes));
  for (const k of ["codename", "build", "image_url", "image_sha256", "image_size", "avb_key_url", "avb_key_sha256"]) {
    if (!(k in meta)) throw new Error(`Release metadata is missing "${k}".`);
  }
  if (meta.codename !== codename) throw new Error(`Metadata is for ${meta.codename}, but the phone is ${codename}.`);
  return meta;
}

async function init() {
  // 1. Browser
  if (!("usb" in navigator)) {
    say("browser", "This browser has no WebUSB. Use Chrome or Edge on Windows, macOS, Linux or ChromeOS.", true);
    return;
  }
  if (!window.isSecureContext) {
    say("browser", "The installer must be opened over https.", true);
    return;
  }
  say("browser", "OK: this browser supports WebUSB.");

  let devices;
  try {
    devices = (await (await fetchChecked("devices.json")).json()).devices;
  } catch (e) {
    say("browser", `Could not load the device list: ${e.message}`, true);
    return;
  }
  activate("preflight");
  $('[data-in="preflight-ok"]').addEventListener("change", (e) => (btn("connect").disabled = !e.target.checked));

  // 2. Connect and identify
  step("connect", async () => {
    state.phone = new Phone();
    await state.phone.connect();
    const codename = await state.phone.codename();
    const dev = devices.find((d) => d.codename === codename);
    if (!dev || dev.tier !== "launch") {
      const when = dev?.tier === "planned" ? ` It is planned as a ${dev.security} device; see docs/DEVICE-TIERS.md.`
        : dev?.tier === "dev" ? " It is a development test device only, because its manufacturer no longer ships security updates." : "";
      throw new Error(`${dev?.name || codename} is not available in this installer yet.${when}`);
    }
    state.device = dev;
    const tier = dev.security.charAt(0).toUpperCase() + dev.security.slice(1);
    say("connect", `Connected: ${dev.name} (${codename}). Security tier: ${tier}.${dev.limits ? " Limits: " + dev.limits : ""}`);
    if (await state.phone.isUnlocked()) {
      say("unlock", "Already unlocked.");
      activate("download");
    } else {
      activate("unlock");
    }
  });

  // 3. Unlock
  step("unlock", async () => {
    say("unlock", "Confirm on the phone…");
    await state.phone.unlock();
    if (!(await state.phone.isUnlocked())) throw new Error("The phone is still locked. Did you choose Unlock on the phone?");
    say("unlock", "Unlocked.");
    activate("download");
  });

  // 4. Download and verify (nothing touches the phone in this step)
  step("download", async () => {
    say("download", "Checking release signature…");
    const meta = await loadSignedMetadata(state.device.codename);
    say("download", `Downloading build ${meta.build}…`);
    const image = await downloadWithProgress(meta.image_url, meta.image_size, out("download-progress"));
    say("download", "Verifying SHA-256…");
    if ((await sha256Hex(await image.arrayBuffer())) !== meta.image_sha256.toLowerCase()) {
      throw new Error("Image hash does not match the signed metadata. The download is corrupt or tampered with.");
    }
    const avbKey = await (await fetchChecked(meta.avb_key_url)).blob();
    const avbHash = await sha256Hex(await avbKey.arrayBuffer());
    if (avbHash !== meta.avb_key_sha256.toLowerCase()) throw new Error("Verified-boot key hash does not match the signed metadata.");
    Object.assign(state, { meta, image, avbKey });
    say("download", `Verified build ${meta.build}.`);
    out("verify").textContent = avbHash.match(/.{1,8}/g).join(" ");
    activate("flash");
  });

  // 5. Flash
  step("flash", async () => {
    const bar = out("flash-progress");
    bar.hidden = false;
    await state.phone.flashFactory(
      state.image,
      async () => {
        say("flash", "The phone restarted. If the browser asks, pick the phone again.");
        await state.phone.reconnect();
      },
      (label, p) => { say("flash", label); bar.value = p; },
    );
    say("flash", "Installed.");
    activate("key");
  });

  // 6. AVB key
  step("key", async () => {
    await state.phone.flashAvbKey(state.avbKey);
    say("key", "Key added.");
    activate("lock");
  });

  // 7. Relock (mandatory)
  step("lock", async () => {
    say("lock", "Confirm on the phone…");
    await state.phone.lock();
    if (await state.phone.isUnlocked()) throw new Error("The phone is still unlocked. It is not safe to use like this. Choose Lock on the phone.");
    say("lock", "Locked.");
    activate("verify");
  });

  window.addEventListener("beforeunload", (e) => {
    const cur = document.querySelector("#steps > li.active")?.dataset.step;
    if (["flash", "key", "lock"].includes(cur)) e.preventDefault();
  });
}

init();
