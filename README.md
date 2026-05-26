# Conduit IR-only

A modified build of [**Psiphon Conduit**](https://github.com/Psiphon-Inc/conduit)
that relays internet traffic **only for people in Iran**.

Conduit is a program you run on a computer at home. Psiphon — a long-running
anti-censorship project — uses a slice of your internet to help people in
censored countries get online. The official version helps anyone in any
censored country. This version is narrower: only Iran.

## The entire change

This is the whole modification, in [`ir-only.patch`](ir-only.patch). Four
lines of logic added to Psiphon's source code:

```go
clientRegion := announceResponse.ClientRegion

if clientRegion != "IR" {
    return false, errors.TraceNew("client region not allowed")
}
```

It checks the country of each user the Psiphon broker wants to send to
your computer. If they aren't in Iran, your computer politely declines
and waits for the next one.

The downloadable binaries on the [Releases page](https://github.com/adpunt/conduit-ir-patch/releases)
are built automatically by GitHub: it clones Psiphon's official source,
applies that 8-line patch, compiles, and uploads. You can watch this
happen in the [Actions tab](https://github.com/adpunt/conduit-ir-patch/actions).

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

### Before you start: make a folder

Create one folder where everything will live. This makes the rest easy
because you won't need to type long paths.

- **Mac:** Open Finder → click on your home folder → `File → New Folder` →
  name it `conduit-ir`.
- **Windows:** Open File Explorer → go to your home folder (e.g.
  `C:\Users\YourName`) → right-click → New Folder → name it `conduit-ir`.
- **Linux:** `mkdir ~/conduit-ir`.

You'll put three files in this folder before the end.

### 1. Download the patched Conduit + the config tool

Open the [**latest release**](https://github.com/adpunt/conduit-ir-patch/releases/latest)
in your browser. You need **two files**, both matching your computer:

| Your computer | Conduit binary | Config tool |
|---|---|---|
| Mac with Apple Silicon (M1/M2/M3/M4) | `conduit-ir-darwin-arm64` | `extract-config-darwin-arm64` |
| Mac with Intel chip | `conduit-ir-darwin-amd64` | `extract-config-darwin-amd64` |
| Windows | `conduit-ir-windows-amd64.exe` | `extract-config-windows-amd64.exe` |
| Linux, normal PC | `conduit-ir-linux-amd64` | `extract-config-linux-amd64` |
| Raspberry Pi or other ARM Linux | `conduit-ir-linux-arm64` | `extract-config-linux-arm64` |

Click each filename in the Releases page to download. Both files **must
go into your `conduit-ir` folder** from the previous step.

> **Don't know which Mac you have?** Click the Apple menu → *About This Mac*.
> "Apple M…" = Apple Silicon. "Intel" = Intel.
>
> **What's inside the binary?** Psiphon's official Conduit source, plus
> the 4-line patch shown at the top of this README. GitHub's CI builds it
> automatically from public source — see [Actions](https://github.com/adpunt/conduit-ir-patch/actions).

### 2. Get a Psiphon config file

The patched Conduit needs a **network config** to talk to Psiphon's
servers. This file belongs to Psiphon, so we don't ship it in our
download — but every official Conduit release already has it baked in.
The config tool you downloaded copies it out for you.

**Step 2a — Download the official Conduit.** Go to
[Psiphon's releases page](https://github.com/Psiphon-Inc/conduit/releases/latest)
and download whichever file matches your OS. Save it to your
`conduit-ir` folder. Now you have three files in there.

**Step 2b — Open a terminal in your folder.**

- **Mac:** Open Finder, right-click your `conduit-ir` folder, choose
  *"New Terminal at Folder"*. (If you don't see that option: open Terminal
  from Applications → Utilities, then type `cd ~/conduit-ir` and press
  Enter.)
- **Windows:** Open your `conduit-ir` folder in File Explorer, click in
  the address bar at the top, type `cmd` and press Enter. A Command Prompt
  opens already inside the folder.
- **Linux:** `cd ~/conduit-ir` in any terminal.

**Step 2c — Run the config tool.** This is one command. The trick: type
the start, then **drag the official Conduit file from your folder into
the terminal window** — your computer will paste the filename for you.

- **Mac/Linux:** First, make the tool runnable (one-time, paste exactly):

  ```bash
  chmod +x extract-config-* conduit-ir-*
  ```

  Then type `./extract-config-` followed by your platform name (e.g.
  `darwin-arm64`), then a space, then **drag the official Conduit file
  into the terminal**. You'll end up with something like:

  ```bash
  ./extract-config-darwin-arm64 conduit-mac-1.8.0-RC.2.dmg
  ```

  Press Enter. You'll see: `✓ Wrote psiphon_config.json (10142 bytes) in the current folder.`

- **Windows:** Same idea — type `extract-config-windows-amd64.exe`, then
  a space, then drag the official Conduit `.exe` into the window. Final
  command looks like:

  ```cmd
  extract-config-windows-amd64.exe conduit-windows-amd64.exe
  ```

You now have a fourth file in your folder: `psiphon_config.json` (~10 KB).

### 3. Run it

Still in your terminal, in the same folder:

- **Mac/Linux:**
  ```bash
  ./conduit-ir-darwin-arm64 start -c psiphon_config.json -m 10 -b 20
  ```
  (Replace `darwin-arm64` with whatever you actually downloaded.)

- **Windows:**
  ```cmd
  conduit-ir-windows-amd64.exe start -c psiphon_config.json -m 10 -b 20
  ```

What the flags mean:

- `-m 10` — at most 10 simultaneous users at once (start small)
- `-b 20` — at most 20 Mbps total bandwidth (`-b -1` = unlimited)

To stop the program, press **`Ctrl+C`** in the terminal.

> **Mac says "cannot be opened, developer cannot be verified"?** Expected
> for any program not sold through the App Store. Open Finder, right-click
> the binary, choose **Open**, then click **Open** in the warning. Only
> needed once.
>
> **Windows shows a blue SmartScreen warning?** Click "More info" →
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

## What's in this repo

Everything is small and readable. Click any file to see its contents:

| File | Purpose |
|---|---|
| [`ir-only.patch`](ir-only.patch) | The actual change (shown at top of this README) |
| [`extract-config/`](extract-config/) | Source code of the config-extraction tool |
| [`install.sh`](install.sh) | Used by CI to test the build (you don't run it) |
| [`NOTICE.md`](NOTICE.md), [`LICENSE`](LICENSE) | Attribution + GPL-3.0 |

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
