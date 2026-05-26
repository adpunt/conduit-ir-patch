# Conduit, but only for Iran

This is a small patch to **Psiphon Conduit** that makes your Conduit proxy
help **only people connecting from Iran**. Conduit normally helps anyone in
any censored country. This patch turns down everyone except people in Iran.

> ⚠️ **Important:** This is an unofficial patch. It is not affiliated with,
> endorsed by, or supported by Psiphon Inc. If something goes wrong, do
> **not** contact Psiphon about it. See `NOTICE.md` for full attribution.

---

## What Conduit is, in plain English

Psiphon is a free tool that helps people get around internet censorship in
countries like Iran, China, and Russia. **Conduit** is a companion program:
you run it on your home computer, and it lets Psiphon use a small slice of
your internet connection to relay traffic for people stuck behind censorship.

You don't see what they do. They don't see who you are. Psiphon's servers sit
in the middle and handle all of that.

Psiphon's official version of Conduit will match you with users from
**any** censored country. This patched version matches you with users from
**Iran only**.

## Why someone might want this

You might prefer to help users from one specific country if:

- You are donating to a particular cause (e.g. Iranian protesters)
- You want to be sure your bandwidth is going where you think it is

You probably **do not** want this if:

- You just want to help as many people as possible — use the official
  Conduit instead. It will match you to wherever demand is highest, which is
  more efficient overall.

## What this actually does to the code

The patch adds **8 lines** to one file in Psiphon's open-source code. When
Psiphon's matchmaking server offers you a user to relay, your proxy now
checks the country code. If it isn't `IR` (Iran), it politely refuses and
asks for a different user. That's the whole change.

The patch is the file `ir-only.patch` in this repository. You can read it.
It's three lines of logic plus a comment.

---

## What you need before you start

You'll need:

1. **A Mac or Linux computer** that stays on. (Windows is possible but these
   instructions are for macOS/Linux. Windows users: use WSL2 and follow the
   Linux steps.)
2. **About 1 GB of free disk space.**
3. **About 30 minutes** the first time (mostly waiting for things to
   download).
4. **A Psiphon config file** — see "Getting a Psiphon config" below. This is
   the part that isn't included in this repo and that you have to obtain
   yourself.
5. **Comfort with copy-pasting commands into a Terminal.** If you've never
   opened Terminal before, that's fine — just follow along carefully. Each
   command does one specific thing and is explained.

You **don't** need a GitHub account, a developer license, or any prior
programming knowledge.

---

## Step 1 — Open Terminal

On a Mac: press `Cmd+Space`, type `Terminal`, press Enter. A black or white
window will appear with a `$` or `%` prompt. That's Terminal. You'll paste
commands into it and press Enter to run them.

On Linux: open your usual terminal app.

## Step 2 — Install the tools

You need two programs: **Homebrew** (a package manager for Mac) and **Go**
(the programming language Conduit is written in).

### Install Homebrew (skip if you already have it)

Paste this into Terminal and press Enter. It will ask for your password:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This downloads and installs Homebrew. It takes a few minutes.

### Install Go version 1.24

Conduit requires **specifically Go 1.24** (newer versions don't work with
some of Psiphon's code). Paste:

```bash
brew install go@1.24
brew unlink go 2>/dev/null
brew link --force go@1.24
```

To check it worked, run:

```bash
go version
```

You should see something like `go version go1.24.13 darwin/amd64`. The `1.24`
part is what matters.

On Linux, install Go 1.24 from https://go.dev/dl/ — pick the file named like
`go1.24.x.linux-amd64.tar.gz` and follow the instructions on that page.

### Install Git (if you don't have it)

On macOS, type `git --version` in Terminal. If it asks you to install command
line tools, click "Install". On Linux, use your package manager
(`sudo apt install git` on Ubuntu/Debian).

## Step 3 — Get the source code

Make a folder to keep everything in, then download Psiphon's Conduit source:

```bash
mkdir -p ~/repos
cd ~/repos
git clone https://github.com/Psiphon-Inc/conduit.git
```

This downloads the official Conduit source code from Psiphon. About 50 MB.

Now download the helper code Conduit needs:

```bash
cd ~/repos/conduit/cli
make setup
```

This will print a lot of "downloading..." lines. Wait for it to finish.
About 5–10 minutes depending on your connection.

## Step 4 — Apply this patch

Download the patch file from this repository and apply it to the source
code:

```bash
cd ~/repos/conduit/cli/psiphon-tunnel-core
curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/conduit-ir-patch/main/ir-only.patch | git apply
```

> **Replace `YOUR_GITHUB_USERNAME`** with whatever GitHub user/org actually
> hosts this repo. If you got this file outside of GitHub, you can also save
> `ir-only.patch` somewhere on disk and run `git apply /path/to/ir-only.patch`
> instead.

You can verify the patch landed by running:

```bash
grep -A1 "IR-only allowlist" psiphon/common/inproxy/proxy.go
```

You should see the comment and the `if clientRegion != "IR"` line printed
back to you.

## Step 5 — Tell Conduit to use your patched code

Open the file `~/repos/conduit/cli/go.mod` in any text editor (TextEdit is
fine on Mac). Scroll to the bottom. Add these two lines at the very end:

```
// Local fork: IR-only client allowlist patch in psiphon/common/inproxy/proxy.go
replace github.com/Psiphon-Labs/psiphon-tunnel-core => ./psiphon-tunnel-core
```

Save the file. This tells the build to use *your* patched copy of Psiphon's
code instead of downloading the unpatched version from the internet.

## Step 6 — Build it

```bash
cd ~/repos/conduit/cli
go mod tidy
make build
```

`go mod tidy` updates some internal bookkeeping. `make build` compiles the
program. It will take a couple of minutes the first time. When it's done,
your custom Conduit binary lives at:

```
~/repos/conduit/cli/dist/conduit
```

## Step 7 — Getting a Psiphon config

This is the part that is **not in this repo**, because the config file
belongs to Psiphon, not to me.

You have two options:

**Option A — Ask Psiphon nicely (recommended).** Email
`conduit-oss@psiphon.ca` and explain you'd like to run Conduit from source.
They handle this kind of request.

**Option B — Extract from an official release.** Download the official
Conduit release for your platform from
https://github.com/Psiphon-Inc/conduit/releases — the config is embedded
inside the binary. Extracting it is a couple of lines of Python; you can
find the technique online by searching for "extract go:embed". This is a
grey area: the config isn't secret (it's inside every public release), but
some people consider repackaging it impolite. Use your own judgment.

Whichever you do, save the file as `psiphon_config.json` in
`~/repos/conduit/cli/dist/`.

## Step 8 — Run it

```bash
cd ~/repos/conduit/cli/dist
./conduit start -c psiphon_config.json -m 10 -b 20
```

This starts your Conduit proxy with:
- `-c psiphon_config.json` — the config you just put there
- `-m 10` — at most 10 simultaneous users at a time
- `-b 20` — capped at 20 Mbps total bandwidth

Adjust `-m` and `-b` to whatever you're comfortable with. Use `-m 5 -b 5`
for very conservative, `-m 50 -b -1` for "give everything I've got." For
testing, `-m 1 -b 5` is fine.

You will see a lot of log lines fly by. That's normal.

## How to know it's working

The proxy takes about a minute to fully start up. After that, look for
these lines:

- `Starting Psiphon Conduit (...)` — confirms it launched
- `inproxy proxy: announce` — confirms you're telling Psiphon you're
  available
- `client region not allowed` — confirms the IR filter is doing its job
  (rejecting a non-Iran user)
- `inProxyActivityStats` with byte counts — someone in Iran is actually
  using your proxy 🎉

If you only see `client region not allowed` and never see actual traffic,
that's fine — it just means right now Psiphon happens to be sending you
non-Iran users. Leave it running. Demand from Iran fluctuates by time of
day.

## How to stop it

Press `Ctrl-C` in the Terminal window. You'll see "Shutting down..." and
then "Stopped." That's it.

## Running it in the background (optional)

If you want it to keep running while you close Terminal, the simplest way
is `nohup`:

```bash
cd ~/repos/conduit/cli/dist
nohup ./conduit start -c psiphon_config.json -m 10 -b 20 > conduit.log 2>&1 &
```

To stop it later:

```bash
pkill -f "conduit start"
```

To watch its log:

```bash
tail -f ~/repos/conduit/cli/dist/conduit.log
```

For a proper "always running" setup, look up `launchd` (macOS) or `systemd`
(Linux) — but that's beyond the scope of this guide.

---

## Troubleshooting

**"go: command not found"** — Go isn't installed or isn't on your PATH. Run
the `brew install go@1.24` step again.

**"Error: psiphon config required"** — You haven't put `psiphon_config.json`
next to the binary. See Step 7.

**Logs say "no broker specs" forever** — Wait a minute or two. On first run
Conduit has to download a server list before it can do anything. If it
still isn't working after 5 minutes, your config file may not be valid.

**Logs say "Go 1.25 detected, but Go 1.24.x is required"** — You're on the
wrong Go version. Run `brew unlink go && brew link --force go@1.24`.

**The patch won't apply ("patch does not apply")** — Psiphon's code has
moved since the patch was written. Open `ir-only.patch` and apply the
change by hand: in `psiphon/common/inproxy/proxy.go`, find the line that
says `clientRegion := announceResponse.ClientRegion` and paste the 6 lines
of `if clientRegion != "IR" { ... }` below it. Then re-run Step 6.

**I'm seeing no traffic at all** — Right now there may simply be no Iranian
users matched to you. Try leaving it running for an hour. If still nothing,
double-check your config file is valid by running the unpatched official
Conduit binary with the same config — if *that* sees traffic and yours
doesn't, the patch is working as intended (the broker isn't sending IR
users to you specifically).

---

## Updating later

Psiphon updates Conduit frequently. Every few months you may want to pull
in their latest fixes:

```bash
cd ~/repos/conduit && git pull
cd cli/psiphon-tunnel-core && git pull
cd ~/repos/conduit/cli/psiphon-tunnel-core
git apply ~/path/to/ir-only.patch
cd ~/repos/conduit/cli
make build
```

If `git apply` fails because Psiphon has changed the file around your
patch, you'll need to apply the 6-line change by hand (see Troubleshooting).

---

## Credit where it's due

**Conduit and `psiphon-tunnel-core` are the work of Psiphon Inc. and its
many contributors over more than a decade.** The hard parts — circumvention
protocols, WebRTC negotiation, server matchmaking, the network itself —
are all theirs. None of it is mine.

This repository is an 8-line tweak. It only exists because Psiphon
generously licenses their work under GPL-3.0, which explicitly permits
modifications like this.

If you find this patch useful and want to support the underlying project,
the best thing you can do is also run the **official** Conduit alongside
this one. The official version helps users from every censored country,
not just Iran.

See `NOTICE.md` for the full disclaimer and `LICENSE` for the GPL-3.0
license text.

---

## Privacy and safety notes

- **You will be acting as a relay for someone else's encrypted internet
  traffic.** You do not see what they are doing. They are protected by
  Psiphon's encryption.
- **You will not see who is using your proxy** (no IP addresses, no
  identities, no browsing history).
- **Your ISP will see** an unusual amount of encrypted traffic going to and
  from your computer. In most countries this is fine. In some countries,
  running a circumvention proxy may itself be discouraged or illegal —
  know your local laws.
- **This is not a substitute for using Psiphon as a user.** If *you* are
  the one trying to bypass censorship, you want the regular Psiphon app,
  not Conduit.
