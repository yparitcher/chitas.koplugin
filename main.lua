-- Requires libzmanim
-- luarocks --lua-version=5.1 install libzmanim CC=arm-kindlepw2-linux-gnueabi-gcc --tree=rocks
-- libzmanim.lua (ffi cdecl) in lua package path /usr/local/ or ~/luarocks/ lua/5.1/libzmanim.lua
-- libzmanim.so in linker path /usr/lib/
local libzmanim = require("libzmanim_load")

if not libzmanim then
    return { disabled = true, }
end

local Dispatcher = require("dispatcher")
local DocSettings = require("docsettings")
local Event = require("ui/event")
local FFIUtil = require("ffi/util")
local Font = require("ui/font")
local InfoMessage = require("ui/widget/infomessage")
local ReadHistory = require("readhistory")
local UIManager = require("ui/uimanager")
local Widget = require("ui/widget/widget")
local util = require("util")
local _ = require("gettext")
local ffi = require("ffi")
local C = ffi.C
require("ffi/rtc_h")

local Chitas = Widget:extend{
    name = "chitas",
    base = (G_reader_settings:readSetting("home_dir") or require("apps/filemanager/filemanagerutil").getDefaultDir()) .. "/epub/",
}

function Chitas:onDispatcherRegisterActions()
    Dispatcher:registerAction("chumash", {category="none", event="Chumash", title=_("Chumash"), general=true,})
    Dispatcher:registerAction("shnaimmikrah", {category="none", event="ShnaimMikrah", title=_("Shnaim Mikrah"), general=true,})
    Dispatcher:registerAction("rambam", {category="none", event="Rambam", title=_("Rambam"), general=true,})
    Dispatcher:registerAction("tanya", {category="none", event="Tanya", title=_("Tanya"), general=true,})
end

function Chitas:init()
    self:onDispatcherRegisterActions()
end

function Chitas:popup(text, timeout)
    local popup = InfoMessage:new{
        face = Font:getFace("ezra.ttf", 32),
        show_icon = false,
        text = text,
        lang = "he",
        para_direction_rtl = true,
        timeout = timeout,
        name = "Chitas_popup",
    }
    UIManager:show(popup)
end

function Chitas:getShuir(func, offset)
    local t = ffi.new("time_t[1]")
    t[0] = C.time(nil)
    local tm = ffi.new("struct tm") -- luacheck: ignore
    tm = C.localtime(t)
    local hdate = ffi.new("hdate[1]")
    hdate[0] = libzmanim.convertDate(tm[0])
    if offset then
        libzmanim.hdateaddday(hdate, offset)
    end
    local shuir = ffi.new("char[?]", 250)
    func(hdate[0], shuir)
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
        local tomorrow = self:getShuir(libzmanim.tanya, 1)
        local _, _, text = tomorrow:find("תניא\n(.*)\n.*")
        if not text then text = tomorrow or " " end
        self:popup(shuir .. "\n    ~~~\n" .. text)
        return true
    end
    return false
end

Chitas.onReaderReady = Chitas.displayTanya

function ReadHistory:removeItemByDirectory(directory)
    assert(self ~= nil)
    for i=1, #self.hist do
        if FFIUtil.realpath(FFIUtil.dirname(self.hist[i].file)) == FFIUtil.realpath(directory) then
            self:removeItem(self.hist[i])
            break
        end
    end
    self:ensureLastFile()
end

function Chitas:isNotRecent(file_path)
    local mtime = DocSettings:getLastSaveTime(file_path) or 0
    return os.time() - mtime > 604800
end

function Chitas:switchToShuir(path, name, chapter)
    local file = path .. name .. ".epub"
    if util.fileExists(file) then
        if self:isNotRecent(file) and chapter then
            Chitas.onReaderReady = function()
                Chitas:goToChapter(chapter)
                Chitas.onReaderReady = Chitas.displayTanya
            end
        end
        local ReaderUI = require("apps/reader/readerui")
        ReaderUI:showReader(file)
        ReadHistory:removeItemByDirectory(path)
    end
    self:popup(name, 1)
end

function Chitas:goToChapter(chapter)
    for _, k in ipairs(self.ui.toc.toc) do
        if k.title == chapter then
            self.ui.link:addCurrentLocationToStack()
            self.ui:handleEvent(Event:new("GotoPage", tonumber(k.page)))
            break
        end
    end
    self:popup(chapter, 1.2)
end

function Chitas:onTanya()
    if not self.ui.view or not self:displayTanya() then
        local ReaderUI = require("apps/reader/readerui")
        ReaderUI:showReader(self.base .. "tanya.epub")
    end
end

function Chitas:onChumash()
    local root = self.base .. "חומש/"
    local parshah, day = self:getParshah()
    local chapter = parshah:gsub("_", " ") .. " - " .. day
    if self.ui.view and self.ui.toc.toc ~= nil and self.ui.document.file == root .. parshah .. ".epub" then
        self:goToChapter(chapter)
    else
        self:switchToShuir(root, parshah, chapter)
    end
end

function Chitas:onShnaimMikrah()
    local parshah, _ = self:getParshah()
    self:switchToShuir(self.base .. "שניים מקרא/", parshah)
end

function Chitas:onRambam()
    local root = self.base .. "רמבם/"
    --local sefer = "???????"
    local shuir = self:getShuir(libzmanim.rambam)
    local _, _, perek = shuir:find("רמב״ם\n(.*)")
--require("logger").warn("@@@@", perek)
    perek = perek:gsub("\n", " - ")
--require("logger").warn("@@@@", perek)
    if self.ui.view and self.ui.toc.toc ~= nil and util.stringStartsWith(self.ui.document.file, root) then
        self:goToChapter(" " .. perek)
--require("logger").warn("@@@@", self.ui.toc.toc)
    else
        self.ui:handleEvent(Event:new("BookShortcut", root))
    end
end

return Chitas
