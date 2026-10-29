*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords     Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...              AND              Create aliases
...              AND              Create ues deployment  ues=1
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=               ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${cfg_file}=           ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-B1_3_Resource_Group_Aware_Scheduler_considering_different_quotas_for_each_resource_group_single_UE_multiple_PDU
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register UE-1 and establish 5 pdu sessions
    Stop syscomdump collection  target_dir=${OUTPUTDIR}/CB008828-SR-C-a-B1-3

    Start DL and UL traffic for UE-1 for 5 pdu
    Verify SA traffic for multi UEs

    Verify that ues are in correct resource group  input_file=${OUTPUTDIR}/CB008828-SR-C-a-B1-3/syscomdump/syscomdump.pcap
    ...                                            expected_rg=C-a-B1-3
    ...                                            ues=${ues_rnti}

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-a-B1-3/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-SR-C-a-B1-3/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-B1-3
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    [Teardown]  Run Keywords
    ...    Deregister UE    UE_ID=1
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5min
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to False
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B1-3.yaml

Register UE-${UE_ID} and establish 5 pdu sessions
    Create ues dictionary
    FOR    ${PDU_ID}    IN RANGE    1    6
        Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=${PDU_ID}
    END
    Register UE  UE_ID=${UE_ID}  CELL_ID=1
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=1  SLICE_ID=${UE_ID}  RRC_CHECK=True
    FOR    ${PDU_ID}    IN RANGE    2    6
        Establish PDU session  UE_ID=${UE_ID}  PDU_ID=${PDU_ID}  SLICE_ID=${PDU_ID}
    END
    Get C-RNTI for UE  UE_ID=${UE_ID}

Start ${DL} and ${UL} traffic for UE-${UE_ID} for 5 pdu
    Start SA traffic  ue=${UE_ID}  dir=${DL}  pdu=1  traffic_rate=130Mbps
    Start SA traffic  ue=${UE_ID}  dir=${DL}  pdu=2  traffic_rate=175Mbps
    Start SA traffic  ue=${UE_ID}  dir=${DL}  pdu=3  traffic_rate=130Mbps
    Start SA traffic  ue=${UE_ID}  dir=${DL}  pdu=4  traffic_rate=130Mbps
    Start SA traffic  ue=${UE_ID}  dir=${DL}  pdu=5  traffic_rate=130Mbps
    FOR  ${UE_ID}  IN RANGE  1  5
        Start SA traffic  ue=1  dir=${UL}  pdu=${UE_ID}  traffic_rate=20Mbps
    END

Verify SA traffic for multi UEs
    verify SA traffic  ue=1  dir=dl  pdu=1  expected_traffic=130Mbps
    verify SA traffic  ue=1  dir=dl  pdu=2  expected_traffic=175Mbps
    verify SA traffic  ue=1  dir=dl  pdu=3  expected_traffic=130Mbps
    verify SA traffic  ue=1  dir=dl  pdu=4  expected_traffic=130Mbps
    verify SA traffic  ue=1  dir=dl  pdu=5  expected_traffic=130Mbps
    FOR  ${UE_ID}  IN RANGE  1  5
        Verify SA traffic  ue=1  dir=ul  pdu=${UE_ID}  expected_traffic=20Mbps
    END