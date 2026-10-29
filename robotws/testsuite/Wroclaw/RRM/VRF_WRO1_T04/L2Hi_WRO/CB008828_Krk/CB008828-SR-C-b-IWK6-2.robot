*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Aleksandra Wilczynska
...    contact: aleksandra.wilczynska@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=1,2,3,4,5,6
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_MP_AP_LO.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_MP_AP_LO.cfg

*** Test Cases ***
CB008828-SR-C-b-IWK6-2_Interaction_between_Micro-DTX_scheduler_with_Slice_Aware_Scheduler_–_DRB_profile_parameters_less_than_cell_level_parameters
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi UEs to different RG
    Establish pdu session for UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-b-IWK6-2

    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-b-IWK6-2/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-b-IWK6-2
    ...                                              ues=${ues_rnti}

    Start SA traffic for multi UEs
    Sleep    10s
    Verify SA traffic for multi UEs

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-b-IWK6-2/TTiTraces
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=5

    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/CB008828-C-b-IWK6-2/TTiTraces/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/CB008828-C-b-IWK6-2/TTiTraces/output_with_dtx
    ...  conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlDtxOptimData|dlDtxCellEnablingData|dlPagingOrSibSchedData
    ...  format=excelCsv

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-b-IWK6-2/TTiTraces/output_dl.csv
    ...                                               expected_tti=C-b-IWK6-2
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to False
    Set feature flag NRCELL-1/actEnhDtxOptimizedScheduler to True
    Set feature flag NRCELL-1/actDtxOptimizedScheduler to True
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Set Micro-DTX scheduler parameters value
    Configure SNSSAI per RG

Set Micro-DTX scheduler parameters value
    Configure    {'MOC': 'NRCELL', 'ID': '1', 'dtxOptimizedScheduler': [{'dtxDelaySinceLastScheduling': 30, 'dtxMaxRetentionDelay': 30}]}
    Configure    {'MOC': 'NRDRB', 'ID': '15', 'dtxDelaySinceLastScheduling': 10, 'dtxMaxRetentionDelay': 10}

Configure SNSSAI per RG
    Configure and wait   ${CURDIR}/config/CB008828-SR-C-b-IWK6-2.yaml

Register multi UEs to different RG
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  7
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
    Establish PDU session  UE_ID=4  PDU_ID=4  SLICE_ID=3  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=4
    Establish PDU session  UE_ID=5  PDU_ID=5  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=5
    Establish PDU session  UE_ID=6  PDU_ID=6  SLICE_ID=5  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=6

Start SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Start SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  traffic_rate=45Mbps
    END

Verify SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Run keyword and continue on failure    Verify SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=40-47Mbps
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  7
        Deregister UE  UE_ID=${UE_ID}
    END
