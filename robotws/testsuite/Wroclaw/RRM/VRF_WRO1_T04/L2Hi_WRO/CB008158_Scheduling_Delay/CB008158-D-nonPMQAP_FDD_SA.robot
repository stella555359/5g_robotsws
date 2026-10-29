*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00
    ...    CLOUD_5G_I_MP_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Library       taf.ul.hanging_resources.listener    ${False}
Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup    Run Keywords    Prepare suite environment
...                     AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${counters}=      M55308C00057,M55308C00058,M55308C00060,M55308C00061

*** Test Cases ***
CB008158-SR-D_nonPMQAP_Average_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_in_L2Ps_FDD_FR1_SA
    [Setup]  Prepare test environment

    Start TTI trace collection
    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1  PDU_ID=1
    Verify in UeContextModificationResponse that DRX is configured for UE_1
    Start SA traffic  ue=1  dir=dl  traffic_rate=100Mbps
    Sleep  5s  reason=wait for tput stable
    Stop SA traffic  ue=1  dir=dl
    Deregister UE  UE_ID=1
    Stop and convert TTI trace collection    conversion_filter=dlFdSchedData|dlFlowControlData|utcTimestampData
    Verify counters
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1
    Compare dl schedule delay dnm from tti trace to pm counters
    ...    tti_trace_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...    counters=M55308C00058,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    Check schedule delay to dnm ratio
    ...    counters=M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    ...    technology=FDD_FR1

    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actLatencyPmCount to True
    Set parameter NRCELL-1/actCDrx to True
    Wait for next full pm interval

Verify counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    Run keyword and continue on failure  Verify last counters in file
    ...    M55308C00057    1750000-3800000    DL_INITSCHD_DLY_DRX_ACT
    ...    M55308C00058    1500-3200          DL_INIT_SCHD_DLY_DRX_ACT_DNM
    ...    M55308C00060    1000-150000        DL_INIT_SCHD_DLY_DRX_INACT
    ...    M55308C00061    1-5                DL_INIT_SCHD_DLY_DRX_INACT_DNM
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
