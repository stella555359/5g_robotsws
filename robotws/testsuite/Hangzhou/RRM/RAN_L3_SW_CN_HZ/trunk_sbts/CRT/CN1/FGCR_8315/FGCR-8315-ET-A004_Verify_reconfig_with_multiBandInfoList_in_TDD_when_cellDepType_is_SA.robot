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
...    MRBTS-1/NRBTS-1:gNbCuType=SA
...    MRBTS-1/NRBTS-1:x2LinkSupervisionTmr=0
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2:cellDepType=SA
...    delete:NRCELL-1:configuredEpsTac
...    delete:NRCELL-2:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=40640
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:carrierFreq=2150
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
...    MRBTS-1/NRBTS-1/NRADJECELL-2:eUtraMultibandInfoList=2,3,4,5,6,22,23,24
...    MRBTS-1/NRBTS-1/NRADJECELL-2:eNodeBId=2
...    MRBTS-1/NRBTS-1/NRADJECELL-2:ePSTrackingAreaCode=202
...    MRBTS-1/NRBTS-1/NRADJECELL-2:earfcnValue=2150
...    MRBTS-1/NRBTS-1/NRADJECELL-2:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-2:physCellId=202
...    MRBTS-1/NRBTS-1/NRADJECELL-3:eUtraMultibandInfoList=37,38,39,44,41,42,43,45,46
...    MRBTS-1/NRBTS-1/NRADJECELL-3:eNodeBId=3
...    MRBTS-1/NRBTS-1/NRADJECELL-3:ePSTrackingAreaCode=203
...    MRBTS-1/NRBTS-1/NRADJECELL-3:earfcnValue=40640
...    MRBTS-1/NRBTS-1/NRADJECELL-3:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJECELL-3:physCellId=203
...    MRBTS-1/NRBTS-1/NRADJECELL-2:ecgiPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-2:ecgiPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-2:ecgiPlmn:mncLength=2
...    MRBTS-1/NRBTS-1/NRADJECELL-2:enbPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-2:enbPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-2:enbPlmn:mncLength=2
...    MRBTS-1/NRBTS-1/NRADJECELL-3:ecgiPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-3:ecgiPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-3:ecgiPlmn:mncLength=2
...    MRBTS-1/NRBTS-1/NRADJECELL-3:enbPlmn:mcc=262
...    MRBTS-1/NRBTS-1/NRADJECELL-3:enbPlmn:mnc=3
...    MRBTS-1/NRBTS-1/NRADJECELL-3:enbPlmn:mncLength=2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:allowedMeasBw=mbw100
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:pMaxEutra=23
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:presenceAntPort1=false
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:qQualMin=-34
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:qRxLevMin=-22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:threshXHigh=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:threshXLow=0
...    @{list_1}

@{list_1}
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=33,34,35,36,41
@{list_2}
...    MRBTS-1/NRBTS-1/NRADJECELL-1:eUtraMultibandInfoList=33,34,35,36,41,11,12,13

*** Test Cases ***
FGCR-8315-ET-A004_Verify_reconfig_with_multiBandInfoList_in_TDD_when_cellDepType_is_SA
    [Documentation]    this case is to check GNB broadcase SIB5 with multibandInfolist use reconfig function \
    [Tags]    FGCR-8315-ET-A004    QC_62321
    start to capture wireshark log    8315_004
    delta commission parameters    ${list_2}
    Check Wireshark Log    ${CURDIR}${/}a2a_8315_004${/}a2a_8315_004.ini    name=8315_004    wait_string=successfulOutcome.procedureCode::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    ue_count=2
