*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Documentation
...             author:                 sowrabha sm, sowrabha.s_m@nokia.com
...             maintainer:             sowrabha sm, sowrabha.s_m@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     CB007200-A 5G21B Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
...                                random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
...             TESTING SPLIT:     See CB007200-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007200-A CFAM
...


Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_40MHz_scs_30KHz_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${SCFC}=         ${CURDIR}/config/SCF/TDD_2cell_scf.xml
${AP_XML}=       ${CURDIR}/config/SCF/TDD_2cell_iphy.xml
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1

*** Test Cases ***
[1][2.0] CB007200-5G-G_003_Test_performance NR only RU TDD FR1 PUCCH-F1-ACK - 100 MHz
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
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${100}   ${100}
    Start Collecting Syslog
    Start Performance Test PUCCH    reporting_int=1.5
    ...                             beamPatternId=${beampattern}
    ...                             pucch_format=F0
    ...                             ru_mode=NR_Only
    ...                             pci=7
    ...                             format_2_test_type=Ack
    ...                             pucch_payload_content=1
    ...                             num_payload_bit=1
    ...                             numPucchSymbol=1
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    5s    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${750}   ${750}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}

	Stop CPRT capture   ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message for NR UL
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0

    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.5
    Verify that StartConformance message contains the correct 8 bits for Receiving slot and Expection slot

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
	Set L1L2 capture    ${CaptureL1L2}
	sleep    1ms    reason=Wait for successful response from admin
	Stop L1L2 capture   ${CaptureL1L2}
    Stop Collecting Syslog

    run keyword and ignore error    Verify that ULData_PucchReceiveReq message contains the correct slot type based on recieving slot set

	run keyword and ignore error    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    run keyword and ignore error
    ...     Verify that UlData_PucchReceiveReq is set in accordance with conformance test - prbOffset and largetPrbIndex verified for F0-ACK

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...     ${CURRENT_SYSLOG_PATH}     pucch

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog



[1][2.0] CB007200-5G-G_004_Test_performance NR only RU TDD FR1 PRACH format A2, CPRI, 100 MHz
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
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    Start Collecting Syslog
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}

    Start Performance Test PRACH
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    1ms    reason=Wait for successful response from admin

    ${changebeampattern}       Create List       ${200}   ${200}

    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}

    Stop CPRT capture   ${CaptureCPRT}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    run     /sbin/tcpdump -r ${LOG_PATH}/BIP_L1L2.pcap -w ${LOG_PATH}/BIP_L1L2_Split.pcap -C 1
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2_Split.pcap

    Stop Collecting Syslog

    Get information elements from L2PS_StartConformanceTestReq message for NR UL
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq and verify prachConfigurationIndex and pfaTargetPrachId    87   0    67
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0
    Get Information Elements from cellsetupreq message and verify prach parameters    106
    Verify that ULCell_CellSetupReq contains prachformat is A2 for prachConfigurationIndex set to 87
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.5
    Verify that prach StartConformance message contains the correct 8 bits for Receiving slot and Expection slot
    Verify that ULData_PrachReceiveReq message contains the correct slot type based on recieving slot set

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...      ${CURRENT_SYSLOG_PATH}     prach

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog



