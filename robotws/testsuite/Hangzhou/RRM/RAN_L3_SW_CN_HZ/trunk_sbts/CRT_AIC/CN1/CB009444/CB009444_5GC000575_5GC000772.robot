*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_Aic    master_vDU    CRT
...    owner-jianfen.shen    release-5G23R3    team-DevHZ5_SG02    vDUCNF00    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F
${NSA_UE_ID}    31
@{PARAMS_IN_SCF_CU}    @{5GC000575CU_full}    @{5GC000772CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC000575DU_full}    @{5GC000772DU_full}
@{DELTA_PARAMS_IN_SCF_CU}    @{5GC000772CU_delta}
@{DELTA_PARAMS_IN_SCF_DU}    @{5GC000772DU_delta}


@{5GC000575CU_full}
...    @{IntraMeNBMobility}
...    @{IntraFreqIntraGnb}
...    @{A3_Rsrp}

@{IntraMeNBMobility}
...    NRBTS:actIntraMeNBMobility=true

@{IntraFreqIntraGnb}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
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
...    NRBTS/NRCELL-2:chBw=100MHz
...    NRBTS/NRCELL-2:freqBandIndicatorNR=78
...    NRBTS/NRCELL-2:nrarfcn=636666
...    NRBTS/NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRBTS/NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRBTS/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRBTS/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS/NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{A3_Rsrp}
...    NRBTS/NRCELL:a3MeasEnabled=rsrp
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRBTS/NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS/NRCELL:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL:filterCoeffSsbRsrp=fc4
...    NRBTS/NRCELL:sMeasConfigSsbRsrp=1


@{5GC000575DU_full}
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

@{5GC000772CU_full}
...    NRBTS/NRCELL-1:actCDrx=true
...    NRDRX-4:drxLongCycle=80ms
...    NRBTS/NRCELL-2:actCDrx=false

@{5GC000772DU_full}
...    NRBTS/NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRBTS/NRCELL-1:actCDrx=true
...    NRBTS/NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRBTS/NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRBTS/NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRDRX-4:drxLongCycle=80ms
...    NRDRX-4:drxOnDurationTimer=20ms
...    NRDRX-4:drxInactivityTimer=20ms
...    NRDRX-4:drxRetransTimerDl=16slot
...    NRDRX-4:drxRetransTimerUl=16slot
...    delete:NRBTS/NRCELL-1:tddFrameStructure:lteToNrFrameShift


@{5GC000772CU_delta}
...    NRBTS/NRCELL-1:actCDrx=false
...    NRBTS/NRCELL-2:actCDrx=false

@{5GC000772DU_delta}
...    NRBTS/NRCELL-1:actCDrx=false
...    NRBTS/NRCELL-2:actCDrx=false

###counter on CU
###575 counter
${X2_SGNB_MOD_REQ_RECEIVED}    M55112C04001   #Number of incoming SGNB MODIFICATION REQUEST received from LTE eNB
${X2_SGNB_MOD_REQ_ACK_SNT}    M55112C04002   #Number of outgoing SGNB MODIFICATION REQUEST ACKNOWLEDGE sent to LTE eNB
${INTRA_MENB_HO_WI_PSCELL_CHNGE}    M55128C00001    #Number of successful Intra-MeNB HO with PSCell Change
${INTRA_MENB_HO_RRC_RECONF}    M55128C00003    #Number of RRC Reconfiguration attempts due to Intra-MeNB HO
${INTRA_MENB_HO_RRC_RECONF_SUCC}    M55128C00004    #Number of successful RRC Reconfiguration due to Intra-MeNB HO
@{PM_Counters_Check_CU}
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_RECEIVED}=1
...    NRCELL-1:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=1
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_RECEIVED}=0
...    NRCELL-2:NX2CC:${X2_SGNB_MOD_REQ_ACK_SNT}=0
...    NRBTS-1:LTEMO:${INTRA_MENB_HO_WI_PSCELL_CHNGE}=1
...    NRBTS-1:LTEMO:${INTRA_MENB_HO_RRC_RECONF}=1
...    NRBTS-1:LTEMO:${INTRA_MENB_HO_RRC_RECONF_SUCC}=1

###counter on DU
###772 counter
${SLOTS_UE_DRX_ACTIVE}    M55308C11001   #Number of slots when UE is in DRX active time.
${SLOTS_UE_DRX_SLEEP}    M55308C11002   #Number of slots when UE is in DRX sleep time.
@{PM_Counters_Check_DU}
...    NRCELL-1:NCELA:${SLOTS_UE_DRX_ACTIVE}>=1
...    NRCELL-1:NCELA:${SLOTS_UE_DRX_SLEEP}>=1
...    NRCELL-2:NCELA:${SLOTS_UE_DRX_ACTIVE}=0
...    NRCELL-2:NCELA:${SLOTS_UE_DRX_SLEEP}=0

*** Test Cases ***
CB009444-ET_5GC000575_Intra-MeNB_LTE_handover_causes_changing_UE_capabilities_to_change_PSCell_at_SgNB
    [Documentation]
    ...    1. The purpose of this test case is to:
    ...        a. Intra-MeNB LTE handover causes changing UE capabilities to change PSCell at SgNB is successful. -5GC000575
    ...        b. Check DRX setup when UE attach to cell1(actCDrx=true in cell1), and DRX release when HO to cell2(actCDrx=false in cell2)
    ...    2. Test Case Steps:
    ...         a. NSA UE attach and start traffic
    ...         b. Configure MeNB to include CandidateCellInfoListMN with the provided MeasResultList2NR hex bytes that will trigger PS Cell Change
    ...         c. Trigger Intra-MeNB Inter-cell Handover
    ...         d. NSA UE detach
    ...         e. deactivate DRX
    ...         f. NSA UE attach and start traffic
    ...    3. Expected Results:
    ...         Step a: NSA UE attach successfully and traffic should be OK, drx setup
    ...         Step c: trigger SgNBModificationRequest, UE HO to cell2, also check drx release
    ...         Step d: NSA UE detach successfully
    ...         Step e: delta commisonn on CU and DU successfully
    ...         Step f: NSA UE attach successfully and traffic should be OK, check no drx setup
    ...         check counters on CU: M55112C04001, M55112C04002, M55128C00001, M55128C00003, M55128C00004
    ...         check counters on DU: M55308C12001, M55308C11001, M55308C11002
    [Tags]    QC_278711
    Clear Counter Files
    Config Allow Endc For Enb Cell2
    NSA UE Attach and Traffic
    Configure MeNB To Include CandidateCellInfoListMN
    Trigger Intra-MeNB Inter-cell Handover
    Verify Throuput Should Be OK
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_575_772/a2a.ini    wait_string=UEContextModificationResponse::12
    Check Counters
    Deactivate DRX And Verify UE Attach and Traffic OK


*** Keywords ***
Modify Cfg Aic
    Update Cfg Aic    set_cell id=2 enb=1 eci=0x1234602 pci=3:1 tac=222 proxy=10.0.2.1:12229 earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    ${V_1}    catenate  set_cell id=1 gnb=2 pci=16:2 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    ${V_2}    catenate  set_cell id=2 gnb=2 pci=17:0 tac=280 nrci=0x02 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off
    Update Cfg Aic    ${V_1}
    Update Cfg Aic    ${V_2}

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}
    Check Counters Du Aic    pm_counters_expression=${PM_Counters_Check_DU}    wait=False

Config Allow Endc For Enb Cell2
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on

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

Configure MeNB To Include CandidateCellInfoListMN
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=0B26DA810C804330
    Sleep    3s    ###AP requried

Trigger Intra-MeNB Inter-cell Handover
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2    Intra-eNB handover

Deactivate DRX And Verify UE Attach and Traffic OK
    Detach UE
    Deactivate DRX
    NSA UE Attach and Traffic
    Stop Traffic

Detach UE
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Release Ues    ue_id=${ue_id}    ue_type=nsa

Deactivate DRX
    Delta Commission Parameters CU    ${DELTA_PARAMS_IN_SCF_CU}
    Delta Commission Parameters DU    ${DELTA_PARAMS_IN_SCF_DU}

Stop Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped
