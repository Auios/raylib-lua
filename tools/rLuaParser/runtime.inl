//----------------------------------------------------------------------------------
// Includes
//----------------------------------------------------------------------------------
#include "raylib.h"
#include "raymath.h"

#include <string.h>
#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
#define LuaPush_int(L, value)           lua_pushinteger(L, (lua_Integer)(value))
#define LuaPush_unsigned(L, value)      lua_pushinteger(L, (lua_Integer)(value))
#define LuaPush_float(L, value)         lua_pushnumber(L, (lua_Number)(value))
#define LuaPush_double(L, value)        lua_pushnumber(L, (lua_Number)(value))
#define LuaPush_bool(L, value)          lua_pushboolean(L, (value))
#define LuaPush_string(L, value)        lua_pushstring(L, (value) ? (value) : "")
#define LuaPush_long(L, value)          lua_pushinteger(L, (lua_Integer)(value))

#define LuaGetArgument_int(L, i)        (int)luaL_checkinteger(L, i)
#define LuaGetArgument_unsigned(L, i)   (unsigned int)luaL_checkinteger(L, i)
#define LuaGetArgument_unsigned_int(L, i) (unsigned int)luaL_checkinteger(L, i)
#define LuaGetArgument_float(L, i)      (float)luaL_checknumber(L, i)
#define LuaGetArgument_double(L, i)     (double)luaL_checknumber(L, i)
#define LuaGetArgument_bool(L, i)       lua_toboolean(L, i)
#define LuaGetArgument_string(L, i)     luaL_checkstring(L, i)
#define LuaGetArgument_long(L, i)       (long)luaL_checkinteger(L, i)
#define LuaGetArgument_char(L, i)       (char)luaL_checkinteger(L, i)
#define LuaGetArgument_unsigned_char(L, i) (unsigned char)luaL_checkinteger(L, i)

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
static lua_State *mainLuaState = 0;
static lua_State *L = 0;

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
static void LuaPush_Color(lua_State *L, Color color);
static void LuaPush_Vector2(lua_State *L, Vector2 vec);
static void LuaPush_Vector3(lua_State *L, Vector3 vec);
static void LuaPush_Vector4(lua_State *L, Vector4 vec);
static void LuaPush_Quaternion(lua_State *L, Quaternion vec);
static void LuaPush_Matrix(lua_State *L, Matrix matrix);
static void LuaPush_Rectangle(lua_State *L, Rectangle rect);
static void LuaPush_Camera(lua_State *L, Camera cam);
static void LuaPush_Camera2D(lua_State *L, Camera2D cam);
static void LuaPush_Ray(lua_State *L, Ray ray);
static void LuaPush_RayCollision(lua_State *L, RayCollision hit);
static void LuaPush_BoundingBox(lua_State *L, BoundingBox bb);
static void LuaPush_NPatchInfo(lua_State *L, NPatchInfo info);
static void LuaPush_Transform(lua_State *L, Transform t);
static void LuaPush_VrDeviceInfo(lua_State *L, VrDeviceInfo info);

static Color LuaGetArgument_Color(lua_State *L, int index);
static Vector2 LuaGetArgument_Vector2(lua_State *L, int index);
static Vector3 LuaGetArgument_Vector3(lua_State *L, int index);
static Vector4 LuaGetArgument_Vector4(lua_State *L, int index);
static Quaternion LuaGetArgument_Quaternion(lua_State *L, int index);
static Matrix LuaGetArgument_Matrix(lua_State *L, int index);
static Rectangle LuaGetArgument_Rectangle(lua_State *L, int index);
static Camera LuaGetArgument_Camera(lua_State *L, int index);
static Camera2D LuaGetArgument_Camera2D(lua_State *L, int index);
static Ray LuaGetArgument_Ray(lua_State *L, int index);
static RayCollision LuaGetArgument_RayCollision(lua_State *L, int index);
static BoundingBox LuaGetArgument_BoundingBox(lua_State *L, int index);
static NPatchInfo LuaGetArgument_NPatchInfo(lua_State *L, int index);
static Transform LuaGetArgument_Transform(lua_State *L, int index);
static VrDeviceInfo LuaGetArgument_VrDeviceInfo(lua_State *L, int index);

static void LuaWrite_Camera(lua_State *L, int index, Camera cam);

//----------------------------------------------------------------------------------
// Opaque userdata helpers
//----------------------------------------------------------------------------------
static void LuaPushOpaqueWithMetatable(lua_State *L, const void *ptr, size_t size, const char *metatable_name)
{
    void *ud = lua_newuserdata(L, size);
    memcpy(ud, ptr, size);
    luaL_setmetatable(L, metatable_name);
}

#define LuaPush_Image(L, img)               LuaPushOpaqueWithMetatable(L, &(img), sizeof(Image), "Image")
#define LuaPush_Texture(L, tex)             LuaPushOpaqueWithMetatable(L, &(tex), sizeof(Texture), "Texture2D")
#define LuaPush_Texture2D(L, tex)           LuaPush_Texture(L, tex)
#define LuaPush_TextureCubemap(L, tex)      LuaPush_Texture(L, tex)
#define LuaPush_RenderTexture(L, tex)       LuaPushOpaqueWithMetatable(L, &(tex), sizeof(RenderTexture), "RenderTexture2D")
#define LuaPush_RenderTexture2D(L, tex)     LuaPush_RenderTexture(L, tex)
#define LuaPush_Font(L, fnt)                LuaPushOpaqueWithMetatable(L, &(fnt), sizeof(Font), "Font")
#define LuaPush_Mesh(L, mesh)               LuaPushOpaqueWithMetatable(L, &(mesh), sizeof(Mesh), "Mesh")
#define LuaPush_Shader(L, sh)               LuaPushOpaqueWithMetatable(L, &(sh), sizeof(Shader), "Shader")
#define LuaPush_Material(L, mat)            LuaPushOpaqueWithMetatable(L, &(mat), sizeof(Material), "Material")
#define LuaPush_Model(L, mdl)               LuaPushOpaqueWithMetatable(L, &(mdl), sizeof(Model), "Model")
#define LuaPush_ModelSkeleton(L, sk)        LuaPushOpaqueWithMetatable(L, &(sk), sizeof(ModelSkeleton), "ModelSkeleton")
#define LuaPush_ModelAnimation(L, anim)     LuaPushOpaqueWithMetatable(L, &(anim), sizeof(ModelAnimation), "ModelAnimation")
#define LuaPush_Wave(L, wav)                LuaPushOpaqueWithMetatable(L, &(wav), sizeof(Wave), "Wave")
#define LuaPush_Sound(L, snd)               LuaPushOpaqueWithMetatable(L, &(snd), sizeof(Sound), "Sound")
#define LuaPush_Music(L, mus)               LuaPushOpaqueWithMetatable(L, &(mus), sizeof(Music), "Music")
#define LuaPush_AudioStream(L, aud)         LuaPushOpaqueWithMetatable(L, &(aud), sizeof(AudioStream), "AudioStream")
#define LuaPush_VrStereoConfig(L, cfg)      LuaPushOpaqueWithMetatable(L, &(cfg), sizeof(VrStereoConfig), "VrStereoConfig")
#define LuaPush_AutomationEvent(L, ev)      LuaPushOpaqueWithMetatable(L, &(ev), sizeof(AutomationEvent), "AutomationEvent")
#define LuaPush_AutomationEventList(L, lst) LuaPushOpaqueWithMetatable(L, &(lst), sizeof(AutomationEventList), "AutomationEventList")
#define LuaPush_GlyphInfo(L, g)             LuaPushOpaqueWithMetatable(L, &(g), sizeof(GlyphInfo), "GlyphInfo")

#define LuaGetArgument_Image(L, i)          (*(Image *)luaL_checkudata(L, i, "Image"))
#define LuaGetArgument_Texture(L, i)        (*(Texture *)luaL_checkudata(L, i, "Texture2D"))
#define LuaGetArgument_Texture2D(L, i)      LuaGetArgument_Texture(L, i)
#define LuaGetArgument_TextureCubemap(L, i) LuaGetArgument_Texture(L, i)
#define LuaGetArgument_RenderTexture(L, i)  (*(RenderTexture *)luaL_checkudata(L, i, "RenderTexture2D"))
#define LuaGetArgument_RenderTexture2D(L, i) LuaGetArgument_RenderTexture(L, i)
#define LuaGetArgument_Font(L, i)           (*(Font *)luaL_checkudata(L, i, "Font"))
#define LuaGetArgument_Mesh(L, i)           (*(Mesh *)luaL_checkudata(L, i, "Mesh"))
#define LuaGetArgument_Shader(L, i)         (*(Shader *)luaL_checkudata(L, i, "Shader"))
#define LuaGetArgument_Material(L, i)       (*(Material *)luaL_checkudata(L, i, "Material"))
#define LuaGetArgument_Model(L, i)          (*(Model *)luaL_checkudata(L, i, "Model"))
#define LuaGetArgument_ModelSkeleton(L, i)  (*(ModelSkeleton *)luaL_checkudata(L, i, "ModelSkeleton"))
#define LuaGetArgument_ModelAnimation(L, i) (*(ModelAnimation *)luaL_checkudata(L, i, "ModelAnimation"))
#define LuaGetArgument_Wave(L, i)           (*(Wave *)luaL_checkudata(L, i, "Wave"))
#define LuaGetArgument_Sound(L, i)          (*(Sound *)luaL_checkudata(L, i, "Sound"))
#define LuaGetArgument_Music(L, i)          (*(Music *)luaL_checkudata(L, i, "Music"))
#define LuaGetArgument_AudioStream(L, i)    (*(AudioStream *)luaL_checkudata(L, i, "AudioStream"))
#define LuaGetArgument_VrStereoConfig(L, i) (*(VrStereoConfig *)luaL_checkudata(L, i, "VrStereoConfig"))
#define LuaGetArgument_AutomationEvent(L, i) (*(AutomationEvent *)luaL_checkudata(L, i, "AutomationEvent"))
#define LuaGetArgument_AutomationEventList(L, i) (*(AutomationEventList *)luaL_checkudata(L, i, "AutomationEventList"))
#define LuaGetArgument_GlyphInfo(L, i)      (*(GlyphInfo *)luaL_checkudata(L, i, "GlyphInfo"))
#define LuaGetArgument_Camera3D(L, i)       LuaGetArgument_Camera(L, i)
#define LuaPush_Camera3D(L, cam)            LuaPush_Camera(L, cam)

static int LuaIndexImage(lua_State *L)
{
    Image img = LuaGetArgument_Image(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "width")) LuaPush_int(L, img.width);
    else if (!strcmp(key, "height")) LuaPush_int(L, img.height);
    else if (!strcmp(key, "mipmaps")) LuaPush_int(L, img.mipmaps);
    else if (!strcmp(key, "format")) LuaPush_int(L, img.format);
    else return 0;
    return 1;
}

static int LuaIndexTexture2D(lua_State *L)
{
    Texture2D tex = LuaGetArgument_Texture2D(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "id")) LuaPush_unsigned(L, tex.id);
    else if (!strcmp(key, "width")) LuaPush_int(L, tex.width);
    else if (!strcmp(key, "height")) LuaPush_int(L, tex.height);
    else if (!strcmp(key, "mipmaps")) LuaPush_int(L, tex.mipmaps);
    else if (!strcmp(key, "format")) LuaPush_int(L, tex.format);
    else return 0;
    return 1;
}

static int LuaIndexRenderTexture2D(lua_State *L)
{
    RenderTexture2D rt = LuaGetArgument_RenderTexture2D(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "id")) LuaPush_unsigned(L, rt.id);
    else if (!strcmp(key, "texture")) LuaPush_Texture2D(L, rt.texture);
    else if (!strcmp(key, "depth")) LuaPush_Texture2D(L, rt.depth);
    else return 0;
    return 1;
}

static int LuaIndexFont(lua_State *L)
{
    Font fnt = LuaGetArgument_Font(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "baseSize")) LuaPush_int(L, fnt.baseSize);
    else if (!strcmp(key, "glyphCount")) LuaPush_int(L, fnt.glyphCount);
    else if (!strcmp(key, "glyphPadding")) LuaPush_int(L, fnt.glyphPadding);
    else if (!strcmp(key, "texture")) LuaPush_Texture2D(L, fnt.texture);
    else return 0;
    return 1;
}

static int LuaIndexShader(lua_State *L)
{
    Shader sh = LuaGetArgument_Shader(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "id")) LuaPush_unsigned(L, sh.id);
    else return 0;
    return 1;
}

static int LuaIndexModel(lua_State *L)
{
    Model mdl = LuaGetArgument_Model(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "meshCount")) LuaPush_int(L, mdl.meshCount);
    else if (!strcmp(key, "materialCount")) LuaPush_int(L, mdl.materialCount);
    else if (!strcmp(key, "transform")) LuaPush_Matrix(L, mdl.transform);
    else return 0;
    return 1;
}

static int LuaIndexWave(lua_State *L)
{
    Wave wav = LuaGetArgument_Wave(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "frameCount")) LuaPush_unsigned(L, wav.frameCount);
    else if (!strcmp(key, "sampleRate")) LuaPush_unsigned(L, wav.sampleRate);
    else if (!strcmp(key, "sampleSize")) LuaPush_unsigned(L, wav.sampleSize);
    else if (!strcmp(key, "channels")) LuaPush_unsigned(L, wav.channels);
    else return 0;
    return 1;
}

static int LuaIndexMusic(lua_State *L)
{
    Music mus = LuaGetArgument_Music(L, 1);
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "looping")) LuaPush_bool(L, mus.looping);
    else if (!strcmp(key, "frameCount")) LuaPush_unsigned(L, mus.frameCount);
    else return 0;
    return 1;
}

static int LuaNewIndexMusic(lua_State *L)
{
    Music *mus = (Music *)luaL_checkudata(L, 1, "Music");
    const char *key = luaL_checkstring(L, 2);
    if (!strcmp(key, "looping")) mus->looping = lua_toboolean(L, 3);
    return 0;
}

static void LuaRegisterMetatable(const char *name, lua_CFunction indexFn)
{
    luaL_newmetatable(L, name);
    if (indexFn)
    {
        lua_pushcfunction(L, indexFn);
        lua_setfield(L, -2, "__index");
    }
    lua_pop(L, 1);
}

static void LuaBuildOpaqueMetatables(void)
{
    LuaRegisterMetatable("Image", LuaIndexImage);
    LuaRegisterMetatable("Texture2D", LuaIndexTexture2D);
    LuaRegisterMetatable("RenderTexture2D", LuaIndexRenderTexture2D);
    LuaRegisterMetatable("Font", LuaIndexFont);
    LuaRegisterMetatable("Mesh", NULL);
    LuaRegisterMetatable("Shader", LuaIndexShader);
    LuaRegisterMetatable("Material", NULL);
    LuaRegisterMetatable("Model", LuaIndexModel);
    LuaRegisterMetatable("ModelSkeleton", NULL);
    LuaRegisterMetatable("ModelAnimation", NULL);
    LuaRegisterMetatable("Wave", LuaIndexWave);
    luaL_newmetatable(L, "Music");
    lua_pushcfunction(L, LuaIndexMusic);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, LuaNewIndexMusic);
    lua_setfield(L, -2, "__newindex");
    lua_pop(L, 1);
    LuaRegisterMetatable("Sound", NULL);
    LuaRegisterMetatable("AudioStream", NULL);
    LuaRegisterMetatable("VrStereoConfig", NULL);
    LuaRegisterMetatable("AutomationEvent", NULL);
    LuaRegisterMetatable("AutomationEventList", NULL);
    LuaRegisterMetatable("GlyphInfo", NULL);
}

//----------------------------------------------------------------------------------
// Field-table getters / setters
//----------------------------------------------------------------------------------
static Vector2 LuaGetArgument_Vector2(lua_State *L, int index)
{
    Vector2 result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Vector2");
    lua_getfield(L, index, "x"); result.x = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "y"); result.y = (float)luaL_checknumber(L, -1);
    lua_pop(L, 2);
    return result;
}

static Vector3 LuaGetArgument_Vector3(lua_State *L, int index)
{
    Vector3 result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Vector3");
    lua_getfield(L, index, "x"); result.x = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "y"); result.y = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "z"); result.z = (float)luaL_checknumber(L, -1);
    lua_pop(L, 3);
    return result;
}

static Vector4 LuaGetArgument_Vector4(lua_State *L, int index)
{
    Vector4 result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Vector4");
    lua_getfield(L, index, "x"); result.x = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "y"); result.y = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "z"); result.z = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "w"); result.w = (float)luaL_checknumber(L, -1);
    lua_pop(L, 4);
    return result;
}

static Quaternion LuaGetArgument_Quaternion(lua_State *L, int index)
{
    return LuaGetArgument_Vector4(L, index);
}

static Matrix LuaGetArgument_Matrix(lua_State *L, int index)
{
    Matrix result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Matrix");

    lua_getfield(L, index, "m0");
    if (lua_isnumber(L, -1))
    {
        float *ptr = &result.m0;
        static const char *names[16] = {
            "m0","m4","m8","m12","m1","m5","m9","m13","m2","m6","m10","m14","m3","m7","m11","m15"
        };
        lua_pop(L, 1);
        for (int i = 0; i < 16; i++)
        {
            lua_getfield(L, index, names[i]);
            ptr[i] = (float)luaL_checknumber(L, -1);
            lua_pop(L, 1);
        }
    }
    else
    {
        lua_pop(L, 1);
        float *ptr = &result.m0;
        for (int i = 0; i < 16; i++)
        {
            lua_rawgeti(L, index, i + 1);
            ptr[i] = (float)luaL_checknumber(L, -1);
            lua_pop(L, 1);
        }
    }
    return result;
}

static Color LuaGetArgument_Color(lua_State *L, int index)
{
    Color result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Color");
    lua_getfield(L, index, "r"); result.r = (unsigned char)luaL_checkinteger(L, -1);
    lua_getfield(L, index, "g"); result.g = (unsigned char)luaL_checkinteger(L, -1);
    lua_getfield(L, index, "b"); result.b = (unsigned char)luaL_checkinteger(L, -1);
    lua_getfield(L, index, "a"); result.a = (unsigned char)luaL_checkinteger(L, -1);
    lua_pop(L, 4);
    return result;
}

static Rectangle LuaGetArgument_Rectangle(lua_State *L, int index)
{
    Rectangle result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Rectangle");
    lua_getfield(L, index, "x"); result.x = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "y"); result.y = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "width"); result.width = (float)luaL_checknumber(L, -1);
    lua_getfield(L, index, "height"); result.height = (float)luaL_checknumber(L, -1);
    lua_pop(L, 4);
    return result;
}

static Camera LuaGetArgument_Camera(lua_State *L, int index)
{
    Camera result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Camera");
    lua_getfield(L, index, "position"); result.position = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "target"); result.target = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "up"); result.up = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "fovy"); result.fovy = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "projection");
    if (lua_isnumber(L, -1)) result.projection = (int)lua_tointeger(L, -1);
    else result.projection = CAMERA_PERSPECTIVE;
    lua_pop(L, 1);
    return result;
}

static void LuaWrite_Camera(lua_State *L, int index, Camera cam)
{
    index = lua_absindex(L, index);
    LuaPush_Vector3(L, cam.position); lua_setfield(L, index, "position");
    LuaPush_Vector3(L, cam.target); lua_setfield(L, index, "target");
    LuaPush_Vector3(L, cam.up); lua_setfield(L, index, "up");
    LuaPush_float(L, cam.fovy); lua_setfield(L, index, "fovy");
    LuaPush_int(L, cam.projection); lua_setfield(L, index, "projection");
}

static Camera2D LuaGetArgument_Camera2D(lua_State *L, int index)
{
    Camera2D result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Camera2D");
    lua_getfield(L, index, "offset"); result.offset = LuaGetArgument_Vector2(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "target"); result.target = LuaGetArgument_Vector2(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "rotation"); result.rotation = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "zoom"); result.zoom = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    return result;
}

static BoundingBox LuaGetArgument_BoundingBox(lua_State *L, int index)
{
    BoundingBox result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected BoundingBox");
    lua_getfield(L, index, "min"); result.min = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "max"); result.max = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    return result;
}

static Ray LuaGetArgument_Ray(lua_State *L, int index)
{
    Ray result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Ray");
    lua_getfield(L, index, "position"); result.position = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "direction"); result.direction = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    return result;
}

static RayCollision LuaGetArgument_RayCollision(lua_State *L, int index)
{
    RayCollision result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected RayCollision");
    lua_getfield(L, index, "hit"); result.hit = lua_toboolean(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "distance"); result.distance = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "point"); result.point = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "normal"); result.normal = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    return result;
}

static NPatchInfo LuaGetArgument_NPatchInfo(lua_State *L, int index)
{
    NPatchInfo result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected NPatchInfo");
    lua_getfield(L, index, "source"); result.source = LuaGetArgument_Rectangle(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "left"); result.left = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "top"); result.top = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "right"); result.right = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "bottom"); result.bottom = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "layout"); result.layout = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    return result;
}

static Transform LuaGetArgument_Transform(lua_State *L, int index)
{
    Transform result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected Transform");
    lua_getfield(L, index, "translation"); result.translation = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "rotation"); result.rotation = LuaGetArgument_Quaternion(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "scale"); result.scale = LuaGetArgument_Vector3(L, -1); lua_pop(L, 1);
    return result;
}

static VrDeviceInfo LuaGetArgument_VrDeviceInfo(lua_State *L, int index)
{
    VrDeviceInfo result = { 0 };
    index = lua_absindex(L, index);
    luaL_argcheck(L, lua_istable(L, index), index, "Expected VrDeviceInfo");
    lua_getfield(L, index, "hResolution"); result.hResolution = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "vResolution"); result.vResolution = (int)luaL_checkinteger(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "hScreenSize"); result.hScreenSize = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "vScreenSize"); result.vScreenSize = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "eyeToScreenDistance"); result.eyeToScreenDistance = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "lensSeparationDistance"); result.lensSeparationDistance = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    lua_getfield(L, index, "interpupillaryDistance"); result.interpupillaryDistance = (float)luaL_checknumber(L, -1); lua_pop(L, 1);
    return result;
}

static void LuaPush_Color(lua_State *L, Color color)
{
    lua_createtable(L, 0, 4);
    LuaPush_int(L, color.r); lua_setfield(L, -2, "r");
    LuaPush_int(L, color.g); lua_setfield(L, -2, "g");
    LuaPush_int(L, color.b); lua_setfield(L, -2, "b");
    LuaPush_int(L, color.a); lua_setfield(L, -2, "a");
}

static void LuaPush_Vector2(lua_State *L, Vector2 vec)
{
    lua_createtable(L, 0, 2);
    LuaPush_float(L, vec.x); lua_setfield(L, -2, "x");
    LuaPush_float(L, vec.y); lua_setfield(L, -2, "y");
}

static void LuaPush_Vector3(lua_State *L, Vector3 vec)
{
    lua_createtable(L, 0, 3);
    LuaPush_float(L, vec.x); lua_setfield(L, -2, "x");
    LuaPush_float(L, vec.y); lua_setfield(L, -2, "y");
    LuaPush_float(L, vec.z); lua_setfield(L, -2, "z");
}

static void LuaPush_Vector4(lua_State *L, Vector4 vec)
{
    lua_createtable(L, 0, 4);
    LuaPush_float(L, vec.x); lua_setfield(L, -2, "x");
    LuaPush_float(L, vec.y); lua_setfield(L, -2, "y");
    LuaPush_float(L, vec.z); lua_setfield(L, -2, "z");
    LuaPush_float(L, vec.w); lua_setfield(L, -2, "w");
}

static void LuaPush_Quaternion(lua_State *L, Quaternion vec)
{
    LuaPush_Vector4(L, vec);
}

static void LuaPush_Matrix(lua_State *L, Matrix matrix)
{
    static const char *names[16] = {
        "m0","m4","m8","m12","m1","m5","m9","m13","m2","m6","m10","m14","m3","m7","m11","m15"
    };
    float *ptr = &matrix.m0;
    lua_createtable(L, 0, 16);
    for (int i = 0; i < 16; i++)
    {
        LuaPush_float(L, ptr[i]);
        lua_setfield(L, -2, names[i]);
    }
}

static void LuaPush_Rectangle(lua_State *L, Rectangle rect)
{
    lua_createtable(L, 0, 4);
    LuaPush_float(L, rect.x); lua_setfield(L, -2, "x");
    LuaPush_float(L, rect.y); lua_setfield(L, -2, "y");
    LuaPush_float(L, rect.width); lua_setfield(L, -2, "width");
    LuaPush_float(L, rect.height); lua_setfield(L, -2, "height");
}

static void LuaPush_Ray(lua_State *L, Ray ray)
{
    lua_createtable(L, 0, 2);
    LuaPush_Vector3(L, ray.position); lua_setfield(L, -2, "position");
    LuaPush_Vector3(L, ray.direction); lua_setfield(L, -2, "direction");
}

static void LuaPush_RayCollision(lua_State *L, RayCollision hit)
{
    lua_createtable(L, 0, 4);
    LuaPush_bool(L, hit.hit); lua_setfield(L, -2, "hit");
    LuaPush_float(L, hit.distance); lua_setfield(L, -2, "distance");
    LuaPush_Vector3(L, hit.point); lua_setfield(L, -2, "point");
    LuaPush_Vector3(L, hit.normal); lua_setfield(L, -2, "normal");
}

static void LuaPush_BoundingBox(lua_State *L, BoundingBox bb)
{
    lua_createtable(L, 0, 2);
    LuaPush_Vector3(L, bb.min); lua_setfield(L, -2, "min");
    LuaPush_Vector3(L, bb.max); lua_setfield(L, -2, "max");
}

static void LuaPush_Camera(lua_State *L, Camera cam)
{
    lua_createtable(L, 0, 5);
    LuaWrite_Camera(L, lua_gettop(L), cam);
}

static void LuaPush_Camera2D(lua_State *L, Camera2D cam)
{
    lua_createtable(L, 0, 4);
    LuaPush_Vector2(L, cam.offset); lua_setfield(L, -2, "offset");
    LuaPush_Vector2(L, cam.target); lua_setfield(L, -2, "target");
    LuaPush_float(L, cam.rotation); lua_setfield(L, -2, "rotation");
    LuaPush_float(L, cam.zoom); lua_setfield(L, -2, "zoom");
}

static void LuaPush_NPatchInfo(lua_State *L, NPatchInfo info)
{
    lua_createtable(L, 0, 6);
    LuaPush_Rectangle(L, info.source); lua_setfield(L, -2, "source");
    LuaPush_int(L, info.left); lua_setfield(L, -2, "left");
    LuaPush_int(L, info.top); lua_setfield(L, -2, "top");
    LuaPush_int(L, info.right); lua_setfield(L, -2, "right");
    LuaPush_int(L, info.bottom); lua_setfield(L, -2, "bottom");
    LuaPush_int(L, info.layout); lua_setfield(L, -2, "layout");
}

static void LuaPush_Transform(lua_State *L, Transform t)
{
    lua_createtable(L, 0, 3);
    LuaPush_Vector3(L, t.translation); lua_setfield(L, -2, "translation");
    LuaPush_Quaternion(L, t.rotation); lua_setfield(L, -2, "rotation");
    LuaPush_Vector3(L, t.scale); lua_setfield(L, -2, "scale");
}

static void LuaPush_VrDeviceInfo(lua_State *L, VrDeviceInfo info)
{
    lua_createtable(L, 0, 7);
    LuaPush_int(L, info.hResolution); lua_setfield(L, -2, "hResolution");
    LuaPush_int(L, info.vResolution); lua_setfield(L, -2, "vResolution");
    LuaPush_float(L, info.hScreenSize); lua_setfield(L, -2, "hScreenSize");
    LuaPush_float(L, info.vScreenSize); lua_setfield(L, -2, "vScreenSize");
    LuaPush_float(L, info.eyeToScreenDistance); lua_setfield(L, -2, "eyeToScreenDistance");
    LuaPush_float(L, info.lensSeparationDistance); lua_setfield(L, -2, "lensSeparationDistance");
    LuaPush_float(L, info.interpupillaryDistance); lua_setfield(L, -2, "interpupillaryDistance");
}

//----------------------------------------------------------------------------------
// Structure constructors
//----------------------------------------------------------------------------------
static int lua_Color(lua_State *L)
{
    LuaPush_Color(L, (Color){
        (unsigned char)luaL_checkinteger(L, 1),
        (unsigned char)luaL_checkinteger(L, 2),
        (unsigned char)luaL_checkinteger(L, 3),
        (unsigned char)luaL_optinteger(L, 4, 255)
    });
    return 1;
}

static int lua_Vector2(lua_State *L)
{
    LuaPush_Vector2(L, (Vector2){ (float)luaL_checknumber(L, 1), (float)luaL_checknumber(L, 2) });
    return 1;
}

static int lua_Vector3(lua_State *L)
{
    LuaPush_Vector3(L, (Vector3){ (float)luaL_checknumber(L, 1), (float)luaL_checknumber(L, 2), (float)luaL_checknumber(L, 3) });
    return 1;
}

static int lua_Vector4(lua_State *L)
{
    LuaPush_Vector4(L, (Vector4){ (float)luaL_checknumber(L, 1), (float)luaL_checknumber(L, 2), (float)luaL_checknumber(L, 3), (float)luaL_checknumber(L, 4) });
    return 1;
}

static int lua_Quaternion(lua_State *L)
{
    return lua_Vector4(L);
}

static int lua_Matrix(lua_State *L)
{
    Matrix m = { 0 };
    if (lua_istable(L, 1)) m = LuaGetArgument_Matrix(L, 1);
    LuaPush_Matrix(L, m);
    return 1;
}

static int lua_Rectangle(lua_State *L)
{
    LuaPush_Rectangle(L, (Rectangle){
        (float)luaL_checknumber(L, 1), (float)luaL_checknumber(L, 2),
        (float)luaL_checknumber(L, 3), (float)luaL_checknumber(L, 4)
    });
    return 1;
}

static int lua_Ray(lua_State *L)
{
    LuaPush_Ray(L, (Ray){ LuaGetArgument_Vector3(L, 1), LuaGetArgument_Vector3(L, 2) });
    return 1;
}

static int lua_RayCollision(lua_State *L)
{
    RayCollision hit = { 0 };
    hit.hit = lua_toboolean(L, 1);
    hit.distance = (float)luaL_checknumber(L, 2);
    hit.point = LuaGetArgument_Vector3(L, 3);
    hit.normal = LuaGetArgument_Vector3(L, 4);
    LuaPush_RayCollision(L, hit);
    return 1;
}

static int lua_BoundingBox(lua_State *L)
{
    LuaPush_BoundingBox(L, (BoundingBox){ LuaGetArgument_Vector3(L, 1), LuaGetArgument_Vector3(L, 2) });
    return 1;
}

static int lua_Camera(lua_State *L)
{
    Camera cam = { 0 };
    cam.position = LuaGetArgument_Vector3(L, 1);
    cam.target = LuaGetArgument_Vector3(L, 2);
    cam.up = LuaGetArgument_Vector3(L, 3);
    cam.fovy = (float)luaL_checknumber(L, 4);
    cam.projection = (int)luaL_optinteger(L, 5, CAMERA_PERSPECTIVE);
    LuaPush_Camera(L, cam);
    return 1;
}

#define lua_Camera3D lua_Camera

static int lua_Camera2D(lua_State *L)
{
    Camera2D cam = { 0 };
    cam.offset = LuaGetArgument_Vector2(L, 1);
    cam.target = LuaGetArgument_Vector2(L, 2);
    cam.rotation = (float)luaL_checknumber(L, 3);
    cam.zoom = (float)luaL_checknumber(L, 4);
    LuaPush_Camera2D(L, cam);
    return 1;
}

static int lua_NPatchInfo(lua_State *L)
{
    NPatchInfo info = { 0 };
    info.source = LuaGetArgument_Rectangle(L, 1);
    info.left = (int)luaL_checkinteger(L, 2);
    info.top = (int)luaL_checkinteger(L, 3);
    info.right = (int)luaL_checkinteger(L, 4);
    info.bottom = (int)luaL_checkinteger(L, 5);
    info.layout = (int)luaL_checkinteger(L, 6);
    LuaPush_NPatchInfo(L, info);
    return 1;
}

static int lua_Transform(lua_State *L)
{
    Transform t = { 0 };
    t.translation = LuaGetArgument_Vector3(L, 1);
    t.rotation = LuaGetArgument_Quaternion(L, 2);
    t.scale = LuaGetArgument_Vector3(L, 3);
    LuaPush_Transform(L, t);
    return 1;
}

//----------------------------------------------------------------------------------
// Hand-written wrappers for pointer / variadic / list APIs
//----------------------------------------------------------------------------------
static int lua_TraceLog(lua_State *L)
{
    int logLevel = (int)luaL_checkinteger(L, 1);
    const char *text = luaL_checkstring(L, 2);
    TraceLog(logLevel, "%s", text);
    return 0;
}

static int lua_TextFormat(lua_State *L)
{
    lua_getglobal(L, "string");
    lua_getfield(L, -1, "format");
    lua_remove(L, -2);
    lua_insert(L, 1);
    lua_call(L, lua_gettop(L) - 1, 1);
    return 1;
}

static int lua_LoadFileData(lua_State *L)
{
    const char *fileName = luaL_checkstring(L, 1);
    int dataSize = 0;
    unsigned char *data = LoadFileData(fileName, &dataSize);
    if (!data) { lua_pushnil(L); return 1; }
    lua_pushlstring(L, (const char *)data, (size_t)dataSize);
    UnloadFileData(data);
    return 1;
}

static int lua_SaveFileData(lua_State *L)
{
    const char *fileName = luaL_checkstring(L, 1);
    size_t len = 0;
    const char *data = luaL_checklstring(L, 2, &len);
    lua_pushboolean(L, SaveFileData(fileName, (void *)data, (int)len));
    return 1;
}

static int lua_LoadFileText(lua_State *L)
{
    char *text = LoadFileText(luaL_checkstring(L, 1));
    if (!text) { lua_pushnil(L); return 1; }
    lua_pushstring(L, text);
    UnloadFileText(text);
    return 1;
}

static int lua_UnloadFileData(lua_State *L) { (void)L; return 0; }
static int lua_UnloadFileText(lua_State *L) { (void)L; return 0; }

static void LuaPushFilePathList(lua_State *L, FilePathList list)
{
    lua_createtable(L, (int)list.count, 0);
    for (unsigned int i = 0; i < list.count; i++)
    {
        lua_pushstring(L, list.paths[i]);
        lua_rawseti(L, -2, (lua_Integer)(i + 1));
    }
}

static int lua_LoadDroppedFiles(lua_State *L)
{
    FilePathList list = LoadDroppedFiles();
    LuaPushFilePathList(L, list);
    UnloadDroppedFiles(list);
    return 1;
}

static int lua_LoadDirectoryFiles(lua_State *L)
{
    FilePathList list = LoadDirectoryFiles(luaL_checkstring(L, 1));
    LuaPushFilePathList(L, list);
    UnloadDirectoryFiles(list);
    return 1;
}

static int lua_LoadDirectoryFilesEx(lua_State *L)
{
    FilePathList list = LoadDirectoryFilesEx(luaL_checkstring(L, 1), luaL_checkstring(L, 2), lua_toboolean(L, 3));
    LuaPushFilePathList(L, list);
    UnloadDirectoryFiles(list);
    return 1;
}

static int lua_UnloadDroppedFiles(lua_State *L) { (void)L; return 0; }
static int lua_UnloadDirectoryFiles(lua_State *L) { (void)L; return 0; }

static int lua_UpdateTexture(lua_State *L)
{
    Texture2D texture = LuaGetArgument_Texture2D(L, 1);
    size_t len = 0;
    const char *pixels = luaL_checklstring(L, 2, &len);
    UpdateTexture(texture, pixels);
    return 0;
}

static int lua_UpdateTextureRec(lua_State *L)
{
    Texture2D texture = LuaGetArgument_Texture2D(L, 1);
    Rectangle rec = LuaGetArgument_Rectangle(L, 2);
    size_t len = 0;
    const char *pixels = luaL_checklstring(L, 3, &len);
    UpdateTextureRec(texture, rec, pixels);
    return 0;
}

static int lua_LoadImageColors(lua_State *L)
{
    Image image = LuaGetArgument_Image(L, 1);
    Color *colors = LoadImageColors(image);
    int count = image.width * image.height;
    lua_createtable(L, count, 0);
    if (colors)
    {
        for (int i = 0; i < count; i++)
        {
            LuaPush_Color(L, colors[i]);
            lua_rawseti(L, -2, i + 1);
        }
        UnloadImageColors(colors);
    }
    return 1;
}

static int lua_UnloadImageColors(lua_State *L) { (void)L; return 0; }

static int lua_SetShaderValue(lua_State *L)
{
    Shader shader = LuaGetArgument_Shader(L, 1);
    int locIndex = (int)luaL_checkinteger(L, 2);
    int uniformType = (int)luaL_checkinteger(L, 4);
    float values[4] = { 0 };
    int ivalues[4] = { 0 };

    if (lua_istable(L, 3))
    {
        int n = (int)luaL_len(L, 3);
        if (n > 4) n = 4;
        for (int i = 0; i < n; i++)
        {
            lua_rawgeti(L, 3, i + 1);
            values[i] = (float)luaL_checknumber(L, -1);
            ivalues[i] = (int)luaL_checkinteger(L, -1);
            lua_pop(L, 1);
        }
    }
    else if (lua_isnumber(L, 3))
    {
        values[0] = (float)lua_tonumber(L, 3);
        ivalues[0] = (int)lua_tointeger(L, 3);
    }
    else luaL_argerror(L, 3, "number or table expected");

    switch (uniformType)
    {
        case SHADER_UNIFORM_INT:
        case SHADER_UNIFORM_SAMPLER2D:
            SetShaderValue(shader, locIndex, ivalues, uniformType);
            break;
        default:
            SetShaderValue(shader, locIndex, values, uniformType);
            break;
    }
    return 0;
}

static int lua_UpdateCamera(lua_State *L)
{
    Camera camera = LuaGetArgument_Camera(L, 1);
    int mode = (int)luaL_checkinteger(L, 2);
    UpdateCamera(&camera, mode);
    LuaWrite_Camera(L, 1, camera);
    lua_pushvalue(L, 1);
    return 1;
}

static int lua_UpdateCameraPro(lua_State *L)
{
    Camera camera = LuaGetArgument_Camera(L, 1);
    Vector3 movement = LuaGetArgument_Vector3(L, 2);
    Vector3 rotation = LuaGetArgument_Vector3(L, 3);
    float zoom = (float)luaL_checknumber(L, 4);
    UpdateCameraPro(&camera, movement, rotation, zoom);
    LuaWrite_Camera(L, 1, camera);
    lua_pushvalue(L, 1);
    return 1;
}

static int lua_LoadFontEx(lua_State *L)
{
    const char *fileName = luaL_checkstring(L, 1);
    int fontSize = (int)luaL_checkinteger(L, 2);
    int *codepoints = NULL;
    int codepointCount = 0;

    if (!lua_isnoneornil(L, 3) && lua_istable(L, 3))
    {
        codepointCount = (int)luaL_len(L, 3);
        codepoints = (int *)RL_MALLOC(codepointCount * sizeof(int));
        for (int i = 0; i < codepointCount; i++)
        {
            lua_rawgeti(L, 3, i + 1);
            codepoints[i] = (int)luaL_checkinteger(L, -1);
            lua_pop(L, 1);
        }
    }

    Font font = LoadFontEx(fileName, fontSize, codepoints, codepointCount);
    if (codepoints) RL_FREE(codepoints);
    LuaPush_Font(L, font);
    return 1;
}

static int lua_LoadImageFromMemory(lua_State *L)
{
    const char *fileType = luaL_checkstring(L, 1);
    size_t dataSize = 0;
    const char *fileData = luaL_checklstring(L, 2, &dataSize);
    Image image = LoadImageFromMemory(fileType, (const unsigned char *)fileData, (int)dataSize);
    LuaPush_Image(L, image);
    return 1;
}

static Vector2 *LuaGetVector2Array(lua_State *L, int index, int *count)
{
    luaL_checktype(L, index, LUA_TTABLE);
    int n = (int)luaL_len(L, index);
    Vector2 *points = (Vector2 *)RL_MALLOC((n > 0 ? n : 1) * sizeof(Vector2));
    for (int i = 0; i < n; i++)
    {
        lua_rawgeti(L, index, i + 1);
        points[i] = LuaGetArgument_Vector2(L, -1);
        lua_pop(L, 1);
    }
    *count = n;
    return points;
}

static int lua_DrawLineStrip(lua_State *L)
{
    int count = 0;
    Vector2 *points = LuaGetVector2Array(L, 1, &count);
    Color color = LuaGetArgument_Color(L, 2);
    DrawLineStrip(points, count, color);
    RL_FREE(points);
    return 0;
}

static int lua_DrawTriangleFan(lua_State *L)
{
    int count = 0;
    Vector2 *points = LuaGetVector2Array(L, 1, &count);
    Color color = LuaGetArgument_Color(L, 2);
    DrawTriangleFan(points, count, color);
    RL_FREE(points);
    return 0;
}

static int lua_DrawTriangleStrip(lua_State *L)
{
    int count = 0;
    Vector2 *points = LuaGetVector2Array(L, 1, &count);
    Color color = LuaGetArgument_Color(L, 2);
    DrawTriangleStrip(points, count, color);
    RL_FREE(points);
    return 0;
}

static int lua_CompressData(lua_State *L)
{
    size_t dataSize = 0;
    const char *data = luaL_checklstring(L, 1, &dataSize);
    int compSize = 0;
    unsigned char *comp = CompressData((const unsigned char *)data, (int)dataSize, &compSize);
    if (!comp) { lua_pushnil(L); return 1; }
    lua_pushlstring(L, (const char *)comp, (size_t)compSize);
    MemFree(comp);
    return 1;
}

static int lua_DecompressData(lua_State *L)
{
    size_t compSize = 0;
    const char *comp = luaL_checklstring(L, 1, &compSize);
    int dataSize = 0;
    unsigned char *data = DecompressData((const unsigned char *)comp, (int)compSize, &dataSize);
    if (!data) { lua_pushnil(L); return 1; }
    lua_pushlstring(L, (const char *)data, (size_t)dataSize);
    MemFree(data);
    return 1;
}

static int lua_EncodeDataBase64(lua_State *L)
{
    size_t dataSize = 0;
    const char *data = luaL_checklstring(L, 1, &dataSize);
    int outputSize = 0;
    char *encoded = EncodeDataBase64((const unsigned char *)data, (int)dataSize, &outputSize);
    if (!encoded) { lua_pushnil(L); return 1; }
    lua_pushstring(L, encoded);
    MemFree(encoded);
    return 1;
}

static int lua_DecodeDataBase64(lua_State *L)
{
    const char *text = luaL_checkstring(L, 1);
    int outputSize = 0;
    unsigned char *decoded = DecodeDataBase64(text, &outputSize);
    if (!decoded) { lua_pushnil(L); return 1; }
    lua_pushlstring(L, (const char *)decoded, (size_t)outputSize);
    MemFree(decoded);
    return 1;
}

static int lua_UpdateSound(lua_State *L)
{
    Sound sound = LuaGetArgument_Sound(L, 1);
    size_t len = 0;
    const char *data = luaL_checklstring(L, 2, &len);
    int sampleCount = (int)luaL_optinteger(L, 3, (lua_Integer)len);
    UpdateSound(sound, data, sampleCount);
    return 0;
}

static int lua_UpdateAudioStream(lua_State *L)
{
    AudioStream stream = LuaGetArgument_AudioStream(L, 1);
    if (lua_istable(L, 2))
    {
        int n = (int)luaL_len(L, 2);
        float *buf = (float *)RL_MALLOC((size_t)n * sizeof(float));
        if (buf == NULL) luaL_error(L, "out of memory");
        for (int i = 0; i < n; i++)
        {
            lua_rawgeti(L, 2, i + 1);
            buf[i] = (float)luaL_checknumber(L, -1);
            lua_pop(L, 1);
        }
        int frameCount = (int)luaL_optinteger(L, 3, n);
        UpdateAudioStream(stream, buf, frameCount);
        RL_FREE(buf);
        return 0;
    }

    size_t len = 0;
    const char *data = luaL_checklstring(L, 2, &len);
    int frameCount = (int)luaL_optinteger(L, 3, (lua_Integer)len);
    UpdateAudioStream(stream, data, frameCount);
    return 0;
}

static int lua_LoadWaveFromMemory(lua_State *L)
{
    const char *fileType = luaL_checkstring(L, 1);
    size_t dataSize = 0;
    const char *fileData = luaL_checklstring(L, 2, &dataSize);
    Wave wave = LoadWaveFromMemory(fileType, (const unsigned char *)fileData, (int)dataSize);
    LuaPush_Wave(L, wave);
    return 1;
}

static int lua_LoadMusicStreamFromMemory(lua_State *L)
{
    const char *fileType = luaL_checkstring(L, 1);
    size_t dataSize = 0;
    const char *data = luaL_checklstring(L, 2, &dataSize);
    Music music = LoadMusicStreamFromMemory(fileType, (const unsigned char *)data, (int)dataSize);
    LuaPush_Music(L, music);
    return 1;
}

static int lua_CheckCollisionLines(lua_State *L)
{
    Vector2 startPos1 = LuaGetArgument_Vector2(L, 1);
    Vector2 endPos1 = LuaGetArgument_Vector2(L, 2);
    Vector2 startPos2 = LuaGetArgument_Vector2(L, 3);
    Vector2 endPos2 = LuaGetArgument_Vector2(L, 4);
    Vector2 collisionPoint = { 0 };
    bool hit = CheckCollisionLines(startPos1, endPos1, startPos2, endPos2, &collisionPoint);
    LuaPush_bool(L, hit);
    LuaPush_Vector2(L, collisionPoint);
    return 2;
}

static int lua_LoadShader(lua_State *L)
{
    const char *vsFileName = lua_isnoneornil(L, 1) ? NULL : luaL_checkstring(L, 1);
    const char *fsFileName = lua_isnoneornil(L, 2) ? NULL : luaL_checkstring(L, 2);
    Shader shader = LoadShader(vsFileName, fsFileName);
    LuaPush_Shader(L, shader);
    return 1;
}

static int lua_LoadShaderFromMemory(lua_State *L)
{
    const char *vsCode = lua_isnoneornil(L, 1) ? NULL : luaL_checkstring(L, 1);
    const char *fsCode = lua_isnoneornil(L, 2) ? NULL : luaL_checkstring(L, 2);
    Shader shader = LoadShaderFromMemory(vsCode, fsCode);
    LuaPush_Shader(L, shader);
    return 1;
}

static int lua_GetImageData(lua_State *L)
{
    Image image = LuaGetArgument_Image(L, 1);
    int size = GetPixelDataSize(image.width, image.height, image.format);
    if ((image.data == NULL) || (size <= 0)) lua_pushliteral(L, "");
    else lua_pushlstring(L, (const char *)image.data, (size_t)size);
    return 1;
}

static int lua_SetModelTexture(lua_State *L)
{
    Model *model = (Model *)luaL_checkudata(L, 1, "Model");
    int mapType = (int)luaL_checkinteger(L, 2);
    Texture2D texture = LuaGetArgument_Texture2D(L, 3);
    luaL_argcheck(L, (model->materialCount > 0) && (model->materials != NULL), 1, "model has no materials");
    SetMaterialTexture(&model->materials[0], mapType, texture);
    lua_pushvalue(L, 1);
    return 1;
}

static int lua_SetModelShader(lua_State *L)
{
    Model *model = (Model *)luaL_checkudata(L, 1, "Model");
    Shader shader = LuaGetArgument_Shader(L, 2);
    luaL_argcheck(L, (model->materialCount > 0) && (model->materials != NULL), 1, "model has no materials");
    model->materials[0].shader = shader;
    lua_pushvalue(L, 1);
    return 1;
}

static int lua_GetModelMesh(lua_State *L)
{
    Model model = LuaGetArgument_Model(L, 1);
    int index = (int)luaL_checkinteger(L, 2);
    luaL_argcheck(L, (index >= 0) && (index < model.meshCount) && (model.meshes != NULL), 2, "mesh index out of range");
    LuaPush_Mesh(L, model.meshes[index]);
    return 1;
}
