dofile(minetest.get_modpath("banners").."/smartfs.lua")

banners = {}

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

banners.colors = {
    "black", "cyan", "green", "white",
    "blue", "darkblue", "red", "yellow",
    "grey", "orange", "pink", "violet",
    "brown", "darkbrown"
}

banners.base_transform = ({texture = "bg_black.png", mask="mask_background.png"})

banners.creation_form = smartfs.create("banners:banner_creation",
        function(state)
            -- helper functions
            state.update_player_inv = function(self)
                local player = minetest.get_player_by_name(self.player)
                local newbanner = player:get_wielded_item()
                newbanner:set_metadata(state.banner:get_transform_string())
                player:set_wielded_item(newbanner)
            end
            state.update_preview = function(self)
                self:get("banner_preview"):setImage(state.banner:get_transform_string())
            end
            state.update_all = function(self)
                self:update_preview()
                self:update_player_inv()
            end
            -- initialize with empty banner
            state.banner = banners.Banner:new(nil)
            state.banner:push_transform(banners.base_transform)
            state.current_color = "bg_black.png"
            state:size(20,10)
            state:image(3, 0.4, 4, 2, "banner_preview", state.banner:get_transform_string())
            -- undo button
            state:button(0.5, 0.3, 2, 1, "undo", "Undo"):click(function(self, state)
                    if #state.banner.transforms > 1 then
                        state.banner:pop_transform()
                        state:update_all()
                    end
                end)
            -- delete button
            state:button(0.5, 1.3, 2, 1, "delete", "Delete"):click(function(self, state)
                    state.banner.transforms = {banners.base_transform}
                    state:update_all()
                end)
            -- add banners colors
            local x = 7
            local y = .3
            for i in ipairs(banners.colors) do 
                local b = state:button(x, y, 1, 1, banners.colors[i], "")
                b:setImage("bg_"..banners.colors[i]..".png")
                b:click(function(self, state)
                            state.current_color = "bg_"..self.name..".png"
                            -- todo: update masks or something
                        end
                    )
                x = x + 1
                if x > 19 then
                    y = y + 1
                    x = 7
                end
            end
            -- add banners buttons
            local x = 1
            local y = 3
            for i in ipairs(banners.masks) do
                local b = state:button(x, y, 2, 1, banners.masks[i], "")
                b:setImage(banners.masks[i]..".png")
                b:click(function(self, state)
                            state.banner:push_transform({texture=state.current_color, mask=self.name..".png"})
                            state:update_all()
                        end
                )
                x = x + 2
                if x > 17.5 then
                    y = y + 1
                    x = 1
                end
            end
            return true
        end
    )


-- banner definition
banners.Banner = {
    transforms = {}
}
function banners.Banner:new(banner)
    banner = banner or {}
    setmetatable(banner, self)
    self.__index = self
    return banner
end
function banners.Banner.push_transform(self, transform)
    table.insert(self.transforms, transform)
end
function banners.Banner.pop_transform(self)
    table.remove(self.transforms)
end
function banners.Banner.get_transform_string(self)
    local final = {}
    for i in ipairs(self.transforms) do
        table.insert(final, "("..self.transforms[i].texture.."^[mask:"..self.transforms[i].mask.."^[makealpha:0,0,0)")
    end
    local ret = table.concat(final, "^")
    return ret
end

-- helper function for determining the flag's direction
local determine_flag_direction
determine_flag_direction = function(pos, pointed_thing)
    local above = pointed_thing.above
    local under = pointed_thing.under
    local dir = {x = under.x - above.x,
                 y = under.y - above.y,
                 z = under.z - above.z}
    return minetest.dir_to_wallmounted(dir)
end

-- da wooden banner
minetest.register_node("banners:wooden_banner",
    {
        drawtype = "mesh",
        mesh = "banner_support.x",
        tiles = {"banner_support.png"},
        description = "Wooden banner",
        groups = {choppy=2, dig_immediate=2},
        diggable = true,
        stack_max = 1,
        paramtype="light",
        paramtype2="facedir",
        after_place_node = function (pos, player, itemstack, pointed_thing)
            minetest.get_node(pos).param2 = determine_flag_direction(pos, pointed_thing)
            minetest.get_meta(pos):set_string("banner", itemstack:get_metadata())
            minetest.add_entity(pos, "banners:banner_ent")
        end,
        on_destruct = function(pos)
            local objects = minetest.get_objects_inside_radius(pos, 0.5)
            for _,v in ipairs(objects) do
                local e = v:get_luaentity()
                if e and e.name == "banners:banner_ent" then
                    v:remove()
                end
            end
        end,
        on_use = function(itemstack, player, pointed_thing)
            if player.is_player then
                banners.creation_form:show(player:get_player_name())
            end
        end,
        on_dig = function(pos, node, player)
            local meta = minetest.get_meta(pos)
            local inventory = player:get_inventory()
            inventory:add_item("main", {name=node.name, count=1, wear=0, metadata=meta:get_string("banner")})
            minetest.remove_node(pos)
        end
    }
)


-- banner entity
local set_banner_texture
set_banner_texture = function (obj, texture)
    obj:set_properties({textures={"banner_uv_text.png^"..texture}})
end

local banner_on_activate

local banner_on_activate = function(self)
    local pos = self.object:getpos()
    local banner = minetest.get_meta(pos):get_string("banner")
    local banner_face = minetest.get_node(pos).param2
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
    self.object:setyaw(yaw)
    if banner then
        set_banner_texture(self.object, banner)
    end
end

minetest.register_entity("banners:banner_ent",
    {
        collisionbox = {0,0,0,0,0,0},
        visual = "mesh",
        textures = {"banner_uv_text"},
        mesh = "banner_pole.x",
        on_activate = banner_on_activate,
    }
)


-- items

minetest.register_craftitem("banners:banner_sheet",
    {
        groups = {},
        description = "Banner sheet",
        inventory_image = "banner_sheet.png",
        stack_max = 1,
        metadata = "",
    }
)

minetest.register_craftitem("banners:wooden_pole",
    {
        groups = {},
        description = "Wooden pole",
        inventory_image = "wooden_pole.png"
    }
)

minetest.register_craftitem("banners:wooden_base",
    {
        groups = {},
        description = "Wooden Base",
        inventory_image = "wooden_base.png"
    }
)

-- craft recipes
minetest.register_craft( -- wooden flag pole
    {
        output = "banners:wooden_pole 1",
        recipe = {
            {"", "", "default:stick"},
            {"", "default:stick", ""},
            {"default:stick", "", ""}
        }
    }
)

minetest.register_craft( -- wooden flag support base
    {
        output = "banners:wooden_base 1",
        recipe = {
            {"", "default:stick", ""},
            {"default:stick", "", "default:stick"},
            {"default:wood", "default:wood", "default:wood"}
        }
    }
)

minetest.register_craft( -- banner sheet
    {
        output = "banners:banner_sheet 1",
        recipe = {
            {"", "", ""},
            {"farming:cotton", "farming:cotton", "farming:cotton"},
            {"farming:cotton", "farming:cotton", "farming:cotton"}
        }
    }
)

minetest.register_craft( -- banner support
    {
        output = "banners:wooden_banner 1",
        recipe = {
            {"", "banners:banner_sheet", ""},
            {"", "banners:wooden_pole", ""},
            {"", "banners:wooden_base", ""}
        }
    }
)

