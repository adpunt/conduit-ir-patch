# Conduit IR-only

A modified build of [**Psiphon Conduit**](https://github.com/Psiphon-Inc/conduit)
that relays internet traffic **only for people in Iran**.

Conduit is a program you run on a computer at home. Psiphon — a long-running
anti-censorship project — uses a slice of your internet to help people in
censored countries get online. The official version helps anyone in any
censored country. This version is narrower: only Iran.

> ⚠️ **Unofficial.** Not made by, endorsed by, or supported by Psiphon Inc.
> If something goes wrong, don't email them about it. See [`NOTICE.md`](NOTICE.md).

---

## 🤖 Never done anything like this before?

**Open ChatGPT, Claude, or any AI assistant. Paste the message below.** It
will walk you through every step, answer your questions, and debug anything
that goes wrong.

> I want to follow the instructions at
> https://github.com/adpunt/conduit-ir-patch to run a patched version of
> Psiphon Conduit on my computer that only helps people in Iran. Please
> read that README and guide me through it one step at a time. Ask me what
> operating system I'm using, then tell me each step in plain English. If
> anything I paste back to you looks like an error, help me fix it before
> moving on.

This is genuinely the easiest way. It works.

---

## Should I do this?

**Yes**, if you want to help people in Iran specifically and you have a
computer with a reliable internet connection that's on most of the day.

**No**, if:

- You'd rather help users from any censored country — use the
  [official Conduit](https://github.com/Psiphon-Inc/conduit) instead.
- You're on a slow or metered connection.
- You're in a country where running a circumvention proxy is illegal.

---

## Three steps

### 1. Download the patched Conduit

Go to the [**latest release**](https://github.com/adpunt/conduit-ir-patch/releases/latest)
and download the file that matches your computer:

| Your computer | File to download |
|---|---|
| Mac with Apple Silicon (M1/M2/M3/M4) | `conduit-ir-darwin-arm64` |
| Mac with Intel chip | `conduit-ir-darwin-amd64` |
| Windows | `conduit-ir-windows-amd64.exe` |
| Linux, normal PC | `conduit-ir-linux-amd64` |
| Raspberry Pi or other ARM Linux | `conduit-ir-linux-arm64` |

Also download `extract-config.py` from the same release — you'll need it
in step 2.

> **Don't know which Mac you have?** Click the Apple menu → *About This Mac*.
> If it says "Apple M…" you have Apple Silicon. If it says "Intel" you have
> Intel.

After downloading, put both files in a folder you'll remember — `Downloads`
is fine, or make a new folder called `conduit`.

### 2. Get a Psiphon config file

The patched Conduit needs a **network config** to know how to talk to
Psiphon's servers. This file belongs to Psiphon and isn't included in this
download. Here's how to get one:

1. **Download the official Conduit** from
   [Psiphon's releases page](https://github.com/Psiphon-Inc/conduit/releases/latest).
   Pick the file for your OS.
2. **Run the extraction script** to copy the config out of the official
   binary. Open a terminal, navigate to your folder, and run:

   - **Mac/Linux:**
     ```bash
     python3 extract-config.py /path/to/official-conduit-binary > psiphon_config.json
     ```

   - **Windows (Command Prompt or PowerShell):**
     ```cmd
     python extract-config.py C:\path\to\official-conduit-binary.exe > psiphon_config.json
     ```

   Python 3 ships with macOS and most Linux distros. On Windows, install it
   from [python.org/downloads](https://www.python.org/downloads/) (tick "Add
   Python to PATH" during install).

You should now have `psiphon_config.json` in your folder. It's about 10 KB.

> **Why is this needed?** The official Conduit has the config baked inside
> it. We can't legally redistribute it in our patched build, so the
> extraction script copies it out of *your* download of the official
> version.

### 3. Run it

In a terminal, in the same folder:

- **Mac/Linux:**
  ```bash
  chmod +x conduit-ir-*
  ./conduit-ir-darwin-arm64 start -c psiphon_config.json -m 10 -b 20
  ```
  (Replace `darwin-arm64` with whichever file you downloaded.)

- **Windows:**
  ```cmd
  conduit-ir-windows-amd64.exe start -c psiphon_config.json -m 10 -b 20
  ```

What the flags mean:

- `-m 10` — at most 10 simultaneous users at once (start small)
- `-b 20` — at most 20 Mbps total bandwidth (`-b -1` = unlimited)

To stop the program, press **`Ctrl+C`** in the terminal.

> **Mac says "cannot be opened, developer cannot be verified"?** This is
> expected for any program not bought from the App Store. Open Finder,
> right-click the binary, choose **Open**, then click **Open** in the
> warning dialog. You only need to do this once.
>
> **Windows shows a blue SmartScreen warning?** Click "More info", then
> "Run anyway". Same idea.

---

## How to know it's working

About a minute after startup, watch the terminal for:

- `Starting Psiphon Conduit` — it launched
- `inproxy proxy: announce` — telling Psiphon you're available
- `client region not allowed` — the IR filter is doing its job (rejecting
  a non-Iran user)
- `inProxyActivityStats` with byte counts — **someone in Iran is using your
  proxy** 🎉

If you only see "client region not allowed" and never see real traffic,
that's fine. Iran demand fluctuates. Leave it running.

---

## How to verify this isn't sketchy

The repository contains five small files. You can read every line:

| File | Purpose |
|---|---|
| [`ir-only.patch`](ir-only.patch) | The 8-line change to Psiphon's code |
| [`extract-config.py`](extract-config.py) | The Python script that copies the config out of your official Conduit binary |
| [`install.sh`](install.sh) | Used by CI to test the build (you don't run it) |
| [`README.md`](README.md) | This file |
| [`NOTICE.md`](NOTICE.md), [`LICENSE`](LICENSE) | Attribution + GPL-3.0 |

**The patch itself, in full:**

```go
clientRegion := announceResponse.ClientRegion

if clientRegion != "IR" {
    return false, errors.TraceNew("client region not allowed")
}
```

That's it. The binaries on the Releases page are built automatically by
GitHub from the source code in this repository plus Psiphon's official
source — see the [Actions tab](https://github.com/adpunt/conduit-ir-patch/actions).
If the most recent run shows a red ✗ instead of a green ✓, don't download
until it's fixed.

---

## Build it yourself (optional)

If you'd rather build from source than trust our binaries, the process is
straightforward but takes ~30 minutes the first time. You need
[Go 1.24](https://go.dev/dl/) (specifically 1.24, not 1.25+), Git, and
`make`.

```bash
git clone https://github.com/Psiphon-Inc/conduit.git ~/repos/conduit
cd ~/repos/conduit/cli
make setup
cd psiphon-tunnel-core
curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/ir-only.patch | git apply
cd ..
cat >> go.mod <<'EOF'

replace github.com/Psiphon-Labs/psiphon-tunnel-core => ./psiphon-tunnel-core
EOF
go mod tidy
make build
```

Your binary will be at `~/repos/conduit/cli/dist/conduit`.

On Windows, do this inside WSL2 (run `wsl --install -d Ubuntu` from an
elevated PowerShell, restart, then open Ubuntu from Start menu).

---

## Updating

When Psiphon releases new versions of Conduit, this repo will publish a
new release within a few weeks. Just download the latest binary from
[Releases](https://github.com/adpunt/conduit-ir-patch/releases) and
replace your old one. Your config file stays the same.

---

## Privacy notes

- Your computer encrypts and forwards other people's web traffic. You
  **don't** see what they're doing. They **don't** see who you are.
- Your ISP will see unusual amounts of encrypted traffic to and from your
  computer. In most countries this is fine — know your local laws.
- This is **not** the same as using Psiphon yourself to bypass censorship.
  If *you* want to bypass censorship, install the regular
  [Psiphon app](https://psiphon.ca/), not this.

---

## Credit

All of Conduit and `psiphon-tunnel-core` is the work of **Psiphon Inc.**
and its contributors over more than a decade. The hard parts —
circumvention protocols, WebRTC negotiation, server matchmaking, the
network itself — are all theirs.

This repository is an 8-line tweak. It only exists because Psiphon
generously licenses their work under [GPL-3.0](LICENSE), which explicitly
permits modifications like this.

If you find this useful, the best thing you can do to support the
underlying project is to **also run the
[official Conduit](https://github.com/Psiphon-Inc/conduit)** on a second
device. It helps people from every censored country.

See [`NOTICE.md`](NOTICE.md) for the full disclaimer.
