// Dayne
// Build
// Alex Hartford
// August 2024

#import "Basic";
#import "Compiler";
#import "File";

#import "ctags";

build :: () {
    w := compiler_create_workspace("Main Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "fish";

    options.output_path = "bin";
    options.intermediate_path = "bin/.build";
    options.output_type = .EXECUTABLE;
    options.text_output_flags = 2;

    set_build_options(options, w);
    set_build_options_dc(.{do_output=false});

	compiler_begin_intercept(w);

    add_build_file(tprint("%/source/main.jai", #filepath), w);

	// Set up ctags options
	ctags: CTags;
	ctags.output_filename = "tags";
	ctags.base_path = tprint("%", #filepath);
	defer reset(*ctags);

	while true {
		message := compiler_wait_for_message();
		if !message continue;

		if message.workspace == w {
			process_message(*ctags, message);
		}

		if message.kind == .COMPLETE break;
	}

    // Create a manifest and an icon file.
	#if OS == .WINDOWS {
		exe_name := sprint("%/%.exe", options.output_path, options.output_executable_name);
		defer free(exe_name);

		ico_data := create_ico_file_from_bitmap_filename("assets/misc/icon.png");
		defer free(ico_data);

		set_icon_by_data(exe_name, ico_data);
        write_entire_file("assets/misc/icon.ico", ico_data);

		print("Icon     added: %\n", set_icon_by_filename(exe_name, "assets/misc/icon.ico"));

		manifest_options: Manifest_Options;
		print("Manifest added: %\n", add_manifest_to_executable(exe_name, manifest_options));

		#import "Ico_File";
		#import "Windows_Resources";
	}
}

#run build();
