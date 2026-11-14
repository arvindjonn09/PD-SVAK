# Duress PIN: read this before you turn it on

> **Status:** the duress PIN/password is planned for **v1.1**. It is not in the Developer Preview.
> This page is general information, **not legal advice**. Laws differ by country and change. If you think you may face a border search, arrest or a court order, talk to a lawyer where you live.

## What it does

You set a second PIN or password. If anyone enters it on the lock screen (or in the encryption prompt after a reboot), the phone **immediately and permanently erases itself**:

- The secure element destroys the keys that encrypt your data, so the data can never be recovered, by you or anyone else.
- eSIMs are deleted too.
- The phone then powers off. There is no confirmation and no undo.

It is meant for situations where someone is forcing you to unlock your phone.

## Risks you take on

1. **You lose everything on the phone.** Anything not backed up elsewhere is gone for good. Keep an encrypted backup (Seedvault) somewhere you control, if you need your data afterwards.
2. **Accidental wipes happen.** If your duress PIN is close to your real PIN, or a child or friend guesses it, the phone wipes. Choose a duress PIN that is clearly different from your real one.
3. **Wiping can be a crime.** In some places, deleting data while a police officer, border agent or court is asking for it can be treated as:
   - destroying or tampering with evidence,
   - obstructing an officer or investigation, or
   - contempt of court, if a court ordered you to give access.

   These charges can be more serious than whatever the search was about. Some countries also make it an offence to refuse to give up a password at all.
4. **It may be obvious.** A phone that powers off and comes back empty after you entered a PIN shows that a wipe happened. Don't assume nobody will notice.
5. **It does not protect copies.** Data already synced to cloud services, sent in messages, or copied off the phone before is not affected.

## Our recommendation

- **Most people don't need it.** The protections that are on by default do more for most threat models: a locked phone with a strong passphrase, USB-C port lockdown and the auto-reboot timer already make data extraction very hard.
- **Before crossing a border,** consider powering the phone off (it then returns to the before-first-unlock state) or travelling with a phone that has little data on it, instead of relying on a duress wipe.
- **If you do turn it on,** know your local law first, keep an off-device backup, and pick a duress PIN you will never type by mistake.

## Where to find it (v1.1)

Settings → Security & privacy → Device unlock → Duress Password. You must enter your current PIN/password to set it, and the setup screen links to this page.
