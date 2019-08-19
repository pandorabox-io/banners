
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

minetest.register_craft( -- steel flag pole
    {
        output = "banners:steel_pole 1",
        recipe = {
            {"", "", "default:steel_ingot"},
            {"default:stick", "default:steel_ingot", "default:stick"},
            {"default:steel_ingot", "", ""}
        }
    }
)

minetest.register_craft( -- wooden flag support base
    {
        output = "banners:wooden_base 1",
        recipe = {
            {"", "default:stick", ""},
            {"default:stick", "", "default:stick"},
            {"group:wood", "group:wood", "group:wood"}
        }
    }
)

minetest.register_craft( -- steel support
    {
        output = "banners:steel_base",
        recipe = {
            {"", "default:steel_ingot", ""},
            {"default:steel_ingot", "", "default:steel_ingot"},
            {"", "default:steelblock", ""}
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

minetest.register_craft( -- wooden support
    {
        output = "banners:wooden_banner 1",
        recipe = {
            {"", "banners:banner_sheet", ""},
            {"", "banners:wooden_pole", ""},
            {"", "banners:wooden_base", ""}
        }
    }
)

minetest.register_craft( -- steel support
    {
        output = "banners:steel_banner 1",
        recipe = {
            {"", "banners:banner_sheet", ""},
            {"", "banners:steel_pole", ""},
            {"", "banners:steel_base", ""}
        }
    }
)
