#import "Compiler";
#import "File";
#import "Basic";
#import "meow_hash";
hash_string :: (data : string) -> u128 {
	
#asm { hash: vec; }
	
	MeowHash(MeowDefaultSeed, xx data.count, data.data, hash);
	
	out : u128;
	out.U64[0] = MeowU64From(hash, 0);
	out.U64[1] = MeowU64From(hash, 1);
	
	return out;
}
u128 :: struct {
	U64 : [2]u64;
};

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
			return;
		}
	} 
	
	w := compiler_create_workspace("winter");
	target_options := get_build_options(w);
	target_options.output_executable_name = "winter";
	target_options.output_path = ".build/";
	target_options.backend = .X64;
	set_build_options(target_options, w);
	
	add_build_file("code/main.jai", w);
}

#run build();