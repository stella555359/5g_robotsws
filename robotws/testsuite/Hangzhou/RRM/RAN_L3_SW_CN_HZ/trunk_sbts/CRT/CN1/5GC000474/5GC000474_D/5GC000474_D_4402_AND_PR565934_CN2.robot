*** Settings ***
Documentation     this case is the 5GC000474_D_4402 for AP testline
...               \n Author: peach.fu@nokia-sbell.com
...               \n Please do not edit the existing keywords in this file without testing.
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he   release-SBTS22R2    CRT
Resource          ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{FAULTS_EXCLUDED_CHECKING}    7300    7107

@{delete useless cell}
...    delete:MRBTS-1/NRBTS-1/NRCELL-2
...    delete:MRBTS-1/NRBTS-1/NRCELLGRP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3
...    delete:MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4
...    delete:MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
...    NRDU-1:refNrCellGroup=0
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs

@{x2LinkSupervisionTmr}
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=1

@{LOCKX2LINK}
...    NRBTS-1/LTEENB-0:x2LinkLock=locked

@{UNLOCKX2LINK}
...    NRBTS-1/LTEENB-0:x2LinkLock=unlocked

#X2 fault
${7300_fault_name}    No X2 link available
${7300_fault_id}    7300
${7300_alarm_id}    7107


${X2_SHUTDOWN_LOCKED}    M55110C00007
${X2_RESET_REQUEST_SENT}    M55110C00011
${X2_RESET_RESPONSE_RECEIVED}    M55110C00012
${X2_UEREL_OUTGOING_RESET}    M55110C00020

@{4402_COUNTER}
...    ${X2_SHUTDOWN_LOCKED}=1
...    ${X2_RESET_REQUEST_SENT}=1
...    ${X2_RESET_RESPONSE_RECEIVED}=1
...    ${X2_UEREL_OUTGOING_RESET}=1

@{PR565934_COUNTER}
...    ${X2_SHUTDOWN_LOCKED}=1
...    ${X2_RESET_REQUEST_SENT}=1

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
5GC000474_D_4402_Test_Outgoing_X2_Reset_due_to_Locking_of_LTEENB_Object_with_X2_Reset_Response_Received
    [Tags]    QC_60647    4402
    Set X2AP To GNB And Clear Counter Files
    Delta Commission x2LinkSupervisionTmr
    UE Attach And Lock X2 Link
    Check X2 Link Alarm
    Check Counters    ${4402_COUNTER}
    Check Egate log    4402
	UE Detach

5GSW_CP_EDA_5GC000474_PR565934_lock_lteenb_X2AP-ResetReq
    [Documentation]
    ...    [Purpose]:For EDA PR565934. The purpose of this test case is to check
    ...    X2APResetReq send out with M55110C00011 pegged value when lock lteenb with a cell locked already
    ...    [Configuration]: 1 classical cmWave gNB, 1 Airphone, 1 Cell, NSA
    ...    [Cover Feature]: 5GC000474
    [Tags]    QC_90831    565934
    Set X2AP To GNB And Clear Counter Files
    Delta Commission x2LinkSupervisionTmr
    UE ATTACH
    Lock Cell1
    Lock X2 Link
    Check X2 Link Alarm
    Check Counters    ${PR565934_COUNTER}
    Check Egate log    PR565934
	UE Detach

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Modify Cfg
    Update Cfg  ue_param id=31-39 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}

Set X2AP To GNB And Clear Counter Files
    Execute Egate Command    enb_x2_link_up enb=1 target=2  ENB-1: X2AP Link with GNB-2
    Clear Counter Files

Delta Commission x2LinkSupervisionTmr
    Delta Commission Parameters    ${x2LinkSupervisionTmr}

UE Attach And Lock X2 Link
    UE ATTACH
    Lock X2 Link

UE ATTACH
    Execute Egate Command    ue_change_location id=31 enb=1 cell=1
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...  UE31: Proxy \\(eNB 2 cell 1\\) reported successful RA

Lock X2 Link
    Delta Commission Parameters    ${LOCKX2LINK}

Check X2 Link Alarm
    ${fault7300}  Create List    fault_id=${7300_fault_id}    alarm_id=${7300_alarm_id}    severity=Major
    ...    fault_name=${7300_fault_name}
    Fm Fault Should Be Raised    ${fault7300}    5min

Unlock X2 Link
    Delta Commission Parameters    ${UNLOCKX2LINK}

Check Egate log
    [Arguments]   ${A2A_FILE}=4402
    Check RRC log    ${CURDIR}${/}a2a_${A2A_FILE}${/}a2a.ini
    RRC SHOULD CONTAIN    Bearer-type change from SCG-split to MCG is successful

UE Detach
    Execute Egate Command    ue_detach id=31    UE IS OFF

Test Teardown And Stop Capture Logs
    Unlock X2 Link
    Common Test Teardown And Stop Capture Logs
