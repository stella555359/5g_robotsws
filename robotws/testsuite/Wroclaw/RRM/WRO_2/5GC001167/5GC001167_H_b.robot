*** Settings ***
Force Tags    CIT    RAN_5G    SBTS00    SBTS22R3    SBTS22R4    SBTS23R1    NoResUsage
    ...    CLOUD_5G_I_BLLL_AP_LOO
    ...    VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD_2CELLS

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     String
Library     DateTime
Library     Keywords5GC001167.py
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging

Suite Setup       Run Keywords    Disable L1Bypass
                    ...    AND    With Swconfig Flags    flags=@{SWCONFIG_FLAGS_LIST}
#Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


Test Setup    With Retry Context    5
...           With Gnb Snapshot Collection On Failure
...    AND    With Simulator Snapshot Collection On Failure
...    AND    Trigger Site Reset
...    AND    Wait For Testline Icmp Echo Replies And Ssh Services
...    AND     With Teardownable
...               keyword=Start Default Logging With Timestamp Folder
...               teardown=Stop Default Logging With Timestamp Folder
...    AND      With Simulator Configuration    config=${CURDIR}/config/sa_fdd_cmWv_fs/basic_fs_sa_call_fdd_cmwv_2CC.cfg    timeout=300

*** Variables ***
${retry_path}
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC001167-H-b2_Data_Transmission_for_2CC_configured_UE
    Attach UE With Scell Configuration
    Verify Successful 2CC On NGAP And F1AP Messages    pcap_file_path=${retry_path}/tshark/gnb_F1_E1_RRC.pcap
    Send Data Traffic For Ue And Display Bearer Statistic
    Detach Ue And Verify Detach Procedure

*** Keywords ***
Attach UE With Scell Configuration
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue    ue_id=1    cell=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Send Data Traffic For Ue And Display Bearer Statistic
    Start Dl Data Traffic    ue_id=1    qfi=1    trf_id=1
    Start Ul Data Traffic    ue_id=1    qfi=1    trf_id=1
    Wait for Traffic to Stabilize
    Display Bearer Statistic In Egate Console    ue_id=1    qfi=1
    Stop All Data Traffics    ue_id=1

Detach Ue And Verify Detach Procedure
    Start Tcpdump On Remote Interface    alias=detach_check    log_filename_prefix=detach_check    log_dirpath=${OUTPUT_DIR}/tshark
    Wait For Tcpdump To Start
    Deregister Ue    ue_id=1
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    pcap_file_path=${OUTPUT_DIR}/tshark/detach_check.pcap

Wait For Tcpdump To Start
    Sleep  10s

Start Default Logging With Timestamp Folder
    ${date}=    Get Current Date    result_format=%d-%m-%y_%H:%M:%S
    ${date}=    Convert to String    ${date}
    Create Directory    ${OUTPUT_DIR}/${date}
    Set Suite Variable    $retry_path    ${OUTPUT_DIR}/${date}
    Start Default Logging    output_dirpath=${retry_path}

Stop Default Logging With Timestamp Folder
    Stop Default Logging    output_dirpath=${retry_path}


