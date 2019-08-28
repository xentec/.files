function fish_right_prompt
	set -l dur_color green
	if [ $__fish_last_status -ne 0 ]
		echo -ns (set_color -o red) "$__fish_last_status! " (set_color normal)
		set dur_color red
	end

	[ "$__fish_cmd_duration" ]; and \
		echo -ns (set_color $dur_color) "+$__fish_cmd_duration "

	echo -s (set_color blue) (date '+%H:%M:%S') (set_color normal) " "
end
