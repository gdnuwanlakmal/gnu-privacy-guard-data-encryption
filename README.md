# GnuPG (GPG) – Step-by-Step Key Management

GnuPG (GPG) implements OpenPGP for encrypting, signing, and verifying data.  
* This guide shows how to create, list, export/import, delete, and use keys—plus a few crucial safety steps you don’t want to skip.

## Install & Check Your Setup
```bash
# Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y gnupg
```

# Verify version and home (keyring) path
```bash
gpg --version
# Look for "Home: /root/.gnupg" or "/home/<user>/.gnupg"
```
* Keyring directory (example):
```shell
~/.gnupg/
  ├─ openpgp-revocs.d/
  ├─ private-keys-v1.d/
  ├─ pubring.kbx
  └─ trustdb.gpg
```
### 1. Create a New Key Pair (default ECC)
```shell
gpg --gen-key
```
* You’ll see output like:
```shell
pub   ed25519 YYYY-MM-DD [SC] [expires: YYYY-MM-DD]
      <FINGERPRINT>
uid   Your Name <you@example.com>
sub   cv25519 YYYY-MM-DD [E] [expires: YYYY-MM-DD]
```
* Tip: Entropy matters—type/move mouse during generation if prompted.
### 2. Generate a Key Pair That Never Expires (RSA 4096 example)
```shell
gpg --full-generate-key
# (1) RSA and RSA
# keysize: 4096
# validity: 0  (0 = never expires)
# enter name/email/comment → O(kay)
```
### 3. List Keys (Public & Private)
```shell
# Public keys
gpg --list-keys

# Private/secret keys
gpg --list-secret-keys
```
* Show short vs long IDs:
```shell
gpg --list-secret-keys --keyid-format short
gpg --list-secret-keys --keyid-format long
```
* Show fingerprint (preferred identifier):
```shell
gpg --fingerprint <KEYID or email>
```
* Use the full fingerprint for safety (avoids short-ID collisions).
### 4. Export Keys
* Public key (shareable):
```shell
gpg --export --armor <KEYID or email> > public-key.asc
```
* Private key (keep secret; back up offline):
```shell
gpg --export-secret-keys --armor <KEYID or email> > private-key.asc
```
* Optional (subkeys only): gpg --export-secret-subkeys --armor <KEYID> > private-subkeys.asc
### 5. Import Keys
```shell
# Import public or private keys
gpg --import public-key.asc
gpg --import private-key.asc
```
* Mark your own key as ultimately trusted (ownertrust):
```shell
gpg --edit-key <KEYID>
gpg> trust
# choose 5 = I trust ultimately  (only for your OWN key)
gpg> save
```
### 6. Delete Keys (order matters)
```shell
# 1) Delete the secret key first
gpg --delete-secret-keys <KEYID>

# 2) Then delete the public key
gpg --delete-keys <KEYID>
```
### 7. Create & Store a Revocation Certificate (CRITICAL)
* If your key is lost/compromised, you’ll need this to revoke it.
```shell
gpg --output revoke-<KEYID>.asc --gen-revoke <KEYID>
# Store this safely OFFLINE (not in Git).
```
* Newer GnuPG also auto-creates a revocation cert under ~/.gnupg/openpgp-revocs.d/.
### 8. Change Key Passphrase or Expiry Later
```shell
gpg --edit-key <KEYID>
gpg> passwd     # change passphrase
gpg> expire     # change expiry (0 = never)
gpg> save
```
### 9. Encrypt / Decrypt Files
* Encrypt to recipient (binary output):
```shell
gpg --encrypt --recipient <KEYID or email> file.txt
# produces file.txt.gpg
```
* ASCII-armored output (good for email/paste):
```shell
gpg --armor --encrypt -r <KEYID> file.txt > file.txt.asc
```
### Decrypt:
```shell
gpg --output file.txt --decrypt file.txt.gpg
# or
gpg --decrypt file.txt.gpg > file.txt
```
* Symmetric (password-only) encryption:
```shell
gpg --symmetric file.txt
gpg --output file.txt --decrypt file.txt.gpg
```
### 10. Sign / Verify (Integrity & Authorship)
* Detached signature (keeps file clean):
```shell
gpg --detach-sign file.txt      # creates file.txt.sig
gpg --verify file.txt.sig file.txt
```
* Clear-sign text (human-readable):
```shell
gpg --clearsign README.md       # creates README.md.asc
gpg --verify README.md.asc
```
### 11) Useful Tips & Housekeeping

* Default key (optional): add to ~/.gnupg/gpg.conf
default-key <YOUR-KEYID>

* Backup: keep offline copies of:
 - private-key.asc, revoke-<KEYID>.asc
 - OR the whole ~/.gnupg/ directory with strict permissions (chmod 700 ~/.gnupg)

* Check home path at any time:
```shell
gpg --version   # shows "Home: ..."
echo "$GNUPGHOME"  # overrides default if set
```

* Never commit private keys, revocation certs, or passphrases to Git/GitHub.
