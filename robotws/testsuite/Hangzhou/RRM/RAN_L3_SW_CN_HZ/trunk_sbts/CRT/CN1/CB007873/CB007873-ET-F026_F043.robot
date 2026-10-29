*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{Common_Config}    @{CELL12_Config}    @{cell1_Config}
@{Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRBTS:actIntraMeNBMobility=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:configuredEpsTac=200
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{cell1_Config}
...    NRCELL-1:chBw=60MHz
...    NRCELL-1:nrarfcn=518580
...    NRCELL-1:freqBandIndicatorNR=41
...    NRCELL-1:gscnOrSsPbchArfcn=6486

...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed

@{CELL12_Config}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1586

...    NRCELL-12:rsrpThresholdSSB=11
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:filterCoeffSsbRsrp=fc4
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed

@{PM_Counters_Check_F026}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=3
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=3
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000

${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

*** Test Cases ***
CB007873-5G-ET-F026_Verify_NSA_A3_rsrp_IntraMeNB_HO_failed_with_UE_bandcombination_not_support_from_CA_to_CA
    [Documentation]    This case will test scell is not added when use Non-CA allowedBC List.
    ...    precondition : IntraMeNB mobility
    ...    Case steps:
    ...    1.CA(F+T pscell is cell 12) and CA(F+T scell is cell 1)setup:scell added,drx setup without SRB3
    ...    2.Update allowedBC list to 1:1 which is supported CA.
    ...    3.IntraMeNB HO without SCGchange: enb1 cell 1 to enb1 cell 2;
    ...    4.Update allowedBC list to 2:1 which is not supported CA.
    ...    5.IntraMeNB HO without SCGchange: key fresh in MeNB cell1;check no scell add
    [Tags]    QC_97168    F026
    Clear Counter files    False
    Ue Attach and Initial ENDC
    Intra MeNB HO from MeNB1 cell1 to MeNB1 cell-2 with Update allowedBC list
    Intra MeNB Intra cell HO
    Release Ues    ue_type=all
    Check Counters    ${PM_Counters_Check_F026}
    Check wireshark log    ${CURDIR}${/}a2a_F026${/}a2a_wireshark.ini


CB007873-5G-ET-F043_Verify_intraMeNB_interfreq_handover_without_sgnb_change
    [Documentation]    This case will test IntraMeNB interfreq HO
    ...    Case steps:
    ...    1.CA(F+T pscell is cell 12) and CA(F+T scell is cell 1)setup:scell added,drx setup without SRB3
    ...    2.do intraMeNB interfreq HO without sgnb change from ENB1 cell1 to ENB1 cell2
    ...    3.do intraMeNB interfreq HO back without sgnb change from ENB1 cell2 to ENB1 cell1
    [Tags]    QC_89206    F043
    Ue Attach and Initial ENDC
    Intra MeNB HO from MeNB1 cell1 to MeNB1 cell-2
    Intra MeNB HO from MeNB1 cell2 to MeNB1 cell-1
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F043${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=${TL_TYPE_PATH}

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V3}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:1 tac=222 proxy=$CONTAINER_IP:12220|$CONTAINER_IP:8890 earfcn=2200:20200
    ...    mandatory_for_activation=off
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200

Ue Attach and Initial ENDC
    UE attach
    Initial ENDC
    Send And Verify Throuput

UE attach
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on

Initial ENDC
    [Arguments]    ${ue_id}=91    ${target_cells}=12
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity

Send And Verify Throuput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UDP UL
    Verify Throuput

Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000>0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

Intra MeNB HO from MeNB1 cell1 to MeNB1 cell-2
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=2
    ...    SgNBModificationRequestAcknowledge
    Execute Egate Command
    ...    enb_ue_dc_modify ue=91 by=enb cause=RN_action_desirable_for_radio_reasons
    ...    SgNBModificationRequestAcknowledge
    Verify Throuput
Intra MeNB HO from MeNB1 cell2 to MeNB1 cell-1
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=1
    ...    SgNBModificationRequestAcknowledge
    Execute Egate Command
    ...    enb_ue_dc_modify ue=91 by=enb cause=RN_action_desirable_for_radio_reasons
    ...    SgNBModificationRequestAcknowledge
    Verify Throuput

Intra MeNB HO from MeNB1 cell1 to MeNB1 cell-2 with Update allowedBC list
    Start RRC Log    IntraMeNB_InterCell_HO
    Execute Egate Command
    ...    ue_ho id=91 ho_mode=INTRA_LTE enb=1 cell=2
    ...    SgNBModificationRequestAcknowledge
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1
    rrc should contain    Intra-eNB handover from ENB-1.1 to ENB-1.2 performed
    rrc should contain    SCellIndex 9 activated successfully at airphone
    rrc should contain    Successfully reconfigured dual connectivity
    Verify Throuput

Intra MeNB Intra cell HO
    Start RRC Log    IntraMeNB_IntraCell_HO
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=2:1
    Execute Egate Command    ue_reauth id=91    SgNBModificationConfirm
    rrc should contain    Intra-cell handover (key refresh) performed at ENB-1.2
    rrc should contain    Successfully reconfigured dual connectivity
    rrc should not contain    SCellIndex 9
    non-CA UE Verify Throuput
    Execute Egate Command    enb_endc_param id=1 allowed_bc_list_mrdc=1:1|2:1|3:1|4:1

non-CA UE Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90


