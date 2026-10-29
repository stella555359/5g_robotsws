*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords     Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...              AND              Create aliases
...              AND              Create ues deployment  ues=51,52,53,54
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=               ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${cfg_file}=           ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-b-IWK3_Resource_Group_Aware_Scheduler_with_PRB_resource_pooling_for_FDD_only
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi UEs to different RG
    Stop syscomdump collection  target_dir=${OUTPUTDIR}/CB008828-SR-C-b-IWK3

    Start 45Mbps DL traffic for multiple UEs
    Verify SA traffic for multi UEs
    Verify that ues are in correct resource group  input_file=${OUTPUTDIR}/CB008828-SR-C-b-IWK3/syscomdump/syscomdump.pcap
    ...                                            expected_rg=C-b-IWK3
    ...                                            ues=${ues_rnti}

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-b-IWK3/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-SR-C-b-IWK3/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-b-IWK3
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to False
    Configure and wait    ${CURDIR}/config/CB008828-SR-C-b-IWK3.yaml

Register multi UEs to different RG
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  5
        Set pdu param for internal traffic  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=5${UE_ID}  CELL_ID=3
        Establish PDU session  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}  SLICE_ID=${UE_ID}  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=5${UE_ID}
    END

Start ${dl_tput}Mbps ${dir} traffic for multiple UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Start SA traffic  ue=5${UE_ID}  dir=${dir}  pdu=${UE_ID}  traffic_rate=${dl_tput}Mbps
    END

Verify SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Verify SA traffic  ue=5${UE_ID}  pdu=${UE_ID}  dir=dl  expected_traffic=45Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Deregister UE  UE_ID=5${UE_ID}
    END
