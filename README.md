# PuiusInput
Input abstraction library for ROBLOX.

# Synopsis
```lua
void module:DefineEvents(Config: table, Keybinds: table, Events: table);
void module:DefineEventSimple(BindName: string, Keybinds: table, Callback: function);
void module:DisconnectEvent(EventsName: string, Keybinds: table);
```

# DefineEvents
The `Config` table for the function call should look as it follows:
```
{
  EventOne = {
    PassProcessedEvents = boolean,
    InputType = number,
  },

  EventTwo = {
    PassProcessedEvents = boolean,
    InputType = number,
  },

  ...
}
```
Where InputType should be a number between 1 and 4 (1 for InputBegan, 2 for InputEnded, 3 for InputChanged and 4 for all).

The `Keybinds` table for the function call should look as it follows:
```
{
  [Enum.UserInputType / Enum.KeyCode] = {"EventOne", "EventTwo", ...},
  [Enum.UserInputType / Enum.KeyCode] = {"EventOne", "EventTwo", ...},
  ...
}
```

The `Events` table for the function call should look as it follows:
```
{
  EventOne = function(DataStruct)

  end),

  EventTwo = function(DataStruct)

  end),

  ...
}
```

# DataStruct
When the callbacks are called, instead of the traditional `InputObject` and `GameProcessed` parameters, you get a table which contains both plus an additional `InputType` which is a number from 1 to 3 that denotes what event was fired (InputBegan, InputEnded or InptuChanged).

DataStructure format:
```
{
  InputObject = InputObject,
  GameProcessed = boolean,
  InputType = number
}
```

# Example
```lua
local InputModule = require(game:GetService("ReplicatedStorage").PuiusInput);

local Config = {
	["BloopyBlooper"] = {
    PassProcessedEvents = true,
    InputType = 4, -- 1 for InputBegan, 2 for InputEnded, 3 for InputChanged and 4 for all
	}
};

local Keybinds = {
	[Enum.KeyCode.R] = {"BloopyBlooper"}
};

local Events = {
	["BloopyBlooper"] = function(DataStruct)
		print(DataStruct);
	end;
};

InputModule:DefineEvents(Config, Keybinds, Events);
```

# License
The project is licensed under the MIT license.
