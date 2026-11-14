// The only file that talks to the phone. Everything else in the installer goes through it.
//
// Backend: our fork of kdrag0n/fastboot.js (MIT), vendored at ./vendor/fastboot.mjs.
// It has not been vendored yet. Until it is, connect() throws a clear error and nothing is flashed.
// VERIFY the method names below against the fork's API when vendoring it.

let FastbootDevice = null;

async function loadBackend() {
  if (FastbootDevice) return;
  try {
    ({ FastbootDevice } = await import("./vendor/fastboot.mjs"));
  } catch {
    throw new Error("Flashing library not bundled in this build (installer/web/vendor/fastboot.mjs is missing).");
  }
}

export class Phone {
  #dev = null;

  async connect() {
    await loadBackend();
    this.#dev = new FastbootDevice();
    await this.#dev.connect(); // shows the browser's USB device picker
  }

  getvar(name) { return this.#dev.getVariable(name); }

  async codename() { return (await this.getvar("product")).trim(); }

  async isUnlocked() { return (await this.getvar("unlocked")).trim() === "yes"; }

  // Each of these needs the user to confirm on the phone.
  unlock() { return this.#dev.runCommand("flashing unlock"); }
  lock() { return this.#dev.runCommand("flashing lock"); }

  // Flashes firmware, then the OS, from a factory-image zip. Handles reboots between stages.
  flashFactory(blob, onReconnect, onProgress) {
    return this.#dev.flashFactoryZip(blob, /* wipe */ true, onReconnect,
      (action, item, progress) => onProgress(`${action} ${item}`, progress));
  }

  async flashAvbKey(blob) {
    await this.#dev.runCommand("erase:avb_custom_key");
    await this.#dev.flashBlob("avb_custom_key", blob);
  }

  reconnect() { return this.#dev.connect(); }
}
