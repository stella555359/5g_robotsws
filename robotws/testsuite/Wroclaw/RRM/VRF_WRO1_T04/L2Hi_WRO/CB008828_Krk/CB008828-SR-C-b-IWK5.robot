*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Jakub Grela
...    contact: jakub.grela@nokia.com
...    Description: Suite description in QC

Suite Setup          Run keywords     Prepare suite environment     egate_config=${epc_cfg}  scfc=${scfc}
...                  AND              Create aliases
...                  AND              Create ues deployment  ues=51,52,53,54,55

*** Variables ***
${scfc}=       ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_slice_1_plmn.xml
${epc_cfg}=    ${CURDIR}/config/config_FDD_TDD_FR1_IWK5.cfg

*** Test Cases ***
CB008828-SR-C-b-IWK5_basic_slicing-RG_IWK_with_NBR
    [Setup]    Prepare test environment
    Wait for next full pm interval
    Register multi UEs and establish pdu session
    Start SA traffic for multi UEs
    Sleep    4s
    Run keyword and continue on failure    Verify SA traffic for multi UEs before nbr
    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection  conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlFdSchedData|dlPagingOrSibSchedData

    Run keyword and continue on failure    verify dlslicedata and dldrbweight in tti traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces/output_dl.csv
    ...                                        expected_tti=5UE_2RG
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}

    Deregister multi UEs
    Sleep    5s
    Wait for next full pm interval
    Enable feature
    Register multi UEs and establish pdu session
    Sleep    5s
    Start SA traffic for multi UEs
    Verify NBR counters
    Sleep    5s

    Run keyword and continue on failure    Verify SA traffic for multi UEs after nbr
    Start TTI trace collection
    Sleep    10s
    Stop and convert TTI trace collection  directory_name=${TESTNAME}/TtiTraces2/
    ...                                    conversion_filter=utcTimestampData|dlDrbWeightData|dlSliceData|dlFdSchedData|dlPagingOrSibSchedData

    Run keyword and continue on failure    verify dlslicedata and dldrbweight in tti traces
    ...                                        csv_path=${OUTPUTDIR}/${TESTNAME}/TtiTraces2/output_dl.csv
    ...                                        expected_tti=5UE_2RG_nbr
    ...                                        cell_id=52
    ...                                        ues=${ues_rnti}
    Wait for next full pm interval
    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Verify NBR counters
    Log to console  Collecting counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set Test Variable  ${pm_counters}
    Get counters values  counters=M55139C03506
    ...                  localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3  filepath=${pm_counters}  rg_id=1
    Get counters values  counters=M55139C03507
    ...                  localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3  filepath=${pm_counters}  rg_id=1
    Get counters values  counters=M55139C03509
    ...                  localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3  filepath=${pm_counters}  rg_id=1
    Get counters values  counters=M55139C03510
    ...                  localmoid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3  filepath=${pm_counters}  rg_id=1

    Log to console  Verifing counters
    Run keyword and continue on failure  Verify last counters in file
    ...    M55139C03506    >1     SA_DU_DRB_NBR_REQ
    ...    M55139C03507    >1     SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...    M55139C03509    >0     SA_DU_DRB_NBR_DL
    ...    M55139C03510    >0     SA_DU_DRB_NBR_UL
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Deregister multi UEs
    Release PDU session  UE_ID=51  PDU_ID=1
    Release PDU session  UE_ID=52  PDU_ID=1
    Release PDU session  UE_ID=53  PDU_ID=1
    Release PDU session  UE_ID=54  PDU_ID=1
    Release PDU session  UE_ID=55  PDU_ID=1
    Deregister UE  UE_ID=51
    Deregister UE  UE_ID=52
    Deregister UE  UE_ID=53
    Deregister UE  UE_ID=54
    Deregister UE  UE_ID=55

Start SA traffic for multi UEs
    Start SA traffic  ue=51  dir=dl  pdu=1  traffic_rate=70Mbps
    Start SA traffic  ue=52  dir=dl  pdu=1  traffic_rate=70Mbps
    Start SA traffic  ue=53  dir=dl  pdu=1  traffic_rate=40Mbps
    Start SA traffic  ue=54  dir=dl  pdu=1  traffic_rate=40Mbps
    Start SA traffic  ue=55  dir=dl  pdu=1  traffic_rate=40Mbps

Register multi UEs and establish pdu session
    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}

    Register UE  UE_ID=51  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=51  PDU_ID=1
    Establish PDU session  UE_ID=51  PDU_ID=1  RRC_CHECK=True  SLICE_ID=2
    Get C-RNTI for UE  UE_ID=51
    Register UE  UE_ID=52  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=52  PDU_ID=1
    Establish PDU session  UE_ID=52  PDU_ID=1  RRC_CHECK=True  SLICE_ID=3
    Get C-RNTI for UE  UE_ID=52
    Register UE  UE_ID=55  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=55  PDU_ID=1
    Establish PDU session  UE_ID=55  PDU_ID=1  RRC_CHECK=True  SLICE_ID=5
    Get C-RNTI for UE  UE_ID=55


    Register UE  UE_ID=53  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=53  PDU_ID=1
    Establish PDU session  UE_ID=53  PDU_ID=1  RRC_CHECK=True  SLICE_ID=82
    Get C-RNTI for UE  UE_ID=53
    Register UE  UE_ID=54  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=54  PDU_ID=1
    Establish PDU session  UE_ID=54  PDU_ID=1  RRC_CHECK=True  SLICE_ID=104
    Get C-RNTI for UE  UE_ID=54


Prepare test environment
    Log to console  Prepare test
    Configure and wait  ${CURDIR}/config/CB008828-SR-C-b-IWK5.yaml

Enable feature
    Log to console  Enable NBR traffic
    Configure and wait  ${CURDIR}/config/CB008828-SR-C-b-IWK5-enable.yaml

Verify SA traffic for multi UEs before nbr
    Log to console  Verify traffic - traffic will be lower due to FDD limits
    Run keyword and continue on failure    Verify SA traffic  ue=51  dir=dl  pdu=1  expected_traffic=38Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=52  dir=dl  pdu=1  expected_traffic=38Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=53  dir=dl  pdu=1  expected_traffic=40Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=54  dir=dl  pdu=1  expected_traffic=40Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=55  dir=dl  pdu=1  expected_traffic=38Mbps

Verify SA traffic for multi UEs after nbr
    Log to console  Verify traffic - check if resources were alocated for NBR traffic instead of UE55
    Run keyword and continue on failure    Verify SA traffic  ue=51  dir=dl  pdu=1  expected_traffic=70Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=52  dir=dl  pdu=1  expected_traffic=70Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=53  dir=dl  pdu=1  expected_traffic=26Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=54  dir=dl  pdu=1  expected_traffic=26Mbps
    Run keyword and continue on failure    Verify SA traffic  ue=55  dir=dl  pdu=1  expected_traffic=1-3Mbps
