*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Vishnu
...              :contact: mundanad.vishnu@nokia.com
...              The aim of the Tetscase describes successful configuration of Long PUCCH and verifies expansion of the
...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE for NSA
...              with Single UE Call Attach on ABIO
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./resources/CB006878_Resource.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Prepare TL with all config files
...                 AND     Perform SCF Delta Commissioning with CB006878_Enable.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep    120s
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords
...                 Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_TDD_2AEQE.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/

${nsa_ue_id}      11
${nsa_trf_id}    1
${nsa_qfi_id}    1

${SCFC}     ${CURDIR}/config/SCF_TDD_2AEQE.xml
${AP_XML}   ${CURDIR}/config/2AEQE_iphy.xml


*** Test Cases ***
CB006878_A_1_02_LongPUCCH_for_FR1_TDD_NonBF_with_NSA_SingleUE_Call_attach_ABIO
    [Documentation]
    ...              The aim of the Tetscase describes successful configuration of Long PUCCH and verifies expansion of the
    ...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE for NSA with
    ...              Single UE Call Attach on ABIO


    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start CPRT Trace Capturing
    Attach UE
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach_TC2.pcap
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=20      trf_id=${nsa_trf_id}
    Trigger UL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     ul_rate=66       trf_id=${nsa_trf_id}
    sleep  60s
    Validate DL Traffic For NSA   ue_id=${nsa_ue_id}     dl_rate=20
    Validate UL Traffic For NSA   ue_id=${nsa_ue_id}     ul_rate=66
    sleep  5s
    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    common_log_collection.Start BIP capture taf    ABIO    [ABIO]    FS
    sleep      2s
    common_log_collection.Stop BIP capture taf    log_dir=${LOG_PATH}
    set test variable     ${CaptureL1L2.path}     ${LOG_PATH}/BIP_L1L2.pcap
    Log to Console  ${CaptureL1L2}
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq     ${LOG_PATH}/BIP_L1L2.pcap   ${10}    ${253}


*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Attach UE
    Start Collecting Syslog     NAME=NSA_call
    X2AP Link Should be UP
    LTE Attach should be Successful    ${nsa_ue_id}
    UE Attach should be Successful    ${nsa_ue_id}

get matched packet in a list
    [Arguments]                     ${message}          ${pdmlFile}     ${FIELDS_name}
    [Documentation]                 returns a list of packets for matched packet
    @{listpacketMatch}              analyzer.get_match_from_path
    ...                             pdmlFile=${pdmlFile}
    ...                             packetName=${message}
    ...                             path=${FIELDS_name}
    ...                             startPacket=1
    ...                             endPacket=100
    [return]          @{listpacketMatch}



Verify prbs in uldata_puschreceivereq
    [Arguments]
    ...      ${pcapFile}   ${start_prb}   ${num_of_prb}
    [Documentation]
    ...     Verifies start prb and number of prbs value used in uldata_puschreceivereq in provided pcap traces
    ${num_of_prbs_using_lower_pcsi}=   set Variable   0
    ${num_of_prbs_using_upper_pcsi}=   set Variable   0
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         uldata_puschreceivereq
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_START_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_start_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_START_PRB}
        ${packet_start_prb}=    convert to integer      ${packet_start_prb}
        should be true      ${packet_start_prb} >= ${start_prb}
        ${num_of_prbs_using_lower_pcsi}=  Run Keyword if     '${packet_start_prb}' == '${start_prb}'
        ...                               Evaluate   ${num_of_prbs_using_lower_pcsi} + 1
        ...                               ELSE     Set Variable   ${num_of_prbs_using_lower_pcsi}
    END
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_NUM_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_num_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_NUM_PRB}
        ${packet_num_prb}=      convert to integer      ${packet_num_prb}
        should be true      ${packet_num_prb} <= ${num_of_prb}
        ${num_of_prbs_using_upper_pcsi}=   Run Keyword if     '${packet_num_prb}' == '${num_of_prb}'
        ...                               Evaluate   ${num_of_prbs_using_upper_pcsi} + 1
        ...                               ELSE      Set Variable   ${num_of_prbs_using_upper_pcsi}
    END
    Log to console  Checking lower PCSI and upper PCSI prb region are used.
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_lower_pcsi} > 20
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_upper_pcsi} > 20
