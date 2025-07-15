swap_buffers :: (win : Window_Type)
{
	dc := GetDC(win);
	SwapBuffers(dc);
	ReleaseDC(win, dc);
}

get_window_size :: (win : Window_Type) -> Vector2i
{
	out : Vector2i;
	rect : RECT;
	GetClientRect(win, *rect);
	out.x = rect.right - rect.left;
	out.y = rect.bottom - rect.top;
	
	return out;
}

toggle_cursor :: (show : s32)
{
	count := ShowCursor(show);
	if show {
		while (count < 0) count = ShowCursor(1);
	} else {
		while (count >= 0) count = ShowCursor(0);
	}
}

get_perf_counter :: () -> s64
{
	counter : s64;
	QueryPerformanceCounter(*counter);
	return counter;
}

get_perf_freq :: () -> s64
{
	frequency : s64;
	QueryPerformanceFrequency(*frequency);
	return frequency;
}

sleep :: (ms : s32)
{
	Sleep(ms);
}
