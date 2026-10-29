*** Settings ***
Documentation
...   Author: huiqiong.yan@nokia-sbell.com
...   Contact: huiqiong.yan@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords   Common Suite Setup For RRM   AND   Update bsr package
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Common Test Teardown For RRM

Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          CB008118_D_KeyWords.robot


*** Test Cases ***
#Case_Precondition
#    Case Precondition

CB008118-D#B1_TC01_Admission_Control_for_Public_Safety_DRB_with_Pre-emption_DRB_Resource_Shortage_UE_Attach_TDD
    [Tags]    QC_220434       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes gNB behaviour with cell level admission control Public Safety DRB (PS-DRB)
    ...    setup proceduresincluding handover (incoming inter-gNB Xn handover, inter-gNB NG handover, inter-RAT
    ...    handover, intra-gNB handover). Interactionwith DRB pre-emption (escalated to UE context pre-emption)
    ...    is considered. (CB008118-D#B1)
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
    sleep    720s
    [Setup]    Case Precondition
    UE Deregister From gNB      ue_id=1-80
    FOR     ${ue_id}    IN RANGE    10    14
        ${index}    Set Variable    ${ue_id}
        Establish mcs-PriorityAccess    ue_id=${ue_id}
        UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=5
        sleep    10s
        UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=2
        sleep    10s
        Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=2
        sleep    5s
#        Check GBR UE Tput    ue_id=${ue_id}   pdu_id=1    qfi_id=2
    END
    FOR     ${ue_id}    IN RANGE    1    4
        ${index}    Set Variable    ${ue_id}
        Establish mcs-PriorityAccess    ue_id=${ue_id}
        UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19
        sleep    10s
        UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15
        sleep    10s
        UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=17
        sleep    10s
        Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=2
        Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=3
        sleep    5s
        Check GBR UE Tput    ue_id=${ue_id}   pdu_id=1    qfi_id=2
        Check GBR UE Tput    ue_id=${ue_id}   pdu_id=1    qfi_id=3
    END
    UE Deregister From gNB      ue_id=1-80
    [Teardown]    Run Keyword And Ignore Error      Execute_teardown

CB008118_D#B2_TC11_Admission_Control_for_Public_Safety_DRB_with_Pre-emption_UEcontext_Resource_Shortage_UE_i-RAT_HO_TDD
    [Tags]    QC_220433       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes gNB behaviour with cell level admission control Public Safety DRB (PS-DRB)
    ...    setup proceduresincluding handover (incoming inter-gNB Xn handover, inter-gNB NG handover, inter-RAT
    ...    handover, intra-gNB handover). Interactionwith UE context pre-emption is considered. (CB008118-D#B2)
#    Airphone Operation    edaemon_egate_setup     gnb tag=CB008118_RJIO
    [Setup]    Case Precondition
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxGBRTrafficLimit    90
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxNumOfSCellAlloc    5
    Set Parameter For CB008118    MRBTS-1/NRBTS-1/NRCELL-1    maxNumOfRrcSA    5

    UE Deregister From gNB      ue_id=1-80
    FOR     ${ue_id}    IN RANGE    10    16
        ${index}    Set Variable    ${ue_id}
        Establish mcs-PriorityAccess    ue_id=${ue_id}
        UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=9
        sleep    10s
        Send NonGBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=1
    END

    FOR     ${ue_id}    IN RANGE    1    5
        ${index}    Set Variable    ${ue_id}
        Establish mcs-PriorityAccess    ue_id=${ue_id}
        UE Register And PDU Session Setup   ue_id=${ue_id}   qos_flow=19
        sleep    10s
        UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=15
        sleep    10s
        UE Modify new PDU    ue_id=${ue_id}    pdu=1    qosflows_to_add=17
        sleep    10s
        Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=2
        Send GBR Throughput    ue_id=${ue_id}    pdu_id=1    qfi_id=3

        sleep    10s
        Check GBR UE Tput    ue_id=${ue_id}   pdu_id=1    qfi_id=2
        Check GBR UE Tput    ue_id=${ue_id}   pdu_id=1    qfi_id=3
    END
    [Teardown]    Run Keyword And Ignore Error      Execute_teardown
