*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-DevHZ5_SG1    owner-carol.an    release-SBTS23R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    master_vDU
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
@{PARAMS_IN_SCF_CU}    @{NRREL}    @{5GC000704}    @{5GC000732}
@{PARAMS_IN_SCF_DU1}    @{DU_NRREL}
@{PARAMS_IN_SCF_DU2}    @{DU_NRREL}

@{5GC000732}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=2000ms
...    NRBTS:tWaitingRlRecoverSA=4000ms
@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    MRBTS-1/NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gNodeBId=36
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-2:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    MRBTS-1/NRBTS-1/NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=35
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489|mncLength=3

@{DU_NRREL}
...    NRCELL/NRREL-1
...    NRCELL/NRREL-2
...    NRBTS-1/NRADJNRCELL-1

@{output}
...    rrcSetupComplete
...    PDU Session Reestablishment Request with PDU Session ID 1
...    rrcReconfigurationComplete
...    pcid:51
...    setup/reestablishment complete

@{outputB3_03}
...    sgnb_ue_x2ap_id IE will not be included
...    Successfully reconfigured dual connectivity
...    UE-X2AP-ID : 955

*** Test Cases ***
CB008926-SR-B-B2_ET_01_03_sgNB release with invalid MeNB X2AP ID and invalid SgNB X2AP ID can be handled correctly in AiC
    [Tags]
    NSA Attach setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    NSA Attach setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    ENDC Release UE
    Release Ues    ue_type=all
    Check WireShark Log Aic    ${CURDIR}${/}A2A_B-B2-03${/}a2a.ini    wait_string=UEContextReleaseCommand::4

CB008926-SR-B-B2_ET_01_04_PDU modification request with invalid AMF NGAP ID and valid RAN NGAP ID can be handled correctly in AiC
    [Tags]
    UE Register To GNB    ue_id=1
    UE Register To GNB    ue_id=2
    ${RAN_UE_NGAP_ID_UE1}    UE PDU Session Setup With Invalid AMFngap ID
    Set Test Variable    ${RAN_UE_NGAP_ID_UE1}    ${RAN_UE_NGAP_ID_UE1}
    Release Ues    ue_type=all
    Check WireShark Log Aic    ${CURDIR}${/}A2A_B-B2-04${/}a2a.ini    wait_string=UEContextReleaseCommand::10

CB008926-SR-B-B3_ET_01_03_SgNB release request without SgNB X2AP ID and with invalid MeNB X2AP ID in AiC
    [Tags]
    NSA Attach setup ENDC to TargetGnbCell    ue_id=32    target_gnbCell=1
    NSA Attach setup ENDC to TargetGnbCell    ue_id=31    target_gnbCell=1
    ENDC release
    Release Ues    ue_type=all

CB008926-SR-B-B1_ET_01_08_UE RRC reestablishment successful to different cell in same Gnb
    [Tags]
    Set UE Parameters Before Register
    UE Register and PDU Setup    enb_id=2    cell_id=1    ue_id=1
    Reestablishment same Gnb
    Release Ues    ue_type=all
    Check WireShark Log Aic    ${CURDIR}${/}A2A_B-B1-08-Aic${/}a2a.ini    wait_string=UEContextReleaseCommand::4

CB008926-SR-B-B1_ET_01_10_UE RRC Reestablishment to AiC from simGNB
    [Tags]
    Set UE Parameters Before Register
    Register UE    enb_id=3    cell_id=1    ue_id=1
    Reestablish simGnb to gnb cell1
    Release Ues    ue_type=all
    Check WireShark Log Aic    ${CURDIR}${/}A2A_B-B1-10${/}a2a.ini    wait_string=UEContextReleaseCommand::4

*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_qosflow id=2 5qi=5
    Update Cfg Aic    set_qosflow id=3 5qi=1
    Update Cfg Aic    ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
    Update Cfg Aic    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg Aic    set_amf_region id=1 tac_list=200,280,300,400,500,600,788 plmn=311:489,311:490,311:491
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3 sib1_period=3000
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.150 ng=10.0.11.12 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2=10.0.12.13:36422
    ...    x2_peers=none xn=10.0.12.14 nssai=0x1:0xd143a5 amf=1
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1,2 pdu=1 trf_type=internal
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1

set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

Reestablish simGnb to gnb cell1
    Execute Egate Command    ue_disp    pass_regexp=3.1
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=1    pass_regexp=setup/reestablishment complete
    Execute Egate Command    ue_disp    2.1

Register UE
    [Arguments]    ${enb_id}    ${cell_id}    ${ue_id}    ${gw_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

Reestablishment same Gnb
    Execute Egate Command    ue_disp    pass_regexp=2.1
    Execute Egate Command    ue_rrc_reestablish id=1 gnb=2 cell=2    pass_regexp=${output}
    Execute Egate Command    ue_disp    pass_regexp=2.2

UE Register and PDU Setup
    [Arguments]    ${enb_id}    ${cell_id}    ${ue_id}    ${gw_id}=1
    Register to Call Successfully    ${ue_id}    ${cell_id}    ${enb_id}
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

Register to Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}=1    ${enb_id}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trace_sim amf=1-2 on
    Execute Egate Command    ue_change_location id=1 enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE PDU Session Setup With Invalid AMFngap ID
    [Return]    ${RAN_UE_NGAP_ID_UE1[0]}
    Execute Egate Command    qosflow_modify default=on qos_flow=1 priority=5
    Execute Egate Command    smf_param id=1 reset
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    ${RAN_UE_NGAP_ID_UE1}    Get Regexp Matches    ${ret}    value RAN-UE-NGAP-ID : (\\d+)    1
    ${AMF_UE_NGAP_ID_UE1}    Get Regexp Matches    ${ret}    value AMF-UE-NGAP-ID : (\\d+)    1
    Run Keyword If    "${AMF_UE_NGAP_ID_UE1[0]}"!="25"    Execute Egate Command
    ...    amf_ue_pdu_modify_param id=1 ue=1 action=override_ie amf_ue_id=25 nth=1
    ...    ELSE    Execute Egate Command    amf_ue_pdu_modify_param id=1 ue=1 action=override_ie amf_ue_id=32 nth=1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf    pass_regexp=UE1: Received RRC Release

ENDC release
    ${ret}=    Execute Egate Command    enb_ue_dc_release ue=31 by=enb cause=RN_load_balancing exclude_sgnb_ue_x2ap_id=true menb_ue_x2ap_id=955
    ...    pass_regexp=${outputB3_03}
    Should Not Contain    ${ret}    Bearer-type change from SCG-split to MCG is successful
    Execute Egate Command    ue_disp

NSA Attach setup ENDC to TargetGnbCell
    [Arguments]    ${ue_id}    ${target_gnbCell}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ...    pass_regexp=SgNBAdditionRequestAcknowledge

ENDC Release UE
    Execute Egate Command    enb_ue_dc_release ue=31 by=enb cause=RN_user_inactivity menb_ue_x2ap_id=125 sgnb_ue_x2ap_id=125    dual connectivity

