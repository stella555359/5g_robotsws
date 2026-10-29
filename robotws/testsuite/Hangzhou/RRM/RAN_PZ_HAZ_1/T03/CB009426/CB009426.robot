*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB009426-SR
# Resource          ../Resources/common_resource.robot
# Suite Setup       Common MultiBTS Suite Setup For RRM
# Suite Teardown      Common MutliBTS Suite Teardown For RRM
# Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
# Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
# Force Tags
# # ...                     CRT
# ...                     RAN_5G
# ...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
# ...                     SBTS00
# # ...                     STATE_SW_UPLOADED
# ...                     STATE_SKIP_AGENT
# ...                     CA_RAN_PZ_HAZ_1
# ...                     RAN_PZ_HAZ1_SG07_ST_RRM
# ...                     TA_LEVEL_22
# *** Variables ***
# ${DEBUGMODE}                        ${False}
# ${PA_MaxValue}           ${60}
# ${PA_NormalValue}        ${10}
# ${PA_HoValue}            ${50}
# ${PA_MinValue}           ${0}
# ${Handover_MAX_Value}    ${60}
# ${Handover_MIN_Value}    ${0}
# ${BBMOD_Index}           ${2}
# ${overlap_len}           ${7}
# ${hp_reserve_len}        ${5}
# ${check_lp_amount}       ${80}
# ${pci_of_cell2}          ${984}
# ${pci_of_cell5}          ${5}
# ${MRBTSID}               11688
# ${NRBTSID}               11688
# @{Selected_Colums}    sfn    slot   startPrb    rat0Bitmap    txNumber
# &{fault_4527}              faultId=${4527}
# &{fault_4602}              faultId=${4602}
# &{fault_4741}              faultId=${4741}
# &{fault_61618}             faultId=${61618}
# @{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}


# *** Test Cases ***
# CB009426-A_Enable_Disable_Randomized_RBG_allocations_in_one_BWP
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB009426_A
#     @{cell_list}=    Create List    5    6
#     Change Commission To Lock cell    @{cell_list}
#     # ADB.Prepare UE
#     # ADB.UE Detach
#     Attach UE to AZHL_41
#     Attach UE By AT
#     sleep    2s
#     Wait Until Keyword Succeeds    8x    2min    Set APN by ADB
#     # ADB.UE Attach
#     sleep    30s
#     ${dl_server1}    Connect To IperfServer From Appservers
#     Start DL traffic By Iperf    time=120    traffic=30.00M    dl_server=${dl_server1}
#     Cap DL Traffic
#     Log To Console    start to decode
#     @{filterOut_list}=    Create List    ${EMPTY}
#     csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
#     ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=rat0Bitmap
#     ...    filter_value=@{filterOut_list}    parameter=@{Selected_Colums}
#     ...    condition=!=    support_empty_value=False
#     Check Func CB009426    ${rows}

# CB009426-B_Randomized_RBG_allocations_in_cell_with_two_dedicated_BWPs
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB009426_B
#     @{cell_list}=    Create List    1    2    6
#     Change Commission To Lock cell    @{cell_list}
#     # ADB.Prepare UE
#     # ADB.UE Detach
#     Attach UE to GNB_41
#     Attach UE By AT
#     sleep    2s
#     Wait Until Keyword Succeeds    8x    2min    Set APN by ADB
#     # ADB.UE Attach
#     sleep    30s
#     ${dl_server1}    Connect To IperfServer From Appservers
#     Start DL traffic By Iperf    time=120    traffic=30.00M    dl_server=${dl_server1}
#     Cap DL Traffic
#     Log To Console    start to decode
#     @{filterOut_list}=    Create List    ${EMPTY}
#     csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
#     ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=rat0Bitmap
#     ...    filter_value=@{filterOut_list}    parameter=@{Selected_Colums}
#     ...    condition=!=    support_empty_value=False
#     Log To Console    check data
#     Check Func CB009426 with two bwp    ${rows}

# CB009426-C_Randomized_RBG_allocations_in_one_BWP_with_CB008955_enabled
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB009426_C
#     @{cell_list}=    Create List    1    2    6
#     Change Commission To Lock cell    @{cell_list}
#     # ADB.Prepare UE
#     # ADB.UE Detach
#     Attach UE to GNB_41
#     # ADB.UE Attach
#     Attach UE By AT
#     sleep    2s
#     Wait Until Keyword Succeeds    8x    2min    Set APN by ADB
#     sleep    30s
#     ${dl_server1}    Connect To IperfServer From Appservers
#     Start DL traffic By Iperf    time=120    traffic=30.00M    dl_server=${dl_server1}
#     Cap DL Traffic
#     Log To Console    start to decode
#     @{filterOut_list}=    Create List    ${EMPTY}
#     csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
#     ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=rat0Bitmap
#     ...    filter_value=@{filterOut_list}    parameter=@{Selected_Colums}
#     ...    condition=!=    support_empty_value=False
#     Check Func CB009426 interact CB008955    ${rows}

# CB009426-D_ Randomized_RBG_allocations_with_CB008955_enabled_two_BWPs_configured
#     [Documentation]    author:keli
#     [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB009426_D    SWCONFIG_10_5_UTESRAN001T11688
#     @{cell_list}=    Create List    1    2    6
#     Change Commission To Lock cell    @{cell_list}
#     Attach UE to GNB_41
#     Attach UE By AT
#     sleep    2s
#     Wait Until Keyword Succeeds    8x    2min    Set APN by ADB
#     sleep    30s
#     ${dl_server1}    Connect To IperfServer From Appservers
#     Start DL traffic By Iperf    time=360    traffic=30.00M    dl_server=${dl_server1}
#     sleep    2s
#     gnb_tool.prepare_gnb_tool
#     Capture Tti log with Gnb Tool    t_time=5    cell_tti=5
#     Log To Console    start to decode
#     @{filterOut_list}=    Create List    ${EMPTY}
#     csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
#     ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=rat0Bitmap
#     ...    filter_value=@{filterOut_list}    parameter=@{Selected_Colums}
#     ...    condition=!=    support_empty_value=False
#     Check Func CB009426 interact CB008955 with PS BWP    ${rows}

# *** Keywords ***
# Case Setup
#     Log To Console    Case Setup
#     Log To Console    Set PA to max
#     Init Attenuation All Max    max_value=${PA_MaxValue}

# Case Teardown
#     Log To Console    Case Teardown
#     Run Keyword And Ignore Error    Restore APN by ADB
#     Run Keyword And Ignore Error    Change Commission To Unlock cell
#     Run Keyword And Ignore Error    AT.UE Detach
#     Run Keyword And Ignore Error    Disconnect All VM

# Cap DL Traffic
#     Connect All VM
#     # ${ue_ip}    ADB.Get UE IP
#     gnb_tool.prepare_gnb_tool
#     sleep   1s
#     Log To Console    start to capture tti
#     gnb_tool.Start To Capture Bip Log With Gnb Tool
#     ...    log_dire=${TEST_LOG_DIRECTORY}
#     ...    host=${BTS0_PC_INFO.Host}
#     ...    dest_ip=10.106.230.21
#     ...    add_options=-t 8 -c ${BBMOD_Index}
#     # gnb_tool.start_to_capture_tti_log_with_gnb_tool
#     # ...    log_dire=${TEST_LOG_DIRECTORY}
#     # ...    host=${BTS0_PC_INFO.Host}
#     # ...    dest_ip=10.106.230.21
#     Sleep    4s
#     Log To Console    gnb_tool.stop_bip_log_with_gnb_tool
#     # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
#     ${log_path}    gnb_tool.stop_bip_log_with_gnb_tool
#     Set Test Variable    ${log_path}     ${log_path}


# Capture Tti log with Gnb Tool
#     [Arguments]    ${t_time}=3    ${cell_tti}=1,2,3
#     Log To Console    start to capture tti
#     gnb_tool.start_to_capture_bip_log_with_gnb_tool
#     ...    log_dire=${TEST_LOG_DIRECTORY}
#     ...    host=${BTS0_PC_INFO.Host}
#     ...    dest_ip=10.106.230.21
#     ...    add_options=-t ${t_time} -C ${cell_tti}
#     Sleep    4s
#     Log To Console    stopping tti and bip log with gnb_tool
#     # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
#     ${log_path}    gnb_tool.stop_bip_log_with_gnb_tool
#     Log To Console    stopped gnb tools
#     Set Test Variable    ${log_path}     ${log_path}

# Attach UE to GNB_41
#     Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${PA_MinValue}

# Attach UE to AZHL_41
#     Modify Attenuation For One RRU Of One Site    ru_id=${7}    gnb_id=${0}    value=${PA_MinValue}

# Change Commission To Lock cell
#     [Arguments]    @{cell_list}
#     FOR   ${cell_i}    IN    @{cell_list}
#         BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
#         ...    distname_id=NRCELL-${cell_i}    need_verify=yes
#     END

# Change Commission To Unlock cell
#     @{cell_list}=    Create List    1    2    5    6
#     FOR   ${cell_i}    IN    @{cell_list}
#         BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
#         ...    distname_id=NRCELL-${cell_i}    need_verify=yes
#     END

# Check Bitmap
#     FOR   ${item}    IN    ${test_list}
#         # ${result}=    Convert To Binary    16384
#         ${Bitmap}    Convert Bitmap To Binary    ${item}
#         Check Is Full Used    ${Bitmap}
#     END

# Check Func CB009426
#     [Arguments]    ${rows}
#     [Documentation]    check rbg order
#     ${count_for_valid_check}=    Set Variable    ${0}
#     ${loop_t}    Get Length    ${rows}[startPrb]
#     ${loop_t}=    Run Keyword If    ${loop_t}>${50}
#     ...    Set Variable    ${50}
#     ...    ELSE    Set Variable    ${loop_t}
#     FOR    ${index}    IN RANGE    ${loop_t}
#         Log    ${rows}[startPrb][${index}]
#         ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#         Log    ${res}
#         Continue For Loop If    '${res}'=='111111111111111111'
#         Log    ${rows}[sfn][${index}]
#         Log    ${rows}[slot][${index}]
#         ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#         ${slot}    Convert To Integer   ${rows}[slot][${index}]
#         ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#         ${len}=    Get Length    ${res}
#         @{bit_list}    Evaluate    list('${res}')
#         ${x_offset_index}    Evaluate    ${18}-${len}
#         ${x}    Count Values In List	${bit_list}    1
#         Log    ${x}
#         ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell2}
#         ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#         ...    bitmap=${bitmap}
#         Log    ${used_rbg_order_list}
#         ${index2}    Get Index From List    ${rbg_order_list}    ${x}
#         ${f_index}    Evaluate    ${index2}-${x_offset_index}
#         Should Be True    '${bit_list}[${f_index}]'=='1'
#         ${count_for_valid_check}=    Evaluate    ${count_for_valid_check} + ${1}
#     END
#     Should Be True    ${count_for_valid_check}>0

# Check Func CB009426 with two bwp
#     [Arguments]    ${rows}
#     [Documentation]    second bwp 40Mhz 14
#     # Log    check CB009426 with two bwp
#     ${loop_t}    Get Length    ${rows}[startPrb]
#     ${loop_t}=    Run Keyword If    ${loop_t}>${80}
#     ...    Set Variable    ${80}
#     ...    ELSE    Set Variable    ${loop_t}
#     FOR    ${index}    IN RANGE    ${loop_t}
#         Log    ${rows}[startPrb][${index}]
#         ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#         ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#         ${tx_num}    Convert To Integer   ${rows}[txNumber][${index}]
#         Log    ${res}
#         Continue For Loop If    '${res}'=='111111111111111111'
#         Continue For Loop If     ${tx_num}>${1}
#         Run Keyword If    ${bitmap}<${2048}    Check with Second Bwp Not Used    ${rows}    ${index}
#         Run Keyword If    ${bitmap}>=${2048}    Check with Second Bwp Used    ${rows}    ${index}
#     END

# Check with Second Bwp Not Used
#     [Arguments]    ${rows}    ${index}
#     Log To Console    Check with Second Bwp Not Used
#     Log    ${rows}[sfn][${index}]
#     Log    ${rows}[slot][${index}]
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#     ${slot}    Convert To Integer   ${rows}[slot][${index}]
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${len}=    Get Length    ${res}
#     @{bit_list}    Evaluate    list('${res}')
#     ${x_offset_index}    Evaluate    ${18}-${len}
#     ${x}    Count Values In List	${bit_list}    1
#     Log    ${x}
#     ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#     ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#     ...    bitmap=${bitmap}
#     Log    ${used_rbg_order_list}
#     ${count_for_first_bwp}=    Set Variable    ${0}
#     ${count_for_sec_bwp}=    Set Variable    ${0}
#     FOR    ${count_index}    IN RANGE    ${x}
#         ${index3}    Get Index From List    ${rbg_order_list}    ${count_index+1}
#         ${count_for_sec_bwp}=    Run Keyword If    ${index3}<=${overlap_len}
#         ...    Evaluate    ${count_for_sec_bwp} + ${1}
#         ...    ELSE    Set Variable    ${count_for_sec_bwp}
#         ${count_for_first_bwp}=    Run Keyword If    ${index3}>${overlap_len}
#         ...    Evaluate    ${count_for_first_bwp} + ${1}
#         ...    ELSE    Set Variable    ${count_for_first_bwp}
#     END
#     Run Keyword If    ${count_for_first_bwp}<${x}
#     ...    Should Be True    ${count_for_sec_bwp}>0

# Check with Second Bwp Used
#     [Arguments]    ${rows}    ${index}
#     Log To Console    Check with Second Bwp Used
#     Log    ${rows}[sfn][${index}]
#     Log    ${rows}[slot][${index}]
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#     ${slot}    Convert To Integer   ${rows}[slot][${index}]
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${len}=    Get Length    ${res}
#     @{bit_list}    Evaluate    list('${res}')
#     ${x_offset_index}    Evaluate    ${18}-${len}
#     ${x}    Count Values In List	${bit_list}    1
#     Log    ${x}
#     ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#     ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#     ...    bitmap=${bitmap}
#     Log    ${used_rbg_order_list}
#     ${slice_len}    Evaluate    ${overlap_len}-${x_offset_index}
#     ${not_overlap_part}    Get Slice From List    ${bit_list}    ${slice_len}
#     ${y}    Count Values In List	${not_overlap_part}    1
#     Should Be True    ${y} == ${10}
#     ${is_prbg_used}    Is Partial RBG Used    bitmap=${bitmap}
#     Should Not Be True    ${is_prbg_used}
#     # Should Be True    '${bit_list}[${-1}]'=='0'

# Check Func CB009426 interact CB008955
#     [Arguments]    ${rows}
#     [Documentation]    check rbg order
#     Log    check CB009426 interact CB008955
#     ${count_for_valid_check}=    Set Variable    ${0}
#     ${loop_t}    Get Length    ${rows}[startPrb]
#     ${loop_t}=    Run Keyword If    ${loop_t}>${100}
#     ...    Set Variable    ${100}
#     ...    ELSE    Set Variable    ${loop_t}
#     FOR    ${index}    IN RANGE    ${loop_t}
#         Log    ${rows}[startPrb][${index}]
#         ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#         ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#         ${slot}    Convert To Integer   ${rows}[slot][${index}]
#         ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#         ${tx_num}    Convert To Integer   ${rows}[txNumber][${index}]
#         Log    ${res}
#         Continue For Loop If    '${res}'=='111111111111111111'
#         Continue For Loop If     ${tx_num}>${1}
#         @{bit_list}    Evaluate    list('${res}')
#         ${hp_part}    Get Slice From List    ${bit_list}    ${13}    ${18}
#         ${is_prbg_used}    Is Partial RBG Used    bitmap=${bitmap}
#         Run Keyword If    ${is_prbg_used} == ${False}
#         ...    Check Func with No HP UE    ${rows}    ${index}
#         Run Keyword If    ${is_prbg_used} == ${True}
#         ...    Check Func with HP UE    ${rows}    ${index}
#         ${count_for_valid_check}=    Evaluate    ${count_for_valid_check} + ${1}
#     END
#     Should Be True    ${count_for_valid_check}>0

# Check Func CB009426 interact CB008955 with PS BWP
#     [Arguments]    ${rows}
#     Log    check CB009426 interact CB008955 with two bwp
#     ${count_for_valid_check}=    Set Variable    ${0}
#     ${loop_t}    Get Length    ${rows}[startPrb]
#     ${loop_t}=    Run Keyword If    ${loop_t}>${check_lp_amount}
#     ...    Set Variable    ${check_lp_amount}
#     ...    ELSE    Set Variable    ${loop_t}
#     FOR    ${index}    IN RANGE    0    ${loop_t}
#         Log    ${rows}[startPrb][${index}]
#         ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#         ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#         ${slot}    Convert To Integer   ${rows}[slot][${index}]
#         ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#         ${tx_num}    Convert To Integer   ${rows}[txNumber][${index}]
#         Log    ${res}
#         Continue For Loop If    '${res}'=='111111111111111111'
#         Continue For Loop If     ${tx_num}>${1}
#         @{bit_list}    Evaluate    list('${res}')
#         ${hp_part}    Get Slice From List    ${bit_list}    ${13}    ${18}
#         ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#         ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#         ...    bitmap=${bitmap}
#         ${is_prbg_used}    Is Partial RBG Used    bitmap=${bitmap}
#         Run Keyword If    ${is_prbg_used} == ${False}
#         ...    Check Func with No HP UE With Two Bwp    ${rows}    ${index}
#         Run Keyword If    ${is_prbg_used} == ${True}
#         ...    Check Func with HP UE With Two Bwp    ${rows}    ${index}
#         ${count_for_valid_check}=    Evaluate    ${count_for_valid_check} + ${1}
#     END
#     Should Be True    ${count_for_valid_check}>0

# Check Func with No HP UE
#     [Arguments]    ${rows}    ${index}
#     [Documentation]    for case2 check
#     Log To Console    Check Func with No HP UE
#     # ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#     ${slot}    Convert To Integer   ${rows}[slot][${index}]
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#     ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#     ...    bitmap=${bitmap}
#     Log    ${used_rbg_order_list}
#     @{bit_list}    Evaluate    list('${res}')
#     ${len}=    Get Length    ${res}
#     ${x}    Count Values In List	${bit_list}    1
#     ${hp_part}    Get Slice From List    ${bit_list}    start=-5
#     ${y}    Count Values In List	${hp_part}    1
#     ${no_hp_part}    Get Slice From List    ${bit_list}    end=-5
#     ${z}    Count Values In List	${no_hp_part}    1
#     # no need to use reserved RBG
#     Run Keyword If    ${z}==${0}
#     ...    No HP Ue And No Need To Use Reserve RBG    ${x}    ${rbg_order_list}
#     # need to use reserved RBG
#     Run Keyword If    ${z}>${0}
#     ...    No HP Ue Used Reserve HP RBG

# Check Func with HP UE
#     [Arguments]    ${rows}    ${index}
#     [Documentation]    for case2 check cotiguous and partial used
#     Log To Console    Check Func with HP UE
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${is_prbg_used}    Is Partial RBG Used    bitmap=${bitmap}
#     Should Be True    ${is_prbg_used}
#     ${is_contigu_rbg_used}    Is RBG Contiguous Used    bitmap=${bitmap}
#     Should Be True    ${is_contigu_rbg_used}

# Check Func with No HP UE With Two Bwp
#     [Arguments]    ${rows}    ${index}
#     [Documentation]    for case4
#     Log To Console    Check Func with No HP UE
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     Run Keyword If    ${bitmap}<${2048}    Check with Second Bwp Not Used interact CB008955
#     ...    ${rows}    ${index}
#     Run Keyword If    ${bitmap}>${2048}    Check with Second Bwp Used interact CB008955
#     ...    ${rows}    ${index}

# Check with Second Bwp Not Used interact CB008955
#     [Arguments]    ${rows}    ${index}
#     Log To Console    Check with Second Bwp Not Used interact CB008955
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#     ${slot}    Convert To Integer   ${rows}[slot][${index}]
#     @{bit_list}    Evaluate    list('${res}')
#     ${no_ps_hp_part}    Get Slice From List    ${bit_list}    start=-11    end=-5
#     ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#     # ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#     # ...    bitmap=${bitmap}
#     # Log    ${used_rbg_order_list}
#     ${x}    Count Values In List	${bit_list}    1
#     ${count_for_hp_part}=    Set Variable    ${0}
#     ${count_for_no_hp_part}=    Set Variable    ${0}
#     ${count_for_ps_part}=    Set Variable    ${0}
#     FOR    ${count_index}    IN RANGE    0    ${x}
#         ${index2}    Get Index From List    ${rbg_order_list}    ${count_index+1}
#         ${count_for_hp_part}=    Run Keyword If    ${index2}>=${13}
#         ...    Evaluate    ${count_for_hp_part} + ${1}
#         ...    ELSE    Set Variable    ${count_for_hp_part}
#         ${count_for_no_hp_part}=    Run Keyword If    ${index2}<${13} and ${index2}>${6}
#         ...    Evaluate    ${count_for_no_hp_part} + ${1}
#         ...    ELSE    Set Variable    ${count_for_no_hp_part}
#         ${count_for_ps_part}=    Run Keyword If    ${index2}<${7}
#         ...    Evaluate    ${count_for_ps_part} + ${1}
#         ...    ELSE    Set Variable    ${count_for_ps_part}
#     END
#     Run Keyword If    ${count_for_no_hp_part}<${x}
#     ...    Should Be True    ${count_for_hp_part}>0 or ${count_for_ps_part}>0

# Check with Second Bwp Used interact CB008955
#     [Arguments]    ${rows}    ${index}
#     Log To Console    Check with Second Bwp Not Used interact CB008955
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     @{bit_list}    Evaluate    list('${res}')
#     ${no_ps_part}    Get Slice From List    ${bit_list}    start=-11
#     ${y}    Count Values In List	${no_ps_part}    1
#     Should Be True    ${y}==${10}

# Check Func with HP UE With Two Bwp
#     [Arguments]    ${rows}    ${index}
#     [Documentation]    for case4 8955 part check
#     Log To Console    Check Func HP UE with two bwp
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     Check Func with HP UE    ${rows}    ${index}

# Check Func with HP UE Reserve Part
#     [Arguments]    ${rows}    ${index}
#     Log To Console    Check Func with HP UE
#     Log    ${rows}[sfn][${index}]
#     Log    ${rows}[slot][${index}]
#     ${res}    Convert Bitmap To Binary    ${rows}[rat0Bitmap][${index}]
#     ${sfn}    Convert To Integer   ${rows}[sfn][${index}]
#     ${slot}    Convert To Integer   ${rows}[slot][${index}]
#     ${bitmap}    Convert To Integer   ${rows}[rat0Bitmap][${index}]
#     ${len}=    Get Length    ${res}
#     @{bit_list}    Evaluate    list('${res}')
#     ${x_offset_index}    Evaluate    ${18}-${len}
#     ${x}    Count Values In List	${bit_list}    1
#     Log    ${x}
#     ${rbg_order_list}    Calc Rbg Order    sfn=${sfn}    slot=${slot}    pci=${pci_of_cell5}
#     ${used_rbg_order_list}    Get Used Rbg List    order_list=${rbg_order_list}
#     ...    bitmap=${bitmap}
#     Log    ${used_rbg_order_list}
#     ${is_prbg_used}    Is Partial RBG Used    bitmap=${bitmap}
#     Should Be True    ${is_prbg_used}
#     ${is_contigu_rbg_used}    Is RBG Contiguous Used    bitmap=${bitmap}
#     Should Be True    ${is_contigu_rbg_used}
#     # Should Be True    '${used_rbg_order_list}[${x-1}]'=='18'

# No HP Ue And No Need To Use Reserve RBG
#     [Arguments]    ${x}    ${rbg_order_list}
#     [Documentation]    if not order some rbg index should be in hp part
#     Log To Console    No HP Ue And No Need To Use Reserve RBG
#     ${count_for_hp_part}=    Set Variable    ${0}
#     ${count_for_no_hp_part}=    Set Variable    ${0}
#     FOR    ${count_index}    IN RANGE    0    ${x}
#         ${index2}    Get Index From List    ${rbg_order_list}    ${count_index+1}
#         ${count_for_hp_part}=    Run Keyword If    ${index2}>=${13}
#         ...    Evaluate    ${count_for_hp_part} + ${1}
#         ...    ELSE    Set Variable    ${count_for_hp_part}
#         ${count_for_no_hp_part}=    Run Keyword If    ${index2}<${13}
#         ...    Evaluate    ${count_for_no_hp_part} + ${1}
#         ...    ELSE    Set Variable    ${count_for_no_hp_part}
#     END
#     Should Be True    ${count_for_hp_part}>0

# No HP Ue Used Reserve HP RBG
#     Log    No HP Ue need use reserved HP part

# Calc Rbg Order
#     [Arguments]    ${sfn}    ${slot}    ${pci}
#     ${order_list}    rbg_order.calc_rbg_order    bwp_width=${273}    rat=TDD    slot_num=${20}    pci=${pci}
#     ...    sfn=${sfn}   slot=${slot}
#     [Return]    ${order_list}

# Get Used Rbg List
#     [Arguments]    ${order_list}    ${bitmap}
#     ${order_list}    rbg_order.rbg_order_check    rbg_order_list=${order_list}    rat0bitmap=${bitmap}
#     [Return]    ${order_list}

# Convert Bitmap To Binary
#     [Arguments]    ${Bitmap}
#     ${result}=    Convert To Binary    ${Bitmap}
#     [Return]    ${result}

# Is Partial RBG Used
#     [Arguments]    ${bitmap}
#     ${is_prbg_used}    rbg_order.is_last_rbg_used    rat0bitmap=${bitmap}
#     [Return]    ${is_prbg_used}

# Is RBG Contiguous Used
#     [Arguments]    ${bitmap}
#     ${is_contigu_rbg_used}    rbg_order.is_contiguous_rbg_used    rat0bitmap=${bitmap}
#     [Return]    ${is_contigu_rbg_used}

# Check Is Full Used
#     [Arguments]    ${Bitmap}
#     Run keyword if    ${Bitmap} == "111111111111111111"    set test variable    ${res}    True
#     ...    ELSE    set test variable    ${res}    False
#     [Return]    ${res}

# Set APN by ADB
#     ADB.Prepare UE
#     Log to Console    Start to set apn
#     Sleep    10s
#     Qualcomm.Set APN By Uiauto    apn=stdata1
#     ${ret}=    Qualcomm.Get APN By Uiauto
#     Should Contain    ${ret}    stdata1

# Restore APN by ADB
#     ADB.Prepare UE
#     Log to Console    Start to set apn
#     Sleep    10s
#     Qualcomm.Set APN By Uiauto    apn=mdrb.nokia.com
#     ${ret}=    Qualcomm.Get APN By Uiauto
#     Should Contain    ${ret}    mdrb.nokia.com