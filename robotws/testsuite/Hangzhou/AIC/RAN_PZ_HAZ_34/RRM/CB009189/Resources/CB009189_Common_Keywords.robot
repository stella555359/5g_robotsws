*** Settings ***
Documentation
...    Author: y63li
...    Email address: ying.15.li@nokia-sbell.com
...    Description: This feature describes the admission control for specific SR period configured.


Resource    ../../../../RAN_PZ_HAZ_34/Resources/AIC_Counter_KPI.robot
Resource    ../../../../RAN_PZ_HAZ_34/Resources/AIC_BTS.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../RAN_PZ_HAZ_34/Resources/AIC_Common_Setup_Teardown.robot
Resource          ../../../../RAN_PZ_HAZ_34/Resources/AIC_Capture_Analysis_Log.robot
Library           ../../../../RAN_PZ_HAZ_34/Resources/python/basic.py    WITH NAME    basic
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           ../Resources/collect_logs.py    WITH NAME    wireshark
Library           ../Resources/command_result.py

Library     ssh_pcf.py
Library     ssh_pcf.pcf   WITH NAME    PCF
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${PC_HOST}                   ${tl.test_pc.default_ssh_connection_details.addr}
${PC_USER}                   ${tl.test_pc.default_ssh_connection_details.username}
${PC_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${MRBTS_ID}                  ${tl.gnbs[0].dus.instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].dus.global_bts_id}
${cu_master_ip}              ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
${cu_master_username}        ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
${cu_master_password}        ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
${PCF_IP}    ${tl.core.pcf.oam_ssh_connection_details.addr}
${PCF_username}    ${tl.core.pcf.oam_ssh_connection_details.username}
${PCF_password}    ${tl.core.pcf.oam_ssh_connection_details.password}
${ALIAS_PCF}    pcf
${ims}     262033
${VCU_NAMESPACE}    tl2054
${UE_TYPE}     samsung_vran20
${dl_tput}     300M
${ul_tput}     30M
${local_file_path}    /home/ute/log
${priorityLevel}    3
${TEST_LOG_DIRECTORY}     /home/ute/log
${server_ip}     ${tl.test_pc.default_ssh_connection_details.addr}
*** Keywords ***
Test Case Setup
    log to console    Test Case Setup
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

Test Case Teardown
    log to console     Test Case Teardown
    Run Keyword And Ignore Error    power_ue.UE Detach     ue_index=${1}    ue_type=${ue_type}
    Run Keyword And Ignore Error    Hang up VoNR call
    Run Keyword And Ignore Error    Exit the PCF service

Precondition
    log to console    \n*** Commission SCF ***
    vDU Full Commission SCF    scf_file=${SCF_PATH_9189}/${9189_DU_SCF}
    VCU Full Commssion    cu_scfc_path=${SCF_PATH_9189}/${9189_CU_SCF}

Start PCF Simulator
    log to console     Start PCF service
    Start PCF service    ims=${ims}    ip=${PCF_IP}

Connect to PCF server
    [Arguments]    ${alias}=${ALIAS_PCF}
    csn.Connect to    hostname=${PCF_IP}
    ...    username=${PCF_username}
    ...    password=${PCF_password}
    ...    alias=${alias}
    [Return]    ${alias}

Exit the PCF service
    Connect to PCF server
    csn.send command  ps -ef | grep sim | grep -v grep | grep 5g | awk '{print $2}' | xargs kill -2    connection=${ALIAS_PCF}
    sleep    5S

Start PCF service
    [Arguments]    ${ims}    ${ip}
    PCF.pcf_connect    ip=${PCF_IP}    username=${PCF_username}    password=${PCF_password}
    PCF.pcf_start    ims=${ims}    ip=${ip}

Configure and commit the QoS
    [Arguments]    ${five_qi}    ${priorityLevel}    ${server_ip}
    PCF.pcf_add_one_QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}

Start wireshark log collection
    log to console   Start wireshark log collection
    Start Wireshark Log In vCU
    ...                          hostname=${cu_master_ip}
    ...                          username=${cu_master_username}
    ...                          password=${cu_master_password}
    ...                          container_name=nwmgmt


Attach UE
    log to console    Attach UE
    power_ue.Prepare UE    ue_index=${1}    ue_type=${ue_type}
    power_ue.UE Attach     ue_index=${1}    ue_type=${ue_type}    attach_mode=5G_SA

Detach UE
    log to console     Detach UE
    UE Detach    ${ue_type}    ue_index=${0}


ADD DRB with 5QI${five_qi}
    log to console    ADD DRB with 5QI${five_qi}
    Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}
    sleep    2s

Start VONR call
    log to console    Start VONR call
    [Arguments]    ${ue_index}=${1}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin${ue_index}
    sleep    2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Hang up VoNR call
    [Arguments]    ${ue_index}=${1}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Stop Wireshark Log in CU And Check message
    log to console   Stop Wireshark Log
    [Arguments]    ${5qi}=${1}    ${SR_Period}=${0}
    ${local_file_path}    Stop Wireshark Log With Non Root And Download To K8s Master In vCU
    ...                          hostname=${cu_master_ip}
    ...                          username=${cu_master_username}
    ...                          password=${cu_master_password}
    ...                          container_name=nwmgmt
    log to console    analyse the logs
    cap.read_cap      cap_file=${local_file_path}    display_filter=ngap||f1ap
    ${filter_1} =    Catenate   ngap.fiveQI == ${5qi} || f1ap.RRCReconfigurationCompleteIndicator == 0
    cap.Check Expression    ${filter_1}
    ${filter_2} =    Catenate    nr-rrc.periodicityAndOffset == ${SR_Period}
    cap.Check Expression    ${filter_2}

Check Counter
    Log to console    \n***Check DU counter***
    ${du_counter_id_list}    Create List    M55165C00505   M55165C00511    M55165C00517
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-2054/NRBTS-2054/NRCELL-1
        ...                                            expected_value=0
        ...                                            get_number=3
    END
