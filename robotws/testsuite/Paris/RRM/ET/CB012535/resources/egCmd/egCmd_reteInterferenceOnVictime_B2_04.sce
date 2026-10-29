ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=-79,-81,-83,-85,-87,-89,-91,-93,-95,-97,-99,-101,-101,-103,-105,-105,-105,-107,-107,-110,-110,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115 
cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

sleep_script 2

sim_log_set flush
exit