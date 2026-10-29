*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB009059-SR
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
# ${DEBUGMODE}                        ${True}
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}
${CA_MAX_Value}          ${60}
${CA_NormalValue}        ${8}
${CA_MIN_Value}          ${0}
${overlap_len}           ${7}
${hp_reserve_len}        ${5}
${check_lp_amount}       ${80}
${pci_of_cell2}          ${984}
${pci_of_cell5}          ${5}
${BBMOD_Index}           ${2}
${cell_tti}              1,2,3
${Cell1_ID}              191496193
${Cell2_ID}              191496194
${Cell3_ID}              191496195
${Cell4_ID}              191496196
${Cell5_ID}              191496197
${Cell6_ID}              191496198
${1_Value}               10
${10M_Value}             10000000
${MRBTSID}               11688
${NRBTSID}               11688
@{Selected_Colums}    sfn    slot   startPrb    rat0Bitmap    txNumber
${dist_name}            MRBTS-11688/NRBTS-11688
${Feature_parameter}    actDrbProfileForCellAggrLevel
${spark_iperf_server}      10.108.233.142
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
${cell1_file_index}       0
${cell2_file_index}       1
${cell3_file_index}       0
@{condition_cell_1}       lcrId    ==    1
@{condition_cell_2}       lcrId    ==    2
@{condition_cell_3}       lcrId    ==    3
@{condition_dl}    scheduledBytesPerBearer    >    0
@{condition_ul}    rcvdBytes    >    0
${step_cmd}    proc node pcf 1 policy-update-notify all

*** Test Cases ***
case30_CB008126 Interacts with CB009059_5QI modification with Not CA eligible DRB profile
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008126_B7_case30
    Unblock BTS11688 NRCell_2
    AT.Prepare UE
    AT.UE Attach
    sleep    10s
    Wait Until Keyword Succeeds    8x    2min    Set APN by ADB as stmdrb1106
    AT.UE Detach

    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_26203_on.pcf

    Start Multi Bts Log

    AT.UE Attach
    sleep    15s
    Unblock BTS11688 NRCell_1

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=7200    traffic=500.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    200s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # gnb_tool.prepare_gnb_tool
    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=1,2

    Sleep    10s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    Sleep    200s

    ${rule3}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02008;
    ...         Counter rule: max(M55310C02008)>0
    ${rule4}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02008;
    ...         Counter rule: max(M55310C02008)==0
    ${rule_list}    Create List    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    sleep    200s

    ${value2}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=2
    # Traffic Check NO DL for BTS0    cell_ids=1

    Sleep    10s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI8_to_5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    Sleep    200s

    ${rule5}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule6}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule_list}    Create List    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    sleep    200s

    ${value3}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=1,2


case31_CB008126 Interacts with CB009059_5QI modification with CA incompatible DRB profile
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008126_B7_case31
    Unblock BTS11688 NRCell_2
    AT.Prepare UE
    AT.UE Attach
    sleep    10s
    Wait Until Keyword Succeeds    8x    2min    Set APN by ADB as stmdrb1106
    AT.UE Detach

    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_26203_on.pcf
    Sleep    5s
    Start Multi Bts Log
    AT.UE Attach
    sleep    15s
    Unblock BTS11688 NRCell_1

    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    Sleep   5s


    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule2}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=7200    traffic=500.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    200s

    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # gnb_tool.prepare_gnb_tool
    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=1,2
    Sleep    5s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    Sleep    200s


    ${rule3}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02008;
    ...         Counter rule: max(M55310C02008)>0
    ${rule4}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02008;
    ...         Counter rule: max(M55310C02008)==0
    ${rule_list}    Create List    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    sleep    200s

    ${value2}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=2
    # Traffic Check NO DL for BTS0    cell_ids=1

    # Check Scell release

    Sleep    5s
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI8_to_5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}
    Sleep    200s

    ${rule5}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-2;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule6}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688/NRCELL-1;
    ...         Counter: M55310C02009;
    ...         Counter rule: max(M55310C02009)>0
    ${rule_list}    Create List    ${rule5}    ${rule6}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
    sleep    200s

    ${value3}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0


    # Capture Tti log with Gnb Tool For BTS0
    # sleep    2s
    # Traffic Check DL for BTS0    cell_ids=1,2


*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    Change Commission To Unlock cell
    Run Keyword And Ignore Error    Restore APN by ADB
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Set APN by ADB as stmdrb1106
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=stmdrb1106
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    stmdrb1106

Restore APN by ADB
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=stdata1
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    stdata1

Capture Tti log with Gnb Tool For BTS0
    [Arguments]    ${t_time}=4    ${cell_tti}=1,2
    Log To Console    start to capture tti
    gnb_tool.start_to_capture_bip_log_with_gnb_tool
    ...    log_dire=${TEST_LOG_DIRECTORY}
    ...    host=${BTS0_PC_INFO.Host}
    ...    dest_ip=10.106.230.21
    ...    add_options=-t ${t_time} -C ${cell_tti}
    Sleep    4s
    Log To Console    stopping bip_log with gnb_tool
    # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
    ${log_path}    gnb_tool.stop_bip_log_with_gnb_tool
    Log To Console    stopped gnb tools
    Set Test Variable    ${log_path}     ${log_path}

Unblock BTS11688 NRCell_2
    Log To Console    Unblock BTS11688 NRCell_2
    Modify Attenuation For One RRU Of One Site    ru_id=${7}    gnb_id=${0}    value=${PA_MinValue}

Unblock BTS11688 NRCell_1
    Log To Console    Unblock BTS11688 NRCell_1
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_MinValue}

Block BTS11688 NRCell_1
    Log To Console    Block BTS11688 NRCell_1
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_MaxValue}

Check Scell release
    Log To Console    Check Scell release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'Scell release cause: incompatibleDrbsToBeSetup' | grep -av grep
    Should Contain    ${ret}    Scell release cause: incompatibleDrbsToBeSetup

Traffic Check DL Scheduled
    [Arguments]    ${cell_ids}=1,2,3
    @{csv_file_list}    csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
    Sort List    ${csv_file_list}
    @{cell_list}    Split String   ${cell_ids}    ,
    FOR   ${cell_id}    IN    @{cell_list}
        ${file_index1}    Set Variable    ${cell${cell_id}_file_index}
        # cell 1 in file0
        ${path1}    Set Variable    ${csv_file_list}[${file_index1}]
        # @{condition_lcid}    Create List    lcId    ==    ${lcid}
        # dl traffic sch conditon
        @{conditions_1}    Create List
        ...    ${condition_cell_${cell_id}}
        # ...    ${condition_lcid}
        ...    ${condition_dl}
        ${matching_rows_tbs}    ${row_nums}    process_csv.filter_rows_with_conditions_from_csv_file
        ...    ${path1}
        ...    ${conditions_1}
        Should Not Be Empty    ${matching_rows_tbs}
    END

Traffic Check DL for BTS0
    [Arguments]    ${cell_ids}=1,2
    Traffic Check DL Scheduled    cell_ids=${cell_ids}


Traffic Check NO DL for BTS0
    [Arguments]    ${filter_values}
    ${tput_st}    ${v}    Run Keyword And Ignore Error
    ...    Traffic Check DL for BTS0    ${filter_values}
    Should Be True    "${tput_st}"=="FAIL"

