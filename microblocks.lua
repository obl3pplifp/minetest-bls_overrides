local get_modpath = minetest.get_modpath
local global_exists = minetest.global_exists
local registered_nodes = minetest.registered_nodes

local has_stairsplus = global_exists("stairsplus")
local has_facade = global_exists("facade")
local has_letters = minetest.get_modpath("letters")

local function most_common_in_table(t)
    local counts = {}
    for _, item in ipairs(t) do
        counts[item] = (counts[item] or 0) + 1
    end
    local most_common
    local count = 0
    for item, item_count in pairs(counts) do
        if item_count > count then
            most_common = item
            count = item_count
        end
    end
    return most_common
end

local function register_letters(recipe_item)
    local modname, subname = recipe_item:match("^([^:]+):([^:]+)$")
    local def = registered_nodes[recipe_item]
    if not def then
        bls.log("warning", "microblocks: No def for %s", recipe_item)
        return
    end
    if def.drawtype == "normal" and not registered_nodes[("%s:%s_letter_au"):format(modname, subname)] then
        local tiles
        if type(def.tiles) == "string" then
            tiles = def.tiles
        elseif type(def.tiles) == "table" and #def.tiles > 0 then
            tiles = most_common_in_table(def.tiles)
        end
        if tiles then
            letters.register_letters(modname, subname, recipe_item, def.description, tiles)
        end
    end
end

local function register(recipe_item, make_stairs, make_facade, make_letters)
    local modname, subname = recipe_item:match("^([^:]+):([^:]+)$")
    if not (modname and subname) then
        bls.log("warning", "microblocks: %s is not a valid name", recipe_item)
        return
    end
    local def = registered_nodes[recipe_item]
    if not def then
        bls.log("warning", "microblocks: No def for %s", recipe_item)
        return
    end
    if make_stairs == nil then make_stairs = true end
    if make_facade == nil then make_facade = true end
    if make_letters == nil then make_letters = false end

    if has_stairsplus and make_stairs then
        -- TODO: figure out a check to see if these are already registered?
        stairsplus:register_all(modname, subname, recipe_item, def)
    end

    if has_facade and make_facade then
        if def.drawtype == "normal" and not registered_nodes[("facade:%s_bannerstone"):format(subname)] then
                 facade.register_facade_nodes(modname, subname, recipe_item, def.description or subname)
        end
    end

    -- letter cutter: adding letters increases lag (and load time) hugely
    if has_letters and make_letters then
        register_letters(recipe_item)
    end
end

-- This is done so we can add them back in more easily if we need them
-- and because some mods register them automatically so we cannot just remove the registrations easily
local ignore_variations = {
    {"artdeco","1c"},
    {"artdeco","1d"},
    {"artdeco","1f"},
    {"artdeco","1g"},
    {"artdeco","1i"},
    {"artdeco","1j"},
    {"artdeco","1k"},
    {"artdeco","1l"},
    {"artdeco","2b"},
    {"artdeco","decoblock2"},
    {"artdeco","decoblock4"},
    {"artdeco","decoblock5"},
    {"artdeco","tile5"},
    {"moreblocks","clean_glow_glass"},
    {"moreblocks","clean_super_glow_glass"},
    {"moreblocks","desert_cobble_compressed"},
    {"moreblocks","tar"},
    {"my_door_wood","wood_brown"},
    {"my_door_wood","wood_grey"},
    {"scifi_nodes","blackoct"},
    {"scifi_nodes","blackpipe"},
    {"scifi_nodes","blackvnt"},
    {"scifi_nodes","bluetile"},
    {"scifi_nodes","doomengine"},
    {"scifi_nodes","doomlight"},
    {"scifi_nodes","doomwall2"},
    {"scifi_nodes","doomwall4"},
    {"scifi_nodes","doomwall41"},
    {"scifi_nodes","doomwall42"},
    {"scifi_nodes","doomwall43"},
    {"scifi_nodes","doomwall431"},
    {"scifi_nodes","doomwall44"},
    {"scifi_nodes","fan"},
    {"scifi_nodes","green2"},
    {"scifi_nodes","greenbar"},
    {"scifi_nodes","greenlights"},
    {"scifi_nodes","greenlights2"},
    {"scifi_nodes","greenmetal2"},
    {"scifi_nodes","greybolts"},
    {"scifi_nodes","greygreenbar"},
    {"scifi_nodes","holes"},
    {"scifi_nodes","octofloor"},
    {"scifi_nodes","octofloor2"},
    {"scifi_nodes","pplblk"},
    {"scifi_nodes","ppllght"},
    {"scifi_nodes","pplwll3"},
    {"scifi_nodes","purple"},
    {"scifi_nodes","red"},
    {"scifi_nodes","red_square"},
    {"scifi_nodes","rock2"},
    {"scifi_nodes","rust"},
    {"scifi_nodes","screen3"},
    {"scifi_nodes","stripes2top"},
    {"technic","blast_resistant_concrete"},
    {"technic","cast_iron_block"},
    {"technic","marble"},
    {"technic","marble_bricks"},
    {"techpack_stairway","lattice"},
    {"terumet","block_coke"},
    {"terumet","block_con_orange"},
    {"terumet","block_con_pink"},
    {"terumet","block_entropy"},
}
for _,ignore_variation in ipairs(ignore_variations) do
    stairsplus.remove_all_and_ignore(ignore_variation[1], ignore_variation[2], ignore_variation[3] or (ignore_variation[1] .. ":" .. ignore_variation[2]))
end

local COLORS = {
    "black", "blue", "brown", "cyan", "dark_green", "dark_grey", "green", "grey",
    "magenta", "orange", "pink", "red", "violet", "white", "yellow"
}

local function register_colors(name_pattern, make_stairs, make_facade, make_letters)
    for _, color in ipairs(COLORS) do
        register(name_pattern:format(color), make_stairs, make_facade, make_letters)
    end
end

if get_modpath("asteroid") or get_modpath("other_worlds") then
    register("asteroid:cobble", nil, false)
    register("asteroid:dust", nil, false)
    register("asteroid:gravel", nil, false)
    register("asteroid:redcobble", nil, false)
    register("asteroid:reddust", nil, false)
    register("asteroid:redgravel", nil, false)
end

if get_modpath("bakedclay") then
    for _, color in ipairs(COLORS) do
        register_letters("bakedclay:" .. color, nil, false)
    end
end

if get_modpath("basic_materials") then
    register("basic_materials:brass_block", nil, false)
    register("basic_materials:cement_block", nil, false)
    register("basic_materials:concrete_block", nil, false)
end

if get_modpath("caverealms") then
    register("caverealms:coal_dust", nil, false)
    register("caverealms:glow_amethyst", nil, false)
    register("caverealms:glow_amethyst_ore", nil, false)
    register("caverealms:glow_crystal", nil, false)
    register("caverealms:glow_emerald", nil, false)
    register("caverealms:glow_emerald_ore", nil, false)
    register("caverealms:glow_mese", nil, false)
    register("caverealms:glow_obsidian", nil, false)
    register("caverealms:glow_obsidian_2", nil, false)
    register("caverealms:glow_ore", nil, false)
    register("caverealms:glow_ruby", nil, false)
    register("caverealms:glow_ruby_ore", nil, false)
    register("caverealms:hot_cobble", nil, false)
    register("caverealms:mushroom_cap", nil, false)
    register("caverealms:mushroom_stem", nil, false)
    register("caverealms:salt_crystal", nil, false)
    register("caverealms:stone_with_salt", nil, false)
    register("caverealms:thin_ice", nil, false)
end

if get_modpath("cblocks") then
    register_colors("cblocks:glass_%s")
end

if get_modpath("cottages") then
    register("cottages:hay", nil, false)
    register("cottages:loam")
    register("cottages:reet", nil, false)
    register("cottages:slate_vertical", nil, false)
end

if get_modpath("default") then
    -- for some reason, moreblocks doesn't register ice, so do this the "default" way
    stairsplus:register_all("moreblocks", "ice", "default:ice", minetest.registered_nodes["default:ice"])
    stairsplus:register_alias_force_all("default", "ice", "moreblocks", "ice")
end

if get_modpath("extra") then
    register("extra:cobble_condensed", nil, false)
end

if get_modpath("farming") then
    register("farming:chocolate_block", nil, false)
    register("farming:hemp_block", nil, false)
end

if get_modpath("mahogany") then
    local def = registered_nodes["mahogany:leaves"]
    local def_copy = table.copy(def)
    def_copy.drop = nil
    def_copy.wield_image = nil
    def_copy.inventory_image = nil
    def_copy.after_place_node = function(pos, placer, itemstack, pointed_thing)
        if placer and placer:is_player() then
            local vertical_correction = {
                [12]=15,
                [14]=15,
                [7]=6,
                [5]=6,
                [18]=17,
                [16]=17,
                [9]=8,
                [11]=8
            }
            local node = minetest.get_node(pos)
            local correction = vertical_correction[node.param2]
            if correction then
                node.param2 = correction
                minetest.set_node(pos, node)
            end
        end
    end
    stairsplus:register_all("mahogany", "leaves", "mahogany:leaves", def_copy)
end

if get_modpath("mobs_animal") then
    register("mobs:cheeseblock", nil, false)
    register("mobs:honey_block", nil, false)
end

if get_modpath("moreores") then
    register("moreores:mithril_block")
    register("moreores:silver_block")
end

if get_modpath("nether") then
    register("nether:glowstone")
    register("nether:obsidian_enchanted")
    register("nether:rack")
end

if get_modpath("redtrees") then
    register("redtrees:rtree", nil, false)
    register("redtrees:rwood", nil, false)
end

if get_modpath("sakuragi") then
    register("sakuragi:stree", nil, false)
    register("sakuragi:swood", nil, false)
end

if get_modpath("terumet") then
    register("terumet:block_asphalt", nil, false)
    register("terumet:block_ceramic", nil, false)
    register("terumet:block_cgls", nil, false)
    register("terumet:block_coke", nil, false)
    register_colors("terumet:block_con_%s", nil, false)
    register("terumet:block_dust_bio", nil, false)
    register("terumet:block_entropy", nil, false)
    register("terumet:block_pwood", nil, false)
    register("terumet:block_raw", nil, false)
    register("terumet:block_tar", nil, false)
    register("terumet:block_tcha", nil, false)
    register("terumet:block_tcop", nil, false)
    register("terumet:block_tglass", nil, false)
    register("terumet:block_tglassglow", nil, false)
    register("terumet:block_tgol", nil, false)
    register("terumet:block_thermese", nil, false)
    register("terumet:block_tste", nil, false)
    register("terumet:block_ttin", nil, false)
end

if get_modpath("titanium") then
    register("titanium:block", nil, false)
    register("titanium:glass", nil, false)
    register("titanium:titanium_plate", nil, false)
end

if get_modpath("xdecor") then
    register("xdecor:cactusbrick", nil, false)
    register("xdecor:coalstone_tile", nil, false)
    register("xdecor:desertstone_tile", nil, false)
    register("xdecor:hard_clay", nil, false)
    register("xdecor:moonbrick", nil, false)
    register("xdecor:packed_ice", nil, false)
    register("xdecor:iron_lightbox", nil, false)
    register("xdecor:stone_rune", nil, false)
    register("xdecor:stone_tile", nil, false)
    register("xdecor:wooden_lightbox", nil, false)
    register("xdecor:woodframed_glass", nil, false)
    register("xdecor:wood_tile", nil, false)
end
