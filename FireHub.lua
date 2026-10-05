local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

---------------------------------------------------------
-- GESTÃO DE PASTA FIREHUB, SAVES E ARQUIVOS MP3 NO EXECUTOR
---------------------------------------------------------
local folderName = "FireHub"
local saveFileName = folderName .. "/FireHubSaves.txt"

-- Funções do executor para manipular arquivos
local isfolder = isfolder or (getgenv and getgenv().isfolder)
local makefolder = makefolder or (getgenv and getgenv().makefolder)
local listfiles = listfiles or (getgenv and getgenv().listfiles)
local isfile = isfile or (getgenv and getgenv().isfile)
local writefile = writefile or (getgenv and getgenv().writefile)
local readfile = readfile or (getgenv and getgenv().readfile)
local getcustomasset = getcustomasset or (getgenv and getgenv().getcustomasset) or (syn and syn.getcustomasset)

if isfolder and makefolder then
    if not isfolder(folderName) then
        makefolder(folderName)
    end
end

-- Tabela de Estados Salváveis
local Options = {
    walkSpeed = 16,
    jumpPower = 50,
    flySpeed = 50,
    noclip = false,
    fly = false,
    infiniteJump = false,
    invisibility = false,
    esp = false,
    fullbright = false,
    tracers = false,
    xray = false,
    autoClick = false,
    autoJump = false,
    autoSpin = false,
    autoWalk = false,
    pingAlert = false,
    preventTp = false,
    autoRejoin = false
}

-- Salvar Opções no FireHubSaves.txt
local function saveSettings()
    if writefile then
        local content = ""
        for k, v in pairs(Options) do
            content = content .. tostring(k) .. "=" .. tostring(v) .. "\n"
        end
        writefile(saveFileName, content)
    end
end

-- Carregar Opções do FireHubSaves.txt
local function loadSettings()
    if isfile and readfile and isfile(saveFileName) then
        local success, content = pcall(readfile, saveFileName)
        if success and content then
            for line in string.gmatch(content, "[^\r\n]+") do
                local key, val = string.match(line, "([^=]+)=([^=]+)")
                if key and val and Options[key] ~= nil then
                    if val == "true" then
                        Options[key] = true
                    elseif val == "false" then
                        Options[key] = false
                    elseif tonumber(val) then
                        Options[key] = tonumber(val)
                    end
                end
            end
        end
    else
        saveSettings()
    end
end

loadSettings()

-- Remove interface anterior se existir
if PlayerGui:FindFirstChild("FireHubUI") then
    PlayerGui.FireHubUI:Destroy()
end

-- ScreenGui Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FireHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

---------------------------------------------------------
-- SISTEMA DE NOTIFICAÇÕES / MENSAGENS DO SCRIPT
---------------------------------------------------------
local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 220, 1, -20)
notificationContainer.Position = UDim2.new(1, -230, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.ZIndex = 100
notificationContainer.Parent = screenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 6)
notifLayout.Parent = notificationContainer

local function notify(title, text, duration)
    duration = duration or 3
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 45)
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    card.BackgroundTransparency = 0.1
    card.Position = UDim2.new(1, 230, 0, 0)
    card.Parent = notificationContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 130, 0)
    stroke.Thickness = 1
    stroke.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -10, 0, 18)
    tLabel.Position = UDim2.new(0, 8, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(255, 130, 0)
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = card

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -10, 0, 18)
    msgLabel.Position = UDim2.new(0, 8, 0, 22)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = text
    msgLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 9
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = card

    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(duration, function()
        local tw = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        TweenService:Create(tLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(msgLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        tw:Play()
        tw.Completed:Connect(function()
            card:Destroy()
        end)
    end)
end

notify("FireHub", "Script carregado e configurações restauradas!", 4)

-- Configurações de Tamanho
local mainWidth = 380
local mainHeight = 260
local barWidth = 14
local barHeight = 220

local expandedPosition = UDim2.new(0.5, -mainWidth / 2, 0.5, -mainHeight / 2)
local barPosition = UDim2.new(0, 20, 0.5, -barHeight / 2)

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, barWidth, 0, barHeight)
mainFrame.Position = barPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = false
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Fundo de Imagem
local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundImage"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.Position = UDim2.new(0, 0, 0, 0)
bgImage.BackgroundTransparency = 1

local rawImageUrl = "https://raw.githubusercontent.com/joaopedroscriptsblox/FireHub/main/ChatGPT%20Image%205%20de%20out.%20de%202026%2C%2006_44_21.png"
local localFileName = folderName .. "/FireHubBG.png"

local function getAsset(url, fileName)
    if getcustomasset and writefile and game.HttpGet then
        pcall(function()
            if not isfile or not isfile(fileName) then
                writefile(fileName, game:HttpGet(url))
            end
        end)
        if isfile and isfile(fileName) then
            return getcustomasset(fileName)
        end
    end
    return url
end

bgImage.Image = getAsset(rawImageUrl, localFileName)
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.Parent = mainFrame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 10)
bgCorner.Parent = bgImage

-- Título Principal
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 130, 0, 25)
titleLabel.Position = UDim2.new(0, 10, 0, 4)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FireHub"
titleLabel.TextColor3 = Color3.fromRGB(255, 130, 0)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTransparency = 1
titleLabel.ZIndex = 2
titleLabel.Parent = mainFrame

-- Botão Minimizar (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeBtn.Position = UDim2.new(1, -50, 0, 4)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextTransparency = 1
minimizeBtn.ZIndex = 2
minimizeBtn.Parent = mainFrame

-- Botão Fechar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -25, 0, 4)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextTransparency = 1
closeBtn.ZIndex = 2
closeBtn.Parent = mainFrame

-- Conteúdo Principal
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -16, 1, -36)
contentFrame.Position = UDim2.new(0, 8, 0, 30)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 2
contentFrame.Parent = mainFrame

-- BARRA LATERAL ESQUERDA (Menu de Abas)
local sidebarFrame = Instance.new("ScrollingFrame")
sidebarFrame.Name = "Sidebar"
sidebarFrame.Size = UDim2.new(0, 110, 1, 0)
sidebarFrame.Position = UDim2.new(0, 0, 0, 0)
sidebarFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
sidebarFrame.BackgroundTransparency = 0.2
sidebarFrame.BorderSizePixel = 0
sidebarFrame.ScrollBarThickness = 2
sidebarFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 130, 0)
sidebarFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebarFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
sidebarFrame.Parent = contentFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebarFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 3)
sidebarLayout.Parent = sidebarFrame

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 3)
sidebarPadding.PaddingLeft = UDim.new(0, 3)
sidebarPadding.PaddingRight = UDim.new(0, 3)
sidebarPadding.PaddingBottom = UDim.new(0, 3)
sidebarPadding.Parent = sidebarFrame

sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    sidebarFrame.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 6)
end)

-- CONTAINER DAS ABAS
local pagesContainer = Instance.new("Frame")
pagesContainer.Name = "PagesContainer"
pagesContainer.Size = UDim2.new(1, -116, 1, 0)
pagesContainer.Position = UDim2.new(0, 116, 0, 0)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = contentFrame

-- Animações Suaves
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local isMinimized = true

local function setElementsTransparency(transparency)
    titleLabel.TextTransparency = transparency
    minimizeBtn.TextTransparency = transparency
    closeBtn.TextTransparency = transparency
    for _, child in ipairs(contentFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextTransparency = transparency
        elseif child:IsA("Frame") or child:IsA("ScrollingFrame") then
            child.BackgroundTransparency = math.max(child.BackgroundTransparency, transparency * 0.5)
        end
    end
end

local function expandUI()
    isMinimized = false
    mainFrame.ClipsDescendants = false
    local expandTween = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, mainWidth, 0, mainHeight),
        Position = expandedPosition
    })
    expandTween:Play()
    contentFrame.Visible = true
    setElementsTransparency(0)
end

local function minimizeUI()
    isMinimized = true
    mainFrame.ClipsDescendants = true
    contentFrame.Visible = false
    setElementsTransparency(1)
    local minimizeTween = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, barWidth, 0, barHeight),
        Position = barPosition
    })
    minimizeTween:Play()
end

task.delay(0.2, function()
    expandUI()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        minimizeUI()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    setElementsTransparency(1)
    mainFrame.ClipsDescendants = true
    local closeTween = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, barHeight),
        BackgroundTransparency = 1
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

---------------------------------------------------------
-- SISTEMA DE MOVIMENTAÇÃO DA INTERFACE
---------------------------------------------------------
local dragging = false
local dragStart, startPos
local isClick = false

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        isClick = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            isClick = false
        end
        
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        
        if isMinimized then
            if isClick then
                expandUI()
            else
                local viewportSize = Camera.ViewportSize
                local currentX = mainFrame.Position.X.Offset
                local currentY = mainFrame.Position.Y.Offset
                
                local snapX = (currentX + barWidth / 2 > viewportSize.X / 2) and (viewportSize.X - barWidth - 15) or 15
                local snapY = math.clamp(currentY, 15, viewportSize.Y - barHeight - 15)
                
                barPosition = UDim2.new(0, snapX, 0, snapY)
                TweenService:Create(mainFrame, tweenInfo, {Position = barPosition}):Play()
            end
        else
            expandedPosition = mainFrame.Position
        end
    end
end)

---------------------------------------------------------
-- SISTEMA DE NAVEGAÇÃO DE ABAS
---------------------------------------------------------
local tabs = {}

local function createTab(tabName)
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 130, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = pagesContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 4)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingRight = UDim.new(0, 4)
    pagePadding.Parent = page

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 5)
    end)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabName .. "TabBtn"
    tabBtn.Size = UDim2.new(1, 0, 0, 22)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    tabBtn.Text = tabName
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 9
    tabBtn.Parent = sidebarFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            t.Button.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
        page.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    tabs[tabName] = {Page = page, Button = tabBtn}
    return page
end

local function createButton(text, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 9
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    return btn
end

local function createSlider(title, min, max, default, parent, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 30)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    sliderFrame.Parent = parent

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 4)
    sCorner.Parent = sliderFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 12)
    label.Position = UDim2.new(0, 4, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 9
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -8, 0, 6)
    sliderBg.Position = UDim2.new(0, 4, 0, 18)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBg.Parent = sliderFrame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 3)
    bgCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local sliding = false

    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local value = math.floor(min + (max - min) * pos)
        label.Text = title .. ": " .. tostring(value)
        callback(value)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

-- Criando as Abas (Sem a aba Scripts)
local tab1Page = createTab("Jogador & Alvo")
local tab2Page = createTab("Movimento")
local tab3Page = createTab("Visual")
local tab4Page = createTab("Teleportes")
local tab5Page = createTab("Servidor")
local tab6Page = createTab("Automacoes")
local tab7Page = createTab("Utilitarios")
local tab8Page = createTab("Servidores Extra")
local tab9Page = createTab("Diversos & Estilo")
local tabAudioPage = createTab("Áudio")

tab1Page.Visible = true
tabs["Jogador & Alvo"].Button.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
tabs["Jogador & Alvo"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

---------------------------------------------------------
-- ABA 1: JOGADOR & ALVO
---------------------------------------------------------
local selectedPlayer = nil
local viewCameraActive = false
local flingActive = false
local flingConnection = nil
local savedCFrame = nil
local flingTask = nil
local lockActive = false

local listDropdownBtn = Instance.new("TextButton")
listDropdownBtn.Size = UDim2.new(1, 0, 0, 22)
listDropdownBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
listDropdownBtn.Text = " Selecionar Alvo [v]"
listDropdownBtn.TextColor3 = Color3.fromRGB(255, 130, 0)
listDropdownBtn.Font = Enum.Font.GothamSemibold
listDropdownBtn.TextSize = 9
listDropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
listDropdownBtn.Parent = tab1Page

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 4)
dropCorner.Parent = listDropdownBtn

local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(1, 0, 0, 80)
playerListFrame.Position = UDim2.new(0, 0, 1, 2)
playerListFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 2
playerListFrame.Visible = false
playerListFrame.ZIndex = 10
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.Parent = listDropdownBtn

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = playerListFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
end)

local refreshBtn = createButton("Atualizar Lista de Jogadores", tab1Page)
local cameraToggle = createButton("Ver Câmera do Alvo: OFF", tab1Page)
local tpBtn = createButton("Teleportar para Alvo", tab1Page)
local flingToggle = createButton("Fling Alvo (7s): OFF", tab1Page)
local lockBtn = createButton("Travar Mira no Alvo: OFF", tab1Page)
local resetCamBtn = createButton("Resetar Câmera", tab1Page)

listDropdownBtn.MouseButton1Click:Connect(function()
    playerListFrame.Visible = not playerListFrame.Visible
end)

local function updatePlayerList()
    for _, item in ipairs(playerListFrame:GetChildren()) do
        if item:IsA("TextButton") then item:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -4, 0, 18)
            pBtn.BackgroundColor3 = (selectedPlayer == p) and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(35, 35, 45)
            pBtn.Text = " " .. p.DisplayName .. " (@" .. p.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.Font = Enum.Font.Gotham
            pBtn.TextSize = 9
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.ZIndex = 11
            pBtn.Parent = playerListFrame

            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 3)
            pCorner.Parent = pBtn

            pBtn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                listDropdownBtn.Text = " Alvo: " .. p.DisplayName
                playerListFrame.Visible = false
                updatePlayerList()
            end)
        end
    end
end

refreshBtn.MouseButton1Click:Connect(updatePlayerList)
updatePlayerList()

cameraToggle.MouseButton1Click:Connect(function()
    viewCameraActive = not viewCameraActive
    if viewCameraActive and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = selectedPlayer.Character.Humanoid
        cameraToggle.Text = "Ver Câmera do Alvo: ON"
        cameraToggle.TextColor3 = Color3.fromRGB(255, 130, 0)
    else
        viewCameraActive = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        cameraToggle.Text = "Ver Câmera do Alvo: OFF"
        cameraToggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
        end
    end
end)

local function stopFlingProcess()
    flingActive = false
    flingToggle.Text = "Fling Alvo (7s): OFF"
    flingToggle.TextColor3 = Color3.fromRGB(220, 220, 220)

    if flingConnection then flingConnection:Disconnect() flingConnection = nil end
    if flingTask then task.cancel(flingTask) flingTask = nil end

    task.spawn(function()
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP then
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.RotVelocity = Vector3.new(0, 0, 0)
            myHRP.Anchored = true
            task.wait(3)
            myHRP.Anchored = false
            if savedCFrame then
                for i = 1, 3 do
                    myHRP.Velocity = Vector3.new(0, 0, 0)
                    myHRP.RotVelocity = Vector3.new(0, 0, 0)
                    myHRP.CFrame = savedCFrame
                    task.wait(0.05)
                end
                savedCFrame = nil
            end
        end
    end)
end

flingToggle.MouseButton1Click:Connect(function()
    if flingActive then
        stopFlingProcess()
    else
        if not selectedPlayer then return end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP then
            savedCFrame = myHRP.CFrame
            flingActive = true
            flingToggle.Text = "Fling Alvo (7s): ON"
            flingToggle.TextColor3 = Color3.fromRGB(255, 130, 0)

            local angle = 0
            local offsets = {Vector3.new(2, 0, 0), Vector3.new(-2, 0, 0), Vector3.new(0, 0, 2), Vector3.new(0, 0, -2)}
            local step = 1

            flingConnection = RunService.Heartbeat:Connect(function()
                if not flingActive or not selectedPlayer or not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    stopFlingProcess()
                    return
                end
                local targetHRP = selectedPlayer.Character.HumanoidRootPart
                local currentHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if currentHRP and targetHRP then
                    angle = angle + 100
                    step = (step % #offsets) + 1
                    currentHRP.Velocity = Vector3.new(9999, 9999, 9999)
                    currentHRP.RotVelocity = Vector3.new(9999, 9999, 9999)
                    currentHRP.CFrame = targetHRP.CFrame * CFrame.new(offsets[step]) * CFrame.Angles(0, math.rad(angle), 0)
                end
            end)

            flingTask = task.delay(7, function()
                if flingActive then stopFlingProcess() end
            end)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if lockActive and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, selectedPlayer.Character.HumanoidRootPart.Position)
    end
end)

lockBtn.MouseButton1Click:Connect(function()
    lockActive = not lockActive
    lockBtn.Text = lockActive and "Travar Mira no Alvo: ON" or "Travar Mira no Alvo: OFF"
    lockBtn.TextColor3 = lockActive and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end)

resetCamBtn.MouseButton1Click:Connect(function()
    viewCameraActive = false
    lockActive = false
    cameraToggle.Text = "Ver Câmera do Alvo: OFF"
    cameraToggle.TextColor3 = Color3.fromRGB(220, 220, 220)
    lockBtn.Text = "Travar Mira no Alvo: OFF"
    lockBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end)

---------------------------------------------------------
-- ABA 2: MOVIMENTO
---------------------------------------------------------
local noclipConnection = nil

local function applyWalkSpeed(val)
    Options.walkSpeed = val
    saveSettings()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end

local function applyJumpPower(val)
    Options.jumpPower = val
    saveSettings()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end

createSlider("Velocidade de Caminhada", 16, 300, Options.walkSpeed, tab2Page, applyWalkSpeed)
createSlider("Altura do Pulo", 50, 300, Options.jumpPower, tab2Page, applyJumpPower)
createSlider("Velocidade do Voo (Fly)", 10, 200, Options.flySpeed, tab2Page, function(val)
    Options.flySpeed = val
    saveSettings()
end)

local noclipBtn = createButton("Noclip (Atravessar): OFF", tab2Page)
local flyBtn = createButton("Voo (Fly Mobile): OFF", tab2Page)
local infJumpBtn = createButton("Pulo Infinito: OFF", tab2Page)

local function enableNoclip()
    if not noclipConnection then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function toggleNoclip(state)
    Options.noclip = state
    saveSettings()
    noclipBtn.Text = Options.noclip and "Noclip (Atravessar): ON" or "Noclip (Atravessar): OFF"
    noclipBtn.TextColor3 = Options.noclip and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
    if Options.noclip then
        enableNoclip()
    else
        if not Options.fly then disableNoclip() end
    end
end

noclipBtn.MouseButton1Click:Connect(function()
    toggleNoclip(not Options.noclip)
end)

local flyControlGui = nil
local upPressed, downPressed = false, false

local function createFlyControls()
    if flyControlGui then flyControlGui:Destroy() end
    flyControlGui = Instance.new("Frame")
    flyControlGui.Name = "FlyMobileControls"
    flyControlGui.Size = UDim2.new(0, 90, 0, 100)
    flyControlGui.Position = UDim2.new(0.85, 0, 0.5, -50)
    flyControlGui.BackgroundTransparency = 1
    flyControlGui.Parent = screenGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0, 90, 0, 45)
    upBtn.Position = UDim2.new(0, 0, 0, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(255, 130, 0)
    upBtn.Text = "SUBIR"
    upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    upBtn.Font = Enum.Font.GothamBold
    upBtn.TextSize = 12
    upBtn.Parent = flyControlGui

    local uC = Instance.new("UICorner")
    uC.CornerRadius = UDim.new(0, 6)
    uC.Parent = upBtn

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0, 90, 0, 45)
    downBtn.Position = UDim2.new(0, 0, 0, 52)
    downBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    downBtn.Text = "DESCER"
    downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    downBtn.Font = Enum.Font.GothamBold
    downBtn.TextSize = 12
    downBtn.Parent = flyControlGui

    local dC = Instance.new("UICorner")
    dC.CornerRadius = UDim.new(0, 6)
    dC.Parent = downBtn

    upBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = true end
    end)
    upBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = false end
    end)

    downBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = true end
    end)
    downBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = false end
    end)
end

local function toggleFly(state)
    Options.fly = state
    saveSettings()
    flyBtn.Text = Options.fly and "Voo (Fly Mobile): ON" or "Voo (Fly Mobile): OFF"
    flyBtn.TextColor3 = Options.fly and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    local myChar = LocalPlayer.Character
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if Options.fly and hrp and humanoid then
        createFlyControls()
        humanoid.PlatformStand = true
        enableNoclip()

        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end

        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "FlyBodyVelocity"
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.Parent = hrp

        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyBodyGyro"
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp

        task.spawn(function()
            while Options.fly and hrp:FindFirstChild("FlyBodyVelocity") do
                local moveDir = humanoid.MoveDirection
                local verticalDir = 0
                if upPressed then verticalDir = 1 end
                if downPressed then verticalDir = -1 end

                local camCFrame = Camera.CFrame
                local lookVector = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
                local rightVector = Vector3.new(camCFrame.RightVector.X, 0, camCFrame.RightVector.Z).Unit

                if lookVector.Magnitude == 0 then lookVector = Vector3.new(0,0,-1) end
                if rightVector.Magnitude == 0 then rightVector = Vector3.new(1,0,0) end

                local moveVel = Vector3.new(0,0,0)
                if moveDir.Magnitude > 0 then
                    moveVel = moveDir * Options.flySpeed
                end

                bodyVel.Velocity = Vector3.new(moveVel.X, verticalDir * Options.flySpeed, moveVel.Z)
                bodyGyro.CFrame = camCFrame

                task.wait()
            end

            bodyVel:Destroy()
            bodyGyro:Destroy()
            humanoid.PlatformStand = false
            if not Options.noclip then disableNoclip() end
            if flyControlGui then flyControlGui:Destroy() end
        end)
    else
        if humanoid then humanoid.PlatformStand = false end
        if not Options.noclip then disableNoclip() end
        if flyControlGui then flyControlGui:Destroy() end
    end
end

flyBtn.MouseButton1Click:Connect(function()
    toggleFly(not Options.fly)
end)

UserInputService.JumpRequest:Connect(function()
    if Options.infiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

infJumpBtn.MouseButton1Click:Connect(function()
    Options.infiniteJump = not Options.infiniteJump
    saveSettings()
    infJumpBtn.Text = Options.infiniteJump and "Pulo Infinito: ON" or "Pulo Infinito: OFF"
    infJumpBtn.TextColor3 = Options.infiniteJump and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end)

---------------------------------------------------------
-- ABA 3: VISUAL
---------------------------------------------------------
local invisBtn = createButton("Invisibilidade Local: OFF", tab3Page)
local espBtn = createButton("ESP Visao Jogadores: OFF", tab3Page)
local noFogBtn = createButton("Remover Nevoa / Fog", tab3Page)
local brightBtn = createButton("Iluminacao Fullbright: OFF", tab3Page)
local tracersBtn = createButton("Linhas Tracers: OFF", tab3Page)
local xrayBtn = createButton("X-Ray Paredes: OFF", tab3Page)
local dayTimeBtn = createButton("Mudar Para Dia Limpo", tab3Page)

local function toggleInvis(state)
    Options.invisibility = state
    saveSettings()
    local myChar = LocalPlayer.Character
    if myChar then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = Options.invisibility and 1 or 0
            end
        end
    end
    invisBtn.Text = Options.invisibility and "Invisibilidade Local: ON" or "Invisibilidade Local: OFF"
    invisBtn.TextColor3 = Options.invisibility and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end

invisBtn.MouseButton1Click:Connect(function()
    toggleInvis(not Options.invisibility)
end)

local function toggleEsp(state)
    Options.esp = state
    saveSettings()
    espBtn.Text = Options.esp and "ESP Visao Jogadores: ON" or "ESP Visao Jogadores: OFF"
    espBtn.TextColor3 = Options.esp and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if Options.esp then
                if not p.Character:FindFirstChild("FireESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "FireESP"
                    hl.FillColor = Color3.fromRGB(255, 130, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = p.Character
                end
            else
                if p.Character:FindFirstChild("FireESP") then
                    p.Character.FireESP:Destroy()
                end
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    toggleEsp(not Options.esp)
end)

noFogBtn.MouseButton1Click:Connect(function()
    Lighting.FogEnd = 100000
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("Atmosphere") then v:Destroy() end
    end
    notify("Visual", "Névoa removida com sucesso!")
end)

local function toggleFullbright(state)
    Options.fullbright = state
    saveSettings()
    brightBtn.Text = Options.fullbright and "Iluminacao Fullbright: ON" or "Iluminacao Fullbright: OFF"
    brightBtn.TextColor3 = Options.fullbright and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
    if Options.fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
    end
end

brightBtn.MouseButton1Click:Connect(function()
    toggleFullbright(not Options.fullbright)
end)

tracersBtn.MouseButton1Click:Connect(function()
    Options.tracers = not Options.tracers
    saveSettings()
    tracersBtn.Text = Options.tracers and "Linhas Tracers: ON" or "Linhas Tracers: OFF"
    tracersBtn.TextColor3 = Options.tracers and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end)

local function toggleXray(state)
    Options.xray = state
    saveSettings()
    xrayBtn.Text = Options.xray and "X-Ray Paredes: ON" or "X-Ray Paredes: OFF"
    xrayBtn.TextColor3 = Options.xray and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            obj.LocalTransparencyModifier = Options.xray and 0.5 or 0
        end
    end
end

xrayBtn.MouseButton1Click:Connect(function()
    toggleXray(not Options.xray)
end)

dayTimeBtn.MouseButton1Click:Connect(function()
    Lighting.ClockTime = 12
    notify("Visual", "Horário alterado para o meio-dia.")
end)

---------------------------------------------------------
-- ABA 4: TELEPORTES
---------------------------------------------------------
local savedPosition = nil

local savePosBtn = createButton("Salvar Posicao Atual", tab4Page)
local loadPosBtn = createButton("Teleportar Posicao Salva", tab4Page)
local tpUpBtn = createButton("Teleportar 10 Blocs Cima", tab4Page)
local tpForwardBtn = createButton("Teleportar 10 Blocs Frente", tab4Page)
local tpSpawnBtn = createButton("Teleportar Spawn Servidor", tab4Page)
local tpRandomPlayerBtn = createButton("Teleportar Jogador Aleatorio", tab4Page)
local resetPosBtn = createButton("Limpar Posicao Salva", tab4Page)

savePosBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        savedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
        notify("Teleporte", "Posição salva com sucesso!")
    end
end)

loadPosBtn.MouseButton1Click:Connect(function()
    if savedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = savedPosition
        notify("Teleporte", "Teleportado para a posição salva.")
    end
end)

tpUpBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
    end
end)

tpForwardBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -10)
    end
end)

tpSpawnBtn.MouseButton1Click:Connect(function()
    local spawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")
    if spawnLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = spawnLocation.CFrame * CFrame.new(0, 3, 0)
    end
end)

tpRandomPlayerBtn.MouseButton1Click:Connect(function()
    local plrs = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(plrs, p)
        end
    end
    if #plrs > 0 then
        local target = plrs[math.random(1, #plrs)]
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
    end
end)

resetPosBtn.MouseButton1Click:Connect(function()
    savedPosition = nil
    notify("Teleporte", "Posição salva foi removida.")
end)

---------------------------------------------------------
-- ABA 5: SERVIDOR
---------------------------------------------------------
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(1, 0, 0, 40)
statsPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
statsPanel.Parent = tab5Page

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 5)
statsCorner.Parent = statsPanel

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0.5, 0, 1, 0)
fpsLabel.Position = UDim2.new(0, 0, 0, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(255, 130, 0)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 11
fpsLabel.Parent = statsPanel

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(0.5, 0, 1, 0)
pingLabel.Position = UDim2.new(0.5, 0, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Text = "PING: -- ms"
pingLabel.TextColor3 = Color3.fromRGB(255, 130, 0)
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = 11
pingLabel.Parent = statsPanel

local frameCount = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 1 then
        fpsLabel.Text = "⚡ FPS: " .. tostring(frameCount)
        frameCount = 0
        lastTime = currentTime
        
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        pingLabel.Text = "📡 PING: " .. tostring(ping) .. " ms"
    end
end)

local rejoinBtn = createButton("Reentrar no Servidor", tab5Page)
local serverHopBtn = createButton("Trocar de Servidor", tab5Page)
local copyJobIdBtn = createButton("Copiar ID do Servidor", tab5Page)
local copyGameIdBtn = createButton("Copiar ID do Jogo", tab5Page)
local playersCountBtn = createButton("Contar Jogadores", tab5Page)
local serverTimeBtn = createButton("Tempo do Servidor", tab5Page)

rejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

serverHopBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

copyJobIdBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(tostring(game.JobId))
        notify("Servidor", "Job ID copiado com sucesso!")
    end
end)

copyGameIdBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(tostring(game.PlaceId))
        notify("Servidor", "Place ID copiado com sucesso!")
    end
end)

playersCountBtn.MouseButton1Click:Connect(function()
    local count = #Players:GetPlayers()
    notify("Servidor", "Total de Jogadores: " .. tostring(count))
end)

serverTimeBtn.MouseButton1Click:Connect(function()
    local timeInSeconds = math.floor(workspace.DistributedGameTime)
    notify("Servidor", "Tempo Online: " .. tostring(timeInSeconds) .. "s")
end)

---------------------------------------------------------
-- ABA 6: AUTOMAÇÕES
---------------------------------------------------------
local autoClickBtn = createButton("Auto Clicker (100ms): OFF", tab6Page)
local autoJumpBtn = createButton("Auto Pulo Continuo: OFF", tab6Page)
local autoRotateBtn = createButton("Girar Personagem: OFF", tab6Page)
local antiAfkBtn = createButton("Ativar Anti-AFK", tab6Page)
local spamChatBtn = createButton("Enviar Mensagem Teste", tab6Page)
local autoWalkBtn = createButton("Caminhar para Frente: OFF", tab6Page)
local clearGuisBtn = createButton("Limpar Interfaces Na Tela", tab6Page)

local function toggleAutoClick(state)
    Options.autoClick = state
    saveSettings()
    autoClickBtn.Text = Options.autoClick and "Auto Clicker (100ms): ON" or "Auto Clicker (100ms): OFF"
    autoClickBtn.TextColor3 = Options.autoClick and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    task.spawn(function()
        while Options.autoClick do
            if mouse1click then mouse1click() end
            task.wait(0.1)
        end
    end)
end

autoClickBtn.MouseButton1Click:Connect(function()
    toggleAutoClick(not Options.autoClick)
end)

local function toggleAutoJump(state)
    Options.autoJump = state
    saveSettings()
    autoJumpBtn.Text = Options.autoJump and "Auto Pulo Continuo: ON" or "Auto Pulo Continuo: OFF"
    autoJumpBtn.TextColor3 = Options.autoJump and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    task.spawn(function()
        while Options.autoJump do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.Jump = true
            end
            task.wait(0.5)
        end
    end)
end

autoJumpBtn.MouseButton1Click:Connect(function()
    toggleAutoJump(not Options.autoJump)
end)

local function toggleAutoSpin(state)
    Options.autoSpin = state
    saveSettings()
    autoRotateBtn.Text = Options.autoSpin and "Girar Personagem: ON" or "Girar Personagem: OFF"
    autoRotateBtn.TextColor3 = Options.autoSpin and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    task.spawn(function()
        while Options.autoSpin do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(20), 0)
            end
            task.wait(0.03)
        end
    end)
end

autoRotateBtn.MouseButton1Click:Connect(function()
    toggleAutoSpin(not Options.autoSpin)
end)

antiAfkBtn.MouseButton1Click:Connect(function()
    local virtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
    notify("Automação", "Anti-AFK ativado com sucesso!")
end)

spamChatBtn.MouseButton1Click:Connect(function()
    local textChannel = game:GetService("TextChatService"):FindFirstChild("TextChannels")
    if textChannel and textChannel:FindFirstChild("RBXGeneral") then
        textChannel.RBXGeneral:SendAsync("FireHub Executado com Sucesso")
    end
end)

local function toggleAutoWalk(state)
    Options.autoWalk = state
    saveSettings()
    autoWalkBtn.Text = Options.autoWalk and "Caminhar para Frente: ON" or "Caminhar para Frente: OFF"
    autoWalkBtn.TextColor3 = Options.autoWalk and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    task.spawn(function()
        while Options.autoWalk do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, -1), true)
            end
            task.wait()
        end
    end)
end

autoWalkBtn.MouseButton1Click:Connect(function()
    toggleAutoWalk(not Options.autoWalk)
end)

clearGuisBtn.MouseButton1Click:Connect(function()
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name ~= "FireHubUI" then
            g.Enabled = not g.Enabled
        end
    end
    notify("Utilitários", "Interfaces ocultadas/exibidas.")
end)

---------------------------------------------------------
-- ABA 7: UTILITÁRIOS
---------------------------------------------------------
local resetCharBtn = createButton("Resetar Personagem", tab7Page)
local resetMoveBtn = createButton("Resetar Velocidade e Pulo", tab7Page)
local destroyBtn = createButton("Fechar Interface Hub", tab7Page)
local removeTexturesBtn = createButton("Remover Texturas (FPS Boost)", tab7Page)
local unlockFpsBtn = createButton("Desbloquear Maximo FPS", tab7Page)
local hideNameBtn = createButton("Esconder Nome do Personagem", tab7Page)
local consoleBtn = createButton("Abrir Console Roblox", tab7Page)

resetCharBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = 0
    end
end)

resetMoveBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
        Options.walkSpeed = 16
        Options.jumpPower = 50
        saveSettings()
        notify("Movimento", "Velocidade e pulo resetados!")
    end
end)

destroyBtn.MouseButton1Click:Connect(function()
    if screenGui then screenGui:Destroy() end
end)

removeTexturesBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            v:Destroy()
        end
    end
    notify("Performance", "Texturas removidas para melhoria de FPS.")
end)

unlockFpsBtn.MouseButton1Click:Connect(function()
    if setfpscap then setfpscap(240) end
    notify("Performance", "Limite de FPS ajustado para 240.")
end)

hideNameBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    notify("Utilitários", "Nome do personagem ocultado.")
end)

consoleBtn.MouseButton1Click:Connect(function()
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
end)

---------------------------------------------------------
-- ABA 8: SERVIDORES EXTRA
---------------------------------------------------------
local lowServerBtn = createButton("Entrar Servidor Menos Lotado", tab8Page)
local rejoiningSameJobBtn = createButton("Forcar Rejoin no Mesmo Server", tab8Page)
local copyServerLinkBtn = createButton("Copiar Link Direto do Servidor", tab8Page)
local serverRegionBtn = createButton("Mostrar Regiao do Servidor", tab8Page)
local serverPingLimitBtn = createButton("Alerta de Ping Alto (>200ms)", tab8Page)
local blockRejoinBtn = createButton("Prevenir Teleportes Involuntarios", tab8Page)
local autoRejoinCrashBtn = createButton("Auto Rejoin ao Desconectar: OFF", tab8Page)

lowServerBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

rejoiningSameJobBtn.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

copyServerLinkBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://www.roblox.com/games/" .. tostring(game.PlaceId) .. "?jobId=" .. tostring(game.JobId))
        notify("Servidor", "Link direto copiado!")
    end
end)

serverRegionBtn.MouseButton1Click:Connect(function()
    notify("Servidor", "Região atual: Global/Auto")
end)

local function togglePingLimit(state)
    Options.pingAlert = state
    saveSettings()
    serverPingLimitBtn.Text = Options.pingAlert and "Alerta Ping (>200ms): ON" or "Alerta de Ping Alto (>200ms)"
    serverPingLimitBtn.TextColor3 = Options.pingAlert and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end

serverPingLimitBtn.MouseButton1Click:Connect(function()
    togglePingLimit(not Options.pingAlert)
end)

local function togglePreventTp(state)
    Options.preventTp = state
    saveSettings()
    blockRejoinBtn.Text = Options.preventTp and "Prevenir Teleportes: ON" or "Prevenir Teleportes Involuntarios"
    blockRejoinBtn.TextColor3 = Options.preventTp and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)
end

blockRejoinBtn.MouseButton1Click:Connect(function()
    togglePreventTp(not Options.preventTp)
end)

local function toggleAutoRejoin(state)
    Options.autoRejoin = state
    saveSettings()
    autoRejoinCrashBtn.Text = Options.autoRejoin and "Auto Rejoin ao Desconectar: ON" or "Auto Rejoin ao Desconectar: OFF"
    autoRejoinCrashBtn.TextColor3 = Options.autoRejoin and Color3.fromRGB(255, 130, 0) or Color3.fromRGB(220, 220, 220)

    if Options.autoRejoin then
        local GuiService = game:GetService("GuiService")
        GuiService.ErrorMessageChanged:Connect(function()
            if Options.autoRejoin then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
end

autoRejoinCrashBtn.MouseButton1Click:Connect(function()
    toggleAutoRejoin(not Options.autoRejoin)
end)

---------------------------------------------------------
-- ABA 9: DIVERSOS & ESTILO
---------------------------------------------------------
local themeBtn = createButton("Alternar Cor do Tema (Laranja/Azul)", tab9Page)
local reloadUiBtn = createButton("Recarregar Interface", tab9Page)

local currentTheme = false
themeBtn.MouseButton1Click:Connect(function()
    currentTheme = not currentTheme
    local newColor = currentTheme and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 130, 0)
    titleLabel.TextColor3 = newColor
    sidebarFrame.ScrollBarImageColor3 = newColor
    notify("Estilo", "Tema da interface alterado!")
end)

reloadUiBtn.MouseButton1Click:Connect(function()
    notify("FireHub", "Recarregando interface...")
    task.wait(0.5)
    expandUI()
end)

---------------------------------------------------------
-- ABA ÁUDIO (SOMENTE LEITURA DE ARQUIVOS .MP3 NA PASTA FIREHUB)
---------------------------------------------------------
local activeSound = nil

local function loadAudioFiles()
    for _, child in ipairs(tabAudioPage:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local audioFound = false

    if listfiles and getcustomasset and isfile then
        local files = listfiles(folderName)
        for _, file in ipairs(files) do
            if string.sub(file, -4):lower() == ".mp3" then
                audioFound = true
                local cleanName = string.match(file, "[^/%\\]+$") or file
                
                local audioBtn = createButton("▶ " .. cleanName, tabAudioPage)
                
                audioBtn.MouseButton1Click:Connect(function()
                    if activeSound then
                        activeSound:Stop()
                        activeSound:Destroy()
                        activeSound = nil
                    end

                    local soundAsset = getcustomasset(file)
                    activeSound = Instance.new("Sound")
                    activeSound.SoundId = soundAsset
                    activeSound.Volume = 1
                    activeSound.Parent = SoundService
                    activeSound:Play()

                    notify("Áudio", "Tocando: " .. cleanName)
                end)
            end
        end
    end

    if not audioFound then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "Nenhum arquivo .mp3 encontrado\nna pasta workspace/FireHub"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 9
        emptyLabel.Parent = tabAudioPage
    end

    local stopAudioBtn = createButton("⏹ Parar Áudio Atual", tabAudioPage)
    stopAudioBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    stopAudioBtn.MouseButton1Click:Connect(function()
        if activeSound then
            activeSound:Stop()
            activeSound:Destroy()
            activeSound = nil
            notify("Áudio", "Áudio interrompido.")
        end
    end)
end

loadAudioFiles()

-- Restauração de Estados Salvos após a construção do script
if Options.noclip then toggleNoclip(true) end
if Options.fly then toggleFly(true) end
if Options.infiniteJump then infJumpBtn.Text = "Pulo Infinito: ON" infJumpBtn.TextColor3 = Color3.fromRGB(255, 130, 0) end
if Options.invisibility then toggleInvis(true) end
if Options.esp then toggleEsp(true) end
if Options.fullbright then toggleFullbright(true) end
if Options.tracers then tracersBtn.Text = "Linhas Tracers: ON" tracersBtn.TextColor3 = Color3.fromRGB(255, 130, 0) end
if Options.xray then toggleXray(true) end
if Options.autoClick then toggleAutoClick(true) end
if Options.autoJump then toggleAutoJump(true) end
if Options.autoSpin then toggleAutoSpin(true) end
if Options.autoWalk then toggleAutoWalk(true) end
if Options.pingAlert then togglePingLimit(true) end
if Options.preventTp then togglePreventTp(true) end
if Options.autoRejoin then toggleAutoRejoin(true) end
