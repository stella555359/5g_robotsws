
function collect_bearer_stats(ues, dir, trf_id)
    local cmd = 'bearer_stats ue='.. ues .. ' dir='..dir ..' pdu=1 qfi=1 type=l3 format=long scell=0 trf_id='.. trf_id
    exec(cmd)
    sleep(0.4)
    local end_time = os.clock()
    exec('sim_log_set flush')
    print('bearer_stats collected')
end
