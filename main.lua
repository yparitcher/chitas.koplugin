local Device = require("device")
local FFIUtil = require("ffi/util")
local InfoMessage = require("ui/widget/infomessage")
local ReadHistory = require("readhistory")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local util = require("ffi/util")
local _ = require("gettext")
local ffi = require("ffi")
local C = ffi.C
require("ffi/rtc_h")
local libzmanim
if Device:isKindle() then
    libzmanim = ffi.load("plugins/chitas.koplugin/libzmanim.so")
elseif Device:isEmulator() then
    libzmanim = ffi.load("plugins/chitas.koplugin/libzmanim-linux.so")
else
    return { disabled = true, }
end
require("libzmanim")

local Chitas = WidgetContainer:new{
    name = "chitas",
}

function Chitas:init()
    if self.ui.view then -- Reader
        table.insert(self.ui.postReaderCallback, function()
            self:displayTanya()
        end)
    end
--temp
self:openChumash()
end

function Chitas:hdateNow()
    local t = ffi.new("time_t[1]")
    t[0] = C.time(nil)
    local tm = ffi.new("struct tm") -- luacheck: ignore
    tm = C.localtime(t)
    return libzmanim.convertDate(tm[0])
end

function Chitas:displayTanya()
    if util.basename(self.document.file) == "tanya.epub" then
        local hdate = self:hdateNow()
        local shuir = ffi.new("char[?]", 100)
        libzmanim.tanya(hdate, shuir)
        local text = ffi.string(shuir)
        local popup = InfoMessage:new{
            show_icon = false,
            text = text,
            lang = "he",
            para_direction_rtl = true,
        }
        UIManager:show(popup)
    end
end

function ReadHistory:removeItemByDirectory(directory)
    assert(self ~= nil)
    for i = #self.hist, 1, -1 do
        if FFIUtil.realpath(FFIUtil.dirname(self.hist[i].file)) == FFIUtil.realpath(directory) then
            self:removeItem(self.hist[i])
            break
        end
    end
    self:ensureLastFile()
end

function Chitas:openChumash()
    local hdate = self:hdateNow()
    local simchastorah = hdate.EY and 22 or 23
    local parshah = libzmanim.NOPARSHAH
    while (parshah == libzmanim.NOPARSHAH) do
        libzmanim.hdateaddday(hdate, 7 - hdate.wday)
        parshah = libzmanim.getparshah(hdate)
    end
    if parshah == libzmanim.BERESHIT and (hdate.day < simchastorah) then
        parshah = libzmanim.VZOT_HABERACHAH
    end
    local popup = InfoMessage:new{
        show_icon = false,
        text = tonumber(parshah), --text,
        lang = "he",
        para_direction_rtl = true,
    }
    UIManager:show(popup)
    local path = "/AUR/koreader/test/חומש(rashi)/פרשת_אמור.epub" --"/mnt/us/" .. tonumber(parshah) .. ".epub"
--    local ReaderUI = require("apps/reader/readerui")
--    ReaderUI:showReader(path)
    ReadHistory:removeItemByDirectory(FFIUtil.dirname(path))
end

return Chitas
