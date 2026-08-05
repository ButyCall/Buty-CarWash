# Buty Car Wash

A configurable and cinematic car wash system for FiveM, originally created by **ButyCall** and modernized by **Hotspot Creations**.

Players can drive into a configured car wash, select one of three service packages, pay using cash or bank funds, and watch NPCs perform an animated vehicle-cleaning sequence.

## Features

* Cinematic car wash camera system
* Interactive NUI package selector
* Basic, Standard, and Premium service packages
* Prices automatically loaded from `config.lua`
* Secure server-side price validation
* Cash and bank payment support
* Automatic framework detection
* Custom framework resource-name support
* Multiple configurable car wash locations
* Configurable NPC models
* Configurable vehicle cleaning steps
* Built-in progress bar
* No separate `Buty-Progress` resource required
* Map blips and interaction markers
* Driver-only interaction protection
* Vehicle freezing during the cleaning process
* Supports modern FiveM artifacts and Lua 5.4

## Supported Frameworks

* QBCore
* ESX Legacy
* QBox

The resource can automatically detect the active framework, or you can select one manually in `config.lua`.

## Dependencies

### Required

* A supported framework
* `ox_lib`

`ox_lib` is currently loaded through the resource manifest:

```lua
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
```

The separate `Buty-Progress` or `BCall_progress` resource is **not required**. Its progress interface is built directly into Buty Car Wash.

## Installation

1. Download the resource.
2. Place the `Buty-CarWash` folder inside your server's resources directory.
3. Confirm that `ox_lib` and your framework start before Buty Car Wash.
4. Configure the framework, prices, and locations in `config.lua`.
5. Add the resource to your `server.cfg`.

```cfg
ensure ox_lib
ensure qb-core
ensure Buty-CarWash
```

For ESX:

```cfg
ensure ox_lib
ensure es_extended
ensure Buty-CarWash
```

For QBox:

```cfg
ensure ox_lib
ensure qbx_core
ensure Buty-CarWash
```

Restart the server or run:

```text
refresh
ensure Buty-CarWash
```

## Framework Configuration

Framework settings are located at the top of `config.lua`.

```lua
Configuration = {
    -- auto | esx | qbcore | qbox
    FrameWork = "auto",

    -- Leave blank to use the default framework resource name.
    -- ESX: es_extended
    -- QBCore: qb-core
    -- QBox: qbx_core
    CoreFolderName = "",

    Prices = {
        1000,
        2000,
        3500
    }
}
```

### Automatic Detection

Use:

```lua
FrameWork = "auto"
```

The script will attempt to detect a supported framework that is already running.

### Manual Framework Selection

QBCore:

```lua
FrameWork = "qbcore"
```

ESX:

```lua
FrameWork = "esx"
```

QBox:

```lua
FrameWork = "qbox"
```

### Renamed Framework Resources

Leave `CoreFolderName` blank when using the standard resource name:

```lua
CoreFolderName = ""
```

When your framework folder has been renamed, enter the exact resource name:

```lua
FrameWork = "qbcore",
CoreFolderName = "my-qb-core"
```

The same option is available for ESX and QBox.

## Price Configuration

Package prices are controlled entirely through `Configuration.Prices`.

```lua
Prices = {
    1000, -- Basic
    2000, -- Standard
    3500  -- Premium
}
```

The package order must remain:

| Index | Package  |
| ----: | -------- |
|   `1` | Basic    |
|   `2` | Standard |
|   `3` | Premium  |

When these values are changed, the prices displayed in the NUI automatically update the next time the menu opens.

The server also retrieves the selected package price directly from `config.lua`. It does not trust a payment amount submitted by the player's NUI or client.

## Payment Behavior

The resource checks the player's available funds in this order:

1. Cash
2. Bank

When the player has enough cash, the payment is removed from cash.

When the player does not have enough cash but has enough money in the bank, the payment is removed from the bank.

When neither account has enough money, the service is rejected.

## Adding a Car Wash Location

Locations are configured inside the `Locations` table.

```lua
Locations = {
    {
        Name = "Ronnie's Car Wash",

        Coord = vector3(164.92, -1727.40, 28.88),

        Npc = {
            ['BASIC'] = {
                {
                    model = "s_m_y_baywatch_01",

                    steps = {
                        [1] = "wheel_lf",
                        [2] = "wheel_lr",
                        [3] = "wheel_rf",
                        [4] = "wheel_rr",
                        [5] = "window_rf"
                    }
                }
            },

            ['STANDARD'] = {
                {
                    model = "s_m_y_baywatch_01",

                    steps = {
                        [1] = "wheel_lf",
                        [2] = "wheel_lr",
                        [3] = "wheel_rf",
                        [4] = "wheel_rr",
                        [5] = "window_rf"
                    }
                }
            },

            ['PREMIUM'] = {
                {
                    model = "s_m_y_baywatch_01",

                    steps = {
                        [1] = "wheel_lf",
                        [2] = "wheel_lr",
                        [3] = "wheel_rf",
                        [4] = "wheel_rr",
                        [5] = "window_rf"
                    }
                }
            }
        }
    }
}
```

Each location supports a different NPC model and cleaning-step list for each service package.

## Location Options

### Name

The internal name of the car wash.

```lua
Name = "Ronnie's Car Wash"
```

### Coordinates

The location where the marker appears and the vehicle is positioned.

```lua
Coord = vector3(164.92, -1727.40, 28.88)
```

### NPC Model

The pedestrian model used during the cleaning animation.

```lua
model = "s_m_y_baywatch_01"
```

Use a valid GTA V pedestrian model name.

### Cleaning Steps

The vehicle bones that the NPC visits during the cleaning sequence.

```lua
steps = {
    [1] = "wheel_lf",
    [2] = "wheel_lr",
    [3] = "wheel_rf",
    [4] = "wheel_rr",
    [5] = "window_rf"
}
```

Common vehicle bones include:

```text
wheel_lf
wheel_lr
wheel_rf
wheel_rr
window_lf
window_lr
window_rf
window_rr
bonnet
boot
```

Vehicle bone availability can vary between vehicle models.

## Default Locations

The included configuration contains car washes in:

* Los Santos
* Paleto Bay
* Sandy Shores
* Little Seoul

Each location can be removed, edited, or duplicated through `config.lua`.

## Player Usage

1. Drive a vehicle to a configured car wash.
2. Enter the interaction marker.
3. Remain in the driver's seat.
4. Press `E`.
5. Select a service package.
6. Press **Buy Service**.
7. The payment is validated by the server.
8. The cinematic cleaning sequence begins.
9. The vehicle is released when the service is complete.

Only the driver can begin a car wash service.

## Service Packages

### Basic

A lower-cost exterior cleaning package.

Displayed cleaning level:

```text
50%
```

### Standard

A more complete general exterior wash.

Displayed cleaning level:

```text
75%
```

### Premium

The full cinematic cleaning and detailing sequence.

Displayed cleaning level:

```text
100%
```

## Built-In Progress Bar

The progress display is now included directly inside the Buty Car Wash NUI.

The client triggers it internally using:

```lua
Progress(24000, "Spraying cleaning fluid...")
```

Its default appearance can be edited in `client.lua`:

```lua
Progress = function(time, text)
    SendNUIMessage({
        type = 'progress',
        time = tonumber(time) or 3000,
        text = text or 'Loading...',
        options = {
            background = 'linear-gradient(20.5deg, #00E4FF 9.83%, rgba(172, 65, 222, 0) 93.95%)',
            color = '#00C1FF'
        }
    })
end
```

Its layout and animation styles are located in:

```text
html/style.css
```

Its browser-side behavior is located in:

```text
html/script.js
```

Do not install or start a separate progress-bar resource for Buty Car Wash.

## Resource Structure

```text
Buty-CarWash/
├── client.lua
├── config.lua
├── fxmanifest.lua
├── server.lua
└── html/
    ├── index.html
    ├── script.js
    ├── style.css
    ├── style.less
    └── img/
        ├── basic.png
        ├── icon.png
        ├── premium.png
        ├── standard.png
        ├── vector1.png
        ├── vector2.png
        ├── vector3.png
        └── vector4.png
```

## Troubleshooting

### The resource reports that no framework was found

Confirm that your framework starts before Buty Car Wash.

```cfg
ensure qb-core
ensure Buty-CarWash
```

You can also manually select the framework:

```lua
FrameWork = "qbcore"
```

### The framework has a custom folder name

Set `CoreFolderName` to the exact resource-folder name:

```lua
CoreFolderName = "custom-qb-core"
```

### The package prices display as `$0`

Confirm that the client opens the interface using:

```lua
SendNUIMessage({
    type = "ui",
    status = true,
    prices = Configuration.Prices
})
```

Also confirm that `config.lua` is loaded as a shared script.

### The displayed price does not match the charged price

Restart the resource after changing `config.lua`:

```text
restart Buty-CarWash
```

Both the NUI and server payment logic use `Configuration.Prices`.

### The progress bar does not appear

Confirm that the following files contain the built-in progress implementation:

```text
client.lua
html/index.html
html/script.js
html/style.css
```

A separate `Buty-Progress` resource should not be required.

### Players can open the menu but cannot pay

Confirm that:

* The correct framework is selected.
* The configured framework resource is running.
* The player object loads correctly.
* The player has enough cash or bank funds.
* No other resource has replaced the standard money functions.

### NPCs do not move to part of a vehicle

Some custom vehicles use missing or unusual bone names. Change the configured cleaning steps to bones supported by that vehicle.

### The menu remains open or the vehicle stays frozen

Check the client F8 console and server console for Lua or NUI errors. Also verify that the `exit` and `wash` NUI callbacks are present in `client.lua`.

## Security

Package prices are validated on the server.

The NUI only submits the selected package index:

```text
1 = Basic
2 = Standard
3 = Premium
```

The server retrieves the real price from:

```lua
Configuration.Prices[packageIndex]
```

Do not modify the resource to accept a payment amount directly from JavaScript or another client-controlled value.

## Credits

### Original Author

* ButyCall#8291

### Updates and Modernization

* Hotspot Creations
* Framework auto-detection
* QBCore, ESX, and QBox compatibility
* Config-driven NUI pricing
* Server-authoritative payments
* Built-in progress-bar integration
* General modernization and compatibility improvements

## Support

For updates and support, use the official Hotspot Creations support channels.