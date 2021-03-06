pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
--require("collision")()
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
--require("eminent")
--require("email")
require("json")
local wibox = require("wibox")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
}

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

menubar.utils.terminal = terminal -- Set the terminal for applications that require it

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Hide all empty tags
    --s.mytaglist = awful.widget.taglist {
       --screen = s,
       --filter = function (t) return t.selected or #t:clients() > 0 end,
       --buttons = taglist_buttons
   --}
-- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
    local volumebar_widget = require("awesome-wm-widgets.volumebar-widget.volumebar")
    local volume_widget = require("awesome-wm-widgets.volume-widget.volume")
    local netspeed_widget = require("awesome-wm-widgets.net-speed-widget.net-speed")
    local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
    local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
    local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")
    local brightnessarc_widget = require("awesome-wm-widgets.brightnessarc-widget.brightnessarc")
    local storage_widget = require("awesome-wm-widgets.fs-widget.fs-widget")
    local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
    local volumearc_widget = require("awesome-wm-widgets.volumearc-widget.volumearc")
    local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
    mytextclock = wibox.widget.textclock()

    local cw = calendar_widget({
       theme = 'nord',
       placement = 'top_left'
    }),

    s.mywibox:setup {
       layout = wibox.layout.align.horizontal,
       { -- Right widgets
          mytextclock,
          layout = wibox.layout.fixed.horizontal,
          cpu_widget({
             width = 70,
             step_width = 2,
             step_spacing = 0,
             color = '#434c5e'
          }),
          volumebar_widget({
             main_color = '#af13f7',
             mute_color = '#ff0000',
             width = 50,
             shape = 'rounded_bar', -- octogon, hexagon, powerline, etc
             -- bar's height = wibar's height minus 2x margins
             margins = 8
          }),
          volumearc_widget({
             button_press = function(_, _, _, button)   -- Overwrites the button press behaviour to open pavucontrol when clicked
                if (button == 1) then awful.spawn('pavucontrol --tab=3', false)
                end
             end }),
             --volume_widget({display_notification = true}), --icons are needed!
             netspeed_widget(),
             --battery_widget({
             --display_notification = true,
             --notification_position = 'top_left',
             --show_current_level = true,
             --enable_battery_warning = true
             --}),
             batteryarc_widget({
                show_current_level = true,
                arc_thickness = 1,
             }),
             brightnessarc_widget(),
             --email_icon,
             --email_widget,
             storage_widget({ mounts = { '/', '/home' } }), -- multiple mounts
             --wibox.widget.textbox(':'),
             ram_widget({
                display_labels = true,
             }),
             weather_widget({
                api_key='637bfed03fbf6f0c45e0757f9c5b3d81',
                coordinates = {46.770920, 23.589920},
                show_hourly_forecast = true,
                show_daily_forecast = true,
             }),
       }
    }

    mytextclock:connect_signal("button::press", 
    function(_, _, _, button)
       if button == 1 then cw.toggle() end
    end)

end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ }, "Print", function () awful.spawn.with_shell("maim -s screenshot-selection-$(date '+%y%m%d-%H%M-%S').png") end),
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "p",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "n",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "b", awful.tag.history.restore,
              {description = "toggle between current and previous tags", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Shift"           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift"   }, "l", function () awful.spawn("betterlockscreen -l dim") end,
              {description = "lock screen", group = "robcsi"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "robcsi"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey,           }, "z",     function () awful.tag.incgap(1)          end,
              {description = "increase tag gap", group = "layout"}),
    awful.key({ modkey,           }, "x",     function () awful.tag.incgap(-1)          end,
              {description = "decrease tag gap", group = "layout"}),

    --awful.key({ modkey, "Control" }, "n",
              --function ()
                  --local c = awful.client.restore()
                  ---- Focus restored client
                  --if c then
                    --c:emit_signal(
                        --"request::activate", "key.unminimize", {raise = true}
                    --)
                  --end
              --end,
              --{description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ "Shift" },            "space",     function () 
    awful.util.spawn("rofi -show run") end,
      {description = "rofi run", group = "laucher"}),

    -- Launch Browser
    awful.key({ modkey },            "w",     function () 
    awful.util.spawn("firefox") end,
      {description = "launch browser (firefox)", group = "robcsi"}),

    -- Launch Caja
    awful.key({ modkey },            "e",     function () 
    awful.util.spawn("caja") end,
      {description = "launch file manager (caja)", group = "robcsi"}),

    -- Launch vifm
    awful.key({ modkey },            "r",     function () 
    awful.util.spawn(terminal .. " -e vifm") end,
      {description = "launch file manager (vifm)", group = "robcsi"}),

    -- Launch gotop
    awful.key({ modkey , "Shift" },            "r",     function () 
    awful.util.spawn(terminal .. " -e gotop") end,
      {description = "launch gotop", group = "robcsi"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "robcsi"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, }, "v", function (c) client.focus = awful.client.getmaster(); client.focus:raise() end,
              {description = "focus back to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    -- awful.key({ modkey,           }, "n",
    --     function (c)
    --         -- The client currently has the input focus, so it cannot be
    --         -- minimized, since minimized clients can't have the focus.
    --         c.minimized = true
    --     end ,
    --     {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),

    awful.key({ modkey },            "space", function (c)
          if client.focus == awful.client.getmaster() then
             awful.client.swap.bydirection("right")
          else
             c:swap(awful.client.getmaster())
          end
          client.focus = awful.client.getmaster()
          client.focus:raise();
       end ,
       {description = "make client on right master", group = "layout"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 2,
                     border_color = beautiful.border_normal, 
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "MessageWin",  -- kalarm.
          "Wpa_gui",
          "Artha",
          "Orage"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true, center = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Adding gaps
beautiful.useless_gap = 5
beautiful.border_normal = "#3F3F3F"
beautiful.border_focus  = "#2aa198"
beautiful.border_marked = "#CC9393"

-- Autostart
awful.spawn.with_shell("compton")
awful.spawn.with_shell("nm-applet")
awful.spawn("artha")
awful.spawn.with_shell("mate-power-manager")
awful.spawn.with_shell("mate-volume-control-applet")
awful.spawn("orage")
awful.spawn.with_shell("dunst")
awful.spawn.with_shell("/home/robcsi/.config/polybar/launch.sh")
--awful.spawn.with_shell("feh --bg-fill --randomize ~/wallpapers")
awful.spawn.with_shell("killall -q nitrogen || nitrogen --random --set-scaled /home/robcsi/wallpapers/")
