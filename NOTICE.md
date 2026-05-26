# Attribution and Disclaimer

## This is an unofficial patch

This repository contains an **8-line modification** to source code originally
written by **Psiphon Inc.** It is:

- **NOT affiliated with Psiphon Inc.**
- **NOT endorsed by Psiphon Inc.**
- **NOT an official Psiphon product.**

If you have questions, bug reports, or feedback about Psiphon, Conduit, or
psiphon-tunnel-core, please contact Psiphon directly — not the author of this
patch. Their email is `conduit-oss@psiphon.ca` and their official repositories
are:

- https://github.com/Psiphon-Inc/conduit
- https://github.com/Psiphon-Labs/psiphon-tunnel-core

## What this patch modifies

All of the heavy lifting — the inproxy protocol, WebRTC handling, the broker
negotiation, the entire Psiphon network — is the work of Psiphon Inc. and its
contributors over many years.

This patch adds **8 lines** to a single file
(`psiphon/common/inproxy/proxy.go`) that cause the proxy to reject clients
whose country code is anything other than `IR`. That is the entire
contribution of this repository.

## License

The code being modified, `psiphon-tunnel-core`, is licensed under the GNU
General Public License version 3 (GPL-3.0). Because this patch is a
modification of GPL-3.0 code, this repository is also distributed under
GPL-3.0. See `LICENSE` for the full text.

The GPL-3.0 license is the reason this patch can legally exist and be shared.
The Psiphon authors chose that license specifically so that downstream
modifications like this one are permitted.

## What this repository does NOT contain

- Psiphon's network configuration file (`psiphon_config.json`). That file
  contains identifiers and signing keys that belong to Psiphon's network and
  is not redistributed here. You will need to obtain one from Psiphon
  (`conduit-oss@psiphon.ca`) or extract it from an official Conduit release
  binary.
- Any prebuilt binaries. You build it yourself from source.
- Any of Psiphon's source code. Only the diff is included; you fetch their
  source from their official repository.
