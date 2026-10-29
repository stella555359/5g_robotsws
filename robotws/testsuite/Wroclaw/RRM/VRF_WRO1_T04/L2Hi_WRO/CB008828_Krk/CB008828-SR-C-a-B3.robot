*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Suite Setup          Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}
...                  AND              Create aliases
...                  AND              Create ues deployment  ues=51,52,53,54

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-B3_Existing_resource_group_is_removed
    [Setup]    Prepare test environment

    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Start syscomdump collection
    Register UE-51 and establish 1 pdu sessions on 1 slice on 3 cell
    Get C-RNTI for UE    UE_ID=51
    Register UE-52 and establish 1 pdu sessions on 21 slice on 3 cell
    Get C-RNTI for UE    UE_ID=52
    Register UE-53 and establish 1 pdu sessions on 41 slice on 3 cell
    Get C-RNTI for UE    UE_ID=53
    Register UE-54 and establish 1 pdu sessions on 41 slice on 3 cell
    Get C-RNTI for UE    UE_ID=54
    Stop syscomdump collection
    Log to console    \n------Traffic
    Start 50Mbps DL traffic for UE-51 for 1pdu
    Start 50Mbps DL traffic for UE-52 for 1pdu
    Start 50Mbps DL traffic for UE-53 for 1pdu
    Start 50Mbps DL traffic for UE-54 for 1pdu

    Start TTI trace collection

    Sleep    5s    reason=wait for traffic stabilization
    Stop collecting logs
    Log to console    \n------Verify
    Run Keyword And Continue On Failure    verify_dlslicedata_and_dldrbweight_in_tti_traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-a-B3
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}

    Remove resource group

    Start TTI trace collection

    Sleep    5s    reason=wait for traffic stabilization
    Stop collecting logs
    Run Keyword And Continue On Failure    Stop SA traffic for UEs
    Log to console    \n------Verify
    Run Keyword And Continue On Failure    verify_dlslicedata_and_dldrbweight_in_tti_traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-a-B3_mod
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Configure   ${CURDIR}/config/CB008828-SR-C-a-B3.yaml

Verify traffic for UE-${UE_ID}
    Verify SA traffic  ue=${UE_ID}  dir=dl  expected_traffic=100Mbps

Remove resource group
    Log to console    \n------Removing Resource Group
    Configure   ${CURDIR}/config/CB008828-SR-C-a-B3_del_RG.yaml

Deregister multi ues
    Release PDU session  UE_ID=54   PDU_ID=1
    Deregister UE  UE_ID=54
    Release PDU session  UE_ID=53   PDU_ID=1
    Deregister UE  UE_ID=53
    Release PDU session  UE_ID=52   PDU_ID=1
    Deregister UE  UE_ID=52
    Release PDU session  UE_ID=51   PDU_ID=1
    Deregister UE  UE_ID=51

Stop collecting logs
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData

Stop SA traffic for UEs
    Stop SA traffic  ue=51  pdu=1   dir=dl
    Stop SA traffic  ue=52  pdu=1   dir=dl
    Stop SA traffic  ue=53  pdu=1   dir=dl
    Stop SA traffic  ue=54  pdu=1   dir=dl

Register UE-${UE_ID} and establish multiple pdu sessions
    Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=1
    Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=2
    Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=3
    Register UE  UE_ID=${UE_ID}  CELL_ID=1
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=1  SLICE_ID=2
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=2  SLICE_ID=100
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=3  SLICE_ID=499

Start ${dl_tput}Mbps DL traffic for UE-${UE_ID} for each pdu
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=1  traffic_rate=${dl_tput}Mbps
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=2  traffic_rate=${dl_tput}Mbps
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=3  traffic_rate=${dl_tput}Mbps

Start ${traffic_rate}Mbps ${dir} traffic UE-${UE_ID} pdu-${PDU_ID}
    Start SA traffic  ue=${UE_ID}  dir=${dir}  pdu=${PDU_ID}  traffic_rate=${traffic_rate}Mbps
