# Conduit, but only for Iran

This is a small modification to **Psiphon Conduit** that makes your home
computer help **only people connecting from Iran** get around internet
censorship.

Normally Conduit helps anyone in any censored country. This version is
narrower: if the user isn't in Iran, your computer politely refuses and
waits for the next one.

> ⚠️ **This is unofficial.** It is not made by, endorsed by, or supported
> by Psiphon Inc. If something goes wrong, don't email Psiphon about it.
> See `NOTICE.md` for full details.

---

## Should I do this?

**Yes, probably**, if you:

- Care about helping people in Iran specifically
- Have a Mac or a Windows PC that's on most of the day
- Have a home internet connection with some bandwidth to spare
- Are willing to follow ~10 copy-paste commands in a terminal window

**No**, if you:

- Just want to help as many people as possible — use the [official
  Conduit](https://github.com/Psiphon-Inc/conduit) instead. It will
  help users from wherever demand is highest.
- Are on a metered or very slow connection
- Are in a country where running a circumvention proxy is illegal —
  know your local laws

---

## What you'll do

There are seven short steps. Each one is one or two commands you paste
into a terminal window. The whole thing takes about 30 minutes the first
time, mostly waiting for downloads.

> **Stuck on any step?** Skip to the **"If something goes wrong"** section
> at the bottom — there's a simple trick using ChatGPT/Claude that will
> almost certainly unstick you.

---

## Setup (Windows users only)

If you're on a **Mac**, skip this — go to Step 1.

If you're on **Windows**, you first need to install something called
**WSL2**, which is just a free Linux environment that comes with Windows.
This makes the rest of the instructions work.

1. Press the Start button, type `PowerShell`, **right-click** "Windows
   PowerShell", and choose **"Run as administrator"**. A blue window opens.
2. Paste this and press Enter:
   ```powershell
   wsl --install -d Ubuntu
   ```
3. **Restart your computer** when it asks.
4. After restart, a window labeled "Ubuntu" will open automatically and
   ask you to make up a username and password. Pick anything — this is
   for the Linux side, separate from your Windows login.
5. From now on, whenever the instructions say "open a terminal," you'll
   open **Ubuntu** from your Start menu.

Now follow the rest of the steps. The commands are identical to what a
Linux user would type.

---

## Step 1 — Open a terminal

- **Mac:** Press `Cmd+Space`, type `Terminal`, press Enter.
- **Windows:** Open **Ubuntu** from your Start menu.

A window opens with a `$` or `%` prompt. That's where you type. To "run a
command," you paste the command and press Enter. To paste, use
`Cmd+V` on Mac or `Ctrl+Shift+V` in Ubuntu.

## Step 2 — Install Go and Git

These are the two tools you need. Go is the programming language Conduit
is written in. Git downloads source code.

**On Mac:**

```bash
brew install go@1.24 git
brew unlink go 2>/dev/null
brew link --force go@1.24
```

If you don't have Homebrew (`brew`) yet, install it first by pasting this:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**On Windows (in your Ubuntu terminal) / Linux:**

```bash
sudo apt update
sudo apt install -y git make build-essential curl
curl -fsSL https://go.dev/dl/go1.24.13.linux-amd64.tar.gz -o /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
```

`sudo` will ask for your password. That's normal.

**Check it worked** (both OSes, paste this):

```bash
go version
```

You should see something like `go version go1.24.13 ...`. The number must
start with **1.24**. If it doesn't, the build will fail later — go back
and re-do this step.

## Step 3 — Download Conduit's source code

```bash
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/Psiphon-Inc/conduit.git
cd conduit/cli
make setup
```

That last line, `make setup`, prints a *lot* of `downloading...` lines and
takes 5–10 minutes. That's normal. Wait for it to finish (your prompt
will come back).

## Step 4 — Apply the IR-only patch

```bash
cd ~/repos/conduit/cli/psiphon-tunnel-core
curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/ir-only.patch | git apply
```

This downloads the 8-line patch from this repository and applies it. To
confirm it worked, paste:

```bash
grep "IR-only allowlist" psiphon/common/inproxy/proxy.go
```

If you see the words printed back at you, the patch is in place.

## Step 5 — Tell the build to use your patched code

```bash
cd ~/repos/conduit/cli
cat >> go.mod <<'EOF'

// Local fork: IR-only client allowlist patch
replace github.com/Psiphon-Labs/psiphon-tunnel-core => ./psiphon-tunnel-core
EOF
```

This appends two lines to a configuration file. There's no visible output
— that means it worked.

## Step 6 — Build the patched Conduit

```bash
cd ~/repos/conduit/cli
go mod tidy
make build
```

This takes a couple of minutes. When it finishes, you have a custom
Conduit binary at `~/repos/conduit/cli/dist/conduit`.

## Step 7 — Get a Psiphon config file

This is the one step that **isn't** a paste-able command. Psiphon's
network config belongs to Psiphon — it isn't included in this repo and
you have to ask them for it.

Email **`conduit-oss@psiphon.ca`** and say something like:

> Hi, I'd like to run Conduit built from source. Could you send me a
> network config file?

When they reply with a `psiphon_config.json` file, save it to:

```
~/repos/conduit/cli/dist/psiphon_config.json
```

(On Mac, that path means `/Users/yourname/repos/conduit/cli/dist/psiphon_config.json`. On WSL2 Ubuntu, you can drag the file into the terminal window or use `mv ~/Downloads/psiphon_config.json ~/repos/conduit/cli/dist/`.)

---

## Running it

Once your config is in place:

```bash
cd ~/repos/conduit/cli/dist
./conduit start -c psiphon_config.json -m 10 -b 20
```

- `-m 10` — at most 10 users at a time (start small, you can increase later)
- `-b 20` — at most 20 Mbps total bandwidth shared between them
  (use `-b -1` for "unlimited")

You'll see logs scroll by. To stop, press **`Ctrl+C`**.

### How to know it's working

About a minute after startup, watch for:

- `Starting Psiphon Conduit` — it launched
- `inproxy proxy: announce` — it's telling Psiphon you're available
- `client region not allowed` — your IR-only filter is doing its job
  (rejecting a non-Iran user)
- `inProxyActivityStats` with byte counts — **someone in Iran is using
  your proxy 🎉**

If you only see "client region not allowed" and never see actual
traffic, that's fine. It just means right now Psiphon happens to be
trying to send you non-Iranian users. Demand from Iran fluctuates. Leave
it running.

---

## If something goes wrong

The single most useful thing you can do is **ask an AI assistant** like
ChatGPT, Claude, or Gemini.

1. Find the error message in your terminal (usually the last few red or
   bold lines).
2. Highlight it with your mouse, copy it (Cmd+C / Ctrl+Shift+C).
3. Open ChatGPT (or Claude, or any AI chat).
4. Paste this:

   > I'm following the instructions at
   > https://github.com/adpunt/conduit-ir-patch and got this error:
   >
   > [paste your error here]
   >
   > Which step does this look like a problem with, and how do I fix it?

The AI can read this README, understand which step you were on, and walk
you through the fix. This works astonishingly well — better than trying
to follow generic troubleshooting guides.

If the AI's suggestion doesn't work, paste its response back, then your
new error, and ask again. Two or three rounds will usually resolve it.

If you're still stuck after that, open an issue at
https://github.com/adpunt/conduit-ir-patch/issues with the error and the
step you were on.

---

## How to verify this isn't doing anything sketchy

You're about to run code on your computer. Healthy paranoia is good.
Here's what to check:

### What this repository contains

This repo is **tiny** — five files, less than 200 lines of code:

| File | What it is |
|---|---|
| `ir-only.patch` | The actual change to Psiphon's code. 8 lines of Go. |
| `install.sh` | An installer script (used by CI; you don't need it). |
| `README.md` | This file. |
| `NOTICE.md` | Attribution and disclaimer. |
| `LICENSE` | GPL-3.0 text (same license Psiphon uses). |

**The instructions above do not run `install.sh`.** They walk you through
each command manually. You can see every command before you paste it.

### The patch itself

Here is the entire functional change. You can see it in
[`ir-only.patch`](ir-only.patch):

```go
clientRegion := announceResponse.ClientRegion

// IR-only allowlist (local fork). Reject non-IR matched clients with a
// non-backoff error so the announce loop immediately re-announces and the
// broker tries to match a different client.
if clientRegion != "IR" {
    return false, errors.TraceNew("client region not allowed")
}
```

That's it. Four lines of actual logic. The patch:

- **Does** check the country code of each incoming user and skip them if
  they aren't from Iran
- **Does not** send any data anywhere
- **Does not** modify Psiphon's encryption, certificates, or signing keys
- **Does not** install any background services
- **Does not** read any of your files

### Where does the actual Conduit code come from?

Step 3 downloads Conduit directly from **Psiphon's own GitHub repository**
(`github.com/Psiphon-Inc/conduit`). This repo only contributes the 8-line
patch — everything else is fetched from Psiphon's official source. So you
are running 99.99% Psiphon-Inc code plus our 8-line addition.

### Continuous Integration

The `install.sh` script in this repo is automatically tested on fresh
Ubuntu and macOS machines by GitHub every time anything changes. You can
see the test results at
[Actions](https://github.com/adpunt/conduit-ir-patch/actions). If you
ever see a red ✗ there, don't run anything in this repo until it's
green again.

---

## Below the fold

### Privacy and what your computer is actually doing

- Your computer will encrypt and pass through other people's web traffic.
  You **don't** see what they're doing. They **don't** see who you are.
- Your ISP will see an unusual amount of encrypted traffic to and from
  your computer. In most countries this is fine. In a few it isn't.
- This is **not** the same as using Psiphon yourself to bypass
  censorship. If *you* want to bypass censorship, install the regular
  [Psiphon app](https://psiphon.ca/), not this.

### Updating later

Every few months Psiphon updates Conduit. To get those updates while
keeping your IR-only patch:

```bash
cd ~/repos/conduit && git pull
cd cli/psiphon-tunnel-core && git pull
cd ~/repos/conduit/cli/psiphon-tunnel-core
curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/ir-only.patch | git apply
cd ~/repos/conduit/cli
make build
```

If `git apply` fails, Psiphon changed something near the patched lines.
Ask ChatGPT/Claude to help you re-apply by hand.

### Running it permanently in the background

```bash
cd ~/repos/conduit/cli/dist
nohup ./conduit start -c psiphon_config.json -m 10 -b 20 > conduit.log 2>&1 &
```

Stop it later with `pkill -f "conduit start"`.

### Credit

All of Conduit and `psiphon-tunnel-core` is the work of **Psiphon Inc.**
and its many contributors. The hard parts — circumvention protocols,
WebRTC negotiation, server matchmaking, the entire Psiphon network —
are all theirs. This repo is an 8-line tweak.

If you find this useful and want to support the underlying project, the
best thing you can do is **also run the [official Conduit](https://github.com/Psiphon-Inc/conduit)** on a second device.
It helps people from every censored country, not just Iran.

### License

GPL-3.0, the same license Psiphon uses. See [`LICENSE`](LICENSE) and
[`NOTICE.md`](NOTICE.md) for details.

---

## Maintainer notes (for whoever owns this repo)

This section is for the person maintaining `conduit-ir-patch`, not for
end users. If you're just installing Conduit, ignore everything below.

### When to update this repo

Psiphon's `staging-client` branch in `psiphon-tunnel-core` moves often.
You should check in on this repo at least every **1–2 months** and after
any major Conduit release. The two things that go stale are:

1. **The patch itself** — if Psiphon refactored `proxyOneClient` in
   `psiphon/common/inproxy/proxy.go`, `git apply ir-only.patch` will start
   failing for users.
2. **The Go version pin** — Psiphon may eventually move to Go 1.25+ or
   require a newer minimum. The `install.sh` and README still tell users
   to install Go 1.24.

The CI on this repo (`.github/workflows/test-install.yml`) runs the full
install on fresh Ubuntu and macOS every time you push, **and** on a
weekly schedule. If you wake up to a red ✗, upstream broke us.

### Quick health check

Without changing anything, you can verify the patch still applies cleanly:

```bash
cd /tmp
rm -rf check-patch && git clone --depth 1 https://github.com/Psiphon-Labs/psiphon-tunnel-core.git -b staging-client check-patch
cd check-patch
curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/ir-only.patch | git apply --check
```

If `--check` exits 0, you're fine. If it complains about hunks failing,
the patch needs updating.

### How to refresh the patch when it breaks

```bash
# 1. Clone fresh and build a working version locally
cd ~/repos
rm -rf conduit-refresh
git clone https://github.com/Psiphon-Inc/conduit.git conduit-refresh
cd conduit-refresh/cli
make setup

# 2. Manually re-apply the 4-line check in the new proxy.go
#    Find the line: `clientRegion := announceResponse.ClientRegion`
#    Insert immediately after it:
#
#      if clientRegion != "IR" {
#          return false, errors.TraceNew("client region not allowed")
#      }
#
#    (plus a 3-line comment block above it, see ir-only.patch)

# 3. Commit on a local branch of the tunnel-core clone
cd psiphon-tunnel-core
git checkout -b ir-only-filter
git add psiphon/common/inproxy/proxy.go
git commit -m "Hardcode IR-only client allowlist in proxyOneClient"

# 4. Regenerate the .patch file
git format-patch -1 HEAD --stdout > ~/repos/conduit-ir-patch/ir-only.patch

# 5. Commit and push the updated patch
cd ~/repos/conduit-ir-patch
git add ir-only.patch
git commit -m "Refresh patch against latest staging-client (<date>)"
git push
```

CI will run automatically on the push and confirm the new patch works on
both OSes.

### How to update the Go version requirement

If Conduit's `Makefile` ever bumps `GO_REQUIRED_VERSION` (currently
`1.24`), search-and-replace `1.24` → `<new version>` in:

- `README.md` (multiple places)
- `install.sh` (the Linux Go install URL and version checks)
- `.github/workflows/test-install.yml` (no explicit pin — it uses
  install.sh — but verify CI still passes)

Then push and check CI.

### Sanity-check the README against `install.sh`

The README walks users through commands by hand; `install.sh` does the
same commands inside CI. These two **must stay in sync** or CI will pass
while real users hit problems (or vice versa). Specifically check:

- Apt packages installed (Linux)
- Homebrew packages installed (macOS)
- Go install method/URL
- `make setup` step
- Patch URL
- `go.mod` replace directive text
- Build command

If you change one, change the other.

### When to delete this repo

If Psiphon ever ships per-country filtering as a first-class feature
(e.g., a `--allowed-regions IR` flag on the official binary), this patch
becomes unnecessary. At that point, archive the repo with a final commit
that points users at the official mechanism.
