*** Settings ***
#Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
#...             CRT    RAN_5G    5G_RAN_TDD     master_vDU    vDUCNF22R4

Documentation
...     Feature:        CB010412
...     author:         gaurav.sarwariya@nokia.com 
...     maintainer:     gaurav.sarwariya@nokia.com        ..             
...     INTRODUCTION:   CB009500
...     TEST SET NAME:  CB010412-CB009500-5G-A_5_PUSCH_performance_tests-TDD-eCPRI-ABIO_100MHz

...     CONTACTS:          I_MN_RAN_L2_SW1_BLR_RDPZ_DEV_10_SG_GMS <I_MN_RAN_L2_SW1_BLR_RDPZ_DEV_10_SG@internal.nsn.com>
...     REFERENCES:        CB009500 CFAM

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource            resources/ConformanceTest_keywords_AiC.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL
...                     AND              Log to console    Performing full commissioning
...                     AND       Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
...                     AND       Fast Delta Commission vCU Using Delta XML File      ${vcu_file_path}
...                     AND       BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND       BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}
...                     AND                 Log to console    vDU delta commissioning
...                     AND                 Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND                 BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND                 BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}


Suite Teardown         Run keywords        Suite Teardown

*** Variables ***
${RMOD_name}       AZQJ
${iphy_file_path}  ${CURDIR}/config/SBTS24R3/iphy_conformance.xml
${wts_cfg_file}    ${CURDIR}/config/SBTS24R3/basic_conformance.cfg
${vcu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vcu.xml
${vdu_file_path}   ${CURDIR}/config/SBTS24R3/Delta_vdu.xml
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${delta_vdu}        ${CURDIR}/config/SBTS24R2/Delta_configuration_scf_MRBTS-1_DU-11133_BLR_Thor_2cell_TDD_SA.xml

${epc_log_path}     /tmp/
${UE_ID}     1
${gscn_value}   1
@{conformance_params}     SStartConformanceTestReq      frcIndex      ulDmrsMappingType     prbOffset
...       i11Codebook4AntPorts    ruMode    StartConformanceTestResp    ENgStatus
@{cellsetup_params}    CellSetupReq_t

*** Test Cases ***
[1][1.0] CB009500-5G-A_5_PUSCH_performance_tests-TDD-eCPRI-ABIO_10MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:
    ...  REFERENCES: N/A
    ...  CONTACTS:  gaurav.sarwariya@nokia.com
    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
    ...  REQUIRED LOGS:  Syslog, TTI Trace
    ...  TEST ENVIRONMENT:
    ...    - gNB: 1x AirScale
    ...  DEFINITIONS FROM THE TEST PLAN:
    ...  PRECONDITIONS:
    ...  HISTORY:
    
    ...

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode
    
    Start Syslog Monitoring
    ${beampattern}       Create List       ${20}   ${20}   ${20}   ${20}
    Start Performance Test PUSCH    reporting_int=0.2
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G-FR1-A5-11
    ...                             mapType=A
    sleep    1s    reason=Wait for successful response from admin
    Stop and Collect Syslog Monitoring
    Validate Conformance test results in Syslog    syslog     ${conformance_params}
    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
    

*** Keywords ***
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----

Validate Conformance test results in Syslog
    [Arguments]      ${NAME}    ${conformance_params}
    log to console     Verifying conformance test messages in syslog
    FOR   ${item}   IN    @{conformance_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReq    ${status}
          #Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
          Run Keyword If    '${item}' == 'frcIndex'      Should Contain     ${status}     EFrcIndex = G_FR1_A5_11
          Run Keyword If    '${item}' == 'ulDmrsMappingType'      Should Contain     ${status}     EUlDmrsMappingType = TYPE_A
          Run Keyword If    '${item}' == 'prbOffset'      Should Contain     ${status}     TPrbOffset = 0
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

Validate SStartConformanceTestReq
     [Arguments]      ${status}
     Should Contain     ${status}     ETypeTest = RECEIVER
     Should Contain     ${status}     TBeamPatternId[4] = [20, 20, 20, 20]
     Should Contain     ${status}     TReportingTimeInterval = 0.2

Validate transmitterTestingConfig
     [Arguments]      ${status}
     Should Contain     ${status}     TestModel = TM3_1
     Should Contain     ${status}     polarization = 0
     Should Contain     ${status}     TPowerBackoff = 0
     Should Contain     ${status}     EMimoRank = MIMO_RANK_1
     Should Contain     ${status}     TCodebook2AntPorts = 0
     Should Contain     ${status}     TReportingTimeInterval = 1
     Should Contain     ${status}     TCodebook2AntPorts = 0
     Should Contain     ${status}     EMimoRank = MIMO_RANK_1

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
