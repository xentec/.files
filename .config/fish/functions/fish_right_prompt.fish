function fish_right_prompt
	set -l dur ""
	if [ $CMD_DURATION -ne 0 ]

		# mostly copied from 
		# https://github.com/jichu4n/fish-command-timer/blob/28871b3ce1bc7a1adc92a3e92d1c3182eef23c69/conf.d/fish_command_timer.fish#L149
		# thanks jichu4n!
		set -l SEC 1000
		set -l MIN 60000
		set -l HOUR 3600000
		set -l DAY 86400000

		set -l num_days (math "$CMD_DURATION / $DAY")
		set -l num_hours (math "$CMD_DURATION % $DAY / $HOUR")
		set -l num_mins (math "$CMD_DURATION % $HOUR / $MIN")
		set -l num_secs (math "$CMD_DURATION % $MIN / $SEC")
		set -l num_millis (math "$CMD_DURATION % $SEC")
		if [ $num_days -gt 0 ];  set dur {$dur}{$num_days}"-";  end
		if [ $num_hours -gt 0 ]; set dur {$dur}{$num_hours}":"; end
		if [ $num_mins -gt 0 ];  set dur {$dur}{$num_mins}":";  end

		set dur "+"{$dur}{$num_secs}"."(printf '%003d' $num_millis)"s"
	end

	echo -s (set_color green) $dur " " (set_color blue) (date '+%H:%M:%S') (set_color normal)

	if [ $CMD_DURATION -gt 10000 ]
		set -l cmd $history[1]
		set -l exe (string split -m 1 ' ' $cmd)[1] 

		if not contains -- $exe  fish ssh ncmpcpp less man ranger
			notify-send -a "fish" -t 60 \
				"fish: $exe done!" "$dur"
		end
	end

end
