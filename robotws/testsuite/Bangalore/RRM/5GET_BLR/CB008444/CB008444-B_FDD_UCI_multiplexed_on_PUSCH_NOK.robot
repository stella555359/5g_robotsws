*** Settings ***
#Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#...             CONFIGS_Bangalore/RRM/ET/CB008444/CB008444_B_011.yml
#...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Documentation
...             author:                 manasa hs, manasa.shankarappa@nokia.com
...             maintainer:             manasa hs, manasa.shankarappa@nokia.com
...
...             INTRODUCTION:      CB008444 Conformance Test and Type Approvals for 5G22R4
...             TEST SET NAME:
...             CB008444_B_011_Performance testing of UCI multiplexed on PUSCH for FR1 FDD-CPRI-non-beamforming, ABIO, CPRI, 40 MHz
...             TESTING SPLIT:     See CB008444-B testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008444-B CFAM
...

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot

Suite Setup                Run keywords
...                        ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Test Cases ***
CB008444_B_011_Performance testing of UCI multiplexed on PUSCH for FR1 FDD-CPRI-non-beamforming, ABIO, eCPRI, 40 MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verify from test Tool and gNB point of view, the correct initiation of
    ...          a performance PUCCH test procedure with Test Model set to FR1-FDD: F0-ACK
    ...
    ...         Update configurable IE reportingTimeInterval value range and step to '0.1.. 3600, step 0.1'
    ...         second from webEM/test tool, currently the reportingTimeInterval value range and
    ...         step is '1.. 3600, step 1'second.
    ...
    ...         Special handling for configurable IE receivingSlot and expectationSlot
    ...         that only the LSB 8 bits of the pattern are used for FDD PUCCH/PRACH.
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
    ...         HARDWARE ID:   AHFII
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
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${10}   ${10}
    Start Collecting Syslog
    Start Performance Test PUSCH UCI     reporting_int=.7
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=187
    ...                             frcIndex=G_FR1_A4_9
    ...                             mapType=B
    ...                             nrarfcn_ul=135760
    ...                             nrarfcn_dl=126380
    sleep    3s    reason=Wait for successful response from admin
    Stop CPRT capture   ${CaptureCPRT}

    Get Information elements from StartConformanceTestReq message for Long PUCCH TCs and verify
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Run Keyword and Continue on Failure     Verify that DlCell_CellSetupReq contains dlMimoMode set to 2 (OL 2x2 MIMO)
    Run Keyword and Continue on Failure     Verify the Reporting Time Interval between the MeasurementRepInd messages   0.7
    Run Keyword and Continue on Failure     Verify the detected and missed counters in the MeasurementRepInd messages for Pusch

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture    ${CaptureL1L2}
    Stop L1L2 capture   ${CaptureL1L2}
    Stop Collecting Syslog

    Run Keyword and Continue on Failure     Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveReq message contains the numofUciCsiPart1Bits
    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for FDD
    ...       ${CURRENT_SYSLOG_PATH}     pusch    change_beam=False

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
