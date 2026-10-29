*** Settings ***
Force Tags      CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation
...
...             author:            Samik Sarkar, samik.sarkar@nokia.com
...             maintainer:        Samik Sarkar, samik.sarkar@nokia.com
...
...             INTRODUCTION:      CB008938 Conformance Test and Type Approvals for 23R1
...             TEST SET NAME:     CB008938-5G-A_006_Transmitter test model is successful aligned with 09-2021
...                                TS 38.141-1-2-NR-FR1-TM3.2-1Tx2Rx FDD-CPRI ABIN 20Mhz.
...             TESTING SPLIT:     See CB008938-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008938-A CFAM
...

Resource           ./CB008938_Resource.robot
Resource           ../resources/robot/common_log_collection.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Change IPHY File Value    AHPDA   2356
...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_20MHz_scs_15KHz_FDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CB008938/config/SCF/FDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CB008938/config/SCF/FDD_2cell_iphy.xml


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
    ...                    _nrCellindentity, type, transmiter testingConfig, polarization) are equal to ones set in WebElementManager
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
    ...         HARDWARE ID:   AHLOA
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

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${0}   ${0}
    Start Collecting Syslog
    Start DL Test Transmitter    test_model=TM3_2
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_plus45_or_0
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=0
    ...                          mimo_rank=1
    ...                          p_max=39
    sleep    1ms    reason=Wait for successful response from admin
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq
    Verify that ps_cell_CellSetupReq contains dlMimoMode set to 12 and nrCellType set to 6 (1x1 Single Antenna Transmission)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 106

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIP    [ABIP]    FS
    sleep    1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    run     tcpdump -r ${LOG_PATH}/BIP_L1L2.pcap -w ${LOG_PATH}/BIP_L1L2_Split.pcap -C 1
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2_Split.pcap

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify message DlData_PdcchSendReq for ConformanceTest_A001 without change beam    DICTONARY_PDCCHSENDREQ_IE=&{DICTONARY_PDCCHSENDREQ_IE_1x1}
    Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM3.2_FDD_UE1_C_20MHz_CB008938 for UE_1 - BW: 20MHz
    Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM3.2_FDD_UE2_C_20MHz_CB008938 for UE_2 - BW: 20MHz
	Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM3.2_FDD_UE3_C_20MHz_CB008938 for UE_3 - BW: 20MHz

    Verify PN23 sequence for PdcchSendReq

    Stop Collecting Syslog
    run keyword and ignore error     Check the syslog contain the startconformance test and other parameters for FDD
    ...     ${CURRENT_SYSLOG_PATH}    tm3.2_FDD_CB008938    change_beam=False

    [Teardown]  Run Keywords     Stop Test Transmitter test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
