package main

import "core:c"
import "core:os"
import "core:fmt"
import "base:runtime"
import "core:strings"

import "nix"

// NOTE: I am not using the Nix bindings mechanism for handling errors at all.
// Read through the bindings' docs before copying anything I do here.
main :: proc() {
    nix.libexpr_init(nil)
    // Passing nil for the second parameter tells Nix to open the default store on the current system.
    store := nix.store_open(nil, nil, nil)
    state := nix.state_create(nil, nil, store)
    value := nix.alloc_value(nil, state)

    if len(os.args) != 2 {
        fmt.eprintln("Usage: igloo <nix expr>")
        return
    }

    input := os.args[1]
    nix.expr_eval_from_string(nil, state, strings.clone_to_cstring(input), ".", value)

    // I'm intentionally not calling nix.value_force() here because I want the REPL to be lazy.
    // If the repl was strict, then you wouldn't be able to eval all of "(import <nixpkgs> {})"
    // without something crashing.
    show_value(value, state)

    nix.value_decref(nil, value)
    nix.store_free(store)
}

show_value :: proc(value: ^nix.Value, state: ^nix.EvalState) {
    type := nix.get_type(nil, value)
    switch type {
    case .ATTRS:
        fmt.println("{")
        for attr, value in nix.get_attrs(value, state) {
            typename := nix.get_typename(nil, value)
            fmt.printfln("  %s: %s", attr, typename)
        }
        fmt.println("}")
    case .STRING:
        str: string
        nix.get_string(nil, value, load_str, &str)
        fmt.printfln("\"%s\"", str)
    case .BOOL:
        fmt.println(nix.get_bool(nil, value))
    case .NULL:
        fmt.println("null")
    case .INT:
        fmt.println(nix.get_int(nil, value))
    case .FLOAT:
        fmt.println(nix.get_float(nil, value))
    case .LIST:
        fmt.println("[")
        for item in nix.get_items(value, state) {
            typename := nix.get_typename(nil, value)
            fmt.println("  %s", typename)
        }
        fmt.println("]")
    case .PATH:
        fmt.println(nix.get_path_string(nil, value))
    case .EXTERNAL:
        fmt.println("<external-type>")
    case .FUNCTION:
        fmt.println("<function>")
    case .THUNK:
        fmt.println("<thunk>")
    }
}

load_str :: proc "c" (start: rawptr, n: c.int, user_data: rawptr) {
    context = runtime.default_context()
    str := strings.clone_from_ptr(cast(^byte)start, int(n))
    out := cast(^string)user_data
    out^ = str
}
