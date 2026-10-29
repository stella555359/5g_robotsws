*** Settings ***

Documentation
...     20.01.2025 - updated FOR functions and solved RF5.0 issues

Resource          vdu_oam_cm.robot

#*** Variables ***

*** Keywords ***
Get Parameter Value
    [Arguments]     ${Abbreviation}
    [Documentation]  Get Parameter Value
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Abbreviation | yes | e.g, miNrEcpriUpFCp |
    ...
    ...    *RETURN VALUE*
    ...    Parameter Value
    ...
    ...    Example
    ...    | Parameter Value= | Get Parameter Value | Abbreviation=miNrEcpriUpFCp |
    ${xpath}=  catenate  SEPARATOR=   xpath=/html/body/vdu-webem-root/div/div/webem-single-column-layout/webem-page-layout/div/
    ...     webem-page-header/div/webem-quick-menu/ui-webem-routed-menu/ui-webem-button[3]
    Wait Until Element Is Visible   ${xpath}
    sleep   3s
    Click Element   ${xpath}
    Wait Until Element Is Visible   xpath=//*[@id="parameter-search-input"]/div/input
    sleep   3s
    input text      xpath=//*[@id="parameter-search-input"]/div/input       ${Abbreviation}
    Click Element   xpath=//*[@id="parameter-search-input"]/div/div
    Wait Until Element Is Visible   xpath=//*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr/td[4]/div
    ${Parameter_Value}=   get text  xpath=//*[@id="global-search-table"]/div[2]/p-treetable/div/div[1]/table/tbody/tr/td[4]/div
    sleep   3s
    [Return]    ${Parameter_Value}

Find Route Info
    [Arguments]   ${MO}  ${search_value1}   ${basic_para1}
    [Documentation]  Find Route Info
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | MO | yes | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 |
    ...    | search_value1 | yes | 10.0.85.170 |
    ...    | search_value2 | yes | 10.1.1.1 |
    ...    | basic_para1 | yes | destIpAddr |
    ...    | basic_para2 | yes | gateway |
    ...    *RETURN VALUE*
    ...    route_count
    ...
    ...    Example
    ...    | ${count} | Find Route Info | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 | 10.0.85.170 | 10.1.1.1 | destIpAddr | gateway |
    FOR     ${route_count}     IN RANGE     0   10
       ${value1}   Get VDU Parameter Value Online    ${MO}   forwardingEntries/${route_count}/${basic_para1}
       Exit For Loop If   "${value1}"=="${search_value1}"
       run keyword if      ${route_count}==10      fail
    END
    [Return]       ${route_count}

Activate Delta Plan Without Saving
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${timeout}=60
    [Documentation]  Activate Delta Plan Without Saving
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | dp_00000000 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | ${plan_id} | ${action_id} | Generate delta plan | DELTA-PLAN-1 |
    ...    | Validate Delta Plan By REST | ${plan_id} |
    ...    | Activate Delta Plan Without Saving | ${plan_id} |
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}

Check parameter value via SCF
    [Arguments]     ${MO}     ${para_name}     ${SCF}
    [Documentation]  Check parameter value via SCF
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | MO | yes | MRBTS-0/TNLSVC-1/TNL-1/IPNO-1/IPRT-1/IPRT_R-1 |
    ...    | para_name | yes | underLyingInterface |
    ...    | SCF | yes | scf path |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Check parameter value via SCF | MRBTS-0/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1 | underLyingInterface | ${SCF_PATH} |
    ${para_value}     Get VDU Parameter Value Online       ${MO}     ${para_name}
    ${MO_content}   Get MO Content      ${SCF}    ${MO}
    log to console     ${MO_content}
    should contain     ${MO_content}    ${para_value}

Check Parameters Modified Successfully
    [Arguments]  ${mo_dn}   ${Abbreviation}   ${check_value}
    [Documentation]  Check parameters modifiction
    ...  author: miao.a.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check parameters detail info |
    ${paramters_value}   Get VDU Parameter Value Online      ${mo_dn}      ${Abbreviation}
    should be equal     ${paramters_value}     ${check_value}

Get TNL match relationship
    [Documentation]  Get TNL match relationship
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    none
    ...
    ...    Example
    ...    | Get TNL match relationship |
    ${TNL-4_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-4_match}"""=="""certman-server oam"""  set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-4_match}"""=="""F1-C"""                set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-4_match}"""=="""F1-U"""                set variable      TNL-4
    run keyword if  """${TNL-4_match}"""=="""F1-U"""    set test variable   ${TNL_UP}
    ${TNL-5_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-5_match}"""=="""certman-server oam"""  set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-5_match}"""=="""F1-C"""                set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-5_match}"""=="""F1-U"""                set variable      TNL-5
    run keyword if  """${TNL-5_match}"""=="""F1-U"""    set test variable   ${TNL_UP}
    ${TNL-6_match}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1    uniqueIpAddressIdentifier
    ${TNL_OAM}      run keyword if  """${TNL-6_match}"""=="""certman-server oam"""  set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""certman-server oam"""  set test variable   ${TNL_OAM}
    ${TNL_CPRT}     run keyword if  """${TNL-6_match}"""=="""F1-C"""                set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""F1-C"""    set test variable   ${TNL_CPRT}
    ${TNL_UP}       run keyword if  """${TNL-6_match}"""=="""F1-U"""                set variable      TNL-6
    run keyword if  """${TNL-6_match}"""=="""F1-U"""    set test variable   ${TNL_UP}

Upload Plan
    [Documentation]  Upload Plan
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_file | yes | scf file path |
    ...    | plan_name | yes | scf file name on webem after upload |
    ...    | plan_description | no | plan description, default is empty |
    ...    *RETURN VALUE*
    ...    temp_plan_id
    ...
    ...    Example
    ...    | ${plan_id} | Upload Plan | plan_file=${SCF_PATH} |
    [Arguments]  ${plan_file}  ${plan_name}=TA_Upload_Plan  ${plan_description}=${EMPTY}
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
    sleep   2
    [Return]    ${temp_plan_id}

Validate Plan
    [Documentation]  Validate Plan
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | plan from upload plan |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Validate Plan | ${plan_id} |
    [Arguments]  ${plan_id}
    ${validate_plan_response}=  vdu.validate_plan   ${plan_id}
    wait until keyword succeeds  2min  5s  Validate Plan Operation Should Be Successful
    ...  ${plan_id}
    ...  ${validate_plan_response['action_id']}

Activate Plan
    [Documentation]  Activate Plan
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | plan from upload plan |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Activate Plan | ${plan_id} |
    [Arguments]  ${plan_id}
    ${activate_plan_response}=  vdu.activate_plan  ${plan_id}
    sleep  90s
    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be Successful
    ...  ${plan_id}
    ...  ${activate_plan_response['id']}

Add ALD Parameter Value In Staged Plan
    [Arguments]     ${plan_id}  ${mrbts_id}   ${ald_productcode}  ${ald_serialnumber}   ${ald_id}=1
    ${para_dict}    create dictionary   productCode=${ald_productcode}
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}   ${para_dict}    add
    ${para_dict}    create dictionary   serialNumber=${ald_serialnumber}
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}   ${para_dict}    add
    ${para_dict}    create dictionary   firstEndpointDN=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/RSL-1
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/HWTOP-1/LOGLINK-${ald_id}   ${para_dict}    add
    ${para_dict}    create dictionary   secondEndpointDN=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}
    ${validation_id}   Update Staged Plan Parameter    ${plan_id}   MRBTS-${mrbts_id}/EQM-1/HWTOP-1/LOGLINK-${ald_id}   ${para_dict}    add
    ${para_dict}    create dictionary   linkModeConfiguration=true
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${ald_id}   ${para_dict}    replace
    ${para_dict}    create dictionary   linkModeDC=true
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${ald_id}   ${para_dict}    replace

Add RSL Parameter Value In Staged Plan
    [Arguments]     ${plan_id}  ${mrbts_id}
    ${para_dict}    create dictionary   dcVoltageEnabled=true
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1/RSL-1   ${para_dict}  add
    ${para_dict}    create dictionary   hdlcCommunicationAllowed=true
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1/RSL-1   ${para_dict}  add

Add MO ALD LOGLINK RSL
    [Arguments]     ${mrbts_id}     ${ald_num}=1
    FOR    ${ald_id}   IN RANGE    1   ${ald_num}+1
       svdu.add_object  dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1    object_class_name=ALD
    ...     is_load_default_values=${True}   id_value=${ald_id}
       svdu.add_object  dist_name=MRBTS-${mrbts_id}/EQM-1/HWTOP-1    object_class_name=LOGLINK
    ...     is_load_default_values=${True}   id_value=${ald_id}
    svdu.add_object  dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1    object_class_name=RSL
    ...     is_load_default_values=${True}   id_value=1
    END

Add MO RAEU
    [Arguments]     ${mrbts_id}     ${ald_id}=1    ${raeu_id}=1
    svdu.add_object  dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}    object_class_name=RAEU
    ...     is_load_default_values=${True}   id_value=${raeu_id}

Add MO ALD UNIT
    [Arguments]     ${mrbts_id}     ${unit_type}=RETU    ${ald_id}=1    ${unit_id}=1
    svdu.add_object  dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}    object_class_name=${unit_type}
    ...     is_load_default_values=${True}   id_value=${unit_id}

Add RETU Parameter Value
    [Arguments]     ${mrbts_id}     ${ald_id}=1    ${retu_id}=1
    ${para_dict}    create dictionary   angle=3
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}/RETU-${retu_id}
    ...     ${para_dict}    add
    ${para_dict}    create dictionary   /antlDNList/0=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/PHYANT-1
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}/RETU-${retu_id}
    ...     ${para_dict}    add
    ${para_dict}    create dictionary   mechanicalAngle=4
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}/RETU-${retu_id}
    ...     ${para_dict}    add
    ${para_dict}    create dictionary   minAngle=0
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}/RETU-${retu_id}
    ...     ${para_dict}    add
    ${para_dict}    create dictionary   maxAngle=7
    ${validation_id}   Update Staged Plan Parameter     ${plan_id}   MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-${ald_id}/RETU-${retu_id}
    ...     ${para_dict}    add
    log to console  modify RETU complete

Get RU Version
    ${RU_version}  Get VDU Parameter Value Online  MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-12/RMOD_R-1  activeSwVersion
    [Return]  ${RU_version}
