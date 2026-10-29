***Settings ***
Documentation
    ...     [Procedure]             "RP002338-A-a - One logical SBTS with mixed (ASIA/ASIB) dual common units operation"
    ...     [Date]                  "02-03-21"
    ...     [Author]                "Madhuri Thokala"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Upgrade Branch ,Rollback,3RAT 0n-air,Snapshot and IMsanpshot,SOE and SSH "
    ...     [Feature_ID]            "RP002338-A"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5GET-TRSIV-TL3815"


variables	   ta_e2e_bts_trs_fw
Resource  	   taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Library         SSHLibrary



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${host}             10.58.143.176
${username}         ute
${password}         ute
${index}                    1
${length}                   1

*** Test Cases ***
TRS_SR002338_upgrade_commissioning_snapshot_IM_log_collection
    ${mplane_ipv4_1}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4_1}

    setup oamops    bts_host=${mplane_ipv4_1}    alias=upgrade_mplane
    Collect Im Snapshot     timeout=300
    Collect Snapshot        timeout=1200
    ${mplane_ipv4_1}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4_1}
    Perform Recommissioning        type=delta      delta_file=${SR002338_3RAT_SOE_Disable_Primary}
    ...       skip_parameter_relation_errors=${True}      timeout=300    alias=upgrade_mplane
    Sleep    20
    ${output}=    Run    ping -c 2 ${mplane_ipv4_1}
    Should Contain    ${output}   ${packet_loss_0}
    ${output2}=    Run    ping -c 2 ${SOE_IP}
    Should Contain    ${output2}   ${packet_loss_0}
    ${output3}=    Run    ping -c 2 ${LMP_IP}
    Should Contain    ${output3}   ${packet_loss_0}
    Perform Recommissioning        type=delta      delta_file=${SR002338_3RAT_SOE_Enable_Primary}
    ...       skip_parameter_relation_errors=${True}      timeout=300    alias=upgrade_mplane
    Sleep    20
    ${output4}=    Run    ping -c 2 ${mplane_ipv4_1}
    Should Contain    ${output4}   ${packet_loss_0}
    ${output}=    Run    ping -c 2 ${SOE_IP}
    Should Contain    ${output}   ${packet_loss_100}
    Run Keyword And Ignore Error    Perform software download and update     wft_profile=sbtstrunk_00
    ...     package=auto     activate_sw=true    update_timeout=5500    alias=upgrade_mplane
    Sleep    300
    Reset Bts       verify_bts=True  vreq_rat=all     should_be_onair=True     wait_for=1000    alias=upgrade_mplane
    Sleep   10
    ${output5}=    Run    ping -c 2 ${mplane_ipv4}
    Should Contain    ${output5}   ${packet_loss_0}
    ${output6}=    Run    ping -c 2 ${SOE_IP}
    Should Contain    ${output6}   ${packet_loss_100}
   Sleep    20
    ${output7}=    Run    ping -c 2 ${mplane_ipv4}
    Should Contain    ${output7}   ${packet_loss_0}
    ${output8}=    Run    ping -c 2 ${SOE_IP}
    Should Contain    ${output8}   ${packet_loss_0}
    ${output9}=    Run    ping -c 2 ${LMP_IP}
    Should Contain    ${output9}   ${packet_loss_0}
   Collect Im Snapshot     timeout=300
   Collect Snapshot        timeout=2000
   [Teardown]    Teardown oamops    alias=upgrade_mplane

***Keywords***

Verify SSH Login
    Setup Remote Access     remote_device=Primarybts
    [Teardown]  Teardown Remote Access

Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Verify rechability of SecondaryBTS
    SSHLibrary.Open Connection  ${host}
    SSHLibrary.Login            ${username}  ${password}
    ${stdout}=                  SSHLibrary.Execute Command     ping 192.168.255.119 -c 4
    Log                         ${stdout}
    Should contain      ${stdout}     4 packets transmitted, 4 received, 0% packet loss


Check SSH status
    ${status}=     Get Parameter     param_path=MRBTS-3815/MNL-1/MNLENT-1/SECADM-1:actServiceAccountSsh     dut=bts    timeout=120     alias=default
    Should Be True      ${status}==True


check BTS status and unexpected alarms
    Verify Alarm        faultid=4352     rat=lte     should_exist=${False}  occurrences=1     check_unexpected_alarms=${False}
    Verify Alarm        faultid=6450     rat=lte     should_exist=${False}  occurrences=1     check_unexpected_alarms=${False}

Perform SW upgrade
    ${active}       ${passive}=         Get Sw Version          timeout=30
    ${status}=  Run Keyword And Return Status       Should Contain      ${active}            SBTS22R3
    Run Keyword If      ${status}==True     Perform Software Download And Update    wft_profile=branch_SBTS22R3
    ...      package=auto    activate_sw=True    update_timeout=3800
    ...     ELSE        Perform Software Download And Update    wft_profile=sbtstrunk_00      package=auto    activate_sw=True    update_timeout=3800
verify expected and unexpected alarms
    Verify Alarm        faultid=4352     rat=lte     should_exist=${True}  occurrences=1     check_unexpected_alarms=${False}
    Verify Alarm        faultid=6450     rat=lte     should_exist=${False}  occurrences=1     check_unexpected_alarms=${False}
Poweroff_BTS
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 0
    Sleep   120
    [Teardown]  Teardown Remote Access
Poweron_BTS
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 1
    Sleep   120
    [Teardown]  Teardown Remote Access
verify alarm is cleared on primary core
    Verify Alarm        faultid=4352     rat=lte     should_exist=${false}  occurrences=1     check_unexpected_alarms=${false}
