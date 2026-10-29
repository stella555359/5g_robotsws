*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Michal Obszarny
...    contact: michal.obszarny@nokia.com

Resource    resources/CB008453_resources.robot

Suite Setup       Run keywords
...               Prepare suite environment
...               scfc=${scfc}
...               egate_config=${egate_config}
...               ap_xml=${iphy}
...               x2=False
...               AND
...               Disable SA CA
...               AND
...               Create aliases
Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}                ${CURDIR}/config/wts_212_UEs_SA.lua
${scfc}                        ${CURDIR}/config/SCFC_2_AWEUC_8_cells_SA_CB008453_E_B3.xml
${iphy}                        ${CURDIR}/config/AP_2_AWEUC_8cells.xml
@{BIP_columns_SSB_SLOT_SFN}    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-E_B3_Single_UE_scheduling_without_carrier_aggregation_in_SA_mode_and_PRACH_format_B4
    [Documentation]
    ...  Description:
    ...    This user scenario validates the scheduling of a continuous data transmission for a single 5G-UE
    ...    according to the preconfigured semi-static frame structure with UL/DL ratio of 4:4 with HARQ processing
    ...    in both directions included in a stand-alone configuration and B4 PRACH format.
    ...
    ...  gNB configuration - SCF:
    ...    maxNumScellsDlSA = 0
    ...    maxNumScellsUlSA = 0
    ...    NRCELL.tddFrameStructure.frameStructureType = semiStatic
    ...    NRCELL.tddFrameStructure.ulDlDataSlotRatio = 4/4
    ...    NRCELL.cellDepType = SA
    ...    NRCELL.tddFrameStructure.guardPeriodLength = 6Symbols
    ...    NRCELL.prachConfigurationIndex = 129
    ...    NRCELL.rangeExtension = 0-6.9km
    ...    NRCELL.beamSet.beamsMuted = Bits 8, 9, 16 and 17 set to 1
    ...    NRCELLGRP.numberOfTransmittedSsBlocks = 20 beams
    ...    NRCELL.type0SearchSpaceConfigurationIndex = 8
    ...    NRCELL.inactiveSsbFr2 = 0x3F00 0000 0000 3F00
    ...
    ...  Setup/TestLine:
    ...    gNB (ASIM + ABIP)
    ...    Testline type: CLOUD_5G_I_MP_AP_LO
    ...    Variant: NSA_FS_ECPRI_MMWV_TDD_GMC
    ...    Simulated RRH: 2xAWEUC
    ...    Technology: TDD FR2
    ...    Mode: SA
    ...    Beamforming: Analog
    ...    Carrier Aggregation: None
    ...    UEs number: Single UE
    ...
    ...  Cells:
    ...    Cell    physCellId    Technology    Band    Bandwidth    Notes
    ...    1       50            TDD           N258    100MHz       Cell on gNB-1
    ...    2       51            TDD           N258    100MHz       Cell on gNB-1
    ...    3       52            TDD           N258    100MHz       Cell on gNB-1
    ...    4       53            TDD           N258    100MHz       Cell on gNB-1
    ...    5       54            TDD           N258    100MHz       Cell on gNB-1
    ...    6       55            TDD           N258    100MHz       Cell on gNB-1
    ...    7       56            TDD           N258    100MHz       Cell on gNB-1
    ...    8       57            TDD           N258    100MHz       Cell on gNB-1
    ...
    ...  Postconditions:
    ...    [OK]  1. 5G-UE SA is attached to the cell
    ...    [OK]  2. 5G-UE SA is scheduled in every UL and DL slot
    ...    [OK]  3. Data transfer in UL and DL is maintained all the time
    ...    [OK]  4. All DL HARQ feedbacks are received successfully
    ...    [OK]  5. SS slots, PRACH slots and TRS slots occur according to RRC configuration
    ...    [OK]  6. 5G-UE SA is transmitting HARQ feedback on a single PUCCH format 0 or format 2
    ...              according to the required number of HARQ-ACK bits
    ...    [OK]  7. 5G-UE SA is transmitting periodic CSI
    ...    [OK]  8. DL and UL bler is less than 0.5%

    Sleep    120s    reason=Wait for env stabilization
    Position UE1 in distance to cell - 6000m
    Set pdu param for internal traffic   UE_ID=1  PDU_ID=1
    Register UE    UE_ID=1    CELL_ID=1
    Establish PDU session    UE_ID=1    PDU_ID=1    GW_ID=1    RRC_CHECK=True
    Run keyword and continue on failure    Verify tdd-UL-DL-ConfigurationCommon on SA pcell with    guardPeriod=6    pcell_id=51    ue_id=1

    Start SA traffic    ue=1    dir=dl    traffic_rate=305Mbps
    Start SA traffic    ue=1    dir=ul    traffic_rate=325Mbps
    Sleep    5s    reason=wait for tput stabilization
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=DL    expected_traffic=305Mbps
    Run keyword and continue on failure    Verify SA traffic    ue=1    dir=UL    expected_traffic=325Mbps

    Start TTI trace collection
    Stop and convert TTI trace collection
    ...    directory_name=CB008453_E_B3_TTI_Trace
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData
    ...    delay=2

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B3_BIP    delay=2

    Convert BIP logs pcap to csv
    ...    pcap_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B3_BIP/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${OUTPUT_DIR}/${TEST_NAME}/CB008453_E_B3_BIP/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B3_tti_trace/
    Run keyword and continue on failure    Verify periodic csi is transmitting
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B3_tti_trace/
    Run keyword and continue on failure    Verify TRS on slots
    ...                                    slots=2,10,18,26,34
    ...                                    csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B3_tti_trace/
    Run keyword and continue on failure    Verify SSB on slots
    ...                                    slots=0,1,2,3,10,11,16,17
    ...                                    bip_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B3_BIP/
    ...                                    tti_csv_directory=${OUTPUTDIR}/${TESTNAME}/CB008453_E_B3_tti_trace/

    Start TTI trace collection
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/TTI_Trace_10s    delay=10

    [Teardown]    Run keywords
    ...           Deregister UE
    ...           UE_ID=1
    ...           AND
    ...           Run keyword and ignore error
    ...           setups_and_teardowns_keywords.Add main BTS metadata to report
