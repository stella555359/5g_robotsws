*** Settings ***
Force Tags      CLOUD_5G_O_H_AP_LOO    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_SC_FDD    5G_RAN
...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE   SBTS00     CONFIGURED

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
${SCFC}          ${CURDIR}/config/TC4/SCF_CB011018_ABIO.xml
${AP_XML}      ${CURDIR}/config/TC4/iphy_CB011018_AEHC.xml
${test_dn_perf1}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1
${test_dn_perf2}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_UPLINKCCM_TEST-1

*** Test Cases ***
[1]CB011018-A#3 TC4 G-FR1-A4-11 TDD-eCPRI ABIO 15MHz Successful_Operability_of_PUSCH_FRC
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...    The purpose of this test is to lead the GNB into Test Dedicated State (TDS) for conformance test and check
    ...    operability of TDS with 15MHz TDD Cell. PUSCH test model G-FR1-A4-11 will be configured and verified.
    ...    gNB is set with TDD FR1 profile
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
    ...                   *uldata_puschreceiverespharq
    ...
    ...                    }
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AEHC
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_2386
    ...
    ...  REQUIRED LOGS:   L1-L2 Bip logs ,CPRT logs ,Syslogs ,Snapshot
    ...
    ...  CONTACTS:   I_MN_RAN_RD_VRF_BLR1_T11_GMS <I_MN_RAN_RD_VRF_BLR1_T11@internal.nsn.com>
    ...  AUTHOR:     sruthi.jacob@nokia.com
    ...
    ...  REFERENCES:   CB011018 CFAM
    ...                5G_UP_12373

    ...
    Set test log path
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${1}   ${1}
    Start Collecting Syslog
    Start Performance Test PUSCH    reporting_int=1
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=50
    ...                             frcIndex=G_FR1_A4_11
    ...                             mapType=A
    ...                             nrarfcn_ul=518766
    ...                             nrarfcn_dl=518766
    sleep    5s    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${750}   ${750}
    ${test_dn_perf}    set variable if    '${DomainId}' == '1'    ${test_dn_perf1}    ${test_dn_perf2}
    Change beamPattern id    ${test_dn_perf}        ${changebeampattern}
    Stop CPRT capture   ${CaptureCPRT}

    Get Information elements from StartConformanceTestReq message for PUSCH_CB011018_A#3_TC4_and_verify
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq_CB011018
    Verify that DlCell_CellSetupReq contains dlMimoMode set to 0 (CL 2x2 MIMO)
    Verify the Reporting Time Interval between the MeasurementRepInd messages   1.0
    Verify that DlCell_CellSetupReq contains dlBandwidth set to 38
    Get Information Elements from Beampatternchangereq and verify     0     ${changebeampattern}
    Get Information Elements from Beampatternchangeresp and verify    0
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep    0.1ms    reason=Wait for successful response from admin
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    run     /bin/tcpdump -r ${LOG_PATH}/BIP_L1L2.pcap -w ${LOG_PATH}/BIP_L1L2_Split.pcap -C 1
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2_Split.pcap
    Get Information Elements from cellsetupreq message and verify pusch-a1 parameters    38     38
    Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements_CB011018
    Verify that ULData_PuschReceiveReq message contains the puschTransformPrecoderFlag disabled

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
