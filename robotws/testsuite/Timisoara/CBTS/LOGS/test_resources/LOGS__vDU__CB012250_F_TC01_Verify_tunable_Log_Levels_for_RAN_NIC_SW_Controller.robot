*** Settings ***
Documentation
...  Tests for CB012250-F

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/common_vdu.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Resource  ../../common_resources/M2M_Interface.robot


Library    taf.transport.ssh  WITH NAME  csn
Library    taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    ../resources/python/utils.py
Library    SSHLibrary
Library     DateTime

Variables  ../resources/python/My_NetAct.py

*** Variables ***

${alarm_presence}    ${False}

*** Keywords ***

TC__LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller

    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  update logLevel Nops
    ...  ******************
    ...  *AUTHOR*: radu.turcu@nokia.com

    Set Tags  CA-WebEM  OWNER-radu.turcu@nokia.com  AUTHOR-radu.turcu@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R3  FEATURE-CB01250-F


    Step 0: Precondition
    Step 1: Update logLevel to Debug
    Step 2: Check logs Debug messages
    Step 3: Update logLevel to wrong level
    Step 4: Check logs Warn messages

Step 0: Precondition
   [Documentation]
    ...   In this step Precond

    Log    \nStep 0: Precondition    console=${True}
    ${date}  Get Current Date  result_format=datetime
    Set Test Variable  ${START_DATE}  ${date}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}

    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable  ${ip_addr}    ${vdu_ssh_connection_params['ip_addr']}
    Set Test Variable  ${username}    ${vdu_ssh_connection_params['username']}
    Set Test Variable  ${password}    ${vdu_ssh_connection_params['password']}
    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp

Step 1: Update logLevel to Debug
    Log    \nStep 1: Update logLevel to Debug    console=${True}
    ${newLogLevel}=      Set Log Level       Debug
    should be equal as strings    ${newLogLevel}        Debug
    Log to console    Sleep 2 min
    sleep    2min

Step 2: Check logs Debug messages
    Log    \nStep 2: Check logs Debug messages    console=${True}
    ${cmd_kctl}=      Set Variable      oc get pods -n ran-nic-sw-controller | grep -a \"ran-nic-sw-controller\" | awk \'{print $1}\'
    ${currentPod}=    ssh.Execute    ${cmd_kctl}    connection=ocp
    ${currentPod}=    Fetch from left   ${currentPod}  \r\n
    ${cmd_kctl1}=     Set Variable    oc logs -n ran-nic-sw-controller ${currentPod}
    ${currentLog}=    ssh.Execute    ${cmd_kctl1}   connection=ocp
    ${lastLineLog}=     get line    ${currentLog}       -1
    should contain    ${lastLineLog}     [DEBUG] Successfully set log level to:

Step 3: Update logLevel to wrong level
    Log    \nStep 3: Update logLevel to wrong level    console=${True}
    ${newLogLevel}=      Set Log Level       Debugi
    should be equal as strings    ${newLogLevel}        Debugi
    Log to console    Sleep 2 min
    sleep    2min

Step 4: Check logs Warn messages
    Log    \nStep 2: Check logs Debug messages    console=${True}
    ${cmd_kctl}=      Set Variable      oc get pods -n ran-nic-sw-controller | grep -a \"ran-nic-sw-controller\" | awk \'{print $1}\'
    ${currentPod}=    ssh.Execute    ${cmd_kctl}    connection=ocp
    ${currentPod}=    Fetch from left   ${currentPod}  \r\n
    ${cmd_kctl1}=     Set Variable    oc logs -n ran-nic-sw-controller ${currentPod}
    ${currentLog}=    ssh.Execute    ${cmd_kctl1}   connection=ocp
    ${lastLineLog}=     get line    ${currentLog}       -1
    should contain    ${lastLineLog}     [WARN] Fail to update log level

Set Log Level
    [Arguments]  ${LogLevel}
    ${currentLogLevel}      Get LogLevel
    ${cmd_kctl2}=    Set Variable
    ...     oc get cm runtime-config -n ran-nic-sw-controller -o yaml | sed 's/${currentLogLevel}/${LogLevel}/g' | oc apply -f -
    ${currentLogLevel}=    ssh.Execute    ${cmd_kctl2}    connection=ocp
    ${newLogLevel}      Get LogLevel
    [Return]       ${newLogLevel}

Get LogLevel
    ${cmd_kctl1}=    Set Variable      oc get cm -n ran-nic-sw-controller runtime-config -o yaml | grep -a \\\"logLevel\\\": | awk \'{print $2}\'
    ${currentLogLevel}=    ssh.Execute    ${cmd_kctl1}    connection=ocp
    ${currentLogLevel}=   Replace String     ${currentLogLevel}    \"     ${EMPTY}   # Replace double quotes with an empty string
    ${currentLogLevel}=    Fetch from left   ${currentLogLevel}  \r\n
    log to console    Current logLevel is: ${currentLogLevel}
    [Return]    ${currentLogLevel}


Test Teardown
    [Documentation]
    ...   Teardown In this step Set Info LogLevel
    Log    \nTeardown: Set Info LogLevel    console=${True}
    Set Log Level       Info



TC Setup
    Common VDU Setup
#    Login Using M2M Interface  ${VDU_OAM_IP}
#    Log       ggggggg

TC Teardown

    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy
