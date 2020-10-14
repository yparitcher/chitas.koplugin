local Device = require("device")
local Dispatcher = require("dispatcher")
local FFIUtil = require("ffi/util")
local Font = require("ui/font")
local InfoMessage = require("ui/widget/infomessage")
local ReadHistory = require("readhistory")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local util = require("util")
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

function Chitas:onDispatcherRegisterActions()
    Dispatcher:registerAction("chumash", {category="none", event="Chumash", title=_("Chumash"), filemanager=true,})
end

function Chitas:init()
    if self.ui.view then -- Reader
        table.insert(self.ui.postReaderCallback, function()
            self:displayTanya()
        end)
    end
    self:onDispatcherRegisterActions()
end

function Chitas:hdateNow()
    local t = ffi.new("time_t[1]")
    t[0] = C.time(nil)
    local tm = ffi.new("struct tm") -- luacheck: ignore
    tm = C.localtime(t)
    return libzmanim.convertDate(tm[0])
end

function Chitas:displayTanya()
    if FFIUtil.basename(self.document.file) == "tanya.epub" then
        local hdate = self:hdateNow()
        local shuir = ffi.new("char[?]", 100)
        libzmanim.tanya(hdate, shuir)
        local text = ffi.string(shuir)
        local popup = InfoMessage:new{
            face = Font:getFace("ezra.ttf", 24),
            show_icon = false,
            text = text,
            lang = "he",
            para_direction_rtl = true,
            timeout = 3,
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

function Chitas:onChumash()
    local chumashPath = "/mnt/us/ebooks/epub/חומש/"
    local hdate = self:hdateNow()
    local shuir = ffi.new("char[?]", 100)
    libzmanim.chumash(hdate, shuir)
    local _, _, text = ffi.string(shuir):find("(.-)\n")
    text = text:gsub(" ", "_")
    local path = chumashPath .. text .. ".epub"
    if util.fileExists(path) then
        local ReaderUI = require("apps/reader/readerui")
        ReaderUI:showReader(path)
        ReadHistory:removeItemByDirectory(chumashPath)
    end
    local popup = InfoMessage:new{
        face = Font:getFace("ezra.ttf", 24),
        show_icon = false,
        text = text,
        lang = "he",
        para_direction_rtl = true,
    }
    UIManager:show(popup)
end

return Chitas
