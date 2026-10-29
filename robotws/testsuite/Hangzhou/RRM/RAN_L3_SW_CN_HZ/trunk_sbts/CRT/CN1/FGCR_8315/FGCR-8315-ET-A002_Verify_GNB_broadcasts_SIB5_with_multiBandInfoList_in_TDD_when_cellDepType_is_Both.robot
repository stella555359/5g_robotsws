*** Settings ***
Documentation     author: Ge Nanxiao
...               contact: nanxiao.ge@nokia-sbell.com
...               squad group: 5G SW ENG CN2 T&A
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    master_classicalbts_all    STATE_CONFIGURED    5G_RAN_TDD    FGCR-8315
...    CRT    team-CN2    Classical    CRT_HNZ    RRM_Call_handling    FR1    IPV4    PRI-High
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    Owner-Nanxiao.Ge    release-SBTS22R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=40640
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eNodeBId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-1:ePSTrackingAreaCode=201
...    MRBTS-1/NRBTS-1/NRADJECELL-1:earfcnValue=40640
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
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=38,4,41,38
@{list_2}
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=41,4,37,38

*** Test Cases ***
FGCR-8315-ET-A002_Verify_GNB_broadcasts_SIB5_with_multiBandInfoList_in_TDD_when_cellDepType_is_Both
    [Documentation]    this case is to check GNB broadcase SIB5 with multibandInfolist in TDD when both \
    [Tags]    FGCR-8315-ET-A002    QC_62323
    start to capture wireshark log    8315_002
    delta commission parameters    ${list_2}
    Check Wireshark Log    ${CURDIR}${/}a2a_8315_002${/}a2a_8315_002.ini    name=8315_002    wait_string=successfulOutcome.procedureCode::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2
