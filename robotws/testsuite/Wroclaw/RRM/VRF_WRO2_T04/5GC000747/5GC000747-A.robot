*** Settings ***
Documentation
...  author: Tomasz Godlewski
...  contact: tomasz.1.godlewski.ext@nokia.com
...  ETWS subfeature A

Resource    ../../resources/logs.robot

Library    ../../resources/etws_cmas/counters.py
Library    ../../resources/etws_cmas/ngap_checkers.py
Library    ../../resources/etws_cmas/sib_gnb.py

Library    ./resources/EtwsBroadcaster.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Resource    ./resources/keywords_747.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/keywords_8225.robot

*** Keywords ***
5GC000747-A_004_Successful_ETWS_primary_and_secondary_notification_broadcast
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    Activate ETWS
    counters.Wait For Pm Counters Interval
    Tcpdump.Start Tcpdump On Smod    filename=f1_a004_primary
    Start L1L2 Collection   l1l2_a004_primary.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    Attach Ue To Selected Cell   ue=${FIRST_UE}
    ${sn_primary}=    Start ETWS Primary Notification    cells=${UE_1_CELL}
    Wait For Broadcast    10
    ${l1l2_primary}=    Stop L1L2 Collection
    ${pcap_file_primary}=    Tcpdump.Stop Tcpdump and download logs from SMOD

    Tcpdump.Start Tcpdump On Smod    filename=f1_a004_secondary
    Start L1L2 Collection   l1l2_a004_secondary.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    ${sn_secondary}=    Start ETWS Secondary Notification    cells=${UE_1_CELL}
    Wait For Broadcast    10
    ${l1l2_secondary}=    Stop L1L2 Collection
    ${pcap_file_secondary}=    Tcpdump.Stop Tcpdump and download logs from SMOD

    Gnb Responded To Write Replace Warning Request    ${pcap_file_primary}    cell_id=${UE_1_CELL}   serial_number=${sn_primary}
    ...    etws_type=primary
    Gnb Responded To Write Replace Warning Request    ${pcap_file_secondary}    cell_id=${UE_1_CELL}   serial_number=${sn_secondary}
    ...    etws_type=secondary
    WRWR_REQ_RECD Counter Incremented Successfully    expected_value=2
    WRWR_RESP_SENT Counter Incremented Successfully    expected_value=2    wait_for_interval=${FALSE}

    SIB6 Is Broadcasted    ${l1l2_primary}
    SIB7 Is Broadcasted    ${l1l2_secondary}
    SIB6 Is Not Broadcasted    ${l1l2_secondary}
    SIB7 Is Not Broadcasted    ${l1l2_primary}

    UE_1.Is Alert Visible On The Screen    Earthquake  # primary
    UE_1.Is Alert Visible On The Screen    Earthquake  # secondary
    [Teardown]    Run Keywords
    ...    ute_ue.Detach Ue    ${FIRST_UE}    AND
    ...    Deactivate ETWS    AND
    ...    Teardown Tcpdump On Smod    AND
    ...    Run Keyword And Ignore Error    UE_1.Clear All Alerts

5GC000747-A_009_Successful_ETWS_secondary_notification_broadcast_replace
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    Activate ETWS
    Tcpdump.Start Tcpdump On Smod
    Start L1L2 Collection   l1l2_a009.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    Attach Ue To Selected Cell   ue=${FIRST_UE}
    Start ETWS Secondary Notification Twice    cells=${UE_1_CELL}
    Wait For Broadcast    30
    ${l1l2}=     Stop L1L2 Collection
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Gnb Responded To Write Replace Warning Request    ${pcap_file}    msg_id=4352    cell_id=${UE_1_CELL}
    Gnb Responded To Write Replace Warning Request    ${pcap_file}    msg_id=4353    cell_id=${UE_1_CELL}
    SIB7 Is Broadcasted    ${l1l2}    msg_id=4352
    SIB7 Is Broadcasted    ${l1l2}    msg_id=4353
    Run Keyword And Ignore Error    UE_1.Is Alert Visible On The Screen    Earthquake
    UE_1.Is Alert Visible On The Screen    Tsunami
    [Teardown]    Run Keywords
    ...    ute_ue.Detach Ue    ${FIRST_UE}    AND
    ...    Deactivate ETWS    AND
    ...    Teardown Tcpdump On Smod    AND
    ...    Run Keyword And Ignore Error    UE_1.Clear All Alerts

5GC000747-A_010_Successful_ETWS_primary_notification_broadcast_in_RRC_IDLE_state
    Enable Inactive State Feature On Ue    ${FIRST_UE}
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    Activate ETWS
    Set Max Time For Ue RRC Inactive State    value=1
    Tcpdump.Start Tcpdump On Smod    filename=pcap_inactive
    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=inactive_idle.pcap
    Attach Ue To Selected Cell   ue=${FIRST_UE}
    BuiltIn.Sleep    25
    Start L1L2 Collection   l1l2_a010_inact.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    Start ETWS Primary Notification    cells=${UE_1_CELL}
    BuiltIn.Sleep  2
    ${l1l2_inact}=    Stop L1L2 Collection

    BuiltIn.Sleep    ${TIMER_IDLE}
    Start L1L2 Collection   l1l2_a010_idle.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    Start ETWS Primary Notification    cells=${UE_1_CELL}
    BuiltIn.Sleep  2
    ${l1l2_idle}=    Stop L1L2 Collection
    Stop Listening Tcpdump From Smod

    Gnb Responded To Write Replace Warning Request    ${pcap_file}    cell_id=${UE_1_CELL}
    Gnb Responded To Write Replace Warning Request    ${pcap_file}    cell_id=${UE_1_CELL}
    ngap_checkers.Ue Released    ${pcap_file}    f1ap    cause=normal-release
    ngap_checkers.Ue Released    ${pcap_file}     ngap    cause=user-inactivity
    SIB6 Is Broadcasted    ${l1l2_inact}
    SIB6 Is Broadcasted    ${l1l2_idle}
    UE_1.Is Alert Visible On The Screen    Earthquake
    UE_1.Is Alert Visible On The Screen    Earthquake
    [Teardown]    Run Keywords
    ...    ute_ue.Detach Ue    ${FIRST_UE}    AND
    ...    Deactivate ETWS    AND
    ...    Teardown Tcpdump On Smod    AND
    ...    Set Max Time For Ue RRC Inactive State    AND
    ...    Run Keyword And Ignore Error    UE_1.Clear All Alerts


5GC000747-A_023_Successful_SIB_reconfiguration_during_ETWS_notification_broadcast
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    Activate ETWS
    Tcpdump.Start Tcpdump On Smod
    Start L1L2 Collection   l1l2_a023.pcap  ${L1L2_CAPTURE_TIME}   cell_ids=${UE_1_CELL}
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${PDSCH_MESSAGES_FILTER}
    ...   wait=${FALSE}
    Attach Ue To Selected Cell   ue=${FIRST_UE}
    ${sn_primary}    ${sn_secondary}    Start Primary And Secondary Notification    cells=${UE_1_CELL}
    Wait For Broadcast    30
    ${l1l2}=    Stop L1L2 Collection
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Gnb Responded To Write Replace Warning Request    ${pcap_file}    msg_id=4352    cell_id=${UE_1_CELL}
    ...    etws_type=primary    serial_number=${sn_primary}
    Gnb Responded To Write Replace Warning Request    ${pcap_file}    msg_id=4352    cell_id=${UE_1_CELL}
    ...    etws_type=secondary    serial_number=${sn_secondary}
    Run Keyword And Continue On Failure    SIB6 Is Broadcasted    ${l1l2}    msg_id=4352
    Run Keyword And Continue On Failure    SIB7 Is Broadcasted    ${l1l2}    msg_id=4352
    UE_1.Is Alert Visible On The Screen    Earthquake
    UE_1.Is Alert Visible On The Screen    Earthquake
    [Teardown]    Run Keywords
    ...    ute_ue.Detach Ue    ${FIRST_UE}    AND
    ...    Deactivate ETWS    AND
    ...    Teardown Tcpdump On Smod    AND
    ...    Run Keyword And Ignore Error    UE_1.Clear All Alerts
