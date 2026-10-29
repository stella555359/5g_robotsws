*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO
...             CRT    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    5G_RAN     SBTS00    SBTS23R1     CONFIGURED

Documentation
...             author:                 prerana n s, prerana.n_s@nokia.com
...             maintainer:             prerana n s, prerana.n_s@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     CB007200-A 5G21B Update data content of ?all zero data? to random data for PDCCH and PDSCH channels,
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

Suite Setup                Run keywords     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Perform SCF Delta Commissioning with delta_scf_7200_E_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${SCFC}=            Bangalore/RRM/ET/CB007200/scf_100MHz_30KHz_TDD.xml
${AP_XML}=          Bangalore/RRM/ET/CB007200/AEQE_iphy.xml

*** Test Cases ***
[1][1.0] CB007200-5G-E_001_Performance testing of UCI multiplexed on PUSCH for FR1 TDD-eCPRI-non-beamforming
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verify the correct initiation of a conformance test procedure in case
    ...          of Perfomance testing of UCI multiplexed on PUSCH, step by step for new FRC G-FR1-A4-11 from
    ...          webEM->OAM->CP-RT->L2-PS->L1  point of view .gNB is set with TDD FR1 profile
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
    ...                   * DlMimoMode set to 1(CL 4X4)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check message contents with settings corresponding to F0-ACK (3GPP 38.141-1) and
    ...                       TDD frame structure (3GPP 37.141) {
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
    ${beampattern}       Create List       ${10}   ${10}
    Start Collecting Syslog
    Start Performance Test PUSCH UCI     reporting_int=.7
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=187
    ...                             frcIndex=G_FR1_A4_11
    ...                             mapType=B
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666
    sleep    3s    reason=Wait for successful response from admin
    Stop CPRT capture   ${CaptureCPRT}

    Get Information elements from StartConformanceTestReq message for Long PUCCH TCs and verify frc
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.7
    Verify the detected and missed counters in the MeasurementRepInd messages for Pusch

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    run     tcpdump -r ${LOG_PATH}/BIP_L1L2.pcap -w ${LOG_PATH}/BIP_L1L2_Split.pcap -C 1
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2_Split.pcap
    Stop Collecting Syslog

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that ULData_PuschReceiveReq message contains the numofUciCsiPart1Bits
    Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for FDD
    ...       ${CURRENT_SYSLOG_PATH}     pusch    change_beam=False

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Get Information elements from StartConformanceTestReq message for Long PUCCH TCs and verify frc
    Log to console                       Checking StartConformanceTestReq OAM-CPRT IE
    Log Variables
    ${start_conf_variables}        Get Information Element from L2PS UCI  ${CaptureCPRT.path}     itf_l2_ps_tm_cell_startconformancetestreq
    set suite variable       ${start_conf_variables}     ${start_conf_variables}
    Log Variables
    should be true    ${start_conf_variables.reportingTimeInterval} == 0.7
	Verify pusch StartConformanceTestReq_frc    frcIndex     G_FR1_A4_11
	Verify pusch StartConformanceTestReq    harqEnable     1
	Verify pusch StartConformanceTestReq    prbOffset_receive_test      0
	#Verify pusch StartConformanceTestReq    prbOffset      0
	Verify pusch StartConformanceTestReq    ruMode_type    0
    Verify pusch StartConformanceTestReq    ulDmrsMappingType      1
	Verify pusch StartConformanceTestReq    csiPayloadBit-Length    2
	Verify pusch StartConformanceTestReq    csiPayloadBit_item_0     1342177280
	Verify pusch StartConformanceTestReq    csiPayloadBit_item_1     2147483648
	Verify pusch StartConformanceTestReq    numUciBits     7
