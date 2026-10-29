*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               owner-Xianjiao.Xie    release-5G20A    team-SG2
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{MFBI_Config}
...    @{Mobility_NRHOIF}
...    NRBTS-1:actHigherPrioFreqHo=SA
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633364
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1:tmpActFeat1=1
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:cipherPrefL:nea0=1
...    MRBTS-1/NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a5MeasEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=40
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=30
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=4000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=10
...    NRCELL:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    NRCELL:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    NRCELL:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
@{Mobility_NRHOIF}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408       #nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=633216
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
@{MFBI_Config}
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    delete:MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList
@{PARAMS_TO_MODIFY_706_C_TC05}
...    MRBTS-1/NRBTS-1/NRCELL-2:dlPtrs:actDlPtrs=false
...    MRBTS-1/NRBTS-1/NRCELL-2:dlPtrs:dlPtrsFreqDensityThresNrb0=278
...    MRBTS-1/NRBTS-1/NRCELL-2:dlPtrs:dlPtrsFreqDensityThresNrb1=24
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPtrs:actUlPtrs=false
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPtrs:ulPtrsFreqDensityThresNrb0=278
...    MRBTS-1/NRBTS-1/NRCELL-2:ulPtrs:ulPtrsFreqDensityThresNrb1=24
@{PARAMS_TO_MODIFY_706_J_TC03}
...    MRBTS-1/NRBTS-1/NRCELL-2:maxNumOfRrcSA=0
${ue_sa_capabilities}    SEPARATOR=
...      E1A00000074E5A031E000381A00F04983200021E0A018806804C020301C002A36266B04050D012CB2898183D6C10101070EF1C3
...      9061C00103278FAB80027800E0009E0000841C4C000000006026C04C07007008089EC260060005038280381803C01C001A0F800
...      0000000000395340004000025965400D2AAA0A01C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1
...      280
@{pm_couter_J003}
...    NRCELL-1:${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}==1
${FAI_IF_INTRA_DU_HOP_AC_SA_PLMN}    M55145C00323

*** Test Cases ***
5GC000706_ET_C002_Verify_A3_Inter-frequency_Intra-gNB_handover_With_Different_Source_and_Target_BW_but_Same_FR1_Band_Without_DRX
    [Tags]    QC_81792    owner-xianjiao.xie   F089    C002
    UE register and setup PDU session    ue_id=1    pdu_id=1
    UE intra-gNB inter-freq Handover    ID=1    target_cell=2    source_cell=1    A2_id=1    A3_id=5    pci=51
    UE intra-gNB inter-freq Handover    ID=1   target_cell=1    source_cell=2    A2_id=7    A3_id=11    pci=50
    release ues    ue_type=all

5GC000706_ET_C005_Verify_Inter-freq_Inter-gNB_handover_based_on_A3_with_source_has_phaseTrackingRS_config_but_target_set_phaseTrackingRS_to_none
    [Tags]    QC_81793    owner-xianjiao.xie   F089    C005
    OnlineParamChange    ${PARAMS_TO_MODIFY_706_C_TC05}
    UE register and setup PDU session    ue_id=2    pdu_id=1
    UE intra-gNB inter-freq Handover    ID=2    target_cell=2    source_cell=1    A2_id=1    A3_id=5    pci=51
    UE intra-gNB inter-freq Handover    ID=2    target_cell=1    source_cell=2    A2_id=7    A3_id=11   pci=50
    release ues    ue_type=all

5GC000706-ET-J003_Verify counter in unsuccessful Intra-DU Intra-gNB handover due to AC failure -target 2 cells all in blacklist
    [Tags]    QC_61692    owner-xianjiao.xie   F089    J003
    OnlineParamChange    ${PARAMS_TO_MODIFY_706_J_TC03}
    CLEAR COUNTER FILES
    UE register and setup PDU session    ue_id=3    pdu_id=1
    trigger A2 event    ue_id=3  meas_id=1
    trigger A3 event fail    ue_id=3   meas_id=5    phycell_id=51
    Check counters    ${pm_couter_J003}
    release ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Comment    Debug Enter Into Egate

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be OnAir

UE intra-gNB inter-freq Handover
    [Arguments]    ${ID}    ${target_cell}    ${source_cell}    ${A2_id}    ${A3_id}    ${pci}
    trigger A2 event    ue_id=${ID}    meas_id=${A2_id}
    trigger A3 event    ue_id=${ID}    meas_id=${A3_id}    phycell_id=${pci}    sourcecell_id=${source_cell}    targetcell_id=${target_cell}


UE register and setup PDU session
    [Arguments]   ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command     ue_register id=${ue_id} ue_nr_capabilities=${ue_sa_capabilities}    UE performed Registration
    Execute Egate Command     ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${pdu_id}
    ...    pass_regexp=Initial Context Setup Successful

trigger A2 event
    [Arguments]    ${ue_id}    ${meas_id}=1
    ${ret1}=    Execute Egate Command     ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    measurementReport
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measIdToRemoveList{${meas_id}}
    Should Contain    ${ret1}    eventIdeventA1
    Should Contain    ${ret1}    eventIdeventA3
    Should Contain    ${ret1}    eventIdeventA5
    Should not Contain    ${ret1}    eventIdeventA2

trigger A3 event
    [Arguments]    ${ue_id}    ${meas_id}=5    ${phycell_id}=51    ${sourcecell_id}=1    ${targetcell_id}=2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.${sourcecell_id} to EXT_ENB-2.${targetcell_id} performed
    Should Contain    ${ret1}    measConfig
    Should Contain    ${ret1}    measObjectToAddModList
    Should Contain    ${ret1}    measObject measObjectNR
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    physCellId ${phycell_id}

trigger A3 event fail
    [Arguments]    ${ue_id}    ${meas_id}=5    ${phycell_id}=51
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=20 srsrq_nr=20 phycell_id=${phycell_id} nrsrp_nr=61 nrsrq_nr=61
    ...    pass_regexp=measurementReport
    Should not Contain    ${ret1}    Intra-eNB handover