*** Settings ***
Force Tags    CLOUD_5G_I_MP_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature  : Verify UE-Associated Large Syscom messages when UE attempts rrc_reestablishment


Resource          resources/Keywords/CNI101964_keywords.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${AP_CONFIG_BASIC}     ${CURDIR}/config/wts
${UE_ID}               1
${DL_RATE}             150
${UL_RATE}             150
${TIMEOUT}             5 min
${RETRY_TIME}          30s
${UE_RRC_REESTABLISH_COMPLETE_PATTERN}      .*rrcReconfigurationComplete.*
${RRC_REESTABLISH_COMPLETE_PATTERN}     rrcReconfigurationComplete


*** Test Cases ***
[1][1.0] CNI-101964 03 Verify UE-Associated Large Syscom messages when UE attempts rrc_reestablishment
    [Documentation]    Verify UE-Associated Large Syscom messages when UE attempts rrc_reestablishment
    [Setup]    Prepare For CNI101964
    Log to Console      TestCase prepared..
    Start pcap collection in gNB CU       gnbTcpdump
    Getting UE Param And Register UE       UE_ID=${UE_ID}
    Traffic Should Be Successful For SA    traffic_dl_rate=${DL_RATE}
    ...        traffic_ul_rate=${UL_RATE}          UE_ID=${UE_ID}
    Sleep   10s
    Re-establish rrc setup UE
    ${pcap_file}    Stop Pcap Collection In GNB CU      gnbTcpdump      ${Log_Path}
    Verify RRC Segment Allowed        ${pcap_file}
    Verify Fragment Count     ${pcap_file}
    Wait Until Keyword Succeeds        ${TIMEOUT}       ${RETRY_TIME}
    ...     Verifying The PM Counter For CNI10964
    UE Deregister Should Be Successful For SA       ${UE_ID}
