# Conduit IR-only

A modified version of [**Psiphon Conduit**](https://github.com/Psiphon-Inc/conduit)
that relays internet traffic **only for people in Iran**.

> **Unofficial. Not affiliated with Psiphon Inc.** See [`NOTICE.md`](NOTICE.md).

---

## What is Conduit

Conduit lets people in regions with internet censorship reach the open
internet through your device. You host a Conduit station; people in Iran
connect to it with Psiphon. Their requests travel encrypted to your
machine, which relays that encrypted traffic onward to a Psiphon
server that connects out to the
wider internet on their behalf. The websites they visit see
Psiphon server's IP, not yours, and your computer never sees what
they're doing inside the tunnel. Your personal
internet provider only sees encrypted traffic between you and the people
you're connected to (called "peers").

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
> runs `-m 100` on my personal home fibre with no problem. I recommend starting at 50, see how
> your computer handles it, and raise it if your internet speeds seem unaffected.
>
> **First-run security popups.** macOS says "developer cannot be
> verified": open **System Settings → Privacy & Security**, scroll to the
> Security section, and click **Open Anyway**, then **Open**. (On macOS
> Sonoma/14 and earlier you could right-click the file in Finder →
> **Open**, but that was removed in Sequoia/15 and never worked for
> command-line files, so use the Settings route. Power users:
> `xattr -d com.apple.quarantine ./conduit-ir-*`.) Windows SmartScreen:
> click "More info" → "Run anyway".

---

## How to know it's working

About a minute after startup, watch the terminal for these lines:

- `[OK] Starting Psiphon Conduit (...)`: the program launched.
- `[ERROR] client region not allowed`: someone outside Iran was matched to
  you and your computer turned them away — the restriction doing its job.
  How often this shows up varies.
- A stats line like:
  `[STATS] Announcing: 0 | Connecting: 73 | Connected: 21 | Up: 17.6 GB | Down: 134.6 GB | Uptime: 99h47m44s | Regions: common[IR(conn:21|traffic:152.2 GB)]`
  When `Connected` is at least 1 and `Up`/`Down` are moving, someone in
  Iran is using your proxy right now. **The `Regions` field is your real
  proof the restriction works — it should only ever list `IR`.** If that's
  all you see there, your build is serving Iran and nowhere else.

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
| [`ir-only.patch`](ir-only.patch) | The change, shown in full — for reading. It's already in the fork (below). |
| [`extract-config/`](extract-config/) | Source code of the config tool |
| [`install.sh`](install.sh) | Script GitHub uses to build the release binaries (you don't run it) |
| [`NOTICE.md`](NOTICE.md), [`LICENSE`](LICENSE) | Credit to Psiphon + the open-source license |


[**adpunt/psiphon-tunnel-core**](https://github.com/adpunt/psiphon-tunnel-core)
is a fork of Psiphon's tunnel core repository, which just means a copy of Psiphon's own
networking code with my changes on top. This change is an ~8-line
change in the file `psiphon/common/inproxy/proxy.go`. 

The Conduit app you actually run is built
on top of that networking code. The Iran-only change lives in the code, not in
the app. So building this project means taking the official Conduit app,
untouched, and compiling it against the copied-and-slightly-modified network code instead
of Psiphon's original. What comes out is the genuine Conduit app with the one
Iran-only line added — nothing about the app itself is altered or re-published,
only this repo and that one copied library.

---

## Build it yourself (optional)

If you'd rather build the program from source than trust the
ready-made version. ~30 minutes first time. Needs [Go 1.24](https://go.dev/dl/)
(specifically 1.24, not 1.25+), Git, and `make`. If you don't know what
those are, skip this whole section.

There's no patch step and no fork of the Conduit app. You clone the
**official** Conduit, point its build at the
[`psiphon-tunnel-core`](https://github.com/adpunt/psiphon-tunnel-core) fork
(`ir-only` branch — upstream Psiphon plus the one change shown above), and
build:

```bash
git clone https://github.com/Psiphon-Inc/conduit.git ~/repos/conduit-ir-build
cd ~/repos/conduit-ir-build/cli
# pull the IR-only fork instead of Psiphon's upstream tunnel-core
make setup PSIPHON_REPO=https://github.com/adpunt/psiphon-tunnel-core.git PSIPHON_BRANCH=ir-only
# build the official app against that fork (this line is what applies the change)
go mod edit -replace github.com/Psiphon-Labs/psiphon-tunnel-core=./psiphon-tunnel-core
go mod tidy
make build
```

Program appears at `~/repos/conduit-ir-build/cli/dist/conduit` (just `conduit`,
not `conduit-ir-*`). Windows: do this inside WSL2 (Windows' built-in Linux
environment): run `wsl --install -d Ubuntu` from PowerShell as
administrator, restart, then open Ubuntu from the Start menu.

To check the restriction is built in, search the program for the rejection
message:

```bash
strings dist/conduit | grep "client region not allowed"
```

That only confirms the code is present, though. The real proof is at
runtime: when you run it, the `Regions` line in the `[STATS]` output should
only ever list `IR` (see "How to know it's working" above).

---

## Updating

When Psiphon releases a new version of Conduit, this repo rebuilds and
publishes a matching release automatically (a scheduled job checks weekly).
Replace your file from [Releases](https://github.com/adpunt/conduit-ir-patch/releases);
the settings file stays the same.

---

## Privacy + safety

- Your internet provider will see encrypted traffic going to
  and from your computer. Fine in most countries, but it's recommended to check your local laws.
- This is not for bypassing censorship yourself, use [Psiphon app](https://psiphon.ca/) for that.

---

## Additional information on Conduit

You cannot see what people using your node are doing, nor can you add 
any additional protections on your machine to help them. Your
computer is like a bridge, their traffic is encrypted to a
Psiphon server, and Psiphon's code only lets your node relay to Psiphon
servers, never to arbitrary sites. Things that you may do to protect your
own privacy do not apply to their internet activity, such as:

- **Encrypted DNS** - the Psiphon
  server resolves the sites they visit, not you, so any DoH/DoT on your
  computer only affects your own browsing, not theirs.
- **Corporate/endpoint monitoring** - only encrypted tunnel traffic going to Psiphon servers.
- **A personal VPN** - only changes how
  your own hop to Psiphon is routed; the VPN still sees only encrypted
  tunnel bytes, not anyone's browsing.

What could matter on your end:

- **Running it on a device and network that are actually yours.** Their
  browsing is invisible to your employer or school, but running a relay
  service can still break an acceptable-use policy, and some networks
  block or interfere with the traffic. Watch out for anything an
  organisation controls: a work-issued or employer-managed laptop, a
  company desktop, a university campus or dorm network, a corporate VPN,
  or a rented cloud/VPS box with its own terms of service. A personal
  computer, an old laptop, or a Raspberry Pi on your home connection
  sidesteps the whole question.
- **Keep it running.** Uptime is the thing that helps, leave it on as
  much as you can, and restart it after a reboot. Demand from Iran spikes
  during crackdowns and in the windows when a shutdown eases (often at odd
  hours), so being already up when one of those windows opens is what
  matters. Additionally, the more users the have the more difficult monitoring
  beocmes.

### Tor and Conduit

Tor is known as the gold standard of anonymous internet browsing. Tor routes every connection
through three relays run by three different volunteers, under layers of
encryption ("onion routing"): the first relay knows who you are but not where
you're going, the last one (the "exit") knows where you're going but not who you
are, and the middle keeps those two apart. No single party ever sees both
ends. Psiphon on the other hand
carries a user's traffic out through a *single* Psiphon server. One party could link
them to what they're doing. While Psiphon is built for reach, Tor is built for anonymity. 
Two limitations to Tor worth mentioning, 
the exit relay can read traffic to the destination if it isn't itself
encrypted (so stick to HTTPS), and an adversary able to watch both ends at once
could in theory correlate them. And no matter how anonymous your connection, 
Tor can't help you stay hidden if you log into an account that identifies you.


**This begs the question, why Psiphon/Conduit instead of Tor?**

The major catch with Tor is
that Iran has spent years making most ways of reaching Tor impractical —
older bridge types like obfs4 are now largely detected and blocked. Could you use Conduit to give Iranian's access to Tor? Yes and no.

While it may be tempting to activate Tor on your device, routing your relay's 
own traffic out through Tor only changes *your* path to Psiphon, it does nothing
to your peers traffic. In fact, it may backfire as Tor exit IPs are CAPTCHA-walled and blocked by the IRGC,
degrading the access you provide. 

A person in Iran *can* use Conduit to reach Tor, but it would have to be on their side. This is
the one setup that genuinely gives them anonymity (in theory, there's always a potential someone has found a workaround).
This is what it would look like:

1. Connect to Psiphon first and confirm it's actually up and in
   whole-device (VPN) mode. Tor browser would not be accessible without an initial VPN like Conduit (or any other trusted VPN)
2. Then open **Tor Browser** (desktop or Android, from
   [torproject.org](https://www.torproject.org/) — reachable once Psiphon is
   up) and connect with its **normal/direct setting: no Snowflake, no bridge.**
   Snowflake only exists to reach Tor from *inside* Iran's filtering; Psiphon
   has already carried them past it, so plain Tor connects the way it would in
   any uncensored country.

The major downside is speed. A volunteer
Conduit relay is already slow, and Tor adds three more hops, so this is for
text: messaging, email, reading, and posting. Videos or big downloads are not recommended. 
And regardless of the content, nothing should be logged into accounts that identify them. 

---

## Background on Conduit

During and after the January 2026 internet blackout, [Iran International
reported](https://www.iranintl.com/en/202601240957) that on January 22,
2026 more than half of Psiphon Conduit's 2.8 million connection attempts
that day came from inside Iran and, citing the site's live data at the
time of writing (late January), that more than 40,000 Iranians were
connected through Conduit volunteers at once. Iran is consistently one of the
largest sources of Psiphon users in the world. 

There are a few complaints with Conduit. First, only a small amount of people are 
typically able to connect. Conduits desktop and mobile apps have a UI element that 
caps the max number of peers at 25. Command-line builds like this one have no such limit. 
I personally run mine at 100. Second, despite the high number of Iranian users, their
speed is quite low, and a lot of the traffic goes to users in other regions. While
there is certainly a case to be made that all these users deserve free Internet (as is provided
by the original Conduit), given the current situation in Iran many people have expressed 
interest in helping only Iranians. 

Volunteers actually asked Psiphon to build an Iran-only option into
Conduit ([conduit#137](https://github.com/Psiphon-Inc/conduit/issues/137),
[#159](https://github.com/Psiphon-Inc/conduit/issues/159)), Psiphon declined,
and instead briefly set its whole network to serve only Iran during the January
2026 crisis. That is no longer in effect, so a normal relay again serves every
country. 


Conduit is built for getting through censorship. In the day-to-day filtering Iranians live with most of the time, it
keeps the everyday internet reachable (news, WhatsApp/Telegram/Signal,
social media, video calls with family, journals, banking) where commercial
VPNs are blocked. However, this access can be slow and drop in and out. It works
by automatically switching between several disguises, making the traffic
look like random data or ordinary HTTPS, and by riding volunteers' home
(residential) IP addresses.

When Iran cuts the network to
a slim allowlist in the form of white simcards, nothing else that rides the normal internet gets
through, Conduit included. That's what happened during the hardest days of
the January 2026 shutdown, when outside connectivity fell to roughly 1% of
normal. 

There are some downsides, most importantly that Psiphon doesn't claim to
be a privacy or anonymity tool. Independent reviewers ([ProPrivacy](https://proprivacy.com/privacy-service/review/psiphon))
explain: *"Psiphon does not increase your online privacy, and should not
be considered or used as an online security tool."* Psiphon's own
[privacy policy](https://psiphon.ca/en/privacy.html) notes
that its servers collect aggregated connection metadata (timestamps,
region/city codes, protocol type, bytes transferred) — not the websites
visited, but a footprint of each connection. Independent security audits
by Cure53 ([2017](https://cure53.de/pentest-report_psiphon.pdf),
[2019](https://cure53.de/pentest-report_psiphon_2.pdf), and
[2024 tunnel-core](https://cure53.de/pentest-report_psiphon_4.pdf))
found the core networking library this build relies on to be solid — no
critical flaws in tunnel-core. (The 2019 audit did find two Critical
remote-code-execution bugs, but both were in Psiphon's legacy Windows
desktop client, not tunnel-core and not the Conduit app.) There's also a
separate
[audit of the Conduit library itself](https://cure53.de/pentest-report_psiphon-conduit-library_2.pdf).
And because their traffic rides a single Psiphon tunnel (exiting at a
Psiphon server rather than bouncing through multiple anonymous hops the
way Tor does) a determined state-level adversary watching both ends
could in principle correlate them. As the operator you can see the
volume and timing of the encrypted traffic crossing your machine, but
not its content; Psiphon's design keeps the relayed tunnel opaque to you.

Compared to a **paid VPN** (NordVPN, Mullvad, ExpressVPN, etc.), the
shape is similar: encrypted tunnel, the user's ISP can't see the
destination. Conduit is free, open source, and designed to keep
working where commercial VPNs are blocked. The trade-off is that it
runs on volunteer home computers, so speeds vary, while paid VPNs tend
to be faster. 

If you're recommending this to family/friends, it's a solid free
option for everyday access to blocked sites. For situations where
anonymity matters more than reachability, a high-trust paid VPN or Tor over a working
transport is still the better answer, with the caveat that both can be
hard to come by inside Iran. Tell users not to log into identifying
accounts they wouldn't want associated with their connection.

---

<p align="center">
  <img src="assets/lion-and-sun-flag.png" alt="Lion and Sun flag of Iran" width="200">
</p>

## Alternative ways of helping Iranians

Running this build is one option, not the only one. The goal is to get people
in Iran back online by whatever actually works and keeps them safe, and what
counts as "safe enough" depends on each person's situation inside Iran. 

### Getting the same Iran-only effect in Conduit without this patch

There are two ways to make a relay serve only Iran. One is to change the program
itself, the way this repo does. The other is to leave the official program
exactly as it is and use your computer's own firewall to allow only connections
to and from Iranian internet addresses — that's what the tools below do.

**Why there's no "just block a port" option** - Conduit doesn't listen for
incoming connections. Your relay dials *out* to a Psiphon broker, and the broker
hands it clients it reaches over WebRTC (via STUN/TURN). So there's no inbound
port to gate, and your machine never picks who it serves, the broker does. That
constrains every option here.

**The firewall approach (works with the stock, unmodified app)** - these tools
leave Conduit untouched and add OS firewall rules, scoped to the Conduit process,
that only allow traffic to/from downloaded Iranian IP ranges. The usual design
keeps TCP open globally (so the broker and discovery keep working) but limits the
high-bandwidth UDP/WebRTC data path to Iranian IPs; a "strict" mode locks both to
Iran.

- **Linux — [KhajuBridge](https://github.com/delejos/conduit-iran-khajubridge)**
  (nftables + systemd cgroup; the most maintained of these). It expects Conduit
  already running as a systemd service (`conduit.service`). Roughly:
  ```bash
  git clone https://github.com/delejos/conduit-iran-khajubridge
  cd conduit-iran-khajubridge
  sudo bash install.sh                                        # deploy scripts + systemd units
  sudo /opt/khajubridge/scripts/update_region_cidrs.sh        # fetch Iran IP ranges
  sudo /opt/khajubridge/scripts/apply_firewall.sh             # apply: TCP global, UDP → Iran only
  sudo systemctl enable --now khajubridge-cidr-refresh.timer  # keep the ranges fresh weekly
  ```
  That's its default "Layer 1." For hard Iran-only it has an "Option A" that pins
  a dedicated IP with cgroup SNAT. Undo everything with
  `sudo nft delete table inet khajubridge`.
- **Windows — [moridani/conduit-for-iran-firewall](https://github.com/moridani/conduit-for-iran-firewall)**
  (and the near-identical [moneshvenkul/iran-conduit-firewall](https://github.com/moneshvenkul/iran-conduit-firewall)).
  Download `iran_firewall_final.BAT`, right-click → Run as administrator, then
  press `1` for Normal (TCP global, UDP Iran-only) or `2` for Strict (both
  Iran-only); `3` disables it. It writes Windows Firewall rules against
  `conduit-tunnel-core.exe` and pulls Iran ranges from ipdeny.com. (A Linux
  iptables/ipset version also exists:
  [ardavannafezi/iran-conduit-firewall-Linux](https://github.com/ardavannafezi/iran-conduit-firewall-Linux).)

A big appael of the firewall route is that it needs no custom build and it runs the official app. 
Personally, if I were to take this approach I'd still continue to use the command line version of the program 
to increase the maximum number of peer connections and use a firewall on top fo that. 
One downside of the firewall system is that it filters by
*IP address* against a downloaded list, which can be imprecise: WebRTC
often routes through a TURN relay, so the peer IP your firewall sees may not be
the user's real Iranian address. You can wrongly block real Iranians or let
others through, and strict rulesets can choke Psiphon's own broker/discovery
traffic and make your node go dark (which is why these tools keep TCP global).
It's also only as accurate as the IP list it last downloaded, and the tools are
small and single-author. This repo's patch rejects a client using the
region Psiphon already attributed to it, before any traffic flows. You get no IP
lists (relayed WebRTC can't fool it) at the cost of building the fork and restricting yourself
to the command line application.

**Running stock Conduit on a server or in a container.** If you just want a relay
running headless, [ssmirr/conduit](https://github.com/ssmirr/conduit) is a
community Linux/CLI fork and
[CappyT's setup gist](https://gist.github.com/CappyT/4df97556349375a44a43b4d6011e0ded)
has ready-made Docker Compose and Kubernetes manifests for it (no public IP
needed — it dials out over STUN/TURN). Both run all-regions Conduit, so pair them
with a firewall tool above, or use this repo's patch, for Iran-only.

### Alternatives to Conduit

- **Tor with Snowflake** - as disgused above, Tor is a fantastic tool for anonymity, but it's hard
  to reach from Iran: direct Tor and the older obfs4 bridges are blocked, and
  Snowflake (a WebRTC transport that looks like a video call) is what mostly
  still connects. The catch is that a person inside Iran usually needs a working
  tunnel like Psiphon just to reach Tor in the first place. See
  **[Tor and Conduit](#tor-and-conduit)** above for the how.
- **Self-hosted VLESS + REALITY (Xray)** - the strongest self-hosted option for
  Iran. You rent a VPS and run an
  encrypted tunnel that specific people connect to with a config you hand them.
  REALITY's trick is that instead of presenting its own (fingerprintable)
  certificate, it completes a real TLS 1.3 handshake against a real, unrelated
  website and borrows that site's certificate. The connection looks like an ordinary visit to a legitimate site,
  which is why it survives SNI/cert filtering better than plain VLESS or
  Shadowsocks. Two things to understand before choosing it: (1) it serves *one or
  a few trusted people*, not anonymous strangers. Iranian ISPs burn a server IP
  by traffic volume (~100 GB in ~2 days on Irancell), so a busy IP dies fast;
  running a real website on the box, keeping user counts low, and rotating IPs
  extends its life. (2) Unlike Conduit, you are the exit. Whoever runs the VPS
  can see the user's traffic, so it places real trust in the operator. 
- **MahsaNG / Lantern** - Iran-tuned apps the user installs on their own device
  (TLS fragmentation, rotating free configs, many transports bundled in). These
  are someone's own secondary tool to recommend to a person in Iran, not
  something a volunteer abroad hosts.

**Exists, but not recommended for Iran:**

- **AmneziaWG** - UDP-based Obfuscated WireGuard. Iran throttles and
  (during shutdowns) blocks UDP outright; AmneziaWG was among the protocols named
  blocked in June 2025. Its "works for years" reputation is from Russia and
  Turkmenistan, not Iran. Prefer a TCP/TLS option like VLESS+REALITY.
- **Plain Tor and commercial VPNs (NordVPN, Mullvad, and the like)** - on their
  own they mostly don't connect from inside Iran. Standard Tor is blocked and
  most commercial VPN protocols are detected and dropped. A commercial VPN can
  still serve as the outer tunnel that gets a user to Tor (see above), but as a
  standalone tool inside Iran it's unreliable.

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
