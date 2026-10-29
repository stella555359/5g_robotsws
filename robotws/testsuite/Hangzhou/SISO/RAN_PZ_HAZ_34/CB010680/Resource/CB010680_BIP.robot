*** Settings ***
Library    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_SRS_BIP.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010680/Resource/CB010680_A_Params.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Documentation    this file used for bip log collection

*** Keywords ***
Check BIP log SRS TOE is Expected
    [Arguments]    ${pcap_log_path}    ${srsUePeriodicity}    ${csrs}    ${expected_startPrb}
    ...    ${pci}=none    ${subcell_num}=${0}    ${srs_cell_num}=${0}
    Log To Console    start to check srs from bip with ${pcap_log_path} ${srsUePeriodicity} ${csrs} ${expected_startPrb} ${pci}
    ${srs_pos_msg}    Set Variable    \"uldata_srsposreceivereq||uldata_srsposreceiverespps\"
    ${json_file}    Covert Pcap To Json    pcap_file=${pcap_log_path}
    ...    output_file=${OUTPUT_DIR}/${TEST NAME}/bip_srs_${log_time}.json    filter=${srs_pos_msg}
    get_srs_and_check_value    file_name=${json_file}    srsUePeriodicity=${srsUePeriodicity}
    ...    csrs=${csrs}    expected_startPrb=${expected_startPrb}    pci=${pci}    subcell_num=${subcell_num}
    ...    srs_cell_num=${srs_cell_num}

Start Common Capture BIP log
    [Arguments]    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${destination}=Local
    ...    ${nr_phy_cell_ids}=${None}
    Log To Console    start capture bip log
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}

End Common Capture BIP log and Download
   [Arguments]    ${target_dir}    ${target_file_name}=l1l2bip_log
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    [Return]    ${full_log_path}

Common Capture BIP log and download
    [Arguments]    ${target_dir}    ${duration}=1s    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${destination}=Local
    ...    ${nr_phy_cell_ids}=${None}
    Log To Console    start capture bip log
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    sleep    ${duration}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    [Return]    ${full_log_path}

Covert Pcap To Json
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T json > ${output_file}
    Run    ${command}
    [Return]    ${output_file}

Trigger SRS Measurement From LMF
    [Arguments]    ${ue_index}=${0}
    ${ue_sn}    set variable    ${tl.ues[${ue_index}].imsi}
    ${lcs_trigger_file}    Set Variable    ${CURDIR}/lcs_srs_trigger.xml
    update_imsi_in_xml    file_path=${lcs_trigger_file}     new_imsi=${ue_sn}
    #${cmd}    Set Variable    curl -v http://10.110.137.171:9210 -d @${lcs_trigger_file}
    ${cmd}    Set Variable    curl -v http://10.68.81.137:9210 -d @${lcs_trigger_file}
    ${result}    run    ${cmd}
    Log To Console    ${result}

Start Catch TCPDUMP SCTP Log
    [Arguments]    ${filename}   ${time}=3s    ${connection}=GNB_SSH
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_username}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump -t sctp -i any port 38472 or port 38412 -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Stop And Copy TCPDUMP To UTE
    [Arguments]    ${filename}    ${time}=10s     ${connection}=GNB_SSH
    Log To Console    Stop And Copy Log To UTE
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}/
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_username}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${OUTPUT_DIR}/${TEST NAME}/${filename}    connection=${connection}
    sleep    ${time}
    [Return]    ${OUTPUT_DIR}/${TEST NAME}/${filename}
    [Teardown]    ssh.disconnect    connection=${connection}

Bip capture and SRS Check
    [Arguments]    ${srs_config_dict}    ${pci_dict}    ${srs_cell_num_dic}    ${gnb_index}=${0}
    ${cell_id_list}    get dictionary keys    ${srs_config_dict}
    ${utc_time}    robot.libraries.DateTime.Get Current Date
    ${log_time}    change_format_for_utr_time    utc_time=${utc_time}
    Set Test Variable    ${log_time}
    ${pcap_log_path_lst}    Common Capture BIP log and download    target_dir=${OUTPUT_DIR}/${TEST NAME}
    ...    target_file_name=bip_srs_${log_time}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${cSRS}    set variable    ${srs_config_dict[${cell_id}]}
        ${csrs_prb}    set variable    ${CSRS_PRBNUM_MAPPING[${cSRS}]}
        ${srsConfig}    ${startPrb}    ${prbNum}    Get srsForPositioning For Specfic Cell
        ...    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
        ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
        ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
        ...    cell_id=${cell_id}    cSRS_PRBs=${csrs_prb}
        Check BIP Log SRS TOE Is Expected    pcap_log_path=${pcap_log_path_lst[0]}    pci=${pci_dict[${cell_id}]}
        ...    srsUePeriodicity=${srsConfig['srsUePeriodicity']}    csrs=${srsConfig['cSRS']}    expected_startPrb=${startPrb}
        ...    srs_cell_num=${srs_cell_num_dic[${cell_id}]}
    END