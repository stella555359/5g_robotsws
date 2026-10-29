*** Settings ***

Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000506-A
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/SyVe_Left_Shift/5GC000506-A/5GC000506-A.robot


Resource    ./resources/specific_keywords.robot
Resource    ./resources/tshark.robot
Resource    ./resources/PrePostconditions.robot
Resource    ../CommonKeywords/custom_commissionings.robot

#Force Tags   STATE_CONFIGURED  5G_RAN_TDD  5G_RAN
#...    CA_BTS_OAM_FMRECOV    QCP_BTS_OAM    QCD_MN_BTS_OAM



Suite Setup    Run keywords       506-A Suite Preconditions
...            AND                Resolve errors 5G BTS for Common build
Suite Teardown   506-A Suite Postconditions
Test Setup    506-A Test Preconditions
Test Teardown    506-A Test Postconditions

*** Variables ***
${IPv4address}=       10.0.1.1
${outputPathPcap}=    /home/ute/Remote.pcap
${path_for_syslog}    /var/log/btslog-udp.json

*** Test Cases ***
5GC000506-A_2_Syslog configuration for storing logs to remote server with use IPv4 (UDP protocol)
 #   [Tags]       CIT__WITH__SBTS00
 #   ...          CLOUD_5G_KL_AP_NSA_FS_CMWV
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
    Assert that remote syslog status is enabled
    Assert that syslog server is receiving logs        ${outputPathPcap}
    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
    should be true    ${filtered_output}  did not received proper logs from remote server
    Assert that remote syslog status is enabled


#
5GC000506-A_3_Syslog configuration for storing logs to remote server with use IPv4 (transmission in interval time)
#    [Tags]       CIT__WITH__SBTS00
 #   ...          CLOUD_5G_KL_AP_NSA_FS_CMWV
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
    Assert that remote syslog status is enabled
    Assert that syslog server is receiving logs      ${outputPathPcap}
    ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
    should be true    ${filtered_output}  did not received proper logs from remote server
    wait until keyword succeeds  3 min  10 sec  Assert that remote syslog status is disabled
    Disable remote syslog transmission

