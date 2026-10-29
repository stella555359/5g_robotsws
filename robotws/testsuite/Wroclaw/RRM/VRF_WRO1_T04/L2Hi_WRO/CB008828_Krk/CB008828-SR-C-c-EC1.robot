*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SBTS24R2
...           CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Resource    ./resources/CB008828_resources.robot
Resource    ../resources/common_configuration.robot

Documentation
...    author: Arkadiusz Sobejko
...    contact: arkadiusz.sobejko@nokia.com
...    Description: Suite description in QC

Suite Setup      Run keywords    Prepare suite environment    egate_config=${cfg_file}    scfc=${scfc}
...              AND             Create aliases
...              AND             Create ues deployment    ues=51,52,53,54,55,56,57,58
Suite Teardown   Clean suite environment

*** Variables ***
${scfc}=      ${CURDIR}/config/scfc_FDD_TDD_FR1_AEQE_2000_SNSSAI_6_PLMN.xml
${cfg_file}=  ${CURDIR}/config/config_FDD_TDD_FR1.cfg

*** Test Cases ***
CB008828-SR-C-c-EC1_Excessive_GBR_traffic_load
    [Setup]    Prepare test environment C-c-EC1

    Start syscomdump collection
    Register multi UEs to different RGs
    Establish pdu sessions for multi UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR

    Establish additional non-GBR 5QI for multi UEs

    Start non-GBR SA traffic for multi UEs for additional 5QI
    Sleep    5s
    Verify non-GBR SA traffic for multi UEs for additional 5QI

    Start TTI trace collection

    Stop TTI trace  target_dir=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR/TTiTraces  delay=3


    Verify that ues are in correct resource group    input_file=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR/syscomdump/syscomdump.pcap
    ...                                              expected_rg=C-c-EC1_nonGBR
    ...                                              ues=${ues_rnti}

    Stop non-GBR SA traffic for multi UEs

    Start syscomdump collection
    Establish additional GBR 5QI for multi UEs
    Stop syscomdump collection    target_dir=${OUTPUTDIR}/CB008828-C-c-EC1_GBR

    Start GBR SA traffic for multi UEs for additional 5QI
    Sleep    5s
    Verify GBR SA traffic for multi UEs for additional 5QI

    Start non-GBR SA traffic for multi UEs for additional 5QI
    Sleep    5s
    Verify non-GBR SA traffic after GBR traffic for multi UEs for additional 5QI

    Start TTI trace collection

    Stop TTI trace  target_dir=${OUTPUTDIR}/CB008828-C-c-EC1_GBR/TTiTraces  delay=3


    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR/TTiTraces/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR/TTiTraces/output_nonGBR
    ...  conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...  format=excelCsv

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-c-EC1_nonGBR/TTiTraces/output_nonGBR_dl.csv
    ...                                               expected_tti=C-c-EC1_nonGBR
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}

    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/CB008828-C-c-EC1_GBR/TTiTraces/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/CB008828-C-c-EC1_GBR/TTiTraces/output_GBR
    ...  conversion_filter=dlDrbWeightData|utcTimestampData|dlSliceData|dlPagingOrSibSchedData
    ...  format=excelCsv

    Verify dlslicedata and dldrbweight in tti traces  csv_path=${OUTPUTDIR}/CB008828-C-c-EC1_GBR/TTiTraces/output_GBR_dl.csv
    ...                                               expected_tti=C-c-EC1_GBR
    ...                                               cell_id=52
    ...                                               ues=${ues_rnti}


    [Teardown]    Run Keywords
    ...    Deregister multi UEs
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Prepare test environment C-c-EC1
    Set feature flag NRBTS-1/actSliceAwareScheduler to True
    Set feature flag NRBTS-1/actRanSharing to True
    Set feature flag NRBTS-1/actSliceNumExt to True
    Set feature flag NRPMRNL-1/miNrCellUtilPerNrg to 5
    Configure RGs

Configure RGs
    Configure and wait    ${CURDIR}/config/CB008828-SR-C-c-EC1.yaml

Register multi UEs to different RGs
    Create ues dictionary
    FOR  ${UE_ID}  IN RANGE  1  9
        Set pdu param for internal traffic  UE_ID=5${UE_ID}  PDU_ID=${UE_ID}
        Register UE  UE_ID=5${UE_ID}  CELL_ID=3
    END

Establish pdu sessions for multi UEs
    Establish PDU session  UE_ID=51  PDU_ID=1  SLICE_ID=2  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=51
    Establish PDU session  UE_ID=52  PDU_ID=2  SLICE_ID=4  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=52
    Establish PDU session  UE_ID=53  PDU_ID=3  SLICE_ID=5  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=53
    Establish PDU session  UE_ID=54  PDU_ID=4  SLICE_ID=6  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=54
    Establish PDU session  UE_ID=55  PDU_ID=5  SLICE_ID=1501  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=55
    Establish PDU session  UE_ID=56  PDU_ID=6  SLICE_ID=1502  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=56
    Establish PDU session  UE_ID=57  PDU_ID=7  SLICE_ID=1503  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=57
    Establish PDU session  UE_ID=58  PDU_ID=8  SLICE_ID=1504  RRC_CHECK=True
    Get C-RNTI for UE  UE_ID=58

Start non-GBR SA traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  5
        Start SA traffic  ue=5${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  traffic_rate=40Mbps
    END
    FOR  ${UE_ID}  IN RANGE  5  9
        Start SA traffic  ue=5${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  traffic_rate=20Mbps
    END

Verify non-GBR SA traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  5
        Verify SA traffic  ue=5${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  expected_traffic=25-40Mbps
    END
    FOR  ${UE_ID}  IN RANGE  5  9
        Verify SA traffic  ue=5${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  expected_traffic=10-20Mbps
    END

Verify non-GBR SA traffic after GBR traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Verify SA traffic  ue=5${UE_ID}  dir=dl  qfi=2  pdu=${UE_ID}  expected_traffic=0-2Mbps
    END

Start GBR SA traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Start SA traffic  ue=5${UE_ID}  dir=dl  qfi=4  pdu=${UE_ID}  traffic_rate=30Mbps
        Sleep    2s
    END

Verify GBR SA traffic for multi UEs for additional 5QI
    FOR  ${UE_ID}  IN RANGE  1  9
        Verify SA traffic  ue=5${UE_ID}  dir=dl  qfi=4  pdu=${UE_ID}  expected_traffic=20-30Mbps
    END

Stop non-GBR SA traffic for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Stop SA traffic  ue=5${UE_ID}  pdu=${UE_ID}
    END

Establish additional non-GBR 5QI for multi UEs
    Modify pdu session    UE_ID=51  QOS=6  PDU_ID=1
    Modify pdu session    UE_ID=52  QOS=6  PDU_ID=2
    Modify pdu session    UE_ID=53  QOS=6  PDU_ID=3
    Modify pdu session    UE_ID=54  QOS=6  PDU_ID=4
    Modify pdu session    UE_ID=55  QOS=6  PDU_ID=5
    Modify pdu session    UE_ID=56  QOS=6  PDU_ID=6
    Modify pdu session    UE_ID=57  QOS=6  PDU_ID=7
    Modify pdu session    UE_ID=58  QOS=6  PDU_ID=8

Establish additional GBR 5QI for multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Modify pdu session  UE_ID=5${UE_ID}  QOS=3  PDU_ID=${UE_ID}
        Modify pdu session  UE_ID=5${UE_ID}  QOS=1  PDU_ID=${UE_ID}
    END

Deregister multi UEs
    FOR  ${UE_ID}  IN RANGE  1  9
        Deregister UE  UE_ID=5${UE_ID}
    END
