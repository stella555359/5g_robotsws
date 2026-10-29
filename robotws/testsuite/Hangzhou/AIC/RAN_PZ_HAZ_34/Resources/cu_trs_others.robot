*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_trs_others.robot
...




*** Variables ***



*** Keywords ***
Download File From VDU Container
    [Arguments]  ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}   ${filename}=${EMPTY}   ${local_filename}=${EMPTY}   ${gnb_index}=0     ${vdu_index}=0
    [Teardown]   run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]    Download File From VDU Container
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   3.8.2021,chris.l.cao@nokia-sbell.com, support to not-using pod_abbr
    ...   26.10.2021,hongyuan.sun@nokia-sbell.com,
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr  |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...    | filename  | yes | filename, remote file absolute file name in VDU container |
    ...    | local_filename | No | local_filename. Default value is ${EMPTY}, it means a temporary file will be created and returned |
    ...    | gnb_index | No | gnb_index. Default value is 0 |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    local UTE's file name where is the content of remote file in vdu container
    ...
    ...    Example
    ...   | ${local_file} | Download File From VDU Container | container=logstorageserver | filename=/var/log/audit/auditlog |   |
    ...   | ${local_file} | Download File From VDU Container | pod_abbr=logservice | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ${local_file} | Download File From VDU Container | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ... |  local_filename=/tmp/abc.log |
    ...   | ${local_file} | Download File From VDU Container | pod_abbr=logservice | container=logstorageserver | filename=/var/log/audit/auditlog |
    ...   | ... |  local_filename=/tmp/abc.log |
    ...
    should not be empty  ${container}
    should not be empty  ${filename}

    ${container_full_name}     Get Full Container Name By Container Abbreviation  ctr_abbr=${container}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ns}  Get vDU Namespace From TestLine   vdu_index=${vdu_index}
    ${alias}  get unique id
    Connect To K8s Master Interactively  alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_abbr}  Run Keyword If  "${pod_abbr}"=="${EMPTY}"  get pod abbreviation by container abbreviation   container_abbr=${container}
    ...    ELSE   set variable   ${pod_abbr}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively  pod_abbr=${pod_abbr}   alias=${alias}  vdu_index=${vdu_index}

    ${path2} 	${file}  OperatingSystem.split path   ${filename}
    ${remote_filename}  Get A Remote File   ${file}  alias=${alias}

#    ${cmd}  Set Variable If   "${container}"=="logstorageserver"
#       ...   kubectl exec ${pod_full_name} -c ${container_full_name} -n ${ns} -- /bin/gzip -c ${file_name}|gunzip> ${remote_filename}
#       ...   kubectl cp ${pod_full_name}:${file_name} -c ${container_full_name} ${remote_filename} -n ${ns}
    ${local_ute_filename}  Run Keyword If   "${container}"=="logstorageserver"
    ...   _Download File From VDU Container Misc  ${ns}  ${pod_full_name}  ${remote_filename}  ${local_filename}  ${alias}
    Return From Keyword if  "${container}"=="logstorageserver"  ${local_ute_filename}

    ${cmd}  Set Variable   kubectl cp ${pod_full_name}:${file_name} -c ${container_full_name} ${remote_filename} -n ${ns}
    ${out}  issh.Execute  command=${cmd}    alias=${alias}

    ${local_ute_filename}  Run Keyword If  "${local_filename}"=="${EMPTY}"   get a file   Download_File_From_VDU_Container   ${alias}
    ...   ELSE   Set Variable   ${local_filename}
    issh.download_file   remote_path=${remote_filename}   local_path=${local_ute_filename}   alias=${alias}

    [Return]  ${local_ute_filename}


_Download File From VDU Container Misc
    [Arguments]  ${ns}=${ns}  ${pod_full_name}=${pod_full_name}  ${remote_filename}=${remote_filename}
    ...  ${local_filename}=${local_filename}  ${alias}=${alias}
    ${pvc_volume_cmd}  Set Variable   kubectl get pvc -n ${ns} | grep -i logservice-auditlog |awk '{print $3}'
    ${pvc_volume}  issh.Execute  command=${pvc_volume_cmd}    alias=${alias}
	${pvc_volume}   Get Regexp Matches      ${pvc_volume}    \\S+-pv-\\S+
    ${pod_uid_cmd}  Set Variable   kubectl get pod ${pod_full_name} -n ${ns} -o yaml | grep -i uid | tail -1
    ${pod_uid_tmp}  issh.Execute  command=${pod_uid_cmd}    alias=${alias}
    ${pod_uid_tmp}  Get Regexp Matches      ${pod_uid_tmp}   \\S+\\r
    ${pod_uid}  Set Variable  ${pod_uid_tmp[0].strip('\r')}

    ${cmd}   Catenate  SEPARATOR=  sudo cp -r /var/lib/kubelet/pods/${pod_uid}/volumes/kubernetes.io~local-v
    ...  olume/${pvc_volume[0]}/auditlog ${remote_filename}
    ${out}  issh.Execute  command=${cmd}    alias=${alias}

    ${local_ute_filename}  Run Keyword If  "${local_filename}"=="${EMPTY}"   get a file   Download_File_From_VDU_Container   ${alias}
    ...   ELSE   Set Variable   ${local_filename}
    issh.download_file   remote_path=${remote_filename}   local_path=${local_ute_filename}   alias=${alias}

    [Return]  ${local_ute_filename}
