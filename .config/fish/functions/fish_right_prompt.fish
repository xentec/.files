
set fish_notify_exclude fish ssh ncmpcpp less man ranger htop tig

function delayed_notify --on-event fish_postexec
	set -g __fish_cmd_duration ""
	[ $CMD_DURATION -gt 1000 ]
		or return

	set -l cmd_dur $CMD_DURATION
	set CMD_DURATION 0

	# mostly copied from 
	# https://github.com/jichu4n/fish-command-timer/blob/28871b3ce1bc7a1adc92a3e92d1c3182eef23c69/conf.d/fish_command_timer.fish#L149
	# thanks jichu4n!
	set -l dur ""
	set -l SEC 1000
	set -l MIN 60000
	set -l HOUR 3600000
	set -l DAY 86400000

	set -l num_days (math -s0 "$cmd_dur / $DAY")
	set -l num_hours (math -s0 "$cmd_dur % $DAY / $HOUR")
	set -l num_mins (math -s0 "$cmd_dur % $HOUR / $MIN")
	set -l num_secs (math -s0 "$cmd_dur % $MIN / $SEC")
	set -l num_millis (math -s0 "$cmd_dur % $SEC")
	if [ $num_days -gt 0 ];  set dur {$dur}(printf "%02d-" {$num_days});  end
	if [ $num_hours -gt 0 ]; set dur {$dur}(printf "%02d:" {$num_hours}); end
	if [ $num_mins -gt 0 ];  set dur {$dur}(printf "%02d:" {$num_mins});  end

	set dur {$dur}{$num_secs}"."(printf '%003d' $num_millis)"s"
	set __fish_cmd_duration "$dur"

	[ $cmd_dur -gt 30000 ]
		or return

	set -l exe (string split -m 1 ' ' $argv[1])[1]
	contains -- $exe $fish_notify_exclude
		and return

	echo -nes "\a" # bell (will flash terminal)

	command -qs notify-send; and \
		notify-send -a "fish" -t 10000 "fish: $exe done!" "$dur" &
end


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
