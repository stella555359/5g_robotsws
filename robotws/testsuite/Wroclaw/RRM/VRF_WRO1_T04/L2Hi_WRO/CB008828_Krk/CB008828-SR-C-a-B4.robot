*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...    Author: Michal Gorski
...    Contact: michal.gorski@nokia.com
...    Description: Suite description in QC

Library     resources/drb_verifier.py
Resource    resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Suite Setup       Prepare suite environment with UE aliases
Suite Teardown    Clean suite environment

*** Variables ***
${scfc}=             ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_SNSSAI_6_PLMN.xml
${epc_cfg}=          ${CURDIR}/config/config_FDD_TDD_FR1_B4.cfg
${logcollector}=     True
${tti_trace_dir}=    TtiTraces
${ues_rnti}=         &{EMPTY}

*** Test Cases ***
CB008828-SR-C-a-B4_DRB_without_configured_resource_group

    [Setup]  Prepare test environment

    Register 4 UEs with 3 DRBs each and start data traffic
    Wait 10s for throughput stabilization
    Log average data rates for all UEs

    Collect TTI trace over 1s

    Verify DRB mapping
    Verify target share

    [Teardown]   Run Keywords
    ...    Deregister UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare suite environment with UE aliases
    Prepare suite environment    scfc=${scfc}    egate_config=${epc_cfg}
    Create aliases
    Create ues deployment  ues=1,2,3,4

Prepare test environment
    Configure    ${CURDIR}/config/CB008828-SR-C-a-B4.yaml
    Wait for eNB on air

Register 4 UEs with 3 DRBs each and start data traffic
    Register UE-1 and establish 3 PDU sessions with slices 1, 2, 3
    Start 75Mbps DL data traffic on each of 3 PDUs for UE-1

    Register UE-2 and establish 3 PDU sessions with slices 100, 101, 102
    Start 75Mbps DL data traffic on each of 3 PDUs for UE-2

    Register UE-3 and establish 3 PDU sessions with slices 1501, 1502, 1503
    Start 75Mbps DL data traffic on each of 3 PDUs for UE-3

    Register UE-4 and establish 3 PDU sessions with slices 1701, 1702, 1703
    Start 75Mbps DL data traffic on each of 3 PDUs for UE-4

Register UE-${UE_ID} and establish 3 PDU sessions with slices ${SLICE_1}, ${SLICE_2}, ${SLICE_3}
    Register UE  UE_ID=${UE_ID}  CELL_ID=1
    Sleep    1s

    Set PDU param for internal traffic  UE_ID=${UE_ID}  PDU_ID=1
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=1  SLICE_ID=${SLICE_1}  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=${UE_ID}
    Sleep    1s

    Set PDU param for internal traffic  UE_ID=${UE_ID}  PDU_ID=2
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=2  SLICE_ID=${SLICE_2}
    Sleep    1s

    Set PDU param for internal traffic  UE_ID=${UE_ID}  PDU_ID=3
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=3  SLICE_ID=${SLICE_3}
    Sleep    2s

Start ${traffic_rate} DL data traffic on each of 3 PDUs for UE-${UE_ID}
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=1  traffic_rate=${traffic_rate}
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=2  traffic_rate=${traffic_rate}
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=3  traffic_rate=${traffic_rate}

Log average data rates for all UEs
    Get bearer stats for UE-1
    Get bearer stats for UE-2
    Get bearer stats for UE-3
    Get bearer stats for UE-4

Get bearer stats for UE-${UE_ID}
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=1  qfi=1  data_rate_type=Average
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=2  qfi=1  data_rate_type=Average
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=3  qfi=1  data_rate_type=Average

Collect TTI trace over ${duration}
    Start TTI trace collection
    Sleep    ${duration}
    Stop and convert TTI trace collection    directory_name=${tti_trace_dir}
    ...                                      conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData

Verify target share
    Run keyword and continue on failure
    ...    Verify dlSliceData and dlDrbWeight in TTI traces
    ...        csv_path=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        expected_tti=C-a-B4
    ...        cell_id=50
    ...        ues=&{EMPTY}

Verify DRB mapping
    Run keyword and continue on failure
    ...    Verify DRB allocation to RGs
    ...        trace_file=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        rnti_to_ue_id_mapping=${ues_rnti}
    ...        test_case=C-a-B4
    ...        cell_id=50

Deregister UEs
    Deregister UE    UE_ID=1
    Deregister UE    UE_ID=2
    Deregister UE    UE_ID=3
    Deregister UE    UE_ID=4
