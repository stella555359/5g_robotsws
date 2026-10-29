*** Settings ***

*** Variables ***
${cell_id}
@{ALLOWED_FAULT}                    4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  7312  4592  7313
@{ALLOWED_HISTORY_FAULT}            4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  7312  4592  7313
${save_snapshot}                    ${False}
${SAVE LOG DIRECTORY}               /home/ute/Try/Testlog_Folder/
${snapshot_path}                    ${SAVE LOG DIRECTORY}/snapshot_path/
${testline_name}                    7_2_RJIO1063
${cur_relative_dir}                 /home/ute/Try
${scf_relative_dir}                 /home/ute/Try
${scf_path}                        /home/ute/scf_location
${TS_LOG_PATH_BASE}                /home/ute/Try/Testlog_Folder/
${TS_CASE_LOG_PATH}                /home/ute/Try/Testlog_Folder/
${BTS_ID}                          BTS_1063
${ru_type_init}                    AQQJ
${enb_index}                       0
${trunk_rolll_needed}              ${True}

${SUITE_LOG_PATH}                  /home/ute/Try/Suite_log_path
${nr_cell_type}                    nr

@{btslog_dirs}                    /opt/btslog 
${log_dir}                        /tmp/btslog2
${unexpected_active_alarm_file_path}    /home/ute/Try/unexpected_active_alarm_file_path
${unexpected_history_alarm_file_path}    /home/ute/Try/unexpected_history_alarm_file_path
${vm_addr}    10.58.239.163
${vm_username}    ute
${vm_password}    BT5l@bus3rl0g1n
# ${SCFNAME}        SCF_SBTS00.xml

&{Dcap_Server_Details} =  host=10.41.209.120  port=443  secure=True  Alias=GNB_1
...  username=dcapuser  password=dcapadmin!

&{Dcap_User_Details} =  host=10.58.239.183  port=443  username=Nemuadmin  password=nemuuser
@{Only_Gnb_custom_profile} =  cp_5g  L2Ps_Component  L2Lo_Component  L2HiRlc_Component  L2HiPdcp_Component   
@{Bts_custom_profile}=   immediateSnapshot  scf  pmFiles  ipCapture
${OUT_SUITE_LOGS_DIR_PATH} =  ${TEMP_DIR}/dcaplog 
