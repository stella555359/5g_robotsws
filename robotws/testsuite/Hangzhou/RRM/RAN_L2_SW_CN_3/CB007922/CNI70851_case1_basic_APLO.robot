*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown  Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot
Resource    ../resources/sg10/internal_resource/internal_capture_log.robot
Documentation
...   add counter Number of UEs per beam - Beam ID

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID1}          1
${UE_ID2}          2
${UE_ID_NSA1}          12
${SCFC_NAME}     70851_CASE01_SCFC_LO_AP_LO_8DL4UL_bbpool.xml
${AIRPHONE_NAME}    IPHY_AEQE_2CELL_LO_AP_LO.xml
${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_2Cell.cfg
@{LOG_NAME_LIST}    gnb_snapshot
${EGATE_TAG_1}      CA_before_block
${EGATE_TAG_2}      CA_after_block
${Block_Num}   1
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
${counter_V}    3000
${counter_V2}    2990
${counter_V3}    3010
${counter_V_2UE}    7200    #600
${FILTER}    uldata_puschreceivereq
${UE_NUM_SA}    1

*** Test Cases ***
CNI70851_case01_intraL2RT_NSA_5GC002200_DRX
    Prepare gNB
    run keyword and continue on failure    CA beam counter check times    1
    run keyword and continue on failure    attach 2UE '1' times

*** Keywords ***
Prepare gNB
#    Active GNB L2 feature debug traces
    Add RD
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/L2-PS    WRN/.uplane
    Set Test Variable    ${custom_error}
    Prepare gnb onair

Add RD
    Add GNB swconfig    0x58057a:0x4
    Add GNB swconfig    0x58057c:0x4000000
#    Add GNB swconfig    0x5806B1:1
#    Add GNB swconfig    0x5806B2:0xD8092EE9

CA beam counter check times
    [Arguments]    ${times_total}
    FOR    ${num_x}    IN RANGE    0    ${times_total}
       log to console    CA beam counter check times_${num_x}
       CA beam counter check
    END

Attach multi SA UE and check scelladdition
    Log To Console   \n-------------step2:Attach SA UE and check scelladdition---------------
#    Start capture only gnb syslog in 'step2' file
    FOR    ${num}    IN RANGE    1    1+${UE_NUM_SA}
        airphone_cleanup_egate_console_log
        ${gw_pdu_r}    evaluate    ${num}%10
#        Start collect f1ap    UE${num}_attach_f1ap
        Airphone SA Attach    ue_id=${num}
        Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
        Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
        Log To Console   attach UE${num} successfully
#        Stop collect f1ap    UE${num}_attach_f1ap
#        Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
        Collect AP egate log    ${num}_step2
        run keyword and continue on failure     Analyse scelladd in rrclog    ${num}_step2     RRC_scelladd_LO_AP_LO_cell52.ini
    END
#	run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'

SA send data UEs
    [Arguments]     ${start}
    log to console    push data for UEs
    FOR    ${num}    IN RANGE    ${start}    ${start}+${UE_NUM_SA}
       ${gw_pdu_r}    evaluate    ${num}%10
        SA send mutiple trf dl data    ${num}    16   175M   ${gw_pdu_r}    tcp
        SA send mutiple trf ul data    ${num}    1    175M   ${gw_pdu_r}
    END

Stop data transfer
    [Arguments]    ${UE_ID}
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl
#    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul

capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip


Verify fullbuffer CAUE throughput
    [Arguments]     ${CA_start}
    FOR    ${num}    IN RANGE    ${CA_start}    ${CA_start}+${UE_NUM_SA}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ScellTP_${dl_throughput_scell1}_ULTP_${ul_throughput_pcell}
    END

KPI bler check
     [Arguments]     ${PM_counter_file}    ${cell_id}=1
     ${NR_5055b_ini_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=${cell_id}
     ${NR_5054a_res_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=${cell_id}
     should be true    ${NR_5055b_ini_bler}<0.01
     should be true    ${NR_5055b_ini_bler}==0

CA beam counter check
    Start capture gnb and ap syslog in 'step2' file
    Attach multi SA UE and check scelladdition
    SA send data UEs    start=1
#    Verify fullbuffer CAUE throughput    CA_start=1
    run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=500000   Scell_TP=500000
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    run keyword and continue on failure    tti trace ACK check    scell_add_first_time    #debug
    KPI bler check    ${PM_counter_file}    cell_id=1
    KPI bler check    ${PM_counter_file}    cell_id=3
#    tti trace ACK check    scell_add_first_time    #debug
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'
    Start capture gnb and ap syslog in 'a2_release' file
    UE send A2 event    ${UE_ID1}
    run keyword and continue on failure    Check Scell release    scell_release_egate_log
    Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID1}    1250000
#    tti trace ACK check    scell_release
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'scell_release'
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} == 0
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'a2_release' file '${custom_error}'

    Start capture gnb and ap syslog in 'a1_scell_addBack' file
    UE send A1 event again    ${UE_ID1}
    Collect AP egate log    scell_add_again_rrc_logs
    Analyse scelladd in rrclog    scell_add_again_rrc_logs     RRC_scelladd_LO_AP_LO_cell52.ini
    run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=500000   Scell_TP=500000
#    tti trace ACK check    scell_add_again
#    Start collect bip log
#    Wait for '1s' to stop bip log with name'scell_add_again'
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    KPI bler check    ${PM_counter_file}    cell_id=3
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'a1_scell_addBack' file '${custom_error}'

    Start capture gnb and ap syslog in 'scell_deac' file
    Stop data transfer    ${UE_ID1}
    Check Scell deactive

#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_deactive'
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} == 0
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    tti trace ACK check    scell_deactive
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac' file '${custom_error}'

    Start capture gnb and ap syslog in 'scell_deac_activ_again' file
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
#    tti trace ACK check    scell_active_again
#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_active_again'
#    Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1000000     #Pcell_TP=1250000   Scell_TP=1100000

    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    KPI bler check    ${PM_counter_file}    cell_id=3
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac_activ_again' file '${custom_error}'
    Start capture gnb and ap syslog in 'scell_deac2' file
    Stop data transfer    ${UE_ID1}
    Check Scell deactive
#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_deactive'
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} == 0
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac2' file '${custom_error}'
    tti trace ACK check    scell_deactive
    capture snapshot start once    scell_deactive
    Start capture gnb and ap syslog in 'scell_deac_activ_again2' file
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
#    tti trace ACK check    scell_active_again
#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_active_again'
#    Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1000000     #Pcell_TP=1250000   Scell_TP=1100000
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    KPI bler check    ${PM_counter_file}    cell_id=3
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac_activ_again2' file '${custom_error}'

    Start capture gnb and ap syslog in 'scell_deac3' file
    Stop data transfer    ${UE_ID1}
    Check Scell deactive
#    tti trace ACK check    scell_deactive
#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_deactive'
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} == 0
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac3' file '${custom_error}'
    Start capture gnb and ap syslog in 'scell_deac_activ_again4' file
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
#    Start collect bip log
#    Wait for '2s' to stop bip log with name'scell_active_again'
    run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=500000   Scell_TP=500000
    ${PM_counter_file}    Get counter file
    Get TDD 2CC counters    ${PM_counter_file}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} >= ${counter_V2}
    run keyword and continue on failure    should be true  ${M55305C12009_scell} <= ${counter_V3}
    run keyword and continue on failure    should be true  ${M55305C12009_pcell} <= ${counter_V3}
    KPI bler check    ${PM_counter_file}    cell_id=1
    KPI bler check    ${PM_counter_file}    cell_id=3
#    Check throughput    ${UE_ID1}     Pcell_TP=1100000   Scell_TP=1000000     #Pcell_TP=1250000   Scell_TP=1100000
#    tti trace ACK check    scell_active_again
    Detach UE     ${UE_ID1}
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'scell_deac_activ_again4' file '${custom_error}'
#

attach 2UE '${NUM_attach}' times
    set '2' SA UEs beam
    FOR    ${num}    IN RANGE    0    ${NUM_attach}
        Start capture only gnb syslog in 'syslog_traffic_${num}times' file
        ${num_r}    evaluate    ${num}%4
        log to console    attach 2UE ${num} times
        Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
        Send ue '${UE_ID1}' A1 event
        SA send dl and ul data    ${UE_ID1}    number=10    dl_data=175M    ul_data=15M    pdu_id=1
        Attach SA UE    UE_ID=2     PDU_ID=2   SLICE_ID=1    GW_ID=1
        SA send dl and ul data    ${UE_ID2}    number=6    dl_data=175M    ul_data=15M    pdu_id=2
        Wait '5s' for stable
        Check throughput    ${UE_ID1}     Pcell_TP=100000   Scell_TP=100000
        Check nonCA throughput    ${UE_ID2}     Pcell_TP=100000
        run keyword if    ${num_r}==1    Trigger '2' SA UEs beam change file '2'
        run keyword if    ${num_r}==2    Trigger '2' SA UEs beam change file '3'
        run keyword if    ${num_r}==3    Trigger '2' SA UEs beam change file '4'
        tti trace ACK check    after_beam_switch_${num}times
#        Get TDD 2CC counters 2UEs    ${counter_V_2UE}    ${counter_V_2UE}
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times' file '${custom_error}'
        Start capture only gnb syslog in 'syslog_traffic_${num}times_2_issue' file
#        Start collect logs by gnb_logs    ${command}    #debug
        UE send A2 event    ${UE_ID1}
        Wait '5s' for stable
#        Wait for '1s' to stop collect logs by gnb tool
        tti trace ACK check    scellrelease_${num}times
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times_2_issue' file '${custom_error}'
        Start capture only gnb syslog in 'syslog_traffic_${num}times_3' file
        Send ue '${UE_ID2}' A1 event 4
        Collect AP egate log    scelladd_back_${num}times
        Get TDD 2CC counters 2UEs    ${counter_V_2UE}    ${counter_V_2UE}
#        Check throughput    ${UE_ID1}     Pcell_TP=100000   Scell_TP=100000
        Stop data transfer    ${UE_ID2}
        Wait '5s' for stable
        SA send dl and ul data    ${UE_ID2}    number=10    dl_data=175M    ul_data=15M    pdu_id=1
        tti trace ACK check    scelladd_back_${num}times
        Wait '5s' for stable
        Get TDD 2CC counters 2UEs    ${counter_V_2UE}    ${counter_V_2UE}
        Stop data transfer    ${UE_ID1}
        Stop data transfer    ${UE_ID2}
        Detach UE     ${UE_ID1}
        Detach UE     ${UE_ID2}
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times_3' file '${custom_error}'
    END

set '${UE_NUM}' SA UEs beam
    log to console    set '${UE_NUM}' SA UEs beam play
    airphone_execute_egate_command
    ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=0,1,2,3,4,5 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
	airphone_execute_egate_command
	...    beam_control_testmode_nr profile_id\=3 ueBeamIndexInitial\=2,3,4,5,0,1 ssbeam_bestbeam\=2 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-85
	airphone_execute_egate_command
	...    beam_control_testmode_nr profile_id\=4 ueBeamIndexInitial\=4,5,0,1,2,3 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-75
	airphone_execute_egate_command
	...    beam_control_testmode_nr profile_id\=5 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-75
    FOR    ${num}    IN RANGE    1    3
        airphone_execute_egate_command
        ...    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=0,1
    END

Trigger '${UE_NUM}' SA UEs beam change file '${profile_id}'
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_execute_egate_command
        ...    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=${profile_id} beamaction\=switch scell\=0,1
       Log To Console    --UE${num} beam change
    END

Check nonCA throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    Wait until keyword succeeds    30s    6s    Verify nonCA throughput    ${UE_ID}    ${Pcell_TP}

Verify nonCA throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
    log to console    ${UE_ID}_dl_throughput_pcell is ${dl_throughput_pcell}

rank2 peak check TP
    [Arguments]    ${UE_ID}=1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=1
    Wait '15s' for stable
    Check throughput    ${UE_ID1}     Pcell_TP=600000   Scell_TP=550000

Attach SA UE
    [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
#    Start collect 'attach_ue${UE_ID}' tcpdump
    Airphone Setup X2 Connection
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
    Send ue '${UE_ID1}' A1 event
#    Stop collect 'attach_ue${UE_ID}' tcpdump
    Wait '5s' for stable

Verify throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
    should_be_true    ${dl_throughput_scell1}>${Scell_TP}
    log to console    UE_ID${UE_ID} pcell is ${dl_throughput_pcell}
    log to console    UE_ID${UE_ID} scell is ${dl_throughput_scell1}

tti trace ACK check
    [Arguments]     ${tti_tag}
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'${tti_tag}_tti'
    Check ttitrace    ${tti_tag}_tti

Override Scell CQI trigger bad threshold
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=1
    Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
    Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}

Override Scell CQI trigger good threshold and scell resume
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
    Check throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}

UE send A1 event again
    [Arguments]    ${UE_ID}
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr

Check Scell deactive
    wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#    wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb

UE send A2 event
    [Arguments]    ${UE_ID}
    airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=${UE_ID} meas_id\=3 rs_type\=ssb scell\=1 scell_rsrp\=30

Override Scell CQI trigger good threshold and scell not resume
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
    Wait until keyword succeeds    60s    6s    Verify Pcell throughput    ${UE_ID}    ${Pcell_TP}
    Wait until keyword succeeds    60s    6s    Verify Scell throughput=0    ${UE_ID}

Check throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    Wait until keyword succeeds    30s    6s    Verify throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}

Analyse scelladd in rrclog
    [Arguments]    ${EGATE_TAG}    ${ini}
    check_log_with_au2anlysis    ${CURDIR}/ini/${ini}    p
    ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

Analyse non CA in rrclog
    [Arguments]    ${EGATE_TAG}    ${ini}
    check_log_with_au2anlysis    ${CURDIR}/ini/${ini}    p
    ...  save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

Wait '${time} ' to check log
    sleep    ${time}


Verify Pcell throughput
   [Arguments]    ${UE_ID}    ${Pcell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}


Verify Scell throughput=0
    [Arguments]    ${UE_ID}
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_scell1}==0

Check Scell release
    [Arguments]    ${scell_release_egate_log}
    wait '5s ' to check log
    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}/    unzip=TRUE
    check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}

Check ttitrace
    [Arguments]    ${tti_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

SA send dl and ul data
    [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
    SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
    SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}

Send ue '${ue_id}' A1 event
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${ue_id} meas_obj_type\=nr
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50

Send ue '${ue_id}' A1 event 4
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${ue_id} meas_obj_type\=nr
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=4 event\=A1 rs_type\=ssb srsrp_nr\=50

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti



Detach UE
    [Arguments]    ${UE_ID}
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30


Block Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
         ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Unblock Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
         ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END
    TAF_ADMIN.teardown    connection=${alias}

Get counter file
#    FOR    ${num}    IN RANGE    1    2400
#        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
##        log to console    \n${remaining_time}
#        Wait '0.2s' for stable
#        ${remaining_time_real}    evaluate    ${remaining_time}-350    #230 time update PM file
##        log to console    \n${remaining_time_real}
#        ${wait}    Run Keyword If    ${num}==1 and ${remaining_time_real}<=20    Set variable    610
#        ...    ELSE    Set variable    310
#        Run Keyword if    ${remaining_time_real}==0   Exit For Loop
#    END
#    Wait '${wait}S' for stable
    Wait '700S' for stable     #10min+100s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    [Return]    ${PM_counter_file}

Get TDD 2CC counters
    [Arguments]    ${PM_counter_file}
    ${UEs_PER_BEAM_ID_cell1_pcell}   create list
    ${UEs_PER_BEAM_ID_cell3_scell}   create list
    FOR    ${num}    IN RANGE    1    10
        ${counter_2}   evaluate   2000+${num}
	    ${M55305C120_cell1_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C1${counter_2}    cell_id=1   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C1${counter_2}_pcell}     ${M55305C120_cell1_res}
        append to list    ${UEs_PER_BEAM_ID_cell1_pcell}    ${M55305C1${counter_2}_pcell}
	    ${M55305C120_cell3_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C1${counter_2}    cell_id=3   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C1${counter_2}_scell}     ${M55305C120_cell3_res}
        append to list    ${UEs_PER_BEAM_ID_cell3_scell}    ${M55305C1${counter_2}_scell}
    END
    set suite variable   ${UEs_PER_BEAM_ID_cell1_pcell_suite}    ${UEs_PER_BEAM_ID_cell1_pcell}
    set suite variable   ${UEs_PER_BEAM_ID_cell3_scell_suite}    ${UEs_PER_BEAM_ID_cell3_scell}
    ${list_max_70851_pcell}    evaluate    max(${UEs_PER_BEAM_ID_cell1_pcell_suite})
    ${list_max_70851_scell}    evaluate    max(${UEs_PER_BEAM_ID_cell3_scell_suite})
    log to console    list_max_70851_pcell is ${list_max_70851_pcell}
    log to console    list_max_70851_scell is ${list_max_70851_scell}

Get TDD 2CC counters 2UEs
    [Arguments]    ${2UE_tar_pcell}    ${2UE_tar_scell}
    Wait '300s' for stable
    ${UEs_PER_BEAM_ID_cell1_pcell}   create list
    ${UEs_PER_BEAM_ID_cell2_scell}   create list
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    FOR    ${num}    IN RANGE    1    10
	    ${M55305C120_cell1_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C1200${num}    cell_id=1   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C1200${num}_pcell}     ${M55305C120_cell1_res}
        append to list    ${UEs_PER_BEAM_ID_cell1_pcell}    ${M55305C1200${num}_pcell}
	    ${M55305C120_cell2_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C1200${num}    cell_id=3   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C1200${num}_scell}     ${M55305C120_cell2_res}
        append to list    ${UEs_PER_BEAM_ID_cell2_scell}    ${M55305C1200${num}_scell}
    END

    FOR    ${num}    IN RANGE    10    65
	    ${M55305C120_cell1_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C120${num}    cell_id=1   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C120${num}_pcell}     ${M55305C120_cell1_res}
        append to list    ${UEs_PER_BEAM_ID_cell1_pcell}    ${M55305C120${num}_pcell}
	    ${M55305C120_cell2_res}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55305C120${num}    cell_id=3   #UEs_PER_BEAM_ID_0
        set suite variable     ${M55305C120${num}_scell}     ${M55305C120_cell2_res}
        append to list    ${UEs_PER_BEAM_ID_cell2_scell}    ${M55305C120${num}_scell}
    END
    set suite variable   ${UEs_PER_BEAM_ID_cell1_pcell_suite}    ${UEs_PER_BEAM_ID_cell1_pcell}
    set suite variable   ${UEs_PER_BEAM_ID_cell2_scell_suite}    ${UEs_PER_BEAM_ID_cell2_scell}
    ${list_max_70851_pcell}    evaluate    max(${UEs_PER_BEAM_ID_cell1_pcell_suite})
    ${list_max_70851_scell}    evaluate    max(${UEs_PER_BEAM_ID_cell2_scell_suite})
    log to console    list_max_70851_pcell is ${list_max_70851_pcell}
    log to console    list_max_70851_scell is ${list_max_70851_scell}
    should be true    ${list_max_70851_pcell}<=${2UE_tar_pcell}
    should be true    ${list_max_70851_scell}<=${2UE_tar_scell}

#get F1AP and UE id for test start
#Get Crnti and gnb_du_id from f1ap
#    [Arguments]     ${bip_file}    ${ue_id}    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
#    Log To Console   Check '${bip_file}' Crnti and gnb_du_id
#    Run Keyword And ignore error    Convert BIP To CSV
#    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
#    ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
#    Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
#    ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
#    set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
#    Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----
#
#Get col_values from bip csv
#    [Arguments]    ${csv_file}    ${col_name}
#    ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
#    ${col_value_list}    Remove Duplicates    ${col_values}
#    [return]     ${col_value_list}
#get F1AP and UE id for test end
