*** Settings ***
Documentation
...   author: jiahao.chen
...   contact: jiahao.chen@nokia-sbell.com
...   this is a robot case about CB008234-SR-A

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

${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
${PA_HoValue}            ${50}
${PA_MinValue}           ${0}
${host}              10.56.198.156
${username}          ute
${password}          Nokia123!
${parameter}         actUlAmbr
${file_path1}         ${CURDIR}/PDU_AMBR.txt
${file_path2}         ${CURDIR}/UE_AMBR.txt
${file_path3}         ${CURDIR}/PDU_AMBR_2.txt
${file_path4}         ${CURDIR}/PDU_AMBR_modify.txt
${file_path5}         ${CURDIR}/PDU_AMBR_initial.txt
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
&{fault_4001}              faultId=${4001}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_4001}
# ${DEBUG_MODE}        ${TRUE}


*** Test Cases ***
CB008234_A_B1 DL AMBR limitation for the non_GBR bearer of the SA UE
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008234_ST_A_Case01
    AT.Prepare UE
    Start Multi Bts Log

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

	sleep    10s

    Unblock BTS11688 NRCell_2
    AT.UE Attach
    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=900    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    2min

    Check DL data limit by UE AMBR

    Disable DL UE AMBR
    sleep    5s

    Check DL data limit by UE AMBR

    AT.UE Detach
    sleep    10s

    AT.UE Attach
    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=900    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    2min


    Check DL data not limit by UE AMBR

    Enable DL UE AMBR
    sleep    5s

    Check DL data not limit by UE AMBR

    AT.UE Detach
    sleep    10s


    AT.UE Attach
    sleep    10s

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=900    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    2min

    Check DL data limit by UE AMBR


CB008234_A_B6 DL AMBR limitation handling with PDU Session Modify
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008234_ST_A_B6
    AT.Prepare UE
    Start Multi Bts Log

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path3}
	sleep    10s
    Unblock BTS11688 NRCell_2
    AT.UE Attach
    sleep    10s
    Wait Until Keyword Succeeds    8x    2min    Set APN by ADB as stdata1
    # Check SA State For BTS0
    sleep    5s
    AT.UE Detach
	sleep    10s

    AT.UE Attach
    sleep    10s
    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=900    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    2min
    Check DL data limit by UE AMBR

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path4}
    sleep    2min
    Check DL data limit by PDU AMBR modify


USCB008234_D AMBR_DL_UL limitation interworking with CB009059 RLC_UM DRB for non-GBR setting
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008234_ST_D_CB009059_UM
    AT.Prepare UE
    Start Multi Bts Log

    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path1}
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}
	sleep    10s
    Unblock BTS11688 NRCell_2
    AT.UE Attach
    sleep    10s
    Wait Until Keyword Succeeds    8x    2min    Set APN by ADB as mdrb.nokia.com
    # Check SA State For BTS0
    sleep    5s
    AT.UE Detach

    Unblock BTS11688 NRCell_2
    AT.UE Attach
    sleep    10s
    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI7
    Start DL traffic By Iperf    time=1200    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep    2min
    Check DL data limit by UE AMBR

    UE PDU Session Modify    identifier=262033100009410    rule=ADD-5QI6-KL
    sleep    5s
    Check gNB Scell Add

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI6
    Start DL traffic By Iperf    time=1200    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${50001}
    sleep    2min
    Check DL data limit by UE AMBR 5QI7 and 5QI6

    UE PDU Session Modify    identifier=262033100009410    rule=ADD-5QI9-KL
    sleep    5s
    Check gNB Scell release

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    #5QI9
    Start DL traffic By Iperf    time=1200    traffic=50.00M    dl_server=${dl_server1}
    ...    DL_port=${50002}
    sleep    2min
    Check DL data limit by UE AMBR 5QI7 and 5QI6 and 5QI9


    Restart Bts log

    UE PDU Session Modify    identifier=262033100009410    rule=DEL-5QI9-KL
    sleep    5s
    Check gNB Scell Add
    sleep    2min
    Check DL data limit by UE AMBR 5QI7 and 5QI6

USCB008234_D_B10 UL UE AMBR interworking with FR1 UL CA
    [Documentation]    author:jiahao.chen
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008234_ST_D_ULCA
    AT.Prepare UE
    Start Multi Bts Log
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path2}

    Unblock BTS11688 NRCell_1
    AT.UE Attach
    sleep    10s
    Unblock BTS11688 NRCell_2

    Start UL Traffic    tport=${5001}    server_ip=10.56.221.13
    sleep    20s

    Check ULCA

    sleep    2min

    Check UL data limit by UE AMBR
    Stop UL Traffic

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    Change Commission To Unlock cell
    Run Keyword And Ignore Error    Restore APN by ADB
    Run Keyword And Ignore Error    Restore PDU AMBR
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    # Run Keyword If Test Passed     Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Restore PDU AMBR
    Run Cmd Of File In Remote Server   ${host}  ${username}   ${password}   ${file_path5}

Restore APN by ADB
    Set APN by ADB as stdata1

Stop All Bts Log
    Stop All BTSLog And Download to Local

# Run Cmd Of File In Remote Server
#     [Arguments]  ${host}    ${username}    ${password}    ${file_path}
#     ${context}    Get File    ${file_path}
#     csn.Connect To    hostname=${host}    username=${username}    password=${password}    alias=remote_server_${host}
#     csn.Execute    command=${context}    connection=remote_server_${host}
#    # Should Contain ${ret}, result\="success"
#     ssh .Disconnect    connection=remote_server_${host}

Unblock BTS11688 NRCell_2
    Log To Console    Unblock BTS11688 NRCell_2
    Modify Attenuation For One RRU Of One Site    ru_id=${7}    gnb_id=${0}    value=${PA_MinValue}

Disable DL UE AMBR
    @{para_list}      Create List    actDlAmbr
    @{mo_list}        Create List    MRBTS-11688/NRBTS-11688
    @{value_list}     Create List    disabled
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Enable DL UE AMBR
    @{para_list}      Create List    actDlAmbr
    @{mo_list}        Create List    MRBTS-11688/NRBTS-11688
    @{value_list}     Create List    SA
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Check DL data limit by UE AMBR
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12007;
    ...         Counter rule: latest(M55319C12007)
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${DL_cpmpare}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    Should be true    ${DL_cpmpare}<=33000

Check DL data not limit by UE AMBR
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12007;
    ...         Counter rule: latest(M55319C12007)
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${DL_cpmpare}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    Should be true    ${DL_cpmpare}>=33000

Check DL data limit by PDU AMBR modify
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12007;
    ...         Counter rule: latest(M55319C12007)
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${DL_cpmpare}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    Should be true    ${DL_cpmpare}<=22000

Check gNB Scell Add
    Log To Console    Check gNB Scell Add
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a Received TaskDone for ueSCellAdditionTask - OK | grep -av grep
    Should Contain    ${ret}    Received TaskDone for ueSCellAdditionTask - OK

Check gNB Scell release
    Log To Console    Check gNB Scell release
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a Received TaskDone for ueSCellReleaseCompleteTask - OK | grep -av grep
    Should Contain    ${ret}    Received TaskDone for ueSCellReleaseCompleteTask - OK

Check DL data limit by UE AMBR 5QI7 and 5QI6
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12007;
    ...         Counter rule: latest(M55319C12007)
    ${rule2}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12006;
    ...         Counter rule: latest(M55319C12006)
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${DL_cpmpare_5QI7}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    ${DL_cpmpare_5QI6}    Evaluate    ${value1}[check_result][${rule2}]*8/60
    Should be true    ${DL_cpmpare_5QI7}<=11500
    Should be true    ${DL_cpmpare_5QI6}<=21500

Check DL data limit by UE AMBR 5QI7 and 5QI6 and 5QI9
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12007;
    ...         Counter rule: latest(M55319C12007)
    ${rule2}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12006;
    ...         Counter rule: latest(M55319C12006)
    ${rule3}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C12009;
    ...         Counter rule: latest(M55319C12009)
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${DL_cpmpare_5QI7}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    ${DL_cpmpare_5QI6}    Evaluate    ${value1}[check_result][${rule2}]*8/60
    ${DL_cpmpare_5QI9}    Evaluate    ${value1}[check_result][${rule3}]*8/60
    Should be true    ${DL_cpmpare_5QI7}<=6000
    Should be true    ${DL_cpmpare_5QI6}<=11500
    Should be true    ${DL_cpmpare_5QI9}<=16500

Restart Bts log
    Stop BTSLite For Btslog On VM0
    Start BTSLite For Btslog On VM    btslog_name=restart.log

UE PDU Session Modify
    [Arguments]    ${rule}    ${identifier}=262033100009410
    Core_net.Setup    host=10.110.137.235    port=8443
    Core_net.Send Custom Rule    identifier=${identifier}    rule=${rule}

Set APN by ADB as stdata1
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=stdata1
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    stdata1

Set APN by ADB as mdrb.nokia.com
    ADB.Prepare UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Set APN By Uiauto    apn=mdrb.nokia.com
    ${ret}=    Qualcomm.Get APN By Uiauto
    Should Contain    ${ret}    mdrb.nokia.com

Check ULCA
    Log To Console    Check ULCA
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a uplinkConfigCommon | grep -av grep
    Should Contain    ${ret}    uplinkConfigCommon

Unblock BTS11688 NRCell_1
    Log To Console    Unblock BTS11688 NRCell_1
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_MinValue}

Check UL data limit by UE AMBR
    ${rule1}    Catenate
    ...         Distname: MRBTS-11688/NRBTS-11688;
    ...         Counter: M55319C16007;
    ...         Counter rule: latest(M55319C16007)
    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     wait_for_next_counter_generate={Ture}
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0

    ${UL_cpmpare}    Evaluate    ${value1}[check_result][${rule1}]*8/60
    Should be true    ${UL_cpmpare}<=11500
    Should be true    ${UL_cpmpare}>=5000

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
    ...    tput_time=3000s
    #Sleep    90s

Stop UL Traffic
    Connect All VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=5001
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0