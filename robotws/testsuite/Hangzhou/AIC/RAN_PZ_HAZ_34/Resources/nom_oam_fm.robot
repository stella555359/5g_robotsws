*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   nom_oam_fm.robot



*** Variables ***



*** Keywords ***
NOM Get History Alarms Via Rest
   [Arguments]    ${integrated_id}     ${Nom_label}=NOM13   ${filter}=${None}
   [Documentation]    NOM Get History Alarms Via Rest
    ...   *Author*: rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | how or what |
    ...   | 03-08-2022 | r3li | initial created |
    ...   | 18-10-2002 | r3li | add parameter ${filter} |
    ...   *Arguments Descrition*
    ...   | Input Parameters | Man. | Description |
    ...   | integrated_id | Yes | integrated id |
    ...   | Nom_label | No | nom label |
    ...   | filter | No | filter condition, default is None will assemble the actual filter with integrated_id, |
    ...   | otherwise use this filter, but type of filter must be list, like: |
    ...   | [{'attribute_name': 'alarmStatus', 'operator': 'EQ', 'attribute_value': 'terminated'} ] |
    ...   *RETURN VALUE*
    ...   Alarms list
    ...   *Example*
    ...   | NOM Get History Alarms Via Rest | 5253 | NOM13 |
    ...   | ${filter_dict} | Create Dictinary | attribute_name=alarmStatus | operator=EQ | attribute_value=terminated |
    ...   | ${filter_list} | Create List | ${filter_dict} |
    ...   | NOM Get History Alarms Via Rest | 5235 | NOM13 | ${filter_list} |
    ${client_id}    Nom Rest Login     ${Nom_label}
    ${filter_dict}    Create Dictionary    attribute_name=integratedId    attribute_value=${integrated_id}   operator=CONTAINS
    ${filter_list_in}    Create List    ${filter_dict}
    ${filter_list}   Set Variable If   '${filter}'=='${None}'   ${filter_list_in}    ${filter}
    ${alarms_info}=  nom_rest.get_historical_alarms    filters=${filter_list}
    [Return]   ${alarms_info["alarms"]}
    [Teardown]    Nom Rest Logout    client_id=${client_id}    nom_label=${Nom_label}
