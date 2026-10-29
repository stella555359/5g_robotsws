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
${epc_cfg}=          ${CURDIR}/config/config_FDD_TDD_FR1_IWK2.cfg
${logcollector}=     True
${tti_trace_dir}=    TtiTraces
${ues_rnti}=         &{EMPTY}


*** Test Cases ***
CB008828-SR-C-b-IWK2_Resource_Group_Aware_Scheduler_interaction_with_VoNR

    [Setup]  Prepare test environment

    Register 3 VoNR UEs and start both GBR and non-GBR data traffic for each
    Wait 10s for throughput stabilization
    Log average data rates for all UEs
    Verify GBR traffic data rates

    Collect TTI trace over 1s

    Verify DRB mapping
    Verify target share

    [Teardown]    Run Keywords
    ...    Deregister UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare suite environment with UE aliases
    Prepare suite environment    scfc=${scfc}    egate_config=${epc_cfg}
    Create aliases
    Create ues deployment  ues=1,2,3

Prepare test environment
    Configure    ${CURDIR}/config/CB008828-SR-C-b-IWK2.yaml
    Wait for eNB on air

Register 3 VoNR UEs and start both GBR and non-GBR data traffic for each
    Register UE-1 and establish PDU session for VoNR
    Start SA traffic  ue=1  dir=dl  pdu=1  qfi=1  traffic_rate=100Mbps
    Start SA traffic  ue=1  dir=dl  pdu=1  qfi=3  traffic_rate=30Mbps

    Register UE-2 and establish PDU session for VoNR
    Start SA traffic  ue=2  dir=dl  pdu=1  qfi=1  traffic_rate=100Mbps
    Start SA traffic  ue=2  dir=dl  pdu=1  qfi=3  traffic_rate=30Mbps

    Register UE-3 and establish PDU session for VoNR
    Start SA traffic  ue=3  dir=dl  pdu=1  qfi=1  traffic_rate=100Mbps
    Start SA traffic  ue=3  dir=dl  pdu=1  qfi=3  traffic_rate=30Mbps

Register UE-${UE_ID} and establish PDU session for VoNR
    Register UE  UE_ID=${UE_ID}  CELL_ID=1
    Sleep    1s

    Set PDU param for internal traffic  UE_ID=${UE_ID}  PDU_ID=1
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=1  SLICE_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=${UE_ID}
    Sleep    1s

    Execute egate command    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=5
    Sleep    1s

    Execute egate command    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=1 qosflows_to_add=1
    Sleep    1s

Collect TTI trace over ${duration}
    Start TTI trace collection
    Sleep    ${duration}
    Stop and convert TTI trace collection    directory_name=${tti_trace_dir}
    ...                                      conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData

Log average data rates for all UEs
    Get bearer stats for UE-1
    Get bearer stats for UE-2
    Get bearer stats for UE-3

Verify GBR traffic data rates
    Verify GRB traffic for UE-1
    Verify GRB traffic for UE-2
    Verify GRB traffic for UE-3

Verify GRB traffic for UE-${UE_ID}
    Run keyword and continue on failure
    ...    Verify SA traffic  dir=dl  ue=${UE_ID}  pdu=1  qfi=3  expected_traffic=30Mbps  data_rate_type=Average

Get bearer stats for UE-${UE_ID}
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=1  qfi=1  data_rate_type=Average
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=1  qfi=2  data_rate_type=Average
    Get SA bearer stats data rate  ue=${UE_ID}  dir=dl  pdu=1  qfi=3  data_rate_type=Average

Verify target share
    Run keyword and continue on failure
    ...    Verify dlSliceData and dlDrbWeight in TTI traces
    ...        csv_path=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        expected_tti=C-b-IWK2
    ...        cell_id=50
    ...        ues=&{EMPTY}

Verify DRB mapping
    Run keyword and continue on failure
    ...    Verify DRB allocation to RGs
    ...        trace_file=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        rnti_to_ue_id_mapping=${ues_rnti}
    ...        test_case=C-b-IWK2
    ...        cell_id=50

Deregister UEs
    Deregister UE    UE_ID=1
    Deregister UE    UE_ID=2
    Deregister UE    UE_ID=3