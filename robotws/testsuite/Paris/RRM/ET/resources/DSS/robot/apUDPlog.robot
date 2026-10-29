*** Settings ***

Documentation     Keywords for AP UDP Syslog Traces

Library     ute_syslog

*** Keywords ***

Start To Capture Iphy Udplog
  [Arguments]     ${tag}=${EMPTY}    ${target_dir}=None
  ${if_no_skip_capture}=    get variable value   ${W_AP_UDPLOG}     False
  ${if_skip_capture}=    Set Variable If     '${if_no_skip_capture}'=='True'         ${False}
  ...                                                                                ${True}
  Return From Keyword If  ${if_skip_capture} is ${True}
  ${iphylog_name}  Set Variable If  'startup' in '${tag}' or ${tag.__len__()}==0   ap_udplog.LOG
  ...                                                                              ap_udplog_${tag}.LOG
  ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    Get Testcase Log Directory
    ...                 ELSE                                     Set Variable    ${target_dir}
  ${iphylog_dir}  Set Variable If  'startup' in '${tag}'  ${target_dir}/${tag}_logs
  ...                                                     ${target_dir}
  Run Keyword And Ignore Error  ute_syslog.Start Syslog  ${iphylog_dir}  ${iphylog_name}   192.168.200.126
  ...                                                    file_limit=209715200  # 200MB
  ...                                                    add_line_number=True
  ...                                                    alias=iphy1


Stop Capture Iphy Udplog
  [Arguments]     ${target_dir}=None
  BuiltIn.log    target_dir=${target_dir}
  ${if_no_skip_capture}=    get variable value   ${W_AP_UDPLOG}     False
  ${if_skip_capture}=       Set Variable If     '${if_no_skip_capture}'=='True'         ${False}
  ...                                                                                   ${True}
  Return From Keyword If  ${if_skip_capture} is ${True}
  ${ERR_SmUeContext_iphy1_message_num}=        ute_syslog.Count Syslog messages    regexp=ERR/SmUeContext.cpp    alias=iphy1
  ${ERR_l1_application_iphy1_message_num}=     ute_syslog.Count Syslog messages    regexp=ERR/l1_application    alias=iphy1
  ${msg}=     Catenate     [INFO] ERR_SmUeContext_iphy1_message_num=${ERR_SmUeContext_iphy1_message_num} (ERR/SmUeContext.cpp not present
  ...                             in UDP syslog iphy1)
  run Keyword if     ${ERR_SmUeContext_iphy1_message_num} > ${0}
  ...             BuiltIn.Log   ERR_SmUeContext_iphy1_message_num=${ERR_SmUeContext_iphy1_message_num} present (check UDP syslog iphy1)   level=WARN
  ...    ELSE     BuiltIn.Log   ${msg}     level=INFO      console=True
  Run Keyword And Ignore Error  ute_syslog.collect_syslog_results    unzip=${FALSE}    alias=iphy1
  Run Keyword And Ignore Error  ute_syslog.teardown_all_aliases_for_syslog

