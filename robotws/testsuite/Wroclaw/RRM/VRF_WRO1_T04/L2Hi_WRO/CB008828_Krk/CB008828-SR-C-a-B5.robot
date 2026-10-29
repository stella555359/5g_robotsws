*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Suite Setup          Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}
...                  AND              Create aliases
...                  AND              Create ues deployment  ues=1,2,3,4,5,6,7

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_MP_AP_LO.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_MP_AP_LO.cfg

*** Test Cases ***
CB008828-SR-C-a-B5-1_Default_resource_group_online_modification
    [Setup]    Prepare test environment

    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}
    Start syscomdump collection
    Register multi UEs and establish pdu sessions
    Stop syscomdump collection
    Start SA traffic for multi UEs

    Start TTI trace collection

    Sleep    5s    reason=wait for traffic stabilization
    Stop collecting logs
    Run Keyword And Continue On Failure    Stop SA traffic for UEs
    Log to console    \n------Verify tti trace
    Run Keyword And Continue On Failure   verify_dlslicedata_and_dldrbweight_in_tti_traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-a-B5
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}

    Online modification default Resource Group
    Start SA traffic for multi UEs

    Start TTI trace collection

    Sleep    5s    reason=wait for traffic stabilization
    Stop collecting logs
    Run Keyword And Continue On Failure    Stop SA traffic for UEs
    Log to console    \n------Verify tti trace
    verify_dlslicedata_and_dldrbweight_in_tti_traces  csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=C-a-B5_mod
    ...                                        cell_id=50
    ...                                        ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Configure   ${CURDIR}/config/CB008828-SR-C-a-B5.yaml

Register multi UEs and establish pdu sessions
    Register UE-1 and establish 1 pdu sessions on 1 slice on 1 cell
    Register UE-2 and establish 1 pdu sessions on 2 slice on 1 cell
    Register UE-3 and establish 1 pdu sessions on 3 slice on 1 cell
    Register UE-4 and establish 1 pdu sessions on 4 slice on 1 cell
    Register UE-5 and establish 1 pdu sessions on 5 slice on 1 cell
    Register UE-6 and establish 1 pdu sessions on 1 slice on 1 cell
    Register UE-7 and establish 1 pdu sessions on 5 slice on 1 cell

Start SA traffic for multi UEs
    Log to console    \n------Start traffic
    Start 300Mbps DL traffic for UE-1 for 1pdu
    Start 100Mbps DL traffic for UE-2 for 1pdu
    Start 200Mbps DL traffic for UE-3 for 1pdu
    Start 200Mbps DL traffic for UE-4 for 1pdu
    Start 500Mbps DL traffic for UE-5 for 1pdu
    Start 200Mbps DL traffic for UE-6 for 1pdu
    Start 200Mbps DL traffic for UE-7 for 1pdu

Online modification default Resource Group
    Log to console    \n------Online modification default Resource Group
    Configure   ${CURDIR}/config/CB008828-SR-C-a-B5-online-mod.yaml

Deregister multi ues
    Release PDU session  UE_ID=7   PDU_ID=1
    Deregister UE  UE_ID=7
    Release PDU session  UE_ID=6   PDU_ID=1
    Deregister UE  UE_ID=6
    Release PDU session  UE_ID=5   PDU_ID=1
    Deregister UE  UE_ID=5
    Release PDU session  UE_ID=4   PDU_ID=1
    Deregister UE  UE_ID=4
    Release PDU session  UE_ID=3   PDU_ID=1
    Deregister UE  UE_ID=3
    Release PDU session  UE_ID=2   PDU_ID=1
    Deregister UE  UE_ID=2
    Release PDU session  UE_ID=1   PDU_ID=1
    Deregister UE  UE_ID=1

Stop SA traffic for UEs
    Stop SA traffic  ue=7  pdu=1    dir=dl
    Stop SA traffic  ue=6  pdu=1    dir=dl
    Stop SA traffic  ue=5  pdu=1    dir=dl
    Stop SA traffic  ue=4  pdu=1    dir=dl
    Stop SA traffic  ue=3  pdu=1    dir=dl
    Stop SA traffic  ue=2  pdu=1    dir=dl
    Stop SA traffic  ue=1  pdu=1    dir=dl

Stop collecting logs
    Stop and convert TTI trace collection    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
