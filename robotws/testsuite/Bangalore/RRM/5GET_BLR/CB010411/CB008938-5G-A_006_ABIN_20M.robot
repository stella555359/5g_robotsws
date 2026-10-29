*** Settings ***
Force Tags      CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation
...
...             author:            Prerana N S
...             maintainer:        Prerana N S, prerana.n_s@nokia.com
...
...             INTRODUCTION:      CB008938 Conformance Test and Type Approvals for 23R1
...             TEST SET NAME:     CB008938-5G-A_006_Transmitter test model is successful aligned with 09-2021
...                                TS 38.141-1-2-NR-FR1-TM3.2-1Tx2Rx FDD-CPRI ABIN 20Mhz.
...             TESTING SPLIT:     See CB008938-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008938-A CFAM
...

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
Resource            resources/ConformanceTest_keywords_AiC.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot


Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${vcu_file_path}
...                 AND           Fast Delta Commission vDU With Delta XML File      ${vdu_file_path}
...                     AND              sleep    60s

#Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${epc_log_path}     /tmp/
${UE_ID}     1
${gscn_value}   1
${RMOD_name}       AHCA
${iphy_file_path}  ${CURDIR}/config/SBTS24R3/iphy_8938.xml
${vcu_file_path}   ${CURDIR}/config/SBTS24R3/VCU_SCF_8938.xml
${vdu_file_path}   ${CURDIR}/config/SBTS24R3/VDU_SCF_8938.xml
@{conformance_params}     SStartConformanceTestReq      transmitterTestingConfig     i11Codebook4AntPorts
...   ruMode    StartConformanceTestResp    ENgStatus

@{conformance_params_Ul}     SStartConformanceTestReq      transmitterTestingConfig    receiverTestingConfig
...    i11Codebook4AntPorts    ruMode    StartConformanceTestResp    ENgStatus

@{cellsetup_params}     UlCell_SetupReq

&{Test_Parameter}      beam_pattern_id=${1}    frc_index=G_FR1_A1_1    prb_offset=${1}
...   reporting_time_interval=${1.0}    phys_cell_id=${50}    ru_mode=NR_Only

${nr_cellid}    1
${CellIdentity}    16387


*** Test Cases ***
[1][1.0] CB008938-5G-A_006_TM3_2-1Tx2Rx FDD-CPRI ABIN 20Mhz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify the correct CB008938-A 5G23R1
    ...  New value introduced for dlMimoMode and nrCellType (1DL2UL) for supporting Single Antenna Transmission.
    ...
    ...  The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                    _nrCellindentity, type, transmiter testingConfig, polarization) are equal to ones set in
    ...                     WebElementManager
    ...                    - _ruMode is set to NR only
    ...                    - _physCellId
    ...                    - nrCellindentity, type, status=OK
    ...            }
    ...                    CpRtCm_MeasurmentReportInd - check frequency and value of messages toward OAM
    ...
    ...       2. (L2PS)  PsCell_CellSetupReq  contains {
    ...                    * physCellId equal to the same value as in  CpRtCm_StartConformanceTestReq
    ...           }
    ...
    ...       3. (L1-L3) [L1 logs] UlCell_CellSetupReq contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 12 (SingleAntennaTransmission_1x1)
    ...                   * DlSubcellType to 6 (A1 for Single Antenna 1x1, 1DL2UL)
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 5 (SAT_1x1_MIMO)
    ...                   * DlSubcellType to 6 (A1 for Single Antenna 1x1, 1DL2UL)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check contents of following messages with specific setting corresponding to TM3_2 {
    ...                   *_DlData_PatternConfigReq
    ...                   *_DlData_PdcchSendReq
    ...                   *_DlData_PdschSendReq
    ...                   *_DlData_PdschPayloadTbSendReq (payload = 0)
    ...           }
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AHCA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_5,5G_RAN_USR_RRM_16829,5G_RAN_USR_RRM_16830
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...
    ...  REFERENCES:   CB008938 CFAM,
    ...

    [Setup]     Run keywords         Log to console     \n-----> Test Setup <-----
    ...         AND                  Testcase Setup
    ...         AND                  Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode

    ${beampattern}       Create List       ${0}   ${0}   ${0}   ${0}
    Start Syslog Monitoring
    Start DL Test Transmitter FDD    test_model=NR-FR1-TM3.2
    ...                              ru_mode=NR_Only
    ...                              pci=52
    ...                              polarization=P_plus45_or_0
    ...                              beamPatternId=${beampattern}
    ...                              power_backoff=0
    ...                              mimo_rank=Rank1
    ...                              p_max=39
    ...                              nrarfcn_dl=188540
    ...                              nrarfcn_ul=179500
    ...                              nrcell_id=3
    sleep    1ms    reason=Wait for successful response from admin
    Stop and Collect Syslog Monitoring

    Validate Conformance test results in Syslog    syslog     ${conformance_params}
    Validate CellSetup in Syslog    syslog     ${cellsetup_params}

    [Teardown]   Run Keywords      Stop Test Transmitter test model FDD     nrcell_id=3
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

Validate CellSetup in Syslog
    [Arguments]      ${NAME}    ${cellsetup_params}
    log to console     Verifying Dl/UL cell setup messages in syslog
    FOR   ${item}   IN    @{cellsetup_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'CellSetupReq_t'    Validate DLCellSetup Msg   ${status}
    END

Validate DLCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}    "physCellId":52
     Should Contain     ${status}     "dlBandwidth":"PR"
     Should Contain     ${status}      BS_106"
     Should Contain     ${status}     "ssbScs":"KHZ_15"

Validate SStartConformanceTestReqDL
     [Arguments]      ${status}
     Should Contain     ${status}     TCellIdentity = ${CellIdentity}
     Should Contain     ${status}     ETypeTest = TRANSMITTER
     Should Contain     ${status}     TBeamPatternId[4] = [0, 0, 0, 0]
     Should Contain     ${status}     TReportingTimeInterval = 1

Validate transmitterTestingConfig
     [Arguments]      ${status}
     Should Contain     ${status}     "testModel":"TM3_2"
     Should Contain     ${status}     "polarization":"P_PLUS45_OR_0"
     Should Contain     ${status}     "powerBackoff":0
     Should Contain     ${status}     "mimoRank":"MIMO_RANK_1"

Validate ruMode
     [Arguments]      ${status}
     Should Contain     ${status}     ERuMode = NR_ONLY
     Should Contain     ${status}     TPhysCellId = 52

Validate StartConformanceTestResp
     [Arguments]      ${status}
     Should Contain     ${status}     StartConformanceTestResp

Validate ENgStatus
     [Arguments]      ${status}
     Should Contain     ${status}     ENgStatus = OK

Validate i11Codebook4AntPorts
     [Arguments]      ${status}
     Should Contain     ${status}     TI11Codebook4AntPorts = 0
     Should Contain     ${status}     TI13Codebook4AntPorts = 0
     Should Contain     ${status}     TI2Codebook4AntPorts = 0
