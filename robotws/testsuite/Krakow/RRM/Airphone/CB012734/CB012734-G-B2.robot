*** Settings ***
Documentation
...    author: Michal Obszarny
...    contact: michal.obszarny@nokia.com

Resource  resources/CB012734_resources.robot

Suite Setup  Run keywords  IWF Suite Setup  scfc=${scfc}  wts_cfg=${wts_cfg}  ap_xml=${iphy}  x2=True  del_RADs=@{del_RADs}  set_RADs=@{set_RADs}
...    AND   Configure and wait  ${CURDIR}/config/CB012734-G-B2.yaml  name=G-B2-configure  bts_id=1
...    AND   Configure and wait  ${CURDIR}/config/CB012734-prachConfigurationIndex_38.yaml  bts_id=1
Suite Teardown  Suite teardown after execution

*** Variables ***
${wts_cfg}=         ${CURDIR}/config/wts_212_UEs.lua
${scfc}=            ${CURDIR}/config/scfc_FR2_8CC_TDD_NSA.xml
${iphy}=            ${CURDIR}/config/AP_AWEUB_8cells.xml
@{set_RADs}=        0x580953=0x0    0x580957=0x1    0x580959=0x0    0x590253=0x1    0x590254=0x1    0x590255=0x0
@{del_RADs}=        0x590253    0x580953    0x580958    0x580957    0x580959    0x580983    0x590254    0x590255
${tti_trace_path}=  ${OUTPUTDIR}/TTI_Trace/
${logcollector}=    False

*** Test Cases ***
CB012734-G_B2_Intermediate_configuration_with_5CC_and_2_beam_reports_with_maximum_connected_UEs
    [Documentation]
    ...  Description:
    ...    With only -G subfeature, the number of bits for UCI could be up to 78 bits (instead of 52 bits).
    ...    This scenario concerns the 5CC with 1 UCI per UE and 2 beam reports (no -H required).
    ...    In this scenario with maximum number of connected UEs, it is required to activate
    ...    all possible subflags of this feature to optimize the L2PS CPU load.
    ...
    ...  gNB configuration - SCF:
    ...    maxNumScellsDl = 4
    ...    maxNumScellsUl = 1    (NSA UE 5CC DL and 2CC UL)
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
    ...    0x580953=0x0    rdActAutoSCellDeactivationOnLoad    -> (default = FALSE)    -> Subfeature -B -C
    ...    0x580957=0x1    rdActSinglePfMetricPerUeOnLoad      -> (default = TRUE )    -> Subfeature -D
    ...    0x580959=0x0    rdActEnhBeamSelection               -> (default = TRUE )    -> Subfeature -E
    ...    0x590253=0x1    rdActDedicatedCsiSlots              -> (default = TRUE )    -> Subfeature -A
    ...    0x590254=0x1    rdActIncreasedUciBits               -> (default = TRUE )    -> Subfeature -G
    ...    0x590255=0x0    rdActSingleBeamReport               -> (default = TRUE )    -> Subfeature -H

    [Setup]  Start Collecting GNB and AP syslog

    Configure AP test modes supported high throughput scenarios on IWF setup    first_ue_id=107    last_ue_id=212
    Attach multi ues    first_ue_id=107    last_ue_id=212
    Sleep    15s    reason=Wait for env stabilization
    Start NSA traffic for multiple UEs    ues=107-212    traffic_rate=23Mbps    dir=DL
    Log to console    *** Started 23Mbps for each of 106 UEs
    Sleep    15s    reason=Wait for avg tput stabilization

    Start TTI trace
    Stop TTI trace    delay=2    target_dir=${tti_trace_path}
    Sleep    15s    reason=Wait for env stabilization

    Start TTI trace
    Stop TTI trace    delay=10    target_dir=${tti_trace_path}/TTI_Traces_10s
    Sleep    15s    reason=Wait for env stabilization

    Verify NSA DL throughput at gNB level
    ...    min_dl_traffic_mbps=2400
    ...    first_ue=107
    ...    last_ue=212
    ...    min_active_cc=529
    ...    max_active_cc=531

    Convert TTI trace pcap    input=${tti_trace_path}/l2stream3/tcpdump/tcpdump.pcap    output=${tti_trace_path}/output

    Verify in L2PS TTI Traces number of beams reported in CSI
    ...    expected_number_of_beams_reported_in_CSI=2
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that PUCCH is well decoded in all slots containing UCI or not
    ...    margin_percent=0.5
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces UCI payload size
    ...    expected_max_UCI_payload_bits=57
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that the average of carrier cuts and cell throughput are acceptable
    ...    skipped_ues_ratio_limit=0.095
    ...    csv_directory=${tti_trace_path}
    Verify in L2PS TTI Traces that overload control is improved during the scenario
    ...    min_scheduled_ues=${4.20}
    ...    max_scheduled_ues=${5.00}
    ...    min_skipped_ues=${0.15}
    ...    max_skipped_ues=${0.80}
    ...    min_slot_processing_time=${104500}
    ...    max_slot_processing_time=${109500}
    ...    csv_directory=${tti_trace_path}

    Sleep    300s    reason=Wait until more logs are collected

    [Teardown]  Run keywords
    ...         Collect Snapshot and Egate and Syslog logs
    ...  AND    Detach multi UEs    first_ue_id=107  last_ue_id=212
    ...  AND    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
