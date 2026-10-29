*** Settings ***
Documentation
...   author: huilin.xu@nokia-sbell.com
...   contact: huilin.xu@nokia-sbell.com
...   pcmd common keyword





*** Variables ***


*** Keywords ***
############################## PCMD Log Start ##############################
====== PCMD Log Start ======
     Log To Console  \n*** only used for readable ***

####################
Enable PCMD Status On VDU
    [Arguments]  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Enable PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
	...   17.4.2023,eahsuan.xuan@nokia-sbell.com,Modify replace to add and add nrRanTraceReference=${EMPTY}
    ...   17.4.2023,eahsuan.xuan@nokia-sbell.com,Modify NRBTS-${mrbts_id} to NRBTS-${vdu_conf["nrbts_id"]}
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    Example
    ...    | Enable PCMD Status On VDU |
    ...
    vDU Rest Login    vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${MRBTS_ID}  set variable      ${vdu_conf["mrbts_id"]}
    ${NRDU_dist_name}    Set Variable    MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf['nrbts_id']}/NRDU-${vdu_conf['nrdu_id']}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=MRBTS-${MRBTS_ID}/MNL-1   mo_name=TCEADM-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1   mo_name=TCE-1

    ${TCE_Info_1}=   create dictionary  tceIpAddress=${DCAP_IP}   tcePortNumber=${DCAP_PORT}
    ${TCE_Info_2}=   create dictionary  tceIdentifier=1
    ${TCE_Info_3}=   create dictionary  tlsEnabled=false

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_1}
    ...  operation=add


    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_2}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_3}
    ...  operation=add

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}   mo_name=NRCTRLTSDU-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1   mo_name=NRMTRACEDU-1

    ${NRMTRACEDU_Info_1}=   create dictionary    jobType=TraceOnly  scope=allResources
    ${NRMTRACEDU_Info_2}=   create dictionary   actPCMDReporting=true  nrTceIdentifier=1  cellMaxActiveUEsTraced=2
    ${nrRanTraceReference_Info}    create dictionary    nrRanTraceReference=${EMPTY}    nrRanTraceReference/0/mcc=262
    ...   nrRanTraceReference/0/mnc=3    nrRanTraceReference/0/mncLength=2   nrRanTraceReference/0/traceId=1

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_1}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_2}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${nrRanTraceReference_Info}
    ...  operation=add

    ${actPCMDReport_true}    Create Dictionary    actPCMDReport=true

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${vdu_conf["nrbts_id"]}/
    ...  updated_paras_dict=${actPCMDReport_true}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    Activate Delta Plan By REST   plan_id=${plan_id}


Update PCMD Status On VDU
    [Arguments]   ${actPCMDReport_expected}  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Update PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   17.5.2023,eahsuan.xuan@nokia-sbell.com,Modify NRBTS-${MRBTS_ID} to NRBTS-${all_BTS_ID[1]}
    ...    |  Input Parameters | Man. | Description |
    ...	   |  ${actPCMDReport_expected} | Yes | true or false |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Update PCMD Status On VDU | ${actPCMDReport_expected}=true  |
    ...
    vDU Rest Login  vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}
    set test variable    ${NRBTS_MO_DN}    MRBTS-${MRBTS_ID}/NRBTS-${all_BTS_ID[1]}

    ${actPCMDReport_status}=    Get VDU Parameter Value Online    ${NRBTS_MO_DN}    actPCMDReport
    ${added_dict}    Create Dictionary    actPCMDReport=${actPCMDReport_expected}

    run keyword if    '${actPCMDReport_status}' != '${actPCMDReport_expected}'    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${NRBTS_MO_DN}    updated_paras_list=${added_dict}    auto_lock_cells=${False}    wait_vdu_up=${true}


Check PCMD Session Status
    [Arguments]  ${setup}=${true}   ${vdu_index}=0
    [Documentation]  Check PCMD Session Status
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <28-Jun-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  setup | No |  setup status, default is ${true}, means vdu is connected dcap server |
	...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check PCMD Session Status  |  ${true}  |

    ${ip_info}  Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${ip}  Set Variable   ${ip_info['addr']}
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=netstat -tan | grep ${DCAP_PORT}    check_result=${False}   alias=${alias}
    ${sessions}  strip prompt  ${sessions}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}

Disable PCMD Status On VDU
    [Arguments]  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Disable PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.11.2022,chris.l.cao@nokia-sbell.com, change NRBTS-${mrbts_id} to NRBTS-${vdu_conf["nrbts_id"]}
    ...
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    Example
    ...    | Disable PCMD Status On VDU |
    ...
    vDU Rest Login  vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${mrbts_id}  set variable      ${vdu_conf["mrbts_id"]}


    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    Configure DU Delete Dcap Server MO And PCMD MO      scf_path=${scf_file_with_fullpath}    plan_id=${plan_id}

    ${actPCMDReport_false}    Create Dictionary    actPCMDReport=false

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${mrbts_id}/NRBTS-${vdu_conf["nrbts_id"]}/
    ...  updated_paras_dict=${actPCMDReport_false}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    Activate Delta Plan By REST   plan_id=${plan_id}


Configure DU Delete Dcap Server MO And PCMD MO
    [Arguments]  ${scf_path}    ${plan_id}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${matches_1}     Get Regexp Matches    ${scf_content}   .*TCE"\\s+distName="MRBTS-(\\d+)/MNL-1/TCEADM-1/TCE-1"\\s+.*
    ${matches_2}     Get Regexp Matches    ${scf_content}   .*TCEADM"\\s+distName="MRBTS-(\\d+)/MNL-1/TCEADM-1"\\s+.*

    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_path}
    ${mrbts_id}  set variable      ${vdu_conf["mrbts_id"]}
    ${NRDU_dist_name}    Set Variable    MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf['nrbts_id']}/NRDU-${vdu_conf['nrdu_id']}

    ${distname_1}  Set Variable    MRBTS-${mrbts_id}/MNL-1/TCEADM-1/TCE-1
    ${distname_2}  Set Variable    MRBTS-${mrbts_id}/MNL-1/TCEADM-1

    Run Keyword If    ${matches_1}   Delete Delta Plan MO   ${plan_id}   ${distname_1}
    Run Keyword If    ${matches_2}   Delete Delta Plan MO   ${plan_id}   ${distname_2}

    ${matches_3}     Get Regexp Matches    ${scf_content}
    ...  .*NRMTRACEDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)/NRCTRLTSDU-1/NRMTRACEDU-1"\\s+.*
    ${matches_4}     Get Regexp Matches    ${scf_content}
    ...  .*NRCTRLTSDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)/NRCTRLTSDU-1"\\s+.*

    ${distname_3}  Set Variable    ${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ${distname_4}  Set Variable    ${NRDU_dist_name}/NRCTRLTSDU-1

    Run Keyword If    ${matches_3}   Delete Delta Plan MO   ${plan_id}   ${distname_3}
    Run Keyword If    ${matches_4}   Delete Delta Plan MO   ${plan_id}   ${distname_4}


Enable PCMD Status On VDU with TLS
    [Arguments]  ${vdu_index}=0  ${certTypeForTlsAuth}=RSA
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Enable PCMD Status On VDU with TLS
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   18.11.2022,chris.l.cao@nokia-sbell.com, change NRBTS-${mrbts_id} to NRBTS-${vdu_conf["nrbts_id"]}
	...   17.4.2023,eahsuan.xuan@nokia-sbell.com,Modify replace to add and add nrRanTraceReference=${EMPTY}
	...   08.5.2023,huilin.xu@nokia-sbell.com,add parameter certTypeForTlsAuth
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  vdu_index | no | vdu_index, default is 0 |
    ...
    ...    Example
    ...    | Enable PCMD Status On VDU with TLS |
    ...    | Enable PCMD Status On VDU with TLS | certTypeForTlsAuth=ECDSA |
    ...
    vDU Rest Login    vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${MRBTS_ID}  set variable      ${vdu_conf["mrbts_id"]}
    ${NRDU_dist_name}    Set Variable    MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf['nrbts_id']}/NRDU-${vdu_conf['nrdu_id']}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=MRBTS-${MRBTS_ID}/MNL-1   mo_name=TCEADM-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1   mo_name=TCE-1

    ${TCE_Info_1}=   create dictionary  tceIpAddress=${DCAP_IP_TLS}   tcePortNumber=${DCAP_PORT_TLS}
    ${TCE_Info_2}=   create dictionary  tceIdentifier=1
    ${TCE_Info_3}=   create dictionary  tlsEnabled=true
    ${TCE_Info_4}=   Run Keyword If  "${certTypeForTlsAuth}"=="ECDSA"   create dictionary  certTypeForTlsAuth=ECDSA

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_1}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_2}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_3}
    ...  operation=add

	  Run Keyword If  "${certTypeForTlsAuth}"=="ECDSA"    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_4}
    ...  operation=add

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}   mo_name=NRCTRLTSDU-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1   mo_name=NRMTRACEDU-1

    ${NRMTRACEDU_Info_1}=   create dictionary    jobType=TraceOnly  scope=allResources
    ${NRMTRACEDU_Info_2}=   create dictionary   actPCMDReporting=true  nrTceIdentifier=1  cellMaxActiveUEsTraced=2
    ${nrRanTraceReference_Info}    create dictionary    nrRanTraceReference=${EMPTY}    nrRanTraceReference/0/mcc=262
    ...   nrRanTraceReference/0/mnc=3    nrRanTraceReference/0/mncLength=2   nrRanTraceReference/0/traceId=1

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_1}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_2}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${nrRanTraceReference_Info}
    ...  operation=add

    ${actPCMDReport_true}    Create Dictionary    actPCMDReport=true

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${vdu_conf["nrbts_id"]}/
    ...  updated_paras_dict=${actPCMDReport_true}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    Activate Delta Plan By REST   plan_id=${plan_id}


Get Latest Trace File Name of DU On Dcap Server
    [Arguments]  ${vdu_index}=0
    [Documentation]  Get Latest Trace File Name of DU On Dcap Server(Commercial)
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <27-Jul-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...    Example
    ...    |  Get Latest Trace File Name of DU On Dcap Server |
    ${ip_info}  Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${ip}  Set Variable   ${ip_info['addr']}
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=cd ${DCAP_LOG_DIR}   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_LOG_DIR} -name \"\*${ip}\*\" | xargs ls --sort=time -r   alias=${alias}
    ${trace_files}    Strip Prompt    ${trace_files}
    ${trace_files}   Set Variable   ${trace_files.splitlines()}
    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
    [Return]   ${trace_files[-1]}
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}


Get Latest Trace File Name of DU On Dcap Server TLS
    [Arguments]  ${vdu_index}=0
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]  Get Latest Trace File Name of DU On Dcap Server
    ...    author: huilin.xu@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2021-7-27 | huilxu@nokia-sbell.com | Initial creation |
    ...   | 2022-11-18 | chris.l.cao@nokia-sbell.com | use 'Connect To DCAP TLS' |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...
    ...    *RETURN VALUE*
    ...    dcap log file path on server
    ...
    ...    Example
    ...    |  Get Latest Trace File Name of DU On Dcap Server TLS |
    ...
    ${ip_info}  Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${ip}  Set Variable   ${ip_info['addr']}
    ${alias}  get unique id
    Connect To DCAP TLS   alias=${alias}
    ${trace_files}   issh.Execute   command=find ${DCAP_LOG_DIR_TLS} -name \"\*${ip}\*\" | xargs ls --sort=time -r |tail -1  alias=${alias}
    ${trace_files}    Strip Prompt    ${trace_files}
#    ${trace_files}   Set Variable   ${trace_files.splitlines()}
#    Return From Keyword If   len(${trace_files})==0 or (len(${trace_files})==1 and """${trace_files[0]}"""=="""""")    ${EMPTY}
#    [Return]   ${trace_files[-1]}
     [Return]   ${trace_files}


Download Newest Trace Files of DU From Dcap Server
    [Arguments]  ${vdu_index}=0
    [Documentation]  Download Newest Trace Files of DU From Dcap Server(Commercial)
    ...    author: huilin.xu@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2021-7-27 | huilxu@nokia-sbell.com | Initial creation |
    ...   | 2022-11-18 | chris.l.cao@nokia-sbell.com | use 'Connect To DCAP TLS' |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...
    ...    Example
    ...    |  Download Newest Trace Files of DU From Dcap Server |
    ...
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   Get A Directory   dcap_log    log_${curr_date}
    ${trace_file}   Get Latest Trace File Name of DU On Dcap Server  vdu_index=${vdu_index}
    Return From Keyword If   """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}   ${trace_file_name}   Split Path   ${trace_file}
    ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    issh.download file   remote_path=${trace_file}   local_path=${local_dir}/${trace_file_name}   alias=${alias}
    [Return]   ${local_dir}/${trace_file_name}
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}


Download Newest Trace Files of DU From Dcap Server TLS
    [Arguments]  ${vdu_index}=0
    [Documentation]  Download Newest Trace Files of DU From Dcap Server TLS
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <27-Jul-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Trace Files of DU From Dcap Server TLS |
    ${curr_date}   Get Current Date   result_format=%Y%m%d_%H%M%S   exclude_millis=True
    ${local_dir}   Get A Directory   dcap_log    log_${curr_date}
    ${trace_file}   Get Latest Trace File Name of DU On Dcap Server TLS  vdu_index=${vdu_index}
    Return From Keyword If   """${trace_file}"""=="""${EMPTY}"""
    ${trace_dir}   ${trace_file_name}   Split Path   ${trace_file}
    ${trace_file_name}   Set Variable   ${trace_file_name.replace(":", "")}
    ${alias}  get unique id
    Connect To DCAP TLS   alias=${alias}
    issh.download file   remote_path=${trace_file}   local_path=${local_dir}/${trace_file_name}   alias=${alias}
    [Return]   ${local_dir}/${trace_file_name}
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}


Check PCMD Session Status with TLS
    [Arguments]  ${setup}=${True}   ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]  Check PCMD Session Status with TLS
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <28-Jun-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  setup | No |  setup status, default is ${true}, means vdu is connected dcap server |
	...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check PCMD Session Status with TLS |  ${true}  |

    ${ip_info}  Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${ip}  Set Variable   ${ip_info['addr']}
    ${alias}  get unique id
    Connect To DCAP TLS   alias=${alias}

    ${sessions}   issh.Execute   command=netstat -tan | grep ${DCAP_PORT_TLS}   alias=${alias}
    ${sessions}  strip prompt  ${sessions}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}


Get Remaning Time For Generating DCAP New Folder
    [Arguments]    ${internal_value}
    [Documentation]    Get Remaning Time For Generating DCAP New Folder(Commercial)
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <27-Jul-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | internal_value | Yes | the interval that DCAP new folder generated |
    ...    *RETURN VALUE*
    ...    remaining time that DCAP New Folder will generate
    ...    Example
    ...    | ${value}= | Get Remaning Time For Generating DCAP New Folder |  15  |

    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${ret}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${minute}=  convert to integer   ${matches[0]}
    ${minute_1} =    Evaluate    ${minute}%${internal_value}
    ${remain}=     Evaluate    ${internal_value} - ${minute_1}
    [return]    ${remain}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}

Get Remaning Time For Generating DCAP TLS New Folder
    [Arguments]    ${internal_value}
    [Documentation]    Get Remaning Time For Generating DCAP TLS New Folder (Commercial)
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <08-May-2023>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | internal_value | Yes | the interval that DCAP new folder generated |
    ...    *RETURN VALUE*
    ...    remaining time that DCAP TLS New Folder will generate
    ...    Example
    ...    | ${value}= | Get Remaning Time For Generating DCAP TLS New Folder |  15  |

    ${alias}  get unique id
    Connect To DCAP TLS   alias=${alias}
    ${ret}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${minute}=  convert to integer   ${matches[0]}
    ${minute_1} =    Evaluate    ${minute}%${internal_value}
    ${remain}=     Evaluate    ${internal_value} - ${minute_1}
    [return]    ${remain}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}

Add Object NRMTRACECU With allResources On CU
    [Arguments]  ${actPCMDReporting}=true
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Add Object NRMTRACECU With allResources On CU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
	...    modified by:        <16-May-2022>, <Xuan Eahsuan>, <add CU_MRBTS_ID>
	...    modified by:        <18-Oct-2022>, <Cao Liting>, <update CU_NRBTS_ID >
	...    modified by:        <22-Feb-2023>, <Xu Huilin>, <add steps of creating MO Operation Check >
    ...    |  Input Parameters | Man. | Description |
    ...	   |  actPCMDReporting         | No| true or false,default is true |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Add Object NRMTRACECU With Allresources On CU |
	#${vdu_conf}   Get VDU Conf From SCF
    #${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
	#${CU_MRBTS_ID}   Get MRBTS Id From vCU SCF
	${vcu_conf}    Get VCU Conf From SCF    gnb_index=0
    ${CU_MRBTS_ID}  set variable      ${vcu_conf["mrbts_id"]}
	${CU_NRBTS_ID}  set variable      ${vcu_conf["nrbts_id"]}
    CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
	#${vdu_conf}   Get VDU Conf From SCF
    #${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
	${mo_dn}    set variable    MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}/NRCTRLTS-1
	${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.nrbts:NRCTRLTS
	${nidd}  convert to string  ${nidd_id}
	${instance}  convert to integer  1
    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}

	${mo_dn_1}    set variable    MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
	${uuid_1}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}/NRCTRLTS-1
    ${nidd_id_1}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.nrbts:NRMTRACECU
	${nidd_1}  convert to string  ${nidd_id_1}
	${instance_1}  convert to integer  1

    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid_1}
    ...  	nidd_id=${nidd_1}   instance_id=${instance_1}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}


    &{actCellTraceReportingCU}    create dictionary    operation_type=add    parameter_path=/actCellTraceReportingCU    value=true
	@{actCellTraceReportingCU_list}=    Create List  ${actCellTraceReportingCU}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${actCellTraceReportingCU_list}

    &{actPCMDReporting}    create dictionary    operation_type=add    parameter_path=/actPCMDReporting    value=${actPCMDReporting}
	@{actPCMDReporting_list}=    Create List  ${actPCMDReporting}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${actPCMDReporting_list}

    &{cellMaxActiveUEsTraced}    create dictionary    operation_type=add    parameter_path=/cellMaxActiveUEsTraced    value=3
	@{cellMaxActiveUEsTraced_list}=    Create List  ${cellMaxActiveUEsTraced}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${cellMaxActiveUEsTraced_list}

    &{jobType}    create dictionary    operation_type=add    parameter_path=/jobType    value=TraceOnly
	@{jobType_list}=    Create List  ${jobType}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${jobType_list}

    &{nrMtraceCuId}    create dictionary    operation_type=add    parameter_path=/nrMtraceCuId    value=1
	@{nrMtraceCuId_list}=    Create List  ${nrMtraceCuId}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${nrMtraceCuId_list}

    &{nrTceIdentifier}  create dictionary  operation_type=add    parameter_path=/nrTceIdentifier    value=1
    @{nrTceIdentifier_list}=    Create List  ${nrTceIdentifier}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${nrTceIdentifier_list}

	&{scope}    create dictionary    operation_type=add    parameter_path=/scope    value=allResources
	@{scope_list}=    Create List  ${scope}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${scope_list}

    &{traceNGAPSetting}    create dictionary    operation_type=add    parameter_path=/traceNGAPSetting    value=all
	@{traceNGAPSetting_list}=    Create List  ${traceNGAPSetting}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${traceNGAPSetting_list}

    &{traceNRRRCSetting}    create dictionary    operation_type=add    parameter_path=/traceNRRRCSetting    value=all
	@{traceNRRRCSetting_list}=    Create List  ${traceNRRRCSetting}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${traceNRRRCSetting_list}

    &{traceX2Setting}    create dictionary    operation_type=add    parameter_path=/traceX2Setting    value=all
	@{traceX2Setting_list}=    Create List  ${traceX2Setting}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${traceX2Setting_list}

    &{traceXNSetting}    create dictionary    operation_type=add    parameter_path=/traceXNSetting    value=all
	@{traceXNSetting_list}=    Create List  ${traceXNSetting}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${traceXNSetting_list}

	&{nrRanTraceReference}  create dictionary  operation_type=add    parameter_path=/nrRanTraceReference
    @{nrRanTraceReference_list}=    Create List  ${nrRanTraceReference}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${nrRanTraceReference_list}

	&{mcc}  create dictionary  operation_type=add    parameter_path=/nrRanTraceReference/0/mcc     value=262
    @{mcc_list}=    Create List  ${mcc}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${mcc_list}

	&{mnc}  create dictionary  operation_type=add    parameter_path=/nrRanTraceReference/0/mnc     value=3
    @{mnc_list}=    Create List  ${mnc}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${mnc_list}

	&{mncLength}  create dictionary  operation_type=add    parameter_path=/nrRanTraceReference/0/mncLength     value=2
    @{mncLength_list}=    Create List  ${mncLength}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${mncLength_list}

	&{traceId}  create dictionary  operation_type=add    parameter_path=/nrRanTraceReference/0/traceId     value=1
    @{traceId_list}=    Create List  ${traceId}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${traceId_list}

	CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    CU Activate Delta Plan Should Be Successful    ${delta_plan_id}

Delete Object NRMTRACECU On CU
    [Arguments]
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Delete Object NRMTRACECU On CU
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
	...    modified by:        <16-May-2022>, <Xuan Eahsuan>, <add CU_MRBTS_ID >
	...    modified by:        <18-Oct-2022>, <Cao Liting>, <update CU_NRBTS_ID >
	...    modified by:        <22-Feb-2023>, <Xu Huilin>, <add NRCTRLTS deletion step>
	...    modified by:        <03-Mar-2023>, <Xu Huilin>, <add match before deletion>
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete Object NRMTRACECU On CU |
	#${vdu_conf}   Get VDU Conf From SCF
    #${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
    #${CU_MRBTS_ID}   Get MRBTS Id From vCU SCF
    ${vcu_conf}    Get VCU Conf From SCF    gnb_index=0
    ${CU_MRBTS_ID}  set variable      ${vcu_conf["mrbts_id"]}
    ${CU_NRBTS_ID}  set variable      ${vcu_conf["nrbts_id"]}


    CU Login
    ${scf_path}=    Get A File    SCF    vcu_scf.xml
    cu.get_current_plan_file   path=${scf_path}  timeout=60  include_runtime_data=${True}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${matches_1}     Get Regexp Matches    ${scf_content}   .*NRMTRACECU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCTRLTS-1/NRMTRACECU-1"\\s+.*
    ${matches_2}     Get Regexp Matches    ${scf_content}   .*NRCTRLTS"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCTRLTS-1"\\s+.*


    CU Rest Login
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    Run Keyword If    ${matches_1}   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}
    ...    MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
    Run Keyword If    ${matches_2}   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}
    ...    MRBTS-${CU_MRBTS_ID}/NRBTS-${CU_NRBTS_ID}/NRCTRLTS-1

    Run Keyword If    ${matches_2.__len__()>=1}   CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    Run Keyword If    ${matches_2.__len__()>=1}   CU Activate Delta Plan Should Be Successful    ${delta_plan_id}

Delete Object TCE On CU
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Delete Object TCE On CU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
	  ...    modified by:        <08-May-2023>, <Xu Huilin>, <inital create >
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete Object TCE On CU |
    ${vcu_conf}    Get VCU Conf From SCF    gnb_index=0
    ${CU_MRBTS_ID}  set variable      ${vcu_conf["mrbts_id"]}

    CU Login
    ${scf_path}=    Get A File    SCF    vcu_scf.xml
    cu.get_current_plan_file   path=${scf_path}  timeout=60  include_runtime_data=${True}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${matches_1}     Get Regexp Matches    ${scf_content}   .*TCE"\\s+distName="MRBTS-(\\d+)/MNL-(\\d+)/TCEADM-1/TCE-(\\d+)"\\s+.*
    ${matches_2}     Get Regexp Matches    ${scf_content}   .*TCEADM"\\s+distName="MRBTS-(\\d+)/MNL-(\\d+)/TCEADM-1"\\s+.*


    CU Rest Login
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    Run Keyword If    ${matches_1}   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}
    ...    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    Run Keyword If    ${matches_2}   CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}
    ...    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1

    Run Keyword If    ${matches_2.__len__()>=1}   CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    Run Keyword If    ${matches_2.__len__()>=1}   CU Activate Delta Plan Should Be Successful    ${delta_plan_id}

Add Object TCE With TLS On CU
    [Arguments]  ${certTypeForTlsAuth}=RSA
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Add Object TCE With TLS On CU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
	  ...    modified by:        <08-May-2023>, <Xu Huilin>, <initial create>
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Add Object TCE With TLS On CU |
    ...    | Add Object TCE With TLS On CU |  certTypeForTlsAuth=RSA  |
    ...    | Add Object TCE With TLS On CU |  certTypeForTlsAuth=ECDSA  |
	${vcu_conf}    Get VCU Conf From SCF    gnb_index=0
    ${CU_MRBTS_ID}  set variable      ${vcu_conf["mrbts_id"]}
	${CU_NRBTS_ID}  set variable      ${vcu_conf["nrbts_id"]}
    CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

	${mo_dn}    set variable    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1
	${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/MNL-1
    ${nidd_id}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.mnl:TCEADM
	${nidd}  convert to string  ${nidd_id}
	${instance}  convert to integer  1
    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}

	${mo_dn_1}    set variable    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	${uuid_1}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1
    ${nidd_id_1}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.mnl:TCE
	${nidd_1}  convert to string  ${nidd_id_1}
	${instance_1}  convert to integer  1

    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid_1}
    ...  	nidd_id=${nidd_1}   instance_id=${instance_1}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}


    &{certTypeForTlsAuth}    create dictionary    operation_type=add    parameter_path=/certTypeForTlsAuth    value=${certTypeForTlsAuth}
	@{certTypeForTlsAuth_list}=    Create List  ${certTypeForTlsAuth}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${certTypeForTlsAuth_list}

    &{tceIdentifier}    create dictionary    operation_type=add    parameter_path=/tceIdentifier    value=1
	@{tceIdentifier_list}=    Create List  ${tceIdentifier}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tceIdentifier_list}

    &{tceIpAddress}    create dictionary    operation_type=add    parameter_path=/tceIpAddress	    value=${DCAP_IP_TLS}
	@{tceIpAddress_list}=    Create List  ${tceIpAddress}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tceIpAddress_list}

	&{tcePortNumber}    create dictionary    operation_type=add    parameter_path=/tcePortNumber	    value=${DCAP_PORT_TLS}
	@{tcePortNumber_list}=    Create List  ${tcePortNumber}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tcePortNumber_list}

    &{tlsEnabled}    create dictionary    operation_type=add    parameter_path=/tlsEnabled	    value=true
	@{tlsEnabled_list}=    Create List  ${tlsEnabled}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tlsEnabled_list}

	CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    CU Activate Delta Plan Should Be Successful    ${delta_plan_id}

Add Object TCE With non-TLS On CU
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Add Object TCE With non-TLS On CU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
	  ...    modified by:        <05-May-2023>, <Xu Huilin>, <initial create>
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Add Object TCE With non-TLS On CU |
	${vcu_conf}    Get VCU Conf From SCF    gnb_index=0
    ${CU_MRBTS_ID}  set variable      ${vcu_conf["mrbts_id"]}
	${CU_NRBTS_ID}  set variable      ${vcu_conf["nrbts_id"]}
    CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful

	${mo_dn}    set variable    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1
	${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/MNL-1
    ${nidd_id}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.mnl:TCEADM
	${nidd}  convert to string  ${nidd_id}
	${instance}  convert to integer  1
    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}

	${mo_dn_1}    set variable    MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
	${uuid_1}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${CU_MRBTS_ID}/MNL-1/TCEADM-1
    ${nidd_id_1}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.mnl:TCE
	${nidd_1}  convert to string  ${nidd_id_1}
	${instance_1}  convert to integer  1

    ${create_res}=  cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid_1}
    ...  	nidd_id=${nidd_1}   instance_id=${instance_1}  include_defaults=False
     Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${create_res['action_id']}

    &{certTypeForTlsAuth}    create dictionary    operation_type=add    parameter_path=/certTypeForTlsAuth    value=RSA
	@{certTypeForTlsAuth_list}=    Create List  ${certTypeForTlsAuth}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${certTypeForTlsAuth_list}

    &{tceIdentifier}    create dictionary    operation_type=add    parameter_path=/tceIdentifier    value=1
	@{tceIdentifier_list}=    Create List  ${tceIdentifier}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tceIdentifier_list}

    &{tceIpAddress}    create dictionary    operation_type=add    parameter_path=/tceIpAddress	    value=${DCAP_IP}
	@{tceIpAddress_list}=    Create List  ${tceIpAddress}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tceIpAddress_list}

	&{tcePortNumber}    create dictionary    operation_type=add    parameter_path=/tcePortNumber	    value=${DCAP_PORT}
	@{tcePortNumber_list}=    Create List  ${tcePortNumber}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tcePortNumber_list}

    &{tlsEnabled}    create dictionary    operation_type=add    parameter_path=/tlsEnabled	    value=false
	@{tlsEnabled_list}=    Create List  ${tlsEnabled}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${tlsEnabled_list}

	CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    CU Activate Delta Plan Should Be Successful    ${delta_plan_id}
############################## PCMD Log End ##############################
====== PCMD Log End ======
     Log To Console  \n*** only used for readable ***

Get Appointed Dcap Http Info
    [Arguments]    ${dcap_label}    ${ip_type}=ipv4
    [Documentation]    Get Appointed Dcap Http Info
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-24 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | dcap_label | Yes | dcap label, like dcap1, dcap2, dcap3 |
    ...   *Return*
    ...   - dcap http ip
    ...   - dcap http port
    ...   - dcap http username
    ...   - dcap http password
    ...   *Example*
    ...   | ${http_ip} | ${http_port} | ${http_username} | ${http_password} | Get Appointed Dcap Http Info | dcapv3 |
    ${dcap_info}    get_appointed_dcap_info    ${dcap_label}
    ${dcap_dhcp_info}     set variable if    '${ip_type}'=='ipv4'   ${dcap_info}[http_info]   ${dcap_info}[http_info_v6]
    ${http_server_ip}     set variable    ${dcap_dhcp_info.addr}
    ${http_server_port}     set variable    ${dcap_dhcp_info.port}
    ${http_server_username}     set variable    ${dcap_dhcp_info.username}
    ${http_server_password}     set variable    ${dcap_dhcp_info.password}
    [Return]    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}


Connect to Dcap By Rest Api
    [Arguments]    ${alias}=${None}    ${rd_version}=dcapv3    ${secure}=${TRUE}    ${dcap_label}=dcap3
    [Documentation]    Connect to Dcap By Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | No | connect string, default is None |
    ...   | rd_version | No | rd version, default is dcapv3 |
    ...   | secure | No | is need secure connect, default is True |
    ...   *Return*
    ...   - dcap connect object
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True | dcap3 |
    ${unique_id}    Get Unique Id
    ${alias}    Set Variable If    '${alias}'=='${None}'   ${unique_id}     ${alias}
    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}
    ...    Get Appointed Dcap Http Info    ${dcap_label}
    dcap_rest.connect_to    host=${http_server_ip}
    ...                     port=${http_server_port}
    ...                     username=${http_server_username}
    ...                     password=${http_server_password}
    ...                     rd_version=${rd_version}
    ...                     secure=${secure}
    ...                     alias=${alias}
    [Return]   ${alias}

Create Bts In Dcap By Rest Api
    [Arguments]    ${http_connection_info}    ${mrbts_id}    ${alias}    ${ne_type}=vdu
    [Documentation]    Create Bts In Dcap By Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-17 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | http_connection_info | Yes | a dic contians connection info for vdu/vcu, its key must have addr, port, username, password |
    ...   | mrbts_id |Yes | mrbts id |
    ...   | alias | Yes | dcap connecting object |
    ...   | ne_type | No | must be vdu or vcu, default is vdu |
    ...   *Return*
    ...   - bts id
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${bts_id} | Create Bts In Dcap By Rest Api | ${http_connect_info} | MRBTS-12345 | 0 | ${connection} | vdu |
    ${host}   Set Variable    ${http_connection_info}[addr]
    ${port}   Set Variable    ${http_connection_info}[port]
    ${username}   Set Variable    ${http_connection_info}[username]
    ${password}   Set Variable    ${http_connection_info}[password]
    _Delete Existed Bts By Rest Api   alias=${alias}    ip_addr=${host}
    ${create_info}    dcap_rest.create_bts    host=${host}   port=${port}   username=${username}
    ...    password=${password}   connection=${alias}    bts_alias=${mrbts_id}-${ne_type}
    ${bts_id}    Set Variable    ${create_info.id}
    [Return]    ${bts_id}


Create vDU Bts In Dcap By Rest Api
    [Arguments]   ${alias}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Create vDU Bts In Dcap By Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   | 2022-6-17 | r3li | delete bts before add |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | Yes | dcap connecting object |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   *Return*
    ...   - bts id
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${bts_id} | Create vDU Bts In Dcap By Rest Api | ${connection} | 0 | 0 |
    ${vdu_connect_oam_http_info}    Get VDU OAM Http Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}    Get MRBTS Id From vDU SCF    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${bts_id}    Create Bts In Dcap By Rest Api     http_connection_info=${vdu_connect_oam_http_info}
    ...    mrbts_id=MRBTS-${mrbts_id}   alias=${alias}   ne_type=vdu
    [Return]    ${bts_id}

Create vCU Bts In Dcap By Rest Api
    [Arguments]   ${alias}   ${gnb_index}=0
    [Documentation]    Create vCU Bts In Dcap By Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-17 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | Yes | dcap connecting object |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   *Return*
    ...   - bts id
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${bts_id} | Create VCU Bts In Dcap By Rest Api | ${connection} | 0 |
    ${vcu_connect_oam_http_info}    Get VCU OAM Http Connection Info  gnb_index=${gnb_index}
    ${MRBTS_id}    Get MRBTS Id From vCU SCF    gnb_index=${gnb_index}
    ${bts_id}   Create Bts In Dcap By Rest Api     http_connection_info=${vcu_connect_oam_http_info}
    ...     mrbts_id=MRBTS-${MRBTS_id}   alias=${alias}    ne_type=vcu
    [Return]   ${bts_id}


VDU Online Add DCAP Server Route On TNL-3
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0    ${dcap_label}=dcap3
    [Documentation]    VDU Online Add DCAP Server Route On TNL-3
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   | 2022-11-03 | huilxu | add TNL-3 in keyword name |
    ...   | 2022-11-09 | huilxu | add ip_type as a parameter |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   *Example*
    ...   | VDU Online Add DCAP Server Route On TNL-3 | 0 | 0 | dcap3 |
    vDU Rest Login    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${oam_ip}   Get vDU OAM Ip   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_type}    Set Variable If    ':' in '${oam_ip}'    ipv6    ipv4
    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}
    ...    Get Appointed Dcap Http Info    ${dcap_label}        ${ip_type}
    _Online Add DCAP Server Route On TNL-3    ${http_server_ip}  ${ip_type}
    [Teardown]   vDU Logout

CU Add DCAP Server White Name List
    [Arguments]    ${gnb_index}=0    ${dcap_label}=dcap3
    [Documentation]    CU Add DCAP Server White Name List
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-23 | r3li | new |
    ...   | 2022-9-5 | r3li | support ipv6 |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | dcap_label | No | dcap label, default is dcap3 |
    ...   *Example*
    ...   | CU Add DCAP Server White Name List | 0 | dcap3 |
    ${alias}    Connect To CU K8S Master With Tenant
    ${pod_name}    Get CU Full Pod Name By Pod Abbreviation    pod_abbr=oamext    alias=${alias}    gnb_index=${gnb_index}
    ${container_name}     Get CU Full Container Name By Container Abbreviation    ctr_abbr=providercontroller
    ${namespace}   Get Cu Namespace From Testline    gnb_index=${gnb_index}
    ${cu_oam_ip}    Get vCU OAM Ip    gnb_index=${gnb_index}
    ${ip_type}    Set Variable If    ':' in '${cu_oam_ip}'    ipv6    ipv4
    _Add DCAP Server White Name List   alias=${alias}   namespace=${namespace}   pod_name=${pod_name}
    ...    container_name=${container_name}    dcap_label=${dcap_label}    ip_type=${ip_type}
    [Teardown]  Disconnect Interactive Connections

vDU Add DCAP Server White Name List
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${dcap_label}=dcap3
    [Documentation]    vDU Add DCAP Server White Name List
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-23 | r3li | new |
    ...   | 2022-9-5 | r3li | support ipv6 |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   | dcap_label | No | dcap label, default is dcap3 |
    ...   *Example*
    ...   | vDU Add DCAP Server White Name List | dcap3 | 0 | 0 |
    ${alias}    get unique id
    ${alias}    Connect To K8s Master Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${pod_name}    Get Full Pod Name By Container Abbreviation Interactively    container_abbr=providercontroller
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${container_name}     Get Full Container Name By Container Abbreviation    ctr_abbr=providercontroller
    ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${namespace}   Get vDu Namespace From Testline    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_oam_ip}    Get vDU OAM Ip    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_type}    Set Variable If    ':' in '${vdu_oam_ip}'    ipv6    ipv4
    _Add DCAP Server White Name List   alias=${alias}   namespace=${namespace}   pod_name=${pod_name}
    ...    container_name=${container_name}    dcap_label=${dcap_label}    ip_type=${ip_type}
    [Teardown]  Disconnect Interactive Connections


_Add DCAP Server White Name List
    [Arguments]    ${alias}    ${namespace}    ${pod_name}    ${container_name}    ${dcap_label}   ${ip_type}
    ${bash_cmd}   Set Variable    kubectl -n ${namespace} exec -it ${pod_name} -c ${container_name} -- bash
    ${out}    issh.Execute    command=${bash_cmd}    alias=${alias}   check_result=${False}
    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}
    ...    Get Appointed Dcap Http Info    ${dcap_label}    ${ip_type}
    ${get_cmd}   Set Variable    /opt/nokia/bin/dataprovidercli show | grep ${http_server_ip}
    ${out}    issh.Execute    command=${get_cmd}   alias=${alias}   check_result=${False}
    Return From Keyword If    '${http_server_ip}' in '''${out}'''
    ${old_prompt}  issh.get_prompt   alias=${alias}
    ${new_prompt}  set variable  ${old_prompt}|y/n ?
    issh.set_prompt    ${new_prompt}    alias=${alias}

    ${add_cmd}   Set Variable   /opt/nokia/bin/dataprovidercli add -u ${http_server_ip}
    ${out}    issh.Execute    command=${add_cmd}   alias=${alias}   check_result=${False}

    Run Keyword If    'y/n' in '''${out}'''    issh.Execute    command=y   alias=${alias}
    issh.set_prompt  ${old_prompt}   alias=${alias}
    ${out}    issh.Execute    command=${get_cmd}   alias=${alias}   check_result=${False}
    Return From Keyword If    '${http_server_ip}' in '''${out}'''


CU Delete DCAP Server White Name List
    [Arguments]    ${dcap_label}=dcap3   ${gnb_index}=0
    [Documentation]    CU Delete DCAP Server White Name List
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-23 | r3li | new |
    ...   | 2022-9-5 | r3li | support ipv6 |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | dcap_label | No | dcap label, default is dcap3 |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   *Example*
    ...   | CU Delete DCAP Server White Name List | dcap3 | 0 |
    ${alias}    Connect To CU K8S Master With Tenant
    ${pod_name}    Get CU Full Pod Name By Pod Abbreviation    pod_abbr=oamext    alias=${alias}    gnb_index=${gnb_index}
    ${container_name}     Get CU Full Container Name By Container Abbreviation    ctr_abbr=providercontroller
    ${namespace}   Get Cu Namespace From Testline    gnb_index=${gnb_index}
    ${cu_oam_ip}    Get vCU OAM Ip    gnb_index=${gnb_index}
    ${ip_type}    Set Variable If    ':' in '${cu_oam_ip}'    ipv6    ipv4
    _Delete DCAP Server White Name List   alias=${alias}   namespace=${namespace}   pod_name=${pod_name}
    ...    container_name=${container_name}   dcap_label=${dcap_label}    ip_type=${ip_type}
    [Teardown]  Disconnect Interactive Connections


vDU Delete DCAP Server White Name List
    [Arguments]    ${dcap_label}=dcap3   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    vDU Delete DCAP Server White Name List
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-27 | r3li | new |
    ...   | 2022-9-5 | r3li | support ipv6 |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | dcap_label | No | dcap label, default is dcap3 |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   *Example*
    ...   | vDU Delete DCAP Server White Name List | dcap3 | 0 | 0 |
    ${alias}    get unique id
    ${alias}    Connect To K8s Master Interactively    gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    ${pod_name}    Get Full Pod Name By Container Abbreviation Interactively    container_abbr=providercontroller
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${container_name}     Get Full Container Name By Container Abbreviation    ctr_abbr=providercontroller
    ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${namespace}   Get vDu Namespace From Testline    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_oam_ip}    Get vDU OAM Ip    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ip_type}    Set Variable If    ':' in '${vdu_oam_ip}'    ipv6    ipv4
    _Delete DCAP Server White Name List   alias=${alias}   namespace=${namespace}   pod_name=${pod_name}
    ...    container_name=${container_name}   dcap_label=${dcap_label}    ip_type=${ip_type}

    [Teardown]  Disconnect Interactive Connections


_Delete DCAP Server White Name List
    [Arguments]    ${alias}    ${namespace}    ${pod_name}   ${container_name}    ${dcap_label}   ${ip_type}
    ${bash_cmd}   Set Variable    kubectl -n ${namespace} exec -it ${pod_name} -c ${container_name} -- bash
    ${out}    issh.Execute    command=${bash_cmd}    alias=${alias}   check_result=${False}
    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}
    ...    Get Appointed Dcap Http Info    ${dcap_label}    ${ip_type}
    ${del_cmd}   Set Variable    /opt/nokia/bin/dataprovidercli delete -u ${http_server_ip}
    issh.Execute    command=${del_cmd}   alias=${alias}   check_result=${False}
    ${get_cmd}   Set Variable    /opt/nokia/bin/dataprovidercli show | grep ${http_server_ip}
    ${out}    issh.Execute    command=${get_cmd}   alias=${alias}   check_result=${False}
    Run Keyword If    '${http_server_ip}' in '''${out}'''   fail    cu delete dcap server route failure.


Start Capture Log By Dcap With Rest Api
    [Arguments]    ${alias}    ${nr_cell_list}=${None}    ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    ...    ${duration}=-1   ${ne_type}=vdu    ${gnb_index}=0    ${vdu_index}=0    ${dcap_label}=dcap3
    ...    ${control_plane_interface}=${None}   ${is_tls}=${False}
    [Documentation]    Start Capture Log By Dcap With Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   | 2022-6-23 | r3li | This parameter is mutually exclusive with vdu_custom_profile/vcu_custom_profile |
    ...   | 2022-2-7 | r3li | optmize keyword for api field changes |
    ...   | 2023-5-11 | r3li | update keyword for with tls case. |
    ...   | 2023-5-23 | eahsuan | modify ${create_info}[id] to ${create_info}[tracer_id] . |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | Yes | dcap connecting object |
    ...   | nr_cell_list | No | nr cell list, deault is None will select all cells. |
    ...   | vdu_custome_profile | No | vdu custome profile info, can be snapshotVdu, L2Ps_Component, L2Lo_Component,
    ...                                           L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa,
    ...                                           L2HiRlc_Sherpa, L2HiPdcp_Sherpa |
    ...   | vcu_custome_profile | No | vdu custome profile info, can be snapshotVcu, L2Ps_Component, L2Lo_Component,
    ...                                           L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa,
    ...                                           L2HiRlc_Sherpa, L2HiPdcp_Sherpa
    ...   | duration | No | trace time, default value is -1. when it's default value, you have to call stop trace |
    ...   | ne_type | No | only support vdu |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   | dcap_label | No | dcap label, default is dcap3 |
    ...   | control_plane_interface | No | default value None is Automatic detection; True--Force common; False--Force old |
    ...   | if want this parameter valid, please set vdu_custom_profile=None and vcu_custom_profile=None |
    ...   | is_tls | No | is tls environment, default value is False. If Set True, dcap and NE need support tls |
    ...   *Return*
    ...   - trace id
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${trace_id} | Start Capture Log By Dcap With Rest Api | ${connection} | [L2Ps_Component] | None | -1 | vdu | 0 | 0 |
    ...   | ${zip_file_path} | Stop And Save Trace Log By Dcap With Rest Api | ${connection} | ${trace_id} |
    ...   | ${pcap_file_list} | Unzip Trace Log File | ${zip_file_path} |
    Run Keyword If   '${ne_type.upper()}'=='VDU'    VDU Online Add DCAP Server Route On TNL-3    vdu_index=${vdu_index}
    ...    gnb_index=${gnb_index}    dcap_label=${dcap_label}
    ...    ELSE IF   '${ne_type.upper()}'=='CU'    log to console    need to adapt.
    ...    ELSE   fail    not support this ne_type
    Run Keyword If   '${ne_type.upper()}'=='VDU' and '${is_tls}'=='${False}'    vDU Add DCAP Server White Name List    vdu_index=${vdu_index}
    ...    gnb_index=${gnb_index}    dcap_label=${dcap_label}
    ...    ELSE IF   '${ne_type.upper()}'=='CU' and '${is_tls}'=='${False}'     CU Add DCAP Server White Name List    gnb_index=${gnb_index}
    ...    dcap_label=${dcap_label}

    ${bts_info}    Get Bts Info By Appointed Ip   ${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...   ne_type=${ne_type}
    ${bts_info}    _Set Nr Cell Info To Bts Info    ${bts_info}    ${nr_cell_list}
    ${bts_info}   Create List   ${bts_info}
    ${create_info}    Run Keyword If    '''${vdu_custom_profile}'''=='''${None}''' and '''${vcu_custom_profile}'''=='''${None}'''
    ...    dcap_rest.start_trace
    ...    bts=${bts_info}
    ...    control_plane_interface=${control_plane_interface}
    ...    gnb_trace_profile=dcap-lite-default
    ...    connection=${alias}
    ...  ELSE IF  '''${vdu_custom_profile}'''!='''${None}''' and '''${vcu_custom_profile}'''=='''${None}'''
    ...    dcap_rest.start_trace
    ...    bts=${bts_info}
    ...    duration=${duration}
    ...    connection=${alias}
    ...    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vdu_custom_profile}'''=='''${None}''' and '''${vcu_custom_profile}'''!='''${None}'''
    ...    dcap_rest.start_trace
    ...    bts=${bts_info}
    ...    duration=${duration}
    ...    connection=${alias}
    ...    vcu_custom_profile=${vcu_custom_profile}
    ${trace_id}    Set Variable     ${create_info}[tracer_id]
    [Return]    ${trace_id}

Stop And Save Trace Log By Dcap With Rest Api
    [Arguments]    ${alias}    ${trace_id}
    [Documentation]    Stop And Save Trace Log By Dcap With Rest Api(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | Yes | dcap connecting object |
    ...   | trace_id | Yes | trace id that get by Start Capture Log By Dcap With Rest Api |
    ...   *Return*
    ...   - trace id
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${trace_id} | Start Capture Log By Dcap With Rest Api | ${connection} | [L2Ps_Component] | None | -1 | vdu | 0 | 0 |
    ...   | ${zip_file_path} | Stop And Save Trace Log By Dcap With Rest Api | ${connection} | ${trace_id} |
    ...   | ${pcap_file_list} | Unzip Trace Log File | ${zip_file_path} |

    run keyword and ignore error    dcap_rest.stop_trace    trace_id=${trace_id}    connection=${alias}
    sleep    200
    ${file_path}    Get A Directory    dcap
    ${zip_file_path}    dcap_rest.get_results    result_id=${trace_id}    target_dir=${file_path}    connection=${alias}
    [Return]    ${zip_file_path}


Unzip Trace Log File
    [Arguments]    ${zip_file_path}    ${file_suffix}=pcap   ${is_need_latest}=${False}
    [Documentation]    Unzip Trace Log File
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   | 2022-6-23 | r3li | support get log with different suffix and can choose is need get latest log |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | zip_file_path | Yes | trace log path |
    ...   | file_suffix | No | file suffix, such as pcap, 5gm |
    ...   | is_need_latest | No | is need get latest file, if true, get one log, otherwise get all log |
    ...   *Return*
    ...   - a list that contains all trace log full path.
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${trace_id} | Start Capture Log By Dcap With Rest Api | ${connection} | [L2Ps_Component] | None | -1 | vdu | 0 | 0 |
    ...   | ${zip_file_path} | Stop And Save Trace Log By Dcap With Rest Api | ${connection} | ${trace_id} |
    ...   | ${pcap_file_list} | Unzip Trace Log File | ${zip_file_path} | pcap | False |
    ${get_name_command}    set variable    zip -sf ${zip_file_path} | grep ${file_suffix}
    ${file_name}    OperatingSystem.Run   command=${get_name_command}
    ${file_name_list}    Split String    ${file_name}    \n
    ${file_path}    Get A Directory    ${file_suffix}
    ${unzip_command}     set variable    unzip ${zip_file_path} "*${file_suffix}" -d ${file_path}
    OperatingSystem.Run   command=${unzip_command}
    ${full_path_list}    Create List
    FOR  ${path}  IN  @{file_name_list}
        ${path}    Strip String    ${path}
        ${full_path}    Join Path     ${file_path}    ${path}
        File Should Exist    ${full_path}
        Append to List    ${full_path_list}    ${full_path}
    END
    Sort List   ${full_path_list}
    ${full_path_list}    Set Variable If    '${is_need_latest}'=='${False}'    ${full_path_list}     ${full_path_list}[-1]
    [Return]    ${full_path_list}


_Set Nr Cell Info To Bts Info
    [Arguments]    ${bts_info}   ${nr_cell_list}=${None}
    ${nr_cell_list}    convert_list    ${nr_cell_list}
    ${all_nr_cell_list}    Set Variable    ${bts_info}[nrCells]
    List Should Contain Sub List    ${all_nr_cell_list}    ${nr_cell_list}    set nr cell info not exist.
    Run Keyword If   '${nr_cell_list.__len__()}'!='0'   set_to_multiple_dictionary    ${bts_info}    nrCells    ${nr_cell_list}
    [Return]    ${bts_info}


Get Bts Info By Appointed Ip
    [Arguments]    ${alias}    ${gnb_index}=0   ${vdu_index}=0    ${ip_address}=${None}    ${ne_type}=vdu
    [Documentation]    Get Bts Info By Appointed Ip
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   | 2022-6-23 | r3li | support get bts info with cu |
    ...   | 2022-11-18 | r3li | optmize keyword for api field changes |
    ...   | 2023-2-7 | r3li | optmize keyword for api field changes |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | alias | Yes | dcap connecting object |
    ...   | gnb_index | No | gnb index, default is 0 |
    ...   | vdu_index | No | vdu index, default is 0 |
    ...   | ip_address | No | default is None will get info from OAM ip which difined in __init__.py |
    ...   | ne_type | No | must be vdu or cu, its decided get vdu info or cu if ip address is None |
    ...   *Return*
    ...   - bts info
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${bts_info} | Get Bts Info By Appointed Ip | ${connection} | 0 | 0 | None | vdu |

    ${all_bts_info}    dcap_rest.get_all_bts_info    connection=${alias}
    ${oam_http_info}    Run Keyword If    '${ne_type.upper()}'=='VDU'   Get VDU OAM Http Connection Info  gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ...    ELSE IF   '${ne_type.upper()}'=='CU'   Get VCU OAM Http Connection Info  gnb_index=${gnb_index}
    ...    ELSE   fail    not support this ne_type
    ${ip_address}    Set Variable If    '${ip_address}'=='${None}'    ${oam_http_info}[addr]    ${ip_address}
    ${flag}    Set Variable   ${0}
    FOR   ${info}   IN    @{all_bts_info}
        ${flag}    Set Variable If    '${info}[host]'=='${ip_address}'    ${1}    ${0}
        Exit For Loop If    '${info}[host]'=='${ip_address}'
    END
    Run Keyword If    '${flag}'=='${0}'    fail    Not found bts info of ${ip_address}
    ${get_nr_cells}    Set Variable    ${info}[nr_cells]
    ${nr_cells}    Create List
    FOR    ${nr_cell}    IN     @{get_nr_cells}
        Append To List    ${nr_cells}    ${nr_cell}[internal_id]
    END
    ${bts_info}   Create Dictionary    nrCells=${nr_cells}   username=${oam_http_info}[username]
    ...   password=${oam_http_info}[password]   id=${info}[id]
    ...   port=${info}[port]   host=${ip_address}
    ...   alias=${info}[alias]
    [Return]    ${bts_info}


Delete Bts In Dcap By Rest Api
    [Arguments]    ${bts_id}    ${alias}
    [Documentation]    Get Bts Info By Appointed Ip(Basic)
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-5-20 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | bts_id | Yes | bts id |
    ...   | alias | Yes | dcap connecting object |
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | ${bts_info} | Delete Bts In Dcap By Rest Api | 1 | ${connection} |

    dcap_rest.delete_bts    bts_id=${bts_id}    connection=${alias}


_Delete Existed Bts By Rest Api
    [Arguments]    ${ip_addr}   ${alias}
    [Documentation]    Delete Existed Bts By Rest Api
    ...   *Author*    rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 2022-6-17 | r3li | new |
    ...   *Argument Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ip_addr | Yes | ip address |
    ...   | alias | Yes | dcap connecting object |
    ...   *Example*
    ...   | ${connection} | Connect to Dcap By Rest Api | None | dcapv3 | True |
    ...   | Delete Existed Bts By Rest Api | 1.1.1.1 |${connection} |
    ${all_bts_info}    dcap_rest.get_all_bts_info    connection=${alias}
    ${exist_bts_id}    Set Variable    ${None}
    FOR   ${bts_info}   IN    @{all_bts_info}
        ${exist_bts_id}    Set Variable If    '${bts_info}[host]'=='${ip_addr}'   ${bts_info}[id]
        Exit For Loop If    '${bts_info}[host]'=='${ip_addr}'
    END
    Run Keyword If    '${exist_bts_id}'!='${None}'    dcap_rest.delete_bts   bts_id=${exist_bts_id}  connection=${alias}

Get Remaning Time For Generating DCAP Basic New Folder
    [Arguments]    ${internal_value}
    [Documentation]    Get Remaning Time For Generating DCAP Basic New Folder(Commercial)
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <28-Jul-2022>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | internal_value | Yes | the interval that DCAP Basic new folder generated |
    ...    *RETURN VALUE*
    ...    remaining time that DCAP Basic New Folder will generate
    ...    Example
    ...    | ${value}= | Get Remaning Time For Generating DCAP Basic New Folder |  10  |
    ${alias}  get unique id
    ${http_server_ip}   ${http_server_port}   ${http_server_username}  ${http_server_password}    Get Appointed Dcap Http Info    dcap_label=dcap3
    issh.Connect_To   ip=${http_server_ip}
      ...   username=${http_server_username}
      ...   password=${http_server_password}
      ...   prompt=\\[dcapuser@dcapbasic-nesc-master\\s\\S+\\]\\$|bash-\\d\\.\\d\\$\\s
      ...   alias=${alias}
      ...   width=200
    ${ret}=    issh.Execute    command=date +"%Y-%m-%d %H:%M:%S"   alias=${alias}
    ${matches}    Get Regexp Matches    ${ret}    \\d{4}-\\d{2}-\\d{2} \\d{2}:(\\d{2}):\\d{2}  1
    ${minute}=  convert to integer   ${matches[0]}
    ${minute_1} =    Evaluate    ${minute}%${internal_value}
    ${remain}=     Evaluate    ${internal_value} - ${minute_1}
    [return]    ${remain}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}
