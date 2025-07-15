f32 :: float32;
f64 :: float64;

u128 :: struct 
{
	U64 : [2]u64;
};

COLOR_WHITE :: Vector4.{1, 1, 1, 1};
COLOR_BLACK :: Vector4.{0, 0, 0, 1};

COLOR_RED :: Vector4.{1, 0, 0, 1};
COLOR_GREEN :: Vector4.{0, 1, 0, 1};
COLOR_BLUE :: Vector4.{0, 0, 1, 1};
COLOR_YELLOW :: Vector4.{1, 1, 0, 1};
COLOR_CYAN :: Vector4.{0, 1, 1, 1};
COLOR_MAGENTA :: Vector4.{1, 0, 1, 1};

COLOR_ORANGE :: Vector4.{0.79, 0.33, 0, 1};

operator == :: (a : u128, b : u128) -> bool {
	return ((a.U64[0] == b.U64[0]) && (a.U64[1] == b.U64[1]));
}

KB :: (v : u64) -> u64 #expand {
	return v * 1024;
}

MB :: (v : u64) -> u64 #expand {
	return KB(v) * 1024;
}

GB :: (v : u64) -> u64 #expand {
	return MB(v) * 1024;
}

TB :: (v : u64) -> u64 #expand {
	return GB(v) * 1024;
}

is_pow_2 :: (addr : u64) -> bool #expand{
	return (addr & (addr-1)) == 0;
}

align_pow_2 :: (x: u64, b: u64) -> u64 #expand{
	return (((x) + (b) - 1)&(~((b) - 1)));
}

clamp_top :: (a : $A, x : A) -> A #expand {
	return min(a,x);
}

clamp_bot :: (x : $X, b : X) -> X #expand {
	return max(x,b);
}

max :: (a : float32, b : float32) -> float32 {
	if a > b {
		return a;
	} else {
		return b;
	}
}