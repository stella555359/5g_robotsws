*** Settings ***
Documentation     author: Ge Nanxiao
...               contact: nanxiao.ge@nokia-sbell.com
...               squad group: 5G SW ENG CN2 T&A
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_FDD    SBTS00    master_classicalbts_all    STATE_CONFIGURED    5G_RAN_FDD    FGCR-8315
...    CRT    team-CN2    Classical    CRT_HNZ    RRM_Call_handling    FR1    IPV4    PRI-High
...    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    Owner-Nanxiao.Ge    release-SBTS22R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=2150
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=201
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=2150
...    MRBTS-1/NRBTS-1/NRADJECELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:physCellId=201
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ecgiPlmn:mncLength=2
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-1:enbPlmn:mncLength=2
...    @{list_1}

@{list_1}
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=4,4,66,38
@{list_2}
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=4,5,66,38

*** Test Cases ***
FGCR-8315-ET-A003_Verify_GNB_broadcasts_SIB5_with_multiBandInfoList_in_FDD_env
    [Documentation]    this case is to check GNB broadcase SIB5 with multibandInfolist in FDD when SA
    [Tags]    FGCR-8315-ET-A003    QC_62324
    start to capture wireshark log    8315_003
    delta commission parameters    ${list_2}
    Check Wireshark Log    ${CURDIR}${/}a2a_8315_003${/}a2a_8315_003.ini    name=8315_003    wait_string=successfulOutcome.procedureCode::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    ue_count=2
