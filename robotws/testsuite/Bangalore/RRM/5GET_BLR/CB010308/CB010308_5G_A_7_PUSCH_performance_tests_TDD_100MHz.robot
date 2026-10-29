*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB010308/CB010308_A_7.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      CONFIGURED

Documentation

...
...
...             INTRODUCTION:      CB010308 Conformance Test and Type Approvals for 23R4
...             The feature introduces changes to conformance test functionality due the changes of the 3GPP baseline of this release.
...             The feature extends the conformance test coverage due to new features introduced in 23R4-SR for a classical gNB or a eNB
...             and for a 23R4-CR cloud BTS
...             This feature introduces the deployment for concurrent LTE and NR test mode.

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot

Suite Setup                Run keywords     Prepare TL with SCF change    
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${frcIndex}         G_FR1_A9_5
${numofrun}         1
${start_run}        1
${end_run}          5
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${SCFC}=                   Bangalore/RRM/ET/CB010308/CB010308_A_7_scf.xml

*** Test Cases ***
[1]CB010308-5G-A_7_PUSCH_performance_tests-TDD-eCPRI-ABIO_100MHz_G-FR1-A9-5_Robustness
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
	...  The purpose of this test is to verify the correct initiation of a conformance test procedure as 5G Uplink(PUSCH performance)
	...  with FRC index set to - G-FR1-A9-5, gNB is set with TDD profile

    ${beampattern}       Create List       ${30}   ${30}
    FOR    ${numofrun}    IN RANGE    ${start_run}    ${end_run}+1
        Start Performance Test PUSCH    reporting_int=0.1
        ...                             beamPatternId=${beampattern}
        ...                             ru_mode=NR_Only
        ...                             pci=50
        ...                             frcIndex=G_FR1_A9_5
        ...                             mapType=A
        ...                             nrarfcn_ul=636666
        ...                             nrarfcn_dl=636666
        sleep    5s    reason=Wait for successful response from admin
        Stop Test Receiver test model
    END

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    Start Collecting Syslog

    Start Performance Test PUSCH    reporting_int=0.1
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A9_5
    ...                             mapType=A
    ...                             nrarfcn_ul=636666
    ...                             nrarfcn_dl=636666

    sleep    5s    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${30}   ${30}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}

    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_9500
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Verify that DlCell_CellSetupReq contains dlMimoMode set to 1 (CL 4x4 or 4x2 MIMO)

    Verify that DlCell_CellSetupReq contains dlBandwidth set to 273
    Verify the Reporting Time Interval between the MeasurementRepInd messages   0.1
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}

    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
	Stop Collecting Syslog

    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements_ABIL9500
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled
    Verify that UlData_PuschReceiveReq message is in accordance with TC assumptions_9500

    Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify CB010308
	
	
    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND     Run Keyword and Ignore Error    Get Snapshot

