*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown  Common Suite Teardown
Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   owner_l3gao
...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    2TDD_CA
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot
Documentation
...   add counter Number of UEs per beam - Beam ID

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID1}          1
${UE_ID2}          2
${SCFC_NAME}     70851_CASE01_SCFC_LO_AP_LO_8DL4UL_cwq.xml
${AIRPHONE_NAME}    IPHY_AEQE_2CELL_LO_AP_LO.xml
${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_2Cell.cfg
${EGATE_TAG_1}      CA_before_block
${EGATE_TAG_2}      CA_after_block
@{LOG_NAME_LIST}    gnb_snapshot
${Block_Num}   1
@{Rdparameter}    0x340000:15    0x9D0000:15
${command}    sudo ./gnb_logs -t -c -b -cp
@{TOOLS_LIST}    luashark    bip_script    common_config_golden    common_config_private    mcshark    ttitrace_decode

*** Test Cases ***
CNI70851_case01_intraL2RT_NSA_5GC002200_DRX
    get ready for gnb
    airphone_cleanup_egate_console_log
    run keyword and continue on failure    attach 2UE '8' times
#    run keyword and continue on failure    attach 2UE '2' times_cwq
#    run keyword and continue on failure    attach 2UE '3' times_cwq_debug
    capture snapshot start once   CA_snapshot

*** Keywords ***
get ready for gnb
    Add GNB swconfig    @{Rdparameter}
    Prepare gnb onair
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/.uplane    WRN/L2-PS
    Set Test Variable    ${custom_error}
    Get gnb_logs from git
    modify gnb_logs config

set '${UE_NUM}' SA UEs beam
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
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times' file '${custom_error}'
        Start capture only gnb syslog in 'syslog_traffic_${num}times_2_issue' file
#        Start collect logs by gnb_logs    ${command}    #debug
        UE send A2 event    ${UE_ID1}
        Wait '5s' for stable
#        Wait for '1s' to stop collect logs by gnb tool
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times_2_issue' file '${custom_error}'
        Start capture only gnb syslog in 'syslog_traffic_${num}times_3' file
        Send ue '${UE_ID2}' A1 event
        Wait '5s' for stable
        Stop data transfer    ${UE_ID2}
        Wait '5s' for stable
        SA send dl and ul data    ${UE_ID2}    number=10    dl_data=175M    ul_data=15M    pdu_id=1
        Wait '5s' for stable
        Stop data transfer    ${UE_ID1}
        Stop data transfer    ${UE_ID2}
        Detach UE     ${UE_ID1}
        Detach UE     ${UE_ID2}
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times_3' file '${custom_error}'
    END


attach 2UE '${NUM_attach}' times_cwq
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
        run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=100000   Scell_TP=100000
        run keyword and continue on failure    Check nonCA throughput    ${UE_ID2}     Pcell_TP=100000
        Trigger UE to report CQI is 0 on SCell    ${UE_ID1}
        run keyword if    ${num_r}==1    Trigger '2' SA UEs beam change file '2'
        run keyword if    ${num_r}==2    Trigger '2' SA UEs beam change file '3'
        run keyword if    ${num_r}==3    Trigger '2' SA UEs beam change file '4'
        run keyword if    ${num_r}==4    Trigger '2' SA UEs beam change file '5'
        ${num_r}    evaluate    ${num_r}+1
        Wait '5s' for stable
        Stop data transfer    ${UE_ID1}
        Wait '10s' for stable
        SA send dl and ul data    ${UE_ID1}    number=10    dl_data=175M    ul_data=15M    pdu_id=1
        Wait '10s' for stable
        Trigger UE to report CQI is 0 on SCell    ${UE_ID1}
        run keyword if    ${num_r}==1    Trigger '2' SA UEs beam change file '2'
        run keyword if    ${num_r}==2    Trigger '2' SA UEs beam change file '3'
        run keyword if    ${num_r}==3    Trigger '2' SA UEs beam change file '4'
        run keyword if    ${num_r}==4    Trigger '2' SA UEs beam change file '5'
        ${num_r}    evaluate    ${num_r}+1
        Wait '5s' for stable
        Stop data transfer    ${UE_ID1}
        Wait '10s' for stable
        SA send dl and ul data    ${UE_ID1}    number=10    dl_data=175M    ul_data=15M    pdu_id=1
        Trigger UE to report CQI is 15 on SCell    ${UE_ID1}
        Wait '10s' for stable
        run keyword and continue on failure    Check throughput    ${UE_ID1}     Pcell_TP=100000   Scell_TP=100000
        UE send A2 event    ${UE_ID1}
        run keyword and continue on failure    Check nonCA throughput    ${UE_ID1}     Pcell_TP=100000
        Wait '5s' for stable
        Send ue '${UE_ID2}' A1 event
        Wait '5s' for stable
        Stop data transfer    ${UE_ID2}
        Wait '5s' for stable
        SA send dl and ul data    ${UE_ID2}    number=10    dl_data=175M    ul_data=15M    pdu_id=2
        Wait '5s' for stable
        Trigger UE to report CQI is 0 on SCell    ${UE_ID2}
        run keyword if    ${num_r}==1    Trigger '2' SA UEs beam change file '2'
        run keyword if    ${num_r}==2    Trigger '2' SA UEs beam change file '3'
        run keyword if    ${num_r}==3    Trigger '2' SA UEs beam change file '4'
        run keyword if    ${num_r}==4    Trigger '2' SA UEs beam change file '5'
        Trigger UE to report CQI is 15 on SCell    ${UE_ID2}
        Stop data transfer    ${UE_ID1}
        Stop data transfer    ${UE_ID2}
        Detach UE     ${UE_ID1}
        Detach UE     ${UE_ID2}
        run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_traffic_${num}times' file '${custom_error}'
    END


Trigger UE to report CQI is 0 on SCell
    [Arguments]    ${UE_id}=1
    Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed
    Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=3 cqi\=0 cqi_mode\=fixed
    Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_id} testmode\=csi_override action\=activate profile_id\=3 scell\=1
    Wait Throughput Timer    10
    ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_id}    scell_id=0    type=pdsch    tput_type=ave
    ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_id}    scell_id=1    type=pdsch    tput_type=ave
    should be true    ${Pcell_dl_throughput} > 200000
    should be true    ${Scell_dl_throughput} == 0

Trigger UE to report CQI is 15 on SCell
    [Arguments]    ${UE_id}=1
    Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed
    Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=3 cqi\=0 cqi_mode\=fixed
    Airphone Execute Egate Command    ue_testmode_set_nr id\=${UE_id} testmode\=csi_override action\=activate profile_id\=2 scell\=1
    Wait Throughput Timer    10
    ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_id}    scell_id=0    type=pdsch    tput_type=ave
    ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_id}    scell_id=1    type=pdsch    tput_type=ave
    should be true    ${Pcell_dl_throughput} > 200000
    should be true    ${Scell_dl_throughput} > 20     #should be 200

capture snapshot start once
    [Arguments]    ${log_tag}=snapshot
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip

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
#    Stop collect 'attach_ue${UE_ID}' tcpdump
    Wait '5s' for stable

Verify throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
    should_be_true    ${dl_throughput_scell1}>${Scell_TP}
    log to console    ${UE_ID}_dl_throughput_pcell is ${dl_throughput_pcell}
    log to console    ${UE_ID}_dl_throughput_scell1 is ${dl_throughput_scell1}

Verify nonCA throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
    log to console    ${UE_ID}_dl_throughput_pcell is ${dl_throughput_pcell}

tti trace ACK check
    [Arguments]     ${tti_tag}
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'${tti_tag}_tti'
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

Check Scell deactive
#    wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
    wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb

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

Check nonCA throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}
    Wait until keyword succeeds    30s    6s    Verify nonCA throughput    ${UE_ID}    ${Pcell_TP}

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
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

Stop data transfer
    [Arguments]    ${UE_ID}
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl
#    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul

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

Get TDD 2CC counters
    Wait '30s' for stable
    ${UEs_PER_BEAM_ID_cell1_pcell}   create list
    ${UEs_PER_BEAM_ID_cell2_scell}   create list
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
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
    log to console    UEs_PER_BEAM_ID_cell1_pcell_suite is ${UEs_PER_BEAM_ID_cell1_pcell_suite}
    log to console    UEs_PER_BEAM_ID_cell2_scell_suite is ${UEs_PER_BEAM_ID_cell2_scell_suite}

# gnb logs capture
Get gnb_logs from git
     ${exist}    List Directory    /home/ute
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    modify gnb_logs config

Start collect logs by gnb_logs
    [Arguments]    ${command}
    log to console    Start collect logs by gnb_logs
    OperatingSystem.Run    rm -rf /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129*
    TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
    TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    TAF_SSH.Read Output Until    (Q)uit    connection=bsh

Wait for '${time}' to stop collect logs by gnb tool
    log to console    stop collect logs by gnb tool
    Wait '${time}' for stable
    OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    30000    10    file should contain
    ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running
    OperatingSystem.Run    scp /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129* ${TEST_LOG_DIRECTORY()}/All

modify gnb_logs config
    setup_txt    /home/ute/gnb_logs-tool/gnb_logs/config.ini
    Modify Txt Node    TTI_log_files:60    BIP_log_files:10
    teardown_txt
