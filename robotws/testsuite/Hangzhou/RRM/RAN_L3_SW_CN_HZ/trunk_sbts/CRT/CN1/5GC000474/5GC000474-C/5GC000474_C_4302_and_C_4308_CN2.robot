*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107    7101    7305

@{Online_Param}
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=1
...    MRBTS-1/NRBTS-1:shutdownNogNBCellTmr=0
...    MRBTS-1/NRBTS-1:x2EnDcCfUpNbInfoBackOffTmr=0
...    MRBTS-1/NRBTS-1/NRCELL-1:msg1FrequencyStart=13

#PM counter

${ENDC_X2_SETUP_REQUEST_RECEIVED}      M55110C00003
${ENDC_X2_SETUP_RESPONSE_SENT}         M55110C00004
${X2_SHUTDOWN_DETECTED}                M55110C00002

@{ENDC_X2_SETUP}
...    ${ENDC_X2_SETUP_REQUEST_RECEIVED}=1
...    ${ENDC_X2_SETUP_RESPONSE_SENT}=1

@{X2_SHUTDOWN_DET}
...    ${X2_SHUTDOWN_DETECTED}=1

#X2 fault
${7300_fault_name}    No X2 link available
${7300_fault_id}    7300
${7300_alarm_id}    7107

${ue_nr_capabilities}  SEPARATOR=
...    ED007000479A4BBF5FFFFEF8001BD409A00CFDBFCB98AD7FFBF900001F53FFFFD1000000E
...    77EF3FFF3FFFEC0001F78017FFE00002C7807E290401BFFEF0BFFEBC00E54D00158800000000023003CAA08

${ue_eutra_nr_capabilities}  SEPARATOR=
...    BD1BA063058380713400000018062B000060400C1001830030600E268000010300C160801
...    C4D000006060182C000389A00000C0C03058100713400001018060B0600E2680000203004
...    8BC500C200020100801002570010040200804010080201004020080401008020100402008
...    0401008020100402010040200804010080000004020080400000000000402000000000000
...    0000402008040100802010000000804010080000000000080400000000000000008040100
...    8020100402008040000002010040200804000000000000000080400000000000000000000
...    1009C00202008040080801010000000404008080000000000040400000000000000004020
...    1004010080201004020080401008020100402008040100802010040200808020100202000
...    0000808010100000004040000000000020200000000000101004020040400808000000202
...    0040400000000000202004040000000000020200000000000000002027001008020100402
...    0000001008020100000008040000000000040200000000000201004020080400000020100
...    4020000001008000000000008040000000000040100802010040200804010080201004020
...    0804010080201004020080401008040100802010000000804010080000004020000001008
...    00000040200000000000201000000000001009C0020200404008080101002020000000808
...    0101002020000000000010100000004040080801010020200404000000101002020040400
...    0000000002020000000808010100202004040080800000020200404008080000000000040
...    4000000100802010040200804010080201004020080401008020100402008040100802010
...    0402008040100804017001008010100000004040080800000000000000008080000000000
...    0000000000201002020000000808010100000000000000001010000000000000000000004
...    0200404000000101002020000000000000000202000000000000000000000804008080000
...    002020040400808000000000004040000001010020200000000000000002020000000809C
...    40080180100300200600400C0080180100300200600400C0080180100300200600400C008
...    0180100300200600400C0080180100300200600400C0080180100300200600400C0080180
...    100300200600400C0080180100300200600400C0080180100300200600400C00801801003
...    00200600400C0080180100300200600400C0080180100300200600400C008018010030020
...    0600400C0080180100300200600400C008010800040202004008400040101002004


*** Test Cases ***
5GC000474_C_4302_Test_ENDC_X2_Setup_Procedure_on_an_X2_Link_already_Established
    [Tags]    QC_60653    4302
    Set X2AP To GNB
    Clear Counter Files
    UE attach to gNB cell  31  1
    Send And Verify Throughput
    Rebuild X2 Link
    Verify GNB Throughput and ENB Throughput
    check counters  ${ENDC_X2_SETUP}
    Check Wireshark Log  ${CURDIR}${/}a2a_4302${/}a2a.ini
    UE detach

5GC000474_C_4308_Test_X2_Link_Detection_Failure_with_SCTP_Association_Unavailable_Initiated_by_eNB
    [Tags]    QC_60649    4308
    Set X2AP To GNB
    OnlineParamChange
    Clear Counter Files
    UE attach to gNB cell  31  1
    Reset LTEEMU
    check counters  ${X2_SHUTDOWN_DET}
    Check X2 Alarm

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=31-39 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Set X2AP To GNB
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

UE attach to gNB cell
    [Arguments]  ${ue_id}=1   ${target_cell}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=1 cell=1
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...  UE${ue_id}: Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA

Send And Verify Throughput
    Execute Egate Command    data_trf_start ue=31 id=2 dir=dl mbps=5    UE 31: UDP DL
    Verify Throughput

Verify Throughput
    [Arguments]  ${sleep_time_for_tput}=60s
    sleep    ${sleep_time_for_tput}    sleep for Tput stable
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throuput}/1000>4.5

Rebuild X2 Link
    Execute Egate Command    enb_x2_link_up enb=1 target=2  restarting X2 link with eNB-2

Verify GNB Throughput and ENB Throughput
    [Arguments]  ${sleep_time_for_tput}=60s
    sleep    ${sleep_time_for_tput}    sleep for Tput stable
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}==0.0
    Verify Throughput

OnlineParamChange
    #wait until keyword succeeds    3 min    10 sec    cells should be on air
    Delta Commission Parameters    ${Online_Param}
    #wait until keyword succeeds    3 min    10 sec    cells should be on air

Reset LTEEMU
    Execute Egate Command    re    pass_regexp=CHANGE STATE: INIT    timeout=60    sleep_time=5

Check X2 Alarm
    ${fault7300}  Create List    fault_id=${7300_fault_id}    alarm_id=${7300_alarm_id}    severity=Major
    ...    fault_name=${7300_fault_name}
    Fm Fault Should Be Raised    ${fault7300}    40

UE detach
    Execute Egate Command    ue_detach id=31    UE IS OFF
