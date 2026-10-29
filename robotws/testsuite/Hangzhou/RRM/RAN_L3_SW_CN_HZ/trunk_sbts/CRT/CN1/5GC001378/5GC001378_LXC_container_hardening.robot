*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G19B
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{snapshotUploadDestinationForFault6450}

@{snapshotUploadDestinationForFault6450}
...    delete:MNLENT-1/TRBLCADM-1:faultSnapshotTriggers

@{FAULTS_EXCLUDED_CHECKING}    6450

*** Test Cases ***
5GC001378-ET-A001_CP_IF_start_using_btssw_user_after_GNB_up
    [Documentation]    The purpose of this test case is to check following scenarios:
    ...    1) cp_if process started by user "btssw"
    ...    2) cp_rt process started by user "btssw"     CB006048
    ...    [Configuration]: 1 classical cmWave gNb, 1 cell
    ...    [Cover Feature]: 5GC001378
    [Tags]    QC_86740    Classical    CRT_HNZ    5GC001378    FR1    IPV4     Owner_yejing    PRI-High    CN2
    Check If Started By Btssw    cp_if
    Check If Started By Btssw    cp-rt
    Check If Started By Btssw    cp_sctp

#5GC001378-ET-A003_CP_IF_restart_automatically
#    [Documentation]    The purpose of this test case is to check following scenarios:
#    ...    1) cp_if process started by user "btssw" after gNB restart
#    ...    2) cp_sctp process started by user "btssw" after gNB restart
#    ...    [Configuration]: 1 classical cmWave gNb, 1 cell
#    ...    [Cover Feature]: 5GC001378
#    [Tags]    QC_62351    Classical    5GC001378    FR1
#    ...    IPV4    Owner_yejing    PRI-High    CN2
#    Reboot Gnb And Airphone
#    Wait Until Keyword Succeeds    15min    30s    Check If Started By Btssw    cp_if
#    Wait Until Keyword Succeeds    15min    30s    Check If Started By Btssw    cp_sctp

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Reboot Gnb And Airphone
    Reboot Bts