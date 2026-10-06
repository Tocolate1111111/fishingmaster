if not game:IsLoaded() then game.Loaded:Wait() end

local ps = game:GetService("Players")
repeat task.wait() until ps.LocalPlayer

local lp, rv = ps.LocalPlayer, getrenv().shared
local function waitUntil(cond, limit)
	local dl = os.clock() + limit
	while os.clock() < dl do
		local ok, v = pcall(cond)
		if ok and v then return true end
		task.wait(0.2)
	end
	return false
end
waitUntil(function() return lp:GetAttribute("IsLoaded") == true end, 45)
waitUntil(function() return rv.LoadingController and rv.LoadingController:IsLoaded() end, 45)

local qk = {Right = "D", Left = "A", Up = "W"}

local function pd() return rv.PlayerDataV2Controller:Fetch() end

local function sk()
	local d, o = pd(), {}
	local r = d and d.Rods and d.Rods[d.RodEquip]
	for s, id in r and r.BookSlots or {} do
		if type(id) == "string" and id ~= "" and id ~= "None" then table.insert(o, {s, id}) end
	end
	table.sort(o, function(a, b) return a[1] < b[1] end)
	return o
end

local function eq()
	local d, c = pd(), lp.Character
	local rd = d and d.RodEquip
	if type(rd) ~= "string" or rd == "" or rd == "None" then return nil, "No Rod" end
	if not c then return nil, "No Character" end
	local function hd() return c:FindFirstChild(rd) and c[rd]:IsA("Tool") end
	if hd() then return true end
	rv.HeldToolController.SetHeldSlot:Fire(1)
	local dl = os.clock() + 5
	repeat task.wait(0.1) until hd() or os.clock() > dl
	if hd() then return true end
	return nil, "Equip Timeout"
end

local function tg(h)
	local w = workspace:FindFirstChild("World")
	local il, ip = w and w:FindFirstChild("Islands"), RaycastParams.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for i = 0, 15 do
		local a = math.rad(i * 22.5)
		for _, r in {60, 50, 40, 30} do
			local p = Vector3.new(h.Position.X + math.sin(a) * r, 3, h.Position.Z + math.cos(a) * r)
			if not il or not workspace:Raycast(p + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), ip) then return p end
		end
	end
	return nil
end

local function fp(s)
	local lm, st = s.fp[1], s.fp[2]
	local el = workspace:GetServerTimeNow() - st
	local pk = (2 * math.max(0, math.ceil((el * 2.4 - 1) / 2)) + 1) / 2.4
	if pk < lm then task.wait(pk - el) end
	rv.FishingController.FishFirstPull:Fire()
end

local function rl(f, s, ks)
	local fc, mv, sq, nc = rv.FishingController, rv.RodController.Moveset, 0, 0
	while f.st == "Running" and not s.cr and not s.rr do
		local t = os.clock()
		if s.q and t >= s.q[2] then fc.FishQTEResponse:Fire(qk[s.q[1]]); s.q = nil end
		if not lp:GetAttribute("IsUsingSkill") then
			for _, x in ks do
				local c = s.cd[x[1]]
				if not c or c[1] == "Ready" or (c[1] == "Cooldown" or c[1] == "Pending") and t >= c[2] then
					mv:Fire(x[1], x[2])
					s.cd[x[1]], s.q = {"Pending", t + 1}, nil
					break
				end
			end
		end
		if t >= nc and t >= s.sw and t >= s.bs then
			sq = sq % 65535 + 1
			fc.FishReelPull:Fire(sq)
			nc = math.max(nc, t - 0.01) + 1 / 6 + 0.005
		end
		task.wait()
	end
	return nil
end

local ra = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine", "Huge"}

local function md(...)
	local x = game:GetService("ReplicatedStorage")
	for _, n in {...} do x = x:FindFirstChild(n) or error(`Module Missing: {n}`) end
	return require(x)
end

local function fl() return md("Shared", "Lib", "FishStorageRules").GetState(pd()).isFull end

local function ns(id, p)
	local b, bd, bx
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == id then
			local q = x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position
			if q and (not bd or (q - p).Magnitude < bd) then b, bd, bx = q, (q - p).Magnitude, x end
		end
	end
	return b, bx
end

local sn = 0

local function sq(p, t)
	if sn >= 4 then return false end
	local dn = false
	sn += 1
	task.spawn(function()
		pcall(function() lp:RequestStreamAroundAsync(p, t) end)
		sn, dn = sn - 1, true
	end)
	local dl = os.clock() + t + 1
	repeat task.wait(0.1) until dn or os.clock() > dl
	return dn
end

local fz, cj = {Enum.HumanoidStateType.Freefall, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll}, nil

local function lc()
	local c = lp.Character
	local r, h = c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
	if r and h and h.Health > 0 and r:IsA("BasePart") then return c, r, h end
	return nil
end

local function pz(p, cf)
	p.CFrame = cf
	p.AssemblyLinearVelocity, p.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
end

local function uc(j)
	if j.ca then j.ca:Disconnect(); j.cr:Disconnect() end
	for p, v in j.cc do pcall(function() p.CanCollide = v end) end
	for e, v in j.ss do pcall(function() j.h:SetStateEnabled(e, v) end) end
	j.c, j.h, j.ca, j.cr, j.cc, j.ss, j.pl = nil, nil, nil, nil, {}, {}, {}
end

local function ac(j, c, h)
	uc(j)
	j.c, j.h, j.pd = c, h, true
	for _, e in fz do j.ss[e] = h:GetStateEnabled(e); h:SetStateEnabled(e, false) end
	j.ca = c.DescendantAdded:Connect(function() j.pd = true end)
	j.cr = c.DescendantRemoving:Connect(function() j.pd = true end)
end

local function nx(j)
	local c, _, h = lc()
	if not c then return end
	if c ~= j.c then ac(j, c, h) end
	if j.pd then
		j.pd, j.pl = false, {}
		for _, d in c:GetDescendants() do
			if d:IsA("BasePart") then
				if j.cc[d] == nil then j.cc[d] = d.CanCollide end
				table.insert(j.pl, d)
			end
		end
	end
	for _, p in j.pl do if p.CanCollide then p.CanCollide = false end end
	if h.Sit or h.SeatPart then h.Sit = false end
end

local function hx(j, dt)
	local c, r, h = lc()
	if not c then
		if j.c then uc(j) end
		j.st = "Respawn"
		return
	end
	if c ~= j.c then ac(j, c, h) end
	local d = j.p - r.Position
	local ar, fd = d.Magnitude <= j.s * dt, Vector3.new(d.X, 0, d.Z)
	j.lk = ar and j.fk or fd.Magnitude > 1e-3 and fd.Unit or j.lk
	j.st = ar and "Arrived" or "Moving"
	pz(r, CFrame.lookAlong(ar and j.p or r.Position + d.Unit * j.s * dt, j.lk))
end

local function cz(j, st, why)
	if j.dn then return end
	j.dn = true
	j.cs:Disconnect(); j.ch:Disconnect()
	pcall(uc, j)
	pcall(function()
		local _, r = lc()
		if r then r.AssemblyLinearVelocity, r.AssemblyAngularVelocity = Vector3.zero, Vector3.zero end
	end)
	j.st, j.why = st, why
	if cj == j then cj = nil end
end

local function mo(p, s, fk)
	if typeof(p) ~= "Vector3" or p.Magnitude ~= p.Magnitude or p.Magnitude == math.huge then return nil, "Move Failed: Bad Point" end
	if cj then cj:Stop() end
	local c, r, h = lc()
	local j = {st = "Moving", p = p, s = s, cc = {}, ss = {}, pl = {}, lk = r and Vector3.new(r.CFrame.LookVector.X, 0, r.CFrame.LookVector.Z).Unit or -Vector3.zAxis}
	j.fk = fk or j.lk
	function j.Stop(x) cz(x or j, "Stopped") end
	if c then ac(j, c, h) end
	local rs = game:GetService("RunService")
	j.cs = rs.Stepped:Connect(function()
		local ok, e = pcall(nx, j)
		if not ok then cz(j, "Failed", `Move Failed: {e}`) end
	end)
	j.ch = rs.Heartbeat:Connect(function(dt)
		local ok, e = pcall(hx, j, dt)
		if not ok then cz(j, "Failed", `Move Failed: {e}`) end
	end)
	cj = j
	return j
end

local ap

local function gf(f, p, fk)
	for _ = 1, 4 do
		local _, r = lc()
		if not r then return nil, "No Character" end
		local d = p - r.Position
		if Vector3.new(d.X, 0, d.Z).Magnitude <= 2 then return true end
		if f.st ~= "Running" then return nil end
		local j, e = mo(p, 30, fk)
		if not j then return nil, e end
		local dl = os.clock() + d.Magnitude / 30 + 5
		repeat task.wait() until j.st == "Arrived" or j.dn or f.st ~= "Running" or os.clock() > dl
		local why = j.why
		j:Stop()
		if why then return nil, why end
		if f.st ~= "Running" then return nil end
		task.wait(0.5)
	end
	return nil, "Move Timeout"
end

local go = gf

local function gd(c, p)
	local rp = RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, {c}
	local r = workspace:Raycast(p + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), rp)
	return r and Vector3.new(p.X, r.Position.Y + 3, p.Z) or p
end

local function lk(sr, kp)
	local d, ct, sc, st, hl = pd(), md("Data", "Catalog"), rv.SellController, {}, {}
	for _, r in sr do st[r] = true end
	for u, x in d.Inventory.Fishes do
		local fi = ct.Fish.GetById(x.fishId)
		if x.locked ~= true and (kp[u] or not (fi and st[fi.rarity] and (not x.isHuge or st.Huge))) then
			local s, v = sc:ToggleLock(u)
			if s ~= 0 or v ~= true then return hl, `Lock Failed: {x.fishId}` end
			table.insert(hl, u)
		end
	end
	return hl, nil
end

local function uk(hl)
	local d, sc = pd(), rv.SellController
	for _, u in hl do
		local x = d.Inventory.Fishes[u]
		if x then
			local s, v = sc:ToggleLock(u)
			if s == 0 and v == true then s, v = sc:ToggleLock(u) end
			if s ~= 0 or v ~= false then return nil, `Unlock Failed: {x.fishId}` end
		end
	end
	return true, nil
end

local function wlk(f, p, fk)
	local ps = game:GetService("PathfindingService")
	for _ = 1, 3 do
		local c, r, h = lc()
		if not c then return nil, "No Character" end
		if Vector3.new(p.X - r.Position.X, 0, p.Z - r.Position.Z).Magnitude <= 3 then
			if fk then pz(r, CFrame.lookAlong(r.Position, fk)) end
			return true
		end
		if f.st ~= "Running" then return nil end
		local path = ps:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
		local ok = pcall(function() path:ComputeAsync(r.Position, p) end)
		local wps = ok and path.Status == Enum.PathStatus.Success and path:GetWaypoints() or {{Position = p, Action = Enum.PathWaypointAction.Walk}}
		local stuck = false
		for _, w in wps do
			c, r, h = lc()
			if not c then return nil, "No Character" end
			if f.st ~= "Running" then return nil end
			if w.Action == Enum.PathWaypointAction.Jump then h.Jump = true end
			h:MoveTo(w.Position)
			local dl = os.clock() + 4
			repeat
				task.wait(0.1)
				c, r, h = lc()
			until not c or f.st ~= "Running" or Vector3.new(w.Position.X - r.Position.X, 0, w.Position.Z - r.Position.Z).Magnitude <= 3 or os.clock() > dl
			if not c then return nil, "No Character" end
			if f.st ~= "Running" then return nil end
			if Vector3.new(w.Position.X - r.Position.X, 0, w.Position.Z - r.Position.Z).Magnitude > 3 then
				stuck = true
				break
			end
		end
		if not stuck then
			local _, r2 = lc()
			if r2 and Vector3.new(p.X - r2.Position.X, 0, p.Z - r2.Position.Z).Magnitude <= 4 then
				if fk then pz(r2, CFrame.lookAlong(r2.Position, fk)) end
				return true
			end
		end
	end
	return nil, "Walk Failed"
end

local function mvt(f, p, fk)
	if f.wk and f.wk() then
		local _, r = lc()
		local sw = rv.Swimming and rv.Swimming:IsSwimming()
		if r and not sw and (p - r.Position).Magnitude <= 800 then
			local ok = wlk(f, p, fk)
			if ok then return true end
			if f.st ~= "Running" then return nil end
		end
	end
	return go(f, p, fk)
end

local function tr(f)
	local c = lp.Character
	local h = c and c:FindFirstChild("HumanoidRootPart")
	if not h then return nil, "No Character" end
	local o, sw = h.CFrame, rv.Swimming and rv.Swimming:IsSwimming()
	local np = ns("npc_fish_seller", o.Position)
	if not np then return "Auto Fish Failed: No Fish Seller" end
	local hl, e = lk(f.sr(), f.kp())
	if e then
		local _, ue = uk(hl)
		return nil, ue or e
	end
	local sp = ap(c, np, o.Position)
	local w, we, s
	for _ = 1, 3 do
		w, we = mvt(f, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
		if not w or f.st ~= "Running" then break end
		task.wait(0.5)
		s = rv.SellController:SellAll()
		if s ~= 1 then break end
	end
	local uo, ue = uk(hl)
	if f.st == "Running" and not sw then mvt(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
	if sw then f.rp = true end
	if f.st ~= "Running" then return nil, nil end
	if not uo then return nil, ue end
	if not w then return nil, we or "Move Failed" end
	if s == 3 then return "Auto Fish Failed: Satchel Full" end
	if s ~= 0 then return nil, `Sell Status {s}` end
	return nil, nil
end

local iz, ix, bn, bi = {}, {}, {}, {}
for _, x in {{"Starter Island", "island_starter"}, {"Jungle Island", "island_jungle"}, {"Desert Island", "island_desert"}, {"Snow Island", "island_snow"}, {"Volcanic Island", "island_volcano"}, {"Fossil Island", "island_fossil"}} do
	table.insert(iz, x[1])
	ix[x[1]] = x[2]
end
for _, x in {{"Truck", "truck"}, {"Red Truck", "red_truck"}} do
	table.insert(bn, x[1])
	bi[x[1]] = x[2]
end

local function ic() return rv.IslandRegionController:GetCurrentIslandId() end

local function rs(id)
	local c, r = lc()
	local w = workspace:FindFirstChild("World")
	local il = w and w:FindFirstChild("Islands")
	local fo = il and il:FindFirstChild(id or ic())
	if not (c and fo) then return nil end
	local ip, o, rd = RaycastParams.new(), {}, Random.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for _ = 1, 150 do
		local a, d = rd:NextNumber(0, math.pi * 2), rd:NextNumber(10, 150)
		local h = workspace:Raycast(Vector3.new(r.Position.X + math.sin(a) * d, 150, r.Position.Z + math.cos(a) * d), Vector3.new(0, -200, 0), ip)
		if h and h.Instance:IsDescendantOf(fo) and h.Position.Y > 3.5 and h.Position.Y < 20 then
			local g = h.Position
			for i = 0, 7 do
				local b = math.rad(i * 45)
				if not workspace:Raycast(Vector3.new(g.X + math.sin(b) * 12, 103, g.Z + math.cos(b) * 12), Vector3.new(0, -100, 0), ip) and tg({Position = g}) then
					table.insert(o, g + Vector3.new(0, 3, 0))
					break
				end
			end
		end
	end
	return #o > 0 and o[rd:NextInteger(1, #o)] or nil
end

local function ul(id)
	local c, d = md("Data", "Config", "IslandConfig")[id], pd()
	return c and c.defaultUnlocked == true or d and d.UnlockedIslands and d.UnlockedIslands[id] == true or false
end

local function rg(id)
	for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if x:IsA("BasePart") and x:GetAttribute("islandId") == id then return x.Position end
	end
	return nil
end

local hs = game:GetService("HttpService")

local function vi(p)
	local id = ic()
	if id ~= "" then return id end
	for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
		if x:IsA("BasePart") and (x.Position - p).Magnitude < x.Size.X / 2 then return x:GetAttribute("islandId") end
	end
	return ""
end

ap = function(c, np, p)
	local u = Vector3.new(p.X, np.Y, p.Z) - np
	return gd(c, np + (u.Magnitude > 0.1 and u.Unit or Vector3.xAxis) * 6)
end

local function bv(k)
	local a = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
	local m = a and a:FindFirstChild("Cars")
	m = m and m:FindFirstChild(k)
	m = m and m:FindFirstChild("Model")
	return m and m:GetAttribute("Speed")
end

local function gb(f, k)
	local c, r = lc()
	local cf = workspace:FindFirstChild("Cars")
	if not c then return nil, "No Character" end
	if not cf then return nil, "No Cars Folder" end
	local nm = tostring(lp.UserId)
	local om = cf:FindFirstChild(nm)
	local ct = md("Data", "Catalog", "Car")
	local function pc() return ct[k] and ct[k].price or 0 end
	local function ok(x) return x and x:FindFirstChild("Main") and x:FindFirstChild("DSeat") and x:GetAttribute("Speed") == bv(k) and ((x.Main.Position - r.Position) * Vector3.new(1, 0, 1)).Magnitude < 500 end
	if ok(om) then return om end
	if pc() > (pd().Coin or 0) then k = "truck" end
	if ok(om) then return om end
	local mp, mx = ns("npc_car_merchant", r.Position)
	if not mp then return nil, "No Boat Merchant" end
	local g, e = go(f, ap(c, mp, r.Position))
	if not g then return nil, e end
	local P = md("Stardust").Packet
	P("SpawnCarEvent", P.String):Fire(`{k}/{mx:GetAttribute("IslandId")}`)
	local dl = os.clock() + 8
	repeat
		task.wait(0.2)
		local x = cf:FindFirstChild(nm)
		if x and x ~= om and x:FindFirstChild("Main") and x:FindFirstChild("DSeat") then return x end
	until os.clock() > dl or f.st ~= "Running"
	return nil, f.st == "Running" and "Boat Spawn Timeout" or nil
end

local function pq(m, v)
	for _, x in m and m:GetDescendants() or {} do
		if x:IsA("ProximityPrompt") then x.Enabled = v end
	end
end

local function sb(f, m)
	local c, r, h = lc()
	if not c then return nil, "No Character" end
	local ds = m:FindFirstChild("DSeat")
	local pp = ds and ds:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not pp then return nil, "No Boat Seat" end
	pq(m, true)
	if ds.Occupant == h then return true end
	local q = (r.Position - ds.Position) * Vector3.new(1, 0, 1)
	local g, e = go(f, Vector3.new(ds.Position.X, r.Position.Y, ds.Position.Z) + (q.Magnitude > 0.1 and q.Unit or Vector3.xAxis) * 3)
	if not g then return nil, e end
	if cj then cj:Stop() end
	local dl, lc2 = os.clock() + 20, false
	repeat
		fireproximityprompt(pp)
		local d1 = os.clock() + 1
		repeat task.wait(0.1) until ds.Occupant == h or os.clock() > d1
		if ds.Occupant ~= h and not lc2 then
			lc2 = true
			rv.FishingController.FishLootConfirm:Fire()
			rv.FishingController.FishCancel:Fire()
		end
	until ds.Occupant == h or os.clock() > dl
	if ds.Occupant ~= h then return nil, "Sit Timeout" end
	return true
end

local function dv(f, m, id, pt)
	local _, _, h = lc()
	local mn, ds = m:FindFirstChild("Main"), m:FindFirstChild("DSeat")
	local ap, ao = mn and mn:FindFirstChild("AlignPosition"), mn and mn:FindFirstChild("AlignOrientation")
	local cp = rg(id)
	if not (h and ds and ap and ao) then return nil, "Bad Boat" end
	if not cp then return nil, "No Island Region" end
	local sp, y, cc, sx = m:GetAttribute("Speed") or 30, ap.Position.Y, {}, {}
	for _, x in {m, lp.Character} do
		for _, p in x:GetDescendants() do
			if p:IsA("BasePart") then cc[p] = p.CanCollide end
			if p:IsA("Seat") or p:IsA("VehicleSeat") then table.insert(sx, p) end
		end
	end
	local w = workspace:FindFirstChild("World")
	local il, rp = w and w:FindFirstChild("Islands"), RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	local tp, to, er, cn, on, sh = Vector3.new(mn.Position.X, 0, mn.Position.Z), pt and Vector3.new(pt.X, 0, pt.Z) or Vector3.new(cp.X, 0, cp.Z), nil, nil, false, nil
	local hd, hl = (to - tp).Unit, math.max(mn.Size.X, mn.Size.Z) / 2 + 3
	cn = game:GetService("RunService").Stepped:Connect(function(_, dt)
		local ok, e = pcall(function()
			for _, x in sx do
				local c = x.Occupant and x.Occupant.Parent
				if c and c ~= lp.Character then
					for _, p in c:GetDescendants() do
						if p:IsA("BasePart") and cc[p] == nil then cc[p] = p.CanCollide end
					end
				end
			end
			for p in cc do
				if p.CanCollide then p.CanCollide = false end
			end
			local q = to - tp
			if q.Magnitude > 0.05 and not sh then
				hd = q.Unit
				local nx2 = tp + hd * math.min(q.Magnitude, sp * dt)
				local r = not pt and on and il and workspace:Raycast(Vector3.new(nx2.X, 103, nx2.Z) + hd * hl, Vector3.new(0, -100, 0), rp)
				if r then sh = r.Position else tp = nx2 end
			end
			ap.Position, ao.CFrame = Vector3.new(tp.X, y, tp.Z), CFrame.Angles(0, math.atan2(-hd.X, -hd.Z), 0)
		end)
		if not ok then er = `Boat Drive Failed: {e}`; cn:Disconnect() end
	end)
	local lb, lt, dl, dn = math.huge, os.clock(), os.clock() + (to - tp).Magnitude / sp * 1.5 + 30, false
	while f.st == "Running" and not er do
		task.wait(0.25)
		if ds.Occupant ~= h then er = "Left Boat"; break end
		on = ic() == id
		if sh then
			task.wait(0.5)
			dn = true
			break
		end
		if on and not pt then
			local mp, mx = ns("npc_car_merchant", mn.Position)
			local nq = mp and mx:GetAttribute("IslandId") == id and Vector3.new(mp.X, 0, mp.Z)
			if nq and nq ~= to then to, lb = nq, math.huge end
		end
		local d = (Vector3.new(mn.Position.X, 0, mn.Position.Z) - to).Magnitude
		if d < lb - 1 then lb, lt = d, os.clock() end
		if d < (pt and 3 or 15) or on and not pt and os.clock() - lt > 2 then dn = true; break end
		if os.clock() - lt > 4 then er = "Boat Stuck" end
		if os.clock() > dl then er = "Boat Timeout" end
	end
	if cn.Connected then cn:Disconnect() end
	for p, v in cc do pcall(function() p.CanCollide = v end) end
	local dd = os.clock() + 3
	while ds.Occupant == h and os.clock() < dd do
		h.Sit, h.Jump = false, true
		task.wait(0.2)
	end
	local _, r = lc()
	local hj = r and mo(r.Position, 30)
	task.wait(1)
	if er or not dn then
		if hj then hj:Stop() end
		return nil, er
	end
	return true, sh
end

local wb = {on = true}
local zy = {on = false, rq = false, nt = 0, ss = 0, fr = {}, wl = {}}
local wz = {island_starter = Vector3.new(-37.4, 11.1, 305.9), island_jungle = Vector3.new(-1161.1, 10.8, -61.9), island_desert = Vector3.new(-44.1, 10.1, -935.4), island_snow = Vector3.new(1171.7, 9.4, -266.5), island_volcano = Vector3.new(1772.5, 9.2, 1069.3), island_fossil = Vector3.new(-543.2, 10.6, 2172.3)}

local function wm(id)
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == "npc_car_merchant" and x:GetAttribute("IslandId") == id then return x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or wz[id] end
	end
	return wz[id]
end

local wv
if getgenv and getgenv().__FmW then pcall(getgenv().__FmW.Destroy, getgenv().__FmW) end
pcall(function()
	local pg, lt = lp:WaitForChild("PlayerGui"), rv.LoadingController
	local x = pg:WaitForChild("Loading", 10):Clone()
	local fr = x.Frame
	x.Name, x.Enabled, x.ResetOnSpawn, x.DisplayOrder = hs:GenerateGUID(false), false, false, 1000
	fr.BackgroundTransparency, fr.Background.Gradient.ImageTransparency, fr.Background.Rectangle.BackgroundTransparency, fr.ImageLabel.ImageTransparency = 0, 0, 0, 0
	fr.tips.Position, fr.Bar.Position = lt._originalTipsPos, lt._originalBarPos
	fr.Bar.MasteryText.Text = "Teleporting..."
	x.Parent = pg
	wv = x
end)
if getgenv then getgenv().__FmW = wv end

local wg, wk, wp, wo = 0, nil, 0, {}
local wt = {"Tips: Cast your bobber near ripple spots to catch rare fish!", "Tips: Different rods provide unique luck and strength boosts.", "Tips: Keep an eye on the tension bar to avoid snapping your line!", "Tips: Upgrade your bait at the bait shop to attract bigger fish.", "Tips: Perfect catches grant extra experience and rare materials.", "Tips: Check the weather! Some mythical fish only appear in storms.", "Tips: Visit the fish merchant to convert your catches into Coins & Gems.", "Tips: Explore distant islands once you discover their fast travel points.", "Tips: Rare auras and rod skins can be equipped to show off your style.", "Tips: Complete daily quests for bonus rewards and crates.", "Tips: Fill out your fish Index to track every species you've caught!"}

local function wc(v, ok)
	if not wv then return end
	wg += 1
	local g, fr, ts, lt = wg, wv.Frame, game:GetService("TweenService"), rv.LoadingController
	local b, bg = fr.Bar, fr.Background
	pcall(function()
		if v then
			if wk then wk:Disconnect() end
			for _, x in wo do x:Cancel() end
			fr.BackgroundTransparency, bg.Gradient.ImageTransparency, bg.Rectangle.BackgroundTransparency, fr.ImageLabel.ImageTransparency = 0, 0, 0, 0
			b.Position, fr.tips.Position = UDim2.new(lt._originalBarPos.X.Scale, lt._originalBarPos.X.Offset, 1.25, 0), UDim2.new(lt._originalTipsPos.X.Scale, lt._originalTipsPos.X.Offset, 1.35, 0)
			b.Fill.Size, b.MasteryText.Text, wp, wv.Enabled = UDim2.fromScale(0, 1), "Loading game...", 0, true
			local cp, tp = 0, 0
			wk = game:GetService("RunService").RenderStepped:Connect(function(dt)
				tp = wp
				if tp > cp then cp = math.min(cp + math.max((tp - cp) * math.clamp(dt * 10, 0, 1), 5e-4), tp) end
				local t = os.clock()
				b.Fill.Size, b.Fish.Position, b.Fish.Rotation = UDim2.fromScale(cp, 1), UDim2.new(cp, 0, 0.5, math.sin(t * 10) * 3), math.sin(t * 12) * 10
			end)
			wo = {ts:Create(b.Shine, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.25})}
			wo[1]:Play()
			ts:Create(b, TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = lt._originalBarPos}):Play()
			task.delay(0.08, function() ts:Create(fr.tips, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = lt._originalTipsPos}):Play() end)
			local ti3, op = math.random(1, #wt), lt._originalTipsPos
			fr.tips.Text = wt[ti3]
			task.spawn(function()
				while true do
					task.wait(2.5)
					if wg ~= g then return end
					ti3 = ti3 % #wt + 1
					local x = ts:Create(fr.tips, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(op.X.Scale, op.X.Offset, op.Y.Scale - 0.035, op.Y.Offset)})
					x:Play()
					x.Completed:Wait()
					if wg ~= g then return end
					fr.tips.Text, fr.tips.Position = wt[ti3], UDim2.new(op.X.Scale, op.X.Offset, op.Y.Scale + 0.035, op.Y.Offset)
					ts:Create(fr.tips, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = op}):Play()
				end
			end)
			task.spawn(function()
				for k, x in {"Starting up...", "Building interface...", "Loading your data...", "Preparing gameplay..."} do
					task.wait(1)
					if wg ~= g then return end
					wp, b.MasteryText.Text = k * 0.22, x
				end
			end)
			return
		end
		if ok then wp = 1 end
		b.MasteryText.Text = ok and "Ready!" or "Teleport Failed"
		task.spawn(function()
			task.wait(ok and 0.4 or 1)
			if wg ~= g then return end
			ts:Create(fr.tips, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(lt._originalTipsPos.X.Scale, lt._originalTipsPos.X.Offset, 1.35, 0)}):Play()
			task.delay(0.06, function() ts:Create(b, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(lt._originalBarPos.X.Scale, lt._originalBarPos.X.Offset, 1.25, 0)}):Play() end)
			local q = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			ts:Create(bg.Gradient, q, {ImageTransparency = 1}):Play()
			ts:Create(bg.Rectangle, q, {BackgroundTransparency = 1}):Play()
			ts:Create(fr.ImageLabel, q, {ImageTransparency = 1}):Play()
			ts:Create(fr, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			task.wait(1.5)
			if wg ~= g then return end
			if wk then wk:Disconnect() end
			for _, x in wo do x:Cancel() end
			wv.Enabled = false
		end)
	end)
end

local function wy(f, id, mp, h, o)
	if cj then cj:Stop() end
	local r = h.Parent and h.Parent:FindFirstChild("HumanoidRootPart")
	if not r then return nil, "Warp Failed: No Character" end
	local sp, cf, ok = md("Shared", "Lib", "SpawnPointDialogue"), CFrame.new(r.Position + Vector3.new(0, 1000, 0)), false
	o.hb = game:GetService("RunService").Heartbeat:Connect(function()
		if r.Parent then r.AssemblyLinearVelocity, r.CFrame = Vector3.zero, cf end
	end)
	task.wait(0.5)
	cf = CFrame.new(mp.X, 1000, mp.Z)
	task.wait(1)
	cf = CFrame.new(mp + Vector3.new(4, 3, 0))
	task.wait(0.3)
	local dl = os.clock() + 4.5
	while not ok and os.clock() < dl and f.st == "Running" do
		local b, dn = {}, false
		task.spawn(function() sp.CreateAction(true, b, b).on_select(function(x) ok, dn = x == true, true end) end)
		local d2 = os.clock() + 3
		repeat task.wait() until dn or os.clock() > d2
		if not ok then task.wait(0.1) end
	end
	o.hb:Disconnect()
	if f.st ~= "Running" then return nil end
	if not ok then return nil, "Warp Failed: Spawn Not Set" end
	local bc, tk = md("Controllers", "BackpackController"), false
	for _ = 1, 10 do
		task.wait(1)
		if f.st ~= "Running" then return nil end
		local s, v = pcall(function() return bc.TeleportToSpawn:Fire() end)
		tk = s and v == true
		if tk then break end
	end
	if not tk then return nil, "Warp Failed: Respawn Refused" end
	dl = os.clock() + 8
	repeat task.wait(0.2) until ic() == id and lc() or os.clock() > dl
	if ic() ~= id then return nil, "Warp Failed: Not On Island" end
	return true
end

local function wx(f, id)
	if not (wb.on and ul(id)) then return nil end
	local mp = wm(id)
	if not mp then return nil, "Warp Failed: No Boat Merchant" end
	local ok, e = nil, nil
	wc(true)
	while f.st == "Running" do
		local dl, h = os.clock() + 8, nil
		repeat
			local _, _, x = lc()
			h = x
			if not h then task.wait(0.2) end
		until h or os.clock() > dl or f.st ~= "Running"
		if not h then continue end
		local o: {hb: RBXScriptConnection?} = {}
		local s
		s, ok, e = pcall(wy, f, id, mp, h, o)
		if o.hb then o.hb:Disconnect() end
		if not s then ok, e = nil, `Warp Failed: {ok}` end
		if ok or f.st ~= "Running" then break end
		task.wait(1)
	end
	wc(false, ok)
	return ok, e
end

local function ti(f, id, k)
	if ic() == id then return true end
	local w, we = wx(f, id)
	if w or f.st ~= "Running" then return w end
	if we then f.nq = {Title = "Teleport", Text = `{we}, Sailing`} end
	local m, e = gb(f, k)
	if not m then return nil, e end
	local g
	g, e = sb(f, m)
	if not g then return nil, e end
	g, e = dv(f, m, id)
	if not g then return nil, e end
	local c, r = lc()
	if not c then return nil, "No Character" end
	local mp, mx = ns("npc_car_merchant", r.Position)
	local cp = mp and mx:GetAttribute("IslandId") == id and mp or e and e + ((e - r.Position) * Vector3.new(1, 0, 1)).Unit * 12 or rg(id)
	g, e = go(f, ap(c, cp, r.Position))
	if not g then return nil, e end
	task.wait(0.5)
	if ic() ~= id then return nil, "Not On Island" end
	return true
end

local function zm(p, wi)
	if zy.wl[p.UserId] then return true end
	local hm = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	local an = hm and hm:FindFirstChildOfClass("Animator")
	for _, t in an and an:GetPlayingAnimationTracks() or {} do
		if t.WeightCurrent > 0.05 and t.Animation and wi[t.Animation.AnimationId] then
			zy.wl[p.UserId] = true
			return true
		end
	end
	return false
end

local function zw()
	local c, r = lc()
	local id = r and vi(r.Position) or ""
	local am = c and c:FindFirstChild("Animate")
	if not am then return false end
	local g = id ~= "" and os.clock() >= zy.ss and rg(id)
	if g then
		zy.ss = os.clock() + 10
		task.spawn(sq, Vector3.new(g.X, 2, g.Z), 5)
	end
	local wi, nr, cs = {}, false, game:GetService("CollectionService")
	for _, n in {"walk", "run"} do
		for _, x in am:FindFirstChild(n) and am[n]:GetChildren() or {} do
			if x:IsA("Animation") then wi[x.AnimationId] = true end
		end
	end
	for _, p in game:GetService("Players"):GetPlayers() do
		local h = p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if h then
			if zy.fr[p.UserId] == nil then
				local ok, v = pcall(lp.IsFriendsWith, lp, p.UserId)
				zy.fr[p.UserId] = ok and v == true
			end
			for _, x in zy.fr[p.UserId] == false and zm(p, wi) and id ~= "" and cs:GetTagged("IslandRegion") or {} do
				if x:IsA("BasePart") and x:GetAttribute("islandId") == id and (x.Position - h.Position).Magnitude < x.Size.X / 2 then nr = true end
			end
		end
	end
	return nr
end

local function zh()
	zy.nt = os.clock() + 30
	local ok, r = pcall(function() return hs:JSONDecode((game :: any):HttpGet(`https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Asc&limit=100`)) end)
	if not ok or type(r) ~= "table" or type(r.data) ~= "table" then return nil, "Hop Failed: Server List" end
	local o = {}
	for _, s in r.data do
		if type(s) == "table" and type(s.id) == "string" and s.id ~= game.JobId and tonumber(s.playing) and tonumber(s.maxPlayers) and s.playing < s.maxPlayers then table.insert(o, s.id) end
	end
	if #o == 0 then return nil, "Hop Failed: No Server" end
	local tp = game:GetService("TeleportService")
	local tk, e = pcall(tp.TeleportToPlaceInstance, tp, game.PlaceId, o[math.random(1, math.min(5, #o))], lp)
	if not tk then return nil, `Hop Failed: {e}` end
	task.wait(15)
	return nil, "Hop Failed: Teleport Timeout"
end

local function sa()
	local cs, n = game:GetService("CollectionService"), 0
	for _, x in cs:GetTagged("IslandRegion") do
		if x:IsA("BasePart") then sq(Vector3.new(x.Position.X, 2, x.Position.Z), 10) end
	end
	for _, x in cs:GetTagged("BossRegion") do
		if x:IsA("BasePart") then n += 1 end
	end
	return n
end

local function br(f)
	local ev = rv.EventController and rv.EventController._active_events
	if type(ev) ~= "table" or next(ev) == nil then
		f.bx = nil
		return nil
	end
	local function fd()
		local n = 0
		for _, x in game:GetService("CollectionService"):GetTagged("BossRegion") do
			local fx = x:IsA("BasePart") and x:FindFirstChild("BossSpawnerFX")
			n += 1
			if fx and fx:GetAttribute("BossSpawnerFXActive") == true and x ~= f.bx then return x, n end
		end
		return nil, n
	end
	local x, n = fd()
	if x or n >= 12 or os.clock() < (f.sc or 0) then return x end
	f.sc = os.clock() + 20
	sa()
	return (fd())
end

local function zd(m)
	local mn = m and m:FindFirstChild("Main")
	if not mn then return nil end
	local cf, sz, rp, st, pt, bn = mn.CFrame, mn.Size, RaycastParams.new(), {}, {}, {}
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {m}
	for _, x in m:GetDescendants() do
		if x:IsA("Seat") or x:IsA("VehicleSeat") then table.insert(st, x) end
	end
	for z = 0, sz.Z / 2, 0.5 do
		for x = -sz.X / 2, sz.X / 2, 0.5 do
			local o = cf:PointToWorldSpace(Vector3.new(x, 0, z))
			local h = workspace:Raycast(Vector3.new(o.X, cf.Position.Y + 20, o.Z), Vector3.new(0, -40, 0), rp)
			if h and h.Instance.CanCollide and h.Normal.Y > 0.95 then
				local k = math.floor(h.Position.Y * 2 + 0.5)
				bn[k] = (bn[k] or 0) + 1
				table.insert(pt, {h.Position, k})
			end
		end
	end
	local fk, fn = nil, 0
	for k, n in bn do
		if n > fn then fk, fn = k, n end
	end
	local c, b, bd = cf:PointToWorldSpace(Vector3.new(0, 0, sz.Z / 4)), nil, math.huge
	for _, v in pt do
		if math.abs(v[2] - fk) <= 1 then
			local fr = true
			for _, q in st do
				local l = q.CFrame:PointToObjectSpace(v[1])
				if math.abs(l.X) < q.Size.X / 2 + 0.75 and math.abs(l.Z) < q.Size.Z / 2 + 0.75 then fr = false; break end
			end
			local d = ((v[1] - c) * Vector3.new(1, 0, 1)).Magnitude
			if fr and d < bd then b, bd = v[1], d end
		end
	end
	return b
end

local function oz(m)
	local _, r, h = lc()
	if not (r and m and m.Parent) or h.SeatPart or rv.Swimming and rv.Swimming:IsSwimming() then return false end
	local rp = RaycastParams.new()
	rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {m}
	return workspace:Raycast(r.Position, Vector3.new(0, -6, 0), rp) ~= nil
end

local function sd(f, m)
	local p = zd(m)
	if not p then return false end
	local g = gf(f, p + Vector3.new(0, 3, 0))
	if not g or f.st ~= "Running" then return false end
	if not mo(p + Vector3.new(0, 3, 0), 30) then return false end
	task.wait(1)
	return oz(m)
end

local function bw(f)
	local _, r = lc()
	if not r then return nil, "No Character" end
	local id = ic()
	local np = ns("npc_fish_seller", r.Position)
	if not np and rg(id) then
		sq(Vector3.new(rg(id).X, 2, rg(id).Z), 10)
		np = ns("npc_fish_seller", r.Position)
	end
	if not np then return nil, "No Fish Seller" end
	local w = workspace:FindFirstChild("World")
	local il, ip = w and w:FindFirstChild("Islands"), RaycastParams.new()
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	local d = (r.Position - np) * Vector3.new(1, 0, 1)
	local u, pt = d.Magnitude > 1 and d.Unit or Vector3.xAxis, nil
	for k = 10, math.max(300, d.Magnitude), 5 do
		local q = np + u * k
		if not workspace:Raycast(Vector3.new(q.X, 103, q.Z), Vector3.new(0, -100, 0), ip) then
			pt = q
			break
		end
	end
	if not pt then return nil, "No Water Near Fish Seller" end
	local m, e = gb(f, f.bk())
	if not m then return nil, e end
	local ok
	ok, e = sb(f, m)
	if not ok then return nil, e end
	ok, e = dv(f, m, id, pt)
	if ok then sd(f, m) end
	return ok, e
end

local function hz(f, y)
	local _, r = lc()
	if not r then return nil, "No Character" end
	local function sw() return rv.Swimming and rv.Swimming:IsSwimming() end
	if cj and not cj.dn and not sw() and r.Position.Y > y - 2 then return true end
	local j, e = mo(Vector3.new(r.Position.X, y, r.Position.Z), 30)
	if not j then return nil, e end
	local dl = os.clock() + 4
	repeat task.wait(0.1) until j.st == "Arrived" and not sw() or j.dn or f.st ~= "Running" or os.clock() > dl
	if j.dn then return nil, j.why or "Hover Failed" end
	if f.st ~= "Running" then return nil end
	if sw() then return nil, "Hover Failed: Still Swimming" end
	return true
end

local function bo(f)
	local ev = rv.EventController and rv.EventController._active_events
	if type(ev) ~= "table" or next(ev) == nil then f.s.bc = false end
	if f.s.bc or (tonumber(pd().LastBossKillSlot) or 0) >= workspace:GetServerTimeNow() // 2400 * 2400 then return nil end
	if os.clock() < (f.bl or 0) then return nil end
	local x = br(f)
	if not x then return nil end
	local id, q = x.Parent and x.Parent.Parent and x.Parent.Parent.Name, Vector3.new(x.Position.X, 3, x.Position.Z)
	local _, r, h = lc()
	if not r then return nil, "No Character" end
	f.br = x
	local sw = rv.Swimming and rv.Swimming:IsSwimming()
	local cm = workspace:FindFirstChild("Cars")
	cm = cm and cm:FindFirstChild(tostring(lp.UserId))
	local cn = cm and cm:FindFirstChild("Main") and ((cm.Main.Position - q) * Vector3.new(1, 0, 1)).Magnitude <= 50
	if (((r.Position - q) * Vector3.new(1, 0, 1)).Magnitude <= 45 or cn and oz(cm)) and not h.SeatPart then
		if cn and (oz(cm) and cj and not cj.dn or sd(f, cm)) then
			f.bm = cm
			pq(cm, false)
			return q
		end
		if f.st ~= "Running" then return nil end
		local ok, e = hz(f, q.Y + 9)
		if not ok then return nil, e end
		return q
	end
	if not (f.hm or f.bb or sw or h.SeatPart) and ic() ~= "" then f.hm = {r.CFrame, ic()} end
	if id and ic() ~= id and wx(f, id) then
		_, r, h = lc()
		if not r then return nil, "No Character" end
	end
	if f.st ~= "Running" then return nil end
	local d = (r.Position - q) * Vector3.new(1, 0, 1)
	local m, e = gb(f, f.bk())
	if not m then return nil, e end
	local ok
	ok, e = sb(f, m)
	if not ok then return nil, e end
	local w, cs = workspace:FindFirstChild("World"), workspace:FindFirstChild("Cars")
	local il, ip, a0, pt = w and w:FindFirstChild("Islands"), RaycastParams.new(), math.floor(lp.UserId * 0.6180339887 % 1 * 8), nil
	ip.FilterType, ip.FilterDescendantsInstances = Enum.RaycastFilterType.Include, {il}
	for i = 0, 7 do
		local p, fr = q + Vector3.new(math.sin((a0 + i) * math.pi / 4), 0, math.cos((a0 + i) * math.pi / 4)) * 40, true
		for _, x in cs and cs:GetChildren() or {} do
			local mn = x.Name ~= tostring(lp.UserId) and x:FindFirstChild("Main")
			if mn and ((mn.Position - p) * Vector3.new(1, 0, 1)).Magnitude < 28 then fr = false; break end
		end
		if fr and (not il or not workspace:Raycast(p + Vector3.new(0, 100, 0), Vector3.new(0, -100, 0), ip)) then pt = p; break end
	end
	ok, e = dv(f, m, id, pt or q + (d.Magnitude > 1 and d.Unit or Vector3.xAxis) * 40)
	if not ok then return nil, e end
	f.bb = true
	if sd(f, m) then
		f.bm = m
		pq(m, false)
		return q
	end
	if f.st ~= "Running" then return nil end
	ok, e = hz(f, q.Y + 9)
	if not ok then return nil, e end
	return q
end

local qd = {
	{"unlock_island_2", "island_starter", "island_jungle", "Jungle Island", {RequiredCoin = 40000}},
	{"unlock_island_3", "island_jungle", "island_desert", "Desert Island", {RequiredCoin = 180000}},
	{"unlock_island_4", "island_desert", "island_snow", "Snow Island", {RequiredCoin = 900000, RequiredFish = 3}, {"Legendary", "island_desert"}},
	{"unlock_island_5", "island_snow", "island_volcano", "Volcanic Island", {RequiredCoin = 4000000, RequiredFishes = {frozen_crown_dragonfish = 1, frosttusk_seal = 1, frostmaw_monster = 1}}},
	{"unlock_island_6", "island_volcano", "island_fossil", "Fossil Island", {RequiredCoin = 15000000, RequiredFishes = {ancient_trihorn_fish = 1, stormblade_shark = 1, lavascale_dragonfish = 1}}},
}

local qt, qz, qm = {
	{"crimson_bead_rod", "island_volcano", "island_volcano", "Crimson Bead Rod", {RequiredFished = 0}, nil, "legacy_rod"},
	{"bamboo_rod", "island_volcano", "island_volcano", "Bamboo Rod", {RequiredBamboo = 0}, nil, "crimson_bead_rod", "island_jungle"},
	{"heaven_piercer_turtle_rod", "island_fossil", "island_fossil", "Heaven Piercer Turtle Rod", {RequiredFish = 0}, {"Legendary", "island_fossil"}, nil, "island_fossil"},
	{"zen_staff_rod", "island_fossil", "island_fossil", "Zen Staff Rod", {RequiredFish = 0}, nil, nil, "island_fossil"},
	{"dread_fish_rod", "island_fossil", "island_fossil", "Dread Fish Rod", {RequiredFish = 0}, {"Mythical", "island_fossil"}, nil, "island_fossil"},
	{"taiji_hooking_art_v2", "island_snow", "island_snow", "Taiji Hooking Art V2 Upgrade", {RequiredKills = 0}},
}, {}, {}
for _, q in qt do
	table.insert(qz, q[4])
	qm[q[4]] = q
end

local qg, qgz = {
	{"white_tiger", "island_desert", "island_desert", "White Tiger Soul", {RequiredFish = 3}, {"Legendary", "island_desert", 1000}, nil, "island_desert", true},
	{"phoenix", "island_snow", "island_snow", "Phoenix Soul", {RequiredFish = 3}, {"Legendary", "island_snow"}, nil, "island_snow", true},
	{"azure_dragon", "island_volcano", "island_volcano", "Azure Dragon Soul", {RequiredFish = 0, CatchWithSkill = 0}, {"Legendary", "island_volcano"}, nil, "island_volcano", true},
	{"supreme_king", "island_fossil", "island_fossil", "Supreme King Soul", {CatchWithSkill = 0, RequiredBooks = {}}, nil, nil, "island_fossil", true},
}, {}
for _, q in qg do table.insert(qgz, q[4]) end

local function qc(q, d, pr)
	local ct, n, ks, df, id, rr = md("Data", "Catalog"), {}, {}, {}, q[1], q[6]
	local wk = id == "unlock_island_6" and md("Data", "Config", "QuestConfig").UnlockIsland6MinWeightKg or {}
	if rr then
		for _, x in (ct.Island.GetById(rr[2]) or {}).fishes or {} do df[x.fishId] = true end
	end
	local rf = rr and {["*"] = pr.RequiredFish or 1} or pr.RequiredFishes or {}
	for u, x in d.Inventory and d.Inventory.Fishes or {} do
		local fi = ct.Fish.GetById(x.fishId)
		local k = rr and fi and fi.rarity == rr[1] and df[x.fishId] and (x.weight or 0) >= (rr[3] or 0) and "*" or not rr and rf[x.fishId] and (id ~= "unlock_island_6" or wk[x.fishId] and (x.weight or 0) >= wk[x.fishId]) and x.fishId
		if k and (n[k] or 0) < rf[k] then n[k], ks[u] = (n[k] or 0) + 1, true end
	end
	local ok = (d.Coin or 0) >= (pr.RequiredCoin or 0)
	for k, v in rf do
		if (n[k] or 0) < v then ok = false end
	end
	if id == "crimson_bead_rod" and (pr.CurrentFished or 0) < (pr.RequiredFished or 1) then ok = false end
	if id == "zen_staff_rod" and (pr.CurrentFish or 0) < (pr.RequiredFish or 1) then ok = false end
	if id == "bamboo_rod" and md("Shared", "getItemCount")(d, "bamboo_fragment") < (pr.RequiredBamboo or 1) then ok = false end
	if id == "taiji_hooking_art_v2" and ((pr.CurrentKills or 0) < (pr.RequiredKills or 1) or (((d.Inventory or {}).Books or {}).taiji_hooking_art or 0) < (pr.RequiredBookCount or 1)) then ok = false end
	if (id == "azure_dragon" or id == "supreme_king") and (pr.CurrentUsedSkill or 0) < (pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5)) then ok = false end
	if id == "phoenix" or id == "supreme_king" then
		local ba = md("Utils", "skillBookAvailability")
		for b, v in id == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or pr.RequiredBooks or {rod_gate_20_percent = 1} do
			if ba.GetCounts(d, b).available < v then ok = false end
		end
	end
	return ok, ks
end

local function qn(f)
	for _, q in qd do
		if not ul(q[3]) then return ul(q[2]) and not f.qx[q[1]] and q or nil end
	end
	return nil
end

local function qw(f, k, t, h)
	if f.qw[k] then return end
	f.qw[k], f.nq = true, {Title = h or "Rod Quest", Text = t}
end

local function qp(f)
	local q, d = f.qs(), pd()
	if not q or f.qx[q[1]] then return nil end
	if d.Quest and d.Quest.Done and d.Quest.Done[q[1]] then
		f.qx[q[1]], f.nq = true, {Title = "Rod Quest", Text = `{q[4]} Already Done`}
		return nil
	end
	if not ul(q[2]) then return qw(f, `i{q[1]}`, `Rod Quest Waiting: Island Locked`) end
	if q[7] and not (d.Rods and d.Rods[q[7]]) then return qw(f, `r{q[1]}`, `Rod Quest Waiting: No {q[7] == "legacy_rod" and "Legacy Rod" or "Crimson Bead Rod"}`) end
	if q[1] == "taiji_hooking_art_v2" and (((d.Inventory or {}).Books or {}).taiji_hooking_art or 0) < 1 then return qw(f, `b{q[1]}`, "Rod Quest Waiting: No Taiji Hooking Art Book") end
	return q
end

local function qk(d, ys)
	local r, dn, so = {}, (d.Quest or {}).Done or {}, (d.Inventory or {}).Souls or {}
	for _, q in qg do
		if table.find(ys or {}, q[4]) and not dn[q[1]] and so[q[1]] ~= true then table.insert(r, q) end
	end
	return r
end

local function qy(f)
	local d = pd()
	local cq = (d.Quest or {}).Current or {}
	local ls, hb = qk(d, f.ys()), {}
	for _, x in ((d.Rods or {})[d.RodEquip] or {}).BookSlots or {} do hb[x] = true end
	for i, q in ls do
		if q[1] == cq.Id then table.insert(ls, 1, table.remove(ls, i)); break end
	end
	for _, q in ls do
		local id, pr = q[1], cq.Id == q[1] and cq.Progress or {}
		local fb = (pr.CurrentUsedSkill or 0) < (pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5))
		local ba, mb = md("Utils", "skillBookAvailability"), {}
		for b, v in id == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or id == "supreme_king" and not fb and (pr.RequiredBooks or {rod_gate_20_percent = 1}) or {} do
			if ba.GetCounts(d, b).available < v then table.insert(mb, (md("Data", "Catalog").Skill.GetById(b) or {}).name or b) end
		end
		table.sort(mb)
		if f.qx[id] then
			continue
		elseif not ul(q[2]) then
			qw(f, `yi{id}`, `Soul Quest Waiting: {q[4]} Island Locked`, "Soul Quest")
		elseif #mb > 0 then
			qw(f, `yb{id}`, `Soul Quest Waiting: {q[4]} Needs Unequipped {table.concat(mb, ", ")}`, "Soul Quest")
		elseif fb and (id == "azure_dragon" or id == "supreme_king") and not hb[id == "azure_dragon" and "one_hook_supreme" or "rod_gate_20_percent"] then
			qw(f, `ye{id}`, `Soul Quest Waiting: Equip {id == "azure_dragon" and "One Hook Supreme" or "Rod Gate 20%"}`, "Soul Quest")
		else
			return q
		end
	end
	return nil
end

local function qv(q)
	local d = pd()
	if not q then return {} end
	local cq = d.Quest and d.Quest.Current
	local _, ks = qc(q, d, cq and cq.Id == q[1] and cq.Progress or q[5])
	return ks
end

local function gn(q)
	local id, g = `npc_{q[1]}`, rg(q[3])
	local p = ns(id, Vector3.zero)
	if not p and g then
		sq(Vector3.new(g.X, 2, g.Z), 10)
		p = ns(id, Vector3.zero)
	end
	return p
end

local function ub()
	local d, n = pd(), 0
	for _, r in d.Rods or {} do
		for _, id in r.BookSlots or {} do
			if id == "taiji_hooking_art" then n += 1 end
		end
	end
	if (((d.Inventory or {}).Books or {}).taiji_hooking_art or 0) - n >= 1 then return true end
	local re = d.Rods and d.Rods[d.RodEquip]
	for s, id in re and re.BookSlots or {} do
		if id == "taiji_hooking_art" then
			local i = tonumber(tostring(s):match("%d+"))
			local x = i and rv.EquipmentsController.EquipMoveset:Fire("", i)
			if x ~= "Success" then return nil, `Unequip Book Failed: {x or "No Response"}` end
			local dl = os.clock() + 3
			repeat task.wait(0.2) until (((pd().Rods or {})[d.RodEquip] or {}).BookSlots or {})[s] ~= "taiji_hooking_art" or os.clock() > dl
			return true, nil, i
		end
	end
	return nil, "Unequip Book Failed: Book On Another Rod"
end

local function ug(f, q, ac)
	local ok, e = ti(f, q[3], f.bk())
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	local np = gn(q)
	if not np then return nil, "No Island Guide" end
	local sp = ap(c, np, rt.Position)
	ok, e = (q[1] == "zen_staff_rod" and gf or go)(f, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
	if not ok then return nil, e or f.st == "Running" and "Move Failed" or nil end
	if f.st ~= "Running" then return nil end
	local qr, iu = rv.QuestController, q[1]:find("^unlock_island_") ~= nil
	local tt, px = iu and "Island Guide" or q[9] and "Soul Quest" or "Rod Quest", iu and "Unlock Island Failed" or q[9] and "Soul Quest Failed" or "Rod Quest Failed"
	local function vb() return ((pd().Inventory or {}).Books or {}).taiji_hooking_art_v2 or 0 end
	local v0 = vb()
	local function dn() return ((pd().Quest or {}).Done or {})[q[1]] == true or q[1] == "taiji_hooking_art_v2" and vb() > v0 or q[9] and ((pd().Inventory or {}).Souls or {})[q[1]] == true end
	if not ac then
		local a, m = qr:Accept(q[1])
		if a ~= true then
			f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {m or "Accept Refused"}`}
			return true
		end
		local dl = os.clock() + 3
		repeat task.wait(0.2) until (pd().Quest or {}).Current and pd().Quest.Current.Id == q[1] or os.clock() > dl
		local cq = (pd().Quest or {}).Current
		if not (cq and cq.Id == q[1]) then return nil, "Quest Not Saved" end
		if not qc(q, pd(), cq.Progress or {}) then
			f.nq = {Title = tt, Text = `{q[4]} Quest Accepted, Requirements Not Met`}
			return true
		end
	end
	local cq = (pd().Quest or {}).Current
	local _, ks = qc(q, pd(), cq and cq.Id == q[1] and cq.Progress or q[5])
	for u in ks do
		local x = pd().Inventory.Fishes[u]
		if x and x.locked == true then
			local s, v = rv.SellController:ToggleLock(u)
			if s ~= 0 or v ~= false then
				f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: Unlock Fish Failed`}
				return true
			end
		end
	end
	local bi2
	if q[1] == "taiji_hooking_art_v2" then
		local bo2, be2
		bo2, be2, bi2 = ub()
		if not bo2 then
			f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {be2}`}
			return true
		end
	end
	local cp, m = qr:Complete(q[1])
	if cp ~= true then
		f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: {m or "Complete Refused"}`}
		return true
	end
	local dl = os.clock() + 5
	repeat task.wait(0.2) until dn() or os.clock() > dl
	if not dn() then
		f.qx[q[1]], f.nq = true, {Title = tt, Text = `{px}: Not Completed`}
		return true
	end
	if q[1] == "taiji_hooking_art_v2" then
		f.qx[q[1]] = true
		local d2 = pd()
		for sl, x in ((d2.Rods or {})[d2.RodEquip] or {}).BookSlots or {} do
			if not bi2 and x == "taiji_hooking_art" then bi2 = tonumber(tostring(sl):match("%d+")) end
		end
		local x = bi2 and rv.EquipmentsController.EquipMoveset:Fire("taiji_hooking_art_v2", bi2)
		if bi2 and x ~= "Success" then
			f.nq = {Title = tt, Text = `Got {q[4]}, Equip V2 Failed: {x or "No Response"}`}
			return true
		end
	end
	if q[9] and ({human = true, [""] = true})[pd().SoulEquip or ""] then
		local eo = rv.EquipmentsController.EquipmentEquip:Fire("soul", q[1])
		f.nq = {Title = tt, Text = eo == true and `Got {q[4]}, Equipped` or `Got {q[4]}, Equip Soul Failed`}
		return true
	end
	f.nq = {Title = tt, Text = `{iu and "Unlocked" or "Got"} {q[4]}`}
	return true
end

local function uq(f, q)
	if not q then return nil end
	local d = pd()
	local cq = d.Quest and d.Quest.Current
	local ci = cq and cq.Id or ""
	if ci ~= "" and ci ~= q[1] then return nil end
	if not qc(q, d, ci == q[1] and cq.Progress or q[5]) then return nil end
	local _, rt = lc()
	if not rt then return nil, "No Character" end
	local o, oi = rt.CFrame, ic()
	local ok, e = ug(f, q, ci == q[1])
	local hk, he = true, nil
	if f.st == "Running" and oi ~= "" and ic() ~= oi then hk, he = ti(f, oi, f.bk()) end
	if hk and f.st == "Running" and ic() == oi then hk, he = go(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
	f.rp = f.rp or not hk
	return true, not ok and e or not hk and f.st == "Running" and (he or "Return Failed") or nil
end

local function dy(f)
	local d, du = pd(), md("Shared", "Lib", "DailyQuestUtil")
	local dq = d.DailyQuest
	if type(dq) ~= "table" or type(dq.Active) ~= "table" then return nil end
	local a = dq.Active
	if a.Template ~= "" then
		if not du.IsSkillGachaQuest(a) or f.qw.dp then return nil end
		local sc = rv.SkillGachaController
		local q = sc.GetQuote:Fire(1)
		if type(q) ~= "table" or not q.ok then return nil, `Daily Quest Pull Failed: {type(q) == "table" and q.reason or "No Quote"}` end
		if (d.Coin or 0) < q.coin_cost then
			if not f.qw.dc then f.qw.dc, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Waiting: Not Enough Coin"} end
			return nil
		end
		f.qw.dc = nil
		sc._requestId = (tonumber(sc._requestId) or 0) + 1
		local r, p0 = sc.Pull:Fire("Coin", 1, sc._requestId), a.Progress or 0
		if type(r) ~= "table" or not r.ok then return nil, `Daily Quest Pull Failed: {type(r) == "table" and r.reason or "No Response"}` end
		local function mv()
			local x = pd().DailyQuest.Active
			return x.Template == "" or (x.Progress or 0) > p0
		end
		local dl = os.clock() + 5
		repeat task.wait(0.2) until mv() or os.clock() > dl
		if not mv() then f.qw.dp, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Failed: Pull Not Counted"} end
		return true
	end
	if os.clock() < (f.dx or 0) or (((d.Quest or {}).Current or {}).Id or "") ~= "" then return nil end
	if du.AcceptsLeft(dq, md("Shared", "Lib", "DailyRewardUtil").get_now()) <= 0 then
		if not f.qw.dd then f.qw.dd, f.nq = true, {Title = "Daily Quest", Text = "Daily Quest Done For Today"} end
		return nil
	end
	local id = f.fi() or ic()
	if id == "" or not ul(id) then return nil end
	local ok, e = ti(f, id, f.bk())
	if not ok then return true, e or f.st == "Running" and "Move Failed" or nil end
	local w = workspace:FindFirstChild("World")
	local fo = w and w:FindFirstChild("Islands") and w.Islands:FindFirstChild(id)
	local function nf()
		for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
			if fo and x:GetAttribute("InteractiveId") == "npc_daily_quest" and x:IsDescendantOf(fo) then return x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or nil end
		end
		return nil
	end
	local np, g = nf(), rg(id)
	if not np and g then
		sq(Vector3.new(g.X, 2, g.Z), 10)
		np = nf()
	end
	if not np then
		f.dx = os.clock() + 60
		return true, "Daily Quest Failed: No Quest NPC"
	end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	local sp = ap(c, np, rt.Position)
	ok, e = go(f, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
	if not ok then return true, e or f.st == "Running" and "Move Failed" or nil end
	if f.st ~= "Running" then return true end
	local ak, m = rv.QuestController:AcceptDaily()
	f.rp = true
	if ak ~= true then f.dx = os.clock() + 60 end
	f.nq = {Title = "Daily Quest", Text = ak == true and `Daily Quest: {m}` or `Daily Quest Failed: {m ~= "" and m or "Accept Refused"}`}
	return true
end

local function ss(f)
	local s, fc = f.s, rv.FishingController
	local ks = sk()
	if #ks == 0 then return "Auto Fish Failed: No Skill Equipped" end
	local bp, be
	if f.ab() then bp, be = bo(f) end
	f.bu = bp ~= nil
	if not bp and f.bm then
		pq(f.bm, true)
		f.bm, f.rp = nil, true
		if cj then cj:Stop() end
	end
	if be then return nil, be end
	if not bp and f.bb then f.bb, f.rp = false, true end
	if not bp and f.hm then
		local o, oi = f.hm[1], f.hm[2]
		local ok, e = true, nil
		if ic() ~= oi then ok, e = ti(f, oi, f.bk()) end
		if ok and f.st == "Running" then ok, e = go(f, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
		if f.st ~= "Running" then return nil end
		if not ok then return nil, e or "Return Failed" end
		f.hm, f.rp = nil, false
		return nil
	end
	if not bp then
		for _, q in {f.au() and qn(f) or false, f.qa() and qp(f) or false, f.ya() and qy(f) or false} do
			local u, ue = uq(f, q or nil)
			if u or ue then return nil, ue end
		end
		if f.dq() then
			local u, ue = dy(f)
			if u or ue then return nil, ue end
		end
	end
	local rq = not bp and f.qa() and qp(f)
	local rc = rq and rq[8] and (pd().Quest or {}).Current
	local da = not bp and f.dq() and (pd().DailyQuest or {}).Active
	local yq = not bp and f.ya() and qy(f)
	local fi = not bp and (rc and rc.Id == rq[1] and rq[8] or da and da.Template ~= "" and da.IslandId ~= "" and da.IslandId or yq and yq[8] or f.fi())
	if fi and ic() ~= fi then
		if not ul(fi) then return "Auto Fish Failed: Island Locked" end
		local ok, e = ti(f, fi, f.bk())
		if not ok then return nil, e end
		f.rp = true
		return nil
	end
	if f.ao() and fl() then
		if bp then
			local ok, e = bw(f)
			if not ok then return nil, e end
		end
		local hd, sf = tr(f)
		if hd or sf or f.st ~= "Running" then return hd, sf end
		task.wait(1)
		if fl() then return "Auto Fish Failed: Satchel Full" end
		if bp then return nil end
	end
	local ok, e = eq()
	if not ok then return nil, e end
	local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
	if not h then return nil, "No Character" end
	if not bp and (f.rp or rv.Swimming and rv.Swimming:IsSwimming() or not tg(h)) then
		f.rp = false
		local g = rs(vi(h.Position))
		if not g and vi(h.Position) == "" then
			local nb, nd = nil, math.huge
			for _, x in game:GetService("CollectionService"):GetTagged("IslandRegion") do
				local id = x:GetAttribute("islandId")
				if x:IsA("BasePart") and type(id) == "string" and ul(id) and (x.Position - h.Position).Magnitude < nd then nb, nd = id, (x.Position - h.Position).Magnitude end
			end
			if nb then
				f.rp = true
				local ok, e = ti(f, nb, f.bk())
				return nil, not ok and (e or "Move Failed") or nil
			end
		end
		if not g then return "Auto Fish Failed: No Open Water" end
		local q = tg({Position = g})
		local mk, me = go(f, g, q and ((q - g) * Vector3.new(1, 0, 1)).Unit)
		if not mk then return nil, me end
	end
	if not bp and rv.Swimming and rv.Swimming:IsSwimming() then
		f.rp = true
		return nil, "Swimming"
	end
	local p = bp or tg(h)
	if not p then return "Auto Fish Failed: No Open Water" end
	s.wa, s.fp, s.rl, s.q, s.cr, s.rr, s.sw, s.bs, s.id = nil, nil, nil, nil, nil, nil, 0, 0, nil
	fc.FishCast:Fire(1, p)
	local dl = os.clock() + 3
	repeat task.wait() until s.wa or s.fp or s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	if not (s.wa or s.fp or s.rl or s.cr or s.rr) then
		if f.st == "Running" then fc.FishLootConfirm:Fire() end
		return nil, "No Cast Ack"
	end
	dl = os.clock() + 25
	repeat task.wait() until s.fp or s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	if s.fp and not (s.rl or s.cr or s.rr) and f.st == "Running" then
		fp(s)
		repeat task.wait() until s.rl or s.cr or s.rr or f.st ~= "Running" or os.clock() > dl
	end
	local fo = s.id and md("Data", "Catalog").Fish.GetById(s.id)
	local bf = fo and fo.kind == "Boss"
	local zq, zk, zc = not bp and f.qa() and qp(f), ks, (pd().Quest or {}).Current or {}
	local zp = zc.Progress or {}
	local zs = zq and zc.Id == zq[1] and (zq[1] == "zen_staff_rod" and fo and fo.rarity == "Legendary" and ic() == "island_fossil" and "taiji_hooking_art_v2" or zq[1] == "taiji_hooking_art_v2" and "taiji_hooking_art") or not bp and f.ya() and (zp.CurrentUsedSkill or 0) < (zp.CatchWithSkill or 1) and (zc.Id == "azure_dragon" and "one_hook_supreme" or zc.Id == "supreme_king" and fo and fo.rarity == "Legendary" and ic() == "island_fossil" and "rod_gate_20_percent")
	if zs then
		zk = {}
		for _, x in ks do
			if x[2] == zs then table.insert(zk, x) end
		end
		if #zk == 0 then
			local rq2 = zs:find("^taiji") ~= nil
			zk = ks
			qw(f, `z{zs}`, `{rq2 and "Rod" or "Soul"} Quest Waiting: Equip {({taiji_hooking_art = "Taiji Hooking Art", taiji_hooking_art_v2 = "Taiji Hooking Art V2", one_hook_supreme = "One Hook Supreme", rod_gate_20_percent = "Rod Gate 20%"})[zs]}`, rq2 and "Rod Quest" or "Soul Quest")
		end
	end
	local re = s.rl and f.st == "Running" and rl(f, s, zk) or not (s.cr or s.rr) and f.st == "Running" and "Bite Timeout"
	if bf and not (s.cr and s.cr[1]) then f.bl = os.clock() + 180 end
	if f.st ~= "Running" or re then
		if s.cr and s.cr[1] and not s.cr[2] then task.wait(0.75); fc.FishLootConfirm:Fire() end
		if not (s.cr or s.rr) then fc.FishCancel:Fire(); task.wait(1) end
		return nil, re
	end
	if bp and s.rr == "IslandLocked" then
		f.bx, f.bb, f.rp = f.br, false, true
		return nil
	end
	if s.rr == "NoSkillEquipped" then return "Auto Fish Failed: No Skill Equipped" end
	if s.rr == "SatchelFull" and not f.ao() then return "Auto Fish Failed: Satchel Full" end
	if s.rr == "SessionActive" then
		fc.FishLootConfirm:Fire()
		fc.FishCancel:Fire()
		task.wait(1)
	end
	if s.rr then return nil, s.rr end
	if s.cr[1] then
		f.c += 1
		if not s.cr[2] then task.wait(0.75); fc.FishLootConfirm:Fire() end
	end
	task.wait(0.6)
	return nil
end

local function rn(f)
	local n = 0
	while f.st == "Running" do
		if f.iw() then
			task.wait(0.5)
			continue
		end
		if zy.on and zy.rq and not (f.bu or f.bb or f.hm) then
			zy.rq = false
			local _, e = zh()
			f.nq = {Title = "Safe", Text = e}
			continue
		end
		f.bz = true
		local hd, sf = ss(f)
		f.bz = false
		if hd then f.why = hd; return end
		n = sf and n + 1 or 0
		if n >= 5 then
			n, f.rp, f.nq = 0, true, {Title = "Auto Fish", Text = `Auto Fish Retry: {sf}`}
			if cj then cj:Stop() end
			task.wait(1)
		elseif sf then
			task.wait(1)
		end
	end
end

local L = (function()
local ps, uis, tws, gs, hs, rs, cp = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("GuiService"), game:GetService("HttpService"), game:GetService("RunService"), game:GetService("ContentProvider")
local ge = getgenv and getgenv() or _G
local ff, fi = Font.new("rbxassetid://12187375422", Enum.FontWeight.Bold), Font.new("rbxassetid://12187375422", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
local c = {wh = Color3.new(1, 1, 1), bk = Color3.new(0, 0, 0), tx = Color3.fromRGB(232, 238, 255), dm = Color3.fromRGB(150, 165, 200), bl = Color3.fromRGB(85, 170, 255), gn = Color3.fromRGB(0, 249, 0), kf = Color3.fromRGB(204, 205, 209), er = Color3.fromRGB(235, 64, 52), nv = Color3.fromRGB(10, 16, 40), sk = Color3.fromRGB(20, 20, 30)}
local A = {rc = "rbxassetid://125251722298900", bd = "rbxassetid://136433490436465", pt = "rbxassetid://121067803898821", bn = "rbxassetid://93002040112047", cl = "rbxassetid://111107150082609", dv = "rbxassetid://136287431693380", tb = "rbxassetid://125130865636154", kp = "rbxassetid://135029838989371", ib = "rbxassetid://93542270748747", gb = "rbxassetid://78615923342985"}
local ww, wh = 500, 322
local mb, tc, mm = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement
local L, tf, fx, bad = {Flags = {}}, nil, {}, {}

local function mk(k, p, ch)
	local o = Instance.new(k)
	for i, v in p do
		if i ~= "Parent" then o[i] = v end
	end
	for _, x in ch or {} do x.Parent = o end
	o.Parent = p.Parent
	return o
end

local function rc(r)
	return mk("UICorner", {CornerRadius = UDim.new(0, r or 6)})
end

local function pd(l, r, t, b)
	return mk("UIPadding", {PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r or l), PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or t or 0)})
end

local function fire(f, ...)
	if type(f) ~= "function" then return end
	task.spawn(function(...)
		local ok, e = pcall(f, ...)
		if ok then return end
		warn(`Callback Failed: {e}`)
		if tf then tf(tostring(e)) end
	end, ...)
end

local function ck(q, k)
	if type(q) ~= "table" or type(q.Name) ~= "string" then error(`{k} Failed: No Name`) end
	if q.Flag ~= nil and type(q.Flag) ~= "string" then error(`{k} Failed: Bad Flag`) end
end

local function dg(h, cs, st, mv, en)
	local a, p0
	local function me(i)
		return i == a or (a.UserInputType == mb and i.UserInputType == mb)
	end

	table.insert(cs, h.InputBegan:Connect(function(i)
		if a or (i.UserInputType ~= mb and i.UserInputType ~= tc) then return end
		a, p0 = i, i.Position
		st(i)
	end))
	table.insert(cs, uis.InputChanged:Connect(function(i)
		if a and (i == a or (a.UserInputType == mb and i.UserInputType == mm)) then mv(Vector2.new(i.Position.X - p0.X, i.Position.Y - p0.Y)) end
	end))
	table.insert(cs, uis.InputEnded:Connect(function(i)
		if not a or not me(i) then return end
		local d = Vector2.new(i.Position.X - p0.X, i.Position.Y - p0.Y)
		a = nil
		if en then en(d) end
	end))
end

local function gr(p, k, r)
	local q = {}
	for i, x in k do q[i] = ColorSequenceKeypoint.new((i - 1) / (#k - 1), Color3.fromHex(x)) end
	return mk("UIGradient", {Parent = p, Color = ColorSequence.new(q), Rotation = r or 90})
end

local function fb(o, k)
	if bad[k] then o.BackgroundTransparency = 0 else table.insert(fx, {o, k}) end
	return o
end

task.spawn(function()
	local ls = {}
	for _, v in A do table.insert(ls, v) end
	pcall(cp.PreloadAsync, cp, ls, function(id, st)
		if st ~= Enum.AssetFetchStatus.Failure then return end
		for k, v in A do
			if v == id then bad[k] = true end
		end
		for _, x in fx do
			if bad[x[2]] and x[1].Parent then x[1].BackgroundTransparency = 0 end
		end
	end)
end)

local function tl(p, z, t, f, sc)
	return mk("TextLabel", {Parent = p, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, FontFace = f or ff, TextSize = z, TextColor3 = c.wh, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = t}, {mk("UIStroke", {Color = sc or c.sk, Thickness = 1.2})})
end

local function bt(x)
	local k = x:FindFirstChildOfClass("UIStroke")
	k.Color, k.Transparency, k.Thickness, k.LineJoinMode = c.bk, 0.25, 2, Enum.LineJoinMode.Round
	x.AnchorPoint, x.Position, x.Size, x.TextTruncate, x.TextXAlignment, x.TextScaled = Vector2.new(0.5, 0.5), UDim2.fromScale(0.58, 0.63), UDim2.fromScale(0.6, 0.32), Enum.TextTruncate.None, Enum.TextXAlignment.Center, true
	return x
end

local function hg(o)
	local w, g = Color3.new(1, 1, 1), Color3.fromRGB(126, 126, 126)
	mk("UIGradient", {Parent = o, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, w), ColorSequenceKeypoint.new(0.38, w), ColorSequenceKeypoint.new(0.59, g), ColorSequenceKeypoint.new(0.72, w), ColorSequenceKeypoint.new(1, w)})})
	return o
end

local function im(p, i, q)
	q.Parent, q.Image, q.BackgroundTransparency = p, i, q.BackgroundTransparency or 1
	return mk("ImageLabel", q)
end

local function pn(p, ss)
	local f, s = mk("Frame", {Parent = p, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}), Rect.new(256, 256, 256, 256)
	fb(mk("Frame", {Parent = f, Size = UDim2.fromScale(1, 1), BackgroundColor3 = c.nv, BackgroundTransparency = 1, BorderSizePixel = 0}, {rc(10)}), "rc")
	im(f, A.rc, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Slice, SliceCenter = s, SliceScale = ss, ImageColor3 = c.bk, ImageTransparency = 0.2, ZIndex = 2})
	im(f, A.pt, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -8, 1, -8), ScaleType = Enum.ScaleType.Crop, ImageColor3 = Color3.fromHex("9fa1a1"), ImageTransparency = 0.5, ZIndex = 2})
	gr(im(f, A.rc, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Slice, SliceCenter = s, SliceScale = ss, ImageTransparency = 0.5, ZIndex = 3}), {"0433ff", "000000"}, -90)
	gr(im(f, A.bd, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Slice, SliceCenter = s, SliceScale = ss, ImageColor3 = Color3.fromHex("f4f7ff"), ZIndex = 5}), {"f4f7ff", "7c8088", "7c8088"}, 73)
	return f
end

function L:Window(o)
	o = o or {}
	if type(o) ~= "table" then error("Window Failed: Bad Options") end
	if o.Key ~= nil and o.Key ~= false and typeof(o.Key) ~= "EnumItem" then error("Window Failed: Bad Key") end
	if o.Config ~= nil and (type(o.Config) ~= "string" or (o.Config .. "/"):gsub("[%w _%-]+/", "") ~= "") then error("Window Failed: Bad Config") end
	if ge.__AvW then pcall(ge.__AvW.Destroy, ge.__AvW) end

	local W, cs, tb, ov = {}, {}, {}, nil
	local key = o.Key == nil and Enum.KeyCode.LeftControl or o.Key
	local sg = mk("ScreenGui", {Name = hs:GenerateGUID(false), ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999})
	if not pcall(function() sg.Parent = gethui and gethui() or game:GetService("CoreGui") end) then sg.Parent = ps.LocalPlayer:WaitForChild("PlayerGui") end

	local w = mk("Frame", {Parent = sg, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(ww, wh), BackgroundTransparency = 1, Active = true})
	local us = mk("UIScale", {Parent = w})
	pn(w, 0.3)
	local tp = mk("Frame", {Parent = w, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Active = true, ZIndex = 2})
	local ta = tostring(o.Title or "MOS HUB")
	local t1 = ta:match("^(.-)%s*|")
	local bn = fb(im(w, A.bn, {Position = UDim2.fromOffset(-14, -30), Size = UDim2.fromOffset(300, 80), BackgroundColor3 = c.bl, ScaleType = Enum.ScaleType.Fit, Active = true, ZIndex = 3}), "bn")
	local tt = hg(tl(bn, 18, t1 or ta, fi))
	bt(tt)
	local xb = fb(mk("ImageButton", {Parent = w, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(34, 38), BackgroundColor3 = c.er, BackgroundTransparency = 1, AutoButtonColor = false, Image = A.cl, ScaleType = Enum.ScaleType.Fit, ZIndex = 4}), "cl")
	local xu = mk("UIScale", {Parent = xb})
	local nb = mk("TextButton", {Parent = w, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -32, 0, 18), Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 4})
	mk("Frame", {Parent = nb, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 3), BackgroundColor3 = c.wh, BorderSizePixel = 0, ZIndex = 4}, {rc(2), mk("UIStroke", {Color = c.sk, Thickness = 1.2})})
	local bar = mk("ScrollingFrame", {Parent = w, Position = UDim2.fromOffset(12, 48), Size = UDim2.new(0, 46, 1, -60), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 2}, {mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), HorizontalAlignment = Enum.HorizontalAlignment.Center}), pd(0, 0, 3, 3)})
	mk("Frame", {Parent = w, Position = UDim2.fromOffset(64, 48), Size = UDim2.new(0, 1, 1, -60), BackgroundColor3 = c.dm, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 2})
	local hd = hg(tl(w, 20, "", fi))
	hd.Position, hd.Size, hd.ZIndex = UDim2.fromOffset(78, 44), UDim2.new(1, -92, 0, 26), 2
	local bd = mk("Frame", {Parent = w, Position = UDim2.fromOffset(72, 74), Size = UDim2.new(1, -82, 1, -84), BackgroundTransparency = 1, ZIndex = 2})
	local gz = mk("TextButton", {Parent = w, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, -4), Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, AutoButtonColor = false, Text = "", ZIndex = 6})
	for _, q in {{10, 10}, {6, 10}, {10, 6}, {2, 10}, {6, 6}, {10, 2}} do mk("Frame", {Parent = gz, Position = UDim2.fromOffset(q[1], q[2]), Size = UDim2.fromOffset(2, 2), BackgroundColor3 = c.dm, BorderSizePixel = 0, ZIndex = 6}) end
	local hu = nil
	local hb = hu and hu:FindFirstAncestorOfClass("ScreenGui")
	local sh = mk("ScreenGui", {Name = hs:GenerateGUID(false), ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 998})
	if hb then
		sh.IgnoreGuiInset = hb.IgnoreGuiInset
		pcall(function() sh.ScreenInsets = hb.ScreenInsets end)
	end
	if not pcall(function() sh.Parent = gethui and gethui() or game:GetService("CoreGui") end) then sh.Parent = ps.LocalPlayer:WaitForChild("PlayerGui") end
	local se = nil
	local fl = mk("TextButton", {Parent = sh, Name = "MosToggle", AnchorPoint = Vector2.zero, Size = UDim2.fromOffset(46, 46), BackgroundColor3 = Color3.fromRGB(18, 18, 21), BackgroundTransparency = 0.05, AutoButtonColor = false, Font = Enum.Font.GothamBold, Text = "MOS", TextSize = 15, TextColor3 = Color3.fromRGB(255, 255, 255)}, {mk("UICorner", {CornerRadius = UDim.new(1, 0)}), mk("UIStroke", {Color = Color3.fromRGB(85, 170, 255), Thickness = 2})})
	local fu = fl:FindFirstChildOfClass("UIScale") or mk("UIScale", {Parent = fl})
	local hz, ht = se ~= nil, 0
	local tq = mk("Frame", {Parent = sg, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -12, 1, -12), Size = UDim2.new(0, 250, 1, -80), BackgroundTransparency = 1}, {mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8)})})
	local qs, act, tn = mk("UIScale", {Parent = tq}), {}, 0

	local function vs()
		local v = sg.AbsoluteSize
		if v.X < 1 then v = workspace.CurrentCamera.ViewportSize end
		return v, gs:GetGuiInset().Y
	end

	local function cl(p, z)
		local v, t = vs()
		local hx, hy = z.X / 2, z.Y / 2
		return Vector2.new(math.clamp(p.X, hx, math.max(hx, v.X - hx)), math.clamp(p.Y, t + hy, math.max(t + hy, v.Y - hy)))
	end

	local v0, t0 = vs()
	local wp, zm = Vector2.new(v0.X / 2, (v0.Y + t0) / 2), nil
	local function put()
		wp = cl(wp, Vector2.new(ww + 24, wh + 36) * us.Scale)
		w.Position = UDim2.fromOffset(wp.X, wp.Y)
	end

	local function zs()
		local v, t = vs()
		return zm or math.clamp(math.min((v.X - 24) / (ww + 24), (v.Y - t - 24) / (wh + 36), 1.2), 0.5, 1.2)
	end

	local function fit()
		us.Scale = zs()
		qs.Scale = us.Scale
		put()
	end

	local function toast(q)
		tn += 1
		local o = #act >= 4 and table.remove(act, 1)
		if o then o:Destroy() end
		local h = mk("Frame", {Parent = tq, LayoutOrder = tn, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
		local k = mk("Frame", {Parent = h, Position = UDim2.fromOffset(270, 0), Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
		local pf = pn(k, 0.12)
		mk("Frame", {Parent = pf, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(0, 3, 1, -18), BackgroundColor3 = q.Err and c.er or c.bl, BorderSizePixel = 0, ZIndex = 6}, {rc(2)})
		local x = mk("Frame", {Parent = k, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2}, {pd(20, 12, 10), mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)})})
		local function rz() pf.Size = UDim2.new(1, 0, 0, x.AbsoluteSize.Y / math.max(qs.Scale, 0.01)) end
		x:GetPropertyChangedSignal("AbsoluteSize"):Connect(rz)
		rz()
		hg(mk("TextLabel", {Parent = x, LayoutOrder = 1, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, FontFace = fi, TextSize = 15, TextColor3 = c.wh, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = q.Title}, {mk("UIStroke", {Color = c.sk, Thickness = 1.2})}))
		if q.Text ~= "" then mk("TextLabel", {Parent = x, LayoutOrder = 2, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, FontFace = ff, TextSize = 13, TextColor3 = c.tx, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = q.Text}, {mk("UIStroke", {Color = c.sk, Thickness = 1})}) end
		table.insert(act, h)
		tws:Create(k, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new()}):Play()
		task.delay(q.Time, function()
			local i = table.find(act, h)
			if not i then return end
			table.remove(act, i)
			local tw = tws:Create(k, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.fromOffset(270, 0)})
			tw:Play()
			tw.Completed:Wait()
			h:Destroy()
		end)
	end

	local function ef(e)
		toast({Title = "Callback Failed", Text = e, Time = 6, Err = true})
	end

	local cf, dt, pv = o.Config and `Moshub/Configs/{o.Config}.json`, {}, false
	if cf then
		local ok, r = pcall(function() return isfile(cf) and hs:JSONDecode(readfile(cf)) or {} end)
		if ok and type(r) == "table" then
			dt = r
		else
			pcall(function() writefile(`{cf}.bad`, readfile(cf)) end)
			toast({Title = "Config Load Failed", Text = "Invalid Json", Time = 6, Err = true})
		end
	end

	local function wr()
		if not pv then return end
		pv = false
		local ok, e = pcall(function()
			if not isfolder("Moshub") then makefolder("Moshub") end
			local fp = "Moshub/Configs"
			if not isfolder(fp) then makefolder(fp) end
			for x in o.Config:gmatch("([^/]+)/") do
				fp ..= `/{x}`
				if not isfolder(fp) then makefolder(fp) end
			end
			writefile(cf, hs:JSONEncode(dt))
		end)
		if not ok then toast({Title = "Config Save Failed", Text = tostring(e), Time = 6, Err = true}) end
	end

	local function sf(f, v, e)
		if f == nil then return end
		L.Flags[f] = v
		if not cf then return end
		if e == nil then dt[f] = v else dt[f] = e end
		if pv then return end
		pv = true
		task.delay(0.5, wr)
	end

	local function lv(f)
		if f == nil then return nil end
		return dt[f]
	end
	local zv = tonumber(lv("_z"))
	zm = zv and math.clamp(zv, 0.5, 10) or nil

	local function tg()
		w.Visible = not w.Visible
	end

	fit()
	local function hp()
		if hz and not (hu and hu.Parent and hu:IsDescendantOf(game)) and os.clock() - ht > 1 then
			ht = os.clock()
			local ok, b = pcall(function() return ps.LocalPlayer.PlayerGui.HUD.Frame.Buttons end)
			hu = ok and b or nil
			hb = hu and hu:FindFirstAncestorOfClass("ScreenGui")
		end
		local s, i = hz and hu and hu:FindFirstChild("Settings"), hz and hu and hu:FindFirstChild("Index")
		if s and i and hb then
			local u, g = s:FindFirstChildOfClass("UIScale"), sh.AbsolutePosition
			local z, c1 = s.AbsoluteSize / math.max(u and u.Scale or 1, 0.01), s.AbsolutePosition + s.AbsoluteSize / 2
			local p = c1 * 2 - (i.AbsolutePosition + i.AbsoluteSize / 2) - z / 2 - g
			fl.Size, fl.Position = UDim2.fromOffset(z.X, z.Y), UDim2.fromOffset(p.X, p.Y)
			fl.Visible = hb.Enabled and hu.Parent.Visible and hu.Visible and s.Visible
		else
			fl.Size, fl.Position, fl.Visible = UDim2.fromOffset(46, 46), UDim2.fromOffset(16, select(2, vs()) + 8), true
		end
	end
	hp()
	table.insert(cs, rs.RenderStepped:Connect(hp))
	table.insert(cs, sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local v, t = vs()
		wp = Vector2.new(v.X / 2, (v.Y + t) / 2)
		fit()
	end))
	local w0
	for _, h in {tp, bn} do
		dg(h, cs, function() w0 = wp end, function(d)
			wp = w0 + d
			put()
		end)
	end
	local z0, s0
	dg(gz, cs, function()
		z0, s0 = us.Scale, Vector2.new(ww, wh) * us.Scale
	end, function(d)
		zm = math.clamp(z0 * (1 + (d.X / s0.X + d.Y / s0.Y) / 2), 0.5, 10)
		us.Scale = zs()
		qs.Scale = us.Scale
		put()
	end, function() sf("_z", zm) end)
	local fm, fv = fl:FindFirstChild("Image"), false
	local fk = fm and fm:FindFirstChild("Icon")
	local function fa(x, ro)
		tws:Create(fu, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Scale = x}):Play()
		if fk and ro then tws:Create(fk, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Rotation = ro}):Play() end
	end
	table.insert(cs, fl.MouseEnter:Connect(function()
		fv = true
		fa(1.05, 5)
	end))
	table.insert(cs, fl.MouseLeave:Connect(function()
		fv = false
		fa(1, 0)
	end))
	table.insert(cs, fl.MouseButton1Down:Connect(function() fa(0.9) end))
	table.insert(cs, fl.MouseButton1Up:Connect(function() fa(fv and 1.05 or 1) end))
	table.insert(cs, fl.Activated:Connect(tg))
	table.insert(cs, nb.Activated:Connect(function() w.Visible = false end))
	local xa, xn = false, 0
	local function xs(a)
		xa = a
		tws:Create(xu, TweenInfo.new(0.12), {Scale = a and 1.2 or 1}):Play()
	end

	table.insert(cs, xb.Activated:Connect(function()
		if xa then
			(W :: any):Destroy()
			return
		end
		xn += 1
		local n = xn
		xs(true)
		task.delay(3, function()
			if xa and xn == n then xs(false) end
		end)
	end))
	table.insert(cs, uis.InputBegan:Connect(function(i)
		if key and i.KeyCode == key and not uis:GetFocusedTextBox() then tg() end
	end))

	local function sel(T)
		hd.Text = T.nm
		for _, x in tb do
			local on = x == T
			x.cg.Visible = on
			tws:Create(x.bt, TweenInfo.new(0.15), {BackgroundColor3 = on and c.bl or c.bk, BackgroundTransparency = on and 0.2 or 0.5}):Play()
			x.sk.Transparency = on and 0 or 1
		end
	end

	local function ox()
		local x = ov
		ov = nil
		if not x then return end
		x.f:Destroy()
		if x.cb then x.cb() end
	end

	local function oo(nm, ls, has, pick, cb)
		ox()
		local f = mk("TextButton", {Parent = w, Size = UDim2.fromScale(1, 1), BackgroundColor3 = c.bk, BackgroundTransparency = 0.45, AutoButtonColor = false, Text = "", ZIndex = 20})
		f.Activated:Connect(ox)
		local p = mk("Frame", {Parent = f, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.53), Size = UDim2.new(1, -60, 1, -56), BackgroundTransparency = 1, Active = true})
		pn(p, 0.2)
		local t = hg(tl(p, 17, nm, fi))
		t.Position, t.Size, t.ZIndex = UDim2.fromOffset(14, 6), UDim2.new(1, -60, 0, 26), 2
		local x = fb(mk("ImageButton", {Parent = p, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(28, 31), BackgroundColor3 = c.er, BackgroundTransparency = 1, AutoButtonColor = false, Image = A.cl, ScaleType = Enum.ScaleType.Fit, ZIndex = 3}), "cl")
		x.Activated:Connect(ox)
		local y, sb = 36, nil
		if #ls > 8 then
			local bx = mk("Frame", {Parent = p, Position = UDim2.fromOffset(12, 36), Size = UDim2.new(1, -24, 0, 30), BackgroundColor3 = c.bk, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 2})
			im(bx, A.ib, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(80, 80, 432, 432), SliceScale = 0.15, ZIndex = 3})
			sb = mk("TextBox", {Parent = bx, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, ClearTextOnFocus = false, FontFace = ff, TextSize = 14, TextColor3 = c.wh, PlaceholderColor3 = Color3.fromRGB(128, 128, 128), PlaceholderText = "SEARCH", TextXAlignment = Enum.TextXAlignment.Left, Text = "", ZIndex = 4})
			y = 72
		end
		local cv = mk("CanvasGroup", {Parent = p, Position = UDim2.fromOffset(12, y), Size = UDim2.new(1, -24, 1, -y - 10), BackgroundTransparency = 1, ZIndex = 2})
		local fg = mk("UIGradient", {Parent = cv, Rotation = 90})
		local sc = mk("ScrollingFrame", {Parent = cv, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = c.bl, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, {mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3)}), pd(0, 6, 0, 0)})
		local function fe()
			local q = sc.CanvasPosition.Y
			local u, d = q > 1, q < sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y - 1
			fg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, u and 1 or 0), NumberSequenceKeypoint.new(0.1, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, d and 1 or 0)})
		end
		for _, n in {"CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize"} do sc:GetPropertyChangedSignal(n):Connect(fe) end
		fe()
		local bs = {}
		for i, s in ls do
			local b = mk("TextButton", {Parent = sc, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = c.bl, BackgroundTransparency = 1, BorderSizePixel = 0, AutoButtonColor = false, Text = ""}, {rc(6)})
			local l = tl(b, 14, s)
			l.Position, l.Size = UDim2.fromOffset(10, 0), UDim2.new(1, -40, 1, 0)
			local k = mk("Frame", {Parent = b, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = c.gn, BackgroundTransparency = 1, BorderSizePixel = 0}, {rc(4), mk("UIStroke", {Color = c.wh, Thickness = 1.2})})
			bs[s] = {b, k}
			b.Activated:Connect(function()
				if pick(s) then ox() end
			end)
		end
		local function rf()
			for s, z in bs do
				local on = has(s)
				z[1].BackgroundTransparency, z[2].BackgroundTransparency = on and 0.55 or 1, on and 0 or 1
			end
		end
		if sb then
			sb:GetPropertyChangedSignal("Text"):Connect(function()
				local q = sb.Text:lower()
				for s, z in bs do z[1].Visible = q == "" or s:lower():find(q, 1, true) ~= nil end
			end)
		end
		rf()
		ov = {f = f, cb = cb}
		return rf
	end

	function W:Tab(q)
		if type(q) ~= "table" or type(q.Name) ~= "string" then error("Tab Failed: No Name") end
		if q.Icon ~= nil and type(q.Icon) ~= "string" then error("Tab Failed: Bad Icon") end
		if q.IconRect ~= nil and (type(q.IconRect) ~= "table" or #q.IconRect ~= 4) then error("Tab Failed: Bad Icon Rect") end
		local T, n = {nm = q.Name}, 0
		T.bt = mk("TextButton", {Parent = bar, LayoutOrder = #tb + 1, Size = UDim2.fromOffset(34, 34), BackgroundColor3 = c.bk, BackgroundTransparency = 0.5, BorderSizePixel = 0, AutoButtonColor = false, Text = ""}, {rc(10)})
		T.sk = mk("UIStroke", {Parent = T.bt, Color = c.wh, Thickness = 1.5, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
		if q.Icon then
			local x = im(T.bt, q.Icon, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(26, 26), ScaleType = Enum.ScaleType.Fit})
			if q.IconRect then x.ImageRectOffset, x.ImageRectSize = Vector2.new(q.IconRect[1], q.IconRect[2]), Vector2.new(q.IconRect[3], q.IconRect[4]) end
		else
			tl(T.bt, 18, q.Name:sub(1, 1), fi).TextXAlignment = Enum.TextXAlignment.Center
		end
		T.cg = mk("CanvasGroup", {Parent = bd, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
		local fg = mk("UIGradient", {Parent = T.cg, Rotation = 90})
		T.pg = mk("ScrollingFrame", {Parent = T.cg, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = c.bl, ScrollingDirection = Enum.ScrollingDirection.Y, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, {pd(0, 8, 2, 6), mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})})
		local function fe()
			local y = T.pg.CanvasPosition.Y
			local a, z = y > 1, y < T.pg.AbsoluteCanvasSize.Y - T.pg.AbsoluteWindowSize.Y - 1
			fg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, a and 1 or 0), NumberSequenceKeypoint.new(0.1, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, z and 1 or 0)})
		end
		for _, p in {"CanvasPosition", "AbsoluteCanvasSize", "AbsoluteWindowSize"} do table.insert(cs, T.pg:GetPropertyChangedSignal(p):Connect(fe)) end
		fe()
		table.insert(tb, T)
		table.insert(cs, T.bt.Activated:Connect(function() sel(T) end))
		if #tb == 1 then sel(T) end

		local function od()
			n += 1
			return n
		end

		local function row(k, h)
			local r = mk(k, {Parent = T.pg, LayoutOrder = od(), Size = UDim2.new(1, 0, 0, h or 38), BackgroundColor3 = c.bk, BorderSizePixel = 0})
			if r:IsA("TextButton") then r.AutoButtonColor, r.Text = false, "" end
			mk("UIGradient", {Parent = r, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.4), NumberSequenceKeypoint.new(0.9, 0.4), NumberSequenceKeypoint.new(1, 1)})})
			return r
		end

		local function lb(p, s, wd)
			local x = tl(p, 15, s, ff, Color3.fromHex("303030"))
			x.Position, x.Size = UDim2.fromOffset(14, 0), UDim2.new(1, -14 - wd, 1, 0)
			gr(x, {"d9daff", "55ffff", "4f87ff", "55aaff"})
			return x
		end

		function T:Section(q)
			if type(q) ~= "table" or type(q.Name) ~= "string" then error("Section Failed: No Name") end
			local r = mk("Frame", {Parent = T.pg, LayoutOrder = od(), Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1})
			gr(im(r, A.dv, {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0.9, 0, 0, 5), ScaleType = Enum.ScaleType.Stretch}), {"fdffff", "f7fafa", "929294", "dfe1e1", "fdffff"}, 0)
			local x = tl(r, 18, q.Name, fi)
			x.TextXAlignment, x.TextTruncate, x.ZIndex = Enum.TextXAlignment.Center, Enum.TextTruncate.None, 2
			return {Set = function(_, s) x.Text = tostring(s) end, Get = function() return x.Text end}
		end

		function T:Label(q)
			if type(q) ~= "table" or q.Text == nil then error("Label Failed: No Text") end
			local r = row("Frame")
			r.AutomaticSize = Enum.AutomaticSize.Y
			local x = mk("TextLabel", {Parent = r, Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, FontFace = ff, TextSize = 14, TextColor3 = c.tx, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Text = tostring(q.Text)}, {pd(14, 14, 9), mk("UIStroke", {Color = c.sk, Thickness = 1})})
			return {Set = function(_, s) x.Text = tostring(s) end, Get = function() return x.Text end}
		end

		function T:Button(q)
			if type(q) ~= "table" or type(q.Name) ~= "string" then error("Button Failed: No Name") end
			local r = row("TextButton")
			local x = lb(r, q.Name, 96)
			local g = fb(mk("ImageButton", {Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(78, 26), BackgroundColor3 = c.gn, BackgroundTransparency = 1, AutoButtonColor = false, Image = A.gb, ScaleType = Enum.ScaleType.Fit}, {rc(6)}), "gb")
			gr(g, {"00f900", "76ff4d"})
			hg(tl(g, 14, "Run", fi)).TextXAlignment = Enum.TextXAlignment.Center
			local u = mk("UIScale", {Parent = g})
			local function go()
				u.Scale = 0.9
				tws:Create(u, TweenInfo.new(0.2), {Scale = 1}):Play()
				fire(q.Callback)
			end
			table.insert(cs, r.Activated:Connect(go))
			table.insert(cs, g.Activated:Connect(go))
			return {Set = function(_, s) x.Text = tostring(s) end, Get = function() return x.Text end}
		end

		function T:Toggle(q)
			ck(q, "Toggle")
			local r, v = row("TextButton"), nil
			lb(r, q.Name, 70)
			local k = mk("Frame", {Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(54, 24), BackgroundColor3 = c.bl, BorderSizePixel = 0}, {rc(12)})
			rc(12).Parent = im(k, A.tb, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(7, 7), ImageColor3 = c.bk, ImageTransparency = 0.85})
			local d = mk("Frame", {Parent = k, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0.05, 0.5), Size = UDim2.fromScale(0.45, 0.8), BackgroundColor3 = c.kf, BorderSizePixel = 0}, {rc(10), mk("UIStroke", {Color = c.bk, Thickness = 1.5})})
			rc(10).Parent = im(d, A.kp, {Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, ImageColor3 = c.bk, ImageTransparency = 0.5})
			local function set(x, cb)
				x = x == true
				if x == v then return end
				v = x
				sf(q.Flag, v)
				tws:Create(d, TweenInfo.new(0.15), {Position = UDim2.fromScale(v and 0.5 or 0.05, 0.5), BackgroundColor3 = v and c.gn or c.kf}):Play()
				if cb then fire(q.Callback, v) end
			end

			local sv = lv(q.Flag)
			set(q.Default)
			if type(sv) == "boolean" then
				set(sv)
				task.defer(fire, q.Callback, v)
			end
			table.insert(cs, r.Activated:Connect(function() set(not v, true) end))
			return {Set = function(_, x) set(x, true) end, Get = function() return v end}
		end

		function T:Dropdown(q)
			ck(q, "Dropdown")
			local mu, v, rd, rf = q.Multi == true, nil, false, nil
			local function po(o, k)
				if type(o) ~= "table" then error(`{k} Failed: Bad Options`) end
				local t = {}
				for _, s in o do
					if type(s) ~= "string" then error(`{k} Failed: Bad Options`) end
					if not table.find(t, s) then table.insert(t, s) end
				end
				return t
			end

			local op = po(q.Options or {}, "Dropdown")
			local r = row("TextButton")
			lb(r, q.Name, 160)
			local vl = tl(r, 13, "")
			vl.AnchorPoint, vl.Position, vl.Size, vl.TextXAlignment, vl.TextColor3 = Vector2.new(1, 0.5), UDim2.new(1, -30, 0.5, 0), UDim2.fromOffset(140, 20), Enum.TextXAlignment.Right, c.dm
			local cv = mk("Frame", {Parent = r, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(12, 6), BackgroundTransparency = 1})
			mk("Frame", {Parent = cv, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(8, 2), Rotation = 45, BackgroundColor3 = c.bl, BorderSizePixel = 0})
			mk("Frame", {Parent = cv, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(9, 3), Size = UDim2.fromOffset(8, 2), Rotation = -45, BackgroundColor3 = c.bl, BorderSizePixel = 0})

			local function has(x)
				return mu and table.find(v, x) ~= nil or v == x
			end

			local function draw()
				vl.Text = mu and (#v > 0 and table.concat(v, ", ") or "None") or v or "None"
				if rf then rf() end
			end

			local function nv(x)
				if not mu then return table.find(op, x) and x or nil end
				local o = {}
				if type(x) == "table" then
					for _, s in op do
						if table.find(x, s) then table.insert(o, s) end
					end
				end
				return o
			end

			local function same(a, b)
				if not mu then return a == b end
				if #a ~= #b then return false end
				for i = 1, #a do
					if a[i] ~= b[i] then return false end
				end
				return true
			end

			local function set(x, cb)
				x = nv(x)
				if rd and same(x, v) then return end
				rd, v = true, x
				sf(q.Flag, mu and table.clone(v) or v, mu and table.clone(v) or v or false)
				draw()
				if cb then fire(q.Callback, mu and table.clone(v) or v) end
			end

			local sv = lv(q.Flag)
			set(q.Default)
			if mu and type(sv) == "table" or not mu and (sv == false or type(sv) == "string") then
				set(sv or nil)
				task.defer(fire, q.Callback, mu and table.clone(v) or v)
			end
			table.insert(cs, r.Activated:Connect(function()
				rf = oo(q.Name, op, has, function(x)
					if not mu then
						set(x, true)
						return true
					end
					local n = table.clone(v)
					local j = table.find(n, x)
					if j then table.remove(n, j) else table.insert(n, x) end
					set(n, true)
					return false
				end, function() rf = nil end)
			end))
			return {Set = function(_, x)
				if mu and type(x) ~= "table" then error("Dropdown Set Failed: Not A Table") end
				if not mu and x ~= nil and not table.find(op, x) then error("Dropdown Set Failed: Unknown Option") end
				set(x, true)
			end, Get = function() return mu and table.clone(v) or v end, Refresh = function(_, o)
				op = po(o, "Dropdown Refresh")
				if rf then ox() end
				set(v, true)
				draw()
			end}
		end

		return T
	end

	function W:Notify(q)
		if type(q) ~= "table" or (q.Title == nil and q.Text == nil) then error("Notify Failed: No Text") end
		if q.Time ~= nil and (type(q.Time) ~= "number" or not (q.Time > 0)) then error("Notify Failed: Bad Time") end
		toast({Title = tostring(q.Title or "MOS HUB"), Text = q.Text == nil and "" or tostring(q.Text), Time = q.Time or 4})
	end

	function W:Destroy()
		for _, x in cs do x:Disconnect() end
		table.clear(cs)
		table.clear(act)
		wr()
		sh:Destroy()
		sg:Destroy()
		if tf == ef then tf = nil end
		if ge.__AvW == W then ge.__AvW = nil end
	end

	tf, ge.__AvW = ef, W
	return W
end

L.Sk = {bt = bt, mk = mk, rc = rc, gr = gr, fb = fb, tl = tl, hg = hg, im = im, pn = pn, A = A, c = c, ff = ff, fi = fi}

return L
end)()

local ge = getgenv()
local gw = L:Window({Title = "MOS HUB-V2 tiktok@noelnoathebest02", Config = `FishingMaster/{lp.Name}`})
local gt, ft = gw:Tab({Name = "General", Icon = "rbxassetid://135753849387222"}), nil

local function cx(fn, ...)
	local r, dn
	task.spawn(function(...) r = table.pack(pcall(fn, ...)); dn = true end, ...)
	repeat task.wait() until dn
	return table.unpack(r, 1, r.n)
end

local function fb(f)
	local s, fc = f.s, rv.FishingController
	for n, cb in {
		FishWaitingAck = function() s.wa = true end,
		FishFirstPullStart = function(id, _, _, lm, st) s.fp, s.id = {lm, st}, id end,
		FishFirstPullResult = function(m) s.pm = m end,
		FishReelStartAck = function(id) s.rl, s.id = true, s.id or id end,
		FishQTEPrompt = function(d) s.q = {d, os.clock() + 0.2 + math.random() * 0.15} end,
		FishQTECancel = function() s.q = nil end,
		FishSkillWindow = function(w) s.sw = os.clock() + w end,
		FishBossStun = function(w) s.bs = os.clock() + w end,
		FishCatchResult = function(ok, _, _, _, _, sp) s.cr = {ok, sp} end,
		FishReset = function(r) s.rr = r end,
	} do table.insert(f.cs, fc[n].OnClientEvent:Connect(cb)) end
	table.insert(f.cs, rv.BossRegionController.BossSpawnClaimed.OnClientEvent:Connect(function(v) s.bc = v == true end))
	table.insert(f.cs, md("Data", "Packets", "DailyQuestPackets").Completed.OnClientEvent:Connect(function(g, c)
		if f.dq() then f.nq = {Title = "Daily Quest", Text = `Daily Quest Done: +{g} Gem, +{c} Coin`} end
	end))
	table.insert(f.cs, rv.RodController.ReplicatedSkillCooldown.OnClientEvent:Connect(function(t)
		if typeof(t) ~= "table" then return end
		for k, v in t do
			if type(v) == "table" and type(v.phase) == "string" then s.cd[k] = {v.phase, os.clock() + (tonumber(v.remaining) or 0)} end
		end
	end))
	local ok, e = pcall(rn, f)
	for _, c in f.cs do c:Disconnect() end
	if cj then cj:Stop() end
	if not ok then error(e, 0) end
end

local function fs()
	local o = ge.__FmF
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local so = ge.__FmS
	if so and so.busy then
		local dl = os.clock() + 30
		repeat task.wait(0.1) until not so.busy or os.clock() > dl
	end
	local f = {st = "Running", s = {cd = {}, sw = 0, bs = 0}, cs = {}, c = 0, rp = true, dn = false, bu = false, qx = {}, qw = {}, nq = false}
	function f.ao() return L.Flags.as == true end
	function f.au() return L.Flags.au == true end
	function f.qa() return L.Flags.qa == true end
	function f.qs() return qm[L.Flags.qs] end
	function f.ya() return L.Flags.ya == true end
	function f.ys() return L.Flags.ys or {} end
	function f.kp()
		local k = f.au() and qv(qn(f)) or {}
		for u in f.qa() and qv(qp(f)) or {} do k[u] = true end
		local d = pd()
		local cq = (d.Quest or {}).Current or {}
		for _, q in f.ya() and qk(d, f.ys()) or {} do
			for u in select(2, qc(q, d, cq.Id == q[1] and cq.Progress or {RequiredFish = 3})) do k[u] = true end
		end
		return k
	end
	function f.sr() return L.Flags.sr or {} end
	function f.wk() return L.Flags.ss == "Walk To Seller" end
	function f.fi() return ix[L.Flags.fi] end
	function f.ab() return L.Flags.ab == true end
	function f.dq() return L.Flags.dq == true end
	function f.bk() return bi[L.Flags.sb] or "truck" end
	function f.iw()
		local j, id, g, b, t, u = ge.__FmI, ix[L.Flags.si], ge.__FmG, ge.__FmR, ge.__FmT, ge.__FmU
		return g and not g.dn and (g.bz or g.rq and not f.bu) or b and not b.dn and (b.bz or b.rq and not f.bu) or j and not j.dn and (j.bz or id and ic() ~= id) or t and not t.dn and t.bz or u and not u.dn and (u.bz or u.rq and not f.bu) or false
	end
	ge.__FmF = f
	task.spawn(function()
		while not f.dn do
			local x = f.nq
			if x then
				f.nq = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(fb, f)
	if not ok then f.why = `Auto Fish Failed: {e}` end
	f.dn = true
	if ge.__FmF ~= f or not f.why then return end
	gw:Notify({Title = "Auto Fish", Text = f.why})
	ft:Set(false)
end

local function sls()
	local o = ge.__FmS
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 30
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local f = {st = "Running", dn = false, busy = false, rp = false, bu = false, qx = {}, qw = {}, nq = false}
	function f.wk() return L.Flags.ss == "Walk To Seller" end
	function f.au() return L.Flags.au == true end
	function f.qa() return L.Flags.qa == true end
	function f.qs() return qm[L.Flags.qs] end
	function f.ya() return L.Flags.ya == true end
	function f.ys() return L.Flags.ys or {} end
	function f.sr() return L.Flags.sr or {} end
	function f.kp()
		local k = f.au() and qv(qn(f)) or {}
		for u in f.qa() and qv(qp(f)) or {} do k[u] = true end
		local d = pd()
		local cq = (d.Quest or {}).Current or {}
		for _, q in f.ya() and qk(d, f.ys()) or {} do
			for u in select(2, qc(q, d, cq.Id == q[1] and cq.Progress or {RequiredFish = 3})) do k[u] = true end
		end
		return k
	end
	ge.__FmS = f
	while f.st == "Running" do
		local fm = ge.__FmF
		local fishing = fm and not fm.dn and fm.st == "Running"
		local ok, full = pcall(fl)
		if not fishing and ok and full and lc() then
			f.busy = true
			local ok2, hd, sf = cx(tr, f)
			f.busy = false
			local why = not ok2 and tostring(hd) or hd or sf
			if why and f.st == "Running" then
				gw:Notify({Title = "Auto Sell", Text = tostring(why):gsub("^Auto Fish Failed: ", "")})
				task.wait(10)
			end
		end
		task.wait(1)
	end
	f.dn = true
end

local function ib(j)
	local n = 0
	while j.st == "Running" do
		local id, fm = ix[L.Flags.si], ge.__FmF
		if not id then j.why = "Auto Island Failed: No Island Selected"; return end
		if ic() == id then j.ar = true; return end
		if not (fm and not fm.dn and fm.bz or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz) then
			j.bz = true
			local ok, e = ti(j, id, bi[L.Flags.sb] or "truck")
			j.bz = false
			if ok then j.ar = true; return end
			n = j.st == "Running" and n + 1 or n
			if n >= 3 then j.why = `Auto Island Failed: {e}`; return end
		end
		task.wait(1)
	end
end

local it
local function is()
	local o = ge.__FmI
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", ar = false}
	ge.__FmI = j
	local ok, e = cx(ib, j)
	if not ok then j.why = `Auto Island Failed: {e}` end
	j.dn = true
	if ge.__FmI ~= j or not (j.why or j.ar) then return end
	if j.why then gw:Notify({Title = "Auto Island", Text = j.why}) end
	it:Set(false)
end

local nz, nl, nj = {
	{"Fish Merchant - Starter Island", "npc_fish_seller", "island_starter"},
	{"Rod Merchant - Starter Island", "npc_rod_shop", "island_starter"},
	{"Boat Merchant - Starter Island", "npc_car_merchant", "island_starter"},
	{"Skill Master", "npc_gacha_book", "island_starter"},
	{"Auras Dealer", "npc_gacha_aura", "island_starter"},
	{"Unit Summoner", "npc_gacha_unit", "island_starter"},
	{"Skill Market", "npc_premium_skill", "island_starter"},
	{"Daily Quests - Starter Island", "npc_daily_quest", "island_starter"},
	{"Jungle Island Guide", "npc_unlock_island_2", "island_jungle"},
	{"Fish Merchant - Jungle Island", "npc_fish_seller", "island_jungle"},
	{"Rod Merchant - Jungle Island", "npc_rod_shop", "island_jungle"},
	{"Boat Merchant - Jungle Island", "npc_car_merchant", "island_jungle"},
	{"Daily Quests - Jungle Island", "npc_daily_quest", "island_jungle"},
	{"Desert Island Guide", "npc_unlock_island_3", "island_desert"},
	{"Fish Merchant - Desert Island", "npc_fish_seller", "island_desert"},
	{"Rod Merchant - Desert Island", "npc_rod_shop", "island_desert"},
	{"Boat Merchant - Desert Island", "npc_car_merchant", "island_desert"},
	{"Daily Quests - Desert Island", "npc_daily_quest", "island_desert"},
	{"White Tiger Guardian", "npc_white_tiger", "island_desert"},
	{"Snow Island Guide", "npc_unlock_island_4", "island_snow"},
	{"Fish Merchant - Snow Island", "npc_fish_seller", "island_snow"},
	{"Rod Merchant - Snow Island", "npc_rod_shop", "island_snow"},
	{"Boat Merchant - Snow Island", "npc_car_merchant", "island_snow"},
	{"Daily Quests - Snow Island", "npc_daily_quest", "island_snow"},
	{"Phoenix Guardian", "npc_phoenix", "island_snow"},
	{"Taiji Master", "npc_taiji_hooking_art_v2", "island_snow"},
	{"Volcanic Island Guide", "npc_unlock_island_5", "island_volcano"},
	{"Fish Merchant - Volcanic Island", "npc_fish_seller", "island_volcano"},
	{"Boat Merchant - Volcanic Island", "npc_car_merchant", "island_volcano"},
	{"Daily Quests - Volcanic Island", "npc_daily_quest", "island_volcano"},
	{"Crimson Bead Craftsman", "npc_crimson_bead_rod", "island_volcano"},
	{"Bamboo Rod Craftsman", "npc_bamboo_rod", "island_volcano"},
	{"Azure Dragon Guardian", "npc_azure_dragon", "island_volcano"},
	{"Fossil Island Guide", "npc_unlock_island_6", "island_fossil"},
	{"Fish Merchant - Fossil Island", "npc_fish_seller", "island_fossil"},
	{"Daily Quests - Fossil Island", "npc_daily_quest", "island_fossil"},
	{"Heaven Piercer Craftsman", "npc_heaven_piercer_turtle_rod", "island_fossil"},
	{"Zen Staff Craftsman", "npc_zen_staff_rod", "island_fossil"},
	{"Dread Fish Craftsman", "npc_dread_fish_rod", "island_fossil"},
	{"Supreme King Guardian", "npc_supreme_king", "island_fossil"},
}, {}, {}
for _, v in nz do
	table.insert(nl, v[1])
	nj[v[1]] = v
end

local function ne(v)
	local w = workspace:FindFirstChild("World")
	local fo = w and w:FindFirstChild("Islands") and w.Islands:FindFirstChild(v[3])
	if not fo then return nil end
	for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
		if x:GetAttribute("InteractiveId") == v[2] and x:IsDescendantOf(fo) then
			return x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position or nil
		end
	end
	return nil
end

local function nw(j)
	local v, n = nj[L.Flags.sv], 0
	if not v then j.why = "Teleport Failed: No NPC Selected"; return end
	while j.st == "Running" do
		local fm = ge.__FmF
		if not (fm and not fm.dn and fm.bz or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz) then
			j.bz = true
			local ok, e = ti(j, v[3], bi[L.Flags.sb] or "truck")
			local c, r = lc()
			local np = ok and r and ne(v)
			if ok and r and not np then
				local g = rg(v[3])
				sq(g and Vector3.new(g.X, 2, g.Z) or r.Position, 10)
				np = ne(v)
			end
			if ok and not r then ok, e = nil, "No Character" end
			if ok and not np then ok, e = nil, "NPC Not Found" end
			if ok and j.st == "Running" then
				local sp = ap(c, np, r.Position)
				ok, e = (v[2] == "npc_zen_staff_rod" and gf or go)(j, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
			end
			j.bz = false
			if ok and j.st == "Running" then j.ar = true; return end
			if e == "NPC Not Found" then j.why = `Teleport Failed: {e}`; return end
			n = j.st == "Running" and n + 1 or n
			if n >= 3 then j.why = `Teleport Failed: {e or "Move Failed"}`; return end
		end
		task.wait(1)
	end
end

local nk
local function ny()
	local o = ge.__FmT
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", ar = false}
	ge.__FmT = j
	local ok, e = cx(nw, j)
	if not ok then j.why = `Teleport Failed: {e}` end
	j.dn = true
	if ge.__FmT ~= j or not (j.why or j.ar) then return end
	if j.why then gw:Notify({Title = "Teleport", Text = j.why}) end
	nk:Set(false)
end

local ga, gm = {"Skill Master", "Ocean Chest", "Dragon Chest", "Aura", "Unit"}, {["Ocean Chest"] = "crate_ocean_chest", ["Dragon Chest"] = "crate_dragon_chest"}

local function gl(j)
	local sc = rv.SkillGachaController
	while j.st == "Running" do
		local k, cr = L.Flags.gr == "x10" and 10 or 1, gm[L.Flags.gk]
		local cc = cr and md("Data", "Config", "CrateConfig").GetCrate(cr)
		if cr and not cc then
			j.why = "Auto Roll Failed: No Chest"
			return
		end
		local ag, ut = L.Flags.gk == "Aura" and md("Data", "Config", "AuraGachaConfig").Pull, L.Flags.gk == "Unit" and rv.UnitGachaController
		local nm = cc and cc.DisplayName or ag and "Aura" or ut and "Unit" or "Skill Master"
		local function ca()
			local d = pd()
			if cc then return (((d.CrateGacha or {}).Credits or {})[cr] or 0) >= k or ((cc.Currency == "Coin" and d.Coin or d.Gem) or 0) >= (cc.Prices[k] or math.huge) end
			if ag then return ((d.AuraGacha or {}).Credits or 0) >= k or (d.Gem or 0) >= math.ceil(ag.CostGem * k * (ag.BulkDiscount[k] or 1)) end
			local q = (ut or sc).GetQuote:Fire(k)
			if type(q) ~= "table" or not q.ok then return nil, type(q) == "table" and q.reason or "No Quote" end
			if ut and (q.storage_available or 0) < k then return nil, "Storage Full" end
			return (d.Coin or 0) >= q.coin_cost
		end
		local af, ae = ca()
		if ae then
			j.why = `Auto Roll Failed: {ae}`
			return
		end
		if not af then
			task.wait(5)
			continue
		end
		local fm = ge.__FmF
		j.rq = true
		while j.st == "Running" and fm and not fm.dn and (fm.bz or fm.bu) do task.wait(0.5) end
		if j.st ~= "Running" then return end
		j.bz, j.rq = true, false
		local r
		while j.st == "Running" do
			local rc = ut or not (cc or ag) and sc
			if rc then rc._requestId = (tonumber(rc._requestId) or 0) + 1 end
			r = cc and rv.CrateGachaController.OpenPacket:Fire(cr, k) or ag and rv.AuraGachaController.Pull:Fire(k) or ut and ut.Pull:Fire(k, ut._requestId) or not (cc or ag or ut) and sc.Pull:Fire("Coin", k, sc._requestId)
			for _ = 1, ut and type(r) == "table" and r.reason == "pending" and 5 or 0 do
				task.wait(3)
				local x = ut.Recover:Fire(ut._requestId)
				if type(x) == "table" and x.reason ~= "pending" and x.reason ~= "none" then r = x; break end
			end
			if type(r) ~= "table" or not r.ok then break end
			local ct, t = md("Data", "Catalog"), {}
			for _, x in r.results or {} do
				local sv = cc and ct.RodSkin.GetById(x.rod_skin_id) or ag and ct.Aura.GetById(x.aura_id) or ut and ct.Unit.GetById(x.unit_id) or not (cc or ag or ut) and ct.Skill.GetById(x.skill_id)
				table.insert(t, `{sv and sv.name or x.rod_skin_id or x.aura_id or x.unit_id or x.skill_id} ({x.rarity})`)
			end
			j.nt = {Title = nm, Text = table.concat(t, ", ")}
			task.wait(1)
			if not ca() then break end
		end
		j.bz = false
		if j.st ~= "Running" then return end
		if type(r) ~= "table" then
			j.why = "Auto Roll Failed: No Response"
			return
		end
		if not r.ok and r.reason ~= "insufficient_coin" and r.reason ~= "insufficient_gem" then
			j.why = `Auto Roll Failed: {r.reason}`
			return
		end
		task.wait(1)
	end
end

local gs
local function gg()
	local o = ge.__FmG
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false, bz = false, rq = false}
	ge.__FmG = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(gl, j)
	if not ok then j.why = `Auto Roll Failed: {e}` end
	j.dn = true
	if ge.__FmG ~= j or not j.why then return end
	gw:Notify({Title = "Auto Roll", Text = j.why})
	gs:Set(false)
end

local mz, mi = {}, {}
pcall(function()
	local ct, t = md("Data", "Catalog"), {}
	for id, v in md("Data", "Config", "SkillMarketConfig").Listings do
		local x = ct.Skill.GetById(id)
		table.insert(t, {x and x.name or id, id, v.price or 0})
	end
	table.sort(t, function(a, b) return a[3] < b[3] or a[3] == b[3] and a[1] < b[1] end)
	for _, x in t do
		table.insert(mz, x[1])
		mi[x[1]] = x[2]
	end
end)

local function ml(j)
	local rp, mc = game:GetService("ReplicatedStorage"), rv.SkillMarketController
	local cf, ba, en, sx = md("Data", "Config", "SkillMarketConfig"), md("Utils", "skillBookAvailability"), md("Data", "Config", "EntitlementConfig"), {}
	while j.st == "Running" do
		local st, ea = rp:GetAttribute("SkillMarketStock"), rp:GetAttribute("SkillMarketEndsAt")
		local sl, kl = type(ea) == "number" and ea - cf.IntervalSeconds or 0, type(st) == "string" and st:split(",") or {}
		for _, nm in L.Flags.mm or {} do
			if j.st ~= "Running" then return end
			local id, d = mi[nm], pd()
			local sm = type(d.SkillMarket) == "table" and d.SkillMarket or {}
			if id and table.find(kl, id) and not sx[`{sl}{id}`] and not (sm.SlotStart == sl and (sm.Bought or {})[id]) and (d.Gem or 0) >= (cf.Price(id) or math.huge) and ba.GetCounts(d, id).owned < en.BookStackCap(d) then
				local r = mc.BuyDirect:Fire(id)
				if type(r) ~= "table" then
					j.why = "Auto Buy Skill Market Failed: No Response"
					return
				end
				if r.reason == "ok" then
					j.nt = {Title = "Skill Market", Text = `Bought {nm}`}
				elseif r.reason == "bought" or r.reason == "out_of_stock" or r.reason == "full" then
					sx[`{sl}{id}`] = true
				elseif r.reason ~= "insufficient" and r.reason ~= "busy" then
					j.why = `Auto Buy Skill Market Failed: {r.reason}`
					return
				end
				task.wait(1)
			end
		end
		task.wait(5)
	end
end

local function xu(j)
	local uc, uo, ct = rv.UnitController, md("Shared", "Units", "UnitCore"), md("Data", "Catalog")
	while j.st == "Running" do
		local d, rr, q = pd(), {}, {}
		for _, r in L.Flags.ur or {} do rr[r] = true end
		for id, u in type(d.Units) == "table" and type(d.Units.Owned) == "table" and d.Units.Owned or {} do
			if type(u) == "table" and rr[u.Rarity] and not uo.IsEquipped(d.Units, id) then table.insert(q, id) end
		end
		if #q > 0 then
			local fm = ge.__FmF
			j.rq = true
			while j.st == "Running" and fm and not fm.dn and (fm.bz or fm.bu) do task.wait(0.5) end
			if j.st ~= "Running" then return end
			j.bz, j.rq = true, false
			local t = {}
			for _, id in q do
				if j.st ~= "Running" then break end
				local u = (pd().Units.Owned or {})[id]
				if u and not uo.IsEquipped(pd().Units, id) then
					local ok, e = uc:RemoveUnit(id)
					if ok ~= true and e ~= "fishing_locked" then
						j.bz = false
						j.why = `Auto Delete Unit Failed: {e or "No Response"}`
						return
					end
					if ok ~= true then break end
					local x = ct.Unit.GetById(u.UnitId)
					table.insert(t, `{x and x.name or u.UnitId} ({u.Rarity})`)
					task.wait(0.5)
				end
			end
			j.bz = false
			if #t > 0 then j.nt = {Title = "Unit", Text = `Deleted {table.concat(t, ", ")}`} end
		end
		task.wait(5)
	end
end

local xk
local function xy()
	local o = ge.__FmU
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false, bz = false, rq = false}
	ge.__FmU = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(xu, j)
	if not ok then j.why = `Auto Delete Unit Failed: {e}` end
	j.dn = true
	if ge.__FmU ~= j or not j.why then return end
	gw:Notify({Title = "Unit", Text = j.why})
	xk:Set(false)
end

local mk
local function mg()
	local o = ge.__FmM
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, nt = false}
	ge.__FmM = j
	task.spawn(function()
		while not j.dn do
			local x = j.nt
			if x then
				j.nt = false
				gw:Notify(x)
			end
			task.wait(0.5)
		end
	end)
	local ok, e = cx(ml, j)
	if not ok then j.why = `Auto Buy Skill Market Failed: {e}` end
	j.dn = true
	if ge.__FmM ~= j or not j.why then return end
	gw:Notify({Title = "Skill Market", Text = j.why})
	mk:Set(false)
end

local rz, ri = {}, {}
for _, x in {{"Stone Rod", "stone_rod"}, {"Iron Rod", "iron_rod"}, {"Golden Rod", "golden_rod"}, {"Steel Rod", "steel_rod"}, {"Golden Steel Rod", "golden_steel_rod"}, {"Diamond Steel Rod", "diamond_steel_rod"}, {"Taoist Rod", "taoist_rod"}, {"Legacy Rod", "legacy_rod"}} do
	table.insert(rz, x[1])
	ri[x[1]] = x[2]
end

local function rm(id)
	for k = 1, 2 do
		for _, x in game:GetService("CollectionService"):GetTagged("Interactive") do
			if x:GetAttribute("InteractiveId") == "npc_rod_shop" and x:GetAttribute("IslandId") == id then
				local q = x:IsA("Model") and x:GetPivot().Position or x:IsA("BasePart") and x.Position
				if q then return q end
			end
		end
		local g = k == 1 and rg(id)
		if g then sq(Vector3.new(g.X, 2, g.Z), 10) end
	end
	return nil
end

local function ru(j, id, il)
	local ok, e = ti(j, il, bi[L.Flags.sb] or "truck")
	if not ok then return nil, e or j.st == "Running" and "Move Failed" or nil end
	local c, rt = lc()
	if not rt then return nil, "No Character" end
	local np = rm(il)
	if not np then return nil, "No Rod Merchant" end
	local sp = ap(c, np, rt.Position)
	ok, e = go(j, sp, Vector3.new(np.X - sp.X, 0, np.Z - sp.Z).Unit)
	if not ok then return nil, e or j.st == "Running" and "Move Failed" or nil end
	if j.st ~= "Running" then return nil end
	local r = rv.FishingRodShopController.PurchaseRod:Fire(id)
	if r == nil then return nil, "No Response" end
	if r ~= true then return nil, "Purchase Refused" end
	j.by = true
	if rv.EquipmentsController.EquipmentEquip:Fire("rod", id) ~= true then return nil, "Equip Refused" end
	local dl = os.clock() + 5
	repeat task.wait(0.1) until pd().RodEquip == id or os.clock() > dl
	if pd().RodEquip ~= id then return nil, "Equip Timeout" end
	return true
end

local function rj(j)
	local nm = L.Flags.rd
	local id = ri[nm]
	if not id then j.why = "Auto Buy Rod Failed: No Rod Selected"; return end
	local cf = md("Data", "Config", "RodShopConfig")[id]
	if not cf then j.why = "Auto Buy Rod Failed: No Price"; return end
	while j.st == "Running" do
		local d = pd()
		if d.Rods and d.Rods[id] then j.why = "Auto Buy Rod Failed: Already Owned"; return end
		if not ul(cf.islandId) then j.why = "Auto Buy Rod Failed: Island Locked"; return end
		if (d.Coin or 0) < cf.price then
			task.wait(5)
			continue
		end
		local fm = ge.__FmF
		j.rq = true
		while j.st == "Running" and (fm and not fm.dn and (fm.bz or fm.bu) or ge.__FmG and not ge.__FmG.dn and ge.__FmG.bz or ge.__FmI and not ge.__FmI.dn or ge.__FmT and not ge.__FmT.dn) do task.wait(0.5) end
		if j.st ~= "Running" then return end
		j.bz, j.rq = true, false
		local _, rt = lc()
		if not rt then j.why = "Auto Buy Rod Failed: No Character"; return end
		local o, oi = rt.CFrame, ic()
		local ok, e = ru(j, id, cf.islandId)
		local hk, he = true, nil
		if j.st == "Running" and oi ~= "" and ic() ~= oi then hk, he = ti(j, oi, bi[L.Flags.sb] or "truck") end
		if hk and j.st == "Running" and ic() == oi then hk, he = go(j, o.Position, Vector3.new(o.LookVector.X, 0, o.LookVector.Z).Unit) end
		j.bz = false
		if j.st ~= "Running" then return end
		local t = ok and `Bought {nm}` or j.by and `Bought {nm}, {e}` or `Auto Buy Rod Failed: {e}`
		j.why = hk and t or `{t}, Return Failed: {he or "Move Failed"}`
		return
	end
end

local rk
local function rh()
	local o = ge.__FmR
	if o then
		o.st = "Stopped"
		local dl = os.clock() + 5
		repeat task.wait(0.1) until o.dn or os.clock() > dl
	end
	local j = {st = "Running", dn = false, bz = false, rq = false, by = false}
	ge.__FmR = j
	local ok, e = cx(rj, j)
	if not ok then j.why = `Auto Buy Rod Failed: {e}` end
	j.dn = true
	if ge.__FmR ~= j or not j.why then return end
	gw:Notify({Title = "Rod Merchant", Text = j.why})
	rk:Set(false)
end

gt:Section({Name = "Farm"})
do
	local bl, tk = gt:Label({Text = "Next Boss: --"}), {}
	ge.__FmL = tk
	task.spawn(function()
		local ok, en, iv = cx(function()
			local d, n = md("Data", "Catalog", "Fish"), {}
			for k, v in md("Data", "Catalog", "Boss").Pools do
				if v[1] and d[v[1].id] then n[k] = d[v[1].id].name end
			end
			return n, md("Data", "Catalog", "Event").Constant.OCCURRENCE_INTERVAL
		end)
		if not ok or type(iv) ~= "number" then
			bl:Set("Next Boss: Unknown")
			return
		end
		while ge.__FmL == tk do
			local t, ek, ex = workspace:GetServerTimeNow(), nil, 0
			local ev = rv.EventController and rv.EventController._active_events
			for k, v in type(ev) == "table" and ev or {} do
				if en[k] then ek, ex = k, math.max(v.expire_at or 0, v.admin_override_expire_at or 0) end
			end
			local lf = math.max(0, math.floor((ek and ex or (t // iv + 1) * iv) - t))
			bl:Set(ek and `Boss Up: {en[ek]} - {lf // 60}:{string.format("%02d", lf % 60)} Left` or `Next Boss: {os.date("%H:%M", math.floor((t // iv + 1) * iv))} - In {lf // 60}:{string.format("%02d", lf % 60)}`)
			task.wait(1)
		end
	end)
end
gt:Dropdown({Name = "Select Farm Island", Options = {"Current Island", table.unpack(iz)}, Default = "Current Island", Flag = "fi"})
ft = gt:Toggle({Name = "Auto Fish", Flag = "af", Callback = function(v)
	if v then fs() elseif ge.__FmF then ge.__FmF.st = "Stopped" end
end})
gt:Toggle({Name = "Auto Boss", Flag = "ab"})

gt:Section({Name = "Quest"})
gt:Dropdown({Name = "Select Rod Quest", Options = qz, Flag = "qs"})
gt:Toggle({Name = "Auto Rod Quest", Flag = "qa"})
gt:Toggle({Name = "Auto Unlock Island", Flag = "au"})
gt:Toggle({Name = "Auto Daily Quest", Flag = "dq"})

gt:Section({Name = "Soul"})
gt:Dropdown({Name = "Select Soul Quest", Options = qgz, Default = {}, Multi = true, Flag = "ys"})
gt:Toggle({Name = "Auto Soul Quest", Flag = "ya"})

gt:Section({Name = "Sell"})
gt:Dropdown({Name = "Sell Rarity", Options = ra, Default = {}, Multi = true, Flag = "sr"})
gt:Dropdown({Name = "Sell Style", Options = {"Fly To Seller", "Walk To Seller"}, Default = "Fly To Seller", Flag = "ss"})
gt:Toggle({Name = "Auto Sell", Flag = "as", Callback = function(v)
	if v then sls() elseif ge.__FmS then ge.__FmS.st = "Stopped" end
end})

local tz, qtx = gw:Tab({Name = "Status", Icon = "rbxassetid://125235305885604"}), `Iq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Island Quest"})
local iql = tz:Label({Text = qtx})
local rtx = `Rq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Rod Quest"})
local rql = tz:Label({Text = rtx})
local ytx = `Yq{game:GetService("HttpService"):GenerateGUID(false)}`
tz:Section({Name = "Soul Quest"})
local yql = tz:Label({Text = ytx})
tz:Section({Name = "Skill Market"})
local kql = tz:Label({Text = "Loading..."})

local tm = gw:Tab({Name = "Misc", Icon = "rbxassetid://137813242924560"})
tm:Section({Name = "Unit"})
tm:Dropdown({Name = "Delete Rarity", Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"}, Default = {}, Multi = true, Flag = "ur"})
xk = tm:Toggle({Name = "Auto Delete Unit", Flag = "ua", Callback = function(v)
	if v then xy() elseif ge.__FmU then ge.__FmU.st = "Stopped" end
end})

local tq = gw:Tab({Name = "Shop", Icon = "rbxassetid://95128643065405"})
tq:Section({Name = "Gacha"})
tq:Dropdown({Name = "Select Gacha", Options = ga, Default = "Skill Master", Flag = "gk"})
tq:Dropdown({Name = "Select Roll", Options = {"x1", "x10"}, Default = "x1", Flag = "gr"})
gs = tq:Toggle({Name = "Auto Roll", Flag = "gs", Callback = function(v)
	if v then gg() elseif ge.__FmG then ge.__FmG.st = "Stopped" end
end})
tq:Section({Name = "Skill Market"})
tq:Dropdown({Name = "Select Skills", Options = mz, Default = {}, Multi = true, Flag = "mm"})
mk = tq:Toggle({Name = "Auto Buy Skill Market", Flag = "ma", Callback = function(v)
	if v then mg() elseif ge.__FmM then ge.__FmM.st = "Stopped" end
end})
tq:Section({Name = "Rod"})
tq:Dropdown({Name = "Select Rod", Options = rz, Flag = "rd"})
rk = tq:Toggle({Name = "Auto Buy Rod", Flag = "rb", Callback = function(v)
	if v then
		if it then it:Set(false) end
		if nk then nk:Set(false) end
		rh()
	elseif ge.__FmR then ge.__FmR.st = "Stopped" end
end})

local tl = gw:Tab({Name = "Teleport", Icon = "rbxassetid://116165046950286"})
tl:Section({Name = "Island"})
tl:Dropdown({Name = "Select Island", Options = iz, Flag = "si"})
it = tl:Toggle({Name = "Auto Island", Flag = "ai", Callback = function(v)
	if v then
		if rk then rk:Set(false) end
		if nk then nk:Set(false) end
		is()
	elseif ge.__FmI then ge.__FmI.st = "Stopped" end
end})
tl:Section({Name = "NPC"})
tl:Dropdown({Name = "Select NPC", Options = nl, Flag = "sv"})
nk = tl:Toggle({Name = "Teleport To NPC", Flag = "tv", Callback = function(v)
	if v then
		if it then it:Set(false) end
		if rk then rk:Set(false) end
		ny()
	elseif ge.__FmT then ge.__FmT.st = "Stopped" end
end})

local ez, eo = {cs = {}, o = {}, w = {}}, nil
do
	local ov = ge.__FmV
	if ov then
		ov.w = {}
		if ov.rw then pcall(ov.rw) end
		for _, c in ov.cs do c:Disconnect() end
	end
	ge.__FmV = ez
	for _, n in {"RodSkinId", "AuraCatalogId"} do
		if ov then ez.o[n] = ov.o[n] else ez.o[n] = lp:GetAttribute(n) end
		table.insert(ez.cs, lp:GetAttributeChangedSignal(n):Connect(function()
			local v = lp:GetAttribute(n)
			if v == ez.w[n] then return end
			ez.o[n] = v
			if ez.w[n] then lp:SetAttribute(n, ez.w[n]) end
		end))
	end
	local et, an = 0, "AuraCatalogId"
	table.insert(ez.cs, game:GetService("RunService").Heartbeat:Connect(function()
		if not ez.w[an] or os.clock() < et then return end
		et = os.clock() + 0.25
		local c = lp.Character
		local fx = c and c:FindFirstChild("ClientAuraEffect")
		for _, d in fx and fx:GetDescendants() or {} do
			if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Light") or d:IsA("Highlight") then
				if not d.Enabled then d.Enabled = true end
			elseif d:IsA("BasePart") and d.LocalTransparencyModifier ~= 0 then
				d.LocalTransparencyModifier = 0
			end
		end
	end))
	local sn, ac, ah, zo = "RodSkinId", {}, nil, {}
	local function rw(t)
		local sk, df, nm = ez.w[sn], eo and eo[3], ah
		local r = sk and df and nm and df[1](t.Name, df[2][sk])
		if not r or r.id == t.Animation.AnimationId then return end
		local n = ac[r.id]
		if not n then
			local an2 = Instance.new("Animation")
			an2.AnimationId = r.id
			local ok, x = pcall(nm.LoadAnimation, nm, an2)
			if not ok or not x then return end
			n, ac[r.id] = x, x
		end
		n.Priority, n.Looped = r.priority, r.looped
		t:AdjustWeight(0.001, 0)
		zo[t] = n
		n:Play(r.fadeTime, 1, r.playbackSpeed)
		local c1
		c1 = t.Stopped:Connect(function()
			c1:Disconnect()
			if zo[t] ~= n then return end
			zo[t] = nil
			for _, n2 in zo do
				if n2 == n then return end
			end
			n:Stop(r.fadeTime)
		end)
	end
	local function hk2(c)
		local h = c and c:WaitForChild("Humanoid", 10)
		local nm = h and h:WaitForChild("Animator", 10)
		if not nm or ge.__FmV ~= ez then return end
		ah, ac, zo = nm, {}, {}
		table.insert(ez.cs, nm.AnimationPlayed:Connect(rw))
	end
	table.insert(ez.cs, lp.CharacterAdded:Connect(hk2))
	task.spawn(hk2, lp.Character)
	ez.rw = function()
		for t, n in zo do
			pcall(function() n:Stop(0.15); t:AdjustWeight(1, 0.15) end)
		end
		zo = {}
		for _, t in ah and ah:GetPlayingAnimationTracks() or {} do
			if t.WeightTarget > 0 then rw(t) end
		end
	end
	local ok, a, b, rz2 = cx(function()
		local ct, rk, sa2 = md("Data", "Catalog"), {}, {}
		for _, v in ct.RodSkin.GetAll() do
			if type(v) == "table" and type(v.id) == "string" then sa2[v.id] = v.animations end
		end
		for i, r in ra do rk[r] = i end
		local function bl(t)
			local l, m, n = {}, {}, {"Default"}
			for _, v in t.GetAll() do
				if type(v) == "table" and type(v.name) == "string" and type(v.id) == "string" then table.insert(l, v); m[v.name] = v.id end
			end
			table.sort(l, function(x, y)
				local p, q = rk[x.rarity] or 0, rk[y.rarity] or 0
				if p ~= q then return p > q end
				return x.name < y.name
			end)
			for _, v in l do table.insert(n, v.name) end
			return {n, m}
		end
		return bl(ct.RodSkin), bl(ct.Aura), {md("Data", "Config", "RodAnimationConfig").Resolve, sa2}
	end)
	if ok then eo = {a, b, rz2} else gw:Notify({Title = "Visual", Text = "Effect List Failed: Catalog Error"}) end
end

local function ep(n, id)
	ez.w[n] = id
	lp:SetAttribute(n, id or ez.o[n])
	if ez.rw then ez.rw() end
end

if eo then
	local tv = gw:Tab({Name = "Visual", Icon = "rbxassetid://105107872623903"})
	tv:Section({Name = "Effect"})
	tv:Dropdown({Name = "Rod Skin", Options = eo[1][1], Default = "Default", Flag = "es", Callback = function(v) ep("RodSkinId", eo[1][2][v]) end})
	tv:Dropdown({Name = "Aura", Options = eo[2][1], Default = "Default", Flag = "ea", Callback = function(v) ep("AuraCatalogId", eo[2][2][v]) end})
end

local function zp()
	if ge.__FmP then return nil, "Already On" end
	ge.__FmP = true
	local sc, lt, tr, oc = rv.SettingsController, game:GetService("Lighting"), workspace.Terrain, workspace:FindFirstChild("Ocean")
	local ul = true
	for k, v in {ultra_low_graphic = true, show_others_vfx = false, show_my_vfx = false, show_cutscenes = false, show_damage_indicator = false, camera_shaking = false, auto_fishing_hide_vfx = true} do
		if not (sc and sc._SetLocal and pcall(sc._SetLocal, sc, k, v)) then ul = false end
	end
	local function ko(d)
		d.Enabled = false
		d:GetPropertyChangedSignal("Enabled"):Connect(function() if d.Enabled then d.Enabled = false end end)
	end
	local function lf()
		if lt.GlobalShadows then lt.GlobalShadows = false end
		if lt.FogEnd < 1e9 then lt.FogEnd = 1e9 end
	end
	local function kx(d)
		if d:IsA("PostEffect") then
			ko(d)
		elseif d:IsA("Atmosphere") then
			local function z() if d.Density ~= 0 or d.Haze ~= 0 or d.Glare ~= 0 then d.Density, d.Haze, d.Glare = 0, 0, 0 end end
			z()
			d.Changed:Connect(z)
		end
	end
	local function px(d)
		if d == tr or oc and d:IsDescendantOf(oc) then return end
		if d:IsA("ParticleEmitter") then
			d.Lifetime = NumberRange.new(0)
			ko(d)
		elseif d:IsA("Beam") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("Light") or d:IsA("Highlight") then
			ko(d)
		elseif d:IsA("Decal") then
			d.Transparency = 1
		elseif d:IsA("SurfaceAppearance") then
			task.defer(pcall, d.Destroy, d)
		elseif d:IsA("BasePart") and d.Material ~= Enum.Material.Water then
			d.Material, d.Reflectance, d.CastShadow = Enum.Material.SmoothPlastic, 0, false
		end
	end
	lf()
	lt:GetPropertyChangedSignal("GlobalShadows"):Connect(lf)
	lt:GetPropertyChangedSignal("FogEnd"):Connect(lf)
	for _, d in lt:GetChildren() do pcall(kx, d) end
	lt.ChildAdded:Connect(function(d) pcall(kx, d) end)
	pcall(function() tr.WaterWaveSize, tr.WaterWaveSpeed, tr.WaterReflectance = 0, 0, 0 end)
	workspace.DescendantAdded:Connect(function(d) pcall(px, d) end)
	task.spawn(function()
		for i, d in workspace:GetDescendants() do
			pcall(px, d)
			if i % 2000 == 0 then task.wait() end
		end
	end)
	if not ul then return nil, "Game Settings Failed: Settings Error" end
	return true
end

local ts = gw:Tab({Name = "Setting", Icon = "rbxassetid://138794268715403"})
ts:Section({Name = "Game"})
ts:Dropdown({Name = "Select Boat", Options = bn, Default = "Truck", Flag = "sb"})
ts:Toggle({Name = "Instant Teleport", Default = true, Flag = "wb", Callback = function(v) wb.on = v == true end})
ts:Toggle({Name = "Safe", Flag = "zy", Callback = function(v) zy.on = v == true end})
local jr = false
pcall(function() ge.__FmJ:Disconnect() end)
ge.__FmJ = (game:GetService("GuiService") :: any).ErrorMessageChanged:Connect(function(m)
	if jr or type(m) ~= "string" or m == "" then return end
	jr = true
	task.spawn(function()
		local tp = game:GetService("TeleportService")
		while true do
			pcall(tp.Teleport, tp, game.PlaceId, lp)
			task.wait(10)
		end
	end)
end)
local zl = {}
ge.__FmZ = zl
task.spawn(function()
	while ge.__FmZ == zl do
		task.wait(0.5)
		local f = ge.__FmF
		if not zy.on or os.clock() < zy.nt or not zw() then
			zy.rq = false
		elseif f and not f.dn and f.st == "Running" then
			zy.rq = true
		else
			gw:Notify({Title = "Safe", Text = "Player On Island, Hopping"})
			local _, e = zh()
			gw:Notify({Title = "Safe", Text = e})
		end
	end
end)
ts:Button({Name = "FPS Booster", Callback = function()
	local ok, e = zp()
	gw:Notify({Title = "FPS Booster", Text = ok and "On Until Rejoin" or e})
end})

local rx = "MOS HUB-V2 tiktok@noelnoathebest02"

local function nt()
	for _, c in ge.__FmN or {} do c:Disconnect() end
	local cs, tx, gr = {}, rx, {}
	ge.__FmN = cs
	local function hk(m)
		task.spawn(function()
			local p = m:WaitForChild("PlrName", 10)
			local s = p and p:WaitForChild("Surface", 10)
			local l = s and s:WaitForChild("Label", 10)
			if not l or ge.__FmN ~= cs then return end
			if m.Name == lp.Name then
				local o = `@{lp.Name}`
				if l.Text ~= o then l.Text = o end
				if l:FindFirstChild("Rb") then l.Rb:Destroy() end
				local lo = l
				lo.TextTransparency, lo.TextStrokeTransparency = 1, 1
				for _, n in {"TextTransparency", "TextStrokeTransparency"} do
					table.insert(cs, lo:GetPropertyChangedSignal(n):Connect(function() if lo[n] ~= 1 then lo[n] = 1 end end))
				end
				local fd = l:FindFirstChild("Fade")
				if fd and fd:IsA("GuiObject") then
					fd.Visible = false
					table.insert(cs, fd:GetPropertyChangedSignal("Visible"):Connect(function() if fd.Visible then fd.Visible = false end end))
				end
				if s:FindFirstChild("Rx") then s.Rx:Destroy() end
				local tp = game:GetService("ReplicatedStorage"):FindFirstChild("Assets")
				for _, n in {"UIs", "Prefabs", "Nametag", "PlrName", "Surface", "Label"} do tp = tp and tp:FindFirstChild(n) end
				local cl = (tp and tp:IsA("TextLabel") and tp or l):Clone()
				for _, x in cl:GetChildren() do
					if x.Name == "Rb" then x:Destroy() elseif x.Name == "Fade" and x:IsA("GuiObject") then x.Visible = true end
				end
				cl.Name, cl.TextTransparency, cl.TextStrokeTransparency, cl.Parent = "Rx", 0, 0, s
				l = cl
			end
			l.Text = tx
			table.insert(cs, l:GetPropertyChangedSignal("Text"):Connect(function() if l.Text ~= tx then l.Text = tx end end))
			local g = l:FindFirstChild("Rb") or Instance.new("UIGradient")
			g.Name, g.Parent = "Rb", l
			gr[g] = true
		end)
	end
	local nf = workspace:FindFirstChild("Nametags")
	if not nf then return end
	table.insert(cs, game:GetService("RunService").Heartbeat:Connect(function()
		local p, k = os.clock() * 0.25, {}
		for i = 0, 9 do k[i + 1] = ColorSequenceKeypoint.new(i / 9, Color3.fromHSV((i / 9 - p) % 1, 1, 1)) end
		local q = ColorSequence.new(k)
		for g in gr do
			if g.Parent then g.Color = q else gr[g] = nil end
		end
	end))
	table.insert(cs, nf.ChildAdded:Connect(hk))
	for _, m in nf:GetChildren() do hk(m) end
end

nt()

task.spawn(function()
	for _ = 1, 3 do
		if sa() >= 12 then return end
		task.wait(5)
	end
	gw:Notify({Title = "Auto Boss", Text = "Boss Scan Failed: Regions Missing"})
end)

if ge.__FmA then ge.__FmA:Disconnect() end
ge.__FmA = lp.Idled:Connect(function()
	local vu = game:GetService("VirtualUser")
	vu:CaptureController()
	vu:ClickButton2(Vector2.new())
end)

local function bh()
	for _, x in ge.__FmB or {} do
		pcall(function() x:Disconnect() end)
		pcall(function() x:Destroy() end)
	end
	local cs, fc = {}, rv.FishingController
	ge.__FmB = cs
	local ok, en, bd = cx(function()
		local fs2, n, d = md("Data", "Catalog", "Fish"), {}, {}
		for id, v in fs2 do
			if type(v) == "table" and type(v.name) == "string" then d[id] = {v.name, v.kind == "Boss"} end
		end
		for k, v in md("Data", "Catalog", "Boss").Pools do
			if v[1] and d[v[1].id] then n[k] = d[v[1].id][1] end
		end
		return n, d
	end)
	if not ok then return end
	local sr = lp.PlayerGui:WaitForChild("SessionInfo", 10)
	if not (sr and sr:FindFirstChild("Holder")) then return end
	local sg = sr:Clone()
	for _, x in sg:GetDescendants() do
		if x:IsA("LuaSourceContainer") then x:Destroy() end
	end
	sg.Name, sg.ResetOnSpawn, sg.DisplayOrder, sg.Enabled = game:GetService("HttpService"):GenerateGUID(false), false, 10, true
	local h = sg.Holder
	local hp, fn = h:FindFirstChild("FishHP"), h:FindFirstChild("FishName")
	local fi, ht = hp and hp:FindFirstChild("Fill"), hp and hp:FindFirstChild("HealthText")
	if not (fn and fi and ht) then return end
	for _, n in {"Tension", "FinisherGate", "EscapeSign"} do
		local x = h:FindFirstChild(n)
		if x then x.Visible = false end
	end
	for _, n in {"MaxHealthReduced", "MaxHealthReducedGate"} do
		local x = hp:FindFirstChild(n)
		if x then x.Visible = false end
	end
	local g1, g2, f0, tw = fi:FindFirstChild("Normal"), fi:FindFirstChild("BossPhase2"), fi.BackgroundColor3, game:GetService("TweenService")
	local px, po, pv, sv, fs = h.Position.X.Scale, h.Position.X.Offset, h.Position.Y.Offset, false, -1
	h.Position, h.Visible, fn.Visible = UDim2.new(px, po, -0.2, pv), false, true
	if not pcall(function() sg.Parent = gethui() end) then sg.Parent = lp.PlayerGui end
	table.insert(cs, sg)
	local function sl(v)
		if v == sv then return end
		sv = v
		if v then h.Visible = true end
		local t = tw:Create(h, TweenInfo.new(0.35, Enum.EasingStyle.Quint, v and Enum.EasingDirection.Out or Enum.EasingDirection.In), {Position = UDim2.new(px, po, v and 0.1 or -0.2, pv)})
		t.Completed:Connect(function() if not sv then h.Visible = false end end)
		t:Play()
	end
	local st, im, nr, iy, kh = nil, nil, 0, {}, false
	for n, v in ix do iy[v] = n end
	local function nf(n)
		return (tostring(math.floor(n + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	table.insert(cs, fc.FishFirstPullStart.OnClientEvent:Connect(function(id, hp, mx) st = {bd[id] and bd[id][1] or tostring(id), hp, mx, 1, bd[id] and bd[id][2]} end))
	table.insert(cs, fc.FishReelStartAck.OnClientEvent:Connect(function(id, hp, mx) if not st then st = {bd[id] and bd[id][1] or tostring(id), hp, mx, 1, bd[id] and bd[id][2]} end end))
	table.insert(cs, fc.FishReelHPUpdate.OnClientEvent:Connect(function(hp) if st then st[2] = hp end end))
	table.insert(cs, fc.FishReelPhaseHP.OnClientEvent:Connect(function(hp, mx) if st then st[2], st[3], st[4] = hp, mx, 2 end end))
	table.insert(cs, fc.FishCatchResult.OnClientEvent:Connect(function() st = nil end))
	table.insert(cs, fc.FishReset.OnClientEvent:Connect(function() st = nil end))
	table.insert(cs, game:GetService("RunService").RenderStepped:Connect(function()
		pcall(function()
			local ev, ek, ex = rv.EventController and rv.EventController._active_events, nil, 0
			for k, v in type(ev) == "table" and ev or {} do
				if en[k] then ek, ex = k, math.max(v.expire_at or 0, v.admin_override_expire_at or 0) end
			end
			local gh = sr.Parent and sr:FindFirstChild("Holder")
			sl((ek ~= nil or st ~= nil) and not (gh and gh.Visible))
			if not sv then return end
			if os.clock() >= nr then
				nr, im = os.clock() + 1, nil
				task.spawn(function()
					local o, v = pcall(function() return (tonumber(pd().LastBossKillSlot) or 0) >= workspace:GetServerTimeNow() // 2400 * 2400 end)
					kh = o and v == true
				end)
				for _, x in game:GetService("CollectionService"):GetTagged("BossRegion") do
					local fx = x:FindFirstChild("BossSpawnerFX")
					if fx and fx:GetAttribute("BossSpawnerFXActive") == true and x.Parent and x.Parent.Parent then im = iy[x.Parent.Parent.Name] or x.Parent.Parent.Name end
				end
			end
			local lf, bo2 = math.floor(ex - workspace:GetServerTimeNow()), ek ~= nil and (not st or st[5])
			fn.Text = (st and st[1] or en[ek] or "Boss") .. (bo2 and im and ` - {im}` or "")
			if st then
				local f = math.clamp(st[2] / math.max(st[3], 1), 0, 1)
				if f ~= fs then
					fs = f
					tw:Create(fi, TweenInfo.new(0.15), {Size = UDim2.fromScale(f, 1)}):Play()
				end
				fi.BackgroundColor3 = f0
				if g1 then g1.Enabled = st[4] < 2 end
				if g2 then g2.Enabled = st[4] >= 2 end
				ht.Text = `{nf(st[2])} / {nf(st[3])}`
			else
				if fs ~= 1 then
					fs = 1
					tw:Create(fi, TweenInfo.new(0.15), {Size = UDim2.fromScale(1, 1)}):Play()
				end
				local hd = kh and ek ~= nil
				fi.BackgroundColor3 = hd and Color3.fromRGB(96, 165, 110) or Color3.fromRGB(70, 70, 80)
				if g1 then g1.Enabled = false end
				if g2 then g2.Enabled = false end
				ht.Text = hd and "Hunted" or lf > 0 and string.format("Not Hooked - %d:%02d", lf // 60, lf % 60) or "Not Hooked"
			end
		end)
	end))
end

task.spawn(bh)

local function iq()
	local o = ge.__FmQ
	if o then
		o.on = false
		pcall(function() o.sg:Destroy() end)
	end
	local tk, lb, rb, ylb = {on = true}, nil, nil, nil
	ge.__FmQ = tk
	local ok0, hu = pcall(gethui)
	for _, rt in {ok0 and hu or lp.PlayerGui, lp.PlayerGui} do
		for _, x in rt:GetDescendants() do
			if x:IsA("TextLabel") and x.Text == qtx then lb = x end
			if x:IsA("TextLabel") and x.Text == rtx then rb = x end
			if x:IsA("TextLabel") and x.Text == ytx then ylb = x end
		end
		if lb then break end
	end
	if lb then lb.RichText = true end
	if rb then rb.RichText = true end
	if ylb then ylb.RichText = true end
	iql:Set("Loading...")
	rql:Set("Loading...")
	yql:Set("Loading...")
	local iy = {}
	for n, v in ix do iy[v] = n end
	local function nf(v)
		return (tostring(math.floor(v + 0.5)):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	local function kg(v)
		return v >= 100 and `{nf(v)} kg` or `{string.format("%.1f", v)} kg`
	end
	local qf = {
		crimson_bead_rod = {RequiredFished = 100, RequiredCoin = 3000000},
		bamboo_rod = {RequiredBamboo = 20, RequiredCoin = 3600000},
		heaven_piercer_turtle_rod = {RequiredFish = 5, RequiredCoin = 5000000},
		zen_staff_rod = {RequiredFish = 5, RequiredCoin = 5000000},
		dread_fish_rod = {RequiredFish = 1, RequiredCoin = 10000000},
		taiji_hooking_art_v2 = {RequiredKills = 100, RequiredCoin = 1000000},
	}
	local function rd()
		local q = qm[L.Flags.qs]
		if not q then return nil end
		local d, ct = pd(), md("Data", "Catalog")
		local cq = d.Quest and d.Quest.Current
		local ac, id = cq and cq.Id == q[1], q[1]
		if ((d.Quest or {}).Done or {})[id] then return {`{q[4]} (Completed)`, {}} end
		local pr, df, ln = ac and cq.Progress or {}, qf[id] or {}, {}
		local function gv(k) return pr[k] or df[k] or 0 end
		local function ro(n, h, w, s) table.insert(ln, {`{n}: {nf(h)} / {nf(w)}`, h >= w, s}) end
		local na = not ac and "Counts only after accepting" or nil
		local u = ul(q[2])
		table.insert(ln, {`{iy[q[2]] or q[2]}: {u and "Unlocked" or "Locked"}`, u})
		if q[7] then
			local r, o = ct.Rod.GetById(q[7]), d.Rods and d.Rods[q[7]] ~= nil
			table.insert(ln, {`Own {r and r.name or q[7]}: {o and "Yes" or "No"}`, o})
		end
		ro("Coins", d.Coin or 0, gv("RequiredCoin"))
		if id == "crimson_bead_rod" then
			ro("Fish With Legacy Rod", ac and pr.CurrentFished or 0, gv("RequiredFished"), na)
		elseif id == "bamboo_rod" then
			ro("Bamboo Fragments", md("Shared", "getItemCount")(d, "bamboo_fragment"), gv("RequiredBamboo"), "10% drop while fishing on Jungle Island")
		elseif id == "zen_staff_rod" then
			ro("Final Blows With Taiji Hooking Art V2", ac and pr.CurrentFish or 0, gv("RequiredFish"), `Legendary fish from Fossil Island{na and `, {na:lower()}` or ""}`)
		elseif id == "taiji_hooking_art_v2" then
			ro("Final Blows With Taiji Hooking Art", ac and pr.CurrentKills or 0, gv("RequiredKills"), `Any fish, any island{na and `, {na:lower()}` or ""}`)
			local bk = ((d.Inventory or {}).Books or {}).taiji_hooking_art or 0
			table.insert(ln, {`Taiji Hooking Art Books: {bk}`, bk >= 1, "One book is turned into V2; the hub unequips it before completing"})
		elseif q[6] then
			local c = 0
			for _ in select(2, qc(q, d, {RequiredFish = gv("RequiredFish")})) do c += 1 end
			ro(`{q[6][1]} Fish`, c, gv("RequiredFish"), `Any {q[6][1]} fish from {iy[q[6][2]] or q[6][2]}`)
		end
		return {`{q[4]}{ac and " (Accepted)" or ""}`, ln}
	end
	local function rs(r)
		if not r then return "No Rod Quest Selected" end
		local t = {rb and `<b>{r[1]}</b>` or r[1]}
		for _, v in r[2] do
			local hn = v[3] and (rb and ` <font color="#96938C">- {v[3]}</font>` or ` - {v[3]}`) or ""
			table.insert(t, (rb and `<font color="#{v[2] and "78C882" or "D66A5E"}">{v[1]}</font>` or v[1]) .. hn)
		end
		return table.concat(t, "\n")
	end
	local function dt()
		local d, q = pd(), nil
		for _, x in qd do
			if not ul(x[3]) then q = x; break end
		end
		if not q then return {} end
		local ct, cq = md("Data", "Catalog"), d.Quest and d.Quest.Current
		local pr = cq and cq.Id == q[1] and cq.Progress or q[5]
		local _, ks = qc(q, d, pr)
		local ln, n, bw, fl = {{"Coins", d.Coin or 0, pr.RequiredCoin or 0}}, {}, {}, {}
		for u in ks do
			local x = d.Inventory.Fishes[u]
			if x then n[x.fishId] = (n[x.fishId] or 0) + 1 end
		end
		for _, x in d.Inventory.Fishes do bw[x.fishId] = math.max(bw[x.fishId] or 0, x.weight or 0) end
		for _, il in ix do
			for _, x in (ct.Island.GetById(il) or {}).fishes or {} do
				fl[x.fishId] = fl[x.fishId] and `{fl[x.fishId]}, {iy[il]}` or iy[il]
			end
		end
		if q[6] then
			local c = 0
			for _ in ks do c += 1 end
			table.insert(ln, {`{q[6][1]} Fish`, c, pr.RequiredFish or 1, `Any {q[6][1]} fish from {iy[q[6][2]] or q[6][2]}`})
		else
			local wk, fs = q[1] == "unlock_island_6" and md("Data", "Config", "QuestConfig").UnlockIsland6MinWeightKg or {}, {}
			for id, v in pr.RequiredFishes or {} do
				local fi = ct.Fish.GetById(id)
				local nm, rr, il = fi and fi.name or id, fi and fi.rarity or "?", fl[id] or "?"
				table.insert(fs, {nm, n[id] or 0, v, wk[id] and `Need {kg(wk[id])} - Best {bw[id] and kg(bw[id]) or "none"} - {rr} - {il}` or `{rr} - {il}`, wk[id] or 0})
			end
			table.sort(fs, function(x, y)
				if x[5] ~= y[5] then return x[5] < y[5] end
				return x[1] < y[1]
			end)
			for _, x in fs do table.insert(ln, x) end
		end
		return {q[4], ln, cq and cq.Id == q[1]}
	end
	local function yd()
		local d, ct, ba = pd(), md("Data", "Catalog"), md("Utils", "skillBookAvailability")
		local cq, so, dn, ps = (d.Quest or {}).Current or {}, (d.Inventory or {}).Souls or {}, (d.Quest or {}).Done or {}, L.Flags.ys or {}
		local se = ct.Soul.GetById(d.SoulEquip or "")
		local t = {{`Equipped Soul: {se and se.name or "Human"}`}}
		if #ps == 0 then table.insert(t, {"No Soul Quest Selected"}) end
		for _, q in qg do
			local id = q[1]
			if not table.find(ps, q[4]) then continue end
			if dn[id] or so[id] == true then
				table.insert(t, {`{q[4]} (Owned)`, true, nil, true})
				continue
			end
			local ac = cq.Id == id
			local pr, u = ac and cq.Progress or {}, ul(q[2])
			table.insert(t, {`{q[4]}{ac and " (Accepted)" or ""}`, nil, nil, true})
			table.insert(t, {`{iy[q[2]] or q[2]}: {u and "Unlocked" or "Locked"}`, u})
			if id == "azure_dragon" or id == "supreme_king" then
				local h, w = ac and pr.CurrentUsedSkill or 0, pr.CatchWithSkill or (id == "azure_dragon" and 100 or 5)
				table.insert(t, {`{id == "azure_dragon" and "Final Blows With One Hook Supreme" or "Legendary Final Blows With Rod Gate 20%"}: {nf(h)} / {nf(w)}`, h >= w, `{id == "azure_dragon" and "Any fish" or "Legendary fish from Fossil Island"}{ac and "" or ", counts only after accepting"}`})
			end
			if q[6] then
				local w, c = pr.RequiredFish or 3, 0
				for _ in select(2, qc(q, d, {RequiredFish = w})) do c += 1 end
				table.insert(t, {`{q[6][1]} Fish{q[6][3] and ` {nf(q[6][3])}+ kg` or ""}: {c} / {w}`, c >= w, `From {iy[q[6][2]] or q[6][2]}`})
			end
			for b, v in id == "phoenix" and md("Data", "Config", "QuestConfig").PhoenixRequiredBooks or id == "supreme_king" and (pr.RequiredBooks or {rod_gate_20_percent = 1}) or {} do
				local a = ba.GetCounts(d, b).available
				table.insert(t, {`Unequipped {(ct.Skill.GetById(b) or {}).name or b}: {math.min(a, v)} / {v}`, a >= v, id == "supreme_king" and "A copy besides the one on your rod" or "Skill book not on any rod"})
			end
		end
		return t
	end
	local function yr(r)
		local t = {}
		for _, v in r do
			local x = v[4] and (ylb and `<b>{v[1]}</b>` or v[1]) or v[2] ~= nil and ylb and `<font color="#{v[2] and "78C882" or "D66A5E"}">{v[1]}</font>` or v[1]
			table.insert(t, x .. (v[3] and (ylb and ` <font color="#96938C">- {v[3]}</font>` or ` - {v[3]}`) or ""))
		end
		return table.concat(t, "\n")
	end
	local function kd()
		local st, ct, t = game:GetService("ReplicatedStorage"):GetAttribute("SkillMarketStock"), md("Data", "Catalog"), {}
		for id in (type(st) == "string" and st or ""):gmatch("[^,]+") do
			local x = ct.Skill.GetById(id)
			table.insert(t, x and x.name or id)
		end
		return #t > 0 and table.concat(t, "\n") or "No Stock"
	end
	while ge.__FmQ == tk do
		local ok, r = cx(dt)
		if ok and r then
			local t = {r[1] and `Next Island: {r[1]}{r[3] and " (Accepted)" or ""}` or "All Islands Unlocked"}
			if lb then t[1] = `<b>{t[1]}</b>` end
			for _, v in r[2] or {} do
				local x = `{v[1]}: {nf(v[2])} / {nf(v[3])}`
				local hn = v[4] and (lb and ` <font color="#96938C">- {v[4]}</font>` or ` - {v[4]}`) or ""
				table.insert(t, (lb and `<font color="#{v[2] >= v[3] and "78C882" or "D66A5E"}">{x}</font>` or x) .. hn)
			end
			iql:Set(table.concat(t, "\n"))
		end
		local ok2, r2 = cx(rd)
		if ok2 then rql:Set(rs(r2)) end
		local ok4, r4 = cx(yd)
		if ok4 and r4 then yql:Set(yr(r4)) end
		local ok3, r3 = cx(kd)
		if ok3 then kql:Set(r3) end
		task.wait(1)
	end
end

task.spawn(iq)
