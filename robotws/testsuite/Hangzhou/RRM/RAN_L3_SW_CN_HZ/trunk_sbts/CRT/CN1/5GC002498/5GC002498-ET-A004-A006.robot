*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...    owner-Owner_Junhui.He    release-SBTS22R3
Resource          ../../../../resources/DevHZ5_resource.robot

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
@{PARAMS_1}    NRBTS-1/NRCELL-1:cellDepType=NSA
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:trackingAreaDN
...    NRCELL:actVoNR=false
...    NRCELL:actEmergencyCall=false
${UE_ID}    31

*** Test Cases ***
5GC002498-ET-A004_Verified F1 reset trigger X2 reset
    [Documentation]    This case test scenario when F1 reset triggers X2 reset
    [Tags]    QC_61175
    Start To Capture Wireshark Log     F1Reset
    Attach UE and setup EN-DC
    Trigger F1 link reset by lock cell
    Trigger F1 link setup and wait eNB onair
    Check F1 reset trigger X2 reset


5GC002498-ET-A006_Verified X2 reset trigger f1 reset
    [Documentation]    This case test scenario when X2 reset triggers F1 reset
    [Tags]    QC_61177
    Start To Capture Wireshark Log     X2Reset
    Attach UE and setup EN-DC
    Trigger X2 link reset by locked X2 link
    Analysis X2 reset trigger F1 reset log

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Perform Steps After Onair
    Delta Commission Parameters    ${delete useless cell}

Attach UE and setup EN-DC
    Execute Egate Command    ue_attach id=${UE_ID} profile=1    UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg    successful RA
    ...    timeout=20s

Trigger F1 link reset by lock cell
    Delta Commission Parameters    ${PARAMS_1}
    sleep    300s    #wait for cells to be onair
    Lock Cell1
    #Stop Capture Wireshark Log    F1Reset

Check F1 reset trigger X2 reset
    Check WireShark Log    ${CURDIR}${/}a2a_TA04${/}TA04.ini    name=F1Reset    wait_string=UEContextReleaseComplete::1

Trigger X2 link reset by locked X2 link
    Execute Egate Command    x2_link_reset from=1 to=2    Bearer-type change from SCG-split to MCG is successful    timeout=20s

Trigger F1 link setup and wait eNB onair
    Unlock Cell1
    wait until keyword succeeds    3 min    30 sec    Cells Should Be Onair    check_sib=${False}

Analysis X2 reset trigger F1 reset log
    sleep    10s    #sleep for capture wireshark
    #Stop Capture Wireshark Log    X2Reset
    Check WireShark Log    ${CURDIR}${/}a2a_TA06${/}TA06.ini    name=X2Reset    wait_string=UEContextReleaseComplete::1
