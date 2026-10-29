*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB009500/CB009500_A_9.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      CONFIGURED

Documentation
...
...
...             INTRODUCTION:      CB009500 Conformance Test and Type Approvals for 23R3
...             The feature extends the conformance test coverage due to new features introduced
...             in 23R3-SR for a classical gNB and due to 3GPP changes (CRs).

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot

Suite Setup                Run keywords    Prepare TL with all config files
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${SCFC}=            Bangalore/RRM/ET/CB009500/10Mhz_wo_scf.xml
${AP_XML}=          Bangalore/RRM/ET/CB009500/AEHC_iphy_AEHC.xml

*** Test Cases ***
[1][1.0] CB009500-5G-A_9_Transmitter_Receiver-TDD-eCPRI-ABIO_10MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify CB009500 conformance test with NR in testmode.
    ...  This user scenario shall be run for Transmitter test models:  NR-FR1-TM2
    ...  This user scenario shall be run for following FRC for pusch receiver operability: G-FR1-A2-2

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${200}   ${200}
    Start Collecting Syslog
    Start DL Test Transmitter    test_model=TM2
    ...                          ru_mode=NR_Only
    ...                          pci=50
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=0
    ...                          mimo_rank=1
    ...                          p_max=23
    sleep    1ms    reason=Wait for successful response from admin

    Start Test Receiver FRC Index G_FR1_A2_2 on NR_Only
    sleep    1ms    reason=Wait for successful response from admin

    ${changebeampattern}       Create List       ${69}   ${69}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 24
    Get Information Elements from Beampatternchangereq and verify     1     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    1

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    Stop Collecting Syslog

    Verify that DlData_SlotTypeReq message contains the correct slot type based on cell technology for TM2 and TM2a 9500
    Verify that message DlData_PdcchSendReq contains IE values in accordance with conformance test requirements

    Verify message DlData_PdschSendReq based on Test Model Dictionary - DL_PDSCHSENDREQ_TM2_TDD_UE2_10MHz_CB009500 for UE_2 - BW: 10MHz
    Verify PN23 sequence for PdcchSendReq

    Get Information elements from StartConformanceTestReq message for PUSCH-G_9500 TC and verify    G_FR1_A2_2
    Get Information Elements from cellsetupreq message and verify pusch-a1 parameters        24      24
    Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions_9500

    [Teardown]  Run Keywords     Stop Test Transmitter test model
     ...                 AND     Run Keyword and Ignore Error    Get Snapshot


