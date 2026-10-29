*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_sync.robot



*** Variables ***



*** Keywords ***
VDU Sync State Should Be OK
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Documentation]   VDU Sync State Should Be OK
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Sync State Should Be OK |
    ...
    log to console  KW:VDU Sync State Should Be OK
    ${platform_name}   Get Platform Name

    run keyword if   "${platform_name}"=="NCIR"  _VDU Sync State Should Be OK NCIR
     ...   vdu_index=${vdu_index}   restart_sync_service=${restart_sync_service}
    ...   ELSE   _VDU Sync State Should Be OK NCS
     ...   vdu_index=${vdu_index}   restart_sync_service=${restart_sync_service}


_VDU Sync State Should Be OK NCIR
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _VDU Sync State Should Be OK NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _VDU Sync State Should Be OK NCIR |
    ...
    log to console  KW:VDU Sync State Should Be OK NCIR
    #${syncState}  Get VDU Sync State  vdu_index=${vdu_index}
    #should be true  "${syncState}"=="true"

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute  command=cat /etc/ptp4l.conf    alias=${alias_master}
    ${out}   issh.Execute  command=cat /etc/sysconfig/phc2sys    alias=${alias_master}
    ${out}   issh.is_dir   path=/var/run/ptp    alias=${alias_master}
    run keyword if  "${out}"=="${False}"    issh.Execute  command=sudo mkdir -p /var/run/ptp   alias=${alias_master}

    run keyword if   "${restart_sync_service}"=="${True}"   log to console  sudo systemctl restart ptp4l & phc2sys
    ${out}   run keyword if   "${restart_sync_service}"=="${True}"
       ...   issh.Execute   command=sudo systemctl restart ptp4l      alias=${alias_master}
    ${out}   run keyword if   "${restart_sync_service}"=="${True}"
       ...  issh.Execute   command=sudo systemctl restart phc2sys    alias=${alias_master}
    run keyword if   "${restart_sync_service}"=="${True}"    sleep  2

    ${out}   issh.Execute   command=systemctl status ptp4l|grep ptp4l|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $7}'
       ...   alias=${alias_master}
    ${freq}   strip prompt  ${out}
    ${freq}   Parse Number Only From Content   ${freq}
    should not be empty   ${freq}
    ${freq}   evaluate  int(${freq})
    should be true  ${freq}<500

    ${out}   issh.Execute   command=systemctl status ptp4l|grep ptp4l|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $11}'
       ...   alias=${alias_master}
    ${delay}   strip prompt  ${out}
    ${delay}   Parse Number Only From Content   ${delay}
    should not be empty   ${delay}
    ${delay}   evaluate  int(${delay})
    should be true  ${delay}<15

    ${out}   issh.Execute   command=systemctl status phc2sys|grep phc2sys|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $7}'
       ...   alias=${alias_master}
    ${freq}   strip prompt  ${out}
    ${freq}   Parse Number Only From Content   ${freq}
    should not be empty   ${freq}
    ${freq}   evaluate  int(${freq})
    should be true  ${freq}<10

    ${out}   issh.Execute   command=systemctl status phc2sys|grep phc2sys|tail -n 1|awk -F "rms" '{print $2}'|awk '{print $11}'
       ...   alias=${alias_master}
    ${delay}   strip prompt  ${out}
    ${delay}   Parse Number Only From Content   ${delay}
    should not be empty   ${delay}
    ${delay}   evaluate  int(${delay})
    should be true  ${delay}<5


_VDU Sync State Should Be OK NCS
    [Arguments]    ${vdu_index}=0   ${restart_sync_service}=${False}
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _VDU Sync State Should Be OK NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | except_for_build_number | yes | except_for_build_number |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | _VDU Sync State Should Be OK NCS |
    ...
    log to console  KW:VDU Sync State Should Be OK NCS
    ${syncState}      Get VDU Sync State  vdu_index=${vdu_index}
    return from keyword if  "${syncState}"=="OK"

    return from keyword if   "${restart_sync_service}"=="${False}"

    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute  command=kubectl get pod -n ncms|grep "linuxptp-daemon-"|awk '{print $1}'
    ...    alias=${alias_master}
    ${ptp_demon_pod_name}   strip prompt  ${out}

    log to console   kubectl delete pod ${ptp_demon_pod_name} -n ncms
    ${out}   issh.Execute  command=kubectl delete pod ${ptp_demon_pod_name} -n ncms
    ...    alias=${alias_master}

    sleep  5

    Wait Unitl VDU K8s Node Services Up     vdu_index=${vdu_index}


Get VDU Sync State
    [Arguments]    ${vdu_index}=0
    [Documentation]   Get VDU Sync State
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | Get VDU Sync State |
    ...
    log to console  Get VDU Sync State
    ${platform_name}   Get Platform Name

    ${syncState}   run keyword if   "${platform_name}"=="NCIR"    _Get VDU Sync State NCIR   vdu_index=${vdu_index}
    ...   ELSE   _Get VDU Sync State NCS   vdu_index=${vdu_index}

    [Return]  ${syncState}


_Get VDU Sync State NCIR
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _Get VDU Sync State NCIR
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | _Get VDU Sync State NCIR |
    ...
    log to console   _Get VDU Sync State NCIR
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=sudo pmc -u -b 0 -d 24 'GET TIME_STATUS_NP'|grep gmPresent|awk '{print $2}'
       ...   alias=${alias_master}

    ${syncState}   strip prompt  ${out}
    [Return]  ${syncState}


_Get VDU Sync State NCS
    [Arguments]    ${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   _Get VDU Sync State NCS
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   |  ${syncState}  | _Get VDU Sync State NCS |
    ...
    log to console  _Get VDU Sync State NCS
    ${alias_master}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}  alias=${alias_master}

    ${out}   issh.Execute   command=chronyc sources |grep "#* PTP"|wc -l
       ...   alias=${alias_master}

    ${out}   strip prompt  ${out}
    ${syncState}   set variable if   ${out}==1   OK   FAIL
    [Return]  ${syncState}


Get FHGW Sync State via CLI
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Get FHGW Sync State via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${syncStatus} | Get FHGW Sync State via CLI |
    ...
    ${alias}   get unique id
    connect to fhgw  gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}  alias=${alias}
    ${out}   issh.Execute   command=redis-cli get syncStatus   alias=${alias}
    ${syncStatus}   strip prompt  ${out}
    ${syncStatus}   set variable  ${syncStatus.strip("\"")}
    [Return]  ${syncStatus}


FHGW Sync State Should Be Locked
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${fhgw_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   FHGW Sync State Should Be Locked
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index        |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | fhgw_index       |  no | fhgw_index, default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | FHGW Sync State Should Be Locked |
    ...
    ${state}   Get FHGW Sync State via CLI
    should be true   "${state}"=="LOCKED"
