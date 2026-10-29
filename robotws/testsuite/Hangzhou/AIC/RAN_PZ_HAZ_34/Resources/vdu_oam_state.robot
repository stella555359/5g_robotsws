*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_oam_state.robot



*** Variables ***



*** Keywords ***
Get Static Route Info WebEM
    [Arguments]   ${distname}   ${instancedn}
    [Documentation]    Get Static Route Info WebEM
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the configured static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | Get Static Route Info WebEM | distname=MRBTS-5318/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1 |
    ...    | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${destip_par}   set variable if  'IPRTV6' in '''${distname}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  'IPRTV6' in '''${distname}'''    destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  'IPRTV6' in '''${distname}'''    gatewayIpv6Addr   gateway
    ${sr_par}   set variable if  'IPRTV6' in '''${distname}'''    staticIpv6Routes   staticRoutes
    ${gwaddr}   scf.get_all_values_from_scf   dist_name=${distname}   p_name=${gw_par}
    ${route_len}   get length  ${gwaddr}
    VDU Rest Login
    FOR    ${i}    IN RANGE    0    ${route_len}
        ${gateway}   scf.get_value_from_scf   dist_name=${distname}   p_name=${gw_par}   index=${i}
        ${destip}   scf.get_value_from_scf   dist_name=${distname}   p_name=${destip_par}   index=${i}
        ${prefixlen}   scf.get_value_from_scf   dist_name=${distname}   p_name=${prefix_par}   index=${i}
        ${status}   ${tmppref}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${distname}   ${sr_par}/${i}/preference
        ${preference}   set variable if  '${status}'=='PASS'   ${tmppref}   1
        ${exist}   Static Route Exist In Forwarding Entries   gateway=${gateway}   dstip=${destip}
        ...  prefixlength=${prefixlen}   preferenceid=${preference}   instancedn=${instancedn}
        should be true  '${exist}'=='${True}'   Configured static route is not exist in forwarding entries!
    END

Static Route Exist In Forwarding Entries
    [Arguments]   ${gateway}   ${dstip}   ${prefixlength}    ${preferenceid}   ${instancedn}
    [Documentation]    Static Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Static route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Static Route Exist In Forwarding Entries | gateway=2a00:8a00:8000:117:1:2:a47:a651 |
    ...    |   dstip=:: | prefixlength=0 | preferenceid=1 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${gateway}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${gateway}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${gateway}'''   gatewayIpv6Addr   gateway
    ${v6gateway}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${gateway}   :0   :
    ${finalgateway}   set variable if  ':' in '''${gateway}'''   ${v6gateway}   ${gateway}
    ${v6dstip}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${gateway}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}  list_name=forwardingEntries  p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}  list_name=forwardingEntries   p_name=${prefix_par}   index=${i}
        ${status}   ${gw_fw}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/${gw_par}
        ${dest_gw1}   set variable if  '${status}'=='PASS'   ${gw_fw}   ${None}
        ${dest_gw2}   run keyword if  ':' in '''${dest_gw1}'''   Remove String Using Regexp   ${dest_gw1}   :0   :
        ${dest_gw}   set variable if  ':' in '''${dest_gw1}'''   ${dest_gw2}   ${dest_gw1}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'indirect' and '${dest_gw}' == '${finalgateway}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag3}=   Set Variable If   '${indexflag2}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
    #    ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}' and '${preference_fw}' == '${preferenceid}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}'   ${True}   ${False}
       exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}

Direct Route Exist In Forwarding Entries
    [Arguments]   ${dstip}   ${prefixlength}    ${preference}   ${instancedn}
    [Documentation]    Direct Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given direct route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | dstip   | yes | the given direct route destination ip |
    ...    | prefixlength   | yes | the given direct route prefix length |
    ...    | preferenceid   | yes | the given direct route preference for ipv6 route or source ip for ipv4 route |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Direct route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=2a00:8a00:8000:117:1:2:a47:a650 |
    ...    | prefixlength=125 | preferenceid=256 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=10.71.177.72 |
    ...    | prefixlength=29 | preferenceid=10.71.177.74 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV4-1/IPRTV4_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${dstip}'''   destIpv6Addr   destIpAddr
    ${preference_par}   set variable if  ':' in '''${dstip}'''   preference   preSrcIpv4Addr
    ${prefix_par}   set variable if  ':' in '''${dstip}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${v6dstip}   run keyword if  ':' in '''${dstip}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${dstip}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${ipv4flag}   set variable if  ':' not in '''${dstip}'''   ${True}   ${False}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${prefix_par}   index=${i}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'direct' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
        ${preferenceflag}=   Set Variable If   '${ipv4flag}'=='${True}' or '${preference_fw}' == '${preference}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag2}'=='${True}' and '${preferenceflag}' == '${True}'   ${True}   ${False}
        exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}



Is VDU OAM Up
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Is VDU OAM Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...    |  ${status} | Is VDU OAM Up |
    ...
    ${r}   ${out}   Run Keyword And Ignore Error   VDU Rest Login
    ${state}   Set Variable If   "${r}"=="PASS"    ${True}   ${False}

    [Return]   ${state}


VDU Oam Service Should Be Ready
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   VDU Oam Service Should Be Ready
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  30.12.2021,  chris.l.cao@nokia-sbell.com,  initilization
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | No | gnb_index, default is 0 |
    ...    | vdu_index   | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait Until Keyword Succeeds | 480 | 20 | VDU Oam Service Should Be Ready |
    ...
    ${state}   Is VDU OAM Up   gnb_index=${gnb_index}   gnb_index=${gnb_index}
    Should Be True   "${state}"=="${True}"


Get RU Operational State via REST
    [Arguments]   ${ru_index}=0   ${need_rest_login}=${True}
    [Documentation]   Get RU Operational State via REST
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | No | ru_index, default value is 0  |
    ...    | need_rest_login | No | need_rest_login, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${operational_State} | Get RU Operational State via REST |
    ...

    run keyword if  "${need_rest_login}"=="${True}"   vdu rest login
    ${out}   vdu.get_rmods_status
    ${one_ru_info}   set variable  ${out[${ru_index}]}
    ${operational_state}   set variable  ${one_ru_info["operational_state"]}
    [Return]   ${operational_state}


Reset VDU By REST
    [Arguments]  ${need_check_on_air}=${False}   ${wait}=660
    [Documentation]   Reset VDU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.3.2022, chris.l.cao@nokia-sbell.com, extend retry time from 100s to 300s for detecting OAM UP->DOWN
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | need_check_on_air | No | need_check_on_air, default value is ${False}  |
    ...    | wait             | No | wait, default value is 600s  |
    ...
    ...   *RETURN VALUE*
    ...  None
    ...
    ...   Example
    ...  | vDU Rest Login |
    ...  | Reset VDU By REST |
    ...
    log to console  Reset VDU By REST...
    ${out}   vdu.reset_vdu
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error

    ${out}   Reset VDU Status Should Be Successful   operation_id=${out["id"]}
    Run Keyword If    ${need_check_on_air}   Log To Console   Wait OAM down->up->on-air ...
    Run Keyword If    ${need_check_on_air}    Sleep  180

    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  500   20s   VDU Oam Service Should Be Ready
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is up.
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  ${wait}  30s   OAM Precondition Cell Should Be Onair
    Run Keyword If    ${need_check_on_air}   Log To Console   OAM is on-air.


Reset VDU Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Reset VDU Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Reset VDU Status Should Be Successful | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  60   3   _Reset VDU Status Should Be Expected   operation_id=${operation_id}    expected_status=ongoing
    [Return]  ${out}


_Reset VDU Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_vdu_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}



Reset RUs By REST
    [Arguments]   ${rmods_list}   ${vdu_index}=0   ${gnb_index}=0   ${expect_status}=ongoing
    [Documentation]   Reset RUs by rmod id list.
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | vdu rest login |
    ...  |  Reset RUs By REST  |
    ...
    log to console   Reset RUs ${rmods_list} by REST...
    vdu login  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}   vdu.reset_rmods     ${rmods_list}
    Reset RUs Operation Should Be Successful   operation_id=${out["operation_id"]}   expect_status=${expect_status}
    [Teardown]  vdu logout

Reset RUs Operation Should Be Successful
    [Arguments]  ${operation_id}   ${expect_status}=ongoing
    [Documentation]   Reset RUs operation should Be successful
    ...   *AUTHOR* fen.huang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   |  operation_id    | yes |  operation_id  |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  |  Reset RUs Operation Should Be Successful  | operation_id=1 |
    ...
    Wait Until Keyword Succeeds  600   30   _Reset RUs Status Should Be Expected   operation_id=${operation_id}    expected_status=${expect_status}


_Reset RUs Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_rmods_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"

Get RMOD ID List
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get RMOD ID List
    ...   *AUTHOR* zhijiang.shan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    02.02.2023, zhijiang.shan@nokia-sbell.com, moved from case to common KW
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | vdu_index | No | specify which vdu needs to be check if the testline configed multi vdus  |
    ...    | gnb_index | No | specify which vdu needs to be check if the testline configed multi vdus  |
    ...
    ...   *RETURN VALUE*
    ...  Rmod ID list
    ...
    ...   Example
    ...  | ${rmod_id_list} | Get RMOD ID List |
    ...
    vdu login  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${rmod_id_list}=  create list
    ${rmods_info}=   vdu.get_rmods_status
    FOR  ${rmod}  IN  @{rmods_info}
        append to list   ${rmod_id_list}   ${rmod["id"]}
    END
    log to console  ${rmod_id_list}
    [Return]   ${rmod_id_list}
    [Teardown]  vdu logout

Lock RUs Operation Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Lock RUs Operation Should Be Successful
    ...   *AUTHOR* zhijiang.shan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    02.02.2023, zhijiang.shan@nokia-sbell.com, moved from case to common KW
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | operation_id | Yes | operation ID which lock/unlock RUs  |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | vdu login |
    ...  | ${out} | vdu.lock_rmods | ${rmod_id_list} |
    ...  | Lock RUs Operation Should Be Successful | operation_id=${out["id"]} |
    ...  | vdu logout |
    ...
    Wait Until Keyword Succeeds  300   10   _Lock RUs Should Be Successful   operation_id=${operation_id}  expected_status=success

_Lock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_operation_state_of_locking_rmods   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Unlock RUs Operation Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Unlock RUs Operation Should Be Successful
    ...   *AUTHOR* zhijiang.shan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    02.02.2023, zhijiang.shan@nokia-sbell.com, moved from case to common KW
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | operation_id | Yes | operation ID which lock/unlock RUs  |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | vdu login |
    ...  | ${out} | vdu.unlock_rmods  | ${rmod_id_list} |
    ...  | Unlock RUs Operation Should Be Successful | operation_id=${out["id"]} |
    ...  | vdu logout |
    ...
    Wait Until Keyword Succeeds  300   10   _Unlock RUs Should Be Successful   operation_id=${operation_id}    expected_status=success

_Unlock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_operation_of_unlocking_rmods   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Verify Cells Status Should Be Onair With Expected Cell Number
    [Arguments]  ${vdu_index}=0     ${gnb_index}=0   ${expected_cell_number}=1
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    Initialized by calla.wang@nokia-sbell.com,add support container.
    ...    26.11.2020, chris.l.cao@nokia-sbell.com,add check for ${on_line}>=1
    ...    7.6.2021, chris.l.cao@nokia-sbell.com,add parameter expected_cell_number
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | expected_cell_number | No. | expected_cell_number |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number  |
    ...
    ${alias}=  get unique id
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${vdu_cells_summary}=  vdu.get_vdu_cells_summary  vdu_connection=${alias}
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}  0
    Should Be Equal As Numbers  ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}   set variable   ${vdu_cells_summary['availability_status']['on_line']}
    should be true  ${on_line}==${expected_cell_number}
    #should be true  ${on_line}>=1

    [Teardown]  vdu.disconnect   ${alias}


vDU Verify All Cells Status Should Be Onair
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    [Documentation]  vDU Verify All Cells Status Should Be Onair
    ...             the keyword only support rest api v2.
    ...             the checked status are operational_state--disabled
    ...                                 administrative_state--locked
    ...                                 administrative_state--shutting_down
    ...   *Author*: calla.wang@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2020-11-26 | chris.l.cao | add check for ${on_line}>=1 |
    ...   | 2021-7-6 | chris.l.cao | exactly check all cells are on-air |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | vdu_index | Yes | specify which vdu needs to be check if the testline configed multi vdus |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   |  vDU Verify All Cells Status Should Be Onair  |
    ...   |  vDU Verify All Cells Status Should Be Onair  | gnb_index=0 |
    ...   |  vDU Verify All Cells Status Should Be Onair  | gnb_index=0 |  vdu_index=0 |
    #${cell_number}   Get VCU Cell Number From TestLine    gnb_index=${gnb_index}
    ${cell_number}   Get VDU Cell Number From SCF    gnb_index=${gnb_index}   vdu_index=${vdu_index}

    vDU Verify Cells Status Should Be Onair With Expected Cell Number    gnb_index=${gnb_index}    vdu_index=${vdu_index}
     ...   expected_cell_number=${cell_number}


vDU Verify All Cells Status Should Be Onair For All DUs
    [Arguments]   ${gnb_index}=0
    [Documentation]    vDU Verify All Cells Status Should Be Onair For All DUs
    ...    the keyword only support rest api v2.
    ...    the checked status are operational_state--disabled
    ...                           administrative_state--locked
    ...                           administrative_state--shutting_down
    ...    history change: <date>,<who>,<what and how>
    ...    10.6.2021, chris.l.cao@nokia-sbell.com, exactly check all cells are on-air
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | Yes. | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  vDU Verify All Cells Status Should Be Onair For All DUs |
    ...
    ${du_number}   Get vDU Number   gnb_index=${gnb_index}
    FOR   ${i}  IN RANGE   ${du_number}
       vDU Verify All Cells Status Should Be Onair    vdu_index=${i}   gnb_index=${gnb_index}
    END


vDU Get Cells ID list
   [Arguments]  ${vdu_index}=0
   [Documentation]      Get all avaiable cells id list.
    ...  author:   calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    cell id list
    ...    Example
    ...    |  vDU Get Cells ID list  | 0 |
    vDU Rest Login    vdu_index=${vdu_index}
    ${all_cells_id_list}=   create list
    ${cells_info}=  vdu.get_vdu_cells_status
    FOR    ${cell_info}    IN    @{cells_info}
        append to list    ${all_cells_id_list}    ${cell_info["id"]}
    END
   [Return]   ${all_cells_id_list}
   # [Teardown]  vDU Logout


Should be Multiple Cell
    [Documentation]      Should be Multiple Cell
    ...  author:  winnie.su@nokia-sbell.com
    ...    it will check cell numbers
    ...    2021-3-17 first version
    ...    Example
    ...    | Should be Multiple Cell  |
    log to console    check If cell is multiple cells
    VDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id_list}    Get CELL ID List From vDU SCF    scf_path=${scf_file_with_fullpath}
    should be true   ${cell_id_list.__len__()>1}


Get CELL ID List From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]      Get CELL ID List From vDU SCF
    ...  author:  winnie.su@nokia-sbell.com
    ...    it will check cell numbers
    ...    2021-3-17 first version
    ...    Example
    ...   |  ${cell_id_list}  | Get CELL ID List From vDU SCF  |  scf_path |  ${scf_file_with_fullpath}  |
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"   1  2  3
    log to console    ${result}
    @{cell_list}   Evaluate    [i[2] for i in @{result}]
    log to console    @{cell_list}
    [Return]   @{cell_list}


vDU Special Pod Status And Container Number Should Be Expected
    [Arguments]  ${pod_abbr}    ${status}   ${vdu_index}=0   ${alias}=${EMPTY}   ${is_check_number}=true  ${gnb_index}=0
    [Teardown]  run keyword and ignore error  Run Keyword If   "${alias}"=="${EMPTY}"   fast_disconnect  alias=${real_alias}
    [Documentation]   vDU Special Pod Status And Container Number Should Be Expected
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:        <25-Mar-2020>, <huilxu>, <is_check_number added>
    ...  modified by:        <06-May-2022>, <lingtsun>, <update for cran up multi-pod>
    ...  modified by:        <06-Jun-2022>, <lingtsun>, <update for cran rcpsdl multi-pod>
    ...  modified by:        <24-Apr-2023>, <r3li>, <update for multi pods has same abbr>
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod abbreviation, eg, oamcp, up |
    ...    | status          | yes | expected status, it is not case-sensitive, e.g, RUNNING, Running, etc. |
    ...    | vdu_index       | No | vdu_index, default is 0 |
    ...    | is_check_number | No | is_check_number, default is true |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=oamcp | status=Running |
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=up    | status=Running |
    ...    | vDU Special Pod Status And Container Number Should Be Expected | pod_abbr=securestorage    | status=Running |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   get unique id
    ...    ELSE   Set Variable   ${alias}

    Run Keyword If   "${alias}"=="${EMPTY}"     fast_connect_to_k8s_master
      ...   alias=${alias}  vdu_index=${vdu_index}  alias=${real_alias}
    ${command}  Set Variable  kubectl get pod
    ${with_pipeline_command}   Set Variable   |egrep "(-${pod_abbr}-)" |wc -l
    ${pod_number}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${real_alias}
    ${redundency_pod_list}   create list   up  rcpsdl  oamasm  oamcm  oamext  oamconfig  oamfm
    FOR    ${i}    IN RANGE    0    ${pod_number}
       ${pod_index}    set variable if  '${pod_abbr}' in ${redundency_pod_list}
    ...   ${i}   ${EMPTY}
       ${pod_name_list}   Get Full Pod Name By Pod Abbreviation Interactively In Python
    ...  pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${real_alias}   pod_index=${pod_index}
       _Check Pod Status   ${pod_name_list}    ${real_alias}    ${status}   ${is_check_number}   ${gnb_index}   ${vdu_index}
    END

_Check Pod Status
    [Arguments]   ${pod_name_list}    ${real_alias}    ${status}    ${is_check_number}   ${gnb_index}   ${vdu_index}
    FOR   ${full_pod_name}   IN   @{pod_name_list}
       ${command}  Set Variable  kubectl get pod ${full_pod_name}
       ${with_pipeline_command}  Set Variable   |awk '{print $2}'|grep -v READY
       ${actual_ready}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
       ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${real_alias}
       ${actual_ready}   Set Variable  ${actual_ready.strip()}
       Should Not Be Empty   ${actual_ready}
       ${command}  Set Variable  kubectl get pod ${full_pod_name}
       ${with_pipeline_command}  Set Variable   |awk '{print $3}'|grep -v STATUS
       ${actual_status}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
       ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${real_alias}

       ${actual_status}   Set Variable  ${actual_status.strip()}
       Should Not Be Empty   ${actual_status}
       ${matches}   split string  ${actual_ready}   /
       should be true  ${matches.__len__()}==2
       ${running_num}  set variable   ${matches[0]}
       ${total_num}    set variable  ${matches[1]}
       Run keyword if  "${is_check_number}"=="${True}"   should be true   ${running_num}==${total_num}

       ${actual_status}   Set Variable  ${actual_status.strip()}
       Should Be True   "${actual_status}"=="${status}"
    END


Should Be Multiple RUs
    [Documentation]   Should Be Multiple RUs
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Should Be Multiple RUs |
    ...
    log to console    check If cell is multiple RUs
    VDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${ru_id_list}    Get RU ID List From vDU SCF    scf_path=${scf_file_with_fullpath}
    should be true   ${ru_id_list.__len__()}>1   Should Be Multiple RUs!


Get RU ID List From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get RU ID List From vDU SCF
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path  | yes | scf_path |
    ...
    ...    *RETURN VALUE*
    ...    RU id list, e.g, ['1', '2']
    ...
    ...    Example
    ...   |  ${ru_id_list}  | Get RU ID List From vDU SCF  |  scf_path=/tmp/a.scf  |
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/EQM-(\\d+)/APEQM-(\\d+)/RMOD-(\\d+)"   1  2  3  4
    @{ru_list}   Evaluate    [i[3] for i in @{result}]
    [Return]   @{ru_list}


Wait For RU Operational State Is Enabled
    [Arguments]  ${detection_time}=400
    [Documentation]   Wait For RU Operational State Is Enabled
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | detection_time  | no | detection_time, default is 120s |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Wait For RU Operational State Is Enabled |
    wait until keyword succeeds   ${detection_time}   10s   _Wait For RU Operational State Is Enabled Check Once


_Wait For RU Operational State Is Enabled Check Once
    ${operational_state}    Get RU Operational State via REST
    log to console   operational_state:${operational_state}
    should be true  "${operational_state}"=="enabled"


Get Cell To L2RT Mapping
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  Get the global cell id list to up pod mapping dict
    ...   *Author:* lingting.sun@nokia-sbell.com
    ...   *Change History*
    ...   | 2023-3-7 | lingtsun | update up to l2rt|
     ...   | 2022-4-14 | lingtsun | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   | vdu_index | NO | int,vdu index, default is 0 |
    ...    *RETURN VALUE*
    ...    cell_to_l2rt_mapping_dict}
    ...   {'176586753': 'po-cran1-up-0', '176586754': 'po-cran1-up-0', '176586755': 'po-cran1-up-0'}
    ...   *Example*
    ...   | cell_to_l2rt_mapping_dict |
    ${pods_info}=    vDU Get Pods Full Info     vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${pods_name_list}=    Get Dictionary Keys    ${pods_info}
    ${pod_list}  create list   @{empty}
    FOR    ${pod}  IN  @{pods_name_list}
       run keyword if    '-up-' in '${pod}' or '-l2rt-' in '${pod}'   Append To List   ${pod_list}   ${pod}
    END
    ${container_name}   Get Full Container Name By Container Abbreviation   ctr_abbr=l2rt
    ...  vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${l2rt_to_cell_mapping}  create dictionary
    FOR    ${pod}    IN    @{pod_list}
        log   ${pod}
        ${log_path}   Collect vDU K8S Logs In Given Pod   ${pod}   l2rt_${pod}    ${container_name}  duration=20s
    ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}
        ${nrcellid_list}=   get_nrcellid_list_from_l2_log   ${log_path}${container_name}.log
        set to dictionary    ${l2rt_to_cell_mapping}    ${pod}    ${nrcellid_list}
    END
    ${cell_to_l2rt_mapping_dict}   utils.Get Cell Global L2rt Mapping Dict     cell_to_l2rt_mapping=${l2rt_to_cell_mapping}
    [return]   ${cell_to_l2rt_mapping_dict}


VDU Block Specify One Cell By REST
    [Arguments]  ${cell_index}=0    ${vdu_index}=0
    [Documentation]    VDU Block Specify One Cell By REST, Will be deprecated
    ...    the keyword only block cell.
    ...    author:  luofei.tu@nokia-sbell.com
    ...    | date | who | what or how |
    ...    | 2022-05-20 | luofei.tu | first version |
    ...    | 2022-07-13 | r3li | add delete blcok operation in teardown |
    ...    | Input Parameters | Man. | Description |
    ...	   | cell_index | No. |cell index, default value is 0, it means it is the first cell |
    ...	   | vdu_index | No. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  VDU Block Specify One Cell By REST  |
    vDU Rest Login    vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id}    Get CELL ID From vDU SCF    scf_path=${scf_file_with_fullpath}    cell_index=${cell_index}
    ${return_info}   vdu.block_cell     ${cell_id}
    Wait until keyword succeeds  10x  5s
    ...   Block Cell Operation Should Be Successful   ${return_info["id"]}
    [Teardown]  Run keywords  vdu.delete_block_cell_operation    ${return_info["id"]}   AND   vDU Rest Logout


Block Cell Operation Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   checking Block Cell Operation Should Be Successful
    ...    *AUTHOR*  luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | operation_id | yes | block operation id |
    ...    *RETURN VALUE*
    ...    None
    ${block_operation_response}=  vdu.get_block_cell_operation_status  ${operation_id}
    should be equal as strings  ${block_operation_response['status']}  success


Unblock Cell Operation Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   checking Unblock Cell Operation Should Be Successful
    ...    *AUTHOR*  luofei.tu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | operation_id | yes | block operation id |
    ...    *RETURN VALUE*
    ...    None
    ${unblock_operation_response}=  vdu.get_unblock_cell_operation_status  ${operation_id}
    should be equal as strings  ${unblock_operation_response['status']}  success


VDU Unblock Specify One Cell By REST
    [Arguments]  ${cell_index}=0   ${vdu_index}=0
    [Documentation]    VDU Unblock Specify One Cell By REST
    ...    the keyword only unblock cell.
    ...    author:  luofei.tu@nokia-sbell.com
    ...    | who | date | what or how |
    ...    | luofei.tu | 2022-05-20 | first version |
    ...    | r3li | 2022-07-13 | add delete unblcok operation in teardown |
    ...    | Input Parameters | Man. | Description |
    ...	   | cell_index | No. |cell index, default value is 0, it means it is the first cell |
    ...	   | vdu_index | No. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  VDU Unblock Specify One Cell By REST |
    vDU Rest Login    vdu_index=${vdu_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${cell_id}    Get CELL ID From vDU SCF    scf_path=${scf_file_with_fullpath}    cell_index=${cell_index}
    ${return_info}   vdu.unblock_cell     ${cell_id}
    Wait until keyword succeeds  10x  5s
    ...   Unblock Cell Operation Should Be Successful   ${return_info["id"]}
    [Teardown]  Run keywords  vdu.delete_unblock_cell_operation    ${return_info["id"]}   AND   vDU Rest Logout


Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Block Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is blocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Block Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Rest Login
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Rest Logout


_Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}   ${alias}=default
    ${out}    get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=${alias}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}   ${alias}=default
    ${out}    get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=${alias}
    Should Be True    "${out["status"]}"=="${expected_status}"


Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Unblock Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is unblocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unblock Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Rest Login
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...                                                     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Rest Logout


Get SW Update Xml of ALD
    [Arguments]   ${file_path}   ${ald_sw_update_info_list}
    [Documentation]  Get SW Update Xml of ALD
    ...   *Author*: rui.3.li@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-2-24 | r3li | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | file_path | Yes | file path that saved bin file of sw update, like /test_results/ |
    ...   | ald_sw_update_info_list | Yes | a list containing sw info, like [ {'fileName': '86010148_RCU_FW_V02-03-02.bin',
    ...   'forced': 'TRUE', 'hwVersion': '2.0.0', 'productNumber': 'TRAE-TDGA12V02', 'restricted': 'FALSE', 'serialNumber': 'RT212600014',
    ...   'tagertVersion': 'TDGA02V01-1.0.C', 'vendorId': 'TY'} ] |
    ...
    ...   *Return*
    ...   file path saved xml
    ...   *Example*
    ...   | ${info_dict} | Create Dictionary | fileName=86010148_RCU_FW_V02-03-02.bin | vendorId=TY   productNumber=TRAE-TDGA12V02 |
    ...   | hwVersion=2.0.0 | restricted=FALSE | forced=TRUE | tagertVersion=TDGA02V01-1.0.C | serialNumber=RT212600014 |
    ...   | ${info_list} | Create List | ${info_dict} |
    ...   | Get SW Update Xml of ALD | /home/ute/test_results/ | ${info_list} |

    ${ald_sw_update_info_list}   convert_list    ${ald_sw_update_info_list}
    ${file_name_list}   Create List
    ${xml_strs}  Set Variable   ${EMPTY}
    ${file_name_xmls}  Set Variable   ${EMPTY}
    FOR  ${sw_update_info}  IN   @{ald_sw_update_info_list}
       ${xml_str}   Set Variable   ${EMPTY}
       ${file_name}   Get From Dictionary   ${sw_update_info}   fileName
       ${vendor_id}   Get From Dictionary   ${sw_update_info}   vendorId
       ${product_number}   Get From Dictionary   ${sw_update_info}   productNumber
       ${hw_version}   Get From Dictionary   ${sw_update_info}   hwVersion
       ${restricted}   Get From Dictionary   ${sw_update_info}   restricted
       ${forced}   Get From Dictionary   ${sw_update_info}   forced
       ${tagert_version}   Get From Dictionary   ${sw_update_info}   tagertVersion
       ${serial_number}   Get From Dictionary   ${sw_update_info}   serialNumber
       Append to List   ${file_name_list}   ${file_name}
       ${xml_str}   Catenate   <hwResource   vendorId="${vendor_id}"   productNumber="${product_number}"
    ...  hwVersion="${hw_version}"   restrictedSWDL="${restricted}"   forcedSWDL="${forced}"
    ...  requestedSWVersion="${tagert_version}"   serialNumber="${serial_number}"   >\n
       ${xml_element_str}   Set Variable   <swFileKey>${file_name}</swFileKey>\n
       ${xml_str}   Set Variable   ${xml_str}${xml_element_str}</hwResource>\n
       ${xml_strs}   Set Variable   ${xml_strs}${xml_str}
       ${full_bin_path}   OperatingSystem.Join Path   ${file_path}    ${file_name}
       ${file_size}   Get File Size    ${full_bin_path}
       ${file_name_xml}   Catenate   <buildElement swFileKeyName="${file_name}"   name="${file_name}"   nrOfBlocks="1"
    ...    fileLength="${file_size}"   path=""/>\n
       ${file_name_xmls}   Set Variable   ${file_name_xmls}${file_name_xml}
    END

    ${all_xml_info}   Catenate   <?xml version="1.0"?>\n   <targetBD_EXD>\n   ${xml_strs}${file_name_xmls}</targetBD_EXD>
    ${xml_file_path}   Get A File   sw_update    TargetBD_EXD.xml
    Create File   ${xml_file_path}    ${all_xml_info}
    [Return]   ${xml_file_path}


NE Should Be Restarted
    [Arguments]   ${ne_type}=vdu  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   NE Should Be Restarted
    ...   *Author*: rui.3.li@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-5-10 | r3li | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ne_type | No | only suport vdu or vcu, default value is vdu. |
    ...   | gnb_index | No | gnb index, default value is 0 |
    ...   | vdu_index | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | NE Should Be Restarted | ne_type=vdu | gnb_index=0 | vdu_index=0 |
    ...   | NE Should Be Restarted | ne_type=vdu | gnb_index=0 | vdu_index=1 |
    ...   | NE Should Be Restarted | ne_type=vcu | gnb_index=0 |
    ${oam_info}   Run Keyword If   '${ne_type}'=='vdu'    Get VDU OAM Http Connection Info   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...   ELSE IF   '${ne_type}'=='vcu'   Get Vcu Oam Http Connection Info   gnb_index=${gnb_index}
    ...   ELSE   fail   not supported ne type.
    ${ip_addrss}   Set Variable   ${oam_info}[addr]
    Wait Until Keyword Succeeds  300  3   ping_status_should_be_as_expected   ip_address=${ip_addrss}   is_pass=${False}
    Wait Until Keyword Succeeds  300  3   ping_status_should_be_as_expected   ip_address=${ip_addrss}


vDU Lock Cells By RESTAPI
    [Arguments]   ${cells_id_list}  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Lock cells by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cells_id_list | No | cell id list, [1, 2, 3]. |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${cells_id_list}   |   vDU Get Cells ID list | gnb_index=0 | vdu_index=0 |
    ...   | vDU Lock Cells By RESTAPI   | cells_id_list=${cells_id_list} | gnb_index=0 | vdu_index=0 |
    ...   | vDU Cells Status Should Be As Expected |  cells_id_list=${cells_id_list} |
    ...   gnb_index=0 | vdu_index=0 | administrative_state=Locked |  operational_state=disabled |
    ...   availability_status=off line |
    ${unique_id}  Get Unique ID
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${unique_id}
    ${out}   vdu.Lock Cells   cell_id_list=${cells_id_list}   vdu_connection=${unique_id}
    Lock Cells Operation Should Be Successful   operation_id=${out['id']}  alias=${unique_id}
    [Teardown]    vDU Rest Logout  alias=${unique_id}


vDU Unlock Cells by RESTAPI
    [Arguments]   ${cells_id_list}  ${gnb_index}=0   ${vdu_index}=0
     [Documentation]   Unlock cells by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cells_id_list | No | cell id list, [1, 2, 3]. |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${cells_id_list}   |   vDU Get Cells ID list | gnb_index=0 | vdu_index=0 |
    ...   | vDU Unlock Cells by RESTAPI    | cells_id_list=${cells_id_list} | gnb_index=0 | vdu_index=0 |
    ...   | vDU Cells Status Should Be As Expected |  cells_id_list=${cells_id_list} |
    ...   gnb_index=0 | vdu_index=0 |
    ${unique_id}  Get Unique ID
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${unique_id}
    ${out}   vdu.Unlock Cells   cell_id_list=${cells_id_list}   vdu_connection=${unique_id}
    Unlock Cells Operation Should Be Successful   operation_id=${out['id']}  alias=${unique_id}
    [Teardown]    vDU Rest Logout  alias=${unique_id}


Lock Cells Operation Should Be Successful
    [Arguments]  ${operation_id}  ${alias}=default
    [Documentation]   Lock Cells Operation Should Be Successful
    ...   *AUTHOR* lingting.sun@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id | Yes | operation ID which lock/unlock Cellss  |
    ...   | alias        | No  | connection alias                      |
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | Lock Cells Operation Should Be Successful | operation_id=${out["id"]} |
    ...  | vdu logout |
    ...
    Wait Until Keyword Succeeds  30   10   _Lock Cells Should Be Successful   operation_id=${operation_id}
    ...   expected_status=success   alias=${alias}

_Lock Cells Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${alias}=default
    ${out}   vdu.get_operation_state_of_locking_cells   operation_id=${operation_id}  vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Unlock Cells Operation Should Be Successful
    [Arguments]  ${operation_id}  ${alias}=default
    [Documentation]   Unlock Cells Operation Should Be Successful
    ...   *AUTHOR* lingting.sun@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id | Yes | operation ID which lock/unlock Cells  |
    ...   | alias        | No  | connection alias                      |
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | Unlock Cells Operation Should Be Successful | operation_id=${out["id"]} |
    ...  | vdu logout |
    ...
    Wait Until Keyword Succeeds  300   10   _Unlock Cells Should Be Successful   operation_id=${operation_id}
    ...   expected_status=success   alias=${alias}

_Unlock Cells Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${alias}=default
    ${out}   vdu.get_operation_state_of_unlocking_cells   operation_id=${operation_id}  vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Lock Rmods by RESTAPI
    [Arguments]   ${rmods_id_list}  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Lock Rmods by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | rmods_id_list | No | rmod id list, [1, 2, 3].      |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${rmods_list} |  Get RMOD ID List By RESTAPI | gnb_index=0 | vdu_index=0 |
    ...   | Lock Rmods by RESTAPI  | rmods_id_list=${rmods_list} | gnb_index=0 | vdu_index=0 |
    ...   | RMOD Status Should Be As Expected |  rmods_id_list=${rmods_list} |
    ...   gnb_index=0 | vdu_index=0 | administrative_state=Locked |
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${out}   vdu.lock_rmods     ${rmods_id_list}
    Lock RUs Operation Should Be Successful   operation_id=${out["id"]}
    [Teardown]    vDU Rest Logout


Unlock Rmods by RESTAPI
    [Arguments]   ${rmods_id_list}  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Lock Rmods by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | rmods_id_list | No | rmod id list, [1, 2, 3].      |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${rmods_list} |  Get RMOD ID List By RESTAPI | gnb_index=0 | vdu_index=0 |
    ...   | Unlock Rmods by RESTAPI  | rmods_id_list=${rmods_list} | gnb_index=0 | vdu_index=0 |
    ...   | RMOD Status Should Be As Expected |  rmods_id_list=${rmods_list} | gnb_index=0 | vdu_index=0 |
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${out}   vdu.unlock_rmods     ${rmods_id_list}
    Unlock RUs Operation Should Be Successful   operation_id=${out["id"]}
    [Teardown]    vDU Rest Logout


vDU Block cells By RESTAPI
    [Arguments]    ${cells_id_list}  ${gnb_index}=0   ${vdu_index}=0  ${timeout}=${60}
    [Documentation]   Block cells by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cells_id_list | No | cell id list, [1, 2, 3]. |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${cells_id_list}   |   vDU Get Cells ID list | gnb_index=0 | vdu_index=0 |
    ...   | vDU Block cells By RESTAPI   | cells_id_list=${cells_id_list} | gnb_index=0 | vdu_index=0 |
    ...   | vDU Cells Status Should Be As Expected |  cells_id_list=${cells_id_list} |
    ...   gnb_index=0 | vdu_index=0 | blocking_state=Blocked |  operational_state=disabled |
    ...   availability_status=off line |
    ${alias}  Get Unique ID
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    FOR    ${cell_id}    IN    @{cells_id_list}
        run keyword and continue on failure  _Block Cell By RESTAPI  cell_id=${cell_id}    timeout=${timeout}   alias=${alias}
    END
    [Teardown]    vDU Rest Logout  alias=${alias}


_Block Cell By RESTAPI
    [Arguments]    ${cell_id}   ${timeout}=${60}   ${alias}=default
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...     expected_status=success   alias=${alias}


vDU Unblock cells By RESTAPI
    [Arguments]    ${cells_id_list}  ${gnb_index}=0   ${vdu_index}=0  ${timeout}=${60}
    [Documentation]   Unblock cells by rest api
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2023-6-14 | lingtsun | initial creation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | cells_id_list | No | cell id list, [1, 2, 3]. |
    ...   | gnb_index     | No | gnb index, default value is 0 |
    ...   | vdu_index     | No | vdu index, default value is 0 |
    ...
    ...   *Return*
    ...
    ...   *Example*
    ...   | ${cells_id_list}   |   vDU Get Cells ID list | gnb_index=0 | vdu_index=0 |
    ...   | vDU vDU Unblock cells By RESTAPI  | cells_id_list=${cells_id_list} | gnb_index=0 | vdu_index=0 |
    ...   | vDU Cells Status Should Be As Expected |  cells_id_list=${cells_id_list} |
    ...   gnb_index=0 | vdu_index=0 |
    ${alias}  Get Unique ID
    vDU Rest Login   gnb_index=${gnb_index}   vdu_index=${vdu_index}  alias=${alias}
    FOR    ${cell_id}    IN    @{cells_id_list}
        run keyword and continue on failure  _Unblock Cell By RESTAPI  cell_id=${cell_id}    timeout=${timeout}   alias=${alias}
    END
    [Teardown]    vDU Rest Logout  alias=${alias}


_Unblock Cell By RESTAPI
    [Arguments]    ${cell_id}   ${timeout}=${60}   ${alias}=default
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...     expected_status=success   alias=${alias}


Get Start Timestamp Of Container
    [Arguments]   ${ctr_abbr}   ${pod_abbr}=${EMPTY}   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error     Disconnect Interactive Connection  alias=${alias}
    [Documentation]  Get Start Timestamp Of Container
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No. | the pod name abbreviation, do not give the full pod name. such as oamcm |
    ...    | ctr_abbr | Yes. | the container name abbreviation. such as oamagent, oamcm |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...    | vdu_index | No. | the vdu index, default value is 0. |
    ...
    ...    *RETURN VALUE*
    ...    The string of container start timestamp, eg. "2023-06-16T22:14:16Z"
    ...
    ...   Example
    ...   | ${timestamp1} | Get Start Timestamp Of Container | ctr_abbr=oamagent |
    ...   | ${timestamp2} | Get Start Timestamp Of Container | pod_abbr=oamext | ctr_abbr=oamagent |
    ...   | ${timestamp3} | Get Start Timestamp Of Container | pod_abbr=oamext | ctr_abbr=nwmgmt |
    ...

    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively     alias=${alias}   gnb_index=${gnb_index}  vdu_index=${vdu_index}

    ${pod_abbr}   Run Keyword If   "${pod_abbr}"=="${EMPTY}"   Get Pod Abbreviation By Container Abbreviation   container_abbr=${ctr_abbr}
    ...   ELSE  Set Variable  ${pod_abbr}

    ${container_prefix}   Run Keyword If  "${ctr_abbr}"=="nwmgmt"   Get Container Name Prefix  vdu_index=${vdu_index}
    ${container_full_name}   Run Keyword If  "${ctr_abbr}"=="nwmgmt"
       ...   Set Variable   ${container_prefix}${ctr_abbr}
       ...   ELSE   Get Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}   vdu_index=${vdu_index}
    ${pod_full_name}  Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}
          ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    #oc get pod -o yaml| grep ctr-cran1-oamagent -A 7|grep startedAt|awk '{print $2}' |tr --delete "\""
    ${cmd}  Set Variable  oc get pod ${pod_full_name} -o yaml| grep ${container_full_name} -A 7|grep startedAt|awk '{print $2}' |tr --delete "\\""
    ${out}  issh.Execute  command=${cmd}   check_result=${False}   alias=${alias}
    ${timestamp}  Strip Prompt  ${out}
    [Return]  ${timestamp}
