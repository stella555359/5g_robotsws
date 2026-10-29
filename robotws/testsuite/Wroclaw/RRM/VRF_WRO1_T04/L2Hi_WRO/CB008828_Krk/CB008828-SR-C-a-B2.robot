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
...              AND              Create ues deployment  ues=1,2,3,4,5,6,7,8
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=               ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${cfg_file}=           ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-B2_Resource_Group_Aware_Scheduler_considering_resource_group_online_modification
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi UEs to different RG
    Stop syscomdump collection  target_dir=${OUTPUTDIR}/CB008828-SR-C-a-B2

    Start 70Mbps DL traffic for multiple UEs
    Verify SA traffic for multi UEs

    Verify that ues are in correct resource group  input_file=${OUTPUTDIR}/CB008828-SR-C-a-B2/syscomdump/syscomdump.pcap
    ...                                            expected_rg=C-a-B2
    ...                                            ues=${ues_rnti}

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-a-B2/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-SR-C-a-B2/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-B2_1
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    Online modification Resource Groups
    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-a-B2/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-SR-C-a-B2/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-B2_2
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5min
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to False
    Configure and wait  ${CURDIR}/config/CB008828-SR-C-a-B2_1.yaml

Online modification Resource Groups
    Configure and wait  ${CURDIR}/config/CB008828-SR-C-a-B2_2.yaml

Register multi UEs to different RG
    Create ues dictionary

    Set pdu param for internal traffic  UE_ID=1  PDU_ID=1
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1  PDU_ID=1  SLICE_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=1

    Set pdu param for internal traffic  UE_ID=2  PDU_ID=2
    Register UE  UE_ID=2  CELL_ID=1
    Establish PDU session  UE_ID=2  PDU_ID=2  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=2

    Set pdu param for internal traffic  UE_ID=3  PDU_ID=3
    Register UE  UE_ID=3  CELL_ID=1
    Establish PDU session  UE_ID=3  PDU_ID=3  SLICE_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=3

    Set pdu param for internal traffic  UE_ID=4  PDU_ID=4
    Register UE  UE_ID=4  CELL_ID=1
    Establish PDU session  UE_ID=4  PDU_ID=4  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=4

    Set pdu param for internal traffic  UE_ID=5  PDU_ID=5
    Register UE  UE_ID=5  CELL_ID=1
    Establish PDU session  UE_ID=5  PDU_ID=5  SLICE_ID=5  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=5

    Set pdu param for internal traffic  UE_ID=6  PDU_ID=6
    Register UE  UE_ID=6  CELL_ID=1
    Establish PDU session  UE_ID=6  PDU_ID=6  SLICE_ID=6  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=6

    Set pdu param for internal traffic  UE_ID=7  PDU_ID=7
    Register UE  UE_ID=7  CELL_ID=1
    Establish PDU session  UE_ID=7  PDU_ID=7  SLICE_ID=7  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=7

    Set pdu param for internal traffic  UE_ID=8  PDU_ID=8
    Register UE  UE_ID=8  CELL_ID=1
    Establish PDU session  UE_ID=8  PDU_ID=8  SLICE_ID=8  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=8

Start ${dl_tput}Mbps ${dir} traffic for multiple UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=${UE_ID}  dir=${dir}  pdu=${UE_ID}  traffic_rate=${dl_tput}Mbps
    END

Verify SA traffic for multi UEs
    FOR    ${UE_ID}    IN RANGE    1    9
        Verify SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=70Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Deregister UE  UE_ID=${UE_ID}
    END
