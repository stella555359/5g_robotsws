*** Settings ***
Documentation
...     Feature:        CB007120
...     author:         madhusudhan.y@nokia.com 
...     maintainer:     chaithanya.h_s@nokia.com        ..             
...     INTRODUCTION:   7120-C
...     TEST SET NAME:  CB007120-C_04_Verify_Transmitter_testmodel_with_ongoing_UL_ongoing
...     TESTING SPLIT:     See CB007120 testplan
...     CONTACTS:          I_MN_RAN_L2_SW1_BLR_RDPZ_DEV_10_SG_GMS <I_MN_RAN_L2_SW1_BLR_RDPZ_DEV_10_SG@internal.nsn.com>
...     REFERENCES:        CB007120 CFAM

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
Resource           resources/ConformanceTest_keywords_AiC.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot

Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND              Log to console    Performing full commissioning
...                     AND       Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
...                     AND       Fast Delta Commission vCU Using Delta XML File      ${vcu_file_path}
...                     AND       BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND       BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}
...                     AND       sleep    60s
...                     AND       Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND       BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND       BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}

Test Teardown       Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${RMOD_name}       AZQJ
${vcu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vcu.xml
${vdu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vdu.xml
${epc_log_path}     /tmp/
${UE_ID}     1
${gscn_value}   1
${delta_vdu}        ${CURDIR}/config/SBTS24R2/Delta_configuration_scf_MRBTS-1_DU-11133_BLR_Thor_2cell_TDD_SA.xml
@{conformance_params}     SStartConformanceTestReq      transmitterTestingConfig     i11Codebook4AntPorts
...   ruMode    StartConformanceTestResp    ENgStatus

@{conformance_params_Ul}     SStartConformanceTestReq      transmitterTestingConfig    receiverTestingConfig
...    i11Codebook4AntPorts    ruMode    StartConformanceTestResp    ENgStatus

@{cellsetup_params}     CellSetupReq

@{beampattern_reciever}          ${1}   ${1}   ${1}   ${1}
&{Test_Parameter}      beam_pattern_id=@{beampattern_reciever}    frc_index=G-FR1-A2-5    prb_offset=${1}
...   reporting_time_interval=${1.0}    phys_cell_id=${50}    ru_mode=NR_Only

${nr_cellid}    1
${CellIdentity}    16385
*** Test Cases ***
[1]CB007120-C_04_Verify_Transmitter_testmodel_case_stop_with_ongoing_UL_conformance_testing
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:
    ...  REFERENCES: N/A
    ...  CONTACTS:  vivek.gv@nokia.com
    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
    ...  REQUIRED LOGS:  Syslog, TTI Trace
    ...  TEST ENVIRONMENT:
    ...    - gNB: 1x AirScale
    ...  DEFINITIONS FROM THE TEST PLAN:
    ...  PRECONDITIONS:
    ...  HISTORY:
    ...      v0.1: 14.09.2021:  Vivek GV   : first draft
    ...

    [Setup]     Run keywords         Log to console     \n-----> Test Setup <-----
    ...         AND                  Testcase Setup
    ...         AND                  Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode

    Start CPRT F1 Monitoring
    ${beampattern}       Create List       ${0}   ${0}   ${0}   ${0}
    Start DL Test Transmitter    test_model=NR-FR1-TM3.1
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_plus45_or_0
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=0
    ...                          mimo_rank=Rank1
    ...                          p_max=1
    sleep    1s    reason=Wait for successful response from admin

    Start Test Receiver FRC Index G-FR1-A2-5 on NR_Only
    Sleep  10s
    Get UL Test Result   ${nr_cellid}
    Stop Test Transmitter test model
    Sleep  5s
    Get UL Test Result    ${nr_cellid}
    Stop and Collect CPRT F1 Monitoring
    Stop and Collect Syslog Monitoring
    Collect Journal Logs vDU    consolidate
    Collect Journal Logs vCU     consolidate
    Validate Conformance test results in Syslog    syslog     ${conformance_params}
    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
    Validate UL Conformance test results in Syslog    syslog  ${conformance_params}


    [Teardown]   Run Keywords      Stop Test Receiver test model
    ...         AND        vdu.disconnect    vdu_connection=coam_admin


*** Keywords ***
Validate Conformance test results in Syslog
    [Arguments]      ${NAME}    ${conformance_params}
    log to console     Verifying conformance test messages in syslog
    FOR   ${item}   IN    @{conformance_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReqDL    ${status}
          Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
    END


Validate UL Conformance test results in Syslog
    [Arguments]      ${NAME}    ${conformance_params}
    log to console     Verifying conformance test messages in syslog
    FOR   ${item}   IN    @{conformance_params_Ul}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReqUL    ${status}
          Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
          Run Keyword If    '${item}' == 'receiverTestingConfig'      Validate ReceiverTestingConfig   ${Status}
          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}

    END

Validate CellSetup in Syslog
    [Arguments]      ${NAME}    ${cellsetup_params}
    log to console     Verifying Dl/UL cell setup messages in syslog
    FOR   ${item}   IN    @{cellsetup_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'CellSetupReq_t'    Validate DLCellSetup Msg   ${status}
          Run Keyword If    '${item}' == 'CellSetupReq_t'    Validate ULCellSetup Msg   ${status}
    END

Validate DLCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     "physCellId":50
     Should Contain     ${status}     "dlBandwidth":"PR
     Should Contain     ${status}      BS_273"
     Should Contain     ${status}     "ssbScs":"KHZ_30"
     Should Contain     ${status}     "dlSubcellType":"SUBCELLTYPE_C4"

Validate ULCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     "physCellId":50
     Should Contain     ${status}     "ulBandwidth":"PRBS_273"
     Should Contain     ${status}     "ssbScs":"KHZ_30"
     Should Contain     ${status}     "ulSubcellType":
     Should Contain     ${status}     "SUBCELLTYPE_C4"

Validate SStartConformanceTestReqDL
     [Arguments]      ${status}
     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
     Should Contain     ${status}     ETypeTest = TRANSMITTER
     Should Contain     ${status}     TBeamPatternId[4] = [0, 0, 0, 0]
     Should Contain     ${status}     TReportingTimeInterval = 1

Validate SStartConformanceTestReqUL
     [Arguments]      ${status}
     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
     Should Contain     ${status}     ETypeTest = RECEIVER
     Should Contain     ${status}     TBeamPatternId[4] = [0, 0, 0, 0]
     Should Contain     ${status}     TReportingTimeInterval = 1

Validate transmitterTestingConfig
     [Arguments]      ${status}
#     Should Contain     ${status}     TestModel = TM3_1
     Should Contain     ${status}     "polarization":"P_PLUS45_OR_0"
     Should Contain     ${status}     "powerBackoff":0

Validate i11Codebook4AntPorts
     [Arguments]      ${status}
     Should Contain     ${status}     TI11Codebook4AntPorts = 0
     Should Contain     ${status}     TI13Codebook4AntPorts = 0
     Should Contain     ${status}     TI2Codebook4AntPorts = 0
Validate ruMode
     [Arguments]      ${status}
     Should Contain     ${status}     ERuMode = NR_ONLY
     Should Contain     ${status}     TPhysCellId = 50

Validate StartConformanceTestResp
     [Arguments]      ${status}
     Should Contain     ${status}     StartConformanceTestResp

Validate ENgStatus
     [Arguments]      ${status}
     Should Contain     ${status}     ENgStatus = OK

Validate ReceiverTestingConfig
    [Arguments]    ${Status}
     Should Contain     ${status}    EFrcIndex = G_FR1_A2_5

