# Conduit IR-only

A modified version of [**Psiphon Conduit**](https://github.com/Psiphon-Inc/conduit)
that relays internet traffic **only for people in Iran**.

> **Unofficial. Not affiliated with Psiphon Inc.** See [`NOTICE.md`](NOTICE.md).

---

## What is Conduit

Conduit lets people in regions with internet censorship reach the open
internet through your device. You host a Conduit station; people in Iran
connect to it with Psiphon. It works like Tor's Snowflake: your computer
is a **bridge, not an exit**. Their requests travel encrypted to your
machine, which relays that still-encrypted traffic onward to a **Psiphon
server** — and the Psiphon server is what actually connects out to the
wider internet on their behalf. So the blocked websites they visit see the
**Psiphon server's IP, not yours**, and your computer never sees what
they're doing inside the tunnel. Psiphon's code enforces this: your node
can only relay to Psiphon servers, never to arbitrary sites. Your home
internet provider just sees encrypted traffic between you and the people
you help (and between you and Psiphon's servers) — never the contents.

During the January 2026 blackout, [Iran International
reported](https://www.iranintl.com/en/202601240957) more than 40,000
Iranians connected through Conduit volunteers at once; on January 22,
more than half of Psiphon Conduit's 2.8 million connection attempts came
from inside Iran. Iran has more Psiphon users than any country in the
world. A volunteer running the standard Conduit phone app serves only
around 25 people at a time; command-line builds — the official one as
well as this one — let you raise that on a machine that can handle it
(50 is a comfortable starting point — see Step 3).

Conduit is built for getting through censorship, and it's good at that
job. It reliably unblocks the everyday internet for Iranians (news,
WhatsApp/Telegram/Signal, social media, video calls with family,
journals, banking) in places where commercial VPNs are blocked, because
Psiphon disguises its traffic to look like ordinary browsing, using
volunteers' residential IP addresses. This provides Iranians with free,
open internet.

There are some downsides, most importantly that Psiphon doesn't claim to
be a privacy or anonymity tool. Independent reviewers ([ProPrivacy](https://proprivacy.com/privacy-service/review/psiphon))
explain: *"Psiphon does not increase your online privacy, and should not
be considered or used as an online security tool."* Psiphon's own
[privacy bulletins](https://psiphon.ca/en/privacy-bulletin.html) note
that its servers collect aggregated connection metadata (timestamps,
region/city codes, protocol type, bytes transferred) — not the websites
visited, but a footprint of each connection. Independent security audits
by Cure53 ([2017](https://cure53.de/pentest-report_psiphon.pdf),
[2019](https://cure53.de/pentest-report_psiphon_2.pdf), and
[2024 tunnel-core](https://cure53.de/pentest-report_psiphon_4.pdf))
found no catastrophic flaws, with a separate
[audit of the Conduit library itself](https://cure53.de/pentest-report_psiphon-conduit-library_2.pdf).
And because their traffic rides a single Psiphon tunnel — exiting at a
Psiphon server rather than bouncing through multiple anonymous hops the
way Tor does — a determined state-level adversary watching both ends
could in principle correlate them. As the operator you can see the
volume and timing of the encrypted traffic crossing your machine, but
not its content; Psiphon's design keeps the relayed tunnel opaque to you.

Tor, another tool, is the gold standard for internet anonymity. It
bounces every connection through multiple servers run by strangers, so
no single hop knows both who you are and what you're doing. The catch is
that Iran has spent years making Tor impractical: the Tor Project's
[2025 censorship report](https://blog.torproject.org/staying-ahead-of-censors-2025/)
describes Tor's main entry method (obfs4 bridges) being blocked in bulk,
leaving Snowflake — slow and unstable — as the only widely working
transport. Additionally, Psiphon's protocol mimicry tends to keep
working through harsher internet conditions when Tor doesn't.

Compared to a **paid VPN** (NordVPN, Mullvad, ExpressVPN, etc.), the
shape is similar: encrypted tunnel, the user's ISP can't see the
destination. Conduit is free, open source, and designed to keep
working where commercial VPNs are blocked. The trade-off is that it
runs on volunteer home computers, so speeds vary.

**If you're recommending this to family/friends:** it's a solid free
option for everyday access to blocked sites. For situations where
anonymity matters more than reachability (organising, or anything that
could get someone arrested), a high-trust paid VPN or Tor over a working
transport is still the better answer, with the caveat that both can be
hard to come by inside Iran. Tell users not to log into identifying
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

The whole restriction is this one block, kept in
[`ir-only.patch`](ir-only.patch) for reference and carried on the `ir-only`
branch of the [tunnel-core fork](https://github.com/adpunt/psiphon-tunnel-core):

```go
clientRegion := announceResponse.ClientRegion

// IR-only allowlist (local fork). Reject non-IR matched clients with a
// non-backoff error so the announce loop immediately re-announces and the
// broker tries to match a different client.
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
| [`ir-only.patch`](ir-only.patch) | The change, shown in full — for reading. The actual builds use the fork (below), which already contains it. |
| [`extract-config/`](extract-config/) | Source code of the config tool |
| [`install.sh`](install.sh) | Script GitHub uses to build the release binaries from the `conduit-ir` fork (you don't run it) |
| [`NOTICE.md`](NOTICE.md), [`LICENSE`](LICENSE) | Credit to Psiphon + the open-source license |

The IR-only restriction lives in two forks, each carrying the change on an
`ir-only` branch:

- [**adpunt/psiphon-tunnel-core**](https://github.com/adpunt/psiphon-tunnel-core) `@ir-only` — upstream Psiphon plus the 8-line change in `psiphon/common/inproxy/proxy.go`.
- [**adpunt/conduit-ir**](https://github.com/adpunt/conduit-ir) `@ir-only` — the Conduit app, wired to build against the tunnel-core fork above.

This repo (`conduit-ir-patch`) is just the distribution layer: it builds those
forks into the ready-made binaries you download in Step 1.

---

## Build it yourself (optional)

If you'd rather build the program from source than trust the
ready-made version. ~30 minutes first time. Needs [Go 1.24](https://go.dev/dl/)
(specifically 1.24, not 1.25+), Git, and `make`. If you don't know what
those are, skip this whole section.

The Iran-only restriction now lives in a fork, so there's no patch step:
the [`conduit-ir`](https://github.com/adpunt/conduit-ir) fork builds against
the [`psiphon-tunnel-core`](https://github.com/adpunt/psiphon-tunnel-core)
fork, which is upstream Psiphon plus the one change shown above. Both keep
that change on a branch called `ir-only`.

```bash
git clone -b ir-only https://github.com/adpunt/conduit-ir.git ~/repos/conduit-ir
cd ~/repos/conduit-ir/cli
make setup   # clones the patched tunnel-core fork
make build
```

Program appears at `~/repos/conduit-ir/cli/dist/conduit` (just `conduit`,
not `conduit-ir-*`). Windows: do this inside WSL2 (Windows' built-in Linux
environment): run `wsl --install -d Ubuntu` from PowerShell as
administrator, restart, then open Ubuntu from the Start menu.

To confirm the restriction is really in your build:

```bash
strings dist/conduit | grep "client region not allowed"
```

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

## A few notes for operators

**You can't see what the people using your node are doing.** Your
computer is a bridge, not an exit: their traffic is encrypted to a
Psiphon server, and Psiphon's code only lets your node relay to Psiphon
servers, never to arbitrary sites. That's good for you — but it also
means several "protect your users" steps you might expect *don't apply*:

- **Encrypted DNS on your machine does nothing for them.** The Psiphon
  server resolves the sites they visit, not you — so DoH/DoT on your
  computer only affects your own browsing, not theirs.
- **Corporate/endpoint monitoring on your machine won't see their
  browsing** — only encrypted tunnel traffic going to Psiphon servers.
- **A personal VPN neither helps nor harms them.** It only changes how
  your own hop to Psiphon is routed; the VPN still sees only encrypted
  tunnel bytes, not anyone's browsing.

What *does* matter:

- **Make sure a relay is allowed on your network.** Their browsing is
  invisible to your employer or school, but running a relay service can
  still break an acceptable-use policy, and some corporate networks
  block or interfere with the traffic. A personal computer, an old
  laptop, or a Raspberry Pi on your home connection sidesteps the
  question.
- **Keep it running.** Uptime is the thing that helps — leave it on as
  much as you can, and restart it after a reboot. Demand from Iran
  spikes during blackouts, often at odd hours.
- **A wired connection is steadier** than Wi-Fi for sustained relaying,
  if you can manage one.

### Should I route my relay through Tor for extra anonymity?

**No.** It's a natural instinct, but it doesn't help the people using
you and creates new problems. Because your node is a bridge, not an exit
(above), the real exit is the Psiphon server — so sending your node's
traffic out through Tor changes *your* path to Psiphon, not the users'
anonymity. It also tends to make things *worse*: Tor exit IPs get
CAPTCHA-walled and blocked by many sites (degrading the access you're
trying to provide), it loads scarce Tor exit capacity with relay
traffic, and Tor itself is heavily blocked inside Iran. The Tor Project
and Whonix both warn against this "proxy-over-Tor" pattern. If someone
needs Tor's anonymity, they should use Tor directly, not through a
Conduit relay.

---

## Other ways to help Iran connect

Running this build is one option, not the only one. The goal is simply
to get people in Iran back online by whatever means actually works and
keeps them safe — and what counts as "safe enough" depends on each
person's situation inside Iran. This section just lays out options. It's
up to you, and to the people you're helping, to decide which (if any)
fit, or whether to help at all.

### Other ways to do IR-only filtering

This project filters by changing Conduit's code (the fork above). Others do
the same thing at the network layer instead, which works with the **official**
Conduit and needs no custom build:

- **Firewall / geo-IP filtering** — tools like
  [iran-conduit-firewall](https://github.com/ardavannafezi/iran-conduit-firewall-Linux)
  use `iptables` + `ipset` with downloaded Iran IP ranges so that only
  Iranian IPs can reach the proxy port. Linux-only, runs alongside the
  stock Conduit. (As always: read the scripts before running anything
  with `sudo`.)
- **Community fork** — [ssmirr/conduit](https://github.com/ssmirr/conduit)
  is an actively maintained community fork of the official app with
  extra packaging and platform support.

### Amnezia VPN (a self-hosted alternative)

[Amnezia VPN](https://amnezia.org/) is a free, open-source VPN in a
similar spirit to Conduit: you run it yourself and share access with
people who need it. Its **AmneziaWG** protocol is built to survive the
deep-packet-inspection (DPI) filtering used in heavily censored
countries, and the
[AmneziaWG 2.0 release (2026)](https://amnezia.org/blog/amneziawg-2-0-available-for-self-hosted)
goes further — disguising VPN traffic as ordinary DNS, QUIC, or SIP so
filters wave it through. It's reported to work well in Iran, China, and
Russia. Unlike Conduit, it runs on a server (often a cheap VPS) rather
than just your home computer. Coverage:
[TechRadar](https://www.techradar.com/vpn/vpn-services/amnezia-vpn-drops-new-amneziawg-2-0-protocol-as-censorship-tactics-grow-smarter),
[CNET](https://www.cnet.com/tech/services-and-software/amnezia-vpn-new-protocol-amneziawg-v2/).

---

## Credit

Conduit and the networking code underneath it (called
`psiphon-tunnel-core`) are entirely **Psiphon Inc.**'s work, released
under an open-source license ([GPL-3.0](LICENSE)). This project just
adds a tiny change on top (one `if` check, plus an explanatory
comment).

If you find it useful, also run the
[official Conduit](https://github.com/Psiphon-Inc/conduit) on a second
device. It helps every censored country, not just Iran. Full
disclaimer in [`NOTICE.md`](NOTICE.md).
