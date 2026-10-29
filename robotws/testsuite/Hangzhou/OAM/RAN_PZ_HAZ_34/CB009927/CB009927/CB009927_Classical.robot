*** Settings ***
Resource   ../Resource/Common.robot

Suite Setup   Common Suite Setup
Suite Teardown   Common Suite Teardown


*** Variables ***
${TESTLINE_TYPE}   CLASSICAL
${ue_index}   ${0}

&{bts_classical}
...   host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}
...   password=${tl.gnbs[0].cu.oam_http_connection_details.password}
...   port=443
${emil_host}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
${emil_user}   ${tl.ues[${ue_index}].ssh_connection_details.username}
${emil_password}   ${tl.ues[${ue_index}].ssh_connection_details.password}


*** Test Cases ***
CB009927_SR_A_Inclusion_of_data_decoders_into_BTS_build
    [Setup]   robot_common_operations.Common Case Setup
    Log To Console   ${EMPTY}

    coam.download_sack_file   output_file_name=${OUTPUT_DIR}/result_sack.zip   connection=COAM
    OperatingSystem.File Should Not Be Empty   path=${OUTPUT_DIR}/result_sack.zip


    Connect To DCAP Basic WEB
    Create BTS On DCAP Basic WEB   bts_dict=${bts_classical}
    ${result_id}   Start Trace On DCAP Basic WEB   bts_dict=${bts_classical}
    Sleep   10s

    # L3 CALL
    Run Keyword And Ignore Error   CB009927 L3 Call

    ${downloaded_emil_file_path}   Stop Trace On DCAP Basic WEB   result_id=${result_id}
    # ${emil_log_file_list}   ${sack_file_list}   Exact Dcap log   downloaded_emil_file_path=${downloaded_emil_file_path}

    # Upload IDA File To EMIL Server
    # ...   sack_file_list=${sack_file_list}
    # ...   emil_host=${emil_host}
    # ...   emil_user=${emil_user}
    # ...   emil_password=${emil_password}

    # ${emil_txt_file}   Covert Emil Logs to TXT
    # ...   file_list=${emil_log_file_list}
    # ...   emil_host=${emil_host}
    # ...   emil_user=${emil_user}
    # ...   emil_password=${emil_password}

    # ${output}   OperatingSystem.Run   cat ${emil_txt_file} | grep TRACE_CONTROLLER_NR_APP
    # Should Contain   ${output}   TRACE_CONTROLLER_NR_APP


*** Keywords ***
Common Suite Setup
    Common Setup Classical
    Remove And Add PCMD Object


Common Suite Teardown
    Common Teardown Classical
