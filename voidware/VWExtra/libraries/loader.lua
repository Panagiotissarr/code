-- Voidware Loader Library Stub (Dev/Private Mode)
-- Replaces the obfuscated libraries/loader.lua
-- Skips all whitelist/key checks, gives full access

local loaderStub = {}

loaderStub.Colors = {
	Gradient = {
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#c41e3a")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#165b33")),
	}
}

function loaderStub:Loader(icon)
	local loader = {}
	loader.__conns = {}
	loader.__progress = 0

	function loader:Connect(callback)
		table.insert(loader.__conns, callback)
		return {
			Disconnect = function(self)
				local id = table.find(loader.__conns, callback)
				if id then
					table.remove(loader.__conns, id)
				end
			end
		}
	end

	function loader:Update(text, progress)
		loader.__progress = progress or loader.__progress
		for _, conn in loader.__conns do
			pcall(conn, text)
		end
	end

	function loader:Abort(text)
		for _, conn in loader.__conns do
			pcall(conn, text)
		end
		loader:Destroy()
	end

	function loader:Destroy()
		loader.__conns = {}
	end

	return loader
end

return loaderStub
