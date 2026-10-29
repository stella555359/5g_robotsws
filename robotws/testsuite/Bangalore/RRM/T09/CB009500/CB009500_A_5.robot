*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      CONFIGURED

Documentation
...
...
...             INTRODUCTION:      CB009500 Conformance Test and Type Approvals for 23R3
...             The feature extends the conformance test coverage due to new features introduced
...             in 23R3-SR for a classical gNB and due to 3GPP changes (CRs).

Resource           ../../../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../../../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../../../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../../../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot

Suite Setup                Run keywords
...                        ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${SCFC}=            Bangalore/RRM/ET/CB009500/10Mhz_wo_scf.xml
${AP_XML}=          Bangalore/RRM/ET/CB009500/AEHC_iphy_AEHC.xml


*** Test Cases ***
[1][1.0] CB009500-5G-A_5_PUSCH_performance_tests-TDD-eCPRI-ABIO_10MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify CB009500 conformance test with NR in testmode.
    ...  This user scenario shall be run for following FRC for PUSCH performance operability: G-FR1-A5-11

        ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${100}   ${100}
    Start Collecting Syslog
    Start Performance Test PUSCH    reporting_int=0.1
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A5_11
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

    Get Information elements from StartConformanceTestReq message for PUSCH-G TC_9500_TC5 and verify

    [Teardown]  Run Keywords     Stop Test Receiver test model
     ...                 AND     Run Keyword and Ignore Error    Get Snapshot

