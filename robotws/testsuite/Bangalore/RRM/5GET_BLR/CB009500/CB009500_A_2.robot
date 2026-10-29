*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R3     CONFIGURED

Documentation
...
...
...             INTRODUCTION:      CB009500 Conformance Test and Type Approvals for 23R3


Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Teardown             TCs Teardown

*** Test Cases ***
[1][1.0] CB009500-5G-A_2_PUSCH_performance_tests_TDD_eCPRI_ABIO_10MHz_FRC_G-FR1-A3-11
    [Tags]   TC01
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify CB009500
    ...  Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
    ...  random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
    [Setup]   Run Keywords   Set Suite Variable    ${SCFC}      ${CURDIR}/config/SCF/10Mhz_ABIO_scf.xml
    ...   AND   Set Suite Variable    ${AP_XML}     ${CURDIR}/config/SCF/AEHC_iphy_AEHC.xml
    ...   AND   Set Suite Variable    ${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
    ...   AND   Set Suite Variable    ${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
    ...                        AND     Prepare TL with all config files
    ...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
    ...                        AND     Activate Test dedicated Mode
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${100}   ${100}
    Start Collecting Syslog
    Start Performance Test PUSCH    reporting_int=0.1
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A3_11
    ...                             mapType=A
    ...                             nrarfcn_ul=518598
    ...                             nrarfcn_dl=518598
    sleep    5s    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${750}   ${750}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_9500
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 24
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.1

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}

    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
	Stop Collecting Syslog
    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements

    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions_9500

    Get Information elements from StartConformanceTestReq message for PUSCH-G TC_9500_TC2 and verify1
    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB007200-5G-A_017_Test_performance_TDD_PRACH_format_ASIB_ABIO_CPRI_100_MHz
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
    ...         HARDWARE ID:   AEQA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_1716
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
    [Tags]   TC02   QC_168044      QCD_MN_RAN    QCP_RAN_ET
    [Setup]   Run Keywords   Set Suite Variable   ${SCFC}     Bangalore/RRM/ET/CB007200/scf_100MHz_30KHz_TDD.xml
    ...   AND     Set Suite Variable   ${AP_XML}          Bangalore/RRM/ET/CB007200/AEQE_iphy.xml
    ...   AND     Prepare TL with all config files
    ...   AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
    ...   AND     Perform SCF Delta Commissioning with delta_scf_chBw_100MHz_scs_30KHz_TDD.json
    ...   AND     sleep    5s    reason=Wait for successful response from admin
    ...   AND     Activate Test dedicated Mode
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}

    run keyword and ignore error    Start Collecting Syslog

    Start Performance Test PRACH
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    1ms    reason=Wait for successful response from admin

    Stop CPRT capture   ${CaptureCPRT}

    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    run keyword and ignore error    Stop Collecting Syslog

    Get information elements from L2PS_StartConformanceTestReq message for NR UL
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq and verify prachConfigurationIndex and pfaTargetPrachId    87   0    67
    Verify that ULCell_CellSetupReq contains prachformat is A2 for prachConfigurationIndex set to 87
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.5
    Verify that prach StartConformance message contains the correct 8 bits for Receiving slot and Expection slot
    Verify that ULData_PrachReceiveReq message contains the correct slot type based on recieving slot set
    Get Information Elements from cellsetupreq message and verify prach parameters     273
    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...     ${CURRENT_SYSLOG_PATH}     prach_a    change_beam=False

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting




*** Keywords ***

Verify pusch StartConformanceTestReq1
   [Arguments]      ${key}     ${expected_value}
   ${value}     get from dictionary       ${start_conf_variables}     ${key}
   ${value}     Convert To Boolean     ${value}
   ${value}     convert to string      ${value}
   should be equal      ${value}     ${expected_value}


Get Information elements from StartConformanceTestReq message for PUSCH-G TC_9500_TC2 and verify1
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        run keyword if     '${AirScale}' == 'ASOE'    Get Information Element from L2PS
    ...           ${LOG_PATH1}/SYSCOM_NODECPRT_GNB.pcap      itf_l2_ps_tm_cell_startconformancetestreq
    ...    ELSE     Get Information Element from L2PS     ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.1
   Verify pusch StartConformanceTestReq_frc    frcIndex      G_FR1_A3_11

    Verify pusch StartConformanceTestReq1    harqEnable     True
    Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
#   Verify pusch StartConformanceTestReq    prbOffset      0
    Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      0
