package nix

import "core:c"

when ODIN_OS == .Darwin {
    foreign import nixexpr "system:nixexprc"
    foreign import nixstore "system:nixstorec"
    foreign import nixutil "system:nixutilc"
}

NixErr :: enum {
    OK = 0,
    ERR_UNKNOWN = -1,
    ERR_OVERFLOW = -2,
    ERR_KEY = -3,
    ERR_NixErrOR = -4,
}

Store :: struct {}

// Used for holding error messages for functions that can fail.
// It's fine to expose it for now, but eventually I will probably make
// a higher-level API that wraps this up.
Context :: struct {}

EvalState :: struct {}

Value :: struct {}
ExternalValue :: struct {}

ValueType :: enum(c.int) {
    THUNK,
    INT,
    FLOAT,
    BOOL,
    STRING,
    PATH,
    NULL,
    ATTRS,
    LIST,
    FUNCTION,
    EXTERNAL,
}

@(link_prefix="nix_")
@(default_calling_convention="c")
foreign nixexpr {
    libexpr_init :: proc(^Context) -> NixErr ---
    state_create :: proc(^Context, [^]cstring, ^Store) -> ^EvalState ---
    alloc_value :: proc(^Context, ^EvalState) -> ^Value ---
    expr_eval_from_string :: proc(^Context, ^EvalState, cstring, cstring, ^Value) -> NixErr ---
    value_force :: proc(^Context, ^EvalState, ^Value) -> NixErr ---
    get_type :: proc(^Context, ^Value) -> ValueType ---
    get_typename :: proc(^Context, ^Value) -> cstring ---
    get_bool :: proc(^Context, ^Value) -> bool ---
    get_string :: proc(^Context, ^Value, proc "c" (start: rawptr, n: c.int, user_data: rawptr), rawptr) -> NixErr ---
    get_path_string :: proc(^Context, ^Value) -> cstring ---
    get_list_size :: proc(^Context, ^Value) -> c.uint ---
    get_attrs_size :: proc(^Context, ^Value) -> c.uint ---
    get_float :: proc(^Context, ^Value) -> c.double ---
    get_int :: proc(^Context, ^Value) -> c.int64_t ---
    get_external_value :: proc(^Context, ^Value) -> ^ExternalValue ---
    get_list_byidx :: proc(^Context, ^Value, ^EvalState, c.uint) -> ^Value ---
    get_list_byidx_lazy :: proc(^Context, ^Value, ^EvalState, c.uint) -> ^Value ---
    get_attr_byname :: proc(^Context, ^Value, ^EvalState, cstring) -> ^Value ---
    get_attr_byname_lazy :: proc(^Context, ^Value, ^EvalState, cstring) -> ^Value ---
    has_attr_byname :: proc(^Context, ^Value, ^EvalState, cstring) -> ^Value ---
    // the last ^cstring points to the attr name
    get_attr_byidx :: proc(^Context, ^Value, ^EvalState, c.uint, ^cstring) -> ^Value ---
    get_attr_byidx_lazy :: proc(^Context, ^Value, ^EvalState, c.uint, ^cstring) -> ^Value ---
    get_attr_name_byidx :: proc(^Context, ^Value, ^EvalState, c.uint) -> cstring ---
    gc_decref :: proc(^Context, rawptr) -> NixErr ---
    value_decref :: proc(^Context, ^Value) -> NixErr ---
    state_free :: proc(^EvalState) ---
}

get_items :: proc(v: ^Value, state: ^EvalState) -> []^Value {
    count := get_list_size(nil, v)
    output := make([]^Value, count)
    name := new(cstring)
    defer free(name)
    for i in 0..<count {
        child_value := get_list_byidx(nil, v, state, i)
        output[i] = child_value
    }
    return output
}

get_attrs :: proc(v: ^Value, state: ^EvalState) -> map[string]^Value {
    count := get_attrs_size(nil, v)
    output := make(map[string]^Value, count)
    name := new(cstring)
    defer free(name)
    for i in 0..<count {
        child_value := get_attr_byidx_lazy(nil, v, state, i, name)
        output[string(name^)] = child_value
    }
    return output
}

// Not 100% sure if this is accurate; I haven't tested it yet.
store_params :: [^][^]Maybe(cstring)

@(link_prefix="nix_")
@(default_calling_convention="c")
foreign nixstore {
    store_open :: proc(^Context, Maybe(cstring), store_params) -> ^Store ---
    store_free :: proc(^Store) ---
}
