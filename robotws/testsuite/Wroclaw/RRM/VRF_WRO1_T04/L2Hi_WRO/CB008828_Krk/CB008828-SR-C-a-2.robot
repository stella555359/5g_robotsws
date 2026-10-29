*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2    SKIPRUN
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Aleksandra Wilczynska
...    contact: aleksandra.wilczynska@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords     Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...              AND    Create aliases
...              AND    Create ues deployment  ues=151,152,153,154,155,156
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=                        ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_20_SNSSAI.xml
${cfg_file}=                    ${CURDIR}/config/config_FDD_TDD_FR1_20SNSSAI.cfg

*** Test Cases ***
CB008828-SR-C-a-2_measure_PRB_related_counters_per_Resource_Group_level_when_a_resource_group_is_created_using_SPID_Groups_and_CB008828_is_disabled
    [Setup]     Run keywords    Prepare test environment
    ...         AND             Wait for next full pm interval

    Start syscomdump collection

    Attach multi UEs to different RG
    SgNB addition for multi UEs

    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-a-2

    Start NSA traffic for multi UEs
    Sleep    10s    reason=wait for traffic stabilization
    Verify NSA traffic for multi UEs

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-a-2/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-a-2/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-2
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}


    Verify counters    test_name=C-a-2  nrcell_id=3

    [Teardown]    Run Keywords
    ...    Detach multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceNumExt to False
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRBTS-1/actSpidBasedSlicingNsa to True
    Set feature flag NRCELL-3/actEndcSpidFwd to True
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5min
    Configure SPID per RG

Configure SPID per RG
    Configure    ${CURDIR}/config/CB008828-SR-C-a-2.yaml

Attach multi UEs to different RG
    Execute egate command  cmd=ue_enb_param id=151
    Attach UE  UE_ID=151
    FOR  ${UE_ID}  IN RANGE  2  4
        Execute egate command  cmd=ue_enb_param id=15${UE_ID} spid=1
        Attach UE  UE_ID=15${UE_ID}
    END
    FOR  ${UE_ID}  IN RANGE  4  6
        Execute egate command  cmd=ue_enb_param id=15${UE_ID} spid=2
        Attach UE  UE_ID=15${UE_ID}
    END
    FOR  ${UE_ID}  IN RANGE  6  7
        Execute egate command  cmd=ue_enb_param id=15${UE_ID} spid=3
        Attach UE  UE_ID=15${UE_ID}
    END

SgNB addition for multi UEs
    Create ues dictionary
    Change eNB ENDC selected PLMN    PLMN=311:489
    FOR  ${UE_ID}  IN RANGE  1  4
        SgNB Addition  UE_ID=15${UE_ID}  CELL_ID=3  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=15${UE_ID}
    END
    Change eNB ENDC selected PLMN    PLMN=311:490
    FOR  ${UE_ID}  IN RANGE  4  6
        SgNB Addition  UE_ID=15${UE_ID}  CELL_ID=3  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=15${UE_ID}
    END
    Change eNB ENDC selected PLMN    PLMN=311:491
    FOR  ${UE_ID}  IN RANGE  6  7
        SgNB Addition  UE_ID=15${UE_ID}  CELL_ID=3  RRC_CHECK=True
        Get C-RNTI for UE  UE_ID=15${UE_ID}
    END

Start NSA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Start NSA traffic  ue=15${UE_ID}  dir=dl  bearer=2  traffic_rate=30Mbps
    END

Verify NSA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Run keyword and continue on failure    Verify NSA traffic  ue=15${UE_ID}  dir=dl  bearer=2  expected_traffic=30Mbps
    END

Detach multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Detach UE    UE_ID=15${UE_ID}
    END
