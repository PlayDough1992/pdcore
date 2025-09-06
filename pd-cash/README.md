# pd-cash

A robust cash drop and player-to-player cash transfer system for FiveM servers.

## Features

- **Money Bag Cash Drops**: Cash appears as visible money bags in the world
- **Visual Effects**: Marker, mini-map blip, and particle effects make cash easy to find
- **Player-to-Player Cash Transfers**: Give cash to nearby players with a user-friendly UI
- **Interactive Pickup**: Animation and effects when picking up cash
- **Secure Handling**: Input validation and permission checks
- **Bank Integration**: Works with pd-bank resource for money management
- **Notifications**: Uses pd-notifications for feedback to players

## Commands

### Player Commands
- `/givecash` - Open the cash transfer UI to give money to nearby players
- `/mypos` - Display your current position (debug mode only)
- `/cashhere [amount]` - Spawn cash at your position (debug mode only)
- `/testcash [amount]` - Test a cash drop in front of you (debug mode only)
- `/testallcash` - Test different money props (debug mode only)
- `/showcash` - Show all active cash drops (debug mode only)
- `/cashdebug` - Toggle debug information display (debug mode only)

### Admin Commands
- `/spawncash [amount] [x] [y] [z]` - Spawn cash at specific coordinates
- `/listcash` - List all cash drops in the server
- `/clearcash` - Clear all cash drops

## Configuration

Edit `config.lua` to customize:

- Cash drop locations
- Spawn intervals
- Min/Max amounts
- Maximum concurrent drops
- Pickup radius
- Transfer settings and reasons
- Debug mode

## Requirements

- pd-bank
- pd-notifications

## Installation

1. Place pd-cash in your resources folder
2. Add `ensure pd-cash` to your server.cfg after pd-bank and pd-notifications
3. Configure to your liking in config.lua
4. Start your server

## Technical Details

### Architecture
- Server-side cash drop management
- Client-side pickup detection using native GTA pickups
- NUI interface for cash transfers
- Integration with pd-bank for money persistence

### Events
- `pd-cash:spawnCash` - Spawns a cash pickup in the world
- `pd-cash:removeCash` - Removes a cash pickup from the world
- `pd-cash:openGiveCash` - Opens the cash transfer UI
- `pd-cash:giveCash` - Handles cash transfer between players

### Future Improvements
- Animations for giving cash
- Logging system for transactions
- Enhanced anti-cheat measures
- Support for multiple currencies
2. Use `/spawncash` command to manually spawn cash
3. Use `/showcash` to verify cash drops exist client-side
4. Ensure the cash model is loading correctly

## Developer Info

### Client Events
- `pd-cash:spawnCash` - Spawns a cash pickup
- `pd-cash:removeCash` - Removes a cash pickup
- `pd-cash:openGiveCash` - Opens the cash transfer UI
- `pd-cash:closeGiveCash` - Closes the cash transfer UI

### Server Events
- `pd-cash:requestAllCashDrops` - Client requests all existing cash drops
- `pd-cash:pickupCash` - Client picked up cash
- `pd-cash:giveCash` - Player giving cash to another player
