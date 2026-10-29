*** Settings ***
#Force Tags    PY27
#Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
#...             CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS21B     CONFIGURED

Documentation
...
...             author:            Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...             maintainer:        Vaibhav Tyagi, vaibhav.3.tyagi@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     CB007200-A 5G21B Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
...                                random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
...             TESTING SPLIT:     See CB007200-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007200-A CFAM
...

Resource           ../resources/robot/ConformanceConstants/Constants_general.robot
Resource           ../resources/robot/ConformanceTest_keywords.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog.robot


Suite Setup                Run keywords
...                        ConformanceTest_Setup_Env.Suite Setup from scratch
...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_50MHz_scs_30KHz_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_left}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_right}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1

*** Test Cases ***
[1][1.0] CB007200-5G-A_003_Transmitter test model is successful aligned with 09-2020 TS 38.141-1-2-NR-FR1-TM3.1a-TDD-CPRI
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify the correct CB007200-A 5G21B
    ...  Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
    ...  random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
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
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 0(CL 2X2)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check contents of following messages with specific setting corresponding to TM3_1A {
    ...                   *_DlData_PatternConfigReq
    ...                   *_DlData_PdcchSendReq
    ...                   *_DlData_PdschSendReq
    ...                   *_DlData_PdschPayloadTbSendReq (payload = 0)
    ...           }
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEQA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_8146
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...
    ...  REFERENCES:   CB007200 CFAM, 5G_RAN_USR_8146
    ...

    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${200}   ${200}
    Start Collecting Syslog
    Start DL Test Transmitter    test_model=TM3_1A
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=10
    ...                          mimo_rank=1
    ...                          p_max=35
    sleep    1ms    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${69}   ${69}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_left}    ${test_dn_right}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 133
    Get Information Elements from Beampatternchangereq and verify     1     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    1


    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}
    sleep    1ms    reason=Wait for successful response from admin
    Stop L1L2 capture  ${CaptureL1L2}

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that message DlData_PdcchSendReq contains IE values in accordance with conformance test requirements
    Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM3_1A_TDD_UE1_C_50MHz_CB007200 for UE_1 - BW: 50MHz
    Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM3_1A_TDD_UE2_C_50MHz_CB007200 for UE_2 - BW: 50MHz

    Verify PN23 sequence for PdcchSendReq
    Verify PN23 sequence for PdschPayloadTbSendReq for testmodel         'tm3_1A'

    Stop Collecting Syslog
    run keyword and ignore error     Check the syslog contain the startconformance test and other parameters for TDD
    ...      ${CURRENT_SYSLOG_PATH}    tm3.1A

    [Teardown]  Run Keywords     Stop Test Transmitter test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog

