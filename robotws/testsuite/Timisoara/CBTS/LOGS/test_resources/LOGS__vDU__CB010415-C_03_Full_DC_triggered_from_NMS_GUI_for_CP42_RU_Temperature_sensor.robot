*** Settings ***
Documentation
...  Tests for CB010415

Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/common_vdu.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Resource  ../../common_resources/M2M_Interface.robot


Library    taf.transport.ssh  WITH NAME  csn
Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    ../resources/python/utils.py
Library    SSHLibrary
Library     DateTime

Variables  ../resources/python/My_NetAct.py
#Variables  ../../common_resources/python_resources/common_variables.py

*** Variables ***

#${K8s_USERNAME}    core
#${K8s_PASSWORD}    System123

#${alarm1}    70158  #  FILE SYSTEM USAGE OVER LIMIT
#${alarm2}    165128    #  Diagnostic Check Error
${alarm_presence}    ${False}
#${cmd_kctl}    kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- bash
${al1938}    ${False}
${al4681}    ${False}
${frmon}  frmonShellClient 127.0.0.1 2000
*** Keywords ***

TC__LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor

    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  DC failed with CP18
    ...  ******************
    ...  *AUTHOR*: dan.moldovan@nokia.com

    Set Tags  CA-WebEM  OWNER-dan.moldovan@nokia.com  AUTHOR-dan.moldovan@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R1  FEATURE-CB10415-D


    Step 0: Precondition
    Step 1: RF override FAULTY
    Step 2: Request Full Diagnostic Check Through M2M Interface

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


    ${command_pod}    Set variable    oc get pod -n cran1 |grep oamfh | awk \'{print $1}\'
    ${command_ctr_begin}    Set variable    oc -n cran1 describe pod

    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp
    ${pod}    ssh.Execute  ${command_pod}  connection=ocp
    ${pod}=    Fetch from left   ${pod}  \r\n
    ${command_ctr}=  catenate  ${command_ctr_begin} ${pod} |grep ctr-oamfh | awk 'NR==1 {print $2}'
    ${command_ctr}=    Fetch from left   ${command_ctr}  \r\n
    ${cont}    ssh.Execute  ${command_ctr}  connection=ocp
    ${cont}=    Fetch from left   ${cont}  \r\n
    Set Test Variable    ${cmd_kctl_new}    kubectl exec -it -n cran1 ${pod} -c ${cont} -- bash

    Run keyword if    '${VDU_ACTIVE_SW_RELEASE}' == 'vDUCNF25R3'
    ...    Set Test Variable    ${cmd_kctl}    kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- bash
    ...    ELSE    Set Test Variable    ${cmd_kctl}    ${cmd_kctl_new}

    ${command}=  catenate    ${cmd_kctl}
    ...    -c "{ echo \\"aasyscomgw -r\\";sleep 3;echo \\"quit\\"; } | nc 127.0.0.1 15067;" | grep -a "192.170" |grep UDPCP | awk \'{print $7}\'

    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp
    ${rf_ip}    ssh.Execute  ${command}  connection=ocp
    log to console    RFip is:${rf_ip}
    Set Test Variable    ${rf_ip}    ${rf_ip}

Step 1: RF override FAULTY
     Log    \nStep 1: RF override FAULTY   console=${True}

    Set Test Variable    ${command2}    echo "/ca action terminate"| ${frmon}
    Set Test Variable    ${command3}    echo "/ action create ConfigAccess /ca /module"| ${frmon}
    Set Test Variable    ${command4}    echo "/ action create ThermometerDevice /CI/ThermoModule /rf/pa1"| ${frmon}
    Set Test Variable    ${command5}    echo "/CI/ThermoModule action override FAULTY"| ${frmon}

    ${crtl_c}    Evaluate    chr(int(3))
    Login SSH
#    read until prompt
    Write    ${cmd_kctl}
    ${output}=  Read  delay=2s

    Write    ssh -B lo root@${rf_ip}

    ${output1}=  Read  delay=2s
    log to console    ${output1}
    Write    yes
     ${output2}=  Read  delay=2s
    log to console    ${output2}

    Write    ${command2}
    sleep    2
    Write    ${command3}
    sleep    2
    ${output3}    Read  delay=1s
    should contain    ${output3}     done ok
    Write    ${command4}
    sleep    2
    ${output4}    Read  delay=1s
    should contain    ${output4}     done ok
    Write    ${command5}
    sleep    2
    ${output5}    Read  delay=1s
    should contain    ${output5}     done ok


Step 2: Request Full Diagnostic Check Through M2M Interface
    Log  \nStep 2: Request Full Diagnostic Check Through M2M Interface  console=true
    sleep    120

    wait until keyword succeeds    3x    5min    Request Full Diagnostic Check Through M2M Interface

Request Full Diagnostic Check Through M2M Interface
    ${current_date_time}  Get Current Time For Diagnostic Check
    Set Test Variable  ${CURRENT_DATE_TIME}
    ${diagnostic_post_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":false}"
    Should Contain  ${diagnostic_post_output}  "status":"ongoing"
    Log  Diagnostic POST request sent, "status":"ongoing"! [OK]  console=true
    ${diagnostic_op_id}  Get Operation Id Value - Longer Version  ${diagnostic_post_output}
    Set Test Variable  ${DIAGNOSTIC_OP_ID}
    Sleep  240s  Wait for Diagnostic check to be done.

    ${diagnostic_get_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches/${DIAGNOSTIC_OP_ID}"
    ...  Bearer  ${TOKEN}

    ###get result:
    ${diagnostic_get_result}  Run M2M Command  GET    "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/report"
    ...  Bearer  ${TOKEN}
    log to console    Result:${diagnostic_get_result}

    ${string}  Fetch From Left  ${diagnostic_get_result}  RU Temperature sensor
    ${CP_result}  Fetch From Right  ${string}  EQM_R-1/APEQM_R-1/RMOD_R-1

    log to console    ${CP_result}
    Should contain    ${CP_result}   "checkpoint":42
    Should contain    ${CP_result}   "checkStatus":"Check point failure"


Login SSH
    Open Connection  ${ip_addr}
    Login  core  ${password}


Clear faulty

    Login SSH      #connect to OCP
    Write    ${cmd_kctl}
    ${output}=  Read  delay=2s

    Write    ssh -B lo root@${rf_ip}

    ${output1}=  Read  delay=2s
    log to console    ${output1}
    Write    yes
     ${output2}=  Read  delay=2s
    log to console    ${output2}

    Write    reboot

Clear alarm 4681
    ${diagnostic_post_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":false}"
    Wait until keyword succeeds   20x    20s   Wait alarm clear    7115    4681

Test Teardown
    [Documentation]
    ...   Teardown In this step Clear Alarms

    Log    \nTeardown: Clear Alarms    console=${True}

    Clear faulty


TC Setup
    Common VDU Setup
    Login Using M2M Interface  ${VDU_OAM_IP}

TC Teardown

    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy
