*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    CRT    RAN_5G    RAN_5G_TDD
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-DevHZ5_SG2    owner-zhubaijie    release-5G19A
Resource     ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
#CIT014
...    NRCELL-1:actCDrx=true
...    NRBTS/NRDRX-1:drxInactivityTimer=50ms
...    NRBTS/NRDRX-1:drxLongCycle=40ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-1:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=16slot
...    NRBTS-1:nsaInactivityTimer=30
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:cbraPreamblesPerSsb=n60
...    NRCELL-1:rsrpThresholdSSB=15
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    MRBTS-1/NRBTS-1:actRanSharing=true
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=402
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-3:mcc=460
...    MRBTS-1/NRBTS-1/NRPLMN-3:mnc=2
...    MRBTS-1/NRBTS-1/NRPLMN-3:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:configuredEpsTac=200
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
#...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_NSA-1:configuredEpsTac=200
#...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-3
#...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
#...    MRBTS-1/NRBTS-1/NRCELL-3/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
#CIT015
...    NRCELL-1:actDynUlDataSplitMode=true
...    NRCELL-1:rlResumePathLossThreshold=83
...    NRCELL-1:rlResumeSinrThreshold=300
...    NRCELL-1:rloConsecDtxThreshold=1
...    NRCELL-1:rloDtxRatioThreshold=1
...    NRCELL-1:consecRlOThreshold=3
...    NRCELL-1:consecRlRThreshold=1
...    NRCELL-1:rloPathLossThreshold=85
...    NRCELL-1:rloSinrThreshold=299
...    NRCELL-1:puschDataDtxNumOfSamples=100
...    NRCELL-1:pucchDataDtxNumOfSamples=100
...    NRDRB-2:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-3:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-4:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-5:nsaDrbParam:ulDataPath=ulOverNr
...    NRDRB-6:nsaDrbParam:ulDataPath=ulOverNr
...    delete:NRDRB-5:nsaDrbParam:ulDataPathForUlSplitNotCapableUe
...    delete:NRDRB-6:nsaDrbParam:ulDataPathForUlSplitNotCapableUe
...    NRDRB-2:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-3:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-4:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-5:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRDRB-6:nsaDrbParam:ulDataSplitThreshold=infinity
#CIT012
...    NRBTS-1:actMultiDrbNSA=true
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...    NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0

${RA_UE_NSA_PLMN}    M55145C00005
${RA_NGBR_DRB_NSA_PLMN}    M55145C00006
${UL_DATA_SPLIT_RECONF_LTE_SUCC}    M55146C01002    #Number of UL data split mode reconfiguration completions to LTE only
${UL_DATA_SPLIT_RECONF_LTE_ATT}    M55146C01001    #Number of UL data split mode reconfiguration attempts to LTE only
${NUM_MEET_UL_RL_OUTAGE_THLD}    M55308C12001    #Number of times meet the UL RL outage thresholds
${SGNB_NSA_ADMISSION_REQ}    M55114C00001    #The number of radio admission requests for NSA user
${SGNB_NSA_ADMISSION_SUCC}    M55114C00002    #	The number of radio admitted UEs for NSA user
${SGNB_NSA_ADMISSION_MFBI_REQ}    M55114C00501    #Number of NSA user radio admission requests where request is on the alternative band
${SGNB_NSA_ADMISSION_MFBI_SUCC}    M55114C00502    #Number of NSA user admitted where radio admission is done on the alternative band

@{PM_COUNTERS}
...    NRCELL-1/MCC-311/MNC-489:NRANS:${RA_UE_NSA_PLMN}=1
...    NRCELL-1/MCC-311/MNC-489:NRANS:${RA_NGBR_DRB_NSA_PLMN}=1
...    ${UL_DATA_SPLIT_RECONF_LTE_SUCC}=1
...    ${UL_DATA_SPLIT_RECONF_LTE_ATT}=1
...    ${NUM_MEET_UL_RL_OUTAGE_THLD}>=3
@{PM_Counters_Check_UE54}
...    NRCELL-1:${SGNB_NSA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=1

@{PM_Counters_Check_UE53}
...    NRCELL-1:${SGNB_NSA_ADMISSION_REQ}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_SUCC}=1
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_REQ}=0
...    NRCELL-1:${SGNB_NSA_ADMISSION_MFBI_SUCC}=0

@{PARAMS_IN_SWCONFIG}
...  0x59004D=1    #disableCallRejectionOnInvalidUeCapaRadParam) to disable CNI-48216 : Call rejection in case of invalid UE Capabilities


${BTS_STARTUP_RETRY}    4
@{DisableDynUlDataSplitMod}
...    NRCELL-1:actDynUlDataSplitMode=false

@{B005}
...    NRCELL-1:actDynUlDataSplitMode=true
...    NRCELL-1:rlResumeSinrThreshold=-199
...    NRCELL-1:rlResumePathLossThreshold=159

${ue53_nr_capabilities}    SEPARATOR=
...    ED007000479A4BBF5FFFFEF8005BD409A00CFDBFCB98AD7FFBF900001F53FFFFC00004C88
...    0000073BF79FFF9FFFF60000FBC00BFFF0000163C03F148200DFFF785FFF5E00F2A6A7000158800000000023007CAA080E0
${ue53_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA083058380713400000018062B000060400C1001830030600E2680000
...    10300C160801C4D000004060182C000389A00000C0C03058100713400002018060B0600E2680000503000100504C00C01002826C1
...    300389178A038400040201002004A0000000000000000000000000000000000800000100008040400801080008020200400800804
...    0180100200201006004008400000001000000400000000800000020000000

${ue54_nr_capabilities}    SEPARATOR=
...    6100000004418004000000C48010000260000410040182644100066FFFFF1BC0100
...    0000000000000040145427000400000000000040102A074

${ue54_eutra_nr_capabilities}    SEPARATOR=
...    BD1BA063058380713000000018062B000060400C1001830030600E260000010300C160801C4C000006060182C000389800000C0C0
...    3058100713000001018060B0600E260000020300C9BCD00C2000201008010025700100402008040100802010040200804010080201004020
...    0804010080201004020100402008040100800000040200804000000000004020000000000000000402008040100802010000000804010080
...    0000000000804000000000000000080401008020100402008040000002010040200804000000000000000080400000000000000000000100
...    9C00202008040080801010000000404008080000000000040400000000000000004020100401008020100402008040100802010040200804
...    0100802010040200808020100202000000080801010000000404000000000002020000000000010100402004040080800000020200404000
...    0000000020200404000000000002020000000000000000202700100802010040200000010080201000000080400000000000402000000000
...    0020100402008040000002010040200000010080000000000080400000000000401008020100402008040100802010040200804010080201
...    00402008040100804010080201000000080401008000000402000000100800000040200000000000201000000000001009C0020200404008
...    0801010020200000008080101002020000000000010100000004040080801010020200404000000101002020040400000000000202000000
...    0808010100202004040080800000020200404008080000000000040400000010080201004020080401008020100402008040100802010040
...    2008040100802010040200804010080401700100801010000000404008080000000000000000808000000000000000000002010020200000
...    0080801010000000000000000101000000000000000000000402004040000001010020200000000000000002020000000000000000000008
...    04008080000002020040400808000000000004040000001010020200000000000000002020000000809C40080180100300200600400C0080
...    180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030020060040
...    0C0080180100300200600400C0080180100300200600400C0080180100300200600400C008010800040202004008400040101002004

@{Endc_Blind_Ca}
...    Successfully reconfigured dual connectivity

@{PM_Counters_EDA}
...    NRBTS-1:${DDDS_24001}>0
...    NRBTS-1:${DDDS_25001}>0
...    NRBTS-1:${DDDS_25002}>0
...    NRBTS-1:${DDDS_25003}>0
...    NRBTS-1:${DDDS_25004}>0
...    NRBTS-1:${DDDS_25005}>0
...    NRBTS-1:${DDDS_25006}>0

${DDDS_24001}    M55313C24001   #Number of X2-U DDDS received
${DDDS_25001}    M55313C25001   #Distribution of DDDS period over X2-U - Bin 01
${DDDS_25002}    M55313C25002   #Distribution of DDDS period over X2-U - Bin 02
${DDDS_25003}    M55313C25003   #Distribution of DDDS period over X2-U - Bin 03
${DDDS_25004}    M55313C25004   #Distribution of DDDS period over X2-U - Bin 04
${DDDS_25005}    M55313C25005   #Distribution of DDDS period over X2-U - Bin 05
${DDDS_25006}    M55313C25006   #Distribution of DDDS period over X2-U - Bin 06

*** Test Cases ***
5GSW_CP_CIT012_14_15 Ran sharing and RLO and native band and alternave band funcation successfully
    [Documentation]
    #CIT014
    ...    This case will include feature 5GC000738
    ...    The purpose of this test case is to check Multi PLMN are broadcasted to each connected MeNB
    ...    during EN-DC X2 Setup and SgNB Addition procedure.
    ...    PLMN1 and PLMN2 add to cell1
    ...    PLMN3 add to cell2
    ...    UE attach to each PLMN
    ...    Check PLMN is correct in ENDCX2AP and sgNB addition request
    #CIT015
    ...    This case will include feature 5GC001200.The purpose of this test case is to check the gNB behavior,
    ...    when reconfigure from NR to LTEOnly due to a UL Radio Link Outage Indication
    ...    RLO happen
    ...    Check counters
    ...    Add 1 SCG split bearer
    ...    Disable DynUlDataSplitMod and Attach new UE successfully
    ...    RL resume happen
    #CIT012
    ...    1.Verify native band and alternave band will be send to enb in X2SetupResponse
    ...    2.Verify addition successfully when UE supported alternative band on gNB and the alternative band will be selected.
    ...    3.Verify addition successfully when UE supported both native band and alternative band on gNB,the native band will be selected.
    ...    4.Counters during the procedures
    #EDA 04310545 For NR_1245
    ...    NR_1245a   5G Average time between consecutive DDDS received over X2-U
    ...    This KPI shows the average time difference between consecutive DDDS messages received over X2-U measured in the gNB-CU.
    ...    It is calculated from the bin counters and the weight of each bin is considered the half value of the interval,
    ...    except for the last bin,where the minimum value of the interval is used as weight.
    ...    Note: One major factor contributing to CPU load is handling of Downlink Data Delivery Status(DDDS).
    ...    The CPU load reduces when the DDDS period is increased.
    ...    04310545's issue: We notice high increase in NR_1245 for pilot cluster post SW upgrade to 24R1.
    ...    NUM_OF_X2_DDDS_RCVD (M55313C24001) decrease (denominator ) which lead to NR_1245 5G Average time between consecutive.
    ...    DDDS received over X2-U increase.
    [Tags]    QC_47244
    Attach UE check the result and check the traffic    ue_id=54
    Check Counters    ${PM_Counters_Check_UE54}
    Attach UE check the result and check the traffic    ue_id=53
    Check Counters    ${PM_Counters_Check_UE53}
    Ul Data Split As Expected    RLO
    Check Counters    ${PM_COUNTERS}
    Perform EN-DC SN modification procedure to add 1 SCG split bearer
    Attach new UE after disable DynUlDataSplitMod
    Release All UEs
    EDA 04310545 For NR_1245

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    ${ue32}    catenate
    ...    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=311:402:21645501
    ${ue33}    catenate
    ...    set_ue simulated id=33 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=460:002:21645502
    ${ue34}    catenate
    ...    set_ue simulated id=34 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nia=null+snow3g+zuc+aes nea=null+zuc+snow3g imsi=460:002:21645502
    Update Cfg    mme_pool_area id=2 mmegi=2 plmn=311:402 tac_list=200,777,111,222,444,333,210 eq_plmn=311:402
    Update Cfg    mme_pool_area id=3 mmegi=3 plmn=311:406 tac_list=200,777,111,222,444,333,210
    Update Cfg    ${ue32}
    Update Cfg    ${ue33}

    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1 preprovisioned=on filter=2 precedence=2
    ${set_ue53}    catenate    set_ue simulated id=53 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645422
    Update Cfg    ${set_ue53}
    ${set_ue54}    catenate    set_ue simulated id=54 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+snow3g+aes eea=null nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc imsi=250:555:21645423
    Update Cfg    ${set_ue54}
    ${set_ue53_capability}    catenate
    ...    ue_param id=53 ue_nr_capabilities=${ue53_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue53_eutra_nr_capabilities}
    Update Cfg    ${set_ue53_capability}
    ${set_ue54_capability}    catenate
    ...    ue_param id=54 ue_nr_capabilities=${ue54_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue54_eutra_nr_capabilities}
    Update Cfg    ${set_ue54_capability}
    Update Cfg    set_bearer id=2 ue=53 qci=9 pdn=1 ip=4.7.254.230 default=on trf_type=internal
    Update Cfg    set_bearer id=2 ue=54 qci=9 pdn=1 ip=4.7.254.231 default=on trf_type=internal

Perform Steps After Onair
    Check WireShark Log    ${CURDIR}${/}a2a_CIT014${/}a2a_x2.ini    wait_string=ENDCX2SetupResponse::1

NSA UEs L3 Call And ENDC Succeed
    ${IDs_List_dict}    Create Dictionary
    Set Test Variable    \${IDs_List_dict}
    FOR    ${ue_id}    IN RANGE    31    34
        ${plmn}=    Set Variable If    ${ue_id} == 31    311:489    ${ue_id} == 32    311:402    460:002
        ${cell}=    Set Variable If    ${ue_id} == 33    2    1
        Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
        Execute Egate Command    ue_attach id=${ue_id}    UE${ue_id}: === UE IS ACTIVE
        Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
        Execute Egate Command    enb_endc_param selected_plmn=${plmn} id=1
        ${ret1}=    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell} bearer=2 type=split_scg
        ...    UE${ue_id}: Proxy \\(eNB 2 cell ${cell}\\) reported successful RA
        ${IDs_List}=    Get Ue x2ap Ids    ${UE_ID}     ${ret1}
        Set To Dictionary    ${IDs_List_dict}    ${UE_ID}    ${IDs_List}
    END
    Set Suite Variable    ${UE_X2AP_ID}    ${IDs_List_dict[31][0]}
    Set Suite Variable    ${SgNB_UE_X2AP_ID}    ${IDs_List_dict[31][1]}

Check DL And UL Throughput
    Send And Verify Throuput    31    2    1.8    all
    Send And Verify Throuput    32    2    1.8    all
    Send And Verify Throuput    33    2    1.8    all

Release All UEs
    Execute Egate Command    ue_detach id=31    UE31: detached
    Execute Egate Command    ue_detach id=32    UE32: detached
    Execute Egate Command    ue_detach id=33    UE33: detached

Attach UE check the result and check the traffic
    [Arguments]   ${ue_id}    ${target_cells}=1
    Clear Counter files
    Start To Capture Wireshark Log     pcap_UE${ue_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    successful RA    timeout=20s
    traffic should be ok    ue_id=${ue_id}    type=NSA
    Check Wireshark Log    ${CURDIR}/a2a_CIT014/a2a_${ue_id}.ini    name=pcap_UE${ue_id}    wait_string=SNStatusTransfer::2

Ul Data Split As Expected
    [Arguments]    ${pcap_name}
    start to capture wireshark log    ${pcap_name}
    Config PHR profile
    NSA UEs L3 Call And ENDC Succeed
    Activate LTE-NR DC modification mod MGAP
    Check DL And UL Throughput
    Activate PHR testmode
    Verify Throuput    31    2    0    scg
#    Verify UL Throuput after RLO
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT014${/}RLO.ini    name=RLO
    ...    wait_string=BearerContextModificationResponse::18

Activate LTE-NR DC modification mod MGAP
   [Documentation]
   ...   Command to trigger LTE-NR dual connectivity modification release by sending hex-string
   ...   the base hex string may be taken from X2 logs of 5GC000795_B_TC01_Add_new... test case
   ...   ${UE_X2AP_ID}  and  ${SgNB_UE_X2AP_ID}  are global variables; they will be defined in
   ...   keyword  Activate LTE-NR Dual Connectivity for bearer 2 and verifiy UE IDs
   [Arguments]
   ${UE_X2AP_IDhex}=        Run  printf "%04x" ${UE_X2AP_ID}
   ${SgNB_UE_X2AP_IDhex}=   Run Keyword if   ${SgNB_UE_X2AP_ID}<${65536}  Run  printf "%04x" ${SgNB_UE_X2AP_ID}
   ...                      ELSE    Run   printf "%06x" ${SgNB_UE_X2AP_ID}
   ${cmd4bit_short}    Catenate    SEPARATOR=  send_hex source=enb:1 target=gnb:2 hex=001D0029000005006F0002${UE_X2AP_IDhex}
   ...   00CF0002${SgNB_UE_X2AP_IDhex}00054002112000D70008010000011340017200CE000403002020
   ${cmd4bit_long}    Catenate    SEPARATOR=  send_hex source=enb:1 target=gnb:2 hex=001D002B000005006F0002${UE_X2AP_IDhex}
   ...   00cf000340${SgNB_UE_X2AP_IDhex}00054002112000D70008010000011340017200CE000403002020
   ${cmd6bit}    Catenate    SEPARATOR=  send_hex source=enb:1 target=gnb:2 hex=001D0029000005006F0002${UE_X2AP_IDhex}
   ...   00cf000480${SgNB_UE_X2AP_IDhex}00054002112000D70008010000011340017200CE000403002020
   ${CmdStr}=  Set Variable If  ${SgNB_UE_X2AP_ID}<${256}             ${cmd4bit_short}
   ...                           ${256}<${SgNB_UE_X2AP_ID}<${65536}    ${cmd4bit_long}
   ...                           ${65536}<${SgNB_UE_X2AP_ID}           ${cmd6bit}
   Execute Egate Command    ${CmdStr}

Attach new UE after disable DynUlDataSplitMod
    Online modification    ${DisableDynUlDataSplitMod}
    UE_Attach    34    2
    Send And Verify Throuput    34    2    1.8    all

Config PHR profile
    Clear Counter Files
    ${config_phr}    catenate
    ...    phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23 phr_max=40 phr_step_size=-63
    ...    phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${config_phr}
    Sleep    2s

UE_Attach
    [Arguments]    ${UE_ID}=31    ${BEARER_ID}=2
    Execute Egate Command    ue_attach id=${UE_ID}    UE IS ACTIVE    timeout=300
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
    Execute Egate Command
    ...    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=${BEARER_ID} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

Activate PHR testmode
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=deactivate profile_id=1 scell=5
    Sleep    100s
    Execute Egate Command    ue_testmode_set_nr id=31 testmode=phr_override action=activate profile_id=1 scell=5
    ...    SgNBModificationConfirm    timeout=300

Send And Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=dl mbps=2 trf_id=2    UE ${UE_ID}: UDP DL
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=ul mbps=2    UE ${UE_ID}: UDP UL
    Verify Throuput    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}


Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=ul    dc_cell_group=${dcgroup}    rate_type=ave
    Should Be True    ${ul_throuput}/1000>=${ul_throuput_expect}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>1.8

Verify UL Throuput after RLO
    [Arguments]    ${ue_id}=31
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput}==0
#    Execute Egate Command    bearer_stats_clear ue=31 id=2
#    &{bearStatDict}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul   dc_cell_group=scg
#    Should Be True    &{bearStatDict}[Bytes sent]==0

Verify UL Throuput on scg before RLO
    [Arguments]    ${ue_id}=31
    ${ul_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput}>0
#    &{bearStatDict}    Ap Get Bearer Stats Info    ue=31    id=2    dir=ul   dc_cell_group=scg
#    Should Be True    &{bearStatDict}[Bytes sent]>0

Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs

Perform EN-DC SN modification procedure to add 1 SCG split bearer
# Activate RLF, CSI Report Override, PHR Override testmodes
    start to capture wireshark log    add_bearer
    Execute Egate Command    enb_ue_dc_modify ue=31 bearer_to_add=3 by=enb cause=MISC_CauseMisc_unspecified type=split_scg
    ...    SgNBReconfigurationComplete    timeout=300
    Check Wireshark Log    ${CURDIR}${/}a2a_CIT014${/}add_bearer.ini    name=add_bearer
    ...    wait_string=BearerContextModificationResponse::12

EDA 04310545 For NR_1245
    Clear Counter Files
    Ue Attach To Cell And Initial Endc With Low Traffic
    Check KPI NR_1245A    1    8
    Clear Counter Files
    Ue Attach To Cell And Initial Endc With Medium Traffic
    Check KPI NR_1245A    1    11

Online modification
    [Arguments]  ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Ue Attach To Cell And Initial Endc With Low Traffic
    Execute Egate Command    ue_change_location id=31 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=31
    Initial Endc And Blind Ca    ue_id=31    target_gnb=2    target_cells=1    bearer_id=2
    Send And Verify Throuput With Low traffic
    Release Ues    ue_type=all

Ue Attach To Cell And Initial Endc With Medium Traffic
    Execute Egate Command    ue_change_location id=31 cell=1 enb=1
    UE Attach To Enb Cell1    ue_id=31
    Initial Endc And Blind Ca    ue_id=31    target_gnb=2    target_cells=1    bearer_id=2
    Send And Verify Throuput With Mediem traffic
    Release Ues    ue_type=all

UE Attach To Enb Cell1
    [Arguments]    ${ue_id}=31
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Initial Endc And Blind Ca
    [Arguments]    ${ue_id}=31    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=1
    ${ret1}=    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ...    pass_regexp=${Endc_Blind_Ca}    timeout=20s

Send And Verify Throuput With Low traffic
    Execute Egate Command    data_trf_start ue=31 id=2 dir=dl mbps=1 trf_id=2    UE 31: UDP DL
    Verify DL Throughput

Send And Verify Throuput With Mediem traffic
    Execute Egate Command    data_trf_start ue=31 id=2 dir=dl mbps=100 trf_id=2    UE 31: UDP DL
    Verify DL Throughput

Verify DL Throughput
    [Arguments]    ${sleep_time}=300s    ${ue_id}=31
    sleep    ${sleep_time}
    Execute Egate Command    ue_disp
    ${dl_Throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput}/1000>0

Check KPI NR_1245A
    [Arguments]    ${min}=0    ${max}=5
    ${pm_counters}    Create List    NRBTS-1:${DDDS_25001}    NRBTS-1:${DDDS_25002}    NRBTS-1:${DDDS_25003}
    ...    NRBTS-1:${DDDS_25004}    NRBTS-1:${DDDS_25005}    NRBTS-1:${DDDS_25006}    NRBTS-1:${DDDS_24001}
    ${501}    ${502}    ${503}    ${504}    ${505}    ${506}    ${401}    get_counters_value    ${pm_counters}
    ${value}    Evaluate    (${501}*2.5+${502}*7.5+${503}*15+${504}*25+${505}*35+${506}*40)/(${401})
    should be true    ${value}>${min}
    should be true    ${value}<${max}
    BuiltIn.Log To Console    NR_1245a is fit for expection
