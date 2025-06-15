#import "Bindings_Generator";
#import "Compiler";
#import "Basic";

#run build();

build :: ()
{
	set_build_options_dc(.{do_output=false});
	
	output_filename: string;
	opts: Generate_Bindings_Options;
	{
		using opts;
		output_filename          = "windows.jai";
		generate_compile_time_struct_checks = false;
		
		array_add(*libnames,      "Dwrite.dll");
		array_add(*source_files,  "dwrite.h");
		array_add(*extra_clang_arguments, "-x", "c++", "-DWIN32_LEAN_AND_MEAN", "-DUNICODE");
		array_add(*path_fragments_to_treat_as_non_system_paths, "dwrite.h", "dcommon.h");
		mimic_spacing_flags &= ~Mimic_Spacing_Flags.VTABLE;
		log_stripped_declarations = false;
	}
	generate_bindings(opts, output_filename);
}