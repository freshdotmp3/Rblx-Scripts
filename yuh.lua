-- anti afk
game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- variables
local localplayer = game:GetService("Players").LocalPlayer
local runservice = game:GetService("RunService")

-- lib
local library = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local window = library:CreateWindow({
	Title = "Shrimp",
	SubTitle = "by NotFreshzy",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl,
	Transparency = false
})
local options = library.Options

-- general
local general = window:AddTab({Title = "General", Icon = "house"})

general:AddToggle("auto_farm", {
	Title = "Auto Farm",
	Default = false,
	Callback = function(boolen)
		_G.AutoFarm = boolen
	end
})

general:AddInput("custom_damage", {
	Title = "Custom Damage",
	Default = nil,
	Numeric = true,
	Finished = true,
	Callback = function(value)
		_G.CustomDamage = value
	end
})

-- get plot
local function getplot()
	for _, plot in pairs(workspace.Plots:GetDescendants()) do
		if plot:FindFirstChild("Owner") then
			if plot.Owner.Value == localplayer then
				return plot.Parent
			end
		end
	end
	return nil
end

-- get closet zombie to flag
local function getzombie()
	local target = nil
	local distance = math.huge
	for _, zombie in pairs(getplot().Zombies:GetChildren()) do
		if zombie:FindFirstChildOfClass("Humanoid") then
			if zombie:FindFirstChildOfClass("Humanoid").Health > 0 then
				local magnitude = (getplot().Plot.HitBox.Position - zombie.HumanoidRootPart.Position).Magnitude
				if magnitude < distance then
					target = zombie
					distance = magnitude
				end
			end
		end
	end
	return target
end

spawn(function()
	runservice.Heartbeat:Connect(function()
		pcall(function()
			if _G.AutoFarm == true then
				if (getzombie() == nil) then
					localplayer.Character.HumanoidRootPart.CFrame = getplot().Plot.HitBox.CFrame * CFrame.new(0, 50, 0)
					workspace.CurrentCamera.CameraSubject = getzombie().Humanoid
				elseif not (getzombie() == nil) then
					game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Weapons"):WaitForChild("TakeDamage"):FireServer(table.unpack({
						[1] = getzombie().HumanoidRootPart,
						[2] = _G.CustomDamage
					}))
					workspace.CurrentCamera.CameraSubject = getplot().Plot.HitBox
					localplayer.Character.HumanoidRootPart.CFrame = getzombie().HumanoidRootPart.CFrame * CFrame.new(0, 50, 0)
				end
			end
		end)
	end)
end)

spawn(function()
	runservice.Stepped:Connect(function()
		if _G.AutoFarm == true then
			pcall(function()
				if not localplayer.Character.HumanoidRootPart:FindFirstChild("Noclip") then
					local BodyVel = Instance.new("BodyVelocity")
					BodyVel.Name = "Noclip"
					BodyVel.Parent = localplayer.Character.HumanoidRootPart
					BodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
					BodyVel.Velocity = Vector3.new(0, 0, 0)
				end
				for i, v in pairs(localplayer.Character:GetChildren()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end)
		else
			pcall(function()
				if localplayer.Character.HumanoidRootPart:FindFirstChild("Noclip") then
					localplayer.Character.HumanoidRootPart["Noclip"]:Destroy()
				end
			end)
		end
	end)
end)
