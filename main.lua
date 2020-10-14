local Device = require("device")
local Dispatcher = require("dispatcher")
local Event = require("ui/event")
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
    Dispatcher:registerAction("shnaimmikrah", {category="none", event="ShnaimMikrah", title=_("Shnaim Mikrah"), filemanager=true,})
end

function Chitas:init()
    if self.ui.view then -- Reader
        table.insert(self.ui.postReaderCallback, function()
            self:displayTanya()
        end)
    end
    self:onDispatcherRegisterActions()
end

function Chitas:popup(text)
    local popup = InfoMessage:new{
        face = Font:getFace("ezra.ttf", 32),
        show_icon = false,
        text = text,
        lang = "he",
        para_direction_rtl = true,
    }
    UIManager:show(popup)
end

function Chitas:getShuir(func)
    local t = ffi.new("time_t[1]")
    t[0] = C.time(nil)
    local tm = ffi.new("struct tm") -- luacheck: ignore
    tm = C.localtime(t)
    local hdate = libzmanim.convertDate(tm[0])
    local shuir = ffi.new("char[?]", 100)
    func(hdate, shuir)
    return ffi.string(shuir)
end

function Chitas:getParshah()
    local shuir = self:getShuir(libzmanim.chumash)
    local _, _, parshah, day = shuir:find("(.-)\n(.-) עם פירש״י")
    return parshah:gsub(" ", "_"), day
end

function Chitas:displayTanya()
    if FFIUtil.basename(self.document.file) == "tanya.epub" then
        local shuir = self:getShuir(libzmanim.tanya)
        self:popup(shuir)
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

function Chitas:switchToShuir(path, name)
    local file = path .. name .. ".epub"
    if util.fileExists(file) then
        local ReaderUI = require("apps/reader/readerui")
        ReaderUI:showReader(file)
        ReadHistory:removeItemByDirectory(path)
    end
    self:popup(name)
end

function Chitas:goToChapter(chapter)
    for _, k in ipairs(self.ui.toc.toc) do
        if k.title == chapter then
            self.ui:handleEvent(Event:new("GotoPage", tonumber(k.page)))
            break
        end
    end
    self:popup(chapter)
end

function Chitas:onChumash()
    local root = "/mnt/us/ebooks/epub/חומש/"
    local parshah, day = self:getParshah()
    if self.ui.view and self.ui.toc.toc ~= nil then --and self.ui.document.file == root .. name .. ".epub" then
        self:goToChapter(day)
    else
        self:switchToShuir(root, parshah)
    end
end

function Chitas:onShnaimMikrah()
    local parshah, _ = self:getParshah()
    self:switchToShuir("/mnt/us/ebooks/epub/שניים מקרא/", parshah)
end

return Chitas
