*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
#...            CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00        SBTS23R1    CONFIGURED

Documentation
...             author:                 sowrabha sm, sowrabha.s_m@nokia.com
...             maintainer:             sowrabha sm, sowrabha.s_m@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     CB007200-G 5G21B Modification beam patternid is validated PUSCH scenario
...                                PUSCH performance test with G_FR1_A2_32 is selected for the test
...             TESTING SPLIT:     See CB007200-G testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007200-G CFAM
...


Library            ../resources/python/BIP_Capture.py
Library            ../resources/python/CPRT_Capture.py
Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot

Suite Setup                Run keywords
...                        Log To console  SuiteSetup
...                        AND     Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
#...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_100MHz_scs_30KHz_TDD_long_pucch.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB007326-G_TDD_Performance_PUSCH_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB007326-G_TDD_Performance_PUSCH_iphy.xml
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1

*** Test Cases ***
[1][1.0] CB007326-A_005_Test_performance NR only RU for PUSCH G-FR1-A3-32-TDD - 100Mhz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verifybeampatternidlist and beam change
    ...          during Performance test for PUSCH, step by step from L3/L2/L1 point of view .
    ...          gNB is set with TDD FR1 profile
    ...          Update configurable IE reportingTimeInterval value range and step to '0.1.. 3600, step 0.1'
    ...         second from webEM/test tool, currently the reportingTimeInterval value range and
    ...         step is '1.. 3600, step 1'second.
    ...
    ...          The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                  _nrCellIdentity, type==control testingConfig, controlChannelTestType==PUCCH, PUCCH format==F0,
    ...                  receivingSlot, expectationSlot - are equal to ones set in WebElementManager
    ...                 _ruMode is set to NR_ONLY
    ...                 _physCellId is set to 7
    ...            }
    ...
    ...       2. (L2PS)  PsCell_CellSetupReq  contains {
    ...                    * physCellId equal to the same value as in  CpRtCm_StartConformanceTestReq
    ...                    * dlMimoMode (set in NIDD)
    ...           }
    ...
    ...       3. (L1-L3) [L1 logs] UlCell_CellSetupReq contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 0(CL 2X2)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check message contents with settings corresponding to F0-ACK (3GPP 38.141-1) and
    ...                       FDD frame structure (3GPP 37.141) {
    ...                 *  DlData_SlotTypeReq (UL, DL and calibration)
    ...                 * _DlData_PatternConfigReq
    ...                 * _UlData_PucchReceiveReq contains {
    ...                         -       pucchFormat
        ...                         -   numOfPrb
        ...                         -   nANPucch
        ...                         -   numOfBitsOfUciInformation
        ...                         -   numOfSymbols
        ...                         -   dmrsSymbols
        ...                         -   firstSymbol
        ...                         -   frequencyHopping
        ...                         -   modulationType
    ...                   }
    ...                 * IE prbOffset set to 0
        ...                 * IE largestPrbIndex set to 200
    ...                 * IE startPrb: set to prbOffset under structure pucch in PsTM_StartConformanceTest
    ...                 * IE secondHopPrb: largestPrbIndex - (numOfPrb - 1), where largestPrbIndex from PsTM_StartConformanceTestReq.
    ...                 * _UlData_PucchReceiveRespHarqD
    ...           }
    ...
    ...
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEQA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_18896
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS
    ...  AUTHOR:     sowrabha.s_m@nokia.com
    ...
    ...  REFERENCES:   CB007200 CFAM
    ...
    ...
    Set test log path
    sleep   600s
    CPRT Monitoring Start ASOE
    ${beampattern}       Create List       ${100}   ${100}
    Start Collecting Syslog
    Start Performance Test PUSCH    reporting_int=0.1
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A3_32
    ...                             mapType=A
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    5s    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${750}   ${750}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}

    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.1

#    Bip Mon Start AP ASIK ABIL
#    sleep    1ms    reason=Wait for successful response from admin
#    Bip Mon Stop AP ASIK ABIL      ${LOG_PATH1}

    common_log_collection.Start BIP capture taf    ASOE    [ASOE]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    Stop Collecting Syslog

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag
    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...     ${CURRENT_SYSLOG_PATH}     puschg

    run keyword and ignore error    Get Information Elements from cellsetupreq message and verify pusch-g parameters
    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        run keyword if test failed      Bip Mon Stop AP ASIK ABIL       log_dir=${LOG_PATH1}
    ...         AND        run keyword if test failed      CPRT Monitoring Stop Collect ASOE       log_dir=${LOG_PATH1}
