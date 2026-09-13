#!/usr/bin/env python3
"""Generate src/raylib-lua.h from raylib 6.0 rlparser dumps."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
API_JSON = Path(__file__).resolve().parent / "api" / "raylib_api.json"
RAYMATH_H = Path(__file__).resolve().parent / "api" / "raymath.h"
RUNTIME_INL = Path(__file__).resolve().parent / "runtime.inl"
OUT_H = ROOT / "src" / "raylib-lua.h"

C_KEYWORDS = {
    "auto", "break", "case", "char", "const", "continue", "default", "do",
    "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline",
    "int", "long", "register", "restrict", "return", "short", "signed", "sizeof",
    "static", "struct", "switch", "typedef", "union", "unsigned", "void",
    "volatile", "while", "end", "type",
}

HANDWRITTEN = {
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
}

SKIP = {
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
}

CONSTRUCTORS = [
    "Color", "Vector2", "Vector3", "Vector4", "Quaternion", "Matrix",
    "Rectangle", "Ray", "RayCollision", "BoundingBox", "Camera", "Camera3D",
    "Camera2D", "NPatchInfo", "Transform",
]

PRIMITIVES = {
    "void": "void",
    "bool": "bool",
    "int": "int",
    "unsigned": "unsigned",
    "unsigned int": "unsigned",
    "unsigned char": "unsigned_char",
    "char": "char",
    "float": "float",
    "double": "double",
    "long": "long",
}

FIELD_TYPES = {
    "Vector2", "Vector3", "Vector4", "Quaternion", "Matrix", "Color",
    "Rectangle", "Camera", "Camera3D", "Camera2D", "Ray", "RayCollision",
    "BoundingBox", "NPatchInfo", "Transform", "VrDeviceInfo",
}

OPAQUE_TYPES = {
    "Image", "Texture", "Texture2D", "TextureCubemap", "RenderTexture",
    "RenderTexture2D", "Font", "Mesh", "Shader", "Material", "Model",
    "ModelSkeleton", "ModelAnimation", "Wave", "Sound", "Music", "AudioStream",
    "VrStereoConfig", "AutomationEvent", "AutomationEventList", "GlyphInfo",
}

INOUT_PTR = {
    "Image *": "Image",
    "Wave *": "Wave",
    "Mesh *": "Mesh",
    "Texture2D *": "Texture2D",
    "Texture *": "Texture2D",
    "Material *": "Material",
    "Model *": "Model",
}

TYPE_ALIASES = {
    "Camera3D": "Camera",
    "Texture": "Texture2D",
    "TextureCubemap": "Texture2D",
    "RenderTexture": "RenderTexture2D",
}

HEADER_PREFIX = r'''/**********************************************************************************************
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
*   This header is generated by tools/rLuaParser/gen_bindings.py from the official
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

'''

FOOTER = r'''
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
'''


def sanitize_name(name: str, fallback: str) -> str:
    name = name.strip()
    name = name.replace("*", "").replace("[]", "")
    if not name or name in C_KEYWORDS:
        return fallback
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", name):
        return fallback
    return name


def normalize_type(t: str) -> str:
    t = " ".join(t.replace("const", " ").split())
    return TYPE_ALIASES.get(t, t)


def classify(t: str) -> tuple[str, str] | None:
    """Return (kind, lua_helper_type) or None if unsupported."""
    raw = t.strip()
    if raw.endswith("Callback") or raw == "..." or raw == "va_list":
        return None

    stripped = normalize_type(raw)

    if stripped in ("char *",):
        return ("string", "string")
    if stripped in PRIMITIVES:
        return ("prim", PRIMITIVES[stripped])
    if stripped in FIELD_TYPES:
        return ("field", TYPE_ALIASES.get(stripped, stripped))
    if stripped in OPAQUE_TYPES:
        return ("opaque", TYPE_ALIASES.get(stripped, stripped))
    if raw in INOUT_PTR or stripped in INOUT_PTR:
        key = raw if raw in INOUT_PTR else stripped
        return ("inout", INOUT_PTR[key])
    return None


def c_decl_type(kind: str, helper: str, orig: str) -> str:
    if kind == "string":
        return "const char *"
    if kind == "inout":
        return f"{helper} *"
    if kind == "prim":
        mapping = {
            "int": "int",
            "unsigned": "unsigned int",
            "unsigned_char": "unsigned char",
            "char": "char",
            "float": "float",
            "double": "double",
            "bool": "bool",
            "long": "long",
            "void": "void",
        }
        return mapping[helper]
    # field / opaque: use original without const
    t = normalize_type(orig)
    return t


def emit_get(kind: str, helper: str, orig: str, argn: int, varname: str) -> str:
    if kind == "inout":
        mt = {
            "Image": "Image",
            "Wave": "Wave",
            "Mesh": "Mesh",
            "Texture2D": "Texture2D",
            "Material": "Material",
            "Model": "Model",
        }[helper]
        return f"    {helper} *{varname} = ({helper} *)luaL_checkudata(L, {argn}, \"{mt}\");"
    if kind == "string":
        return f"    const char *{varname} = LuaGetArgument_string(L, {argn});"
    if kind == "prim":
        return f"    {c_decl_type(kind, helper, orig)} {varname} = LuaGetArgument_{helper}(L, {argn});"
    helper_name = TYPE_ALIASES.get(helper, helper)
    return f"    {c_decl_type(kind, helper, orig)} {varname} = LuaGetArgument_{helper_name}(L, {argn});"


def emit_push(kind: str, helper: str, expr: str) -> str:
    if kind == "string":
        return f"    LuaPush_string(L, {expr});"
    if kind == "prim":
        return f"    LuaPush_{helper}(L, {expr});"
    helper_name = TYPE_ALIASES.get(helper, helper)
    return f"    LuaPush_{helper_name}(L, {expr});"


def parse_raymath(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8", errors="replace")
    funcs = []
    pattern = re.compile(r"^RMAPI\s+(.+?)\s+(\w+)\s*\((.*)\)\s*$", re.M)
    for m in pattern.finditer(text):
        ret, name, args = m.group(1).strip(), m.group(2), m.group(3).strip()
        if ret in ("float3", "float16"):
            continue
        params = []
        if args and args != "void":
            skip = False
            for part in args.split(","):
                part = part.strip()
                # split type and name from the right
                bits = part.split()
                if len(bits) < 2:
                    skip = True
                    break
                pname = bits[-1].lstrip("*")
                ptype = " ".join(bits[:-1])
                if bits[-1].startswith("*"):
                    ptype = ptype + " *"
                params.append({"type": ptype, "name": pname})
                if classify(ptype) is None:
                    skip = True
                    break
            if skip:
                continue
        if classify(ret) is None and ret != "void":
            continue
        funcs.append({"name": name, "description": "", "returnType": ret, "params": params})
    return funcs


def generate_wrapper(fn: dict) -> str | None:
    name = fn["name"]
    if name in HANDWRITTEN or name in SKIP:
        return None
    ret = fn.get("returnType", "void")
    params = fn.get("params") or []
    desc = fn.get("description") or ""

    classified = []
    for i, p in enumerate(params):
        c = classify(p["type"])
        if c is None:
            return None
        classified.append((p, c))

    ret_c = None
    if ret != "void":
        ret_c = classify(ret)
        if ret_c is None:
            return None
        if ret_c[0] == "inout":
            return None

    lines = []
    if desc:
        lines.append(f"// {desc}")
    lines.append(f"static int lua_{name}(lua_State *L)")
    lines.append("{")
    if not params:
        lines.append("    (void)L;")

    arg_names = []
    has_inout = False
    for i, (p, (kind, helper)) in enumerate(classified):
        varname = sanitize_name(p["name"], f"arg{i+1}")
        arg_names.append((varname, kind))
        lines.append(emit_get(kind, helper, p["type"], i + 1, varname))
        if kind == "inout":
            has_inout = True

    call_args = []
    for varname, kind in arg_names:
        call_args.append(varname)
    call = ", ".join(call_args)

    nret = 0
    if ret == "void":
        lines.append(f"    {name}({call});")
        if has_inout:
            # return first inout userdata
            first_inout = next(i for i, (_, kind) in enumerate(arg_names) if kind == "inout")
            lines.append(f"    lua_pushvalue(L, {first_inout + 1});")
            nret = 1
    else:
        rkind, rhelper = ret_c
        rtype = c_decl_type(rkind, rhelper, ret)
        lines.append(f"    {rtype} result = {name}({call});")
        if rkind == "string":
            lines.append("    LuaPush_string(L, result);")
        else:
            lines.append(emit_push(rkind, rhelper, "result"))
        nret = 1
        if has_inout:
            # pointer-mutating functions that also return something are rare; keep return value
            pass

    lines.append(f"    return {nret};")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def generate_enum_regs(api: dict) -> str:
    lines = []
    for d in api.get("defines", []):
        dtype = d.get("type")
        name = d["name"]
        if dtype == "COLOR":
            lines.append(f'    LuaPush_Color(L, {name}); lua_setglobal(L, "{name}");')
        elif dtype in ("FLOAT", "FLOAT_MATH") and name in ("PI", "DEG2RAD", "RAD2DEG"):
            lines.append(f'    lua_pushnumber(L, {name}); lua_setglobal(L, "{name}");')
        elif dtype == "STRING" and name == "RAYLIB_VERSION":
            lines.append(f'    lua_pushstring(L, RAYLIB_VERSION); lua_setglobal(L, "RAYLIB_VERSION");')
        elif dtype == "INT" and name.startswith("RAYLIB_VERSION_"):
            lines.append(f'    lua_pushinteger(L, {name}); lua_setglobal(L, "{name}");')
        elif dtype == "UNKNOWN" and re.match(r"^[A-Z][A-Z0-9_]*$", name) and re.match(r"^[A-Z][A-Z0-9_]*$", str(d.get("value", ""))):
            lines.append(f'    lua_pushinteger(L, {name}); lua_setglobal(L, "{name}");')

    for enum in api.get("enums", []):
        for val in enum.get("values", []):
            name = val["name"]
            lines.append(f'    lua_pushinteger(L, {name}); lua_setglobal(L, "{name}");')
    return "\n".join(lines)


def main() -> None:
    api = json.loads(API_JSON.read_text(encoding="utf-8"))
    raymath_funcs = parse_raymath(RAYMATH_H)
    runtime = RUNTIME_INL.read_text(encoding="utf-8")

    generated = []
    registered = list(CONSTRUCTORS) + sorted(HANDWRITTEN)
    skipped = []

    for fn in api["functions"]:
        wrap = generate_wrapper(fn)
        if wrap is None:
            if fn["name"] not in HANDWRITTEN:
                skipped.append(fn["name"])
            continue
        generated.append(wrap)
        registered.append(fn["name"])

    for fn in raymath_funcs:
        if fn["name"] in registered:
            continue
        wrap = generate_wrapper(fn)
        if wrap is None:
            skipped.append(fn["name"])
            continue
        generated.append(wrap)
        registered.append(fn["name"])

    # Unique preserve order
    seen = set()
    unique_reg = []
    for n in registered:
        if n not in seen:
            seen.add(n)
            unique_reg.append(n)

    aliases = []
    for d in api.get("defines", []):
        if d.get("name") == "GetMouseRay" and d.get("value") == "GetScreenToWorldRay":
            aliases.append('    { "GetMouseRay", lua_GetScreenToWorldRay },')

    reg_lines = ["static const luaL_Reg raylib_functions[] = {"]
    for n in unique_reg:
        reg_lines.append(f"    {{ \"{n}\", lua_{n} }},")
    reg_lines.extend(aliases)
    reg_lines.append("    { NULL, NULL }")
    reg_lines.append("};")

    enum_regs = generate_enum_regs(api)
    footer = FOOTER.replace("ENUM_REGS", enum_regs)

    parts = [
        HEADER_PREFIX,
        runtime,
        "\n//----------------------------------------------------------------------------------\n",
        "// Generated raylib / raymath wrappers\n",
        "//----------------------------------------------------------------------------------\n\n",
        "\n".join(generated),
        "\n",
        "\n".join(reg_lines),
        footer,
    ]

    OUT_H.write_text("".join(parts), encoding="utf-8", newline="\n")
    print(f"Wrote {OUT_H}")
    print(f"  registered: {len(unique_reg)}")
    print(f"  generated wrappers: {len(generated)}")
    print(f"  handwritten: {len(HANDWRITTEN)}")
    print(f"  skipped: {len(skipped)}")
    if skipped:
        print("  skipped names:")
        for n in skipped:
            print(f"    {n}")


if __name__ == "__main__":
    main()
