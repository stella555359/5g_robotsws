*** Settings ***
Documentation
...  keywords for handling nsp related features
...
...  author/contact: luofei.tu@nokia-sbell.com



*** Keywords ***

Set NSP
    [Documentation]    Set NSP version
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  stream  | No |  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Set NSP |
    [Arguments]  ${stream}
    run keyword if  '${stream}'=='5G19A'  set suite variable  ${nsp_ip}  ${nsp_ip_19A}
    run keyword if  '${stream}'=='5G19B'  set suite variable  ${nsp_ip}  ${nsp_ip_19B}
    log  ${nsp_ip}

Check branch and set NSP
    ${stream}=  split_enb_build    ${ENB_BUILD}    prefix
    Set NSP  ${stream}

Connect to NSP with xml api
     [Documentation]    Set NSP version
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  ip  | Yes | nsp ip |
    ...    |  user  | No | nsp xml api user |
    ...    |  pass  | No | nsp xml api password |
    ...    |  port  | No | nsp xml api port|
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Connect to NSP with xml api   ip=10.97.123.115 |
    [Arguments]
    ...             ${ip}=${nsp_ip}
    ...             ${user}=xml_api_user
    ...             ${pass}=A0zY~rP#8Mx@
    ...             ${port}=8443
    nfmp.setup   ip=${ip}    username=${user}    password=${pass}   port=${port}

Activate vnf from NSP
     [Documentation]    Activate vnf from NSP
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  mrbts_id  | Yes |  ie. “MRBTS-1900” |
    ...    |  connection   | No | NfmpConnectionFacade instance or if used, string name is alias|
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Activate vnf from NSP   mrbts_id=MRBTS-1900|
    [Arguments]  ${mrbts_id}
    log to console  MRBTS-${mrbts_id}
    nfmp.set_vnf_to_active  MRBTS-${mrbts_id}


Deactivate vnf from NSP
     [Documentation]    Deactivate vnf from NSP
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  mrbts_id  | Yes |  ie. “MRBTS-1900” |
    ...    |  connection   | No | NfmpConnectionFacade instance or if used, string name is alias|
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Deactivate vnf from NSP   mrbts_id=MRBTS-1900|
    [Arguments]  ${mrbts_id}
    log to console  MRBTS-${mrbts_id}
    nfmp.set_vnf_to_standby  MRBTS-${mrbts_id}

Update from peer node by NSP
     [Documentation]    Update from peer node by NSP
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  mrbts_id  | Yes |  ie. “MRBTS-1900” |
    ...    |  connection   | No | NfmpConnectionFacade instance or if used, string name is alias|
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Update from peer node by NSP    mrbts_id=MRBTS-1900  |
    [Arguments]  ${mrbts_id}
    log to console  MRBTS-${mrbts_id}
    nfmp.update_from_peer_node  MRBTS-${mrbts_id}
	
Get all alarms by nsp
    [Documentation]    get all alarms from nsp
    ...  author:             luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  stream  | No |  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Get all alarms by nsp |
    ${nsp_alarms}=   nfmp.get_alarms
    [Return]  ${nsp_alarms}


