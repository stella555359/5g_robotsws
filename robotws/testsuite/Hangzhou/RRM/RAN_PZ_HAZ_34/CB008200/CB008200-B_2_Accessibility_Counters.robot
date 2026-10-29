*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008200-B

Force Tags  CA_5G_RRM
...    PY36
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Setup Env for test
...                            AND    Common UE parameter setup
...                            AND    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${0}
...                            AND    Wait Until Keyword Succeeds    3x    10s
...                                   Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    set apn dxdata2
...                                   ELSE IF    '${ue_type}' == 'qct_dx50'
...                                   choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}    ue_type=${ue_type}   ue_index=${0}
#...                                   Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2}
...                            AND    Run Keyword If    '${ue_type}' == 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${0}
...                            AND    get_release_check_result

Suite Teardown    Run keywords    robot_common_operations.Common Suite Teardown
...                               AND    Common Suite Teardown for COAM    gnb_list=@{gnb_index}


Resource     Resources/CB008200_common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008200/Resources/CB008200_variables_ming.py
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008200/Resources/CB008200_multi_gnb_variables_ming.py


*** Variables ***
${log_name_B_001}    log_name_B_001.pcap
${enb_log_name_B_001}    enb_log_name_B_001.pcap
${log_name_B_002_attach}    log_name_B_002_attach.pcap
${log_name_B_002_1}    log_name_B_002_1.pcap
${log_name_B_002}    log_name_B_002.pcap
${enb_log_name_B_002}    enb_log_name_B_002.pcap
${log_name_B_003}    log_name_B_003.pcap
${enb_log_name_B_003}    enb_log_name_B_003.pcap
${log_name_B_007}    log_name_B_007.pcap
${enb_log_name_B_007}    enb_log_name_B_007.pcap
${log_name_B_008}    log_name_B_008.pcap
${log_name_B_009}    log_name_B_009.pcap
${log_name_B_010_1}    log_name_B_010_1.pcap
${log_name_B_010_2}    log_name_B_010_2.pcap
${log_name_B_010}    log_name_B_010.pcap
${log_name_B_011_1}    log_name_B_011_1.pcap
${enb_log_name_B_011_1}    enb_log_name_B_011_1.pcap
${log_name_B_011}    log_name_B_011.pcap
${log_name_B_012}    log_name_B_012.pcap
${log_name_B_012_1}    log_name_B_012_1.pcap
${log_name_B_013_1}    log_name_B_013_1.pcap
${log_name_B_013_2}    log_name_B_013_2.pcap

${B_002_message_filter}    ngap.emergencyFallbackRequestIndicator == 0 or ngap.radioNetwork == 41

#${ue_type}    samsung

${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_dist_name}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-3    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
@{enb_para}    administrativeState    ipAddrPrim
@{enb_value}    unlocked    locked    10.107.245.164    10.108.225.167

@{cell_id}    0    1    2    3    4    5
@{multi_gnb_PA}    ${5}    ${26}    ${40}    ${0}    ${30}    ${127}    ${15}
@{PA_list}    0    30    45    127

${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml

@{gnb_index}    ${0}    ${1}

${dxdata2_apn}    95 943
${dxdata2_apn_348}    95 943

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}


*** Test Cases ***
[1]CB008200_5G_B_F_SA_Accessibility_counter_002_QosFlow_Setup_Fail_due_to_Successful_Emergency_Fallback_when_UE_in_IDLE
    [Documentation]  This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the number of QosFlows that failed to Setup
    ...    due to Voice Fallback. The User scenario is a rerun of 5G_RAN_USR_RRM_3527 for Emergency Fallback.
    [Tags]    CB008200-B    CIT_TRUNK    CRT_22R2    CRT_22R3    CIT_22R4    CIT_23R1
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup
    Run Keyword If    '${enb_instance}' == '${enb_id}[4]'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_383}
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8200_B_002}
    Online delete parmeters    parameters_to_update=${PARAM_DELETE_8200_B_002}
    ###set gnb1 cell1 PA to 0
    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    UE attach and make data disable and check
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_002_WA}
    ####set gnb1 cell3 and enb cell1 PA to 0
    Run Keyword If    ${enb_instance} == ${enb_id}[3]     #TL348
    ...    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[3]
    ...    ELSE IF    ${enb_instance} == ${enb_id}[6]     #TL358
    ...    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[6]
    ...    ELSE IF    ${enb_instance} == ${enb_id}[4]     #TL383
    ...    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[3]
    Change Attenuation value    cell=4Gcell${cell_id}[1]    value=${multi_gnb_PA}[3]
    Start capture gNB log on master    filename=${log_name_B_002}
    Start to collect the log on eNB    log_name=${enb_log_name_B_002}    interface=br1
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    Step2: UE setup EMC call
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a EMC call on SDX70
    sleep    20s
    check voice call status    status=${2}
    Prepare with PM counter time to caculate    period=start
    Sleep    1m
    ####set gnb1 cell1 PA to 127
    Set attenuation to trigger
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_002}
    Stop and download Logs on eNB    log_name=${enb_log_name_B_002}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 002
    Check counter for 002_2
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Step3: UE hang up EMC call
    ...    AND    sleep    5m
    ...    AND    check voice call status    status=${0}
    ...    AND    Setup UE data status    status=enable
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002_attach}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_002}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${enb_log_name_B_002}
    ...    AND    Run Keyword If    '${enb_instance}' == '${enb_id}[4]'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_002_383}
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_002}
    ...    AND    Online add parmeters    parameters_to_update=${PARAM_ADD_8200_B_002}
    ...    AND    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM

[1]CB008200_5G_B_F_SA_Accessibility_counter_009_VoNR_QosFlow_Setup_when_Intra-gNB_Intra-DU_HO
    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup
    ...    due to incoming handovers. The User scenario is a rerun of multiple scenarios 5G_RAN_USR_RRM_xxx:
    ...    Intra-gNB Intra-DU HO (5G Control Plane - 5G_RAN_CP_12371397)
    [Tags]    CB008200-B    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
    [Timeout]    1 hour
    [Setup]
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_009}
    ###set gnb1 cell1 PA to 5
    robot_common_operations.Common Case Setup
    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]
    Step1: UE attach    ue_type=${ue_type}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'
    ...    Step2: UE setup VoNR call
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
    ...    AND    sleep    20s
    ...    AND    check voice call status    status=${2}
    ###set gnb1 cell3 PA to 0
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[6]
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_009}
    add attenuation for 1db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
    ...    origin_value=${multi_gnb_PA}[3]    target_value=${multi_gnb_PA}[2]
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_009}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 009
    Check counter for 009
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Step3: UE hang up VoNR call    AND    check voice call status    status=${0}    AND
    ...    Step4: Detach UE    ue_type=${ue_type}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_009}    AND
    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_009}    AND
    ...    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]CB008200_5G_B_F_SA_Accessibility_counter_010_VoNR_QosFlow_Setup_when_Inter-gNB_Xn_HO
    [Documentation]    This User Scenario is to provide the counters used for measuring SA accessibility.
    ...    The User scenario creates a counter to measure the success ratio of QosFlows Setup due to incoming handovers.
    ...    The User scenario is a rerun of multiple scenarios Inter-gNB Xn HO (5G Control Plane - 5G_RAN_CP_12788):
    ...    a UE for which Inter-frequency A3/A5 measurements have been configured sends a Inter-frequency A3/A5 measurement
    ...    report and gNB performs handover based on the measurement report to a cell in the same gNB-DU.
    [Tags]    CB008200-B    CIT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CIT_23R1
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_010_1}
    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8200_B_010_2}
    ###set gnb1 cell1 PA to 5
    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    Step1: UE attach    ue_type=${ue_type}
    Start capture gNB log on master    filename=${log_name_B_010}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'
    ...    Step2: UE setup VoNR call
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
    ...    AND    sleep    20s
    ...    AND    check voice call status    status=${2}
    Stop and download Logs on gNB on master    filename=${log_name_B_010}
    Prepare with PM counter time to caculate    period=start
    Sleep    1m
    Start capture gNB log on master    filename=${log_name_B_010_1}
    Start capture gNB log on master    filename=${log_name_B_010_2}    gNB_index=${1}
    ###set gnb2 cell1 PA to 15    #TL348
    Run Keyword If    ${enb_instance} == ${enb_id}[3]     #TL348
    ...    Change Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA}[6]
    ###set gnb2 cell1 PA to 5    #TL358+TL383
    ...    ELSE    Change Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA}[0]    #TL358+TL383
    ###set gnb1 cell1 PA from 0 to target value
    Run Keyword If    ${enb_instance} == ${enb_id}[4]     #TL383
    ###set gnb1 cell1 PA to 40db,handover to gnb2 cell1   TL383
    ...    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}
    ...    origin_value=${multi_gnb_PA}[3]    target_value=${multi_gnb_PA}[2]
    ###set gnb1 cell1 PA to 30db,handover to gnb2 cell1   #TL348+TL358
    ...    ELSE    add attenuation for 5db    port1=${5Gcell1_ANT1}    port2=${5Gcell1_ANT2}    #TL348+TL358
    ...    origin_value=${multi_gnb_PA}[3]    target_value=${multi_gnb_PA}[4]
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_010_1}
    Stop and download Logs on gNB on master    filename=${log_name_B_010_2}    gNB_index=${1}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 010
    Check counter for 010
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Step3: UE hang up VoNR call
    ...    AND    sleep    20s
    ...    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010_1}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_010_2}    gNB_index=${1}
    ...    AND    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_010_1}
    ...    AND    Online modify parmeters    gnb_index=${1}    parameters_to_update=${PARAM_8200_recover_B_010_2}
    ...    AND    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]    set_value=${multi_gnb_PA}[0]
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

[1]CB008200_5G_B_F_SA_Accessibility_counter_012_VoNR_QosFlow_Setup_when_intra_gNB_re-establish
    [Documentation]    This User scenario is to provide counters used for measuring SA accessibility.
    ...    The User scenario creates counters to measure the success ratio of QosFlows Setup and Setup success
    ...    due to intra Du / intra-gNB rrc reestablshment.
    [Tags]    CB008200-B    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup
    Online modify parmeters    parameters_to_update=${PARAM_8200_B_012}
    ###set gnb1 cell1 PA to 0
    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]
    Step1: UE attach    ue_type=${ue_type}
    Start capture gNB log on master    filename=${log_name_B_012}
    Wait Until Keyword Succeeds    3x    5s    Run Keywords    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'
    ...    Step2: UE setup VoNR call
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'    Make a VoNR call(+6688) on SDX70
    ...    AND    sleep    20s
    ...    AND    check voice call status    status=${2}
    ###set gnb1 cell3 PA to 0
    Change Attenuation value    cell=5Gcell${cell_id}[3]    value=${multi_gnb_PA}[6]
    Stop and download Logs on gNB on master    filename=${log_name_B_012}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_012_1}
    ###set gnb1 cell1 PA to 127
    Set attenuation to trigger
    sleep    30s
    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}
    Prepare with PM counter time to caculate    period=end
    Check wireshark log for 012
    Check counter for 012
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Step3: UE hang up VoNR call
    ...    AND    check voice call status    status=${0}
    ...    AND    Step4: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012}
    ...    AND    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_B_012_1}
    ...    AND    Run Keyword If    '${enb_instance}' == '${enb_id}[4]'
    ...    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_012_383}
    ...    ELSE    Online modify parmeters    parameters_to_update=${PARAM_8200_recover_B_012}
    ...    AND    PA one cell 0 on and set other cell value    cellid=${cell_id}[1]
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

*** Keywords ***
Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to muti DRB
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

choice required APN on QCOM UE
    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X70 pointer variable
    set Qcom apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    csn.disconnect    connection=cygwin

set Qcom apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap 241 1076    connection=cygwin
        sleep   1s
    END
    sleep   2s
    ####1.APN setting
    ####1.1 setting
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings$ApnSettingsActivity
    ...    connection=cygwin
    ####1.2 Network&internet
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 447 938    connection=cygwin
    sleep   2s
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 323 1205    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 337 736    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 486 1604    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   2s
    [Teardown]    csn.disconnect    connection=cygwin

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    5s    reason=Qcom UE need more time to unlock the phone
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a EMC call on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    5s    reason=Qcom UE need more time to unlock the phone
    #####make EMC call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL    connection=cygwin${ue_index}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input text ${phone_number}    connection=cygwin${ue_index}
    Sleep    2s
    # Qcom UE click the call button(Dialing keys)
    csn.send_command    command=adb -s ${serial_number} shell input tap 526 2129    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[3]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

###check wireshar log
Check wireshark log for 001
    Check EPSFB message on gnb    logname=${log_name_B_001}
    Check EPSFB mesage on enb    logname=${enb_log_name_B_001}

Check wireshark log for 002_1
    check into idle status    logname=${log_name_B_002_1}

Check wireshark log for 002
    Check idle EMC fallback message on gnb    logname=${log_name_B_002}

Check wireshark log for 003
    Check EMC fallback message on gnb    logname=${log_name_B_003}

Check wireshark log for 007
    Check invalid QoS Combination message on gnb    logname=${log_name_B_007}

Check wireshark log for 008
    Check VoNR call failed message with unspecified    logname=${log_name_B_008}

Check wireshark log for 009
    Check VoNR call success message with intra gnb HO    logname=${log_name_B_009}

Check wireshark log for 010
    Check VoNR success message    logname=${log_name_B_010}
    Check VoNR call success message with inter gnb HO source    logname=${log_name_B_010_1}
    Check VoNR call success message with inter gnb HO target    logname=${log_name_B_010_2}

Check wireshark log for 011
    Check VoNR success message    logname=${log_name_B_011}
    check message with B2 event of Inter_RAT HO    logname=${log_name_B_011_1}
    check message with B2 event of Inter_RAT HO on enb    logname=${enb_log_name_B_011_1}

Check wireshark log for 012
    Check VoNR call success message with intra gnb re-establish    logname=${log_name_B_012_1}

Check wireshark log for 013
    Check VoNR success message    logname=${log_name_B_013_1}
    Check VoNR release success message    logname=${log_name_B_013_2}


###check counter on WEBUI
Check counter for 001
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['counter_id']}
    ...    dic_path=${NR_RRC_RELEASE_REDIR_VFB_LTE['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NR_RRC_RELEASE_REDIR_VFB_LTE['gnb_id']}

Check counter for 002_1
    [Arguments]      ${counter_index}=${0}
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY['gnb_id']}
    ...    counter_index=${counter_index}
    ...    ELSE
    ...    Check gnb counter greater expected_value
    ...    counter_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_GNB_UE_INACTIVITY_trunk['gnb_id']}
    ...    counter_index=${counter_index}

Check counter for 002_2
    sleep    60s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2['gnb_id']}
    ...    timeout=${600}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK_2_trunk['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_trunk['gnb_id']}
    ...    timeout=${600}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1_2_trunk['gnb_id']}
    ...    timeout=${600}

Check counter for 003
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_FALLBACK['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_FALLBACK['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_FALLBACK['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_FALBACK_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_FAIL_FALBACK_5QI1['gnb_id']}

Check counter for 007
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_WRONG_MSG['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_WRONG_MSG['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['dic_path']}
    ...    expected_value=${2}
    ...    gnb_id=${NG_FLOW_STP_FAIL_WRG_MSG_PMQAP['gnb_id']}

Check counter for 008
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPECIFIED['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_FAIL_UNSPC_5QI1['gnb_id']}

Check counter for 009
    sleep    30s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_2_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_trunk['gnb_id']}

Check counter for 010
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_5QI1_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_5QI1_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_INC_HO_PMQAP_3_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_INC_HO_PMQAP_3_trunk['gnb_id']}

Check counter for 011
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_REL_IRAT_SUC_HO_PMQAP['gnb_id']}

Check counter for 012
    sleep    40s
    Run Keyword If    '${check_result}' != 'True'    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU['gnb_id']}
    ...    ELSE    run keywords
    ...    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_PMQAP_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_ATT_RES_IADU_5QI1_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_PMQAP_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_STP_SUC_RES_IADU_5QI1_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_ATT_REEST_IADU_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_ATT_REEST_IADU_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_ATT_REEST_IADU_trunk['gnb_id']}
    ...    AND    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_STP_SUC_REEST_IADU_trunk['counter_id']}
    ...    dic_path=${NG_FLOW_STP_SUC_REEST_IADU_trunk['dic_path']}
    ...    expected_value=${3}
    ...    gnb_id=${NG_FLOW_STP_SUC_REEST_IADU_trunk['gnb_id']}

Check counter for 013
    sleep    40s
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_ATT_TOT_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_ATT_TOT_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_SETUP_SUCC_TOT_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_SETUP_SUCC_TOT_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL_PMQAP['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL_PMQAP['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_NORMAL_5QI1['counter_id']}
    ...    dic_path=${NG_FLOW_REL_NORMAL_5QI1['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_NORMAL_5QI1['gnb_id']}
    Check gnb counter as expected_value
    ...    counter_id=${NG_FLOW_REL_AMF_NORMAL['counter_id']}
    ...    dic_path=${NG_FLOW_REL_AMF_NORMAL['dic_path']}
    ...    expected_value=${1}
    ...    gnb_id=${NG_FLOW_REL_AMF_NORMAL['gnb_id']}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

UE attach and make data disable and check
    Start capture gNB log on master    filename=${log_name_B_002_attach}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    make WA with Samsung S21
    Step1: UE attach    ue_type=${ue_type}
    Stop and download Logs on gNB on master    filename=${log_name_B_002_attach}
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_B_002_1}
    Setup UE data status    status=disable
    sleep    10s
    Stop and download Logs on gNB on master    filename=${log_name_B_002_1}
    Prepare with PM counter time to caculate    period=end
    ####check RRC idle log
    Check wireshark log for 002_1
    Check counter for 002_1    counter_index=${0}
#    Run Keyword If    '${ue_type}' != 'qct_dx50'    Check counter for 002_1    counter_index=${0}
#    ...    ELSE    Check counter for 002_1    counter_index=${1}
