*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown  Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_l3gao
...   CLOUD_5G_I_BLLL_AP_LOO    2TDD_CA
Test Timeout      600 minutes
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot
Documentation
...     beamform_beamset6 8mhz_80mhz refinebeam_false 4DL2UL dlmimo_4X4 SA frame_1/4 radio_2symbol
...     actPdschAtSsbSlots_P_enable_S_true prach_98
...     peak downlink_1.2g_1.2g  uplink 120mbps
...     uldata push stop due to [Precheck][CB007922[SBTS00][LOAPLO]When send ul data the rank will drop to rank1
...     tti check shutdown due to NACK

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID1}          1
${UE_ID2}          2
${SCFC_NAME}     1729_CASE76_SCFC_BLLL_AP_LO.xml
${AIRPHONE_NAME}    IPHY_AEQE_4CELL_1729_case76.xml
${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_1729_case76.cfg
${EGATE_TAG_1}      CA_before_block
${EGATE_TAG_2}      CA_after_block
@{LOG_NAME_LIST}    gnb_snapshot      sosreport    #sosreport    egatelog     sosreport
${Block_Num}   1
${cell1_as_pcell_tp}    1300000  #1300000
${cell2_as_Pcell_tp}    1050000  #1050000
${cell2_as_Pcell_tp_block}    200000  #200000
${cell2_as_scell_tp}    1050000   #1050000
${cell1_as_scell_tp}    1300000   #1300000
${cell1_as_pcell_tp_block}    740000.0

*** Test Cases ***
5GC001729_Case76_C11_Cell_Unlock_of_TDD_SCell
    step1: Prepare gnb onair
    step2: attach UE to cell50 and check TP and bler
    step3: block and unblock scell52 reattach UE to cell50 and check TP and bler
    step4: attach UE to cell52 and check TP and bler
    step5: block and unblock scell50 reattach UE to cell52 and check TP and bler
    step6：block ‘${Block_Num}’ times

*** Keywords ***
step1: Prepare gnb onair
    log to console   step1: Prepare gnb onair
    Prepare gnb onair

step2: attach UE to cell50 and check TP and bler
    log to console   step2: attach UE to cell50 and check TP and bler
    Start capture gnb and ap syslog in 'before_block_start' file
    airphone_cleanup_egate_console_log
    Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID1}' A1 event
    SA send dl and ul data    ${UE_ID1}    number=15    dl_data=175M    ul_data=15M    pdu_id=1
    Collect AP egate log    before_block_cell52
    Analyse scelladd in rrclog    before_block_cell52     RRC_scelladd_LO_AP_LO_cell52.ini
    Check throughput    ${UE_ID1}     Pcell_TP=${cell1_as_pcell_tp}   Scell_TP=${cell2_as_Pcell_tp}
    tti trace ACK check    before_block_start
    Detach UE     ${UE_ID1}
    Stop capture gnb and ap syslog in 'before_block_start' file

step3: block and unblock scell52 reattach UE to cell50 and check TP and bler
    log to console    step3: block and unblock scell52 reattach UE to cell50 and check TP and bler
    Start capture gnb and ap syslog in 'block_unblock_cell52' file
    airphone_cleanup_egate_console_log
    Block Cell    52    gNB
    Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID1}' A1 event
    SA send dl and ul data    ${UE_ID1}    number=15    dl_data=175M    ul_data=15M    pdu_id=1
    Collect AP egate log     block_cell52
    Analyse non CA in rrclog    block_cell52     RRC_non_CA_LO_AP_LO_cell52.ini
    Wait until keyword succeeds    60s    5s    Verify Pcell throughput    ${UE_ID1}   Pcell_TP=${cell1_as_pcell_tp}
    Stop data transfer    ${UE_ID1}
    Detach UE     ${UE_ID1}

    airphone_cleanup_egate_console_log
    Unblock Cell  52    gNB
    Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID1}' A1 event
    SA send dl and ul data    ${UE_ID1}    number=15    dl_data=175M    ul_data=15M    pdu_id=1
    Collect AP egate log    unblock_cell52
    Analyse scelladd in rrclog   unblock_cell52   RRC_scelladd_LO_AP_LO_cell52.ini
    Check throughput    ${UE_ID1}     Pcell_TP=${cell1_as_pcell_tp}   Scell_TP=${cell2_as_Pcell_tp}
    tti trace ACK check    unblock_cell52     #tti check
    Stop data transfer    ${UE_ID1}
    Detach UE     ${UE_ID1}
    Stop capture gnb and ap syslog in 'block_unblock_cell52' file

step4: attach UE to cell52 and check TP and bler
    log to console    step4: attach UE to cell52 and check TP and bler
    Start capture gnb and ap syslog in 'ue2_attach_pcell_cell3' file
    airphone_cleanup_egate_console_log
    Attach SA UE    UE_ID=2     PDU_ID=2   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID2}' A1 event
    SA send dl and ul data    ${UE_ID2}    number=15    dl_data=175M    ul_data=15M    pdu_id=2
    Collect AP egate log     before_block_cell50
    Analyse scelladd in rrclog    before_block_cell50    RRC_scelladd_LO_AP_LO_cell50.ini
    Check throughput    ${UE_ID2}    Pcell_TP=${cell2_as_scell_tp}   Scell_TP=${cell1_as_scell_tp}
#    tti trace ACK check    before_block_cell50
    Stop data transfer    ${UE_ID2}
    Detach UE     ${UE_ID2}
    Stop capture gnb and ap syslog in 'ue2_attach_pcell_cell3' file

step5: block and unblock scell50 reattach UE to cell52 and check TP and bler
    log to console    step5: block and unblock scell50 reattach UE to cell52 and check TP and bler
    airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'block_unblock_cell50' file
    Block Cell    50    gNB
    Attach SA UE    UE_ID=2     PDU_ID=2   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID2}' A1 event
    SA send dl and ul data    ${UE_ID2}    number=16    dl_data=175M    ul_data=15M    pdu_id=2
    Collect AP egate log    block_cell50
    Analyse non CA in rrclog    block_cell50    RRC_non_CA_LO_AP_LO_cell50.ini
    Wait until keyword succeeds    60s    5s    Verify Pcell throughput    ${UE_ID2}    Pcell_TP=${cell2_as_scell_tp}
#    tti trace ACK check    block_cell50
    Stop data transfer    ${UE_ID2}
    Detach UE     ${UE_ID2}

    airphone_cleanup_egate_console_log
    Unblock Cell  50    gNB
    Attach SA UE    UE_ID=2     PDU_ID=2   SLICE_ID=1    GW_ID=1
    Send ue '${UE_ID2}' A1 event
    SA send dl and ul data    ${UE_ID2}    number=15    dl_data=175M    ul_data=15M    pdu_id=2
    Collect AP egate log    unblock_cell50
    Analyse scelladd in rrclog    unblock_cell50     RRC_scelladd_LO_AP_LO_cell50.ini
    Check throughput    ${UE_ID2}    Pcell_TP=${cell2_as_scell_tp}   Scell_TP=${cell1_as_scell_tp}
    tti trace ACK check    unblock_cell50
    Stop data transfer    ${UE_ID2}
    Detach UE     ${UE_ID2}
    Stop capture gnb and ap syslog in 'block_unblock_cell50' file

Attach SA UE
    [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=5
    Airphone Setup X2 Connection
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${UE_ID} cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${UE_ID} scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${UE_ID} scell\=1
    Wait '5s' for stable

Fix rank4 again
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1



tti trace ACK check
    [Arguments]     ${tti_tag}
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'${tti_tag}'
    Check ttitrace    ${tti_tag}

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
    Wait until keyword succeeds    60s    6s    Verify throughput    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}

Verify throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>=${Pcell_TP}
    run keyword and continue on failure    should_be_true    ${dl_throughput_scell1}>=${Scell_TP}
    log to console    dl_throughput_pcell result is ${dl_throughput_pcell} and target is ${Pcell_TP}
    log to console    dl_throughput_scell1 result is ${dl_throughput_scell1} and target is ${Scell_TP}


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
    should_be_true    ${dl_throughput_pcell}>=${Pcell_TP}
    log to console    dl_throughput_pcell result is ${dl_throughput_pcell} and target is ${Pcell_TP}

Verify Scell throughput=0
    [Arguments]    ${UE_ID}
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_scell1}==0

Check Scell release
    [Arguments]    ${scell_release_egate_log}
    wait '5s ' to check log
    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}/    unzip=TRUE
    check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scell_release.ini    u
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${scell_release_egate_log}

Check ttitrace
    [Arguments]    ${tti_file}
    log to console    starct check tti ini
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

SA send dl and ul data
    [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
    log to console   push full data start
    SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
    SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}

SA send dl and ul data_2
    [Arguments]    ${ue_id}    ${number}=4    ${dl_data}=175M    ${ul_data}=20M    ${pdu_id}=1
    SA send mutiple trf dl data    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}
#    SA send mutiple trf ul data    ${ue_id}    ${number}    ${ul_data}    ${pdu_id}


Send ue '${ue_id}' A1 event
    airphone_execute_egate_command    ue_measurement_send_nr id\=${ue_id} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

Stop data transfer
    [Arguments]    ${UE_ID}
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=dl

Detach UE
    [Arguments]    ${UE_ID}
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30


Block Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   block Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
         ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END    
    TAF_ADMIN.teardown    connection=${alias}

Unblock Cell
    [Arguments]    ${phy_cell_id}    ${alias}
    log to console   unblock Cell${phy_cell_id}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
    FOR    ${nrcel}    IN    @{nrcel_list}
        Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
         ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    sleep    60
    END    
    TAF_ADMIN.teardown    connection=${alias}

step6：block ‘${NUM}’ times
    log to console    step6：block ‘${NUM}’ times
    FOR    ${num}    IN RANGE    1    ${NUM}+1
        airphone_cleanup_egate_console_log
        Log To Console   ${\n}-----block ${num} time ------
        Start capture gnb and ap syslog in 'block_unblock_cell50_${num}' file
        Block Cell    52    gNB
        Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
        Send ue '${UE_ID1}' A1 event
        SA send dl and ul data_2    ${UE_ID1}    number=8    dl_data=175M    ul_data=15M    pdu_id=1
        Collect AP egate log      block_cell52_${num}
        Analyse non CA in rrclog     block_cell52_${num}     RRC_non_CA_LO_AP_LO_cell52.ini
        Wait until keyword succeeds    60s    5s    Verify Pcell throughput    ${UE_ID1}   Pcell_TP=${cell1_as_pcell_tp}
        Stop data transfer    ${UE_ID1}
        Detach UE     ${UE_ID1}
        Log To Console   ${\n}-----unblock ${num} time ------
        airphone_cleanup_egate_console_log
#        run keyword if  ${num}==9    Start collect 'unblock_9th_ng_fail' tcpdump
        Unblock Cell  52    gNB
        Wait '5s' for stable
        Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1
        Send ue '${UE_ID1}' A1 event
        SA send dl and ul data_2    ${UE_ID1}    number=8    dl_data=175M    ul_data=15M    pdu_id=1
        Check throughput    ${UE_ID1}    Pcell_TP=${cell1_as_pcell_tp_block}    Scell_TP=${${cell2_as_Pcell_tp_block}}
#        run keyword if  ${num}==9   Stop collect 'unblock_9th_ng_fail' tcpdump
        Collect AP egate log     unblock_cell52_${num}
        Analyse scelladd in rrclog    unblock_cell52_${num}   RRC_scelladd_LO_AP_LO_cell52.ini
        run keyword and continue on failure    tti trace ACK check    unblock_cell52_${num}
        Stop data transfer    ${UE_ID1}
        Detach UE     ${UE_ID1}
        Stop capture gnb and ap syslog in 'block_unblock_cell50_${num}' file
        Wait '2s' for stable
        END
