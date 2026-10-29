*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-sherry.zhang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot



*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa
...    @{PARAMS_FOR_IODT_ABIO_2T4F}
...    @{same frequency}
...    @{NRREL}
...    @{CA_enable}
...    @{ho}
...    @{IRAT_config}
...    @{8311_enable}

@{NRREL}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=35
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRBTS:actIncXn=true
...    NRBTS:actConflictConfiguration=true
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=524310
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
#NRRELL for case08 cell2 and cell11
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:removeNotAllowed=false
...    NRCELL-2/NRREL-2:lcrId=11
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlOnly
#NRRELL for case15
...    NRCELL-2/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-2/NRRELE-1:eNodeBId=18
...    NRCELL-2/NRRELE-1:eutranCellExcluded=false
...    NRCELL-2/NRRELE-1:lcrId=1
...    NRCELL-2/NRRELE-1:removeNotAllowed=false
...    NRCELL-2/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-2/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-2/NRRELE-1:ecgiPlmn:mncLength=3

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20

@{CA_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actHoOptimizationCa=true
...    NRBTS-1:actRanSharing=false
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actBeamforming=false
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=20|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1

@{same frequency}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=524310
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=6549
...    MRBTS-1/NRBTS-1/NRCELL-1:type0CoresetConfigurationIndex=10
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwDl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    MRBTS-1/NRBTS-1/NRCELL-13:type0CoresetConfigurationIndex=7
...    MRBTS-1/NRBTS-1/NRCELL-13:gscnOrSsPbchArfcn=5300

@{ho}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=15min

#for A015
@{IRAT_config}
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1:actInterRatHoFromEutraToSA=true
...    NRBTS-1:nonContentRachAcFullConfigHo=true
...    NRBTS-1:tNgRelocExecDeltL=5000
...    NRCELL-2:measGapSelectionSA=favourUeThroughput
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1ThresholdhoSsbRsrpSA=30|a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2ThresholdhoSsbRsrpSA=20|a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL-2:actCDrx=true
...    NRCELL-2:dtxOptimizedScheduler:dtxDelaySinceLastScheduling=0
...    NRCELL-2:dtxOptimizedScheduler:dtxMaxRetentionDelay=10
...    NRCELL-2:dtxOptimizedScheduler:dtxPrbThreshold=80
...    NRCELL-2:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=18
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=0
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=11
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=3

@{OnlineParamChange_A008}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecoverSA=4000ms

@{OnlineParam_A008_recover}
...    NRBTS-1:rrcReestabTypeSA=deactivated

@{OnlineParamChange_A014}
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocCancelN =2000
...    NRCELL-1/NRREL-1:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-1/NRREL-2:handoverAllowedSA=XnHoNotAllowed

@{OnlineParam_A014_recover}
...    NRBTS-1:actIntraNrNgHo=disabled
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-2:handoverAllowedSA=allowed

@{OnlineParam_A015_recover}
...    NRBTS-1:actInterRatHoSA=false
...    NRBTS-1:actInterRatHoFromEutraToSA=false

@{InterHO_to_sim}
...    Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1

@{InterHO_from_sim}
...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1
...    physCellId 50
...    SCellIndex 1 activated successfully at airphone

${nwslice}    1

*** Test Cases ***
CB008311-ET-A003_2CC_TT_SA_Buffer_based_one_shot_SCell_Addition_after_each_initial_PDU_session_setup
    [Documentation]
    ...    1. This user scenario describes the successful Buffer-based one shot SCell Addition with blind SCell Addition
    ...      Method DL buffer monitoring activation after initial PDU session setup.It's about UE connects to the cell
    ...      without PDU session establishment during ICS. The gNB does not activate DL buffer monitoring until after
    ...      an initial PDU session with a non-GBR DRB is established.
    ...    2. Configuration:
    ...       cell1-cell2
    ...    3. Test Case Steps:
    ...       1). UE1 attaches to the TDD cell1, PDU session not established during the UE initial context setup.
    ...           CU performs prerequisite checks prior to activating DL buffer monitoring for SCell Addition and
    ...           succeed, CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring.
    ...       2). Then for UE1 setup a PDU session with a non-GBR DRB, High DL non-GBR data rate starts, DL buffer overflows
    ...           and cannot be drained by the serving cell.DU sends private unacknowledged F1AP message to
    ...           CU to inform CU of the DL buffer overflow condition.gNB configures TDD cell2 as scell to the UE1.
    ...       3). UE2 attaches to the same TDD cell1. PDU session with non-GBR DRB is established during the UE initial
    ...           context setup.Low DL non-GBR data rate start to the UE2. NO scell be added for UE2.
    ...       4). For UE2 release PDU and thus the last non-GBR DRB is released and wait for a few seconds, setup a new
    ...           PDU with non-GBR DRB.
    ...       5). High DL non-GBR data starts for the new PDU on UE2, thus the DL buffer overflows and cannot be drained
    ...           by serving cell,DU sends private unacknowledged F1AP message to CU to inform CU DL buffer overflow
    ...           condition. DU stops DL data buffer monitoring. gNB configures TDD Cell2 as scell to the UE2.
    ...           Non-GBR data transfer is on the PCell cell1 and SCell cell2.
    [Tags]    QC_279036    owner-sherry.zhang    A003    CA_LABEL-TT(60MHz_TDD_n41+50MHz_TDD_n78)
    Set ICS without PDU    send_ics_registration=on
    UE Attach To Target Cell
    Send high Throuput
    Verify Throuput on Pcell and Scell    ue_id=81
    Set ICS without PDU    send_ics_registration=off
    UE Attach To Target Cell    ue_id=82
    Send low Throuput    ue_id=82
    Verify no Scell add    ue_id=82
    Release one PDU    ue_id=82
    Setup one PDU    ue_id=82
    Send high Throuput    ue_id=82
    Verify Throuput on Pcell and Scell    ue_id=82
    UE Deregister From gNB    ue_id=82
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311A003${/}a2a.ini    wait_string=UEContextReleaseComplete::3
    [Teardown]    A003_Teardown

CB008311-ET-A008_2CC_TF_SA_Connection_reestablishment_via_RRC_Reestablishment_message
    [Documentation]
    ...    1. This user scenario describes the successful Buffer-based one shot SCell Addition with blind SCell Addition
    ...      Method after connection reestablishment via RRC Reestablishment message in SA mode.
    ...    2. Configuration:
    ...       cell2-cell11
    ...    3. Test Case Steps:
    ...       1). UE1 attaches to the TDD cell2, PDU session established during the UE initial context setup.
    ...           CU performs prerequisite checks prior to activating DL buffer monitoring for SCell Addition and
    ...           succeed, CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring.
    ...       2). High DL non-GBR data rate starts on PDU UE1, DL buffer overflows and cannot be drained by the serving
    ...           cell. DU sends private unacknowledged F1AP message to CU to inform CU of the DL buffer overflow condition.
    ...           gNB configures FDD cell11 as scell to the UE2.
    ...       3). Trigger connection reestablishment via RRC Reestablishment by egate command.
    ...       4). After receipt of an RRC reestablishment Request from UE1, gnb activate DL buffer monitoring, DU sends
    ...           private unacknowledged F1AP message to CU to inform CU DL buffer overflow condition. DU stops DL data
    ...           buffer monitoring. gNB configures FDD Cell11 as scell.
    ...           Non-GBR data transfer is on the PCell cell2 and SCell cell11.
    [Tags]    QC_279030     owner-sherry.zhang    A008    CA_LABEL-TF(50MHz_TDD_n78+10MHz_FDD_n66)
    OnlineParamChange    ${OnlineParamChange_A008}
    UE Attach To Target Cell    cell_id=2
    Send high Throuput
    Verify Throuput on Pcell and Scell
    Trigger reestablishment via RRC RE
    Verify Throuput on Pcell and Scell
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311A008${/}a2a.ini    wait_string=UEContextReleaseComplete::3
    [Teardown]    A008_Teardown

CB008311-ET-A014_2CC_TT_SA_Intra_NR_handover_via_NG
    [Documentation]
    ...    1. This user scenario describes the successful one-shot scell addition via incoming NG handover triggered by
    ...       dl data buffer criterion during blind scell addition method in SA mode.
    ...    2. Configuration:
    ...       NRADJGNB/NRADJNRCELL have some Frequency with NRCELL-1.
    ...       cell1-cell2
    ...    3. Test Case Steps:
    ...       1). UE1 registers successfully and PDU session with non-GBR DRB is setup successfully on cell1,
    ...           CU performs prerequisite checks prior to activating DL buffer monitoring for SCell Addition and
    ...           succeed, CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring.
    ...       2). High DL non-GBR data rate starts on PDU UE1, DL buffer overflows and cannot be drained by the serving cell.
    ...           DU sends private unacknowledged F1AP message to CU to inform CU of the DL buffer overflow condition.
    ...           gNB configures TDD cell2 as scell to the UE1.
    ...       3). A3 for mobility measurement report from UE1.
    ...           inter gnb intra frequency handover through ng to sim gnb NRADJNRCELL-1 successfully.
    ...       4). A3 for mobility measurement report from UE1.
    ...           inter gnb intra frequency handover through ng from sim gnb NRADJNRCELL-1 to cell1 successfully.
    ...           cell2 added as scell.
    [Tags]    QC_279026    owner-sherry.zhang    A014    CA_LABEL-TT(60MHz_TDD_n41+50MHz_TDD_n78)
    OnlineParamChange    ${OnlineParamChange_A014}
    Set UE Parameters Before Register    send_xn_setup=false    ho_type=ng_based
    UE Attach To Target Cell
    Send high Throuput
    Verify Throuput on Pcell and Scell
    trigger A3 intra ferquency inter gnb ho to sim gnb
    trigger A3 intra ferquency inter gnb ho to real gnb
    Verify Throuput on Pcell and Scell
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311A014${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    [Teardown]    A014_Teardown

CB008311-ET-A015_2CC_TF_SA_Buffer_based_one_shot_SCell_Addition_interaction_with_Inter_RAT_HO
    [Documentation]
    ...    1. This user scenario describes the gNB behaviour for an incoming Handover from LTE connected to EPC with
    ...       blind SCell addition method and Buffer-based one shot SCell Addition activated. After handover completion
    ...       the gNB activates DL buffer monitoring for SCell Addition.
    ...    2. Configuration:
    ...       cell2-cell11
    ...    3. Test Case Steps:
    ...       1). UE1 registers successfully and PDU session with non-GBR DRB is setup successfully on cell2,
    ...           CU performs prerequisite checks prior to activating DL buffer monitoring for SCell Addition and
    ...           succeed, CU sends a private unacknowledged F1AP message to DU to activate DL data buffer monitoring.
    ...       2). High DL non-GBR data rate starts on PDU UE1, DL buffer overflows and cannot be drained by the serving cell.
    ...           DU sends private unacknowledged F1AP message to CU to inform CU of the DL buffer overflow condition.
    ...           gNB configures FDD cell11 as scell to the UE1.
    ...       3). Trigger UE NR IRAT HO to LTE, when B2 was already configured to UE1.
    ...       4). Make UE IRAT HO from LTE to NR, gnb activate DL buffer monitoring, DU sends private unacknowledged F1AP
    ...           message to CU to inform CU DL buffer overflow condition. DU stops DL data buffer monitoring.
    ...           gNB configures FDD Cell11 as scell.
    ...           Non-GBR data transfer is on the PCell cell2 and SCell cell11.
    [Tags]    QC_47051    owner-sherry.zhang    A015    CA_LABEL-TF(50MHz_TDD_n78+10MHz_FDD_n66)
    UE Attach To Target Cell    cell_id=2    ue_id=83
    Send high Throuput    ue_id=83
    Verify Throuput on Pcell and Scell    ue_id=83
    Trigger A2 MR    ue_id=83
    Trigger B2 inter rat ho to LTE    ue_id=83
    Trigger HO back from LTE    ue_id=83
    Verify Throuput on Pcell and Scell    ue_id=83
    UE Deregister From gNB    ue_id=83
    Check Wireshark Log    ${CURDIR}${/}a2a_CB008311A015${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    [Teardown]    A015_Teardown

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Modify Cfg
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=524310:524310 gscn=6549 mandatory_for_activation=off
    Update Cfg    ${gnb3_cell1}
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true

A003_Teardown
    Set ICS without PDU    send_ics_registration=off
    Common Test Teardown And Stop Capture Logs

A008_Teardown
    OnlineParamChange    ${OnlineParam_A008_recover}
    Common Test Teardown And Stop Capture Logs

A014_Teardown
    OnlineParamChange    ${OnlineParam_A014_recover}
    Common Test Teardown And Stop Capture Logs

A015_Teardown
    OnlineParamChange    ${OnlineParam_A015_recover}
    Common Test Teardown And Stop Capture Logs

Trigger reestablishment via RRC RE
    [Arguments]    ${ue_id}=81    ${cell_id}=2
    ${cmd}=    Set Variable    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id} cause=reconfigurationFailure
    Execute Egate Command    ${cmd}    pass_regexp=RRC Reestablishment sucessfully completed

Set ICS without PDU
    [Arguments]    ${send_ics_registration}=off
    Execute Egate Command    amf_param id=1 send_ics_registration=${send_ics_registration}

Setup one PDU
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${gw_id}=1
    ${cmd}=    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${pdu_id}
    Execute Egate Command    ${cmd}    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created

Release one PDU
    [Arguments]    ${ue_id}=82    ${pdu_id}=1
    ${cmd}=    Set Variable    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    Execute Egate Command    ${cmd}    pass_regexp=Successfully released PDU Session

Set UE Parameters Before Register
    [Arguments]    ${send_xn_setup}=true    ${ho_type}=xn_based
    Execute Egate Command    ue_history_information_list id=1 action=reset
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=${send_xn_setup} sa_ho=${ho_type}

UE Attach To Target Cell
    [Arguments]    ${cell_id}=1    ${ue_id}=81    ${pdu_id}=1    ${gw_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Setup one PDU    ue_id=${ue_id}

Send low Throuput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=50 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Send high Throuput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=175 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=1    UE ${ue_id}: UDP UL
    sleep    30s    #sleep for stable traffic

Verify Throuput on Pcell and Scell
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=5    ${scell_id}=1
    sleep    10s     #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify no Scell add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

trigger A3 intra ferquency inter gnb ho to sim gnb
    [Arguments]    ${event_type}=A3    ${carrierfreq}=523950    ${srsrp_nr}=11    ${srsrq_nr}=11    ${ue_id}=81
    ...    ${phycell_id}=381    ${nrsrp_nr}=61    ${nrsrq_nr}=61
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${InterHO_to_sim}

trigger A3 intra ferquency inter gnb ho to real gnb
    [Arguments]    ${event_type}=A3    ${carrierfreq}=523950    ${srsrp_nr}=11    ${srsrq_nr}=11    ${ue_id}=81
    ...    ${phycell_id}=50    ${nrsrp_nr}=71    ${nrsrq_nr}=71
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=${srsrp_nr}
    ...    srsrq_nr=${srsrq_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${InterHO_from_sim}

Trigger A2 MR
    [Arguments]    ${event_type}=A2    ${carrierfreq}=633216    ${ue_id}=81
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=rrcReconfigurationComplete

Trigger B2 inter rat ho to LTE
    [Arguments]    ${event_type}=B2    ${carrierfreq}=1    ${ue_id}=81
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=1    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete
    sleep    20s    reason=wait timer

Trigger HO back from LTE
    [Arguments]    ${ue_id}=81
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=2 plmn=311:489
    ...    pass_regexp=ENB-5.1 to EXT_ENB-2.2
    sleep    100s    reason=wait timer

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s
