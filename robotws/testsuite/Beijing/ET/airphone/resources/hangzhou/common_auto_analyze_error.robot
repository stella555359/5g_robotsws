*** Keywords ***
Auto_Analyze_Error
    [Arguments]    ${filter_syslog}    ${status}=${FILTER_SYSLOG_STATUS}
    #Run Keyword And Ignore Error    Auto_Analyze_Check_Gnb_Container
    Run    cat ${filter_syslog}
    Run Keyword If    "${status}"=="${TRUE}"    Check Syslog All Crash Error    ${filter_syslog}
    #Run Keyword If    "${status}"=="${TRUE}"    Check Syslog L2 Crash Error    ${filter_syslog}

Auto_Analyze_Check_Gnb_Container
    Get Base Band Board Type
    Run Keyword If    "${ASP_BOARD_TYPE}"=="ABIO"    Auto_Analyze_Check_Gnb_Container_ABIO
    Run Keyword If    "${ASP_BOARD_TYPE}"=="ABIL"    Auto_Analyze_Check_Gnb_Container_ABIL

Auto_Analyze_Check_Gnb_Container_ABIO
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:0 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:0 ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:0 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:0 ls -al /tmp/ |grep node

Auto_Analyze_Check_Gnb_Container_ABIL
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:0 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:0 ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:1 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 1:1 ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:0 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:0 ls -al /tmp/ |grep node
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:1 lxc-ls
    ${rc}    ${output}=    Run And Return Rc And Output    ${SSH_CMD} bsh 2:1 ls -al /tmp/ |grep node

Check Syslog All Crash Error
    [Arguments]    ${output_file}
    ${cmd}=    Set Variable    egrep "CCSRT ERR: NEW -=-= CC&S Error Handler exception report =-=-" ${output_file}
    ${rc}    ${output_crash}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${crash_fail_msg}=    Set Variable    WRN:Crash error happened!!! Do report PR!!!
    Run Keyword If    """${output_crash}"""!="${EMPTY}"    Collect GNB SnapShot Via AaShell    log_dir=${OUTPUT_DIR}/crash_snapshot/
    Run Keyword If    """${output_crash}"""!="${EMPTY}"    Fail     msg=${crash_fail_msg}

Check Syslog L2 Crash Error
    [Arguments]    ${output_file}
    ${cmd}=    Set Variable    egrep "CCSRT ERR: NEW -=-= CC&S Error Handler exception report =-=-" ${output_file}
    ${rc}    ${output_crash}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Set Variable    egrep "CCSRT ERR: .*?/opt/lib/lib5gl2lo.so" ${output_file}
    ${rc}    ${output_crash_L2lo}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Set Variable    egrep "CCSRT ERR: .*?/opt/lib/lib5gl2ps.so" ${output_file}
    ${rc}    ${output_crash_L2ps}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${cmd}=    Set Variable    egrep "CCSRT ERR: .*?/opt/lib/lib5gl2hi.so" ${output_file}
    ${rc}    ${output_crash_L2hi}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${crash_fail_msg}=    Set Variable    WRN:Crash happened!!! Do report PR!!!
    ${crash_fail_msg_L2lo}=    Set Variable    WRN:L2lo Crash happened!!! Do report PR to L2 team!!!
    ${crash_fail_msg_L2ps}=    Set Variable    WRN:L2ps Crash happened!!! Do report PR to L2 team!!!
    ${crash_fail_msg_L2hi}=    Set Variable    WRN:L2hi Crash happened!!! Do report PR to L2 team!!!
    Run Keyword If    """${output_crash}"""!="${EMPTY}"    Collect GNB SnapShot Via AaShell    log_dir=${OUTPUT_DIR}/crash_snapshot/
    Run Keyword If    """${output_crash}"""!="${EMPTY}" and """${output_crash_L2lo}"""!="${EMPTY}"    Fail     msg=${crash_fail_msg_L2lo}
    Run Keyword If    """${output_crash}"""!="${EMPTY}" and """${output_crash_L2ps}"""!="${EMPTY}"    Fail     msg=${crash_fail_msg_L2ps}
    Run Keyword If    """${output_crash}"""!="${EMPTY}" and """${output_crash_L2hi}"""!="${EMPTY}"    Fail     msg=${crash_fail_msg_L2hi}
    #Run Keyword If    """${output_crash}"""!="${EMPTY}"    Fail     msg=${crash_fail_msg}
    Run Keyword If    """${output_crash}"""!="${EMPTY}"    Log     ${crash_fail_msg}    ERROR
