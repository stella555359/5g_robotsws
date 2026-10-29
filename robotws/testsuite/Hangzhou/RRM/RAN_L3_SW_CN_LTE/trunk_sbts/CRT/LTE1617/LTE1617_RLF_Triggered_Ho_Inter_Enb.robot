*** Settings ***
Documentation     Inter-eNB reestablishment to an unprepared cell is not possible due to an ongoing RRC reconfiguration procedure on serving eNB.
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    team-DevHZ5_SG4
...               owner-xu.wang    release-RL70/RL55TD
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    delete:LNADJ.*
...    delete:LNREL.*
...    delete:LNCEL:defaultLnRelGnbCellId
...    LNBTS-1:actRLFbasedRCR=true
...    LNBTS-1:rlfBasedRCRdefault=true
...    LNBTS-1:tS1RelPrepL=2000
...    LNCEL:t301Guard=1000
...    LNADJ-1:adjEnbId=2
...    LNADJ-1:cPlaneIpAddr=10.0.1.4
...    LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNADJ-1:rlfBasedRCRsupported=true
...    LNCEL-1/LNREL-1:amleAllowed=false
...    LNCEL-1/LNREL-1:cellIndOffNeigh=0dB
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiLcrId=1
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:nrControl=automatic
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1:a3Offset=6
...    LNCEL-1:threshold2InterFreq=40
...    LNCEL-1:threshold2Wcdma=35
...    LNCEL-1:threshold2GERAN=33
@{PARAMS_IN_SCF_ENB2}
...    delete:LNADJ.*
...    delete:LNREL.*
...    delete:LNCEL:defaultLnRelGnbCellId
...    LNBTS-2:actRLFbasedRCR=true
...    LNBTS-2:rlfBasedRCRdefault=true
...    LNCEL-1/SIB-0:t301=2000ms
...    LNCEL:t301Guard=1000
${enb1_cell1_ECGI}    0b0000000000000000000100000001
${enb2_cell1_ECGI}    0b0000000000000000001000110011
${enb2_cell2_ECGI}    0b0000000000000000001000110100

*** Test Cases ***
I_LTE1617_006_2_Inter_X2 Handover
    [Documentation]    | LTE1617 Inter-eNB re-establishtment, intra-eNB, inter-eNB ongoing handover |
    ...    Successful inter-eNB reestablishment to an unprepared cell is executed when an ongoing inter-eNB X2 handover is taking place.
    [Tags]    I_LTE1617_006_2
    Trigger re-establishment during inter enb handover

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Create UE Alias     UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=10.0.1.2    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Perform Steps After Onair
    Object Should Exist    LNADJ-1:x2LinkStatus=available

Trigger re-establishment during inter enb handover
    ${ho_request_to_enb2cell2}    catenate
    ...    Cause contains (
    ...    radioNetwork eq 'handover-desirable-for-radio-reasons'
    ...    )
    ...    and
    ...    ECGI contains (
    ...    eUTRANcellIdentifier eq '${enb2_cell2_ECGI}'
    ...    )
    ...    and
    ...    UE-HistoryInformation contains (
    ...    e-UTRAN-Cell contains (global-Cell-ID contains (eUTRANcellIdentifier eq '${enb1_cell1_ECGI}'))
    ...    )
    ${RLF}    catenate
    ...    PCI eq 1
    ...    and
    ...    eUTRANcellIdentifier eq '${enb2_cell1_ECGI}'
    ...    and
    ...    RRCConnReestabIndicator eq 'handoverFailure'
    ${ho_request_to_enb2cell1}    catenate
    ...    Cause contains (
    ...    radioNetwork eq 'time-critical-handover'
    ...    )
    ...    and
    ...    ECGI contains (
    ...    eUTRANcellIdentifier eq '${enb2_cell1_ECGI}'
    ...    )
    ...    and
    ...    UE-HistoryInformation contains (
    ...    e-UTRAN-Cell contains (global-Cell-ID contains (eUTRANcellIdentifier eq '${enb1_cell1_ECGI}'))
    ...    )
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (${ho_request_to_enb2cell2})
    #enb1 receive HO ACK from enb2
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 52))
    ...    UE_1:RRC_RRCConnectionReconfiguration (mobilityControlInfo contains (targetPhysCellId eq 52))
    #UE send re-estab req to enb2cell1
    ...    UE_1:RRC_RRCConnectionReestablishmentRequest (physCellId eq 1 and reestablishmentCause eq 'handoverFailure')
    #enb1 receive RLF indication from enb2
    ...    ENB_1:X2AP_RLFIndication (${RLF})
    ...    ENB_1:X2AP_HandoverCancel
    ...    ENB_1:X2AP_HandoverRequest (${ho_request_to_enb2cell1})
    #enb1 receive HO ACK from enb2
    ...    ENB_1:X2AP_HandoverRequestAcknowledge (HandoverCommand contains (targetPhysCellId eq 51))
    ...    ENB_1:X2AP_SNStatusTransfer
    #UE re-estab to enb2cell1 complete
    ...    UE_1:RRC_RRCConnectionReestablishment
    ...    UE_1:RRC_RRCConnectionReestablishmentComplete
    #enb1 receive UEContextRelease from enb2
    ...    ENB_1:X2AP_UEContextRelease
    ...    alias=RLF_Triggered_Ho_flow    overall_timeout=20
    Execute UEx Command    ue_rrc_reconf_param id=1 if_contains=mobilityControlInfo action=reestablish cell=51 nth=1 cause=handoverFailure
    Execute UEx Command    ue_attach id=1 selected_plmn=262:02 cell=1
    Execute UEx Command    ue_measurement_send id=1 event=A3 nrsrp=75 srsrp=65 nrsrq=20 srsrq=20 phycell_id=52
    Flow Occurred As Expected    alias=RLF_Triggered_Ho_flow
