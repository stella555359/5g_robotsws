*** Settings ***
Documentation   TestCases for CNI-146617.
...
...  author:  Julia Wijas
...  contact: julia.wijas@nokia.com

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/mantaray/mantaray.robot
Resource    ../../../common_resources/variables/variables.robot
Resource    ../../../common_resources/ip_traffic/ip_traffic.robot

Library     SSHLibrary

*** Variables ***
${COUNT1}=                  500
${COUNT2}=                  501
${INTERVAL}=                1s
${MAX_SIZE}=                5

*** Keywords ***
CNI-146617_SECU_Verify_Duration_of_Audit_Trail_Logs_Upload
    Log    Step 1: Integration to MantaRay without TLS    console=true
    ${NMS_LAB}    Integrate BTS to MantaRay without TLS   PREFERRED_LAB=srnclab2010
    Log    Step 2: Chenging the parameter ne3sOperationLogging to True          console=true
    Change parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                 ne3sOperationLogging
    ...                                 true
    Log    Step 3: Disconncting BTS from NetAct by setting oamTls parameter different between SBTS and Netact     console=true
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        oamTls
    ...                        forced
    Log    Step 4: Starting PCAP                                                console=true
    Start TCPDump
    Log    Step 5: Running script                console=true
    FOR    ${i}    IN RANGE    ${COUNT1}
        SSHLibrary.Open Connection    host=${LMP_IP}    prompt=>
        SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
        SSHLibrary.Close Connection
        LOG    Logon to ${LMP_IP} done ${i}    console=${True}
        Sleep    ${INTERVAL}
    END
    SSHLibrary.Open Connection    host=${LMP_IP}    prompt=>
    SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    ${size}=      SSHLibrary.Execute Command       du -h /tmp/ne3sadapt/notifs/atl_queue | cut -f1
    SSHLibrary.Close Connection
    Log     Size of ATL queue is ${size}     console=true
    ${size}=      Remove String    ${size}    M
    Should Be True    ${size} < ${MAX_SIZE}
    Log    Step 6: Conncting to Netact by setting oamTls to off     console=true
    Change parameter on BTS    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                        oamTls
    ...                        off
    Log    Step 6: Uploading Atl Logs to NMS    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${NMS_LAB}
    SSHLibrary.Open Connection   host=${atl_node_ip}
    SSHLibrary.Login             username=${NMS_USERNAME}       password=${NMS_PASSWORD}
    SSHLibrary.Write             su ${NMS_ROOT_USER}
    Sleep    5s                  reason=Waiting until password can be written
    SSHLibrary.Write             ${NMS_ROOT_PASS}
    Sleep    2s                  reason=Waiting for user change
    SSHLibrary.Write   sudo su
    Sleep    3s                  reason=Waiting for user changing
    SSHLibrary.Write   smanager.pl status service dmgr | cut -d ':' -f 2
    ${dmgr_node}=   SSHLibrary.Read Until    \n
    SSHLibrary.Write   ssh root@${dmgr_node}
    ${login_info}=  SSHLibrary.Read          delay=10s
    Should Contain  ${login_info}            You are about to access a private system.
    Sleep    2s                   reason=Waiting for user changing
    SSHLibrary.Write    /opt/oss/NSN-atlc/bin/slnbi-cli.sh log-upload --dn PLMN-PLMN/MRBTS-${BTS_ID}
    ${upload_start}=    SSHLibrary.Read           delay=30s
    Should Contain      ${upload_start}           Log Upload
    Sleep    25s        reason=Waiting for upload status
    SSHLibrary.Write    /opt/oss/NSN-atlc/bin/slnbi-cli.sh basic-check --dn PLMN-PLMN/MRBTS-${BTS_ID}
    ${upload_finish}=   SSHLibrary.Read           delay=10s
    ${status}=  Run Keyword And Return Status     Should Contain      ${upload_finish}          FINISHED
    Run Keyword If      ${status}==${FALSE}       Should Contain      ${upload_finish}          PRESENT
    Log    Step:7 Stop collecting and download TCPdump      console=true
    ${file_path}=         Stop TCPDump And Download PCAP  tcpdump_filename=log_upload.pcap
    Log    Step:8 Check wireshark, the BTS shall complete the audit trail logs upload operation within 20 seconds    console=true
    ${pcap_filters}=      Catenate  frame contains \"ne3s_atl_logUploadNotification\" && ip.src == ${MPLANE_IPV4} && tcp.flags.push == 1
    ${time}=       Run    tshark -r ${file_path} -Y '${pcap_filters}' -T fields -e frame.time_epoch
    @{time}=       Split String    ${time}    \n
    ${first_frame}=   Get From List    ${time}    0
    ${last_frame}=    Get From List    ${time}    -1
    ${upload_time}=   Evaluate         ${last_frame} - ${first_frame}
    Log    Time of uploading ATL logs to NMS: ${upload_time}s     console=true
    Should Be True    ${upload_time} < 20
    Deintegrate BTS from MantaRay    ${NMS_LAB}
    [Teardown]    Run Keywords       Run Keyword And Continue On Failure    SSHLibrary.Close All Connections
    ...           AND                Run Keyword And Ignore Error           Deintegrate BTS from MantaRay    ${NMS_LAB}

CNI-146617_SECU_Verify_BTS_Capacity_for_Audit_Trail_Logs
     Log    Step 1: Integration to MantaRay without TLS    console=true
     ${NMS_LAB}    Integrate BTS to MantaRay without TLS   PREFERRED_LAB=srnclab2010
     Check If Local ATL Is Configured     ${NMS_LAB}
     Clear ATL                            ${NMS_LAB}
     Sleep    60s    reason=Wait more time to be sure that all logs will be captured
     Log    Step 2: Starting PCAP                          console=true
     Start TCPDump
     Log    Step 3: Chenging the parameter ne3sOperationLogging to True          console=true
     Change parameter on BTS             MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
     ...                                 ne3sOperationLogging
     ...                                 true
     Log    Step 4: Running script      console=true
     FOR    ${i}    IN RANGE    ${COUNT2}
         SSHLibrary.Open Connection    host=${LMP_IP}    prompt=>
         SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
         SSHLibrary.Close Connection
         LOG    Logon to ${LMP_IP} done ${i}    console=${True}
         Sleep    ${INTERVAL}
     END
     Log    Step:4 Stop collecting and download TCPdump      console=true
     ${file_path}=     Stop TCPDump And Download PCAP  tcpdump_filename=log3.pcap
     Log    Step:5 Check a number of audit trail log         console=true
     SSHLibrary.Open Connection    host=${LMP_IP}    prompt=>
     SSHLibrary.Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
     ${file_name}=      SSHLibrary.Execute Command    ls /tmp/ne3sadapt/notifs/atl_queue | head -n 1
     ${logs_number}=    SSHLibrary.Execute Command    grep -o "</operationId>" /tmp/ne3sadapt/notifs/atl_queue/${file_name} | wc -l
     ${size_of_DB}=     SSHLibrary.Execute Command    du -sh /tmp/ne3sadapt/ne3sadapt.db | cut -f1
     SSHLibrary.Close Connection
     Log     Number of logs is ${logs_number}     console=true
     Log     Size od DB is ${size_of_DB}          console=true
     Should Be True    ${logs_number}  > 501
     Sleep    2h           reason=Log will be generated after 2h
     ${atl_log}=           Gather ATL for BTS to Variable    ${NMS_LAB}    MRBTS-${BTS_ID}
     Create File           /home/ute/atl.txt    ${atl_log}
     ${atl_logs_before_reste}=   Run      grep -o 'eventType' /home/ute/atl.txt | wc -l
     Log    Step:6 Reset the BTS and check a number of audit trail log          console=true
     Reset Site And Reconnect
     Wait Until Keyword Succeeds       10m  60s   Wait Until BTS Reach Configured Or OnAir State
     ${atl_log}=           Gather ATL for BTS to Variable    ${NMS_LAB}    MRBTS-${BTS_ID}
     Create File           /home/ute/atl_a.txt    ${atl_log}
     ${atl_logs_after_reset}=    Run      grep -o 'eventType' /home/ute/atl.txt | wc -l
     Should Not Be True    ${atl_logs_after_reset} < ${atl_logs_before_reste}
     [Teardown]    Run Keywords       Deintegrate BTS from MantaRay          ${NMS_LAB}
     ...           AND                Run Keyword And Continue On Failure    SSHLibrary.Close All Connections

