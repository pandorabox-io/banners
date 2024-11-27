
-- craft recipes

-- wooden flag pole
core.register_craft({
    output = "banners:wooden_pole 1",
    recipe = {
        { "", "", "default:stick" },
        { "", "default:stick", "" },
        { "default:stick", "", "" }
    }
})

-- steel flag pole
core.register_craft({
    output = "banners:steel_pole 1",
    recipe = {
        { "", "", "default:steel_ingot" },
        { "default:stick", "default:steel_ingot", "default:stick" },
        { "default:steel_ingot", "", "" }
    }
})

-- wooden flag support base
core.register_craft({
    output = "banners:wooden_base 1",
    recipe = {
        { "", "default:stick", "" },
        { "default:stick", "", "default:stick" },
        { "group:wood", "group:wood", "group:wood" }
    }
})

-- steel support
core.register_craft({
    output = "banners:steel_base",
    recipe = {
        { "", "default:steel_ingot", "" },
        { "default:steel_ingot", "", "default:steel_ingot" },
        { "", "default:steelblock", "" }
    }
})

-- banner sheet
core.register_craft({
    output = "banners:banner_sheet 1",
    recipe = {
        { "", "", "" },
        { "farming:cotton", "farming:cotton", "farming:cotton" },
        { "farming:cotton", "farming:cotton", "farming:cotton" }
    }
})

-- wooden support
core.register_craft({
    output = "banners:wooden_banner 1",
    recipe = {
        { "", "banners:banner_sheet", "" },
        { "", "banners:wooden_pole", "" },
        { "", "banners:wooden_base", "" }
    }
})

-- steel support
core.register_craft({
    output = "banners:steel_banner 1",
    recipe = {
        { "", "banners:banner_sheet", "" },
        { "", "banners:steel_pole", "" },
        { "", "banners:steel_base", "" }
    }
})

