*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CRT   owner-baijie.zhu    release-5G20A
...     team-DevHZ5_SG02    vDUCNF00    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC    SANSA_FS_ECPRI_CMWV_TDD_CPRI_CMWV_FDD

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tddfdd_sansa_cmwv/FS/1du/4cells_2T2F

${nsaInactivityTimer}    15s
${NSA_UE_ID}    31

@{PARAMS_IN_SCF_CU}    @{5GC000886CU_full}    @{5GC000772CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC000772DU_full}

@{5GC000886CU_full}
...    NRBTS-1:nsaInactivityTimer=10

@{5GC000772CU_full}
...    NRBTS/NRCELL-1:actCDrx=true
#...    NRBTS/NRCELL-1:drxProfile1:drxLongCycle=80ms
...    NRBTS/NRCELL-2:actCDrx=false

@{5GC000772DU_full}
...    NRBTS/NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...    NRBTS/NRCELL-1:actCDrx=true
...    NRBTS/NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRBTS/NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRBTS/NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4
#...    NRBTS/NRCELL-1:drxProfile1:drxLongCycle=80ms
#...    NRBTS/NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
#...    NRBTS/NRCELL-1:drxProfile1:drxInactivityTimer=20ms
#...    NRBTS/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
#...    NRBTS/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
...    delete:NRBTS/NRCELL-1:tddFrameStructure:lteToNrFrameShift

@{DELTA_PARAMS_IN_SCF_CU_1}    @{DataUsageRep_Change_delta}
@{DataUsageRep_Change_delta}
...    NRBTS-1:actSecDataUsageRep=true
...    NRBTS-1:periodicalDataUsageReportTimer=60
...    NRBTS-1:actInactDetNSAUe=true

###counter on CU
${ENDC_X2_SEC_RAT_DATA_USAGE_REP}    M55110C02001    #Number of EN-DC X2 Secondary RAT Data Usage Report sent to eNB
@{PM_Counters_Check_CU}
...    NRBTS-1:NX2CB:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}=1

*** Test Cases ***
5GC000886_Verify_Cloud_NSA_TDD_cmWave_L3_call_setup_with_DRX_is_successful_and_Secondary_RAT_Data_Usage_Report_is_delivery_to_MeNB
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check:
    ...    NSA L3 call with DRX activated. -5GC000772
    ...    DRX profile begins to use drx configuration of nonGBRNrDrxDN NRDRX-4 after feature 9109
    ...    MeNB receives Secondary RAT Data Usage Report reflecting volume of the data transmitted by gNB radio after DRB termination.-5GC000886
    ...    [Configuration]: 1 cloud cmWave gNB, 1 Airphone, 2 Cell
    ...    [Cover Feature]: 5GC000886 and 5GC000772
    [Tags]    QC_280718
    Clear Counter Files
    Attach UE And Verify DRX Relevant PM Counter
    Set Parameters For DataUsageRep
    Verify Traffic And Trigger NSA Inactivity
    Check Data Usage Report And PM Counter

*** Keywords ***
Modify Cfg Aic
    ${V_1}    catenate
    ...    set_ue simulated id=${NSA_UE_ID} uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    ...    imsi=311:489:21645431
    Update Cfg Aic    ${V_1}
    ${V_2}    catenate
    ...    ue_param id=${NSA_UE_ID} ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg Aic    ${V_2}
    Update Cfg Aic    set_bearer id=2 ue=${NSA_UE_ID} qci=9 pdn=1 ip=4.7.254.208 default=on trf_type=internal

Clear Counter Files
    Clear Counter Files Cu Aic    wait=False
    Clear Counter Files Du Aic    wait=False

Check Counters
    Check Counters Cu Aic    ${PM_Counters_Check_CU}

Send Throughput
    [Arguments]    ${ue_id}
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=5 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=5 trf_id=2    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    &{BearInfoDict}    Ap Get Bearer Stats Info    ue=${ue_id}    id=2    dir=ul    dc_cell_group=scg
    Should Be True    &{BearInfoDict}[Total packets sent]>0

Detach UE
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Release Ues    ue_id=${ue_id}    ue_type=nsa

Stop Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped

Set Parameters For DataUsageRep
    Delta Commission Parameters CU    ${DELTA_PARAMS_IN_SCF_CU_1}
    BuiltIn.Log To Console    delta commission for DataUsageRep is done

Attach UE And Verify DRX Relevant PM Counter
    NSA UE Attach
    Check DRX Relevant PM Counter

NSA UE Attach
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA

Send And Verify Throuput
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}

Verify Traffic And Trigger NSA Inactivity
    Detach UE
    NSA UE Attach
    Send And Verify Throuput
    Stop Traffic
    sleep    ${nsaInactivityTimer}
    BuiltIn.Log To Console    Trigger NSA inactivity is done

Check Data Usage Report And PM Counter
    Get The Bytes Sent And Bytes Received By The Egate
    Check WireShark Log Aic    ${CURDIR}/a2a_886/a2a.ini    wait_string=SecondaryRATDataUsageReport::1
    BuiltIn.Log To Console    Wirshark check is done
    Check Counters
    BuiltIn.Log To Console    886 PM counter check is done

Check DRX Relevant PM Counter
    ${pm_counters}    Create List    NRCELL-1:M55308C11001    NRCELL-1:M55308C11002
    ${counter1}    ${counter2}    get_counters_value_du_aic    ${pm_counters}
    ${value}    Evaluate    float(${counter2})/float(${counter1})
    should be true    ${value}>1.80
    should be true    ${value}<2.50
    BuiltIn.Log To Console    DRX_Acitve and DRX_Sleep Ratio check is done

Get The Bytes Sent And Bytes Received By The Egate
    ${bearer_stats}=    Execute Egate Command     bearer_stats ue=31 id=2 dir=dl type=l3 trf_id=2
    ...    pass_regexp=Bytes sent
    ${Bytes sent}=    Get regexp matches    ${bearer_stats}     Bytes sent (.*)    1
    ${Bytes sent}    convert to integer    ${Bytes sent[0].strip()}
    ${bearer_stats}=    Execute Egate Command     bearer_stats ue=31 id=2 dir=ul trf_id=1 type=l3
    ...    pass_regexp=Bytes received
    ${Bytes received}=    Get regexp matches    ${bearer_stats}     Bytes received (.*)    1
    ${Bytes received}    convert to integer    ${Bytes received[0].strip()}
    Set Test Variable    ${Bytes sent}
    Set Test Variable    ${Bytes received}