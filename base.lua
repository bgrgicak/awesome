-- This function returns a formatted string with the current battery status. It
-- can be used to populate a text widget in the awesome window manager. Based
-- on the "Gigamo Battery Widget" found in the wiki at awesome.naquadah.org

local naughty = require("naughty")
local beautiful = require("beautiful")
oldPower = 0
timeLeft = 0

function batteryInfo(adapter)
  local fh = io.open("/sys/class/power_supply/"..adapter.."/present", "r")
  if fh == nil then
    battery = "A/C"
    icon = ""
    percent = ""
  else
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")  
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    local cap = fcap:read()
    local sta = fsta:read()
    fcur:close()
    fcap:close()
    fsta:close()
    battery = math.floor(cur * 100 / cap)
  
    if sta:match("Charging") then
      icon = "⚡"
      percent = "%"

	if oldPower > 0 then
    		timeLeft = (tonumber(cap) - tonumber(cur))/(tonumber(cur) - oldPower) 
	end
    elseif sta:match("Discharging") then
      icon = ""
      percent = "%"
      if tonumber(battery) < 5 then
        naughty.notify({ title    = "Battery Warning"
               , text     = "Battery low!".."  "..battery..percent.."  ".."left!"
               , timeout  = 5
               , position = "top_right"
               , fg       = beautiful.fg_focus
               , bg       = beautiful.bg_focus
        })
      end

	if oldPower > 0 then
    		timeLeft = tonumber(cur)/(oldPower - tonumber(cur)) 
	end
    end
	
    oldPower = tonumber(cur)
  end

  if percent == nil then
    percent="%"
  end

    icon="⚡"

  if battery == nil then
    battery=""
  end
  return " "..icon..battery..percent.." "
end


function volumeInfo()
	local handle = io.popen("amixer get Master | grep 'Front Left:' | tr -s '[' | cut -d '[' -f 2 | cut -d ']' -f 1 | cut -d '%' -f 1")
	local result = handle:read("*a")
	handle:close()
	return "♫"..tostring(result).."    "
end
function clockInfo()
	return tostring(os.date("%H:%M")).."    "
end

	--naughty.notify({ text=tostring(message), icon="/path/to/icon" })





