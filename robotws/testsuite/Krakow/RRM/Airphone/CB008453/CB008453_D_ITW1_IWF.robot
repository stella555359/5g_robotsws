*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    author: Michal Obszarny
...    contact: michal.obszarny@nokia.com

Resource    resources/CB008453_resources.robot
Resource    ../CB012734/resources/CB012734_resources.robot

Suite Setup    Run keywords
...    IWF Suite Setup    scfc=${scfc}   wts_cfg=${wts_cfg}    ap_xml=${iphy}    x2=False    del_RADs=@{del_RADs}    set_RADs=@{set_RADs}
...    AND    Configure and wait    ${CURDIR}/config/CB008453_feature_enable.yaml    bts_id=1
...    AND    Configure and wait    ${CURDIR}/config/CB008453_D_ITW1_CB012734_enable.yaml    bts_id=1
Suite Teardown    Suite teardown after execution

*** Variables ***
${wts_cfg}=           ${CURDIR}/config/wts_212_UEs_NSA_IWF.lua
${scfc}=              ${CURDIR}/config/SCFC_2_AWEUC_8_cells_NSA_IWF_CB008453_D_B1.xml
${iphy}=              ${CURDIR}/config/AP_2_AWEUC_8cells.xml
@{set_RADs}=          @{EMPTY}
@{del_RADs}=          0x590253    0x580953    0x580958    0x580957    0x580959    0x580983    0x590254    0x590255
${tti_trace_path}=    ${OUTPUTDIR}/TTI_Trace/
${bip_logs_path}=     ${OUTPUTDIR}/BIP_Logs/
${logcollector}=      False
@{BIP_columns_SSB_SLOT_SFN}=    dldata_ssblocksendreql1sw    3gpp.sfn    3gpp.slot

*** Test Cases ***
[1][1.0] CB008453-D_ITW1_Maximum_number_of_RRC_connected_users_with_8CC
    [Documentation]
    ...  Description:
    ...    This user scenario validates the scheduling of a continuous data transmission for 106 5G-UEs
    ...    according to the preconfigured semi-static frame structure with UL/DL ratio of 4:4 with HARQ processing
    ...    in both directions included with 8CC configured.
    ...
    ...  gNB configuration - SCF:
    ...    NRCELL.tddFrameStructure.frameStructureType = semiStatic
    ...    NRCELL.tddFrameStructure.ulDlDataSlotRatio = 4/4
    ...    NRCELL.cellDepType = NSA
    ...    NRCELL.tddFrameStructure.guardPeriodLength = 2Symbols
    ...    NRCELL.prachConfigurationIndex = 176
    ...    NRCELLGRP.actHighNumberOfUEs	= true
    ...    NRBTS.maxNumScellsDl	= 7
    ...    NRBTS.maxNumScellsUl	= 3
    ...
    ...  Setup/TestLine:
    ...    gNB (ASIM + ABIP)
    ...    Testline type: CLOUD_5G_I_MP_AP_LO
    ...    Variant: NSA_FS_ECPRI_MMWV_TDD_GMC
    ...    Simulated RRH: 2xAWEUC
    ...    Technology: TDD FR2
    ...    Mode: NSA
    ...    Beamforming: Analog
    ...    Carrier Aggregation: 8CC DL 4CC UL
    ...    UEs number: Multi 106 NSA UEs
    ...
    ...  Cells:
    ...    Cell    physCellId    Technology    Band    Bandwidth    Notes
    ...    1       50            TDD           N257    100MHz       Cell on gNB-1
    ...    2       51            TDD           N257    100MHz       Cell on gNB-1
    ...    3       52            TDD           N257    100MHz       Cell on gNB-1
    ...    4       53            TDD           N257    100MHz       Cell on gNB-1
    ...    5       54            TDD           N257    100MHz       Cell on gNB-1
    ...    6       55            TDD           N257    100MHz       Cell on gNB-1
    ...    7       56            TDD           N257    100MHz       Cell on gNB-1
    ...    8       57            TDD           N257    100MHz       Cell on gNB-1
    ...
    ...  POSTCONDITIONS:
    ...    [ OK]  1. 106 5G-UEs NSA are attached to the cell
    ...    [ OK]  2. 106 5G-UEs NSA are scheduled in every UL and DL slot (each slot with a potential different UE)
    ...    [ OK]  3. Data transfer in UL and DL is maintained all the time
    ...    [ OK]  4. The transmitted data 5G packets can be decoded successfully
    ...    [ OK]  5. All DL HARQ feedbacks are received successfully
    ...    [ OK]  6. The achived data rate in both directions is in line with expectations (50% of tput value reached by single UE 8CC DL 4 CC UL)
    ...    [ OK]  7. SS slots, PRACH slots and TRS slots occur according to RRC configuration
    ...    [ OK]  8. 106 5G-UEs NSA are transmitting HARQ feedback on a single PUCCH format 0 or format 2
    ...              according to the required number of HARQ-ACK bits
    ...    [ OK]  9. 106 5G-UEs NSA are transmitting periodic CSI
    ...    [ OK] 10. DL and UL bler is less than 0.5%
    ...
    ...    Tput estimated by NR DIMM:             DL: 347Mbps per Cell    ||    UL: 250Mbps per Cell
    ...    Tput reached in single UE scenario:    DL: 347Mbps per Cell    ||    UL: 250Mbps per Cell
    ...
    ...    Tput Expected in EXCEL (106UEs x 8CC DL x 4CC UL):
    ...    DL - 2321 Mbps (target  L1 1800Mbps)
    ...    UL - 1438 Mbps (Target L1 1100Mbps)

    [Setup]  Start Collecting GNB and AP syslog

    Sleep    180s    reason=Wait for env stabilization
    Configure Airphone test modes supported high throughput scenarios on IWF setup    first_ue_id=107    last_ue_id=212
    Attach multi ues   first_ue_id=107  last_ue_id=212
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs  ues=107-159  traffic_rate=20Mbps  dir=DL
    Start NSA traffic for multiple UEs  ues=160-212  traffic_rate=19Mbps  dir=DL
    Log to console    *** Started 19Mbps/20Mbps on DL for each of 106 UEs
    Start NSA traffic for multiple UEs  ues=107-212  traffic_rate=5Mbps  dir=UL
    Log to console    *** Started 5Mbps on UL for each of 106 UEs
    Sleep    15s    reason=Wait for avg tput stabilization

    Start collecting BIP logs
    Stop collecting BIP logs    dir_path=${bip_logs_path}    delay=2

    Start TTI trace
    Stop TTI trace    delay=2    target_dir=${tti_trace_path}
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace
    Stop TTI trace    delay=10    target_dir=${tti_trace_path}/TTI_Traces_10s
    Sleep    15s    reason=Wait for env stabilization

    Verify DL NSA throughput at gNB level
    ...    expected_dl_traffic_mbps=2050
    ...    margin_mbps=250
    ...    first_ue=107
    ...    last_ue=212
    ...    min_active_cc=841
    ...    max_active_cc=849

    Verify UL NSA throughput at gNB level
    ...    expected_ul_traffic_mbps=550
    ...    margin_mbps=50
    ...    first_ue=107
    ...    last_ue=212
    ...    min_active_cc=421
    ...    max_active_cc=425

    Convert TTI trace pcap    input=${tti_trace_path}/l2stream3/tcpdump/tcpdump.pcap    output=${tti_trace_path}/output
    ...    conversion_filter=utcTimestampData|csiSrReportData|csiRsSchedData|dlFdSchedData|dlHarqRxDataArray|ulFdSchedData|ulHarqRxData

    Convert BIP logs pcap to csv
    ...    pcap_path=${bip_logs_path}/L1L2_BIP_Logs/tcpdump.pcap
    ...    filter=dldata_ssblocksendreql1sw
    ...    columns=@{BIP_columns_SSB_SLOT_SFN}
    ...    dir_path=${bip_logs_path}/
    ...    csv_log_name=BIP_Logs.csv

    Run keyword and continue on failure    Verify HARQ feedback on single PUCCH    csv_directory=${tti_trace_path}    ack_nack_check=False
    Run keyword and continue on failure    Verify periodic csi is transmitting    csv_directory=${tti_trace_path}
    Run keyword and continue on failure    Verify TRS on slots    slots=3,11,19,27,35,43,51,59    csv_directory=${tti_trace_path}
    Run keyword and continue on failure    Verify SSB on slots    slots=0,1,2,3,10,11,16,17    bip_csv_directory=${bip_logs_path}
    ...                                                                                        tti_csv_directory=${tti_trace_path}

    Run keyword and continue on failure    Verify BLER from Dl ACK NACK results    csv_directory=${tti_trace_path}    margin_percent=0.25
    Run keyword and continue on failure    Verify BLER from Ul CRC results    csv_directory=${tti_trace_path}    margin_percent=0.25

    [Teardown]    Run keywords
    ...           Collect Snapshot and Egate and Syslog logs
    ...    AND    Detach multi UEs    first_ue_id=107  last_ue_id=212
    ...    AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
