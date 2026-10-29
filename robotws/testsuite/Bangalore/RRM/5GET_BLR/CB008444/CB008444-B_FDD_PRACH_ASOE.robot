*** Settings ***
Test Timeout  60 minutes
Force Tags      CLOUD_5G_O_E_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB008444/CB008444_B_010.yml
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1      CONFIGURED

Documentation
...             author:                 manasa hs, manasa.shankarappa@nokia.com
...             maintainer:             manasa hs, manasa.shankarappa@nokia.com
...
...             INTRODUCTION:      CB008444 Conformance Test and Type Approvals for 5G22R4
...             TEST SET NAME:     The purpose of this test is to verify from test Tool and gNB point of view,
...                                the correct initiation of a performance PUCCH test procedure with NR only RU FR1-FDD: F1-ACK 40. MHz
...             TESTING SPLIT:     See CB008444-B testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008444-B CFAM

Library            ../resources/python/BIP_Capture.py
Library            ../resources/python/CPRT_Capture.py
Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot


Suite Setup                Run keywords
...                        ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
#...                        AND     Perform SCF Delta Commissioning with Enable_CB007145.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             run keyword and ignore error    TCs Teardown

*** Test Cases ***
CB008444_B_010_Test_performance FDD PRACH format 0 - 30,10MHz - ASOE
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verify from test Tool and gNB point of view, the correct initiation of
    ...          a performance PUCCH test procedure with Test Model set to FR1-TDD: F0-ACK
    ...
    ...         Update configurable IE reportingTimeInterval value range and step to '0.1.. 3600, step 0.1'
    ...         second from webEM/test tool, currently the reportingTimeInterval value range and
    ...         step is '1.. 3600, step 1'second.
    ...
    ...         Special handling for configurable IE receivingSlot and expectationSlot
    ...         that only the LSB 8 bits of the pattern are used for TDD PUCCH/PRACH.
    ...
    ...
    ...     The following IE in messages are verified:
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
    ...                       TDD frame structure (3GPP 37.141) {
    ...                 *  DlData_SlotTypeReq (UL, DL and calibration)
    ...                 * _DlData_PatternConfigReq
    ...                 * _UlData_PucchReceiveReq contains {
    ...                         -	pucchFormat
    ...                         -	numOfPrb
    ...                         -	nANPucch
    ...                         -	numOfBitsOfUciInformation
    ...                         -	numOfSymbols
    ...                         -	dmrsSymbols
    ...                         -	firstSymbol
    ...                         -	frequencyHopping
    ...                         -	modulationType
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
    ...         HARDWARE ID:   AHFIB
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15519, 5G_RAN_USR_RRM_15520, 5G_RAN_USR_RRM_15521
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS
    ...  AUTHOR:     manasa.shankarappa@nokia.com
    ...
    ...  REFERENCES:   CB008444 CFAM
    ...
    ...
    Set test log path
    sleep   120s
    CPRT Monitoring Start ASOE
    run keyword and ignore error    Start Collecting Syslog

    Start Performance Test PRACH CB008444
    sleep    1ms    reason=Wait for successful response from admin

    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Bip Mon Start AP ASIK ABIL
    sleep    1ms    reason=Wait for successful response from admin
    Bip Mon Stop AP ASIK ABIL      ${LOG_PATH1}
    run keyword and ignore error    Stop Collecting Syslog
    

    Get information elements from L2PS_StartConformanceTestReq message for NR UL
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq and verify prachConfigurationIndex and pfaTargetPrachId    12   0    50
    Run keyword And Continue On Failure    Verify that ULCell_CellSetupReq contains prachformat is 0 for prachConfigurationIndex
    Run keyword And Continue On Failure    Verify that DlCell_CellSetupReq contains dlMimoMode set to 3 (OL 4x4 Or 4x2 MIMO)
    Run keyword And Continue On Failure    
    ...     Verify that prach StartConformance message contains the correct 8 bits for Receiving slot and Expection slot CB008444
    Run keyword And Continue On Failure    
    ...     Verify that ULData_PrachReceiveReq message contains the correct slot type based on recieving slot set CB008444

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
