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


*** Variables ***

${TL10872_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/APCFG/wts_cloud.cfg
${vm_config_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/ap_tl10872.json

*** Test Cases ***
Update Local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...               eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/ap_tl10872.json
    ...               ap_build=${None}
    OperatingSystem.Run    cp ${TL10872_wts} /opt/wts/latest/basic_setup.cfg

CB010559_A_TC01_B1_Successful_RRE_unprepared_gNB_without_HO
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     This test case verifies the successful Radio Resource Control (RRC) connection
    ...     re-establishment procedure when a User Equipment (UE) moves to an unprepared gNB
    ...     where no handover procedure is ongoing.
    ...     Precondition:
    ...     Xn interface is available and correctly configured between gNB1 and gNB2
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
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Change UE1 Location To eNB2 Cell4
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    sleep  10s
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=4  cause=otherFailure
    [Teardown]    CB010559_A_Tear_Down

CB010559_A_TC02_B1_Successful_RRE_unprepared_gNB_without_HO_VONR
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]    [Setup]    Run Keywords    Case Precondition

    ...     This test case verifies the successful Radio Resource Control (RRC) connection
    ...     re-establishment procedure when a User Equipment (UE) moves to an unprepared gNB
    ...     where no handover procedure is ongoing.
    ...     Precondition:
    ...     Xn interface is available and correctly configured between gNB1 and gNB2
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
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Change UE1 Location To eNB4 Cell1
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    PDU Modify to add DRB  ue_id=1  pdu_id=1  qosflows=4   pass_regexp=${None}
    sleep  10s
    PDU Modify to add DRB  ue_id=1  pdu_id=1  qosflows=2   pass_regexp=${None}
    sleep  10s
    Start 1Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=2  cell_id=4  cause=handoverFailure
    [Teardown]    CB010559_A_Tear_Down

CB010559_A_TC03_EC3_PathSwitchRequest_failure_in_RRE_target_gNB
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     This test case is designed to verify the system's behavior and resource release mechanism in a 5G Standalone (SA)
    ...     mode scenario. Specifically, it addresses the case where a UE attempts an RRC connection re-establishment on
    ...     an unprepared gNB, but the subsequent Path Switch Request to the core network.
    ...     Precondition:
    ...     Xn interface is available and correctly configured between gNB1 and gNB2
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
#    [Setup]    Run Keywords    Case Precondition
    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Configures path switch acknowledgement parameter AMF
    Change UE1 Location To eNB2 Cell4
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=4
    [Teardown]    CB010559_A_Tear_Down

CB010559_A_TC04_EC5_ALT1_Fallback_RRC_Setup_Due_RetrieveUeContextFailure
    [Tags]    QC_XXX    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     This test case is designed to verify the gNB's behavior when an RRC connection re-establishment procedure fails.
    ...     Specifically, it tests the fallback mechanism where the target gNB (gNB1) initiates a new RRC Setup procedure
    ...     after failing to retrieve the UE context from the UE's last serving gNB (gNB2) .
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
    Configures ue retrieve failure parameter  gnb_id=3
    Trigger RRC Reestablish to other gNB  ue_id=1  gnb=2  cell_id=4   cause=otherFailure
    [Teardown]    CB010559_A_Tear_Down

*** Keywords ***

CB010559_A_Tear_Down
    [Arguments]   ${ue_id}=1
    UE Deregister From gNB      ue_id=${ue_id}