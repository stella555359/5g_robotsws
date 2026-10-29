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
...              AND              Create ues deployment  ues=51,52,53,151,152,153
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_SNSSAI_6_PLMN.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1.cfg

*** Test Cases ***
CB008828-SR-C-a-B1_Resource_Group_Aware_Scheduler_considering_different_quotas_for_each_resource_group
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi SA and NSA UEs to different RG
    Stop syscomdump collection  target_dir=${OUTPUTDIR}/CB008828-SR-C-a-Exploratory

    Start 25Mbps DL traffic for multiple UEs
    Verify SA and NSA traffic for multi UEs

    Verify that ues are in correct resource group
    ...                                  input_file=${OUTPUTDIR}/CB008828-SR-C-a-Exploratory/syscomdump/syscomdump.pcap
    ...                                  expected_rg=C-a-Exploratory
    ...                                  ues=${ues_rnti}

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-SR-C-a-Exploratory/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=10

    Verify dlslicedata and dldrbweight in tti traces
    ...                                  csv_path=${OUTPUTDIR}/CB008828-SR-C-a-Exploratory/TtiTraces/output_dl.csv
    ...                                  expected_tti=C-a-Exploratory
    ...                                  cell_id=52
    ...                                  ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5min
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Configure and wait    ${CURDIR}/config/CB008828-SR-C-a-Exploratory.yaml

Register multi SA and NSA UEs to different RG
    Register multi SA UEs
    Register multi NSA UEs

Register multi SA UEs
    Create ues dictionary
    Set pdu param for internal traffic  UE_ID=51  PDU_ID=1
    Register UE  UE_ID=51  CELL_ID=3
    Establish PDU session  UE_ID=51  PDU_ID=1  SLICE_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=51

    Set pdu param for internal traffic  UE_ID=52  PDU_ID=2
    Register UE  UE_ID=52  CELL_ID=3
    Establish PDU session  UE_ID=52  PDU_ID=2  SLICE_ID=1501  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=52

    Set pdu param for internal traffic  UE_ID=53  PDU_ID=3
    Register UE  UE_ID=53  CELL_ID=3
    Establish PDU session  UE_ID=53  PDU_ID=3  SLICE_ID=1701  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=53

Register multi NSA UEs
    Attach UE  UE_ID=151
    Change eNB ENDC selected PLMN    PLMN=311:492
    SgNB Addition  UE_ID=151  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=151

    Attach UE  UE_ID=152
    Change eNB ENDC selected PLMN    PLMN=311:493
    SgNB Addition  UE_ID=152  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=152

    Attach UE  UE_ID=153
    Change eNB ENDC selected PLMN    PLMN=311:494
    SgNB Addition  UE_ID=153  CELL_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=153

Start ${dl_tput}Mbps ${dir} traffic for multiple UEs
    FOR  ${UE_ID}  IN RANGE  1  4
        Start SA traffic  ue=5${UE_ID}  dir=${dir}  pdu=${UE_ID}  traffic_rate=${dl_tput}Mbps
    END
    FOR  ${UE_ID}  IN RANGE  1  4
        Start NSA traffic  ue=15${UE_ID}  dir=${dir}  traffic_rate=${dl_tput}Mbps
    END

Verify SA and NSA traffic for multi UEs
    FOR    ${UE_ID}    IN RANGE  1  4
        verify SA traffic  ue=5${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=25Mbps
    END
    FOR    ${UE_ID}    IN RANGE  1  4
        verify NSA traffic  ue=15${UE_ID}  dir=dl  expected_traffic=25Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  4
        Deregister UE  UE_ID=5${UE_ID}
    END
    FOR  ${UE_ID}  IN RANGE  1  4
        Detach UE  UE_ID=15${UE_ID}
    END
