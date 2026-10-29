*** Settings ***
Documentation
...   author: cheng xianbiao
...   contact: xianbiao.cheng@nokia-sbell.com



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

Enable RU SSH From SCF and Update serviceuser Password
   [Arguments]    ${quantity_of_cu}=0   ${serviceuser_new_pwd}=Nokia@123
   FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        Enable RU SSH From SCF and Update serviceuser Password on Specific CU  gnb_index=${gnb_index}   serviceuser_new_pwd=${serviceuser_new_pwd}
   END

Enable RU SSH From SCF and Update serviceuser Password Not Using RFRL
   [Arguments]    ${quantity_of_cu}=0   ${serviceuser_new_pwd}=Nokia@123
   FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        Enable RU SSH From SCF and Update serviceuser Password on Specific CU Not Using RFRL  gnb_index=${gnb_index}
        ...    serviceuser_new_pwd=${serviceuser_new_pwd}
   END


Enable RU SSH From SCF and Update serviceuser Password on Specific CU
    [Arguments]    ${gnb_index}=0   ${serviceuser_new_pwd}=Nokia@123
    ${quantity_of_vdu}   Get vDU Number  ${gnb_index}
    FOR  ${vdu_index}  IN RANGE  ${quantity_of_vdu}
        Enable SSH For RU In SCF  gnb_index=${gnb_index}    vdu_index=${vdu_index}
        Change The Password Of Serviceuser Account Via Webem  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        ...  serviceuser_new_pwd=${serviceuser_new_pwd}
    END

Enable RU SSH From SCF and Update serviceuser Password on Specific CU Not Using RFRL
    [Arguments]    ${gnb_index}=0   ${serviceuser_new_pwd}=Nokia@123
    ${quantity_of_vdu}   Get vDU Number  ${gnb_index}
    FOR  ${vdu_index}  IN RANGE  ${quantity_of_vdu}
        Enable SSH For RU In SCF Not Using RFRL  gnb_index=${gnb_index}    vdu_index=${vdu_index}
        Change The Password Of Serviceuser Account Via Webem  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        ...  serviceuser_new_pwd=${serviceuser_new_pwd}
    END


Should Have Power On All RUs
    [Arguments]     ${cu_quantity}=${EMPTY}    ${use_taf_rfrl_cbts}=${True}
    [Documentation]   Check there is power on all RUs (include TDD and FDD)defined in init config.
    ...    author: fen.huang@nokia-sbell.com
    ...    lingting.sun@nokia-sbell.com  <16-09-2021>, <lingtsun>, Add TDD RF check
    ...    hongyuan.sun@nokia-sbell.com  <24-01-2022>, <hongysun>, Add cu_quantity parameter
    ...    chris.l.cao@nokia-sbell.com  <22-5-2024>, Add use_taf_rfrl_cbts with default value True,
    ...                                              so we can call it with False to solve failure while calling rfrl lib
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | cu_quantity | no | Number of custom cu |
    ...    | use_taf_rfrl_cbts | no | True: use taf.rfrl.cbts lib, otherwise not use this lib, default is True |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Should Have Power On All RUs  |  ${2}  |
    log to console    Check power start...
    ${quantity_of_cu_tmp}   get length   ${tl.gnbs}
    ${quantity_of_cu}    set variable if    "${cu_quantity}"=="${EMPTY}"   ${quantity_of_cu_tmp}
    Run Keyword If    "${use_taf_rfrl_cbts}"=="${True}"
       ...    Enable RU SSH From SCF and Update serviceuser Password   quantity_of_cu=${quantity_of_cu}   serviceuser_new_pwd=Nokia@123
    ...  ELSE
      ...   Enable RU SSH From SCF and Update serviceuser Password Not Using RFRL   quantity_of_cu=${quantity_of_cu}   serviceuser_new_pwd=Nokia@123

    ${is_dc}    set variable   ${0}
    ${is_dc}    Get RU Direct Connection Flag
    run keyword if    "${is_dc}"=="${0}"    log to console   Site Type: SWN
    run keyword if    "${is_dc}"=="${1}"    log to console   Site Type: Direct-connect
    ${is_in_teardown}=    Is Run In TearDown
    run keyword if   "${is_in_teardown}"=="${False}"
    ...    _Should Have Power On All RUs In Case   quantity_of_cu=${quantity_of_cu}    is_dc=${is_dc}  serviceuser_new_pwd=Nokia@123
    ...   ELSE IF    "${is_in_teardown}"=="${True}"
    ...    _Should Have Power On All RUs In Case Teardown   quantity_of_cu=${quantity_of_cu}    is_dc=${is_dc}  serviceuser_new_pwd=Nokia@123

_Should Have Power On All RUs In Case
    [Arguments]     ${quantity_of_cu}    ${is_dc}=${0}  ${serviceuser_new_pwd}=${None}
    log to console   \n*** Should have power on all rus... ***
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        Should Have Power On RUs Under Specified vCU   ${gnb_index}    is_dc=${is_dc}  serviceuser_new_pwd=${serviceuser_new_pwd}
    END

_Should Have Power On All RUs In Case Teardown
    [Arguments]     ${quantity_of_cu}    ${is_dc}=${0}  ${serviceuser_new_pwd}=${None}
    log to console   \n*** Should have power on all rus in case teardown... ***
    ${exist}    Run Keyword And Return Status    Variable Should Exist     ${POST_RU_POWER}
    run keyword if   "${exist}"=="${False}"   set test variable   ${POST_RU_POWER}   ${False}
    ${r_tmp}    Set Variable    ${True}
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        ${r}    Run Keyword And Return Status    Should Have Power On RUs Under Specified vCU   ${gnb_index}  is_dc=${is_dc}
        ...  serviceuser_new_pwd=${serviceuser_new_pwd}
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
    Log To Console    ${2nduser}
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
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
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
    ${mac_ip_list}    utils.get_mac_ip_list_from_csv_txt     ${total_content}
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
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
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
    [Arguments]     ${ru_ip}     ${username}    ${password}    ${ru_prompt}=Node0:~#     ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Log in Ru with Ecpri Interface of TDD via IP
    ...    *author*: zhijiang.shan@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | zhijiang | 2022-10-17 | create |
    ...    | rao hongping | 2023-08-29 | update for AZQJ |
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
    Log To Console    ${gnb_index}
    Log To Console    ${vdu_index}
    ${alias}   Get Unique Id
    Connect To VDU Container Interactively    oamfh    oamfh    alias=${alias}
    ${cmd}    Set Variable    ssh -o StrictHostKeyChecking=no ${username}@${ru_ip}
    ${old_prompt}    issh.get prompt    alias=${alias}
    issh.set prompt   ${old_prompt}|password:   alias=${alias}
    ${out}    issh.Execute   command=${cmd}    alias=${alias}     check_result=${False}
    issh.set prompt   ${old_prompt}|${ru_prompt}|:~#|:~\$   alias=${alias}
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
    FOR  ${info}  IN   @{RU_info_list}
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

Get MicroDTX Value For FDD RU
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${fhgw_index}=0
    [Documentation]   Get MiocroDTX on FDD RU supporting DC and SWN.
    ...    *author*: calla.wang@nokia-sbell.com
    ...    *RETURN VALUE*
    ...    MiocroDTX value, i.e. [{'AHCA': 76.0}, {'AHCA': 77.67}]
    ${result_list}   Create List
    ${is_dc}    set variable   ${0}
    ${is_dc}    Get RU Direct Connection Flag  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    Enable SSH For RU In SCF  gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Change The Password Of Serviceuser Account Via Webem  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ...  serviceuser_new_pwd=Nokia@123
    ${TDD_RUs}  ${FDD_RUs}    Get TDD/FDD RU Info On Specific vCU And VDU
    ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}    serviceuser_new_pwd=Nokia@123
    ${FDD_RUs}=   Run Keyword If    ${is_dc}==${1}  Updating DC RU IP   FDD_RUS=${FDD_RUs}  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...  ELSE   ru_fdd_ope.get_ru_ip   ru_infos=${FDD_RUs}  gnb_index=${gnb_index}
    ...   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}

    FOR  ${fdd_ru}  IN  @{FDD_RUs}
        ${alias}=   Run Keyword If    ${is_dc}==${1}  Connect To DC FDD RU    ${fdd_ru}    ${gnb_index}      ${vdu_index}
        ...  ELSE  Connect To FDD RU  ${fdd_ru}  ${gnb_index}    ${vdu_index}   ${fhgw_index}
        ${power_consumption}=   Get Power Consumption   ru_info=${fdd_ru}   alias=${alias}
        ${value_dict}    Create Dictionary   ${fdd_ru}[model]=${power_consumption}
        Append to List   ${result_list}   ${value_dict}
    END
    [Return]   ${result_list}
    [Teardown]   Run Keyword And Ignore Error   Run Keywords   ssh_conn.disconnect_vdu_cloud_hosting  alias=${alias}
    ...  AND    ru_fdd_ope.disconnect_from_ru  alias=${alias}

Get Power Consumption
    [Arguments]   ${ru_info}   ${alias}
    ${commond_list}   get_ru_MiocroDTX_cli   ${ru_info}[model]
    ${command_1}   Set Variable   ${commond_list}[0]
    ${command_2}   Set Variable   ${commond_list}[1]
    ${command_3}   Set Variable   ${commond_list}[2]
    ssh_conn.execute_normal_cmd   base_command=frmonShellClient localhost 2000   alias=${alias}   check_result=${False}
    sleep  1
    ${out}  ssh_conn.execute_normal_cmd   base_command=${command_1}   alias=${alias}   check_result=${False}
    ${power}  Set Variable   ${0}
    FOR  ${i}   IN RANGE   ${3}
        Sleep    3
        ${_power_tmp}    Wait Until Keyword Succeeds  60   20    _Check Power ON FDD RU    alias=${alias}   command=${command_2}
        ${power}    Evaluate   int(${_power_tmp})+${power}
    END
    ${result}    Evaluate   round(${power}/${3}, 2)
    [Return]  ${result}
    [Teardown]    ssh_conn.execute_normal_cmd   base_command=${command_3}   alias=${alias}    check_result=${False}

_Check Power ON FDD RU
    [Arguments]    ${alias}     ${command}
    ${out}   ssh_conn.execute_normal_cmd   base_command=${command}   alias=${alias}   check_result=${False}
#    ${out}   Strip Prompt   ${out}
    ${out_list}  Split String   ${out}   POWER
    ${_power}   Set Variable    ${out_list}[-1]
    ${_power_tmp}   Strip String    ${_power}
    Run Keyword If   '''failed''' in '''${_power}'''   Fail    check power on ru fail.
    [Return]   ${_power_tmp}


Updating DC RU IP
    [Arguments]    ${FDD_RUS}   ${gnb_index}=0    ${vdu_index}=0
    ${sn_mac_dict}    tl_config.get_all_ru_sn_mac_dict_from_tl     gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${FDD_RUS}    ru_generic.replace sn with mac    ${FDD_RUS}    ${sn_mac_dict}
    ${FDD_RUS}=    Wait Until Keyword Succeeds     30s   3   ru_operations._Get Final SN IP Mapping   ${FDD_RUS}
    ...   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    [Return]    ${FDD_RUS}


Connect To DC FDD RU
    [Arguments]    ${fdd_ru}  ${gnb_index}=0    ${vdu_index}=0
    ${alias}=  Wait Until Keyword Succeeds   3x   10  VDU Connect To Container   oamfh-0   oamfh
    ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${password}   set variable    ${fdd_ru}[password]
    ${2nduser}   set variable    ${fdd_ru}[2nduser]
    ${RF_ip}   set variable   ${fdd_ru}[ru_ip]
    ${rf_local_ip_list}   set variable   ${fdd_ru}[rf_local_ip]
    ru_dc_fdd_ope.connect to ru fdd dc    ru_ip=${RF_ip}  username=${2nduser}  password=${password}
    ...  ru_local_ip=${rf_local_ip_list}  alias=${alias}   need_login_local_ip=${False}
    [Return]    ${alias}


Connect To FDD RU
    [Arguments]    ${fdd_ru}  ${gnb_index}=0    ${vdu_index}=0     ${fhgw_index}=0
    ${alias}=   ru_fdd_ope.connect_to_ru_fdd  ru_info=${fdd_ru}   gnb_index=${gnb_index}
    ...   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}   alias=${alias}
    [Return]    ${alias}



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
    Log To Console    ${vdu_index}
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
    ${power1}  Set Variable   ${0}
    FOR  ${i}   IN RANGE   ${3}
        Sleep    3
        ${power2}    Wait Until Keyword Succeeds  60   20    _Check Power ON RU    alias=${alias}   command=${command_2}
        ${power}    Evaluate   int(${power2})+${power1}
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

Get Specific RU Related Cell id
   [Arguments]    ${rmods_id_list}
   [Documentation]      Get Specific RU Related Cell id
    ...    *Author*:        liting.cao@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what or how |
    ...    | 12-09-2023 | liting.cao | initial created |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | rmods_id_list | Yes |  rmod id list, [1, 2, 3].   |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | Get Specific RU Related Cell id | rmods_id_list=${rmods_id_list} |
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    @{cell_id_list}  Create List
    FOR    ${i}    IN RANGE    0    ${RU_info.__len__()}
        ${RU_id}   get from dictionary    ${RU_info}[${i}]   id
        ${cell_ids}   get from dictionary    ${RU_info}[${i}]   cell_ids
        @{cell_id_list}=   run keyword if    "${RU_id}" in "${rmods_id_list}"
        ...  _combine cell_id_list    cell_id_list=${cell_id_list}    cell_ids=${cell_ids}
        ...  ELSE   set variable   ${cell_id_list}
    END
    [Return]    ${cell_id_list}

_combine cell_id_list
    [Arguments]    ${cell_id_list}    ${cell_ids}
    ${cell_id_list}=   run keyword if    "${cell_id_list}"!="None"
    ...  combine lists    ${cell_id_list}    ${cell_ids}
    ...  ELSE   set variable   ${cell_id_list}
    [Return]    ${cell_id_list}



Get RANNIC Distname From Cell Id
    [Arguments]  ${cell_id}=0  ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Get RANNIC Distname From Cell Id
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  9.11.2023,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | cell_id  | no | cell_index, value range is from 1 to N, default is 1,  |
    ...	   | gnb_index  | no | gnb_index, value range is from 0 to N, default is 0 |
    ...	   | vdu_index | no | vdu_index, value range is from 0 to N, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   RANNIC_dist_name, e.g, MRBTS-10823/EQM_R-1/APEQM_R-1/RNICMOD_R-1
    ...
    ...    Example
    ...    | ${RANNIC_dist_name} | Get RANNIC Distname From Cell Id | cell_id=1 |
    ...    | ${RANNIC_dist_name} | Get RANNIC Distname From Cell Id | cell_id=2 | gnb_index=0 | vdu_index=1 |
    ...    | ${RANNIC_dist_name} | Get RANNIC Distname From Cell Id | cell_id=3 | vdu_index=1 |
    ...
    ${rmod_dist_name}   Get RMOD Distname From Cell Id   cell_id=${cell_id}   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${RANNIC_dist_name}   Get RANNIC Distname From RMOD Distname   rmod_dist_name=${rmod_dist_name}  gnb_index=${gnb_index}  vdu_index=${vdu_index}

    [Return]  ${RANNIC_dist_name}


Get RMOD Distname From Cell Id
    [Arguments]  ${cell_id}=1  ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Get RU Index From Cell Index
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  9.11.2023,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | cell_id  | no | cell_id, value range is from 1 to N, default is 1,  |
    ...	   | gnb_index  | no | gnb_index, value range is from 0 to N, default is 0 |
    ...	   | vdu_index | no | vdu_index, value range is from 0 to N, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    RMOD dist_name, e.g,  MRBTS-108191/EQM-1/APEQM-1/RMOD-2
    ...
    ...    Example
    ...    | ${rmod_dist_name} | Get RMOD Distname From Cell Id | cell_id=1 |
    ...    | ${rmod_dist_name} | Get RMOD Distname From Cell Id | cell_id=2 | gnb_index=0 | vdu_index=1 |
    ...    | ${rmod_dist_name} | Get RMOD Distname From Cell Id | cell_id=3 | vdu_index=1 |
    ...
    ${alias}   VDU Rest Login   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${RU_info}  vdu.Get_Rmods_Status   vdu_connection=${alias}

    ${ru_cell_id_mapping}   Create Dictionary

    FOR    ${i}    IN RANGE    0    ${RU_info.__len__()}
        ${cell_ids}   Get From Dictionary    ${RU_info[${i}]}   cell_ids
        ${dist_names}   Get From Dictionary    ${RU_info[${i}]}   dist_names
        ${RMOD_R}  Set Variable   ${dist_names["runtime"]}
        _Set RU Cell Id Mapping   ru_cell_id_mapping=${ru_cell_id_mapping}   cell_ids=${cell_ids}   RMOD_R=${RMOD_R}
    END
    Log to console   ${ru_cell_id_mapping}
    ${cell_id}   Convert To String   ${cell_id}
    ${ru_dist_name}  Get From Dictionary   ${ru_cell_id_mapping}  ${cell_id}
    [Return]   ${ru_dist_name}


_Set RU Cell Id Mapping
    [Arguments]  ${ru_cell_id_mapping}  ${cell_ids}   ${RMOD_R}
    FOR   ${cell_id}  IN  @{cell_ids}
        ${cell_id_keys}  Get Dictionary Keys  ${ru_cell_id_mapping}
        Run Keyword If  ${cell_id} not in ${cell_id_keys}   Set To Dictionary  ${ru_cell_id_mapping}  ${cell_id}   ${RMOD_R}
    END


Get RANNIC Distname From RMOD Distname
    [Arguments]  ${rmod_dist_name}   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]   Get RANNIC Distname From RMOD Distname
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  9.11.2023,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | rmod_dist_name  | yes | rmod_dist_name, e.g, MRBTS-108191/EQM-1/APEQM-1/RMOD-1 |
    ...	   | gnb_index  | no | gnb_index, value range is from 0 to N, default is 0 |
    ...	   | vdu_index | no | vdu_index, value range is from 0 to N, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    RANNIC distname, e.g, MRBTS-10823/EQM_R-1/APEQM_R-1/RNICMOD_R-1
    ...
    ...    Example
    ...    | ${rmod_dist_name} | Get RMOD Distname From Cell Id | cell_id=1 |
    ...    it returns MRBTS-108191/EQM-1/APEQM-1/RMOD-1
    ...    | ${RANNIC_dist_name} | Get RANNIC Distname From RMOD Distname | rmod_dist_name=${rmod_dist_name} |
    ...
    ...    | ${rmod_dist_name} | Get RMOD Distname From Cell Id | cell_id=2 | vdu_index=1 |
    ...    | ${RANNIC_dist_name} | Get RANNIC Distname From RMOD Distname   | rmod_dist_name=${rmod_dist_name} | vdu_index=1 |
    ...
    ${scf_path}   Get VDU SCF From Current Plan   include_runtime_data=${True}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${LOGLINK_or_CABLINK}  Is LOGLINK Or CABLINK   ${scf_path}

    scf.load_scf  file_path=${scf_path}
    ${vdu_conf}    Get VDU Conf From SCF  scf_path=${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}
       ...   .*${LOGLINK_or_CABLINK}"\\s+distName="MRBTS-(\\d+)/EQM_R-(\\d+)/HWTOP_R-(\\d+)/${LOGLINK_or_CABLINK}-(\\d+)"\\s+.*  1  2  3  4

    ${ru_rannic_mapping}   Create Dictionary
    FOR  ${line}  IN  @{result}
        ${mrbts_id}   Set Variable   ${line[0]}
        ${eqm_id}   Set Variable     ${line[1]}
        ${hwtop_id}   Set Variable   ${line[2]}
        ${LOGLINK_or_CABLINK_id}   Set Variable   ${line[3]}
        ${dist_name}  Set Variable   MRBTS-${mrbts_id}/EQM_R-${eqm_id}/HWTOP_R-${hwtop_id}/${LOGLINK_or_CABLINK}-${LOGLINK_or_CABLINK_id}
        Log To Console  ${dist_name}
        ${firstEndpointDN}    scf.get_value_from_scf     dist_name=${dist_name}    p_name=firstEndpointDN
        ${secondEndpointDN}    scf.get_value_from_scf     dist_name=${dist_name}    p_name=secondEndpointDN
        ${ru_keys}  Get Dictionary Keys  ${ru_rannic_mapping}
        Run Keyword If  "${secondEndpointDN}" not in "${ru_keys}"   Set To Dictionary  ${ru_rannic_mapping}  ${secondEndpointDN}   ${firstEndpointDN}
    END
    Log To Console    ${ru_rannic_mapping}

    ${rannic_dist_name}  Get From Dictionary   ${ru_rannic_mapping}  ${rmod_dist_name}

    [Return]  ${rannic_dist_name}


Is LOGLINK Or CABLINK
    [Arguments]  ${scf_path}
    [Documentation]  Is LOGLINK Or CABLINK
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  9.11.2023,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | scf_path  | yes | scf_path, e.g, /tmp/myscf.xml  |
    ...
    ...    *RETURN VALUE*
    ...    LOGLINK_R or CABLINK_R
    ...
    ...    Example
    ...    | ${RANNIC_index} | Is LOGLINK Or CABLINK |   scf_path=/tmp/myscf.xml |
    ...
    scf.load_scf  file_path=${scf_path}
    ${vdu_conf}    Get VDU Conf From SCF  scf_path=${scf_path}

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}    Get Regexp Matches    ${scf_content}   .*LOGLINK_R"\\s+distName="MRBTS-\\d+/EQM_R-\\d+/HWTOP_R-\\d+/LOGLINK_R-(\\d+)"\\s+.*   1
    Return From Keyword If  ${result}    LOGLINK_R
    ${result}    Get Regexp Matches    ${scf_content}   .*LOGLINK_R"\\s+distName="MRBTS-\\d+/EQM_R-\\d+/HWTOP_R-\\d+/CABLINK_R-(\\d+)"\\s+.*   1
    [Return]  CABLINK_R


Get RU Number
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get RU Number
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-4 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   | vdu_index | NO | int,vdu index, default is 0 |
    ...
    ...   *Return*
    ...   - int, RU numbers
    ...
    ...   *Example*
    ...   | ${ru_number} | Get RU Number |
    ...
    ${all_ru_info}    Set Variable   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws[0].rus}
    ${ru_number}    Set Variable    ${all_ru_info.__len__()}
    [Return]    ${ru_number}


Get Attenuator Number
    [Documentation]   Get Attenuator Number
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-11 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   None
    ...   *Return*
    ...    Attenuator number
    ...
    ...   *Example*
    ...   | ${attenuator_number} | Get Attenuator Number |
    ...
    ${all_attenuator_info}    Set Variable   ${tl.attenuators}
    ${attenuator_number}    Set Variable    ${all_attenuator_info.__len__()}
    [Return]    ${attenuator_number}


Should Have Attenuator
    [Arguments]  ${operator}=eq  ${number}=1
    [Documentation]  Should Have Attenuator
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    *Change History*
    ...    | Date | Who | What and How |
    ...    | 2024-1-20 | chris.l.cao@nokia-sbell.com | new keyword |
    ...
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | operator | No  | operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==, gt:>, ge:>=, lt:<, le:<=, ne:!= , default is eq |
    ...    | number | No  | expected attenuator number, default is 1 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Should Have Attenuator |
    ...    | Should Have Attenuator | operator=eq | number=1 |
    ...    | Should Have Attenuator | operator=eq | number=3 |
    ...    | Should Have Attenuator | operator=ge | number=2 |
    ...
    ${operator}   set variable  ${operator.lower()}
    ${op}  Set Variable If  "${operator}"=="gt"    >
      ...    "${operator}"=="ge"   >=
      ...    "${operator}"=="lt"   <
      ...    "${operator}"=="le"   <=
      ...    "${operator}"=="ne"   !=
      ...    "${operator}"=="eq"   ==

    ${attenuator_number}    Get Attenuator Number
    Should be true   ${attenuator_number} ${op} ${number}


Enable Attenuator Power For Specific RU In Single UE Environment
    [Arguments]    ${on_call_ru_index}=0    ${enable_db_value}=0    ${disable_db_value}=120
    [Documentation]   Enable Attenuator Power For Specific RU In Single UE Environment
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2024-1-14 | chris.l.cao | init create |
    ...   | 2024-3-7 | chris.l.cao | do nothing and return from keyword if there is no attenuator in the environment |
    ...
    ...   *Argument Description*
    ...   | Input Arg     | Main | description |
    ...   | on_call_ru_index | NO | ru_index where we will make call, default is 0 |
    ...   | enable_db_value  | NO | enable_db_value, default is 0 |
    ...   | disable_db_value | NO | disable_db_value, default is 120 |
    ...
    ...   *Return*
    ...   None
    ...
    ...   *Example*
    ...   | Enable Attenuator Power For Specific RU In Single UE Environment | ue_call_ru_index=0 |
    ...   | Enable Attenuator Power For Specific RU In Single UE Environment | ue_call_ru_index=1 |
    ...
    Log To Console   Enable Attenuator Power For Specific RU In Single UE Environment
    ${attenuator_number}    Get Attenuator Number

    Run Keyword If   ${attenuator_number}==0   Log To Console   There is no attenuator, we can't operate attenuator!
    Return From Keyword If   ${attenuator_number}==0

    ${ru_number}  Get Ru Number
    ${ru_index_list}   Create List
    FOR  ${ru_index}  IN RANGE   ${ru_number}
        Append To List  ${ru_index_list}   ${ru_index}
    END
    FOR   ${i}   IN  @{ru_index_list}
        Run Keyword If  ${i}==${on_call_ru_index}  Enable RU Power Via Adjusting PA  ru_index=${i}
        ...   enable_db_value=${enable_db_value}   report_error_if_not_exist_attenuator=${True}
        Run Keyword If  ${i}!=${on_call_ru_index}  Disable RU Power Via Adjusting PA  ru_index=${i}
        ...   disable_db_value=${disable_db_value}   report_error_if_not_exist_attenuator=${True}
    END


Enable Attenuator Power For All RUs In Muliple UE Environment
    [Arguments]   ${enable_db_value}=0
    [Documentation]   Enable Attenuator Power For All RUs In Muliple UE Environment
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2024-1-14 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg     | Main | description |
    ...   | enable_db_value  | NO | enable_db_value, 0 |
    ...
    ...   *Return*
    ...   None
    ...
    ...   *Example*
    ...   | Enable Attenuator Power For All RUs In Muliple UE Environment |
    ...
    Log To Console   Enable Attenuator Power For All RUs In Muliple UE Environment
    ${ru_number}  Get Ru Number
    FOR   ${i}   IN RANGE   ${ru_number}
        Enable RU Power Via Adjusting PA  ru_index=${i}   enable_db_value=${enable_db_value}  report_error_if_not_exist_attenuator=${True}
    END


Enable RU Power Via Adjusting PA
    [Arguments]  ${ru_index}=0    ${enable_db_value}=0    ${pa_index}=${EMPTY}    ${report_error_if_not_exist_attenuator}=${True}
    [Documentation]   Enable RU Power Via Adjusting PA
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-4 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg     | Main | description |
    ...   | ru_index     | NO | ru_index, default is 0 |
    ...   | pa_index     | NO | pa_index, default is ${EMPTY}. |
    ...   |              |     | When it's ${EMPTY}, it will be set 0 if there is only one attenuator, otherwise it's same as ru_index |
    ...   | report_error_if_not_exist_attenuator | NO | When there is no attenuator, |
    ...   |                       | When attenuator does not exist, it will report error if it's ${True}, else it does not report error |
    ...
    ...   *Return*
    ...   - int, RU numbers
    ...
    ...   *Example*
    ...   | Enable RU Power Via Adjusting PA | ru_index=0 |
    ...   | Enable RU Power Via Adjusting PA | ru_index=1 |
    ...
    ${r}  ${attenuation_port_number}  Run Keyword And Ignore Error   Get RU Attenuation Ports   ru_index=${ru_index}
    Return From Keyword If   "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${False}"
    Run Keyword If  "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${True}"  Fail  There is no attenuator for ru_index:${ru_index} !

    ${attenuator_number}  Get Attenuator Number
    ${real_pa_index}  Set Variable If   "${pa_index}"!="${EMPTY}"  ${pa_index}
       ...   "${pa_index}"=="${EMPTY}" and ${attenuator_number}==1   0   ${ru_index}
    Connect To PA    pa_index=${real_pa_index}    attenuation_port_numbers=${attenuation_port_number}
    FOR  ${port}    IN    @{attenuation_port_number}
        Set PA Power Value   attenuator_port=${port}   db_value=${enable_db_value}    pa_index=${real_pa_index}
        Get PA Port Value    attenuator_port=${port}   pa_index=${real_pa_index}
    END
    Sleep  2


Disable RU Power Via Adjusting PA
    [Arguments]  ${ru_index}=0   ${disable_db_value}=120   ${pa_index}=${EMPTY}   ${report_error_if_not_exist_attenuator}=${False}
    [Documentation]   Enable RU Power Via Adjusting PA
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2023-12-14 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | ru_index | NO | ru_index, default is 0 |
    ...   | pa_index     | NO | pa_index, default is ${EMPTY}. |
    ...   |              |     | When it's ${EMPTY}, it will be set 0 if there is only one attenuator, otherwise it's same as ru_index |
    ...   | report_error_if_not_exist_attenuator | NO | When there is no attenuator, |
    ...   |                       | When attenuator does not exist, it will report error if it's ${True}, else it does not report error |
    ...
    ...   *Return*
    ...   - int, RU numbers
    ...
    ...   *Example*
    ...   | Disable RU Power Via Adjusting PA | ru_index=0 |
    ...   | Disable RU Power Via Adjusting PA | ru_index=1 |
    ...
    ${r}  ${attenuation_port_number}  Run Keyword And Ignore Error   Get RU Attenuation Ports   ru_index=${ru_index}
    Return From Keyword If   "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${False}"
    Run Keyword If  "${r}"=="FAIL" and "${report_error_if_not_exist_attenuator}"=="${True}"  Fail  There is no attenuator for ru_index:${ru_index} !

    ${attenuator_number}  Get Attenuator Number
    ${real_pa_index}  Set Variable If   "${pa_index}"!="${EMPTY}"  ${pa_index}
       ...   "${pa_index}"=="${EMPTY}" and ${attenuator_number}==1   0   ${ru_index}

    Connect To PA   pa_index=${real_pa_index}    attenuation_port_numbers=${attenuation_port_number}
    FOR  ${port}    IN    @{attenuation_port_number}
        Set PA Power Value   attenuator_port=${port}   db_value=${disable_db_value}    pa_index=${real_pa_index}
        Get PA Port Value    attenuator_port=${port}   pa_index=${real_pa_index}
    END
    Sleep  2


Connect RU To vDU
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=1   ${ru_index}=1
    [Teardown]   Run Keyword And Ignore Error   issh.disconnect   alias=${alias}
    [Documentation]   Connect RU To vDU
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2024-1-4 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | rannic_index | no | rannic_index, it starts from 1, default value is 1 |
    ...    | ru_index     | no | ru_index, it starts from 1, default value is 1 |
    ...
    ...   *Return*
    ...   - connection, delta plan change result
    ...
    ...   *Example*
    ...   | Disconnect RU From vDU |
    ...   | Connect RU To vDU |
    ...
    ${first_ru_interface_number}  Set Variable   4
    ${current_ru_interface_number}  Evaluate   int(${first_ru_interface_number})+int(${ru_index})-1
    ${ru_interface}  Set Variable   rfoe${current_ru_interface_number}

    ${conn_info}   ${delta_plan_result}   Enable Rannic Ssh Access    gnb_index=${gnb_index}   vdu_index=${vdu_index}  rannic_index=${rannic_index}
    ${alias}   Connect To Rannic   ${conn_info}
    ${old_prompt}  issh.get_prompt    alias=${alias}

    issh.set_prompt  ${old_prompt}|assword:    alias=${alias}
    ${out}   issh.Execute   command=sudo ifconfig ${ru_interface} up   check_result=${False}  alias=${alias}
    Run Keyword If   "assword:" in """${out}"""   issh.Execute   command=${conn_info["password"]}  check_result=${False}  alias=${alias}

    [Return]  ${conn_info}   ${delta_plan_result}


Disconnect RU From vDU
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=1   ${ru_index}=1
    [Teardown]   Run Keyword And Ignore Error   issh.disconnect   alias=${alias}
    [Documentation]   Disconnect RU From vDU
    ...   *Author:* chris.l.cao@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2024-1-4 | chris.l.cao | init create |
    ...
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | rannic_index | no | rannic_index, it starts from 1, default value is 1 |
    ...    | ru_index     | no | ru_index, it starts from 1, default value is 1 |
    ...
    ...   *Return*
    ...   - connection, delta plan change result
    ...
    ...   *Example*
    ...   | Disconnect RU From vDU |
    ...   | Connect RU To vDU |
    ...
    ${first_ru_interface_number}  Set Variable   4
    ${current_ru_interface_number}  Evaluate   int(${first_ru_interface_number})+int(${ru_index})-1
    ${ru_interface}  Set Variable   rfoe${current_ru_interface_number}

    ${conn_info}   ${delta_plan_result}   Enable Rannic Ssh Access  gnb_index=${gnb_index}   vdu_index=${vdu_index}  rannic_index=${rannic_index}
    ${alias}   Connect To Rannic   ${conn_info}
    ${old_prompt}  issh.get_prompt    alias=${alias}
    issh.set_prompt  ${old_prompt}|assword:    alias=${alias}

    ${out}   issh.Execute   command=sudo ifconfig ${ru_interface} down   check_result=${False}  alias=${alias}
    Run Keyword If   "assword:" in """${out}"""   issh.Execute   command=${conn_info["password"]}  check_result=${False}  alias=${alias}

    [Return]  ${conn_info}   ${delta_plan_result}


Reboot RU By CLI
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${ru_index}=1   ${timeout}=60
    [Documentation]   Reset RU By CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  24.1.2024 chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | ru_index | no | ru_index, it starts from 1, default value is 1 |
    ...    | timeout      | No | timeout, default value is 60 seconds |
    ...
    ...    *RETURN VALUE*
    ...    {'alias': 'ea866f62404e40fe8ca54f57f0bb858d',
    ...     'conn_info': {'dist_name': 'MRBTS-369371/EQM-1/APEQM-1/RMOD-1',
    ...                   'oam_ip': '10.69.13.194',
    ...                   'password': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    ...                   'port': 51201,
    ...                   'username': 'serviceuser'},
    ...     'delta_plan_result': {'need_update': False,
    ...                           'origin_para_value_dict': {'MRBTS-369371/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                                               'passwdHistoryLength': '0'}},
    ...                           'updated_para_value_dict': {'MRBTS-369371/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                                                'passwdHistoryLength': '0'}}}}
    ...
    ...    Example
    ...   | ${handle} | Reboot RU By CLI  |
    ...   | Wait Until Keyword Succeeds |  10m  | 20 | OAM Precondition Cell Should Be Onair |
    ...   | VDU Online Restore Parameters | ${handle["delta_plan_result"]}
    ...
    ...   | ${handle} | Reboot RU By CLI  | ru_index=2 |
    ...   | Wait Until Keyword Succeeds |  10m  | 20 | OAM Precondition Cell Should Be Onair |
    ...   | VDU Online Restore Parameters | ${handle["delta_plan_result"]}
    ...
    ${handle}  Connect To RU  gnb_index=${gnb_index}  vdu_index=${vdu_index}  ru_index=${ru_index}  timeout=${timeout}
    ${alias}   Set Variable   ${handle["alias"]}
    ${out}     issh.Execute    command=sudo -i    check_result=${False}    alias=${alias}
    ${out}     issh.Execute    command=pssreboot hw   check_result=${False}    alias=${alias}
    [Return]  ${handle}


Get RU Version via CLI
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0   ${ru_index}=1
    [Documentation]   Get RU Version via CLI
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index       |  no | gnb_index, default value is 0 |
    ...    | vdu_index        |  no | vdu_index, default value is 0 |
    ...    | ru_index         | No | ru_index, start from 1, default value is 1 |
    ...
    ...    *RETURN VALUE*
    ...   RU version and RU connection handle, e.g, ["RF.ERM6.trunk.20240124.016", <handle>]
    ...
    ...    Example
    ...   | ${version} | ${handle} | Get RU Version via CLI |
    ...   | ${alias} | Set Variable | ${handle["alias"]} |
    ...   | issh.disconnect | alias=${alias} |
    ...   | Log To Console  | ${version} |
    ...
    ${handle}   Connect To RU    gnb_index=${gnb_index}  vdu_index=${vdu_index}    ru_index=${ru_index}
    ${alias}      Set Variable   ${handle["alias"]}
    ${delta_plan_result}  Set Variable   ${handle["delta_plan_result"]}
    ${out}   issh.Execute  command=cat /etc/version |awk '{print $1}'   alias=${alias}
    ${out}   strip prompt  ${out}
    ${unitBldVersion}   set variable  ${out.strip()}
    [Return]   ${unitBldVersion}   ${handle}


Get RU Operational State via REST
    [Arguments]   ${ru_index}=0
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
    vDU Rest Login
    ${out}   vdu.get_rmods_status
    ${one_ru_info}   set variable  ${out[${ru_index}]}
    ${operational_state}   set variable  ${one_ru_info["operational_state"]}
    [Return]   ${operational_state}


Should Be Multiple RUs
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
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
    ${scf_file_with_fullpath}   Get VDU SCF From Current Plan    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${ru_id_list}    Get RU ID List From vDU SCF    scf_path=${scf_file_with_fullpath}
    Should Be True   ${ru_id_list.__len__()}>1   Should Be Multiple RUs!


Check RU Log if Exist In Snapshot
    [Arguments]   ${log_path}
    [Documentation]   Check RU Log if Exist In Snapshot
    ...    *author*: rui.3.li@nokia-sbell.com
    ...    *Change History*
    ...    | who | date | how or what |
    ...    | r3li | 2023-10-11 | create |
    ...    *Argument Description*
    ...    | Input Parameters | Man. | Description |
    ...    | log_path | Yes | ru log saved path |
    ...    *RETURN VALUE*
    ...
    ...    *Example*
    ...    | Check RU Log if Exist In Snapshot | /home/ute/logs/snapshot/Snapshot_20230802-081140.zip |
    ${ru_info_list}   Get RU Info List From Testline
    ${sn_list}   Create List
    ${ru_log_path_list}    Create List
    ${command}   Set Variable   unzip ${log_path}/RU_logs.zip -d ${log_path}
    OperatingSystem.Run   ${command}
    ${flag}   Set Variable  ${1}
    FOR  ${ru_info}  IN   @{ru_info_list}
        ${sn}   Set Variable   ${ru_info}[sn]
        ${ru_log_zip_name}   Set Variable   RU_${flag}.zip
        ${command_1}   Set Variable   unzip -l ${log_path}/RU_logs.zip | grep ${ru_log_zip_name}| awk '{print $NF}'
        ${result}   OperatingSystem.Run   ${command_1}
        Should Not Be Empty   ${result}   ${ru_log_zip_name} not exist.
        ${ru_unzip_path}   Set Variable   ${log_path}/${ru_log_zip_name}
        Append To List   ${sn_list}   ${sn}
        Append To List   ${ru_log_path_list}   ${ru_unzip_path}
        ${flag}   Evaluate   ${flag}+${1}
    END
    utils.check_RU_log_in_snapshot   ${sn_list}   ${ru_log_path_list}
