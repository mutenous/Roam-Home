-- Global table -- scan owned homes ?
RoamHome={
    ver=9.4,
    debug=nil, -- makes mutinys life easier
    primary="", -- primary home for us
    primaryzone="", -- where that house is located -- redundant?
    secondary="", -- second home for us
    secondaryzone="", -- where secondary is located -- redundant ?
    bind1="",
    bind2="",
    bind3="",
    bind4="",
    bind5="",
    string=nil, -- shows strings globally
    color="", -- string color
    hex="", -- string hex
    hstring="", -- /home or /roam
    pdisplay="", -- what displays as primary home in settings
    sdisplay="", -- what displays as secondary home
    savedhousestrings={}, -- saved nicknames for saved @acc houses
    savedhouseids={"",""}, -- where jumpto() goes (id or @accn)
    primaryid=true, -- is it an @accn or id
    secondaryid=true,
    defaultPersistentSettings={
        debug=false,
        primary=GetHousingPrimaryHouse(),
        primaryzone="",
        secondary="",
        secondaryzone="",
        bind1="",
        bind2="",
        bind3="",
        bind4="",
        bind5="",
        string=true,
        color="default",
        hex="|cC0392B",
        hstring="/home",
        pdisplay="Primary Home",
        sdisplay="Free Apartment",
        savedhousestrings={"Primary Home","Free Apartment"},
        savedhouseids={GetHousingPrimaryHouse(),""},           
        primaryid=true,
        secondaryid=true,
    },
	persistentSettings={ },
    stringlist={
        homes={ -- "now this is what i'd call data-driven" ;)
            "Mara's Kiss Public House",
            "The Rosy Lion",
            "The Ebony Flask Inn",
            "Barbed Hook Private Room",
            "Sisters of the Sands Apartment",
            "Flaming Nix Deluxe Garret",
            "Black Vine Villa",
            "Cliffshade",
            "Mathiisen Manor",
            "Humblemud",
            "The Ample Domicile",
            "Stay-Moist Mansion",
            "Snugpod",
            "Bouldertree Refuge",
            "The Gorinir Estate",
            "Captain Margaux's Place",
            "Ravenhurst",
            "Gardner House",
            "Kragenhome",
            "Velothi Reverie",
            "Quondam Indorilia",
            "Moonmirth House",
            "Sleek Creek House",
            "Dawnshadow",
            "Cyrodilic Jungle House",
            "Domus Phrasticus",
            "Strident Springs Demesne",
            "Autumn's-Gate",
            "Grymharth's Woe",
            "Old Mistveil Manor",
            "Hammerdeath Bungalow",
            "Mournoth Keep",
            "Forsaken Stronghold",
            "Twin Arches",
            "House of the Silent Magnifico",
            "Hunding's Palatial Hall",
            "Serenity Falls Estate",
            "Daggerfall Overlook",
            "Ebonheart Chateau",
            "Grand Topal Hideaway",
            "Earthtear Cavern",
        },
        colors={
            default="|cC0392B",
            red="|cff0000", 	
            green="|c00ff00",
            blue="|c0000ff",		
            cyan="|c00ffff",
            magenta="c|ff00ff",
            yellow="|cffff00",		
            orange="|cffa700",
            purple="|c8800aa",
            pink="|cffaabb",
            brown="|c554400",		
            white="|cffffff",
            black="|c000000",
            gray="|c888888"
        }
    }
}

local roam = RoamHome

-- Initialize --
function RoamHome:Initialize() -- holey moley I need to shorten this
	self.persistentSettings=ZO_SavedVars:NewAccountWide("RoamHomeVars",self.ver,nil,self.defaultPersistentSettings)
    self.debug=self.persistentSettings.debug
    self.primary=self.persistentSettings.primary
    self.primaryzone=self.persistentSettings.primaryzone
    self.secondary=self.persistentSettings.secondary
    self.secondaryzone=self.persistentSettings.secondaryzone
    self.string=self.persistentSettings.string
    self.color=self.persistentSettings.color
    self.hex=self.persistentSettings.hex
    self.hstring=self.persistentSettings.hstring
    self.pdisplay=self.persistentSettings.pdisplay
    self.sdisplay=self.persistentSettings.sdisplay
    self.savedhousestrings=self.persistentSettings.savedhousestrings
    self.savedhouseids=self.persistentSettings.savedhouseids
    self.primaryid=self.persistentSettings.primaryid
    self.secondaryid=self.persistentSettings.secondaryid
    self.bind1=self.persistentSettings.bind1
    self.bind2=self.persistentSettings.bind2
    self.bind3=self.persistentSettings.bind3
    self.bind4=self.persistentSettings.bind4
    self.bind4=self.persistentSettings.bind5
    self:FindApartment() -- mutinys bandaid for assigning default home id
    self:CreateSettings() -- creates settings VERY DELICATE do NOT derp inside function
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_HOME","Travel home (/home)")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND1","Keybind 1")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND2","Keybind 2")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND3","Keybind 3")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND4","Keybind 4")
    ZO_CreateStringId("SI_BINDING_NAME_JUMP_BIND5","Keybind 5")
	EVENT_MANAGER:UnregisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED)
end

-- Convienence --
local function TableLength(tab)
    if not(tab) then return 0 end
    local Result=0
    for key,value in pairs(tab)do
        Result=Result+1 end
    return Result
end

local myFriendsOptions = {}

local function GetFriendsList()
    local f=GetNumFriends()
    for i=1,f do -- loops through friends 
        table.insert(myFriendsOptions, tostring(GetFriendInfo(i)))
    end
end

function RoamHome:Chat(msg)
    if self.string then d(self.hex..msg.."|r") end
end

-- Addon --
function RoamHome:JumpHome(id) -- needs shortening
    local totalhouses,location,numid=TableLength(self.stringlist.homes),GetCurrentZoneHouseId(),tonumber(id)
    if (id=="") then -- if where not specified
        if self.primary~=location then
            if self.primaryid then
                self:Chat("Traveling to primary home "..self.stringlist.homes[self.primary])
                RequestJumpToHouse(self.primary) -- now we home             
            else
                self:Chat("Traveling to primary home owned by "..self.primary)
                JumpToHouse(self.primary)
            end
        else
            if self.primary==self.secondary then return end
            if self.secondaryid then
                self:Chat("Traveling to secondary home "..self.stringlist.homes[self.secondary])
                RequestJumpToHouse(self.secondary)           
            else
                self:Chat("Traveling to secondary home owned by "..self.secondary)
                JumpToHouse(self.secondary)
            end
        end
    else
        if (numid<=totalhouses) then -- keeps causing error
            self:Chat("Traveling via home ID to "..self.stringlist.homes[numid])
            RequestJumpToHouse(numid)
        else self:Chat("Could not find house ID to jump to") end
    end
end

function RoamHome:FindApartment(arg) -- done ?
    local alliance=tonumber(GetUnitAlliance("player"))
    if (self.secondary=="" or arg=="secondary") then
        if alliance==1 then roam.secondary=1 end
        if alliance==2 then roam.secondary=3 end
        if alliance==3 then roam.secondary=2 end
        roam.sdisplay="Free Apartment"
        roam.persistentSettings.secondary=roam.secondary
        roam.persistentSettings.sdisplay=roam.sdisplay
        if roam.debug then roam:Chat("Roam Home set secondary home to "..roam.secondary) end
    elseif (arg=="primary") then
        if alliance==1 then roam.primary=1 end
        if alliance==2 then roam.primary=3 end
        if alliance==3 then roam.primary=2 end
        roam.pdisplay="Free Apartment"
        roam.persistentSettings.primary=roam.primary
        roam.persistentSettings.pdisplay=roam.pdisplay
        if roam.debug then roam:Chat("Roam Home set primary home to "..roam.primary) end
    else return end
end

-- Settings --
local friendcache=""
local friendnamecache=""

local anycache=""
local anynamecache=""

function RoamHome:SaveFriend() -- save cache to table
    if friendcache=="" then return end
    table.insert(self.savedhouseids, friendcache)
    if friendnamecache=="" then
        table.insert(self.savedhousestrings, friendcache)
    else table.insert(self.savedhousestrings, friendnamecache) end
    ReloadUI()
end

function RoamHome:SaveAnyone() -- merge above ?
    if anycache=="" then return end
    table.insert(self.savedhouseids, anycache)
    if anynamecache=="" then
        table.insert(self.savedhousestrings, anycache)
    else table.insert(self.savedhousestrings, anynamecache) end
    ReloadUI()
end

function RoamHome:SetKeybind(value, id)
    if id=="1" then
        self.bind1=value
        self.persistentSettings.bind1=self.bind1
    elseif id=="2" then
        self.bind2=value
        self.persistentSettings.bind2=self.bind2
    elseif id=="3" then
        self.bind3=value
        self.persistentSettings.bind3=self.bind3
    elseif id=="4" then
        self.bind4=value
        self.persistentSettings.bind4=self.bind4
    else 
        self.bind5=value
        self.persistentSettings.bind5=self.bind5
    return end
end

function RoamHome:SelectHome(value,id) -- reduce debug strings
    if (id=="primary") then
        if (value=="Primary Home") then
            self.primary=GetHousingPrimaryHouse()
            self.persistentSettings.primary=self.primary
            self.pdisplay="Primary Home"
            self.persistentSettings.pdisplay=self.pdisplay
            self.primaryid=true
            self.persistentSettings.primaryid=self.primaryid
            if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
        elseif (value=="Free Apartment") then
            self:FindApartment("primary")
            self.primaryid=true
            self.persistentSettings.primaryid=self.primaryid
            if self.debug then self:Chat("Roam Home forced roam:FindApartment primary") end
        else
            self.primaryid=false -- is not a homeid (@account)
            self.persistentSettings.primaryid=self.primaryid
            self.primary=value
            self.persistentSettings.primary=self.primary
            self.pdisplay=self.primary
            self.persistentSettings.pdisplay=self.pdisplay
            if self.debug then self:Chat("Roam Home set primary home to "..self.primary.." & display to "..self.pdisplay) end
        end
    elseif (id=="secondary") then
        if (value=="Primary Home") then
            self.secondary=GetHousingPrimaryHouse()
            self.persistentSettings.secondary=self.secondary
            self.sdisplay="Primary home"
            self.persistentSettings.sdisplay=self.sdisplay
            self.secondaryid=true
            self.persistentSettings.secondaryid=self.secondaryid
            if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display to "..self.sdisplay) end
        elseif (value=="Free Apartment") then
            self:FindApartment("secondary")
            self.secondaryid=true
            self.persistentSettings.secondaryid=self.secondaryid
            if self.debug then self:Chat("Roam Home forced roam:FindApartment secondary") end
        else
            self.secondaryid=false -- is not a homeid (@account)
            self.persistentSettings.secondaryid=self.secondaryid
            self.secondary=value -- is this why it doesnt nickname? saves nick to @accname
            self.persistentSettings.secondary=self.secondary
            self.sdisplay=self.secondary
            self.persistentSettings.sdisplay=self.sdisplay
            if self.debug then self:Chat("Roam Home set secondary home to "..self.secondary.." & display to "..self.sdisplay) end
        end
    end
end

-- needs shortening --
function RoamHome:HomeBind() -- merge with jump home
    local location=GetCurrentZoneHouseId()
    if self.primary~=location then
        if self.primaryid then
            self:Chat("Traveling to primary home "..self.stringlist.homes[self.primary])
            RequestJumpToHouse(self.primary) -- now we home             
        else
            self:Chat("Traveling to primary home owned by "..self.primary)
            JumpToHouse(self.primary)
        end
    else
        if self.secondaryid then
            self:Chat("Traveling to secondary home "..self.stringlist.homes[self.secondary])
            RequestJumpToHouse(self.secondary)            
        else
            self:Chat("Traveling to secondary home owned by "..self.secondary)
            JumpToHouse(self.secondary)
        end
    end
end

function RoamHome:JumpBind1()
    self:Chat("Traveling to home owned by "..self.bind1)
    JumpToHouse(self.bind1)
    return         
end

function RoamHome:JumpBind2()
    self:Chat("Traveling to home owned by "..self.bind2)
    JumpToHouse(self.bind2)     
    return   
end

function RoamHome:JumpBind3()
    self:Chat("Traveling to home owned by "..self.bind3)
    JumpToHouse(self.bind3)  
    return      
end

function RoamHome:JumpBind4()
    self:Chat("Traveling to home owned by "..self.bind4)
    JumpToHouse(self.bind4)        
    return 
end

function RoamHome:JumpBind5()
    self:Chat("Traveling to home owned by "..self.bind5)
    JumpToHouse(self.bind5)    
    return      
end

function RoamHome:ChangeCommand(value)
    self.hstring=value
    self.persistentSettings.hstring = self.hstring
end

function RoamHome:PersistentCommand(id, who)
    if who=="roam" and self.hstring=="/roam" then
        self:JumpHome(id)
    elseif who=="home" and self.hstring=="/home" then
        self:JumpHome(id)
    else return end
end

-- end shortening --

function RoamHome:StringSettings(value) -- is complete
    if value==true or value==false then
        self.string=not self.string
        self.persistentSettings.string=self.string
        if self.debug then self:Chat("Roam Home toggled chat: "..tostring(self.string)) end
    else 
        self.color=value
        self.persistentSettings.color=self.color
        self.hex=self.stringlist.colors[value]
        self.persistentSettings.hex=self.hex
        if self.debug then self:Chat("Roam Home changed color to "..value) end
    end
end

function RoamHome:CommandSettings(value, who) -- format done needs to be completed
    if (who=="home") then
        self.hstring=value
        self.persistentSettings.hstring=self.hstring
        if self.debug then self:Chat("Roam Home changed "..who.." command to "..value) end
    end
end

function RoamHome_JumpHome() -- needed for hotkey
    roam:HomeBind()
end

function RoamHome_JumpBind1() -- needed for hotkey
    roam:JumpBind1()
end

function RoamHome_JumpBind2() -- needed for hotkey
    roam:JumpBind2()
end

function RoamHome_JumpBind3() -- needed for hotkey
    roam:JumpBind3()
end

function RoamHome_JumpBind4() -- needed for hotkey
    roam:JumpBind4()
end

function RoamHome_JumpBind5() -- needed for hotkey
    roam:JumpBind5()
end

function RoamHome:CreateSettings()
    GetFriendsList()
    local LAM=LibStub("LibAddonMenu-2.0")
    local defaultSettings={}
    local panelData = {
	    type = "panel",
	    name = "Roam Home",
	    displayName = self.hex.."Roam Home",
	    author = "mutiny",
        version = tostring(self.ver),
		registerForDefaults = true,
		registerForRefresh = true,
    slashCommand = "/roamhome"
    }
    local optionsData = {
        [1] = {
            type = "header", -- DISPLAY SETTINGS
            name = self.hex.."Display|r settings",
            width = "full",
            },
         [2] = {
            type = "checkbox", 
            name = " Show destination in chat window",
            width = "half",
            getFunc = function() return self.string end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [3] = {
            type = "dropdown",
            name = "Message color",
            choices = {"default","red","green","blue","cyan","magenta","yellow","orange","purple","pink","brown","white","black","gray",},
            width = "half",
            getFunc = function() return self.color end,
            setFunc = function(value) self:StringSettings(value) end,
            },
         [4] = {
            type = "header", -- START HOME SETTINGS --
            name = self.hex.."Home|r settings",
            width = "full",
            },
         [5] = {
            type = "dropdown",
            name = " Slash command",
            choices = {"/home","/roam"},
            width = "full",
            getFunc = function() return self.hstring end,
            setFunc = function(value) self:CommandSettings(value, "home") end,
            },
        [6] = {
            type = "divider",
            width = "full",           
            },
         [7] = {
            type = "dropdown",
            name = " First "..self.hstring.." jump",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.pdisplay end,
            setFunc = function(value) self:SelectHome(value, "primary") end,
            },
         [8] = {
            type = "dropdown",
            name = " Second "..self.hstring.." jump",
            warning = "Only works if primary is set to first /home",
            width = "half",
            choices = self.savedhousestrings,
            getFunc = function() return self.sdisplay end,
            setFunc = function(value) self:SelectHome(value, "secondary") end,
            },
         [9] = {
            type = "submenu",
            name = "Add homes",
            width = "full",
            controls= { -- START FRIEND SETTINGS --
                [1] = {
                    type = "description",
                    text = " Save homes to the dropdown menus above",
                    width = "full",           
                    },
               [2] = {
                    type = "header",
                    name = " "..self.hex.."Friends",
                    width = "half",           
                    },
               [3] = {
                    type = "dropdown",
                    name = " @accountname",
                    sort = "name-up",
                    choices = myFriendsOptions,
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendcache=value end,                
                    },
                [4] = {
                    type = "editbox",
                    disabled=true,
                    name = " Nickname (optional)",
                    tooltip = "Coming in future update",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) friendnamecache=value end,
                    },
                [5] = {
                    type = "button",
                    name = "Save home",
                    tooltip = "This will reload the UI",
                    width = "full",
                    func = function() self:SaveFriend() end,
                    },
               [6] = {
                    type = "header",
                    name = " "..self.hex.."Everyone",
                    width = "half",           
                    },
               [7] = {
                    type = "editbox",
                    name = " @accountname",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) anycache=value end,                
                    },
                [8] = {
                    type = "editbox",
                    name = " Nickname (optional)",
                    disabled=true,
                    tooltip = "Coming in future update",
                    width = "full",
                    getFunc = function() return end,
                    setFunc = function(value) anynamecache=value end,
                    },
                [9] = {
                    type = "button",
                    name = "Save home",
                    tooltip = "This will reload the UI",
                    width = "full",
                    func = function() self:SaveAnyone() end,
                    },
                },
         },
         [10] = {
            type = "submenu",
            name = "Edit keybinds",
            width = "full",
            controls= {
                [1] = {
                    type = "description",
                    text = " Assign keybinds in game control settings",
                    width = "full",           
                    },
               [2] = {
                    type = "header",
                    name = " "..self.hex.."Destinations",
                    width = "half",            
                    },
                [3] = {
                    type = "editbox",
                    name = " Keybind 1",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.bind1 end,
                    setFunc = function(value) self:SetKeybind(value, "1") end,
                    },
                [4] = {
                    type = "editbox",
                    name = " Keybind 2",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.bind2 end,
                    setFunc = function(value) self:SetKeybind(value, "2") end,
                    },
                [5] = {
                    type = "editbox",
                    name = " Keybind 3",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.bind3 end,
                    setFunc = function(value) self:SetKeybind(value, "3") end,
                    },
                [6] = {
                    type = "editbox",
                    name = " Keybind 4",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.bind4 end,
                    setFunc = function(value) self:SetKeybind(value, "4") end,
                    },
                [7] = {
                    type = "editbox",
                    name = " Keybind 5",
                    tooltip = "@accountname",
                    width = "half",
                    getFunc = function() return self.bind5 end,
                    setFunc = function(value) self:SetKeybind(value, "5") end,
                    },
            },
        }
    }
    LAM:RegisterOptionControls("RoamHome", optionsData)
	LAM:RegisterAddonPanel("RoamHome", panelData)
end

-- Game hooks --
SLASH_COMMANDS["/test"]=function(id) d("primary: "..roam.primary.."  secondary: "..roam.secondary) end
SLASH_COMMANDS["/homeforce"]=function(id) RoamHome:CreateSettings() d("Forced RoamHome:CreateSettings()") end
SLASH_COMMANDS["/homedebug"]=function(id) roam.debug=not roam.debug roam:Chat("Roam Home debug: "..tostring(roam.debug)) roam.persistentSettings.debug=roam.debug end

SLASH_COMMANDS["/home"]=function(id) roam:PersistentCommand(id, "home") end
SLASH_COMMANDS["/roam"]=function(id) roam:PersistentCommand(id, "roam") end

EVENT_MANAGER:RegisterForEvent("RoamHome_OnLoaded",EVENT_ADD_ON_LOADED,function() roam:Initialize() end)