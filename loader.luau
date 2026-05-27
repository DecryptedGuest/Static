repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(x) return x end
local Services = {
    Players = cloneref(game:GetService("Players")),
    TweenService = cloneref(game:GetService("TweenService")),
    UserInputService = cloneref(game:GetService("UserInputService")),
    MarketplaceService = cloneref(game:GetService("MarketplaceService")),
    CoreGui = cloneref(game:GetService("CoreGui")),
    HttpService = cloneref(game:GetService("HttpService")),
}

local CONFIG = {
    FOLDER_ROOT = "Static",
    FOLDER_ASSETS = "Static/assets",
    LOGO_URL = "https://raw.githubusercontent.com/Ih0bby/Static/main/logo.png",
    LOGO_PATH = "Static/assets/logo.png",
}

local GAMES = {
    ["Fight In A School"] = {
        placeName = "Fight In A School",
        placeIds = { 10449761463, 118758941554698, 17698425045, 86098085533596 },
        patterns = { "fight in a school", "fias" },
    },
    ["Basketball Legends"] = {
        placeName = "Basketball Legends",
        placeIds = { 14386691987, 71832465156084, 17652853807, 17652855195, 17122385635 },
        patterns = { "basketball legends" },
    },
    ["Notoriety"] = {
        placeName = "Notoriety",
        placeIds = { 2557847604, 104434907248230 },
        patterns = { "notoriety" },
    },
    ["South London"] = {
        placeName = "South London",
        placeIds = { 114478751418135 },
        patterns = { "south london" },
    },
    ["Sniper Duels"] = {
        placeName = "Sniper Duels",
        placeIds = { 109397169461300 },
        patterns = { "sniper duels" },
    },
    ["Boxing Beta"] = {
        placeName = "Boxing Beta",
        placeIds = { 6804602922 },
        patterns = { "boxing beta" },
    },
    ["Asylum Life"] = {
        placeName = "Asylum Life",
        placeIds = { 132352755769957 },
        patterns = { "asylum life" },
    },
}


local Utils = {}

function Utils.log(level, msg)
    local prefix = string.format("[Static][%s]", level)
    if level == "ERROR" then warn(prefix, msg) else print(prefix, msg) end
end

function Utils.try(fn, ctx)
    local ok, result = pcall(fn)
    if not ok then
        Utils.log("ERROR", ctx .. ": " .. tostring(result))
        return nil
    end
    return result
end

function Utils.sanitize(input)
    if type(input) ~= "string" then return "" end
    local s = input:gsub("%c", "")
    s = s:match("^%s*(.-)%s*$") or ""
    s = s:gsub("%s+", " ")
    return s
end

function Utils.ensureFolder(path)
    if isfolder and makefolder and not isfolder(path) then
        makefolder(path)
    end
end


local Assets = {}

function Assets.loadLogo()
    local asset = ""
    pcall(function()
        if not (writefile and isfile and getcustomasset) then return end

        Utils.ensureFolder(CONFIG.FOLDER_ROOT)
        Utils.ensureFolder(CONFIG.FOLDER_ASSETS)

        if not isfile(CONFIG.LOGO_PATH) then
            local data = game:HttpGet(CONFIG.LOGO_URL)
            writefile(CONFIG.LOGO_PATH, data)
        end
        asset = getcustomasset(CONFIG.LOGO_PATH)
    end)
    return asset
end


local GameDetector = {}

function GameDetector.getCurrentPlace()
    local placeId = game.PlaceId
    local placeName = "Unknown"
    local ok, info = pcall(function()
        return Services.MarketplaceService:GetProductInfo(placeId)
    end)
    if ok and info then placeName = info.Name:lower() end
    return placeId, placeName
end

function GameDetector.findGame()
    local placeId, placeName = GameDetector.getCurrentPlace()
    Utils.log("INFO", string.format("Detecting game - PlaceId: %d, Name: %s", placeId, placeName))

    for gameKey, gameData in GAMES do
        if gameData.placeIds then
            for _, id in gameData.placeIds do
                if id == placeId then
                    Utils.log("INFO", "Game detected by PlaceId: " .. gameData.placeName)
                    return gameKey, gameData
                end
            end
        end
    end

    for gameKey, gameData in GAMES do
        if gameData.patterns then
            for _, pattern in gameData.patterns do
                if string.find(placeName, pattern:lower(), 1, true) then
                    Utils.log("INFO", "Game detected by pattern: " .. gameData.placeName)
                    return gameKey, gameData
                end
            end
        end
    end

    Utils.log("INFO", "No game detected")
    return nil, nil
end

function GameDetector.isSupported()
    local gk, _ = GameDetector.findGame()
    return gk ~= nil
end


local T = {
    bg          = Color3.fromRGB(10, 10, 15),
    card        = Color3.fromRGB(18, 18, 26),
    cardborder  = Color3.fromRGB(32, 32, 46),
    input       = Color3.fromRGB(25, 25, 36),
    inputborder = Color3.fromRGB(42, 42, 58),
    inputfocus  = Color3.fromRGB(30, 30, 42),
    accent      = Color3.fromRGB(0, 150, 255),
    accentglow  = Color3.fromRGB(40, 175, 255),
    accentdim   = Color3.fromRGB(0, 110, 195),
    white       = Color3.fromRGB(240, 242, 250),
    gray        = Color3.fromRGB(145, 148, 168),
    muted       = Color3.fromRGB(88, 90, 110),
    green       = Color3.fromRGB(40, 200, 105),
    red         = Color3.fromRGB(245, 60, 60),
    discord     = Color3.fromRGB(88, 101, 242),
    discordglow = Color3.fromRGB(108, 121, 255),
    toggleoff   = Color3.fromRGB(48, 48, 64),
    hover       = Color3.fromRGB(36, 36, 52),
    black       = Color3.fromRGB(0, 0, 0),
}

local UI = {}

local TweenService = Services.TweenService
local UserInputService = Services.UserInputService

function UI.new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

function UI.corner(p, r)
    return UI.new("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p })
end

function UI.stroke(p, c, th, tr)
    return UI.new("UIStroke", {
        Color = c or T.cardborder,
        Thickness = th or 1,
        Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = p,
    })
end

function UI.tween(obj, dur, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

function UI.makeDraggable(frame)
    local dragging, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    local dragInput
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            UI.tween(frame, 0.08, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, Enum.EasingStyle.Sine)
        end
    end)
end

function UI.build(logoAsset)
    if Services.CoreGui:FindFirstChild("StaticLoader") then
        Services.CoreGui:FindFirstChild("StaticLoader"):Destroy()
    end

    local c = {}

    c.gui = UI.new("ScreenGui", {
        Name = "StaticLoader",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = Services.CoreGui,
    })

    c.card = UI.new("Frame", {
        Size = UDim2.new(0, 400, 0, 340),
        Position = UDim2.new(0.5, 0, 0.5, 25),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.card,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = c.gui,
    })
    UI.corner(c.card, 12)
    c.cardStroke = UI.stroke(c.card, T.cardborder, 1, 1)

    UI.makeDraggable(c.card)

    c.topAccent = UI.new("Frame", {
        Size = UDim2.new(0.3, 0, 0, 2),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = c.card,
    })
    UI.corner(c.topAccent, 2)

    c.loadContent = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = c.card,
    })

    c.loadLogo = UI.new("ImageLabel", {
        Size = UDim2.new(0, 105, 0, 105),
        Position = UDim2.new(0.5, 0, 0.5, -46),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = logoAsset,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 21,
        Parent = c.loadContent,
    })

    c.loadTitle = UI.new("TextLabel", {
        Size = UDim2.new(0, 250, 0, 26),
        Position = UDim2.new(0.5, 0, 0.5, 16),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "Static",
        TextColor3 = T.white,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        ZIndex = 21,
        Parent = c.loadContent,
    })

    c.loadStatus = UI.new("TextLabel", {
        Size = UDim2.new(0, 250, 0, 14),
        Position = UDim2.new(0.5, 0, 0.5, 42),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = T.muted,
        TextTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        ZIndex = 21,
        Parent = c.loadContent,
    })

    c.progTrack = UI.new("Frame", {
        Size = UDim2.new(0, 180, 0, 4),
        Position = UDim2.new(0.5, 0, 0.5, 66),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.input,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = c.loadContent,
    })
    UI.corner(c.progTrack, 4)

    c.progFill = UI.new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 22,
        Parent = c.progTrack,
    })
    UI.corner(c.progFill, 4)

    c.loginContent = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 11,
        Parent = c.card,
    })

    c.closeBtn = UI.new("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -12, 0, 12),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = T.muted,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        ZIndex = 50,
        Parent = c.loginContent,
    })

    c.closeBtn.MouseEnter:Connect(function() UI.tween(c.closeBtn, 0.15, { TextColor3 = T.red, Rotation = 90 }) end)
    c.closeBtn.MouseLeave:Connect(function() UI.tween(c.closeBtn, 0.15, { TextColor3 = T.muted, Rotation = 0 }) end)

    c.logoImg = UI.new("ImageLabel", {
        Size = UDim2.new(0, 75, 0, 85),
        Position = UDim2.new(0.5, 0, 0, -6),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Image = logoAsset,
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 12,
        Parent = c.loginContent,
    })

    c.titleLabel = UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0.5, 0, 0, 64),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = "Static",
        TextColor3 = T.white,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        ZIndex = 12,
        Parent = c.loginContent,
    })

    c.hSep = UI.new("Frame", {
        Size = UDim2.new(0.85, 0, 0, 1),
        Position = UDim2.new(0.5, 0, 0, 94),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.cardborder,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = c.loginContent,
    })

    local content = UI.new("Frame", {
        Size = UDim2.new(1, -56, 0, 180),
        Position = UDim2.new(0.5, 0, 0, 108),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = c.loginContent,
    })

    c.redeemBtn = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = content,
    })
    UI.corner(c.redeemBtn, 8)

    c.redeemLabel = UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Execute",
        TextColor3 = T.white,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 13,
        Parent = c.redeemBtn,
    })

    c.redeemBtn.MouseEnter:Connect(function() UI.tween(c.redeemBtn, 0.15, { BackgroundColor3 = T.accentglow }) end)
    c.redeemBtn.MouseLeave:Connect(function() UI.tween(c.redeemBtn, 0.15, { BackgroundColor3 = T.accent }) end)

    local bbar = UI.new("Frame", {
        Size = UDim2.new(1, -56, 0, 46),
        Position = UDim2.new(0.5, 0, 0, 280),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = c.loginContent,
    })

    c.bSep = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, -4),
        BackgroundColor3 = T.cardborder,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = bbar,
    })

    c.discordBtn = UI.new("TextButton", {
        Size = UDim2.new(0.5, -4, 0, 34),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = T.discord,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = bbar,
    })
    UI.corner(c.discordBtn, 6)

    c.discordLabel = UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Join Discord",
        TextColor3 = T.white,
        TextTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        ZIndex = 13,
        Parent = c.discordBtn,
    })

    c.discordBtn.MouseEnter:Connect(function() UI.tween(c.discordBtn, 0.15, { BackgroundColor3 = T.discordglow }) end)
    c.discordBtn.MouseLeave:Connect(function() UI.tween(c.discordBtn, 0.15, { BackgroundColor3 = T.discord }) end)

    c.settingsBtn = UI.new("TextButton", {
        Size = UDim2.new(0.5, -4, 0, 34),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = T.input,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = bbar,
    })
    UI.corner(c.settingsBtn, 6)
    c.settingsBtnStroke = UI.stroke(c.settingsBtn, T.inputborder, 1, 1)

    c.settingsLabel = UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = T.gray,
        TextTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        ZIndex = 13,
        Parent = c.settingsBtn,
    })

    c.settingsBtn.MouseEnter:Connect(function() UI.tween(c.settingsBtn, 0.15, { BackgroundColor3 = T.hover }) end)
    c.settingsBtn.MouseLeave:Connect(function() UI.tween(c.settingsBtn, 0.15, { BackgroundColor3 = T.input }) end)

    -- ── Toast ──
    c.toast = UI.new("Frame", {
        Size = UDim2.new(0, 300, 0, 56),
        Position = UDim2.new(0, 16, 0, -68),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = T.card,
        BorderSizePixel = 0,
        ZIndex = 300,
        Parent = c.gui,
    })
    UI.corner(c.toast, 10)
    UI.stroke(c.toast, T.cardborder, 1)

    UI.new("ImageLabel", {
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 3),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "",
        ImageColor3 = T.black,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 299,
        Parent = c.toast,
    })

    c.toastBar = UI.new("Frame", {
        Size = UDim2.new(0, 3, 0.5, 0),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = T.accent,
        BorderSizePixel = 0,
        ZIndex = 301,
        Parent = c.toast,
    })
    UI.corner(c.toastBar, 2)

    c.toastTitle = UI.new("TextLabel", {
        Size = UDim2.new(1, -36, 0, 16),
        Position = UDim2.new(0, 26, 0, 10),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.white,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 301,
        Parent = c.toast,
    })

    c.toastMsg = UI.new("TextLabel", {
        Size = UDim2.new(1, -36, 0, 14),
        Position = UDim2.new(0, 26, 0, 30),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.gray,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 301,
        Parent = c.toast,
    })

    -- ── Settings Overlay ──
    c.stOverlay = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.black,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 100,
        Parent = c.gui,
    })

    local stHeight = 340

    c.stCard = UI.new("Frame", {
        Size = UDim2.new(0, 340, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.card,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 101,
        Parent = c.stOverlay,
    })
    UI.corner(c.stCard, 12)
    UI.stroke(c.stCard, T.cardborder, 1)

    UI.new("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "",
        ImageColor3 = T.black,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 100,
        Parent = c.stCard,
    })

    UI.new("TextLabel", {
        Size = UDim2.new(1, -36, 0, 22),
        Position = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = T.white,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = c.stCard,
    })

    UI.new("Frame", {
        Size = UDim2.new(1, -36, 0, 1),
        Position = UDim2.new(0.5, 0, 0, 50),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.cardborder,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = c.stCard,
    })

    local stToggles = UI.new("ScrollingFrame", {
        Size = UDim2.new(1, -36, 0, 220),
        Position = UDim2.new(0.5, 0, 0, 60),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 102,
        Parent = c.stCard,
    })
    UI.new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = stToggles })

    local function makeToggle(parent, name, desc, default, order)
        local fr = UI.new("Frame", {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = T.input,
            BorderSizePixel = 0,
            LayoutOrder = order or 0,
            ZIndex = 103,
            Parent = parent,
        })
        UI.corner(fr, 8)

        UI.new("TextLabel", {
            Size = UDim2.new(1, -70, 0, 16),
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.white,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 104,
            Parent = fr,
        })

        UI.new("TextLabel", {
            Size = UDim2.new(1, -70, 0, 12),
            Position = UDim2.new(0, 12, 0, 26),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = T.muted,
            Font = Enum.Font.GothamMedium,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 104,
            Parent = fr,
        })

        local track = UI.new("Frame", {
            Size = UDim2.new(0, 38, 0, 20),
            Position = UDim2.new(1, -12, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = default and T.accent or T.toggleoff,
            BorderSizePixel = 0,
            ZIndex = 104,
            Parent = fr,
        })
        UI.corner(track, 10)

        local knob = UI.new("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = default and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = T.white,
            BorderSizePixel = 0,
            ZIndex = 105,
            Parent = track,
        })
        UI.corner(knob, 7)

        local on = default and true or false
        local btn = UI.new("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 106,
            Parent = fr,
        })

        btn.MouseEnter:Connect(function() UI.tween(fr, 0.15, { BackgroundColor3 = T.hover }) end)
        btn.MouseLeave:Connect(function() UI.tween(fr, 0.15, { BackgroundColor3 = T.input }) end)
        btn.MouseButton1Click:Connect(function()
            on = not on
            UI.tween(track, 0.25, { BackgroundColor3 = on and T.accent or T.toggleoff })
            UI.tween(knob, 0.25, { Position = on and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
        end)

        return fr, function() return on end
    end

    makeToggle(stToggles, "Auto Execute", "Automatically run on join", false, 1)
    makeToggle(stToggles, "Remember Key", "Save your key for next session", true, 2)
    makeToggle(stToggles, "Notifications", "Show status notifications", true, 3)
    makeToggle(stToggles, "Anti AFK", "Prevent being kicked for inactivity", false, 4)

    c.stClose = UI.new("TextButton", {
        Size = UDim2.new(1, -36, 0, 38),
        Position = UDim2.new(0.5, 0, 0, 286),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = T.input,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 102,
        Parent = c.stCard,
    })
    UI.corner(c.stClose, 8)
    UI.stroke(c.stClose, T.inputborder, 1)
    UI.new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Close", TextColor3 = T.gray, Font = Enum.Font.GothamSemibold, TextSize = 12, ZIndex = 103, Parent = c.stClose })

    c.stClose.MouseEnter:Connect(function() UI.tween(c.stClose, 0.15, { BackgroundColor3 = T.hover }) end)
    c.stClose.MouseLeave:Connect(function() UI.tween(c.stClose, 0.15, { BackgroundColor3 = T.input }) end)

    c.stOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local m = input.Position
            local p, s = c.stCard.AbsolutePosition, c.stCard.AbsoluteSize
            if m.X < p.X or m.X > p.X + s.X or m.Y < p.Y or m.Y > p.Y + s.Y then
                UI.closePanel(c.stOverlay, c.stCard)
            end
        end
    end)

    c.stHeight = stHeight

    return c
end

-- Panel helpers
local _panelOpen = false

function UI.openPanel(overlay, panel, height)
    if _panelOpen then return end
    _panelOpen = true
    overlay.Visible = true
    UI.tween(overlay, 0.3, { BackgroundTransparency = 0.45 })
    panel.Size = UDim2.new(0, 340, 0, 0)
    UI.tween(panel, 0.4, { Size = UDim2.new(0, 340, 0, height) }, Enum.EasingStyle.Back)
end

function UI.closePanel(overlay, panel)
    if not _panelOpen then return end
    UI.tween(overlay, 0.25, { BackgroundTransparency = 1 })
    UI.tween(panel, 0.25, { Size = UDim2.new(0, 340, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.26, function()
        overlay.Visible = false
        _panelOpen = false
    end)
end


local Loader = {}

function Loader.new()
    local self = {
        ui = nil,
        api = nil,
        toastThread = nil,
    }

    function self.init()
        Utils.ensureFolder(CONFIG.FOLDER_ROOT)

        self.api = {}

        local logoAsset = Assets.loadLogo()
        self.ui = UI.build(logoAsset)

        self.setupEvents()
        self.playIntro()

        Utils.log("INFO", "Loader ready")
    end

    function self.notify(title, msg, color)
        local ui = self.ui
        ui.toastTitle.Text = title
        ui.toastMsg.Text = msg
        ui.toastBar.BackgroundColor3 = color or T.accent

        if self.toastThread then
            pcall(function() task.cancel(self.toastThread) end)
            self.toastThread = nil
        end

        UI.tween(ui.toast, 0.45, { Position = UDim2.new(0, 16, 0.1, 0) }, Enum.EasingStyle.Back)
        self.toastThread = task.delay(3.5, function()
            UI.tween(ui.toast, 0.35, { Position = UDim2.new(0, 16, 0, -68) })
            self.toastThread = nil
        end)
    end

    function self.shake()
        local ui = self.ui
        local orig = ui.card.Position
        task.spawn(function()
            for _ = 1, 6 do
                local rx, ry = math.random(-8, 8), math.random(-8, 8)
                UI.tween(ui.card, 0.05, { Position = UDim2.new(orig.X.Scale, orig.X.Offset + rx, orig.Y.Scale, orig.Y.Offset + ry) })
                task.wait(0.05)
            end
            UI.tween(ui.card, 0.1, { Position = orig })
        end)
    end

    function self.close()
        local ui = self.ui
        UI.tween(ui.card, 0.35, { Position = UDim2.new(0.5, 0, 0.5, 15), BackgroundTransparency = 1, Size = UDim2.new(0, 390, 0, 330) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        UI.tween(ui.cardStroke, 0.25, { Transparency = 1 })

        for _, v in ui.card:GetDescendants() do
            if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                UI.tween(v, 0.15, { TextTransparency = 1 })
            elseif v:IsA("ImageLabel") then
                UI.tween(v, 0.15, { ImageTransparency = 1 })
            elseif v:IsA("Frame") and v ~= ui.card then
                UI.tween(v, 0.15, { BackgroundTransparency = 1 })
            elseif v:IsA("UIStroke") then
                UI.tween(v, 0.15, { Transparency = 1 })
            end
        end

        task.delay(0.4, function()
            if ui.gui then ui.gui:Destroy() end
        end)
    end

  function self.validateKey()
    if not GameDetector.isSupported() then
        self.notify("Unsupported", "This game is not currently supported.", T.red)
        self.shake()
        return
    end

    self.notify("Loading", "Launching script...", T.green)

    task.delay(0.5, function()
        self.close()

        -- YOUR SCRIPT HERE
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DecryptedGuest/Static/main/loader.luau"))()
    end)
end

    function self.openDiscord()
        task.spawn(function()
            pcall(function()
                local req = request or http_request or (syn and syn.request)
                if req then
                    req({
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json", ["origin"] = "https://discord.com" },
                        Body = Services.HttpService:JSONEncode({
                            args = { code = CONFIG.DISCORD_INVITE },
                            cmd = "INVITE_BROWSER",
                            nonce = ".",
                        }),
                    })
                end
            end)
            if setclipboard then
                setclipboard("https://discord.gg/" .. CONFIG.DISCORD_INVITE)
                self.notify("Discord", "Invite link copied!", T.discord)
            end
        end)
    end

    function self.setupEvents()
        local ui = self.ui

        ui.closeBtn.MouseButton1Click:Connect(function() self.close() end)

        ui.redeemBtn.MouseButton1Click:Connect(function()
    self.validateKey()
end)

        ui.discordBtn.MouseButton1Click:Connect(function() self.openDiscord() end)

        ui.settingsBtn.MouseButton1Click:Connect(function()
            UI.openPanel(ui.stOverlay, ui.stCard, ui.stHeight)
        end)

        ui.stClose.MouseButton1Click:Connect(function()
            UI.closePanel(ui.stOverlay, ui.stCard)
        end)
    end

    function self.playIntro()
        local ui = self.ui

        task.spawn(function()
            task.wait(0.2)

            UI.tween(ui.card, 0.55, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }, Enum.EasingStyle.Back)
            UI.tween(ui.cardStroke, 0.55, { Transparency = 0 })
            UI.tween(ui.topAccent, 0.45, { BackgroundTransparency = 0 })
            task.wait(0.5)

            UI.tween(ui.loadLogo, 0.45, { ImageTransparency = 0 })
            task.wait(0.3)
            UI.tween(ui.loadTitle, 0.4, { TextTransparency = 0 })
            task.wait(0.15)
            UI.tween(ui.loadStatus, 0.3, { TextTransparency = 0 })
            UI.tween(ui.progTrack, 0.3, { BackgroundTransparency = 0 })
            UI.tween(ui.progFill, 0.3, { BackgroundTransparency = 0 })
            task.wait(0.3)

            ui.loadStatus.Text = "Checking environment..."
            UI.tween(ui.progFill, 0.6, { Size = UDim2.new(0.3, 0, 1, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.7)

            ui.loadStatus.Text = "Loading modules..."
            UI.tween(ui.progFill, 0.5, { Size = UDim2.new(0.65, 0, 1, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.6)

            ui.loadStatus.Text = "Preparing interface..."
            UI.tween(ui.progFill, 0.45, { Size = UDim2.new(0.85, 0, 1, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.5)

            ui.loadStatus.Text = "Ready"
            UI.tween(ui.progFill, 0.3, { Size = UDim2.new(1, 0, 1, 0) }, Enum.EasingStyle.Sine)
            task.wait(0.45)

            UI.tween(ui.loadLogo, 0.35, { ImageTransparency = 1 })
            UI.tween(ui.loadTitle, 0.35, { TextTransparency = 1 })
            UI.tween(ui.loadStatus, 0.35, { TextTransparency = 1 })
            UI.tween(ui.progTrack, 0.35, { BackgroundTransparency = 1 })
            UI.tween(ui.progFill, 0.35, { BackgroundTransparency = 1 })
            task.wait(0.4)

            ui.loadContent.Visible = false
            ui.loginContent.Visible = true

            UI.tween(ui.logoImg, 0.4, { ImageTransparency = 0 })
            UI.tween(ui.titleLabel, 0.4, { TextTransparency = 0 })
            UI.tween(ui.closeBtn, 0.4, { TextTransparency = 0 })
            task.wait(0.06)

            UI.tween(ui.hSep, 0.35, { BackgroundTransparency = 0 })
            task.wait(0.06)

            UI.tween(ui.redeemBtn, 0.35, { BackgroundTransparency = 0 })
            UI.tween(ui.redeemLabel, 0.35, { TextTransparency = 0 })
            task.wait(0.06)

            UI.tween(ui.bSep, 0.35, { BackgroundTransparency = 0 })
            UI.tween(ui.discordBtn, 0.35, { BackgroundTransparency = 0 })
            UI.tween(ui.discordLabel, 0.35, { TextTransparency = 0 })
            UI.tween(ui.settingsBtn, 0.35, { BackgroundTransparency = 0 })
            UI.tween(ui.settingsBtnStroke, 0.35, { Transparency = 0 })
            UI.tween(ui.settingsLabel, 0.35, { TextTransparency = 0 })
        end)
    end

    return self
end

local loader = Loader.new()
Utils.try(function() loader.init() end, "Loader initialization failed")
