local MP = core.get_modpath("banners") .. "/"
dofile(MP .. "smartfs.lua")

banners = {
    version = 20241128.1533
}

banners.masks = {
    "bend_left", "bend_left_outline",
    "bend_right", "bend_right_outline",
    "central_circle", "central_circle_outline",
    "chevron_bottom", "chevron_bottom_outline",
    "chevron_top", "chevron_top_outline",
    "cross", "cross_outline",
    "nordic_cross", "nordic_cross_outline",
    "saltire", "saltire_outline",
    "mask_background", "david_star",
    "fleur_de_lis", "fullpentagram", "fullpentagram_outline",
    "greek_cross", "greek_cross_outline", "greek_cross_halfoutline",
    "triskel", "triskel_outline",
    "iron_cross", "iron_cross_outline",
    "hilal", "quadrisection_left",
    "quadrisection_right", "outline",
    "thirdfess_bottom", "thirdfess_middle", "thirdfess_top",
    "thirdpale_right", "thirdpale_middle", "thirdpale_left",
    "halfpale_right", "halfpale_left",
    "halffess_top", "halffess_down",
    "soviet_hammer_sickle", "per_bend_sinister_high",
    "per_bend_sinister_low", "per_bend_high", "per_bend_low",
    "canton", "star5_canton", "stripes_horiz_6", "stripes_horiz_4",
    "star_chevron", "checkered_8_4", "checkered_16_8"
}

-- It is now unlikely for the server to crash from too long
-- history since we now trim out garbage when converting to
-- metadata. This limit is now just to avoid run-time
-- memory bloat.
banners.max_undo_levels = 256

-- cache of player histories
local histories = {}

banners.colors = {
    "black", "cyan", "green", "white",
    "blue", "darkblue", "red", "yellow",
    "grey", "orange", "pink", "violet",
    "brown", "darkbrown"
}

local valid_masks = {}
local valid_colors = {}
do
    local i, s
    i = #banners.masks
    repeat
        s = banners.masks[i]
        valid_masks[s .. ".png"] = true
        i = i - 1
    until i == 0

    i = #banners.colors
    repeat
        s = banners.colors[i]
        valid_colors["bg_" .. s .. ".png"] = true
        i = i - 1
    until i == 0
end

banners.base_transform = {
    texture = "bg_white.png",
    mask = "mask_background.png"
}

function banners.creation_form_func(state)
    -- helper functions
    function state:update_player_inv(transform_string)
        local player = core.get_player_by_name(self.player)
        local newbanner = player:get_wielded_item()
        newbanner:get_meta():set_string("", transform_string)
        player:set_wielded_item(newbanner)
    end
    function state:update_preview(transform_string)
        self:get("banner_preview"):setImage(transform_string)
        self:get("color_indicator"):setImage(self.current_color)
    end
    function state:update_preview_inv()
        local transform_string = self.banner:get_transform_string()
        self:update_preview(transform_string)
        self:update_player_inv(transform_string)
    end
    if histories[state.player] then
        -- initialize with saved history
        state.banner = histories[state.player]
    else
        -- initialize with empty banner
        state.banner = banners.Banner:new(nil)
        state.banner:push_transform(banners.base_transform)
        histories[state.player] = state.banner
    end
    state.current_color = state.banner.color
    state:size(20, 10)
    state:image(3, 0.4, 4, 2, "banner_preview", nil)
    state:image(2.4, 0.8, 0.7, 0.7, "color_indicator", state.current_color)
    state:update_preview_inv()
    -- color indicator
    -- undo button
    state:button(0.5, 0.3, 2, 1, "undo", "Undo"):click(function(_, state2)
        if #state2.banner.transforms > 1 then
            state2.banner:pop_transform()
            state2:update_preview_inv()
        end
    end)
    -- delete button
    state:button(0.5, 1.3, 2, 1, "delete", "Delete"):click(function(_, state2)
        state2.banner.transforms = { banners.base_transform }
        state2:update_preview_inv()
    end)
    -- add banners colors
    local x = 7
    local y = .3
    for _, color in ipairs(banners.colors) do
        local b = state:button(x, y, 1, 1, color, "")
        b:setImage("bg_" .. color .. ".png")
        b:click(function(self, state2)
            state2.current_color = "bg_" .. self.name .. ".png"
            state2:get("color_indicator"):setImage(state2.current_color)
            state2.banner.color = state2.current_color
            -- update masks
            for _, mask in ipairs(banners.masks) do
                state2:get(mask):setImage("(" .. state2.current_color
                    .. "^[mask:" .. mask .. ".png^[makealpha:0,0,0)")
            end
        end)
        x = x + 1
        if x > 19 then
            y = y + 1
            x = 7
        end
    end
    -- add banners buttons
    x = 1
    y = 3
    for _, mask in ipairs(banners.masks) do
        local b = state:button(x, y, 2, 1, mask, "")
        b:setImage("(" .. state.current_color
            .. "^[mask:" .. mask .. ".png^[makealpha:0,0,0)")
        b:click(function(self, state2)
            state2.banner:push_transform({
                texture = state2.current_color,
                mask = self.name .. ".png"
            })
            state2:update_preview_inv()
        end)
        x = x + 2
        if x > 17.5 then
            y = y + 1
            x = 1
        end
    end
    return true
end

banners.creation_form = smartfs.create("banners:banner_creation",
    banners.creation_form_func)

function banners.transform_string_to_table(transform_string)
p('transform_string_to_table')
    local transforms = {}
    for part in transform_string:gmatch("%(([^%)]+)%)") do
        parts = part:split("^[")
        if 3 == #parts then
            texture = parts[1]
            mask = parts[2]:sub(6)
            if valid_masks[mask] and valid_colors[texture] then
                table.insert(transforms, {
                    texture = texture,
                    mask = mask
                })
            end
        end
    end
    return transforms
end

function banners.transform_table_to_string(transforms)
    local final = {}
    local used = {}
    local transform
    -- work backwards to keep resulting data small
    local i = #transforms
    if 0 == i then return "" end

    repeat
        transform = transforms[i]
        -- duplicate mask can be trimmed out only use most recent
        if not used[transform.mask] then
            used[transform.mask] = true
            table.insert(final, 1, "(" .. transform.texture
                .. "^[mask:" .. transform.mask .. "^[makealpha:0,0,0)")
            -- anything before a background is fully covered
            if "mask_background.png" == transform.mask then
                break
            end
        end
        i = i - 1
    until i == 0
    return table.concat(final, "^")
end

-- banner definition
banners.Banner = {}

function banners.Banner:new(banner)
p('new')
    banner = banner or { color = "bg_pink.png", transforms = {} }
    setmetatable(banner, self)
    self.__index = self
    return banner
end

function banners.Banner:push_transform(transform)
    table.insert(self.transforms, transform)
    if #self.transforms > banners.max_undo_levels then
        table.remove(self.transforms, 1)
    end
end

function banners.Banner:pop_transform()
    table.remove(self.transforms)
end

function banners.Banner:get_transform_string()
    return banners.transform_table_to_string(self.transforms)
end

end

-- helper function for determining the flag's direction
-- (pos, pointed_thing)
function banners.determine_flag_direction(_, pointed_thing)
    local above = pointed_thing.above
    local under = pointed_thing.under
    local dir = {
        x = under.x - above.x,
        y = under.y - above.y,
        z = under.z - above.z
    }
    return core.dir_to_wallmounted(dir)
end

-- (itemstack, player, pointed_thing)
function banners.banner_on_use(_, player)
    if player.is_player then
        banners.creation_form:show(player:get_player_name())
    end
end

function banners.banner_on_dig(pos, node, player)
    if not player or core.is_protected(pos, player:get_player_name()) then
		return
	end
    local meta = core.get_meta(pos)
    local inventory = player:get_inventory()
    inventory:add_item("main", {
        name = node.name,
        count = 1,
        wear = 0,
        metadata = meta:get_string("banner")
    })
    core.remove_node(pos)
end

-- (pos, node, player)
function banners.banner_on_destruct(pos)
    local objects = core.get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
        local e = v:get_luaentity()
        if e and e.name == "banners:banner_ent" then
            v:remove()
        end
    end
end

-- (pos, player, itemstack, pointed_thing)
function banners.banner_after_place(pos, _, itemstack, pointed_thing)
    core.get_node(pos).param2 = banners.determine_flag_direction(pos, pointed_thing)
    local meta = core.get_meta(pos)
    meta:set_string("banner", itemstack:get_meta():get_string(""))
    meta:set_float("version", banners.version)
    core.add_entity(pos, "banners:banner_ent")
end

-- banner entity

function banners:banner_on_activate()
    local pos = self.object:get_pos()
    local meta = core.get_meta(pos)
    local banner = meta:get_string("banner")
    -- cleanup meta of old banners
    if meta:get_float("version") < 20241122 then
        meta:set_float("version", banners.version)
        banner = banners.transform_table_to_string(
            banners.transform_string_to_table(banner))
        meta:set_string("banner", banner)
    end
    local banner_face = core.get_node(pos).param2
    local yaw = 0.
    if banner_face == 2 then
        yaw = 0.
    elseif banner_face == 0 then
        yaw = 3.141592653589793 -- pi, 180 degrees
    elseif banner_face == 1 then
        yaw = 1.5707963267948966 -- pi / 2
    elseif banner_face == 3 then
        yaw = 4.71238898038469 -- 3 * pi / 2
    end
    self.object:set_yaw(yaw)
    self.object:set_properties({
        textures = { "banner_uv_text.png^" .. banner }
    })
end

core.register_entity("banners:banner_ent", {
    initial_properties = {
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        visual = "mesh",
        textures = { "banner_uv_text" },
        mesh = "banner_pole.x",
    },
    on_activate = banners.banner_on_activate,
})

if core.get_modpath("factions") then
    dofile(MP .. "factions.lua")
end

dofile(MP .. "items.lua")
dofile(MP .. "nodes.lua")
dofile(MP .. "crafts.lua")

