-- Trap stone
minetest.register_node("bls:fake_stone", {
    description = "Fake Stone",
    tiles = {"default_stone.png"},
    walkable = false,
    groups = {cracky = 3, stone = 1, not_in_creative_inventory=1},
})

if minetest.get_modpath("nether") and minetest.global_exists("default") then
    minetest.register_node("bls:fake_glowstone", {
        description = "Fake Glowstone",
        tiles = {"nether_glowstone.png"},
        walkable = false,
        light_source = 14,
        paramtype = "light",
        groups = {cracky = 3, oddly_breakable_by_hand = 3, not_in_creative_inventory=1},
        sounds = default.node_sound_glass_defaults(),
        on_blast = function (pos, intensity) end
    })
end

