*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000506-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d /opt/ute/logs/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB007308-5G_5GC000506/5GC000506-A/5GC000506-A.robot

Resource    ./resources/specific_keywords.robot
Resource    ./resources/tshark.robot
Resource    ./resources/PrePostconditions.robot
Resource    ../CommonKeywords/custom_commissionings.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV  #QCP_BTS_OAM    QCD_MN_BTS_OAM   #SBTS21B   #21A_classicalbts  SBTS22R1


Suite Setup    506-A Suite Preconditions
Suite Teardown   506-A Suite Postconditions
Test Setup    506-A Test Preconditions
Test Teardown    506-A Test Postconditions

*** Variables ***
${IPv4address}=       10.0.1.1
${outputPathPcap}=    /home/ute/Remote.pcap
${path_for_syslog}    /var/log/btslog-udp.json

*** Test Cases ***
5GC000506-A_2_Syslog configuration for storing logs to remote server with use IPv4 (UDP protocol)
    [Tags]       CIT   CIT__WITH__SBTS00   SBTS22R1  SBTS22R2  SBTS00  SBTS22R3  SBTS22R4  SBTS23R1
    [Documentation]
    ...    Checks if IPv4 address for remote server is set and syslog transmission is enabled in unsecure mode (UDP)
    log to console   UDP RFC remote syslog on
    Perform remoteSyslogIPaddress parameter activation
    ...        DSCPvalue=16
    ...        format=RFC5424
    ...        IP_remoteServer=${IPv4address}
    ...        portNumber=514
    ...        time=180
    ...        protocol=UDP
    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Assert that IP address for remote server is set    ${IPv4address}
    Enable remote syslog transmission                    MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Assert that syslog server is receiving logs        ${outputPathPcap}
    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
    run keyword and continue on failure   should be true    ${filtered_output}  did not received proper logs from remote server
    BTS Syslog shall be redirected to remote server


5GC000506-A_3_Syslog configuration for storing logs to remote server with use IPv4 (transmission in interval time)
    [Tags]       CIT   CIT__WITH__SBTS00   SBTS22R1  SBTS22R2  SBTS00  SBTS22R3  SBTS22R4  SBTS23R1
    [Documentation]
    ...    Checks ability to enable transmission with new configuration of Syslog and to measure time of collecting logs
    ...    on remote server with the use of IPv4

    Disable remote syslog transmission
    Perform remoteSyslogIPaddress parameter activation
    ...        DSCPvalue=16
    ...        format=RFC5424
    ...        IP_remoteServer=${IPv4address}
    ...        portNumber=514
    ...        time=1
    ...        protocol=UDP
    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Assert that IP address for remote server is set       ${IPv4address}
    Enable remote syslog transmission                     MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    Assert that syslog server is receiving logs      ${outputPathPcap}
    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
    run keyword and continue on failure   should be true    ${filtered_output}  did not received proper logs from remote server
    BTS Syslog shall be redirected to remote server
    Disable remote syslog transmission


#5GC000506-A_14_Syslog stop_start recording due to outage occur
#    [Tags]       CRT  #Regression Optimisation -part 2- July 2022
#    [Documentation]
#    ...    Checks ability to verify Syslog mechanism during stopped-started transmission
#    ...    and to check if logs are being send chronological after that.
#
#    Disable remote syslog transmission
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=16
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=180
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set       ${IPv4address}
#    Enable remote syslog transmission                     MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
##    Assert that remote syslog status is enabled
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
#    ${before_reset}  get file size   ${path_for_syslog}
#    log to console  Reset BTS
#    Reset COAM BTS
#    wait for configured  20min
##   Assert that remote syslog status is enabled
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
#    Disable remote syslog transmission
#    ${after_reset}  get file size   ${path_for_syslog}
#    log to console  before ${before_reset}
#    log to console  after ${after_reset}
#    should be true      ${after_reset}>${before_reset}


#5GC000506-A_16_Syslog stream sending time expires
#    [Tags]       CRT  #Regression Optimisation -part 2- July 2022
#    [Documentation]
#    ...    Checks ability to verify Syslog mechanism during sending time expire
#
#    Disable remote syslog transmission
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=16
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=1
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set       ${IPv4address}
#    Enable remote syslog transmission                     MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
##   Assert that remote syslog status is enabled
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
#    Sleep    2 min
#    Reset COAM BTS
#    wait for configured
##   Assert that remote syslog status is disabled


#5GC000506-A_17_Syslog transmission from cOAM BTS to Remote Syslog Server on request via Web EM with modified parameters and transmission turn off
#    [Tags]       CRT  #Regression Optimisation -part 2- July 2022
#    [Documentation]
#    ...    Checks ability to verify bility of the operator to request remote syslog transmission to start, stop
#    ...    or update transmission via Web EM
#
#    Disable remote syslog transmission
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=16
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=180
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set    ${IPv4address}
#    Enable remote syslog transmission                    MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
##   Assert that remote syslog status is enabled
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
##   Assert that remote syslog status is enabled
#    Disable remote syslog transmission
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=16
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=1
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set    ${IPv4address}
#    Enable remote syslog transmission                    MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
##   wait until keyword succeeds  3 min  10 sec  Assert that remote syslog status is disabled


#5GC000506-A_18_Remote syslog bandwith using UDP protocol
#    [Tags]       CRT  #Regression Optimisation -part 2- July 2022
#    [Documentation]
#    ...    Checks if BTS transmits syslog to the remoteserver in UDP configuration using a QoS setting
#    ...    independent from the one assigned to the M-Plane services
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=16
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=180
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set    ${IPv4address}
#    Enable remote syslog transmission                    MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
##   Assert that remote syslog status is enabled
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter
#        ...    ip.addr == ${OUT_SCF_MRBTS_IP} && ip.dsfield.dscp == 16    ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
#    Disable remote syslog transmission
##   Wait until keyword succeeds  2 min  10 sec  Assert that remote syslog status is disabled
#    Perform remoteSyslogIPaddress parameter activation
#    ...        DSCPvalue=0
#    ...        format=RFC5424
#    ...        IP_remoteServer=${IPv4address}
#    ...        portNumber=514
#    ...        time=180
#    ...        protocol=UDP
#    ...        Object_WebEm_dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that IP address for remote server is set    ${IPv4address}
#    Enable remote syslog transmission                    MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
#    Assert that syslog server is receiving logs         ${outputPathPcap}
#    ${filtered_output}    check if pcap contains logs with filter
#        ...    ip.addr == ${OUT_SCF_MRBTS_IP} && ip.dsfield.dscp == 0   ${outputPathPcap}
#    should be true    ${filtered_output}  did not received proper logs from remote server
##   Assert that remote syslog status is enabled
#    Disable remote syslog transmission
