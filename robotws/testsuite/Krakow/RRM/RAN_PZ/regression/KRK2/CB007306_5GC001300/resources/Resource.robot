*** Settings ***
Documentation  File contains Robot keywords to assist in performing common tests for CB007306 5GC001300
...            author: Mateusz Jaskot, mateusz.jaskot@nokia.com
...            maintainer: Mateusz Jaskot, mateusz.jaskot@nokia.com

Library       DateTime
Library       Process
Library       String
Library       taf.ue    WITH NAME    ue
Library       testsuite/Krakow/resources/RAN_PZ_KRK2/FR_5GC002421/custom_methods.py
Library       testsuite.Krakow.resources.RAN_PZ_KRK2.FR_5GC002421.GnbCustomDu  WITH NAME  GnbCustomDu
Library       testsuite/Krakow/RRM/RAN_PZ/regression/KRK2/CB007306_5GC001300/resources/Utilities.py
Library       testsuite/Krakow/RRM/RAN_PZ/regression/KRK2/CB007306_5GC001300/resources/5GC001300_rach_verifier.py     WITH NAME   rach
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/common_resources/common_step/interface.robot
Resource      testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Variables     testsuite/Krakow/RRM/RAN_PZ/regression/KRK2/CB007306_5GC001300/resources/delta.py
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
@{ALLOWED_ALARMS}                   SSH enabled
...                                 R&D Service Port enabled
...                                 LMP access via port 443
...                                 Diagnostic Files collected
...                                 Radio Diagnostic Files collected
...                                 BTS Reset Cause
...                                 Ethernet port security is disabled
...                                 Service account root access is enabled
...                                 Sanity Check Error
...                                 Diagnostic Check Error
${PRACH_INDEX_TABLE}                testsuite/Krakow/RRM/RAN_PZ/regression/KRK2/CB007306_5GC001300/resources/prachConfigurationIndex_Table.data
${SUBCELLS_ITEM}                    0
${DETECT_PRACH_ITEM}                0
${IP_TO_COLLECT_GNB_LOGS}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_LOG_FILE_PATH}                /home/ute
${GNB_LOG_ZIP_FILE_NAME}            gnb_logs.zip
${GNB_LOG_FULL_PATH}                ${None}
${GNB_LOG_SCRIPT_PATH}              ${None}
${GNB_LOG_DOWNLOAD_FULL_PATH}       ${None}
${REMOTE_HOST_IP}                   ute@7-7-UTE5GCLOUDT1SK029-integration.p01.ska-lab.nsn-rdnet.net

*** Keywords ***
Suite Setup 5GC001300
    Common Suite Setup With OnAir Test Line Preparation
    ...                swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                prefix_tag=TL75
    Prepare Gnb Log

Test Setup
    [Arguments]   ${capabilities}=REAL_UE
    [Documentation]     Preparing for test includes reserving UE, Cell and setting up expected cell id during attach
    ...     :param capabilities: capabilities used to request UE of correct type
    Common Preconditions
    Common Step Trigger
    ue.Require Ue       UE              capabilities=${capabilities}
    Require Cell        GNB_1_CELL_1    ${tl.gnbs[0].global_bts_id}   1
    Set Ue Location     UE              GNB_1_CELL_1

Test Teardown
    Run Keyword And Ignore Error        Detach Ue   UE

Catch L1L2 Trace And Extract
    Run BIP And TTI logs    ${TEST_NAME}_l1l2      ${IP_TO_COLLECT_GNB_LOGS}      7
    ${logs_name}=    Looking For File Name  path=./   file_name=l1l2.zip
    Log     log_name: ${logs_name}     console=yes
    Extract File  zfile=${logs_name}   dest=${LOG_PATH}
    Remove File     ${logs_name}
    ${logs_name_length}=    Get Length    ${logs_name}
    ${log_dir} =    Get Substring    ${logs_name}    -${logs_name_length}    -4
    Log     ${log_dir}
    ${pcap_file}=    Looking For File Name  path=${LOG_PATH}/${log_dir}/bip/   file_name=.pcap
    Return From Keyword     ${LOG_PATH}/${log_dir}/bip/${pcap_file}

Run BIP And TTI Logs
    [Arguments]    ${bip_name}    ${IP_to_collect_gnb_logs}     ${duration}
    [Documentation]     This keyword catch BIP log from BTS while attaching UE device
    ...                 :param bip_name: file BIP name
    ...                 :param IP_to_collect_gnb_logs: IP of BTS where BIP log will be collected
    ...                 :param duration: collecting BIP log time

    Start Process    ${GNB_LOG_SCRIPT_PATH} ${IP_to_collect_gnb_logs} -b ${duration} -c2 -n ${bip_name}
    ...              shell=yes
    ...              alias=TTI
    Sleep   30   Sleep neeeded to set up Bts log
    Attach UE1
    Sleep   100   Sleep needed to create log files
    Wait For Process     TTI    timeout=200
    Detach Ue   UE

Set PrachConfigIndex To ${prach_nr} On DU
    [Documentation]     This keyword is applying appropriate prach configuration on gNB
    ...     :param prach_nr: used to construct name of variable holding configuration
    ...                      variables are defined in resources/delta.py file in this feature
    ${value}  Catenate      SEPARATOR=      delta_      ${prach_nr}
    Perform Delta Commissioning On gNB      delta=${${value}}
    Sleep   360    Sleep needed to establish X2 link
    Wait Until Keyword Succeeds     300 sec     15 sec   Verify gNB is onAir

Revert Changes To PrachConfigIndex
    Set PrachConfigIndex To 38 On DU

Attach UE1
    Attach Ue   UE      timeout=70

Convert L1L2 For RACH
    [Arguments]  ${input_file}  ${output_file}
    [Documentation]     This keyword uses tshark to filter and convert pcap file to text.
    ...     :param input_file: path to pcap file
    ...     :param output_file: text output will be saved to this file


    ${cmd}    catenate
    ...       tshark
    ...       -r ${input_file} -T fields
    ...       -Y "uldata_prachreceivereq||uldata_prachreceiveind||dldata_pdcchsendreq"
    ...       -e _ws.col.Info
        ...       -e 3gpp.sfn
    ...       -e 3gpp.slot
    ...       -e UlData_prachReceiveReqSubcell_t.prachOccasions_item
    ...       -e UlData_prachReceiveIndSubcell_t.noisePower
    ...       -e UlData_PrachReceiveInd_t.subcells.Length
    ...       -e UlData_prachReceiveIndSubcell_t.detectedPrachPreambles.Length
    ...       -e UlData_detectedPrachPreambles_t.prachPreambleIndex
    ...       -e UlData_detectedPrachPreambles_t.prachPreambleTimeOccasion
    ...       -e UlData_detectedPrachPreambles_t.initialTa
    ...       -e UlData_detectedPrachPreambles_t.peakMetric
    ...       -e DlData_PdcchSendReq_t.beamId
    ...       -E header=y -E separator=';' > ${output_file}
    run       ${cmd}

Prepare Gnb Log
    Download Gnb Log
    Extract Gnb Log

Download Gnb Log
    ${gnb_log_already_downloaded}   Veirfy Gnb Log is Downloaded
    Return from keyword if    ${gnb_log_already_downloaded}==${True}
    ${gnb_log_zip}      catenate  SEPARATOR=
    ...                           ${REMOTE_HOST_IP}
    ...                           :
    ...                           ${GNB_LOG_FILE_PATH}/
    ...                           ${GNB_LOG_ZIP_FILE_NAME}
    Run    cd ${GNB_LOG_FILE_PATH}; scp ${gnb_log_zip} ${GNB_LOG_FILE_PATH}
    verify_file_exists    ${GNB_LOG_DOWNLOAD_FULL_PATH}
    ${file_size}    Get File Size    ${GNB_LOG_DOWNLOAD_FULL_PATH}
    Should be true    ${file_size}>10000    msg=Failed to correctly download gnb log

Veirfy Gnb Log is Downloaded
    ${gnb_log_already_downloaded}    check_if_file_exists    ${GNB_LOG_FILE_PATH}/${GNB_LOG_ZIP_FILE_NAME}
    ${file_size}    Run keyword if    ${gnb_log_already_downloaded}==${True}    Get File Size    ${GNB_LOG_FILE_PATH}/${GNB_LOG_ZIP_FILE_NAME}
    ...             ELSE    Get Zero Value
    ${gnb_log_already_downloaded}    Set variable if    ${file_size}>10000    ${True}    ${False}
    Run keyword if    ${gnb_log_already_downloaded}==${True}    Set suite variable    ${GNB_LOG_DOWNLOAD_FULL_PATH}
    ...                                                       ${GNB_LOG_FILE_PATH}/${GNB_LOG_ZIP_FILE_NAME}
    Set suite variable    ${GNB_LOG_DOWNLOAD_FULL_PATH}    ${GNB_LOG_FILE_PATH}/${GNB_LOG_ZIP_FILE_NAME}
    [Return]    ${gnb_log_already_downloaded}

Extract Gnb Log
    Log to console    Unpacking ${GNB_LOG_DOWNLOAD_FULL_PATH} to ${GNB_LOG_FILE_PATH}/gnb_log
    Run    cd ${GNB_LOG_FILE_PATH}; rm -r ${GNB_LOG_FILE_PATH}/gnb_log
    Run    cd ${GNB_LOG_FILE_PATH}; mkdir gnb_log; unzip ${GNB_LOG_DOWNLOAD_FULL_PATH} -d ${GNB_LOG_FILE_PATH}/gnb_log
    Run    sudo chmod -R 777 ${GNB_LOG_FILE_PATH}/gnb_log
    Set suite variable    ${GNB_LOG_SCRIPT_PATH}     ${GNB_LOG_FILE_PATH}/gnb_log/gnb_logs/gnb_logs
    [Return]    ${GNB_LOG_FILE_PATH}/gnb_log

Get Zero Value
    Log    Keyword to set value of 0
    [Return]    ${0}
