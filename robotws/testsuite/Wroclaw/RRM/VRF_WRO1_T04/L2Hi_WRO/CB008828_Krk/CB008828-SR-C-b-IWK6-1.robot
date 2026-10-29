*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2    SKIPRUN
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description: Suite description in QC


Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=1,2,3,4,5,6,7,8
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_SNSSAI_6_PLMN.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1.cfg

*** Test Cases ***
CB008828-SR-C-b-IWK6-1_Interaction_between_Micro-DTX_scheduler_with_Slice_Aware_Scheduler
    [Setup]    Prepare test environment

    Start syscomdump collection
    Register multi UEs to different RGs
    Establish pdu sessions for multi UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-b-IWK6-1

    Start SA traffic for multi UEs for default 5QI
    Verify traffic for multi UEs for default 5QI

    Establish additional 5QI for multi UEs

    Start SA traffic for multi UEs for additional 5QI
    Verify traffic for multi UEs for additional 5QI

    Start TTI trace collection
    Stop and convert TTI trace collection  directory_name=CB008828-C-b-IWK6-1/TTiTraces
    ...                                    conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...                                    delay=10

    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/CB008828-C-b-IWK6-1/TTiTraces/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/CB008828-C-b-IWK6-1/TTiTraces/output_with_dtx
    ...  conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlDtxOptimData|dlDtxCellEnablingData
    ...  format=excelCsv

    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-b-IWK6-1/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-b-IWK6-1
    ...                                              ues=${ues_rnti}

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-b-IWK6-1/TTiTraces/output_dl.csv
    ...                                               expected_tti=C-b-IWK6-1
    ...                                               cell_id=50
    ...                                               ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Prepare test environment
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRCELL-1/actEnhDtxOptimizedScheduler to True
    Set feature flag NRCELL-1/actDtxOptimizedScheduler to True
    Set DRX parameter to default value
    Configure multiple PLMNs with multiple RGs

Set DRX parameter to default value
    Configure    {'MOC': 'NRCELL', 'ID': '1', 'dtxOptimizedScheduler': [{'dtxMaxRetentionDelay': 10, 'dtxDelaySinceLastScheduling': 0}]}

Configure multiple PLMNs with multiple RGs
    Configure and wait   ${CURDIR}/config/CB008828-SR-C-b-IWK6-1.yaml

Register multi UEs to different RGs
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  9
        Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=${UE_ID}  CELL_ID=1
    END

Establish pdu sessions for multi UEs
    Establish PDU session  UE_ID=1  PDU_ID=1  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=1
    Establish PDU session  UE_ID=2  PDU_ID=2  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=2
    Establish PDU session  UE_ID=3  PDU_ID=3  SLICE_ID=1501  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=3
    Establish PDU session  UE_ID=4  PDU_ID=4  SLICE_ID=1503  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=4
    Establish PDU session  UE_ID=5  PDU_ID=5  SLICE_ID=1701  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=5
    Establish PDU session  UE_ID=6  PDU_ID=6  SLICE_ID=1703  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=6
    Establish PDU session  UE_ID=7  PDU_ID=7  SLICE_ID=1801  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=7
    Establish PDU session  UE_ID=8  PDU_ID=8  SLICE_ID=1803  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=8

Start SA traffic for multi UEs for default 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  traffic_rate=30Mbps
    END

Verify traffic for multi UEs for default 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Run keyword and continue on failure    Verify SA traffic  ue=${UE_ID}  dir=dl  pdu=${UE_ID}  expected_traffic=25-32Mbps
    END

Start SA traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  traffic_rate=30Mbps
    END

Verify traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Run keyword and continue on failure    Verify SA traffic  ue=${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  expected_traffic=25-32Mbps
    END

Modify pdu session
    [Arguments]  ${UE_ID}  ${QOS}  ${PDU_ID}=${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=${PDU_ID} qosflows_to_add=${QOS}

Establish additional 5QI for multi UEs
    Modify pdu session    UE_ID=1  QOS=5  PDU_ID=1
    Modify pdu session    UE_ID=2  QOS=5  PDU_ID=2
    Modify pdu session    UE_ID=3  QOS=6  PDU_ID=3
    Modify pdu session    UE_ID=4  QOS=6  PDU_ID=4
    Modify pdu session    UE_ID=5  QOS=5  PDU_ID=5
    Modify pdu session    UE_ID=6  QOS=5  PDU_ID=6
    Modify pdu session    UE_ID=7  QOS=6  PDU_ID=7
    Modify pdu session    UE_ID=8  QOS=6  PDU_ID=8

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Deregister UE    UE_ID=${UE_ID}
    END
