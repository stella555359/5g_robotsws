*** Settings ***
Documentation
...   Author: zhixia.qin@nokia-sbell.com
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup    Run keywords    Common Suite Setup For AIC
...         AND    Config Eth Interface Internal    ${vm_config_path}
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          CB010559_KeyWords.robot

*** Test Cases ***
CB010559_I_B1_TC01_UE_Ctxt_found_on_Src_HO_gNB_during_Xn_HO_Prep_phase
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     This test case validates the interworking between an RRC Connection Re-establishment and an ongoing inter-gNB handover.
    ...     Specifically, it verifies the scenario where a User Equipment (UE) context is successfully found on the source handover
    ...     gNB (gNB2) during the Xn Handover Preparation phase.
    ...     Precondition:
    ...     gNB1: Re-establishment target gNB   (CB010873)
    ...     gNB2: UE's last serving gNB and Handover Source gNB.  (CB010872)
    ...     gNB3: Handover Target gNB. (simulate) (gNB4)
    ...     NRBTS.NRCELL.NRREL.handoverAllowedSA to 'allowed'
    ...     CB010559 parameters
    ...        NRBTS.actRrcRREUnprepgNB = intergNB
	...     legacy parameters
	...       NRBTS.rrcReestabTypeSA  = sameGNB
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Change UE1 Location To eNB2 Cell4
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    sleep  10s
    Send A2 Measurement    ue_id=1    carrier_freq=628608   threshold=67
    sleep    3s
    Configures xn handover preparation response  gnb_id=3   action=drop
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=381    carrier_freq=636576
    ...    pass_regexp=${none}
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=4
    [Teardown]    CB010559_I_Tear_Down

CB010559_I_B5_TC02_UE_Ctxt_found_on_Tgt_HO_gNB_during_XN_HO_Exec_phase
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    The test verifies that when a UE fails the handover to gNB3 and attempts to re-establish a connection with gNB1,
    ...    gNB1 will attempt to retrieve the UE context from gNB3. Because gNB3 is in the handover execution phase, it will
    ...    reject the context retrieval request. Consequently, gNB1 will fall back to a standard RRC Setup procedure to connect the UE.
    ...     Precondition:
    ...     gNB1: Re-establishment target gNB   (CB010873)
    ...     gNB2: UE's last serving gNB and Handover Source gNB.  (simulate)
    ...     gNB3: Handover Target gNB. (CB010872)
    ...     NRBTS.NRCELL.NRREL.handoverAllowedSA to 'XnHoNotAllowed'
    ...     CB010559 parameters
    ...        NRBTS.actRrcRREUnprepgNB = intergNB
	...     legacy parameters
	...       NRBTS.rrcReestabTypeSA  = sameGNB
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Enable Disable XNHandover
    Start Collect Wireshark For Cloud
    Change UE1 Location To eNB3 Cell1
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    sleep  10s
    Send A2 Measurement    ue_id=1    carrier_freq=636576   threshold=67
    sleep    3s
    Configures RRC Reconfiguration Complete
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=720    carrier_freq=628608
    ...    pass_regexp=${none}
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=4
    [Teardown]    CB010559_I_B6_Tear_Down

CB010559_I_TC03_PMO2_Fallback_RRC_Setup_in_unprepared_gNB
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     This test case is designed to verify the gNB's behavior when an RRC connection re-establishment procedure fails.
    ...     Specifically, it tests the fallback mechanism where the target gNB (gNB1) initiates a new RRC Setup procedure
    ...     af    Start Collect Wireshark For Cloud ter failing to retrieve the UE context from the UE's last serving gNB (gNB2) .
    ...     Precondition:
    ...     Xn interface is available and correctly configured between gNB1 and gNB2.
    ...     gNB1 and gNB2 are connected to the same AMF
    ...     Xn handover is allowed from UE's last serving cell in gNB2 to the UE's selected reestablish target cell in gNB1
    ...     NRBTS.NRCELL.NRREL.handoverAllowedSA to 'allowed'
    ...     CB010559 parameters
    ...        NRBTS.actRrcRREUnprepgNB = intergNB
	...        NRBTS.timerUEContextRetrieval  = 300 in gNB1
	...        NRBTS.tWaitingRlRecoverSA =100000ms in gNB2
	...        NRBTS.timerKeepUECtxtServgNB =2000ms in gNB2
	...     legacy parameters
	...       NRBTS.rrcReestabTypeSA  = sameGNB
	...     inorder to simulate RetrieveUeContextFailure, gNB1 is a simulated gNB
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Change UE1 Location To eNB3 Cell1
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    sleep  10s
    Configures ue retrieve failure parameter  gnb_id=3
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=2  cell_id=4
    [Teardown]    CB010559_I_Tear_Down


*** Keywords ***

CB010559_I_Tear_Down
    [Arguments]   ${ue_id}=1
    UE Deregister From gNB      ue_id=${ue_id}

CB010559_I_B6_Tear_Down
    [Arguments]   ${ue_id}=1
    UE Deregister From gNB      ue_id=${ue_id}
    Enable Disable XNHandover   allowed