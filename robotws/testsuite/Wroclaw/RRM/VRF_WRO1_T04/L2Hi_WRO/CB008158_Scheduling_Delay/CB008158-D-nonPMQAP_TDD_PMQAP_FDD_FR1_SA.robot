*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup    Run Keywords    Prepare suite environment
...                     AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${nonpmqap_counters}=    M55308C00057,M55308C00058,M55308C00060,M55308C00061
${pmqap_counters}=       M55356C00004,M55356C00005,M55356C00006,M55356C00007

*** Test Cases ***
CB008158-SR-D_nonPMQAP_Average_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_in_L2Ps_TDD_FR1_SA
    [Setup]  Prepare test environment TDD nonPMQAP

    Start TTI trace collection
    Set pdu param for internal traffic  UE_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1  PDU_ID=1
    Verify in UeContextModificationResponse that DRX is configured for UE_1
    Start SA traffic  ue=1  dir=dl  traffic_rate=100Mbps
    Sleep  5s  reason=wait for tput stable
    Stop SA traffic  ue=1  dir=dl
    Stop and convert TTI trace collection    conversion_filter=dlFdSchedData|dlFlowControlData|utcTimestampData
    Verify nonPMQAP counters
    Get counters value and report to rp  counters=${nonpmqap_counters}  filepath=${pm_counters}  localmoid=NRCELL-1
    Compare dl schedule delay dnm from tti trace to pm counters
    ...    tti_trace_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...    counters=M55308C00058,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    Check schedule delay to dnm ratio
    ...    counters=M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    ...    technology=TDD_FR1

    [Teardown]    Run keywords
    ...           Deregister UE  UE_ID=1
    ...    AND    Send Configuration ID To Scout

CB008158-SR-D_PMQAP_Average_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_in_L2Ps_FDD_FR1_SA
    [Setup]  Prepare test environment FDD PMQAP

    Start TTI trace collection
    Set pdu param for internal traffic  UE_ID=51  PDU_ID=1
    Register UE  UE_ID=51  CELL_ID=3
    Establish PDU session  UE_ID=51  PDU_ID=1
    Verify in UeContextModificationResponse that DRX is configured for UE_51
    Start SA traffic  ue=51  pdu=1  dir=dl  traffic_rate=100Mbps
    Sleep  5s  reason=wait for tput stable
    Stop SA traffic  ue=51  dir=dl  pdu=1
    Stop and convert TTI trace collection    conversion_filter=dlFdSchedData|dlFlowControlData|utcTimestampData
    Verify PMQAP counters
    Get counters value and report to rp  counters=${pmqap_counters}  filepath=${pm_counters}  localmoid=NRCELL-3
    Compare dl schedule delay dnm from tti trace to pm counters
    ...    tti_trace_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...    counters=M55356C00006,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    Check schedule delay to dnm ratio
    ...    counters=M55356C00004,M55356C00006,M55356C00005,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    ...    technology=FDD_FR1
    ...    pmqap=True

    [Teardown]  Run keywords
    ...           Deregister UE  UE_ID=51
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment TDD nonPMQAP
    Set feature flag NRBTS-1/actLatencyPmCount to True
    Set parameter NRCELL-1/actCDrx to True
    Wait for next full pm interval

Prepare test environment FDD PMQAP
    Configure SA PMQAP Profiles
    Set feature flag NRBTS-1/actLatencyPmCount to True
    Set parameter NRCELL-3/actCDrx to True
    Wait for next full pm interval

Verify nonPMQAP counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    Run keyword and continue on failure  Verify last counters in file
    ...    M55308C00057    1100000-2800000    DL_INIT_SCHD_DLY_DRX_ACT
    ...    M55308C00058    1800-4200          DL_INIT_SCHD_DLY_DRX_ACT_DNM
    ...    M55308C00060    500-145000         DL_INIT_SCHD_DLY_DRX_INACT
    ...    M55308C00061    1-5                DL_INIT_SCHD_DLY_DRX_INACT_DNM
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Verify PMQAP counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    Run keyword and continue on failure  Verify last counters in file
    ...    M55356C00004    1500000-3200000    DL_INIT_SCHD_DLY_DRX_ACT_PMQAP
    ...    M55356C00006    1500-3000          DL_INIT_SCHD_DLY_DRXACT_PMQP_D
    ...    M55356C00005    1000-145000        DL_INT_SCHD_DLY_DRX_INAC_PMQAP
    ...    M55356C00007    1-5                DL_INT_SCHD_DLY_DRX_INA_PMQP_D
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}
