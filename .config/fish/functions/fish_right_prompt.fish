function fish_right_prompt
	set -l dur ""
	if [ $CMD_DURATION -gt 1000 ]

		# mostly copied from 
		# https://github.com/jichu4n/fish-command-timer/blob/28871b3ce1bc7a1adc92a3e92d1c3182eef23c69/conf.d/fish_command_timer.fish#L149
		# thanks jichu4n!
		set -l SEC 1000
		set -l MIN 60000
		set -l HOUR 3600000
		set -l DAY 86400000

		set -l num_days (math -s0 "$CMD_DURATION / $DAY")
		set -l num_hours (math -s0 "$CMD_DURATION % $DAY / $HOUR")
		set -l num_mins (math -s0 "$CMD_DURATION % $HOUR / $MIN")
		set -l num_secs (math -s0 "$CMD_DURATION % $MIN / $SEC")
		set -l num_millis (math -s0 "$CMD_DURATION % $SEC")
		if [ $num_days -gt 0 ];  set dur {$dur}(printf "%02d-" {$num_days});  end
		if [ $num_hours -gt 0 ]; set dur {$dur}(printf "%02d:" {$num_hours}); end
		if [ $num_mins -gt 0 ];  set dur {$dur}(printf "%02d:" {$num_mins});  end

		set dur "+"{$dur}{$num_secs}"."(printf '%003d' $num_millis)"s "
	end

	set_color green
	if [ $__fish_last_status -ne 0 ]
		echo -s (set_color -o red) "$__fish_last_status! " (set_color normal)
		set_color red
	end

	echo -s $dur (set_color blue) (date '+%H:%M:%S') (set_color normal) " "

	if [ $CMD_DURATION -gt 30000 ]; and command -qs notify-send
		set -l cmd $history[1]
		set -l exe (string split -m 1 ' ' $cmd)[1] 

		if not contains -- $exe  fish ssh ncmpcpp less man ranger htop
			notify-send -a "fish" -t 60000 \
				"fish: $exe done!" "$dur"
		end
	end
	set CMD_DURATION 0
end
