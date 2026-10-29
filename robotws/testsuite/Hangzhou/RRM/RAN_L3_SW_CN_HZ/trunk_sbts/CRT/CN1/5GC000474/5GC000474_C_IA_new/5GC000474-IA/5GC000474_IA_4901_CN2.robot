*** Settings ***
Documentation     this case is the 5GC000474_IA_4901 for AP testline
...               \n 5GC002073 is covered by the case.
...               \n Author: peach.fu@nokia-sbell.com
...               \n Please do not edit the existing keywords in this file without testing.
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG2    owner-junhui.he    release-5G20A    CRT
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
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

${UE_ID}    11
${CELL_ID}    1
${BEARER_ID}    2
${GNB_ID}    2
${X2_UEREL_INC_PARTIAL_RESET}    M55110C00027
${X2_PARTIAL_RESET_REQ_RCVD}    M55110C00029
${X2_PARTIAL_RESET_CONFIRM_SENT}    M55110C00030
${Fault_ID}    7300
${Alarm_detail}    No X2 link available

@{PM_Counters_Check}
...    ${X2_UEREL_INC_PARTIAL_RESET}>0
...    ${X2_PARTIAL_RESET_REQ_RCVD}>0
...    ${X2_PARTIAL_RESET_CONFIRM_SENT}>0

*** Test Cases ***
5GC000474_IA_4901_Test_incoming X2 Partial Reset procedure on an X2 link already established successfully
    [Tags]    QC_60654
    Clear Counter Files
    UE Attach
    Incoming X2 Partial Reset
    Check Counters    ${PM_Counters_Check}
    Check Egate Log For X2 Partial Reset And UE Release
    Analysis The Wireshark Log For 4901
    Check No Alarms For No X2 Link
	

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=1

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

UE Attach
    Execute Egate Command    ue_attach id=${UE_ID}    pass_regexp=UE IS ACTIVE    timeout=300
    ${cmd}        Catenate        ue_dc_enb_start ue=${UE_ID} target_gnb=${GNB_ID} target_cells=${CELL_ID}
    ...    bearer=${BEARER_ID} type=split_scg
    Execute Egate Command        ${cmd}        pass_regexp=reported successful RA        timeout=300
    Verify If Attach Passed
	
Verify If Attach Passed
    Wait Until Keyword Succeeds    60sec    5sec    Ensure UE Attach Passed

Ensure UE Attach Passed
    Apl3 Should Contain    Sm User Ue Connection Established Ind message status OK

Incoming X2 Partial Reset
    Execute Egate Command    link_x2_reset from=1 to=2 ue=${UE_ID}    pass_regexp=(successfulOutcome)    timeout=120sec
    Sleep    10sec    Reason=wait the x2 partial reset

Check Egate Log For X2 Partial Reset And UE Release
    RRC Should Contain    Bearer-type change from SCG-split to MCG is successful
    RRC Should Contain    ENDCPartialResetRequired
    RRC Should Contain    ENDCPartialResetConfirm

Analysis The Wireshark Log For 4901
    UE detach
    Check Wireshark Log    ${CURDIR}${/}a2a_IA_4901${/}a2a.ini    wait_string=ENDCPartialResetConfirm::1

Check No Alarms For No X2 Link
    ${fault}    Create List    fault_id=${Fault_ID}    fault_name=${Alarm_detail}
    Fm Fault Should Be Cleared    ${fault}    120s

UE detach
    Execute Egate Command    ue_detach id=${UE_ID}    UE IS OFF