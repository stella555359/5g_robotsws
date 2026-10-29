*** Settings ***
Documentation    :copyright: Nokia
...              :contact: I_NSB_MN_RAN_RD_VRF_HAZ4_13@internal.nsn.com


*** Variables ***
${TXT_DEF_PATH}    C:\\tmp\\Qualcomm\\
${EXPORT_GRID}    Common Displays;Events and Debug Msgs vs. Time



*** Keywords ***
Qualcomm Common Suite Setup
    Clean the process
    Common Suite Setup
#    Get ue name    ue1_name

Qualcomm Common Suite Teardown
    Common Suite Teardown

Qualcomm Common Test Setup
    Common Test Setup

Qualcomm Common Test Teardown
    Common Test Teardown

Qualcomm get throughput
    [Arguments]    ${server}    ${server_log_path}
    Qualcomm Get Throughput    ${server}    ${server_log_path}

Clean the process
    TAF_SSH.connect_to    hostname=${tl.ues[0].ssh_connection_details.addr}    username=${tl.ues[0].ssh_connection_details.username}
    ...                   password=${tl.ues[0].ssh_connection_details.password}    alias=conn
    TAF_SSH.Execute    command=taskkill /f /im adb.exe    connection=conn    timeout=10s
    TAF_SSH.Execute    command=taskkill /f /im QXDM.exe    connection=conn    timeout=10s
    TAF_SSH.Execute    command=taskkill /f /im python.exe    connection=conn    timeout=10s
    TAF_SSH.Execute    command=taskkill /f /im java.exe    connection=conn    timeout=10s
    TAF_SSH.Execute    command=rm -rf C:\\tmp\\Qualcomm\\*    connection=conn    timeout=10s

Wait '${time}' for stabible
    sleep    ${time}

Download qualcomm log
    [Arguments]    ${UE_trace_file}    ${export_grid}    ${name}    ${txt_file_path}=${TXT_DEF_PATH}
    qualcomm export to txt with qcat    ${UE_trace_file}    ${txt_file_path}    ${export_grid}
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${UE_trace_file}    ${test_log_directory()}/
    sftp_download    ${UE_PC_IP}    22    ${UE_PC_USER}    ${UE_PC_PASS}    ${TXT_DEF_PATH}Events_and_Debug_Msgs_vs__Time.txt
    ...              ${test_log_directory()}/${name}

Get qualcomm log
    [Arguments]    ${ue_id}    ${log_path}=${TXT_DEF_PATH}
    Qualcomm Start Qxdm Trace    ${ue_id}
    Wait '15s' for stabible
    ${absolutely_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${log_path}
    [Return]    ${absolutely_path}

Attach qualcomm ue and make call stable
    Qualcomm detach ue    ${UE1_ID}
    Qualcomm attach ue    ${UE1_ID}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Qualcomm Start DL Data    ${UE1_ID}    ${UE1_DL_PORT}    ${UE1_DL_SERVER_LOG}    ${UE1_DL_CLIENT_EXTRA_CMD}
    Wait '60s' for stabible
    Qualcomm Stop DL Data    ${UE1_ID}    ${UE1_DL_PORT}

Attach qualcomm ue and download qualcomm log
    [Arguments]    ${ue_name}    ${dl_port}    ${dl_server_log}    ${extra_cmd}    ${throughput_file_tag}
    ${ue_id}    get_ue_ip    ${CONFIG_FILE}    ${ue_name}
    Qualcomm detach ue    ${ue_id}
    Qualcomm attach ue    ${ue_id}
    Wait '5s' for stabible
    Qualcomm Start DL Data    ${ue_id}    ${dl_port}    ${dl_server_log}    ${extra_cmd}
    Qualcomm Start DL Data    ${ue_id}    5006    ${dl_server_log}    ${extra_cmd}
    Wait '20s' for stabible
    ${log_path}    Get qualcomm log    ${ue_id}
    Qualcomm Stop DL Data    ${ue_id}    ${dl_port}
    Qualcomm detach ue    ${ue_id}
    Download qualcomm log    ${log_path}.hdf    ${EXPORT_GRID}    Throughput_${throughput_file_tag}_raw.txt
    ${throughput_file}    set variable    Throughput_${throughput_file_tag}_raw.txt
    [Return]    ${throughput_file}

Attach qualcomm ue with dlul data and download qualcomm log
    [Arguments]    ${ue_name}    ${dl_port}    ${ul_port}    ${dl_server_log}    ${ul_server_log}
    ...    ${dl_extra_cmd}    ${ul_extra_cmd}    ${throughput_file_tag}
    ${ue_id}    get_ue_ip    ${CONFIG_FILE}    ${ue_name}
    Qualcomm detach ue    ${ue_id}
    Qualcomm attach ue    ${ue_id}
    Wait '5s' for stabible
    Qualcomm Start DL Data    ${ue_id}    ${dl_port}    ${dl_server_log}    ${dl_extra_cmd}
    Qualcomm Start DL Data    ${ue_id}    5006    ${dl_server_log}    ${dl_extra_cmd}
    Qualcomm Start UL Data    ${ue_id}    ${ul_port}    ${ul_server_log}    ${ul_extra_cmd}
    Wait '20s' for stabible
    ${log_path}    Get qualcomm log    ${ue_id}
    Qualcomm Stop DL Data    ${ue_id}    ${dl_port}
    Qualcomm Stop UL Data    ${ue_id}    ${ul_port}
    Qualcomm detach ue    ${ue_id}
    Download qualcomm log    ${log_path}.hdf    ${EXPORT_GRID}    Throughput_${throughput_file_tag}_raw.txt
    ${throughput_file}    set variable    Throughput_${throughput_file_tag}_raw.txt
    [Return]    ${throughput_file}

Get ue name
    [Arguments]    ${ue_name}
    ${UE1_ID}    get_ue_ip    ${CONFIG_FILE}    ${ue_name}
    Set global variable    ${UE1_ID}

Attach ue with name and make call stable
    [Arguments]    ${ue_name}    ${dl_port}    ${dl_server_log}    ${extra_cmd}
    ${ue_id}    get_ue_ip    ${CONFIG_FILE}    ${ue_name}
    Qualcomm Start Qxdm Trace    ${ue_id}
    Qualcomm detach ue    ${ue_id}
    Qualcomm attach ue    ${ue_id}
    Qualcomm Start DL Data    ${ue_id}    ${dl_port}    ${dl_server_log}    ${extra_cmd}
    Qualcomm Start DL Data    ${ue_id}    ${dl_port}    ${dl_server_log}    ${extra_cmd}
    Wait '60s' for stabible
    Qualcomm Stop DL Data    ${ue_id}    ${dl_port}
    ${hdf_path}    Qualcomm Stop Qxdm Trace    ${ue_id}    ${TXT_DEF_PATH}
    ${pcell_id}    Qualcomm Get Field Value    Serving Cell PCI    ${hdf_path}.hdf
    Set suite variable    ${pcell_id}

Set ue to NSA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74213    1099511627776
    Wait '1s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74087    0
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.radio.multisim.config ssss
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_1 1
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '30s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    80000    80
    Wait '5s' for stabible
    Qualcomm Set Apn    ${ue_id}    NSA     stdata1
    Wait '5s' for stabible


Set ue to SA
    [Arguments]    ${ue_id}
    ${value1}    Qualcomm Read Nvitem     ${ue_id}    80000
    Wait '5s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74213    0
    Wait '1s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    74087    1099511627776
    Wait '1s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    67218    1
    Wait '1s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    73991    0
    Wait '5s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    root & adb wait-for-device
    Wait '5s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.radio.multisim.config ssss
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell rm -rf /data/user_de/0/com.android.providers.telephony/databases/telephony.db
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell setprop persist.vendor.radio.5g_mode_pref_0 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    setprop persist.vendor.radio.5g_mode_pref_1 2
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    shell sync
    Wait '1s' for stabible
    qualcomm_execute_adb_cmd    ${ue_id}    reboot
    Wait '30s' for stabible
    Qualcomm Write Nvitem    ${ue_id}    80000    64
    Wait '5s' for stabible
    Qualcomm Set Apn    ${ue_id}    SA    stdata1
    Wait '5s' for stabible


