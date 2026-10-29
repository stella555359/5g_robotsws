*** Settings ***
Documentation    Only variables


*** Variables ***
${local_syslog_path}        \tmp\btslog2\btslog
${cell_id}                ${EMPTY}
${save_snapshot}                    ${False}
${testline_name}                    7_2_RJIO1061
${cur_relative_dir}                 /home/ute/Try
${scf_relative_dir}                 /home/ute/Try
${scf_path}                         /home/ute/robotws/testsuite/Bangalore/RRM/T02/CSV_RJIO_Testing/SCF
${Test_log_path_base}               /home/ute/Testlogs/${testline_name}
${Test_log_path}                   ${Test_log_path_base}
${BTS_ID}                          BTS_1063
${ru_type_init}                    AQQJ
${enb_index}                       0
${trunk_rolll_needed}              ${True}
${SUITE_LOG_PATH}                  ${Test_log_path_base}
${nr_cell_type}                    nr
@{btslog_dirs}                    /tmp/btslog2
${log_dir}                        /tmp/btslog2
${unexpected_active_alarm_file_path}     ${Test_log_path_base}/unexpected_active_alarm_file_path
${unexpected_history_alarm_file_path}    ${Test_log_path_base}/unexpected_history_alarm_file_path
${vm_addr}    10.58.239.163
${vm_username}    ute
${vm_password}    BT5l@bus3rl0g1n
&{Dcap_Server_Details} =  host=10.41.209.120  port=443  secure=True  Alias=GNB_1
...  username=dcapuser  password=dcapadmin!
&{Dcap_User_Details} =  host=10.58.239.183  port=443  username=Nemuadmin  password=nemuuser
@{Only_Gnb_custom_profile} =  cp_5g  L2Ps_Component  L2Lo_Component  L2HiRlc_Component  L2HiPdcp_Component
@{Bts_custom_profile}=   immediateSnapshot  scf  pmFiles  ipCapture
${OUT_SUITE_LOGS_DIR_PATH} =  ${TEMP_DIR}/dcaplog
${Syslog_operation_path}=     /opt/btslog
${RP_CA}=                     VRF_RRM
${RP_QC_DOMAIN}=              MN_RAN
${qc_project_vrf}=            RAN_VRF
${qc_project_st}=             RAN_ST
${RP_RU_TYPE}                 1AHPB+1AHPJ+3AQQJ
${RP_HW_ID}                   1ASOE++1AHPB+1AHPJ+3AQQJ
${RP_TDD_FDD_VARIANT}         FDD+TDD
${RP_LOCATION}    VRF_BLR1
@{RP_Customer}    Reliance India
${RP_organization}         VRF_BLR1_T02
${MCG_host_ip}=            10.45.150.192
${MCG_host_username}=        inbabtslabuser
${MCG_host_password}=        BT5l@bus3rl0g1n
${cellid_0}=           0
${cellid_1}=           1
${cellid_2}=           2
${cellid_3}=           3
${nrpgrp_id_0}=        0
${nrpgrp_id_1}=        1
${nrpgrp_id_2}=        2
${eqm_apeqm_path}=        EQM-1/APEQM-1
${rmod_1}=        RMOD-1
${rmod_2}=        RMOD-2
${rmod_3}=        RMOD-3
@{COMMON_SW_DOWNLOAD_PATH}    /home/ute/uuf_netact    /home/ute/swbuilddownloadpath
