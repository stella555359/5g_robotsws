*** Settings ***
Documentation
...     author:         madhusudhan.y@nokia.com
...     maintainer:     Madhusudhan Y
...     INTRODUCTION:   CB007120 AIC conformance cases
...     Feature:        CB007120
#Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
#Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
#Library             taf.transport.ssh           WITH NAME    taf_ssh
#Resource            ../resources/robot/AIC_Common_Keywords.robot
#Resource            ../resources/robot/Common_Keywords.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
#Resource           resources/ConformanceTest_keywords_AiC.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot
#
#Suite Setup             Run keywords     Test Suite Setup
#...                     AND              AIC Software Build Info
#...                     AND              Fetch Taf Library used in TL
#...                     AND              Update and Activate Delta Plan Parameter    basic
#...                                      ${CURDIR}/config/SBTS23R1/Delta_Configuration_7120_tds_mode.json
#...                     AND              BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
#...                     AND              BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}
#
#
##Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner
#
#*** Variables ***
#${epc_log_path}     /tmp/
#${UE_ID}     1
#${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/Configuration_scf_MRBTS-3806_DU_3806_20220330-1308.xml
#${VCU SCF PATH}     ${CURDIR}/config/SBTS/Configuration_scf_MRBTS-3806_CU_3806_20220330-1309.xml
#${iphy_xml}         ${CURDIR}/config/iphy.xml
#${gscn_value}   1
#@{conformance_params}     SStartConformanceTestReq      transmitterTestingConfig     i11Codebook4AntPorts
#...   ruMode    StartConformanceTestResp    ENgStatus
#
#@{conformance_params_Ul}     SStartConformanceTestReq      transmitterTestingConfig    receiverTestingConfig
#...    i11Codebook4AntPorts    ruMode    StartConformanceTestResp    ENgStatus
#
#@{cellsetup_params}     UlCell_SetupReq
#
#&{Test_Parameter}      beam_pattern_id=${1}    frc_index=G_FR1_A2_5    prb_offset=${1}
#...   reporting_time_interval=${1.0}    phys_cell_id=${50}    ru_mode=NR_Only
#
#${nr_cellid}    1
#${CellIdentity}    16385
#*** Test Cases ***
#[1]CB007120-C_04_Verify_Transmitter_testmodel_case_stop_with_ongoing_UL_conformance_testing
#    [Documentation]
#    ...
#    ...  DESCRIPTION:
#    ...  REQUIREMENTS:
#    ...  REFERENCES: N/A
#    ...  CONTACTS:  vivek.gv@nokia.com
#    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
#    ...  REQUIRED LOGS:  Syslog, TTI Trace
#    ...  TEST ENVIRONMENT:
#    ...    - gNB: 1x AirScale
#    ...  DEFINITIONS FROM THE TEST PLAN:
#    ...  PRECONDITIONS:
#    ...  HISTORY:
#    ...      v0.1: 14.09.2021:  Vivek GV   : first draft
#    ...
#
#    [Setup]     Run keywords         Log to console     \n-----> Test Setup <-----
#    ...         AND                  Testcase Setup
#    ...         AND                  Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode
#
#
#    ${beampattern}       Create List       ${200}   ${200}
#    Start DL Test Transmitter    test_model=NR-FR1-TM3.1
#    ...                          ru_mode=NR_Only
#    ...                          pci=50
#    ...                          polarization=P_plus45_or_0
#    ...                          beamPatternId=0
#    ...                          power_backoff=0
#    ...                          mimo_rank=Rank1
#    ...                          p_max=1
#    sleep    1s    reason=Wait for successful response from admin
#
#    Start Test Receiver FRC Index G-FR1-A2-5 on NR_Only
#    Sleep  10s
#    Get UL Test Result   ${nr_cellid}
#    Stop Test Transmitter test model
#    Sleep  5s
#    Get UL Test Result    ${nr_cellid}
#
##   Start L1L2 Bip Mon    l1hi
##    Sleep   1s
##   Stop and Collect L1L2 Bip Monitoring    l1hi
##   Stop and Collect CPIF_CPRT Monitoring
#    Stop and Collect Syslog Monitoring
#    Collect Journal Logs vDU    consolidate
#    Collect Journal Logs vCU     consolidate
#    Run Keyword And Ignore Error    Validate Conformance test results in Syslog    syslog     ${conformance_params}
#    Run Keyword And Ignore Error    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
#    Run Keyword And Ignore Error    Validate UL Conformance test results in Syslog    syslog  ${conformance_params}
#    Run Keyword And Ignore Error    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
#
#
##    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
##    Verify that message DlData_PdcchSendReq contains IE values in accordance with conformance test requirements
##   Verify message DlData_PdschSendReq based on Test Model Dictionary -
##DL_PDSCHSENDREQ_TM3_1A_TDD_UE1_C_50MHz_CB007200 for UE_1 - BW: 50MHz
##   Verify message DlData_PdschSendReq based on Test Model Dictionary -
##DL_PDSCHSENDREQ_TM3_1A_TDD_UE2_C_50MHz_CB007200 for UE_2 - BW: 50MHz
##   Verify PN23 sequence for PdcchSendReq
##   Verify PN23 sequence for PdschPayloadTbSendReq for testmodel         'tm3_1'
#
##   Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
##   Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions
#
#    [Teardown]   Run Keywords      Stop Test Receiver test model
#    ...         AND        vdu.disconnect    vdu_connection=coam_admin
#
#
#*** Keywords ***
#Validate Conformance test results in Syslog
#    [Arguments]      ${NAME}    ${conformance_params}
#    log to console     Verifying conformance test messages in syslog
#    FOR   ${item}   IN    @{conformance_params}
#          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
#          Should Not Be Empty    ${status}
#          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReqDL    ${status}
#          Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
#          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
#          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
#          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
#          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
#    END
#
#
#Validate UL Conformance test results in Syslog
#    [Arguments]      ${NAME}    ${conformance_params}
#    log to console     Verifying conformance test messages in syslog
#    FOR   ${item}   IN    @{conformance_params_Ul}
#          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
#          Should Not Be Empty    ${status}
#          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReqUL    ${status}
#          Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
#          Run Keyword If    '${item}' == 'receiverTestingConfig'      Validate ReceiverTestingConfig   ${Status}
#          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
#          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
#          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
#          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
#
#    END
#
#Validate CellSetup in Syslog
#    [Arguments]      ${NAME}    ${cellsetup_params}
#    log to console     Verifying Dl/UL cell setup messages in syslog
#    FOR   ${item}   IN    @{cellsetup_params}
#          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
#          Should Not Be Empty    ${status}
##          Run Keyword If    '${item}' == 'DlCell::SetupReq'    Validate DLCellSetup Msg   ${status}
#          Run Keyword If    '${item}' == 'UlCell_SetupReq'    Validate ULCellSetup Msg   ${status}
#    END
#
#Validate DLCellSetup Msg
#     [Arguments]      ${status}
#     Should Contain     ${status}     physCellId=50
#     Should Contain     ${status}     dlBandwidth=273
#     Should Contain     ${status}     scs=30
#     Should Contain     ${status}     dlSubcellType=C4
#
#Validate ULCellSetup Msg
#     [Arguments]      ${status}
#     Should Contain     ${status}     physCellId:50
#     Should Contain     ${status}     BW:273
#     Should Contain     ${status}     scs:30
#     Should Contain     ${status}     ulSubcellType:1
#     Should Contain     ${status}     -prachFormat:8
#
#Validate SStartConformanceTestReqDL
#     [Arguments]      ${status}
#     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
#     Should Contain     ${status}     ETypeTest = TRANSMITTER
#     Should Contain     ${status}     TBeamPatternId[2] = [0, 0]
#     Should Contain     ${status}     TReportingTimeInterval = 1
#
#Validate SStartConformanceTestReqUL
#     [Arguments]      ${status}
#     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
#     Should Contain     ${status}     ETypeTest = RECEIVER
#     Should Contain     ${status}     TBeamPatternId[2] = [0, 0]
#     Should Contain     ${status}     TReportingTimeInterval = 1
#
#Validate transmitterTestingConfig
#     [Arguments]      ${status}
#     Should Contain     ${status}     TestModel = TM3_1
##     Should Contain     ${status}     polarization: 0
##     Should Contain     ${status}     powerBackoff: 0
#
#Validate i11Codebook4AntPorts
#     [Arguments]      ${status}
#     Should Contain     ${status}     TI11Codebook4AntPorts = 0
#     Should Contain     ${status}     TI13Codebook4AntPorts = 0
#     Should Contain     ${status}     TI2Codebook4AntPorts = 0
#Validate ruMode
#     [Arguments]      ${status}
#     Should Contain     ${status}     ERuMode = NR_ONLY
#     Should Contain     ${status}     TPhysCellId = 50
#
#Validate StartConformanceTestResp
#     [Arguments]      ${status}
#     Should Contain     ${status}     StartConformanceTestResp
#
#Validate ENgStatus
#     [Arguments]      ${status}
#     Should Contain     ${status}     ENgStatus = OK
#
#Validate ReceiverTestingConfig
#    [Arguments]    ${Status}
#     Should Contain     ${status}    EFrcIndex = G_FR1_A2_5
#
