*** Keywords ***
Auto_Analyze_Error
    [Arguments]    ${filter_syslog}    ${status}=${FILTER_SYSLOG_STATUS}
    #Run Keyword And Ignore Error    Auto_Analyze_Check_Gnb_Container
    #Run Keyword If    "${status}"=="${TRUE}"    Check Syslog All Crash Error    ${filter_syslog}
    Run    cat ${filter_syslog}
    Run Keyword If    "${status}"=="${TRUE}"    Check Syslog L2 Crash Error    ${filter_syslog}
    Run Keyword If    "${status}"=="${TRUE}"    Check Syslog L1bypass Interface Error    ${filter_syslog}

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

Check Syslog L1bypass Interface Error
    [Arguments]    ${output_file}
    ${cmd}=    Set Variable    egrep "Cell Setup failure, it is not in test mode" ${output_file}
    ${rc}    ${output_L1bypass}=     OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${fail_msg}=    Set Variable    DCI interface mismatch between gnb and airphone!!!
    Run Keyword If    """${output_L1bypass}"""!="${EMPTY}"    Log     ${fail_msg}    ERROR
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    cat /ffs/run/swconfig.txt|egrep '0x590000|0x5800BA'
    ${rc}    ${output}=    Run And Return Rc And Output     ${cmd}
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1
    ...    cat /ffs/run/swconfig.txt|egrep '0x70649|0x70005'
    ${rc}    ${output}=    Run And Return Rc And Output     ${cmd}
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1
    ...    head -n 20 /tmp/APL3.log 2>/dev/null|grep "ItfL1 release"
    ${rc}    ${output}=    Run And Return Rc And Output     ${cmd}
    ${cmd_ABIL}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 0:1 cat /tmp/node_CPRT00/tmp/startup_cp_rt.log|grep "test mode"
    ${cmd_ABIO}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 0:0 cat /tmp/node_CPRT00/tmp/startup_cp_rt.log|grep "test mode"
    ${rc}    ${output}=    Run And Return Rc And Output     ${cmd}