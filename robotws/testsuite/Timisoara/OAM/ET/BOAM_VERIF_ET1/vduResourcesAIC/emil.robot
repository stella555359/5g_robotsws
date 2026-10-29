*** Settings ***
Documentation
...   author: hongping.rao@nokia-sbell.com
...   contact: hongping.rao@nokia-sbell.com
...   emil common keyword





#*** Variables ***


*** Keywords ***
############################## Emil Log Start ##############################
====== Emil Log Start ======
     Log To Console  \n*** only used for readable ***

####################
Waiting For Dcap Ready
    [Arguments]   ${time}=${5}
    [Documentation]  Waiting dcap have enough time to make sure logs are in the same Timeslot
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  time  | No |  time required, unit is min, default is 5 |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Waiting For Dcap Ready |
    ${curr_min}   Get Current Date   result_format=%M   exclude_millis=True
    ${last_time}   evaluate    15-${curr_min}%15
#    ${last_time}   evaluate    ${time}-(15-${curr_min}%15)
    run keyword if   ${last_time}<${time}    Sleep    ${last_time}min 59sec


Check Dcap Session Status
    [Arguments]  ${setup}=${true}  ${connection}=dcap_server
    [Documentation]  check dacp session satus
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  setup | No |  setup status, default is ${true}, means vdu is connected dcap server |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check Dcap Session Status |

    ${ip_info}  Get VCU OAM Http Connection Info
    ${ip}  Set Variable   ${ip_info['addr']}
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    ${sessions}   tafssh.Execute   command=netstat -tan | grep ${DCAP_PORT}   connection=${connection}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Check IPv6 Dcap Session Status
    [Arguments]  ${setup}=${true}  ${connection}=dcap_server
    [Documentation]  check ipv6 dacp session satus
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <13-Apr-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  setup | No |  setup status, default is ${true}, means vdu is connected dcap server |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check Dcap Session Status |

    ${ip_info}  Get VCU OAM Http Connection Info
    ${ip}  Set Variable   ${ip_info['addr']}
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    ${sessions}   tafssh.Execute   command=/usr/sbin/ss -tnp | grep ${DCAP_PORT}   connection=${connection}
    #issh.Connect to   ip=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  prompt=$  alias=${connection}
    #issh.set prompt   $      alias=${connection}
    #${sessions}    issh.Execute   command=ss -tnp | grep ${DCAP_PORT}   alias=${connection}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Get Latest Trace File Name On Dcap Server
    [Arguments]  ${connection}=dcap_server
    [Documentation]  get latest trace file path on dcap server
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Trace File Name On Dcap Server |
    ${ip_info}  Get VCU OAM Http Connection Info
    ${ip}  Set Variable   ${ip_info['addr']}
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    tafssh.Execute   command=cd ${DCAP_LOG_DIR}   connection=${connection}
    ${trace_files}   tafssh.Execute   command=find ${DCAP_LOG_DIR} -name \"\*${ip}\*\" | xargs ls --sort=time -r   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    [Return]   ${trace_files[-1]}
    [Teardown]   tafssh.Disconnect   connection=${connection}


Download Newest Trace Files From Dcap Server
    [Arguments]    ${connection}=dcap_server
    [Documentation]  donwload the latest trace file from dcap server
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Trace Files From Dcap Server |
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   Get A Directory   dcap_log    log_${curr_date}
    ${trace_file}   Get Latest Trace File Name On Dcap Server
    Return From Keyword If   """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}   ${trace_file_name}   Split Path   ${trace_file}
    ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    tafssh.Download File   remote_path=${trace_file}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
    [Return]   ${local_dir}/${trace_file_name}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Covert Emil Logs to TXT
    [Arguments]   ${emil_log_file}   ${profiles}=5G Cell Trace    ${connection}=emil
    [Documentation]  Covert Emil Logs to TXT
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  emil_log_file | yes |  emil log file path |
    ...    |  connection  | No |  connection alais, default is emil |
    ...    *RETURN VALUE*
    ...    local txt file path
    ...    Example
    ...    |  Covert Emil Logs to TXT | /ute/home/temp/test.lcbin |
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${bat_file_name}  Set Variable  get_emil_${curr_date}.bat
    ${emil_txt_name}  Set Variable  Emil_${curr_date}.txt
    ${local_dir}   ${file_name}   Split Path   ${emil_log_file}
    tafssh.Connect to   hostname=${EMIL_HOST}   username=${EMIL_USER}   password=${EMIL_PASSWORD}   alias=${connection}
    tafssh.Execute   command=rm -rf \"${EMIL_PATH}/${bat_file_name}\"   connection=${connection}

    ${cmd}  catenate  start /wait Emil.exe \"${EMIL_WIN_LOG_DIR}\\\\${file_name}\"
    ...  -AutoClose -Profile SourceProfileUser.ini -ProfilePath  \"${EMIL_WIN_PATH}\\profiles\\${profiles}\"
    ...  -Variable OutPath  \"${EMIL_WIN_LOG_DIR}\\\\${emil_txt_name}\"

    OperatingSystem.Create File   path=${local_dir}/${bat_file_name}   content=${cmd}
    tafssh.Execute   command=cd \"${EMIL_LOG_DIR}\";rm -f ${emil_txt_name}   connection=${connection}   timeout=30
    tafssh.Upload File   local_path=${local_dir}/${bat_file_name}
    ...  remote_path=${EMIL_LOG_DIR}/${bat_file_name}   connection=${connection}
    tafssh.Upload File   local_path=${emil_log_file}
    ...  remote_path=${EMIL_LOG_DIR}/${file_name}   connection=${connection}
    ${cmd}   set variable   cd \"${EMIL_PATH}\";cmd.exe /c ${bat_file_name}
    log to console   ${cmd}
    ${res}=  tafssh.Execute   command=${cmd}   connection=${connection}
    log to console  ${res}
    Wait Until Keyword Succeeds   3x   15s   Emil TXT convert done
    ...   file_path=${EMIL_LOG_DIR}/${emil_txt_name}   connection=${connection}

    tafssh.Download File   remote_path=${EMIL_LOG_DIR}/${emil_txt_name}
    ...   local_path=${local_dir}/${emil_txt_name}   connection=${connection}
    File Should Exist     ${local_dir}/${emil_txt_name}
    tafssh.Execute   command=rm -rf \"${EMIL_LOG_DIR}/${bat_file_name}\"  connection=${connection}
    tafssh.Execute   command=rm -rf \"${EMIL_LOG_DIR}/${file_name}\"  connection=${connection}
    [Return]   ${local_dir}/${emil_txt_name}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Emil TXT convert done
    [Arguments]   ${file_path}   ${connection}=emil
    [Documentation]  check emil log convert to txt done
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  file_path | yes |  txt file path |
    ...    |  connection  | No |  connection alais, default is emil |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Emil TXT convert done | /ute/home/temp/test.txt |
    ${file_exist}   tafssh.File Exists   remote_path=${file_path}   connection=${connection}
    Should Be True   ${file_exist}

Check Emil Log Updated
    [Arguments]   ${pre_emil_path}  ${cur_emil_path}
    [Documentation]  check emil log updated based on different file name or file zise increased.
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by:        <19-Mar-2021>, <horao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pre_emil_path | yes |  pre emil path |
    ...    |  cur_emil_path  | yes |  cur emil path |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check Emil Log Updated | /ute/home/temp1/test1.lcbin | /ute/home/temp2/test2.lcbin |
    ${pre_size}  Get File Size   ${pre_emil_path}
    ${cur_size}  Get File Size   ${cur_emil_path}
    ${pre_dir}   ${pre_file_name}   Split Path   ${pre_emil_path}
    ${cur_dir}   ${cur_file_name}   Split Path   ${cur_emil_path}
    Should Be True   """${pre_file_name}"""!="""${cur_file_name}""" or ${cur_size}>${pre_size}

Check Emil Log Not Updated
    [Arguments]   ${pre_emil_path}  ${cur_emil_path}
    [Documentation]  check emil log not updated based on file zise not changed.
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <07-Api-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  pre_emil_path | yes |  pre emil path |
    ...    |  cur_emil_path  | yes |  cur emil path |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check Emil Log Not Updated | /ute/home/temp1/test1.lcbin | /ute/home/temp2/test2.lcbin |
    ${pre_size}  Get File Size   ${pre_emil_path}
    ${cur_size}  Get File Size   ${cur_emil_path}
    ${pre_dir}   ${pre_file_name}   Split Path   ${pre_emil_path}
    ${cur_dir}   ${cur_file_name}   Split Path   ${cur_emil_path}
    Should Be True   """${pre_file_name}"""=="""${cur_file_name}""" and ${cur_size}==${pre_size}

Check L3 Masseage In Emil Log
    [Arguments]   ${emil_log}  @{msg_list}   ${profiles}=5G Cell Trace
    [Documentation]   Check L3 Masseage In Emil Log
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   |  emil_log | Yes | emil log file path |
    ...    |  msg_list  | Yes |  L3 Message List |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | @{msg_list} |  create list | SgNBAdditionRequest | SgNBAdditionRequestAcknowledge |
    ...    | Check L3 Masseage In Emil Log | /ute/home/emil.lcbin  |  @{msg_list}  |
    ...
    [Teardown]   Run Keyword And Ignore Error  disconnect interactive connection  alias=local_ute
    File Should Exist   ${emil_log}
    ${emil_txt_log}=  Covert Emil Logs to TXT  ${emil_log}    ${profiles}
    File Should Exist   ${emil_txt_log}

    Connect To Ute Locally  alias=local_ute
    FOR  ${msg}  IN  @{msg_list}
       ${out}  issh.Execute  command=cat ${emil_txt_log}|grep ${msg}  alias=local_ute
       Should Contain  ${out}  ${msg}   ${msg} not found in emil log, please check file: ${emil_txt_log}
    END

Update VCU Cell Trace Or PCMD Status
    [Arguments]   ${para_name}  ${para_value}=true
    [Teardown]   Run Keyword And Ignore Error  cu logout
    [Documentation]   Update VCU Cell Trace Or PCMD Status
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   |  para_name | Yes | actCellTraceReport or actPCMDReport |
    ...    |  para_value  | No |  true or false, default is true |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Update VCU Cell Trace Or PCMD Status | actCellTraceReport  |  true  |
    ...
    Log To Console   Update VCU Cell Trace Or PCMD Status: ${para_name}-->${para_value}

    ${cu_scf}=    CU Backup SCF
    scf.Load Scf    file_path=${cu_scf}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get BTS ID From vDU SCF   ${cu_scf}
    ${NRBTS_MO_DN}   set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ${value}    CU Get Online Parameter Value     ${NRBTS_MO_DN}  ${para_name}
    Return From Keyword If   '''${value}'''=='''${para_value}'''
    &{status_dict}    Create Dictionary    operation_type=replace    parameter_path=/${para_name}   value=${para_value}
    @{para_list}     Create List  ${status_dict}

    CU Login
    CU Online Change Single Mo Parameters via rest    para_list=${para_list}    mo_dn=${NRBTS_MO_DN}


Enable Cell Trace Status On VCU
    [Documentation]   Enable Cell Trace Status On VCU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Enable Cell Trace Status On VCU |
    ...
    Log To Console   Enable Cell Trace Status On VCU
    Update VCU Cell Trace Or PCMD Status  actCellTraceReport  true

Disable Cell Trace Status On VCU
    [Documentation]   Disable Cell Trace Status On VCU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Disable Cell Trace Status On VCU |
    ...
    Log To Console  Disable Cell Trace Status On VCU
    Update VCU Cell Trace Or PCMD Status  actCellTraceReport  false


Disable PCMD Status On VCU
    [Documentation]   Disable PCMD Status On VCU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Disable PCMD Status On VCU |
    ...
    Log To Console  Disable PCMD Status On VCU
    Update VCU Cell Trace Or PCMD Status  actPCMDReport  false

Enable PCMD Status On VCU
    [Documentation]   Enable PCMD Status On VCU
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Enable PCMD Status On VCU |
    ...
    Log To Console  Enable PCMD Status On VCU
    Update VCU Cell Trace Or PCMD Status  actPCMDReport  true

Configure CU With Dcap Server MO
    [Arguments]   ${actPCMDReporting}=false
    [Teardown]   Run Keyword And Ignore Error  cu logout
    [Documentation]   Configure CU With Dcap Server MO
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  actPCMDReporting  | No |  true or false, default is false |
    ...
    ...    *RETURN VALUE*
    ...    cu scf file path
    ...
    ...    Example
    ...    | ${scf_path} | Configure CU With Dcap Server MO |
    ...
    ${vcu_scf}=    CU Backup SCF
    scf.Load Scf    file_path=${vcu_scf}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get BTS ID From vDU SCF   ${vcu_scf}
    ${tce_dist}   set variable   MRBTS-${mrbts_id}/MNL-1/TCEADM-1/TCE-1
    ${tce_res}  Run Keyword And Ignore Error   scf.Get_Value_From_Scf   dist_name=${tce_dist}   p_name=tceIpAddress
    ${nrmtracecu_dist}   set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ${nrmtracecu_res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU
    ${nrmtracecu_res1}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting
    ${res}=  evaluate   """${nrmtracecu_res[1].lower()}"""=="""true""" and """${nrmtracecu_res1[1].lower()}"""=="""${actPCMDReporting}"""
    Return From Keyword If  """${tce_res[1]}"""=="""${DCAP_IP}""" and ${res}
    ${tce_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/MNL-1   version
    ${nrbts_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   version

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1
    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${tce_dist}

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${nrmtracecu_dist}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCEADM
    ...  dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1   version=${tce_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRCTRLTS
    ...  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1   version=${nrbts_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCE
    ...  dist_name=${tce_dist}   version=${tce_version}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIpAddress  value=${DCAP_IP}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tcePortNumber  value=${DCAP_PORT}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRMTRACECU
    ...  dist_name=${nrmtracecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU  value=true
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting  value=${actPCMDReporting}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=cellMaxActiveUEsTraced  value=${3}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=jobType  value=TraceOnly
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=nrTceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=scope  value=allResources
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNGAPSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNRRRCSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceX2Setting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceXNSetting  value=all

    scf.Add_List_To_Scf     dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference
    ${nrRanTraceReference_dict}    Create dictionary    mcc     262
    ...   mnc  3    mncLength  2    traceId   1
    scf.Add_Item_To_List  dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference   elements=${nrRanTraceReference_dict}

    ${unique_id}   get unique id
    ${scf_with_tec}   Get A File  new_scf   newscf_with_tec_and_nrmtracecu_${unique_id}.xml
    scf.Save_Scf  file_path=${scf_with_tec}
    ${unique_id}   Get Unique Id
    CU Full Commssion By Rest   ${scf_with_tec}     TCE_SCF_${unique_id}
    log to console  Reset VDU
    VDU Rest Login
    sleep   1s
    Reset VDU By REST
    wait until keyword succeeds    15min    60s     OAM Precondition Cell Should Be Onair
    Run Keyword And Ignore Error   VDU Logout
    [Return]    ${scf_with_tec}

Configure CU With Dcap Server MO and NRRESOURCECU
    [Arguments]    ${lncell_id}=1    ${actPCMDReporting}=false
    [Teardown]   Run Keyword And Ignore Error  cu logout
    [Documentation]   Configure CU With Dcap Server MO and NRRESOURCECU
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   |  lncell_id         | Yes | 1,2,3...,default is 1 |
    ...    |  actPCMDReporting  | No |  true or false, default is false |
    ...
    ...    *RETURN VALUE*
    ...    cu scf file path
    ...
    ...    Example
    ...    | ${scf_path} | Configure CU With Dcap Server MO |
    ...
    ${vcu_scf}=    CU Backup SCF
    scf.Load Scf    file_path=${vcu_scf}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get BTS ID From vDU SCF   ${vcu_scf}
    ${tce_dist}   set variable   MRBTS-${mrbts_id}/MNL-1/TCEADM-1/TCE-1
    ${tce_res}  Run Keyword And Ignore Error   scf.Get_Value_From_Scf   dist_name=${tce_dist}   p_name=tceIpAddress
    ${nrmtracecu_dist}   set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ${nrresourcecu_dist}  set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
    ${nrmtracecu_res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU
    ${nrmtracecu_res1}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting
    ${res}=  evaluate   """${nrmtracecu_res[1].lower()}"""=="""true""" and """${nrmtracecu_res1[1].lower()}"""=="""${actPCMDReporting}"""
    #Return From Keyword If  """${tce_res[1]}"""=="""${DCAP_IP}""" and ${res}
    ${tce_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/MNL-1   version
    ${nrbts_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   version

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1
    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${tce_dist}

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${nrmtracecu_dist}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCEADM
    ...  dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1   version=${tce_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRCTRLTS
    ...  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1   version=${nrbts_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCE
    ...  dist_name=${tce_dist}   version=${tce_version}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIpAddress  value=${DCAP_IP}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tcePortNumber  value=${DCAP_PORT}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRMTRACECU
    ...  dist_name=${nrmtracecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU  value=true
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting  value=${actPCMDReporting}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=cellMaxActiveUEsTraced  value=${3}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=jobType  value=TraceOnly
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=nrTceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=scope  value=specificResources
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNGAPSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNRRRCSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceX2Setting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceXNSetting  value=all

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRRESOURCECU
    ...  dist_name=${nrresourcecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf    dist_name=${nrresourcecu_dist}  p_name=resourceDN  value=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${lncell_id}
    scf.Add_Element_To_Scf    dist_name=${nrresourcecu_dist}  p_name=typeNrCu  value=cell

    scf.Add_List_To_Scf     dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference
    ${nrRanTraceReference_dict}    Create dictionary    mcc     262
    ...   mnc  3    mncLength  2    traceId   1
    scf.Add_Item_To_List  dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference   elements=${nrRanTraceReference_dict}

    ${unique_id}   get unique id
    ${scf_with_tec}   Get A File  new_scf   newscf_with_tec_and_nrmtracecu_${unique_id}.xml
    scf.Save_Scf  file_path=${scf_with_tec}
    ${unique_id}   Get Unique Id
    CU Full Commssion By Rest   ${scf_with_tec}     TCE_SCF_${unique_id}
    log to console  Reset VDU
    VDU Rest Login
    sleep   1s
    Reset VDU By REST
    wait until keyword succeeds    15min    60s     OAM Precondition Cell Should Be Onair
    Run Keyword And Ignore Error   VDU Logout
    [Return]    ${scf_with_tec}

Configure CU With IPv6 Dcap Server MO
    [Arguments]   ${actPCMDReporting}=false
    [Teardown]   Run Keyword And Ignore Error  cu logout
    [Documentation]   Configure CU With IPv6 Dcap Server MO
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    |  actPCMDReporting  | No |  true or false, default is false |
    ...
    ...    *RETURN VALUE*
    ...    cu scf file path
    ...
    ...    Example
    ...    | ${scf_path} | Configure CU With Dcap Server MO |
    ...
    ${vcu_scf}=    CU Backup SCF
    scf.Load Scf    file_path=${vcu_scf}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get BTS ID From vDU SCF   ${vcu_scf}
    ${tce_dist}   set variable   MRBTS-${mrbts_id}/MNL-1/TCEADM-1/TCE-1
    ${tce_res}  Run Keyword And Ignore Error   scf.Get_Value_From_Scf   dist_name=${tce_dist}   p_name=tceIpAddress
    ${nrmtracecu_dist}   set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ${nrmtracecu_res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU
    ${nrmtracecu_res1}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting
    ${res}=  evaluate   """${nrmtracecu_res[1].lower()}"""=="""true""" and """${nrmtracecu_res1[1].lower()}"""=="""${actPCMDReporting}"""
    Return From Keyword If  """${tce_res[1]}"""=="""${DCAP_IPv6}""" and ${res}
    ${tce_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/MNL-1   version
    ${nrbts_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   version

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1
    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${tce_dist}

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${nrmtracecu_dist}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCEADM
    ...  dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1   version=${tce_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRCTRLTS
    ...  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1   version=${nrbts_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCE
    ...  dist_name=${tce_dist}   version=${tce_version}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIpAddress  value=${DCAP_IPv6}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tcePortNumber  value=${DCAP_PORT}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRMTRACECU
    ...  dist_name=${nrmtracecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU  value=true
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting  value=${actPCMDReporting}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=cellMaxActiveUEsTraced  value=${3}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=jobType  value=TraceOnly
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=nrTceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=scope  value=allResources
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNGAPSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNRRRCSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceX2Setting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceXNSetting  value=all

    scf.Add_List_To_Scf     dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference
    ${nrRanTraceReference_dict}    Create dictionary    mcc     262
    ...   mnc  3    mncLength  2    traceId   1
    scf.Add_Item_To_List  dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference   elements=${nrRanTraceReference_dict}

    ${unique_id}   get unique id
    ${scf_with_tec}   Get A File  new_scf   newscf_with_tec_and_nrmtracecu_${unique_id}.xml
    scf.Save_Scf  file_path=${scf_with_tec}
    ${unique_id}   Get Unique Id
    CU Full Commssion By Rest   ${scf_with_tec}     TCE_SCF_${unique_id}
    log to console  Reset VDU
    VDU Rest Login
    sleep   1s
    Reset VDU By REST
    wait until keyword succeeds    15min    60s     OAM Precondition Cell Should Be Onair
    Run Keyword And Ignore Error   VDU Logout
    [Return]    ${scf_with_tec}

Configure CU With IPv6 Dcap Server MO and NRRESOURCECU
    [Arguments]    ${lncell_id}=1    ${actPCMDReporting}=false
    [Teardown]   Run Keyword And Ignore Error  cu logout
    [Documentation]   Configure CU With IPv6 Dcap Server MO and NRRESOURCECU
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   |  lncell_id         | Yes | 1,2,3...,default is 1 |
    ...    |  actPCMDReporting  | No |  true or false, default is false |
    ...
    ...    *RETURN VALUE*
    ...    cu scf file path
    ...
    ...    Example
    ...    | ${scf_path} | Configure CU With Dcap Server MO |
    ...
    ${vcu_scf}=    CU Backup SCF
    scf.Load Scf    file_path=${vcu_scf}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get BTS ID From vDU SCF   ${vcu_scf}
    ${tce_dist}   set variable   MRBTS-${mrbts_id}/MNL-1/TCEADM-1/TCE-1
    ${tce_res}  Run Keyword And Ignore Error   scf.Get_Value_From_Scf   dist_name=${tce_dist}   p_name=tceIpAddress
    ${nrmtracecu_dist}   set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1
    ${nrresourcecu_dist}  set variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
    ${nrmtracecu_res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU
    ${nrmtracecu_res1}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf
    ...  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting
    ${res}=  evaluate   """${nrmtracecu_res[1].lower()}"""=="""true""" and """${nrmtracecu_res1[1].lower()}"""=="""${actPCMDReporting}"""
    #Return From Keyword If  """${tce_res[1]}"""=="""${DCAP_IPv6}""" and ${res}
    ${tce_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/MNL-1   version
    ${nrbts_version}   scf.Get_Mo_Attribute   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   version

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1
    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${tce_dist}

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1

    Run Keyword And Ignore Error   scf.Remove_Mo_With_Descendant_Mos
    ...   dist_name=${nrmtracecu_dist}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCEADM
    ...  dist_name=MRBTS-${mrbts_id}/MNL-1/TCEADM-1   version=${tce_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRCTRLTS
    ...  dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCTRLTS-1   version=${nrbts_version}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.mnl:TCE
    ...  dist_name=${tce_dist}   version=${tce_version}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tceIpAddress  value=${DCAP_IPv6}
    scf.Add_Element_To_Scf  dist_name=${tce_dist}   p_name=tcePortNumber  value=${DCAP_PORT}

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRMTRACECU
    ...  dist_name=${nrmtracecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actCellTraceReportingCU  value=true
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=actPCMDReporting  value=${actPCMDReporting}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=cellMaxActiveUEsTraced  value=${3}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=jobType  value=TraceOnly
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=nrTceIdentifier  value=${1}
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=scope  value=specificResources
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNGAPSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceNRRRCSetting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceX2Setting  value=all
    scf.Add_Element_To_Scf  dist_name=${nrmtracecu_dist}   p_name=traceXNSetting  value=all

    scf.Add_Object_To_Scf   class_name=com.nokia.srbts.nrbts:NRRESOURCECU
    ...  dist_name=${nrresourcecu_dist}   version=${nrbts_version}
    scf.Add_Element_To_Scf    dist_name=${nrresourcecu_dist}  p_name=resourceDN  value=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${lncell_id}
    scf.Add_Element_To_Scf    dist_name=${nrresourcecu_dist}  p_name=typeNrCu  value=cell

    scf.Add_List_To_Scf     dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference
    ${nrRanTraceReference_dict}    Create dictionary    mcc     262
    ...   mnc  3    mncLength  2    traceId   1
    scf.Add_Item_To_List  dist_name=${nrmtracecu_dist}  list_name=nrRanTraceReference   elements=${nrRanTraceReference_dict}

    ${unique_id}   get unique id
    ${scf_with_tec}   Get A File  new_scf   newscf_with_tec_and_nrmtracecu_${unique_id}.xml
    scf.Save_Scf  file_path=${scf_with_tec}
    ${unique_id}   Get Unique Id
    CU Full Commssion By Rest   ${scf_with_tec}     TCE_SCF_${unique_id}
    log to console  Reset VDU
    VDU Rest Login
    sleep   1s
    Reset VDU By REST
    wait until keyword succeeds    15min    60s     OAM Precondition Cell Should Be Onair
    Run Keyword And Ignore Error   VDU Logout
    [Return]    ${scf_with_tec}

############################## Emil Log End ##############################
====== Emil Log End ======
     Log To Console  \n*** only used for readable ***



############################## 5GC001663-G #################################3
Check TLS is disable on VDU
    [Arguments]     ${DCAP_IP}
    [Documentation]  Check TLS is disable on VDU
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DCAP_IP        | Yes  | DCAP server IP(ipv4 or ipv6)
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Check TLS is disable on VDU | ${DCAP_IP}
    Connect To K8s master
    ${cmd}  set variable   /opt/nokia/bin/dataprovidercli show
    ${out}  kubectl exec   pod_abbr=oam    container=providercontroller    command=${cmd}
    ${flag}   BuiltIn.Set Variable If   '''${DCAP_IP}''' in '''${out}'''   1   0
    run keyword if    '${flag}'=='0'    Add DCAP INFO on VDU  ${DCAP_IP}
    [Teardown]    disconnect from k8s master


Check TLS is enable on VDU
    [Arguments]     ${DCAP_IP}
    [Documentation]  Check TLS is enable on VDU
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DCAP_IP        | Yes  | DCAP server IP(ipv4 or ipv6)
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Check TLS is enable on VDU | ${DCAP_IP}
    [Teardown]    disconnect from k8s master
    wait until keyword succeeds   300    10   Repeat Check TLS status on VDU   ${DCAP_IP}


Repeat Check TLS status on VDU
    [Arguments]     ${DCAP_IP}
    [Documentation]  Repeat Check TLS status on VDU
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DCAP_IP        | Yes  | DCAP server IP(ipv4 or ipv6)
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Repeat Check TLS status on VDU | ${DCAP_IP}
    ${result}  ${out}   run keyword and ignore error   Check TLS status on VDU Once   ${DCAP_IP}
    return from keyword if  "${result}"=="PASS"
    Delete DCAP INFO on VDU   ${DCAP_IP}
    Check TLS status on VDU Once   ${DCAP_IP}


Check TLS status on VDU Once
    [Arguments]     ${DCAP_IP}
    [Documentation]  Check TLS status on VDU Once
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DCAP_IP        | Yes  | DCAP server IP(ipv4 or ipv6)
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Check TLS status on VDU Once | ${DCAP_IP}
    Connect To K8s master
    ${cmd}  set variable   /opt/nokia/bin/dataprovidercli show |grep ${DCAP_IP}
    ${out}  kubectl exec   pod_abbr=oam    container=providercontroller    command=${cmd}
    should be true    '${DCAP_IP}' not in '''${out}'''
Add DCAP INFO on VDU
    [Arguments]     ${DCAP_IP}
    [Documentation]  Add DCAP INFO on VDU
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | DCAP_IP        | Yes  | DCAP server IP(ipv4 or ipv6)
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Add DCAP INFO on VDU | ${DCAP_IP}
    ${alias}   Get Unique ID
    Connect To K8s master Interactively   alias=${alias}
    ${oam_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=oam   alias=${alias}
    ${pc_ctr_name}   Get Full Container Name By Container Abbreviation     ctr_abbr=providercontroller
    ${initial_prompt}   issh.set prompt   y/n\\s+\\?   alias=${alias}
    ${cmd_1}  set variable
    ...  kubectl exec -it ${oam_pod_name} -c ${pc_ctr_name} bash -n cran1 -- /opt/nokia/bin/dataprovidercli add -u ${DCAP_IP}
    issh.Execute     command=${cmd_1}   check_result=${False}   alias=${alias}
    issh.set prompt   ${initial_prompt}   alias=${alias}
    issh.Execute     command=y   check_result=${False}   alias=${alias}
    ${cmd_2}  set variable
    ...  kubectl exec -it ${oam_pod_name} -c ${pc_ctr_name} bash -n cran1 -- /opt/nokia/bin/dataprovidercli show
    ${out}   issh.Execute     command=${cmd_2}   check_result=${False}   alias=${alias}
    should be true   '${DCAP_IP}' in '''${out}'''


Delete DCAP INFO on VDU
    [Arguments]     ${DCAP_IP}
    [Documentation]  Delete DCAP INFO on VDU
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    |  Delete DCAP INFO on VDU |      |
    ${cmd}  set variable   /opt/nokia/bin/dataprovidercli delete -u ${DCAP_IP}
    kubectl exec   pod_abbr=oam    container=providercontroller    command=${cmd}


Enable TLS on DCAP
    [Documentation]  Enable TLS on DCAP
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Connection alias.
    ...    Example
    ...    |  Enable TLS on DCAP |      |
    ${alias}   SSH to DCAP SERVER
    ${file_path}   BuiltIn.Set Variable   /sharedvolume/flowtracer5g/config/_controller_config.txt
    issh.Execute  command=sudo sed -i "s/#*tlsServer/tlsServer/g" ${file_path}  check_result=${False}  alias=${alias}
    issh.Execute  command=sudo sed -i "s/#*tlsClient/tlsClient/g" ${file_path}  check_result=${False}  alias=${alias}
    ${out}   issh.Execute   command=cat ${file_path}   check_result=${False}  alias=${alias}
    should be true   '#tlsServer' not in '''${out}''' and '#tlsClient' not in '''${out}'''
    issh.Execute  command=docker restart FlowTracer5G   check_result=${False}  alias=${alias}
    sleep  10s
    [Teardown]   issh.disconnect   alias=${alias}


Disable TLS on DCAP
    [Documentation]  Disable TLS on DCAP
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Connection alias.
    ...    Example
    ...    |  Disable TLS on DCAP |      |
    ${alias}   SSH to DCAP SERVER
    ${file_path}   BuiltIn.Set Variable   /sharedvolume/flowtracer5g/config/_controller_config.txt
    issh.Execute  command=sudo sed -i "s/tlsServer/#tlsServer/g" ${file_path}  check_result=${False}  alias=${alias}
    issh.Execute  command=sudo sed -i "s/tlsClient/#tlsClient/g" ${file_path}  check_result=${False}  alias=${alias}
    ${out}   issh.Execute   command=cat ${file_path}  check_result=${False}  alias=${alias}
    should be true   '#tlsServer' in '''${out}''' and '#tlsClient' in '''${out}'''
    issh.Execute  command=docker restart FlowTracer5G   check_result=${False}  alias=${alias}
    sleep  10s
    [Teardown]   issh.disconnect   alias=${alias}


SSH to DCAP SERVER
    [Documentation]  SSH to DCAP SERVER
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <30-6-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    Connection alias.
    ...    Example
    ...    |  SSH To DCAP SERVER |      |
    ${alias}=  Get Unique ID
#   tafssh.Connect to   hostname=${DCAP_IP}   username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${alias}
    issh.Connect To   ip=${DCAP_IP}   username=${DCAP_USER}   password=${DCAP_PASSWORD}  prompt=\\$  alias=${alias}
    [Return]   ${alias}


Create provider Controller
    [Arguments]    ${provider_name}   ${provider_addr}
    [Documentation]  Create provider Controller
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <2-7-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  provider_addr  | Yes | oam container tcplane ip |
    ...    |  provider_name | Yes|  the name for provider controller,suggest keep same with provider_addr |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Create provider Controller | provider_name=${tcplane_ip} | provider_addr=${tcplane_ip}
    ${alias}   SSH to DCAP SERVER
    ${cmd_1}   BuiltIn.Set Variable   docker exec -it FlowTracer5G bash
    issh.Execute  command=${cmd_1}  check_result=${False}  alias=${alias}
    ${provider_addr_new}   BuiltIn.Set Variable If   ''':''' in '''${provider_addr}'''   [${provider_addr}]   ${provider_addr}
    ${cmd_2}   BuiltIn.Set Variable   ./fcmd 127.0.0.1:55001 cp ${provider_name} ${provider_addr_new}:51274
    issh.Execute  command=${cmd_2}  check_result=${False}  alias=${alias}
    sleep   10s
#   ${cmd_3}   BuiltIn.Set Variable   ./fcmd 127.0.0.1:55001 gp ${provider_name} | grep state
    ${cmd_3}   BuiltIn.Set Variable   ./fcmd 127.0.0.1:55001 gp ${provider_name}
    ${out}   issh.Execute  command=${cmd_3}  check_result=${False}  alias=${alias}
    Should be true   'HANDSHAKE_COMPLETED' in '''${out}'''
    [Teardown]   issh.disconnect   alias=${alias}


Delete Provider Controller
    [Arguments]    ${provider_name}
    [Documentation]  Delete provider Controller
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    modified by:        <2-7-2021>, <lingzhao>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  provider_name | Yes | the name for provider controller  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Delete provider Controller | provider_name=${tcplane_ip}
    ${alias}   SSH to DCAP SERVER
    ${cmd_1}   BuiltIn.Set Variable   docker exec -it FlowTracer5G bash
    issh.Execute  command=${cmd_1}  check_result=${False}  alias=${alias}
    ${cmd_2}   BuiltIn.Set Variable   ./fcmd 127.0.0.1:55001 dp ${provider_name}
    issh.Execute  command=${cmd_2}  check_result=${False}  alias=${alias}
    ${cmd_3}   BuiltIn.Set Variable   ./fcmd 127.0.0.1:55001 gp
    ${out}   issh.Execute  command=${cmd_3}  check_result=${False}  alias=${alias}
    Should be true   '${provider_name}' not in '''${out}'''
    [Teardown]   issh.disconnect   alias=${alias}

Create Monitor Session
    [Arguments]    ${monitor_name}   ${provider_name}
    [Documentation]  Create monitor session
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-7-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  monitor_name  | Yes | monotor session name |
    ...    |  provider_addr  | Yes | oam container tcplane ip |
    ...    |  provider_name | Yes|  the name for provider controller,suggest keep same with provider_addr |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Create Monitor Session | monitor_name=${monitor_name}|provider_name=${tcplane_ip}

    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    ${cmd_1}   BuiltIn.Set Variable   docker exec FlowTracer5G ./fcmd 127.0.0.1:55001 gp ${provider_name}
    ${cmd_2}   BuiltIn.Set Variable   |grep sourceName|awk '{print$4}'
    tafssh.Execute   command=${cmd_1}${cmd_2}   connection=${connection}
    ${result}   tafssh.Execute   command=${cmd_1}${cmd_2}   connection=${connection}
    ${out}   Split String  ${result}   \r\n
    ${sourceName}   Set Variable   ${out[0]}
    Log To Console   ${sourceName}
    ${cmd_3}   BuiltIn.Set Variable   docker exec FlowTracer5G ./fcmd 127.0.0.1:55001 gp ${provider_name}
    ${cmd_4}   BuiltIn.Set Variable   |awk '{a[NR]=$0;if(a[NR-1]~/detailedSourceList/){print a[NR]}}' |awk '{print $NF}'
    ${result}  tafssh.Execute  command=${cmd_3}${cmd_4}  connection=${connection}
    ${sourceList}   Split String  ${result}   \r\n
    Log To Console   ${sourceList}

    Prepare filter files  cprt_pod=${sourceList[0]}

    ${cmd_5}   BuiltIn.Set Variable  docker exec FlowTracer5G ./fcmd 127.0.0.1:55001 cm n=${monitor_name}
    ${cmd_6}   BuiltIn.Set Variable  p=${provider_name} d=DataCollector@10.110.95.16:55000
    ${cmd_7}   BuiltIn.Set Variable  m=[f5c:@ext/config/5gfilter.txt][su:${sourceList[0]}][gnb:${sourceName}]
    ${cmd_8}   BuiltIn.Set Variable  m=[f5s:@ext/config/TraceFilter.txt][sh:${sourceList[0]},${sourceList[1]},${sourceList[2]},${sourceList[3]}]
    ${cmd_9}   BuiltIn.Set Variable  [gnb:${sourceName}] pl=[n:flowdiskwriter][c:@ext/config/_diskwriter.txt][s:1]
    ${cmd_10}   BuiltIn.Set Variable  pl=[n:emilforwarder][c:@ext/config/_emilforwarder.txt][s:1]
    ${cmd_create}   BuiltIn.Set Variable  ${cmd_5} ${cmd_6} ${cmd_7} ${cmd_8}${cmd_9} ${cmd_10}

    Log To Console   ${cmd_create}
    ${out}   tafssh.Execute  command=${cmd_create}   connection=${connection}
    Should contain   ${out}   success
    [Teardown]   tafssh.disconnect   connection=${connection}

Prepare filter files
    [Arguments]   ${cprt_pod}
    [Documentation]  prepare TraceFilter.txt and 5gfilter.txt used for monitor session creation
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-7-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  cprt_pod  | Yes | CPRT pod name |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Prepare filter files|  cprt_pod=${sourceList[0]}
    Return From Keyword If  """${TRANS_PARA}"""=="""${NONE}"""
    ${result}  ${tools_repository}    Run Keyword And Ignore Error   Set Variable  ${TRANS_PARA["tools_repository"]}
    Return From Keyword If  """${result}"""=="""FAIL"""
    ${alias}   Get Unique ID
    issh.Connect to   ip=${DCAP_IP}   username=${DCAP_USER}   password=${DCAP_PASSWORD}  prompt=\\$  alias=${alias}

    ${remote_ip}   set variable    ${tools_repository["ip"]}
    ${username}   set variable    ${tools_repository["username"]}
    ${password}   set variable   ${tools_repository["password"]}
    ${remote_folder}  set variable   ${tools_repository["repo_data_folder"]}
    ${Tracefilter_remote_path}   OperatingSystem.Join Path   ${remote_folder}  TraceFilter.txt
    ${local_folder}  Set Variable  /sharedvolume/flowtracer5g/config

    ${cmd}   set variable   scp -r -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${cmd}   set variable  ${cmd} ${username}@${remote_ip}:${Tracefilter_remote_path} ${local_folder}
    ${old_prompt}  issh.Set Prompt   assword:     alias=${alias}
    ${out}   issh.Execute   command=${cmd}    check_result=${False}   alias=${alias}
    ${out}   issh.Set Prompt   ${old_prompt}     alias=${alias}
    ${out}   issh.Execute   command=${password}    check_result=${False}   alias=${alias}

    ${5gfilter_remote_path}   OperatingSystem.Join Path   ${remote_folder}  5gfilter.txt
    ${cmd}   set variable   scp -r -o BatchMode=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
    ${cmd}   set variable  ${cmd} ${username}@${remote_ip}:${5gfilter_remote_path} ${local_folder}
    ${old_prompt}  issh.Set Prompt   assword:     alias=${alias}
    ${out}   issh.Execute   command=${cmd}    check_result=${False}   alias=${alias}
    ${out}   issh.Set Prompt   ${old_prompt}     alias=${alias}
    ${out}   issh.Execute   command=${password}    check_result=${False}   alias=${alias}

    ${Tracefilter_path}   OperatingSystem.Join Path   ${local_folder}  TraceFilter.txt
    ${cmd}    BuiltIn.Set Variable  sudo sed -i "s/cprt-pod-name/${cprt_pod}/g" ${Tracefilter_path}
    issh.Execute  command=${cmd}   check_result=${False}   alias=${alias}


Delete Monitor Session
    [Arguments]    ${monitor_name}
    [Documentation]  Delete monitor session
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-7-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  monitor_name  | Yes | monotor session name |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Delete Monitor Session| monitor_name=${monitor_name}

    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    ${cmd}   BuiltIn.Set Variable   docker exec FlowTracer5G ./fcmd 127.0.0.1:55001 dm ${monitor_name}
    tafssh.Execute   command=${cmd}  connection=${connection}

    ${cmd}   BuiltIn.Set Variable   docker exec FlowTracer5G ./fcmd 127.0.0.1:55001 gm
    ${out}   tafssh.Execute   command=${cmd}  connection=${connection}
    Should not contain    ${out}   ${monitor_name}


Get Latest Cplane Trace File Name On Dcap Server
    [Arguments]  ${connection}=dcap_server
    [Documentation]  get latest cplane trace file path on dcap server
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <12-7-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Trace File Name On Dcap Server |
    ${MRBTS_ID}  Get vDU SourceName
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    tafssh.Execute   command=cd ${DCAP_CP_LOG_DIR}   connection=${connection}
    ${trace_files}   tafssh.Execute   command=find ${DCAP_CP_LOG_DIR} -name \"\*${MRBTS_ID.strip()}\*\"|xargs ls --sort=time -r
    ...   connection=${connection}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    Log To Console   ${trace_files}
    [Return]   ${trace_files[-1]}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Download Newest Cplane Trace Files From Dcap Server
    [Arguments]    ${connection}=dcap_server
    [Documentation]  donwload the latest trace file from dcap server
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <13-July-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Trace Files From Dcap Server |
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   Get A Directory   dcap_log    log_${curr_date}
    ${trace_file}   Get Latest Cplane Trace File Name On Dcap Server
    Return From Keyword If   """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}   ${trace_file_name}   Split Path   ${trace_file}
    ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
    tafssh.Connect to   hostname=${DCAP_IP}  username=${DCAP_USER}  password=${DCAP_PASSWORD}  alias=${connection}
    tafssh.Download File   remote_path=${trace_file}   local_path=${local_dir}/${trace_file_name}   connection=${connection}
    [Return]   ${local_dir}/${trace_file_name}
    [Teardown]   tafssh.Disconnect   connection=${connection}

Get vDU SourceName
    [Arguments]
    [Documentation]  donwload the latest trace file from dcap server
    ...    author: lijuan.1.wang@nokia-sbell.com
    ...    modified by:        <13-July-2021>, <lijuwang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Source name of vDU
    ...    Example
    ...    | Get vDU SourceName |
    Connect To K8s master
    ${cmd}  set variable    /opt/nokia/bin/dataprovidercli show| grep "CPRT" |awk -F ':' '{print$5}'
    ${Source_Name}  Kubectl Exec    pod_abbr=oam    container=providercontroller   command=${cmd}
    [Return]   ${Source_Name}




