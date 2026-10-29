*** Settings ***
Documentation
...    author: Michal Obszarny
...    contact: michal.obszarny@nokia.com

Resource  resources/CB012734_resources.robot

Suite Setup  Run keywords  IWF Suite Setup  scfc=${scfc}  wts_cfg=${wts_cfg}  ap_xml=${iphy}  x2=True  del_RADs=@{del_RADs}  set_RADs=@{set_RADs}
...    AND   Configure and wait  ${CURDIR}/config/CB012734-H-B4.yaml  name=H-B4-configure  bts_id=1
...    AND   Configure and wait  ${CURDIR}/config/CB012734-prachConfigurationIndex_38.yaml  bts_id=1
Suite Teardown  Suite teardown after execution

*** Variables ***
${wts_cfg}=         ${CURDIR}/config/wts_212_UEs.lua
${scfc}=            ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=            ${CURDIR}/config/AP_AWEUB_8cells.xml
@{set_RADs}=        @{EMPTY}
@{del_RADs}=        0x590253    0x580953    0x580958    0x580957    0x580959    0x580983    0x590254    0x590255
${tti_trace_path}=  ${OUTPUTDIR}/TTI_Trace/
${logcollector}=    False

*** Test Cases ***
CB012734-H_B4_Maximum_number_of_connected_UEs_with_8_CC_with_complete_feature_activated
    [Documentation]
    ...  Description:
    ...    Exceeding 52 bits with single beam report allows to use more connected UEs.
    ...    In this scenario 8CC DL and 2CC UL and single beam report for 106 NSA connected UEs is tested.
    ...    The purpose of this test is to check the global gain when all sub-items are activated.
    ...
    ...  gNB configuration - SCF:
    ...    maxNumScellsDl = 7
    ...    maxNumScellsUl = 1    (NSA UE 8CC DL and 2CC UL)
    ...    actHighNumberOfUEs = True
    ...    actPucchBeamConstraintFR2 = TRUE
    ...    nbActiveCarriersThreshold = 200 (default value)
    ...
    ...    gNbCuType = NSA
    ...    nsaInactivityTimer = 6000
    ...    numberOfTransmittedSsBlocks = 32
    ...    prachConfigIndex = 38
    ...    guardPeriodLength = 2
    ...    csiReportPeriodicity = 320 slots
    ...    dlMimoMode = 30 (2x2 CL Mimo)
    ...    ReportQuantity = RI-PMI-CQI
    ...    pucchF2MaxCodeRate = 0.35
    ...    ccLoadThreshold = 100
    ...    maxNumOfUsers = 1000
    ...    maxNumOfNonGBRBearers = 1000
    ...    maxNumOfNonGBRBearersCGRPSA = 1000
    ...    maxNumOfNrDcSnNonGBRBearersCGRP = 1000
    ...    maxNumOfNrDcSnUsersCGRP = 1000
    ...    maxNumOfRrcCGRPSA = 1000
    ...    maxNumOfCaUsersNRCell = 106
    ...    maxNumOfNrDcSnUsers = 106
    ...    maxNumOfRrcSA = 106
    ...    maxNumOfSCellAlloc = 106
    ...    maxNumOfUsersPerCell = 106
    ...    maxNumOfUsersPerNRCell = 106
    ...
    ...  gNB configuration - RADs:
    ...    0x580953=default    rdActAutoSCellDeactivationOnLoad    -> (default = FALSE)    -> Subfeature -B -C
    ...    0x580957=default    rdActSinglePfMetricPerUeOnLoad      -> (default = TRUE )    -> Subfeature -D
    ...    0x580959=default    rdActEnhBeamSelection               -> (default = TRUE )    -> Subfeature -E
    ...    0x590253=default    rdActDedicatedCsiSlots              -> (default = TRUE )    -> Subfeature -A
    ...    0x590254=default    rdActIncreasedUciBits               -> (default = TRUE )    -> Subfeature -G
    ...    0x590255=default    rdActSingleBeamReport               -> (default = TRUE )    -> Subfeature -H

    [Setup]  Start Collecting GNB and AP syslog

    Configure AP test modes supported high throughput scenarios on IWF setup    first_ue_id=107    last_ue_id=212
    Attach multi ues    first_ue_id=107    last_ue_id=212
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs    ues=107-159    traffic_rate=23Mbps    dir=DL
    Start NSA traffic for multiple UEs    ues=160-212    traffic_rate=24Mbps    dir=DL
    Log to console    *** Started 23Mbps/24Mbps for each of 106 UEs
    Sleep    15s    reason=Wait for avg tput stabilization

    Start TTI trace
    Stop TTI trace    delay=2    target_dir=${tti_trace_path}
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace
    Stop TTI trace    delay=10    target_dir=${tti_trace_path}/TTI_Traces_10s
    Sleep    15s    reason=Wait for env stabilization

    Verify NSA DL throughput at gNB level
    ...    min_dl_traffic_mbps=1800
    ...    first_ue=107
    ...    last_ue=212
    ...    min_active_cc=839
    ...    max_active_cc=849

    Convert TTI trace pcap    input=${tti_trace_path}/l2stream3/tcpdump/tcpdump.pcap    output=${tti_trace_path}/output

    Verify in L2PS TTI Traces number of beams reported in CSI
    ...    expected_number_of_beams_reported_in_CSI=1
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that PUCCH is well decoded in all slots containing UCI or not
    ...    margin_percent=0.5
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces UCI payload size
    ...    expected_max_UCI_payload_bits=69
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that the average of carrier cuts and cell throughput are acceptable
    ...    skipped_ues_ratio_limit=0.435
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that overload control is improved during the scenario
    ...    min_scheduled_ues=${4.15}
    ...    max_scheduled_ues=${7.95}
    ...    min_skipped_ues=${1.75}
    ...    max_skipped_ues=${3.75}
    ...    min_slot_processing_time=${112500}
    ...    max_slot_processing_time=${124500}
    ...    csv_directory=${tti_trace_path}

    Sleep    300s    reason=Wait until more logs are collected

    [Teardown]  Run keywords
    ...         Collect Snapshot and Egate and Syslog logs
    ...  AND    Detach multi UEs    first_ue_id=107  last_ue_id=212
    ...  AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
