
#run build();

build :: () {
    set_build_options_dc(.{do_output=false});
    
    options := get_build_options();
    success := build_cpp_dynamic_lib("miniaudio", "miniaudio.c", extra=.["/DMA_DLL", "/DMA_IMPLEMENTATION"], debug=true);
    if !success {
        compiler_set_workspace_status(.FAILED);
        return;
    }

    if !generate_bindings() {
        compiler_set_workspace_status(.FAILED);
        return;
    }    
}

generate_bindings :: () -> bool {
    output_filename: string;
    opts: Generate_Bindings_Options;
    {
        using opts;

        output_filename = "module.jai";
        strip_flags = 0;

        array_add(*libpaths,       ".");
        array_add(*libnames,      "miniaudio");
        array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*source_files,  "miniaudio.h");
        array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN", "-DDMA_DLL");

        // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
