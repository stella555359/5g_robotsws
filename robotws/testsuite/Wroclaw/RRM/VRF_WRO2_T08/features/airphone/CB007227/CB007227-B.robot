*** Settings ***
Documentation
...            title:        CB007227-B PCMD measurements for U-Plane - CU-UP
...            author:       Nelsandro Sampaio, nelsandro.sampaio@nokia.com,
...                          Bartosz Szlezak, bartosz.szlezak@nokia.com,
...                          Marcin Duplaga, marcin.duplaga@nokia.com,
...                          Jakub Rutyna, jakub.rutyna@nokia.com
...            maintainer:   Bartosz Szlezak, bartosz.szlezak@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    CB007227_common.robot
Library     ta5g_enb
Library     ta5g_setups_and_teardowns

Suite Setup       Run Keywords
...               Backup And Modify Swconfig File    parameters_list=@{swconfig_rndFlag}
...    AND        Reset Testline And Wait For Rmods
...    AND        Check Radios Availability
...    AND        Add Simulated GNB to WTS Config    wts_delta=${DELTA_WTS_A3_Xn}    wts_out=${WTS_HO}
...    AND        Testline Setup    config=${SUITE_CONFIG}    reach_on_air=yes    wts=${WTS_HO}
...    AND        Start X2 Link     target_gnb_id=3
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Run Keywords
...               Add Scout External Execution ID To Reporting Portal
...    AND        Test Case Teardown    check_radio_res=yes    oam_logs=yes
...    AND        Update Sim ENB EN-DC Parameters    id=1    reset=yes

*** Variables ***
@{swconfig_rndFlag}=    0xA40000=0
@{IP_ADDR_SIM_GNB}    eth3:10.0.1.3/24    eth3:10.44.76.28/24
${DELTA_WTS_A3_Xn}    ${CURDIR}/configs/wts_sim_gnb_A3_XnHO.cfg
${WTS_HO}             ${OUTPUT DIR}/Logs/wts_ext_and_sim_gnb.cfg
${CONFIG_PCMD}        ${CURDIR}/configs/Delta_PCMD_NRMTRACECUUP_tracing.json
${CONFIG_HO}          ${CURDIR}/configs/Delta_HO_Xn_NG_A3_A5_TDD.json
@{DELTAS}             ${CONFIG_HO}    ${CONFIG_PCMD}
&{SUITE_CONFIG}       delta=${DELTAS}    ip_addr=${IP_ADDR_SIM_GNB}
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
${PM_MOID}              PLMN-PLMN/MRBTS-1/NRBTS-1
@{SA_UL_DL_PM_COUNTERS}     M55327C04006    M55327C02006
@{NSA_UL_DL_PM_COUNTERS}    M55315C03009    M55315C01009
@{SA_DL_DISC_PM_COUNTERS}      M55313C03006    M55320C01006    M55320C03006    M55320C05006    M55320C10006
@{SA_UL_DISC_PM_COUNTERS}      M55320C07006
@{NSA_DL_DISC_PM_COUNTERS}     M55313C03009    M55320C01009    M55320C03009    M55320C05009    M55320C10009
@{NSA_UL_DISC_PM_COUNTERS}     M55320C07009

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB007227-5G-B_33_B01_PCMD_measurements_for_U-Plane_gNB_CU-UP_with_intra-gNB_HO
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Start NSA L3 Call    ue_id=11    target_gnb_cell=1
    Perform Handover To Target PCI
    ...    ue_id=11    target_pci=51    event=A3    pass_regexp=Sending SgNB Modification Confirm
    Sleep    20s    reason=Wait until at least 5 reports (4096 ms each) are sent to TCE
    Stop NSA L3 Call     ue_id=11
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${pm_counter_path}    ta5g_pm_counters.Get Next Unpacked Full Pm Counters File
    ...    output_dirpath=${TEST_log_dir}/PM_COUNTERS
    ${records}    Get PCMD Records from PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records.json
    ${UL_PDCP_VOL_SNT_S1U_QOS_GRP_09}    ta5g_pm_counters.Get Pm Counter Value    ${NSA_UL_DL_PM_COUNTERS}[0]    ${PM_MOID}    ${pm_counter_path}
    ${DL_PDCP_VOL_RCV_S1U_QOS_GRP_09}    ta5g_pm_counters.Get Pm Counter Value    ${NSA_UL_DL_PM_COUNTERS}[1]    ${PM_MOID}    ${pm_counter_path}
    ${NSA_DISCARDED_BYTES_UL}    Get UL Discarded Bytes
    ...    counters=${NSA_UL_DISC_PM_COUNTERS}    counters_path=${pm_counter_path}    syslog_filepath=${dcap_files}[syslog]
    ${NSA_DISCARDED_BYTES_DL}    Get DL Discarded Bytes From PM Counters
    ...    counters=${NSA_DL_DISC_PM_COUNTERS}    counters_path=${pm_counter_path}
    ${dlRbPdcpMeasRecordsAmount}    Get Message Count From PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.dlRbPdcpMeasRecord    options=${tshark_options}
    ${ulRbPdcpMeasRecordAmount}    Get Message Count From PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]    filter=nsetapx.ulRbPdcpMeasRecord    options=${tshark_options}
    Verify PCMD Records    record_name=ulRbPdcpMeasRecord
    ...    PCMD_records_file_path=${TEST_log_dir}/PCMD/PCMD_records.json
    ...    ReporteddBytes_PMcounter=${UL_PDCP_VOL_SNT_S1U_QOS_GRP_09}[0]
    ...    DiscardedBytes_PMcounter=${NSA_DISCARDED_BYTES_UL}
    Verify PCMD Records    record_name=dlRbPdcpMeasRecord
    ...    PCMD_records_file_path=${TEST_log_dir}/PCMD/PCMD_records.json
    ...    ReporteddBytes_PMcounter=${DL_PDCP_VOL_RCV_S1U_QOS_GRP_09}[0]
    ...    DiscardedBytes_PMcounter=${NSA_DISCARDED_BYTES_DL}
    Prepare And Verify Sequence Of Records In Existing Collection
    ...    recordsAmount=${ulRbPdcpMeasRecordAmount}
    ...    record_name=ulRbPdcpMeasRecord
    ...    collection=${records}
    Prepare And Verify Sequence Of Records In Existing Collection
    ...    recordsAmount=${dlRbPdcpMeasRecordsAmount}
    ...    record_name=dlRbPdcpMeasRecord
    ...    collection=${records}

*** Keywords ***
Change UE-${ue_id} Location To Sim GNB
    [Documentation]    Example of wrapper KW with embeded parameters to improve test steps readability.
    ...                KW assumes that Sim GNB has ID 3 and has only one cell with ID 1.
    Change UE Location    ue_id=${ue_id}    node_id=3    cell_id=1

Prepare UE History Information
    [Arguments]    ${ue}=1    ${nrci}=0x01
    ${reset_history}     Set Variable    ue_history_information_list id=${ue} action=reset
    ${ue_history}        Set Variable
    ...    ue_history_information_list_add_ngran id=${ue} gnb_id=3 cell_type=large nrcgi=311:489|${nrci} time_ue_stayed_in_cell=98
    ${commit_history}    Set Variable    ue_history_information_list id=${ue} action=commit
    ${assign_history}    Set Variable    ue_enb_param id=${ue} ue_history_list=${ue}
    ute_wtssim.execute_egate_command    cmd=${reset_history};${ue_history};${commit_history};${assign_history}

Verify PCMD Records
    [Arguments]    ${record_name}    ${PCMD_records_file_path}    ${ReporteddBytes_PMcounter}    ${DiscardedBytes_PMcounter}
    ${rc1}    ${output1}    Run And Return Rc And Output
    ...    grep -A 12 ${record_name} ${PCMD_records_file_path} | grep -w 'sumOfPdcpSdu.xBytes' | cut -d "\\"" -f4
    ${rc2}    ${output2}    Run And Return Rc And Output
    ...    grep -A 12 ${record_name} ${PCMD_records_file_path} | grep -w 'sumOfPdcpSdu.xBytesDiscarded' | cut -d "\\"" -f4
    @{list_of_all_sumOfPdcpSduTxBytes}    Split String    ${output1}    \n
    @{list_of_all_sumOfPdcpSduTxBytesDiscarded}    Split String    ${output2}    \n
    ${sum_of_sumOfPdcpSduTxBytes}            Set Variable    0
    ${sum_of_sumOfPdcpSduTxBytesDiscarded}    Set Variable    0
    FOR    ${sumOfPdcpSduTxBytes}    IN    @{list_of_all_sumOfPdcpSduTxBytes}
        ${sumOfPdcpSduTxBytes}    Convert To Integer    ${sumOfPdcpSduTxBytes}
        ${sum_of_sumOfPdcpSduTxBytes}    Evaluate    ${sum_of_sumOfPdcpSduTxBytes} + ${sumOfPdcpSduTxBytes}
    END
    FOR    ${sumOfPdcpSduTxBytesDiscarded}    IN    @{list_of_all_sumOfPdcpSduTxBytesDiscarded}
        ${sumOfPdcpSduTxBytesDiscarded}    Convert To Integer    ${sumOfPdcpSduTxBytesDiscarded}
        ${sum_of_sumOfPdcpSduTxBytesDiscarded}    Evaluate    ${sum_of_sumOfPdcpSduTxBytesDiscarded} + ${sumOfPdcpSduTxBytesDiscarded}
    END
    ${ReporteddBytes_PMcounter}    Evaluate    ${ReporteddBytes_PMcounter} * 1000
    Compare Values With A Margin    ${sum_of_sumOfPdcpSduTxBytes}    ${ReporteddBytes_PMcounter}    0.5
    Should Be Equal    ${sum_of_sumOfPdcpSduTxBytesDiscarded}    ${DiscardedBytes_PMcounter}

Get DL Discarded Bytes From PM Counters
    [Arguments]    ${counters}    ${counters_path}
    ${first_counter_value_in_kB}    ta5g_pm_counters.Get Pm Counter Value    ${counters}[0]    ${PM_MOID}    ${counters_path}
    ${DISCARDED_BYTES_DL}     Evaluate    ${first_counter_value_in_kB}[0] * 1000
    @{other_counters_in_B}     Get Slice From List     ${counters}     1     -1
    FOR    ${counter}    IN    @{other_counters_in_B}
        ${counter_value}    ta5g_pm_counters.Get Pm Counter Value    ${counter}    ${PM_MOID}    ${counters_path}
        ${DISCARDED_BYTES_DL}    Evaluate    ${DISCARDED_BYTES_DL} + ${counter_value}[0]
    END
    RETURN    ${DISCARDED_BYTES_DL}

Get UL Discarded Bytes
    [Arguments]    ${counters}    ${counters_path}    ${syslog_filepath}=${dcap_files}[syslog]
    ${packet_size}    Set Variable    1250
    ${NSA_DISCARDED_BYTES_UL}    ta5g_pm_counters.Get Pm Counter Value      ${counters}[0]     ${PM_MOID}    ${counters_path}
    ${NSA_DISCARDED_BYTES_UL}    Set Variable    ${NSA_DISCARDED_BYTES_UL}[0]
    FOR    ${syslog}    IN    @{syslog_filepath}
        ${cmd}    Set Variable    grep "PDU with the same SN already in queue" ${syslog} | wc -l
        ${rc}    ${output}    Run And Return Rc And Output    ${cmd}
        ${NSA_DISCARDED_BYTES_UL}    Evaluate    ${NSA_DISCARDED_BYTES_UL} + (${output} * ${packet_size})
    END
    RETURN    ${NSA_DISCARDED_BYTES_UL}

Prepare And Verify Sequence Of Records In Existing Collection
    [Arguments]    ${recordsAmount}    ${record_name}    ${collection}
    ${PCMD_Seq}    Create List
    FOR    ${record}    IN RANGE    ${recordsAmount}-1
        ${prepared_dict}   Create Dictionary    &{${record_name}_EM0}
        Append To List     ${PCMD_Seq}    ${prepared_dict}
    END
    Append To List     ${PCMD_Seq}    ${${record_name}_EM1}
    Verify PCMD Records Sequence in Collection    ${collection}    ${PCMD_Seq}
