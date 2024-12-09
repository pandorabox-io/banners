-- da wooden banner
core.register_node("banners:wooden_banner", {
    drawtype = "mesh",
    mesh = "banner_support.x",
    tiles = { "banner_support.png" },
    description = "Wooden banner",
    groups = { choppy = 2, dig_immediate = 2 },
    is_ground_content = false,
    diggable = true,
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    after_place_node = banners.banner_after_place,
    on_destruct = banners.banner_on_destruct,
    on_use = banners.banner_on_use,
    on_dig = banners.banner_on_dig,
    on_movenode = banners.banner_on_movenode,
})

-- steel banner
core.register_node("banners:steel_banner", {
    drawtype = "mesh",
    mesh = "banner_support.x",
    tiles = { "steel_support.png" },
    description = "Steel banner",
    groups = { cracky = 2 },
    is_ground_content = false,
    diggable = true,
    stack_max = 1,
    paramtype = "light",
    paramtype2 = "facedir",
    after_place_node = banners.banner_after_place,
    on_destruct = banners.banner_on_destruct,
    on_use = banners.banner_on_use,
    on_dig = banners.banner_on_dig,
    on_movenode = banners.banner_on_movenode,
})

