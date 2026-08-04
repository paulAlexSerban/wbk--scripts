Quick guide explaining what SSH and GPG keys are, followed by a step-by-step setup guide for both.

---

## 1. What Are These Keys?
### SSH Keys (Your Digital Passport)
An **SSH (Secure Shell) key pair** is used to authenticate your computer with GitHub without using your password.

* It consists of a **public key** (which you upload to GitHub) and a **private key** (which stays safely hidden on your computer).
* Think of it like a lock and key: GitHub holds the lock (public), and your computer holds the key (private). When you run `git push`, GitHub verifies that your private key matches the public lock.

### GPG Keys (Your Digital Wax Seal)
A **GPG (GNU Privacy Guard) key** is used to **sign** your commits, proving that the code actually came from *you*.
* Anyone can configure their Git local settings to pretend to be someone else by running `git config user.email "elonmusk@tesla.com"`.
* When you sign your commits with a GPG key, GitHub verifies that the commit was cryptographically sealed by your private machine. If it matches, GitHub grants you a green **"Verified"** badge next to your commit.

---
## 2. Quick Guide: Setting Up an SSH Key
### Step 1: Generate a new SSH key
Open your terminal and run the following command (replace with your GitHub email):

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"

```

*Press **Enter** to accept the default file location, and optionally enter a secure passphrase.*

### Step 2: Start the SSH agent and load your key
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

```

### Step 3: Add the SSH key to your GitHub account
1. Copy your public key to your clipboard:
```bash
cat ~/.ssh/id_ed25519.pub

```


2. Go to GitHub **Settings** -> **SSH and GPG keys** -> **New SSH Key**.
3. Paste your key, give it a title (e.g., "My Laptop"), and save.

---
## 3. Quick Guide: Setting Up a GPG Key
### Step 1: Install GPG
If you don't have GPG installed, install it via your package manager:
* **macOS:** `brew install gpg pinentry-mac`
* **Ubuntu/Debian:** `sudo apt install gnupg2`

### Step 2: Generate a GPG key pair

Run the generation command:

```bash
gpg --full-generate-key

```

Choose the following options when prompted:

1. Kind of key: Select **(1) RSA and RSA** (or ECC if preferred).
2. Keysize: Type **4096**.
3. Validity: Press **Enter** (key does not expire) or choose a time limit.
4. Enter your real name and the **exact same email address** you use on GitHub.

### Step 3: Get your GPG Key ID

List your secret keys to find the long hexadecimal ID:

```bash
gpg --list-secret-keys --keyid-format=long

```

Look for the line starting with `sec`. The string of characters after the `/` is your **GPG Key ID**:

```text
sec   rsa4096/3AA5C34371567BDD 2026-05-30 [SC]

```

*(In this example, the ID is `3AA5C34371567BDD`)*

### Step 4: Export the public key to GitHub

1. Export the key using your ID:
```bash
gpg --armor --export 3AA5C34371567BDD

```


2. Copy the entire block output (including `-----BEGIN PGP PUBLIC KEY BLOCK-----` and `-----END PGP PUBLIC KEY BLOCK-----`).
3. Go to GitHub **Settings** -> **SSH and GPG keys** -> **New GPG Key**.
4. Paste the text and save.

---

## 4. Tell Git to Use Your Keys Locally

Now that GitHub knows who you are, update your global Git configurations to use them automatically.

```bash
# Tell Git to sign all commits automatically
git config --global commit.gpgsign true

# Provide Git your GPG Key ID
git config --global user.signingkey 3AA5C34371567BDD

```

The next time you commit and push code (`git commit -m "feat: added login"`), Git will cryptographically seal your work, and GitHub will proudly display the green **Verified** status badge next to it.