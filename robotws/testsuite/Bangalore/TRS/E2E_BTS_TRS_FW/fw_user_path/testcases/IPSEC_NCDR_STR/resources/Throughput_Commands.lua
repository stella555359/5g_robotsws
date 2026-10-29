-- Copyright (c) 2019 Nokia. All rights reserved.
--1.0 Handling pduSize as optional parameter when generating traffic

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'



exec('bearer_stats ue=1 pdu=1 qfi=1 dir=bi')
sleep(1)
exec('bearer_stats ue=1 pdu=1 qfi=2 dir=bi')
sleep(1)
exec('bearer_stats ue=1 pdu=1 qfi=3 dir=bi')
sleep(1)
exec('bearer_stats ue=1 pdu=1 qfi=4 dir=bi')
sleep(1)
exec('bearer_stats ue=1 pdu=1 qfi=5 dir=bi')
--[[

exec('set_pdu_param ue=1 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=1  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=1  dir=dl mbps=175 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=2  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=2  dir=dl mbps=175 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=3  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=3  dir=dl mbps=175 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=4  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=4  dir=dl mbps=175 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=5  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=1 pdu=1 qfi=5  dir=dl mbps=50 ')
sleep(1)

--sleep(5)
--exec('ue_deregister id=1 ue_deregister_type=switch_off')
--[[
sleep(2)
exec('ue_register id=2 profile=1')
sleep(1)
exec('set_pdu_param ue=2 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=2 nwslice=2 gw=1')
sleep(1)
exec('trf_data_start ue=2 pdu=1 qfi=1  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=2 pdu=1 qfi=1  dir=dl mbps=175 ')

--sleep(5)
--exec('ue_deregister id=2 ue_deregister_type=switch_off')


sleep(2)
exec('ue_register id=3 profile=1')
sleep(1)
exec('set_pdu_param ue=3 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=3 nwslice=3 gw=1')
sleep(1)
exec('trf_data_start ue=3 pdu=1 qfi=1  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=3 pdu=1 qfi=1  dir=dl mbps=175 ')

--sleep(5)
--exec('ue_deregister id=3 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=4 profile=1')
sleep(1)
exec('set_pdu_param ue=4 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=4 nwslice=4 gw=1')
sleep(1)
exec('trf_data_start ue=4 pdu=1 qfi=1  dir=ul mbps=50 ')
sleep(1)
exec('trf_data_start ue=4 pdu=1 qfi=1  dir=dl mbps=175 ')

--sleep(5)
--exec('ue_deregister id=4 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=5 profile=1')
sleep(1)
exec('set_pdu_param ue=5 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=5 nwslice=5 gw=1')
sleep(1)
exec('trf_data_start ue=5 pdu=1 qfi=1  dir=ul mbps=25 ')
sleep(1)
exec('trf_data_start ue=5 pdu=1 qfi=1  dir=dl mbps=25 ')

--sleep(5)
--exec('ue_deregister id=5 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=6 profile=1')
sleep(1)
exec('set_pdu_param ue=6 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=6 nwslice=6 gw=1')
sleep(1)
exec('trf_data_start ue=6 pdu=1 qfi=1  dir=ul mbps=25 ')
sleep(1)
exec('trf_data_start ue=6 pdu=1 qfi=1  dir=dl mbps=25 ')

--sleep(5)
--exec('ue_deregister id=6 ue_deregister_type=switch_off')

]]--