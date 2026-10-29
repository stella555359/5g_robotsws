*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2    SKIPRUN
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=121,122,123,124,125,126,127,128
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_20_SNSSAI.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1_20SNSSAI.cfg

*** Test Cases ***
CB008828-SR-C-a-3_measure_PRB_related_counters_per_Resource_Group_level_when_a_resource_group_is_created_using_PLMN_and_CB008828_is_disabled
    [Setup]    Run keywords    Prepare test environment
    ...        AND             Wait for next full pm interval

    Start syscomdump collection
    Attach multi UEs to different RG
    SgNB addition for multi UEs

    Add bearers to UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-a-3
    Start NSA traffic for multi UEs
    Sleep    10s  reason=wait for traffic stabilization
    Verify NSA traffic for multi UEs
    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-a-3/TTiTraces
    ...                                    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=10

    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-a-3/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-a-3
    ...                                              ues=${ues_rnti}

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-a-3/TTiTraces/output_dl.csv
    ...                                               expected_tti=C-a-3
    ...                                               cell_id=51
    ...                                               ues=${ues_rnti}

    Verify counters    test_name=C-a-3  nrcell_id=2


    [Teardown]    Run Keywords
    ...    Detach multi UEs
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actSpidBasedSlicingNsa to False
    Set feature flag NRCELL-2/actEndcSpidFwd to False
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRBTS-1/actSliceNumExt to False
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Configure PLMN per RG

Configure PLMN per RG
    Configure    ${CURDIR}/config/CB008828-SR-C-a-3.yaml

Attach multi UEs to different RG
    FOR  ${UE_ID}  IN RANGE  1  9
        Attach UE  UE_ID=12${UE_ID}
    END

SgNB addition for multi UEs
    Create ues dictionary
    Change eNB ENDC selected PLMN    PLMN=311:489
    FOR  ${UE_ID}  IN RANGE  1  4
        SgNB Addition  UE_ID=12${UE_ID}  CELL_ID=2  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=12${UE_ID}
    END
    Change eNB ENDC selected PLMN    PLMN=311:490
    FOR  ${UE_ID}  IN RANGE  4  7
        SgNB Addition  UE_ID=12${UE_ID}  CELL_ID=2  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=12${UE_ID}
    END
    Change eNB ENDC selected PLMN    PLMN=311:491
    FOR  ${UE_ID}  IN RANGE  7  9
        SgNB Addition  UE_ID=12${UE_ID}  CELL_ID=2  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=12${UE_ID}
    END

Add bearers to UEs
    FOR  ${UE_ID}  IN RANGE  4  9
        Modify LTE-NR dual connectivity    UE_ID=12${UE_ID}  BEARER_ID=1
    END

Detach multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Detach UE    UE_ID=12${UE_ID}
    END

Start NSA traffic for multi UEs
    Start NSA traffic  ue=121  dir=dl  bearer=2  traffic_rate=65Mbps
    Start NSA traffic  ue=122  dir=dl  bearer=2  traffic_rate=65Mbps
    Start NSA traffic  ue=123  dir=dl  bearer=2  traffic_rate=65Mbps
    Start NSA traffic  ue=124  dir=dl  bearer=1  traffic_rate=65Mbps
    Start NSA traffic  ue=125  dir=dl  bearer=1  traffic_rate=65Mbps
    Start NSA traffic  ue=126  dir=dl  bearer=1  traffic_rate=65Mbps
    Start NSA traffic  ue=127  dir=dl  bearer=1  traffic_rate=40Mbps
    Start NSA traffic  ue=128  dir=dl  bearer=1  traffic_rate=40Mbps

Verify NSA traffic for multi UEs
    Run keyword and continue on failure    Verify NSA traffic  ue=121  dir=dl  bearer=2  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=122  dir=dl  bearer=2  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=123  dir=dl  bearer=2  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=124  dir=dl  bearer=1  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=125  dir=dl  bearer=1  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=126  dir=dl  bearer=1  expected_traffic=55-65Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=127  dir=dl  bearer=1  expected_traffic=30-40Mbps
    Run keyword and continue on failure    Verify NSA traffic  ue=128  dir=dl  bearer=1  expected_traffic=30-40Mbps
