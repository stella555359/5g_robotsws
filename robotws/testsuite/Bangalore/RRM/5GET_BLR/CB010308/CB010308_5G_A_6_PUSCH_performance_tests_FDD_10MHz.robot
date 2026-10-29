*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO    SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00      CONFIGURED

Documentation   :copyright: Nokia
...             :authors: Noble
...             :contact: noble.iyeswariyam_edison@nokia.com
...             Feature Overview:
...             INTRODUCTION:      CB010308 Conformance Test and Type Approvals for 23R4
...             The feature introduces changes to conformance test functionality due the changes of the 3GPP baseline of
...             this release.
...             The feature extends the conformance test coverage due to new features introduced in 23R4-SR
...             for a classical gNB or a eNB and for a 23R4-CR cloud BTS
...             This feature introduces the deployment for concurrent LTE and NR test mode.

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/robot/common_log_collection.robot
#Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Setup                Run keywords    Perform SCF Delta Commissioning with Delta_CB010308_TC6.json
...                        AND     ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${numofrun}         1
${start_run}        1
${end_run}          5
${frcIndex}         G_FR1_A9_2
#${SCFC}=            Bangalore/RRM/ET/CB010308/CB010308_A_6_scf.xml
#${AP_XML}=          Bangalore/RRM/ET/CB010308/CB010308_A_6_iphy.xml

*** Test Cases ***
[1]CB010308-5G-A_6_PUSCH_performance_tests-FDD-CPRI-ABIO_10MHz_G-FR1-A9-2_Robustness
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
	...  The purpose of this test is to verify the correct initiation of a conformance test procedure as 5G
	...  uplink(PUSCH performance)
	...  with FRC index set to - G-FR1-A9-2, gNB is set with FDD profile

    ${beampattern}       Create List       ${30}   ${30}
    FOR    ${numofrun}    IN RANGE    ${start_run}    ${end_run}+1
        Start Performance Test PUSCH    reporting_int=0.1
        ...                             beamPatternId=${beampattern}
        ...                             ru_mode=NR_Only
        ...                             pci=50
        ...                             frcIndex=G_FR1_A9_2
        ...                             mapType=B
        ...                             nrarfcn_ul=349000
        ...                             nrarfcn_dl=431000
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
    ...                             frcIndex=G_FR1_A9_2
    ...                             mapType=B
    ...                             nrarfcn_ul=349000
    ...                             nrarfcn_dl=431000
    sleep    5s    reason=Wait for successful response from admin
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message for NR RECEIVER_9500
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

	Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 52
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

    Get Information elements from StartConformanceTestReq message for PUSCH-G TC and verify CB010308 Mappingtype_B

    [Teardown]  Run Keywords     Stop Test Receiver test model
     ...         AND        Run Keyword and Ignore Error    Get Snapshot
     ...         AND        Link SCOUT SCF to Configuration ID for Reporting



