# RoSA-Certifications
*A fully modular licensing/certification system using a sleek tablet UI that allows server owners to manage access to specific weapons and equipment based on in-game certifications — no need to modify `qb-core`*

## Key Features
- ✅ Dynamic Certification UI
Fully configurable via config.lua. Add, remove, or rename certifications without touching HTML or JavaScript.

- ✅ Tablet-Based Menu
Uses a tablet animation (with support for emote menus if installed) for immersive interactions.

- ✅ No qb-core Edits Required
Uses QBCore's built-in metadata functions to assign player certifications (PlayerData.metadata.licences).

- ✅ Inventory Integration (e.g., ox_inventory)
Certifications can directly control access to weapons/equipment using inventory license locks:
```lua
-- ox_inventory/data/shops.lua
{ name = "weapon_stungun", price = 0, metadata = { registered = false }, license = 'service_shotgun', grade = 0 },
```
- ✅ Supports Any Number of Certifications
UI and back-end logic scale with however many options are defined in your config.

- ✅ Role-Based Access Controls
Automatically disables certain options for EMS/FIRE roles, if needed.

## Example
```lua
-- server/sv_settings.lua
LICENSE_NAMES = {
    opt1 = { id = "service_taser", label = "X26 Taser" },
    opt2 = { id = "service_pistol", label = "Glock 19" },
    opt3 = { id = "service_shotgun", label = "M-590" },
    opt4 = { id = "service_rifle", label = "Sig Spear LT" },
    opt5 = { id = "service_sniper", label = "Remington 700" },
    opt6 = { id = "service_pdw", label = "Kratos Vector Recoil" },
    opt7 = { id = "service_40mm", label = "40mm Beanbag Launcher" },
    opt8 = { id = "swat", label = "S.W.A.T. Arsenal" },
}
```

## ox_inventory hook
- Create a new shop!
```lua
-- ox_inventory/data/shops.lua
example_hook = {
	name = "EXAMPLE SHOP",
	groups = { ... },
	inventory = {
		{ name = "weapon_stungun", price = 150, metadata = { registered = true }, license = 'serivce_taser' --[[ This is where the "license" would go! ]] , grade = 0 },
	}, targets = {
		{ ... },
	},
},
```

## Contributors
|  Rank       |  Member       | ID                 | Qualifications                       |
|----         |----           |----                |----                                  |
| Director    | [Lanzaned](https://discordapp.com/users/871877975346405388) | [871877975346405388](https://discordapp.com/users/871877975346405388) | Javascript, XML, HTML, CSS, lua, SQL |

## Useful Links 
Discord: https://rosa.lanzaned.com<br>
Github: https://github.com/Republic-of-San-Andreas<br>

## Sponsors
<img src="https://ptb.discord.com/api/guilds/1216374653065363506/widget.png?style=banner2" alt="Discord Banner 2"/>