*** Settings ***
Documentation
...     author:         manasa.shankarappa@nokia.com
...     maintainer:     Manasa
...     INTRODUCTION:   CB010411 AIC Parity- Conformance of CB008444
...     Feature:        CB010411

Library             taf.transport.ssh           WITH NAME    taf_ssh
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot


Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
Resource           ../CB007120/resources/ConformanceTest_keywords_AiC.robot
#Resource           ../resources/robot/ConformanceTest_Setup_Env.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot

Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
#...                     AND             Update and Activate Delta Plan Parameter    basic
#...                                      ${CURDIR}/config/Delta_Configuration_8444_tds_mode.json
#...                     AND             BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
#...                     AND             BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}


*** Variables ***
${epc_log_path}     /tmp/
${UE_ID}     1
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS/Configuration_scf_MRBTS-3806_DU_3806_20220330-1308.xml
${VCU SCF PATH}     ${CURDIR}/config/SBTS/Configuration_scf_MRBTS-3806_CU_3806_20220330-1309.xml
${iphy_xml}         ${CURDIR}/config/iphy.xml
${gscn_value}   1
@{conformance_params}     SStartConformanceTestReq      transmitterTestingConfig     i11Codebook4AntPorts
...    ruMode    StartConformanceTestResp    ENgStatus
@{cellsetup_params}     UlCell_SetupReq
${CellIdentity}    16385
&{Test_Parameter}      prach_configuration_index=${12}   prach_sequence_type='Unrestricted'  prach_root_sequence_index=${0}
...   receiving_slot=${8}   expectation_slot=${8}

*** Test Cases ***
[1]CB008444_B_010_Test_performance FDD PRACH format 0 - 30,10MHz - ASOE
    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 vDU Login
    ${TESTCASE_LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${TESTCASE_LOG_PATH}
    ${CURRENT_SYSLOG_PATH}    Set Variable    ${TESTCASE_LOG_PATH}/Syslog_vDU
    set test variable       ${CURRENT_SYSLOG_PATH}
#    Start Syslog Monitoring
    Start CPRT F1 Monitoring
    ${beampattern}       Create List       ${200}   ${200}
    ConformanceTest_keywords_AiC.Start Performance Test PRACH CB008444
    ...                             phy_cellid=50
    ...                             arfcn=633000
    ...                             cell_id=1
    sleep    1s    reason=Wait for successful response from admin
    Sleep    10s
#    Start L1L2 Bip Mon    l1hi
#    Sleep   1s
#    Stop and Collect L1L2 Bip Monitoring    l1hi
    Stop and Collect CPRT F1 Monitoring
    Sleep   10s
    Get PRACH Performance Result   ${1}
    ConformanceTest_keywords_AiC.Stop Control Test for MRBTS_R-1
    vdu.disconnect    vdu_connection=coam_admin
#    Stop and Collect Syslog Monitoring
    Collect Journal Logs vDU    consolidate
    Collect Journal Logs vCU    consolidate
#    Run Keyword and continue on Failure    Validate Conformance test results in Syslog    syslog     ${conformance_params}
#    Run Keyword and continue on Failure    Validate CellSetup in Syslog    syslog     ${cellsetup_params}


*** Keywords ***
Validate Conformance test results in Syslog
    [Arguments]      ${NAME}    ${conformance_params}
    log to console     Verifying conformance test messages in syslog
    FOR   ${item}   IN    @{conformance_params}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog | grep "${item}"
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReq    ${status}
          Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
    END

Validate CellSetup in Syslog
    [Arguments]      ${NAME}    ${cellsetup_params}
    log to console     Verifying Dl/UL cell setup messages in syslog
    FOR   ${item}   IN    @{cellsetup_params}
          ${status} =   run    command=sudo cat ${CURRENT_SYSLOG_PATH}/syslog | grep "${item}"
          Should Not Be Empty    ${status}
#          Run Keyword If    '${item}' == 'DlCell::SetupReq'    Validate DLCellSetup Msg   ${status}
          Run Keyword If    '${item}' == 'UlCell_SetupReq'    Validate ULCellSetup Msg   ${status}
    END

Validate DLCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     physCellId=50
     Should Contain     ${status}     dlBandwidth=273
     Should Contain     ${status}     scs=30
     Should Contain     ${status}     dlSubcellType=C4
#     Should Contain     ${status}     conformance_test_mode true

Validate ULCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     physCellId:50
     Should Contain     ${status}     BW:273
     Should Contain     ${status}     scs:30
     Should Contain     ${status}     ulSubcellType:1
     Should Contain     ${status}     -prachFormat:8

Validate SStartConformanceTestReq
     [Arguments]      ${status}
     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
     Should Contain     ${status}     ETypeTest = TRANSMITTER
     Should Contain     ${status}     TBeamPatternId[2] = [1, 1]
     Should Contain     ${status}     TReportingTimeInterval = 1

Validate transmitterTestingConfig
     [Arguments]      ${status}
     Should Contain     ${status}     TestModel = TM3_3
     Should Contain     ${status}     polarization: 2
     Should Contain     ${status}     powerBackoff: 0
     #Should Contain     ${status}     EMimoRank = MIMO_RANK_1
     Should Contain     ${status}     ReportingTimeInterval = 1

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

