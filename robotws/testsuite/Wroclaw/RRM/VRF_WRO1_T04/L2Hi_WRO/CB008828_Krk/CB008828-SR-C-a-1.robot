*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2    SKIPRUN
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Aleksandra Wilczynska
...    contact: aleksandra.wilczynska@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords     Prepare suite environment  egate_config=${cfg_file}  scfc=${scfc}
...              AND    Create aliases
...              AND    Create ues deployment  ues=1,2,3,4
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=                        ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${cfg_file}=                    ${CURDIR}/config/config_FDD_TDD_FR1_AEQE_2000_SNSSAI_1_PLMN.cfg

*** Test Cases ***
CB008828-SR-C-a-1_measure_PRB_related_counters_per_Resource_Group_level
    [Setup]     Run keywords    Prepare test environment
    ...         AND             Wait for next full pm interval

    Start syscomdump collection
    Register multi UEs to different RG
    Establish pdu session for UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-a-1

    Start 50Mbps DL traffic for multi UEs
    Start 20Mbps UL traffic for multi UEs
    Sleep    10s
    Verify SA traffic for multi UEs

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-a-1/TtiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-a-1/TtiTraces/output_dl.csv
    ...                                               expected_tti=C-a-1
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    Verify counters    test_name=C-a-1  nrcell_id=1

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to False
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Configure SNSSAI per RG

Configure SNSSAI per RG
    Configure    ${CURDIR}/config/CB008828-SR-C-a-1.yaml

Register multi UEs to different RG
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  5
        Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=${UE_ID}  CELL_ID=1
    END

Establish pdu session for UEs
    Establish PDU session  UE_ID=1  PDU_ID=1  SLICE_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=1
    Establish PDU session  UE_ID=2  PDU_ID=2  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=2
    Establish PDU session  UE_ID=3  PDU_ID=3  SLICE_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=3
    Establish PDU session  UE_ID=4  PDU_ID=4  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=4

Start ${traffic_rate}Mbps ${dir} traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Start SA traffic  ue=${UE_ID}  dir=${dir}  pdu=${UE_ID}  traffic_rate=${traffic_rate}Mbps
    END

Verify SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Run keyword and continue on failure    Verify SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=45-50Mbps
    END
    FOR  ${UE_ID}  IN RANGE  1  5
        Run keyword and continue on failure    Verify SA traffic  ue=${UE_ID}  dir=ul  pdu=${UE_ID}  expected_traffic=15-20Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  5
        Deregister UE  UE_ID=${UE_ID}
    END
