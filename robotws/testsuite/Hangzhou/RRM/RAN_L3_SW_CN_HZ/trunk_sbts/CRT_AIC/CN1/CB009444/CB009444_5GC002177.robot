*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_Aic    master_vDU    CRT    CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    owner-keyun.ma    release-5G22R4    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${NSA_UE_ID}    31
@{PARAMS_IN_SCF_CU}    @{5GC002177CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC002177DU_full}


@{5GC002177CU_full}
...    NRBTS:actA2SgnbRelease=true
...    @{IntraFreqIntraGnb}
...    @{nea}
...    @{a2MeasRelease}


@{IntraFreqIntraGnb}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS/NRCELL-1:chBw=100MHz
...    NRBTS/NRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-1:nrarfcn=636666
...    NRBTS/NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS/NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRBTS/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS/NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3


@{nea}
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0

@{a2MeasRelease}
...    NRCELL:a2MeasReleaseEnabled=rsrp
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=75
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms0
...    NRCELL:a2MeasReleaseSsbRsrq:a2HysteresisReleaseSsbRsrq=0
...    NRCELL:a2MeasReleaseSsbRsrq:a2ThresholdReleaseSsbRsrq=75
...    NRCELL:a2MeasReleaseSsbRsrq:a2TimeToTriggerReleaseSsbRsrq=ms0


@{5GC002177DU_full}
...    @{rsrp_du}
...    @{NRREL_du}
...    @{IntraFreq}

@{rsrp_du}
...    NRBTS/NRCELL:rsrpThresholdSSB=11

@{NRREL_du}
...    NRBTS/NRCELL/NRREL-1

@{IntraFreq}
...    NRBTS/NRCELL-1:chBw=100MHz
...    NRBTS/NRCELL-1:freqBandIndicatorNR=78
...    NRBTS/NRCELL-1:nrarfcn=636666
...    NRBTS/NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRBTS/NRCELL-2:chBw=100MHz
...    NRBTS/NRCELL-2:freqBandIndicatorNR=78
...    NRBTS/NRCELL-2:nrarfcn=636666
...    NRBTS/NRCELL-2:gscnOrSsPbchArfcn=7880

###counter on CU
###2177 counter
${X2_SGNB_REL_REQUIRED_SENT_A2}    M55112C05001
${X2_SGNB_REL_CONF_RECEIVE_A2}    M55112C05002
${X2_SGNB_REL_REQUIRED_SENT}    M55112C00007
${X2_SGNB_REL_CONF_RECEIVED}    M55112C00008

@{PM_Counters_Check_CU}
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVE_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVED}=1

*** Test Cases ***
CB009444-ET_5GC002177_Verify_Cloud_NSA_TDD_cmWave_SgNB_release_due_to_A2_event_with_RSRP_SRB3_is_successful
    [Documentation]    This Test case is to verify sgnb release due to A2 event via SRB3
    ...    pre-condition:
    ...    srb3SupportEnabled:true, actA2SgnbRelease:true, a2MeasReleaseEnabled:rsrp
    ...    a2HysteresisReleaseSsbRsrp:0, a2ThresholdReleaseSsbRsrp:75, a2TimeToTriggerReleaseSsbRsrp:ms0
    ...    check msg:
    ...    check srb3 in msg SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ...    check A2 measurement configuration in msg SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ...    check A2 measurement report
    ...    check release cause "action-desirable-for-radio-reasons" in msg SgNBReleaseRequired
    ...    check msg SgNBReleaseConfirm
    ...    check counter:
    ...    M55112C05001(X2_SGNB_REL_REQUIRED_SENT_A2), M55112C05002(X2_SGNB_REL_CONF_RECEIVE_A2),
    ...    M55112C00007(X2_SGNB_REL_REQUIRED_SENT), M55112C00008(X2_SGNB_REL_CONF_RECEIVED)
    [Tags]    QC_276101
    Clear Counter Files
    NSA UE Attach and Traffic
    SgNB Release Due To A2 Event Via SRB3
    Check Counters
    Check WireShark Log Aic    ${CURDIR}/a2a_2177/a2a.ini    wait_string=BearerContextReleaseComplete
    Release Ues    ue_type=nsa    ue_id=${NSA_UE_ID}

*** Keywords ***
SgNB Release Due To A2 Event Via SRB3
    ${meas_id_a2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${NSA_UE_ID}    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${NSA_UE_ID} meas_id=${meas_id_a2} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful

Modify Cfg Aic
    Update Cfg Aic    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12229 earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    ${V_1}    catenate    set_cell id=1 gnb=2 pci=16:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${V_2}    catenate    set_cell id=2 gnb=2 pci=17:0 tac=280 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${V_1}
    Update Cfg Aic    ${V_2}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA
    Send Throuput    ue_id=${ue_id}
    Verify Throuput Should Be OK

Send Throuput
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    UE ${ue_id}: UDP UL

Verify Throuput Should Be OK
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.6
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.6

