*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    CRT    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-yuhua.zhu    release-5G19B
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:fiveGsTac=1
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:trackingAreaId=300
...    MRBTS-1/NRBTS-1/TRACKINGAREA-300:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    MRBTS-1/NRBTS-1/NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300

*** Test Cases ***
5GC002145-ET-E008 Successful cell deletion with associated TAC which slice is supported by AMF
    [Documentation]
    ...    This user scenario describes the successful SA slice configuration update via new TAC and NG update procedure,
    ...    when slice is supported by the AMF.
    [Tags]    QC_83110
    Lock And Unlock Cell
    Check Configuration Update

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri

Lock And Unlock Cell
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Locked
    Sleep    2s    # wait commission complete
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Locked
    Delta Commission Parameters    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked
    Sleep    2s    # wait commission complete and cell setup
    Object Should Exist    MRBTS-1/NRBTS-1/NRCELL-2:administrativeState=Unlocked

Check Configuration Update
    Check WireShark Log    ${CURDIR}${/}a2a_E008${/}a2a.ini    wait_string=RANConfigurationUpdateAcknowledge::4
