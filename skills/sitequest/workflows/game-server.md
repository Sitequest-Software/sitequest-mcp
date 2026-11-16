# Game server

Game servers run on a VPS. Tested guides, from an empty server to friends joining:
Minecraft, Palworld, Valheim, Counter-Strike 2, ARK: Survival Ascended, Satisfactory,
Terraria and Farming Simulator 25, at https://site.quest/en/docs/tutorials/ (SteamCMD
setup first for the Steam games). Follow the guide for the game; do not improvise ports or
launch flags.

## Host and size

- Most game servers compute their world on one thread: choose the host with the highest
  boost clock (the AMD Ryzen hosts; the Ryzen 9 7950X3D boosts to 5.7 GHz and has 128 MB
  of L3 cache).
- Ping: the hosts are in Frankfurt and Eygelshoven. Players can measure their own ping at
  https://site.quest/en/performance/.
- Minecraft needs at least 2 GB of RAM; plan 4 GB or more for more than a handful of
  players, plugins or mods. RAM can be added later without reinstalling.

## Setup

Follow [Service on a VPS](vps-service.md) for ordering, firewall and backups, with the
game's guide for the install. Open exactly the ports the guide names.

## Domain for players

- A record from the domain (or a subdomain like `play`) to the server's IPv4.
- Minecraft: add an SRV record (`_minecraft._tcp`) pointing to that name and the port, so
  players type the domain without a port.
- Every VPS has a static IPv4, so the address stays the same after restarts.

## Done

Check the server process runs and the game port answers from outside, then tell the user
the address players use.
