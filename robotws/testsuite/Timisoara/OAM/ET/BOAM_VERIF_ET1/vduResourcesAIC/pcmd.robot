*** Settings ***
Documentation
...   author: huilin.xu@nokia-sbell.com
...   contact: huilin.xu@nokia-sbell.com
...   pcmd common keyword





#*** Variables ***


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
    ...  operation=replace

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_3}
    ...  operation=add

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}   mo_name=NRCTRLTSDU-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1   mo_name=NRMTRACEDU-1

    ${NRMTRACEDU_Info_1}=   create dictionary    jobType=TraceOnly  scope=allResources
    ${NRMTRACEDU_Info_2}=   create dictionary   actPCMDReporting=true  nrTceIdentifier=1  cellMaxActiveUEsTraced=2
    ${nrRanTraceReference_Info}    create dictionary    nrRanTraceReference/0/mcc=262  nrRanTraceReference/0/mnc=3
    ...   nrRanTraceReference/0/mncLength=2   nrRanTraceReference/0/traceId=1

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_1}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_2}
    ...  operation=replace

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${nrRanTraceReference_Info}
    ...  operation=replace

    ${actPCMDReport_true}    Create Dictionary    actPCMDReport=true

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/
    ...  updated_paras_dict=${actPCMDReport_true}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${True}


Enable IPv6 PCMD Status On VDU
    [Arguments]  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Enable IPv6 PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    Example
    ...    | Enable IPv6 PCMD Status On VDU |
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

    ${TCE_Info_1}=   create dictionary  tceIpAddress=${DCAP_IPv6}   tcePortNumber=${DCAP_PORT}
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
    ...  operation=replace

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ...  updated_paras_dict=${TCE_Info_3}
    ...  operation=add

    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}   mo_name=NRCTRLTSDU-1
    Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1   mo_name=NRMTRACEDU-1

    ${NRMTRACEDU_Info_1}=   create dictionary    jobType=TraceOnly  scope=allResources
    ${NRMTRACEDU_Info_2}=   create dictionary   actPCMDReporting=true  nrTceIdentifier=1  cellMaxActiveUEsTraced=2
    ${nrRanTraceReference_Info}    create dictionary    nrRanTraceReference/0/mcc=262  nrRanTraceReference/0/mnc=3
    ...   nrRanTraceReference/0/mncLength=2   nrRanTraceReference/0/traceId=1

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_1}
    ...  operation=add

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${NRMTRACEDU_Info_2}
    ...  operation=replace

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${NRDU_dist_name}/NRCTRLTSDU-1/NRMTRACEDU-1
    ...  updated_paras_dict=${nrRanTraceReference_Info}
    ...  operation=replace

    ${actPCMDReport_true}    Create Dictionary    actPCMDReport=true

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/
    ...  updated_paras_dict=${actPCMDReport_true}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${True}

Update PCMD Status On VDU
    [Arguments]   ${actPCMDReport_expected}  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Update PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
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
    set test variable    ${NRBTS_MO_DN}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

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
    ${sessions}   issh.Execute   command=netstat -tan | grep ${DCAP_PORT}   alias=${alias}
    ${sessions}  strip prompt  ${sessions}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}

Check IPv6 PCMD Session Status
    [Arguments]  ${setup}=${true}  ${vdu_index}=0
    [Documentation]  Check IPv6 PCMD Session Status
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <28-Jun-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  setup | No |  setup status, default is ${true}, means vdu is connected dcap server |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  Check IPv6 PCMD Session Status |

    ${ip_info}  Get VDU OAM Http Connection Info  vdu_index=${vdu_index}
    ${ip}  Set Variable   ${ip_info['addr']}
    ${alias}  get unique id
    Connect To DCAP   alias=${alias}
    ${sessions}   issh.Execute   command=/usr/sbin/ss -tnp | grep ${DCAP_PORT}   alias=${alias}
    ${sessions}  strip prompt  ${sessions}
    log to console   ${sessions}
    ${exists}   Run Keyword and Return Status   Should Contain   ${sessions}   ${ip}
    Should Be Equal   ${exists}   ${setup}
    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}


Disable PCMD Status On VDU
    [Arguments]  ${vdu_index}=0
    [Teardown]   Run Keyword And Ignore Error  VDU Rest Logout  vdu_index=${vdu_index}
    [Documentation]   Disable PCMD Status On VDU
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    Example
    ...    | Disable PCMD Status On VDU |
    ...
    vDU Rest Login  vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${MRBTS_ID}  set variable      ${vdu_conf["mrbts_id"]}


    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    Configure DU Delete Dcap Server MO And PCMD MO      scf_path=${scf_file_with_fullpath}    plan_id=${plan_id}

    ${actPCMDReport_false}    Create Dictionary    actPCMDReport=false

    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/
    ...  updated_paras_dict=${actPCMDReport_false}
    ...  operation=add

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${True}






Configure DU Delete Dcap Server MO And PCMD MO
    [Arguments]  ${scf_path}    ${plan_id}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${matches_1}     Get Regexp Matches    ${scf_content}   .*TCE"\\s+distName="MRBTS-(\\d+)/MNL-1/TCEADM-1/TCE-1"\\s+.*
    ${matches_2}     Get Regexp Matches    ${scf_content}   .*TCEADM"\\s+distName="MRBTS-(\\d+)/MNL-1/TCEADM-1"\\s+.*

    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_path}
    ${MRBTS_ID}  set variable      ${vdu_conf["mrbts_id"]}
    ${NRDU_dist_name}    Set Variable    MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf['nrbts_id']}/NRDU-${vdu_conf['nrdu_id']}

    ${distname_1}  Set Variable    MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1/TCE-1
    ${distname_2}  Set Variable    MRBTS-${MRBTS_ID}/MNL-1/TCEADM-1

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




Get Latest Trace File Name of DU On Dcap Server
    [Arguments]  ${vdu_index}=0
    [Documentation]  Get Latest Trace File Name of DU On Dcap Server
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


Download Newest Trace Files of DU From Dcap Server
    [Arguments]  ${vdu_index}=0
    [Documentation]  Download Newest Trace Files of DU From Dcap Server
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <27-Jul-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  connection  | No |  connection alais, default is dcap_server |
    ...    *RETURN VALUE*
    ...    local dcap log file path or ${EMPTY}
    ...    Example
    ...    |  Download Newest Trace Files of DU From Dcap Server |
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

Get Remaning Time For Generating DCAP New Folder
    [Arguments]    ${internal_value}
    [Documentation]    Get Remaning Time For Generating DCAP New Folder
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

Get Real Rnti_Number
    [Arguments]  ${rnti_number_list}   ${emil_txt_log}
    [Documentation]    Get Real Rnti_Number
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <27-Jul-2021>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | rnti_number_list | Yes | the possible rnti_number_list|
    ...    | emil_txt_log     | Yes | the emil txt log path|
    ...    *RETURN VALUE*
    ...    real_rnti_number
    ...    Example
    ...    | ${real_rnti_number}    Get Real Rnti_Number       ${rnti_number_list}   ${emil_txt_log}|
    ${alias}  get unique id
    Connect To Ute Locally  alias=${alias}
    ${real_rnti_number}   set variable   ${0}
    FOR   ${item}   IN   @{rnti_number_list}
       ${out}  issh.Execute  command=cat ${emil_txt_log}|grep ${item}|wc -l  alias=${alias}
       ${out}  Strip Prompt  ${out}
       ${real_rnti_number}=  run keyword if  ${out}>=1  set variable  ${item}
    END
    [Return]  ${real_rnti_number}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias}

Add Object NRMTRACECU And NRRESOURCECU On CU
    #[Arguments]    ${lncell_id}=1
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Add Object NRMTRACECU And NRRESOURCECU On CU
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   |  lncell_id         | Yes | 1,2,3...,default is 1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Add Object NRMTRACECU And NRRESOURCECU On CU |
	${vdu_conf}   Get VDU Conf From SCF
    ${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
    CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
	${vdu_conf}   Get VDU Conf From SCF
    ${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
	${mo_dn}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1
	${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.nrbts:NRCTRLTS
	${nidd}  convert to string  ${nidd_id}
	${instance}  convert to integer  1
    cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False

	${mo_dn_1}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
	${uuid_1}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1
    ${nidd_id_1}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.nrbts:NRMTRACECU
	${nidd_1}  convert to string  ${nidd_id_1}
	${instance_1}  convert to integer  1

    cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid_1}
    ...  	nidd_id=${nidd_1}   instance_id=${instance_1}  include_defaults=False

    &{actCellTraceReportingCU}    create dictionary    operation_type=add    parameter_path=/actCellTraceReportingCU    value=true
	@{actCellTraceReportingCU_list}=    Create List  ${actCellTraceReportingCU}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_1}    ${actCellTraceReportingCU_list}

    &{actPCMDReporting}    create dictionary    operation_type=add    parameter_path=/actPCMDReporting    value=false
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

	&{scope}    create dictionary    operation_type=add    parameter_path=/scope    value=specificResources
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

	${mo_dn_2}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1
	${uuid_2}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
    ${nidd_id_2}   _Get CU Specifical NIDD ID    name=com.nokia.srbts.nrbts:NRRESOURCECU
	${nidd_2}  convert to string  ${nidd_id_2}
	${instance_2}  convert to integer  1

    cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid_2}
    ...  	nidd_id=${nidd_2}   instance_id=${instance_2}  include_defaults=False

	&{nrResourceCuId}  create dictionary  operation_type=add    parameter_path=/nrResourceCuId     value=1
    @{nrResourceCuId_list}=    Create List  ${nrResourceCuId}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_2}    ${nrResourceCuId_list}

	&{resourceDN}  create dictionary  operation_type=add    parameter_path=/resourceDN     value=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{resourceDN_list}=    Create List  ${resourceDN}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_2}    ${resourceDN_list}

	&{typeNrCu}  create dictionary  operation_type=add    parameter_path=/typeNrCu     value=cell
    @{typeNrCu_list}=    Create List  ${typeNrCu}
	CU Update Delta Plan Should Be Successful    ${delta_plan_id}    ${mo_dn_2}    ${typeNrCu_list}

	CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    CU Activate Delta Plan Should Be Successful    ${delta_plan_id}


Delete Object NRMTRACECU On CU
    [Arguments]
    [Teardown]   Run Keyword And Ignore Error  CU Rest Logout
    [Documentation]   Delete Object NRMTRACECU On CU
    ...    *AUTHOR* eahsuan.xuan@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Delete Object NRMTRACECU On CU |
	${vdu_conf}   Get VDU Conf From SCF
    ${MRBTS_ID}   set variable   ${vdu_conf["mrbts_id"]}
	CU Rest Login
	${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
	CU Delete Delta Plan Managed Object Should Be Successful    ${delta_plan_id}    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCTRLTS-1/NRMTRACECU-1
	CU Validate Delta Plan Should Be Successful    ${delta_plan_id}
    CU Activate Delta Plan Should Be Successful    ${delta_plan_id}



############################## PCMD Log End ##############################
====== PCMD Log End ======
     Log To Console  \n*** only used for readable ***






