*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Kamil Krawiec
...    contact: kamil.krawiec@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords     Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...              AND              Create aliases
...              AND              Create ues deployment  ues=51,52,53,54,55,56,57,58
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=               ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${cfg_file}=           ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-B1_Resource_Group_Aware_Scheduler_considering_different_quotas_for_each_resource_group
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi UEs to different RG
    Stop syscomdump collection  target_dir=${OUTPUTDIR}/CB008828-SR-C-a-B1


    Start 20Mbps DL and 20Mbps UL traffic for multiple UEs
    Verify SA traffic for multi UEs

    Verify that ues are in correct resource group  input_file=${OUTPUTDIR}/CB008828-SR-C-a-B1/syscomdump/syscomdump.pcap
    ...                                            expected_rg=C-a-B1
    ...                                            ues=${ues_rnti}

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-a-B1/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=10

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-SR-C-a-B1/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-B1
    ...                                               cell_id=52
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
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B1.yaml

Register multi UEs to different RG
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  9
        Set pdu param for internal traffic  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=5${UE_ID}  CELL_ID=3
        Establish PDU session  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}  SLICE_ID=${UE_ID}  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=5${UE_ID}
    END

Start ${dl_tput}Mbps ${dl} and ${ul_tput}Mbps ${ul} traffic for multiple UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=5${UE_ID}  dir=${dl}  pdu=${UE_ID}  traffic_rate=${dl_tput}Mbps
    END

    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=5${UE_ID}  dir=${ul}  pdu=${UE_ID}  traffic_rate=${ul_tput}Mbps
    END

Verify SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Verify SA traffic  ue=5${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=20Mbps
    END
    FOR  ${UE_ID}  IN RANGE  1  9
        Verify SA traffic  ue=5${UE_ID}  dir=ul  pdu=${UE_ID}  expected_traffic=20Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Deregister UE  UE_ID=5${UE_ID}
    END
