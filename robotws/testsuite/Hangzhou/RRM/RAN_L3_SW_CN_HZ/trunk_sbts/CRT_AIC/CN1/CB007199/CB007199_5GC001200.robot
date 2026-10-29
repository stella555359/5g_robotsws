*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_Aic    CRT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jianfen.shen    release-5G22R4    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
${NSA_UE_ID}    31
@{PARAMS_IN_SCF_CU}    @{5GC001200CU_full}
@{PARAMS_IN_SCF_DU1}    @{5GC001200DU_full}
@{DELTA_PARAMS_IN_SCF_DU}    @{5GC001200DU_delta}

@{5GC001200CU_full}
...    NRBTS/NRDRB-2:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-2:nsaDrbParam:ulDataSplitThreshold=infinity

@{5GC001200DU_full}
...    NRBTS/NRCELL-1:actDynUlDataSplitMode=true
...    NRBTS/NRCELL-1:consecRlOThreshold=1
...    NRBTS/NRCELL-1:consecRlRThreshold=1
...    NRBTS/NRCELL-1:pucchDataDtxNumOfSamples=100
...    NRBTS/NRCELL-1:puschDataDtxNumOfSamples=100
...    NRBTS/NRCELL-1:rlResumePathLossThreshold=83
...    NRBTS/NRCELL-1:rlResumeSinrThreshold=300
...    NRBTS/NRCELL-1:rloConsecDtxThreshold=1
...    NRBTS/NRCELL-1:rloDtxRatioThreshold=1
...    NRBTS/NRCELL-1:rloPathLossThreshold=85
...    NRBTS/NRCELL-1:rloSinrThreshold=299

@{5GC001200DU_delta}
...    NRBTS/NRCELL-1:actDynUlDataSplitMode=false

###counter on CU
${UL_DATA_SPLIT_RECONF_LTE_SUCC}    M55146C01002    #Number of UL data split mode reconfiguration completions to LTE only
${UL_DATA_SPLIT_RECONF_LTE_ATT}    M55146C01001    #Number of UL data split mode reconfiguration attempts to LTE only
@{PM_Counters_Check_CU}
...    NRCELL-1:NRBC:${UL_DATA_SPLIT_RECONF_LTE_SUCC}=1
...    NRCELL-1:NRBC:${UL_DATA_SPLIT_RECONF_LTE_ATT}=1

###counter on DU
###1200 counter
${NUM_MEET_UL_RL_OUTAGE_THLD}    M55308C12001    #Number of times meet the UL RL outage thresholds

@{PM_Counters_Check_DU}
...    NRCELL-1:NCELA:${NUM_MEET_UL_RL_OUTAGE_THLD}>=1


${SA_Capa_perUE_Full}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C4700FB8D85181AC11
...    84341020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00
...    05800702A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6
...    000001FD8000000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50
...    B0381C3C17003FF001C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E4
...    39F51CF9863CA1607038784FFF800003FFE0000016001C00F78789A001C4100000216020541E1400071180
...    0000858158788C001C41000006160561E14000710400000858158789A001C46000002160562E2300071040
...    038820000142C0AC3C28000E268000060B02B17134003882001C28000008160562E26800711800388C0000
...    082C0AC5C28000E20800711800001058158B850001C41000E208000020B02B17134003882001C460000041
...    60562E14000711800388C0000082C0AC5C4D000E2300070A000002058158788C001C46000006160401C046
...    8051013602083A5D83E14489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF
...    870A040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D
...    8E7C08902040D8E7C0850206C73E000B878C6318C6318C6318C630F413003C00281C1401C0C01D00E000C0
...    480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200
...    80200800006004000038020010000000400004002000024010000060080000A00400005802001024090040
...    0006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282
...    000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004C
...    B29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A8345
...    5298AA4D154062A8145526AAA0F1414178095028140A05028140A05028140A05028140A050281400182020
...    180300801002101002008040300610080100202018030080600C10100C0180403006100801002020180300
...    80100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303
...    236383A3E424A4C4E5052545A5E828305A
${Capa_LTE}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881789818070A00038820
...    000002C040BC4C0C03882001C46000002160205E360601C46000E208007104000010580817898180713400385000000C2C040804808D00
...    A001C041809A26002E41E24E8913639F0E24E8913639F0E24E8913639F0E24E8913639F0E24E8912639F469D1224498E7D127448931CF8
...    30082000080404008020100C01840001008080100202018030C0002010100C01804030060100C018400010080801004020040100000000

*** Test Cases ***
5GC001200_Verify_UE_UL_data_traffic_is_reconfigured_from_NR_only_to_LTE_only_is_successful
    [Documentation]
    ...    1. The purpose of this test case is to:
    ...        a. check the gNB behavior when reconfigure from NR to LTEOnly due to a UL Radio Link Outage Indication. -5GC001200
    ...    2. Test Case Steps:
    ...         a. active 1200 related NIDDs in full commission
    ...         b. config UL Radio Link Outage parameters via egate command
    ...         c. NSA UE attach and start traffic
    ...         d. activate CSI Report Override, PHR Override testmodes
    ...         e. NSA UE detach
    ...         f. deactivate DynUlDataSplitMode
    ...         g. NSA UE attach and start traffic
    ...    3. Expected Results:
    ...         Step c: NSA UE attach successfully and traffic should be OK
    ...         Step d: trigger SgNBModificationConfirm, UL traffic is switch from 5G to 4G and DL traffic is still in 5G
    ...         Step e: NSA UE detach successfully
    ...         Step f: delta commisonn on CU and DU successfully
    ...         Step g: NSA UE attach successfully and traffic should be OK, check no drx setup
    ...         check counters on CU: M55146C01001, M55146C01002
    ...         check counters on DU: M55308C12001, M55308C11001, M55308C11002
    [Tags]    QC_190148
    Clear Counter Files
    Config PHR Profile At Enb Side
    NSA UE Attach and Traffic
    Activate PHR Testmode
    Check UL Traffic Split To LTE And DL Traffic Still In 5G
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_1200/a2a.ini    wait_string=UEContextModificationResponse::4
    Check Counters
    Deactivate DynUlDataSplitMod And Verify UE Attach and Traffic OK
    Release Ues    ue_id=${NSA_UE_ID}    ue_type=nsa

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
    Check Counters Du Aic    pm_counters_expression=${PM_Counters_Check_DU}    wait=False

Config PHR Profile At Enb Side
    Set Suite Variable    ${cmd_1}    phr_override_testmode_nr profile_id=1 phr_start=-23 phr_min=-23
    Set Suite Variable    ${cmd_2}    phr_max=40 phr_step_size=-63 phr_period=1 pc_max=33 phr_mode=Fixed
    Execute Egate Command    ${cmd_1} ${cmd_2}
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
    sleep    10s    sleep for AP command take effect

NSA UE Attach and Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA
    Send Throughput    ue_id=${ue_id}
    Verify Throughput    ue_id=${ue_id}

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

Activate PHR Testmode
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=phr_override action=activate profile_id=1 scell=5
    ...    pass_regexp=Sending SgNB Modification Confirm    timeout=600

Check UL Traffic Split To LTE And DL Traffic Still In 5G
    [Arguments]    ${ue_id}=${NSA_UE_ID}    ${sleep_time}=15s
    Execute Egate Command    bearer_stats_clear ue=${ue_id} id=2
    sleep    ${sleep_time}    sleep for Tput stable
    &{transmitter_stats}    Ap Get Bearer Stats Info    ue=${ue_id}    id=2    dir=ul    dc_cell_group=scg
    Should Be True    &{transmitter_stats}[Total packets sent]==0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=mcg    rate_type=ave
    Should Be True    ${ul_throuput}/1000>4.5
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Detach UE
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Release Ues    ue_id=${ue_id}    ue_type=nsa

Deactivate DynUlDataSplitMod
    Delta Commission Parameters DU    ${DELTA_PARAMS_IN_SCF_DU}

Stop Traffic
    [Arguments]    ${ue_id}=${NSA_UE_ID}
    Execute Egate Command    trf_data_stop ue=${ue_id}    pass_regexp=Traffic was stopped

Deactivate DynUlDataSplitMod And Verify UE Attach and Traffic OK
    Detach UE
    Deactivate DynUlDataSplitMod
    NSA UE Attach and Traffic
    Stop Traffic
