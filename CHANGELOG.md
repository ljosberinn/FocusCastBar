## Version 1.0.9

- fixed a bug where the custom TTS on Cast Start text wasn't imported correctly

## Version 1.0.8

- fixed a bug where the users Text-to-speech preferences weren't respected

## Version 1.0.7

- added ability to customize the TTS on Cast Start text
  - see Edit Mode button
- fixed a bug trying to show target name when in raid
- fixed a bug where the TTS on Cast Start option wasn't respecting the content type when swapping focus to a currently casting unit in raid

## Version 1.0.6

- fixed a bug scaling other texts if secondary font scaling was set to exactly 1

## Version 1.0.5

- added Secondary Font Scale option (defaults to the same as before)
  - allows in/decreasing the size of Cast Target & Interrupt Source text

## Version 1.0.4

- added Glow Color setting (defaults to the same as before)

## Version 1.0.3

- basically uncapped dimension restrictions (they're still there, just a lot more permissive, go wild you degens)
- fixed a bug where focusing a friendly mid cast would not prevent it from showing if Ignore Friendlies was active
- added Play Sound on Cast Start setting (default off, only in dungeons, unconditional)

## Version 1.0.2

- fixed a bug where the interrupt tick was incorrectly placed for channels
- fixed interrupt order for Protection Paladins, Rebuke is now always preferred over Avenger's Shield

## Version 1.0.1

- new setting under Features: Hide When Uninterruptible
  - only shows the cast bar if the cast is interruptible AND the player can interrupt
  - if the player has no interrupt spell (all healers except Restoration Shaman), the addon effectively disables itself

## Version 1.0.0

- fixed Background Opacity to actually work as intended
- added labels to feature groups
- added (Un)Fill Channels setting (default active)
- changed defaults

## Version 1.0.0-alpha7

- fix player color not appearing on target casts when alone in a dungeon
- refactored and condensed settings so the Edit Mode window isn't as large
- added German localization
- added Discord link button
- opened up import / export API

## Version 1.0.0-alpha6

- added Unit setting (defaults to Focus, obviously, but also allows Target)
- refactored Target Name Position setting into a Custom Texts Position setting which now also controls Interrupt Source Position
- added Top Left and Top Right Custom Texts Positions
- new default out of range opacity is now 75%
- new default Custom Texts Position is now Bottom Right
- fixed important glow lingering on interrupted casts

## Version 1.0.0-alpha5

- added Interrupt Source setting (default inactive)
- added Use Interrupt Source Color setting (default active)
- fixed cast end events to also ignore friendlies if Ignore Friendlies is active
- cast target now also shows in open world if the player is the target

## Version 1.0.0-alpha4

- implemented Import/Export
- added Out of Range Opacity setting (default 100%, meaning it's not active)
- removed debug prints
- added option to ignore friendlies / unattackable units (default active)
- added Target Name Position setting, defaulting to bottom center
- added Font Options for Outline and Shadow, defaulting to Outline
- significantly improved performance by throttling updates to 10/second

## Version 1.0.0-alpha3

- added Tick Width setting
- fixed Tick not correctly updating its height

## Version 1.0.0-alpha2

- enabled ignoring friendly/unattackable units

## Version 1.0.0-alpha1

- Initial release
