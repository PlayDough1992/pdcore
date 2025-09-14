# PDCore Framework

PDCore is a comprehensive FiveM server framework designed for roleplay servers. This README documents all available resources, commands, exports, and configuration options.

## Disclaimer

PD Core framework is still in it's development stages, some scripts may not work right off the bat. 
THIS IS A BETA RELEASE

## How to deploy

replace the default yaml file contents in txAdmin with this:

```yaml
$engine: 3
$onesync: on
name: PD Core
description: PD Core recipe.

tasks: 
  # Download default resources
  - action: download_github
    src: https://github.com/citizenfx/cfx-server-data
    ref: master
    subpath: resources
    dest: ./resources

  # Download PD Core resources
  - action: download_github
    src: https://github.com/PlayDough1992/pdcore
    ref: main
    dest: ./resources/[pd]

  # Remove the old chat resource
  - action: remove_path
    path: ./resources/[gameplay]/chat

  # Download PD Core server.cfg
  - action: download_file
    url: https://raw.githubusercontent.com/PlayDough1992/pdcore-serverConfig/main/server.cfg
    path: ./server.cfg
```

## Core Resources

### pd-core

The foundation of the framework that handles admin systems, player identification, and basic commands.

#### Exports
- `IsPlayerAdmin(source)` - Server-side export to check if a player is an admin

#### Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/giveitem [id] [item] [amount]` | Give item to player | Admin |
| `/givemoney [id] [amount]` | Give money to player | Admin |
| `/fix` | Repair current vehicle | Admin |
| `/dvp` | Delete peds around player | Admin |
| `/dvall` | Delete all vehicles | Admin |
| `/dv` | Delete current/nearby vehicle | Everyone |
| `/boost` | Boost vehicle performance | Admin |
| `/car [model]` | Spawn a vehicle | Everyone (monitored) |

#### Configuration
- Admin list in `server/admin.lua` 
- Job definitions in `jobs.lua`

### pd-bank

Handles player money management with persistent JSON storage.

#### Exports
- `GetMoney(identifier)` - Get player's bank balance
- `RemoveMoney(identifier, amount)` - Remove money from player's bank
- `GetCash(identifier)` - Get player's cash balance
- `AddCash(identifier, amount)` - Add cash to player

#### Events
- `pd-bank:addMoney` - Add money to player's bank account
- `pd-bank:removeMoney` - Remove money from player's bank account
- `pd-bank:addCash` - Add cash to player
- `pd-bank:removeCash` - Remove cash from player

#### Storage
- Player money stored in `playermoney/[identifier].json`

### pd-cash

Handles cash pickups, drops and transfers between players.

#### Features
- Automatic cash drops around the map
- Player-to-player cash transfers
- Visual cash pickups with models and blips

#### Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/spawncash [amount] [x] [y] [z]` | Spawn cash at coordinates | Admin |
| `/cashhere [amount]` | Spawn cash at your position | Admin |
| `/givecash [id] [amount]` | Give cash to another player | Everyone |

#### Configuration
- `config.lua` controls cash drop frequency, amounts, and locations
- Notification settings for admins and players
- Visual settings for cash models and blips

### pd-inventory

Grid-based inventory system with item management.

#### Exports
- `AddItem(source, item, amount)` - Add item to player inventory
- `RemoveItem(source, item, amount)` - Remove item from player inventory
- `HasItem(source, item, amount)` - Check if player has item
- `GetInventory(source)` - Get player's inventory

#### Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/inv`, `/inventory` | Open inventory | Everyone |
| `/giveitem [id] [item] [amount]` | Give items to player | Admin |

#### Configuration
- `config.lua` defines all available items, weights, and properties
- Items stored in `playeritems/[license].json`

### pd-clothing

Character customization system with component management.

#### Features
- Full character appearance customization
- Component and prop management
- Rotating camera for viewing player

#### Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/clothing` | Open clothing menu | Everyone |

#### Configuration
- `config.lua` defines UI layout and available components

### pd-notifications

Simple notification system with customizable styles.

#### Usage
```lua
TriggerClientEvent('pd-notifications:notify', source, {
    text = "Your message here",
    type = "success" -- success, error, info, warning
})
```

#### Exports
- `SendNotification(source, message, type)` - Send notification to player

### pd-saver

Handles player data persistence for appearance.

#### Features
- Automatic saving at intervals
- Persistent player appearance

#### Storage
- Player data stored in `playerlooks/[identifier].json`

### pd-hud

Customizable heads-up display for player information.

#### Features
- Health and stamina display
- Player elevation display
- Vehicle damage display
- Player oxygen level display

### pd-chat

Chat display system that utilizes pd-notifications to display chat messages.

### pd-locations

Teleport and location management system.

#### Features
- Saved teleport locations
- Admin teleport commands
- Location blips

### pd-carspawner

Vehicle spawner

#### Features
- Vehicle category browser
- Spawn cars
- Supports addon vehicles
- Job locked vehicle types -- requires pd-core/setjob system -- supports police, ems and firefighter type emergency job locking

### pd-shops

Configurable shop system for buying items.

#### Features
- Multiple shop types
- Item categorization
- Price configuration

## Job System

Jobs are defined in `pd-core/jobs.lua` with grades, ranks and salaries.

### Available Jobs
- Police
- EMS
- Mechanic
- (Add more as configured)

### Commands
| Command | Description | Permission |
|---------|-------------|------------|
| `/setjob` | Set player job | Admin | -- Opens an admin-locked UI for setting player jobs

## Integration Guide

### Using Exports
```lua
-- Check if player is admin
local isAdmin = exports['pd-core']:IsPlayerAdmin(source)

-- Get player money
local money = exports['pd-bank']:GetMoney(identifier)

-- Check inventory
local hasItem = exports['pd-inventory']:HasItem(source, 'bread', 1)
```

### Events
```lua
-- Add money to player
TriggerEvent('pd-bank:addMoney', playerId, amount)

-- Send notification
TriggerClientEvent('pd-notifications:notify', source, {
    text = "Notification text",
    type = "success"
})
```

## Data Storage

PDCore uses JSON files for data persistence:
- Player money: `pd-bank/playermoney/[identifier].json`
- Player inventory: `pd-inventory/playeritems/[license].json`
- Player appearance: `pd-saver/playerlooks/[identifier].json`
- Player jobs: `pd-core/playerjobs/[identifier]_job.json`

## Developer Notes

- Some resources are designed to be modular and independent
- Direct file access is used instead of database for simplicity
- Framework has built-in admin tools and debugging features
- Most resources include configuration files for easy customization
