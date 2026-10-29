*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_FB}=   220s

*** Keywords ***
CB008490-FB#B101_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_Xn-U_Dl_data_GTP-U_Error
    Register Nrdc Ue With Default Pdu Session
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Start Udp Traffic 110Mbps In DL And UL
    Check Data Traffic On Mcg And Scg Scell
    Set Expected Message Flow For UE Context Release Due To Gtp-u Error
    Trigger GTP-U Error for UE
    Verify Expected Message Flow For UE Context Release Due To Gtp-u Error

CB008490-FB#B103_Inter-gNB_NR-DC_bearer_takeback_triggered_due_to_NG-U_Ul_data_GTP-U_Error
    Register Nrdc Ue With Default Pdu Session
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Start Udp Traffic 110Mbps In DL And UL
    Check Data Traffic On Mcg And Scg Scell
    Set Expected Message Flow For UE Context Release Due To Gtp-u Error
    Trigger simulated UPF to send GTP-U Error Indication
    Verify Expected Message Flow For UE Context Release Due To Gtp-u Error

Check Data Traffic On Mcg And Scg Scell
    Sleep    ${TRAFFIC_DURATION_SEC_FB}
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pusch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch scell=1
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pusch scell=1
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=110    unit=mbps    margin=0.2    direction=dl

Trigger GTP-U Error for UE
    Execute egate command    cmd=gnb_ue_xn_inject_error_ind id=2 ue=1 pdu=1 qfi=1

Trigger simulated UPF to send GTP-U Error Indication
    Execute egate command   cmd=upf_ue_pdu_inject_error_ind id=1 ue=1

Set Expected Message Flow For UE Context Release Due To Gtp-u Error
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextModificationRequired
    Expect message flow
    ...    gNB3:E1AP_BearerContextModificationRequired (transport eq 'transport-resource-unavailable') as BearerContextModificationRequired
    ...    alias=E1apBearerContextModificationRequired
    ...    overall_timeout=10
    Expect message flow
    ...    gNB3:F1AP_UEContextReleaseCommand (transport eq 'transport-resource-unavailable') as UEContextReleaseCommandMNContext
    ...    alias=F1apUeContextReleaseMNContext
    ...    overall_timeout=10
    EXPECT FLOW[timeout=10]: gNB3 E1AP bearerContextRelease

Verify Expected Message Flow For UE Context Release Due To Gtp-u Error
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextModificationRequired
    Flow occurred as expected       alias=F1apUeContextReleaseMNContext
    Flow occurred as expected       alias=E1apBearerContextModificationRequired
    PASS FLOW[timeout=10]: gNB3 E1AP bearerContextRelease
