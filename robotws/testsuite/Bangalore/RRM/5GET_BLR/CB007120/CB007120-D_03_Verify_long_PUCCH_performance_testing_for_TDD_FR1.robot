*** Settings ***
Documentation
...     author:         madhusudhan.y@nokia.com
...     maintainer:     Madhusudhan Y
...     INTRODUCTION:   CB007120 AIC conformance cases
...     Feature:        CB007120
#Library             taf.transport.ssh           WITH NAME    taf_ssh
#Resource            ../resources/robot/AIC_Common_Keywords.robot
#Resource            ../resources/robot/Common_Keywords.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
#Resource            resources/ConformanceTest_keywords_AiC.robot
#Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot
#
#Suite Setup             Run keywords    Test Suite Setup
#...                     AND             AIC Software Build Info
#...                     AND             Fetch Taf Library used in TL
#...                     AND             Update and Activate Delta Plan Parameter    basic
#...                                     ${CURDIR}/config/SBTS23R1/Delta_Configuration_7120_tds_mode.json
#...                     AND             BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
#...                     AND             BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}
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
#@{conformance_params}     SStartConformanceTestReq    pucch    ruMode    StartConformanceTestResp
#...   ENgStatus
#@{cellsetup_params}     UlCell_SetupReq
#&{Test_Parameter}      reporting_time_interval=${2.9}  pucch_format=F1
#...     ru_mode=NR_Only   num_payload_bit=2   num_pucch_symbol=14   phys_cell_id=${50}
#${nr_cellid}    1
#${CellIdentity}    16385
#*** Test Cases ***
#[1]CB007120-D_03_Verify_long_PUCCH_performance_testing_for_TDD_FR1
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
#    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
#    ...         AND                 Testcase Setup
#    ...         AND                 vDU Login
#    ...         AND                 Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode
#
#    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
#    set test variable      ${TESTCASE_LOG_PATH}
#    ${CURRENT_SYSLOG_PATH}    Set Variable    ${TESTCASE_LOG_PATH}/Syslog_vDU
#    set test variable       ${CURRENT_SYSLOG_PATH}
#    Start Syslog Monitoring
##    #Start CPIF_CPRT Monitoring
#    ${beampattern}       Create List       ${200}   ${200}
#    ConformanceTest_keywords_AiC.Start Performance Test PUCCH    reporting_int=2.9
#    ...                             beamPatternId=${beampattern}
#    ...                             pucch_format=F1
#    ...                             ru_mode=NR_Only_RU
#    ...                             pci=50
#    ...                             format_2_test_type=Ack
#    ...                             pucch_payload_content=3
#    ...                             num_payload_bit=2
#    ...                             numPucchSymbol=14
#
#    sleep    1s    reason=Wait for successful response from admin
#    Sleep    10s
##    Start L1L2 Bip Mon    l1hi
##    Sleep   1s
##    Stop and Collect L1L2 Bip Monitoring    l1hi
##    Stop and Collect CPIF_CPRT Monitoring
#    Sleep   10s
#    Get PUCCH Performance Result   ${nr_cellid}
#    ConformanceTest_keywords_AiC.Stop Control Test for MRBTS_R-1
#    vdu.disconnect    vdu_connection=coam_admin
#    Stop and Collect Syslog Monitoring
#    Collect Journal Logs vDU    consolidate
#    Collect Journal Logs vCU    consolidate
#    Validate Conformance test results in Syslog    syslog     ${conformance_params}
#    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
##    Run Keyword and ignore error   ConformanceTest_keywords_AiC.Verify that ULData_PucchReceiveReq message
##contains the correct slot type based on recieving slot set
## Run Keyword and ignore error   Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
##    Run Keyword and ignore error   ConformanceTest_keywords_AiC.Verify that UlData_PucchReceiveReq is set in accordanc
##e with conformance test - prbOffset and largetPrbIndex verified for F1-ACK
##    logtype can be "consolidate" or "nonconsolidate"
#
#
#
#*** Keywords ***
#Validate Conformance test results in Syslog
#    [Arguments]      ${NAME}    ${conformance_params}
#    log to console     Verifying conformance test messages in syslog
#    FOR   ${item}   IN    @{conformance_params}
#          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog | grep "${item}"
#          Should Not Be Empty    ${status}
#          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReq    ${status}
#          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
#          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
#          Run Keyword If    '${item}' == 'pucch'    Validate PucchPerformanceTestingConfig   ${status}
#          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
#    END
#
#Validate CellSetup in Syslog
#    [Arguments]      ${NAME}    ${cellsetup_params}
#    log to console     Verifying Dl/UL cell setup messages in syslog
#    FOR   ${item}   IN    @{cellsetup_params}
#          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog | grep "${item}"
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
#     Should Contain     ${status}     physCellId:50
#     Should Contain     ${status}     BW:273
#     Should Contain     ${status}     scs:30
#     Should Contain     ${status}     ulSubcellType:1
#     Should Contain     ${status}     -prachFormat:8
#
#Validate SStartConformanceTestReq
#     [Arguments]      ${status}
#     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
#     Should Contain     ${status}     ETypeTest = CONTROL
#     Should Contain     ${status}     TBeamPatternId[2] = [200, 200]
#     Should Contain     ${status}     TReportingTimeInterval = 2.9
#
#
#Validate PucchPerformanceTestingConfig
#     [Arguments]      ${status}
#     Should Contain     ${status}     EPucchFormat = F1
#	 Should Contain     ${status}     TLargestPrbIndex = 100
##     Should Contain     ${status}     numPayloadBit = 2
##     Should Contain     ${status}     numPucchSymbol = 14
#     Should Contain     ${status}     TPrbOffsetPucch = 1
##     Should Contain     ${status}     pucchPayloadContent = 3
#
#
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
