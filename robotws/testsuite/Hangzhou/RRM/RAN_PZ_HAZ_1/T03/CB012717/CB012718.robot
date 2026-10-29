*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB012718-SR
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROID_ASIL_ABIO_ABIP_AZHL_AEHC_MCS
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${DEBUGMODE}                        ${True}
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}
# ${CA_MAX_Value}          ${60}
# ${CA_NormalValue}        ${8}
# ${CA_MIN_Value}          ${0}
# ${pci_of_cell1}          ${178}
# ${pci_of_cell2}          ${403}
# ${Cell1_ID}              187154473
# ${Cell2_ID}              187154836
# ${Pa_range_size}         ${18}
${Pa_interval}           60
# ${dist_name}            MRBTS-11423/NRBTS-11423
# net config
${BTS0_WEB_IP}    10.106.201.195
${SPARK_IPERF_SERVER}    10.56.198.156
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_6327}              faultId=${6327}
&{fault_6915}              faultId=${6915}
&{fault_61618}             faultId=${61618}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}
...    &{fault_61618}    &{fault_6327}    &{fault_6915}


*** Test Cases ***
CB012718_Center_to_Edge_Draft
    [Documentation]    author:keli
    [Tags]    10_5_UTESRAN001T11423
    Adjust PA For AZHL_41
    Adjust PA For AEHC_41
    sleep    10s
    UEs start Logs
    sleep    10s
    # Spark UEs attach
    UEs Start Test Plan
    sleep    30s
    Adjust PA For AEHC_41    p_value=${10}
    sleep    10s
    Adjust PA For AEHC_41    p_value=${15}
    sleep    10s
    Adjust PA For AEHC_41    p_value=${20}
    sleep    30s
    Adjust PA For UE Move From Center To Edge


CB012718_NFTA_DL_Ho
    [Documentation]    author:keli
    [Tags]    10_5_UTESRAN001T11423
    Adjust PA For AZHL_41
    Adjust PA For AEHC_41
    Log To Console    wait 30s
    sleep    30s
    UEs start Logs    log_tag=DL_Ho
    sleep    10s
    # Spark UEs attach
    UEs Start Ho Test Plan
    sleep    2s
    ${source_pa_port_list}     Create List     7    16
    ${source_pa_value_list}    Create List     0    8
    ${source_pa_value_list2}    Create List     8    0
    ${target_pa_port_list}     Create List    199    208
    ${target_pa_value_list}    Create List    8    0
    ${target_pa_value_list2}    Create List    0    8
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${1}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${1}    pa_type=32*8
    &{source2}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list2}
    ...                               step=${1}    pa_type=32*8
    &{target2}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list2}
    ...                               step=${1}    pa_type=32*8

    FOR    ${i}    IN RANGE   ${35}
        Log To Console    ${\n}==Loop:${i}==${\n}
        PA Operation    source=&{source}    target=&{target}
        sleep    3s
        PA Operation    source=&{source2}    target=&{target2}
        sleep    3s
    END


CB012718_NFTA_UL_Ho
    [Documentation]    author:keli
    [Tags]    10_5_UTESRAN001T11423
    Adjust PA For AZHL_41
    Adjust PA For AEHC_41
    Log To Console    wait 30s
    sleep    30s
    # UEs start Logs    log_tag=UL_Ho
    sleep    10s
    # Spark UEs attach
    # UEs Start Ho Test Plan
    sleep    2s
    ${source_pa_port_list}     Create List     7    16
    ${source_pa_value_list}    Create List     0    7
    ${source_pa_value_list2}    Create List     7    0
    ${target_pa_port_list}     Create List    199    208
    ${target_pa_value_list}    Create List    7    0
    ${target_pa_value_list2}    Create List    0    7
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${1}    pa_type=32*8
    &{target}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list}
    ...                               step=${1}    pa_type=32*8
    &{source2}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list2}
    ...                               step=${1}    pa_type=32*8
    &{target2}    Create Dictionary    att_index=${0}    pa_port=${target_pa_port_list}    pa_value=${target_pa_value_list2}
    ...                               step=${1}    pa_type=32*8

    FOR    ${i}    IN RANGE   ${35}
        Log To Console    ${\n}==Loop:${i}==${\n}
        PA Operation    source=&{source}    target=&{target}
        sleep    4s
        PA Operation    source=&{source2}    target=&{target2}
        sleep    4s
    END



*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Traffic Uebox Operation    operation=stop testplan    ue_imsi=460023100012111
    Run Keyword And Ignore Error    Traffic Uebox Operation    operation=stop testplan    ue_imsi=460023100008884
    Run Keyword And Ignore Error    Traffic Uebox Operation    stop log     ue_imsi=460023100012111,460023100008884
    Run Keyword And Ignore Error    Traffic Uebox Operation    fetch log    ue_imsi=460023100012111,460023100008884
    ...    LogPath=c:\\uelogs    LogName=CB012718_VoNR_${log_tag}_${log_start_time}    LocalDire=${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

UEs start Logs
    [Arguments]    ${log_tag}=tag
    Log To Console    start logs
    ${log_start_time}    Get TimeStamp With Date
    Set Suite Variable    ${log_start_time}
    Set Suite Variable    ${log_tag}
    Traffic Uebox Operation    start log  ue_imsi=460023100012111,460023100008884
    ...    LogPath=c:\\uelogs    LogName=CB012718_VoNR_${log_tag}_${log_start_time}
    Log To Console    start logs ok

UEs Start Test Plan
    Log To Console    start spark test plan
    @{ue1_plans}    Create List    VoNR_MO
    @{ue2_plans}    Create List    VoNR_MT
    # Traffic Uebox Operation    start test plan  ue_imsi=460023100012111    TestPlans=${myplans}
    Traffic Uebox Operation    operation=start testplan    ue_imsi=460023100012111
    ...    TestPlans=${ue1_plans}
    # sleep    1s
    Traffic Uebox Operation    operation=start testplan    ue_imsi=460023100008884
    ...    TestPlans=${ue2_plans}
    sleep    10s

UEs Start Ho Test Plan
    Log To Console    start spark test plan
    @{ue1_plans}    Create List    HO_MO
    @{ue2_plans}    Create List    VoNR_MT
    # Traffic Uebox Operation    start test plan  ue_imsi=460023100012111    TestPlans=${myplans}
    Traffic Uebox Operation    operation=start testplan    ue_imsi=460023100012111
    ...    TestPlans=${ue1_plans}
    # sleep    1s
    Traffic Uebox Operation    operation=start testplan    ue_imsi=460023100008884
    ...    TestPlans=${ue2_plans}
    sleep    10s

Spark UEs attach
    Traffic Uebox Operation    detach    ue_imsi=460023100012111
    sleep    2s
    Traffic Uebox Operation    attach    ue_imsi=460023100012111
    sleep    2s
    Traffic Uebox Operation    detach    ue_imsi=460023100008884
    sleep    2s
    Traffic Uebox Operation    attach    ue_imsi=460023100008884

Adjust PA For AZHL_41
    [Arguments]    ${p_value}=${PA_MinValue}
    Log To Console    PA Change attach to AZHL n41
    # Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${p_value}

Adjust PA For AEHC_41
    [Arguments]    ${p_value}=${PA_MinValue}
    Log To Console    PA Change attach to AEHC n41
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${p_value}
    # Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_MinValue}

Adjust PA For UE Move From Center To Edge
    ${source_pa_port_list}     Create List     7    16
    ${source_pa_value_list}    Create List     22    42
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${1}    pa_type=32*8
    PA Operation    source=&{source}    target=none    wait_sleep=60s
    sleep    1s
    # ${increase_port_list}    Get Attenuation port    RU_id=${1}    gnb_id=${0}
    # ${decrease_port_list}    Get Attenuation port    RU_id=${2}    gnb_id=${0}
    # ${increase_value_list}=    Evaluate    [i for i in range(${22}, ${49} + 1)]
    # ${decrease_value_list}=    Evaluate    [${0}] * ${28}
    # Log    ${increase_value_list}
    # Log    ${decrease_value_list}
    # ${increase_decrease_ports_value_dict}    create dictionary    increase=${increase_port_list}    decrease=${decrease_port_list}
    # ...     increase_value_list=${increase_value_list}     decrease_value_list=${decrease_value_list}    len=${Pa_range_size}
    # Trigger Handover By List    increase_decrease_ports_value_dict=${increase_decrease_ports_value_dict}    sleep_time=${Pa_interval}
    # sleep    15s

Change Commission To Lock cell
    [Arguments]    @{cell_list}
    FOR   ${cell_i}    IN    @{cell_list}
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-${cell_i}    need_verify=yes
    END

Change Commission To Unlock cell
    BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
    ...    distname_id=NRCELL-ALL    need_verify=yes


Check Cell No tput By DataPdu
    [Arguments]    ${cell_id}
    ${datapdu}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "nrCellId ${cell_id}" | grep -av grep
    ${list}    Split String    ${datapdu}    \n
    FOR    ${line}    IN   @{list}
        ${A}    Split String    ${line}    |
        ${B}    Split String    ${A}[-1]    ]
        ${tput_real}    Convert to Integer    ${B}[0]
        ${tput_st}    ${v}    Run Keyword and Ignore Error    Should Be True    ${tput_real}==${0}
        Exit FOR Loop if    "${tput_st}"=="FAIL"
    END
    Run Keyword if    "${tput_st}"=="FAIL"    Fail    Target has tput

Check Scell Released
    Log To Console    Check Scell released
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a ScellRelease | grep -av grep
    Should Contain    ${ret}    Rrc Reconfiguration for ScellRelease procedure completed

Check CA Scell Selection
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a ${CA_Cell_Check_cp} | grep -av grep
    Should Contain    ${ret}        Finished with status Status

Counter Check throughput
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Stop All Bts Log
    Stop All BTSLog And Download to Local

Restart Bts log
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart.log