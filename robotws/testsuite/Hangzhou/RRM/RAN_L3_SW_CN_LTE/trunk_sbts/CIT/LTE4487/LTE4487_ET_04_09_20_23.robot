*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS    CRT
...               Team-DEVHZ5_FT1    release-FL18A    owner-ha.zheng@nokia-sbell.com&chengmao.sun@nokia-sbell.com
...               owner-jie.1.zhu@nokia-sbell.com
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_RRCtrigger_ACB}
...    @{PARAMS_FOR_RACHtrigger_ACB}
...    LNBTS-${BTS_INFO.ID}:actAcBarringACS=true
...    MNL-1/MNLENT-1/FMCADM-1:actCategoryAlarms=false
...    LNCEL:inactivityTimer=1000

@{PARAMS_FOR_RRCtrigger_ACB}
...    LNBTS-${BTS_INFO.ID}:actAcBarringRrcConn=CellOnly
...    LNCEL/SIB-0:acbNumRrcConnCellStart=10
...    LNCEL/SIB-0:acbNumRrcConnCellStop=1
...    LNCEL/SIB-0:acbUpdateTimer=${acbUpdateTimer}
...    LNCEL/SIB-0:acbNumSteps=1
...    LNCEL/SIB-0:acbRrcConnCellStartTimer=30
...    LNCEL/SIB-0:acbRrcConnCellStopTimer=30
...    LNCEL/SIB-0:acbProfileId=1
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMax:probFac=30%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMax:probFac=25%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMax:probFac=20%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMax:probFac=15%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMax:probFac=10%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMin:barTime=8s|probFac=90%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMin:barTime=8s|probFac=90%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMin:barTime=8s|probFac=90%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMin:barTime=8s|probFac=90%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMin:barTime=8s|probFac=90%
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270
...    LNCEL:inactivityTimer=1000
# RRC trigger ACB rrc num=round(10*270)=27

@{PARAMS_FOR_RACHtrigger_ACB}
...    LNBTS-${BTS_INFO.ID}:actAcBarringRrcReq=true
...    LNCEL/SIB-0:acbNumRrcReqStart=2
...    LNCEL/SIB-0:acbNumRrcReqStop=1
...    LNCEL/SIB-0:acbRrcReqFactor=0.25
...    LNCEL/LNCEL_FDD-0:maxNumActUE=10
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUeDc=10
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe3c=10
...    LNCEL/LNCEL_FDD-0:maxNumCaConfUe=10
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=260
...    LNCEL-${CELL1_INFO.ID}/LNCEL_FDD-0:actAutoPucchAlloc=false

${BTS_INFO.ID}    1
${CELL1_INFO.ID}    1
${acbUpdateTimer}    30

@{Precondition_For_Case20}
...    LNBTS-${BTS_INFO.ID}:actAcBarringRrcConn=CellOnly
...    LNCEL/SIB-0:acbNumRrcConnCellStart=2
...    LNCEL/SIB-0:acbNumRrcConnCellStop=1
...    LNCEL/SIB-0:acbUpdateTimer=${acbUpdateTimer}
...    LNCEL/SIB-0:acbNumSteps=4
...    LNCEL/SIB-0:acbRrcConnCellStartTimer=30
...    LNCEL/SIB-0:acbRrcConnCellStopTimer=30
...    LNCEL/SIB-0:acbProfileId=1
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMax:probFac=10%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMax:probFac=10%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMax:probFac=10%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMax:probFac=15%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMax:barAC=0|barTime=8s
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMax:probFac=15%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarCsfbOcAutoMin:barTime=8s|probFac=80%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVideoOcAutoMin:barTime=8s|probFac=80%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarMMTelVoiceOcAutoMin:barTime=8s|probFac=80%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarOcAutoMin:barTime=8s|probFac=85%
...    LNBTS-${BTS_INFO.ID}/ACBPR-1:acBarSigAutoMin:barTime=8s|probFac=85%
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=270
...    LNCEL:inactivityTimer=1000
...    LNBTS-${BTS_INFO.ID}:actAcBarringCFR=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=false
# RRC trigger ACB rrc num=round(2*270)=5
...    LNBTS-${BTS_INFO.ID}:actAcBarringRrcReq=false

${NUM_ACB_MO_DATA_P15}    M8057C13
${NUM_ACB_MO_DATA_P30}    M8057C16
${NUM_ACB_MO_DATA_P50}    M8057C18
${NUM_ACB_MO_DATA_P70}    M8057C20
${NUM_ACB_MO_DATA_P85}    M8057C23
${NUM_ACB_MMTEL_VOICE_P10}    M8057C44
${NUM_ACB_MMTEL_VOICE_P20}    M8057C46
${NUM_ACB_MMTEL_VOICE_P25}    M8057C47
${NUM_ACB_MMTEL_VOICE_P60}    M8057C51
${NUM_ACB_MMTEL_VOICE_P80}    M8057C54
${NUM_ACB_MMTEL_VID_P10}    M8057C60
${NUM_ACB_MMTEL_VID_P25}    M8057C63
${NUM_ACB_MMTEL_VID_P60}    M8057C67
${NUM_ACB_MMTEL_VID_P70}    M8057C68
${NUM_ACB_MMTEL_VID_P80}    M8057C70
${NUM_ACB_MO_SIG_P10}    M8057C28
${NUM_ACB_MO_SIG_P15}    M8057C29
${NUM_ACB_MO_SIG_P30}    M8057C32
${NUM_ACB_MO_SIG_P40}    M8057C33
${NUM_ACB_MO_SIG_P70}    M8057C36
${NUM_ACB_MO_SIG_P85}    M8057C39
${NUM_ACB_CSFB_P10}    M8057C76
${NUM_ACB_CSFB_P25}    M8057C79
${NUM_ACB_CSFB_P30}    M8057C80
${NUM_ACB_CSFB_P60}    M8057C83
${NUM_ACB_CSFB_P75}    M8057C85
${NUM_ACB_CSFB_P80}    M8057C86
${TIME_ACB_OVL}    M8057C0
${TIME_ACB_RRC}    M8057C3
${TIME_ACB_RACH}    M8057C8
${TIME_ACB_CONN_FAIL_RATE}    M8057C9

@{PM_COUNTERS_Case20}
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P15}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P30}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P70}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P85}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P15}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P30}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P70}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P85}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P10}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P25}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P60}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P80}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P10}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P25}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P60}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P80}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P10}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P25}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P60}<=900
...    every LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P80}<=900
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P15}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P30}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P70}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_DATA_P85}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P15}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P30}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P70}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MO_SIG_P85}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P10}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P25}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P60}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VOICE_P80}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P10}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P25}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P60}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_MMTEL_VID_P80}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P10}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P25}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P60}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${NUM_ACB_CSFB_P80}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${TIME_ACB_OVL}=0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${TIME_ACB_RRC}>0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${TIME_ACB_RACH}=0
...    LNCEL-${CELL1_INFO.ID}/MCC-262/MNC-03:${TIME_ACB_CONN_FAIL_RATE}=0
${PM_SPEED_UP_FLAG}    ${True}

*** Test Cases ***
LTE4487_ET_20_23_AACB Counters RRC_group19 and Alarm checking
    [Documentation]    Because the PM counters waiting time has changed back to 15 minutes,
    ...    update the verification threshold of counters related to time sampling.
    [Tags]    owner-chengmao.sun@nokia-sbell.com
    OnlineParamChange    ${Precondition_For_Case20}
    Cells should be onair
    clear counter files
    Attach 5 legacy UEs at cell1
    ${fault6356}    create list  Severity=minor  fault_id=6356  fault_name=Automatic access class barring is active  alarm_id=7655
    ...    alarm_name=CELL NOTIFICATION
    ...    alarming_object=LNCEL-1
    Fm Fault Should Be Raised    ${fault6356}    timeout=100
    Check Counters    ${PM_COUNTERS_Case20}
    Release All UEs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=6

OnlineParamChange
    [Arguments]    ${Online_Param}=${EMPTY}
    Delta Commission Parameters    ${Online_Param}

Attach 5 legacy UEs at cell1
    Execute uex command    ue_attach id=1,2,3,4,5 selected_plmn=262:03 cell=1

Wait For ACB Update
    sleep    ${${acbUpdateTimer}*4}
