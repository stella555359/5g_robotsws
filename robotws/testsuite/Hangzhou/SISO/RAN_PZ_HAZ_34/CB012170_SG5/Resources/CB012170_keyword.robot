*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012170_SG5/Resources/json_utils.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot

Documentation
...    author: Xuewen Zhang
...    contact: xuewen.zhang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${bip_capture_duration}   5s
${gNB_ip}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
*** Keywords ***
Step 1 Active 5GC000430 on webEM
    [Arguments]
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true

Step 2 Active CB008133 on webEM
    [Arguments]
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving    abbr=actNrLBmMimoRTXPowerSaving    new_value=true

Step 3 Active CB012170 on webEM
    [Arguments]
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate SSB boost in mMIMO TX power saving    abbr=actSSBBoostInmMIMOMuting    new_value=true

Bip capture and Check PatternID
    [Arguments]    ${cell_id}=${1}
    ${cell_id_list}    create list  ${cell_id}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}
    FOR    ${cell_id}    IN    @{cell_id_list}
        Check PatternID in BIP Log    pcap_log_path=${pcap_log_path_lst[0]}
    END

Covert Pcap To Json
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T json > ${output_file}
    Run    ${command}
    [Return]    ${output_file}

Check PatternID in BIP Log
    [Arguments]    ${pcap_log_path}
    Log To Console    start to check PatternID from bip
    ${ssbBlockSendReq_msg}    Set Variable
    ...   \"dldata_ssblocksendreq||dldata_csirssendreq\"
    Run     mkdir -p ${OUTPUT_DIR}/${TEST NAME}
    ${json_file}    Covert Pcap To Json    pcap_file=${pcap_log_path}
    ...    output_file=${OUTPUT_DIR}/${TEST NAME}/bip_ssb_${bip_capture_duration}.json    filter=${ssbBlockSendReq_msg}
    ${size}    OperatingSystem.Get File Size    ${json_file}
    Run Keyword If    ${size} == 0    Set Test Variable   ${ssbBlockSendReq_msg}
    ...   \"dldata_ssblocksendreql1sw||dldata_csirssendreql1sw\"
    ${json_file}    Run Keyword If    ${size} == 0    Covert Pcap To Json    pcap_file=${pcap_log_path}
    ...    output_file=${OUTPUT_DIR}/${TEST NAME}/bip_ssb_${bip_capture_duration}.json    filter=${ssbBlockSendReq_msg}
    ...    ELSE    Set Variable  ${json_file}
    replace_l1sw_in_file    file_name=${json_file}
    ${patternId}   get_pattern_id_from_ssblocksendreq    file_name=${json_file}

Common Capture BIP log and download
    [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${destination}=Local
    ...    ${nr_phy_cell_ids}=${None}
    Log To Console    start capture bip log
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    sleep    ${bip_capture_duration}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    [Return]    ${full_log_path}

Download MCShark To UTE
    ${wireshark_version}    Run    ls /usr/lib/x86_64-linux-gnu/wireshark/plugins
    set suite variable     ${wireshark_version}

    ${sw_version}    Get MCShark Version
    ${cmd}    Catenate    wget -r -np -nH --header="Authorization: Bearer cmVmdGtuOjAxOjE3OTI5MjExOTA6ME1uaG1sTzdKYTduOVpVNnM1TVpJcDNueVND"
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}    Run    ls ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${wireshark_version}*bookworm.so | head -n 1
    set suite variable     ${MCShark}

    ${cmd2}    Set Variable    ls ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${wireshark_version}*bookworm.so
    ${rc2}    ${output2}    OperatingSystem.Run And Return Rc And Output    ${cmd2}

    ${exist1}     Run keyword and return status    Should not contain    ${output2}    No such file or directory
    #${exist2}     Run keyword and return status    Should not contain    ${output}    404 Not Found

    ${is_MCShark_exist}=  Run Keyword if  '${exist1}'=='${True}'
    ...     set variable  ${True}

    Run keyword if   ${is_MCShark_exist}==${True}   Download MCShark If Have
    ...  ELSE         log to console    This version mcshark donot exit and use last version mcshark

Download MCShark If Have
    Run    sudo rm /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/mcshark-*bookworm.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/${wireshark_version}/epan/

    log to console    download mcshark successfully to UTE

Get MCShark Version
    [Documentation]    jian.1.chen@nokia-sbell.com
    Connect to gnb coam via ssl
    ${sw_version}    coam.get_sw_version    connection=GNB_OAM
    ${list_version}    Split String    ${sw_version}    _
    ${first}    ${rest}    Split String    ${sw_version}    _    1
    ${new_version}    Set Variable If    "${list_version}[2]"=="9999"
    ...    SBTS00_${rest}      ${sw_version}
    ${list_version}    Split String    ${new_version}    _
    ${rest}    ${last}    Split String From Right    ${new_version}    _    1
    ${latest_version}    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${new_version}
    [Return]    ${latest_version}
    [Teardown]    COAM Teardown gnb connections

Step ${step_id} Check gnb status
    [Arguments]
    log to console   Step ${step_id} Check gnb status
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=GNB_OAM
    Wait Until Keyword Succeeds    5 min    10 sec    Verify all cells should be onair   cell_type=nr
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
