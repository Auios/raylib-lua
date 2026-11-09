-- Generate src/raylib-lua.h from raylib 6.0 rlparser dumps.

local function script_path()
    local src = debug.getinfo(1, "S").source
    if src:sub(1, 1) == "@" then src = src:sub(2) end
    return src:gsub("\\", "/")
end

local function dirname(path)
    return path:match("^(.*)/") or "."
end

local DIR = dirname(script_path())
local ROOT = DIR .. "/../.."
local API_LUA = DIR .. "/api/raylib_api.lua"
local RAYMATH_H = DIR .. "/api/raymath.h"
local RUNTIME_INL = DIR .. "/runtime.inl"
local OUT_H = ROOT .. "/src/raylib-lua.h"

local function set(list)
    local t = {}
    for i = 1, #list do t[list[i]] = true end
    return t
end

local C_KEYWORDS = set({
    "auto", "break", "case", "char", "const", "continue", "default", "do",
    "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline",
    "int", "long", "register", "restrict", "return", "short", "signed", "sizeof",
    "static", "struct", "switch", "typedef", "union", "unsigned", "void",
    "volatile", "while", "end", "type",
})

local HANDWRITTEN = set({
    "TraceLog", "TextFormat",
    "LoadFileData", "SaveFileData", "UnloadFileData",
    "LoadFileText", "UnloadFileText",
    "LoadDroppedFiles", "LoadDirectoryFiles", "LoadDirectoryFilesEx",
    "UnloadDroppedFiles", "UnloadDirectoryFiles",
    "UpdateTexture", "UpdateTextureRec",
    "LoadImageColors", "UnloadImageColors",
    "SetShaderValue",
    "UpdateCamera", "UpdateCameraPro",
    "LoadFontEx", "LoadImageFromMemory",
    "DrawLineStrip", "DrawTriangleFan", "DrawTriangleStrip",
    "CompressData", "DecompressData", "EncodeDataBase64", "DecodeDataBase64",
    "UpdateSound", "UpdateAudioStream",
    "LoadWaveFromMemory", "LoadMusicStreamFromMemory",
    "CheckCollisionLines", "LoadShader", "LoadShaderFromMemory", "GetImageData",
    "SetModelTexture", "SetModelShader", "GetModelMesh",
})

local SKIP = set({
    "MemAlloc", "MemRealloc", "MemFree",
    "GetWindowHandle",
    "SetWindowIcons",
    "SetShaderValueV",
    "SetTraceLogCallback",
    "SetLoadFileDataCallback", "SetSaveFileDataCallback",
    "SetLoadFileTextCallback", "SetSaveFileTextCallback",
    "LoadRandomSequence", "UnloadRandomSequence",
    "ExportDataAsCode",
    "ComputeCRC32", "ComputeMD5", "ComputeSHA1", "ComputeSHA256",
    "LoadImageAnim", "LoadImageAnimFromMemory", "ExportImageToMemory",
    "ImageKernelConvolution",
    "GetPixelColor", "SetPixelColor",
    "LoadFontFromMemory", "LoadFontData", "GenImageFontAtlas", "UnloadFontData",
    "DrawTextCodepoints", "MeasureTextCodepoints",
    "LoadUTF8", "UnloadUTF8", "LoadCodepoints", "UnloadCodepoints",
    "GetCodepoint", "GetCodepointNext", "GetCodepointPrevious", "CodepointToUTF8",
    "LoadTextLines", "UnloadTextLines",
    "TextCopy", "TextJoin", "TextSplit", "TextAppend",
    "ImageDrawTriangleFan", "ImageDrawTriangleStrip",
    "DrawSplineLinear", "DrawSplineBasis", "DrawSplineCatmullRom",
    "DrawSplineBezierQuadratic", "DrawSplineBezierCubic",
    "CheckCollisionPointPoly",
    "DrawTriangleStrip3D",
    "UploadMesh", "UpdateMeshBuffer", "DrawMeshInstanced",
    "LoadMaterials", "LoadModelAnimations", "UnloadModelAnimations",
    "LoadWaveSamples", "UnloadWaveSamples",
    "SetAudioStreamCallback",
    "AttachAudioStreamProcessor", "DetachAudioStreamProcessor",
    "AttachAudioMixedProcessor", "DetachAudioMixedProcessor",
    "SetAutomationEventList",
    "LoadImagePalette", "UnloadImagePalette",
    "TextReplaceAlloc", "TextReplaceBetweenAlloc", "TextInsertAlloc",
    "GetTextBetween", "TextReplaceBetween",
})

local CONSTRUCTORS = {
    "Color", "Vector2", "Vector3", "Vector4", "Quaternion", "Matrix",
    "Rectangle", "Ray", "RayCollision", "BoundingBox", "Camera", "Camera3D",
    "Camera2D", "NPatchInfo", "Transform",
}

local PRIMITIVES = {
    ["void"] = "void",
    ["bool"] = "bool",
    ["int"] = "int",
    ["unsigned"] = "unsigned",
    ["unsigned int"] = "unsigned",
    ["unsigned char"] = "unsigned_char",
    ["char"] = "char",
    ["float"] = "float",
    ["double"] = "double",
    ["long"] = "long",
}

local FIELD_TYPES = set({
    "Vector2", "Vector3", "Vector4", "Quaternion", "Matrix", "Color",
    "Rectangle", "Camera", "Camera3D", "Camera2D", "Ray", "RayCollision",
    "BoundingBox", "NPatchInfo", "Transform", "VrDeviceInfo",
})

local OPAQUE_TYPES = set({
    "Image", "Texture", "Texture2D", "TextureCubemap", "RenderTexture",
    "RenderTexture2D", "Font", "Mesh", "Shader", "Material", "Model",
    "ModelSkeleton", "ModelAnimation", "Wave", "Sound", "Music", "AudioStream",
    "VrStereoConfig", "AutomationEvent", "AutomationEventList", "GlyphInfo",
})

local INOUT_PTR = {
    ["Image *"] = "Image",
    ["Wave *"] = "Wave",
    ["Mesh *"] = "Mesh",
    ["Texture2D *"] = "Texture2D",
    ["Texture *"] = "Texture2D",
    ["Material *"] = "Material",
    ["Model *"] = "Model",
}

local TYPE_ALIASES = {
    Camera3D = "Camera",
    Texture = "Texture2D",
    TextureCubemap = "Texture2D",
    RenderTexture = "RenderTexture2D",
}

local HEADER_PREFIX = [=[/**********************************************************************************************
*
*   raylib-lua v6.0 - raylib Lua bindings for raylib v6.0
*
*   NOTES:
*
*   The following types are treated as Lua tables with named fields, same as in C:
*       Color, Vector2, Vector3, Vector4, Quaternion, Matrix, Rectangle,
*       Ray, RayCollision, Camera, Camera2D, BoundingBox, NPatchInfo, Transform
*
*   Lua defines utility functions to create those objects:
*       local cl = Color(255, 255, 255, 255)
*       local rec = Rectangle(10, 10, 100, 100)
*       local cam = Camera(Vector3(10, 10, 10), Vector3(0, 0, 0), Vector3(0, 1, 0), 45.0)
*
*   Resource types are userdata (opaque, with some readable fields):
*       Image, Texture2D, RenderTexture2D, Font, Mesh, Shader, Material, Model,
*       Wave, Sound, Music, AudioStream
*
*   Pointer-mutating C APIs take the object and return it:
*       In C:           ImageFormat(&image, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
*       In Lua:         image = ImageFormat(image, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
*
*   Model materials are not exposed as nested C arrays. Use:
*       SetModelTexture(model, MATERIAL_MAP_DIFFUSE, texture)
*       SetModelShader(model, shader)
*       GetModelMesh(model, index)   -- 0-based
*
*   UpdateCamera mutates the Camera table in place and also returns it.
*
*   Enums and colors are registered as globals matching the C names
*   (KEY_A, CAMERA_FREE, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, RAYWHITE, ...).
*
*   This header is generated by tools/rLuaParser/gen_bindings.lua from the official
*   raylib 6.0 rlparser dump. Re-run the generator after API changes.
*
*   CONTRIBUTORS:
*       Ghassan Al-Mashareqa (ghassan@ghassan.pl): Original binding creation (for raylib 1.3)
*       Ramon Santamaria (@raysan5): Review, update and maintenance
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2026 Ghassan Al-Mashareqa and Ramon Santamaria (@raysan5)
*
**********************************************************************************************/

#ifndef RAYLIB_LUA_H
#define RAYLIB_LUA_H

#include "raylib.h"

#ifndef RLUADEF
    #define RLUADEF static
#endif

RLUADEF void rLuaInitDevice(void);
RLUADEF void rLuaExecuteCode(const char *code);
RLUADEF void rLuaExecuteFile(const char *filename);
RLUADEF void rLuaCloseDevice(void);

#if defined(RLUA_IMPLEMENTATION)

]=]

local FOOTER = [[
//----------------------------------------------------------------------------------
// raylib Lua API
//----------------------------------------------------------------------------------
static void rLuaRegisterFunctions(void)
{
    lua_pushglobaltable(L);
    luaL_setfuncs(L, raylib_functions, 0);
    lua_pop(L, 1);
}

RLUADEF void rLuaInitDevice(void)
{
    mainLuaState = luaL_newstate();
    L = mainLuaState;
    luaL_openlibs(L);
    LuaBuildOpaqueMetatables();

ENUM_REGS
    rLuaRegisterFunctions();
}

RLUADEF void rLuaCloseDevice(void)
{
    if (IsWindowReady()) CloseWindow();
    if (mainLuaState)
    {
        lua_close(mainLuaState);
        mainLuaState = 0;
        L = 0;
    }
}

static void rLuaReportError(int result)
{
    if (result == LUA_OK) return;
    const char *msg = lua_tostring(L, -1);
    if (result == LUA_ERRMEM) TraceLog(LOG_ERROR, "Lua Memory Error: %s", msg ? msg : "");
    else TraceLog(LOG_ERROR, "Lua Error: %s", msg ? msg : "");
    if (IsWindowReady()) CloseWindow();
}

RLUADEF void rLuaExecuteCode(const char *code)
{
    if (!mainLuaState)
    {
        TraceLog(LOG_WARNING, "Lua device not initialized");
        return;
    }
    rLuaReportError(luaL_dostring(L, code));
}

RLUADEF void rLuaExecuteFile(const char *filename)
{
    if (!mainLuaState)
    {
        TraceLog(LOG_WARNING, "Lua device not initialized");
        return;
    }
    rLuaReportError(luaL_dofile(L, filename));
}

#endif // RLUA_IMPLEMENTATION

#endif // RAYLIB_LUA_H
]]

local function count_set(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function sorted_keys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

local function split_ws(s)
    local bits = {}
    for w in s:gmatch("%S+") do bits[#bits + 1] = w end
    return bits
end

local function join(parts, sep)
    return table.concat(parts, sep)
end

local function read_text(path)
    local f, err = io.open(path, "rb")
    if not f then error("cannot read " .. path .. ": " .. tostring(err)) end
    local text = f:read("*a")
    f:close()
    text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
    return text
end

local function write_text(path, text)
    local f, err = io.open(path, "wb")
    if not f then error("cannot write " .. path .. ": " .. tostring(err)) end
    f:write(text)
    f:close()
end

local function sanitize_name(name, fallback)
    name = name:match("^%s*(.-)%s*$") or name
    name = name:gsub("%*", ""):gsub("%[%]", "")
    if name == "" or C_KEYWORDS[name] then return fallback end
    if not name:match("^[A-Za-z_][A-Za-z0-9_]*$") then return fallback end
    return name
end

local function normalize_type(t)
    t = t:gsub("const", " ")
    t = t:gsub("%s+", " "):match("^%s*(.-)%s*$")
    return TYPE_ALIASES[t] or t
end

local function classify(t)
    local raw = t:match("^%s*(.-)%s*$")
    if raw:match("Callback$") or raw == "..." or raw == "va_list" then
        return nil
    end
    local stripped = normalize_type(raw)
    if stripped == "char *" then
        return "string", "string"
    end
    if PRIMITIVES[stripped] then
        return "prim", PRIMITIVES[stripped]
    end
    if FIELD_TYPES[stripped] then
        return "field", TYPE_ALIASES[stripped] or stripped
    end
    if OPAQUE_TYPES[stripped] then
        return "opaque", TYPE_ALIASES[stripped] or stripped
    end
    if INOUT_PTR[raw] or INOUT_PTR[stripped] then
        local key = INOUT_PTR[raw] and raw or stripped
        return "inout", INOUT_PTR[key]
    end
    return nil
end

local PRIM_C_TYPES = {
    int = "int",
    unsigned = "unsigned int",
    unsigned_char = "unsigned char",
    char = "char",
    float = "float",
    double = "double",
    bool = "bool",
    long = "long",
    void = "void",
}

local function c_decl_type(kind, helper, orig)
    if kind == "string" then return "const char *" end
    if kind == "inout" then return helper .. " *" end
    if kind == "prim" then return PRIM_C_TYPES[helper] end
    return normalize_type(orig)
end

local INOUT_MT = {
    Image = "Image",
    Wave = "Wave",
    Mesh = "Mesh",
    Texture2D = "Texture2D",
    Material = "Material",
    Model = "Model",
}

local function emit_get(kind, helper, orig, argn, varname)
    if kind == "inout" then
        local mt = INOUT_MT[helper]
        return string.format('    %s *%s = (%s *)luaL_checkudata(L, %d, "%s");',
            helper, varname, helper, argn, mt)
    end
    if kind == "string" then
        return string.format("    const char *%s = LuaGetArgument_string(L, %d);", varname, argn)
    end
    if kind == "prim" then
        return string.format("    %s %s = LuaGetArgument_%s(L, %d);",
            c_decl_type(kind, helper, orig), varname, helper, argn)
    end
    local helper_name = TYPE_ALIASES[helper] or helper
    return string.format("    %s %s = LuaGetArgument_%s(L, %d);",
        c_decl_type(kind, helper, orig), varname, helper_name, argn)
end

local function emit_push(kind, helper, expr)
    if kind == "string" then
        return string.format("    LuaPush_string(L, %s);", expr)
    end
    if kind == "prim" then
        return string.format("    LuaPush_%s(L, %s);", helper, expr)
    end
    local helper_name = TYPE_ALIASES[helper] or helper
    return string.format("    LuaPush_%s(L, %s);", helper_name, expr)
end

local function parse_raymath(path)
    local text = read_text(path)
    local funcs = {}
    for line in text:gmatch("[^\n]*") do
        local ret, name, args = line:match("^RMAPI%s+(.-)%s+(%w+)%s*%((.*)%)%s*$")
        if ret then
            ret = ret:match("^%s*(.-)%s*$")
            args = args:match("^%s*(.-)%s*$")
            if ret ~= "float3" and ret ~= "float16" then
                local params = {}
                local skip = false
                if args ~= "" and args ~= "void" then
                    for part in (args .. ","):gmatch("([^,]*),") do
                        part = part:match("^%s*(.-)%s*$")
                        local bits = split_ws(part)
                        if #bits < 2 then
                            skip = true
                            break
                        end
                        local last = bits[#bits]
                        local pname = last:gsub("^%*+", "")
                        local ptype = join({ table.unpack(bits, 1, #bits - 1) }, " ")
                        if last:sub(1, 1) == "*" then
                            ptype = ptype .. " *"
                        end
                        params[#params + 1] = { type = ptype, name = pname }
                        if not classify(ptype) then
                            skip = true
                            break
                        end
                    end
                end
                if not skip then
                    local rk = classify(ret)
                    if rk or ret == "void" then
                        funcs[#funcs + 1] = {
                            name = name,
                            description = "",
                            returnType = ret,
                            params = params,
                        }
                    end
                end
            end
        end
    end
    return funcs
end

local function generate_wrapper(fn)
    local name = fn.name
    if HANDWRITTEN[name] or SKIP[name] then return nil end
    local ret = fn.returnType or "void"
    local params = fn.params or {}
    local desc = fn.description or ""

    local classified = {}
    for i = 1, #params do
        local kind, helper = classify(params[i].type)
        if not kind then return nil end
        classified[i] = { p = params[i], kind = kind, helper = helper }
    end

    local ret_kind, ret_helper
    if ret ~= "void" then
        ret_kind, ret_helper = classify(ret)
        if not ret_kind then return nil end
        if ret_kind == "inout" then return nil end
    end

    local lines = {}
    if desc ~= "" then lines[#lines + 1] = "// " .. desc end
    lines[#lines + 1] = string.format("static int lua_%s(lua_State *L)", name)
    lines[#lines + 1] = "{"
    if #params == 0 then lines[#lines + 1] = "    (void)L;" end

    local arg_names = {}
    local has_inout = false
    for i = 1, #classified do
        local c = classified[i]
        local varname = sanitize_name(c.p.name, "arg" .. i)
        arg_names[i] = { varname = varname, kind = c.kind }
        lines[#lines + 1] = emit_get(c.kind, c.helper, c.p.type, i, varname)
        if c.kind == "inout" then has_inout = true end
    end

    local call_args = {}
    for i = 1, #arg_names do call_args[i] = arg_names[i].varname end
    local call = join(call_args, ", ")

    local nret = 0
    if ret == "void" then
        lines[#lines + 1] = string.format("    %s(%s);", name, call)
        if has_inout then
            local first_inout
            for i = 1, #arg_names do
                if arg_names[i].kind == "inout" then
                    first_inout = i
                    break
                end
            end
            lines[#lines + 1] = string.format("    lua_pushvalue(L, %d);", first_inout)
            nret = 1
        end
    else
        local rtype = c_decl_type(ret_kind, ret_helper, ret)
        lines[#lines + 1] = string.format("    %s result = %s(%s);", rtype, name, call)
        if ret_kind == "string" then
            lines[#lines + 1] = "    LuaPush_string(L, result);"
        else
            lines[#lines + 1] = emit_push(ret_kind, ret_helper, "result")
        end
        nret = 1
    end

    lines[#lines + 1] = string.format("    return %d;", nret)
    lines[#lines + 1] = "}"
    lines[#lines + 1] = ""
    return join(lines, "\n")
end

local IDENT_UPPER = "^[A-Z][A-Z0-9_]*$"

local function generate_enum_regs(api)
    local lines = {}
    local math_names = { PI = true, DEG2RAD = true, RAD2DEG = true }
    for _, d in ipairs(api.defines or {}) do
        local dtype = d.type
        local name = d.name
        if dtype == "COLOR" then
            lines[#lines + 1] = string.format('    LuaPush_Color(L, %s); lua_setglobal(L, "%s");', name, name)
        elseif (dtype == "FLOAT" or dtype == "FLOAT_MATH") and math_names[name] then
            lines[#lines + 1] = string.format('    lua_pushnumber(L, %s); lua_setglobal(L, "%s");', name, name)
        elseif dtype == "STRING" and name == "RAYLIB_VERSION" then
            lines[#lines + 1] = '    lua_pushstring(L, RAYLIB_VERSION); lua_setglobal(L, "RAYLIB_VERSION");'
        elseif dtype == "INT" and name:sub(1, 15) == "RAYLIB_VERSION_" then
            lines[#lines + 1] = string.format('    lua_pushinteger(L, %s); lua_setglobal(L, "%s");', name, name)
        elseif dtype == "UNKNOWN" and name:match(IDENT_UPPER) and tostring(d.value or ""):match(IDENT_UPPER) then
            lines[#lines + 1] = string.format('    lua_pushinteger(L, %s); lua_setglobal(L, "%s");', name, name)
        end
    end
    for _, enum in ipairs(api.enums or {}) do
        for _, val in ipairs(enum.values or {}) do
            local name = val.name
            lines[#lines + 1] = string.format('    lua_pushinteger(L, %s); lua_setglobal(L, "%s");', name, name)
        end
    end
    return join(lines, "\n")
end

local function in_list(list, name)
    for i = 1, #list do
        if list[i] == name then return true end
    end
    return false
end

local function main()
    local api = dofile(API_LUA)
    local raymath_funcs = parse_raymath(RAYMATH_H)
    local runtime = read_text(RUNTIME_INL)

    local generated = {}
    local registered = {}
    for i = 1, #CONSTRUCTORS do registered[#registered + 1] = CONSTRUCTORS[i] end
    for _, n in ipairs(sorted_keys(HANDWRITTEN)) do registered[#registered + 1] = n end
    local skipped = {}

    for _, fn in ipairs(api.functions) do
        local wrap = generate_wrapper(fn)
        if not wrap then
            if not HANDWRITTEN[fn.name] then skipped[#skipped + 1] = fn.name end
        else
            generated[#generated + 1] = wrap
            registered[#registered + 1] = fn.name
        end
    end

    for _, fn in ipairs(raymath_funcs) do
        if not in_list(registered, fn.name) then
            local wrap = generate_wrapper(fn)
            if not wrap then
                skipped[#skipped + 1] = fn.name
            else
                generated[#generated + 1] = wrap
                registered[#registered + 1] = fn.name
            end
        end
    end

    local seen = {}
    local unique_reg = {}
    for i = 1, #registered do
        local n = registered[i]
        if not seen[n] then
            seen[n] = true
            unique_reg[#unique_reg + 1] = n
        end
    end

    local aliases = {}
    for _, d in ipairs(api.defines or {}) do
        if d.name == "GetMouseRay" and d.value == "GetScreenToWorldRay" then
            aliases[#aliases + 1] = '    { "GetMouseRay", lua_GetScreenToWorldRay },'
        end
    end

    local reg_lines = { "static const luaL_Reg raylib_functions[] = {" }
    for i = 1, #unique_reg do
        reg_lines[#reg_lines + 1] = string.format('    { "%s", lua_%s },', unique_reg[i], unique_reg[i])
    end
    for i = 1, #aliases do reg_lines[#reg_lines + 1] = aliases[i] end
    reg_lines[#reg_lines + 1] = "    { NULL, NULL }"
    reg_lines[#reg_lines + 1] = "};"

    local enum_regs = generate_enum_regs(api)
    local footer = FOOTER:gsub("ENUM_REGS", enum_regs, 1)

    local parts = {
        HEADER_PREFIX,
        runtime,
        "\n//----------------------------------------------------------------------------------\n",
        "// Generated raylib / raymath wrappers\n",
        "//----------------------------------------------------------------------------------\n\n",
        join(generated, "\n"),
        "\n",
        join(reg_lines, "\n"),
        "\n",
        footer,
    }

    write_text(OUT_H, table.concat(parts))
    print(string.format("Wrote %s", OUT_H:gsub("\\", "/")))
    print(string.format("  registered: %d", #unique_reg))
    print(string.format("  generated wrappers: %d", #generated))
    print(string.format("  handwritten: %d", count_set(HANDWRITTEN)))
    print(string.format("  skipped: %d", #skipped))
    if #skipped > 0 then
        print("  skipped names:")
        for i = 1, #skipped do
            print("    " .. skipped[i])
        end
    end
end

main()
