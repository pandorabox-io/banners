-- Due to some engine troubles there are sometimes stray
-- banner entities and more rarely there are banner nodes without entities.
-- Calling this command fixes both situations.
core.register_chatcommand("banners_fix", {
    description = "recreates the banner-visuals in your area",
    func = function(name)
        local player = core.get_player_by_name(name)
        if not player then
            return
        end

        local pos = player:get_pos()
        local t1 = core.get_us_time()

        local radius = 10
        local entity_count = 0
        local objects = core.get_objects_inside_radius(pos, radius)
        for _, v in ipairs(objects) do
            local e = v:get_luaentity()
            if e and e.name == "banners:banner_ent" then
                entity_count = entity_count + 1
                v:remove()
            end
        end

        local pos1 = vector.subtract(pos, radius)
        local pos2 = vector.add(pos, radius)
        local nodes = {
            "banners:wooden_banner",
            "banners:steel_banner",
        }
        if core.get_modpath("factions") then
            table.insert_all(nodes, {
                "banners:power_banner",
                "banners:death_banner",

            })
        end
        local pos_list = core.find_nodes_in_area(pos1, pos2, nodes)

        for _, node_pos in ipairs(pos_list) do
            core.add_entity(node_pos, "banners:banner_ent")
        end

        local t2 = core.get_us_time()
        local diff = t2 - t1
        local millis = diff / 1000

        return true, "Removed " .. entity_count .. " banner entities and restored "
            .. #pos_list .. " banners in " .. millis .. " ms"
    end
})

