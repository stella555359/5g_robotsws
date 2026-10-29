*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com




*** Variables ***


*** Keyword ***
Get RF Info List From Testline
    [Arguments]    ${gnb_index}  ${vdu_index}
   [Documentation]   get the rf info list including model, type, username, password, atten_list, 2nduser. etc
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <02-03-2022>, <lingtsun>, <Add RF_local_ip>
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...    | vdu_index  | no |  vdu index  |
    ...    *RETURN VALUE*
    ...    rf_info_list
    ...
    ...    Example
    ...    |  Get RF Info List From Testline |
    log    ${tl.tl_cloud_topology}
    ${rf_model_list}=  create list
    vDU Rest Login    alias=check_power   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${rmods_info}=   vdu.get_rmods_status     vdu_connection=check_power
    FOR  ${rmod}  IN  @{rmods_info}
        ${rmod_dict}=    create dictionary  ${rmod["serial_number"]}=${rmod["product_name"]}
        append to list   ${rf_model_list}   ${rmod_dict}
    END
    ${all_rf_info_}=   get_all_RF_infos
    ${rf_info_list}   create list
    FOR    ${rf_sn_model}    IN    @{rf_model_list}
      ${sn}   get dictionary keys   ${rf_sn_model}
      ${sn}   set variable   ${sn[0]}
      ${rf_type}  ${rf_username}  ${rf_passwsord}  ${rf_2nduser}  ${rf_atten}  ${rf_local_ip}  ${prompt}=    get_rf_infos_by_rf_model
    ...  ${all_rf_info_}   ${rf_sn_model}[${sn}]
      ${rf_info_dict}   create dictionary  model=${rf_sn_model}[${sn}]  type=${rf_type}  username=${rf_username}
    ...   password=${rf_passwsord}   2nduser=${rf_2nduser}    atten=${rf_atten}   rf_local_ip=${rf_local_ip}
    ...   sn=${sn[-5:]}  prompt=${prompt}
      append to list   ${rf_info_list}   ${rf_info_dict}
    END
    run keyword and continue on failure   should not be empty  ${rf_info_list}   msg=Please check the rmod status on web
    [return]   ${rf_info_list}
    [Teardown]  vdu logout   alias=check_power


Should Have Power On All RUs
    [Arguments]     ${cu_quantity}=${EMPTY}
    [Documentation]   Check there is power on all RUs (include TDD and FDD)defined in init config.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <16-09-2021>, <lingtsun>, <Add TDD RF check>
    ...    modified by:  hongyuan.sun@nokia-sbell.com  <24-01-2022>, <hongysun>, <Add cu_quantity parameter>
    ...    | Input Parameters | Man. | Description |
    ...    | cu_quantity | no | Number of custom cu |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On All RUs  |  ${2}  |
#    log to console   temporary modify in Spring Festive
    ${quantity_of_cu_tmp}   get length   ${tl.gnbs}
    ${quantity_of_cu}    set variable if    "${cu_quantity}"=="${EMPTY}"   ${quantity_of_cu_tmp}
    ${is_in_teardown}=    Is Run In TearDown
    run keyword if   "${is_in_teardown}"=="${False}"   _Should Have Power On All RUs In Case   quantity_of_cu=${quantity_of_cu}
    ...   ELSE IF    "${is_in_teardown}"=="${True}"   _Should Have Power On All RUs In Case Teardown   quantity_of_cu=${quantity_of_cu}

_Should Have Power On All RUs In Case
    [Arguments]     ${quantity_of_cu}
    log to console   \n*** Should have power on all rus... ***
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        Should Have Power On RUs Under Specified vCU   ${gnb_index}
    END

_Should Have Power On All RUs In Case Teardown
    [Arguments]     ${quantity_of_cu}
    log to console   \n*** Should have power on all rus in case teardown... ***
    ${exist}    Run Keyword And Return Status    Variable Should Exist     ${POST_RU_POWER}
    run keyword if   "${exist}"=="${False}"   set test variable   ${POST_RU_POWER}   ${False}
    ${r_tmp}    Set Variable    ${True}
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        ${r}    Run Keyword And Return Status    Should Have Power On RUs Under Specified vCU   ${gnb_index}
        run keyword and continue on failure     Should Be True   ${r}
    ...  msg=please check the result of KW [Should Have Power On RUs Under Specified CU ]
        ${r_tmp}     evaluate    ${r_tmp} and ${r}
    END
    ${POST_RU_POWER}   evaluate    ${POST_RU_POWER} or ${r_tmp}
    set test variable   ${POST_RU_POWER}


Should Have Power On RUs Under Specified CU And VDU
   [Arguments]    ${FDD_RFs}   ${gnb_index}   ${vdu_index}
   [Documentation]   Check there is power on all RUs Under to a specified CU/vDU.
    ...    author: fen.huang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no |  gnb index  |
    ...    | vdu_index  | no |  vdu index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On RUs Under Specified CU And VDU   |
   ${quantity_of_fhgw_for_specified_vdu}   get length   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
   FOR   ${fhgw_index}   IN RANGE   ${quantity_of_fhgw_for_specified_vdu}
        Should Have Power On RUs Under Specified CU And VDU And FHGW     ${FDD_RFs}   ${gnb_index}   ${vdu_index}   ${fhgw_index}
    END

Should Have Power On RUs Under Specified CU And VDU And FHGW
   [Arguments]    ${FDD_RFs}   ${gnb_index}   ${vdu_index}   ${fhgw_index}
   [Documentation]   Check there is power on all RUs Under to a specified CU/vDU/FHGW.
    ...    author: fen.huang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index   | no |  gnb index  |
    ...    |  vdu_index   | no |  vdu index  |
    ...    |  fhgw_index  | no |  fhgw index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On RUs Under Specified CU And VDU And FHGW  |
    ${length}   get length   ${FDD_RFs}
    vDU Rest Login    alias=get_cell_band   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${cell_list}    vDU Get Cells ID List For Check Power   vdu_index=${vdu_index}
    FOR    ${index}    IN RANGE   0    ${length}
        ${ru_index}   evaluate  ${index}+1
        ${band}  _Get Cell Band    alias=get_cell_band  cell_id=${cell_list}[${index}]
        ${atten_list}   set variable   ${FDD_RFs}[${index}][atten][${band}]
        ${alias}=  get unique id
        ${alias}=   Connect to Radio Unit   ${gnb_index}  ${vdu_index}  ${fhgw_index}    ${alias}   ${ru_index}   timeout=60
        _RF Check Power On Specific Att FDD   ${gnb_index}   ${vdu_index}   ${fhgw_index}   ${ru_index}  ${atten_list}    ${alias}
        Disconnect Interactive Connection    ${alias}
    END
    [Teardown]  vdu logout   alias=get_cell_band


_RF Check Power On Specific Att FDD
    [Arguments]    ${gnb_index}   ${vdu_index}   ${fhgw_index}   ${ru_index}  ${atten_list}    ${alias}
    FOR    ${atten}    IN   @{atten_list}
       log  ${atten}
        ${result}=  issh.execute   command=/usr/bin/dapd -pwr ${atten}  check_result=${False}   alias=${alias}
        Log To Console   RU Power result_${atten}:${result}
        ${matched}=  get regexp matches   ${result}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
        ${len}=  get length   ${matched}
        run keyword and continue on failure      Should be true    ${len}>=1
    ...   No power detected on cu${gnb_index}_vdu${vdu_index}_fhgw${fhgw_index}_ru${ru_index}:/usr/bin/dapd -pwr ${atten}
    END


_Should Have Power On TDD RUs Under Specified CU And VDU
   [Arguments]    ${TDD_RFs}   ${vdu_index}=0    ${gnb_index}=0
   [Documentation]   Check there is power on all TDD RUs Under to a specified CU/vDU
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <02-03-2022>, <lingtsun>, <Add RF_local_ip>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index   | no |  gnb index  |
    ...    |  vdu_index   | no |  vdu index  |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  _Should Have Power On TDD RUs Under Specified CU And VDU |
    ${rf_list_via_rest}    create list
    FOR    ${rf_info}    IN    @{TDD_RFs}
        append to list    ${rf_list_via_rest}    ${rf_info}[sn]
    END
    ${rf_sn_ip_mapping}    ru._Get Final SN IP Mapping   ${rf_list_via_rest}  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}  get unique id
    Connect To VDU Container With Tenant Interactively   ctr_abbr=oamfh   alias=${alias}  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${length}   get length   ${TDD_RFs}
    FOR    ${index}    IN RANGE   0    ${length}
        ${password}   set variable   ${TDD_RFs}[${index}][password]
        ${username}   set variable   ${TDD_RFs}[${index}][username]
        ${2nduser}   set variable   ${TDD_RFs}[${index}][2nduser]
        ${sn}     set variable   ${TDD_RFs}[${index}][sn]
        ${RF_ip}   set variable   ${rf_sn_ip_mapping}[${sn}]
        ${atten}   set variable   ${TDD_RFs}[${index}][atten]
        ${rf_local_ip_list}   set variable   ${TDD_RFs}[${index}][rf_local_ip]
        log to console   Start to check power on RF:${RF_ip}
        ${result}   ru._RF check power TDD  RF_ip=${RF_ip}  username=${username}  password=${password}
    ...   2nduser=${2nduser}    atten=${atten}  rf_local_ip_list=${rf_local_ip_list}  vdu_index=${vdu_index}   alias=${alias}
        Run Keyword And Continue On Failure   Should Be True   '${result}'=='${True}'
    END
    [Teardown]   Run Keyword And Ignore Error   Disconnect Interactive Connections


_RF Check Power TDD
    [Arguments]    ${RF_ip}  ${username}  ${password}  ${2nduser}  ${atten}  ${rf_local_ip_list}  ${vdu_index}   ${alias}
    ${status}   set variable   ${False}
    FOR    ${rf_local_ip}    IN    @{rf_local_ip_list}
       ${status}   Run Keyword And Return Status    _RF Check Power TDD By Local IP    RF_ip=${RF_ip}  username=${username}  password=${password}
    ...   2nduser=${2nduser}    atten=${atten}  rf_local_ip=${rf_local_ip}  vdu_index=${vdu_index}   alias=${alias}
       Return From Keyword If  "${status}"=="${True}"   ${Status}
    END


_RF Check Power TDD By Local IP
    [Arguments]    ${RF_ip}  ${username}  ${password}  ${2nduser}  ${atten}  ${rf_local_ip}  ${vdu_index}   ${alias}
    FOR    ${i}    IN   @{atten}
        _RF Check Power On Specific Att TDD    RF_ip=${RF_ip}   index=${i}   alias=${alias}
    ...    username=${username}   password=${password}  2nduser=${2nduser}   rf_local_ip=${rf_local_ip}
    ...    vdu_index=${vdu_index}
    END


_RF Check Power On Specific Att TDD
    [Arguments]    ${RF_ip}    ${index}    ${alias}   ${username}   ${password}   ${2nduser}   ${rf_local_ip}  ${vdu_index}
    ${power}=   _RF Get Power On Specific Att TDD  RF_ip=${RF_ip}
    ...    index=${index}   alias=${alias}
    ...    username=${username}   password=${password}  2nduser=${2nduser}   rf_local_ip=${rf_local_ip}
    Log To Console   RU Power result:${power}

    ${matched}=  get regexp matches   ${power}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
    ${len}=  get length   ${matched}
    run keyword and continue on failure      Should be true    ${len}>=1
    ...   No power detected on vdu${vdu_index}_ru_${RF_ip}+att_${index}


_RF Get Power On Specific Att TDD
    [Arguments]    ${RF_ip}    ${index}    ${alias}   ${username}   ${password}   ${2nduser}   ${rf_local_ip}
    ${cmd}    Catenate    SEPARATOR=   ssh ${username}@${RF_ip} -o StrictHostKeyChecking=
    ...  no -- ssh ${rf_local_ip} -- "sudo dapd -pwr ${index};"
    ${old_prompt}  issh.set prompt   assword:    alias=${alias}
    ${output}=   issh.execute   command=${cmd}    check_result=False    alias=${alias}
    ${match}=   Get Regexp Matches    ${output}   password:
    issh.set prompt    ${old_prompt}   alias=${alias}
    ${power}=   run keyword if   "assword:" in "${match[0]}"   issh.Execute
    ...   command=${password}   check_result=False    alias=${alias}
    Should Contain    ${power}    TX=
    [return]   ${power}
    [teardown]   issh.set prompt    ${old_prompt}   alias=${alias}


_Get Cell Band
    [Arguments]   ${cell_id}   ${vdu_index}=0    ${gnb_index}=0   ${alias}=default
    [Documentation]   get cell band from web ui
    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}  vdu_connection=${alias}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${MO}    set variable     MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ${band}   vdu.Search Parameter Of Current Plan    mo_dn=${MO}  para_name=freqBandIndicatorNR  vdu_connection=${alias}
    [return]   ${band}


vDU Get Cells ID List For Check Power
   [Arguments]  ${vdu_index}=0
   [Documentation]      Get all avaiable cells id list.
    vDU Rest Login    vdu_index=${vdu_index}
    ${all_cells_id_list}=   create list
    ${cells_info}=  vdu.get_vdu_cells_status
    FOR    ${cell_info}    IN    @{cells_info}
        append to list    ${all_cells_id_list}    ${cell_info["id"]}
    END
   [Return]   ${all_cells_id_list}


_Should Contain All RFs
   [Arguments]    ${rf_sn_ip_mapping}    ${rf_list}
   ${rf_current_list}=   Get Dictionary Keys    ${rf_sn_ip_mapping}
   List Should Contain Sub List     ${rf_current_list}    ${rf_list}

_Get Final SN IP Mapping
    [Arguments]    ${rf_list}   ${vdu_index}=0    ${gnb_index}=0
    ${rf_sn_mac_sn_infos}    _Get MAC AND IP List    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${rf_sn_ip_mapping}   Create Dictionary
    FOR  ${info}  IN   @{rf_sn_mac_sn_infos}
        Set To Dictionary    ${rf_sn_ip_mapping}   ${info}[sn]   ${info}[ip]
    END
    _Should Contain All RFs    ${rf_sn_ip_mapping}   ${rf_list}
    [Return]   ${rf_sn_ip_mapping}

_Get Up Pod List
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    ${alias}   Get Unique Id
    Connect To K8s Master With Tenant Interactively     gnb_index=${gnb_index}    vdu_index=${vdu_index}    alias=${alias}
    ${ns}   Get Vdu Namespace From Testline    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${command}    Set Variable   kubectl get pod -n ${ns} | grep up | awk '{print $1}'
    ${out}   issh.Execute    command=${command}   alias=${alias}
    ${out}    Strip Prompt     ${out}
    ${pod_list}    Split String     ${out}    \n
    [Return]   ${pod_list}
    [TearDown]   issh.disconnect    alias=${alias}

Get Ru Mac Adress List
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    [Documentation]   Get Ru Mac Adress List
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index   | no |  gnb index  |
    ...    |  vdu_index   | no |  vdu index  |
    ...
    ...    *RETURN VALUE*
    ...    return a list containing all ru mac address.
    ...
    ...    Example
    ...    | Get Ru Mac Adress List | 0 | 0 |
    ${up_pod_list}    _Get Up Pod List    ${gnb_index}    ${vdu_index}
    ${mac_lists}    Create List
    FOR    ${i}   IN RANGE    ${up_pod_list.__len__()}
       ${alias}   Get Unique Id
       Connect To VDU Container Interactively    pod_abbr=up    ctr_abbr=l1hi    alias=${alias}   pod_index=${i}
       ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}
       ${old_prompt}    issh.get prompt    alias=${alias}
       issh.set prompt   ${old_prompt}|FHP_CLI#   alias=${alias}
       issh.Execute    command=/opt/nokia/bin/fhp_cli    alias=${alias}    check_result=${False}
       sleep    1
       ${out}   issh.Execute    command=fhpshow config ecpri    alias=${alias}    check_result=${False}
       ${mac_list}    get_mac_from_string     ${out}
       ${mac_lists}    Evaluate    ${mac_lists}+${mac_list}
       Run Keyword And Ignore Error  issh.disconnect    alias=${alias}
    END
    [Return]    ${mac_lists}


Get Ru Info List Including Ip
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    [Documentation]   Get Ru Info List Including Ip
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    | r3li | 2022-12-28 | keyword adaption for multiple file kea-leases4.csv |
    ...    | r3li | 2023-2-2 | optimize keyword |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...
    ...    *RETURN VALUE*
    ...    return a list containing dic of ru info, including mac, ip, sn
    ...
    ...    Example
    ...    | Get Ru Info List Including Ip | 0 | 0 |
    ${mac_ip_list}    _Get MAC AND IP List   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${full_rf_info_list}   Create List
    ${fhgw_acount_info}    Get FHGW Account Info
    ${rf_info_list}    Get RF Info List From Testline   ${gnb_index}   ${vdu_index}
    FOR    ${info}   IN   @{rf_info_list}
        ${new_info}   Run Keyword If   '${info}[type]'=='FDD'  set_ip_and_mac_to_info_of_FDD    ${info}   ${fhgw_acount_info}   ELSE
        ...   set_ip_and_mac_to_info_of_TDD   ${info}   ${mac_ip_list}
        Append To List   ${full_rf_info_list}   ${new_info}
    END
    [Return]    ${rf_info_list}

_Get MAC AND IP List
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    ${alias}    Get Unique Id
    Connect To K8s Master Interactively     ${gnb_index}    ${vdu_index}    alias=${alias}
    ${ns}   Get Vdu Namespace From Testline    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${container_name}    set variable    ctr-${ns}-dhcp
    ${pod_name}    Set Variable   po-${ns}-oamfh-0
    ${base_cmd}   Set Variable   kubectl exec -it -n ${ns} ${pod_name} -c ${container_name} --
    ${file_cmd}   Set Variable   ${base_cmd} ls -al /var/log/kea-leasesdb | grep kea-leases4.csv | awk '{print $NF}'
    ${file_list_info}   issh.Execute   command=${file_cmd}   alias=${alias}
    ${file_list_info}   Strip Prompt    ${file_list_info}
    ${file_list}   Split String    ${file_list_info}   \n
    ${total_content}   Set Variable   ${EMPTY}
    FOR   ${file_name}   IN   @{file_list}
       ${content}  issh.Execute   command=kubectl exec -it -n ${ns} ${pod_name} -c ${container_name} -- cat /var/log/kea-leasesdb/${file_name}
       ...    alias=${alias}
       ${content}   Strip Prompt    ${content}
       ${total_content}    Catenate   ${total_content}    ${content}
    END
    ${mac_ip_list}    get_mac_ip_list_from_csv_txt     ${total_content}
    [Teardown]     issh.disconnect    alias=${alias}
    [Return]    ${mac_ip_list}

Get RU PID For FDD
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0     ${fhgw_index}=0
    [Documentation]   Get RU PID For FDD
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    | fhgw_index | no | fhgw index |
    ...
    ...    *RETURN VALUE*
    ...    return a dict means the relation of reproxy index and ru pid.
    ...
    ...    Example
    ...    | Get RU PID For FDD | 0 | 0 | 0 |
    ${alias}    Get Unique Id
    Connect to FHGW With Root    gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
    ...   alias=${alias}
    ${command}    Set Variable    docker ps | grep rup | awk '{print $1, $NF}'
    ${out}    issh.Execute    command=${command}     alias=${alias}
    ${out}    Strip Prompt     ${out}
    ${pid_list}    Split String     ${out}    \n
    ${pid_dict}    get_pid_relationship    ${pid_list}
    [Teardown]     issh.disconnect    alias=${alias}
    [Return]    ${pid_dict}

Collect Log on Ru of FDD via FHGW
    [Arguments]    ${log_path}   ${ru_ip}   ${gnb_index}=0    ${vdu_index}=0     ${fhgw_index}=0
    [Documentation]   Collect Log on Ru of FDD via FHGW
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | log_path | Yes | log saved path |
    ...    | ru_ip | Yes | ru ip of fdd rf |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    | fhgw_index | no | fhgw index |
    ...
    ...    *RETURN VALUE*
    ...    return log path in local
    ...
    ...    Example
    ...    | Collect Log on Ru of FDD via FHGW | log_path | ru ip | 0 | 0 | 0 |
    ${alias}    Get Unique Id
    ${pid_dict}    Get RU PID For FDD   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
    Connect to FHGW With Root    gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}
    ...   alias=${alias}
    ${ru_ip_list}    Split String    ${ru_ip}   .
    ${index}   Set Variable  ${ru_ip_list}[2]
    ${pid}    Set Variable    ${pid_dict}[${index}]
    ${old_prompt}    issh.get prompt    alias=${alias}

    issh.set prompt   ${old_prompt}|Node0:~#   alias=${alias}
    ${command}   catenate   docker exec -it ${pid} bash -c
    ...   "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa root@${ru_ip}"
    ${out}    issh.Execute    command=${command}     alias=${alias}
    sleep    1
    ${log_name}    get unique id
    ${log_name}    Set Variable    RRU_LOG_FDD_${ru_ip}_${log_name}.zip
    ${log_command}    Set Variable     log -a -z ${log_name}
    issh.Execute    command=${log_command}     alias=${alias}

    issh.Execute    command=exit     alias=${alias}
    ${scp_command}    catenate   docker exec -it ${pid} bash -c "scp -o UserKnownHostsFile=/dev/null -o
    ...   StrictHostKeyChecking=no -o HostKeyAlgorithms=+ssh-rsa root@${ru_ip}:/run/${log_name} /var/log/${log_name}"
    issh.Execute    command=${scp_command}     alias=${alias}

    issh.download_file    /var/log/RUOAM/ruproxy-${index}/log/${log_name}    ${log_path}/${log_name}     alias=${alias}
    [Teardown]     issh.disconnect    alias=${alias}
	[Return]    ${log_path}/${log_name}


Connect To RU Of TDD via IP
    [Arguments]     ${ru_ip}     ${password}    ${ru_prompt}=Node0:~#     ${gnb_index}=0    ${vdu_index}=0
    ...   ${ru_local_ip}=192.168.101.2   ${rf_login_name}=serviceuser   ${need_login_local_ip}=${True}
    [Documentation]   Collect Log on Ru of TDD via IP
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    | r3li | 2022-11-2 | add parmaters support different RU type |
    ...    | chris.l.cao | 2023-3-5 | adapt to AZQJ |
    ...    | r3li | 2023-4-17 | optimize keyword |
    ...
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | ru_ip | Yes | ru ip of tdd rf |
    ...    | password | Yes | password of tdd |
    ...    | ru_prompt | no | ru prompt |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    | ru_local_ip | no | ru local ip, default is 192.168.101.2 |
    ...    | rf_login_name | no | rf login name, default is serviceuser |
    ...    | need_login_local_ip | is need login local ip, default is True means login, else don't login |
    ...    *RETURN VALUE*
    ...    return alias of connect to fdd
    ...
    ...    Example
    ...    | Connect To RU Of TDD via IP | ru ip | 11111 | Node0:~# | 0 | 0 |
    ${alias}   Get Unique Id
    Connect To VDU Container Interactively    oamfh    oamfh    alias=${alias}
    ${cmd}    Set Variable    ssh -o StrictHostKeyChecking=no ${rf_login_name}@${ru_ip}
    ${old_prompt}    issh.get prompt    alias=${alias}

    issh.set prompt   password:   alias=${alias}
    ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}

    issh.set prompt   ${old_prompt}|\\$|${ru_prompt}   alias=${alias}
    issh.Execute    command=${password}     alias=${alias}    check_result=${False}
    sleep   3

#    Run Keyword If   '${need_login_local_ip}'=='True'   issh.set prompt   ${old_prompt}|Node1:~#   alias=${alias}
    Run Keyword If   '${need_login_local_ip}'=='True'   issh.Execute    command=ssh ${ru_local_ip}     alias=${alias}    check_result=${False}
    Run Keyword If   '${need_login_local_ip}'=='True'   sleep   3
    [Return]    ${alias}

Connect To RU Ecpri Interface Of TDD via IP
    [Arguments]     ${ru_ip}     ${password}    ${ru_prompt}=Node0:~#     ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Log in Ru with Ecpri Interface of TDD via IP
    ...    *author*: zhijiang.shan@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | zhijiang | 2022-10-17 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | ru_ip | Yes | ru ip of tdd rf |
    ...    | password | Yes | password of tdd |
    ...    | ru_prompt | no | ru prompt |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...
    ...    *RETURN VALUE*
    ...    return alias of connect to fdd
    ...
    ...    Example
    ...    | Connect To RU Of TDD via IP | ru ip | 11111 | Node0:~# | 0 | 0 |
    ${alias}   Get Unique Id
    Connect To VDU Container Interactively    oamfh    oamfh    alias=${alias}
    ${cmd}    Set Variable    ssh -o StrictHostKeyChecking=no serviceuser@${ru_ip}
    ${old_prompt}    issh.get prompt    alias=${alias}

    issh.set prompt   ${old_prompt}|password:   alias=${alias}
    ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}

    issh.set prompt   ${old_prompt}|${ru_prompt}   alias=${alias}
    issh.Execute    command=${password}     alias=${alias}    check_result=${False}
    sleep   3
    [Return]    ${alias}

Collect Log on Ru Of TDD
   [Arguments]    ${log_path}    ${ru_ip}     ${password}    ${ru_prompt}=Node0:~#     ${gnb_index}=0    ${vdu_index}=0
   ...    ${rf_local_ip}=192.168.101.2    ${rf_login_name}=serviceuser
   [Documentation]   Collect Log on Ru Of TDD
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-9-22 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | log_path | Yes | path to save log |
    ...    | ru_ip | Yes | ru ip of tdd rf |
    ...    | password | Yes | password of tdd |
    ...    | ru_prompt | no | ru prompt |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    | rf_local_ip | no | rf local ip |
    ...    *RETURN VALUE*
    ...    return log path in local
    ...
    ...    Example
    ...    | Collect Log on Ru Of TDD | log path | ru ip | 11111 | Node0:~# | 0 | 0 |
   ${alias}     Connect To RU Of TDD via IP     ru_ip=${ru_ip}    password=${password}    ru_prompt=${ru_prompt}
   ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}    rf_login_name=${rf_login_name}
   ${old_prompt}    issh.get prompt    alias=${alias}
   ${out}    issh.Execute    command=ls     alias=${alias}    check_result=${False}
   issh.set prompt   ${old_prompt}|root@made-Node1:/home/serviceuser#|made:/home/rfsw#|stratix\\d+-aehb:/home/serviceuser#   alias=${alias}
   issh.Execute    command=sudo su     alias=${alias}    check_result=${False}
   ${log_name}    Get Unique Id
   ${log_name}    Set Variable     RRU_LOG_TDD_${ru_ip}_${log_name}.zip
   ${log_cmd}   Set Variable     log -a -z ${log_name}
   issh.Execute    command=${log_cmd}     alias=${alias}    check_result=${False}
   sleep    3

   issh.set prompt   ${old_prompt}|serviceuser@made-Node1:~#   alias=${alias}
   issh.Execute    command=exit     alias=${alias}    check_result=${False}
   sleep   0.5

   issh.set prompt   ${old_prompt}|${ru_prompt}   alias=${alias}
   issh.Execute    command=exit     alias=${alias}    check_result=${False}
   sleep   0.5

   issh.Execute    command=scp ${rf_local_ip}:/run/${log_name} /var/tmp    alias=${alias}    check_result=${False}

   issh.set prompt   ${old_prompt}|bash-5.1$   alias=${alias}
   issh.Execute    command=exit     alias=${alias}    check_result=${False}
   sleep   0.5

   issh.set prompt   ${old_prompt}|assword:   alias=${alias}
   issh.Execute    command=scp -o StrictHostKeyChecking=no serviceuser@${ru_ip}:/var/tmp/${log_name} /tmp
   ...    alias=${alias}    check_result=${False}
   sleep    3

   issh.Execute    command=${password}     alias=${alias}    check_result=${False}
   sleep   1
   Download File From VDU Container    pod_abbr=oamfh    container=oamfh     filename=tmp/${log_name}
   ...   local_filename=${log_path}/${log_name}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
   issh.Execute    command=exit     alias=${alias}    check_result=${False}

   ${ns}   Get Vdu Namespace From Testline    gnb_index=${gnb_index}    vdu_index=${vdu_index}
   ${delete_ru_cmd_1}    catenate    kubectl exec -it -n ${ns} po-${ns}-oamfh-0 -c ctr-${ns}-oamfh -- ssh
   ...  -o StrictHostKeyChecking=no serviceuser@${ru_ip} -- ssh ${rf_local_ip} -- sudo rm -rf /run/${log_name}

   ${delete_ru_cmd_2}    catenate    kubectl exec -it -n ${ns} po-${ns}-oamfh-0 -c ctr-${ns}-oamfh -- ssh
   ...  -o StrictHostKeyChecking=no serviceuser@${ru_ip} -- rm -rf /var/tmp/${log_name}

   [Teardown]    _Teardown Of Collect TDD Log   alias=${alias}   gnb_index=${gnb_index}   vdu_index=${vdu_index}
   ...   delete_ru_cmd_1=${delete_ru_cmd_1}    delete_ru_cmd_2=${delete_ru_cmd_2}   password=${password}
   [Return]    ${log_path}/${log_name}

_Teardown Of Collect TDD Log
   [Arguments]    ${alias}    ${gnb_index}    ${vdu_index}    ${delete_ru_cmd_1}    ${delete_ru_cmd_2}   ${password}
   ${ns}   Get Vdu Namespace From Testline    gnb_index=${gnb_index}    vdu_index=${vdu_index}
   issh.Execute    command=${delete_ru_cmd_1}     alias=${alias}    check_result=${False}
   issh.Execute    command=${password}     alias=${alias}    check_result=${False}
   sleep   0.5

   issh.Execute    command=${delete_ru_cmd_2}     alias=${alias}    check_result=${False}
   issh.Execute    command=${password}     alias=${alias}    check_result=${False}
   sleep   0.5
   [Teardown]     issh.disconnect    alias=${alias}


Connect To Radio Unit Tdd via RU Index
    [Arguments]    ${ru_index}=1   ${gnb_index}=0    ${vdu_index}=0   ${need_login_local_ip}=${True}
    [Documentation]   Connect To Radio Unit Tdd via RU Index
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-10-10 | create |
    ...    | chris.l.cao | 2023-3-5 | adapt to AZQJ |
    ...    | hongping.rao | 2023-4-25 | add need_login_local_ip, default is True |
    ...
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | no | ru index, start with 1 |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    *RETURN VALUE*
    ...    A alias which conected ru.
    ...
    ...    Example
    ...    | alias | Connect To Radio Unit Tdd via RU Index | 1 | 0 | 0 |
    ...    | ${out} | issh.Execute command=ls -l | alias=${alias} |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ${RU_info_list}    Get Ru Info List Including Ip    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${flag}   Set Variable   ${0}
    FOR  ${info}  in   @{RU_info_list}
        ${tmp}   Evaluate    ${flag}+${1}
        ${flag}   Set Variable If   '${info}[type]'=='TDD'  ${tmp}   ${flag}
        ${connection_info}    Set Variable If   '${flag}'=='${ru_index}'   ${info}
        Exit For Loop If   '${flag}'=='${ru_index}'
    END
    ${ru_ip}   Set Variable    ${connection_info}[ip]
    ${username}   Set Variable    ${connection_info}[username]
    ${password}   Set Variable    ${connection_info}[password]
    ${ru_prompt}   Set Variable    ${connection_info}[prompt]
    ${alias}     Connect To RU Of TDD via IP     ru_ip=${ru_ip}    password=${password}    ru_prompt=${ru_prompt}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}   rf_login_name=${username}
    ...    need_login_local_ip=${need_login_local_ip}
    [Return]   ${alias}


Get MiocroDTX Value
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Get MiocroDTX Value
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-11-2 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb index |
    ...    | vdu_index | No | vdu index |
    ...    *RETURN VALUE*
    ...    A list contain all value like.
    ...
    ...    *Example*
    ...    | result_list | Get MiocroDTX Value |
    ${RU_infos}   Get Ru Info List Including Ip   gnb_index=${gnb_index}   vdu_index=${gnb_index}
    ${result_list}   Create List
    FOR   ${info}   IN   @{RU_infos}
       Continue For Loop If   '${info}[type]'!='TDD'
       ${value}  Check MiocroDTX on Different Type   ${info}
       ${value_dict}    Create Dictionary   ${info}[model]=${value}
       Append to List   ${result_list}   ${value_dict}
    END
    [Return]   ${result_list}


Check MiocroDTX on Different Type
    [Arguments]   ${ru_info}
    [Documentation]   Check MiocroDTX on Different Type
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2022-11-2 | create |
    ...    | r3li | 2022-12-19 | optimize keyword |
    ...    | r3li | 2022-3-6 | optimize keyword |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | ru_info | Yes | ru info can get from keyword Get Ru Info List Including Ip |
    ...    *RETURN VALUE*
    ...    MiocroDTX value
    ...
    ...    Example
    ...    | value | Check MiocroDTX on Different Type | {'2nduser': 'root',
    ...   'atten': {'2', '5', '7', '6', '3', '1', '0', '4'},
    ...   'ip': '192.168.252.45',
    ...   'mac': '48:ec:5b:54:fb:6d',
    ...   'model': 'AEQY',
    ...   'password': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    ...   'prompt': 'Node0:~#',
    ...   'rf_local_ip': ['192.168.101.2'],
    ...   'sn': '03661',
    ...   'type': 'TDD',
    ...   'username': 'serviceuser'} |
    ${commond_list}   get_ru_MiocroDTX_cli   ${ru_info}[model]
    ${command_1}   Set Variable   ${commond_list}[0]
    ${command_2}   Set Variable   ${commond_list}[1]
    ${command_3}   Set Variable   ${commond_list}[2]
    ${rf_local_ip}   Set Variable   ${ru_info}[rf_local_ip][0]
    ${alias}  Connect To RU Of TDD via IP   ${ru_info}[ip]   ${ru_info}[password]    ${ru_info}[prompt]
    ...   rf_login_name=${ru_info}[username]    need_login_local_ip=${False}

    issh.set_prompt   \\$   alias=${alias}
    issh.Execute   command=frmonShellClient localhost 2000   alias=${alias}   check_result=${False}
    sleep  1
    ${out}  issh.Execute   command=${command_1}   alias=${alias}   check_result=${False}
    ${power}  Set Variable   ${0}
    FOR  ${i}   IN RANGE   ${3}
       Sleep    3
       ${_power}    Wait Until Keyword Succeeds  60   20    _Check Power ON RU    alias=${alias}   command=${command_2}
       ${power}    Evaluate   int(${_power})+${power}
    END
    ${result}    Evaluate   ${power}/${3}

    [Return]  ${result}
    [Teardown]   Run Keywords   issh.Execute   command=${command_3}   alias=${alias}   check_result=${False}
      ...   AND  issh.disconnect   ${alias}

_Check Power ON RU
    [Arguments]    ${alias}     ${command}
    ${out}  issh.Execute   command=${command}   alias=${alias}   check_result=${False}
    ${out}   Strip Prompt   ${out}
    ${out_list}  Split String   ${out}   POWER
    ${_power}   Set Variable    ${out_list}[-1]
    ${_power}   Strip String    ${_power}
    Run Keyword If   '''failed''' in '''${_power}'''   Fail    check power on ru fail.
    [Return]   ${_power}

Get The Number of RU From Testline Configuration
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${fhgw_index}=0
    [Documentation]   Get RU number from testline configuration
    ...    *author*: mengtian.yu@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | mengyu | 2023-03-23 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index |
    ...    | vdu_index | no | vdu index |
    ...    | fhgw_index | no | fhgw index |
    ...    *RETURN VALUE*
    ...    RU number
    ${ru_number}   get length   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[${fhgw_index}].rus}
    [Return]   ${ru_number}
