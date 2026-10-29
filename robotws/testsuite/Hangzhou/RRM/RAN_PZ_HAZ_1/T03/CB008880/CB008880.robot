*** Settings ***
Documentation
...   author: yahong.liu
...   contact: yahong.liu@nokia-sbell.com
...   this is a robot case about CB008880
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_NormalValue}        ${1}
${PA_CA}                 ${25}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${UE_IP}                 10.108.164.162
# ${DEBUG_MODE}            ${TRUE}
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
${cell111_file_index}      0
@{condition_cell_111}      lcrId    ==    111
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_6331}
${dist_name}               MRBTS-10787/LNBTS-10787/NRDCDPR-0
@{condition_dl}    scheduledBytesPerBearer    >    0



*** Test Cases ***
Case3_Reconfiguration_of_existing_LTE_or_NR_cells_addition_of_cells_or_deletion_of_cells_from_WEBEM
    [Documentation]    author:yahong.liu
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB008880_case03
    AT.Prepare UE    ue_index=${0}    index_of_yaml=${0}
    Start Multi Bts Log
    Change Commission To Lock LNCell_22 and LNCell_23 for BTS0
    Unblock BTS10787 NRCell_111
    AT.UE Attach
    sleep    20s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=1200    traffic=200.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}    index_of_yaml=${0}


    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55319C12007;
    ...         Counter rule: max(M55319C12007)>0
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    200s
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    sleep    20s
    Remove LTE cell_23

    ${rule1}    Catenate
    ...         Distname: MRBTS-10787/NRBTS-11436;
    ...         Counter: M55319C12007;
    ...         Counter rule: min(M55319C12007)>0
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    200s
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # ${filter_qos7_values}    Check 5QI7 on BTS0
    # gnb_tool.prepare_gnb_tool
    # Capture Tti log with Gnb Tool For BTS0 NRCell_111
    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=111

    # Capture Tti log with Gnb Tool For BTS0 NRCell_111 During LTECELL Delete
    # 5QI7 Traffic Check DL    lcid=${filter_qos7_values}[0]    cell_ids=111

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Change Commission To Unlock cell
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Change Commission To Lock LNCell_22 and LNCell_23 for BTS0
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0
    COAM_Admin.lock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-23
    ...    connection=COAM_0

Unblock BTS10787 NRCell_111
    Log To Console    Unblock BTS10787 NRCell_111
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

5QI7 Traffic Check DL
    [Arguments]    ${lcid}    ${cell_ids}=111
    Traffic Check DL Scheduled    lcid=${lcid}    cell_ids=${cell_ids}

Traffic Check DL Scheduled
    [Arguments]    ${lcid}    ${cell_ids}=111
    @{csv_file_list}    csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
    Sort List    ${csv_file_list}
    @{cell_list}    Split String   ${cell_ids}    ,
    FOR   ${cell_id}    IN    @{cell_list}
        ${file_index1}    Set Variable    ${cell${cell_id}_file_index}
        # cell 1 in file0
        ${path1}    Set Variable    ${csv_file_list}[${file_index1}]
        @{condition_lcid}    Create List    lcId    ==    ${lcid}
        # dl traffic sch conditon
        @{conditions_1}    Create List
        ...    ${condition_cell_${cell_id}}
        ...    ${condition_lcid}
        ...    ${condition_dl}
        ${matching_rows_tbs}    ${row_nums}    process_csv.filter_rows_with_conditions_from_csv_file
        ...    ${path1}
        ...    ${conditions_1}
        Should Not Be Empty    ${matching_rows_tbs}
    END

Check 5QI7 on BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "qosId\=7" | grep -av grep
    Should Contain    ${ret}    qosId\=7
    ${matches}    Get Regexp Matches    ${ret}    lcId\=\\d+
    Log    ${matches[-1]}
    ${matches_nums}    Create List
    FOR    ${match}    IN    {matches}
        ${matches_num}    Get Regexp Matches     ${matches[-1]}    \\d+
        Append to List    ${matches_nums}    ${matches_num}[0]
    END
    [Return]    ${matches_nums}

Capture Tti log with Gnb Tool For BTS0 NRCell_111
    [Arguments]    ${t_time}=4    ${cell_tti}=111
    Log To Console    start to capture tti
    gnb_tool.start_to_capture_bip_log_with_gnb_tool
    ...    log_dire=${TEST_LOG_DIRECTORY}
    ...    host=${BTS0_PC_INFO.Host}
    ...    dest_ip=10.56.5.134
    ...    add_options=-t ${t_time} -C ${cell_tti}
    Sleep    4s
    Log To Console    stopping bip_log with gnb_tool
    # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
    ${log_path}    gnb_tool.stop_bip_log_with_gnb_tool
    Log To Console    stopped gnb tools
    Set Test Variable    ${log_path}     ${log_path}

Capture Tti log with Gnb Tool For BTS0 NRCell_111 During LTECELL Delete
    [Arguments]    ${t_time}=4    ${cell_tti}=111
    Log To Console    start to capture tti
    gnb_tool.start_to_capture_bip_log_with_gnb_tool
    ...    log_dire=${TEST_LOG_DIRECTORY}
    ...    host=${BTS0_PC_INFO.Host}
    ...    dest_ip=10.56.5.134
    ...    add_options=-t ${t_time} -C ${cell_tti}
    Remove LTE cell_23
    Log To Console    stopping bip_log with gnb_tool
    # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
    ${log_path}    gnb_tool.stop_bip_log_with_gnb_tool
    Log To Console    stopped gnb tools
    Set Test Variable    ${log_path}     ${log_path}

Remove LTE cell_23
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    coam.perform_delta_recommissioning
    ...    delta_file=/home/ute/MN/UTE/robotws/commissionings/RRM/SRAN_5G/10_5_UTESRAN001T10787/CB008880_remove_LTE_cell.json
    ...    skip_parameter_relation_errors=${false}
    ...    should_activate=${true}
    ...    timeout=${90}
    ...    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

Stop All Bts Log
    Stop All BTSLog And Download to Local

Change Commission To Unlock cell
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-22
    ...    connection=COAM_0
    COAM_Admin.unlock    dist_name=MRBTS-10787/LNBTS-10787/LNCEL-23
    ...    connection=COAM_0