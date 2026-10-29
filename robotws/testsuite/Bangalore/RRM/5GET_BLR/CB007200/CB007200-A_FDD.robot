*** Settings ***
Force Tags      CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00        SBTS23R1     CONFIGURED

Documentation
...
...             author:            Akhil K P, akhil.k_p@nokia.com
...             maintainer:        Akhil K P, akhil.k_p@nokia.com
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
Library            ./resources/python/l1b_tag_gnb.py

Suite Setup                Run keywords
#...                        update_swconfig_gnb    ${rad}
...                        Log To console  SuiteSetup
...                        AND     Prepare TL with all config files
#...                        AND     Add RD Parameters To GNB Swconfig File    0x480005=0
#...                        AND     Perform SCF Delta Commissioning with delta_scf_chBw_20MHz_scs_15KHz_FDD.json
...                        AND     ssh_cmd.Gnb Ap Reboot
...                        AND     sleep    300s
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***

${SCFC}=        ${CURDIR}/config/SCF/scf_chBw_20MHz_scs_15KHz_FDD.xml
${AP_XML}=      ${CURDIR}/config/SCF/FDD_2cell_iphy.xml

${test_dn}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINK_TEST-1
${rad}    0x480005=0
*** Test Cases ***
[1][2.0] CB007200-5G-A_012_Transmitter test model is successful aligned with 09-2020 TS 38.141-1-2-NR-FR1-TM2-FDD-CPRI
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify the correct CB007200-A 5G21B
    ...  Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
    ...  random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
    ...
    ...     The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                       nrCellindentity,
    ...                       type,
    ...                       transmiter testingConfig,
    ...                       polarization - are equal to ones set in WebElementManager
    ...                       ruMode is set to NR
    ...                       physCellId
    ...            }
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
    ...       5. (L1-L2) [BIP] Check contents within {
    ...                 * DlData_SlotTypeReq
    ...                 * DlData_PdcchSendReq
    ...                 * DlData_PdschSendReq
    ...                 * IE modulationOrder should be set to 2 (QPSK modulation) for boosted and deboosted PRB.
    ...                 * IE mcs should be set to 0.
    ...                 * DlData_PdschPayloadTbSendReq (payload = 0)
    ...           }
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AHLOA
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_7625
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here.
    ...
    ...  CONTACTS:   OU_MN_RAN_L3_SW_2_KRK_3_SG_53004197@internal.nsn.com
    ...  AUTHOR:     nelsandro.sampaio@nokia.com
    ...
    ...  REFERENCES:   CB007200 CFAM, 5G_RAN_USR_7625
    ...
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture     ${CaptureCPRT}
    ${beampattern}       Create List       ${1}   ${1}
    Start Collecting Syslog
    Start DL Test Transmitter    test_model=TM2
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=10
    ...                          mimo_rank=2
    ...                          p_max=29
    sleep    1ms    reason=Wait for successful response from admin
    Stop CPRT capture    ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 106

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements

    Verify message DlData_PdcchSendReq for ConformanceTest_A001 without change beam
    Verify message DlData_PdschSendReq for ConformanceTest_A001

    Verify PN23 sequence for PdcchSendReq
#    Verify PN23 sequence for PdschPayloadTbSendReq for testmodel         'tm2'
    Stop Collecting Syslog
    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for FDD
    ...     ${CURRENT_SYSLOG_PATH}     tm2    change_beam=False

    [Teardown]  Run Keywords     Stop Test Transmitter test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
