*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1      CONFIGURED

Documentation
...             author:                 sowrabha sm, sowrabha.s_m@nokia.com
...             maintainer:             sowrabha sm, sowrabha.s_m@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     The purpose of this test is to verify from test Tool and gNB point of view,
...                                the correct initiation of a performance PUCCH test procedure with NR only RU FR1-FDD: F1-ACK 5 MHz
...             TESTING SPLIT:     See CB007200-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007200-A CFAM

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_100MHz_scs_30KHz_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             run keyword and ignore error    TCs Teardown

*** Variables ***
${SCFC}=            Bangalore/RRM/ET/CB007200/scf_100MHz_30KHz_TDD.xml
${AP_XML}=          Bangalore/RRM/ET/CB007200/AEQE_iphy.xml

*** Test Cases ***
[1][2.0] CB007200-5G-A_018_Test_performance NR only RU TDD FR1 PUCCH-F1-ACK - 100 MHz
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
#    [Tags]     QC_129805    QC_201726      QCD_MN_RAN    QCP_RAN_ET
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${100}   ${100}
    run keyword and ignore error    Start Collecting Syslog
	${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}

    Start Performance Test PUCCH    reporting_int=1.1
    ...                             beamPatternId=${beampattern}
    ...                             pucch_format=F0
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             format_2_test_type=Ack
    ...                             pucch_payload_content=1
    ...                             num_payload_bit=1
    ...                             numPucchSymbol=1
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    5s    reason=Wait for successful response from admin

	Stop CPRT capture   ${CaptureCPRT}

    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap

    run keyword and ignore error    Stop Collecting Syslog

    Get information elements from L2PS_StartConformanceTestReq message for NR UL
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.1
    Verify that StartConformance message contains the correct 8 bits for Receiving slot and Expection slot
    run keyword and ignore error   Verify that ULData_PucchReceiveReq message contains the correct slot type based on recieving slot set
  	Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    run keyword and ignore error
    ...     Verify that UlData_PucchReceiveReq is set in accordance with conformance test - prbOffset and largetPrbIndex verified for F0-ACK
    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for TDD
    ...     ${CURRENT_SYSLOG_PATH}     pucch_a    change_beam=False

    [Teardown]  Run Keywords
    ...         run keyword and ignore error     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
