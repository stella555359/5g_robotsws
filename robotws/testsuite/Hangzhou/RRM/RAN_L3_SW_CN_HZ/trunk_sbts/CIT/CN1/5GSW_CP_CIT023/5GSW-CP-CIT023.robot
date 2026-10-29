*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CDRT
...    release-5G21A    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMW    team-DevHZ5_SG2
...    owner-junhui.he    5GC00706
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    delete:MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList
...    MRBTS-1/NRBTS-1:tmpActFeat1=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1:cipherPrefL:nea3_128=0
...    MRBTS-1/NRBTS-1:cipherPrefL:nea0=1
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=636576
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:chBw=80MHz
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

@{PM_Counters_Check}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=2
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1
...    NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=1

${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322

*** Test Cases ***
5GSW-CP-CIT023_Verify_Classical_SA_TDD_cmWave_inter_frequency_intra-gNB_HO_with_A5_RSRP_CBRA_is_successful
    [Documentation]    This case was designed to verify:
    ...    1. inter-frequency intra-gNB HO with A5 RSRP CBRA successfully.
    ...    2. Related Counter during HO: ATT_IF_GNB_INTRA_DU_HO_SLICE, SUCC_IF_GNB_INTRA_DU_HO_SLICE,
    ...    ATT_IF_INTRA_DU_HO_SA_PLMN and SUCC_IF_INTRA_DU_HO_SA_PLMN.
    [Tags]    QC_81271
	Clear Counter files
	Start To Capture Wireshark Log    CIT023
    register ue with ue_cap
    Trigger Handover and Check Traffic	
	Check Counters    ${PM_Counters_Check}
    check wireshark log    ${CURDIR}/a2a/a2a.ini    name=CIT023    wait_string=UEContextReleaseComplete::4
		
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${AutoVariable_1}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=0 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${AutoVariable_1}
  
register ue with ue_cap
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    ${ue_capa}=    Catenate    SEPARATOR=    E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012C
    ...    B2898183D6C10101070EF1C39061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC2600600050
    ...    38280381803C01C001A0F8000000000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C
    ...    202C4044484C648494989CA1280
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${ue_capa}
    SA UE1 register
	Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    Initial Context Setup Successful
		
SA UE1 register
    Execute Egate Command    ue_register id=1    NG RM Registered

Trigger Handover and Check Traffic
    UE Handover    target_cell=2    source_cell=1    A2_id=1    A5_id=6    pci=51
    sleep    5s    reason=wait related output to be finished
    UE Handover    target_cell=1    source_cell=2    A2_id=7    A5_id=12    pci=50
    sleep    5s    reason=wait related output to be finished
    traffic should be ok    ue_id=1    pdu=1    type=SA

UE Handover
    [Arguments]    ${target_cell}    ${source_cell}    ${A2_id}    ${A5_id}    ${pci}
    trigger A2 event    meas_id=${A2_id}
    trigger A5 event    meas_id=${A5_id}    phycell_id=${pci}    sourcecell_id=${source_cell}    targetcell_id=${target_cell}

trigger A2 event
    [Arguments]    ${meas_id}=1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    rcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measIdToRemoveList{${meas_id}}
    Should Contain    ${ret1}    eventIdeventA1
    Should Contain    ${ret1}    eventIdeventA3
    Should Contain    ${ret1}    eventIdeventA5
    Should not Contain    ${ret1}    eventIdeventA2

trigger A5 event
    [Arguments]    ${meas_id}=6    ${phycell_id}=51    ${sourcecell_id}=1    ${targetcell_id}=2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A5 srsrp_nr=10 srsrq_nr=10 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    Intra-eNB handover from EXT_ENB-2.${sourcecell_id} to EXT_ENB-2.${targetcell_id} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    physCellId ${phycell_id}
    Should Contain    ${ret1}    CBRA
    Should Not Contain    ${ret1}    cfra
