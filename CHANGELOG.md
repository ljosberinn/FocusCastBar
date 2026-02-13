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
