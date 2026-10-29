
exec('ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=300')
exec('ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1')

sleep(1)

for value = 0, 600, 50 
do
    local pusch_sinr = 300 - value
    exec('ul_sinr_testmode_nr profile_id=1 sinr_target_pusch='..pusch_sinr)
    --exec('ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1')
    exec('ue_stats_nr id=1 type=pusch')
    sleep(1)
end

sleep(2)

for value = 0, 600, 50 
do
    local pusch_sinr = -300 + value
    exec('ul_sinr_testmode_nr profile_id=1 sinr_target_pusch='..pusch_sinr)
    --exec('ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1')
    exec('ue_stats_nr id=1 type=pusch')
    sleep(1)
end