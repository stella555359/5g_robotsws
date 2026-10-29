ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=-100,-95,-90,-90,-90,-85,-85,-85,-80,-80,-75,-75,-70,-65,-65,-55,-55,-55,-65,-70,-75,-75,-80,-110,-110,-110,-110,-110,-110,-110,-110,-110
sleep_script 1
cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

sleep_script 2
ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

sim_log_set flush
exit