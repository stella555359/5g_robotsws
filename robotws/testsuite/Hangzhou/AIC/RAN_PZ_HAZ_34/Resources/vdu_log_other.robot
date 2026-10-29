*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_log_other.robot



*** Variables ***



*** Keywords ***
######## Bip Keywords #########
_Online Add DCAP Server Route On TNL-3
    [Arguments]    ${destIpAddr}  ${ip_type}=ipv4
    [Documentation]  _Online Add DCAP Server Route On TNL-3
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:        <24-Dec-2021>, <lingtsun>, <Initial creation>
    ...    modified by:        <09-Nov-2022>, <huilxu>, <add ip_type as a parameter>
    ...    | Input Parameters | Man. | Description |
    ...    |  destIpAddr        | Yes   |  the ip of Dcap server |
    ...    |  ip_type        | No   |  ip type,  ipv4 in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  _Online Add DCAP Server Route On TNL-3 |  10.107.169.16  |
    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    set test variable    ${mrbts_id}
    set test variable    ${nrbts_id}
    set test variable    ${scf_full_path}
    ${route_name}  Set Variable If  "${ip_type}"=="ipv4"  IPRT  IPRTV6
    ${dist}   set variable    MRBTS-${mrbts_id}/TNLSVC-1/TNL-3/IPNO-1/${route_name}-1
    ${add_route}   ${gateway}=   _Check Dcap Server Route Exist  ${scf_full_path}  ${destIpAddr}    ${dist}  ${ip_type}
    ${PrefixLength}  Set Variable If  "${ip_type}"=="ipv4"  32  128
    run keyword if  "${add_route}"=="PASS"  run keywords  log to console   Route to DCAP server is needed, add the route
    ...   AND  Vdu Add Route  ${dist}    ${destIpAddr}  ${PrefixLength}  ${gateway}

_Check Dcap Server Route Exist
    [Arguments]    ${scf_path}  ${destIpAddr}    ${dist}  ${ip_type}=ipv4
    scf.Load Scf   ${scf_path}
    ${route_dstip_name}  Set Variable If  "${ip_type}"=="ipv4"  destIpAddr  destIpv6Addr
    ${route_gateway_name}  Set Variable If  "${ip_type}"=="ipv4"  gateway   gatewayIpv6Addr
    ${res}  ${dest_ip}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_dstip_name}
    ${res}  ${gateway}   Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_gateway_name}
    ${ret_gateway}  Set Variable If  "${gateway}"!="[]"  ${gateway[0]}  ${EMPTY}
    ${res}  ${out}  Run Keyword And Ignore Error   Should Not Contain Match   ${dest_ip}    ${destIpAddr}
    [return]    ${res}    ${ret_gateway}


_Delete Temporary Files
    [Teardown]    run keywords    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ...    AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_root}
    [Documentation]   _Delete Core Dump Files
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Delete Temporary Files |
    ...
    ${alias}  get unique id
    connect to k8s master interactively  alias=${alias}

    #delete tmp folder
    ${ns}  get vdu namespace from testline
    ${cu_ns}   Get CU Namespace From TestLine
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}_${cu_ns}
    ${out}   issh.Execute  command=sudo chmod 777 -R ${tmp_foler_name}   check_result=False  alias=${alias}
    ${out}   Run Keyword If   ${ns.__len__()}>0 and ${cu_ns.__len__()}>0
    ...   issh.Execute   command=sudo rm -rf ${tmp_foler_name}   alias=${alias}


Delete Uplane Trace File On Dcap Server For Certain vDU Site
    [Arguments]    ${ip}
    [Documentation]  Delete Uplane Trace File On Dcap Server For Certain vDU Site(Commercial)
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <29-Jul-2021>, <rifeng>, <Initial creation>
    ...    modified by:        <4-Aug-2021>, <rifeng>, <add argument ip>
    ...    modified by:        <18-Dec-2021>, <huilxu>, <add docker restart UDPTracer>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Delete Uplane Trace File On Dcap Server For Certain vDU Site    ${ip}|
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_UP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" -exec rm -rfv {} \\;    alias=${alias}
    sleep    10s
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\"    alias=${alias}
    ${trace_files}   convert to string    ${trace_files}
    Should Not Contain    ${trace_files}    ${ip}
    issh.Execute  command=docker restart UDPTracer   check_result=${False}  alias=${alias}
    sleep  10s
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}

Upload All Uplane Trace Files to Sherpa Server
    [arguments]  ${trace_file_path}   ${remote_path}=C:\\sherpa_tmp  ${info_index}=0
    [Documentation]  Upload All Uplane Trace Files to Sherpa Server
    ...    author: hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  trace_file_path  | Yes |  local trace file path include file name |
    ...    |  remote_path  | Yes |  remote file path in Sherpa Server  |
    ...    |  info_index   | No |  select Sherpa Server info  |
    ...    *RETURN VALUE*
    ...    remote file path in Sherpa Server
    ...    Example
    ...    |  Upload All Uplane Trace Files to Sherpa Server    ${trace_file_path}|
    ${connection}  get unique id
    Connect To Sherpa Server   connection=${connection}

    tafssh.execute    command=rd /s /q ${remote_path}   connection=${connection}
    tafssh.execute    command=mkdir ${remote_path}     connection=${connection}
    tafssh.upload_file   remote_path=${remote_path}\\tmp.tgz   local_path=${trace_file_path}   connection=${connection}

    [return]    ${remote_path}
    [Teardown]    run keyword and ignore error    Disconnect From K8s Master   connection=${connection}

Convert pcap to csv files and download from Sherpa Server
    [Arguments]    ${sherpa_files_dir}  ${sherpa_decode_file}="C:/Program Files/Nokia/Sherpa_5G18/Sherpa.exe"
    ...  ${info_index}=0  ${connection}=default1  ${alias}=default2
    [Documentation]  Convert pcap to csv files and download from Sherpa Server
    ...    author: hongyuan.sun@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  sherpa_files_dir  | Yes |  pcap file path |
    ...    |  sherpa_decode_file  | No |  Sherpa.exe file path  |
    ...    |  info_index   | No |  select Sherpa Server info  |
    ...    |  alias   | No |  default alias  |
    ...    *RETURN VALUE*
    ...    local csv files path
    ...    Example
    ...    |  Convert pcap to csv files and download from Sherpa Server   ${sherpa_files_dir}|

    Connect To Sherpa Server   connection=${connection}
    ${sherpa_tmp_logs}  set variable  C:\\sherpa_tmp_logs
    tafssh.execute    command=tar -zxvf ${sherpa_files_dir}\\tmp.tgz -C ${sherpa_files_dir}     connection=${connection}
    tafssh.execute    command=rd /s /q ${sherpa_tmp_logs}    connection=${connection}
    tafssh.execute    command=mkdir ${sherpa_tmp_logs}    connection=${connection}
    tafssh.execute    command=dir ${sherpa_tmp_logs}  connection=${connection}
    tafssh.execute    command="C:/Program Files/Nokia/Sherpa_5G18/Sherpa.exe" -o ${sherpa_tmp_logs} -d 2000 -p Sherpa ${sherpa_files_dir}
    ...  connection=${connection}
    tafssh.execute    command=dir ${sherpa_tmp_logs}  connection=${connection}

    tafssh.execute   command=tar -zcvf ${sherpa_tmp_logs}\\tmp.tgz -C ${sherpa_tmp_logs}\\ *.csv   connection=${connection}
    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
    ${local_dir}    Get A Directory    pcap_log    log_${curr_date}
    tafssh.download_file   remote_path=${sherpa_tmp_logs}\\tmp.tgz   local_path=${local_dir}/tmp.tgz  connection=${connection}
    tafssh.execute     command=rd /s /q ${sherpa_tmp_logs}    connection=${connection}
    Disconnect From K8s Master   connection=${connection}

    Connect To UTE   alias=${alias}
    ${cmd}  set variable  tar -zxvf ${local_dir}/tmp.tgz -C ${local_dir}
    ${output}   issh.Execute   command=${cmd}  alias=${alias}
    [Return]   ${local_dir}
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection  alias=${alias}


Uplane Trace File Existed On Dcap Server
    [Arguments]    ${ip}
    [Documentation]   Uplane Trace File Existed On Dcap Server(Commercial)
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <03-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Trace File Name On Dcap Server    ${ip}|
    log to console    check uplane trace existed
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_UP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\"    alias=${alias}
    ${trace_files}   convert to string    ${trace_files}
    Should Contain    ${trace_files}    ${ip}
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}


Download Newest Uplane Trace Files for vDU From Dcap Server
    [arguments]    ${ip}
    [Documentation]  Download Newest Uplane Trace Files for vDU From Dcap Server(Commercial)
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:
    ...    | date | who | what or how |
    ...    | 4-Aug-2021 | rifeng | Initial creation |
    ...    | 7-Dec-2022 | r3li | adpat ${trace_file} is not full file path |
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Uplane Trace Files for vDU From Dcap Server | ${ip}|
    ${curr_date}    Get Current Date    result_format=%Y%m%d_%H%M%S    exclude_millis=True
    ${local_dir}    Get A Directory    dcap_log    log_${curr_date}
    ${trace_file}    Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}
    Return From Keyword If    """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}    ${trace_file_name}    Split Path    ${trace_file}
    ${trace_file_name}    Set Variable    ${trace_file_name.replace(":", "")}
    ${alias}  get unique id
    Connect To DCAP    alias=${alias}
    ${r}   ${info}   Run Keyword And Ignore Error   issh.download file    remote_path=${trace_file}
    ...   local_path=${local_dir}/${trace_file_name}   alias=${alias}
    Run Keyword If    '${r}'=='FAIL'    issh.download file    remote_path=${DCAP_UP_LOG_DIR}/${trace_file}
    ...   local_path=${local_dir}/${trace_file_name}   alias=${alias}
    [Return]    ${local_dir}/${trace_file_name}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}


_Delete Core Dump Files
    [Teardown]    run keywords    run keyword and ignore error  disconnect interactive connection  alias=${alias}
    ...    AND    run keyword and ignore error  disconnect interactive connection  alias=${alias_root}
    [Documentation]   _Delete Core Dump Files
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | _Delete Core Dump Files |
    ...
    ${alias}  get unique id
    connect to k8s master interactively  alias=${alias}

    #delete tmp folder
    ${ns}  get vdu namespace from testline
    ${cu_ns}   Get CU Namespace From TestLine
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}_${cu_ns}
    ${out}   issh.Execute  command=sudo chmod 777 -R ${tmp_foler_name}   check_result=False  alias=${alias}
    ${out}   Run Keyword If   ${ns.__len__()}>0 and ${cu_ns.__len__()}>0
    ...   issh.Execute   command=sudo rm -rf ${tmp_foler_name}   alias=${alias}

    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec chmod 777 {} \\;   alias=${alias}  check_result=False
    ${out}   issh.Execute   command=sudo find /tmp/cdump/ -name core.* -exec rm -f {} \\;   alias=${alias}  check_result=False

    ${platform_name}   Get Platform Name

    Run Keyword If     "${platform_name}"=="OCP"  _VDU Environment WA For OCP   ${alias}
    return from keyword if   "${platform_name}"=="NCIR" or "${platform_name}"=="OCP"


Get Latest Uplane Trace File Name for vDU On Dcap Server
    [arguments]    ${ip}
    [Documentation]  Get Latest Uplane Trace File Name for vDU On Dcap Server(Commercial)
    ...    author: rita.feng@nokia-sbell.com
    ...    modified by:        <4-Aug-2021>, <rifeng>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Tes |  ip for f1uplane |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Uplane Trace File Name for vDU On Dcap Server    ${ip}|
    ${alias}    get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}    issh.Execute    command=cd ${DCAP_UP_LOG_DIR}    alias=${alias}
    ${trace_files}    issh.Execute    command=find ${DCAP_UP_LOG_DIR} -name \"\*${ip}\*\" | xargs ls --sort=time   alias=${alias}
    ${trace_files}  set variable  ${trace_files.replace("\r\n"," ")}
    ${trace_files}   Set Variable   ${trace_files.split()}
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Run Keyword If   ${trace_files.__len__()}>=1   Remove From List  ${trace_files}   index=-1
    Return From Keyword If    len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    [Return]    ${trace_files[0]}
    [Teardown]    run keyword and ignore error    disconnect interactive connection  alias=${alias}
