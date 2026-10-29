*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    CONFIGURED
...           RAN_5G_TDD    RAN_5G    SBTS00

Resource     resources/8608_keywords.robot
Resource     resources/main_vran.robot
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../CB008697/CB008697_variables.robot
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../resources/Python/webem_alarms.py
Library      resources/commissioning_vran.py
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_admin_operations
Library      ta5g_ue_mobility
Library     ../CB008697/CB008697_keywords.py
Library      resources/counters_vdu.py
Library     ../CB008367/CB008367-C.py
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    l2stream3
Library     taf.collectors.core             WITH NAME    core
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Library    taf.ccs.aashell   WITH NAME    aashell
Library      resources/CB008985_keywords.py
Resource     ../resources/configuration_id.robot


Suite Setup    Run Keywords    Enable Cloud
...            AND             Update And Put Iphy Xml Aic
...                               input_filepath=${CURDIR}/config/iphy_8985_AZQJ.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Call Ap Console Reboot
...            AND             Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
...                               scfc_filepath=${CURDIR}/config/default/scf_8985_vdu.xml
...                               output_dirpath=${OUTPUT_DIR}
...            AND             Perform Commissioning Vcu Aic
...                               path_to_plan_file=${CURDIR}/config/default/scf_8985_vcu.xml
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}
...            AND             Check Radios Availability Aic
...                               timeout=300
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Reach Onair Aic
...                            check_edaemon_port=${True}
...                            lua_cfg=${CURDIR}/config/8985_n78.cfg

Suite Teardown   Stop Default Processes And Gather Logs And Compress Logs

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
#    [Teardown]    Send Configuration ID To Scout

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
    ...    cmd=ue_testmode_set_nr id=11 testmode=beam_control action=activate profile_id=2 beamaction=attach scell=1

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
	Sleep   10s

Attach SA UE And Establish PDU Session
    ta5g_ue_mobility.Attach Ue    ue_id=1
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
    Verify Tput For UE NSA    ue_id=11    cc=1    dir=dl    unit=Mbps    expected_tput=90
    Verify Tput For UE NSA    ue_id=11    cc=1    dir=ul    unit=Mbps    expected_tput=40

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
    Verify Tput For UE SA   ue_id=${ue_id}    dir=ul    expected_tput=40

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${max_tput} > ${expected_tput}

Trigger Beam Failure UE NSA
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=11 testmode=beam_control action=activate profile_id=1 beamaction=recovery scell=1
    Sleep   5s

Trigger Beam Failure UE SA
    Execute Egate command
    ...    cmd=ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=2 beamaction=recovery scell=0
    Sleep   5s

Check Beam Recoveries Counters UE SA
    Wait For Next Pm Counter Interval Aic
    Collect_coam_vdu_pm_counters

    Find Counter In Dir
    ...  counter_id=M55305C10001
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

    Find Counter In Dir
    ...  counter_id=M55305C09001
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

Check Beam Recoveries Counters UE NSA
    Wait For Next Pm Counter Interval Aic
    Collect_coam_vdu_pm_counters

    Find Counter In Dir
    ...  counter_id=M55305C10002
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

    Find Counter In Dir
    ...  counter_id=M55305C09002
    ...  value=1
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

Check serving subcell/beam counters NSA
    Find Counter In Dir And Verify If Its Bigger Than Given Value
    ...  counter_id=${DL_SERV_BEAM_ID_BEAM_0_PM}
    ...  value=0
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

    Find Counter In Dir And Verify If Its Bigger Than Given Value
    ...  counter_id=${UL_SERV_BEAM_ID_BEAM_0_PM}
    ...  value=0
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

Check serving subcell/beam counters SA
    Find Counter In Dir And Verify If Its Bigger Than Given Value
    ...  counter_id=${DL_SERV_BEAM_ID_BEAM_1_PM}
    ...  value=0
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

    Find Counter In Dir And Verify If Its Bigger Than Given Value
    ...  counter_id=${UL_SERV_BEAM_ID_BEAM_1_PM}
    ...  value=0
    ...  dir_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pm_counters/
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
