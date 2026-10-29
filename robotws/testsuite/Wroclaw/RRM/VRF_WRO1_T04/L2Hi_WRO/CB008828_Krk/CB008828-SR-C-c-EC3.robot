*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2    AP_REG
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=51,52,55,56,59,60
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_SNSSAI_6_PLMN.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1.cfg

*** Test Cases ***
CB008828-SR-C-c-EC3_Fast_changing_of_cell_bandwidth_due_to_PRB_pooling
    [Setup]    Prepare test environment C-c-EC3

    Start syscomdump collection
    Register multi UEs to different RG
    Establish pdu sessions for multi UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-c-EC3

    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-c-EC3/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-c-EC3
    ...                                              ues=${ues_rnti}

    Establish additional 5QI for multi UEs

    Start SA nonGBR traffic for multi UEs for additional 5QI
    Sleep    2s
    Verify SA nonGBR traffic for multi UEs for additional 5QI
    Start TTI trace collection
    Stop TTI trace  target_dir=${OUTPUTDIR}/CB008828-C-c-EC3/TTiTraces  delay=3


    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/CB008828-C-c-EC3/TTiTraces/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/CB008828-C-c-EC3/TTiTraces/output_EC3
    ...  conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...  format=excelCsv


    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-c-EC3/TTiTraces/output_EC3_dl.csv
    ...                                               expected_tti=C-c-EC3
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}

    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment C-c-EC3
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRBTS-1/actSliceNumExt to True
    Enable PRB pooling
    Set feature flag NRBTS-1/bbPoolMode to 1
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Configure RGs

Enable PRB pooling
    Configure and wait   {'MOC': 'NRDU', 'ID': '1', 'flexibleCAMode': 'NumberCellAmount'}
    Configure and wait   {'MOC': 'NRBTS', 'ID': '1', 'actSlowPrbPooling': 'True', 'actScheUePooling': 'True', 'actConnRrcPooling': 'true'}

Configure RGs
    Configure and wait   ${CURDIR}/config/CB008828-SR-C-c-EC3.yaml

Register multi UEs to different RG
    Create ues dictionary
    Set pdu param for internal traffic  UE_ID=51  PDU_ID=1
    Register UE  UE_ID=51  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=52  PDU_ID=2
    Register UE  UE_ID=52  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=55  PDU_ID=5
    Register UE  UE_ID=55  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=56  PDU_ID=6
    Register UE  UE_ID=56  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=59  PDU_ID=9
    Register UE  UE_ID=59  CELL_ID=3
    Set pdu param for internal traffic  UE_ID=60  PDU_ID=10
    Register UE  UE_ID=60  CELL_ID=3

Establish pdu sessions for multi UEs
    Establish PDU session  UE_ID=51  PDU_ID=1  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=51
    Establish PDU session  UE_ID=52  PDU_ID=2  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=52
    Establish PDU session  UE_ID=55  PDU_ID=5  SLICE_ID=1501  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=55
    Establish PDU session  UE_ID=56  PDU_ID=6  SLICE_ID=1503  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=56
    Establish PDU session  UE_ID=59  PDU_ID=9  SLICE_ID=1701  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=59
    Establish PDU session  UE_ID=60  PDU_ID=10  SLICE_ID=1703  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=60

Start SA nonGBR traffic for multi UEs for additional 5QI
    Start SA traffic  ue=51  dir=dl  qfi=2  pdu=1  traffic_rate=35Mbps
    Start SA traffic  ue=52  dir=dl  qfi=2  pdu=2  traffic_rate=35Mbps
    Start SA traffic  ue=55  dir=dl  qfi=2  pdu=5  traffic_rate=35Mbps
    Start SA traffic  ue=56  dir=dl  qfi=2  pdu=6  traffic_rate=35Mbps
    Start SA traffic  ue=59  dir=dl  qfi=2  pdu=9  traffic_rate=35Mbps
    Start SA traffic  ue=60  dir=dl  qfi=2  pdu=10  traffic_rate=35Mbps

Verify SA nonGBR traffic for multi UEs for additional 5QI
    Verify SA traffic  ue=51  dir=dl  qfi=2  pdu=1  expected_traffic=30-40Mbps
    Verify SA traffic  ue=52  dir=dl  qfi=2  pdu=2  expected_traffic=30-40Mbps
    Verify SA traffic  ue=55  dir=dl  qfi=2  pdu=5  expected_traffic=30-40Mbps
    Verify SA traffic  ue=56  dir=dl  qfi=2  pdu=6  expected_traffic=30-40Mbps
    Verify SA traffic  ue=59  dir=dl  qfi=2  pdu=9  expected_traffic=20-25Mbps
    Verify SA traffic  ue=60  dir=dl  qfi=2  pdu=10  expected_traffic=20-25Mbps

Establish additional 5QI for multi UEs
    Modify pdu session    UE_ID=51  QOS=5  PDU_ID=1
    Modify pdu session    UE_ID=52  QOS=5  PDU_ID=2
    Modify pdu session    UE_ID=55  QOS=6  PDU_ID=5
    Modify pdu session    UE_ID=56  QOS=6  PDU_ID=6
    Modify pdu session    UE_ID=59  QOS=5  PDU_ID=9
    Modify pdu session    UE_ID=60  QOS=5  PDU_ID=10

Deregister multi UEs
    Deregister UE  UE_ID=51
    Deregister UE  UE_ID=52
    Deregister UE  UE_ID=55
    Deregister UE  UE_ID=56
    Deregister UE  UE_ID=59
    Deregister UE  UE_ID=60
