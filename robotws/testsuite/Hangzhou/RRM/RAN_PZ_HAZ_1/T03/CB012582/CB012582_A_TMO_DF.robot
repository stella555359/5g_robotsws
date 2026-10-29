*** Settings ***
Documentation
...   author: Dong Feng
...   contact: tony.1.dong@nokia-sbell.com
...   This is CB012582-A testing robot case on TMO configuration
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}          ${127}
${PA_MinValue}          ${0}
${PA_NormalValue}       ${5}
${PA_NormalValue2}      ${20}


*** Test Cases ***
CB012582_A_4_SA Intra-gNB Intra-DU Inter-Freq HO Interruption time Target Range
    [Documentation]    author:dong feng
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB012582_Target
    Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
#    Start Capture Emil Log By VM dcap    bts_index=${0}
    sleep    10s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    10s
    SA HO from 887 NR Cell_22 to NR Cell_2
    sleep    30s
    Unblock Other SA Cells
#    ${log_path}    Stop Emil Log Collection    bts_index=${0}
#    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012582

CB012582_A_3_SA Intra-gNB Intra-DU Intra-Freq HO Interruption time High Range
    [Documentation]    author:dong feng
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB012582_High
    ${rule1}    Catenate
    ...    Distname: MRBTS-887/NRBTS-887/NRCELL-2;
    ...    Counter: M55379C00004;
    ...    Counter rule: max(M55379C00004)>0;

    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
    Start Capture Emil Log By VM dcap    bts_index=${0}
    sleep    10s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    10s
    SA HO from 887 NR Cell_22 to NR Cell_2
    sleep    200s
    Unblock Other SA Cells
    ${log_path}    Stop Emil Log Collection    bts_index=${0}
    Sleep    10 min    reason=wait for counter ready
    Counter Check CB012582

CB012582_A_2_SA Intra-gNB Intra-DU Intra-Freq HO Interruption time Moderate Range
    [Documentation]    author:dong feng
    [Tags]    10_5_UTESRAN001T887    SCF_10_5_UTESRAN001T887_CB012582_Moderate
    ${rule1}    Catenate
    ...    Distname: MRBTS-887/NRBTS-887/NRCELL-2;
    ...    Counter: M55379C00005;
    ...    Counter rule: max(M55379C00005)>0;
 #   ${rule2}    Catenate
 #   ...    Distname: MRBTS-887/NRBTS-887/NRCELL-2;
 #   ...    Counter: M55380C00004;
 #   ...    Counter rule: max(M55380C00004)>0;

    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Lock other unused SA cells
    Adjust signal of BTS887 NR CELL22 case2
#    Start Capture Emil Log By VM dcap    bts_index=${0}
    sleep    10s
    AT Trigger UE Attach      index_of_yaml=${1}
    sleep    10s
    SA HO from 887 NR Cell_22 to NR Cell_2
    sleep    200s
    Unblock Other SA Cells
#    ${log_path}    Stop Emil Log Collection    bts_index=${0}
    Counter Check CB012582


*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
#    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
#    Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

AT Trigger UE Attach
    [Documentation]    send command by AT cmd,will auto find the ue type
    [Arguments]    ${ue_index}=${0}    ${index_of_yaml}=${0}
    Log to console    Attach ue ${index_of_yaml}
    ${UE_TYPE}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${UE_TYPE}    ${ue_type}
    run keyword    ${UE_TYPE}.Prepare UE    ue_index=${ue_index}    index_of_yaml=${index_of_yaml}
    Wait Until Keyword Succeeds   3x   1min    ${UE_TYPE}.UE Attach    ue_index=${ue_index}
    ...    index_of_yaml=${index_of_yaml}
    Sleep    40s     msg=wait for ue attach success


Adjust signal of BTS887 NR CELL22
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_NormalValue2}

HO from BTS887 NR Cell_22 to NR Cell_2
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}


Lock other unused SA cells
    Log To Console    Lock other unused cells
    COAM_Admin.Block_CELL    global_cell_id=1 41 25    cell_type=nr    connection=COAM_0
    sleep    20s

Unblock Other SA Cells
    Log To Console    Unblock other unused cells
    COAM_Admin.unBlock_CELL    global_cell_id=1 41 25    cell_type=nr    connection=COAM_0
    Sleep    15s

Adjust signal of BTS887 NR CELL22 case2
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_MinValue}

SA HO from 887 NR Cell_22 to NR Cell_2
    Log    Intra Handover start
    ${increase_port_list}    Get Attenuation port    RU_id=${5}    gnb_id=${0}
    ${decrease_port_list}    Get Attenuation port    RU_id=${4}    gnb_id=${0}
    ${increase_value_list}    Create List    ${5}     ${10}    ${15}    ${20}    ${25}
    ${decrease_value_list}    Create List    ${63}    ${0}    ${0}    ${0}    ${0}
    ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${4}
    Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}
    sleep    15s

Counter Check CB012582
    Log To Console    Check related counters for CB012582 TMO configuration
    ${rule1}    Catenate
    ...    Distname: MRBTS-887/NRBTS-887/NRCELL-2;
    ...    Counter: M55379C00006;
    ...    Counter rule: max(M55379C00006)>0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-887/NRBTS-887/NRCELL-2;
    ...    Counter: M55385C00006;
    ...    Counter rule: max(M55385C00006)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    bts_index=0
    ...    counter_rule=${rule_list}
    Sleep    10 min    reason=wait for counter ready
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb    bts_index=0
    Log To Console    ${value1}