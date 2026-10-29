*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...              :authors: Akhil
...              :contact: akhil.k_p@nokia.com
...              :Requirement ID: 5G_RAN_USR_RRM_26070
...              :Description:This test case validates the interaction with RRC Inactive State transitions under same gNB (SA mode)
...               and verifies that during the RRC Resume, the stored default S-NSSAI shall be used and no need to do the switch again

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../resources/robot/wts_sim_keywords.robot
Resource         ./basic_resource.robot

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   300s    reason=wait for RMOD to comeup
...                 AND    Start wts application and load CFG      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib
#Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
#...                 AND     Find Scfc And Fix And Send Full Commissioning
#...                         scfc_filename=rrc_resume_scfc_gmc.xml
#...                 AND     sleep    180s
#...                 AND     gnb.Perform gNB reboot
#...                 AND     sleep    180s
#...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
#...                 AND     Sleep    60s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
Test Setup       Start_capture_testcase_default_logging
Test Teardown    Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/rrc_res_slice_basic_setup_3PLMN.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${SCFC}=              ${CURDIR}/config/SBTS25R1/rrc_resume_scfc.xml
${AP_XML}=            ${CURDIR}/config/new_iphy_rrc_resume.xml
${epc_log_path}    /tmp/
${Ho_success}     rrcReconfigurationComplete
*** Test Cases ***
[1]CB013052-A_B13_TC13_Interaction_with_RRC_Inactive_State_transitions_under_same_gNB
    [Documentation]   This scenario verifies rrc resume procedure after the slice switch for 3 UEs pdu sessions
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts

#UE1
    set amf paramter    1     311:489
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    1    1    pdu_id=1    nw_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 2 pdu session with supported slice id for ue1 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue1

#UE2
    set amf paramter    2     311:490
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    2    2    pdu_id=1    nw_id=2
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 3 pdu session with unsupported slice id for ue2 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue2

#UE3
    set amf paramter    3     311:491
    wts_sim_keywords.MultiUE Register should be Successful And Fetch RNTI with RAT1    3    3    pdu_id=1    nw_id=3
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5      pdu_id=1    trf_id=1       qfi_id=1
    Start Log     cprt
    setup 1 pdu session with supported and 4 with unsupported slice id for ue3 and send data
    ${path1}    Stop Log      cprt      test_scenario=pdu_ue3

    Stop traffic for all
    sleep      120s
    Start Log     cprt
    Trigger rrcresume dl      1
    Trigger rrcresume dl      2
    Trigger rrcresume dl      3
    ${path1}    Stop Log      cprt      test_scenario=resume_ue
    Trigger traffic for all bearers
    sleep       300s
    Wait until the current Measurement Period stops
    Verify 13052 counters


*** Keywords ***
Trigger traffic for all bearers
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=1    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=6    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=6    trf_id=1       qfi_id=1

Verify 13052 counters
     ${Counter_fallback}    Create Dictionary     ${SLICE_FALLBACK_SUC}=${7}
    ${Counter_fallback_pmqap1}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_ho_pmqap1}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_pmqap2}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${3}
    ${Counter_fallback_ho_pmqap2}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counter_fallback_pmqap3}    Create Dictionary     ${NG_FLOW_STP_SUC_SLI_FBK_PMQAP}=${4}
    ${Counter_fallback_ho_pmqap3}    Create Dictionary     ${NG_FLOW_I_HO_SUC_SLI_FBK_PMQAP}=${0}
    ${Counters_resume_att}    Create Dictionary     ${NRRCC_RRC_RESUME_REQUEST1}=${3}
    ${Counters_resume_succ}    Create Dictionary     ${NRRCC_RRC_RESUME_SUCC}=${3}
    Verify Counters modi   ${Counter_fallback}    NRCELL-3
    Verify Counters modi   ${Counter_fallback_pmqap1}    NRCELL-3/PLMN-PLMN/NRPMQAP-1
    Verify Counters modi   ${Counter_fallback_ho_pmqap1}    NRCELL-3/PLMN-PLMN/NRPMQAP-1
    Verify Counters modi   ${Counter_fallback_pmqap2}    NRCELL-3/PLMN-PLMN/NRPMQAP-2
    Verify Counters modi   ${Counter_fallback_ho_pmqap2}    NRCELL-3/PLMN-PLMN/NRPMQAP-2
    Verify Counters modi   ${Counter_fallback_pmqap3}    NRCELL-3/PLMN-PLMN/NRPMQAP-3
    Verify Counters modi   ${Counter_fallback_ho_pmqap3}    NRCELL-3/PLMN-PLMN/NRPMQAP-3
    Verify Counters modi   ${Counters_resume_att}    NRCELL-3
    Verify Counters modi   ${Counters_resume_succ}    NRCELL-3
set amf paramter
    [Arguments]     ${ue_id}    ${plmn}
    ${amf_param1}	SET VARIABLE	amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64
    ${amf_param2}	SET VARIABLE	periodic_registration_update_timer=5:1min plmn_id=${plmn} tac_id=200
    ute_wtssim.execute_egate_command        ${amf_param1} ${amf_param2}

Trigger rrcresume
    FOR     ${ue_id}   IN RANGE    1    4
    ute_wtssim.execute_egate_command    cmd=qfi_stats_clear ue=${ue_id} pdu=1
    sleep      1s
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_resume_request_param id=${ue_id} cause=mo_Data
    sleep      1s
    ute_wtssim.execute_egate_command    cmd=ue_nr_rrc_resume id=${ue_id}
    END

Trigger rrcresume dl
    [Arguments]     ${ue_id}
    ute_wtssim.execute_egate_command    cmd=qfi_stats_clear ue=${ue_id} pdu=1
    sleep      1s
    ute_wtssim.execute_egate_command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
    sleep      1s

Stop traffic for all

    ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=1 pdu=1
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=1 pdu=2
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=1 pdu=3
     sleep      1s
     ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=2 pdu=1
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=2 pdu=2
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=2 pdu=3
     sleep      1s
     ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=2 pdu=4
     sleep      1s
        ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=1
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=2
     sleep      1s
     ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=3
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=4
     sleep      1s
      ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=5
     sleep      1s
     ute_wtssim.execute_egate_command    cmd=trf_data_stop ue=3 pdu=6


setup 2 pdu session with supported slice id for ue1 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=4 ue=1 nwslice=1
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=1 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=5 ue=1 nwslice=1
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    1    1    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    1    1    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
setup 3 pdu session with unsupported slice id for ue2 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
     ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=6 ue=2 nwslice=15
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=7 ue=2 nwslice=15
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=2 pdu=4 trf_type=internal
      ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=8 ue=2 nwslice=15
    ${output3}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    2    2    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    2    2    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
setup 1 pdu session with supported and 4 with unsupported slice id for ue3 and send data
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=2 trf_type=internal
    ${pdu_setup_cmd1}	SET VARIABLE	ue_pdu_session_setup pdu=2 gw=9 ue=3 nwslice=16
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd1}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    ${pdu_setup_cmd2}	SET VARIABLE	ue_pdu_session_setup pdu=3 gw=10 ue=3 nwslice=16
    ${output2}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd2}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=4 trf_type=internal
    ${pdu_setup_cmd3}	SET VARIABLE	ue_pdu_session_setup pdu=4 gw=11 ue=3 nwslice=16
    ${output3}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd3}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=5 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=5 gw=12 ue=3 nwslice=16
    ${output4}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
	sleep   1s
    ute_wtssim.execute_egate_command    cmd=set_pdu_param ue=3 pdu=6 trf_type=internal
    ${pdu_setup_cmd4}	SET VARIABLE	ue_pdu_session_setup pdu=6 gw=14 ue=3 nwslice=6
    ${output4}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd4}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=10s
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=2    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=3    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=4    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=5    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=5     pdu_id=6    trf_id=1       qfi_id=1
    wts_sim_keywords.MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=5     pdu_id=6    trf_id=1       qfi_id=1


Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3
