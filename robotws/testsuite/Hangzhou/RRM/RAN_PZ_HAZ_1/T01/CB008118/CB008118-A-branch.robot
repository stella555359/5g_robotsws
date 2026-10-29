*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords    Kill node    AND    Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM


Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB008118_KeyWords.robot
Library     ta5g_tshark
Library      ute_tshark
Library      taf.config.wts      WITH NAME    wts_conf
*** Variables ***
${delta_scf01}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008118/delta_SCF_B2_EC4.json
${delta_scf02}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB008118/delta_SCF_B2_EC4_alt1.json

*** Test Cases ***
CB008118_Case_prerun
    UTE DCAP install
    New Download wireshark plugin

CB008118-A#B1_TC01_Successful_MCGBR_5QI_65_66_67_Bearer_Setup_with_RLF_parameter
    [Tags]    QC_251191        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes the gNB behavior for the successful setup of 5QI-69 followed by Mission critical
    ...    push to talk (i.e., 5QI 65/66,67) along with RLF parameters, that is received as part of PDU Session Resource
    ...    Setup.(USCB008118-A#B1)
    [Setup]    Case Precondition For Branch
    New Download wireshark plugin
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    UE Deregister From gNB      ue_id=1
    Start Collect Counter For Multi Rule    ${PMQAP_distname}    ${counter1}    ${counter_rule1}    ${nrcell_distname}
    ...        ${counter2}    ${counter_rule2}
    Start Collect Wireshark For GNB
    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-69
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,10 by=amf   #modify 5QI-65，67
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    sleep    3s
    ${local_file_path}=    Stop Wireshark log For GNB
    Stop Collect Counter and verify PM counters
#    CB008118 AB1 TC01 Check Ponit 1    ${local_file_path}
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=False
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
#    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB008118-A#B14_TC25_Successful_Intrafrequency_IntraDU_IntraGnb_handover_with_MCGBR bearers
    [Tags]    QC_251192        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes the gNB behaviour associated with successful modification of mission critical
    ...    QoS flow triggered as part of NGAP: PDU Session Resource Modify Request(based on USCB008118-A#B14)
    [Setup]    Case Precondition For Branch
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    UE Deregister From gNB      ue_id=1
    Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id=1 establishment_cause=mcs-PriorityAccess
    Set Parameter For CB008118    MRBTS-1/NRBTS-1    applyPriorityAccess    MCS
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    actPriorityAccess    true
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxNumOfRrcSA    250
    Start Collect Wireshark For GNB
    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-69
    #UE PDU Session Modify   ue_id=4  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf    #modify 5QI-65
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,10 by=amf   #modify 5QI-65
    sleep    10s
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=53    carrier_freq=520110
    ...        pass_regexp=Intra-eNB handover
#    ${local_file_path}=    Stop Wireshark log For GNB
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=False
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
#    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB008118-A-PMO#B4_TC49_Counter_update_for_recovery_from_RLF_after_MCGBR_bearer_establishment
    [Tags]    QC_251190        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario aims to update the counters for recovery from Radio link failure after the MC-GBR
    ...    bearer establishment.Could be trigger same as User scenario USCB008118-A#B5 (5G_RAN_USR_RRM_28604)
    [Setup]    Case Precondition For Branch
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    UE Deregister From gNB      ue_id=1
    Airphone Execute Egate Command    cmd=ue_change_location id=1 enb=2 cell=1
    Start Collect Counter    ${nrcell_distname}    ${counter9}    ${counter_rule9}
    Deactive Radio Link Failure Profile    ue_id=1
    Start Collect Wireshark For GNB
    Set Parameter For CB008118    MRBTS-1/NRBTS-1    applyPriorityAccess    MCS
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    actPriorityAccess    true
    Set Parameter For CB008118    MRBTS-1/NRBTS-1    tRLFindForDUPubSafety    1000ms
    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-69
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,10 by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    Trigger Radio Link Failure without check    ue_id=1
    sleep    20s
    Trigger RRC Reestablish    ue_id=1    cell_id=1
    Deactive Radio Link Failure Profile    ue_id=1
#    ${local_file_path}=    Stop Wireshark log For GNB
    Stop Collect Counter and verify PM counters
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=False
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
#    ...           AND             Get SCF Internal Id By Scout    no_ute=False

CB008118-A#B2_EC4_TC59_RRC_Connection_reject_when_actPriorityAccess_set_with_false
    [Tags]    QC_251188        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes RRC connection setup for Mission critical services, when no resources is available.
    ...    The High Priority Access (MCS) calls could be recognized using the following:
    ...    RRCSetupRequest:establishmentCause = mcs-PriorityAccess. (based on USCB008118-A#B2 EC4 ALT2)
    ...    IF RRCSetupRequest:establishmentCause = mcs-PriorityAccess BUT actPriorityAccess = false, then this UE
    ...    considered as normal UE
    [Setup]    Case Precondition For Branch
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    Set Parameter For CB008118    MRBTS-1/NRBTS-1    applyPriorityAccess    MCS
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    actPriorityAccess    false
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxNumOfRrcSA    1
    Delta plan operation for CB008118    ${delta_scf01}
    Check site on air
    Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id=1 establishment_cause=mcs-PriorityAccess
    Airphone Execute Egate Command    cmd=ue_nr_rrc_setup_param id=2 establishment_cause=mcs-PriorityAccess
    Start Collect Wireshark For GNB
    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-70
    #UE PDU Session Modify   ue_id=4  pdu=1  qos_flow_list=@{pdu_qos_list}  by=amf    #modify 5QI-65
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,10 by=amf
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    UE2 Register with reject
    ${local_file_path}=    Stop Wireshark log For GNB
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=False
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
#    ...           AND             Get SCF Internal Id By Scout    no_ute=False


CB008118-A#B9_TC13_MCGBR_5QI67_GFBR_Exceeded_causing_packet_discards
    [Tags]    QC_251189        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    A MC-GBR(5QI 67) UE whose over the air transmission data rate exceeds the GFBR value provided by the 5GC will
    ...    have its scheduling priority lowered to non-GBR priority with a scheduling weight equal to 1 until the GBR data
    ...    rate falls below the GFBR value at which time the UE's priority will be returned to GBR priority. While the
    ...    UE's scheduling priority is lowered, GBR packets may be discarded because they could not be scheduled before
    ...    the MC-GBR discard timer expiry.(based on USCB008118-A#B9)
    [Setup]    Case Precondition For Branch
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    Airphone Execute Egate Command    cmd=ue_deregister id=1-18 ue_deregister_type=switch_off
#    Set Parameter For CB008118    MRBTS-1/NRBTS-1    applyPriorityAccess    MCS
#    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    actPriorityAccess    true
#    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxNumOfRrcSA    250
    SLEEP    5S
    Airphone Execute Egate Command    cmd=ue_change_location id=1-18 enb=2 cell=10
    Start Collect Counter    ${nrbts_distname_PDCP}    ${counter5}    ${counter_rule5}
    Start Collect Wireshark For GNB
    FOR    ${ue_id}    IN RANGE    1    9
        Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
        sleep    2s
        Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal default_qos_flow=10
        Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1
        ...                                pass_regexp=QoS Routing Table
        sleep    3s
    END
    Airphone Execute Egate Command    cmd=trf_data_start ue=1-8 pdu=1 qfi=1 dir=dl mbps=60
    ${local_file_path}=    Stop Wireshark log For GNB
    sleep    100s
    Stop Collect Counter and verify PM counters
    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=False
    [Teardown]    Run Keywords      Stop Wireshark log For GNB
    ...           AND               Case Postcondition
#    ...           AND             Get SCF Internal Id By Scout    no_ute=False

