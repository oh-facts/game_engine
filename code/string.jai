str_from_cstr :: (cstr : *u8, zero_terminate : bool = false) -> string
{
	uri_str : string;
	uri_str.data = cstr;
	
	c := uri_str.data[0];
	index : int;
	
	while c != #char "\0" 
	{
		c = uri_str.data[index];
		index += 1;
	}
	
	if !zero_terminate
	{
		index -= 1;
	}
	
	uri_str.count = index;
	
	return uri_str;
}

hash_string :: (data : string) -> u128 {
	
#asm { hash: vec; }
	
	MeowHash(MeowDefaultSeed, xx data.count, data.data, hash);
	
	out : u128;
	out.U64[0] = MeowU64From(hash, 0);
	out.U64[1] = MeowU64From(hash, 1);
	
	return out;
}
