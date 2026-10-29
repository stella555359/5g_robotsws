*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation
...             author:                 manasa puttanagari, manasa.puttanagari@nokia.com
...             maintainer:             manasa puttanagari, manasa.puttanagari@nokia.com
...
...             INTRODUCTION:      CB008014 Conformance Test and Type Approvals for SBTS22R2
...             TEST SET NAME:     CB008014-A SBTS22R2 PUSCH performance for UL timing adjustment Scenario X on FR1,
...                                timing advnace value will be calculated by  5G-L2-PS and sent to L1 for UL timing adjustment.
...             TESTING SPLIT:     See CB008014-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008014-A CFAM
...

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_20MHz_scs_30KHz_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${SCFC}         ${CURDIR}/config/SCF/TDD_2cell_scf.xml
${AP_XML}       ${CURDIR}/config/SCF/TDD_2cell_iphy.xml

*** Test Cases ***
[1]CB008014-A_002_PUSCH performance for UL timing adjustment Scenario X on FR1 TDD G-FR1-A4-32A
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verify the correct initiation of a conformance test procedure
    ...          in case of Performance test for PUSCH with transform precoding disabled, step by step from L3/L2/L1 point of view .
    ...          gNB is set with TDD FR1 profile
    ...
    ...         Update configurable IE reportingTimeInterval value range and step to '0.1.. 3600, step 0.1'
    ...         second from webEM/test tool, currently the reportingTimeInterval value range and
    ...         step is '1.. 3600, step 1'second.
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
    ...                       TDD frame structure (3GPP 38.141) {
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
    ...         HARDWARE ID:   AEQE
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_6961
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS
    ...  AUTHOR:     manasa.puttanagari@nokia.com
    ...
    ...  REFERENCES:   CB008014 CFAM
    ...
    ...
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${100}   ${100}
    Start Collecting Syslog
    Start Performance Test PUSCH    reporting_int=0.2
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A4_32A
    ...                             mapType=A
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    Stop CPRT capture   ${CaptureCPRT}

    Get Information elements from StartConformanceTestReq message for PUSCH TC and verify      G_FR1_A4_32A
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.2

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    gNB_common_unit=ASIL      bb_mods=[ABIO]    l1_type=FS
    sleep    1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    run     /sbin/tcpdump -r ${LOG_PATH}/BIP_L1L2.pcap -w ${LOG_PATH}/BIP_L1L2_Split.pcap -C 1
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2_Split.pcap

    Stop Collecting Syslog

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Get Information Elements from cellsetupreq message and verify pusch-a parameters        51      51
    Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...      ${CURRENT_SYSLOG_PATH}     G_FR1_A4_32A      change_beam=False


    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog


