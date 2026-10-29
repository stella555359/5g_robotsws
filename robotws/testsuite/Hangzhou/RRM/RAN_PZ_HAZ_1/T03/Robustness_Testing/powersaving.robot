*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about robu
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
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
${check_lp_amount}       ${80}
${MRBTSID}               11688
${NRBTSID}               11688
${time_start_dl}           55s
${time_stop_dl}            35s
${bts0_web_ip}             10.106.230.21
${spark_iperf_server}      10.56.198.156
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_6327}              faultId=${6327}
&{fault_6915}              faultId=${6915}
&{fault_61618}             faultId=${61618}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_6327}    &{fault_6915}


*** Test Cases ***
PowerSaving Test
    [Documentation]    author:keli
    ...    this case is used to test the power saving function
    ...    actNrLBmMimoRTXPowerSaving = true
    [Tags]    10_5_UTESRAN001T11688
    Start Multi Bts Log
    sleep   2s
    FOR    ${i}    IN RANGE   ${30}
        # Restart Bts log    findex=${i}
        Attach UEs By AT
        sleep    5s
        # ${ueip}=    AT Operation    get    ue_index=0    item=ueip
        # Log To Console    ${i}:ueip: ${ueip}
        Start DL Traffic    tput=500.00M
        Log To Console    ${i}:start DL wait ${time_start_dl}
        sleep    ${time_start_dl}
        Stop DL Traffic
        Log To Console    Stop DL
        Detach UEs By AT
        sleep    ${time_stop_dl}
        Log To Console    wait ${time_stop_dl}
    END



*** Keywords ***
Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=0
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    Disconnect All VM


Attach UEs By AT
    [Arguments]    ${ue_num}=1
    FOR    ${ue_index}    IN RANGE   ${ue_num}
        AT Operation    attach    ue_index=${ue_index}
        Log To Console    UE${ue_index}: attach
    END

Detach UEs By AT
    [Arguments]    ${ue_num}=1
    FOR    ${ue_index}    IN RANGE   ${ue_num}
        AT Operation    detach    ue_index=${ue_index}
        Log To Console    UE${ue_index}: detach
    END

Start DL Traffic
    [Arguments]    ${tput}=500.00M    ${tport}=50001    ${server_ip}=${spark_iperf_server}
    AT Operation    start_traffic    ue_index=0    IperfOptions=-u -i 1 -t 300 -b ${tput} -p ${tport} -l 1024    direction=dl
    ...    remote_hostname=${server_ip}    remote_username=ute    remote_password=UTE.debian12

Stop DL Traffic
    [Arguments]    ${server_ip}=${spark_iperf_server}
    AT Operation    stop_traffic    direction=dl    remote_hostname=${server_ip}    remote_username=ute    remote_password=UTE.debian12

Counter Check throughput
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Stop All Bts Log
    Stop All BTSLog And Download to Local

Restart Bts log
    [Arguments]    ${findex}=0
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart_${findex}.log