*** Settings ***
Documentation     INTRODUCTION: With the introduction of LTE3056 on XL17, eNB should support the broadcast of System
...    Information Block Type 16.
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LP12_CUS
...               release-xL17    owner-yin.zhang
Resource          ../../../resources/DevHZ5_resource.robot
Library           testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE3056.resources.mobility_parameters_verification

*** Variables ***
${eutra_capabilities}    SEPARATOR=
...    458001E0008206102860E2048A163069022489942A58B983268D9C3A7870F000105F00443214C74254B6360E12161A2629CF80818287888B8
...    C8D8E8F00020000
${cdma2000_capabilities}    123456
${top_ip}         ${EMPTY}
${is_sran}        ${EMPTY}
# Leap seconds for GPS since 2017-01-01 - ????-??-??
# If TCs with this macro be failing due to not appropriate leap seconds, please check if it was not increased globally
${gps_leap_seconds}    18
@{DELTA_LTE1441_SIB16}
...    LNBTS:act1xCsfb=true
...    LNBTS:actUTCBroadcast=true
...    LNADJX-0:arfcn=81
...    LNADJX-0:bandClass=bc0
...    LNADJX-0:cellId=1
...    LNADJX-0:marketId=40
...    LNADJX-0:pnOffset=1
...    LNADJX-0:sectorId=1
...    LNADJX-0:swNo=1
...    LNCEL-1:rttCsfbType=R81xCsfbEnforced
...    LNCEL-1:rand=12345
...    LNCEL-1:rttCellIdInfo=0
...    LNCEL-1:c2KTimers:tC2KMeasReport=1000
...    LNCEL-1:c2KTimers:tC2KRelocPrep=5000
...    LNCEL-1:c2KTimers:tC2kRelocExec=7000
...    LNCEL-1:c2KTimers:tULHOPrepTransfer=1000
...    LNCEL-1:rttRefCellId:rttCellId=1
...    LNCEL-1:rttRefCellId:rttSwNo=1
...    LNCEL-1:rttRefCellId:rttMarketId=40
...    LNCEL-1:rttRefCellId:rttSectorId=1
...    LNCEL-1/XPARAM-1:mcc=1023
...    LNCEL-1/XPARAM-1:bandClass=bc0
...    LNCEL-1/XPARAM-1:dayLtIncluded=false
...    LNCEL-1/XPARAM-1:ltmOffIncluded=false
...    LNCEL-1/CDFIM-1:csfbRegParam1xRtt:nid=1
...    LNCEL-1/CDFIM-1:csfbRegParam1xRtt:sid=1
...    LNCEL-1/LNHOX-1:rttCarrierFreq:rttArfcn=81
...    LNCEL-1/LNHOX-1:rttCarrierFreq:rttBandClass=bc0
...    LNCEL-1/LNRELX-0:arfcn=81
...    LNCEL-1/LNRELX-0:bandClass=bc0
...    LNCEL-1/LNRELX-0:cellId=1
...    LNCEL-1/LNRELX-0:e1xCsfbAllowed=allowed
...    LNCEL-1/LNRELX-0:marketId=40
...    LNCEL-1/LNRELX-0:pnOffset=1
...    LNCEL-1/LNRELX-0:sectorId=1
...    LNCEL-1/LNRELX-0:srvccAllowed=allowed
...    LNCEL-1/LNRELX-0:swNo=1
...    LNCEL-1/REDRT-0:addGsmSIToRedirMsg=both
...    LNCEL-1/REDRT-0:csFallBPrio=1
...    LNCEL-1/REDRT-0:emerCallPrio=1
...    LNCEL-1/REDRT-0:redirBandCdma=bc0
...    LNCEL-1/REDRT-0:redirFreqCdma=81
...    LNCEL-1/REDRT-0:redirFreqEutra=0
...    LNCEL-1/REDRT-0:redirFreqUtra=0
...    LNCEL-1/REDRT-0:redirRat=cdma20001xRTT
...    LNCEL-1/REDRT-0:redirectPrio=1
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=320ms|siMessageSibType=SIB8
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB16
...    LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=320ms|siMessageSibType=SIB16
...    LNCEL-2:rttCsfbType=forbidden
...    LNCEL-3:rttCsfbType=forbidden


*** Test Cases ***
LTE3056_Q_CSFBParametersResponseCDMA2000_containing_mobility_Parameters_with_ltmOffIncluded_and_DayLtIncluded_set_to_false
    [Tags]
    [Documentation]
    ...    XPARAMS dayLtIncluded and ltmOffIncluded are set to false therefore ltmOff and
    ...    dayLt should not be included in mobilityParameters, even when set by system in SIB
    ...
    ...    REQUIREMENTS COVERAGE:
    ...    REQUIREMENTS IN SCOPE: LTE_CP_67203
    Configure LTE1441 and SIB16
    Verify timezone is set to "(GMT+1) Europe/Warsaw"
    Verify that ltmOff is set on all cells to expected value    Europe/Warsaw
    Verify that dayLt is set on all cells to expected value for timezone    Europe/Warsaw
    Start observer for CSFBParametersRequest and Response messages
    Attach CDMA2000 capable UE
    Send CSFBParametersRequestCDMA2000 by UE
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters DAYLT_Included is set to    0
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters LTM_OFF_Included is set to    0
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters LP_SEC_Included is set to    1
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters DAYLT is set to    None
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters LTM_OFF is set to    None
    Verify if CSFBParametersResponseCDMA2000 mobilityParameters LP_SEC is set to    ${gps_leap_seconds}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=LTE3056_3cells_FDD
    Create UE alias    alias=UE_1    id_type=cus    ue_id=1
    Create eNB alias    alias=ENB_1    enb_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=11    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=12    cell_type=cus

Configure LTE1441 and SIB16
    Delta Commission Parameters    ${DELTA_LTE1441_SIB16}

Verify timezone is set to "(GMT+1) Europe/Warsaw"
    Object Should Exist    MRBTS-1/MNL-1:timeZone=(GMT+1) Europe/Warsaw

Verify that ltmOff is set on all cells to expected value
    [Arguments]    ${timezone}
    ${expected_ltmOff}=    get correct value of localtimeoffset including dst for timezone in hours    ${timezone}
    log to console    Expected ltmOff on cells for ${timezone} is: ${expected_ltmOff}h
    Object Should Exist    LNCEL-1/SIB-0:ltmOff=${${expected_ltmOff}*4}
    Object Should Exist    LNCEL-2/SIB-0:ltmOff=${${expected_ltmOff}*4}
    Object Should Exist    LNCEL-3/SIB-0:ltmOff=${${expected_ltmOff}*4}

Verify that dayLt is set on all cells to expected value for timezone
    [Arguments]    ${timezone}
    ${expected_dayLt}=    get dayLt expected value    timezone=${timezone}
    log to console    Expected dayLt on cells for ${timezone} is: ${expected_dayLt}
    Object Should Exist    LNCEL-1/SIB-0:dayLt=${expected_dayLt}
    Object Should Exist    LNCEL-2/SIB-0:dayLt=${expected_dayLt}
    Object Should Exist    LNCEL-3/SIB-0:dayLt=${expected_dayLt}

Start observer for CSFBParametersRequest and Response messages
    Expect Message Flow
    ...    UE_1:RRC_CSFBParametersRequestCDMA2000 as request
    ...    UE_1:RRC_CSFBParametersResponseCDMA2000 as response
    ...    alias=CSFB_PARAMETERS_FLOW    overall_timeout=30

Attach CDMA2000 capable UE
    run uex command    ue_attach    id=1    cell=1    ue_eutra_capabilities=${eutra_capabilities}
    ...    ue_cdma2k_1x_rtt_capabilities=${cdma2000_capabilities}

Send CSFBParametersRequestCDMA2000 by UE
#    WO to send cdma2000 preregister
    run uex command    ue_ul_dcch   id=1    send=0280
    run uex command    ue_ul_dcch    id=1    send=48209FE0802020

Verify if CSFBParametersResponseCDMA2000 mobilityParameters DAYLT_Included is set to
    [Arguments]    ${daylt_inc}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=DAYLT_Included    expected_ie_value=${daylt_inc}

Verify if CSFBParametersResponseCDMA2000 mobilityParameters LTM_OFF_Included is set to
    [Arguments]    ${ltm_inc}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=LTM_OFF_Included    expected_ie_value=${ltm_inc}

Verify if CSFBParametersResponseCDMA2000 mobilityParameters LP_SEC_Included is set to
    [Arguments]    ${lp_sec_inc}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=LP_SEC_Included    expected_ie_value=${lp_sec_inc}

Verify if CSFBParametersResponseCDMA2000 mobilityParameters DAYLT is set to
    [Arguments]    ${daylt_value}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=DAYLT    expected_ie_value=${daylt_value}

Verify if CSFBParametersResponseCDMA2000 mobilityParameters LTM_OFF is set to
    [Arguments]    ${ltm_off_value}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=LTM_OFF    expected_ie_value=${ltm_off_value}    twos_conversion_to_int=1

Verify if CSFBParametersResponseCDMA2000 mobilityParameters LP_SEC is set to
    [Arguments]    ${lp_sec_value}
    Flow Occurred as expected    alias=CSFB_PARAMETERS_FLOW
    verify if mobility parameters field is set to    flow_alias=CSFB_PARAMETERS_FLOW    message_alias=response
    ...    ie_name=LP_SEC    expected_ie_value=${lp_sec_value}


