*** Settings ***
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/basic_variable.py

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${if_commissioning}   True
${if_teardown_commissioning}   True
${if_pdl_check}       True
${if_update_swconfig}      False
${save_snapshot}      True

${testline_name}      null
${CONFIGURATION}      null
${target_old_version}      null
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog      none

# RU log
${ru_runtime_zip}     1011_runtime.zip
${ru_runtime_xz}      runtime_DEFAULT.log.xz
${ru_runtime_log}     runtime_DEFAULT.log
${ru_runtime_tar}     1011_ccsrt-runtime.tar.gz
${TS_LOG_PATH_BASE}   ${OUTPUT DIR}
${scf_relative_dir}      commissionings${/}HGZ

#ssh vm
${vm_addr}          ${tl.test_pc.default_ssh_connection_details.addr}
${vm_username}      ${tl.test_pc.default_ssh_connection_details.username}
${vm_password}      ${tl.test_pc.default_ssh_connection_details.password}
