# @Time    : 2023/9/12 11:23
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_REC_hot_remove_insert_RU_links.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Manual_SiSo_REC_hot_remove_insert_RU_links_1.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 11:23
    ${ru_index_list}    Get All Type RU Index List
    ${ru_cell_binding_info}    Get All RU&CELL Binding Info

    FOR    ${ru_index}    IN    @{ru_index_list}

        # disconnect ru cable link
        Set Test Variable    ${sfp_distname}    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-${ru_index}/LANE-1
        Modify Parameter On BTS With Activate    dist_name=${sfp_distname}    parameter=administrativeState
        ...    value=Locked

        # check fid10 alarm exist and ru&cell status disable 
        Wait Until Keyword Succeeds    5min    10s    Verify BTS Alarm Exist
        ...    fault_id=10    fault_name=No connection to unit
        Check Target RU Status Via Admin    ${ru_index}    operationalState=disabled    availabilityStatus=not installed
        Check Target RU Cells Status Via Admin    ${ru_cell_binding_info['${ru_index}']}    operationalState=disabled
        ...    availabilityStatus=failed

        # connect ru cable link
        Modify Parameter On BTS With Activate    dist_name=${sfp_distname}    parameter=administrativeState
        ...    value=Unlocked

        # check fid10 alarm not exist and ru&cell status enable 
        Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
        ...    fault_id=10    fault_name=No connection to unit
        Wait Until Keyword Succeeds    5min    30s    Check Target RU Status Via Admin
        ...    ${ru_index}    operationalState=enabled
        Wait Until Keyword Succeeds    5min    30s    Check Target RU Cells Status Via Admin
        ...    ${ru_cell_binding_info['${ru_index}']}    operationalState=enabled
    END

Get All RU&CELL Binding Info
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/11 15:26
    ...    support asirmod and rmod
    [Arguments]     ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${ru_cell_binding_info}    Create Dictionary
    ${ru_cell_binding_info}    Get Target Type RU&CELL Binding Info    asirmod    ${hw_info}    ${ru_cell_binding_info}
    ${ru_cell_binding_info}    Get Target Type RU&CELL Binding Info    rmod    ${hw_info}    ${ru_cell_binding_info}
    [Return]    ${ru_cell_binding_info}

Get Target Type RU&CELL Binding Info
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/11 15:39
    ...    ru type: asirmod, rmod
    [Arguments]    ${ru_type}    ${hw_info}    ${ru_cell_binding_info}
    ${ru_info}    Set Variable    ${hw_info.radioModules.${ru_type}}
    FOR  ${ru}  IN  @{ru_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        ${cell_index_list}    Get Target RU Cell List    ${ru.carrierList}
        Set To Dictionary    ${ru_cell_binding_info}    ${ru_index[0]}    ${cell_index_list}
    END
    [Return]    ${ru_cell_binding_info}

Get Target RU Cell List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/11 15:54
    [Arguments]    ${ru_carriers}
    ${cell_index_list}    Create List
    FOR    ${carrier}    IN    @{ru_carriers}
        ${carrier_configuration}    Set Variable    ${carrier.id.configuration}
        ${cell_index}    Get Regexp Matches    ${carrier_configuration}    NRCELL-(\\d+)    1
        Append To List    ${cell_index_list}    ${cell_index[0]}
    END
    ${cell_index_list}    Remove Duplicates    ${cell_index_list}
    [Return]    ${cell_index_list}

Check Target RU Status Via Admin
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 10:09
    [Arguments]    ${ru_index}    ${administrativeState}=None    ${operationalState}=None
    ...    ${powerState}=None    ${proceduralStatus}=None    ${usageState}=None    ${availabilityStatus}=None
    ${ru_status}    Get Target RU Status Via Admin    ${ru_index}
    Run Keyword If    '${administrativeState}'!='None'
    ...    Should Be Equal As Strings    ${administrativeState}    ${ru_status['administrativeState']}
    Run Keyword If    '${operationalState}'!='None'
    ...    Should Be Equal As Strings    ${operationalState}    ${ru_status['operationalState']}
    Run Keyword If    '${powerState}'!='None'
    ...    Should Be Equal As Strings    ${powerState}    ${ru_status['powerState']}
    Run Keyword If    '${proceduralStatus}'!='None'
    ...    Should Be Equal As Strings    ${proceduralStatus}    ${ru_status['proceduralStatus']}
    Run Keyword If    '${usageState}'!='None'
    ...    Should Be Equal As Strings    ${usageState}    ${ru_status['usageState']}
    Run Keyword If    '${availabilityStatus}'!='None'
    ...    Should Be Equal As Strings    ${availabilityStatus}    ${ru_status['availabilityStatus']}

Check Target RU Cells Status Via Admin
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 10:43
    [Arguments]    ${cell_list}    ${administrativeState}=None    ${operationalState}=None
    ...    ${powerState}=None    ${proceduralStatus}=None    ${usageState}=None    ${availabilityStatus}=None
    FOR    ${cell_index}    IN    @{cell_list}
        ${cell_status}    Get Target Cell Status Via Admin    ${cell_index}
        Run Keyword If    '${administrativeState}'!='None'
        ...    Should Be Equal As Strings    ${administrativeState}    ${cell_status['administrativeState']}
        Run Keyword If    '${operationalState}'!='None'
        ...    Should Be Equal As Strings    ${operationalState}    ${cell_status['operationalState']}
        Run Keyword If    '${powerState}'!='None'
        ...    Should Be Equal As Strings    ${powerState}    ${cell_status['powerState']}
        Run Keyword If    '${proceduralStatus}'!='None'
        ...    Should Be Equal As Strings    ${proceduralStatus}    ${cell_status['proceduralStatus']}
        Run Keyword If    '${usageState}'!='None'
        ...    Should Be Equal As Strings    ${usageState}    ${cell_status['usageState']}
        Run Keyword If    '${availabilityStatus}'!='None'
        ...    Should Be Equal As Strings    ${availabilityStatus}    ${cell_status['availabilityStatus']}
    END

Get Target Cell Status Via Admin
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 10:48
    [Arguments]    ${cell_index}    ${cell_type}=nr    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell}  IN  @{cells_info}
        ${cell_id_configuration}    set variable    ${cell['id']['configuration']}
        ${cur_cell_index}    get regexp matches    ${cell_id_configuration}    NRCELL-(\\d+)    1
        Run Keyword If    '${cur_cell_index[0]}'=='${cell_index}'
        ...    Set Test Variable    ${cell_status}    ${cell['status']}
    END
    [Return]    ${cell_status}

Get Target RU Status Via Admin
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 9:45
    [Arguments]    ${ru_index}    ${ru_type1}=rmod    ${ru_type2}=asirmod    ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${ru_info1}    Set Variable    ${hw_info.radioModules.${ru_type1}}
    FOR  ${ru}  IN  @{ru_info1}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${cur_ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        Run Keyword If    '${cur_ru_index[0]}'=='${ru_index}'
        ...    Set Test Variable    ${ru_status}    ${ru.status}
    END

    ${if_have_special_ru_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${hw_info.radioModules}    ${ru_type2}
    Run Keyword If    '${if_have_special_ru_type}'=='True'
    ...    Set Test Variable    ${ru_info2}    ${hw_info.radioModules.${ru_type2}}
    ...    ELSE    Set Test Variable    ${ru_info2}    ${EMPTY}
    FOR  ${ru}  IN  @{ru_info2}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${cur_ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        Run Keyword If    '${cur_ru_index[0]}'=='${ru_index}'
        ...    Set Test Variable    ${ru_status}    ${ru.status}
    END
    [Return]    ${ru_status}

Get All Type RU Index List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/12 10:30
    [Arguments]    ${ru_type1}=rmod    ${ru_type2}=asirmod    ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    ${ru_index_list}    Create List
    ${ru_info1}    Set Variable    ${hw_info.radioModules.${ru_type1}}
    FOR  ${ru}  IN  @{ru_info1}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${cur_ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        Append To List    ${ru_index_list}    ${cur_ru_index[0]}
    END

    ${if_have_special_ru_type}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${hw_info.radioModules}    ${ru_type2}
    Run Keyword If    '${if_have_special_ru_type}'=='True'
    ...    Set Test Variable    ${ru_info2}    ${hw_info.radioModules.${ru_type2}}
    ...    ELSE    Set Test Variable    ${ru_info2}    ${EMPTY}
    FOR  ${ru}  IN  @{ru_info2}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${cur_ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(\\d+)    1
        Append To List    ${ru_index_list}    ${cur_ru_index[0]}
    END
    Sort List    ${ru_index_list}
    [Return]    ${ru_index_list}
