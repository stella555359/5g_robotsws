*** Settings ***
Documentation
...    author: Ming Shi
...    contact:ming.shi@nokia-sbell.com
...    squad group: 5G_PZ_HZ_3_SG
...    feature : TMO_Regression

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Setup for Env cell on-air for multi gnb


Suite Teardown    robot_common_operations.Common Suite Teardown


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/SFE_TMO_Regression_Common_Keywords.robot


*** Variables ***
${log_name_pingpang_HO_704_1}    log_name_pingpang_HO_704_1.pcap
${log_name_pingpang_HO_704_2_1}    log_name_pingpang_HO_704_2_1.pcap
${log_name_pingpang_HO_704_2_2}    log_name_pingpang_HO_704_2_2.pcap
${enb_instance}     ${tl.enbs[0].instance_id}
#${ue_type}    samsung
${muiltdrb}    97 1140
${dxdata2_apn}    95 943
@{cell_id}    0    1    2    3    4    5
@{multi_gnb_PA_common}    ${0}    ${5}    ${10}    ${15}    ${20}    ${25}
@{multi_gnb_PA_358}    ${0}    ${15}
@{multi_gnb_PA_348}    ${0}    ${25}    ${30}
@{multi_gnb_PA_383}    ${1}    ${8}     ${25}
@{multi_gnb_PA_383_loop}    ${10}    ${9}    ${8}    ${7}     ${6}    ${5}    ${4}     ${3}    ${2}    ${1}     ${0}
${multi_gnb_PA_max}    ${127}
${tl_scf_file_name1}    gNB1_Golden_SCF.xml
${tl_scf_file_name2}    gNB2_Golden_SCF.xml
@{gnb_index}    ${0}    ${1}
@{enb_id}    241    383    358
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}

${expected_tput_dl}    1
${Send_Tput_DL}        2M
${expected_tput_ul}    0.5
${Send_Tput_UL}        2M

${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}

${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350

${ue_type}                  ${tl.ues[0].capabilities[0]}

#${dxdata2_apn}    95 943
${dxdata2_apn_348}    150 943

*** Test Cases ***
[1]CB007835_5G_A_004_SA_intergnb_intrafre_pingpang_HO_704_stability
    [Documentation]    GNB1 CELL1- GNB2 CELL1 Intra F(FDD-FDD) inter gnb ping pang HO
    [Timeout]    10 hour
    [Tags]    classical    CRT_23R2    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_TRUNK    CRT_22R4    CRT_23R1
    [Setup]
    robot_common_operations.Common Case Setup
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[2]    #TL358
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_358}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_358}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_383}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_383}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL348
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_348}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_348}
    Comment    set gnb1 cell1 PA to 0
    PA set all cells to max value except specified cell    cellid=${cell_id}[1]    set_value=${multi_gnb_PA_common}[0]
    Check UE device exist    ue_index=${0}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
#    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    set apn to wap2    usedapn=${dxdata2_apn}
#    ...    ELSE IF    '${ue_type}' == 'qct_dx50'
#    ...    choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}    ue_type=${ue_type}   ue_index=${0}
##    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    set apn dxdata2
    ...    ELSE IF    '${ue_type}' == 'qct_dx50'
#    ...    choice required APN on QCOM UE    usedapn=${X75_dxdata2_location}    ue_type=${ue_type}   ue_index=${0}
    ...    Switch QCOM APN to muti DRB    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2}
    Run Keyword If    '${ue_type}' == 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    capture log and ue attach
    make traffic    traffic_direction=DL
    trigger pingpang HO and check kpi
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    finish traffic    traffic_direction=DL
    ...    AND    Run Keyword If    '${ue_type}' != 'qct_dx50'    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    ui_version=default
    ...    AND    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    make WA for Samsung S21
    ...    AND    Step: Detach UE    ue_type=${ue_type}
    ...    AND    Run Keyword And Ignore Error    check hanging resource for per UE on gnb    gnb_ips=${gnb_ips}    UE_Type_Index=${0}
    ...    AND    Run Keyword If    ${enb_instance} == ${enb_id}[2]    #TL358
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_Recover_358}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_Recover_358}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_Recover_383}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_Recover_383}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL348
    ...    change SFE TMO Ping Pang Paras    para=${SFE_TMO_Ping_Pang_Paras_Recover_348}    para2=${SFE_TMO_Ping_Pang_Paras_GNB2_Recover_348}
    ...    AND    PA set all cells to max value except specified cell    cellid=${cell_id}[1]    set_value=${multi_gnb_PA_common}[0]
    ...    AND    Common Case Teardown for COAM    gnb_list=@{gnb_index}

*** Keywords ***
set apn dxdata2
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[0]
    ...    run keywords    Set Suite Variable    ${close_task}    538 1874
    ...    AND    set apn with special method    usedapn=${dxdata2_apn_348}
    ...    ELSE    set apn to wap2    usedapn=${dxdata2_apn}

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
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

capture log and ue attach
    Start capture gNB log on master    filename=${log_name_pingpang_HO_704_1}
    Run Keyword If    '${ue_type}' == 'samsung' or '${ue_type}' == 'Huawei'    make WA for Samsung S21
    # UE attach to gnb1 cell1
    Step: UE attach    ue_type=${ue_type}
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_pingpang_HO_704_1}

make traffic
    [Arguments]    ${traffic_direction}=DL
    Run Keyword If    '${traffic_direction}' == 'DL'
    ...    Start only DL traffic and check tput    ue_index=${0}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl}    dl_throughput=${Send_Tput_DL}    duration=${7200}
    ...    ELSE IF    '${traffic_direction}' == 'UL'
    ...    Start only UL traffic and check tput    ue_index=${0}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_ul_cell=${expected_tput_ul}    ul_throughput=${Send_Tput_UL}    duration=${7200}

trigger pingpang HO and check kpi
    Prepare PM counter sleep time    period=start
    Start capture gNB log on master    filename=${log_name_pingpang_HO_704_2_1}
    Start capture gNB log on master    filename=${log_name_pingpang_HO_704_2_2}    gNB_index=${1}
    ###set gnb2 cell1 PA
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[2]    #TL358 gnb1 cell set 0 and gnb2 cell1 set to 15
    ...    Run Keywords
    ...    Change cell Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA_358}[1]
    ...    AND    Change cell Attenuation value    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA_358}[0]
    ...    ELSE IF    ${enb_instance} == ${enb_id}[1]    #TL383 gnb1 cell set 8 and gnb2 cell1 set to 0
    ...    Run Keywords
    ...    Change cell Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA_383}[0]
    ...    AND    Change cell Attenuation value    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA_383}[1]
#    ...    AND    Change cell Attenuation value    cell=5Gcell@{cell_id}[1]    value=${pa_set_value}
    ...    ELSE IF    ${enb_instance} == ${enb_id}[0]    #TL348 gnb1 cell set 25 and gnb2 cell1 set to 25
    ...    Run Keywords
    ...    Change cell Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA_348}[1]
    ...    AND    Change cell Attenuation value    cell=5Gcell${cell_id}[1]    value=${multi_gnb_PA_348}[1]
    sleep    10m    reason=sleep 10min to check counter of pingpang HO
    Prepare PM counter sleep time    period=end
    Comment    check KPI
    check KPI
    [Teardown]      Run Keywords
    ...    Stop and download Logs on gNB on master    filename=${log_name_pingpang_HO_704_2_1}
    ...    AND    Stop and download Logs on gNB on master    filename=${log_name_pingpang_HO_704_2_2}    gNB_index=${1}

finish traffic
    [Arguments]    ${traffic_direction}=DL
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type}    direction=${traffic_direction}

check KPI
    sleep    30s    reason=wait pm file generated
    Comment    because gnb1 is set 1 min to generate counters
    check KPI via pm file    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO.txt
    ...    para_index=${1}    index=${0}    xml_num=${1}
    check KPI via pm file_2    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt
    ...    para_index=${2}    index=${0}    xml_num=${1}
    Comment    because gnb2 is set 5 min to generate counters
    check KPI via pm file    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO.txt
    ...    para_index=${1}    index=${1}    xml_num=${1}
    RUN KEYWORD IF    ${enb_instance} == ${enb_id}[1]    # TL383 have 3 PLMN pm gnb2 cell1
    ...    check KPI via pm file_2    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt
    ...    para_index=${2}    index=${1}    xml_num=${1}
    ...    ELSE    check KPI via pm file_2    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt
    ...    para_index=${1}    index=${1}    xml_num=${1}

check KPI via pm file
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}    ${xml_num}=${10}
    ${list_kpi_keys_values}=    get list of dict kpi from pm files
    ...    kpi_path=${kpi_path}    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}    xml_num=${xml_num}
    FOR    ${per_dict_kpi}    IN    @{list_kpi_keys_values}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[0]}']}    ${0.0}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[1]}']}    ${0.0}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[2]}']}    ${0.0}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[3]}']}    ${0.0}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[7]}']}    ${0}
        Should Be Equal    ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[8]}']}    ${0}
    END

check KPI via pm file_2
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}    ${xml_num}=${10}
    ${list_kpi_keys_values}=    get list of dict kpi from pm files
    ...    kpi_path=${kpi_path}    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}    xml_num=${xml_num}
    ${sum_counter_M55145C00341}=    Set Variable    ${0}
    ${sum_counter_M55145C00342}=    Set Variable    ${0}
    FOR    ${per_dict_kpi}    IN    @{list_kpi_keys_values}
        ${sum_counter_M55145C00341}=    Evaluate    ${sum_counter_M55145C00341} + ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[4]}']}
        ${sum_counter_M55145C00342}=    Evaluate    ${sum_counter_M55145C00342} + ${per_dict_kpi['${SFE_TMO_ping_pang_kpi_id[9]}']}
    END
    Should Be True    ${sum_counter_M55145C00341} > ${300}
    Should Be True    ${sum_counter_M55145C00342} > ${300}
    ${NR_5204a}=    Evaluate    ${100} * ${sum_counter_M55145C00342} / ${sum_counter_M55145C00341}
    ${NR_5183b}=    Evaluate    ${100} * ${sum_counter_M55145C00342} / ${sum_counter_M55145C00341}
    Should Be True    ${NR_5204a} >= ${99.0}
    Should Be True    ${NR_5183b} >= ${99.0}

check dict KPI from pm file_1
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    kpi_path=${kpi_path}    KPI_file=${KPI_file}
    ...    para_index=${para_index}    index=${index}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[0]}']}    ${0.0}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[1]}']}    ${0.0}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[2]}']}    ${0.0}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[3]}']}    ${0.0}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[7]}']}    ${0}
    Should Be Equal    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[8]}']}    ${0}

check dict KPI from pm file_2
    [Arguments]     ${kpi_path}    ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    kpi_path=${kpi_path}    KPI_file=${KPI_file}
    ...    para_index=${para_index}    index=${index}
    Should Be True    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[4]}']} > ${20}
    Should Be True    ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[9]}']} > ${20}
    ${NR_5204a}=    Evaluate
    ...    ${100} * ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[9]}']} / ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[4]}']}
    ${NR_5183b}=    Evaluate
    ...    ${100} * ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[9]}']} / ${dict_kpis_name_value['${SFE_TMO_ping_pang_kpi_id[4]}']}
    Should Be True    ${NR_5204a} >= ${99.0}
    Should Be True    ${NR_5183b} >= ${99.0}

check dict KPI
    sleep    30s    reason=wait pm file generated
    check dict KPI from pm file_1    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO.txt    para_index=${1}    index=${0}
    check dict KPI from pm file_2    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt    para_index=${2}    index=${0}
    check dict KPI from pm file_1    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO.txt    para_index=${1}    index=${1}
    check dict KPI from pm file_2    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt    para_index=${2}    index=${1}

loop check pingpang HO if executed
    sleep    0.5m
    Set Test Variable    ${pa_set_value}    need to check env
    FOR    ${index}    ${item}    IN ENUMERATE    @{multi_gnb_PA_383_loop}
        Run Keywords
        ...    Change cell Attenuation value    cell=5Gcell${cell_id}[4]    value=${multi_gnb_PA_383}[0]
        ...    AND    Change cell Attenuation value    cell=5Gcell${cell_id}[1]    value=${item}
        sleep    5m    reason=sleep 5min to check counter of pingpang HO and wait pm file generated
        ${result}=    Run Keyword And Return Status    check dict KPI from pm file_2
        ...    kpi_path=${CURDIR}/../KPI_files    KPI_file=SFE_TMO_kpi_pingpang_HO_2.txt    para_index=${2}    index=${0}
        Run Keyword If    '${result}'=='True'    Run Keywords
        ...    Set Test Variable    ${pa_set_value}    ${item}
        ...    AND    Exit For Loop
    END
    Run Keyword If    '${pa_set_value}' == 'need to check env'    Fail    msg=need to check env
