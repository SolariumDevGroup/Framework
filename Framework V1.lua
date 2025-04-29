function UI:CreateMain()
    -- Coins arrondis simulés : on crée plusieurs rectangles superposés

    window.MainOutline = CreateDrawing("Square", {
        Size = Vector2.new(window.Width, window.Height),
        Position = Vector2.new(window.X, window.Y),
        Color = window.Colors.Border,
        Filled = true,
        Visible = true
    })

    window.MainBackground = CreateDrawing("Square", {
        Size = Vector2.new(window.Width-8, window.Height-8),
        Position = window.MainOutline.Position + Vector2.new(4,4),
        Color = window.Colors.Background,
        Filled = true,
        Visible = true
    })

    -- Coins arrondis (effet visuel en superposant)
    window.TopLeftRound = CreateDrawing("Circle", {
        Radius = 8,
        Position = window.MainOutline.Position,
        Color = window.Colors.Background,
        Filled = true,
        Visible = true
    })
    window.TopRightRound = CreateDrawing("Circle", {
        Radius = 8,
        Position = window.MainOutline.Position + Vector2.new(window.Width-8,0),
        Color = window.Colors.Background,
        Filled = true,
        Visible = true
    })
    window.BottomLeftRound = CreateDrawing("Circle", {
        Radius = 8,
        Position = window.MainOutline.Position + Vector2.new(0,window.Height-8),
        Color = window.Colors.Background,
        Filled = true,
        Visible = true
    })
    window.BottomRightRound = CreateDrawing("Circle", {
        Radius = 8,
        Position = window.MainOutline.Position + Vector2.new(window.Width-8,window.Height-8),
        Color = window.Colors.Background,
        Filled = true,
        Visible = true
    })

    window.TitleBar = CreateDrawing("Square", {
        Size = Vector2.new(window.Width-8, 40),
        Position = window.MainOutline.Position + Vector2.new(4,4),
        Color = window.Colors.Border,
        Filled = true,
        Visible = true
    })

    window.TitleText = CreateDrawing("Text", {
        Text = window.Title,
        Size = 25,
        Center = true,
        Outline = true,
        Position = window.TitleBar.Position + Vector2.new((window.Width-8)/2, 5),
        Color = window.Colors.Text,
        Visible = true
    })

    -- Bouton Minimiser
    window.MinimizeButton = CreateDrawing("Square", {
        Size = Vector2.new(24,24),
        Position = window.TitleBar.Position + Vector2.new(window.Width-50,8),
        Color = window.Colors.Accent,
        Filled = true,
        Visible = true
    })

    window.MinimizeText = CreateDrawing("Text", {
        Text = "-",
        Size = 20,
        Center = true,
        Position = window.MinimizeButton.Position + Vector2.new(12,2),
        Color = window.Colors.Text,
        Visible = true
    })

    -- Zone Catégories (PLUS LARGE)
    window.CategoryFrame = CreateDrawing("Square", {
        Size = Vector2.new(180, window.Height-48),
        Position = window.MainOutline.Position + Vector2.new(4,44),
        Color = Color3.fromRGB(25,25,25),
        Filled = true,
        Visible = true
    })

    -- Zone Eléments
    window.ElementFrame = CreateDrawing("Square", {
        Size = Vector2.new(window.Width-180-8, window.Height-48),
        Position = window.MainOutline.Position + Vector2.new(184,44),
        Color = Color3.fromRGB(20,20,20),
        Filled = true,
        Visible = true
    })
end


--// ULTRA FRAMEWORK DRAWING - PARTIE 3/7 - Catégories + Boutons de base

function UI:AddCategory(params)
    local category = {
        Title = params.Title or "Nouvelle Catégorie",
        Elements = {}
    }
    table.insert(window.Categories, category)
    window.CurrentCategory = category -- définit comme catégorie active
end

local function CreateBaseElement(props)
    return {
        Title = props.Title or "Element",
        Script = props.Script or function() end,
        Notification = props.Notification,
        Badge = props.Badge,
        Color = props.Color or Color3.fromRGB(50,50,50),
        Type = props.Type,
        Description = props.Description or nil
    }
end

function UI:AddButton(params)
    local button = CreateBaseElement({
        Title = params.Title,
        Script = params.Script,
        Notification = params.Notification,
        Badge = params.Badge,
        Color = params.Color,
        Type = "Button",
        Description = params.Description
    })
    table.insert(window.CurrentCategory.Elements, button)
end

function UI:AddToggle(params)
    local toggle = CreateBaseElement({
        Title = params.Title,
        Script = params.Script,
        Notification = params.Notification,
        Badge = params.Badge,
        Color = params.Color,
        Type = "Toggle",
        Description = params.Description
    })
    toggle.State = params.Default or false
    table.insert(window.CurrentCategory.Elements, toggle)
end

function UI:AddSlider(params)
    local slider = CreateBaseElement({
        Title = params.Title,
        Script = params.Script,
        Notification = params.Notification,
        Badge = params.Badge,
        Color = params.Color,
        Type = "Slider",
        Description = params.Description
    })
    slider.Min = params.Min or 0
    slider.Max = params.Max or 100
    slider.Value = params.Default or 0
    table.insert(window.CurrentCategory.Elements, slider)
end

function UI:AddDropdown(params)
    local dropdown = CreateBaseElement({
        Title = params.Title,
        Script = params.Script,
        Notification = params.Notification,
        Badge = params.Badge,
        Color = params.Color,
        Type = "Dropdown",
        Description = params.Description
    })
    dropdown.Options = params.Options or {}
    dropdown.Selected = dropdown.Options[1] or ""
    table.insert(window.CurrentCategory.Elements, dropdown)
end

function UI:AddBubble(params)
    local bubble = {
        Title = params.Title or "",
        Type = "Bubble",
        Color = params.Color or Color3.fromRGB(40,40,40)
    }
    table.insert(window.CurrentCategory.Elements, bubble)
end

--// ULTRA FRAMEWORK DRAWING - PARTIE 4/7 - Interaction Toggles, Sliders, Dropdowns

function UI:SelectCategory(title)
    for _, cat in pairs(window.Categories) do
        if cat.Title == title then
            window.SelectedCategory = cat
            self:Draw()
            break
        end
    end
end

function UI:Draw()
    -- Nettoyer les anciens éléments
    for _, obj in pairs(elements) do
        if obj then
            obj:Remove()
        end
    end
    elements = {}

    if not window.SelectedCategory then return end

    local yOffset = 10
    local scroll = 0
    local dropdownOpened = nil

    -- Afficher les éléments de la catégorie
    for _, element in pairs(window.SelectedCategory.Elements) do
        local pos = window.ElementFrame.Position + Vector2.new(10, yOffset + scroll)

        if element.Type == "Bubble" then
            local bubble = CreateDrawing("Square", {
                Size = Vector2.new(200, 5),
                Position = pos,
                Color = element.Color,
                Filled = true,
                Visible = true
            })
            table.insert(elements, bubble)
            yOffset = yOffset + 15
        else
            local bg = CreateDrawing("Square", {
                Size = Vector2.new(200, 30),
                Position = pos,
                Color = element.Color,
                Filled = true,
                Visible = true
            })

            local txt = CreateDrawing("Text", {
                Text = element.Title,
                Size = 18,
                Position = bg.Position + Vector2.new(10, 5),
                Color = window.Colors.Text,
                Visible = true
            })

            -- Badge
            if element.Badge then
                local badgeText = CreateDrawing("Text", {
                    Text = "[" .. (element.Badge.Text or "BADGE") .. "]",
                    Size = 14,
                    Position = bg.Position + Vector2.new(160, 5),
                    Color = element.Badge.Color or window.Colors.Accent,
                    Visible = true
                })
                table.insert(elements, badgeText)
            end

            -- Event clic
            UIS.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouse = UIS:GetMouseLocation()
                    if mouse.X >= bg.Position.X and mouse.X <= bg.Position.X + bg.Size.X
                    and mouse.Y >= bg.Position.Y and mouse.Y <= bg.Position.Y + bg.Size.Y then
                        PlaySound()
                        if element.Type == "Button" then
                            element.Script()
                        elseif element.Type == "Toggle" then
                            element.State = not element.State
                            element.Script(element.State)
                        elseif element.Type == "Slider" then
                            element.Value = math.clamp(element.Value + 5, element.Min, element.Max)
                            element.Script(element.Value)
                        elseif element.Type == "Dropdown" then
                            local idx = table.find(element.Options, element.Selected) or 1
                            idx = (idx % #element.Options) + 1
                            element.Selected = element.Options[idx]
                            element.Script(element.Selected)
                        end
                    end
                end
            end)

            table.insert(elements, bg)
            table.insert(elements, txt)

            yOffset = yOffset + 40
        end
    end
end

--// ULTRA FRAMEWORK DRAWING - PARTIE 5/7 - ColorPicker et KeyBindPicker intégrés

function UI:AddColorPicker(params)
    local colorPicker = {
        Title = params.Title or "Color Picker",
        Script = params.Script or function(color) end,
        Color = params.Default or Color3.fromRGB(255,255,255),
        Type = "ColorPicker",
        Description = params.Description
    }
    table.insert(window.CurrentCategory.Elements, colorPicker)
end

function UI:AddKeyBind(params)
    local keyBind = {
        Title = params.Title or "Key Bind",
        Script = params.Script or function(key) end,
        Key = params.Default or Enum.KeyCode.E,
        Type = "KeyBind",
        Description = params.Description
    }
    table.insert(window.CurrentCategory.Elements, keyBind)
end

function UI:Draw()
    -- Clean previous
    for _, obj in pairs(elements) do
        if obj then
            obj:Remove()
        end
    end
    elements = {}

    if not window.SelectedCategory then return end

    local yOffset = 10

    for _, element in pairs(window.SelectedCategory.Elements) do
        local pos = window.ElementFrame.Position + Vector2.new(10, yOffset)

        if element.Type == "Bubble" then
            local bubble = CreateDrawing("Square", {
                Size = Vector2.new(200, 5),
                Position = pos,
                Color = element.Color,
                Filled = true,
                Visible = true
            })
            table.insert(elements, bubble)
            yOffset = yOffset + 15

        else
            local bg = CreateDrawing("Square", {
                Size = Vector2.new(200, 30),
                Position = pos,
                Color = element.Color or window.Colors.Border,
                Filled = true,
                Visible = true
            })

            local txt = CreateDrawing("Text", {
                Text = element.Title,
                Size = 18,
                Position = bg.Position + Vector2.new(10, 5),
                Color = window.Colors.Text,
                Visible = true
            })

            -- Pour ColorPicker et KeyBind, cases supplémentaires
            if element.Type == "ColorPicker" then
                local colorBox = CreateDrawing("Square", {
                    Size = Vector2.new(20, 20),
                    Position = bg.Position + Vector2.new(170, 5),
                    Color = element.Color,
                    Filled = true,
                    Visible = true
                })

                UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UIS:GetMouseLocation()
                        if mouse.X >= colorBox.Position.X and mouse.X <= colorBox.Position.X + colorBox.Size.X
                        and mouse.Y >= colorBox.Position.Y and mouse.Y <= colorBox.Position.Y + colorBox.Size.Y then
                            local randomColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                            colorBox.Color = randomColor
                            element.Script(randomColor)
                        end
                    end
                end)

                table.insert(elements, colorBox)
            elseif element.Type == "KeyBind" then
                local keyBox = CreateDrawing("Square", {
                    Size = Vector2.new(20, 20),
                    Position = bg.Position + Vector2.new(170, 5),
                    Color = window.Colors.Accent,
                    Filled = true,
                    Visible = true
                })

                local keyText = CreateDrawing("Text", {
                    Text = element.Key.Name,
                    Size = 12,
                    Position = keyBox.Position + Vector2.new(2, 2),
                    Color = window.Colors.Text,
                    Visible = true
                })

                UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UIS:GetMouseLocation()
                        if mouse.X >= keyBox.Position.X and mouse.X <= keyBox.Position.X + keyBox.Size.X
                        and mouse.Y >= keyBox.Position.Y and mouse.Y <= keyBox.Position.Y + keyBox.Size.Y then
                            -- Capture prochaine touche
                            local conn
                            conn = UIS.InputBegan:Connect(function(keyInput)
                                if keyInput.UserInputType == Enum.UserInputType.Keyboard then
                                    element.Key = keyInput.KeyCode
                                    keyText.Text = keyInput.KeyCode.Name
                                    element.Script(keyInput.KeyCode)
                                    conn:Disconnect()
                                end
                            end)
                        end
                    end
                end)

                table.insert(elements, keyBox)
                table.insert(elements, keyText)
            end

            table.insert(elements, bg)
            table.insert(elements, txt)
            yOffset = yOffset + 40
        end
    end
end

--// ULTRA FRAMEWORK DRAWING - PARTIE 6/7 - Notifications, Popups, Sons

function UI:CreateNotification(text, color)
    local notification = {
        Text = text,
        Color = color or window.Colors.Accent,
        LifeTime = 3,
        CreatedAt = tick()
    }
    table.insert(notifications, notification)
end

function UI:DrawNotifications()
    local yOffset = 0
    for i,notif in ipairs(notifications) do
        local age = tick() - notif.CreatedAt
        if age >= notif.LifeTime then
            table.remove(notifications, i)
        else
            local notifBox = CreateDrawing("Square", {
                Size = Vector2.new(250, 30),
                Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X - 260, workspace.CurrentCamera.ViewportSize.Y - 40 - (yOffset*35)),
                Color = notif.Color,
                Filled = true,
                Visible = true
            })

            local notifText = CreateDrawing("Text", {
                Text = notif.Text,
                Size = 16,
                Position = notifBox.Position + Vector2.new(10, 7),
                Color = window.Colors.Text,
                Visible = true
            })

            table.insert(elements, notifBox)
            table.insert(elements, notifText)
            yOffset = yOffset + 1
        end
    end
end

RunService.RenderStepped:Connect(function()
    UI:DrawNotifications()
end)

function UI:AddBubble(params)
    local bubble = {
        Title = params.Title or "",
        Type = "Bubble",
        Color = params.Color or Color3.fromRGB(40,40,40)
    }
    table.insert(window.CurrentCategory.Elements, bubble)
end

-- Sound sur chaque action
function UI:PlayUISound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6026984224"
    sound.Volume = 1
    sound.Parent = SoundService
    sound:Play()
    Debris:AddItem(sound, 2)
end

--// ULTRA FRAMEWORK DRAWING - PARTIE 7/7 - Hover Animations + Descriptions

local hoveredElement = nil
local hoverStart = nil
local descriptionBox = nil
local descriptionText = nil

RunService.RenderStepped:Connect(function()
    if window.Visible then
        local mouse = UIS:GetMouseLocation()

        for _, element in pairs(elements) do
            if element.ClassName == "Square" and element.Size == Vector2.new(200, 30) then
                if mouse.X >= element.Position.X and mouse.X <= element.Position.X + element.Size.X
                and mouse.Y >= element.Position.Y and mouse.Y <= element.Position.Y + element.Size.Y then
                    if hoveredElement ~= element then
                        hoveredElement = element
                        hoverStart = tick()
                    end
                end
            end
        end

        if hoveredElement and tick() - hoverStart >= 2 then
            -- Trouver l'élément associé
            for _, obj in pairs(window.SelectedCategory.Elements) do
                local expectedPos = window.ElementFrame.Position + Vector2.new(10, 10 + ((_ -1)*40))
                if hoveredElement.Position == expectedPos then
                    if obj.Description then
                        -- Créer la boîte de description
                        if not descriptionBox then
                            descriptionBox = CreateDrawing("Square", {
                                Size = Vector2.new(200, 25),
                                Position = hoveredElement.Position - Vector2.new(0, 30),
                                Color = window.Colors.Border,
                                Filled = true,
                                Visible = true
                            })
                            descriptionText = CreateDrawing("Text", {
                                Text = obj.Description,
                                Size = 14,
                                Position = descriptionBox.Position + Vector2.new(10,5),
                                Color = window.Colors.Text,
                                Visible = true
                            })
                        else
                            descriptionBox.Position = hoveredElement.Position - Vector2.new(0, 30)
                            descriptionText.Position = descriptionBox.Position + Vector2.new(10,5)
                            descriptionText.Text = obj.Description
                        end
                    end
                end
            end
        else
            -- Enlever description si on part
            if descriptionBox then
                descriptionBox:Remove()
                descriptionText:Remove()
                descriptionBox = nil
                descriptionText = nil
            end
        end
    end
end)

-- Final Export
return UI
