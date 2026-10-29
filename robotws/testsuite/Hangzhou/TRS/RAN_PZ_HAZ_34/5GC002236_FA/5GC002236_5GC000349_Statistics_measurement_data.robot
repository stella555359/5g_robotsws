# #*** Settings ***
# #Documentation
# #...   author: chris.l.cao@nokia-sbell.com
# #...   contact: chris.l.cao@nokia-sbell.com
# #...   PM transport counter cases
# #
# #Suite Setup       PM Suite Setup
# #Suite Teardown    TRANS Common Teardown
# #
# #Resource   resources/trans_comm.robot
# #
# #Force Tags    5G_TRS   5GC002236   HW_TYPE-REAL_UE   PRIORITY-LOW
# #...    PY36
# #
# #Test Timeout    180 minutes
# #
# #*** Variables ***
# #################################### start of LIST_COUNTER_INFO usage guide #############
# ##LIST_COUNTER_INFO Usage:
# ##<distName>;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNL<vm>/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLINSTANCE_<vm>/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##vm: OAM, CCP,CES,UES,CPIF,DU
# ##
# ##e.g,
# ##TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLCCP/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLCES/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLUES/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLCPIF/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLDU/ETHSVC-1/ETHLK-1;<counter_name>,<increasement_number>
# ##TNLSVC-1/TNL-TNLINSTANCE_CPIF/IPNO-1;M51328C0,0
# ##<counter_name>: M51301C6, etc.
# ##increasement_number: increase number for next round check counter, e.g, 0,5,12345, default is 5.
# ##increasement_number>0 means counter value increases with at least <increasement_number>
# ##0 means counter value is zero
# ##-1 means should not verify this counter, but this counter should exist
# ##-2 means this distname+counter_name should not exist
# ##-999 means do not verify anything for this counter
# #################################### end of guide #############
# #
# #@{LIST_COUNTER_INFO_CHK_EXISTENCE}
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C1,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C2,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C3,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C4,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C5,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C6,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C7,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C8,-1
# ##-------- End of M51300  ---------------
# #
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C1,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C2,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C3,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C4,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C5,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C7,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C9,-1
# ##-------- End of M51301  ---------------
# #
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C1,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C2,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C3,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C4,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C5,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C6,-1
# ##-------- End of M51321  ---------------
# #
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C1,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C2,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51325C3,-1
# ##-------- End of M51325  ---------------
# #
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C1,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C2,-1
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C3,-1
# ##-------- End of M51326  ---------------
# #
# ##-------- End of LIST_COUNTER_INFO_CHK_EXISTENCE  ---------------
# #
# #
# ##Ethernet_Interface
# #@{LIST_COUNTER_INFO_M51300}
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C0,100,200
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C1,100,200
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C2,100
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C3,10000
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C4,100
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C5,10000
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C6,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C7,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1;M51300C8,-1
# ##-------- End of M51300  ---------------
# #
# #
# ##Ethernet_Link_Statistics
# #@{LIST_COUNTER_INFO_M51301}
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C0,100
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C1,10000
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C2,100
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C3,10000
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C4,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C5,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C7,50
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHLK-1;M51301C9,50
# ##-------- End of M51301  ---------------
# #
# #
# ##IP_Interface_Statistics
# #@{LIST_COUNTER_INFO_M51321}
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C0,2000
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C1,20
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C2,2000
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C3,20
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C4,100
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C5,50,100
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1/IPIF-1;M51321C6,100,200
# ##-------- End of M51321  ---------------
# #
# #
# ##SCTP_Statistics
# #@{LIST_COUNTER_INFO_M51326}
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C0,3
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C1,300
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C2,3
# #...    TNLSVC-1/TNL-TNLOAM/IPNO-1;M51326C3,300
# ##-------- End of M51326  ---------------
# #
# #
# ##VLAN_Statistics
# #@{LIST_COUNTER_INFO_M51302}
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C0,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C1,50
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C2,500
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C3,50
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C4,500
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C5,-1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C6,-1
# ##-------- End of M51302  ---------------
# #
# #
# #${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}    0
# #${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS_IN_SWITCH}    0
# #${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_BTS_IN_SWITCH}    0
# #${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_SIMU4DU_IN_SWITCH}    0
# #
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000349_02_Check_Supported_Measurements
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CIT
# #    [Setup]      PM Test Setup General   counter_table_name=${LIST_COUNTER_INFO_CHK_EXISTENCE}
# #    [Teardown]   PM Test Teardown General
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=0
# #    Step3: Generate Traffic Waiting  duration=0
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_CHK_EXISTENCE}
# #    StepN: Check BTS Should Be Normal
# #    Confirm Alarm Is Normal
# #
# #
# #[1]5GC002236_5GC000349_03_Ethernet_Link_Statistics_Measurement_Data
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CIT
# #    [Setup]      PM Test Setup General   counter_table_name=${LIST_COUNTER_INFO_M51301}
# #    [Teardown]   PM Test Teardown General
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic For Ethernet Link Statistics Measurement
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51301}
# #    StepN: Check BTS Should Be Normal
# #    Confirm Alarm Is Normal
# #
# #
# #[1]5GC002236_5GC000349_04_Ethernet_Interface_Statistics_Measurement_Data
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CRT
# #    [Setup]      Ethernet Interface Statistics Setup
# #    [Teardown]   Ethernet Interface Statistics Teardown
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic For Ethernet Interface Statistics
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51300}
# #    StepN: Check BTS Should Be Normal
# #
# #
# #[1]5GC002236_5GC000349_05_VLAN_Statistics_Measurement_Data
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CRT
# #    [Setup]      VLAN Statistics Setup
# #    [Teardown]   VLAN Statistics Teardown
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic For VLAN Statistics
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51302}
# #    StepN: Check BTS Should Be Normal
# #
# #
# #[1]5GC002236_5GC000349_06_IP_Interface_Statistics_Measurement_Data
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CRT
# #    [Setup]      PM Test Setup General   counter_table_name=${LIST_COUNTER_INFO_M51321}
# #    [Teardown]   PM Test Teardown General
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic For IP Interface Statistics
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51321}
# #    StepN: Check BTS Should Be Normal
# #
# #
# #[1]5GC002236_5GC000349_08_SCTP_Statistics_Measurement_Data
# #    [Documentation]
# #    ...    history change, <date>,<who>,<what and how>
# #    ...    -26.09.2019,chris.l.cao@nokia-sbell.com,case draft
# #    [Tags]  CRT
# #    [Setup]     PM Test Setup General    counter_table_name=${LIST_COUNTER_INFO_M51326}
# #    [Teardown]  PM Test Teardown General
# #    Step1: Check BTS Should Be Normal
# #    Step2: Sync To PM Timer Clock   estimated_traffic_generating_duration=9
# #    Step3: Generate Traffic Waiting  duration=2
# #    Step4: Get Counters After Traffic And Verify Them   counter_table_name=${LIST_COUNTER_INFO_M51326}
# #    StepN: Check BTS Should Be Normal
# #
# #
# #*** Keywords ***
# #PM Suite Setup
# #    Trans Common Setup
# #    Wait Until Keyword Succeeds  2x  10s   Change PM Collect Interval   interval=15
# #    ${PM_FILE_LOCATION}   Set Variable  ${DU_PM_FILE_LOCATION}
# #    Set Suite Variable  ${PM_FILE_LOCATION}
# #    ${PM_FILE_PATTERN}   Set Variable  ${DU_PM_FILE_PATTERN}
# #    Set Suite Variable  ${PM_FILE_PATTERN}
# #
# #
# #Step3: Generate Traffic Waiting
# #    [Arguments]  ${duration}=2
# #    Log To Console  Step3: Generate Traffic Waiting with duration(wait: ${duration} minutes)
# #    Sleep   ${duration}min
# #
# #
# #Ethernet Interface Statistics Setup
# #    PM Test Setup General   counter_table_name=${LIST_COUNTER_INFO_M51300}
# #    Wait Until Keyword Succeeds  5x   5s   Add VLAN Config In Switch For BTS Port To Access Unknown Vlan For Ethernet Interface Statistics
# #    Wait Until Keyword Succeeds  5x   5s   Set VLAN Untagged For Unknown VLAN For Simu4DU In Switch
# #
# #
# #Ethernet Interface Statistics Teardown
# #    Restore Switch Config
# #    PM Test Teardown General
# #
# #
# #Restore Switch Config
# #    #need restore for DU_interface if it's changed
# #    Run Keyword If   ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_BTS_IN_SWITCH}==1   Wait Until Keyword Succeeds  5x   5s
# #    ...   Delete VLAN Config In Switch For BTS Port to limit access unknow vlan For Ethernet Interface Statistics
# #
# #    #need restore for simu4DU_interface if it's changed
# #    Run Keyword If   ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_SIMU4DU_IN_SWITCH}==1  Wait Until Keyword Succeeds  5x   5s
# #    ...  Set VLAN Untagged For Default VLAN For Simu4DU In Switch
# #
# #
# #Add VLAN Config In Switch For BTS Port To Access Unknown Vlan For Ethernet Interface Statistics
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${tagged_vlan_configured}   Query Switch VLAN Tag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #
# #    Return From Keyword If  '${tagged_vlan_configured}'=='yes'
# #
# #    ${list_vlan_tag}   Create List  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    ${list_vlan_native}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    Add Switch VLAN Tag With Hybrid Mode     interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   list_vlan_tag=${list_vlan_tag}
# #    ...   list_vlan_native=${list_vlan_native}
# #
# #    Set Suite Variable  ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_BTS_IN_SWITCH}  1
# #
# #
# #Delete VLAN Config In Switch For BTS Port To Limit Access Unknow Vlan For Ethernet Interface Statistics
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${tagged_vlan_configured}    Query Switch VLAN Tag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #
# #    Return From Keyword If  '${tagged_vlan_configured}'=='no'
# #
# #    ${list_vlan_tag}   Create List  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    ${list_vlan_native}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    Delete Switch VLAN Tag With Hybrid Mode     interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   list_vlan_tag=${list_vlan_tag}
# #    ...   list_vlan_native=${list_vlan_native}
# #
# #    Set Suite Variable  ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_BTS_IN_SWITCH}  0
# #
# #
# #Set VLAN Untagged For Unknown VLAN For Simu4DU In Switch
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${untagged_vlan_configured}    Query Switch VLAN Untag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["simu4DU_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #
# #    Return From Keyword If  '${untagged_vlan_configured}'=='yes'
# #
# #    #config to untagged for unknow vlan
# #    ${list_vlan_untagged}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    ${list_vlan_old}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    Add Switch VLAN Untagged     interface=${TRANS_PARA["du_switch"]["switch1"]["simu4DU_interface"]}
# #    ...   list_vlan_untagged=${list_vlan_untagged}   list_vlan_old=${list_vlan_old}
# #
# #    Set Suite Variable  ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_SIMU4DU_IN_SWITCH}   1
# #
# #
# #Set VLAN Untagged For Default VLAN For Simu4DU In Switch
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${untagged_vlan_configured}    Query Switch VLAN Untag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["simu4DU_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #
# #    Return From Keyword If  '${untagged_vlan_configured}'=='yes'
# #
# #    #config to untagged for default vlan
# #    ${list_vlan_untagged}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    ${list_vlan_old}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    Add Switch VLAN Untagged     interface=${TRANS_PARA["du_switch"]["switch1"]["simu4DU_interface"]}
# #    ...   list_vlan_untagged=${list_vlan_untagged}   list_vlan_old=${list_vlan_old}
# #
# #    Set Suite Variable  ${CONFIG_SUCCESS_FLAG_ETHERNET_INTERFACE_VLAN_CONFIG_SIMU4DU_IN_SWITCH}   0
# #
# #
# #Step3: Generate Traffic For Ethernet Interface Statistics
# #    [Teardown]  Run Keyword And Ignore Error  ssh.Disconnect
# #    Log To Console  Step3: Generate Traffic For Ethernet Interface Statistics
# #
# #    #for M51300C0
# #    ${dest_mac}  Get Mac Of OAM   ${DU_OAM_INTERFACE}
# #
# #    ${tool}   Get Full Command Path For Simulator  command=${TOOLS_INFO["send_ether_frame"]}
# #    ${cmd}   Set Variable  ${tool} -i ${SIMULATOR4DU_IF} -T ${dest_mac} -t 0 -c 101 -r 3
# #    TAF Connect To Simulator4DU
# #    ssh.Send Command   command=${cmd}
# #    ${out}  ssh.Read Output
# #
# #    #for M51300C1
# #    Restore Switch Config
# #    #it seems it will lose several frames, so use 103 instead of 101
# #    ${cmd}   Set Variable  ${tool} -i ${SIMULATOR4DU_IF} -T ${dest_mac} -t 1 -c 103 -r 3
# #    ssh.Send Command   command=${cmd}
# #    ${out}  ssh.Read Output
# #
# #    Sleep   60
# #
# #
# #Step3: Generate Traffic For Ethernet Link Statistics Measurement
# #    [Teardown]  Run Keyword And Ignore Error  ssh.Disconnect
# #    Log To Console  Step3: Generate Traffic For Ethernet Link Statistics Measurement
# #    #for M51301C0~6
# #    Sleep   90
# #
# #    #for M51301C7
# #    ${cmd}   Get Full Command Path For Simulator  command=${TOOLS_INFO["cmd_arp_test_m"]}
# #    ${cmd}   Set Variable  ${cmd} -i ${SIMULATOR4DU_IF} -T ${DU_OAM_IP} -c 51
# #    TAF Connect To Simulator4DU
# #    ssh.Send Command   command=${cmd}
# #    ${out}  ssh.Read Output
# #    ssh.Disconnect
# #
# #    #for M51301C9
# #    ${cmd}   Get Full Command Path For Simulator  command=${TOOLS_INFO["cmd_arp_test_m"]}
# #    ${simulator4DU}    Set Variable  ${TRANS_PARA["simulator4DU"]}
# #    ${cmd}   Set Variable  ${cmd} -i ${DU_OAM_INTERFACE} -T ${simulator4DU["service_ip"]} -c 51
# #    TAF Connect To DU OAM
# #    ssh.Send Command   command=${cmd}
# #    ${out}  ssh.Read Output
# #
# #
# #VLAN Statistics Teardown
# #    Run Keyword If   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}==1   Run Keyword And Ignore Error  Delete VLAN Config In WebEM
# #    Run Keyword If   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS_IN_SWITCH}==1  Run Keyword And Ignore Error   Delete VLAN Config In Switch
# #    PM Test Teardown General
# #    Set Suite Variable   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}  0
# #    Set Suite Variable   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS_IN_SWITCH}  0
# #
# #
# #VLAN Statistics Setup
# #    [Teardown]  Run Keyword And Ignore Error   Rest Logout DU
# #    PM Test Setup General   counter_table_name=${LIST_COUNTER_INFO_M51302}
# #    Rest Login DU
# #    Delete VLAN Config In WebEM
# #    Add Vlan Config In WebEM
# #    Add VLAN Config In Switch For VLAN Statistics
# #
# #
# #Add Vlan Config In WebEM
# #    #VLANIF
# #    ${para1}      Create Dictionary   parameterName=vlanId
# #    ...           value=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}   operation=update
# #    ${para_list}  Create List         ${para1}
# #    ${dist_name}    Set Variable  MRBTS-${DU_BTS_ID}/TNLSVC-1/TNL-${DU_TNL_OAM}/ETHSVC-1/ETHIF-1/VLANIF-1
# #    ${mo_dict}      coam.Perform_Object_Recommissioning    dist_name=${dist_name}
# #    ...                                         parameter=${para_list}
# #    ...                                         operation=create
# #    ...                                         skip_parameter_relation_errors=${BOOLEAN_TRUE}
# #    ...                                         should_activate=${BOOLEAN_TRUE}
# #
# #
# #    #IPIF
# #    ${para1}        Create Dictionary   parameterName=interfaceDN   value=${dist_name}    operation=update
# #    ${para2}        Create Dictionary   parameterName=ipMtu
# #      ...   value=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_mtu"]}
# #      ...   operation=update
# #
# #    ${para_list}      Create List         ${para1}   ${para2}
# #    ${dist_name}    Set Variable  MRBTS-${DU_BTS_ID}/TNLSVC-1/TNL-${DU_TNL_OAM}/IPNO-1/IPIF-2
# #    ${mo_dict}      coam.Perform_Object_Recommissioning    dist_name=${dist_name}
# #    ...                                         parameter=${para_list}
# #    ...                                         operation=create
# #    ...                                         skip_parameter_relation_errors=${BOOLEAN_TRUE}
# #    ...                                         should_activate=${BOOLEAN_TRUE}
# #
# #
# #    #IPADDRESSV4
# #    ${para1}    Create Dictionary   parameterName=ipAddressAllocationMethod   value=MANUAL   operation=update
# #    ${para2}    Create Dictionary   parameterName=localIpAddr
# #      ...      value=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_ip"]}
# #      ...      operation=update
# #    ${para3}   Create Dictionary   parameterName=localIpPrefixLength
# #      ...      value=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_masklen"]}
# #      ...      operation=update
# #    ${para_list}    Create List   ${para1}   ${para2}   ${para3}
# #    ${dist_name}    Set Variable  MRBTS-${DU_BTS_ID}/TNLSVC-1/TNL-${DU_TNL_OAM}/IPNO-1/IPIF-2/IPADDRESSV4-1
# #    ${mo_dict}      coam.Perform_Object_Recommissioning    dist_name=${dist_name}
# #    ...                                         parameter=${para_list}
# #    ...                                         operation=create
# #    ...                                         skip_parameter_relation_errors=${BOOLEAN_TRUE}
# #    ...                                         should_activate=${BOOLEAN_TRUE}
# #
# #    ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}  Set Variable  1
# #    Set Suite Variable   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}
# #
# #
# #Delete Vlan Config In WebEM
# #    Run Keyword And Ignore Error  Delete MO IPIF
# #    Run Keyword And Ignore Error  Delete MO VLANIF
# #    ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}  Set Variable  0
# #    Set Suite Variable   ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS}
# #
# #
# #Add VLAN Config In Switch For VLAN Statistics
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${tagged_vlan_configured}    Query Switch VLAN Tag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #
# #    Return From Keyword If  '${tagged_vlan_configured}'=='yes'
# #
# #    ${list_vlan_tag}   Create List  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    ${list_vlan_native}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    Add Switch VLAN Tag With Hybrid Mode     interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   list_vlan_tag=${list_vlan_tag}
# #    ...   list_vlan_native=${list_vlan_native}
# #
# #    Set Suite Variable  ${CONFIG_SUCCESS_FLAG_VLAN_STATISTICS_IN_SWITCH}  1
# #
# #
# #Delete VLAN Config In Switch
# #    [Teardown]  Run Keyword And Ignore Error  Switch Close Connection
# #    Connect To DU Switch
# #    ${tagged_vlan_configured}    Query Switch VLAN Tag Setting   interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   vlanID=${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #
# #    Return From Keyword If  '${tagged_vlan_configured}'=='no'
# #
# #    ${list_vlan_tag}   Create List  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_id"]}
# #    ${list_vlan_native}   Create List   ${TRANS_PARA["du_switch"]["switch1"]["du_vlan_id"]}
# #    Delete Switch VLAN Tag With Hybrid Mode     interface=${TRANS_PARA["du_switch"]["switch1"]["switch_interface"]}
# #    ...   list_vlan_tag=${list_vlan_tag}
# #    ...   list_vlan_native=${list_vlan_native}
# #
# #
# #
# #Step3: Generate Traffic For VLAN Statistics
# #    [Teardown]  TAF Disconnect From DU OAM
# #    Log To Console    Step3: Generate Traffic For VLAN Statistics
# #    #ping from UTE to vlan ip
# #    ${dest}   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_ip"]}
# #    ${cmd}  Set Variable  ping ${dest} -c 50 -i 0.4
# #    ${out}   Run Process   ${cmd}  shell=True
# #
# #    #ping from vlan ip to vlan gateway
# #    ${dest}   Set Variable  ${TRANS_PARA["du_switch"]["switch1"]["du_2nd_vlan_gateway"]}
# #    ${cmd}  Set Variable  ping ${dest} -c 50 -i 0.4
# #    TAF Connect To DU OAM
# #    ${out}   ssh.Execute   command=${cmd}
# #
# #
# #Step3: Generate Traffic For IP Interface Statistics
# #    [Teardown]   Run Keyword And Ignore Error  ssh.Disconnect
# #    Log To Console  Step3: Generate Traffic for IP Interface Statistics
# #    #general tcp packets
# #    FOR  ${i}   IN RANGE  1   6
# #       TAF Connect To DU OAM
# #       TAF Disconnect From DU OAM
# #       Sleep   1
# #    END
# #
# #    #generate M51321C5,C6
# #    TAF Connect To DU OAM
# #    ${dest}   Set Variable  ${TRANS_PARA["simulator4DU"]["service_ip"]}
# #    ${cmd}  Set Variable  ping ${dest} -c 51 -i 0.4 -s 2000
# #    ${out}   ssh.Execute   command=${cmd}
# #    TAF Disconnect From DU OAM
# #
# #    #error incoming IP M51321C4
# #    TAF Connect To Simulator4DU
# #    ${cmd}   Get Full Command Path For Simulator  command=${TOOLS_INFO["icmp_test"]}
# #    ${cmd}   Set Variable  ${cmd} -i ${SIMULATOR4DU_IF} -T ${DU_OAM_IP} --invalid_chksum 1 -c 101
# #    ssh.Send Command   command=${cmd}
# #    ${out}  ssh.Read Output
# #    ssh.Disconnect
