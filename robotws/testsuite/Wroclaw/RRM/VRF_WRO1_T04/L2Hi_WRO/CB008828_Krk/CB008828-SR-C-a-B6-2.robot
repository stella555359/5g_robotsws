*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2    AP_REG
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Jakub Grela
...    contact: jakub.grela@nokia.com
...    Description: Suite description in QC

Suite Setup  Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}  rad_params=${rd_flag}
...                   AND     Create aliases
...                   AND     Create ues deployment  ues=151,152,153,154,155

Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_2_PLMN_NSA.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_2_PLMN.cfg
${rd_flag}=    0x590222=1

*** Test Cases ***
CB008828-SR-C-a-B6-2_Not_configured_RG_or_RG_removal_for_NSA_-_Different_SPID_values
    [Setup]    Prepare test environment


    Attach multi UEs to different RG
    SgNB addition for multi UEs

    Start NSA traffic for multi UEs
    Sleep    10s  reason=wait for traffic stabilization
    Verify NSA traffic for multi UEs
    Start TTI trace collection
    Sleep    10s  reason=wait to collect logs from specific period
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData
    verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-2
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}
    ...                                        deployment=NSA

    Delete resource group
    Start TTI trace collection
    Sleep    10s  reason=wait to collect logs from specific period
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData
    verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-2-del
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}
    ...                                        deployment=NSA

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Log to console  Preparing test
    Configure and wait    ${CURDIR}/config/CB008828-SR-C-a-B6-2.yaml

Delete resource group
    Log to console  Deleting resource group
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B6-1_delete_resource_group.yaml

Attach multi UEs to different RG
    Execute egate command  cmd=ue_enb_param id=151 spid=5
    Attach UE  UE_ID=151
    Sleep  10s  reason=wait for successful attach
    Execute egate command  cmd=ue_enb_param id=152 spid=6
    Attach UE  UE_ID=152
    Sleep  10s  reason=wait for successful attach
    Execute egate command  cmd=ue_enb_param id=153 spid=8
    Attach UE  UE_ID=153
    Sleep  10s  reason=wait for successful attach
    Execute egate command  cmd=ue_enb_param id=154 spid=11
    Attach UE  UE_ID=154
    Sleep  10s  reason=wait for successful attach
    Execute egate command  cmd=ue_enb_param id=155
    Attach UE  UE_ID=155
    Sleep  10s  reason=wait for successful attach


SgNB addition for multi UEs
    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Change eNB ENDC selected PLMN    PLMN=311:489
    SgNB Addition  UE_ID=151  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=151
    SgNB Addition  UE_ID=152  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=152
    SgNB Addition  UE_ID=153  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=153
    Change eNB ENDC selected PLMN    PLMN=311:490
    SgNB Addition  UE_ID=154  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=154
    SgNB Addition  UE_ID=155  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=155

Start NSA traffic for multi UEs
    Start NSA traffic  ue=151  dir=dl  bearer=2  traffic_rate=40Mbps
    Start NSA traffic  ue=152  dir=dl  bearer=2  traffic_rate=40Mbps
    Start NSA traffic  ue=153  dir=dl  bearer=2  traffic_rate=40Mbps
    Start NSA traffic  ue=154  dir=dl  bearer=2  traffic_rate=30Mbps
    Start NSA traffic  ue=155  dir=dl  bearer=2  traffic_rate=30Mbps

Deregister multi UEs
    Detach UE    UE_ID=151
    Detach UE    UE_ID=152
    Detach UE    UE_ID=153
    Detach UE    UE_ID=154
    Detach UE    UE_ID=155

Verify NSA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  151  154
        Run keyword and continue on failure    Verify NSA traffic  ue=${UE_ID}  dir=dl  bearer=2
        ...                                  expected_traffic=40Mbps
    END
    FOR  ${UE_ID}  IN RANGE  154  156
        Run keyword and continue on failure    Verify NSA traffic  ue=${UE_ID}  dir=dl  bearer=2
        ...                                  expected_traffic=30Mbps
    END
