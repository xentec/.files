# ssh config needs 'RemoteForward 11883 localhost:1883'

set fish_notify_exclude fish ssh ncmpcpp less man ranger htop tig
set fish_notify_mqtt_port 11883
set fish_notify_mqtt_topic_base /notify
set fish_notify_mqtt_topic $fish_notify_mqtt_topic_base/(hostname)/fish

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

	[ $cmd_dur -gt 1000 ]
		or return

	set -l cmd (string split -m 1 ' ' $argv)
	set -l exe $cmd[1]
	contains -- $exe $fish_notify_exclude
		and return

	echo -nes "\a" # bell (will flash terminal)

	set -l wrap (string sub -l 20 -- $cmd[2])
	[ "$wrap" != "$cmd[2]" ]; and \
		set wrap "$wrap.."

	set -l body "<tt><b>$exe</b> $wrap </tt>completed in $dur"

	set -l remote
	[ "$SSH_CONNECTION" ]; and command -qs ss; and \
		set remote (ss -H -ltn "sport :$fish_notify_mqtt_port")

	if [ "$remote" ];
		command -qs mosquitto_pub; and \
			mosquitto_pub -p $fish_notify_mqtt_port -t $fish_notify_mqtt_topic -m "$body" &
	else
		command -qs notify-send; and \
			notify-send -a "fish" -t 10000 "fish" "$body" &
	end
end

# ensure a mqtt broker is running
# start this in local maschine in the background
function delayed_notify_subscriber
	command -qs mosquitto_sub; and command -qs notify-send
		or begin
			echo "mosquitto_sub or notify-send not found!"
			return
		end

	while true
		mosquitto_sub -v -c -C 1 -i host/(hostname) -t "$fish_notify_mqtt_topic_base/#" | tee /dev/stderr | read SUM BODY
		notify-send (string replace "$fish_notify_mqtt_topic_base/" '' $SUM) "$BODY"
	end
end
