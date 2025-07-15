is_key_down :: inline (key : Key_Code) -> bool #must
{
	return (input_button_states[cast (s64) key] & .DOWN) != 0;
}

is_key_pressed :: inline (key : Key_Code) -> bool #must
{
	return (input_button_states[cast (s64) key] & .START) != 0;
}

wheel_delta : s32;
last_mpos_x, last_mpos_y : int;
