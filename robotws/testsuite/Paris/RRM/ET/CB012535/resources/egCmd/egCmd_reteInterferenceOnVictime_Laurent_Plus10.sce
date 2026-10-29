ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=-92,-94,-96,-98,-100,-102,-104,-106,-108,-110,-112,-114,-114,-116,-118,-118,-118,-120,-120,-120,-120,-125,-125,-125,-125,-125,-125,-125,-125,-125,-125,-125
cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

sleep_script 2

sim_log_set flush
exit