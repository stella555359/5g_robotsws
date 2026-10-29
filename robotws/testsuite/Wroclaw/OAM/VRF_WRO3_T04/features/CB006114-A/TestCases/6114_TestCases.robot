*** Settings ***
Documentation    The KW for CB006114 feature
Resource         ../Resources/6114_Keywords.robot
Resource         ../../../common_resources/ip_traffic/ip_traffic.robot
Resource         ../../../common_resources/alarms/alarm.robot
Resource         ../../../common_resources/admin/admin.robot

*** Keywords ***
CB006114-A_IPSec_connection_establishment_between_RU_as_Initiator_and_DU_as_Responder
    Start Tcpdump On FHNET via SSH
    Change Flag For IPSEC Feature via Netact through RuProtect    value=0
    Wait Untill RU Will Automatically Reboot
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}
    Wait Until Keyword Succeeds    7min    30sec    Check If All Cells Are OnAir
    [Teardown]      Run Keywords
    ...             Run Keyword And Ignore Error   Stop Tcpdump on FHNET And Download Pcap Via SSH    AND
    ...             Change Flag For IPSEC Feature via Netact through RuProtect    value=1   AND
    ...             Wait Untill RU Will Automatically Reboot    AND
    ...             Wait Until Keyword Succeeds    5min    30sec    Check If All Cells Are OnAir    AND
    ...             ESP Packets Should Not Be Present On BTS

CB006114-A_IPSec_defect_handling_between_the_DU_and_RU
    Turn Off TLS
    Add Multiple Alarms to Watchdog List   10
    Change Flag For IPSEC Feature via Netact Through RuProtect    value=0
    Wait Untill RU Will Automatically Reboot
    ${pcap_file}=    Stop Tcpdump on FHNET And Download Pcap Via SSH
    ISAKMP Packets Should Be Present On BTS    ${pcap_file}
    Wait Until Keyword Succeeds    7min    30sec    Check If All Cells Are OnAir
    ESP Packets Should Be Present On BTS
    Create nft Rule To Break Link To RU
    ${expected_fault}=    Create List    10
    Wait Until Keyword Succeeds    10min    30sec    Check If Expected Faults Except Allowed Are Present On BTS
    ...                                             expected_faults_list=${expected_fault}
    Delete nft Rule to Unbreak Link to RU
    Wait until keyword succeeds    30min    30sec    No Faults Except Allowed Should Be Present On BTS
    Wait Until Keyword Succeeds    13min    1min
    ...                            6114_Keywords.Check If RU operationalState has expected value   excpected_value=[Ee]nabled
    ESP Packets Should Be Present On BTS
    Wait Until Keyword Succeeds    5min    30sec    Check If All Cells Are OnAir
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error   Stop Tcpdump on FHNET And Download Pcap Via SSH    AND
    ...           Run Keyword And Ignore Error   Delete nft Rule to Unbreak Link to RU    AND
    ...           Change Flag For IPSEC Feature via Netact through RuProtect    value=1    AND
    ...           Wait Untill RU Will Automatically Reboot    AND
    ...           Wait Until Keyword Succeeds    7min    30sec    Check If All Cells Are OnAir   AND
    ...           ESP Packets Should Not Be Present On BTS   AND
    ...           Remove Multiple Alarms from Watchdog List   10

CB006114-A_RU_IPSec_incapability_handling_by_DU
    Change Flag For IPSEC Feature via Netact through RuProtect    value=0
    ${expected_faults}=                         Set Variable    4667
    &{allowed_faults}=                          Copy Dictionary    ${ALLOWED_FAULTS_COMMON}
    Set To Dictionary    ${allowed_faults}      61618=BTS and/or peer trust anchor expired or due to expire
    ...                                         61011=End Entity Certificate Update Time Mismatch
    ...                                         10=No Connection To unit
    Wait Until Alarm Appears On BTS             4667  1200
    Sleep  5 minutes                            reason=CHECK IF FAULT DISAPPEAR
    Wait Until Alarm Appears On BTS             4667  1200
    Change Flag For IPSEC Feature via Netact through RuProtect    value=1
    Wait until keyword succeeds    10min    1min    No Faults Except Allowed Should Be Present On BTS
    ...                                             allowed_faults=${allowed_faults}
    Wait Until Keyword Succeeds    5min    30sec    Check If All Cells Are OnAir
    [Teardown]    Run Keywords
    ...           Change Flag For IPSEC Feature via Netact through RuProtect    value=1    AND
    ...           Wait Until Keyword Succeeds    10min    30sec    Check If All Cells Are OnAir

CB006114-A_Disable_plain_text_connection_for_a_RU
    #   PRECONDITION: actEcpriRuMPlaneSecurity - RuProtectOptional
    #                 plainTextConnectionAllowed - true
    &{allowed_faults}=    Copy Dictionary      ${ALLOWED_FAULTS_COMMON}
    Set To Dictionary     ${allowed_faults}    61618=BTS and/or peer trust anchor expired or due to expire
    ...                                        61011=End Entity Certificate Update Time Mismatch
    Set IPSEC Feature For RuProtectOptional PlainText True
    Check If All Cells Are Degraded            timeout=240s
    ${expected_fault}=             Create List      4667
    Wait Until Keyword Succeeds    5min    30sec    Check If Expected Faults Except Allowed Are Present On BTS
    ...                                             expected_faults_list=${expected_fault}
    ...                                             allowed_faults=${allowed_faults}
    Run Keyword And Continue On Failure  Set IPSEC Feature For RuProtectOptional PlainText False
    Run Keyword And Continue On Failure  UDP Packets From RU Should Not Be Present On BTS
    Check If RU operationalState has expected value       excpected_value=[Dd]isabled
    ${expected_faults}=            Create List      10    4667
    Wait Until Keyword Succeeds    10min    20sec   Check If Expected Faults Except Allowed Are Present On BTS
    ...                                             expected_faults_list=${expected_faults}
    ...                                             allowed_faults=${allowed_faults}
    [Teardown]    Run Keywords
    ...           Change Flag For IPSEC Feature via Netact through RuProtect    value=1    AND
    ...           Wait Until Keyword Succeeds    10min    30sec   Check If All Cells Are OnAir
