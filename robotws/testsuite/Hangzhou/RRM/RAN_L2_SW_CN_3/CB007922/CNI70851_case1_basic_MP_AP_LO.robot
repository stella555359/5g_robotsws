*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown  Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   SBTS23R1   RAN_5G_TDD    RAN_5G   owner_l3gao
...   CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    2TDD_CA
Resource    ../resources/KISS/robot/common_resource.robot
Resource    ../resources/sg10/internal_resource/internal_resource.robot
Documentation
...   add counter Number of UEs per beam - Beam ID

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${UE_ID1}          1
${UE_ID2}          2
${SCFC_NAME}     70851_CASE01_SCFC_MP_AP_LO_8DL4UL.xml
${AIRPHONE_NAME}    IPHY_AEQE_2CELL_LO_AP_LO.xml
#${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_8DL4UL.cfg
${WTS_NAME}      WTS_LO_AP_LO_SANSA_n78_8SA_32NSA_2Cell.cfg
#@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog    sosreport
${EGATE_TAG_1}      CA_before_block
${EGATE_TAG_2}      CA_after_block
@{LOG_NAME_LIST}    gnb_snapshot
${Block_Num}   1
@{Rdparameter}    0x340000:15
${Pcell_TP}    1300000   #1300000
${Scell_TP}    1000000    #1000000

*** Test Cases ***
CNI70851_case01_intraL2RT_NSA_5GC002200_DRX
    Active GNB L2 feature debug traces
    Add GNB swconfig    @{Rdparameter}
    Prepare gnb onair
    Start capture gnb and ap syslog in 'after_on_onair' file
    airphone_cleanup_egate_console_log
    Attach SA UE    UE_ID=1     PDU_ID=1   SLICE_ID=1    GW_ID=1

    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
    Wait '40s' for stable
    Collect AP egate log    rrc_logs
    Analyse scelladd in rrclog    rrc_logs     RRC_scelladd_LO_AP_LO_cell52.ini
    Check throughput    ${UE_ID1}     Pcell_TP=${Pcell_TP}   Scell_TP=${Scell_TP}
    tti trace ACK check    scell_add_first_time
    Start collect bip log
    Wait for '1s' to stop bip log with name'scell_add_first_time'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 600
    should be true  ${M55305C12009_pcell} == 600
    UE send A2 event    ${UE_ID1}
    Check Scell release    scell_release_egate_log
    Verify Pcell throughput    ${UE_ID1}    Pcell_TP=${Pcell_TP}
    tti trace ACK check    scell_release
    Start collect bip log
    Wait for '1s' to stop bip log with name'scell_release'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 0
    should be true  ${M55305C12009_pcell} == 600
    UE send A1 event again    ${UE_ID1}
    Collect AP egate log    scell_add_again_rrc_logs
    Analyse scelladd in rrclog    scell_add_again_rrc_logs     RRC_scelladd_LO_AP_LO_cell52.ini
    Run Keyword And Ignore Error    Check throughput    ${UE_ID1}     Pcell_TP=${Pcell_TP}   Scell_TP=${Scell_TP}
    tti trace ACK check    scell_add_again
    Start collect bip log
    Wait for '1s' to stop bip log with name'scell_add_again'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 600
    should be true  ${M55305C12009_pcell} == 600
    Stop data transfer    ${UE_ID1}
    Check Scell deactive
    tti trace ACK check    scell_deactive
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_deactive'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 0
    should be true  ${M55305C12009_pcell} == 600
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
    tti trace ACK check    scell_active_again
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_active_again'
    Check throughput    ${UE_ID1}     Pcell_TP=${Pcell_TP}   Scell_TP=${Scell_TP}
    Get TDD 2CC counters
    should be true  ${M55305C12009_pcell} == 600
    should be true  ${M55305C12009_scell} == 600
    Stop data transfer    ${UE_ID1}
    Check Scell deactive
    tti trace ACK check    scell_deactive
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_deactive'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 0
    should be true  ${M55305C12009_pcell} == 600
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
    tti trace ACK check    scell_active_again
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_active_again'
    Check throughput    ${UE_ID1}     Pcell_TP=${Pcell_TP}   Scell_TP=${Scell_TP}
    Get TDD 2CC counters
    should be true  ${M55305C12009_pcell} == 600
    should be true  ${M55305C12009_scell} == 600
    Stop data transfer    ${UE_ID1}
    Check Scell deactive
    tti trace ACK check    scell_deactive
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_deactive'
    Get TDD 2CC counters
    should be true  ${M55305C12009_scell} == 0
    should be true  ${M55305C12009_pcell} == 600
    SA send dl and ul data    ${UE_ID1}    number=16    dl_data=175M    ul_data=15M    pdu_id=1
    tti trace ACK check    scell_active_again
    Start collect bip log
    Wait for '2s' to stop bip log with name'scell_active_again'
    Check throughput    ${UE_ID1}     Pcell_TP=${Pcell_TP}   Scell_TP=${Scell_TP}
    Get TDD 2CC counters
    should be true  ${M55305C12009_pcell} == 600
    should be true  ${M55305C12009_scell} == 600
    Detach UE     ${UE_ID1}
    Stop capture gnb and ap syslog in 'after_on_onair' file

*** Keywords ***
rank2 peak check TP
    [Arguments]    ${UE_ID}=1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=3 scell\=1
    Wait '15s' for stable
    Check throughput    ${UE_ID1}     Pcell_TP=600000   Scell_TP=550000

Attach SA UE
    [Arguments]    ${UE_ID}=1     ${PDU_ID}=1    ${SLICE_ID}=1   ${GW_ID}=1
    Start collect 'attach_ue${UE_ID}' tcpdump
    Airphone Setup X2 Connection
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal
    Airphone SA Attach    ue_id=${UE_ID}
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=1
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=35 sinr_target_pucch\=-300 noise_srs\=-1053
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=10
    Send ue '${UE_ID1}' A1 event
    Stop collect 'attach_ue${UE_ID}' tcpdump
    Wait '5s' for stable

Verify throughput
    [Arguments]    ${UE_ID}    ${Pcell_TP}    ${Scell_TP}
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>${Pcell_TP}
    should_be_true    ${dl_throughput_scell1}>${Scell_TP}

tti trace ACK check
    [Arguments]     ${tti_tag}
    Start collect ttitrace
    Wait for '3s' to stop ttitrace with name'${tti_tag}_tti'
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
