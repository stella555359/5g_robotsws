*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: kaihui.fan
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Keywords ***
Random Lock Sfp And Lane
    [Documentation]
    ...        lock single bbmod sfp'lane
    [Arguments]   ${bbmod_and_sfps}  ${hw_name}=ABIL
    selenium login and disable screen lock
    ${random_bbmod_sfp}=    Evaluate    random.choice(${bbmod_and_sfps})    random
    ${sfp_port}   get from dictionary  ${random_bbmod_sfp}  sfp_port
    log to console  \n lock SFP ${sfp_port} and Lane-1
    selenium_coam.lock_lane_from_sfp    hw_name=${hw_name}   object_name=${sfp_port}    lane_id=LANE-1
    ${split_string}=    Split String    ${sfp_port}    RF
    ${physical_port}=    Get From List    ${split_string}    -1
    [Return]  ${sfp_port}
    [Teardown]     selenium logout and close browser

UnLock Sfp And Lane
    [Documentation]
    ...        unlock single bbmod sfp'lane
    [Arguments]   ${sfp_port}  ${hw_name}=ABIL
    selenium login and disable screen lock
    log to console  \nunlock SFP ${sfp_port} and Lane-1
    selenium_coam.unlock_lane_from_sfp    hw_name=${hw_name}    object_name=${sfp_port}    lane_id=LANE-1
    [Teardown]     selenium logout and close browser

Online Add Objection Sfps And Lanes On Sinlge BBMOD
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]    ${bbmod_object}   ${bbmod_connected_HW_Ports}
    selenium login and disable screen lock
    FOR   ${HW_PORT_ID}   IN  @{bbmod_connected_HW_Ports}
        ${SFP_ID}=   Get Substring  ${HW_PORT_ID}    -1
        log to console   ${HW_PORT_ID}
        ${sfpid}   set variable  ${SFP_ID}
        log to console  \n add SFP-${SFP_ID} and Lane-${SFP_ID}
        Online Add Objection Single Sfp And Lane  ${bbmod_object}    ${SFP_ID}    ${HW_PORT_ID}    ${sfpid}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]     selenium logout and close browser

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

Online Delete Objection Sfps And Lanes On Sinlge BBMOD
    [Documentation]
    ...        online add MO SFP and Lane, mapping the SFP to the lane, and configue the HWport to the SFP
    [Arguments]    ${bbmod_object}   ${bbmod_connected_HW_Ports}
    selenium login and disable screen lock
    FOR   ${HW_PORT_ID}   IN  @{bbmod_connected_HW_Ports}
        ${SFP_ID}=   Get Substring  ${HW_PORT_ID}    -1
        log to console   ${HW_PORT_ID}
        ${sfpid}   set variable  ${SFP_ID}
        log to console  \ndelete sfp and lanes
        Online Delete Objection Single Sfp And Lane  ${bbmod_object}    ${SFP_ID}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    [Teardown]     selenium logout and close browser

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

Verify All Cells Onair Or 1868 Raised
    [Documentation]    Author: Fan Kaihui    HGZ_SG4
    ...                Description: verify all the cells status should be correct or 1868 raised.
    ${cell_status}  Run Keyword And Return Status  verify all cells should be onair    cell_type=${cell_type}
    ${alarm_status}  Run Keyword And Return Status  Expect Fault Should Present  faultId=1868
    ${check_status}  Run Keyword And Return Status   should be true   ${cell_status} or ${alarm_status}
    Run Keyword If   ${check_status}  Log To Console  All cells are onair or no 1868 alarm raised
    ...              ELSE  Fail  cell not onair and 1868 not raised
