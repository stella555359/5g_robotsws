*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Jakub Grela
...    contact: jakub.grela@nokia.com
...    Description: Suite description in QC

Suite Setup  Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}  rad_params=${rd_flag}
...                   AND     Create aliases
...                   AND     Create ues deployment  ues=101,102,103,104,105,106

Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_2_PLMN_NSA.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_2_PLMN.cfg
${rd_flag}=    0x590222=1

*** Test Cases ***
CB008828-SR-C-a-B6-1_Not_configured_RG_or_RG_removal_for_NSA
    [Setup]    Prepare test environment

    Start syscomdump collection
    Attach multi UEs to different RG
    SgNB addition for multi UEs
    Stop syscomdump collection

    Start NSA traffic for multi UEs
    Sleep    10s
    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-1
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}

    Delete resource group
    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=B6-1-del
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}


    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Log to console  Preparing test
    Configure and wait   ${CURDIR}/config/CB008828-SR-C-a-B6-1.yaml

Delete resource group
    Log to console  Deleting resource group
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B6-1_delete_resource_group.yaml

Attach multi UEs to different RG
    Execute egate command  cmd=ue_enb_param id=101 spid=1
    Attach UE  UE_ID=101
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=102 spid=1
    Attach UE  UE_ID=102
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=103 spid=3
    Attach UE  UE_ID=103
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=104 spid=2
    Attach UE  UE_ID=104
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=105 spid=4
    Attach UE  UE_ID=105
    Sleep  10s
    Execute egate command  cmd=ue_enb_param id=106
    Attach UE  UE_ID=106
    Sleep  10s

SgNB addition for multi UEs
    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Change eNB ENDC selected PLMN    PLMN=311:489
    SgNB Addition  UE_ID=101  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=101
    SgNB Addition  UE_ID=102  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=102
    SgNB Addition  UE_ID=103  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=103
    SgNB Addition  UE_ID=104  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=104
    Change eNB ENDC selected PLMN    PLMN=311:490
    SgNB Addition  UE_ID=105  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=105
    SgNB Addition  UE_ID=106  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=106

Start NSA traffic for multi UEs
    Start NSA traffic  ue=101  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=102  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=103  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=104  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=105  dir=dl  bearer=2  traffic_rate=80Mbps
    Start NSA traffic  ue=106  dir=dl  bearer=2  traffic_rate=80Mbps

Deregister multi UEs
    Detach UE    UE_ID=101
    Detach UE    UE_ID=102
    Detach UE    UE_ID=103
    Detach UE    UE_ID=104
    Detach UE    UE_ID=105
    Detach UE    UE_ID=106

Verify NSA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Run keyword and continue on failure    Verify NSA traffic  ue=10${UE_ID}  dir=dl  bearer=2
        ...                                  expected_traffic=80Mbps
    END
