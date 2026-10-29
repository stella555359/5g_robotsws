*** Settings ***
Force Tags    RAN_5G    RAN_5G_FDD    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Resource   resources/CB008158_resources.robot
Resource     ../resources/common_configuration.robot

Suite Setup    Run Keywords    Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...                     AND    Create aliases
Suite Teardown   Clean suite environment

*** Variables ***
${cfg_file}=  ${CURDIR}/config/scfc_LCG_FDD_TDD_FR1_non_BF.xml
${scfc}=      ${CURDIR}/config/TTD_FDD_AEQE_AHLOA.cfg

*** Test Cases ***
[1]CB008158-D-B202-Exploratory_TDD+FDD_SA
    [Setup]  Prepare test environment
    Register and setup pdu session for UE1 on cell-1 on slice-1
    Verify in UeContextModificationResponse that DRX is configured for UE_1

    Register and setup pdu session for UE2 on cell-1 on slice-3
    Verify in UeContextModificationResponse that DRX is configured for UE_2

    Register and setup pdu session for UE51 on cell-3 on slice-2
    Verify in UeContextModificationResponse that DRX is configured for UE_51

    Register and setup pdu session for UE52 on cell-3 on slice-4
    Verify in UeContextModificationResponse that DRX is configured for UE_52

    Start 35Mbps SA traffic for UE1 UE2 UE51 and UE52

    Sleep  5s  reason=wait for tput stable

    Verify SA traffic for UE1 UE2 UE51 and UE52

    Stop SA traffic for UE1 UE2 UE51 and UE52

    Deregister UE1 UE2 UE51 and UE52

    Verify counters

    Log to console  CELL-1 Verification SA

    Run Keyword And Continue On Failure      Check schedule delay to dnm ratio
    ...    counters=M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    ...    technology=TDD_FR1

    Run Keyword And Continue On Failure    Check schedule delay to dnm ratio
    ...    counters=M55356C00004,M55356C00006,M55356C00005,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    counters_path=${pm_counters}
    ...    technology=TDD_FR1
    ...    pmqap=True
    ...    id=2

    Log to console  CELL-3 Verification SA

    Run Keyword And Continue On Failure      Check schedule delay to dnm ratio
    ...    counters=M55308C00057,M55308C00058,M55308C00060,M55308C00061
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    ...    technology=FDD_FR1

    Run Keyword And Continue On Failure    Check schedule delay to dnm ratio
    ...    counters=M55356C00004,M55356C00006,M55356C00005,M55356C00007
    ...    localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    counters_path=${pm_counters}
    ...    technology=FDD_FR1
    ...    pmqap=True
    ...    id=2

    [Teardown]    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Configure SA PMQAP Profiles
    Set feature flag NRBTS-1/actLatencyPmCount to True
    Set parameter NRCELL-1/actCDrx to True
    Set parameter NRCELL-3/actCDrx to True
    Wait for next full pm interval

Verify counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    Run keyword and continue on failure  Verify last counters in file
    ...    M55308C00057    480000-1000000      DL_INITSCHD_DLY_DRX_ACT
    ...    M55308C00058    2900-7000           DL_INIT_SCHD_DLY_DRX_ACT_DNM
    ...    M55308C00060    2500-100000         DL_INIT_SCHD_DLY_DRX_INACT
    ...    M55308C00061    1-5                 DL_INIT_SCHD_DLY_DRX_INACT_DNM
    ...    M55356C00004    100000-800000       DL_INIT_SCHD_DLY_DRX_ACT_PMQAP
    ...    M55356C00006    2000-7000           DL_INIT_SCHD_DLY_DRXACT_PMQP_D
    ...    M55356C00005    500-90000           DL_INT_SCHD_DLY_DRX_INAC_PMQAP
    ...    M55356C00007    1-5                 DL_INT_SCHD_DLY_DRX_INA_PMQP_D
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Register and setup pdu session for UE${UE_ID} on cell-${CELL_ID} on slice-${SLICE_ID}
    Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=${UE_ID}
    Register UE  UE_ID=${UE_ID}  CELL_ID=${CELL_ID}
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=${UE_ID}  SLICE_ID=${SLICE_ID}

Start 35Mbps SA traffic for UE1 UE2 UE51 and UE52
    Start SA traffic  ue=1  pdu=1  dir=dl  traffic_rate=35Mbps
    Start SA traffic  ue=2  pdu=2  dir=dl  traffic_rate=35Mbps
    Start SA traffic  ue=51  pdu=3  dir=dl  traffic_rate=35Mbps
    Start SA traffic  ue=52  pdu=4  dir=dl  traffic_rate=35Mbps

Verify SA traffic for UE1 UE2 UE51 and UE52
    Verify SA traffic  ue=1  pdu=1  dir=dl  expected_traffic=35Mbps
    Verify SA traffic  ue=2  pdu=2  dir=dl  expected_traffic=35Mbps
    Verify SA traffic  ue=51  pdu=3  dir=dl  expected_traffic=35Mbps
    Verify SA traffic  ue=52  pdu=4  dir=dl  expected_traffic=35Mbps

Stop SA traffic for UE1 UE2 UE51 and UE52
    Stop SA traffic  ue=1  dir=dl  pdu=1
    Stop SA traffic  ue=2  dir=dl  pdu=2
    Stop SA traffic  ue=51  dir=dl  pdu=3
    Stop SA traffic  ue=52  dir=dl  pdu=4

Deregister UE1 UE2 UE51 and UE52
    Deregister UE  UE_ID=1
    Deregister UE  UE_ID=2
    Deregister UE  UE_ID=51
    Deregister UE  UE_ID=52
