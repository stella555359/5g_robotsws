*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

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
${epc_cfg}=          /opt/wts/latest/basic_setup.cfg
${logcollector}=     True
${tti_trace_dir}=    TtiTraces
${ues_rnti}=         &{EMPTY}

*** Test Cases ***
CB008828-SR-C-b-IWK7_Resource_Group_Aware_Scheduler_dependency_with_Secondary_Cell_selection_for_Carrier_Aggregation

    [Setup]  Prepare test environment

    Attach 3 CA NSA UEs and start data traffic for each
    Register 3 nonCA SA UEs and start data traffic for each
    Wait 10s for throughput stabilization
    Verify UE data rates before Slice Aware Scheduler activation

    Activate Slice Aware Scheduler

    Wait 10s for throughput stabilization
    Verify UE data rates after Slice Aware Scheduler activation

    Collect TTI trace over 1s

    Verify target share
    Verify DRB mapping

    [Teardown]    Run Keywords
    ...    Teardown test environment
    ...    AND    Send Configuration ID To Scout


*** Keywords ***
Prepare suite environment with UE aliases
    Prepare suite environment    egate_config=${epc_cfg}
    Create aliases
    Create ues deployment  ues=1,2,3,11,12,14

Prepare test environment
    Configure CA
    Wait for eNB on air

Configure CA
    Create new plan
    Edit planned object attributes    NRBTS-1    actCarrierAggregation=true
    ...                                          caConfigurationSupport=2CCDL_2CCUL
    ...                                          maxNumScellsDl=1
    ...                                          maxNumScellsUl=1
    Edit planned object attributes    NRCELL-3    cellDepType=SA
    Plan attribute deletion    NRCELL-3    configuredEpsTac
    Apply planned changes

Teardown test environment
    Run keyword and continue on failure    Deregister UE  UE_ID=1
    Run keyword and continue on failure    Deregister UE  UE_ID=2
    Run keyword and continue on failure    Deregister UE  UE_ID=3
    Run keyword and continue on failure    Detach UE  UE_ID=11
    Run keyword and continue on failure    Detach UE  UE_ID=12
    Run keyword and continue on failure    Detach UE  UE_ID=14
    Deconfigure all

Attach 3 CA NSA UEs and start data traffic for each
    Attach UE-11 and perform SgNB addition
    Start NSA traffic  ue=11  dir=dl  traffic_rate=300Mbps

    Attach UE-12 and perform SgNB addition
    Start NSA traffic  ue=12  dir=dl  traffic_rate=300Mbps

    Attach UE-14 and perform SgNB addition
    Start NSA traffic  ue=14  dir=dl  traffic_rate=300Mbps

Attach UE-${UE_ID} and perform SgNB addition
    Attach UE  UE_ID=${UE_ID}
    Sleep    1s

    SgNB addition  UE_ID=${UE_ID}  CELL_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=${UE_ID}
    Sleep    1s

Register 3 nonCA SA UEs and start data traffic for each
    Register UE-1 and establish PDU session
    Start SA traffic  ue=1  dir=dl  pdu=1  traffic_rate=300Mbps

    Register UE-2 and establish PDU session
    Start SA traffic  ue=2  dir=dl  pdu=1  traffic_rate=300Mbps

    Register UE-3 and establish PDU session
    Start SA traffic  ue=3  dir=dl  pdu=1  traffic_rate=300Mbps

Register UE-${UE_ID} and establish PDU session
    Register UE  UE_ID=${UE_ID}  CELL_ID=3
    Sleep    1s

    Set PDU param for internal traffic  UE_ID=${UE_ID}  PDU_ID=1
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=1  SLICE_ID=1  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=${UE_ID}
    Sleep    1s

Verify UE data rates before Slice Aware Scheduler activation
    Log average data rates for all UEs
    Verify UE data rates are 25Mbps on SANSA cell and 70Mbps on SA cell

Verify UE data rates after Slice Aware Scheduler activation
    Log average data rates for all UEs
    Verify UE data rates are 15Mbps on SANSA cell and 40Mbps on SA cell

Log average data rates for all UEs
    Get NSA bearer stats data rate  ue=11  dir=dl  bearer=2  bearer_type=all  data_rate_type=Average
    Get NSA bearer stats data rate  ue=12  dir=dl  bearer=2  bearer_type=all  data_rate_type=Average
    Get NSA bearer stats data rate  ue=14  dir=dl  bearer=2  bearer_type=all  data_rate_type=Average

    Get SA bearer stats data rate  ue=1  dir=dl  pdu=1  qfi=1  data_rate_type=Average
    Get SA bearer stats data rate  ue=2  dir=dl  pdu=1  qfi=1  data_rate_type=Average
    Get SA bearer stats data rate  ue=3  dir=dl  pdu=1  qfi=1  data_rate_type=Average

Verify UE data rates are ${SANSA_rate} on SANSA cell and ${SA_rate} on SA cell
    Verify NSA UE-11 data rate is about ${SANSA_rate} on PCell
    Verify NSA UE-12 data rate is about ${SANSA_rate} on PCell
    Verify NSA UE-14 data rate is about ${SANSA_rate} on PCell

    Verify NSA UE-11 data rate is about ${SA_rate} on SCell
    Verify NSA UE-12 data rate is about ${SA_rate} on SCell
    Verify NSA UE-14 data rate is about ${SA_rate} on SCell

    Verify SA UE-1 data rate is about ${SA_rate} on PCell
    Verify SA UE-2 data rate is about ${SA_rate} on PCell
    Verify SA UE-3 data rate is about ${SA_rate} on PCell

Verify SA UE-${UE_ID} data rate is about ${traffic_rate} on PCell
    Run keyword and continue on failure
    ...    Verify SA traffic  dir=DL  ue=${UE_ID}  expected_traffic=${traffic_rate}  data_rate_type=Average  scells=0  tolerance=10

Verify NSA UE-${UE_ID} data rate is about ${traffic_rate} on PCell
    Run keyword and continue on failure
    ...    Verify SA traffic  dir=DL  ue=${UE_ID}  expected_traffic=${traffic_rate}  data_rate_type=Average  scells=8  tolerance=10

Verify NSA UE-${UE_ID} data rate is about ${traffic_rate} on SCell
    Run keyword and continue on failure
    ...    Verify SA traffic  dir=DL  ue=${UE_ID}  expected_traffic=${traffic_rate}  data_rate_type=Average  scells=9  tolerance=10

Activate Slice Aware Scheduler
    Configure    ${CURDIR}/config/CB008828-SR-C-b-IWK7_actSAS.yaml
    Wait for eNB on air

Collect TTI trace over ${duration}
    Start TTI trace collection
    Sleep    ${duration}
    Stop and convert TTI trace collection    directory_name=${tti_trace_dir}
    ...                                      conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData

Verify target share
    Run keyword and continue on failure
    ...    Verify dlSliceData and dlDrbWeight in TTI traces
    ...        csv_path=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        expected_tti=C-b-IWK7_cell_id_50
    ...        cell_id=50
    ...        ues=&{EMPTY}

    Run keyword and continue on failure
    ...    Verify dlSliceData and dlDrbWeight in TTI traces
    ...        csv_path=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        expected_tti=C-b-IWK7_cell_id_52
    ...        cell_id=52
    ...        ues=&{EMPTY}

Verify DRB mapping
    Run keyword and continue on failure
    ...    Verify DRB allocation to RGs
    ...        trace_file=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        rnti_to_ue_id_mapping=${ues_rnti}
    ...        test_case=C-b-IWK7_cell_id_50
    ...        cell_id=50

    Run keyword and continue on failure
    ...    Verify DRB allocation to RGs
    ...        trace_file=${OUTPUTDIR}/${tti_trace_dir}/output_dl.csv
    ...        rnti_to_ue_id_mapping=${ues_rnti}
    ...        test_case=C-b-IWK7_cell_id_52
    ...        cell_id=52
