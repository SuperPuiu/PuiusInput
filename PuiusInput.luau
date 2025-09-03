--!native
local module = {};
local ConnectedEvents = {};
local DefaultConfiguration = {
  PassProcessedEvents = true,
  AcceptedInput = 4 -- 1 for InputBegan, 2 for InputEnded, 3 for InputChanged and 4 for all
};

local UIS = game:GetService("UserInputService");
local RunService = game:GetService("RunService");

if (RunService:IsServer()) then
  error("Unable to run module on server", 2);
end;

local function InputAssert(Condition, ...)
  if (Condition) then
    return;
  end;
  
  local Pack = {...};
  local l_Str = table.remove(Pack, 1);

  error(string.format(l_Str, unpack(Pack)), 2);
end;

local function DisconnectEventInternal(Bind: Enum.KeyCode, EventName: string)
  InputAssert(ConnectedEvents[Bind], "Input binding doesn't exist in ConenctedEvents table.");
  
  if (not ConnectedEvents[Bind][EventName]) then
    return;
  end;
  
  ConnectedEvents[Bind][EventName] = nil;
end;

local function ConnectEventInternal(Name: string, Bind: Enum.KeyCode, Callback: (...any) -> (...any), Configuration: {[string]: (any)})
  InputAssert(typeof(Name) == "string", "Attempted to call ConnectEventInternal with Name non-string (string expected, got %s)", typeof(Name));
  InputAssert(typeof(Bind) == "EnumItem", "Attempted to call ConnectEventInternal with Bind non-enumitem (EnumItem expected, got %s)", typeof(Bind));
  InputAssert(typeof(Callback) == "function", "Attempted to call ConnectEventInternal with Callback non-function (function expected, got %s)", typeof(Callback));
  
  if (not ConnectedEvents[Bind]) then
    ConnectedEvents[Bind] = table.create(1);
  end;
  
  ConnectedEvents[Bind][Name] = {Configuration = Configuration, Callback = Callback};		
end;

local function PropagateInputInternal(InputObject: InputObject, GameProcessed: boolean, InputType: number)
  local DataStructure = {
    InputObject = InputObject,
    GameProcessed = GameProcessed,
    InputType = InputType
  };
  
  for Keybind, Data in pairs(ConnectedEvents) do
    for _, Event in pairs(Data) do
      if ((Event.Configuration.InputType ~= InputType and Event.Configuration.InputType ~= 4) or (not Event.Configuration.PassProcessedEvents and GameProcessed)) then
        continue;
      end;

      Event.Callback(DataStructure);
    end;
  end;
end;

function module:DefineEvents(Config: {[string]: boolean}, Keybinds: {[Enum.KeyCode]: {[number]: string}}, Events: {[string]: (...any) -> (...any)})
  InputAssert(typeof(Config) == "table", "Attempted to call DefineEvents with invalid config type (table expected, got %s)", typeof(Config));
  InputAssert(typeof(Keybinds) == "table", "Attempted to call DefineEvents with invalid keybinds (table expected got %s)", typeof(Keybinds));
  InputAssert(typeof(Events) == "table", "Attempted to call DefineEvents with invalid Events (table expected got %s)", typeof(Events));
  
  for EventName: string, Callback: (...any) -> (...any) in Events do
    InputAssert(typeof(Callback) == "function", "Invalid value within Events table (function expected, got %s)", typeof(Callback));
	  
    local FoundKeybind: EnumItem?;
    
		for Key: EnumItem, KeyEventName: {[number]: string} in Keybinds do
      if table.find(KeyEventName, EventName) then
        FoundKeybind = Key;
				break;
			end;
    end;
    
    InputAssert(typeof(FoundKeybind) == "EnumItem", "Invalid value within Events table (Unknown event found: %s)", EventName);
    InputAssert(typeof(Config[EventName]) == "table", "Invalid value within Events table (Invalid or nil configuration found for event: %s)", EventName);  
    ConnectEventInternal(EventName, FoundKeybind, Callback, Config[EventName]);
   end;
end;

function module:DefineEventSimple(BindName: string, Keybinds: {[number]: EnumItem}, Callback: (...any) -> (...any))
  for _, Bind in pairs(Keybinds) do
    ConnectEventInternal(BindName, Bind, Callback, DefaultConfiguration);
  end;
end;

function module:DisconnectEvent(EventName: string, Keybinds: {[number]: EnumItem})
  InputAssert(typeof(EventName) == "string", "Attempted to call DisconnectEvent with incorrect EventName argument (expected string, got %s)", tostring(EventName));
  InputAssert(typeof(Keybinds) == "table" or Keybinds == nil, "Attempted to call DisconnectEvent with invalid Keybinds argument (expected table or nil, got %s)", tostring(Keybinds));
  
  if (Keybinds) then
    for Index, Bind in pairs(Keybinds) do
      InputAssert(typeof(Bind) == "EnumItem", "Invalid binding at index %i (expected EnumItem, got %s)", Index, typeof(Bind));
      
      DisconnectEventInternal(Bind, EventName);
    end;
  else
    for Binding, Events in pairs(ConnectedEvents) do
      DisconnectEventInternal(Binding, EventName);
    end;
  end;
end;

UIS.InputBegan:Connect(function(Input: InputObject, Processed: boolean)
  PropagateInputInternal(Input, Processed, 1);
end);

UIS.InputEnded:Connect(function(Input: InputObject, Processed: boolean)
  PropagateInputInternal(Input, Processed, 2);
end);

UIS.InputChanged:Connect(function(Input: InputObject, Processed: boolean)
  PropagateInputInternal(Input, Processed, 3);
end);

return module;
