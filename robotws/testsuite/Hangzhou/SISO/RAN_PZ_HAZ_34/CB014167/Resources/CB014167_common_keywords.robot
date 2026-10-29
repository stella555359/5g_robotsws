*** Settings ***
Documentation
...    author: qingjun.quan
...    contact: qingjun.quan@nokia-sbell.com
...    squad group: SG_08
...    feature : CB014167

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library    ../lib/CB014167.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012196_SG08/Resources/EnergySaving_common_keywords.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB014167/AVHA.py
Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009925_CB010766_SG08/lib/parse_soap_update.py
Library    parse_soap_update.SOAPParser    WITH NAME    soap_sg8

*** Variables ***
@{cell_id_common}    ${302}
#${ui_version}    M40PUI1.1
@{cell_id_peak}    ${302}


*** Keywords ***
ISTI_next_to_each_timestamp
    [Arguments]    ${ru_index}=1
    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
#    ${BBOX5_file_path}    Get BBOX5 file from RUlog
    ${BBOX5_file_path}    Get BBOX5 file from Snapshot    ru_index=${ru_index}
    ${Time_ISTI_check_result}    get_ISTI_and_timestamp_count_from_file    ${BBOX5_file_path}
    Should Be Equal    ${Time_ISTI_check_result}    ${True}
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

Information_about_last_RU_resets
    [Arguments]    ${ru_index}=1
    ${reset_two_time_date}    Create List
    ${reset_two_timestamp}    Create List
    FOR    ${i}    IN RANGE  1    3
        Log To Console    ${i}th time RMOD control reset
        ${reset_check_start_time}    DateTime.Get Current Date    result_format=timestamp
        Special_RF_module_reset_from_GUI    ru_index=${ru_index}
        ${reset_check_stop_time}    DateTime.Get Current Date    result_format=timestamp
        Append To List    ${reset_two_time_date}    ${reset_check_start_time}
        Append To List    ${reset_two_time_date}    ${reset_check_stop_time}
        ${reset_check_start_timestamp}    DateTime.Convert Date    ${reset_check_start_time}    result_format=epoch
        ${reset_check_stop_timestamp}    DateTime.Convert Date    ${reset_check_stop_time}    result_format=epoch
        Append To List    ${reset_two_timestamp}    ${reset_check_start_timestamp}
        Append To List    ${reset_two_timestamp}    ${reset_check_stop_timestamp}
    END
#    ${BBOX5_file_path}    Get BBOX5 file from RUlog
    ${BBOX5_file_path}    Get BBOX5 file from Snapshot    ru_index=${ru_index}
    ${reset_reason_item_number}    ${reset_ISTI_item_number}    ${post_dict_content}    get_reset_result_content_from_file    ${BBOX5_file_path}
    Should Be Equal    ${reset_reason_item_number}    ${50}
    Should Be Equal    ${reset_ISTI_item_number}    ${50}
    ${reset_reason}    Set Variable    41 - SOFT_RESET_SW_RESET_N_REQ
    ${reset_cause}    Set Variable    4 - BTS
    Should Be Equal    ${post_dict_content['Reset[1] Reset Reason']}    ${reset_reason}
    Should Be Equal    ${post_dict_content['Reset[1] Reset Cause']}    ${reset_cause}
    ${time_zone_align}=    Add Time To Date    ${post_dict_content['Reset[1] Write']}      08:00:00    result_format=%Y-%m-%d %H:%M:%S
    ${reset_timestamp}    DateTime.Convert Date    ${time_zone_align}   result_format=epoch
    Should Be True     ${reset_timestamp} > ${reset_two_timestamp[0]}
    ...  msg=RMOD 1th reset start time ${reset_check_start_time[0]} after reset write time ${time_zone_align}
    Should Be True     ${reset_timestamp} < ${reset_two_timestamp[1]}
    ...  msg=reset write time ${time_zone_align} after RMOD 1th reset stop time ${reset_two_timestamp[1]}
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

SFP_info_per_SFP_slot_update_with_RU_startup
    [Arguments]    ${ru_index}=1
#    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${BBOX5_file_path}    Get BBOX5 file from Snapshot    ru_index=${ru_index}
    ${all_sfps_info_list_coam}    ${sfp_name_list}    get rmod all sfp info list    ru_index=${ru_index}
    ${all_sfps_info_list_sort_BBOX5}    ${sfp_check_result}    get_all_sfp_info_from_BBOX5    ${BBOX5_file_path}    ${sfp_name_list}
    Should Be Equal    ${sfp_check_result}    ${True}
    ${all_sfps_info_list_length_coam}    Get Length    ${all_sfps_info_list_coam}
    ${all_sfps_info_list_length_BBOX5}    Get Length    ${all_sfps_info_list_sort_BBOX5}
    Should Be Equal    ${all_sfps_info_list_length_coam}    ${all_sfps_info_list_length_BBOX5}
    FOR    ${i}    IN RANGE    ${all_sfps_info_list_length_coam}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['SFP_name']}    ${all_sfps_info_list_sort_BBOX5[${i}]['Item id']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['serialNumber']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] SN']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['speed']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Speed']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['vendor']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Vendor']}
        Should Be Equal    ${all_sfps_info_list_coam[${i}]['vendorPartNumber']}    ${all_sfps_info_list_sort_BBOX5[${i}]['SFP_info[0] Part no']}
    END
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

RU_blackbox_versioning
    [Arguments]    ${check_field}='BlackBox ver:'    ${contain_field}=5.
#    ${BBOX5_file_path}    Get BBOX5 file from RUlog
    ${BBOX5_file_path}    Get BBOX5 file from Snapshot
    ${Black_BOX_vsersion}    Run    command=grep ${check_field} ${BBOX5_file_path}
    Should Contain    ${Black_BOX_vsersion}    ${contain_field}
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

RU_configuration_data
    [Arguments]    ${ru_index}=1
    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
#    ${all_soap_path}    Get startup soap log from RUlog    ru_index=${ru_index}
    ${all_soap_path}    Get startup soap log from Snapshot    ru_index=${ru_index}
    log to console    ${all_soap_path}
    ${all_txcarrier_info_list_soap}    soap_sg8.get_carrier_info_update
    ...    log_path=${all_soap_path}
    ...    class_value=TxArrayCarrier
    ${all_rxcarrier_info_list_soap}    soap_sg8.get_carrier_info_update
    ...    log_path=${all_soap_path}
    ...    class_value=RxArrayCarrier
    Sleep    1min
#    Special_RF_module_reset_from_GUI    ru_index=${ru_index}
#    ${BBOX5_file_path}    Get BBOX5 file from RUlog    ru_index=${ru_index}
    ${BBOX5_file_path}    Get BBOX5 file from Snapshot    ru_index=${ru_index}    snapshot_capture=False
    ${tx_carrier_name_list_BBOX5}    ${tx_carrier_dict_content_BBOX5}    ${rx_carrier_name_list_BBOX5}
    ...    ${rx_carrier_dict_content_BBOX5}    get_all_carriers_info_from_BBOX5    ${BBOX5_file_path}
    ${all_txcarrier_info_list_soap_align_BBOX5}    ${all_rxcarrier_info_list_soap_align_BBOX5}    soap_carriers_index_align_with_BBOX5
    ...    ${all_txcarrier_info_list_soap}    ${tx_carrier_name_list_BBOX5}    ${all_rxcarrier_info_list_soap}    ${rx_carrier_name_list_BBOX5}
    ${all_txcarrier_info_list_num}    Get Length    ${all_txcarrier_info_list_soap_align_BBOX5}
    ${all_rxcarrier_info_list_num}    Get Length    ${all_rxcarrier_info_list_soap_align_BBOX5}
    FOR    ${i}    IN RANGE    ${all_txcarrier_info_list_num}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['distName']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] name']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['array']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] antenna']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['bandwidth']}
        ...    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] bandwidth']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['frequency']}
        ...    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] frequency']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['type']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] type']}
        Should Be Equal    ${all_txcarrier_info_list_soap_align_BBOX5[${i}]['power']}    ${tx_carrier_dict_content_BBOX5['Carrier[${i}] power']}
    END
    FOR    ${i}    IN RANGE    ${all_rxcarrier_info_list_num}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['distName']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] name']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['array']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] antenna']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['bandwidth']}
        ...    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] bandwidth']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['frequency']}
        ...    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] frequency']}
        Should Be Equal    ${all_rxcarrier_info_list_soap_align_BBOX5[${i}]['type']}    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] type']}
        Should Be Equal    ${rx_carrier_dict_content_BBOX5['Carrier[${i}] power']}    0
    END
    [Teardown]    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot

Get BBOX5 file from RUlog
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=7    ${log_name}=14167_AVHA_rflog
    Collect RF Logs To TestPC for secondary core    log_name=${log_name}    ru_index=${ru_index}
    Run  rm -rf ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}/1011_BBOX5*.zip -d ${log_path}/${log_name}
    ${BBOX5_file_path}    set variable    ${log_path}/${log_name}/BBOX5
#    ${BBOX5_file_content}    Run    command=cat ${BBOX5_file}
    [Return]    ${BBOX5_file_path}

Special_RF_module_reset_from_GUI
    [Arguments]  ${ru_index}=${2}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${ru_index_list}  Get All RU Index    connection=${connection}
    wait until keyword succeeds    3x    5sec    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    log to console    \n***RF Module index ${ru_index} Reset from GUI***
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    gnb_index=${gnb_index}    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser

Collect RF Logs To TestPC for secondary core
    [Arguments]  ${log_name}=ru_log  ${ru_index}=1  ${log_path}=${TS_CASE_LOG_PATH}
    ${ru_log_name}    set variable    ${log_name}.zip
    Connect to Common Unit Master  alias=ASIK Master
    Connect to secondary core    sec_alias=ASIK Secondary    asik_alias=ASIK Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    asik_alias=ASIK Secondary    ru_alias=RU_${ru_index}
    FOR  ${i}    IN RANGE    3
        csn.execute     cd /usr/bin;ccsShell.sh log -a -c full -z /ram/${log_name}.zip    connection=RU_${ru_index}    timeout=900
        sleep  15
        ${output_log}    csn.execute    ls /ram/ |grep -i ${log_name}.zip    connection=RU_${ru_index}
        ${output_log}    replace string    ${output_log}    \r\n    ${EMPTY}
        ${status_log}    run keyword and return status    should contain    ${output_log}    ${log_name}.zip
        Exit For Loop if    ${status_log}==True
    END
    &{ru_info}    COAM get ru detial info by ru index   connection=GNB_OAM      ru_index=${ru_index}
    ${ru_ip_addr}   gnb_classical_hangzhou.Get RU IP Address Via File FRIps   ru_serial_number=${ru_info['serialNumber']}
    ...    connection=ASIK Secondary
    Wait until keyword succeeds    5 min    20 sec    csn.download file    remote_path=/ram/${log_name}.zip
    ...    local_path=${log_path}/${log_name}.zip   connection=RU_${ru_index}
    [Teardown]  Run Keywords   Run Keyword And Ignore Error   csn.disconnect   connection=RU_${ru_index}  AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=Container   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=ASIK Secondary   AND
    ...                        Run Keyword And Ignore Error   csn.disconnect   connection=ASIK Master

Make L3 call in celL302
    data_transfer_common    tput_self_define=${tput_define_CB014167}    cell_id=${cell_id_common}    target_avg_percent=${0.98}
    ...    min_percent=${0.8}    loop_times=${1}    duration=${300}

Connect to secondary core
    [Arguments]  ${sec_alias}=ASIK Secondary    ${asik_alias}=ASIK Master
    csn.connect to    hostname=fct4s0icom.local
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=${sec_alias}
    ...    proxy=${asik_alias}

AVHA_energysaving_EDSM_Check
    coam.perform_commissioning     scf_file=${Golden_SCF_Path}      timeout=900    connection=GNB_OAM
    Wait Until Keyword Succeeds    15 min    10 sec    Verify all cells should be onair
    Enable Rmod EDSM
    ${nr_cell_id_list}    Get All Cell Id    cell_type=nr
    Set test variable    ${nr_cell_id_list}
    lock or unlock all the cells and check status
    Wait Until Keyword Succeeds    10min    120s    Special RMODs power state should be correct    expect_state=SLEEP_EXTREME
    sleep   15min
    Special RMODs power state should be correct    expect_state=SLEEP_EXTREME
    log to console    unlock cells
    lock or unlock all the cells and check status    expected_value=Unlocked
    sleep   5min
    Wait Until Keyword Succeeds    20min    30s    Verify all cells should be onair    cell_type=nr
    log to console    check active and history alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    data_transfer_common    tput_self_define=${tput_define_CB014167}    cell_id=${cell_id_common}    target_avg_percent=${0.3}
    ...    min_percent=${0.2}    loop_times=${1}    duration=${60}

get rmod all sfp info list
    [Arguments]  ${connection}=GNB_OAM    ${ru_index}=1
    ${ru_name}    Catenate    SEPARATOR=-    RMOD    ${ru_index}(
	${links}    coam.get_sfp_links   timeout=20    connection=${connection}
	${sfp_name_list}    Create List
	${connected_link_ports_list}    set variable    ${links['connected']}
    ${all_sfps_info_list_coam}    create list
	${not_connected_link_ports_list}    set variable    ${links['notConnected']}
    FOR  ${link}  IN  @{connected_link_ports_list}
        ${OPT_name}    Set Variable    ${link['details']['hardwareParameters']['physicalPort']['source']}
        ${SFP_name}=    Run Keyword If    '${OPT_name}'=='OPT_IF1'    Set Variable    SFP0
        ...    ELSE IF    '${OPT_name}'=='OPT_IF2'    Set Variable    SFP1
        ...    ELSE IF    '${OPT_name}'=='OPT_IF3'    Set Variable    SFP2
        ...    ELSE IF    '${OPT_name}'=='OPT_IF4'    Set Variable    SFP3
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    '${SFP_name}'!='None' and ${status}    Append To List    ${sfp_name_list}    ${SFP_name}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['source']}
        ...    SFP_name=${SFP_name}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['source']}
        ...     vendorPartNumber=${link['details']['hardwareParameters']['vendorPartNumber']['source']}
        ...     serialNumber=${link['details']['hardwareParameters']['serialNumber']['source']}
        ...     speed=${link['details']['staticParameters']['nominalSignalingRate']['source']}
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    ${status}     Append To List    ${all_sfps_info_list_coam}    ${item}
    END
    FOR  ${link}  IN  @{not_connected_link_ports_list}
        ${OPT_name}    Set Variable    ${link['details']['hardwareParameters']['physicalPort']['source']}
        ${SFP_name}=    Run Keyword If    '${OPT_name}'=='OPT_IF1'    Set Variable    SFP0
        ...    ELSE IF    '${OPT_name}'=='OPT_IF2'    Set Variable    SFP1
        ...    ELSE IF    '${OPT_name}'=='OPT_IF3'    Set Variable    SFP2
        ...    ELSE IF    '${OPT_name}'=='OPT_IF4'    Set Variable    SFP3
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    '${SFP_name}'!='None' and ${status}    Append To List    ${sfp_name_list}    ${SFP_name}
        ${item}  create dictionary  linkPort=${link['data']['linkPorts']['source']}
        ...    SFP_name=${SFP_name}
        ...     vendor=${link['details']['hardwareParameters']['vendor']['source']}
        ...     vendorPartNumber=${link['details']['hardwareParameters']['vendorPartNumber']['source']}
        ...     serialNumber=${link['details']['hardwareParameters']['serialNumber']['source']}
        ...     speed=${link['details']['staticParameters']['nominalSignalingRate']['source']}
        ${status}    Run Keyword And Return Status    Should Contain    ${link['data']['linkPorts']['source']}    ${ru_name}
        Run Keyword If    ${status}     Append To List    ${all_sfps_info_list_coam}    ${item}
    END
    [Return]   ${all_sfps_info_list_coam}    ${sfp_name_list}

Get startup soap log from RUlog
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_index}=1    ${log_name}=14167_AQQA_rflog_check_soap
    ${all_soap_path}    Create List
    Collect RF Logs To TestPC for secondary core    log_name=${log_name}    ru_index=${ru_index}
    Run  rm -rf ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}.zip -d ${log_path}/${log_name}
    Run  unzip ${log_path}/${log_name}/1011_UnitOAM_SOAP_Log*.zip -d ${log_path}/${log_name}
    Sleep    10s
    Run  unzip ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_OM*.zip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    Sleep    10s
    ${all_soap_file}=    Run    command= ls ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    ${all_soap_file}    Split String    ${all_soap_file}    \n
    ${soap_file_num}    Get Length    ${all_soap_file}
    FOR    ${i}    IN RANGE    ${soap_file_num}
        ${filename}    Split String    ${all_soap_file[${i}]}    .
        ${filename}    Set Variable    ${filename[0]}
        Run    command=gunzip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${all_soap_file[${i}]}
        Append To List    ${all_soap_path}    ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${filename}.xml
    END
    [Return]    ${all_soap_path}

Get startup soap log from Snapshot
    [Arguments]    ${ru_index}=7    ${snapshot_log_path}=${TS_CASE_LOG_PATH}
    ${all_soap_path}    Create List
    run keyword and ignore error    OperatingSystem.Run    sudo rm -rf /home/ute/snapshot
    ${RU_SN}    Get Serial Number Via Ru Index    ru_index=${ru_index}
    Save Coam Snapshot    target_dir=${snapshot_log_path}
    ${file_name}    OperatingSystem.Run  ls -al ${snapshot_log_path}|grep Snapshot_|awk '{ print $9 }'
    ${snapshot_file_path}    set variable    ${snapshot_log_path}/${file_name}
    log to console    unzip ${snapshot_file_path} to /home/ute/snapshot
    OperatingSystem.Run  unzip ${snapshot_file_path} -d /home/ute/snapshot
    ${soap_file_name}    OperatingSystem.Run    cat /home/ute/snapshot/snapshot_file_list.txt|grep _UnitOAM_SOAP_Log.zip|grep ${RU_SN}
    ${soap_file_name}    Remove String Using Regexp    ${soap_file_name}  \\s+
    ${soap_file_dir}    Replace String    ${soap_file_name}    .zip    ${EMPTY}
    ${bts_part_name}    get_bts_part_name    snapshot_file_list_path=/home/ute/snapshot/snapshot_file_list.txt
    ...    file_name=${soap_file_name}
    log to console    find soap file in ${bts_part_name}
    ${bts_part_dir}    Replace String    ${bts_part_name}    .zip    ${EMPTY}
    log to console    unzip ${bts_part_name} to /home/ute/snapshot/${bts_part_dir}
    OperatingSystem.Run  unzip /home/ute/snapshot/${bts_part_name} -d /home/ute/snapshot/${bts_part_dir}
    OperatingSystem.Run  unzip /home/ute/snapshot/${bts_part_dir}/${soap_file_name} -d /home/ute/snapshot/${bts_part_dir}/${soap_file_dir}
    ${log_path}    set variable    /home/ute/snapshot/${bts_part_dir}
    ${log_name}    set variable    ${soap_file_dir}
    Run  unzip ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_OM*.zip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    Sleep    10s
    ${all_soap_file}=    Run    command= ls ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log
    ${all_soap_file}    Split String    ${all_soap_file}    \n
    ${soap_file_num}    Get Length    ${all_soap_file}
    FOR    ${i}    IN RANGE    ${soap_file_num}
        ${filename}    Split String    ${all_soap_file[${i}]}    .
        ${filename}    Set Variable    ${filename[0]}
        Run    command=gunzip -d ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${all_soap_file[${i}]}
        Append To List    ${all_soap_path}    ${log_path}/${log_name}/UnitOAM_SOAP_Startup_LBTS_log/${filename}.xml
    END
    [Return]    ${all_soap_path}

Get BBOX5 file from Snapshot
    [Arguments]    ${ru_index}=7    ${snapshot_log_path}=${TS_CASE_LOG_PATH}    ${snapshot_capture}=True
    ${RU_SN}    Get Serial Number Via Ru Index    ru_index=${ru_index}
    Run keyword if    ${snapshot_capture}==True    Save Coam Snapshot    target_dir=${snapshot_log_path}
    ${file_name}    OperatingSystem.Run  ls -al ${snapshot_log_path}|grep Snapshot_|awk '{ print $9 }'
    ${snapshot_file_path}    set variable    ${snapshot_log_path}/${file_name}
    Run keyword if    ${snapshot_capture}==True    log to console    unzip ${snapshot_file_path} to /home/ute/snapshot
    Run keyword if    ${snapshot_capture}==True    OperatingSystem.Run  unzip ${snapshot_file_path} -d /home/ute/snapshot
    ${bbox_file_name}    OperatingSystem.Run    cat /home/ute/snapshot/snapshot_file_list.txt|grep _BBOX5_all.zip|grep ${RU_SN}
    ${bbox_file_name}    Remove String Using Regexp    ${bbox_file_name}  \\s+
    ${bbox_file_dir}    Replace String    ${bbox_file_name}    .zip    ${EMPTY}
    ${bts_part_name}    get_bts_part_name    snapshot_file_list_path=/home/ute/snapshot/snapshot_file_list.txt
    ...    file_name=${bbox_file_name}
    log to console    find BBOX file in ${bts_part_name}
    ${bts_part_dir}    Replace String    ${bts_part_name}    .zip    ${EMPTY}
    log to console    unzip ${bts_part_name} to /home/ute/snapshot/${bts_part_dir}
    OperatingSystem.Run  unzip /home/ute/snapshot/${bts_part_name} -d /home/ute/snapshot/${bts_part_dir}
    OperatingSystem.Run  unzip /home/ute/snapshot/${bts_part_dir}/${bbox_file_name} -d /home/ute/snapshot/${bts_part_dir}/${bbox_file_dir}
    File Should Exist    /home/ute/snapshot/${bts_part_dir}/${bbox_file_dir}/BBOX5
    [Return]    /home/ute/snapshot/${bts_part_dir}/${bbox_file_dir}/BBOX5

Get Serial Number Via Ru Index
    [Arguments]    ${ru_index}
    selenium login and disable screen lock
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${ru_index}
    ${serial_number}    Set Variable    ${output_ru['Serial number']}
    [Return]    ${serial_number}
    [Teardown]    selenium logout and close browser
