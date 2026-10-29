*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOO     RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD   SBTS00     CONFIGURED

Documentation
...             author:                 Sruthi Jacob
...             maintainer:             sruthi.jacob@nokia.com
...
...             INTRODUCTION:      CB011018-SR Conformance Test and Type Approvals for 24R3
...             TEST SET NAME:     CB011018-A
...             TESTING SPLIT:    CB011018-A
...             CONTACTS:         I_MN_RAN_RD_VRF_BLR1_T11_GMS <I_MN_RAN_RD_VRF_BLR1_T11@internal.nsn.com>
...             REFERENCES:       CB011018 CFAM
...

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     sleep    5s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode

Suite Teardown             TCs Teardown

*** Variables ***
${SCFC}          ${CURDIR}/config/TC2/SCF_CB011018_ASOE.xml
${AP_XML}      ${CURDIR}/config/TC2/iphy_CB011018_AEHC.xml
${test_dn_rcvr1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINK_TEST-1
${test_dn_rcvr2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINK_TEST-1
${test_dn_left}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_right}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
*** Test Cases ***

[1][1]CB011018-A#2_TC2_G-FR1-A1-2_G-FR1-A2-2_NR-FR1-TM3.2_TDD-eCPRI ASOE 15MHz Successful Operability of Reciever FRCs and Transmitter test models
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...
    ...      The purpose of this test is to lead the GNB into Test Dedicated State (TDS) for conformance test and check
    ...      operability of TDS with 15MHz TDD Cell.Below Receiver  FRCs will be  configured and verified.
    ...      a)G-FR1-A1-2
    ...      b)G-FR1-A2-2
    ...     Below Transmitter test models will be configured and verified
    ...      NR-FR1-TM3.2

    ...
    ...     The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                  *nrCellIdentity, type==control testingConfig, controlChannelTestType==PUSCH
    ...                  *ruMode is set to NR_ONLY
    ...                  *physCellId is set to 50
    ...            }
    ...
    ...       2. (L2PS)  From L2PS logs check values of PsCell_CellSetupReq:
    ...          *nrCellindentity, ,physCellId ,dlBandwidth/ulBandwidth - same as CpRtCm_StartConformanceTestReq
    ...
    ...
    ...       3. (L1-L3) [L1 logs] UlCell_CellSetupReq contains {
    ...                   *physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                    *scs is equal to one in cell configuration
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 0(CL 2X2)
    ...                   * dlBandwidth depends on bandwidth configured
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check message contents {
    ...               check content of following messages with specific setting
    ...                   *corresponding to FRC
    ...                   *DlData_SlotTypeReq
    ...                   *UlData_PuschReceiveReq
    ...                   *uldata_puschreceiverespps
    ...                   *uldata_puschreceiverespharqu
    ...                    }
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEHC
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_23825
    ...
    ...  REQUIRED LOGS:   L1-L2 Bip logs ,CPRT logs ,Syslogs ,Snapshot
    ...
    ...  CONTACTS:   I_MN_RAN_RD_VRF_BLR1_T11_GMS <I_MN_RAN_RD_VRF_BLR1_T11@internal.nsn.com>
    ...  AUTHOR:     sruthi.jacob@nokia.com
    ...
    ...  REFERENCES:   CB011018 CFAM
    ...
    ...
    Set test log path
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    CPRT Monitoring Start ASOE
    Start Test Receiver FRC Index G_FR1_A1_2 on NR_Only
    ${changebeampattern}       Create List       ${50}   ${50}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_rcvr1}    ${test_dn_rcvr2}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_CB011018
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq_CB011018
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.0
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 38
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0
    common_log_collection.Start BIP capture taf    ASOE    [ASOE]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology_CB011018
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    Stop Test Receiver G_FR model
    CPRT Monitoring Start ASOE
    Start Test Receiver FRC Index G_FR1_A2_2 on NR_Only
    ${changebeampattern}       Create List       ${50}   ${50}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_rcvr1}    ${test_dn_rcvr2}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_CB011018
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq_CB011018
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.0
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 38
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0
    common_log_collection.Start BIP capture taf    ASOE    [ASOE]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology_CB011018
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    CPRT Monitoring Start ASOE
    ${beampattern}       Create List       ${200}   ${200}
    Start DL Test Transmitter    test_model=TM3_2
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=0
    ...                          mimo_rank=1
    ...                          p_max=24
    sleep    1ms    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${69}   ${69}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_left}    ${test_dn_right}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}
    CPRT Monitoring Stop Collect ASOE      ${LOG_PATH1}
    Get Information Elements from Beampatternchangereq and verify     1     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    1
    common_log_collection.Start BIP capture taf    ASOE    [ASOE]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    Stop Test Receiver G_FR model
    Stop Test Transmitter test model
