#import "Compiler";
#import "File";
#import "File_Utilities";
#import "Basic";
#load "code/main.jai";

build :: () 
{
	set_build_options_dc(.{do_output=false});
	options := get_build_options();
	args := options.compile_time_command_line;
	
	for args 
	{
		if it == 
		{
			case "clean";
			delete_directory(".build/");
			print("deleted .build\n");
			
			case "ship";
			root_ship_folder := "ships";
			current_ship_folder := sprint("%/%.%.%", root_ship_folder, major, minor, patch);
			
			make_directory_if_it_does_not_exist(root_ship_folder);
			make_directory_if_it_does_not_exist(current_ship_folder);
			
			copy_directory("code", sprint("%/code", current_ship_folder));
			copy_directory("data", sprint("%/data", current_ship_folder));
			copy_directory("modules", sprint("%/modules", current_ship_folder));
			copy_directory(".build", sprint("%/.build", current_ship_folder));
			
			copy_file("first.jai", sprint("%/first.jai", current_ship_folder));
			
			print("shipped to %", current_ship_folder);
		}
	} 
	
	if !args
	{
		w := compiler_create_workspace("winter");
		target_options := get_build_options(w);
		target_options.output_executable_name = "winter";
		target_options.output_path = ".build/";
		target_options.backend = .X64;
		set_build_options(target_options, w);
		
		add_build_file("code/main.jai", w);
	}
}

#run build();