*** Settings ***
Documentation
...    author: Han Ruiyu
...    contact: ruiyu.han@nokia-sbell.com
...    squad group: NSB MN 5G&SC 5G Pz Verf CN 07 SG
Library     Emil_processing_keywords.py
Variables   msg_name_vars.py
Library            OperatingSystem
Library   String

*** Variables ***
${emil_log_path}       C:\\Emil_logs\\
${end_file}=           ${NONE}
${Protocal}=           ${NONE}

*** Keywords ***
Check SA Msg in the Log
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{sa_msgs}
        Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END
    Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-UE']}    txt_output_path=${log_path}
    Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-IF']}    txt_output_path=${log_path}
     [Teardown]

Check NSA Msg in the Log
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{nsa_msgs}
        Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END
    Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-UE']}    txt_output_path=${log_path}
    Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-IF']}    txt_output_path=${log_path}
     [Teardown]

Check Xn Msg in the Log
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{xn_msgs}
        Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END
     [Teardown]

Check Zmq Msg in the Log
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{zmq_msgs}
       run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check Zmq Msg in the Log 5752
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{zmq_msgs_5752}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END


Check XPIF Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{xpif_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check CP-NRT Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{cpnrt_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check CP-RT Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{cprt_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check CP-RT Syscom messages 5752
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{cprt_msgs_5752}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check CP-UE Syscom messages
    [Arguments]    ${log_path}
#    :FOR   ${msg}   IN   @{cpue_msgs}
#        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
#    END
     Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-UE']}    txt_output_path=${log_path}

Check CP-IF Syscom messages
    [Arguments]    ${log_path}
#    :FOR   ${msg}   IN   @{cpif_msgs}
#        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
#    END
     Check Syscom Msg Name Existing in the Log   msg_name=${nodeinfo['CP-IF']}    txt_output_path=${log_path}

Check CP-CELL Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{cpcell_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check CP-NB Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{cpnb_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check COAM Syscom messages
    [Arguments]    ${log_path}
    FOR   ${msg}   IN   @{coam_msgs}
        run keyword and continue on failure    Check Msg Name Existing in the Log   msg_name=${msg}    txt_output_path=${log_path}
    END

Check Several Component Syscom messages
    ${output_txt}    Run    cd ${emil_log_path}&dir /b /o:n /a:a *.txt
    ${output_txt}    Strip string    ${output_txt}
    ${txt_output_path}    Join Path     ${emil_log_path}   ${output_txt}
    set suite variable    ${txt_output_path}
    FOR   ${msg}   IN   @{several_msgs}
        Check Msg Name Existing in the Log   msg_name=${msg}
    END

Check Param Name Existing Sample
     ${txt_output_path}    output_emil_log_info_to_txt    log_path=${emil_log_path}    end_file=${end_file}
     set suite variable    ${txt_output_path}
     Check Msg Parameter Existing in the Log    msg_name=CpIfRequest    msg_param=GnbDuId

Check Param Value Correct Sample
     ${txt_output_path}    output_emil_log_info_to_txt    log_path=${emil_log_path}    end_file=${end_file}
     set suite variable    ${txt_output_path}
     Check Msg Parameter Value Correct in the Log    msg_name=CpIfRequest    msg_param=GnbDuId     msg_value=0${SPACE}(0x00)


Check Msg Name Existing in the Log
     [Arguments]    ${msg_name}    ${txt_output_path}=${OUTPUT_DIR}
    check_emil_msg_name_existing    file_path=${txt_output_path}    msg_name=${msg_name}

Check Syscom Msg Name Existing in the Log
    #For syscom msgs checked by nodeids which may be with case sensitivity
    [Arguments]    ${msg_name}    ${txt_output_path}=${OUTPUT_DIR}
    check_emil_syscom_msg_name_existing    file_path=${txt_output_path}    msg_name=${msg_name}

Check Msg Parameter Existing in the Log
     [Arguments]    ${msg_name}    ${msg_param}    ${txt_output_path}=${OUTPUT_DIR}
    check_emil_msg_param_existing    file_path=${txt_output_path}    msg_name=${msg_name}    msg_param=${msg_param}

Check Msg Parameter Value Correct in the Log
     [Arguments]    ${msg_name}    ${msg_param}    ${msg_value}    ${txt_output_path}=${OUTPUT_DIR}
    ${output_value}    get_emil_msg_parameter_value    ${txt_output_path}    ${msg_name}    ${msg_param}
    should be equal   ${output_value}   ${msg_value}


Check Msg BoardCPU Existing in the Log
     [Arguments]    ${boardcpu}     ${txt_output_path}=${OUTPUT_DIR}
    check_emil_msg_data_existing    file_path=${txt_output_path}    boardcpu=${boardcpu}
