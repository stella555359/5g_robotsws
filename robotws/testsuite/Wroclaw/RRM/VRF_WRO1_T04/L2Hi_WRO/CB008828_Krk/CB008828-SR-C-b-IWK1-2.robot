*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Suite Setup    Run keywords    Prepare suite environment  egate_config=${lua_cfg_file}  scfc=${SCFC}  ap_xml=${AP_XML}
...            AND             Create aliases
...            AND             Create ues deployment  ues=1,2,3

*** Variables ***
${lua_cfg_file}=  ${CURDIR}${/}config${/}config_FDD_TDD_6Cells_SANSA_4CC_CA_2UEs_2000SNSSAI.cfg
${SCFC}=          ${CURDIR}${/}config${/}scfc_FDD_TDD_6Cells_FS_SANSA_4CC_CA_FTTF_1ABIO_8x4MIMO_2000SNSSAI.xml
${AP_XML}=        ${CURDIR}${/}config${/}iphy_AHLOA_AHCA_AHFIB_AEQE_AEQE_6Cells_LO_2000SNSSAI.xml

*** Test Cases ***
CB008828-SR-C-b-IWK1-2_Resource_Group_Aware_Scheduler_interaction_with_CA_-_3CC
    [Setup]    Set resource groups

    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Register multi UEs and establish pdu sessions
    Start SA traffic for multi UEs
    Verify SA traffic for ues
    Start TTI trace collection
    Sleep    5s
    Stop collecting logs
    Stop SA traffic for UEs
    Verify tti trace for cells 50, 52 and 55

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Set resource groups
    Configure   ${CURDIR}/config/CB008828-SR-C-b-IWK1-2.yaml

Register multi UEs and establish pdu sessions
    Register UE-1 and establish 1 pdu sessions on 1 slice on 1 cell
    Register UE-2 and establish 1 pdu sessions on 4 slice on 1 cell
    Register UE-3 and establish 1 pdu sessions on 3 slice on 1 cell

Verify SA traffic for ues
    sleep    3s
    Verify SA traffic  ue=1  dir=dl  expected_traffic=310Mbps  data_rate_type=Average   scells=0,1,2  tolerance=10
    Verify SA traffic  ue=1  dir=ul  expected_traffic=15Mbps  scells=0   tolerance=5
    Verify SA traffic  ue=2  dir=dl  expected_traffic=310Mbps  data_rate_type=Average   scells=0,1,2   tolerance=10
    Verify SA traffic  ue=2  dir=ul  expected_traffic=15Mbps  scells=0   tolerance=5
    Verify SA traffic  ue=3  dir=dl  expected_traffic=310Mbps  data_rate_type=Average   scells=0,1,2   tolerance=10
    Verify SA traffic  ue=3  dir=ul  expected_traffic=15Mbps  scells=0   tolerance=5

Start SA traffic for multi UEs
    Log to console    \n------Start traffic
    Start 300Mbps DL traffic for UE-1 for 1pdu
    Start 300Mbps DL traffic for UE-2 for 1pdu
    Start 300Mbps DL traffic for UE-3 for 1pdu
    Start 50Mbps UL traffic for UE-3 for 1pdu
    Start 50Mbps UL traffic for UE-2 for 1pdu
    Start 50Mbps UL traffic for UE-1 for 1pdu

Deregister multi ues
    Release PDU session  UE_ID=3   PDU_ID=1
    Deregister UE  UE_ID=3
    Release PDU session  UE_ID=2   PDU_ID=1
    Deregister UE  UE_ID=2
    Release PDU session  UE_ID=1   PDU_ID=1
    Deregister UE  UE_ID=1

Stop SA traffic for UEs
    Stop SA traffic  ue=1  pdu=1  dir=dl
    Stop SA traffic  ue=2  pdu=1  dir=dl
    Stop SA traffic  ue=3  pdu=1  dir=dl

Stop collecting logs
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData

Verify tti trace for cells 50, 52 and 55
    Log to console    \n------Verify tti trace
    Run Keyword And Continue On Failure    verify_dlslicedata_and_dldrbweight_in_tti_traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-b-IWK1-2-cell_50
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}
    Run Keyword And Continue On Failure    verify_dlslicedata_and_dldrbweight_in_tti_traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-b-IWK1-2-cell_52
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}
    Run Keyword And Continue On Failure    verify_dlslicedata_and_dldrbweight_in_tti_traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-b-IWK1-2-cell_55
    ...                                        cell_id=55
    ...                                        ues=${ues_rnti}
