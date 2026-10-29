*** Settings ***
Documentation
...   author: kaihui.fan@nokia-sbell.com
...   squad group: SG4
...   Feature 5GC000955
...   5GC000955 common keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Keywords ***
General_Siso_Lock_Unlock_SFP_BBMOD_Trigger_Fault10
    [Documentation]
    ...    lock and unlock sfp from webem to trigger fault 10
    [Arguments]   ${bbmod_index}=1  ${connection}=GNB_OAM  ${fault_id}=10
    Log to console    Get SFP info
    ${bts_info}=     coam.get_bts_info   detailed_output=${True}  timeout=20    connection=${connection}
    @{bbmod_indexs}=   Create List    ${bbmod_index}
    Online Add All Sfps And Lanes On BBMOD By Get BBmod Info   ${bts_info}  ${bbmod_indexs}
    Lock sfps And Lane From webEM  ${bts_info}  ${bbmod_indexs}   ${fault_id}
    Wait until Keyword Succeeds    2min  30s    Expect Fault Should Present  faultId=10
    unLock Sfps And Lane From webEM  ${bts_info}  ${bbmod_indexs}   ${fault_id}
    Wait until Keyword Succeeds    15min  30s    verify all cells should be onair    cell_type=${cell_type}
    Online Delete All Sfps And Lanes On BBMOD By Get BBmod Info  ${bts_info}  ${bbmod_indexs}
    Wait until Keyword Succeeds    2min  30s    verify all cells should be onair    cell_type=${cell_type}

Lock Sfp And Lane From webEM
    [Documentation]
    ...        lock single bbmod sfp'lane
    [Arguments]   ${bbmod_and_sfps}  ${hw_name}=ABIL  ${tag}=configuration  ${fault_id}=10
    FOR  ${bbmod_sfp}  IN  @{bbmod_and_sfps}
        ${sfp_port}   get from dictionary  ${bbmod_sfp}  sfp_port
        ${sfp_lock_tag}   Run Keyword If   "${fault_id}"=="configuration"   Run Keyword And Return Status   Should Be Equal As Strings
        ...   ${bbmod_sfp["configuration"]}  True
        ...   ELSE IF   "${fault_id}"=="synchronization"   Run Keyword And Return Status   Should Be Equal As Strings
        ...   ${bbmod_sfp["synchronization"]}  True
        ...   ELSE   Run Keyword And Return Status   Should Be Equal As Strings  ${bbmod_sfp["data"]}  True
        Run Keyword If   ${sfp_lock_tag}  selenium_coam.lock_lane_from_sfp    hw_name=${hw_name}   object_name=${sfp_port}    lane_id=LANE-1
        ${split_string}=    Split String    ${sfp_port}    RF
        ${physical_port}=    Get From List    ${split_string}    -1
    END

unLock sfp lane from webEM
    [Documentation]
    ...        unlock single bbmod sfp'lane
    [Arguments]   ${bbmod_and_sfps}  ${hw_name}=ABIL   ${tag}=configuration  ${fault_id}=10
    FOR  ${bbmod_sfp}  IN  @{bbmod_and_sfps}
        ${sfp_port}   get from dictionary  ${bbmod_sfp}  sfp_port
        ${sfp_lock_tag}   Run Keyword If   "${fault_id}"=="configuration"   Run Keyword And Return Status   Should Be Equal As Strings
        ...   ${bbmod_sfp["configuration"]}  True
        ...   ELSE IF   "${fault_id}"=="synchronization"   Run Keyword And Return Status   Should Be Equal As Strings
        ...   ${bbmod_sfp["synchronization"]}  True
        ...   ELSE   Run Keyword And Return Status   Should Be Equal As Strings  ${bbmod_sfp["data"]}  True
        Run Keyword If   ${sfp_lock_tag}  selenium_coam.unlock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port}    lane_id=LANE-1
        ${split_string}=    Split String    ${sfp_port}    RF
        ${physical_port}=    Get From List    ${split_string}    -1
    END

Lock sfps And Lane From webEM
    [Documentation]
    ...        lock sfp'lane
    [Arguments]     ${bts_info}  ${bbmod_indexs}=[1]  ${fault_id}=10
    selenium login and disable screen lock
    FOR  ${bbmod_index}  IN  @{bbmod_indexs}
        ${bbmod_info}  ${bbmod_and_ports}  ${bbmod_ports_info_dict}  ${SFP_HW_PORTs}  Get Single BBMOD Connected SFP Ports And Info
        ...   ${bts_info}  ${bbmod_index}
        ${bbmod_product}=   get from dictionary  ${bbmod_info}  product_name
        Lock Sfp And Lane From webEM  ${bbmod_and_ports}  ${bbmod_product}  ${fault_id}
    END
    [Teardown]     selenium logout and close browser

unLock Sfps And Lane From webEM
    [Documentation]
    ...        lock sfp'lane
    [Arguments]     ${bts_info}  ${bbmod_indexs}=[1]  ${fault_id}=10
    selenium login and disable screen lock
    FOR  ${bbmod_index}  IN  @{bbmod_indexs}
        ${bbmod_info}  ${bbmod_and_ports}  ${bbmod_ports_info_dict}  ${SFP_HW_PORTs}  Get Single BBMOD Connected SFP Ports And Info
        ...   ${bts_info}  ${bbmod_index}
        ${bbmod_product}=   get from dictionary  ${bbmod_info}  product_name
        unLock sfp lane from webEM  ${bbmod_and_ports}  ${bbmod_product}  ${fault_id}
    END
    [Teardown]     selenium logout and close browser

Online Add All Sfps And Lanes On BBMOD By Get BBmod Info
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]     ${bts_info}  ${bbmod_indexs}=[1]
    selenium login and disable screen lock
    FOR  ${bbmod_index}  IN  @{bbmod_indexs}
        ${bbmod_info}  ${bbmod_and_ports}  ${bbmod_ports_info_dict}  ${SFP_HW_PORTs}  Get Single BBMOD Connected SFP Ports And Info
        ...  ${bts_info}  ${bbmod_index}
        ${bbmod_object}=   get from dictionary  ${bbmod_info}  object_name
        ${bbmod_product}=   get from dictionary  ${bbmod_info}  product_name
        Online Add Objection Sfps And Lanes On Sinlge BBMOD  ${bbmod_object}  ${SFP_HW_PORTs}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]     selenium logout and close browser

Online Add Objection Sfps And Lanes On Sinlge BBMOD
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]    ${bbmod_object}   ${bbmod_connected_HW_Ports}
    FOR   ${HW_PORT_ID}   IN  @{bbmod_connected_HW_Ports}
        ${SFP_ID}=   Get Substring  ${HW_PORT_ID}    -1
        log to console   ${HW_PORT_ID}
        ${sfpid}   set variable  ${SFP_ID}
        log to console  \n add SFP-${SFP_ID} and Lane-${SFP_ID}
        Online Add Objection Single Sfp And Lane  ${bbmod_object}    ${SFP_ID}    ${HW_PORT_ID}    ${sfpid}
    END

Online Add Objection Single Sfp And Lane
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]    ${bbmod_object}=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ABINET-1/BBMOD-1     ${SFP_ID}=1   ${HW_PORT_ID}=RF1  ${sfpid}=1
    log to console  \n add SFP-${SFP_ID} and Lane-${SFP_ID}
    selenium_coam.add_object  object_name=${bbmod_object}    object_class_name=SFP
    ...   is_load_default_values=${True}  id_value=${SFP_ID}   timeout=${15}
    selenium_coam.set_parameter_value    dist_name=${bbmod_object}/SFP-${SFP_ID}
    ...   filter_param=Small Form-factor pluggable identifier   abbr=sfpId   new_value=${sfpid}
    selenium_coam.set_parameter_value    dist_name=${bbmod_object}/SFP-${SFP_ID}
    ...   filter_param=HW port identifier   abbr=hwPortId   new_value=${HW_PORT_ID}
    selenium_coam.add_object  object_name=${bbmod_object}/SFP-${SFP_ID}  object_class_name=LANE
    ...   is_load_default_values=${True}  id_value=1   timeout=15
    selenium_coam.set_parameter_value    dist_name=${bbmod_object}/SFP-${SFP_ID}/LANE-1
    ...   filter_param=Administrative state   abbr=administrativeState   new_value=Unlocked
    selenium_coam.set_parameter_value    dist_name=${bbmod_object}/SFP-${SFP_ID}/LANE-1
    ...   filter_param=Lane of [Q]SFP device identifier   abbr=laneId   new_value=1

Online Delete All Sfps And Lanes On BBMOD By Get BBmod Info
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]  ${bts_info}  ${bbmod_indexs}=[1]
    selenium login and disable screen lock
    FOR  ${bbmod_index}  IN  @{bbmod_indexs}
        ${bbmod_info}  ${bbmod_and_ports}  ${bbmod_ports_info_dict}  ${SFP_HW_PORTs}  Get Single BBMOD Connected SFP Ports And Info
        ...  ${bts_info}  ${bbmod_index}
        ${bbmod_object}=   get from dictionary  ${bbmod_info}  object_name
        Online Delete Objection Sfps And Lanes On Sinlge BBMOD  ${bbmod_object}  ${SFP_HW_PORTs}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]     selenium logout and close browser

Online Delete Objection Sfps And Lanes On Sinlge BBMOD
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]    ${bbmod_object}   ${bbmod_connected_HW_Ports}
    FOR   ${HW_PORT_ID}   IN  @{bbmod_connected_HW_Ports}
        ${SFP_ID}=   Get Substring  ${HW_PORT_ID}    -1
        log to console   ${HW_PORT_ID}
        ${sfpid}   set variable  ${SFP_ID}
        Online Delete Objection Single Sfp And Lane  ${bbmod_object}    ${SFP_ID}
    END

Online Delete Objection Single Sfp And Lane
    [Documentation]
    ...        online Delete MO SFP and Lane
    [Arguments]  ${bbmod_object}=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/ABINET-1/BBMOD-1     ${SFP_ID}=1
    log to console  \n delete SFP-${SFP_ID} and Lane-1
    selenium_coam.remove_object    object_name=${bbmod_object}/SFP-${SFP_ID}/LANE-1    timeout=15
    selenium_coam.remove_object    object_name=${bbmod_object}/SFP-${SFP_ID}    timeout=15

Get Single BBMOD Connected SFP Ports And Info
    [Documentation]  Author:kaihui.fan@nokia-sbell.com
    ...      Description: Get connected physical port and configuration by port
    ...      Example: Get Connectioned Physical Port And Configuration By Port    links    dict_of_links    port    connection
    ...      Return:  [{physicalPort:RF1,sfpConfiguration:/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1}]
    [Arguments]   ${bts_info}   ${bbmod_index}=1    ${connection}=GNB_OAM
    log to console     Get BBMOD Connected SFP Ports And Info
    ${bbmod_info}   Get bbmod Object And Product Name    ${bts_info}  bbmod_index=${bbmod_index}
    ${bbmod_object_name}   Get From Dictionary    ${bbmod_info}    object_name
    ${bbmods_sfps_list}    Get BBMOD SFP Info   ${bts_info}
    @{bbmod_and_ports}   Create List
    @{SFP_HW_Ports}   Create List
    FOR   ${item}    IN    @{bbmods_sfps_list}
        Run Keyword if  '${item["bbmod_object_name"]}'=='${bbmod_object_name}'
        ...  Run Keywords   append to list  ${bbmod_and_ports}  ${item}
        ...  AND   append to list  ${SFP_HW_Ports}  ${item["sfp_port"]}
    END
    &{bbmod_ports_dict}   Create Dictionary   connected_ports=${bbmod_and_ports}
    set to dictionary  ${bbmod_ports_dict}    object_name    ${bbmod_object_name}   product_name    ${bbmod_info["product_name"]}
    [Return]  ${bbmod_info}   ${bbmod_and_ports}  ${bbmod_ports_dict}  ${SFP_HW_Ports}

Get bbmod Object And Product Name
    [Documentation]  Author:kaihui.fan@nokia-sbell.com
    ...      Description: Get connected physical port and configuration by port
    ...      Example: Get Connectioned Physical Port And Configuration By Port    links    dict_of_links    port    connection
    ...      Return:  [{physicalPort:RF1,sfpConfiguration:/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1}]
    [Arguments]    ${bts_info}   ${bbmod_index}=1
    log to console     Get BBMOD Connected SFP Ports And Info
    ${basebands}=    Set Variable   ${bts_info["requestMessage"]["basebandModules"]}
    &{bbmod_dict}   Create Dictionary
    FOR   ${baseband}   IN   @{basebands}
        ${bbmod_product_name}=   Set Variable   ${baseband["productName"]}
        ${split_string}=    Split String    ${bbmod_product_name}    ${SPACE}
        ${bbmod_product_name}=    Get From List    ${split_string}    0
        ${bbmod_object_name}=   Set Variable   ${baseband["id"]["configuration"]}
        ${status}    Run Keyword And Return Status    Should Contain   ${bbmod_object_name}   BBMOD-${bbmod_index}
        Run keyword if   '${status}'=='True'    Run Keywords  set to dictionary  ${bbmod_dict}    object_name    ${bbmod_object_name}
        ...   AND           set to dictionary  ${bbmod_dict}    product_name    ${bbmod_product_name}
    END
    [Return]    ${bbmod_dict}
Get BBMOD SFP Info
    [Documentation]  Author:kaihui.fan@nokia-sbell.com
    ...      Description: Get connected physical port and configuration by port
    ...      Example: Get Connectioned Physical Port And Configuration By Port    links    dict_of_links    port    connection
    ...      Return:  [{physicalPort:RF1,sfpConfiguration:/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1}]
    [Arguments]    ${bts_info}
    log to console     Get BBMOD Connected SFP Ports And Info
    ${cables}=       Set Variable   ${bts_info["requestMessage"]["cables"]}
    @{bbmod_sfp_list}   Create List
    FOR   ${cable}   IN   @{cables}
        &{bbmod_sfp}   Create Dictionary
        ${SFP_object}=   Set Variable   ${cable["firstEndPointId"]["configuration"]}
        @{parts}=    Split String    ${SFP_object}    /
        ${sfp_port}=    Set Variable    ${parts}[-1]
        ${empty_substring}=    Set Variable
        ${bbmod_object}=    Replace String    ${SFP_object}    /${sfp_port}  ${empty_substring}
        ${link_mode_configuration}    Set Variable  ${cable["linkMode"]["configuration"]}
        ${link_mode_data}    Set Variable  ${cable["linkMode"]["data"]}
        ${link_mode_sync}    Set Variable  ${cable["linkMode"]["synchronization"]}
        set to dictionary  ${bbmod_sfp}    sfp_object_name    ${SFP_object}
        set to dictionary  ${bbmod_sfp}    sfp_port    ${sfp_port}
        set to dictionary  ${bbmod_sfp}    configuration    ${link_mode_configuration}
        set to dictionary  ${bbmod_sfp}    data    ${link_mode_data}
        set to dictionary  ${bbmod_sfp}    synchronization    ${link_mode_sync}
        set to dictionary  ${bbmod_sfp}    bbmod_object_name    ${bbmod_object}
        Append To List    ${bbmod_sfp_list}    ${bbmod_sfp}
    END
    [Return]    ${bbmod_sfp_list}
