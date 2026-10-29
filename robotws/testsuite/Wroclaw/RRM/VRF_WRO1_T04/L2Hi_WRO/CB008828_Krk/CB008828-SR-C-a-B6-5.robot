*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource     ../resources/common_configuration.robot

Documentation
...    author: Jakub Grela
...    contact: jakub.grela@nokia.com
...    Description: Suite description in QC

Suite Setup          Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}
...                  AND              Create aliases
...                  AND              Create ues deployment  ues=101,102,154

Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_2_PLMN_NSA.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_2_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-B6-5_Mobillity_Profiles_exploratory
    [Documentation]
    ...  Description
    ...  This exploratory test checks interaction between CB008828-SR-C-a-B6 Not configured RG
    ...  and 5GC000710 Mobility Profiles in NSA mode.
    ...
    ...  PRECONDITION:
    ...      - gNB is up and handling traffic
    ...      - miNrCellUtillPerNrg is set to 5min
    ...      - miNrNRMOP is set to 5min
    ...      - actSliceAwareScheduler is set to True
    ...      - actSliceNumExt is set to True
    ...      - actRanSharing is set to True
    ...      - actSpidBasedSlicingNsa is set to True
    ...      - actSPID is set to True
    ...      - Default Mobility Profile is configured
    ...      - SPID groups are configured
    ...
    ...  POSTCONDITION:
    ...      PM counters M55157C00001 NRMOP_NSA_PROFILE_SELECTED_01 for a CELL should have value equal
    ...      to number of UEs attached to CELL
    ...      UEs are handled by default resource group when a configured resource group is removed.


    [Setup]    Prepare test environment


    Log to console    Attach UEs
    Attach multi UEs to different RG
    Log to console    SgNB addition
    SgNB addition for multi UEs
    Verify default Mobility Profile was used

    Start NSA traffic for multi UEs
    Sleep    10s
    Verify NSA traffic for multi UEs
    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    Run keyword and continue on failure    verify dlslicedata and dldrbweight in tti traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-5v1
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}
    Run keyword and continue on failure    verify dlslicedata and dldrbweight in tti traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-5v2
    ...                                        cell_id=52
    ...                                        ues=${ue_rnti}

    Delete resource group

    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    Run keyword and continue on failure    verify dlslicedata and dldrbweight in tti traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-5-del
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Verify default Mobility Profile was used
    Log to console  Collecting counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    ${counters_RG_1_1}=    Get counters values  counters=M55157C00001  localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...                                  filepath=${pm_counters}  rg_id=1

    Log to console  Verifing counters
    Run keyword and continue on failure  Verify last counters in file
    ...    M55157C00001    >1     NRMOP_NSA_PROFILE_SELECTED_01
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Prepare test environment
    Log to console  Preparing test
    Configure and wait    ${CURDIR}/config/CB008828-SR-C-a-B6-5.yaml

Delete resource group
    Log to console  Deleting resource group
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B6-1_delete_resource_group.yaml

Attach multi UEs to different RG
    Execute egate command  cmd=ue_enb_param id=101 spid=5
    Attach UE  UE_ID=101
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=102 spid=10
    Attach UE  UE_ID=102
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=154 spid=21
    Attach UE  UE_ID=154
    Sleep  10s

SgNB addition for multi UEs
    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    ${ue_rnti}    Create Dictionary
    Set Suite Variable  ${ue_rnti}
    Change eNB ENDC selected PLMN    PLMN=311:489
    SgNB Addition  UE_ID=101  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=101
    SgNB Addition  UE_ID=102  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=102
    Change eNB ENDC selected PLMN    PLMN=311:490
    SgNB Addition  UE_ID=154  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI-2 for UE  UE_ID=154

Start NSA traffic for multi UEs
    Start NSA traffic  ue=101  dir=dl  bearer=2  traffic_rate=140Mbps
    Start NSA traffic  ue=102  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=154  dir=dl  bearer=2  traffic_rate=80Mbps

Deregister multi UEs
    Detach UE    UE_ID=101
    Detach UE    UE_ID=102
    Detach UE    UE_ID=154

Verify NSA traffic for multi UEs
    Run keyword and continue on failure    Verify NSA traffic  ue=101  dir=dl  bearer=2  expected_traffic=140Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=102  dir=dl  bearer=2  expected_traffic=80Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=154  dir=dl  bearer=2  expected_traffic=80Mbps

