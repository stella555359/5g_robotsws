*** Settings ***
Documentation
...    Author: Chen Jiahao
...    Contact: jiahao.chen@nokia-sbell.com
...    this file is for CB008126_CR.
...    Please do not modify the file without notification to author


Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
Test Setup        Run keywords    Common Test Setup For AIC    AND    Case Setup
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC
Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20?TA_LEVEL_21? TA_LEVEL_22]

Test Timeout    600 minutes

*** Variables ***
${PA_MaxValue}           ${63}
${PA_NormalValue}        ${1}
${PA_MinValue}           ${0}
${FLAG_USE_UE_MODULE}    ${True}
${step_cmd}    proc node pcf 1 policy-update-notify all


*** Test Cases ***
Upgrade
    AIC Upgrade vCU And vDu by Kuafu For All
Case1_Successful_5QI_Modification_initiated_by_5GC_for_an_existing_non_GBR_QoS_Flow_different_DRB_profile

    Load CB008126 SCF for vDU
    Load CB008126 SCF for vCU
    Sleep    1 minute
    wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair

    ADB.Prepare UE
    ADB.UE Detach

    ${pcf_simulator}=  Pet Pcf Simulator Setup  host=10.56.218.70   username=ute   password=Nokia123!   appname=sim-5g-new
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/service_26203_on.pcf

    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}

    ADB.UE Attach
    Sleep    120s    reason=Wait For Attach

    ${rule1}    Catenate
    ...         Distname: MRBTS-37152/NRBTS-11074;
    ...         Counter: M55319C12009;
    ...         Counter rule: max(M55319C12009)
    ${rule2}    Catenate
    ...         Distname: MRBTS-37152/NRBTS-11074;
    ...         Counter: M55319C16009;
    ...         Counter rule: max(M55319C16009)
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}


    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    Log To Console    senddata
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=3600    traffic=50M    dl_server=${dl_server1}
    ...    DL_port=${50001}
    sleep    5s

    Qualcomm8350.Start UL Traffic By MagicIperf      tput_time=3600s      tput_value=20000k      server_ip=10.56.198.156

    Log To Console    sleep 10min
    sleep    10min
    ${value1}    Counter Operation    operation=collect_counter_and_calculate    product_type=vcu    cudu_index=0

    Log To Console    5QI9-5QI8
    Run Script File On PCF Simulator  ${pcf_simulator}    ${CURDIR}/5QI9_to_5QI8.pcf
    Run Command On PCF Simulator    ${pcf_simulator}    ${step_cmd}

    ${rule3}    Catenate
    ...         Distname: MRBTS-37152/NRBTS-11074;
    ...         Counter: M55319C12008;
    ...         Counter rule: max(M55319C12008)
    ${rule4}    Catenate
    ...         Distname: MRBTS-37152/NRBTS-11074;
    ...         Counter: M55319C16008;
    ...         Counter rule: max(M55319C16008)
    ${rule_list}    Create List    ${rule3}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}

    Log To Console    sleep 10min
    sleep    10min
    ${value2}    Counter Operation    operation=collect_counter_and_calculate    product_type=vcu    cudu_index=0

    ${DL_cpmpare}    Evaluate    abs((${value1}[check_result][${rule1}]-${value2}[check_result][${rule3}])/${value1}[check_result][${rule1}])
    # ${UL_cpmpare}    Evaluate    abs((${value1}[check_result][${rule2}]-${value2}[check_result][${rule4}])/${value1}[check_result][${rule2}])
    Should be true    ${DL_cpmpare}<=${0.1}
    # Should be true    ${UL_cpmpare}<=${0.1}

    ${dl_server1}    Connect To IperfServer From Appservers
    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.iperf_details.port}      connection=${dl_server1}

    Qualcomm8350.Stop UL Traffic By MagicIperf

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Check PDU session establishment accept In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Analysis Wireshark Log    ${capture_file_path}    append_cmd=--enable-protocol NAS-5GS
    ...    filter_expression=ngap
    Should Contain    ${output}    PDU session establishment accept

Load CB008126 SCF for vDU
    Parameter Operation    operation=full_commission   product_type=vdu
    ...    scf_path=${CURDIR}/vdu_CB008126_SCF_11074.xml

Load CB008126 SCF for vCU
    Parameter Operation    operation=full_commission   product_type=vcu
    ...    scf_path=${CURDIR}/vcu_CB008126_SCF_11074.xml
