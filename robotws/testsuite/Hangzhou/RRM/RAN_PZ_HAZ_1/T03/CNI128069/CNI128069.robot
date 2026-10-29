*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   this is a robot case about CB007035
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDROID_ASIMR_ABIP_ABIO_ABIQ_AHFIB_AHLOA_AZHL_AVQQA
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
# ${DEBUGMODE}      ${True}
${PA_MaxValue}    ${60}
${PA_NormalValue}    ${50}
${PA_MediumValue}    ${35}
${PA_MinValue}    ${0}
${ChangePA_MinValue}    ${20}
${PASwap_MIN_Value}    ${10}
${MRBTSID}               302
${NRBTSID}               302
${spark_iperf_server}      10.108.233.142
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
${B1HORSRP}               b1ThresholdRsrp
${adminState}             administrativeState
${dist_name}              MRBTS-302/LNBTS-6093
${dist_name1}             MRBTS-302/LNBTS-6093/LNCEL-11
${dist_name2}             MRBTS-302/LNBTS-6093/LNCEL-11/LNHON-0
${MOC_list1}                MRBTS-302/NRBTS-6093/LNCEL-11/SIB-0
${MOC_list2}                MRBTS-302/NRBTS-6093/LNCEL-12/SIB-0
${Redirect From NR to LTE1}      Trigger the rrcReleaseWithRedirectProcedure for voice fallback
${Redirect From NR to LTE2}      measurementType\:B1Redirection
${Redirect From NR to LTE3}      Setup B1 Redirect Measurement
${all_imsi_list}        262033100000002,262033100000003,262033100000006,262033031503107,262033031503108,
...    262033031503159,262033031503147,262033031503151
${3UE_imsi_list}        262033100000002,262033100000003,262033100000006
*** Test Cases ***

CNI-128069_CB012118_FIM_Robustness_and_Exploratory
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T302    SCF_10_5_UTESRAN001T302_CNI128069    SWCONFIG_10_5_UTESRAN001T302
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}
    AT Operation    attach    ue_index=7
    Add LTE PA
    Sleep    5s
    AT Operation    start_call    ue_index=7  number=6688
    Sleep    10s
    AT Operation    start_traffic    ue_index=7  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    ...  remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    Check Redirect From NR to LTE    ${Redirect From NR to LTE1}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE2}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE3}
    AT Operation    stop_call    ue_index=7
    AT Operation    stop_traffic  ue_index=7   remote_hostname=10.56.218.7    remote_username=MTU    remote_password=MTU
    AT Operation    detach    ue_index=7
    Stop All Bts Log

*** Keywords ***
Initial Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PASwap_MIN_Value}
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",NR5G
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"lte_band\\",2
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nr5g_band\\",41
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=1
    Sleep    10s
    AT Operation    exec_at_command    ue_index=7   command=AT+CFUN=0
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
Add LTE PA
    Log To Console    Add LTE PA
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
Check Redirect From NR to LTE
    [Arguments]    ${Redirect_From_NR_to_LTE}
    Log To Console    Redirect From NR to LTE
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "${Redirect_From_NR_to_LTE}" | grep -av grep
    Should Contain    ${ret}    ${Redirect_From_NR_to_LTE}
Start UL Traffic
    [Arguments]    ${tput}=50M    ${tport}=5001    ${server_ip}=${spark_iperf_server}
    Connect All VM
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${server_ip}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=${tport}
    ...    tput_value=${tput}
    ...    tput_time=300s
    #Sleep    90s

Stop UL Traffic
    Connect All VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0

Send And Cap DL Traffic
    [Arguments]    ${tput}=50.00M
    Connect All VM
    ${ueip}=    AT Operation    get    ue_index=7  item=ueip    intf_name=ims
    gnb_tool.prepare_gnb_tool
    ${dl_server1}    Connect To IperfServer From Appservers
    ${ueip}    Start DL traffic By Iperf    time=6000    traffic=${tput}    dl_server=${dl_server1}
    ...    DL_port=${5001}

Start Capture Emil Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    ${local_file_path}    Log Collection    stop_and_download    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}

Initial UE
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nr5g_band\\",25:41:71
    Sleep     1s
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"lte_band\\",2:12:66:71
    Sleep     1s
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"nsa_nr5g_band\\",41:71
    Sleep     1s
    AT Operation    exec_at_command    ue_index=7   command=AT+QNWPREFCFG=\\"mode_pref\\",LTE:NR5G
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword    AT.Prepare UE
    Run Keyword And Ignore Error    Sleep     10s
Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    sleep     5s
    Run Keyword And Ignore Error    Stop UL Traffic
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${5001}
    Run Keyword And Ignore Error    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword And Ignore Error    Initial UE
    Run Keyword And Ignore Error    AT Operation    stop_call    ue_index=7
    Run Keyword And Ignore Error    AT Operation    detach    ue_index=7
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local