*** Settings ***
Documentation
...   Author: shuangfeng.f.sun@nokia-sbell.com
...   Contact: shuangfeng.f.sun@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM

#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes
Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../../T02/Common_Case/common_resource_new.robot
Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Library             taf.sw.scout                                           WITH NAME    scout
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\python\tak_airphone\tak_airphone\interface.py
#C:\robotws\testsuite\Hangzhou\RRM\RAN_PZ_HAZ_1\Resources\Common\Airphone.robot
#Library          ../../Resources/Common/python/airphone.py
# CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# tdd_sansa_cmwv_2cells_ecpri
*** Variables ***
${config_tag}  CB012209_TMO
${config_tag_ANR}  CB012209_TMO_ANR
${config_tag_07}  CB012209_TMO_07
@{pass_regexp_ANR}
#...    Adding QosFlow with QFI:2 5QI:1
#...    PDU Session Resource Modify Unsuccessful Transfer
...    Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed

@{pass_regexp_HO_CELL2_SIMCELL1}
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.* performed

${counter1}    M55125C00035

@{Setup_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    QoS Routing Table
...    Unexpected XnAP: SNStatusTransfer in WAIT HANDOVER REQUEST

@{Add_5QI1_Success}
...    Added QosFlow with QFI:2 fiveQI:1
...    rrcReconfigurationComplete
...    QoS Routing Table

@{HO_Success}
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK

@{Add_5QI1_failed_and_HO_Success}
...    Adding QosFlow with QFI:* 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    PDU SESSION RESOURCE MODIFY RESPONSE Modify Item with cause 33
...    Deleted Unsuccessful QosFlow QFI:2
...    @{HO_Success}

${UE_Capabilities_with_ANR_NoVoNR}    E1A03E0047E02400603F81C06000703D77BFFFD78428007801040000002E0203C127BE7FFFFF8013
...    006379F000281B81807E380B517C18F789C21D881043F28340105B2A3A01893EB1079083C205096F9F809FF87E0007FE1F80005E0000E000
...    A0545F0A3DE27087620410FCA0D00416CA8E80624FAC41E420F081425BE7E017771DF001DDC77C0017A80038002800D94000140000008001
...    00001517C2FF789C21D881043F28340105B2A3A01893EB1079083C205096F9F809FCF73C007F3DCF0005E0000E000A0545F107DE27087620
...    410FCA0D00416CA8E80624FAC41E420F081425BE7E027FE1F8001FF87E0001780003800281517C46F789C21D881043F28340105B2A3A01893
...    EB1079083C205096F9F80840010005E0000E000A0545F133DE27087620410FCA0D00416CA8E80624FAC41E420F081425BE7E01100040017A
...    80038002800D940001400000080010000018A0F06000308C00003D13AA0E0600E230000013D13AA0F0A000308C00023D13AA0E0A00E230000
...    033D13AA0F0A000388C000010F44EA83C46000C2300014F44EA81C2808000C6227541E0C00060A0000E7A27541C0C01C280000107A27541E0
...    C00070A0000049E89D50785000182800051889F50783000181800059E89D005011A0144018176208906429D3B649F0214E9DB24F810A34ED9
...    27C0853A76C93E042853B649F0214E9DB24F810236C93E0429D3B649F0214E8DB24F810A740D927C0851A76C93E0429D3B649F00130C18C63
...    18C6318C6301F0302412190482412190486412190480301FCC00000BC00F800A000C070500703109C01C001C00180F8162080000010400000
...    8820000084100000620800004104000028820000184100000E208004040104100080802882001014041040020280A03B066B266B036B236B0
...    76F2A6B032B23280E0800004B2CA02000032CB280800014B2CA02000072CB280800024B2CA820000B2CB2A0800034B2CA020000F2CB2803A8
...    3455268AA071548E2A83D5D2AAAA0F174AA2858042017E0B0782C1E0B0782C1E0F0782C0000B0838010030020060080140100207006002010
...    00401800804000107002002004004010008020000E00C01C0200480300700801020E01402C0280580600D00C0181C01800804001006002010
...    00041C0280080500100C002018000380300700801200C01C0200408380500F00A01E018044030080700600E0100240180380400810700E00E
...    01C01C040048080080E01C0040400080700101000000E02402C0500580B00D01801820E00400C008018020050040081C0280080600100A002
...    01800041C00800801001004002008000380500B00C01A01402C03006083801003002006008014010020700A01E0180440280780601010700A
...    01601402C0300680600C0E0140040300080500100C00020E00400C008018020050040081C00800802001002002008006D5583808182058C17
...    A0A33B80000001B38080E03C0E03000300467C700040

@{RejectRequest_and_HOSuccess_DuringHOPrepare}
...    Received UE Context Modification Failure from GNB-2 with cause RAN xn handover triggered
...    Inter-eNB handover from EXT_ENB-2.* to ENB-3.1 performed
...    Setup QosFlow with QFI:1
...    PATH SWITCH REQUEST ACK
${nsetapx_plugin_addr}
...   https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.12.6/nsetapx-4.0-0.6.1-1.12.6+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${tshark_path}      /usr/bin/tshark

${Ignore_Cell_Id_For_Sib}    5    6    9    12
*** Test Cases ***
CB012209_01_Prioritizing_Voice_Service_during_XN-HO_Preparation
    [Tags]    CRT    CB012209_01
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 7, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    [Setup]    Precondition_for_CB012209
    Modify_QOS
    Trigger Xn links is Up
    UE Attach    ue_id=1
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Concurrent PDU Modification during HO Preparation Based Feature Enabled    ue_id=1
    sleep    720s
    Check PM Counters for CB012209_01
    [Teardown]    Case Postcondition

CB012209_ET_001_verify_Rejecting_request_setup_Voice_Service_during_ANR-PCI_resolution_phase
    [Tags]    CRT    CB012209_001
    [Documentation]
    ...    Precondition:
    ...             d.1 UE1 Set PCI-ANR resolution time delay of 100ms to wait for pdu session modification to add 5QI1event.
    ...             d.2 UE1 trigger inter-gNB intra-freq HO from real gnb cell2 HO sim gnb cell1.
    [Setup]    Precondition_for_CB012209_ANR
    Start Counter For CB012209_001
    Modify_QOS
    Trigger Xn links is Up
    UE Attach    ue_id=1
    Trigger intraFreANR with the concurrency
    sleep    720s
    Collect And Check Counter
    Intra fre Handover Return    ue_id=1
#    Delete NRREL
#    Delete before PM counter file
#    Start Counter For CB012209_001
#    Trigger intraFreANR with the concurrency2    ue_id=1
#    sleep    900s
#    Collect And Check Counter
    [Teardown]    Case Postcondition

CB012209_ET_002_Rejecting_the_request_to_setup_Voice_Service_during_XN-HO_Execution_Phase
    [Tags]    CRT    CB012209_002
    [Documentation]
    ...    Precondition:

    ...         ho from gnb2.1 to simgnb 3.1
    [Setup]    Precondition_for_CB012209
    Start Counter For CB012209_002
    Modify_QOS
    Trigger Xn links is Up
    UE Attach    ue_id=1
    Concurrent PDU Modification during HO Execution Based Feature Enabled    ue_id=1
    sleep    720s
    Collect And Check Counter
    [Teardown]    Case Postcondition

CB012209_03_Rejection_of_Voice_Service_during_XN-HO_Preparation
    [Tags]    CRT    CB012209_03
    [Documentation]
    ...    Precondition:
    ...         UE not with VONR Capability
    [Setup]    Precondition_for_CB012209
    Start Counter For CB012209_03
    CB012209_Change_UE_Capability  ue_capability=ue_capability_with_ANR_NoVoNR  ue_id=1
    Modify_QOS
    Trigger Xn links is Up
    UE Attach    ue_id=1
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Rejection of Voice Service during XN-HO Preparation    ue_id=1
    sleep    720s
    Collect And Check Counter
    [Teardown]    Case Postcondition

CB012209_07_Monitoring_PCMD_content_related_to_CB012209_with_XnAPSourceHO_Record
    [Tags]    CRT    CB012209_07
    [Documentation]
    ...    Precondition:
    ...         real gnb-2: cell-1: TDD, pci: 50, ssbFrequency=633216
    ...                     cell-2: TDD, pci: 51, ssbFrequency=633408
    ...         sim gnb-3: cell-1: TDD, pci: 7, ssbFrequency=633408
    ...         location on cell1 (Enable VONR): UE 5,6,7,10,11
    ...         UE with VONR Capability:          UE 2,3,4,6,7
    [Setup]    Case Precondition CB012209_07
    Modify_QOS
    Open DCAP
    Trigger Xn links is Up
    Download wireshark plugin
    Start Tcpdump Log
    UE Attach    ue_id=1
    Reset Xn Handover Preparation Param
    Delay Response to Xn Handover Preparation
    Concurrent PDU Modification during HO Preparation Based Feature and PCMD Enabled    ue_id=1
    sleep    20s
    Stop Tcpdump Log
    sleep    20s
    Check tcpdump log
    [Teardown]    Case Postcondition

*** Keywords ***

Case Precondition CB012209_07
    Common Test Setup For RRM
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag_07}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s
    ...                   customer=TMO_65

Precondition_for_CB012209
    # run    sudo mv /opt/iphy /opt/iphy_old
    # run    sudo cp -r /opt/wts /opt/iphy
    # run    sudo chown -R ute:ute /opt/iphy
    # run  sudo chown -R ute:ute /opt/wts
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s
    ...                   customer=TMO_65
    Run Keyword And Ignore Error    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

Precondition_for_CB012209_ANR
    # run    sudo mv /opt/iphy /opt/iphy_old
    # run    sudo cp -r /opt/wts /opt/iphy
    # run    sudo chown -R ute:ute /opt/iphy
    # run  sudo chown -R ute:ute /opt/wts
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sansa
    ...                   product_type=gnb
    ...                   traffic_info_dic=${None}
    ...                   tag=${config_tag_ANR}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=1200s
    ...                   customer=TMO_65
    Run Keyword And Ignore Error    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

Case Postcondition
    Airphone Operation    operation=edaemon_egate_teardown
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    HAZ TC02 Get SCF Internal Id By Scout  no_ute=False

Start Counter For CB012209_001
    #M55125C00035    M55147C01001    M55124C05002    M55153C00001    M55153C00002    M55125C09517
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C00035;
    ...         Counter rule: max(M55125C00035)>=1;
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55147C01001;
    ...         Counter rule:max(M55147C01001)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55124C05002;
    ...         Counter rule: max(M55124C05002)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter:M55153C00001;
    ...         Counter rule:max(M55153C00001)>=1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55153C00002;
    ...         Counter rule:max(M55153C00002)>=1;
    ${rule6}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09517;
    ...         Counter rule:max(M55125C09517)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Counter For CB012209_002
    #M55125C00035    M55125C09517    M55147C00024    M55124C02002    M55143C01504    M55143C00003
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C00035,M55147C00024,M55124C02002,M55125C09517,M55143C00003,M55143C01504,M55147C00001;
    ...         Counter rule: max(M55125C00035)>=1 and max(M55147C00024)==0 and max(M55124C02002)==0
        ...     and max(M55125C09517)>=1 and max(M55143C00003)==0 and max(M55143C01504)==0 and max(M55147C00001)>=1;
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Counter For CB012209_03
#M55125C00035    M55147C00024    M55124C02002    M55125C09517    M55143C00003
#    ...         Counter rule: max(M55125C00035)>=1 and max(M55147C00024)==0 and max(M55124C02002)==0
#    ...                    and max(M55125C09517)>=1 and max(M55143C00003)==0
#    ...                    and max(M55147C00001)>=1 and max(M55153C00001)>=0 and max(M55153C00002)>=0;
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C00035;
    ...         Counter rule: max(M55125C00035)>=1;
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55147C00024;
    ...         Counter rule: max(M55147C00024)==0;
    ${rule3}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55124C02002;
    ...         Counter rule: max(M55124C02002)==0;
    ${rule4}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55125C09517;
    ...         Counter rule: max(M55125C09517)>=1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55143C00003;
    ...         Counter rule: max(M55143C00003)==0;
    ${rule6}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55147C00001;
    ...         Counter rule: max(M55147C00001)>=1;
    ${rule7}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55153C00001;
    ...         Counter rule: max(M55153C00001)>=0;
    ${rule8}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55153C00002;
    ...         Counter rule: max(M55153C00002)>=0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}    ${rule7}    ${rule8}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Prepare UE History Information
    Airphone Execute Egate Command    cmd=ue_change_location id=1-2 cell=1
    Airphone Execute Egate Command    cmd=ue_change_location id=3 cell=2
    Airphone Execute Egate Command    cmd=state_sim_disp
    Airphone Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Modify_QOS
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=5 default\=on
    sleep    2s

CB012209_Change_UE_Capability
    [Arguments]  ${ue_capability}  ${ue_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability} capability_file=${CURDIR}/APCFG/ue_capability.cfg

Preconditions for UE HO Back
    Airphone Execute Egate Command    cmd=ue_reauth id=1 nr_sec_cap=aes|aes
    Airphone Execute Egate Command    cmd=amf_path_switch_param id=1 include_ue_sec_cap=on
    Airphone Execute Egate Command    cmd=smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

Trigger Xn links is Up
    [Arguments]    ${pass_regexp}=XnAP Link with GNB-2 .* is up
    sleep    120s
    ${cmd1}    Catenate    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command    cmd=${cmd1}
    ${cmd2}    Catenate    gnb_xn_link_up gnb=3 target=2
    Airphone Execute Egate Command    cmd=${cmd2}    pass_regexp=${pass_regexp}
    sleep    5s

Delay Response to Xn Handover Preparation
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 action=delayed_rsp time_to_wait=v5s

Reset Xn Handover Preparation Param
    Airphone Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=3 reset

UE Attach
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table
#    sleep    120s
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1    pass_regexp=${pass_regexp}
    sleep    1min

Trigger intraFreANR with the concurrency
    [Arguments]    ${ue_id}=1    ${target_cell}=7    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:1:1:1:1:0 qosflows_to_add=6
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

Trigger intraFreANR with the concurrency2
    [Arguments]    ${ue_id}=1    ${target_cell}=7    ${action}=send_nas_pdu_session_modify

    ${CGI_cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=100ms
    ...                      action=${action} pduSessionInfo=1:1:1:1:1:0 qosflows_to_add=6
    Airphone Execute Egate Command    cmd=${CGI_cmd}
    ${HO_cmd}    Catenate  ue_measurement_send_nr id=${ue_id} meas_id=7 event=A3 srsrp_nr=5 srsrq_nr=5
    ...               phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
     Airphone Execute Egate Command    cmd=${HO_cmd}
#     ...    timeout=120    pass_regexp=${pass_regexp_ANR}
    sleep    2min

UEs Trigger Inter-gNB Intra-FreqANR HO
    [Arguments]    ${ue_id1}=1
    Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication    ${ue_id1}

Trigger Inter-gNB Intra-FreqANR HO Concurrency With PDU Session Mofication
    [Arguments]    ${ue_id}=1    ${target_cell}=7    ${action}=send_nas_pdu_session_modify
    Set PCI-ANR resolution time delay    ${ue_id}    ${action}
    ${cmd1}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=5 srsrq_nr=5
    ${cmd2}    Catenate   phycell_id=${target_cell} nrsrp_nr=100 nrsrq_nr=100
    ${HO_cmd}    Catenate    ${cmd1}    ${cmd2}
    Airphone Execute Egate Command    cmd=${HO_cmd}

Set PCI-ANR resolution time delay
    [Arguments]    ${ue_id}    ${action}=send_nas_pdu_session_modify
    ${cmd_action}=    Catenate    action=${action} pduSessionInfo=1:${ue_id}:1:1:1:0 qosflows_to_add=6
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=500ms ${cmd_action}

Intra fre Handover Return
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 phycell_id=51 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}

Delete NRREL
    ${rm_ob_list}    Create List
    ${rm_ob_name}    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-256
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login
    ${ret}    ${value}     Run Keyword And Ignore Error
    ...    coam.get_parameters   dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-256
    ...    connection=COAM
    Run Keyword If   '${ret}'=='Fail'    Fail    NRREL-256 doesn't deleted
    coam_admin.perform_object_recommissioning    dist_name=${rm_ob_name}    parameter_delta_list=${rm_ob_list}
    ...    operation=delete    connection=COAM
    [Teardown]    COAM_Admin.Logout

Concurrent PDU Modification during HO Preparation Based Feature Enabled
    [Arguments]    ${ue_id}=1    ${A3_meas_id}=3    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=7 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s

Concurrent PDU Modification during HO Preparation Based Feature and PCMD Enabled
    [Arguments]    ${ue_id}=1    ${A3_meas_id}=3    ${pass_regexp}=Added QosFlow with QFI:2 fiveQI:1
#    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=rrcReconfigurationComplete
#    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=7 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s

Rejection of Voice Service during XN-HO Preparation
    [Arguments]    ${ue_id}=1    ${A3_meas_id}=3
#    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=rrcReconfigurationComplete
#    sleep    5s
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=11 phycell_id=7 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf
    sleep    5s
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp
    sleep    5s
#    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
#    sleep    5s
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 trf_id=1 mbps=5 dir=dl
#    sleep    5s

Concurrent PDU Modification during HO Execution Based Feature Enabled
    [Arguments]    ${ue_id}=1
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
#    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
#    ...    pass_regexp=rrcReconfigurationComplete
#    sleep    5s
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} reset
    Airphone Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any delay=1000
    Airphone Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${ho_cmd}  Catenate  ue_measurement_send_nr id=${ue_id} meas_id=3 event=A3 srsrp_nr=11 phycell_id=7 nrsrp_nr=85
    Airphone Execute Egate Command    cmd=${ho_cmd}
    sleep    0.5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf
#    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=2 trf_id=1 mbps=5 dir=dl protocol=tcp

#Check Counter for CB012209_001
#    Sleep   500s
#    ${pi_list}=  Create List    M55125C00035    M55147C01001    M55124C05002    M55153C00001    M55153C00002    M55125C09517
#    ${expect_value}    Set Variable    0
#    FOR  ${counter_ID}  IN  @{pi_list}
#           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
#           ...                                               expect_value=${expect_value}
#    END
#
#Check Counter for CB012209_03
#    Sleep   500s
#    ${pi_list}=  Create List    M55125C00035    M55147C00024    M55124C02002    M55125C09517
#    ${expect_value}    Set Variable    0
#    FOR  ${counter_ID}  IN  @{pi_list}
#           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
#           ...                                               expect_value=${expect_value}
#    END
#    ${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0-0

Check PM Counters for CB012209_01
    Sleep   500s
    ${pi_list}    Create List    M55308C23002    M55308C32000    M55125C09031    M55143C00003    M55143C01504
    ${expect_value}    Set Variable    0
    FOR  ${counter_ID}  IN  @{pi_list}
           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
           ...                                               expect_value=${expect_value}
    END

#Check PM Counters for CB012209_002
#    Sleep   500s
#    ${pi_list}    Create List    M55125C00035    M55125C09517    M55147C00024    M55124C02002
#    ${expect_value}    Set Variable    0
#    FOR  ${counter_ID}  IN  @{pi_list}
#           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
#           ...                                               expect_value=${expect_value}
#    END
#    ${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C00003    expect_value=0
#    ${counter_values_list2}    Check counter value equal expect value1    counter_ID=M55143C01504    expect_value=0

Download wireshark plugin
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

Start Tcpdump Log
    Log To Console    start tcpdump
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}

Stop Tcpdump Log
    Log To Console    stop tcpdump
    ${capture_file_path}    ${input_file}=    Stop Tcpdump in SBTS
    set test variable    ${capture_file_path}

Decode tcpdump
    [Arguments]    ${input_file}=${capture_file_path}    ${filter_expression}=nsetapx.result == 2
    ${tshark_comd}  catenate    tshark -r ${input_file} -o ntrstr.defragment:TRUE  -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -Y ${filter_expression}
    ${filtered_packets}    Run    ${tshark_comd}
    [Return]    ${filtered_packets}

Check tcpdump log
    Log To Console    check tcpdump log
    Decode tcpdump    input_file=${capture_file_path}   filter_expression=nsetapx.result == 2

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start


