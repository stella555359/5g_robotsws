*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup    Run Keywords    Prepare suite environment    egate_config=${cfg_file}
...                     AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${cfg_file}=  ${CURDIR}/config/config_LCG_TDD_FR2.cfg
${counters}=    M55308C00057,M55308C00058,M55308C00060,M55308C00061,M55356C00004,M55356C00005,M55356C00006,M55356C00007

*** Test Cases ***
CB008158-SR-D_Average_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_in_L2Ps_TDD_FR2_NSA
    [Setup]  Prepare test environment

    Start TTI trace collection
    Attach UE  UE_ID=15
    SgNB Addition  UE_ID=15  CELL_ID=3
    Verify in UeContextModificationResponse that DRX is configured for UE_15
    Start NSA traffic  ue=15  dir=dl  traffic_rate=100Mbps
    Sleep  5s  reason=wait for tput stable
    Stop NSA traffic  ue=15  dir=dl
    Detach UE  UE_ID=15
    Stop and convert TTI trace collection    conversion_filter=dlFdSchedData|dlFlowControlData|utcTimestampData
    Verify counters
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-3
    Compare dl schedule delay dnm from tti trace to pm counters
    ...    tti_trace_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...    counters=M55308C00058,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}

    Compare dl schedule delay dnm from tti trace to pm counters
    ...    tti_trace_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...    counters=M55356C00006,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}

    Check schedule delay to dnm ratio
    ...    counters=M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    ...    technology=TDD_FR2

    Check schedule delay to dnm ratio
    ...    counters=M55356C00004,M55356C00006,M55356C00005,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    ...    technology=TDD_FR2
    ...    pmqap=True

    [Teardown]    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Configure NSA PMQAP Profiles
    Set feature flag NRBTS-1/actLatencyPmCount to True
    Set parameter NRCELL-3/actCDrx to True
    Wait for next full pm interval

Verify counters
    ${pm_counters}=  Get Latest Unpacked Full Pm Counters File
    Set Test Variable  ${pm_counters}
    Run keyword and continue on failure  Verify last counters in file
    ...    M55356C00004    380000-1200000   DL_INIT_SCHD_DLY_DRX_ACT_PMQAP
    ...    M55356C00006    2000-6000        DL_INIT_SCHD_DLY_DRXACT_PMQP_D
    ...    M55356C00005    3800-150000      DL_INT_SCHD_DLY_DRX_INAC_PMQAP
    ...    M55356C00007    1-20             DL_INT_SCHD_DLY_DRX_INA_PMQP_D
    ...    M55308C00057    380000-1200000   DL_INIT_SCHD_DLY_DRX_ACT
    ...    M55308C00058    2000-6000        DL_INIT_SCHD_DLY_DRX_ACT_DNM
    ...    M55308C00060    3800-150000      DL_INIT_SCHD_DLY_DRX_INACT
    ...    M55308C00061    1-20             DL_INIT_SCHD_DLY_DRX_INACT_DNM
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

    Check counters equality
    ...    counters=M55356C00004,M55356C00006,M55356C00005,M55356C00007,M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
