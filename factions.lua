banners.power_per_banner = 10.

-- items
core.register_craftitem("banners:golden_finial", {
    groups = {},
    description = "Golden finial",
    inventory_image = "gold_finial.png",
})

core.register_craftitem("banners:silver_pole", {
    groups = {},
    description = "Silver pole",
    inventory_image = "silver_pole.png"
})

core.register_craftitem("banners:power_pole", {
    groups = {},
    description = "Power pole",
    inventory_image = "power_pole.png"
})

core.register_craftitem("banners:golden_sheet", {
    groups = {},
    description = "Golden sheet",
    inventory_image = "golden_sheet.png"
})

core.register_craftitem("banners:death_pole", {
    groups = {},
    description = "Death pole",
    inventory_image = "death_pole.png"
})

core.register_craftitem("banners:death_sheet", {
    groups = {},
    description = "Death sheet",
    inventory_image = "death_sheet.png"
})

core.register_craftitem("banners:death_base", {
    groups = {},
    description = "Death base",
    inventory_image = "death_base.png"
})


-- crafts

-- silver flag pole
core.register_craft({
    output = "banners:silver_pole 1",
    recipe = {
        { "", "", "moreores:silver_ingot" },
        { "", "moreores:silver_ingot", "" },
        { "moreores:silver_ingot", "", "" }
    }
})

-- death flag pole
core.register_craft({
    output = "banners:death_pole 1",
    recipe = {
        { "", "", "default:diamond" },
        { "", "default:obsidian", "" },
        { "default:obsidian", "", "" }
    }
})

-- golden finial
core.register_craft({
    output = "banners:golden_finial",
    recipe = {
        { "", "default:gold_ingot", "default:gold_ingot" },
        { "", "default:gold_ingot", "default:gold_ingot" },
        { "default:gold_ingot", "", "" }
    }
})

-- power flag pole
core.register_craft({
    output = "banners:power_pole 1",
    recipe = {
        { "", "", "" },
        { "", "banners:golden_finial", "" },
        { "banners:silver_pole", "", "" }
    }
})

-- golden sheet
core.register_craft({
    output = "banners:golden_sheet 1",
    type = "shapeless",
    recipe = { "default:gold_ingot", "banners:banner_sheet" }
})

-- death sheet
core.register_craft({
    output = "banners:death_sheet 1",
    type = "shapeless",
    recipe = { "default:obsidian", "banners:banner_sheet" }
})

-- death sheet
core.register_craft({
    output = "banners:death_base 1",
    recipe = {
        { "", "", "" },
        { "", "banners:steel_base", "" },
        { "default:obsidian", "default:obsidian", "default:obsidian" }
    }
})

-- power banner
core.register_craft({
    output = "banners:power_banner",
    recipe = {
        { "", "banners:golden_sheet", "" },
        { "", "banners:power_pole", "" },
        { "", "banners:steel_base", "" }
    }
})

-- death banner
core.register_craft({
    output = "banners:death_banner",
    recipe = {
        { "", "banners:death_sheet", "" },
        { "", "banners:death_pole", "" },
        { "", "banners:death_base", "" }
    }
})


-- nodes
core.register_node("banners:power_banner", {
    drawtype = "mesh",
    mesh = "banner_support.x",
    tiles = { "gold_support.png" },
    description = "Power Banner",
    groups = { cracky = 3 },
    is_ground_content = false,
    diggable = true,
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    after_place_node = banners.after_powerbanner_placed,
    on_destruct = banners.banner_on_destruct,
    on_dig = function(pos, n, p)
        if core.is_protected(pos, p:get_player_name()) then
            return
        end
        local meta = core.get_meta(pos)
        local facname = meta:get_string("faction")
        if facname then
            local faction = factions.factions[facname]
            if faction then
                faction:decrease_maxpower(banners.power_per_banner)
            end
        end
        banners.banner_on_dig(pos, n, p)
    end,
    on_movenode = banners.banner_on_movenode,
})

core.register_node("banners:death_banner", {
    drawtype = "mesh",
    mesh = "banner_support.x",
    tiles = { "death_uv.png" },
    description = "Death Banner",
    groups = { cracky = 3 },
    is_ground_content = false,
    diggable = true,
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    after_place_node = banners.after_deathbanner_placed,
    on_destruct = banners.banner_on_destruct,
    -- (pos, node, player)
    on_dig = function(pos, _, player)
        if core.is_protected(pos, player:get_player_name()) then
            return
        end
        local meta = core.get_meta(pos)
        local defending_facname = meta:get_string("faction")
        local parcelpos = factions.get_parcel_pos(pos)
        if defending_facname then
            local faction = factions.factions[defending_facname]
            if faction then
                faction:stop_attack(parcelpos)
            end
        end
        core.remove_node(pos)
    end,
    on_movenode = banners.banner_on_movenode,
})

-- (pos, player, itemstack, pointed_thing)
banners.after_powerbanner_placed = function(pos, player, _, pointed_thing)
    core.get_node(pos).param2 = banners.determine_flag_direction(pos, pointed_thing)
    local faction = factions.players[player:get_player_name()]
    if not faction then
        core.get_meta(pos):set_string("banner", "bg_white.png")
    else
        local banner_string = factions.factions[faction].banner
        core.get_meta(pos):set_string("banner", banner_string)
        core.get_meta(pos):set_string("faction", faction)
        factions.factions[faction]:increase_maxpower(banners.power_per_banner)
    end
    core.add_entity(pos, "banners:banner_ent")
end

-- (pos, player, itemstack, pointed_thing)
banners.after_deathbanner_placed = function(pos, player, _, pointed_thing)
    core.get_node(pos).param2 = banners.determine_flag_direction(pos, pointed_thing)
    local attacking_faction = factions.players[player:get_player_name()]
    if attacking_faction then
        local parcelpos = factions.get_parcel_pos(pos)
        attacking_faction = factions.factions[attacking_faction]
        attacking_faction:attack_parcel(parcelpos)
        core.get_meta(pos):set_string("faction", attacking_faction.name)
    end
    core.get_meta(pos):set_string("banner", "death_uv.png")
    core.add_entity(pos, "banners:banner_ent")
end

