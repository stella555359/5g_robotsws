*** Settings ***
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Stop Capture Logs And Restore ENV In Test Teardown
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-L3CN3_SG2
...    owner-baijie.zhu    release-5G20A     5GC000772    5GC000886    CDRT    5GC002177
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{DrbInacTimer}    @{CsiReportPeriod}    @{TddFrameStructure}    @{5GC002177_full}

@{DrbInacTimer}
...    NRBTS:drbInactivityTimerSA=7200
...    NRBTS:nsaInactivityTimer=10

@{CsiReportPeriod}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
@{TddFrameStructure}
...    NRCELL-1:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4

@{PM_Counters_Check_CIT011}
...    NRBTS-1:NX2CB:${ENDC_X2_SEC_RAT_DATA_USAGE_REP}=1
#below 4 counters are for 5GC002177
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVE_A2}=1
...    NRCELL-1:NX2CC:${X2_SGNB_REL_REQUIRED_SENT}=3
...    NRCELL-1:NX2CC:${X2_SGNB_REL_CONF_RECEIVED}=3

${ENDC_X2_SEC_RAT_DATA_USAGE_REP}    M55110C02001    #Number of EN-DC X2 Secondary RAT Data Usage Report sent to eNB
${X2_SGNB_REL_REQUIRED_SENT_A2}    M55112C05001    #Number of outgoing SgNB RELEASE REQUIRED message sent to LTE eNB due to A2 based SgNB release
${X2_SGNB_REL_CONF_RECEIVE_A2}    M55112C05002    #The number of incoming SgNB RELEASE CONFIRM received from LTE eNB due to A2 based SgNB release
${X2_SGNB_REL_REQUIRED_SENT}    M55112C00007    #Number of outgoing SGNB RELEASE REQUIRED sent to LTE eNB
${X2_SGNB_REL_CONF_RECEIVED}    M55112C00008    #Number of incoming SGNB RELEASE CONFIRM received from LTE eNB

${nsaInactivityTimer}    15s

@{DRX_State}
...    NRCELL-1:actCDrx=true

#@{DRX_Profile}
#...    NRCELL-1:drxProfile1:drxLongCycle=80ms
#...    NRCELL-1:drxProfile1:drxOnDurationTimer=20ms
#...    NRCELL-1:drxProfile1:drxInactivityTimer=20ms
#...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
#...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot

@{DataUsageRep_Change}
...    NRBTS-1:actSecDataUsageRep=true
...    NRBTS-1:periodicalDataUsageReportTimer=60
...    NRBTS-1:actInactDetNSAUe=true

@{DataUsageRep_Disable}
...    NRBTS-1:actSecDataUsageRep=false
...    NRBTS-1:actInactDetNSAUe=false

@{5GC002177_full}
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:actA2SgnbRelease=true
...    @{nea}
...    @{a2MeasRelease}

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


${SA_Capa_perUE_Full}  SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E77EF3FFF3FFFEC0001F78017FFE00002C7
...    807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08
${Capa_LTE}  SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801C4D000006060182C000389A00000C0C030581
...    00713400001018060B0600E26800002030048BC500C2000201008010025700100402008040100802010040200804010080201004020080
...    40100802010040201004020080401008000000402008040000000000040200000000000000004020080401008020100000008040100800
...    00000000080400000000000000008040100802010040200804000000201004020080400000000000000008040000000000000000000010
...    09C00202008040080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200
...    80401008020100402008080201002020000000808010100000004040000000000020200000000000101004020040400808000000202004
...    04000000000002020040400000000000202000000000000000020270010080201004020000001008020100000008040000000000040200
...    00000000020100402008040000002010040200000010080000000000080400000000000401008020100402008040100802010040200804
...    01008020100402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C00
...    20200404008080101002020000000808010100202000000000001010000000404008080101002020040400000010100202004040000000
...    00002020000000808010100202004040080800000020200404008080000000000040400000010080201004020080401008020100402008
...    04010080201004020080401008020100402008040100804017001008010100000004040080800000000000000008080000000000000000
...    00002010020200000008080101000000000000000010100000000000000000000040200404000000101002020000000000000000202000
...    000000000000000000804008080000002020040400808000000000004040000001010020200000000000000002020000000809C4008018
...    0100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600
...    400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801080004020
...    2004008400040101002004

${BTS_STARTUP_RETRY}    4

*** Test Cases ***
5GSW-CP-CIT011_Verify_Classical_NSA_TDD_cmWave_L3_call_setup_with_DRX_is_successful_and_Secondary_RAT_Data_Usage_Report_is_delivery_to_MeNB
    [Documentation]
    ...    [Purpose]: The purpose of this test case is to check:
    ...    NSA L3 call with DRX activated. -5GC000772
    ...    DRX profile begins to use drx configuration for nonGBRNrDrxDN NRDRX-1  after feature 9109
    ...    MeNB receives Secondary RAT Data Usage Report reflecting volume of the data transmitted by gNB radio after DRB termination.-5GC000886
    ...    verify sgnb release due to A2 event via SRB3. -5GC002177
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell
    ...    [Cover Feature]: 5GC000886 and 5GC000772 and 5GC002177
    [Tags]    Zhu Baijie
    Clear Counter Files
    Set Parameters For DRX
    Attach UE And Verify DRX Relevant PM Counter
    Set Parameters For DataUsageRep
    Verify Traffic And Trigger NSA Inactivity
    Check Data Usage Report
    Set Parameters For DataUsageRep Disable
    Attach UE And Verify Traffic
    SgNB Release Due To A2 Event Via SRB3
    Check WireShark And PM Counter

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${V_1}    catenate
    ...    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V_2}    catenate
    ...    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 nea=null+zuc nia=null+zuc imsi=311:489:21645400
    Update Cfg    ${V_1}
    Update Cfg    ${V_2}

Set Parameters For DRX
#    Delta Commission Parameters    ${DRX_Profile}
    Delta Commission Parameters    ${DRX_State}
    BuiltIn.Log To Console    delta commission for DRX is done

Set Parameters For DataUsageRep
    Delta Commission Parameters    ${DataUsageRep_Change}
    BuiltIn.Log To Console    delta commission for DataUsageRep is done

Set Parameters For DataUsageRep Disable
    Delta Commission Parameters    ${DataUsageRep_Disable}
    BuiltIn.Log To Console    delta commission for DataUsageRep Disable is done

Attach UE And Verify DRX Relevant PM Counter
    Ue Attach To LTE and Initial Endc
    Check DRX Relevant PM Counter

Ue Attach To LTE and Initial Endc
    Execute Egate Command    ue_change_location id=31 cell=1 enb=1
    UE Attach To Enb Cell1
    Initial Endc

Initial Endc
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Send And Verify Throuput
    Execute Egate Command    data_trf_start ue=31 id=2 dir=dl mbps=10 trf_id=2    UE 31: UDP DL
    Execute Egate Command    data_trf_start ue=31 id=2 dir=ul mbps=10    UE 31: UDP UL
    Verify Throuput    sleep_time=30s

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Verify Throuput
    [Arguments]    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>9
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>9

Verify Traffic And Trigger NSA Inactivity
    UE Detach From GNB
    Ue Attach To LTE and Initial Endc
    Send And Verify Throuput
    Traffic Data Stop    ue_id=31
    sleep    ${nsaInactivityTimer}
    BuiltIn.Log To Console    Trigger NSA inactivity is done

Check Data Usage Report
    Get The Bytes Sent And Bytes Received By The Egate
    Check Wireshark Log    ${CURDIR}/a2a_cit011/a2a.ini    wait_string=SecondaryRATDataUsageReport::2
    BuiltIn.Log To Console    Wirshark check is done


Check DRX Relevant PM Counter
    ${pm_counters}    Create List     NRCELL-1:M55308C11001    NRCELL-1:M55308C11002
    ${counter1}    ${counter2}    Get Counters Value    ${pm_counters}
    ${value}    Evaluate    float(${counter2})/float(${counter1})
    should be true    ${value}>3.50
    should be true    ${value}<4.00

Get The Bytes Sent And Bytes Received By The Egate
    ${bearer_stats}=    Execute Egate Command     bearer_stats ue=31 id=2 dir=dl type=l3 trf_id=2
    ...    pass_regexp=Bytes sent
    ${Bytes sent}=   Get regexp matches    ${bearer_stats}     Bytes sent (.*)    1
    ${Bytes sent}    convert to integer  ${Bytes sent[0].strip()}
    ${bearer_stats}=    Execute Egate Command     bearer_stats ue=31 id=2 dir=ul trf_id=1 type=l3
    ...    pass_regexp=Bytes received
    ${Bytes received}=    Get regexp matches    ${bearer_stats}     Bytes received (.*)    1
    ${Bytes received}    convert to integer  ${Bytes received[0].strip()}
    Set Test Variable    ${Bytes sent}
    Set Test Variable    ${Bytes received}

Attach UE And Verify Traffic
    UE Detach From GNB
    Start To Capture Wireshark Log    SgNBRelease
    Ue Attach To LTE and Initial Endc
    Send And Verify Throuput

SgNB Release Due To A2 Event Via SRB3
    ${meas_id_a2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=636576    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=31 meas_id=${meas_id_a2} event=A2 srsrp_nr=11 srsrq_nr=11
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful

Check WireShark And PM Counter
    Check Wireshark Log    ${CURDIR}/a2a_cit011/a2a_SgNBRelease.ini    name=SgNBRelease    wait_string=BearerContextReleaseComplete
    BuiltIn.Log To Console    Wirshark check for 5GC002177 is done
    Check Counters    ${PM_Counters_Check_CIT011}
    BuiltIn.Log To Console    PM counter check is done

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs
