#if enable_profiling
{
	profile_scope :: ($name : string) #expand 
	{
		ZoneScoped(name);
	}
	profile_tick :: () #expand
	{
		FrameMark();
	}
}
else
{
	profile_scope :: ($name : string) #expand {}
	profile_tick :: () #expand {}
}