*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_O_H_AP_LOO   SBTS00    CRT    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      CB008985_keywords.py
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library    ta5g_egate
Library    ta5g_ue_mobility
Library    ta5g_pm_counters
Library    ta5g_setups_and_teardowns
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AZQI_8985_2_A4A7.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008985_A7_1SC_2SB_1070_100M_2x2_ASOH.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_SA.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${EGATE_CONSOLE_LOG}       /opt/iphy/latest/egate_console.log
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

#serving subcell counters
${DL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C00001
${UL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C01001

${DL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C00002
${UL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C01002

*** Test Cases ***
CB008985-A_A7_FR1_TDD_subcell_tracking-switch_failure_and_recovery_NSA_SA_multi_UE
    Wait For Next Full Pm Interval
    Setup X2 Link
    Set Beams and Activate Beam Control Testmode
    Set Internal Traffic Type To UE
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic NSA
    Sleep    20s
    Trigger Beam Failure UE NSA
    Verify DL and UL Tput UE NSA After Subcell Recovery
    Check Beam Recoveries Counters UE NSA
    Check serving subcell/beam counters NSA

    Attach SA UE And Establish PDU Session
    Start DL and UL Data Traffic
	Sleep    20s
    Trigger Beam Failure UE SA
	Verify DL and UL Tput UE SA After Subcell Recovery  ue_id=1
    Check Beam Recoveries Counters UE SA
    Sleep    30s
    Check serving subcell/beam counters SA

    Stop All Data Transfers And Detach UE SA
    Stop All Data Transfers And Detach UE NSA
    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Set Beams and Activate Beam Control Testmode
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
    Execute egate command
    ...    cmd=beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125

    Execute egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=3 beamaction=attach scell=0
    Execute egate command
    ...    cmd=ue_testmode_set_nr id=11 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=8

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
	Sleep   10s

Attach SA UE And Establish PDU Session
    Attach Ue    ue_id=1
	Sleep   10s
    Execute Egate Command   cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    Sleep   20s

Start DL and UL Data Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=20
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Start DL and UL Data Traffic NSA
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=50
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=20
    Sleep    5s

Increase Traffic UE NSA
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=50 trf_id=2
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=20 trf_id=2
    Sleep    5s

Verify DL and UL Tput UE NSA After Subcell Recovery
    Increase Traffic UE NSA
    Verify Tput For UE NSA    ue_id=11    cc=8    dir=dl    unit=Mbps    expected_tput=90
    Verify Tput For UE NSA    ue_id=11    cc=8    dir=ul    unit=Mbps    expected_tput=35

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${cc}    ${dir}    ${unit}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    direction=${dir}    unit=${unit}
    Should Be True    ${max_tput} > ${expected_tput}

Increase Traffic UE SA
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50 trf_id=2
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=20 trf_id=2
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:2
    Sleep    10s

Verify DL and UL Tput SA
    [Arguments]    ${ue_id}
    Verify Tput For UE SA   ue_id=${ue_id}    dir=dl    expected_tput=47.5
    Verify Tput For UE SA   ue_id=${ue_id}    dir=ul    expected_tput=20

Verify DL and UL Tput UE SA After Subcell Recovery
    [Arguments]    ${ue_id}
    Increase Traffic UE SA
    Verify Tput For UE SA   ue_id=${ue_id}    dir=dl    expected_tput=90
    Verify Tput For UE SA   ue_id=${ue_id}    dir=ul    expected_tput=35

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${max_tput} > ${expected_tput}

Trigger Beam Failure UE NSA
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=11 testmode=beam_control action=activate profile_id=1 beamaction=recovery scell=8
    Sleep   5s

Trigger Beam Failure UE SA
    Execute Egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=2 beamaction=recovery scell=0
    Sleep   5s

Check Beam Recoveries Counters UE SA
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55305C10001
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55305C09001
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Check Beam Recoveries Counters UE NSA
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
	Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55305C10002
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=M55305C09002
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS}

Check serving subcell/beam counters NSA
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SERV_BEAM_ID_BEAM_0_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${UL_SERV_BEAM_ID_BEAM_0_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Check serving subcell/beam counters SA
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SERV_BEAM_ID_BEAM_1_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${UL_SERV_BEAM_ID_BEAM_1_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11


