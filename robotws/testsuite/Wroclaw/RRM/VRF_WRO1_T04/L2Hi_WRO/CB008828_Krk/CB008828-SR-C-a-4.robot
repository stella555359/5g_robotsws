*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=51,52,53,54,55,56,57,58
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_20_SNSSAI.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1_20SNSSAI.cfg

*** Test Cases ***
CB008828-SR-C-a-4_measure_PRB_related_counters_per_Resource_Group_level_when_a_resource_group_is_created_using_slice_and_CB008828_is_disabled
    [Setup]    Run keywords    Prepare test environment
    ...        AND             Wait for next full pm interval

    Start syscomdump collection
    Register multi UEs to different RGs
    Establish pdu session for UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-a-4

    Start SA traffic for UE
    Verify SA traffic for multi UEs

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-a-4/TTiTraces
    ...                                    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=10

    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-a-4/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-a-4
    ...                                              ues=${ues_rnti}

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-a-4/TTiTraces/output_dl.csv
    ...                                               expected_tti=C-a-4
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}
    Verify counters    test_name=C-a-4  nrcell_id=3

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRBTS-1/actSliceNumExt to False
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Configure SNSSAI per RG

Configure SNSSAI per RG
    Configure    ${CURDIR}/config/CB008828-SR-C-a-4.yaml

Register multi UEs to different RGs
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  7
        Set pdu param for internal traffic  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=5${UE_ID}  CELL_ID=3
    END

Establish pdu session for UEs
    Establish PDU session  UE_ID=51  PDU_ID=1  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=51
    Establish PDU session  UE_ID=52  PDU_ID=2  SLICE_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=52
    Establish PDU session  UE_ID=53  PDU_ID=3  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=53
    Establish PDU session  UE_ID=54  PDU_ID=4  SLICE_ID=5  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=54
    Establish PDU session  UE_ID=55  PDU_ID=5  SLICE_ID=6  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=55
    Establish PDU session  UE_ID=56  PDU_ID=6  SLICE_ID=7  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=56

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Deregister UE    UE_ID=5${UE_ID}
    END

Start SA traffic for UE
    Start SA traffic  ue=51  dir=dl  pdu=1  traffic_rate=40Mbps
    Start SA traffic  ue=52  dir=dl  pdu=2  traffic_rate=40Mbps
    Start SA traffic  ue=53  dir=dl  pdu=3  traffic_rate=20Mbps
    Start SA traffic  ue=54  dir=dl  pdu=4  traffic_rate=20Mbps
    Start SA traffic  ue=55  dir=dl  pdu=5  traffic_rate=40Mbps
    Start SA traffic  ue=56  dir=dl  pdu=6  traffic_rate=40Mbps

Verify SA traffic for multi UEs
    Run keyword and continue on failure    Verify SA traffic  ue=51  dir=dl  pdu=1  expected_traffic=35-40Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=52  dir=dl  pdu=2  expected_traffic=35-40Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=53  dir=dl  pdu=3  expected_traffic=15-20Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=54  dir=dl  pdu=4  expected_traffic=15-20Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=55  dir=dl  pdu=5  expected_traffic=35-40Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=56  dir=dl  pdu=6  expected_traffic=35-40Mbps
