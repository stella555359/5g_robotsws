require "hw_var"
--require "hw_var_270"
require "multi_ue_sa_script_v5"
require "wrapper"
require "PET_SE_CFG"
------------------------------------------------------------------------------------------------------------------------------------
function run_tau_update_ics_off(rate,seconds)
exec('uec_l2_testmode_params fixed_csi_report=true')
for i = AMF_REGION_ID1,AMF_REGION_ID5 do
exec('amf_registration_param id='..i..' include_mobility_reg_acc_with_ics=off release_ue_tau_update=on')
sleep(0.2)
end
for seq_id = 55,62 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..seconds)
sleep(0.66)
end
sleep(seconds)
end
-------------------------------------------------------------------------------------------------------------------------------------------
function run_RNA_update(rate,seconds)
LAST_RNA_UPDATE_UE_SA = LAST_RNA_UPDATE_UE_SA - 1
 --beam_profile_creation_and_UEs_association(FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA - 1,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
   set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA,PLMN)
    sleep (5)
    exec('amf_ue_ics_param id=1-5 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id='..PLMN..' tac_id='..TAC..' ue='..FIRST_RNA_UPDATE_UE_SA..'-'..LAST_RNA_UPDATE_UE_SA + 1)
    sleep (1)
  exec('filter_sim_rfm disable=all')
       sleep(0.1)
     exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
       exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
    for seq_id = 79,86 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..seconds)
    sleep(0.5)
    end
    sleep(seconds)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function run_UE_ST_IDLE_CONNECTED(rate,seconds)
--beam_profile_creation_and_UEs_association(FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
    set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA,PLMN)
    sleep(13)
exec('filter_sim_rfm disable=all')
    sleep(0.1)
exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
       exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
   for seq_id = 71,78 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..seconds)
    sleep(0.5)
    end
   sleep(seconds)
end
-------------------------------------------------------------------------------------------------------------------------------------------------
function run_PAGING(rate,seconds)
--beam_profile_creation_and_UEs_association(FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
    exec('amf_paging_param id=1-5 default_drx=256 max_paging_retries=1')
    sleep(0.1)
    set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA,PLMN)
    sleep(13)
exec('filter_sim_rfm disable=all')
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
    for seq_id = 63,70 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..seconds)
    sleep(0.5)
    end
    sleep(seconds)
end
------------------------------------------------------------------------------------------------------------------------------------------------------
function run_ApD_Inter_gNB_HO(rt1,rt2,duration)
-- beam_profile_creation_and_UEs_association(FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTER_gNB_INTER_FREQ_HO_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
   addition_of_uehistory_info_sa_handover(FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTER_gNB_INTER_FREQ_HO_UE_SA,PLMN,2)
   sleep(13)
  exec('filter_sim_rfm disable=all')
       sleep(0.1)
     exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
      sleep(0.1)
    for seq_id = 7,12 do
       exec('seq_start rate='..rt1..' id='..seq_id..' detailed_print=on  duration='..duration)
       sleep(0.92)
    end
    for seq_id = 13,18 do
    exec('seq_start rate='..rt2..' id='..seq_id..' detailed_print=on  duration='..duration)
    sleep(3)
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function run_ApD_Intra_gNB_HO(rt1,rt2,duration)
-- beam_profile_creation_and_UEs_association(FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,6,6)
    set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,PLMN)
    sleep(5)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
  exec('filter_sim_rfm disable=all')
       sleep(0.1)
     exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
      sleep(0.1)
    for seq_id = 1,3 do
        exec('seq_start rate='..rt1..' id='..seq_id..' detailed_print=on duration='..duration)
      sleep(0.5)
    end
    for seq_id = 4,6 do
exec('seq_start rate='..rt2..' id='..seq_id..'  detailed_print=on duration='..duration)
    sleep(0.55)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------

function run_ApD_CA(rt1,rt2,duration)
 --beam_profile_creation_and_UEs_association(FIRST_CA_SCELL_ADD_UE_SA,LAST_CA_SCELL_ADD_DEL_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
   print('..AMF_REGION_ID1..','..AMF_REGION_ID5..')
   set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_CA_SCELL_ADD_UE_SA,LAST_CA_SCELL_ADD_DEL_UE_SA,PLMN)
   sleep(8)
   exec('filter_sim_rfm disable=all')
       sleep(0.1)
       exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
exec('sim_param_set disable_events_on_telnet_session=yes')
      sleep(0.1)
    for seq_id = 19,24 do
       exec('seq_start rate='..rt1..' id='..seq_id..' detailed_print=on duration='..duration)
       sleep(0.5)
	 end
	 for seq_id = 25,30 do
       exec('seq_start rate='..rt2..' id='..seq_id..' detailed_print=on duration='..duration)
       sleep(8.5)  
	 end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function run_ApD_ADD_DRB(rate,duration)
--beam_profile_creation_and_UEs_association(FIRST_ADITIONAL_DRB_ADD_UE_SA,LAST_ADITIONAL_DRB_ADD_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
   set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ADITIONAL_DRB_ADD_UE_SA,LAST_ADITIONAL_DRB_ADD_UE_SA,PLMN)
   sleep (5)
    exec('filter_sim_rfm disable=all')
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
	for seq_id = 31,38 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..duration)
    sleep(0.55)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
function run_ApD(rate,duration)
 --   beam_profile_creation_and_UEs_association(FIRST_ATTACH_DETACH_UE_SA,LAST_ATTACH_DETACH_UE_SA,6,6)
   -- sleep(5)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
   set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ATTACH_DETACH_UE_SA,LAST_ATTACH_DETACH_UE_SA,PLMN)
   sleep (5)
  exec('filter_sim_rfm disable=all')
       sleep(0.1)
     exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
for seq_id = 47,54 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..duration)
sleep(1)
end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function run_vonr(rate,duration)
--beam_profile_creation_and_UEs_association(FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA,6,6)
    exec('uec_l2_testmode_params fixed_csi_report=true')
    sleep(0.1)
    set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_VONR_DRB_ADD_UE_SA,LAST_VONR_DRB_ADD_UE_SA,PLMN)
    sleep(8)
exec('filter_sim_rfm disable=all')
    exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
       sleep(0.1)
     exec('sim_param_set disable_events_on_telnet_session=yes')
    sleep(0.1)
	for seq_id = 39,46 do
exec('seq_start rate='..rate..' id='..seq_id..' detailed_print=on duration='..duration)
    sleep(1.5)
    end	
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
function run_vtm_270(duration)
    -- Delay before starting the script
    --sleep(initial_delay)

    -- Run the functions with the specified duration
    run_tau_update_ics_off(0.1875,22)
    sleep(0.1)

    run_RNA_update(1.02,305)
    sleep(0.1)

    run_UE_ST_IDLE_CONNECTED(1.545, 70)
    sleep(0.1)

    run_PAGING(2.25, 50)
    sleep(0.1)

    run_ApD_Inter_gNB_HO(0.18, 0.055, duration)
    sleep(0.1)

    run_ApD_Intra_gNB_HO(1.3, 0.3, duration)
    sleep(0.1) 

    run_ApD_CA(1.3, 6, duration) 
    sleep(0.1)

    run_ApD_ADD_DRB(0.225, duration)
    sleep(0.1)

    run_vonr(0.0825, duration)
    runtime = duration + 900
    stats_collection(1,86,runtime)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vtm_270_real_paging(rt1,drn1,rt2,drn2,rt3,drn3,rt4,drn4,rt5,drn5,rt6,rt7,rt8,rt9,rt10,rt11,rt12,guami_per_ue)
exec('amf_ue_ics_param id=1-5 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id='..PLMN..' tac_id='..TAC..' ue='..FIRST_RNA_UPDATE_UE_SA..'-'..LAST_RNA_UPDATE_UE_SA)
sleep(0.1)
exec('amf_paging_param id=1-5 default_drx=256 max_paging_retries=1')
sleep(0.1)
addition_of_uehistory_info_sa_handover(FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTER_gNB_INTER_FREQ_HO_UE_SA,PLMN,2)
sleep(0.1)
for i = AMF_REGION_ID1,AMF_REGION_ID5 do
exec('amf_registration_param id='..i..' include_mobility_reg_acc_with_ics=off release_ue_tau_update=on')
sleep(0.2)
end
if guami_per_ue == yes then
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA,PLMN)
sleep(0.2)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_VONR_DRB_ADD_UE_SA,LAST_VONR_DRB_ADD_UE_SA,PLMN)
sleep(0.2)
set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ADITIONAL_DRB_ADD_UE_SA,LAST_ADITIONAL_DRB_ADD_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_CA_SCELL_ADD_UE_SA,LAST_CA_SCELL_ADD_DEL_UE_SA,PLMN)
sleep(0.1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ATTACH_DETACH_UE_SA,LAST_ATTACH_DETACH_UE_SA,PLMN)
sleep(0.1)
end
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(0.1)
exec('filter_sim_rfm disable=all')
sleep(0.1)
exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
sleep(0.1)
exec('sim_param_set disable_events_on_telnet_session=yes')

---RNA--- 
exec('seq_start rate='..rt7..' duration='..drn5..' id=39 detailed_print=on')--vonr1
for seq_id = 79,86 do
exec('seq_start rate='..rt1..' duration='..drn1..' id='..seq_id..'  detailed_print=on')
sleep(15.125)
end
-----TAU
exec('seq_start rate='..rt7..' duration='..drn5..' id=40 detailed_print=on')--vonr2
for seq_id = 55,62 do
exec('seq_start rate='..rt2..' duration='..drn2..' id='..seq_id..'  detailed_print=on')
sleep(15.66)
end
-----UE ST
exec('seq_start rate='..rt7..' duration='..drn5..' id=41 detailed_print=on')--vonr3
for seq_id = 71,78 do
exec('seq_start rate='..rt3..' duration='..drn3..' id='..seq_id..'  detailed_print=on')
sleep(15.08)
end
-----PAGING
exec('seq_start rate='..rt7..' duration='..drn5..' id=42 detailed_print=on')--vonr4
exec('seq_start rate='..rt12..' duration='..drn5..' id=25  detailed_print=on')--CA ADD only group1
for seq_id = 63,70 do
exec('seq_start rate='..rt4..' duration='..drn4..' id='..seq_id..'  detailed_print=on')
sleep(15.055)
end
-----Inter-gNB-HO
exec('seq_start rate='..rt7..' duration='..drn5..' id=43 detailed_print=on')--vonr5
exec('seq_start rate='..rt12..' duration='..drn5..' id=26  detailed_print=on')--CA ADD only group2
for seq_id = 13,18 do
exec('seq_start rate='..rt5..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(16)
end
exec('seq_start rate='..rt7..' duration='..drn5..' id=44 detailed_print=on')--vonr6
exec('seq_start rate='..rt12..' duration='..drn5..' id=27  detailed_print=on')---CA ADD only group3
for seq_id = 7,12 do
exec('seq_start rate='..rt6..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(14.992)
end
-----Add DRB
exec('seq_start rate='..rt7..' duration='..drn5..' id=45 detailed_print=on')--vonr7
exec('seq_start rate='..rt12..' duration='..drn5..' id=28  detailed_print=on')---CA ADD only group4
for seq_id = 31,38 do
exec('seq_start rate='..rt8..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.55)
end
----Intra gNB HO
exec('seq_start rate='..rt7..' duration='..drn5..' id=46 detailed_print=on')--vonr8
exec('seq_start rate='..rt12..' duration='..drn5..' id=29 detailed_print=on')---CA Add only group5
for seq_id = 4,6 do
exec('seq_start rate='..rt9..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.256)
end
exec('seq_start rate='..rt12..' duration='..drn5..' id=30 detailed_print=on')---CA Add only group6
for seq_id = 1,3 do
exec('seq_start rate='..rt10..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.256)
end
----CA ADD DEL
for seq_id = 19,24 do
exec('seq_start rate='..rt11..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.130)
end
----CA ADD only
--[[for seq_id = 25,30 do
exec('seq_start rate='..rt12..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(13.03)
end]]--
end
--vtm_270_real_paging(1.02,305,0.1875,22,1.545,70,2.25,50,0.055,9000,0.18,0.0825,0.225,0.3,1.3,1.3,6,yes)

function stats_collection(start_id, end_id,runtime)
     sleep(runtime)
   exec('filter_rfm_sim enable=all')
exec('sim_param_set disable_events_on_telnet_session=no')
    for i = start_id, end_id do
        exec('seq_stats id=' .. i)  -- Executes the command with the current ID
        sleep(1)  -- Pauses for 1 second before the next iteration
    end
   exec('ue_disp state=ACTIVE')
   exec('ue_disp state=IDLE')
   exec('ue_disp state=UE_INACTIVE')
   exec('sim_log_set flush')
end

function vtm_375(rt1,drn1,rt2,drn2,rt3,drn3,rt4,drn4,rt5,drn5,rt6,rt7,rt8,rt9,rt10,rt11,rt12,rt13,guami_per_ue)
sleep(0.1)
addition_of_uehistory_info_sa_handover(FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTER_gNB_INTER_FREQ_HO_UE_SA,PLMN,2)
sleep(0.1)
for i = AMF_REGION_ID1,AMF_REGION_ID5 do
exec('amf_registration_param id='..i..' include_mobility_reg_acc_with_ics=off release_ue_tau_update=on')
sleep(0.2)
end
if RNA_UPDATE ~= 'T380' and  UE_STATE_TRANSITION == '8225' then
set_rrc_resume_req_cause (FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA,"rna_Update")
sleep(1)
set_rrc_resume_req_cause(FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA,"mo_Data")
sleep(1)
exec('amf_ue_ics_param id=1-5 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id='..PLMN..' tac_id='..TAC..' ue='..FIRST_STATE_TRASITION_UE_SA..'-'..LAST_RNA_UPDATE_UE_SA)
else 
set_rrc_resume_req_cause (FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA,"rna_Update")
sleep(1)
exec('amf_ue_ics_param id=1-5 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id='..PLMN..' tac_id='..TAC..' ue='..FIRST_RNA_UPDATE_UE_SA..'-'..LAST_RNA_UPDATE_UE_SA)
end
if guami_per_ue  then
set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA,PLMN)
sleep(2)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_VONR_DRB_ADD_UE_SA,LAST_VONR_DRB_ADD_UE_SA,PLMN)
sleep(2)
set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA,PLMN)
sleep(1)
set_guami_per_ue_random_tmsi(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA,PLMN)
sleep(1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ADITIONAL_DRB_ADD_UE_SA,LAST_ADITIONAL_DRB_ADD_UE_SA,PLMN)
sleep(1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,PLMN)
sleep(1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA,PLMN)
sleep(1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_CA_SCELL_ADD_UE_SA,LAST_CA_SCELL_ADD_DEL_UE_SA,PLMN)
sleep(1)
set_guami_per_ue(AMF_REGION_ID1,AMF_REGION_ID5,AMF_SET_ID1,AMF_POINTER_ID1,FIRST_ATTACH_DETACH_UE_SA,LAST_ATTACH_DETACH_UE_SA,PLMN)
sleep(1)
end

exec('sim_log_set log_to_file=off')
sleep(1)
exec('sim_log_set log_to_file=on')
-----
exec('uec_l2_testmode_params fixed_csi_report=true')
sleep(0.1)
exec('filter_sim_rfm disable=all')
sleep(0.1)
exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
sleep(0.1)
exec('sim_param_set disable_events_on_telnet_session=yes')
sleep(initial_delay)
-----PAGING
exec('seq_start rate='..rt7..' duration='..drn5..' id=42 detailed_print=on')--vonr4
for seq_id = 63,70 do
exec('seq_start rate='..rt4..' duration='..drn4..' id='..seq_id..'  detailed_print=on')
sleep(18.055)
end

if NG_PAGING == 'FAKE' then
exec('seq_start rate=1 duration=1 id=87  detailed_print=on')
end
---RNA--
exec('seq_start rate='..rt7..' duration='..drn5..' id=39 detailed_print=on')--vonr1
for seq_id = 79,86 do
exec('seq_start rate='..rt1..' duration='..drn1..' id='..seq_id..'  detailed_print=on')
sleep(18.125)
end
-----TAU
exec('seq_start rate='..rt7..' duration='..drn5..' id=40 detailed_print=on')--vonr2
for seq_id = 55,62 do
exec('seq_start rate='..rt2..' duration='..drn2..' id='..seq_id..'  detailed_print=on')
sleep(15.66)
end
-----UE ST
exec('seq_start rate='..rt7..' duration='..drn5..' id=41 detailed_print=on')--vonr3
for seq_id = 71,78 do
exec('seq_start rate='..rt3..' duration='..drn3..' id='..seq_id..'  detailed_print=on')
sleep(18.08)
end
-----Inter-gNB-HO
exec('seq_start rate='..rt7..' duration='..drn5..' id=43 detailed_print=on')--vonr5
exec('seq_start rate='..rt12..' duration='..drn5..' id=25  detailed_print=on')--CA ADD only group1
for seq_id = 13,18 do
exec('seq_start rate='..rt5..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(16)
end
exec('seq_start rate='..rt7..' duration='..drn5..' id=44 detailed_print=on')--vonr6
exec('seq_start rate='..rt12..' duration='..drn5..' id=26  detailed_print=on')---CA ADD only group2
for seq_id = 7,12 do
exec('seq_start rate='..rt6..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(14.992)
end
-----Add DRB
exec('seq_start rate='..rt7..' duration='..drn5..' id=45 detailed_print=on')--vonr7
exec('seq_start rate='..rt12..' duration='..drn5..' id=27  detailed_print=on')---CA ADD only group3
for seq_id = 31,38 do
exec('seq_start rate='..rt8..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.55)
end
----Intra gNB HO
exec('seq_start rate='..rt7..' duration='..drn5..' id=46 detailed_print=on')--vonr8
exec('seq_start rate='..rt12..' duration='..drn5..' id=28 detailed_print=on')---CA Add only group4
for seq_id = 4,6 do
exec('seq_start rate='..rt9..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(15.256)
end
exec('seq_start rate='..rt12..' duration='..drn5..' id=29 detailed_print=on')---CA Add only group5
for seq_id = 1,3 do
exec('seq_start rate='..rt10..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(18.256)
end
exec('seq_start rate='..rt12..' duration='..drn5..' id=30 detailed_print=on')---CA Add only group6
----CA ADD DEL
for seq_id = 19,24 do
exec('seq_start rate='..rt11..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(18.130)
end
----Attach_detach
for seq_id = 47,54 do
exec('seq_start rate='..rt13..' duration='..drn5..' id='..seq_id..'  detailed_print=on')
sleep(18.130)
end
end


--function vtm_2250()
--    require "hw_var"
--    local duration
--    if VTM_RUN_DURATION == '2Hrs' then
--        duration = 9000
--    elseif VTM_RUN_DURATION == '4Hrs' then
--        duration = 18000
--    else
--        return -- Exit if duration is not valid
--    end

--    vtm_375(1.27, 320, 0.2, 22, 1.91, 35, 2.25, 110, 0.055, duration, 0.236, 0.082, 0.27, 0.4, 1.4, 1.52, 7.4, 1.65, true)
--      vtm_375(1.27, 250, 0.2, 22, 1.91, 36, 2.25, 140, 0.055, duration, 0.236, 0.082, 0.27, 0.4, 1.4, 1.52, 7.4, 1.65, true)
--end


function vtm_2250()
    require "hw_var"
    local duration
    if VTM_RUN_DURATION == '2Hrs' then
        duration = 9000
    elseif VTM_RUN_DURATION == '4Hrs' then
        duration = 18000
    else
        return -- Exit if duration is not valid
    end

--    vtm_375(1.27, 320, 0.2, 22, 1.91, 35, 2.25, 110, 0.055, duration, 0.236, 0.082, 0.27, 0.4, 1.4, 1.52, 7.4, 1.65, true)
      vtm_375(1.27, 250, 0.2, 22, 1.91, 36, 2.25, 140, 0.055, duration, 0.236, 0.082, 0.27, 0.4, 1.4, 1.52, 7.4, 1.65, true)
	  exec('filter_sim_rfm enable=all')
	   sleep(600)
	   print("vtm_2250 script completed")
	   sleep(10)
	   exec('filter_sim_rfm disable=all')
	   exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
	   sleep(0.1)
end



--vtm_300(1.02,305,0.1875,22,1.545,70,2.25,50,0.055,9000,0.18,0.0825,0.225,0.3,1.3,1.3,6,0.9375,yes)

--vtm_375
-- CA ADD_only ----7.4 (6 groups)
---CA ADD DEL -----1.52 (6 groups)
---ATTACH_DETACH ----1.65 (8 groups)
---paging  89 paging per AP and 89/5=18 paging/sec
--Intr_freq Intra gNB HO---1.44 (6 groups)
--Inter-Freq Intra gNB HO---0.47 (6 groups)
--Intra freq inter gNB----0.36 (6 groups)
--Inter freq Inter gNB ---No diff
--TAU update -----0.2083 ---8 groups
---RNA update ----1.27   ---8 groups
---UE state trasition --1.916 8 groups
---VonR -----0.128    8 groups
---ADD DRB ---0.27 8 groups
