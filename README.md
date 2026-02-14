# Advanced Focus Cast Bar

[![](https://img.shields.io/badge/patreon-red?logo=patreon&style=for-the-badge)](https://www.patreon.com/cw/warcraftlogs)
[![](https://shields.io/badge/discord-lightblue?logo=discord&style=for-the-badge)](https://discord.gg/C5STjYRsCD)

- [Curseforge](https://curseforge.com/wow/addons/advanced-focus-cast-bar)
- [Wago](https://addons.wago.io/addons/advanced-focus-cast-bar)

- [1 min video demonstration](https://youtu.be/1FZiX-rw5PM)

## Features

- deep Edit Mode integration thanks to [LibEditMode](https://github.com/p3lim-wow/LibEditMode/wiki/LibEditMode)
- configurable color options for:
  - uninterruptible cast
  - interruptible cast and your interrupt is ready
  - interruptible cast and your interrupt is not ready (or you don't have an interrupt)
  - interrupt ready tick
- (don't) show border, cast time, spell icon, raid marker, target of cast, interrupt source
- font and font size selection, powered by [LibSharedMedia](https://www.curseforge.com/wow/addons/libsharedmedia-3-0) and more
- texture selection, powered by [LibSharedMedia](https://www.curseforge.com/wow/addons/libsharedmedia-3-0)
- important spell highlighting, powered by [LibCustomGlow](https://github.com/Stanzilla/LibCustomGlow)
- focus tts reminder when your focus disappears mid combat as a reminder to pick a new one
- out of range opacity
- load conditions: don't load on certain content types or roles
- import/export
- option to ignore friendlies / unattackable units
- optionally use as target cast bar instead
- not vibecoded, won't crash out, won't steal code

## Demo Mode

This allows you seeing the cast bar as it shows in Edit Mode, but without the Edit Mode overlay. You cannot interact with it further here, it's really just previewing how it would look like in action.

```
/run AdvancedFocusCastBarParent:ToggleDemo()
```

Run the command again to hide it (or enter Edit Mode).

Alternatively, you can disable `Ignore Friendlies` in the `Features` dropdown, focus yourself and cast spells outside of the Edit Mode.

## Known Limitations/Issues

- with 12.0, Blizzard removed the option to define which channel to play Text-to-Speech on so the focus reminder functionality can only use whatever they decided to use
- no support for empower stages. unless its heavily requested, no plans to support them
- it is not possible to add a sound for when your interrupt is ready

## Honorary Mentions

- [plusmouse](https://www.curseforge.com/members/plusmouse/projects) for discovering the Midnight approach of interrupt ticks
- Nnoggie for testing & feedback

## Legal

See [License](LICENSE)
