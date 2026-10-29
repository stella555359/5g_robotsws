#!/usr/bin/expect -f

# Start uexgate in its own shell
spawn /opt/cus/bin/uexgate

# Wait for UExGate prompt
expect "UExGate>"

# Turn CLI off
send "cli_off\r"
expect "uex-gate(1)>"

# Send the Elixir command (all braces escaped)
send -- "\{\:ok, _subscriber\} = UEx.GenSub.Server.start_link(nil, \{UE.whereis(1), UE.Pub.RRC, \{\:info, \:rrcConnectionReestablishmentReject\}, UEx.GenSub.FlowStep.action(fn _ -> UExGate.trf_data_start(\[ue: 1, dir: :ul, protocol: :udp, Mbps: 20.0, stats: true\]) end)\})\r"
expect "{:ok, #PID"

send -- "\{\:ok, _subscriber\} = UEx.GenSub.Server.start_link(nil, \{UE.whereis(1), UE.Pub.RRC, \{\:info, \:rrcConnectionReestablishmentReject\}, UEx.GenSub.FlowStep.action(fn _ -> UExGate.trf_data_start(\[ue: 1, dir: :ul, protocol: :udp, Mbps: 20.0, stats: true\]) end)\})\r"
expect "{:ok, #PID"

send -- "\{\:ok, _subscriber\} = UEx.GenSub.Server.start_link(nil, \{UE.whereis(1), UE.Pub.RRC, \{\:info, \:rrcConnectionReestablishmentReject\}, UEx.GenSub.FlowStep.action(fn _ -> UExGate.trf_data_start(\[ue: 1, dir: :ul, protocol: :udp, Mbps: 20.0, stats: true\]) end)\})\r"
expect "{:ok, #PID"

send -- "\{\:ok, _subscriber\} = UEx.GenSub.Server.start_link(nil, \{UE.whereis(1), UE.Pub.RRC, \{\:info, \:rrcConnectionReestablishmentReject\}, UEx.GenSub.FlowStep.action(fn _ -> UExGate.trf_data_start(\[ue: 1, dir: :ul, protocol: :udp, Mbps: 20.0, stats: true\]) end)\})\r"
expect "{:ok, #PID"

send -- "\{\:ok, _subscriber\} = UEx.GenSub.Server.start_link(nil, \{UE.whereis(1), UE.Pub.RRC, \{\:info, \:rrcConnectionReestablishmentReject\}, UEx.GenSub.FlowStep.action(fn _ -> UExGate.trf_data_start(\[ue: 1, dir: :ul, protocol: :udp, Mbps: 20.0, stats: true\]) end)\})\r"
expect "{:ok, #PID"

# Turn CLI back on
send "cli_on\r"
expect ":ok"

interact
