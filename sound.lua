Sound = class('Sound')

local audio = love.audio
local pausedSources = {}
function Sound:init(source, vol)
	local source = love.sound.newSoundData(source)
	self.sound = audio.newSource(source)

	if vol then
		self.sound:setVolume(vol)
	end
end

---Plays the sound
---@param loop? boolean # if set, loops until stopped
function Sound:play(loop)
	if loop then
		self.sound:setLooping(true)
	end
	self.sound:play()
end

---Sets the individual sound volume
---@param x number # the desired volume; values range from 0.1-1
function Sound:volume(x)
	self.sound:setVolume(x)
end

function Sound:raiseVolume()
	local currentVolume = love.audio.getVolume()
	if currentVolume >= 0.9 then
		audio.setVolume(1)
	else
		audio.setVolume(currentVolume + 0.1)
	end
end

function Sound:lowerVolume()
	local currentVolume = love.audio.getVolume()
	if currentVolume < 0.1 then
		audio.setVolume(0)
	else
		audio.setVolume(currentVolume - 0.1)
	end
end

--[[
function Sound:pause()
	pausedSources = audio.pause()
end

function Sound:resume()
	if #pausedSources > 0 then
		for s = 1, #pausedSources do
			
		end
		pausedSources = {}
	end
end
--]]

function Sound:stop()
	self.sound:stop()
end