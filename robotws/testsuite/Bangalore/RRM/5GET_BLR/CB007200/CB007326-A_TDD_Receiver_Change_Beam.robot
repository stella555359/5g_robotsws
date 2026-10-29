*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOO     SANSA_FS_ECPRI_CMWV_TDD
#...            CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00       SBTS23R1     CONFIGURED

Documentation
...
...             author:            Manasa Puttanagari, manasa.puttanagari@nokia.com
...             maintainer:        Manasa Puttanagari, manasa.puttanagari@nokia.com
...
...             INTRODUCTION:      CB007200 Conformance Test and Type Approvals for 5G21B
...             TEST SET NAME:     CB007200-A 3GPP CRs alignment and internal testability improvement
...             TESTING SPLIT:     See CB007200-A testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB007200 CFAM
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
#...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_100MHz_scs_30KHz_TDD.json
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown
*** Variables ***
${SCFC}=        ${CURDIR}/config/SCF/CB007326-A_TDD_Receiver_Change_Beam_scf.xml
${AP_XML}=      ${CURDIR}/config/SCF/CB007326-A_TDD_Receiver_Change_Beam_iphy.xml
${test_dn_rcvr1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINK_TEST-1
${test_dn_rcvr2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINK_TEST-1

*** Test Cases ***
[1][1.0] CB007326-A_002_Receiver test model G-FR1-A2-5 - FR1 TDD 90 MHz, CPRI,
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify the correct initiation of a conformance test procedure as 5G Uplink (receiver)
    ...  with Test Model set to G-FR1-A2-5, step by step from L3/L2/L1 point of view. gNB is set with TDD FR1 profile.
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
    ...       5. (L1-L2) [BIP] Check contents of following messages with specific setting corresponding to G-FR1-A2-5 {
    ...          The deboosted PRBs use 16QAM and boosted PRBs use QPSK. The total power is kept constant.
    ...          The power boosting level and power boosting/deboosting PRB locations are aligned with table Table 4.9.2.2.7-1 in 3GPP 38.141-1.
    ...                   *_DlData_PatternConfigReq
    ...                   _UlData_PuschReceiveReq
    ...                   _UlData_PuschReceiveReqInd
    ...           }
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEQA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_17936
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...
    ...  AUTHOR:     manasa.puttanagari@nokia.com
    ...
    ...  REFERENCES:   CB007200 CFAM, 5G_RAN_USR_7669
    ...

    Set test log path
    sleep   600s
    CPRT Monitoring Start ASOE
    ${beampattern}       Create List       ${1}   ${1}
    Start Collecting Syslog
    Start DL Test Transmitter    test_model=TM1_1
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=10
    ...                          mimo_rank=1
    ...                          p_max=35
    sleep    1ms    reason=Wait for successful response from admin

    Start Test Receiver FRC Index G_FR1_A2_5 on NR_Only
    sleep    1ms    reason=Wait for successful response from admin

    ${changebeampattern}       Create List       ${50}   ${50}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_rcvr1}    ${test_dn_rcvr2}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}

    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 273
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0


    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.0
    common_log_collection.Start BIP capture taf    ASOE    [ASOE]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    Stop Collecting Syslog

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions asoe

    run keyword and ignore error     Check the syslog contain the startconformance test and other parameters for TDD
    ...     ${CURRENT_SYSLOG_PATH}     G_FR1_A2_5    change_beam=False

    [Teardown]  Run Keywords    Stop Test Receiver G_FR model
    ...         AND     Run Keyword and Ignore Error   Link SCOUT SCF to Configuration ID for Reporting
    ...         AND         Stop Test Transmitter test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        run keyword if test failed      Bip Mon Stop AP ASIK ABIL       log_dir=${LOG_PATH1}
    ...         AND        run keyword if test failed      CPRT Monitoring Stop Collect ASOE       log_dir=${LOG_PATH1}