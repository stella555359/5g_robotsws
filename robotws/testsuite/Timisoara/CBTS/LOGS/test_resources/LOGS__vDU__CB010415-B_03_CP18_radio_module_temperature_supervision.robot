*** Settings ***
Documentation
...  Tests for CB010415 CP18

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

*** Variables ***

${alarm_presence}    ${False}
#${cmd_kctl}    kubectl exec -it -n cran1 po-cran1-oamfh-0 -c ctr-cran1-oamfh -- bash
${al1938}    ${False}
${al4681}    ${False}
${frmon}  frmonShellClient 127.0.0.1 2000
*** Keywords ***

TC__LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision

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
    Step 1: Raise Alarm Pipe dangerously overheating 1938
    Step 2: Check Alarm 1938 is raised
    Step 3: Request Full Diagnostic Check Through M2M Interface
    Step 4: Check Alarm 4681 is raised

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

    log to console    ${VDU_ACTIVE_SW_RELEASE}:${command}
    ssh.Connect To  hostname=${ip_addr}  username=${username}  password=${password}    alias=ocp
    ${rf_ip}    ssh.Execute  ${command}  connection=ocp
    log to console    RFip is:${rf_ip}
    Set Test Variable    ${rf_ip}    ${rf_ip}

Step 1: Raise Alarm Pipe dangerously overheating 1938
     Log    \nStep 1: Raise Alarm Pipe dangerously overheating 1938    console=${True}

    Set Test Variable    ${command2}    echo "/ca action terminate"| ${frmon}
    Set Test Variable    ${command3}    echo "/trx1 action terminate"| ${frmon}
    Set Test Variable    ${command4}    echo "/ action create ThermometerDevice /trx1 /rf/pa1"| ${frmon}
    Set Test Variable    ${command5}    echo "/ action create ConfigAccess /ca /module"| ${frmon}
    Set Test Variable    ${command6}    echo '/ca action fetch DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"'| ${frmon}
    Set Test Variable    ${command6_1}  ls /ram/tcs_parameters.json
    #bck pentru teardown
    #ctrl-c
    Set Test Variable    ${command7}    echo '/ca action store PERMANENT DECODED "tcs_parameters.bin" "/ram/tcs_parameters.json"'| ${frmon}
    #ctrl-c
    #reboot rf

    Set Test Variable    ${command8}    echo '/ action create ThermometerDevice /trx1 /rf/pa1'| ${frmon}
    Set Test Variable    ${command9}    echo '/trx1 action override TEMPERATURE 150'| ${frmon}

    ${crtl_c}    Evaluate    chr(int(3))
    Set Test Variable    ${crtl_c}    ${crtl_c}
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
    Read  delay=1s
    Write    ${command4}
    sleep    2
    Read  delay=1s
    Write    ${command5}
    sleep    2
    Read  delay=1s
    Write    ${command6}
    sleep    2
    ${output4}=  Read  delay=1s
    log to console    o5:${output4}
    Write    ${crtl_c}
    ${output5}=  Read  delay=1s
    Write     ${command6_1}
    ${output6}=  Read  delay=2s
    log to console    tempfile:${output6}
    should not contain    ${output6}    No such file or directory

#    Write    sed -i 's/"tempOffset": 0.0/"tempOffset": 85.0/g' /var/tmp/tempest_inst1.json
    Write    cp /ram/tcs_parameters.json /ram/tcs_parameters_bck.json
    Write    sed -i 's/"NT_fail": 5/"NT_fail": 2/' /ram/tcs_parameters.json
    sleep    1
    Write    sed -i 's/"deltaTmulti": 50/"deltaTmulti": 120/' /ram/tcs_parameters.json
    sleep    1
    Write    sed -i 's/"deltaTctl": 5/"deltaTctl": 120/' /ram/tcs_parameters.json
    Read  delay=5s


    Write    ${command7}
    Read  delay=5s
    Write    ${crtl_c}
    Write    reboot
    sleep    180

#    Login SSH
#    read until prompt
    Write    ${cmd_kctl}
    ${output}=  Read  delay=2s
    Write    ssh -B lo root@${rf_ip}
    ${output1}=  Read  delay=2s
    log to console    ${output1}
    Write    yes
     ${output2}=  Read  delay=2s
    log to console    ${output2}

    Write    ${command8}
    Read  delay=5s
    Write    ${command9}
    Read  delay=5s

Step 3: Request Full Diagnostic Check Through M2M Interface
    Log  \nStep 3: Start Diagnostic Check through NMS.  console=true
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
#    Should Contain  ${diagnostic_get_output}  "status":"succeeded"
#    Log  Diagnostic GET request sent, "status":"succeeded"! [OK]  console=true

    ###get result:
    ${diagnostic_get_result}  Run M2M Command  GET    "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/report"
    ...  Bearer  ${TOKEN}
    log to console    Result:${diagnostic_get_result}



    ${string}  Fetch From Left  ${diagnostic_get_result}  Radio Module Temperature Supervision
    ${CP_result}  Fetch From Right  ${string}  EQM_R-1/APEQM_R-1/RMOD_R-1

    log to console    ${CP_result}
    Should contain    ${CP_result}   "checkpoint":18
    Should contain    ${CP_result}   "checkStatus":"Check point failure"

Step 2: Check Alarm 1938 is raised
    Log  \nStep 2: Check Alarm 1938 is raised  console=true
    Wait until keyword succeeds   15x    10s   Check Active Alarm    7116    1938
    Set Test Variable  ${al1938}    ${TRUE}

Step 4: Check Alarm 4681 is raised
    Log  \nStep 4: Check Alarm 4681 is raised  console=true
    Wait until keyword succeeds   12x    10s   Check Active Alarm    7115    4681
    Set Test Variable  ${al4681}    ${TRUE}

Check Active Alarm

    [Arguments]  ${alarm_id}  ${fault_id}

     Set Test Variable    ${alarm_presence}     ${False}

     ${active_alarms}  vdu.Vdu Get Active Alarms
     ${alarms_list}  Set Variable  ${active_alarms}[alarms]
     Set Test Variable    ${alarm_presence}    ${False}
     FOR  ${alarm}  IN  @{alarms_list}
#        Set Test Variable    ${alarm_presence}     ${False}

        ${status_alarm_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[alarm_id]  ${alarm_id}
        ${status_fault_id}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${alarm}[fault_id]  ${fault_id}
        Run Keyword If  ${status_alarm_id} and ${status_fault_id}
        ...  Run Keywords    Set Test Variable    ${alarm_presence}    ${True}
        ...  AND    Log  Alarm:${fault_id} is visible in active alarms
        ...  AND    Exit For Loop

     END
    Run Keyword If   ${alarm_presence}
        ...    Log  Alarm:${fault_id} is visible in active alarms
        ...    ELSE
        ...    Fail  Alarm with fault id: ${fault_id} is not visible in WebEM. [NOK]

Login SSH
    Open Connection  ${ip_addr}
    Login  core  ${password}

Clear alarm 1938

    Login SSH      #connect to OCP
    Write    ${cmd_kctl}
    ${output}=  Read  delay=2s

    Write    ssh -B lo root@${rf_ip}

    ${output1}=  Read  delay=2s
    log to console    ${output1}
    Write    yes
     ${output2}=  Read  delay=2s
    log to console    ${output2}

    Write    mv /ram/tcs_parameters_bck.json /ram/tcs_parameters.json
    Write    ${command7}
    Read  delay=5s
    Write    ${crtl_c}
    Write    reboot

    Wait until keyword succeeds   15x    20s   Wait alarm clear    7116    1938

Wait alarm clear
    [Arguments]    ${alarm_id}    ${fault_id}
    ${alarm_status}    run keyword and return status    Check Active Alarm    ${alarm_id}    ${fault_id}

    Run keyword if  ${alarm_status}
    ...  Fail    Fault ${fault_id} " - still present  console=${True}
    ...  ELSE PASS    Fault ${fault_id} - ok cleared  console=${True}

Clear alarm 4681
    ${diagnostic_post_output}  Run M2M Command  POST  "https://${VDU_OAM_IP}/api/licensed/v1/diagnostic-checks/operations/launches"  Bearer  ${TOKEN}
    ...  -d "{\\"allowServiceImpact\\":false}"
    Wait until keyword succeeds   20x    30s   Wait alarm clear    7115    4681

Test Teardown
    [Documentation]
    ...   Teardown In this step Clear Alarms

    Log    \nTeardown: Clear Alarms    console=${True}

    Run Keyword if    ${al1938}   Clear alarm 1938

    Run Keyword if    ${al4681}   Clear alarm 4681


TC Setup
    Common VDU Setup
    Login Using M2M Interface  ${VDU_OAM_IP}

TC Teardown

    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy
