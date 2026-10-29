*** Settings ***
Documentation
...   Author: ZHIFU.XU@nokia-sbell.com
...   Contact: ZHIFU.XU@nokia-sbell.com
...   Description: The user scenario related to AirPhone operation.


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Test Timeout    600 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB013289_KeyWord.robot
Resource          CB013289_PM_Counter_KeyWord.robot
Resource          CB013289_Check_Point_KeyWord.robot
Library     ta5g_tshark
Library      ute_tshark
Library      taf.config.wts      WITH NAME    wts_conf



*** Test Cases ***
CB013289-PMO#1_Counter_update_for_the_successful_Inter-RAT_handover_with_direct_data_forwarding
    [Tags]    CRT1    CB013289_39
    [Documentation]
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    It is the successful case IRAT HO is triggered with direct data forwarding through NG interface.
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)
    ...    NOte:this case is not set 5QI1&2 for data forwarding
    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Counter    ${nrcell_distname}    ${direct_counter}    ${direct_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    UE4 Register
    UE4 And PDU Session-1 Gateway-4 Setup
    Send Egate Command and verify output   ue_meas_cfg_disp id=4
    UE PDU Session Modify   ue_id=4  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE4 And PDU Session-2 Gateway-4 Setup
    UE PDU Session Modify   ue_id=4  pdu=2  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE4
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE4
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-2 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-3 dl for UE4
    Start 10Mbps Traffic On PDU Session-2 QFI-4 dl for UE4
    Trigger inter-RAT Handover    ue_id=4  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 Check Direct Path Item    ${local_file_path}
    CB013289 AB1 TC02 Check Ponit 1    ${local_file_path}
    CB013289 Check Data Forwarding By NG interface    ${local_file_path}
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition

CB013289-PMO#2_Counter_update_for_the_successful_Inter-RAT_handover_with_indirect_data_forwarding
    [Tags]    CRT2    CB013289_40
    [Documentation]
    ...    set the 'data forwarding method' to 'indirect data fwd' in the NRADJECELL MOC.
    ...    The parameter ‘NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd' for NRDRB_5QI MOCs corresponding to
    ...    5QI-A, 5QI-B and 5QI-C
    ...    The ‘Inter-RAT handover from NR to LTE’ is executed with indirect data forwarding.
    [Setup]    Run Keywords    Prepare WTS Config With Active Indirect DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnX2
    Set NRADJECELL-5000 iRatDataForwardingMethod with indirectDataFwd
    Start Collect Counter    ${nrcell_distname}    ${indirect_counter}    ${inidrect_counter_rule}
    Start Collect Wireshark For GNB
#    Start Ip Traffic Capture
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE PDU Session Setup   ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
    UE PDU Session Modify   ue_id=1  pdu=2  qos_flow_list=@{pdu2_qos_list}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=1
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    Stop Collect Counter and verify PM counters
    CB013289 AB2 TC10 Check Ponit 1    ${local_file_path}

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
#    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition

CB013289-PMO#3_Counter_update_for_the_successful_Inter-RAT_handover_with_without_data_forwarding
    [Tags]    CRT3    CB013289_41
    [Documentation]
    ...    This user scenario describes The ‘Inter-RAT handover from NR to LTE’ is executed without data forwarding
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter ‘NRDRB_5QI.dataForwarding’ is set to ‘IRATDataFwd for NRDRB_5QI MOCs corresponding to 5QI-A, 5QI-B and 5QI-C
    ...    CB005876  enabled (The setting of parameter ‘NRBTS.actInterRatHoSADlDataForward’ is set to true)
    ...     eNB side set no data forwarding: gnb_param id=5 ng_data_forwarding_HO=off
    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Counter    ${nrcell_distname}    ${nodata_counter}    ${nodata_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    Airphone Execute Egate Command    cmd=gnb_param id=5 include_e-rab_ids=none
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Send Egate Command and verify output   ue_meas_cfg_disp id=1
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    Stop Collect Counter and verify PM counters

    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition

CB013289-PMO#1_Counter_update_for_the_successful_Inter-RAT_handover_with_direct_data_forwarding_FDD
    [Tags]    CRT4    CB013289_63
    [Documentation]
    ...    This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
    ...    It is the successful case IRAT HO is triggered with direct data forwarding through NG interface.
    ...    CB013289 feature is enabled by setting “NRBTS.actInterRatHoDirectDlDataFwd” to “IRATDirectDataFwdOnNg”
    ...    A NRADJECELL is configured with parameter “iRatDataForwardingMethod” set to “directDataFwd”
    ...    The parameter “NRDRB_5QI.dataForwarding” is set to “IRATDataFwd” for NRDRB_5QI MOCs corresponding to 5QI-X.
    ...    (not include 5QI-1 or 5QI-2)
    ...    NOte:this case is not set 5QI1&2 for data forwarding
    [Setup]    Run Keywords    Prepare WTS Config With Active direct DataFW    ${CURDIR}/config/basic_setup_13289.cfg
    ...           AND          Case Precondition
    ...           AND          Download wireshark plugin
    ...        AND             Delta Plan Commission    ${CURDIR}/config/CB013289_FDD.json
#    Kill agate and start egate
    Active Feature CB013289 On IRATDirectDataFwdOnNg
    Set NRADJECELL-5000 iRatDataForwardingMethod with directDataFwd
    Start Collect Counter    ${nrcell_distname_FDD}    ${direct_counter}    ${direct_counter_rule}
    Start Collect Wireshark For GNB
    Start Ip Traffic Capture
    Airphone Execute Egate Command    cmd=ue_change_location id=51 enb=2 cell=3
    UE51 Register
    UE51 And PDU Session-1 Gateway-51 Setup
    Send Egate Command and verify output   ue_meas_cfg_disp id=51
    UE PDU Session Modify   ue_id=51  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf
    UE51 And PDU Session-2 Gateway-51 Setup
    UE PDU Session Modify   ue_id=51  pdu=2  qos_flow_list=@{pdu_qos_list2}  by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE51
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE51
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE51
    Start 10Mbps Traffic On PDU Session-2 QFI-1 dl for UE51
    Start 10Mbps Traffic On PDU Session-2 QFI-2 dl for UE51
    Start 10Mbps Traffic On PDU Session-2 QFI-3 dl for UE51
    Start 10Mbps Traffic On PDU Session-2 QFI-4 dl for UE51
    Trigger inter-RAT Handover For FDD    ue_id=51  phycell_id=11
    sleep    5s
    ${local_file_path}=    Stop Wireshark log For GNB
    CB013289 Check Direct Path Item    ${local_file_path}
    CB013289 AB1 TC02 Check Ponit 1    ${local_file_path}
    CB013289 Check Data Forwarding By NG interface    ${local_file_path}
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Stop Ip Traffic Capture
    ...           AND               Case Postcondition

*** Keywords ***

Kill agate and start egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    Airphone Edaemon Egate Setup
    Airphone Cfg Configuration    wts_cfg_name=${CURDIR}/config/basic_setup_13289.cfg
    Sleep    5s

Case Precondition For X2IPV6
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_13289.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/scf_13289_X2IPV6.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1


