-- Copyright (c) 2019 Nokia. All rights reserved.
--1.0 Handling pduSize as optional parameter when generating traffic

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'


exec('enb_x2_link_up enb=1 target=2')

sleep(5)

sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:489')
sleep(1)
exec('ue_attach id=1 profile=1 selected_plmn=311:489')
sleep(1)
exec('ue_dc_enb_start ue=1 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=1 id=2 dir=ul trf_id=1 kbps=200 ')

sleep(5)

exec('ue_detach id=1')


sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:490')
sleep(1)
exec('ue_attach id=2 profile=1 selected_plmn=311:490')
sleep(1)
exec('ue_dc_enb_start ue=2 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=2 id=2 dir=ul trf_id=1 kbps=200')

sleep(5)

exec('ue_detach id=2')


sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:491')
sleep(1)
exec('ue_attach id=3 profile=1 selected_plmn=311:491')
sleep(1)
exec('ue_dc_enb_start ue=3 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=3 id=2 dir=ul trf_id=1 kbps=200')

sleep(5)

exec('ue_detach id=3')

sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:492')
sleep(1)
exec('ue_attach id=4 profile=1 selected_plmn=311:492')
sleep(1)
exec('ue_dc_enb_start ue=4 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=4 id=2 dir=ul trf_id=1 kbps=200')

sleep(5)

exec('ue_detach id=4')

sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:493')
sleep(1)
exec('ue_attach id=5 profile=1 selected_plmn=311:493')
sleep(1)
exec('ue_dc_enb_start ue=5 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=5 id=2 dir=ul trf_id=1 kbps=200')

sleep(5)

exec('ue_detach id=5')


sleep(1)
exec('enb_endc_param id=1 selected_plmn=311:494')
sleep(1)
exec('ue_attach id=6 profile=1 selected_plmn=311:494')
sleep(1)
exec('ue_dc_enb_start ue=6 target_gnb=2 target_cells=1 bearer=2 type=split_scg')
sleep(1)
exec('trf_data_start ue=6 id=2 dir=ul trf_id=1 kbps=200')

sleep(5)

exec('ue_detach id=6')




--[[


sleep(2)
exec('ue_register id=2 profile=1')
sleep(1)
exec('set_pdu_param ue=2 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=2 nwslice=2 gw=1')
sleep(1)
exec('trf_data_start ue=2 pdu=1 qfi=1  dir=ul kbps=10 ')
sleep(1)
exec('trf_data_start ue=2 pdu=1 qfi=1  dir=dl kbps=10 ')
sleep(5)
exec('ue_deregister id=2 ue_deregister_type=switch_off')


sleep(2)
exec('ue_register id=3 profile=1')
sleep(1)
exec('set_pdu_param ue=3 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=3 nwslice=3 gw=1')
sleep(1)
exec('trf_data_start ue=3 pdu=1 qfi=1  dir=ul kbps=10 ')
sleep(1)
exec('trf_data_start ue=3 pdu=1 qfi=1  dir=dl kbps=10 ')
sleep(5)
exec('ue_deregister id=3 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=4 profile=1')
sleep(1)
exec('set_pdu_param ue=4 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=4 nwslice=4 gw=1')
sleep(1)
exec('trf_data_start ue=4 pdu=1 qfi=1  dir=ul kbps=10 ')
sleep(1)
exec('trf_data_start ue=4 pdu=1 qfi=1  dir=dl kbps=10 ')
sleep(5)
exec('ue_deregister id=4 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=5 profile=1')
sleep(1)
exec('set_pdu_param ue=5 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=5 nwslice=5 gw=1')
sleep(1)
exec('trf_data_start ue=5 pdu=1 qfi=1  dir=ul kbps=10 ')
sleep(1)
exec('trf_data_start ue=5 pdu=1 qfi=1  dir=dl kbps=10 ')
sleep(5)
exec('ue_deregister id=5 ue_deregister_type=switch_off')

sleep(2)
exec('ue_register id=6 profile=1')
sleep(1)
exec('set_pdu_param ue=6 pdu=1 trf_type=internal')
sleep(1)
exec('ue_pdu_session_setup pdu=1 ue=6 nwslice=6 gw=1')
sleep(1)
exec('trf_data_start ue=6 pdu=1 qfi=1  dir=ul kbps=10 ')
sleep(1)
exec('trf_data_start ue=6 pdu=1 qfi=1  dir=dl kbps=10 ')
sleep(5)
exec('ue_deregister id=6 ue_deregister_type=switch_off')


--LTE Calls verifictaion---

sleep(5)


--OP1--

exec('ue_attach id=21 selected_plmn=311:489')
sleep(1)
exec('trf_data_start ue=21 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=21 id=2 dir=ul trf_id=2 kbps=2')
sleep(5)
exec('ue_detach id=21')


--OP2--
exec('ue_attach id=22 selected_plmn=311:490')
sleep(1)
exec('trf_data_start ue=22 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=22 id=2 dir=ul trf_id=2 kbps=2')

sleep(5)
exec('ue_detach id=22')

--OP3--
exec('ue_attach id=23 selected_plmn=311:491')
sleep(1)
exec('trf_data_start ue=23 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=23 id=2 dir=ul trf_id=2 kbps=2')
sleep(5)
exec('ue_detach id=23')

--OP4--
exec('ue_attach id=24 selected_plmn=311:492')
sleep(1)
exec('trf_data_start ue=24 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=24 id=2 dir=ul trf_id=2 kbps=2')
sleep(5)
exec('ue_detach id=24')
--OP5--
exec('ue_attach id=25 selected_plmn=311:493')
sleep(1)
exec('trf_data_start ue=25 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=25 id=2 dir=ul trf_id=2 kbps=2')
sleep(5)
exec('ue_detach id=25')
--OP6--
exec('ue_attach id=26 selected_plmn=311:494')
sleep(1)
exec('trf_data_start ue=26 id=2 dir=dl trf_id=2 kbps=2')
sleep(1)
exec('trf_data_start ue=26 id=2 dir=ul trf_id=2 kbps=2')
sleep(5)
exec('ue_detach id=26')


--[[
--OP1--
exec('trf_data_start ue=21 id=2 dir=dl trf_id=2 kbps=2')
exec('trf_data_start ue=21 id=2 dir=ul trf_id=2 kbps=2')
sleep(0.1)
--OP2--
exec('trf_data_start ue=22 id=2 dir=dl trf_id=2 kbps=2')
exec('trf_data_start ue=22 id=2 dir=ul trf_id=2 kbps=2')
sleep(0.1)
--OP3--
exec('trf_data_start ue=23 id=2 dir=dl trf_id=2 kbps=2')
exec('trf_data_start ue=23 id=2 dir=ul trf_id=2 kbps=2')
sleep(0.1)
--OP4--
exec('trf_data_start ue=24 id=2 dir=dl trf_id=2 kbps=2')
exec('trf_data_start ue=24 id=2 dir=ul trf_id=2 kbps=2')
sleep(0.1)
--OP5--
exec('trf_data_start ue=25 id=2 dir=dl trf_id=2 kbps=2')
exec('trf_data_start ue=25 id=2 dir=ul trf_id=2 kbps=2')
sleep(0.1)
--OP6--
exec('trf_data_start ue=26 id=2 dir=dl trf_id=2 mbps=2')
exec('trf_data_start ue=26 id=2 dir=ul trf_id=2 mbps=2')
sleep(0.1)

sleep(5)

exec('ue_detach id=21')
exec('ue_detach id=22')
exec('ue_detach id=23')
exec('ue_detach id=24')
exec('ue_detach id=25')
exec('ue_detach id=26')

]] --
--sleep(5)

--NSA Calls---




--[[
exec('ue_attach id=11 profile=1 selected_plmn=311:489')
sleep(0.1)
exec('ue_measurement_send id=11 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(0.1)
exec('bearer_ue_param ue=11 id=2 scg_ul_dist_percent=100')
sleep(0.1)



exec('ue_attach id=11 profile=1 selected_plmn=311:489')
sleep(1)
exec('ue_measurement_send id=11 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=11 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=11 id=2 dir=ul trf_id=1 kbps=2')
sleep(1)
exec('trf_data_start ue=11 id=2 dir=dl trf_id=1 kbps=2')
sleep(5)
exec('ue_detach id=11')

sleep(1)
exec('ue_attach id=12 profile=1 selected_plmn=311:490')
sleep(1)
exec('ue_measurement_send id=12 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=12 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=12 id=2 dir=ul trf_id=1 kbps=2')
sleep(1)
exec('trf_data_start ue=12 id=2 dir=dl trf_id=1 kbps=2')
sleep(5)
exec('ue_detach id=12')


exec('ue_attach id=13 profile=1 selected_plmn=311:491')
sleep(1)
exec('ue_measurement_send id=13 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=13 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=13 id=2 dir=ul trf_id=1 kbps=2')
sleep(1)
exec('trf_data_start ue=13 id=2 dir=dl trf_id=1 kbps=2')
sleep(5)
exec('ue_detach id=13')



exec('ue_attach id=14 profile=1 selected_plmn=311:492')
sleep(1)
exec('ue_measurement_send id=14 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=14 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=14 id=2 dir=ul trf_id=1 kbps=2')
sleep(1)
exec('trf_data_start ue=14 id=2 dir=dl trf_id=1 mbps=2')
sleep(5)
exec('ue_detach id=14')


exec('ue_attach id=15 profile=1 selected_plmn=311:493')
sleep(1)
exec('ue_measurement_send id=15 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=15 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=15 id=2 dir=ul trf_id=1 kbps=2')
sleep(1)
exec('trf_data_start ue=15 id=2 dir=dl trf_id=1 kbps=2')
sleep(5)
exec('ue_detach id=15')



exec('ue_attach id=16 profile=1 selected_plmn=311:494')
sleep(1)
exec('ue_measurement_send id=16 phycell_id=50 nrsrp=127 event=B1_NR')
sleep(1)
exec('bearer_ue_param ue=16 id=2 scg_ul_dist_percent=100')
sleep(1)
exec('trf_data_start ue=16 id=2 dir=ul trf_id=1 mbps=2')
sleep(1)
exec('trf_data_start ue=16 id=2 dir=dl trf_id=1 mbps=2')
sleep(5)
exec('ue_detach id=16')

]]--


--[[
exec('trf_data_start ue=11 id=2 dir=ul trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=11 id=2 dir=dl trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=12 id=2 dir=ul trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=12 id=2 dir=dl trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=13 id=2 dir=ul trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=13 id=2 dir=dl trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=14 id=2 dir=ul trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=14 id=2 dir=dl trf_id=1 mbps=2')
sleep(0.1)
exec('trf_data_start ue=15 id=2 dir=ul trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=15 id=2 dir=dl trf_id=1 kbps=2')
sleep(0.1)
exec('trf_data_start ue=16 id=2 dir=ul trf_id=1 mbps=2')
sleep(0.1)
exec('trf_data_start ue=16 id=2 dir=dl trf_id=1 mbps=2')



sleep(5)

exec('ue_detach id=11')
sleep(0.1)
exec('ue_detach id=12')
sleep(0.1)
exec('ue_detach id=13')
sleep(0.1)
exec('ue_detach id=14')
sleep(0.1)
exec('ue_detach id=15')
sleep(0.1)
exec('ue_detach id=16')

sleep(5)


]]--

--SA Calls---


--[[
sleep(5)

exec('ue_detach id=1')
sleep(0.1)
exec('ue_detach id=2')
sleep(0.1)
exec('ue_detach id=3')
sleep(0.1)
exec('ue_detach id=4')
sleep(0.1)
exec('ue_detach id=5')
sleep(0.1)
exec('ue_detach id=6')

]]--

--[[
    function sim_enb_x2_link_bring_up(start_enbid, end_enbid, target_gNBid, delay)
    local err = {}
    local result = {}
    local func_name = "start_X2_link_up_for_multi_enb"
    local end_id = end_enbid
    
    if target_gNBid ~= 0 or target_gNBid ~= NULL then
        if target_gNBid <= end_enbid and target_gNBid >= start_enbid then
 	    end_id = end_enbid + 1
        end
    end

    for id=start_enbid, end_id do
	print('ENB id: '..id..' X2 Link')
	if id == target_gNBid then
	    goto label1
	end
        exec('enb_x2_link_up enb='..id..' target='..target_gNBid)
        sleep (delay)
        ::label1::
    end
    print('All SIM-ENBs X2 Link up successfully')
--    sleep (10)
--    exec('sim_state_disp')
end


function sim_gnb_xn_link_bring_up(start_gnbid, end_gnbid, target_gNBid, target_gNBip, delay)
    local err = {}
    local result = {}
    local func_name = "start_Xn_link_up_for_multi_gnb"
    local end_id = end_gnbid
    
    if target_gNBid ~= 0 or target_gNBid ~= NULL then
        if target_gNBid <= end_gnbid and target_gNBid >= start_gnbid then
 	    end_id = end_gnbid + 1
        end
    end

    for id=start_gnbid, end_id do
        print('GNB id: '..id..' Xn Link')
        if id == target_gNBid then
	    goto label2
        end
        exec('xn_gnb_link_up gnb='..id..' target='..target_gNBid..' xn_link_addr='..target_gNBip)
        sleep (delay)
        ::label2::
    end
    print('All SIM-GNBs XN Link up successfully')
    sleep (10)
    exec('sim_state_disp')
end
]]--
