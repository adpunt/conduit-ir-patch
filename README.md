# Conduit IR-only

A modified version of [**Psiphon Conduit**](https://github.com/Psiphon-Inc/conduit)
that relays internet traffic **only for people in Iran**.

> **Unofficial. Not affiliated with Psiphon Inc.** See [`NOTICE.md`](NOTICE.md).

---

## What is Conduit

Conduit lets people in regions with internet censorship route their internet through your 
device. Their requests travel encrypted to your machine, then out
to the wider internet from your IP. Blocked websites see your IP,
not theirs. Their internet provider sees encrypted traffic going to
your computer, but can't see what's inside.

**The scale.** During the January 2026 blackout, [Iran International
reported](https://www.iranintl.com/en/202601240957) more than 40,000
Iranians connected through Conduit volunteers at once, out of 2.8
million daily connection attempts from inside Iran. Iran has more
Psiphon users than any country in the world. The standard Conduit
mobile app caps each volunteer at 25 simultaneous users; this
command-line build lets you raise that ceiling on a machine that can
handle it (50 is a comfortable starting point — see Step 3).

**What it's good for.** Conduit is built for getting through
censorship, and it's good at that job. It reliably unblocks the
everyday internet for Iranians — news, WhatsApp/Telegram/Signal,
social media, video calls with family, journals, banking — in places
where commercial VPNs are blocked, because Psiphon disguises its
traffic to look like ordinary browsing. For most Iranians most of
the time, "I can reach the open internet at all" is the thing that
matters, and that's what Conduit delivers.

Where it falls short: Psiphon doesn't claim to be a privacy or
anonymity tool. Independent reviewers ([ProPrivacy](https://proprivacy.com/privacy-service/review/psiphon))
say it plainly: *"Psiphon does not increase your online privacy, and
should not be considered or used as an online security tool."*
Psiphon's own [privacy bulletins](https://psiphon.ca/en/privacy-bulletin.html)
note that its servers collect aggregated connection metadata
(timestamps, region/city codes, protocol type, bytes transferred) —
not the websites visited, but a footprint of each connection.
Independent security audits by Cure53 ([2017](https://cure53.de/pentest-report_psiphon.pdf),
[2019](https://cure53.de/pentest-report_psiphon_2.pdf), and
[2024 tunnel-core](https://cure53.de/pentest-report_psiphon_4.pdf))
found no catastrophic flaws, with a separate
[audit of the Conduit library itself](https://cure53.de/pentest-report_psiphon-conduit-library_2.pdf).
Traffic also exits from your home IP rather than bouncing through
multiple anonymous hops, so a determined state-level adversary
watching both ends of a connection could in principle correlate
them. You (the operator) can observe traffic patterns through your
machine, though not the content.

**What about Tor?** Tor is a different free anti-censorship tool
that's genuinely stronger for anonymity — it bounces every
connection through multiple servers run by strangers, so no single
hop knows both who you are and what you're doing. The catch is that
Iran has spent years making Tor impractical: the Tor Project's
[2025 censorship report](https://blog.torproject.org/staying-ahead-of-censors-2025/)
describes Tor's main entry method (obfs4 bridges) being blocked in
bulk, leaving Snowflake — slow and unstable — as the only widely
working transport. During the June 2025 Iran–Israel conflict and
again in January 2026, Iran cut external internet entirely for days.
Psiphon's protocol mimicry tends to keep working through those
events when Tor doesn't.

Compared to a **paid VPN** (NordVPN, Mullvad, ExpressVPN, etc.), the
shape is similar: encrypted tunnel, the user's ISP can't see the
destination. Conduit is free, open source, and designed to keep
working where commercial VPNs are blocked. The trade-off is that it
runs on volunteer home computers, so speeds vary.

**If you're recommending this to family/friends:** it's a solid free
option for everyday access to blocked sites where nothing else
reliably works. For threat models where anonymity matters more than
reachability (whistleblowing, organising, anything that could get
someone arrested), a high-trust paid VPN or Tor over a working
transport is still the better answer — caveat that both can be hard
to come by inside Iran. Tell users not to log into identifying
accounts they wouldn't want associated with their connection.

---

## 🤖 Never done anything like this before?

**Paste the message below into ChatGPT, Claude, or any AI assistant.**
It'll walk you through every step and debug anything that breaks.

> Read https://github.com/adpunt/conduit-ir-patch and guide me through
> running this modified Psiphon Conduit one step at a time. Ask my OS,
> use plain English, help me fix any errors before moving on.

---

## Three steps

### 1. Download the modified Conduit + the config tool

Make a folder `conduit-ir` in your home folder. Everything lives there.

From the [**latest release**](https://github.com/adpunt/conduit-ir-patch/releases/latest),
click **Assets** to open the file list, then download both files for
your computer:

| Your computer | Conduit program | Config tool |
|---|---|---|
| Mac with Apple Silicon (M1/M2/M3/M4) | `conduit-ir-darwin-arm64` | `extract-config-darwin-arm64` |
| Mac with Intel chip | `conduit-ir-darwin-amd64` | `extract-config-darwin-amd64` |
| Windows | `conduit-ir-windows-amd64.exe` | `extract-config-windows-amd64.exe` |
| Linux, normal PC | `conduit-ir-linux-amd64` | `extract-config-linux-amd64` |
| Raspberry Pi / ARM Linux | `conduit-ir-linux-arm64` | `extract-config-linux-arm64` |

The Iran-only change is already built into the Conduit program. (Which
Mac? Apple menu → *About This Mac*. "Apple M…" = Apple Silicon.)

### 2. Get a Psiphon settings file

It's bad form to share Psiphon's settings file directly, but you can
pull it out of Psiphon's official Conduit program yourself.

**Step 2a.** From [Psiphon's releases](https://github.com/Psiphon-Inc/conduit/releases),
find the latest release starting with `release-cli-…`, click **Assets**
to open the file list, and download the file for your computer (same
name as in Step 1 but without `-ir`, e.g. `conduit-darwin-arm64`). Save
it to `conduit-ir`.

**Step 2b.** Open Terminal and point it at your `conduit-ir` folder:
- **Mac:** open Terminal (Applications → Utilities), type `cd ~/conduit-ir`, press Enter.
- **Windows:** in File Explorer at `conduit-ir`, click the address bar, clear it, type `cmd`, press Enter.
- **Linux:** `cd ~/conduit-ir`.

**Step 2c.** Mac/Linux only: give the files permission to run (you only
do this once):
```bash
chmod +x extract-config-* conduit-ir-*
```

Now run the config tool. Type the start of the command, then drag
the official Conduit file from Finder/Explorer onto your Terminal
window. That fills in its location for you.

**Mac/Linux** (swap `darwin-arm64` for whichever file you downloaded):
```bash
./extract-config-darwin-arm64 conduit-darwin-arm64
```

**Windows:**
```cmd
extract-config-windows-amd64.exe conduit-windows-amd64.exe
```

Press Enter. You'll see `✓ Wrote psiphon_config.json`.

### 3. Run it

**Mac/Linux** (swap `darwin-arm64` for whichever file you downloaded):
```bash
./conduit-ir-darwin-arm64 start -c psiphon_config.json -m 50 -b 20
```

**Windows:**
```cmd
conduit-ir-windows-amd64.exe start -c psiphon_config.json -m 50 -b 20
```

Stop the program any time with **`Ctrl+C`** (Mac: Control, not Command).

- `-m 50`: up to 50 people using your proxy at once
- `-b 20`: caps total speed at 20 Mbps (`-b -1` = no limit)

**Restart later:** repeat Step 2b to open a terminal in `conduit-ir`,
then run the same command above. The `chmod` step is one-time.

> **About `-m` and `-b`:** these are upper limits, not goals. In
> practice only about 10–30% of your `-m` number actually connect at
> once, and they usually use well under your `-b` cap. The maintainer
> runs `-m 200` on home fibre with no problem; start at 50, see how
> your computer handles it, raise it if it's coping fine.
>
> **First-run security popups.** Mac says "developer cannot be
> verified": right-click the file in Finder → **Open** → **Open**.
> Windows SmartScreen: click "More info" → "Run anyway".

---

## How to know it's working

About a minute after startup, watch the terminal for these lines:

- `[OK] Starting Psiphon Conduit (...)`: the program launched.
- `[ERROR] client region not allowed`: someone outside Iran tried to
  connect and your computer turned them away. You'll see a few of
  these at first, then they slow down. This is normal.
- `[STATS] Announcing: ... | Connecting: ... | Connected: ... | Up: ... | Down: ...`:
  when `Connected` is at least 1 and the `Up`/`Down` numbers are
  moving, **someone in Iran is using your proxy right now**.

`Connected` may sit at zero for stretches. Demand from Iran goes up
and down through the day.

---

## What changed in the code

Also in [`ir-only.patch`](ir-only.patch):

```go
clientRegion := announceResponse.ClientRegion

if clientRegion != "IR" {
    return false, errors.TraceNew("client region not allowed")
}
```

If someone outside Iran tries to connect, your computer turns them
down and moves on to the next person. 

---

## What's in this repo

| File | Purpose |
|---|---|
| [`ir-only.patch`](ir-only.patch) | The change |
| [`extract-config/`](extract-config/) | Source code of the config tool |
| [`install.sh`](install.sh) | Script GitHub uses to automatically fetch the source from Psiphon and apply the Iran-only patch (you don't run it) |
| [`NOTICE.md`](NOTICE.md), [`LICENSE`](LICENSE) | Credit to Psiphon + the open-source license |

---

## Build it yourself (optional)

If you'd rather build the program from source than trust the
ready-made version. ~30 minutes first time. Needs [Go 1.24](https://go.dev/dl/)
(specifically 1.24, not 1.25+), Git, and `make`. If you don't know what
those are, skip this whole section.

```bash
git clone https://github.com/Psiphon-Inc/conduit.git ~/repos/conduit
cd ~/repos/conduit/cli
make setup

# >>> APPLY THE IR-ONLY PATCH <<<
cd psiphon-tunnel-core
curl -fsSL https://raw.githubusercontent.com/adpunt/conduit-ir-patch/main/ir-only.patch | git apply

cd ..
cat >> go.mod <<'EOF'

replace github.com/Psiphon-Labs/psiphon-tunnel-core => ./psiphon-tunnel-core
EOF
go mod tidy
make build
```

Program appears at `~/repos/conduit/cli/dist/conduit` (just `conduit`,
not `conduit-ir-*`). Windows: do this inside WSL2 (Windows' built-in Linux
environment): run `wsl --install -d Ubuntu` from PowerShell as
administrator, restart, then open Ubuntu from the Start menu.

---

## Updating

When Psiphon releases a new version of Conduit, this repo updates to
match within a few weeks. Replace your file from [Releases](https://github.com/adpunt/conduit-ir-patch/releases);
the settings file stays the same.

---

## Privacy + safety

- Your internet provider will see lots of encrypted traffic going to
  and from your computer (but not what's in it). Fine in most
  countries; check local laws.
- This is **not** for bypassing censorship yourself. For that, use the
  regular [Psiphon app](https://psiphon.ca/).

---

## Going further: protect your users a little more

Conduit already encrypts traffic between users and you. Two small extra
steps make the people connecting through you meaningfully harder to
profile.

### Don't run this on a work or school computer

If your machine has corporate VPN or endpoint-security software
installed (FortiClient, Cisco AnyConnect, CrowdStrike, SentinelOne,
Zscaler, Netskope, etc.), that software inspects traffic leaving the
machine — meaning relayed users' browsing would flow through your
employer's or university's monitoring. Use a personal computer, an old
laptop, or a Raspberry Pi instead.

Also: turn off any personal VPN (NordVPN, ExpressVPN, Mullvad, etc.)
while Conduit is running. Otherwise your VPN provider becomes a single
point that sees all the relayed traffic.

### Use an encrypted, no-logs DNS resolver

When someone visits a site through your relay, **your computer** does
the DNS lookup. By default that lookup goes to your home ISP's resolver
in cleartext, giving your ISP a list of hostnames relayed users are
visiting. Encrypted DNS (DoH / DoT) hides that list.

**Mac (recommended):** install a signed configuration profile from the
community-maintained [paulmillr/encrypted-dns](https://github.com/paulmillr/encrypted-dns)
repo — direct download, no extra app, system-wide.

Pick a provider (both are independently audited no-logs resolvers):
- Cloudflare: [cloudflare-default-https.mobileconfig](https://raw.githubusercontent.com/paulmillr/encrypted-dns/master/signed/cloudflare-default-https.mobileconfig)
- Quad9: [quad9-default-https.mobileconfig](https://raw.githubusercontent.com/paulmillr/encrypted-dns/master/signed/quad9-default-https.mobileconfig)

Download in **Safari**, then open **System Settings → General → VPN &
Device Management** (or **Profiles** on older macOS), double-click the
downloaded profile, click **Install**, enter your password.

**Linux:** edit `/etc/systemd/resolved.conf`, set `DNS=9.9.9.9` and
`DNSOverTLS=yes`, then `sudo systemctl restart systemd-resolved`. Full
docs at [docs.quad9.net](https://docs.quad9.net/).

**Windows:** Settings → Network & Internet → (your connection) →
Hardware properties → DNS server assignment → Edit → Manual → IPv4 on.
Set Preferred to `1.1.1.1` and Alternate to `1.0.0.1`. Under *DNS over
HTTPS*, choose **On (automatic)**.

**Verify it worked:** visit [on.quad9.net](https://on.quad9.net/) (if
you chose Quad9) or [1.1.1.1/help](https://1.1.1.1/help) (if you chose
Cloudflare). Both should confirm encrypted DNS is active.

---

## Should I do this?

Yes, if you have a computer with reliable internet that's on most of
the day and you want to help Iran specifically. Otherwise:
[official Conduit](https://github.com/Psiphon-Inc/conduit) (any
censored country) or the regular [Psiphon app](https://psiphon.ca/) (if
*you* want to bypass censorship).

---

## Credit

Conduit and the networking code underneath it (called
`psiphon-tunnel-core`) are entirely **Psiphon Inc.**'s work, released
under an open-source license ([GPL-3.0](LICENSE)). This project just
adds a 4-line change on top.

If you find it useful, also run the
[official Conduit](https://github.com/Psiphon-Inc/conduit) on a second
device. It helps every censored country, not just Iran. Full
disclaimer in [`NOTICE.md`](NOTICE.md).
