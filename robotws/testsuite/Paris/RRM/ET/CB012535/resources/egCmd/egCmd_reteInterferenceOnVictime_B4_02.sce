ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=-72,-74,-76,-78,-80,-82,-84,-86,-88,-90,-92,-94,-96,-98,-100,-102,-104,-106,-110,-110,-110,-110,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115
cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

sleep_script 2

sim_log_set flush
exit
