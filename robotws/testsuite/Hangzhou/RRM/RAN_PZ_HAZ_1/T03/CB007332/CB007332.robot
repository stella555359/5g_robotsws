*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB007332
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_120db}              ${120}
${PA_NormalValue}        ${1}
${PA_CA}                 ${25}
${PA_HoValue}            ${35}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.108.164.162
${PA_33db}               ${33}
${PA_38db}               ${38}
${PA_42db}               ${42}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_1933}              faultId=${1933}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_1933}    &{fault_6331}
${Feature_7332_parameter}  dynTriggerLteNrDcConfList
&{feature_7332_val}        method=coverageAndDlUlBufferBased
...                        lcrId=${-1}
...                        actB1NrBeamMeas=false
@{Feature_7332_list}       &{feature_7332_val}
${dist_name}               MRBTS-10787/LNBTS-10787/NRDCDPR-0

*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB007332_01_UL data buffer based EN-DC setup without ULCA configured on UE-FDD
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007332_case01
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10787 LTE Cell_22
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 NR Cell_11
    sleep    10s
    Block BTS10787 NR Cell_11
    sleep    10s
    Start UL Traffic    server_ip=10.108.233.142
    sleep    30s
#    Check UL traffic for ENDC
    Check No ENDC setup
    Stop UL Traffic
    AT.UE Detach
    Unblock BTS10787 LTE Cell_22
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 NR Cell_11
    sleep    10s
#    Check UL traffic for ENDC
    Start UL Traffic    server_ip=10.108.233.142
    sleep    30s
    Check ENDC setup

CB007332_05_UL data buffer based EN-DC setup with ULCA already configured on UE-FDD
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007332_case05
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 LTE AHEGB_ANT24
    Start UL Traffic    server_ip=10.108.233.142
    Check UL traffic for Scell ADD
    Check DL UL CA add
    Stop UL Traffic
    Unblock BTS10787 NR AZHM_ANT1234
    sleep    10s
    Start UL Traffic    server_ip=10.108.233.142
    sleep    20s
#    Check UL traffic for ENDC
    Check ENDC setup
    Check Scell Del

CB007332_09_UL data buffer based EN-DC setup interworking with mrWaitTimer setting when lower priority MR received firstly
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007332_case09
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    sleep    10s
    Unblock BTS10787 NR AZHM_ANT1234
    sleep    10s
    Start UL Traffic
    sleep    20s
#    Check UL traffic for ENDC
    Check ENDC setup
    Check mrWaitTimer


CB007332_12_Activation and configuration of feature CB007332 - UL data buffer trigger for EN-DC
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB007332_case12
    AT.Prepare UE
    Start Multi Bts Log
    Unblock BTS10787 LTE AHEGB_ANT13
    AT.UE Attach
    Unblock BTS10787 LTE AHEGB_ANT24
    Unblock BTS10787 NR AZHM_ANT1234
    sleep    10s
    Start UL Traffic
    Check UL traffic for Scell ADD
    Check DL UL CA add
    stop UL Traffic
    sleep    60s
    Change Dynamic Trigger Method
    Start UL Traffic
    sleep    20s
    Check ENDC setup

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Unblock BTS10787 LTE Cell_22
    Log To Console    Unblock BTS10787 LTE Cell_22
    Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 NR Cell_11
    Log To Console    Unblock BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_NormalValue}

Block BTS10787 NR Cell_11
    Log To Console    Block BTS10787 NR Cell_11
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MaxValue}

Check No ENDC setup
    Log To Console    Check No ENDC setup
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should not Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check ENDC setup
    Log To Console    Check ENDC setup
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check UL traffic for ENDC
    Log To Console    Check UL traffic for ENDC
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'UL ENDC buffer monitor: Receive RadioLinkStatus is UplinkBufferTriggeredEnDc' | grep -av grep
    Should Contain    ${ret}    UL ENDC buffer monitor: Receive RadioLinkStatus is UplinkBufferTriggeredEnDc

Unblock BTS10787 LTE AHEGB_ANT13
    Log To Console    Unblock BTS10787 LTE AHEGB_ANT13
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}

Unblock BTS10787 LTE AHEGB_ANT24
    Log To Console    Unblock BTS10787 LTE AHEGB_ANT13
    Modify Attenuation For One RRU Of One Site    ru_id=${5}    gnb_id=${0}    value=${PA_CA}

Check UL traffic for Scell ADD
    Log To Console    Check UL traffic for Scell ADD
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'UplinkTriggeredScellAddition' | grep -av grep
    Should Contain    ${ret}    UplinkTriggeredScellAddition

Check DL UL CA add
    Log To Console    Check DL UL CA add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'UL triggered request resulted in DL/UL SCell addition and finished with success' | grep -av grep
    Should Contain    ${ret}    UL triggered request resulted in DL/UL SCell addition and finished with success

Unblock BTS10787 NR AZHM_ANT1234
    Log To Console    Unblock BTS10787 NR AZHM_ANT1234
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_NormalValue}

Check Scell Del
    Log To Console    Check Scell Downgrade
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'SCell is successfully released for UE' | grep -av grep
    Should Contain    ${ret}    SCell is successfully released for UE

Check mrWaitTimer
    Log To Console    Check mrWaitTimer
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'not highest priority frequency measurement report received, starting mrWaitTimer' | grep -av grep
    Should Contain    ${ret}    not highest priority frequency measurement report received, starting mrWaitTimer

DL And UL Traffic
    Connect All VM
    # gnb_tool.start_to_capture_tti_log_with_gnb_tool
    # ...    log_dire=${TEST_LOG_DIRECTORY}
    # ...    host=${BTS0_PC_INFO.Host}
    # ...    dest_ip=10.108.231.24
    # ADB.Start Traffic    tput_type=DL
    # ...    server_ip=${BTS0_PC_INFO.Host}
    # ...    client_connection=BTS0_VM
    # ...    tput_value=20M
    # ...    tput_time=120s
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${BTS0_PC_INFO.Host}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=50002
    ...    tput_value=50M
    ...    tput_time=60s
    Sleep    90s
    # ADB.Stop Traffic     tput_type=DL
    # ...    iperf_port=50001
    # ...    client_connection=BTS0_VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    # ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
    # Set Test Variable    ${log_path}     ${log_path}
    # Stop All Bts Log

Start UL Traffic
    [Arguments]    ${server_ip}=${BTS0_PC_INFO.Host}
    Connect All VM
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${server_ip}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=50002
    ...    tput_value=50M
    ...    tput_time=300s
    #Sleep    90s

Stop UL Traffic
    Connect All VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0

Change Dynamic Trigger Method
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${Feature_7332_parameter}
    ...                              operation=update
    ...                              value=@{Feature_7332_list}
    @{parameter_list}    Create List    ${dict}
    coam_admin.perform_object_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
#    COAM_Admin.perform_object_recommissioning    parameter=${parameter}     value=${new_value}    alias=commission
    [Teardown]    COAM_Admin.Logout    connection=commission











