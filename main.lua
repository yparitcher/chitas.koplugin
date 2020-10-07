local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local util = require("ffi/util")
local _ = require("gettext")
local ffi = require("ffi")
local C = ffi.C
require("ffi/rtc_h")
local libzmanim = ffi.load("plugins/tanya.koplugin/libzmanim.so")
require("libzmanim")

local Chitas = WidgetContainer:new{
    name = "thitas",
    is_doc_only = true,
}

function Chitas:init()
    table.insert(self.ui.postReaderCallback, function()
        self:displayTanya()
    end)
end

function Chitas:displayTanya()
    if util.basename(self.document.file) == "tanya.epub" then
        local t = ffi.new("time_t[1]")
        t[0] = C.time(nil)
        local tm = ffi.new("struct tm") -- luacheck: ignore
        tm = C.localtime(t)
        local hdate = libzmanim.convertDate(tm[0])
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

return Chitas
