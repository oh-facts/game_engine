//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



UNICODE :: 1;
DWRITE_ALPHA_MAX :: 255;

FACILITY_DWRITE :: 0x898;
DWRITE_ERR_BASE :: 0x5000;

IDXGISurface :: struct {}

DWRITE_MEASURING_MODE :: enum s32 {
    NATURAL     :: 0;

    GDI_CLASSIC :: 1;

    GDI_NATURAL :: 2;

    DWRITE_MEASURING_MODE_NATURAL     :: NATURAL;

    DWRITE_MEASURING_MODE_GDI_CLASSIC :: GDI_CLASSIC;

    DWRITE_MEASURING_MODE_GDI_NATURAL :: GDI_NATURAL;
}

DWRITE_GLYPH_IMAGE_FORMATS :: enum s32 {
    NONE                   :: 0;

    TRUETYPE               :: 1;

    CFF                    :: 2;

    COLR                   :: 4;

    SVG                    :: 8;

    PNG                    :: 16;

    JPEG                   :: 32;

    TIFF                   :: 64;

    PREMULTIPLIED_B8G8R8A8 :: 128;

    DWRITE_GLYPH_IMAGE_FORMATS_NONE                   :: NONE;

    DWRITE_GLYPH_IMAGE_FORMATS_TRUETYPE               :: TRUETYPE;

    DWRITE_GLYPH_IMAGE_FORMATS_CFF                    :: CFF;

    DWRITE_GLYPH_IMAGE_FORMATS_COLR                   :: COLR;

    DWRITE_GLYPH_IMAGE_FORMATS_SVG                    :: SVG;

    DWRITE_GLYPH_IMAGE_FORMATS_PNG                    :: PNG;

    DWRITE_GLYPH_IMAGE_FORMATS_JPEG                   :: JPEG;

    DWRITE_GLYPH_IMAGE_FORMATS_TIFF                   :: TIFF;

    DWRITE_GLYPH_IMAGE_FORMATS_PREMULTIPLIED_B8G8R8A8 :: PREMULTIPLIED_B8G8R8A8;
}

D2D1_ALPHA_MODE :: enum s32 {
    UNKNOWN       :: 0;

    PREMULTIPLIED :: 1;

    STRAIGHT      :: 2;

    IGNORE        :: 3;

    FORCE_DWORD   :: -1;

    D2D1_ALPHA_MODE_UNKNOWN       :: UNKNOWN;

    D2D1_ALPHA_MODE_PREMULTIPLIED :: PREMULTIPLIED;

    D2D1_ALPHA_MODE_STRAIGHT      :: STRAIGHT;

    D2D1_ALPHA_MODE_IGNORE        :: IGNORE;

    D2D1_ALPHA_MODE_FORCE_DWORD   :: FORCE_DWORD;
}

D2D1_PIXEL_FORMAT :: struct {
    format:    DXGI_FORMAT;
    alphaMode: D2D1_ALPHA_MODE;
}

D2D_POINT_2U :: struct {
    x: u32;
    y: u32;
}

D2D_POINT_2F :: struct {
    x: float;
    y: float;
}

D2D_POINT_2L :: POINT;

D2D_VECTOR_2F :: struct {
    x: float;
    y: float;
}

D2D_VECTOR_3F :: struct {
    x: float;
    y: float;
    z: float;
}

D2D_VECTOR_4F :: struct {
    x: float;
    y: float;
    z: float;
    w: float;
}

D2D_RECT_F :: struct {
    left:   float;
    top:    float;
    right:  float;
    bottom: float;
}

D2D_RECT_U :: struct {
    left:   u32;
    top:    u32;
    right:  u32;
    bottom: u32;
}

D2D_RECT_L :: RECT;

D2D_SIZE_F :: struct {
    width:  float;
    height: float;
}

D2D_SIZE_U :: struct {
    width:  u32;
    height: u32;
}

D2D_MATRIX_3X2_F :: struct {
    union {
        struct {
            m11: float;

            m12: float;

            m21: float;

            m22: float;

            dx:  float;

            dy:  float;
        }

        struct {
            _11: float;
            _12: float;
            _21: float;
            _22: float;
            _31: float;
            _32: float;
        }

        m: [3] [2] float;
    }
}

D2D_MATRIX_4X3_F :: struct {
    union {
        struct {
            _11: float;
            _12: float;
            _13: float;
            _21: float;
            _22: float;
            _23: float;
            _31: float;
            _32: float;
            _33: float;
            _41: float;
            _42: float;
            _43: float;
        }

        m: [4] [3] float;
    }
}

D2D_MATRIX_4X4_F :: struct {
    union {
        struct {
            _11: float;
            _12: float;
            _13: float;
            _14: float;
            _21: float;
            _22: float;
            _23: float;
            _24: float;
            _31: float;
            _32: float;
            _33: float;
            _34: float;
            _41: float;
            _42: float;
            _43: float;
            _44: float;
        }

        m: [4] [4] float;
    }
}

D2D_MATRIX_5X4_F :: struct {
    union {
        struct {
            _11: float;
            _12: float;
            _13: float;
            _14: float;
            _21: float;
            _22: float;
            _23: float;
            _24: float;
            _31: float;
            _32: float;
            _33: float;
            _34: float;
            _41: float;
            _42: float;
            _43: float;
            _44: float;
            _51: float;
            _52: float;
            _53: float;
            _54: float;
        }

        m: [5] [4] float;
    }
}

D2D1_POINT_2F :: D2D_POINT_2F;
D2D1_POINT_2U :: D2D_POINT_2U;
D2D1_POINT_2L :: D2D_POINT_2L;
D2D1_RECT_F :: D2D_RECT_F;
D2D1_RECT_U :: D2D_RECT_U;
D2D1_RECT_L :: D2D_RECT_L;
D2D1_SIZE_F :: D2D_SIZE_F;
D2D1_SIZE_U :: D2D_SIZE_U;
D2D1_MATRIX_3X2_F :: D2D_MATRIX_3X2_F;

DWRITE_FONT_FILE_TYPE :: enum s32 {
    UNKNOWN             :: 0;

    CFF                 :: 1;

    TRUETYPE            :: 2;

    OPENTYPE_COLLECTION :: 3;

    TYPE1_PFM           :: 4;

    TYPE1_PFB           :: 5;

    VECTOR              :: 6;

    BITMAP              :: 7;

    TRUETYPE_COLLECTION :: 3;

    DWRITE_FONT_FILE_TYPE_UNKNOWN             :: UNKNOWN;

    DWRITE_FONT_FILE_TYPE_CFF                 :: CFF;

    DWRITE_FONT_FILE_TYPE_TRUETYPE            :: TRUETYPE;

    DWRITE_FONT_FILE_TYPE_OPENTYPE_COLLECTION :: OPENTYPE_COLLECTION;

    DWRITE_FONT_FILE_TYPE_TYPE1_PFM           :: TYPE1_PFM;

    DWRITE_FONT_FILE_TYPE_TYPE1_PFB           :: TYPE1_PFB;

    DWRITE_FONT_FILE_TYPE_VECTOR              :: VECTOR;

    DWRITE_FONT_FILE_TYPE_BITMAP              :: BITMAP;

    DWRITE_FONT_FILE_TYPE_TRUETYPE_COLLECTION :: TRUETYPE_COLLECTION;
}

DWRITE_FONT_FACE_TYPE :: enum s32 {
    CFF                 :: 0;

    TRUETYPE            :: 1;

    OPENTYPE_COLLECTION :: 2;

    TYPE1               :: 3;

    VECTOR              :: 4;

    BITMAP              :: 5;

    UNKNOWN             :: 6;

    RAW_CFF             :: 7;

    TRUETYPE_COLLECTION :: 2;

    DWRITE_FONT_FACE_TYPE_CFF                 :: CFF;

    DWRITE_FONT_FACE_TYPE_TRUETYPE            :: TRUETYPE;

    DWRITE_FONT_FACE_TYPE_OPENTYPE_COLLECTION :: OPENTYPE_COLLECTION;

    DWRITE_FONT_FACE_TYPE_TYPE1               :: TYPE1;

    DWRITE_FONT_FACE_TYPE_VECTOR              :: VECTOR;

    DWRITE_FONT_FACE_TYPE_BITMAP              :: BITMAP;

    DWRITE_FONT_FACE_TYPE_UNKNOWN             :: UNKNOWN;

    DWRITE_FONT_FACE_TYPE_RAW_CFF             :: RAW_CFF;

    DWRITE_FONT_FACE_TYPE_TRUETYPE_COLLECTION :: TRUETYPE_COLLECTION;
}

DWRITE_FONT_SIMULATIONS :: enum s32 {
    NONE    :: 0;

    BOLD    :: 1;

    OBLIQUE :: 2;

    DWRITE_FONT_SIMULATIONS_NONE    :: NONE;

    DWRITE_FONT_SIMULATIONS_BOLD    :: BOLD;

    DWRITE_FONT_SIMULATIONS_OBLIQUE :: OBLIQUE;
}

DWRITE_FONT_WEIGHT :: enum s32 {
    THIN        :: 100;

    EXTRA_LIGHT :: 200;

    ULTRA_LIGHT :: 200;

    LIGHT       :: 300;

    SEMI_LIGHT  :: 350;

    NORMAL      :: 400;

    REGULAR     :: 400;

    MEDIUM      :: 500;

    DEMI_BOLD   :: 600;

    SEMI_BOLD   :: 600;

    BOLD        :: 700;

    EXTRA_BOLD  :: 800;

    ULTRA_BOLD  :: 800;

    BLACK       :: 900;

    HEAVY       :: 900;

    EXTRA_BLACK :: 950;

    ULTRA_BLACK :: 950;

    DWRITE_FONT_WEIGHT_THIN        :: THIN;

    DWRITE_FONT_WEIGHT_EXTRA_LIGHT :: EXTRA_LIGHT;

    DWRITE_FONT_WEIGHT_ULTRA_LIGHT :: ULTRA_LIGHT;

    DWRITE_FONT_WEIGHT_LIGHT       :: LIGHT;

    DWRITE_FONT_WEIGHT_SEMI_LIGHT  :: SEMI_LIGHT;

    DWRITE_FONT_WEIGHT_NORMAL      :: NORMAL;

    DWRITE_FONT_WEIGHT_REGULAR     :: REGULAR;

    DWRITE_FONT_WEIGHT_MEDIUM      :: MEDIUM;

    DWRITE_FONT_WEIGHT_DEMI_BOLD   :: DEMI_BOLD;

    DWRITE_FONT_WEIGHT_SEMI_BOLD   :: SEMI_BOLD;

    DWRITE_FONT_WEIGHT_BOLD        :: BOLD;

    DWRITE_FONT_WEIGHT_EXTRA_BOLD  :: EXTRA_BOLD;

    DWRITE_FONT_WEIGHT_ULTRA_BOLD  :: ULTRA_BOLD;

    DWRITE_FONT_WEIGHT_BLACK       :: BLACK;

    DWRITE_FONT_WEIGHT_HEAVY       :: HEAVY;

    DWRITE_FONT_WEIGHT_EXTRA_BLACK :: EXTRA_BLACK;

    DWRITE_FONT_WEIGHT_ULTRA_BLACK :: ULTRA_BLACK;
}

DWRITE_FONT_STRETCH :: enum s32 {
    UNDEFINED       :: 0;

    ULTRA_CONDENSED :: 1;

    EXTRA_CONDENSED :: 2;

    CONDENSED       :: 3;

    SEMI_CONDENSED  :: 4;

    NORMAL          :: 5;

    MEDIUM          :: 5;

    SEMI_EXPANDED   :: 6;

    EXPANDED        :: 7;

    EXTRA_EXPANDED  :: 8;

    ULTRA_EXPANDED  :: 9;

    DWRITE_FONT_STRETCH_UNDEFINED       :: UNDEFINED;

    DWRITE_FONT_STRETCH_ULTRA_CONDENSED :: ULTRA_CONDENSED;

    DWRITE_FONT_STRETCH_EXTRA_CONDENSED :: EXTRA_CONDENSED;

    DWRITE_FONT_STRETCH_CONDENSED       :: CONDENSED;

    DWRITE_FONT_STRETCH_SEMI_CONDENSED  :: SEMI_CONDENSED;

    DWRITE_FONT_STRETCH_NORMAL          :: NORMAL;

    DWRITE_FONT_STRETCH_MEDIUM          :: MEDIUM;

    DWRITE_FONT_STRETCH_SEMI_EXPANDED   :: SEMI_EXPANDED;

    DWRITE_FONT_STRETCH_EXPANDED        :: EXPANDED;

    DWRITE_FONT_STRETCH_EXTRA_EXPANDED  :: EXTRA_EXPANDED;

    DWRITE_FONT_STRETCH_ULTRA_EXPANDED  :: ULTRA_EXPANDED;
}

DWRITE_FONT_STYLE :: enum s32 {
    NORMAL  :: 0;

    OBLIQUE :: 1;

    ITALIC  :: 2;

    DWRITE_FONT_STYLE_NORMAL  :: NORMAL;

    DWRITE_FONT_STYLE_OBLIQUE :: OBLIQUE;

    DWRITE_FONT_STYLE_ITALIC  :: ITALIC;
}

DWRITE_INFORMATIONAL_STRING_ID :: enum s32 {
    NONE                             :: 0;

    COPYRIGHT_NOTICE                 :: 1;

    VERSION_STRINGS                  :: 2;

    TRADEMARK                        :: 3;

    MANUFACTURER                     :: 4;

    DESIGNER                         :: 5;

    DESIGNER_URL                     :: 6;

    DESCRIPTION                      :: 7;

    FONT_VENDOR_URL                  :: 8;

    LICENSE_DESCRIPTION              :: 9;

    LICENSE_INFO_URL                 :: 10;

    WIN32_FAMILY_NAMES               :: 11;

    WIN32_SUBFAMILY_NAMES            :: 12;

    TYPOGRAPHIC_FAMILY_NAMES         :: 13;

    TYPOGRAPHIC_SUBFAMILY_NAMES      :: 14;

    SAMPLE_TEXT                      :: 15;

    FULL_NAME                        :: 16;

    POSTSCRIPT_NAME                  :: 17;

    POSTSCRIPT_CID_NAME              :: 18;

    WEIGHT_STRETCH_STYLE_FAMILY_NAME :: 19;

    DESIGN_SCRIPT_LANGUAGE_TAG       :: 20;

    SUPPORTED_SCRIPT_LANGUAGE_TAG    :: 21;

    PREFERRED_FAMILY_NAMES           :: 13;
    PREFERRED_SUBFAMILY_NAMES        :: 14;
    WWS_FAMILY_NAME                  :: 19;

    DWRITE_INFORMATIONAL_STRING_NONE                             :: NONE;

    DWRITE_INFORMATIONAL_STRING_COPYRIGHT_NOTICE                 :: COPYRIGHT_NOTICE;

    DWRITE_INFORMATIONAL_STRING_VERSION_STRINGS                  :: VERSION_STRINGS;

    DWRITE_INFORMATIONAL_STRING_TRADEMARK                        :: TRADEMARK;

    DWRITE_INFORMATIONAL_STRING_MANUFACTURER                     :: MANUFACTURER;

    DWRITE_INFORMATIONAL_STRING_DESIGNER                         :: DESIGNER;

    DWRITE_INFORMATIONAL_STRING_DESIGNER_URL                     :: DESIGNER_URL;

    DWRITE_INFORMATIONAL_STRING_DESCRIPTION                      :: DESCRIPTION;

    DWRITE_INFORMATIONAL_STRING_FONT_VENDOR_URL                  :: FONT_VENDOR_URL;

    DWRITE_INFORMATIONAL_STRING_LICENSE_DESCRIPTION              :: LICENSE_DESCRIPTION;

    DWRITE_INFORMATIONAL_STRING_LICENSE_INFO_URL                 :: LICENSE_INFO_URL;

    DWRITE_INFORMATIONAL_STRING_WIN32_FAMILY_NAMES               :: WIN32_FAMILY_NAMES;

    DWRITE_INFORMATIONAL_STRING_WIN32_SUBFAMILY_NAMES            :: WIN32_SUBFAMILY_NAMES;

    DWRITE_INFORMATIONAL_STRING_TYPOGRAPHIC_FAMILY_NAMES         :: TYPOGRAPHIC_FAMILY_NAMES;

    DWRITE_INFORMATIONAL_STRING_TYPOGRAPHIC_SUBFAMILY_NAMES      :: TYPOGRAPHIC_SUBFAMILY_NAMES;

    DWRITE_INFORMATIONAL_STRING_SAMPLE_TEXT                      :: SAMPLE_TEXT;

    DWRITE_INFORMATIONAL_STRING_FULL_NAME                        :: FULL_NAME;

    DWRITE_INFORMATIONAL_STRING_POSTSCRIPT_NAME                  :: POSTSCRIPT_NAME;

    DWRITE_INFORMATIONAL_STRING_POSTSCRIPT_CID_NAME              :: POSTSCRIPT_CID_NAME;

    DWRITE_INFORMATIONAL_STRING_WEIGHT_STRETCH_STYLE_FAMILY_NAME :: WEIGHT_STRETCH_STYLE_FAMILY_NAME;

    DWRITE_INFORMATIONAL_STRING_DESIGN_SCRIPT_LANGUAGE_TAG       :: DESIGN_SCRIPT_LANGUAGE_TAG;

    DWRITE_INFORMATIONAL_STRING_SUPPORTED_SCRIPT_LANGUAGE_TAG    :: SUPPORTED_SCRIPT_LANGUAGE_TAG;

    DWRITE_INFORMATIONAL_STRING_PREFERRED_FAMILY_NAMES           :: PREFERRED_FAMILY_NAMES;
    DWRITE_INFORMATIONAL_STRING_PREFERRED_SUBFAMILY_NAMES        :: PREFERRED_SUBFAMILY_NAMES;
    DWRITE_INFORMATIONAL_STRING_WWS_FAMILY_NAME                  :: WWS_FAMILY_NAME;
}

DWRITE_FONT_METRICS :: struct {
    designUnitsPerEm:       u16;

    ascent:                 u16;

    descent:                u16;

    lineGap:                s16;

    capHeight:              u16;

    xHeight:                u16;

    underlinePosition:      s16;

    underlineThickness:     u16;

    strikethroughPosition:  s16;

    strikethroughThickness: u16;
}

DWRITE_GLYPH_METRICS :: struct {
    leftSideBearing:   s32;

    advanceWidth:      u32;

    rightSideBearing:  s32;

    topSideBearing:    s32;

    advanceHeight:     u32;

    bottomSideBearing: s32;

    verticalOriginY:   s32;
}

DWRITE_GLYPH_OFFSET :: struct {
    advanceOffset:  float;

    ascenderOffset: float;
}

DWRITE_FACTORY_TYPE :: enum s32 {
    SHARED   :: 0;

    ISOLATED :: 1;

    DWRITE_FACTORY_TYPE_SHARED   :: SHARED;

    DWRITE_FACTORY_TYPE_ISOLATED :: ISOLATED;
}

IDWriteFontFileLoader :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontfileloader_vtable: *IDWriteFontFileLoader_VTable;
}
IDWriteFontFileLoader_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    CreateStreamFromKey: (this: *IDWriteFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, fontFileStream: **IDWriteFontFileStream) -> HRESULT #cpp_method;
}
IDWriteFontFileLoader_CreateStreamFromKey :: inline (this: *IDWriteFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, fontFileStream: **IDWriteFontFileStream) -> HRESULT { return this.idwritefontfileloader_vtable.CreateStreamFromKey(this, fontFileReferenceKey, fontFileReferenceKeySize, fontFileStream); }

vtable :: (obj: *IDWriteFontFileLoader) -> *IDWriteFontFileLoader_VTable { return obj.idwritefontfileloader_vtable; }


IDWriteLocalFontFileLoader :: struct {
    #as using idwritefontfileloader: IDWriteFontFileLoader;
    #place idwritefontfileloader; idwritelocalfontfileloader_vtable: *IDWriteLocalFontFileLoader_VTable;
}
IDWriteLocalFontFileLoader_VTable :: struct #type_info_none {
    using idwritefontfileloader: IDWriteFontFileLoader_VTable;
    GetFilePathLengthFromKey: (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, filePathLength: *u32) -> HRESULT #cpp_method;
    GetFilePathFromKey: (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, filePath: *s16, filePathSize: u32) -> HRESULT #cpp_method;
    GetLastWriteTimeFromKey: (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, lastWriteTime: *FILETIME) -> HRESULT #cpp_method;
}
IDWriteLocalFontFileLoader_GetFilePathLengthFromKey :: inline (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, filePathLength: *u32) -> HRESULT { return this.idwritelocalfontfileloader_vtable.GetFilePathLengthFromKey(this, fontFileReferenceKey, fontFileReferenceKeySize, filePathLength); }
IDWriteLocalFontFileLoader_GetFilePathFromKey :: inline (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, filePath: *s16, filePathSize: u32) -> HRESULT { return this.idwritelocalfontfileloader_vtable.GetFilePathFromKey(this, fontFileReferenceKey, fontFileReferenceKeySize, filePath, filePathSize); }
IDWriteLocalFontFileLoader_GetLastWriteTimeFromKey :: inline (this: *IDWriteLocalFontFileLoader, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, lastWriteTime: *FILETIME) -> HRESULT { return this.idwritelocalfontfileloader_vtable.GetLastWriteTimeFromKey(this, fontFileReferenceKey, fontFileReferenceKeySize, lastWriteTime); }

vtable :: (obj: *IDWriteLocalFontFileLoader) -> *IDWriteLocalFontFileLoader_VTable { return obj.idwritelocalfontfileloader_vtable; }


IDWriteFontFileStream :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontfilestream_vtable: *IDWriteFontFileStream_VTable;
}
IDWriteFontFileStream_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    ReadFileFragment: (this: *IDWriteFontFileStream, fragmentStart: **void, fileOffset: u64, fragmentSize: u64, fragmentContext: **void) -> HRESULT #cpp_method;
    ReleaseFileFragment: (this: *IDWriteFontFileStream, fragmentContext: *void) -> void #cpp_method;
    GetFileSize: (this: *IDWriteFontFileStream, fileSize: *u64) -> HRESULT #cpp_method;
    GetLastWriteTime: (this: *IDWriteFontFileStream, lastWriteTime: *u64) -> HRESULT #cpp_method;
}
IDWriteFontFileStream_ReadFileFragment :: inline (this: *IDWriteFontFileStream, fragmentStart: **void, fileOffset: u64, fragmentSize: u64, fragmentContext: **void) -> HRESULT { return this.idwritefontfilestream_vtable.ReadFileFragment(this, fragmentStart, fileOffset, fragmentSize, fragmentContext); }
IDWriteFontFileStream_ReleaseFileFragment :: inline (this: *IDWriteFontFileStream, fragmentContext: *void) { this.idwritefontfilestream_vtable.ReleaseFileFragment(this, fragmentContext); }
IDWriteFontFileStream_GetFileSize :: inline (this: *IDWriteFontFileStream, fileSize: *u64) -> HRESULT { return this.idwritefontfilestream_vtable.GetFileSize(this, fileSize); }
IDWriteFontFileStream_GetLastWriteTime :: inline (this: *IDWriteFontFileStream, lastWriteTime: *u64) -> HRESULT { return this.idwritefontfilestream_vtable.GetLastWriteTime(this, lastWriteTime); }

vtable :: (obj: *IDWriteFontFileStream) -> *IDWriteFontFileStream_VTable { return obj.idwritefontfilestream_vtable; }


IDWriteFontFile :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontfile_vtable: *IDWriteFontFile_VTable;
}
IDWriteFontFile_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetReferenceKey: (this: *IDWriteFontFile, fontFileReferenceKey: **void, fontFileReferenceKeySize: *u32) -> HRESULT #cpp_method;
    GetLoader: (this: *IDWriteFontFile, fontFileLoader: **IDWriteFontFileLoader) -> HRESULT #cpp_method;
    Analyze: (this: *IDWriteFontFile, isSupportedFontType: *BOOL, fontFileType: *DWRITE_FONT_FILE_TYPE, fontFaceType: *DWRITE_FONT_FACE_TYPE, numberOfFaces: *u32) -> HRESULT #cpp_method;
}
IDWriteFontFile_GetReferenceKey :: inline (this: *IDWriteFontFile, fontFileReferenceKey: **void, fontFileReferenceKeySize: *u32) -> HRESULT { return this.idwritefontfile_vtable.GetReferenceKey(this, fontFileReferenceKey, fontFileReferenceKeySize); }
IDWriteFontFile_GetLoader :: inline (this: *IDWriteFontFile, fontFileLoader: **IDWriteFontFileLoader) -> HRESULT { return this.idwritefontfile_vtable.GetLoader(this, fontFileLoader); }
IDWriteFontFile_Analyze :: inline (this: *IDWriteFontFile, isSupportedFontType: *BOOL, fontFileType: *DWRITE_FONT_FILE_TYPE, fontFaceType: *DWRITE_FONT_FACE_TYPE, numberOfFaces: *u32) -> HRESULT { return this.idwritefontfile_vtable.Analyze(this, isSupportedFontType, fontFileType, fontFaceType, numberOfFaces); }

vtable :: (obj: *IDWriteFontFile) -> *IDWriteFontFile_VTable { return obj.idwritefontfile_vtable; }


DWRITE_PIXEL_GEOMETRY :: enum s32 {
    FLAT :: 0;

    RGB  :: 1;

    BGR  :: 2;

    DWRITE_PIXEL_GEOMETRY_FLAT :: FLAT;

    DWRITE_PIXEL_GEOMETRY_RGB  :: RGB;

    DWRITE_PIXEL_GEOMETRY_BGR  :: BGR;
}

DWRITE_RENDERING_MODE :: enum s32 {
    DEFAULT                     :: 0;

    ALIASED                     :: 1;

    GDI_CLASSIC                 :: 2;

    GDI_NATURAL                 :: 3;

    NATURAL                     :: 4;

    NATURAL_SYMMETRIC           :: 5;

    OUTLINE                     :: 6;

    CLEARTYPE_GDI_CLASSIC       :: 2;
    CLEARTYPE_GDI_NATURAL       :: 3;
    CLEARTYPE_NATURAL           :: 4;
    CLEARTYPE_NATURAL_SYMMETRIC :: 5;

    DWRITE_RENDERING_MODE_DEFAULT                     :: DEFAULT;

    DWRITE_RENDERING_MODE_ALIASED                     :: ALIASED;

    DWRITE_RENDERING_MODE_GDI_CLASSIC                 :: GDI_CLASSIC;

    DWRITE_RENDERING_MODE_GDI_NATURAL                 :: GDI_NATURAL;

    DWRITE_RENDERING_MODE_NATURAL                     :: NATURAL;

    DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC           :: NATURAL_SYMMETRIC;

    DWRITE_RENDERING_MODE_OUTLINE                     :: OUTLINE;

    DWRITE_RENDERING_MODE_CLEARTYPE_GDI_CLASSIC       :: CLEARTYPE_GDI_CLASSIC;
    DWRITE_RENDERING_MODE_CLEARTYPE_GDI_NATURAL       :: CLEARTYPE_GDI_NATURAL;
    DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL           :: CLEARTYPE_NATURAL;
    DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL_SYMMETRIC :: CLEARTYPE_NATURAL_SYMMETRIC;
}

DWRITE_MATRIX :: struct {
    m11: float;

    m12: float;

    m21: float;

    m22: float;

    dx:  float;

    dy:  float;
}

IDWriteRenderingParams :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwriterenderingparams_vtable: *IDWriteRenderingParams_VTable;
}
IDWriteRenderingParams_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetGamma: (this: *IDWriteRenderingParams) -> float #cpp_method;
    GetEnhancedContrast: (this: *IDWriteRenderingParams) -> float #cpp_method;
    GetClearTypeLevel: (this: *IDWriteRenderingParams) -> float #cpp_method;
    GetPixelGeometry: (this: *IDWriteRenderingParams) -> DWRITE_PIXEL_GEOMETRY #cpp_method;
    GetRenderingMode: (this: *IDWriteRenderingParams) -> DWRITE_RENDERING_MODE #cpp_method;
}
IDWriteRenderingParams_GetGamma :: inline (this: *IDWriteRenderingParams) -> float { return this.idwriterenderingparams_vtable.GetGamma(this); }
IDWriteRenderingParams_GetEnhancedContrast :: inline (this: *IDWriteRenderingParams) -> float { return this.idwriterenderingparams_vtable.GetEnhancedContrast(this); }
IDWriteRenderingParams_GetClearTypeLevel :: inline (this: *IDWriteRenderingParams) -> float { return this.idwriterenderingparams_vtable.GetClearTypeLevel(this); }
IDWriteRenderingParams_GetPixelGeometry :: inline (this: *IDWriteRenderingParams) -> DWRITE_PIXEL_GEOMETRY { return this.idwriterenderingparams_vtable.GetPixelGeometry(this); }
IDWriteRenderingParams_GetRenderingMode :: inline (this: *IDWriteRenderingParams) -> DWRITE_RENDERING_MODE { return this.idwriterenderingparams_vtable.GetRenderingMode(this); }

vtable :: (obj: *IDWriteRenderingParams) -> *IDWriteRenderingParams_VTable { return obj.idwriterenderingparams_vtable; }


ID2D1SimplifiedGeometrySink :: struct {}

IDWriteGeometrySink :: ID2D1SimplifiedGeometrySink;

IDWriteFontFace :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontface_vtable: *IDWriteFontFace_VTable;
}
IDWriteFontFace_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetType: (this: *IDWriteFontFace) -> DWRITE_FONT_FACE_TYPE #cpp_method;
    GetFiles: (this: *IDWriteFontFace, numberOfFiles: *u32, fontFiles: **IDWriteFontFile) -> HRESULT #cpp_method;
    GetIndex: (this: *IDWriteFontFace) -> u32 #cpp_method;
    GetSimulations: (this: *IDWriteFontFace) -> DWRITE_FONT_SIMULATIONS #cpp_method;
    IsSymbolFont: (this: *IDWriteFontFace) -> BOOL #cpp_method;
    GetMetrics: (this: *IDWriteFontFace, fontFaceMetrics: *DWRITE_FONT_METRICS) -> void #cpp_method;
    GetGlyphCount: (this: *IDWriteFontFace) -> u16 #cpp_method;
    GetDesignGlyphMetrics: (this: *IDWriteFontFace, glyphIndices: *u16, glyphCount: u32, glyphMetrics: *DWRITE_GLYPH_METRICS, isSideways: BOOL = 0) -> HRESULT #cpp_method;
    GetGlyphIndicesW: (this: *IDWriteFontFace, codePoints: *u32, codePointCount: u32, glyphIndices: *u16) -> HRESULT #cpp_method;
    TryGetFontTable: (this: *IDWriteFontFace, openTypeTableTag: u32, tableData: **void, tableSize: *u32, tableContext: **void, exists: *BOOL) -> HRESULT #cpp_method;
    ReleaseFontTable: (this: *IDWriteFontFace, tableContext: *void) -> void #cpp_method;
    GetGlyphRunOutline: (this: *IDWriteFontFace, emSize: float, glyphIndices: *u16, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET, glyphCount: u32, isSideways: BOOL, isRightToLeft: BOOL, geometrySink: *IDWriteGeometrySink) -> HRESULT #cpp_method;
    GetRecommendedRenderingMode: (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, measuringMode: DWRITE_MEASURING_MODE, renderingParams: *IDWriteRenderingParams, renderingMode: *DWRITE_RENDERING_MODE) -> HRESULT #cpp_method;
    GetGdiCompatibleMetrics: (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, fontFaceMetrics: *DWRITE_FONT_METRICS) -> HRESULT #cpp_method;
    GetGdiCompatibleGlyphMetrics: (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, glyphIndices: *u16, glyphCount: u32, glyphMetrics: *DWRITE_GLYPH_METRICS, isSideways: BOOL = 0) -> HRESULT #cpp_method;
}
IDWriteFontFace_GetType :: inline (this: *IDWriteFontFace) -> DWRITE_FONT_FACE_TYPE { return this.idwritefontface_vtable.GetType(this); }
IDWriteFontFace_GetFiles :: inline (this: *IDWriteFontFace, numberOfFiles: *u32, fontFiles: **IDWriteFontFile) -> HRESULT { return this.idwritefontface_vtable.GetFiles(this, numberOfFiles, fontFiles); }
IDWriteFontFace_GetIndex :: inline (this: *IDWriteFontFace) -> u32 { return this.idwritefontface_vtable.GetIndex(this); }
IDWriteFontFace_GetSimulations :: inline (this: *IDWriteFontFace) -> DWRITE_FONT_SIMULATIONS { return this.idwritefontface_vtable.GetSimulations(this); }
IDWriteFontFace_IsSymbolFont :: inline (this: *IDWriteFontFace) -> BOOL { return this.idwritefontface_vtable.IsSymbolFont(this); }
IDWriteFontFace_GetMetrics :: inline (this: *IDWriteFontFace, fontFaceMetrics: *DWRITE_FONT_METRICS) { this.idwritefontface_vtable.GetMetrics(this, fontFaceMetrics); }
IDWriteFontFace_GetGlyphCount :: inline (this: *IDWriteFontFace) -> u16 { return this.idwritefontface_vtable.GetGlyphCount(this); }
IDWriteFontFace_GetDesignGlyphMetrics :: inline (this: *IDWriteFontFace, glyphIndices: *u16, glyphCount: u32, glyphMetrics: *DWRITE_GLYPH_METRICS, isSideways: BOOL = 0) -> HRESULT { return this.idwritefontface_vtable.GetDesignGlyphMetrics(this, glyphIndices, glyphCount, glyphMetrics, isSideways); }
IDWriteFontFace_GetGlyphIndicesW :: inline (this: *IDWriteFontFace, codePoints: *u32, codePointCount: u32, glyphIndices: *u16) -> HRESULT { return this.idwritefontface_vtable.GetGlyphIndicesW(this, codePoints, codePointCount, glyphIndices); }
IDWriteFontFace_TryGetFontTable :: inline (this: *IDWriteFontFace, openTypeTableTag: u32, tableData: **void, tableSize: *u32, tableContext: **void, exists: *BOOL) -> HRESULT { return this.idwritefontface_vtable.TryGetFontTable(this, openTypeTableTag, tableData, tableSize, tableContext, exists); }
IDWriteFontFace_ReleaseFontTable :: inline (this: *IDWriteFontFace, tableContext: *void) { this.idwritefontface_vtable.ReleaseFontTable(this, tableContext); }
IDWriteFontFace_GetGlyphRunOutline :: inline (this: *IDWriteFontFace, emSize: float, glyphIndices: *u16, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET, glyphCount: u32, isSideways: BOOL, isRightToLeft: BOOL, geometrySink: *IDWriteGeometrySink) -> HRESULT { return this.idwritefontface_vtable.GetGlyphRunOutline(this, emSize, glyphIndices, glyphAdvances, glyphOffsets, glyphCount, isSideways, isRightToLeft, geometrySink); }
IDWriteFontFace_GetRecommendedRenderingMode :: inline (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, measuringMode: DWRITE_MEASURING_MODE, renderingParams: *IDWriteRenderingParams, renderingMode: *DWRITE_RENDERING_MODE) -> HRESULT { return this.idwritefontface_vtable.GetRecommendedRenderingMode(this, emSize, pixelsPerDip, measuringMode, renderingParams, renderingMode); }
IDWriteFontFace_GetGdiCompatibleMetrics :: inline (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, fontFaceMetrics: *DWRITE_FONT_METRICS) -> HRESULT { return this.idwritefontface_vtable.GetGdiCompatibleMetrics(this, emSize, pixelsPerDip, transform, fontFaceMetrics); }
IDWriteFontFace_GetGdiCompatibleGlyphMetrics :: inline (this: *IDWriteFontFace, emSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, glyphIndices: *u16, glyphCount: u32, glyphMetrics: *DWRITE_GLYPH_METRICS, isSideways: BOOL = 0) -> HRESULT { return this.idwritefontface_vtable.GetGdiCompatibleGlyphMetrics(this, emSize, pixelsPerDip, transform, useGdiNatural, glyphIndices, glyphCount, glyphMetrics, isSideways); }

vtable :: (obj: *IDWriteFontFace) -> *IDWriteFontFace_VTable { return obj.idwritefontface_vtable; }


IDWriteFontCollectionLoader :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontcollectionloader_vtable: *IDWriteFontCollectionLoader_VTable;
}
IDWriteFontCollectionLoader_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    CreateEnumeratorFromKey: (this: *IDWriteFontCollectionLoader, factory: *IDWriteFactory, collectionKey: *void, collectionKeySize: u32, fontFileEnumerator: **IDWriteFontFileEnumerator) -> HRESULT #cpp_method;
}
IDWriteFontCollectionLoader_CreateEnumeratorFromKey :: inline (this: *IDWriteFontCollectionLoader, factory: *IDWriteFactory, collectionKey: *void, collectionKeySize: u32, fontFileEnumerator: **IDWriteFontFileEnumerator) -> HRESULT { return this.idwritefontcollectionloader_vtable.CreateEnumeratorFromKey(this, factory, collectionKey, collectionKeySize, fontFileEnumerator); }

vtable :: (obj: *IDWriteFontCollectionLoader) -> *IDWriteFontCollectionLoader_VTable { return obj.idwritefontcollectionloader_vtable; }


IDWriteFontFileEnumerator :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontfileenumerator_vtable: *IDWriteFontFileEnumerator_VTable;
}
IDWriteFontFileEnumerator_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    MoveNext: (this: *IDWriteFontFileEnumerator, hasCurrentFile: *BOOL) -> HRESULT #cpp_method;
    GetCurrentFontFile: (this: *IDWriteFontFileEnumerator, fontFile: **IDWriteFontFile) -> HRESULT #cpp_method;
}
IDWriteFontFileEnumerator_MoveNext :: inline (this: *IDWriteFontFileEnumerator, hasCurrentFile: *BOOL) -> HRESULT { return this.idwritefontfileenumerator_vtable.MoveNext(this, hasCurrentFile); }
IDWriteFontFileEnumerator_GetCurrentFontFile :: inline (this: *IDWriteFontFileEnumerator, fontFile: **IDWriteFontFile) -> HRESULT { return this.idwritefontfileenumerator_vtable.GetCurrentFontFile(this, fontFile); }

vtable :: (obj: *IDWriteFontFileEnumerator) -> *IDWriteFontFileEnumerator_VTable { return obj.idwritefontfileenumerator_vtable; }


IDWriteLocalizedStrings :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritelocalizedstrings_vtable: *IDWriteLocalizedStrings_VTable;
}
IDWriteLocalizedStrings_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetCount: (this: *IDWriteLocalizedStrings) -> u32 #cpp_method;
    FindLocaleName: (this: *IDWriteLocalizedStrings, localeName: *s16, index: *u32, exists: *BOOL) -> HRESULT #cpp_method;
    GetLocaleNameLength: (this: *IDWriteLocalizedStrings, index: u32, length: *u32) -> HRESULT #cpp_method;
    GetLocaleName: (this: *IDWriteLocalizedStrings, index: u32, localeName: *s16, size: u32) -> HRESULT #cpp_method;
    GetStringLength: (this: *IDWriteLocalizedStrings, index: u32, length: *u32) -> HRESULT #cpp_method;
    GetString: (this: *IDWriteLocalizedStrings, index: u32, stringBuffer: *s16, size: u32) -> HRESULT #cpp_method;
}
IDWriteLocalizedStrings_GetCount :: inline (this: *IDWriteLocalizedStrings) -> u32 { return this.idwritelocalizedstrings_vtable.GetCount(this); }
IDWriteLocalizedStrings_FindLocaleName :: inline (this: *IDWriteLocalizedStrings, localeName: *s16, index: *u32, exists: *BOOL) -> HRESULT { return this.idwritelocalizedstrings_vtable.FindLocaleName(this, localeName, index, exists); }
IDWriteLocalizedStrings_GetLocaleNameLength :: inline (this: *IDWriteLocalizedStrings, index: u32, length: *u32) -> HRESULT { return this.idwritelocalizedstrings_vtable.GetLocaleNameLength(this, index, length); }
IDWriteLocalizedStrings_GetLocaleName :: inline (this: *IDWriteLocalizedStrings, index: u32, localeName: *s16, size: u32) -> HRESULT { return this.idwritelocalizedstrings_vtable.GetLocaleName(this, index, localeName, size); }
IDWriteLocalizedStrings_GetStringLength :: inline (this: *IDWriteLocalizedStrings, index: u32, length: *u32) -> HRESULT { return this.idwritelocalizedstrings_vtable.GetStringLength(this, index, length); }
IDWriteLocalizedStrings_GetString :: inline (this: *IDWriteLocalizedStrings, index: u32, stringBuffer: *s16, size: u32) -> HRESULT { return this.idwritelocalizedstrings_vtable.GetString(this, index, stringBuffer, size); }

vtable :: (obj: *IDWriteLocalizedStrings) -> *IDWriteLocalizedStrings_VTable { return obj.idwritelocalizedstrings_vtable; }


IDWriteFontCollection :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontcollection_vtable: *IDWriteFontCollection_VTable;
}
IDWriteFontCollection_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetFontFamilyCount: (this: *IDWriteFontCollection) -> u32 #cpp_method;
    GetFontFamily: (this: *IDWriteFontCollection, index: u32, fontFamily: **IDWriteFontFamily) -> HRESULT #cpp_method;
    FindFamilyName: (this: *IDWriteFontCollection, familyName: *s16, index: *u32, exists: *BOOL) -> HRESULT #cpp_method;
    GetFontFromFontFace: (this: *IDWriteFontCollection, fontFace: *IDWriteFontFace, font: **IDWriteFont) -> HRESULT #cpp_method;
}
IDWriteFontCollection_GetFontFamilyCount :: inline (this: *IDWriteFontCollection) -> u32 { return this.idwritefontcollection_vtable.GetFontFamilyCount(this); }
IDWriteFontCollection_GetFontFamily :: inline (this: *IDWriteFontCollection, index: u32, fontFamily: **IDWriteFontFamily) -> HRESULT { return this.idwritefontcollection_vtable.GetFontFamily(this, index, fontFamily); }
IDWriteFontCollection_FindFamilyName :: inline (this: *IDWriteFontCollection, familyName: *s16, index: *u32, exists: *BOOL) -> HRESULT { return this.idwritefontcollection_vtable.FindFamilyName(this, familyName, index, exists); }
IDWriteFontCollection_GetFontFromFontFace :: inline (this: *IDWriteFontCollection, fontFace: *IDWriteFontFace, font: **IDWriteFont) -> HRESULT { return this.idwritefontcollection_vtable.GetFontFromFontFace(this, fontFace, font); }

vtable :: (obj: *IDWriteFontCollection) -> *IDWriteFontCollection_VTable { return obj.idwritefontcollection_vtable; }


IDWriteFontList :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefontlist_vtable: *IDWriteFontList_VTable;
}
IDWriteFontList_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetFontCollection: (this: *IDWriteFontList, fontCollection: **IDWriteFontCollection) -> HRESULT #cpp_method;
    GetFontCount: (this: *IDWriteFontList) -> u32 #cpp_method;
    GetFont: (this: *IDWriteFontList, index: u32, font: **IDWriteFont) -> HRESULT #cpp_method;
}
IDWriteFontList_GetFontCollection :: inline (this: *IDWriteFontList, fontCollection: **IDWriteFontCollection) -> HRESULT { return this.idwritefontlist_vtable.GetFontCollection(this, fontCollection); }
IDWriteFontList_GetFontCount :: inline (this: *IDWriteFontList) -> u32 { return this.idwritefontlist_vtable.GetFontCount(this); }
IDWriteFontList_GetFont :: inline (this: *IDWriteFontList, index: u32, font: **IDWriteFont) -> HRESULT { return this.idwritefontlist_vtable.GetFont(this, index, font); }

vtable :: (obj: *IDWriteFontList) -> *IDWriteFontList_VTable { return obj.idwritefontlist_vtable; }


IDWriteFontFamily :: struct {
    #as using idwritefontlist: IDWriteFontList;
    #place idwritefontlist; idwritefontfamily_vtable: *IDWriteFontFamily_VTable;
}
IDWriteFontFamily_VTable :: struct #type_info_none {
    using idwritefontlist: IDWriteFontList_VTable;
    GetFamilyNames: (this: *IDWriteFontFamily, names: **IDWriteLocalizedStrings) -> HRESULT #cpp_method;
    GetFirstMatchingFont: (this: *IDWriteFontFamily, weight: DWRITE_FONT_WEIGHT, stretch: DWRITE_FONT_STRETCH, style: DWRITE_FONT_STYLE, matchingFont: **IDWriteFont) -> HRESULT #cpp_method;
    GetMatchingFonts: (this: *IDWriteFontFamily, weight: DWRITE_FONT_WEIGHT, stretch: DWRITE_FONT_STRETCH, style: DWRITE_FONT_STYLE, matchingFonts: **IDWriteFontList) -> HRESULT #cpp_method;
}
IDWriteFontFamily_GetFamilyNames :: inline (this: *IDWriteFontFamily, names: **IDWriteLocalizedStrings) -> HRESULT { return this.idwritefontfamily_vtable.GetFamilyNames(this, names); }
IDWriteFontFamily_GetFirstMatchingFont :: inline (this: *IDWriteFontFamily, weight: DWRITE_FONT_WEIGHT, stretch: DWRITE_FONT_STRETCH, style: DWRITE_FONT_STYLE, matchingFont: **IDWriteFont) -> HRESULT { return this.idwritefontfamily_vtable.GetFirstMatchingFont(this, weight, stretch, style, matchingFont); }
IDWriteFontFamily_GetMatchingFonts :: inline (this: *IDWriteFontFamily, weight: DWRITE_FONT_WEIGHT, stretch: DWRITE_FONT_STRETCH, style: DWRITE_FONT_STYLE, matchingFonts: **IDWriteFontList) -> HRESULT { return this.idwritefontfamily_vtable.GetMatchingFonts(this, weight, stretch, style, matchingFonts); }

vtable :: (obj: *IDWriteFontFamily) -> *IDWriteFontFamily_VTable { return obj.idwritefontfamily_vtable; }


IDWriteFont :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefont_vtable: *IDWriteFont_VTable;
}
IDWriteFont_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetFontFamily: (this: *IDWriteFont, fontFamily: **IDWriteFontFamily) -> HRESULT #cpp_method;
    GetWeight: (this: *IDWriteFont) -> DWRITE_FONT_WEIGHT #cpp_method;
    GetStretch: (this: *IDWriteFont) -> DWRITE_FONT_STRETCH #cpp_method;
    GetStyle: (this: *IDWriteFont) -> DWRITE_FONT_STYLE #cpp_method;
    IsSymbolFont: (this: *IDWriteFont) -> BOOL #cpp_method;
    GetFaceNames: (this: *IDWriteFont, names: **IDWriteLocalizedStrings) -> HRESULT #cpp_method;
    GetInformationalStrings: (this: *IDWriteFont, informationalStringID: DWRITE_INFORMATIONAL_STRING_ID, informationalStrings: **IDWriteLocalizedStrings, exists: *BOOL) -> HRESULT #cpp_method;
    GetSimulations: (this: *IDWriteFont) -> DWRITE_FONT_SIMULATIONS #cpp_method;
    GetMetrics: (this: *IDWriteFont, fontMetrics: *DWRITE_FONT_METRICS) -> void #cpp_method;
    HasCharacter: (this: *IDWriteFont, unicodeValue: u32, exists: *BOOL) -> HRESULT #cpp_method;
    CreateFontFace: (this: *IDWriteFont, fontFace: **IDWriteFontFace) -> HRESULT #cpp_method;
}
IDWriteFont_GetFontFamily :: inline (this: *IDWriteFont, fontFamily: **IDWriteFontFamily) -> HRESULT { return this.idwritefont_vtable.GetFontFamily(this, fontFamily); }
IDWriteFont_GetWeight :: inline (this: *IDWriteFont) -> DWRITE_FONT_WEIGHT { return this.idwritefont_vtable.GetWeight(this); }
IDWriteFont_GetStretch :: inline (this: *IDWriteFont) -> DWRITE_FONT_STRETCH { return this.idwritefont_vtable.GetStretch(this); }
IDWriteFont_GetStyle :: inline (this: *IDWriteFont) -> DWRITE_FONT_STYLE { return this.idwritefont_vtable.GetStyle(this); }
IDWriteFont_IsSymbolFont :: inline (this: *IDWriteFont) -> BOOL { return this.idwritefont_vtable.IsSymbolFont(this); }
IDWriteFont_GetFaceNames :: inline (this: *IDWriteFont, names: **IDWriteLocalizedStrings) -> HRESULT { return this.idwritefont_vtable.GetFaceNames(this, names); }
IDWriteFont_GetInformationalStrings :: inline (this: *IDWriteFont, informationalStringID: DWRITE_INFORMATIONAL_STRING_ID, informationalStrings: **IDWriteLocalizedStrings, exists: *BOOL) -> HRESULT { return this.idwritefont_vtable.GetInformationalStrings(this, informationalStringID, informationalStrings, exists); }
IDWriteFont_GetSimulations :: inline (this: *IDWriteFont) -> DWRITE_FONT_SIMULATIONS { return this.idwritefont_vtable.GetSimulations(this); }
IDWriteFont_GetMetrics :: inline (this: *IDWriteFont, fontMetrics: *DWRITE_FONT_METRICS) { this.idwritefont_vtable.GetMetrics(this, fontMetrics); }
IDWriteFont_HasCharacter :: inline (this: *IDWriteFont, unicodeValue: u32, exists: *BOOL) -> HRESULT { return this.idwritefont_vtable.HasCharacter(this, unicodeValue, exists); }
IDWriteFont_CreateFontFace :: inline (this: *IDWriteFont, fontFace: **IDWriteFontFace) -> HRESULT { return this.idwritefont_vtable.CreateFontFace(this, fontFace); }

vtable :: (obj: *IDWriteFont) -> *IDWriteFont_VTable { return obj.idwritefont_vtable; }


DWRITE_READING_DIRECTION :: enum s32 {
    LEFT_TO_RIGHT :: 0;

    RIGHT_TO_LEFT :: 1;

    TOP_TO_BOTTOM :: 2;

    BOTTOM_TO_TOP :: 3;

    DWRITE_READING_DIRECTION_LEFT_TO_RIGHT :: LEFT_TO_RIGHT;

    DWRITE_READING_DIRECTION_RIGHT_TO_LEFT :: RIGHT_TO_LEFT;

    DWRITE_READING_DIRECTION_TOP_TO_BOTTOM :: TOP_TO_BOTTOM;

    DWRITE_READING_DIRECTION_BOTTOM_TO_TOP :: BOTTOM_TO_TOP;
}

DWRITE_FLOW_DIRECTION :: enum s32 {
    TOP_TO_BOTTOM :: 0;

    BOTTOM_TO_TOP :: 1;

    LEFT_TO_RIGHT :: 2;

    RIGHT_TO_LEFT :: 3;

    DWRITE_FLOW_DIRECTION_TOP_TO_BOTTOM :: TOP_TO_BOTTOM;

    DWRITE_FLOW_DIRECTION_BOTTOM_TO_TOP :: BOTTOM_TO_TOP;

    DWRITE_FLOW_DIRECTION_LEFT_TO_RIGHT :: LEFT_TO_RIGHT;

    DWRITE_FLOW_DIRECTION_RIGHT_TO_LEFT :: RIGHT_TO_LEFT;
}

DWRITE_TEXT_ALIGNMENT :: enum s32 {
    LEADING   :: 0;

    TRAILING  :: 1;

    CENTER    :: 2;

    JUSTIFIED :: 3;

    DWRITE_TEXT_ALIGNMENT_LEADING   :: LEADING;

    DWRITE_TEXT_ALIGNMENT_TRAILING  :: TRAILING;

    DWRITE_TEXT_ALIGNMENT_CENTER    :: CENTER;

    DWRITE_TEXT_ALIGNMENT_JUSTIFIED :: JUSTIFIED;
}

DWRITE_PARAGRAPH_ALIGNMENT :: enum s32 {
    NEAR   :: 0;

    FAR    :: 1;

    CENTER :: 2;

    DWRITE_PARAGRAPH_ALIGNMENT_NEAR   :: NEAR;

    DWRITE_PARAGRAPH_ALIGNMENT_FAR    :: FAR;

    DWRITE_PARAGRAPH_ALIGNMENT_CENTER :: CENTER;
}

DWRITE_WORD_WRAPPING :: enum s32 {
    WRAP            :: 0;

    NO_WRAP         :: 1;

    EMERGENCY_BREAK :: 2;

    WHOLE_WORD      :: 3;

    CHARACTER       :: 4;

    DWRITE_WORD_WRAPPING_WRAP            :: WRAP;

    DWRITE_WORD_WRAPPING_NO_WRAP         :: NO_WRAP;

    DWRITE_WORD_WRAPPING_EMERGENCY_BREAK :: EMERGENCY_BREAK;

    DWRITE_WORD_WRAPPING_WHOLE_WORD      :: WHOLE_WORD;

    DWRITE_WORD_WRAPPING_CHARACTER       :: CHARACTER;
}

DWRITE_LINE_SPACING_METHOD :: enum s32 {
    DEFAULT      :: 0;

    UNIFORM      :: 1;

    PROPORTIONAL :: 2;

    DWRITE_LINE_SPACING_METHOD_DEFAULT      :: DEFAULT;

    DWRITE_LINE_SPACING_METHOD_UNIFORM      :: UNIFORM;

    DWRITE_LINE_SPACING_METHOD_PROPORTIONAL :: PROPORTIONAL;
}

DWRITE_TRIMMING_GRANULARITY :: enum s32 {
    NONE      :: 0;

    CHARACTER :: 1;

    WORD      :: 2;

    DWRITE_TRIMMING_GRANULARITY_NONE      :: NONE;

    DWRITE_TRIMMING_GRANULARITY_CHARACTER :: CHARACTER;

    DWRITE_TRIMMING_GRANULARITY_WORD      :: WORD;
}

DWRITE_FONT_FEATURE_TAG :: enum s32 {
    ALTERNATIVE_FRACTIONS            :: 1668441697;
    PETITE_CAPITALS_FROM_CAPITALS    :: 1668297315;
    SMALL_CAPITALS_FROM_CAPITALS     :: 1668493923;
    CONTEXTUAL_ALTERNATES            :: 1953259875;
    CASE_SENSITIVE_FORMS             :: 1702060387;
    GLYPH_COMPOSITION_DECOMPOSITION  :: 1886217059;
    CONTEXTUAL_LIGATURES             :: 1734962275;
    CAPITAL_SPACING                  :: 1886613603;
    CONTEXTUAL_SWASH                 :: 1752658787;
    CURSIVE_POSITIONING              :: 1936880995;
    DEFAULT                          :: 1953261156;
    DISCRETIONARY_LIGATURES          :: 1734962276;
    EXPERT_FORMS                     :: 1953527909;
    FRACTIONS                        :: 1667330662;
    FULL_WIDTH                       :: 1684633446;
    HALF_FORMS                       :: 1718378856;
    HALANT_FORMS                     :: 1852596584;
    ALTERNATE_HALF_WIDTH             :: 1953259880;
    HISTORICAL_FORMS                 :: 1953720680;
    HORIZONTAL_KANA_ALTERNATES       :: 1634626408;
    HISTORICAL_LIGATURES             :: 1734962280;
    HALF_WIDTH                       :: 1684633448;
    HOJO_KANJI_FORMS                 :: 1869246312;
    JIS04_FORMS                      :: 875589738;
    JIS78_FORMS                      :: 943157354;
    JIS83_FORMS                      :: 859336810;
    JIS90_FORMS                      :: 809070698;
    KERNING                          :: 1852990827;
    STANDARD_LIGATURES               :: 1634167148;
    LINING_FIGURES                   :: 1836412524;
    LOCALIZED_FORMS                  :: 1818455916;
    MARK_POSITIONING                 :: 1802658157;
    MATHEMATICAL_GREEK               :: 1802659693;
    MARK_TO_MARK_POSITIONING         :: 1802333037;
    ALTERNATE_ANNOTATION_FORMS       :: 1953259886;
    NLC_KANJI_FORMS                  :: 1801677934;
    OLD_STYLE_FIGURES                :: 1836412527;
    ORDINALS                         :: 1852076655;
    PROPORTIONAL_ALTERNATE_WIDTH     :: 1953259888;
    PETITE_CAPITALS                  :: 1885430640;
    PROPORTIONAL_FIGURES             :: 1836412528;
    PROPORTIONAL_WIDTHS              :: 1684633456;
    QUARTER_WIDTHS                   :: 1684633457;
    REQUIRED_LIGATURES               :: 1734962290;
    RUBY_NOTATION_FORMS              :: 2036495730;
    STYLISTIC_ALTERNATES             :: 1953259891;
    SCIENTIFIC_INFERIORS             :: 1718511987;
    SMALL_CAPITALS                   :: 1885564275;
    SIMPLIFIED_FORMS                 :: 1819307379;
    STYLISTIC_SET_1                  :: 825258867;
    STYLISTIC_SET_2                  :: 842036083;
    STYLISTIC_SET_3                  :: 858813299;
    STYLISTIC_SET_4                  :: 875590515;
    STYLISTIC_SET_5                  :: 892367731;
    STYLISTIC_SET_6                  :: 909144947;
    STYLISTIC_SET_7                  :: 925922163;
    STYLISTIC_SET_8                  :: 942699379;
    STYLISTIC_SET_9                  :: 959476595;
    STYLISTIC_SET_10                 :: 808547187;
    STYLISTIC_SET_11                 :: 825324403;
    STYLISTIC_SET_12                 :: 842101619;
    STYLISTIC_SET_13                 :: 858878835;
    STYLISTIC_SET_14                 :: 875656051;
    STYLISTIC_SET_15                 :: 892433267;
    STYLISTIC_SET_16                 :: 909210483;
    STYLISTIC_SET_17                 :: 925987699;
    STYLISTIC_SET_18                 :: 942764915;
    STYLISTIC_SET_19                 :: 959542131;
    STYLISTIC_SET_20                 :: 808612723;
    SUBSCRIPT                        :: 1935832435;
    SUPERSCRIPT                      :: 1936749939;
    SWASH                            :: 1752397683;
    TITLING                          :: 1819568500;
    TRADITIONAL_NAME_FORMS           :: 1835101812;
    TABULAR_FIGURES                  :: 1836412532;
    TRADITIONAL_FORMS                :: 1684107892;
    THIRD_WIDTHS                     :: 1684633460;
    UNICASE                          :: 1667853941;
    VERTICAL_WRITING                 :: 1953654134;
    VERTICAL_ALTERNATES_AND_ROTATION :: 846492278;
    SLASHED_ZERO                     :: 1869768058;

    DWRITE_FONT_FEATURE_TAG_ALTERNATIVE_FRACTIONS            :: ALTERNATIVE_FRACTIONS;
    DWRITE_FONT_FEATURE_TAG_PETITE_CAPITALS_FROM_CAPITALS    :: PETITE_CAPITALS_FROM_CAPITALS;
    DWRITE_FONT_FEATURE_TAG_SMALL_CAPITALS_FROM_CAPITALS     :: SMALL_CAPITALS_FROM_CAPITALS;
    DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_ALTERNATES            :: CONTEXTUAL_ALTERNATES;
    DWRITE_FONT_FEATURE_TAG_CASE_SENSITIVE_FORMS             :: CASE_SENSITIVE_FORMS;
    DWRITE_FONT_FEATURE_TAG_GLYPH_COMPOSITION_DECOMPOSITION  :: GLYPH_COMPOSITION_DECOMPOSITION;
    DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_LIGATURES             :: CONTEXTUAL_LIGATURES;
    DWRITE_FONT_FEATURE_TAG_CAPITAL_SPACING                  :: CAPITAL_SPACING;
    DWRITE_FONT_FEATURE_TAG_CONTEXTUAL_SWASH                 :: CONTEXTUAL_SWASH;
    DWRITE_FONT_FEATURE_TAG_CURSIVE_POSITIONING              :: CURSIVE_POSITIONING;
    DWRITE_FONT_FEATURE_TAG_DEFAULT                          :: DEFAULT;
    DWRITE_FONT_FEATURE_TAG_DISCRETIONARY_LIGATURES          :: DISCRETIONARY_LIGATURES;
    DWRITE_FONT_FEATURE_TAG_EXPERT_FORMS                     :: EXPERT_FORMS;
    DWRITE_FONT_FEATURE_TAG_FRACTIONS                        :: FRACTIONS;
    DWRITE_FONT_FEATURE_TAG_FULL_WIDTH                       :: FULL_WIDTH;
    DWRITE_FONT_FEATURE_TAG_HALF_FORMS                       :: HALF_FORMS;
    DWRITE_FONT_FEATURE_TAG_HALANT_FORMS                     :: HALANT_FORMS;
    DWRITE_FONT_FEATURE_TAG_ALTERNATE_HALF_WIDTH             :: ALTERNATE_HALF_WIDTH;
    DWRITE_FONT_FEATURE_TAG_HISTORICAL_FORMS                 :: HISTORICAL_FORMS;
    DWRITE_FONT_FEATURE_TAG_HORIZONTAL_KANA_ALTERNATES       :: HORIZONTAL_KANA_ALTERNATES;
    DWRITE_FONT_FEATURE_TAG_HISTORICAL_LIGATURES             :: HISTORICAL_LIGATURES;
    DWRITE_FONT_FEATURE_TAG_HALF_WIDTH                       :: HALF_WIDTH;
    DWRITE_FONT_FEATURE_TAG_HOJO_KANJI_FORMS                 :: HOJO_KANJI_FORMS;
    DWRITE_FONT_FEATURE_TAG_JIS04_FORMS                      :: JIS04_FORMS;
    DWRITE_FONT_FEATURE_TAG_JIS78_FORMS                      :: JIS78_FORMS;
    DWRITE_FONT_FEATURE_TAG_JIS83_FORMS                      :: JIS83_FORMS;
    DWRITE_FONT_FEATURE_TAG_JIS90_FORMS                      :: JIS90_FORMS;
    DWRITE_FONT_FEATURE_TAG_KERNING                          :: KERNING;
    DWRITE_FONT_FEATURE_TAG_STANDARD_LIGATURES               :: STANDARD_LIGATURES;
    DWRITE_FONT_FEATURE_TAG_LINING_FIGURES                   :: LINING_FIGURES;
    DWRITE_FONT_FEATURE_TAG_LOCALIZED_FORMS                  :: LOCALIZED_FORMS;
    DWRITE_FONT_FEATURE_TAG_MARK_POSITIONING                 :: MARK_POSITIONING;
    DWRITE_FONT_FEATURE_TAG_MATHEMATICAL_GREEK               :: MATHEMATICAL_GREEK;
    DWRITE_FONT_FEATURE_TAG_MARK_TO_MARK_POSITIONING         :: MARK_TO_MARK_POSITIONING;
    DWRITE_FONT_FEATURE_TAG_ALTERNATE_ANNOTATION_FORMS       :: ALTERNATE_ANNOTATION_FORMS;
    DWRITE_FONT_FEATURE_TAG_NLC_KANJI_FORMS                  :: NLC_KANJI_FORMS;
    DWRITE_FONT_FEATURE_TAG_OLD_STYLE_FIGURES                :: OLD_STYLE_FIGURES;
    DWRITE_FONT_FEATURE_TAG_ORDINALS                         :: ORDINALS;
    DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_ALTERNATE_WIDTH     :: PROPORTIONAL_ALTERNATE_WIDTH;
    DWRITE_FONT_FEATURE_TAG_PETITE_CAPITALS                  :: PETITE_CAPITALS;
    DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_FIGURES             :: PROPORTIONAL_FIGURES;
    DWRITE_FONT_FEATURE_TAG_PROPORTIONAL_WIDTHS              :: PROPORTIONAL_WIDTHS;
    DWRITE_FONT_FEATURE_TAG_QUARTER_WIDTHS                   :: QUARTER_WIDTHS;
    DWRITE_FONT_FEATURE_TAG_REQUIRED_LIGATURES               :: REQUIRED_LIGATURES;
    DWRITE_FONT_FEATURE_TAG_RUBY_NOTATION_FORMS              :: RUBY_NOTATION_FORMS;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_ALTERNATES             :: STYLISTIC_ALTERNATES;
    DWRITE_FONT_FEATURE_TAG_SCIENTIFIC_INFERIORS             :: SCIENTIFIC_INFERIORS;
    DWRITE_FONT_FEATURE_TAG_SMALL_CAPITALS                   :: SMALL_CAPITALS;
    DWRITE_FONT_FEATURE_TAG_SIMPLIFIED_FORMS                 :: SIMPLIFIED_FORMS;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_1                  :: STYLISTIC_SET_1;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_2                  :: STYLISTIC_SET_2;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_3                  :: STYLISTIC_SET_3;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_4                  :: STYLISTIC_SET_4;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_5                  :: STYLISTIC_SET_5;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_6                  :: STYLISTIC_SET_6;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_7                  :: STYLISTIC_SET_7;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_8                  :: STYLISTIC_SET_8;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_9                  :: STYLISTIC_SET_9;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_10                 :: STYLISTIC_SET_10;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_11                 :: STYLISTIC_SET_11;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_12                 :: STYLISTIC_SET_12;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_13                 :: STYLISTIC_SET_13;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_14                 :: STYLISTIC_SET_14;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_15                 :: STYLISTIC_SET_15;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_16                 :: STYLISTIC_SET_16;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_17                 :: STYLISTIC_SET_17;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_18                 :: STYLISTIC_SET_18;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_19                 :: STYLISTIC_SET_19;
    DWRITE_FONT_FEATURE_TAG_STYLISTIC_SET_20                 :: STYLISTIC_SET_20;
    DWRITE_FONT_FEATURE_TAG_SUBSCRIPT                        :: SUBSCRIPT;
    DWRITE_FONT_FEATURE_TAG_SUPERSCRIPT                      :: SUPERSCRIPT;
    DWRITE_FONT_FEATURE_TAG_SWASH                            :: SWASH;
    DWRITE_FONT_FEATURE_TAG_TITLING                          :: TITLING;
    DWRITE_FONT_FEATURE_TAG_TRADITIONAL_NAME_FORMS           :: TRADITIONAL_NAME_FORMS;
    DWRITE_FONT_FEATURE_TAG_TABULAR_FIGURES                  :: TABULAR_FIGURES;
    DWRITE_FONT_FEATURE_TAG_TRADITIONAL_FORMS                :: TRADITIONAL_FORMS;
    DWRITE_FONT_FEATURE_TAG_THIRD_WIDTHS                     :: THIRD_WIDTHS;
    DWRITE_FONT_FEATURE_TAG_UNICASE                          :: UNICASE;
    DWRITE_FONT_FEATURE_TAG_VERTICAL_WRITING                 :: VERTICAL_WRITING;
    DWRITE_FONT_FEATURE_TAG_VERTICAL_ALTERNATES_AND_ROTATION :: VERTICAL_ALTERNATES_AND_ROTATION;
    DWRITE_FONT_FEATURE_TAG_SLASHED_ZERO                     :: SLASHED_ZERO;
}

DWRITE_TEXT_RANGE :: struct {
    startPosition: u32;

    length:        u32;
}

DWRITE_FONT_FEATURE :: struct {
    nameTag:   DWRITE_FONT_FEATURE_TAG;

    parameter: u32;
}

DWRITE_TYPOGRAPHIC_FEATURES :: struct {
    features:     *DWRITE_FONT_FEATURE;

    featureCount: u32;
}

DWRITE_TRIMMING :: struct {
    granularity:    DWRITE_TRIMMING_GRANULARITY;

    delimiter:      u32;

    delimiterCount: u32;
}

IDWriteTextFormat :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritetextformat_vtable: *IDWriteTextFormat_VTable;
}
IDWriteTextFormat_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    SetTextAlignment: (this: *IDWriteTextFormat, textAlignment: DWRITE_TEXT_ALIGNMENT) -> HRESULT #cpp_method;
    SetParagraphAlignment: (this: *IDWriteTextFormat, paragraphAlignment: DWRITE_PARAGRAPH_ALIGNMENT) -> HRESULT #cpp_method;
    SetWordWrapping: (this: *IDWriteTextFormat, wordWrapping: DWRITE_WORD_WRAPPING) -> HRESULT #cpp_method;
    SetReadingDirection: (this: *IDWriteTextFormat, readingDirection: DWRITE_READING_DIRECTION) -> HRESULT #cpp_method;
    SetFlowDirection: (this: *IDWriteTextFormat, flowDirection: DWRITE_FLOW_DIRECTION) -> HRESULT #cpp_method;
    SetIncrementalTabStop: (this: *IDWriteTextFormat, incrementalTabStop: float) -> HRESULT #cpp_method;
    SetTrimming: (this: *IDWriteTextFormat, trimmingOptions: *DWRITE_TRIMMING, trimmingSign: *IDWriteInlineObject) -> HRESULT #cpp_method;
    SetLineSpacing: (this: *IDWriteTextFormat, lineSpacingMethod: DWRITE_LINE_SPACING_METHOD, lineSpacing: float, baseline: float) -> HRESULT #cpp_method;
    GetTextAlignment: (this: *IDWriteTextFormat) -> DWRITE_TEXT_ALIGNMENT #cpp_method;
    GetParagraphAlignment: (this: *IDWriteTextFormat) -> DWRITE_PARAGRAPH_ALIGNMENT #cpp_method;
    GetWordWrapping: (this: *IDWriteTextFormat) -> DWRITE_WORD_WRAPPING #cpp_method;
    GetReadingDirection: (this: *IDWriteTextFormat) -> DWRITE_READING_DIRECTION #cpp_method;
    GetFlowDirection: (this: *IDWriteTextFormat) -> DWRITE_FLOW_DIRECTION #cpp_method;
    GetIncrementalTabStop: (this: *IDWriteTextFormat) -> float #cpp_method;
    GetTrimming: (this: *IDWriteTextFormat, trimmingOptions: *DWRITE_TRIMMING, trimmingSign: **IDWriteInlineObject) -> HRESULT #cpp_method;
    GetLineSpacing: (this: *IDWriteTextFormat, lineSpacingMethod: *DWRITE_LINE_SPACING_METHOD, lineSpacing: *float, baseline: *float) -> HRESULT #cpp_method;
    GetFontCollection: (this: *IDWriteTextFormat, fontCollection: **IDWriteFontCollection) -> HRESULT #cpp_method;
    GetFontFamilyNameLength: (this: *IDWriteTextFormat) -> u32 #cpp_method;
    GetFontFamilyName: (this: *IDWriteTextFormat, fontFamilyName: *s16, nameSize: u32) -> HRESULT #cpp_method;
    GetFontWeight: (this: *IDWriteTextFormat) -> DWRITE_FONT_WEIGHT #cpp_method;
    GetFontStyle: (this: *IDWriteTextFormat) -> DWRITE_FONT_STYLE #cpp_method;
    GetFontStretch: (this: *IDWriteTextFormat) -> DWRITE_FONT_STRETCH #cpp_method;
    GetFontSize: (this: *IDWriteTextFormat) -> float #cpp_method;
    GetLocaleNameLength: (this: *IDWriteTextFormat) -> u32 #cpp_method;
    GetLocaleName: (this: *IDWriteTextFormat, localeName: *s16, nameSize: u32) -> HRESULT #cpp_method;
}
IDWriteTextFormat_SetTextAlignment :: inline (this: *IDWriteTextFormat, textAlignment: DWRITE_TEXT_ALIGNMENT) -> HRESULT { return this.idwritetextformat_vtable.SetTextAlignment(this, textAlignment); }
IDWriteTextFormat_SetParagraphAlignment :: inline (this: *IDWriteTextFormat, paragraphAlignment: DWRITE_PARAGRAPH_ALIGNMENT) -> HRESULT { return this.idwritetextformat_vtable.SetParagraphAlignment(this, paragraphAlignment); }
IDWriteTextFormat_SetWordWrapping :: inline (this: *IDWriteTextFormat, wordWrapping: DWRITE_WORD_WRAPPING) -> HRESULT { return this.idwritetextformat_vtable.SetWordWrapping(this, wordWrapping); }
IDWriteTextFormat_SetReadingDirection :: inline (this: *IDWriteTextFormat, readingDirection: DWRITE_READING_DIRECTION) -> HRESULT { return this.idwritetextformat_vtable.SetReadingDirection(this, readingDirection); }
IDWriteTextFormat_SetFlowDirection :: inline (this: *IDWriteTextFormat, flowDirection: DWRITE_FLOW_DIRECTION) -> HRESULT { return this.idwritetextformat_vtable.SetFlowDirection(this, flowDirection); }
IDWriteTextFormat_SetIncrementalTabStop :: inline (this: *IDWriteTextFormat, incrementalTabStop: float) -> HRESULT { return this.idwritetextformat_vtable.SetIncrementalTabStop(this, incrementalTabStop); }
IDWriteTextFormat_SetTrimming :: inline (this: *IDWriteTextFormat, trimmingOptions: *DWRITE_TRIMMING, trimmingSign: *IDWriteInlineObject) -> HRESULT { return this.idwritetextformat_vtable.SetTrimming(this, trimmingOptions, trimmingSign); }
IDWriteTextFormat_SetLineSpacing :: inline (this: *IDWriteTextFormat, lineSpacingMethod: DWRITE_LINE_SPACING_METHOD, lineSpacing: float, baseline: float) -> HRESULT { return this.idwritetextformat_vtable.SetLineSpacing(this, lineSpacingMethod, lineSpacing, baseline); }
IDWriteTextFormat_GetTextAlignment :: inline (this: *IDWriteTextFormat) -> DWRITE_TEXT_ALIGNMENT { return this.idwritetextformat_vtable.GetTextAlignment(this); }
IDWriteTextFormat_GetParagraphAlignment :: inline (this: *IDWriteTextFormat) -> DWRITE_PARAGRAPH_ALIGNMENT { return this.idwritetextformat_vtable.GetParagraphAlignment(this); }
IDWriteTextFormat_GetWordWrapping :: inline (this: *IDWriteTextFormat) -> DWRITE_WORD_WRAPPING { return this.idwritetextformat_vtable.GetWordWrapping(this); }
IDWriteTextFormat_GetReadingDirection :: inline (this: *IDWriteTextFormat) -> DWRITE_READING_DIRECTION { return this.idwritetextformat_vtable.GetReadingDirection(this); }
IDWriteTextFormat_GetFlowDirection :: inline (this: *IDWriteTextFormat) -> DWRITE_FLOW_DIRECTION { return this.idwritetextformat_vtable.GetFlowDirection(this); }
IDWriteTextFormat_GetIncrementalTabStop :: inline (this: *IDWriteTextFormat) -> float { return this.idwritetextformat_vtable.GetIncrementalTabStop(this); }
IDWriteTextFormat_GetTrimming :: inline (this: *IDWriteTextFormat, trimmingOptions: *DWRITE_TRIMMING, trimmingSign: **IDWriteInlineObject) -> HRESULT { return this.idwritetextformat_vtable.GetTrimming(this, trimmingOptions, trimmingSign); }
IDWriteTextFormat_GetLineSpacing :: inline (this: *IDWriteTextFormat, lineSpacingMethod: *DWRITE_LINE_SPACING_METHOD, lineSpacing: *float, baseline: *float) -> HRESULT { return this.idwritetextformat_vtable.GetLineSpacing(this, lineSpacingMethod, lineSpacing, baseline); }
IDWriteTextFormat_GetFontCollection :: inline (this: *IDWriteTextFormat, fontCollection: **IDWriteFontCollection) -> HRESULT { return this.idwritetextformat_vtable.GetFontCollection(this, fontCollection); }
IDWriteTextFormat_GetFontFamilyNameLength :: inline (this: *IDWriteTextFormat) -> u32 { return this.idwritetextformat_vtable.GetFontFamilyNameLength(this); }
IDWriteTextFormat_GetFontFamilyName :: inline (this: *IDWriteTextFormat, fontFamilyName: *s16, nameSize: u32) -> HRESULT { return this.idwritetextformat_vtable.GetFontFamilyName(this, fontFamilyName, nameSize); }
IDWriteTextFormat_GetFontWeight :: inline (this: *IDWriteTextFormat) -> DWRITE_FONT_WEIGHT { return this.idwritetextformat_vtable.GetFontWeight(this); }
IDWriteTextFormat_GetFontStyle :: inline (this: *IDWriteTextFormat) -> DWRITE_FONT_STYLE { return this.idwritetextformat_vtable.GetFontStyle(this); }
IDWriteTextFormat_GetFontStretch :: inline (this: *IDWriteTextFormat) -> DWRITE_FONT_STRETCH { return this.idwritetextformat_vtable.GetFontStretch(this); }
IDWriteTextFormat_GetFontSize :: inline (this: *IDWriteTextFormat) -> float { return this.idwritetextformat_vtable.GetFontSize(this); }
IDWriteTextFormat_GetLocaleNameLength :: inline (this: *IDWriteTextFormat) -> u32 { return this.idwritetextformat_vtable.GetLocaleNameLength(this); }
IDWriteTextFormat_GetLocaleName :: inline (this: *IDWriteTextFormat, localeName: *s16, nameSize: u32) -> HRESULT { return this.idwritetextformat_vtable.GetLocaleName(this, localeName, nameSize); }

vtable :: (obj: *IDWriteTextFormat) -> *IDWriteTextFormat_VTable { return obj.idwritetextformat_vtable; }


IDWriteTypography :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritetypography_vtable: *IDWriteTypography_VTable;
}
IDWriteTypography_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    AddFontFeature: (this: *IDWriteTypography, fontFeature: DWRITE_FONT_FEATURE) -> HRESULT #cpp_method;
    GetFontFeatureCount: (this: *IDWriteTypography) -> u32 #cpp_method;
    GetFontFeature: (this: *IDWriteTypography, fontFeatureIndex: u32, fontFeature: *DWRITE_FONT_FEATURE) -> HRESULT #cpp_method;
}
IDWriteTypography_AddFontFeature :: inline (this: *IDWriteTypography, fontFeature: DWRITE_FONT_FEATURE) -> HRESULT { return this.idwritetypography_vtable.AddFontFeature(this, fontFeature); }
IDWriteTypography_GetFontFeatureCount :: inline (this: *IDWriteTypography) -> u32 { return this.idwritetypography_vtable.GetFontFeatureCount(this); }
IDWriteTypography_GetFontFeature :: inline (this: *IDWriteTypography, fontFeatureIndex: u32, fontFeature: *DWRITE_FONT_FEATURE) -> HRESULT { return this.idwritetypography_vtable.GetFontFeature(this, fontFeatureIndex, fontFeature); }

vtable :: (obj: *IDWriteTypography) -> *IDWriteTypography_VTable { return obj.idwritetypography_vtable; }


DWRITE_SCRIPT_SHAPES :: enum s32 {
    DEFAULT   :: 0;

    NO_VISUAL :: 1;

    DWRITE_SCRIPT_SHAPES_DEFAULT   :: DEFAULT;

    DWRITE_SCRIPT_SHAPES_NO_VISUAL :: NO_VISUAL;
}

DWRITE_SCRIPT_ANALYSIS :: struct {
    script: u16;

    shapes: DWRITE_SCRIPT_SHAPES;
}

DWRITE_BREAK_CONDITION :: enum s32 {
    NEUTRAL       :: 0;

    CAN_BREAK     :: 1;

    MAY_NOT_BREAK :: 2;

    MUST_BREAK    :: 3;

    DWRITE_BREAK_CONDITION_NEUTRAL       :: NEUTRAL;

    DWRITE_BREAK_CONDITION_CAN_BREAK     :: CAN_BREAK;

    DWRITE_BREAK_CONDITION_MAY_NOT_BREAK :: MAY_NOT_BREAK;

    DWRITE_BREAK_CONDITION_MUST_BREAK    :: MUST_BREAK;
}

DWRITE_LINE_BREAKPOINT :: struct {
    __bitfield: u8;
    /* 
        breakConditionBefore: u8; /* 2 bits */
        breakConditionAfter: u8; /* 2 bits */
        isWhitespace: u8; /* 1 bits */
        isSoftHyphen: u8; /* 1 bits */
        padding: u8; /* 2 bits */;
    */
}

DWRITE_NUMBER_SUBSTITUTION_METHOD :: enum s32 {
    FROM_CULTURE :: 0;

    CONTEXTUAL   :: 1;

    NONE         :: 2;

    NATIONAL     :: 3;

    TRADITIONAL  :: 4;

    DWRITE_NUMBER_SUBSTITUTION_METHOD_FROM_CULTURE :: FROM_CULTURE;

    DWRITE_NUMBER_SUBSTITUTION_METHOD_CONTEXTUAL   :: CONTEXTUAL;

    DWRITE_NUMBER_SUBSTITUTION_METHOD_NONE         :: NONE;

    DWRITE_NUMBER_SUBSTITUTION_METHOD_NATIONAL     :: NATIONAL;

    DWRITE_NUMBER_SUBSTITUTION_METHOD_TRADITIONAL  :: TRADITIONAL;
}

IDWriteNumberSubstitution :: struct {
    #as using iunknown: IUnknown;
}

DWRITE_SHAPING_TEXT_PROPERTIES :: struct {
    __bitfield: u16;
    /* 
        isShapedAlone: u16; /* 1 bits */
        reserved1: u16; /* 1 bits */
        canBreakShapingAfter: u16; /* 1 bits */
        reserved: u16; /* 13 bits */;
    */
}

DWRITE_SHAPING_GLYPH_PROPERTIES :: struct {
    __bitfield: u16;
    /* 
        justification: u16; /* 4 bits */
        isClusterStart: u16; /* 1 bits */
        isDiacritic: u16; /* 1 bits */
        isZeroWidthSpace: u16; /* 1 bits */
        reserved: u16; /* 9 bits */;
    */
}

IDWriteTextAnalysisSource :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritetextanalysissource_vtable: *IDWriteTextAnalysisSource_VTable;
}
IDWriteTextAnalysisSource_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetTextAtPosition: (this: *IDWriteTextAnalysisSource, textPosition: u32, textString: **s16, textLength: *u32) -> HRESULT #cpp_method;
    GetTextBeforePosition: (this: *IDWriteTextAnalysisSource, textPosition: u32, textString: **s16, textLength: *u32) -> HRESULT #cpp_method;
    GetParagraphReadingDirection: (this: *IDWriteTextAnalysisSource) -> DWRITE_READING_DIRECTION #cpp_method;
    GetLocaleName: (this: *IDWriteTextAnalysisSource, textPosition: u32, textLength: *u32, localeName: **s16) -> HRESULT #cpp_method;
    GetNumberSubstitution: (this: *IDWriteTextAnalysisSource, textPosition: u32, textLength: *u32, numberSubstitution: **IDWriteNumberSubstitution) -> HRESULT #cpp_method;
}
IDWriteTextAnalysisSource_GetTextAtPosition :: inline (this: *IDWriteTextAnalysisSource, textPosition: u32, textString: **s16, textLength: *u32) -> HRESULT { return this.idwritetextanalysissource_vtable.GetTextAtPosition(this, textPosition, textString, textLength); }
IDWriteTextAnalysisSource_GetTextBeforePosition :: inline (this: *IDWriteTextAnalysisSource, textPosition: u32, textString: **s16, textLength: *u32) -> HRESULT { return this.idwritetextanalysissource_vtable.GetTextBeforePosition(this, textPosition, textString, textLength); }
IDWriteTextAnalysisSource_GetParagraphReadingDirection :: inline (this: *IDWriteTextAnalysisSource) -> DWRITE_READING_DIRECTION { return this.idwritetextanalysissource_vtable.GetParagraphReadingDirection(this); }
IDWriteTextAnalysisSource_GetLocaleName :: inline (this: *IDWriteTextAnalysisSource, textPosition: u32, textLength: *u32, localeName: **s16) -> HRESULT { return this.idwritetextanalysissource_vtable.GetLocaleName(this, textPosition, textLength, localeName); }
IDWriteTextAnalysisSource_GetNumberSubstitution :: inline (this: *IDWriteTextAnalysisSource, textPosition: u32, textLength: *u32, numberSubstitution: **IDWriteNumberSubstitution) -> HRESULT { return this.idwritetextanalysissource_vtable.GetNumberSubstitution(this, textPosition, textLength, numberSubstitution); }

vtable :: (obj: *IDWriteTextAnalysisSource) -> *IDWriteTextAnalysisSource_VTable { return obj.idwritetextanalysissource_vtable; }


IDWriteTextAnalysisSink :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritetextanalysissink_vtable: *IDWriteTextAnalysisSink_VTable;
}
IDWriteTextAnalysisSink_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    SetScriptAnalysis: (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS) -> HRESULT #cpp_method;
    SetLineBreakpoints: (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, lineBreakpoints: *DWRITE_LINE_BREAKPOINT) -> HRESULT #cpp_method;
    SetBidiLevel: (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, explicitLevel: u8, resolvedLevel: u8) -> HRESULT #cpp_method;
    SetNumberSubstitution: (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, numberSubstitution: *IDWriteNumberSubstitution) -> HRESULT #cpp_method;
}
IDWriteTextAnalysisSink_SetScriptAnalysis :: inline (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS) -> HRESULT { return this.idwritetextanalysissink_vtable.SetScriptAnalysis(this, textPosition, textLength, scriptAnalysis); }
IDWriteTextAnalysisSink_SetLineBreakpoints :: inline (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, lineBreakpoints: *DWRITE_LINE_BREAKPOINT) -> HRESULT { return this.idwritetextanalysissink_vtable.SetLineBreakpoints(this, textPosition, textLength, lineBreakpoints); }
IDWriteTextAnalysisSink_SetBidiLevel :: inline (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, explicitLevel: u8, resolvedLevel: u8) -> HRESULT { return this.idwritetextanalysissink_vtable.SetBidiLevel(this, textPosition, textLength, explicitLevel, resolvedLevel); }
IDWriteTextAnalysisSink_SetNumberSubstitution :: inline (this: *IDWriteTextAnalysisSink, textPosition: u32, textLength: u32, numberSubstitution: *IDWriteNumberSubstitution) -> HRESULT { return this.idwritetextanalysissink_vtable.SetNumberSubstitution(this, textPosition, textLength, numberSubstitution); }

vtable :: (obj: *IDWriteTextAnalysisSink) -> *IDWriteTextAnalysisSink_VTable { return obj.idwritetextanalysissink_vtable; }


IDWriteTextAnalyzer :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritetextanalyzer_vtable: *IDWriteTextAnalyzer_VTable;
}
IDWriteTextAnalyzer_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    AnalyzeScript: (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT #cpp_method;
    AnalyzeBidi: (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT #cpp_method;
    AnalyzeNumberSubstitution: (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT #cpp_method;
    AnalyzeLineBreakpoints: (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT #cpp_method;
    GetGlyphs: (this: *IDWriteTextAnalyzer, textString: *s16, textLength: u32, fontFace: *IDWriteFontFace, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, numberSubstitution: *IDWriteNumberSubstitution, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, maxGlyphCount: u32, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, actualGlyphCount: *u32) -> HRESULT #cpp_method;
    GetGlyphPlacements: (this: *IDWriteTextAnalyzer, textString: *s16, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, textLength: u32, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, glyphCount: u32, fontFace: *IDWriteFontFace, fontEmSize: float, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET) -> HRESULT #cpp_method;
    GetGdiCompatibleGlyphPlacements: (this: *IDWriteTextAnalyzer, textString: *s16, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, textLength: u32, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, glyphCount: u32, fontFace: *IDWriteFontFace, fontEmSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET) -> HRESULT #cpp_method;
}
IDWriteTextAnalyzer_AnalyzeScript :: inline (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT { return this.idwritetextanalyzer_vtable.AnalyzeScript(this, analysisSource, textPosition, textLength, analysisSink); }
IDWriteTextAnalyzer_AnalyzeBidi :: inline (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT { return this.idwritetextanalyzer_vtable.AnalyzeBidi(this, analysisSource, textPosition, textLength, analysisSink); }
IDWriteTextAnalyzer_AnalyzeNumberSubstitution :: inline (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT { return this.idwritetextanalyzer_vtable.AnalyzeNumberSubstitution(this, analysisSource, textPosition, textLength, analysisSink); }
IDWriteTextAnalyzer_AnalyzeLineBreakpoints :: inline (this: *IDWriteTextAnalyzer, analysisSource: *IDWriteTextAnalysisSource, textPosition: u32, textLength: u32, analysisSink: *IDWriteTextAnalysisSink) -> HRESULT { return this.idwritetextanalyzer_vtable.AnalyzeLineBreakpoints(this, analysisSource, textPosition, textLength, analysisSink); }
IDWriteTextAnalyzer_GetGlyphs :: inline (this: *IDWriteTextAnalyzer, textString: *s16, textLength: u32, fontFace: *IDWriteFontFace, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, numberSubstitution: *IDWriteNumberSubstitution, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, maxGlyphCount: u32, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, actualGlyphCount: *u32) -> HRESULT { return this.idwritetextanalyzer_vtable.GetGlyphs(this, textString, textLength, fontFace, isSideways, isRightToLeft, scriptAnalysis, localeName, numberSubstitution, features, featureRangeLengths, featureRanges, maxGlyphCount, clusterMap, textProps, glyphIndices, glyphProps, actualGlyphCount); }
IDWriteTextAnalyzer_GetGlyphPlacements :: inline (this: *IDWriteTextAnalyzer, textString: *s16, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, textLength: u32, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, glyphCount: u32, fontFace: *IDWriteFontFace, fontEmSize: float, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET) -> HRESULT { return this.idwritetextanalyzer_vtable.GetGlyphPlacements(this, textString, clusterMap, textProps, textLength, glyphIndices, glyphProps, glyphCount, fontFace, fontEmSize, isSideways, isRightToLeft, scriptAnalysis, localeName, features, featureRangeLengths, featureRanges, glyphAdvances, glyphOffsets); }
IDWriteTextAnalyzer_GetGdiCompatibleGlyphPlacements :: inline (this: *IDWriteTextAnalyzer, textString: *s16, clusterMap: *u16, textProps: *DWRITE_SHAPING_TEXT_PROPERTIES, textLength: u32, glyphIndices: *u16, glyphProps: *DWRITE_SHAPING_GLYPH_PROPERTIES, glyphCount: u32, fontFace: *IDWriteFontFace, fontEmSize: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, isSideways: BOOL, isRightToLeft: BOOL, scriptAnalysis: *DWRITE_SCRIPT_ANALYSIS, localeName: *s16, features: **DWRITE_TYPOGRAPHIC_FEATURES, featureRangeLengths: *u32, featureRanges: u32, glyphAdvances: *float, glyphOffsets: *DWRITE_GLYPH_OFFSET) -> HRESULT { return this.idwritetextanalyzer_vtable.GetGdiCompatibleGlyphPlacements(this, textString, clusterMap, textProps, textLength, glyphIndices, glyphProps, glyphCount, fontFace, fontEmSize, pixelsPerDip, transform, useGdiNatural, isSideways, isRightToLeft, scriptAnalysis, localeName, features, featureRangeLengths, featureRanges, glyphAdvances, glyphOffsets); }

vtable :: (obj: *IDWriteTextAnalyzer) -> *IDWriteTextAnalyzer_VTable { return obj.idwritetextanalyzer_vtable; }


DWRITE_GLYPH_RUN :: struct {
    fontFace:      *IDWriteFontFace;

    fontEmSize:    float;

    glyphCount:    u32;

    glyphIndices:  *u16;

    glyphAdvances: *float;

    glyphOffsets:  *DWRITE_GLYPH_OFFSET;

    isSideways:    BOOL;

    bidiLevel:     u32;
}

DWRITE_GLYPH_RUN_DESCRIPTION :: struct {
    localeName:   *s16;

    _string:      *s16;

    stringLength: u32;

    clusterMap:   *u16;

    textPosition: u32;
}

DWRITE_UNDERLINE :: struct {
    width:            float;

    thickness:        float;

    offset:           float;

    runHeight:        float;

    readingDirection: DWRITE_READING_DIRECTION;

    flowDirection:    DWRITE_FLOW_DIRECTION;

    localeName:       *s16;

    measuringMode:    DWRITE_MEASURING_MODE;
}

DWRITE_STRIKETHROUGH :: struct {
    width:            float;

    thickness:        float;

    offset:           float;

    readingDirection: DWRITE_READING_DIRECTION;

    flowDirection:    DWRITE_FLOW_DIRECTION;

    localeName:       *s16;

    measuringMode:    DWRITE_MEASURING_MODE;
}

DWRITE_LINE_METRICS :: struct {
    length:                   u32;

    trailingWhitespaceLength: u32;

    newlineLength:            u32;

    height:                   float;

    baseline:                 float;

    isTrimmed:                BOOL;
}

DWRITE_CLUSTER_METRICS :: struct {
    width:      float;

    length:     u16;

    __bitfield: u16;
    /* 
        canWrapLineAfter: u16; /* 1 bits */
        isWhitespace: u16; /* 1 bits */
        isNewline: u16; /* 1 bits */
        isSoftHyphen: u16; /* 1 bits */
        isRightToLeft: u16; /* 1 bits */
        padding: u16; /* 11 bits */;
    */
}

DWRITE_TEXT_METRICS :: struct {
    left:                             float;

    top:                              float;

    width:                            float;

    widthIncludingTrailingWhitespace: float;

    height:                           float;

    layoutWidth:                      float;

    layoutHeight:                     float;

    maxBidiReorderingDepth:           u32;

    lineCount:                        u32;
}

DWRITE_INLINE_OBJECT_METRICS :: struct {
    width:            float;

    height:           float;

    baseline:         float;

    supportsSideways: BOOL;
}

DWRITE_OVERHANG_METRICS :: struct {
    left:   float;

    top:    float;

    right:  float;

    bottom: float;
}

DWRITE_HIT_TEST_METRICS :: struct {
    textPosition: u32;

    length:       u32;

    left:         float;

    top:          float;

    width:        float;

    height:       float;

    bidiLevel:    u32;

    isText:       BOOL;

    isTrimmed:    BOOL;
}

IDWriteInlineObject :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwriteinlineobject_vtable: *IDWriteInlineObject_VTable;
}
IDWriteInlineObject_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    Draw: (this: *IDWriteInlineObject, clientDrawingContext: *void, renderer: *IDWriteTextRenderer, originX: float, originY: float, isSideways: BOOL, isRightToLeft: BOOL, clientDrawingEffect: *IUnknown) -> HRESULT #cpp_method;
    GetMetrics: (this: *IDWriteInlineObject, metrics: *DWRITE_INLINE_OBJECT_METRICS) -> HRESULT #cpp_method;
    GetOverhangMetrics: (this: *IDWriteInlineObject, overhangs: *DWRITE_OVERHANG_METRICS) -> HRESULT #cpp_method;
    GetBreakConditions: (this: *IDWriteInlineObject, breakConditionBefore: *DWRITE_BREAK_CONDITION, breakConditionAfter: *DWRITE_BREAK_CONDITION) -> HRESULT #cpp_method;
}
IDWriteInlineObject_Draw :: inline (this: *IDWriteInlineObject, clientDrawingContext: *void, renderer: *IDWriteTextRenderer, originX: float, originY: float, isSideways: BOOL, isRightToLeft: BOOL, clientDrawingEffect: *IUnknown) -> HRESULT { return this.idwriteinlineobject_vtable.Draw(this, clientDrawingContext, renderer, originX, originY, isSideways, isRightToLeft, clientDrawingEffect); }
IDWriteInlineObject_GetMetrics :: inline (this: *IDWriteInlineObject, metrics: *DWRITE_INLINE_OBJECT_METRICS) -> HRESULT { return this.idwriteinlineobject_vtable.GetMetrics(this, metrics); }
IDWriteInlineObject_GetOverhangMetrics :: inline (this: *IDWriteInlineObject, overhangs: *DWRITE_OVERHANG_METRICS) -> HRESULT { return this.idwriteinlineobject_vtable.GetOverhangMetrics(this, overhangs); }
IDWriteInlineObject_GetBreakConditions :: inline (this: *IDWriteInlineObject, breakConditionBefore: *DWRITE_BREAK_CONDITION, breakConditionAfter: *DWRITE_BREAK_CONDITION) -> HRESULT { return this.idwriteinlineobject_vtable.GetBreakConditions(this, breakConditionBefore, breakConditionAfter); }

vtable :: (obj: *IDWriteInlineObject) -> *IDWriteInlineObject_VTable { return obj.idwriteinlineobject_vtable; }


IDWritePixelSnapping :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritepixelsnapping_vtable: *IDWritePixelSnapping_VTable;
}
IDWritePixelSnapping_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    IsPixelSnappingDisabled: (this: *IDWritePixelSnapping, clientDrawingContext: *void, isDisabled: *BOOL) -> HRESULT #cpp_method;
    GetCurrentTransform: (this: *IDWritePixelSnapping, clientDrawingContext: *void, transform: *DWRITE_MATRIX) -> HRESULT #cpp_method;
    GetPixelsPerDip: (this: *IDWritePixelSnapping, clientDrawingContext: *void, pixelsPerDip: *float) -> HRESULT #cpp_method;
}
IDWritePixelSnapping_IsPixelSnappingDisabled :: inline (this: *IDWritePixelSnapping, clientDrawingContext: *void, isDisabled: *BOOL) -> HRESULT { return this.idwritepixelsnapping_vtable.IsPixelSnappingDisabled(this, clientDrawingContext, isDisabled); }
IDWritePixelSnapping_GetCurrentTransform :: inline (this: *IDWritePixelSnapping, clientDrawingContext: *void, transform: *DWRITE_MATRIX) -> HRESULT { return this.idwritepixelsnapping_vtable.GetCurrentTransform(this, clientDrawingContext, transform); }
IDWritePixelSnapping_GetPixelsPerDip :: inline (this: *IDWritePixelSnapping, clientDrawingContext: *void, pixelsPerDip: *float) -> HRESULT { return this.idwritepixelsnapping_vtable.GetPixelsPerDip(this, clientDrawingContext, pixelsPerDip); }

vtable :: (obj: *IDWritePixelSnapping) -> *IDWritePixelSnapping_VTable { return obj.idwritepixelsnapping_vtable; }


IDWriteTextRenderer :: struct {
    #as using idwritepixelsnapping: IDWritePixelSnapping;
    #place idwritepixelsnapping; idwritetextrenderer_vtable: *IDWriteTextRenderer_VTable;
}
IDWriteTextRenderer_VTable :: struct #type_info_none {
    using idwritepixelsnapping: IDWritePixelSnapping_VTable;
    DrawGlyphRun: (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, measuringMode: DWRITE_MEASURING_MODE, glyphRun: *DWRITE_GLYPH_RUN, glyphRunDescription: *DWRITE_GLYPH_RUN_DESCRIPTION, clientDrawingEffect: *IUnknown) -> HRESULT #cpp_method;
    DrawUnderline: (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, underline: *DWRITE_UNDERLINE, clientDrawingEffect: *IUnknown) -> HRESULT #cpp_method;
    DrawStrikethrough: (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, strikethrough: *DWRITE_STRIKETHROUGH, clientDrawingEffect: *IUnknown) -> HRESULT #cpp_method;
    DrawInlineObject: (this: *IDWriteTextRenderer, clientDrawingContext: *void, originX: float, originY: float, inlineObject: *IDWriteInlineObject, isSideways: BOOL, isRightToLeft: BOOL, clientDrawingEffect: *IUnknown) -> HRESULT #cpp_method;
}
IDWriteTextRenderer_DrawGlyphRun :: inline (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, measuringMode: DWRITE_MEASURING_MODE, glyphRun: *DWRITE_GLYPH_RUN, glyphRunDescription: *DWRITE_GLYPH_RUN_DESCRIPTION, clientDrawingEffect: *IUnknown) -> HRESULT { return this.idwritetextrenderer_vtable.DrawGlyphRun(this, clientDrawingContext, baselineOriginX, baselineOriginY, measuringMode, glyphRun, glyphRunDescription, clientDrawingEffect); }
IDWriteTextRenderer_DrawUnderline :: inline (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, underline: *DWRITE_UNDERLINE, clientDrawingEffect: *IUnknown) -> HRESULT { return this.idwritetextrenderer_vtable.DrawUnderline(this, clientDrawingContext, baselineOriginX, baselineOriginY, underline, clientDrawingEffect); }
IDWriteTextRenderer_DrawStrikethrough :: inline (this: *IDWriteTextRenderer, clientDrawingContext: *void, baselineOriginX: float, baselineOriginY: float, strikethrough: *DWRITE_STRIKETHROUGH, clientDrawingEffect: *IUnknown) -> HRESULT { return this.idwritetextrenderer_vtable.DrawStrikethrough(this, clientDrawingContext, baselineOriginX, baselineOriginY, strikethrough, clientDrawingEffect); }
IDWriteTextRenderer_DrawInlineObject :: inline (this: *IDWriteTextRenderer, clientDrawingContext: *void, originX: float, originY: float, inlineObject: *IDWriteInlineObject, isSideways: BOOL, isRightToLeft: BOOL, clientDrawingEffect: *IUnknown) -> HRESULT { return this.idwritetextrenderer_vtable.DrawInlineObject(this, clientDrawingContext, originX, originY, inlineObject, isSideways, isRightToLeft, clientDrawingEffect); }

vtable :: (obj: *IDWriteTextRenderer) -> *IDWriteTextRenderer_VTable { return obj.idwritetextrenderer_vtable; }


IDWriteTextLayout :: struct {
    #as using idwritetextformat: IDWriteTextFormat;
    #place idwritetextformat; idwritetextlayout_vtable: *IDWriteTextLayout_VTable;
}
IDWriteTextLayout_VTable :: struct #type_info_none {
    using idwritetextformat: IDWriteTextFormat_VTable;
    SetMaxWidth: (this: *IDWriteTextLayout, maxWidth: float) -> HRESULT #cpp_method;
    SetMaxHeight: (this: *IDWriteTextLayout, maxHeight: float) -> HRESULT #cpp_method;
    SetFontCollection: (this: *IDWriteTextLayout, fontCollection: *IDWriteFontCollection, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetFontFamilyName: (this: *IDWriteTextLayout, fontFamilyName: *s16, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetFontWeight: (this: *IDWriteTextLayout, fontWeight: DWRITE_FONT_WEIGHT, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetFontStyle: (this: *IDWriteTextLayout, fontStyle: DWRITE_FONT_STYLE, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetFontStretch: (this: *IDWriteTextLayout, fontStretch: DWRITE_FONT_STRETCH, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetFontSize: (this: *IDWriteTextLayout, fontSize: float, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetUnderline: (this: *IDWriteTextLayout, hasUnderline: BOOL, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetStrikethrough: (this: *IDWriteTextLayout, hasStrikethrough: BOOL, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetDrawingEffect: (this: *IDWriteTextLayout, drawingEffect: *IUnknown, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetInlineObject: (this: *IDWriteTextLayout, inlineObject: *IDWriteInlineObject, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetTypography: (this: *IDWriteTextLayout, typography: *IDWriteTypography, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    SetLocaleName: (this: *IDWriteTextLayout, localeName: *s16, textRange: DWRITE_TEXT_RANGE) -> HRESULT #cpp_method;
    GetMaxWidth: (this: *IDWriteTextLayout) -> float #cpp_method;
    GetMaxHeight: (this: *IDWriteTextLayout) -> float #cpp_method;
    GetFontCollection_1: (this: *IDWriteTextLayout, currentPosition: u32, fontCollection: **IDWriteFontCollection, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontFamilyNameLength_1: (this: *IDWriteTextLayout, currentPosition: u32, nameLength: *u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontFamilyName_1: (this: *IDWriteTextLayout, currentPosition: u32, fontFamilyName: *s16, nameSize: u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontWeight_1: (this: *IDWriteTextLayout, currentPosition: u32, fontWeight: *DWRITE_FONT_WEIGHT, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontStyle_1: (this: *IDWriteTextLayout, currentPosition: u32, fontStyle: *DWRITE_FONT_STYLE, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontStretch_1: (this: *IDWriteTextLayout, currentPosition: u32, fontStretch: *DWRITE_FONT_STRETCH, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetFontSize_1: (this: *IDWriteTextLayout, currentPosition: u32, fontSize: *float, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetUnderline: (this: *IDWriteTextLayout, currentPosition: u32, hasUnderline: *BOOL, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetStrikethrough: (this: *IDWriteTextLayout, currentPosition: u32, hasStrikethrough: *BOOL, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetDrawingEffect: (this: *IDWriteTextLayout, currentPosition: u32, drawingEffect: **IUnknown, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetInlineObject: (this: *IDWriteTextLayout, currentPosition: u32, inlineObject: **IDWriteInlineObject, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetTypography: (this: *IDWriteTextLayout, currentPosition: u32, typography: **IDWriteTypography, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetLocaleNameLength_1: (this: *IDWriteTextLayout, currentPosition: u32, nameLength: *u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    GetLocaleName_1: (this: *IDWriteTextLayout, currentPosition: u32, localeName: *s16, nameSize: u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT #cpp_method;
    Draw: (this: *IDWriteTextLayout, clientDrawingContext: *void, renderer: *IDWriteTextRenderer, originX: float, originY: float) -> HRESULT #cpp_method;
    GetLineMetrics: (this: *IDWriteTextLayout, lineMetrics: *DWRITE_LINE_METRICS, maxLineCount: u32, actualLineCount: *u32) -> HRESULT #cpp_method;
    GetMetrics: (this: *IDWriteTextLayout, textMetrics: *DWRITE_TEXT_METRICS) -> HRESULT #cpp_method;
    GetOverhangMetrics: (this: *IDWriteTextLayout, overhangs: *DWRITE_OVERHANG_METRICS) -> HRESULT #cpp_method;
    GetClusterMetrics: (this: *IDWriteTextLayout, clusterMetrics: *DWRITE_CLUSTER_METRICS, maxClusterCount: u32, actualClusterCount: *u32) -> HRESULT #cpp_method;
    DetermineMinWidth: (this: *IDWriteTextLayout, minWidth: *float) -> HRESULT #cpp_method;
    HitTestPoint: (this: *IDWriteTextLayout, pointX: float, pointY: float, isTrailingHit: *BOOL, isInside: *BOOL, hitTestMetrics: *DWRITE_HIT_TEST_METRICS) -> HRESULT #cpp_method;
    HitTestTextPosition: (this: *IDWriteTextLayout, textPosition: u32, isTrailingHit: BOOL, pointX: *float, pointY: *float, hitTestMetrics: *DWRITE_HIT_TEST_METRICS) -> HRESULT #cpp_method;
    HitTestTextRange: (this: *IDWriteTextLayout, textPosition: u32, textLength: u32, originX: float, originY: float, hitTestMetrics: *DWRITE_HIT_TEST_METRICS, maxHitTestMetricsCount: u32, actualHitTestMetricsCount: *u32) -> HRESULT #cpp_method;
}
IDWriteTextLayout_SetMaxWidth :: inline (this: *IDWriteTextLayout, maxWidth: float) -> HRESULT { return this.idwritetextlayout_vtable.SetMaxWidth(this, maxWidth); }
IDWriteTextLayout_SetMaxHeight :: inline (this: *IDWriteTextLayout, maxHeight: float) -> HRESULT { return this.idwritetextlayout_vtable.SetMaxHeight(this, maxHeight); }
IDWriteTextLayout_SetFontCollection :: inline (this: *IDWriteTextLayout, fontCollection: *IDWriteFontCollection, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontCollection(this, fontCollection, textRange); }
IDWriteTextLayout_SetFontFamilyName :: inline (this: *IDWriteTextLayout, fontFamilyName: *s16, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontFamilyName(this, fontFamilyName, textRange); }
IDWriteTextLayout_SetFontWeight :: inline (this: *IDWriteTextLayout, fontWeight: DWRITE_FONT_WEIGHT, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontWeight(this, fontWeight, textRange); }
IDWriteTextLayout_SetFontStyle :: inline (this: *IDWriteTextLayout, fontStyle: DWRITE_FONT_STYLE, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontStyle(this, fontStyle, textRange); }
IDWriteTextLayout_SetFontStretch :: inline (this: *IDWriteTextLayout, fontStretch: DWRITE_FONT_STRETCH, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontStretch(this, fontStretch, textRange); }
IDWriteTextLayout_SetFontSize :: inline (this: *IDWriteTextLayout, fontSize: float, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetFontSize(this, fontSize, textRange); }
IDWriteTextLayout_SetUnderline :: inline (this: *IDWriteTextLayout, hasUnderline: BOOL, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetUnderline(this, hasUnderline, textRange); }
IDWriteTextLayout_SetStrikethrough :: inline (this: *IDWriteTextLayout, hasStrikethrough: BOOL, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetStrikethrough(this, hasStrikethrough, textRange); }
IDWriteTextLayout_SetDrawingEffect :: inline (this: *IDWriteTextLayout, drawingEffect: *IUnknown, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetDrawingEffect(this, drawingEffect, textRange); }
IDWriteTextLayout_SetInlineObject :: inline (this: *IDWriteTextLayout, inlineObject: *IDWriteInlineObject, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetInlineObject(this, inlineObject, textRange); }
IDWriteTextLayout_SetTypography :: inline (this: *IDWriteTextLayout, typography: *IDWriteTypography, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetTypography(this, typography, textRange); }
IDWriteTextLayout_SetLocaleName :: inline (this: *IDWriteTextLayout, localeName: *s16, textRange: DWRITE_TEXT_RANGE) -> HRESULT { return this.idwritetextlayout_vtable.SetLocaleName(this, localeName, textRange); }
IDWriteTextLayout_GetMaxWidth :: inline (this: *IDWriteTextLayout) -> float { return this.idwritetextlayout_vtable.GetMaxWidth(this); }
IDWriteTextLayout_GetMaxHeight :: inline (this: *IDWriteTextLayout) -> float { return this.idwritetextlayout_vtable.GetMaxHeight(this); }
IDWriteTextLayout_GetFontCollection_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontCollection: **IDWriteFontCollection, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontCollection_1(this, currentPosition, fontCollection, textRange); }
IDWriteTextLayout_GetFontFamilyNameLength_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, nameLength: *u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontFamilyNameLength_1(this, currentPosition, nameLength, textRange); }
IDWriteTextLayout_GetFontFamilyName_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontFamilyName: *s16, nameSize: u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontFamilyName_1(this, currentPosition, fontFamilyName, nameSize, textRange); }
IDWriteTextLayout_GetFontWeight_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontWeight: *DWRITE_FONT_WEIGHT, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontWeight_1(this, currentPosition, fontWeight, textRange); }
IDWriteTextLayout_GetFontStyle_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontStyle: *DWRITE_FONT_STYLE, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontStyle_1(this, currentPosition, fontStyle, textRange); }
IDWriteTextLayout_GetFontStretch_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontStretch: *DWRITE_FONT_STRETCH, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontStretch_1(this, currentPosition, fontStretch, textRange); }
IDWriteTextLayout_GetFontSize_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, fontSize: *float, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetFontSize_1(this, currentPosition, fontSize, textRange); }
IDWriteTextLayout_GetUnderline :: inline (this: *IDWriteTextLayout, currentPosition: u32, hasUnderline: *BOOL, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetUnderline(this, currentPosition, hasUnderline, textRange); }
IDWriteTextLayout_GetStrikethrough :: inline (this: *IDWriteTextLayout, currentPosition: u32, hasStrikethrough: *BOOL, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetStrikethrough(this, currentPosition, hasStrikethrough, textRange); }
IDWriteTextLayout_GetDrawingEffect :: inline (this: *IDWriteTextLayout, currentPosition: u32, drawingEffect: **IUnknown, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetDrawingEffect(this, currentPosition, drawingEffect, textRange); }
IDWriteTextLayout_GetInlineObject :: inline (this: *IDWriteTextLayout, currentPosition: u32, inlineObject: **IDWriteInlineObject, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetInlineObject(this, currentPosition, inlineObject, textRange); }
IDWriteTextLayout_GetTypography :: inline (this: *IDWriteTextLayout, currentPosition: u32, typography: **IDWriteTypography, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetTypography(this, currentPosition, typography, textRange); }
IDWriteTextLayout_GetLocaleNameLength_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, nameLength: *u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetLocaleNameLength_1(this, currentPosition, nameLength, textRange); }
IDWriteTextLayout_GetLocaleName_1 :: inline (this: *IDWriteTextLayout, currentPosition: u32, localeName: *s16, nameSize: u32, textRange: *DWRITE_TEXT_RANGE = null) -> HRESULT { return this.idwritetextlayout_vtable.GetLocaleName_1(this, currentPosition, localeName, nameSize, textRange); }
IDWriteTextLayout_Draw :: inline (this: *IDWriteTextLayout, clientDrawingContext: *void, renderer: *IDWriteTextRenderer, originX: float, originY: float) -> HRESULT { return this.idwritetextlayout_vtable.Draw(this, clientDrawingContext, renderer, originX, originY); }
IDWriteTextLayout_GetLineMetrics :: inline (this: *IDWriteTextLayout, lineMetrics: *DWRITE_LINE_METRICS, maxLineCount: u32, actualLineCount: *u32) -> HRESULT { return this.idwritetextlayout_vtable.GetLineMetrics(this, lineMetrics, maxLineCount, actualLineCount); }
IDWriteTextLayout_GetMetrics :: inline (this: *IDWriteTextLayout, textMetrics: *DWRITE_TEXT_METRICS) -> HRESULT { return this.idwritetextlayout_vtable.GetMetrics(this, textMetrics); }
IDWriteTextLayout_GetOverhangMetrics :: inline (this: *IDWriteTextLayout, overhangs: *DWRITE_OVERHANG_METRICS) -> HRESULT { return this.idwritetextlayout_vtable.GetOverhangMetrics(this, overhangs); }
IDWriteTextLayout_GetClusterMetrics :: inline (this: *IDWriteTextLayout, clusterMetrics: *DWRITE_CLUSTER_METRICS, maxClusterCount: u32, actualClusterCount: *u32) -> HRESULT { return this.idwritetextlayout_vtable.GetClusterMetrics(this, clusterMetrics, maxClusterCount, actualClusterCount); }
IDWriteTextLayout_DetermineMinWidth :: inline (this: *IDWriteTextLayout, minWidth: *float) -> HRESULT { return this.idwritetextlayout_vtable.DetermineMinWidth(this, minWidth); }
IDWriteTextLayout_HitTestPoint :: inline (this: *IDWriteTextLayout, pointX: float, pointY: float, isTrailingHit: *BOOL, isInside: *BOOL, hitTestMetrics: *DWRITE_HIT_TEST_METRICS) -> HRESULT { return this.idwritetextlayout_vtable.HitTestPoint(this, pointX, pointY, isTrailingHit, isInside, hitTestMetrics); }
IDWriteTextLayout_HitTestTextPosition :: inline (this: *IDWriteTextLayout, textPosition: u32, isTrailingHit: BOOL, pointX: *float, pointY: *float, hitTestMetrics: *DWRITE_HIT_TEST_METRICS) -> HRESULT { return this.idwritetextlayout_vtable.HitTestTextPosition(this, textPosition, isTrailingHit, pointX, pointY, hitTestMetrics); }
IDWriteTextLayout_HitTestTextRange :: inline (this: *IDWriteTextLayout, textPosition: u32, textLength: u32, originX: float, originY: float, hitTestMetrics: *DWRITE_HIT_TEST_METRICS, maxHitTestMetricsCount: u32, actualHitTestMetricsCount: *u32) -> HRESULT { return this.idwritetextlayout_vtable.HitTestTextRange(this, textPosition, textLength, originX, originY, hitTestMetrics, maxHitTestMetricsCount, actualHitTestMetricsCount); }

vtable :: (obj: *IDWriteTextLayout) -> *IDWriteTextLayout_VTable { return obj.idwritetextlayout_vtable; }


IDWriteBitmapRenderTarget :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritebitmaprendertarget_vtable: *IDWriteBitmapRenderTarget_VTable;
}
IDWriteBitmapRenderTarget_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    DrawGlyphRun: (this: *IDWriteBitmapRenderTarget, baselineOriginX: float, baselineOriginY: float, measuringMode: DWRITE_MEASURING_MODE, glyphRun: *DWRITE_GLYPH_RUN, renderingParams: *IDWriteRenderingParams, textColor: COLORREF, blackBoxRect: *RECT = null) -> HRESULT #cpp_method;
    GetMemoryDC: (this: *IDWriteBitmapRenderTarget) -> HDC #cpp_method;
    GetPixelsPerDip: (this: *IDWriteBitmapRenderTarget) -> float #cpp_method;
    SetPixelsPerDip: (this: *IDWriteBitmapRenderTarget, pixelsPerDip: float) -> HRESULT #cpp_method;
    GetCurrentTransform: (this: *IDWriteBitmapRenderTarget, transform: *DWRITE_MATRIX) -> HRESULT #cpp_method;
    SetCurrentTransform: (this: *IDWriteBitmapRenderTarget, transform: *DWRITE_MATRIX) -> HRESULT #cpp_method;
    GetSize: (this: *IDWriteBitmapRenderTarget, size: *SIZE) -> HRESULT #cpp_method;
    Resize: (this: *IDWriteBitmapRenderTarget, width: u32, height: u32) -> HRESULT #cpp_method;
}
IDWriteBitmapRenderTarget_DrawGlyphRun :: inline (this: *IDWriteBitmapRenderTarget, baselineOriginX: float, baselineOriginY: float, measuringMode: DWRITE_MEASURING_MODE, glyphRun: *DWRITE_GLYPH_RUN, renderingParams: *IDWriteRenderingParams, textColor: COLORREF, blackBoxRect: *RECT = null) -> HRESULT { return this.idwritebitmaprendertarget_vtable.DrawGlyphRun(this, baselineOriginX, baselineOriginY, measuringMode, glyphRun, renderingParams, textColor, blackBoxRect); }
IDWriteBitmapRenderTarget_GetMemoryDC :: inline (this: *IDWriteBitmapRenderTarget) -> HDC { return this.idwritebitmaprendertarget_vtable.GetMemoryDC(this); }
IDWriteBitmapRenderTarget_GetPixelsPerDip :: inline (this: *IDWriteBitmapRenderTarget) -> float { return this.idwritebitmaprendertarget_vtable.GetPixelsPerDip(this); }
IDWriteBitmapRenderTarget_SetPixelsPerDip :: inline (this: *IDWriteBitmapRenderTarget, pixelsPerDip: float) -> HRESULT { return this.idwritebitmaprendertarget_vtable.SetPixelsPerDip(this, pixelsPerDip); }
IDWriteBitmapRenderTarget_GetCurrentTransform :: inline (this: *IDWriteBitmapRenderTarget, transform: *DWRITE_MATRIX) -> HRESULT { return this.idwritebitmaprendertarget_vtable.GetCurrentTransform(this, transform); }
IDWriteBitmapRenderTarget_SetCurrentTransform :: inline (this: *IDWriteBitmapRenderTarget, transform: *DWRITE_MATRIX) -> HRESULT { return this.idwritebitmaprendertarget_vtable.SetCurrentTransform(this, transform); }
IDWriteBitmapRenderTarget_GetSize :: inline (this: *IDWriteBitmapRenderTarget, size: *SIZE) -> HRESULT { return this.idwritebitmaprendertarget_vtable.GetSize(this, size); }
IDWriteBitmapRenderTarget_Resize :: inline (this: *IDWriteBitmapRenderTarget, width: u32, height: u32) -> HRESULT { return this.idwritebitmaprendertarget_vtable.Resize(this, width, height); }

vtable :: (obj: *IDWriteBitmapRenderTarget) -> *IDWriteBitmapRenderTarget_VTable { return obj.idwritebitmaprendertarget_vtable; }


IDWriteGdiInterop :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritegdiinterop_vtable: *IDWriteGdiInterop_VTable;
}
IDWriteGdiInterop_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    CreateFontFromLOGFONT: (this: *IDWriteGdiInterop, logFont: *LOGFONTW, font: **IDWriteFont) -> HRESULT #cpp_method;
    ConvertFontToLOGFONT: (this: *IDWriteGdiInterop, font: *IDWriteFont, logFont: *LOGFONTW, isSystemFont: *BOOL) -> HRESULT #cpp_method;
    ConvertFontFaceToLOGFONT: (this: *IDWriteGdiInterop, font: *IDWriteFontFace, logFont: *LOGFONTW) -> HRESULT #cpp_method;
    CreateFontFaceFromHdc: (this: *IDWriteGdiInterop, hdc: HDC, fontFace: **IDWriteFontFace) -> HRESULT #cpp_method;
    CreateBitmapRenderTarget: (this: *IDWriteGdiInterop, hdc: HDC, width: u32, height: u32, renderTarget: **IDWriteBitmapRenderTarget) -> HRESULT #cpp_method;
}
IDWriteGdiInterop_CreateFontFromLOGFONT :: inline (this: *IDWriteGdiInterop, logFont: *LOGFONTW, font: **IDWriteFont) -> HRESULT { return this.idwritegdiinterop_vtable.CreateFontFromLOGFONT(this, logFont, font); }
IDWriteGdiInterop_ConvertFontToLOGFONT :: inline (this: *IDWriteGdiInterop, font: *IDWriteFont, logFont: *LOGFONTW, isSystemFont: *BOOL) -> HRESULT { return this.idwritegdiinterop_vtable.ConvertFontToLOGFONT(this, font, logFont, isSystemFont); }
IDWriteGdiInterop_ConvertFontFaceToLOGFONT :: inline (this: *IDWriteGdiInterop, font: *IDWriteFontFace, logFont: *LOGFONTW) -> HRESULT { return this.idwritegdiinterop_vtable.ConvertFontFaceToLOGFONT(this, font, logFont); }
IDWriteGdiInterop_CreateFontFaceFromHdc :: inline (this: *IDWriteGdiInterop, hdc: HDC, fontFace: **IDWriteFontFace) -> HRESULT { return this.idwritegdiinterop_vtable.CreateFontFaceFromHdc(this, hdc, fontFace); }
IDWriteGdiInterop_CreateBitmapRenderTarget :: inline (this: *IDWriteGdiInterop, hdc: HDC, width: u32, height: u32, renderTarget: **IDWriteBitmapRenderTarget) -> HRESULT { return this.idwritegdiinterop_vtable.CreateBitmapRenderTarget(this, hdc, width, height, renderTarget); }

vtable :: (obj: *IDWriteGdiInterop) -> *IDWriteGdiInterop_VTable { return obj.idwritegdiinterop_vtable; }


DWRITE_TEXTURE_TYPE :: enum s32 {
    ALIASED_1x1   :: 0;

    CLEARTYPE_3x1 :: 1;

    DWRITE_TEXTURE_ALIASED_1x1   :: ALIASED_1x1;

    DWRITE_TEXTURE_CLEARTYPE_3x1 :: CLEARTYPE_3x1;
}

IDWriteGlyphRunAnalysis :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwriteglyphrunanalysis_vtable: *IDWriteGlyphRunAnalysis_VTable;
}
IDWriteGlyphRunAnalysis_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetAlphaTextureBounds: (this: *IDWriteGlyphRunAnalysis, textureType: DWRITE_TEXTURE_TYPE, textureBounds: *RECT) -> HRESULT #cpp_method;
    CreateAlphaTexture: (this: *IDWriteGlyphRunAnalysis, textureType: DWRITE_TEXTURE_TYPE, textureBounds: *RECT, alphaValues: *u8, bufferSize: u32) -> HRESULT #cpp_method;
    GetAlphaBlendParams: (this: *IDWriteGlyphRunAnalysis, renderingParams: *IDWriteRenderingParams, blendGamma: *float, blendEnhancedContrast: *float, blendClearTypeLevel: *float) -> HRESULT #cpp_method;
}
IDWriteGlyphRunAnalysis_GetAlphaTextureBounds :: inline (this: *IDWriteGlyphRunAnalysis, textureType: DWRITE_TEXTURE_TYPE, textureBounds: *RECT) -> HRESULT { return this.idwriteglyphrunanalysis_vtable.GetAlphaTextureBounds(this, textureType, textureBounds); }
IDWriteGlyphRunAnalysis_CreateAlphaTexture :: inline (this: *IDWriteGlyphRunAnalysis, textureType: DWRITE_TEXTURE_TYPE, textureBounds: *RECT, alphaValues: *u8, bufferSize: u32) -> HRESULT { return this.idwriteglyphrunanalysis_vtable.CreateAlphaTexture(this, textureType, textureBounds, alphaValues, bufferSize); }
IDWriteGlyphRunAnalysis_GetAlphaBlendParams :: inline (this: *IDWriteGlyphRunAnalysis, renderingParams: *IDWriteRenderingParams, blendGamma: *float, blendEnhancedContrast: *float, blendClearTypeLevel: *float) -> HRESULT { return this.idwriteglyphrunanalysis_vtable.GetAlphaBlendParams(this, renderingParams, blendGamma, blendEnhancedContrast, blendClearTypeLevel); }

vtable :: (obj: *IDWriteGlyphRunAnalysis) -> *IDWriteGlyphRunAnalysis_VTable { return obj.idwriteglyphrunanalysis_vtable; }


IDWriteFactory :: struct {
    #as using iunknown: IUnknown;
    #place iunknown; idwritefactory_vtable: *IDWriteFactory_VTable;
}
IDWriteFactory_VTable :: struct #type_info_none {
    using iunknown: IUnknown_VTable;
    GetSystemFontCollection: (this: *IDWriteFactory, fontCollection: **IDWriteFontCollection, checkForUpdates: BOOL = 0) -> HRESULT #cpp_method;
    CreateCustomFontCollection: (this: *IDWriteFactory, collectionLoader: *IDWriteFontCollectionLoader, collectionKey: *void, collectionKeySize: u32, fontCollection: **IDWriteFontCollection) -> HRESULT #cpp_method;
    RegisterFontCollectionLoader: (this: *IDWriteFactory, fontCollectionLoader: *IDWriteFontCollectionLoader) -> HRESULT #cpp_method;
    UnregisterFontCollectionLoader: (this: *IDWriteFactory, fontCollectionLoader: *IDWriteFontCollectionLoader) -> HRESULT #cpp_method;
    CreateFontFileReference: (this: *IDWriteFactory, filePath: *s16, lastWriteTime: *FILETIME, fontFile: **IDWriteFontFile) -> HRESULT #cpp_method;
    CreateCustomFontFileReference: (this: *IDWriteFactory, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, fontFileLoader: *IDWriteFontFileLoader, fontFile: **IDWriteFontFile) -> HRESULT #cpp_method;
    CreateFontFace: (this: *IDWriteFactory, fontFaceType: DWRITE_FONT_FACE_TYPE, numberOfFiles: u32, fontFiles: **IDWriteFontFile, faceIndex: u32, fontFaceSimulationFlags: DWRITE_FONT_SIMULATIONS, fontFace: **IDWriteFontFace) -> HRESULT #cpp_method;
    CreateRenderingParams: (this: *IDWriteFactory, renderingParams: **IDWriteRenderingParams) -> HRESULT #cpp_method;
    CreateMonitorRenderingParams: (this: *IDWriteFactory, monitor: HMONITOR, renderingParams: **IDWriteRenderingParams) -> HRESULT #cpp_method;
    CreateCustomRenderingParams: (this: *IDWriteFactory, gamma: float, enhancedContrast: float, clearTypeLevel: float, pixelGeometry: DWRITE_PIXEL_GEOMETRY, renderingMode: DWRITE_RENDERING_MODE, renderingParams: **IDWriteRenderingParams) -> HRESULT #cpp_method;
    RegisterFontFileLoader: (this: *IDWriteFactory, fontFileLoader: *IDWriteFontFileLoader) -> HRESULT #cpp_method;
    UnregisterFontFileLoader: (this: *IDWriteFactory, fontFileLoader: *IDWriteFontFileLoader) -> HRESULT #cpp_method;
    CreateTextFormat: (this: *IDWriteFactory, fontFamilyName: *s16, fontCollection: *IDWriteFontCollection, fontWeight: DWRITE_FONT_WEIGHT, fontStyle: DWRITE_FONT_STYLE, fontStretch: DWRITE_FONT_STRETCH, fontSize: float, localeName: *s16, textFormat: **IDWriteTextFormat) -> HRESULT #cpp_method;
    CreateTypography: (this: *IDWriteFactory, typography: **IDWriteTypography) -> HRESULT #cpp_method;
    GetGdiInterop: (this: *IDWriteFactory, gdiInterop: **IDWriteGdiInterop) -> HRESULT #cpp_method;
    CreateTextLayout: (this: *IDWriteFactory, _string: *s16, stringLength: u32, textFormat: *IDWriteTextFormat, maxWidth: float, maxHeight: float, textLayout: **IDWriteTextLayout) -> HRESULT #cpp_method;
    CreateGdiCompatibleTextLayout: (this: *IDWriteFactory, _string: *s16, stringLength: u32, textFormat: *IDWriteTextFormat, layoutWidth: float, layoutHeight: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, textLayout: **IDWriteTextLayout) -> HRESULT #cpp_method;
    CreateEllipsisTrimmingSign: (this: *IDWriteFactory, textFormat: *IDWriteTextFormat, trimmingSign: **IDWriteInlineObject) -> HRESULT #cpp_method;
    CreateTextAnalyzer: (this: *IDWriteFactory, textAnalyzer: **IDWriteTextAnalyzer) -> HRESULT #cpp_method;
    CreateNumberSubstitution: (this: *IDWriteFactory, substitutionMethod: DWRITE_NUMBER_SUBSTITUTION_METHOD, localeName: *s16, ignoreUserOverride: BOOL, numberSubstitution: **IDWriteNumberSubstitution) -> HRESULT #cpp_method;
    CreateGlyphRunAnalysis: (this: *IDWriteFactory, glyphRun: *DWRITE_GLYPH_RUN, pixelsPerDip: float, transform: *DWRITE_MATRIX, renderingMode: DWRITE_RENDERING_MODE, measuringMode: DWRITE_MEASURING_MODE, baselineOriginX: float, baselineOriginY: float, glyphRunAnalysis: **IDWriteGlyphRunAnalysis) -> HRESULT #cpp_method;
}
IDWriteFactory_GetSystemFontCollection :: inline (this: *IDWriteFactory, fontCollection: **IDWriteFontCollection, checkForUpdates: BOOL = 0) -> HRESULT { return this.idwritefactory_vtable.GetSystemFontCollection(this, fontCollection, checkForUpdates); }
IDWriteFactory_CreateCustomFontCollection :: inline (this: *IDWriteFactory, collectionLoader: *IDWriteFontCollectionLoader, collectionKey: *void, collectionKeySize: u32, fontCollection: **IDWriteFontCollection) -> HRESULT { return this.idwritefactory_vtable.CreateCustomFontCollection(this, collectionLoader, collectionKey, collectionKeySize, fontCollection); }
IDWriteFactory_RegisterFontCollectionLoader :: inline (this: *IDWriteFactory, fontCollectionLoader: *IDWriteFontCollectionLoader) -> HRESULT { return this.idwritefactory_vtable.RegisterFontCollectionLoader(this, fontCollectionLoader); }
IDWriteFactory_UnregisterFontCollectionLoader :: inline (this: *IDWriteFactory, fontCollectionLoader: *IDWriteFontCollectionLoader) -> HRESULT { return this.idwritefactory_vtable.UnregisterFontCollectionLoader(this, fontCollectionLoader); }
IDWriteFactory_CreateFontFileReference :: inline (this: *IDWriteFactory, filePath: *s16, lastWriteTime: *FILETIME, fontFile: **IDWriteFontFile) -> HRESULT { return this.idwritefactory_vtable.CreateFontFileReference(this, filePath, lastWriteTime, fontFile); }
IDWriteFactory_CreateCustomFontFileReference :: inline (this: *IDWriteFactory, fontFileReferenceKey: *void, fontFileReferenceKeySize: u32, fontFileLoader: *IDWriteFontFileLoader, fontFile: **IDWriteFontFile) -> HRESULT { return this.idwritefactory_vtable.CreateCustomFontFileReference(this, fontFileReferenceKey, fontFileReferenceKeySize, fontFileLoader, fontFile); }
IDWriteFactory_CreateFontFace :: inline (this: *IDWriteFactory, fontFaceType: DWRITE_FONT_FACE_TYPE, numberOfFiles: u32, fontFiles: **IDWriteFontFile, faceIndex: u32, fontFaceSimulationFlags: DWRITE_FONT_SIMULATIONS, fontFace: **IDWriteFontFace) -> HRESULT { return this.idwritefactory_vtable.CreateFontFace(this, fontFaceType, numberOfFiles, fontFiles, faceIndex, fontFaceSimulationFlags, fontFace); }
IDWriteFactory_CreateRenderingParams :: inline (this: *IDWriteFactory, renderingParams: **IDWriteRenderingParams) -> HRESULT { return this.idwritefactory_vtable.CreateRenderingParams(this, renderingParams); }
IDWriteFactory_CreateMonitorRenderingParams :: inline (this: *IDWriteFactory, monitor: HMONITOR, renderingParams: **IDWriteRenderingParams) -> HRESULT { return this.idwritefactory_vtable.CreateMonitorRenderingParams(this, monitor, renderingParams); }
IDWriteFactory_CreateCustomRenderingParams :: inline (this: *IDWriteFactory, gamma: float, enhancedContrast: float, clearTypeLevel: float, pixelGeometry: DWRITE_PIXEL_GEOMETRY, renderingMode: DWRITE_RENDERING_MODE, renderingParams: **IDWriteRenderingParams) -> HRESULT { return this.idwritefactory_vtable.CreateCustomRenderingParams(this, gamma, enhancedContrast, clearTypeLevel, pixelGeometry, renderingMode, renderingParams); }
IDWriteFactory_RegisterFontFileLoader :: inline (this: *IDWriteFactory, fontFileLoader: *IDWriteFontFileLoader) -> HRESULT { return this.idwritefactory_vtable.RegisterFontFileLoader(this, fontFileLoader); }
IDWriteFactory_UnregisterFontFileLoader :: inline (this: *IDWriteFactory, fontFileLoader: *IDWriteFontFileLoader) -> HRESULT { return this.idwritefactory_vtable.UnregisterFontFileLoader(this, fontFileLoader); }
IDWriteFactory_CreateTextFormat :: inline (this: *IDWriteFactory, fontFamilyName: *s16, fontCollection: *IDWriteFontCollection, fontWeight: DWRITE_FONT_WEIGHT, fontStyle: DWRITE_FONT_STYLE, fontStretch: DWRITE_FONT_STRETCH, fontSize: float, localeName: *s16, textFormat: **IDWriteTextFormat) -> HRESULT { return this.idwritefactory_vtable.CreateTextFormat(this, fontFamilyName, fontCollection, fontWeight, fontStyle, fontStretch, fontSize, localeName, textFormat); }
IDWriteFactory_CreateTypography :: inline (this: *IDWriteFactory, typography: **IDWriteTypography) -> HRESULT { return this.idwritefactory_vtable.CreateTypography(this, typography); }
IDWriteFactory_GetGdiInterop :: inline (this: *IDWriteFactory, gdiInterop: **IDWriteGdiInterop) -> HRESULT { return this.idwritefactory_vtable.GetGdiInterop(this, gdiInterop); }
IDWriteFactory_CreateTextLayout :: inline (this: *IDWriteFactory, _string: *s16, stringLength: u32, textFormat: *IDWriteTextFormat, maxWidth: float, maxHeight: float, textLayout: **IDWriteTextLayout) -> HRESULT { return this.idwritefactory_vtable.CreateTextLayout(this, _string, stringLength, textFormat, maxWidth, maxHeight, textLayout); }
IDWriteFactory_CreateGdiCompatibleTextLayout :: inline (this: *IDWriteFactory, _string: *s16, stringLength: u32, textFormat: *IDWriteTextFormat, layoutWidth: float, layoutHeight: float, pixelsPerDip: float, transform: *DWRITE_MATRIX, useGdiNatural: BOOL, textLayout: **IDWriteTextLayout) -> HRESULT { return this.idwritefactory_vtable.CreateGdiCompatibleTextLayout(this, _string, stringLength, textFormat, layoutWidth, layoutHeight, pixelsPerDip, transform, useGdiNatural, textLayout); }
IDWriteFactory_CreateEllipsisTrimmingSign :: inline (this: *IDWriteFactory, textFormat: *IDWriteTextFormat, trimmingSign: **IDWriteInlineObject) -> HRESULT { return this.idwritefactory_vtable.CreateEllipsisTrimmingSign(this, textFormat, trimmingSign); }
IDWriteFactory_CreateTextAnalyzer :: inline (this: *IDWriteFactory, textAnalyzer: **IDWriteTextAnalyzer) -> HRESULT { return this.idwritefactory_vtable.CreateTextAnalyzer(this, textAnalyzer); }
IDWriteFactory_CreateNumberSubstitution :: inline (this: *IDWriteFactory, substitutionMethod: DWRITE_NUMBER_SUBSTITUTION_METHOD, localeName: *s16, ignoreUserOverride: BOOL, numberSubstitution: **IDWriteNumberSubstitution) -> HRESULT { return this.idwritefactory_vtable.CreateNumberSubstitution(this, substitutionMethod, localeName, ignoreUserOverride, numberSubstitution); }
IDWriteFactory_CreateGlyphRunAnalysis :: inline (this: *IDWriteFactory, glyphRun: *DWRITE_GLYPH_RUN, pixelsPerDip: float, transform: *DWRITE_MATRIX, renderingMode: DWRITE_RENDERING_MODE, measuringMode: DWRITE_MEASURING_MODE, baselineOriginX: float, baselineOriginY: float, glyphRunAnalysis: **IDWriteGlyphRunAnalysis) -> HRESULT { return this.idwritefactory_vtable.CreateGlyphRunAnalysis(this, glyphRun, pixelsPerDip, transform, renderingMode, measuringMode, baselineOriginX, baselineOriginY, glyphRunAnalysis); }

vtable :: (obj: *IDWriteFactory) -> *IDWriteFactory_VTable { return obj.idwritefactory_vtable; }


DWriteCreateFactory :: (factoryType: DWRITE_FACTORY_TYPE, iid: *IID, factory: **IUnknown) -> HRESULT #foreign dwrite;
DWriteCreateFactory :: (factoryType: DWRITE_FACTORY_TYPE, iid: IID, factory: **IUnknown) -> HRESULT #no_context {
    return DWriteCreateFactory(factoryType, *iid, factory);
}

#scope_file

dwrite :: #library,system "Dwrite";
