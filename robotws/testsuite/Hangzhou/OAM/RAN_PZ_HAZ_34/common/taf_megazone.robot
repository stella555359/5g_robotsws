*** Settings ***
Library   taf.gnb.oam.megazone_client   WITH NAME   megazone
Library   Collections
Library   OperatingSystem
Library   DateTime
Library   XML
Resource   ./gnb.robot

*** Variables ***
&{NORMAL_FSM_REQUEST}   operationalState=enabled   proceduralStatus=configured
...   planningStatus=planned   ledStatus=${2}
&{NORMAL_FBB_REQUEST}   operationalState=enabled   proceduralStatus=configured   #Availability status=online
...   administrativeState=Unlocked   planningStatus=planned   ledStatus=${2}
&{NORMAL_FRM_REQUEST}   operationalState=enabled   proceduralStatus=configured   #Availability status=online
...   administrativeState=Unlocked   planningStatus=planned   ledStatus=${2}
&{NORMAL_CELL_REQUEST}   operationalState=enabled   availabilityStatus=online   #ledStatus=${2}

*** Keywords ***
Megazone Login
    [Arguments]   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    Run Keyword and Ignore Error   wait_for_session_timeout   1   120

Catch Screenshot by xpath
    [Arguments]   ${xpath}=//body    ${dir}=${OUTPUT_DIR}   ${library}=selenium
    ${curr_data}    Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${mz_lib} =    Get Library Instance    ${library}
    Call Method    ${mz_lib._driver}    set_window_size    1920    2000
#    ${element} =    Call Method    ${mz_lib._driver}    find_element_by_xpath    ${xpath}
#    Call Method    ${element}    screenshot    ${dir}/Screen_${curr_data}.png
    Call Method    ${mz_lib._driver}    save_screenshot    ${dir}/Screen_${curr_data}.png

Get RU type
    megazone.create_session   base_url=https://${WEBUI_ADDR}   user=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ...   alias=ui_client
    ${test_state} =   megazone.get_test_state   session=ui_client   timeout=${600}
    ${RU_TYPE} =   Run Keyword If   '${test_state}'=='GNBWORU'   Set Variable   NONE
    ...   ELSE   megazone.get_frm   attribute=name   frm_id=1   session=ui_client
    Set Suite Variable   ${RU_TYPE}   ${ru_type[0:4]}
    [Teardown]    megazone.teardown_session   session=ui_client
    [Return]   ${RU_TYPE}

Get Cell info
    [Arguments]   ${cell_id}   ${session}=ui_client
    ${cell_info}   megazone.get_cell_specific_info   cell_number=${cell_id}   session=${session}
    [Return]   ${cell_info}

Megazone Client Login
    [Arguments]   ${base_url}=https://${WEBUI_ADDR}   ${user}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${alias}=MegazoneClient
    megazone.create_session   base_url=${base_url}   user=${user}   password=${password}   alias=${alias}

Megazone Client Logout
    [Arguments]   ${session}=MegazoneClient
    megazone.teardown_session   session=${session}

Megazone Client Backup SCF
    [Arguments]   ${local_dir_path}=${OUTPUT_DIR}   ${file_name}=old_commission.xml   ${session}=MegazoneClient
    megazone.get_current_scf_file   local_dir_path=${local_dir_path}   file_name=${file_name}   session=${session}   timeout=${120}

Megazone Client Load SCF
    [Documentation]   Megazone Client Load SCF
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | filepath | no | Saved SCF Path |
    ...   | session | no | Connection Session |
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml   ${session}=MegazoneClient
    megazone.perform_commissioning   scf_path=${filepath}   session=${session}   timeout=${120}

Megazone Client Get Parameter Value
    [Documentation]   Megazone Client Get Parameter Value
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | dist_name | yes | Dist Name |
    ...   | parameter | yes | Parameter Name |
    ...   | session | no | Connection Session |
    [Arguments]   ${dist_name}   ${parameter}   ${session}=MegazoneClient
    ${xpath}   Set Variable   cmData/managedObject[@distName="${dist_name}"]/p[@name="${parameter}"]
    ${scf_xml}   megazone.get_current_scf_content   session=${session}   timeout=${600}
    ${value}   XML.Get Element Text   ${scf_xml}   xpath=${xpath}
    [Return]   ${value}

Megazone Client Get SW Release
    [Documentation]   Megazone Client Get SW Release
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | session | no | Connection Session |
    [Arguments]   ${session}=MegazoneClient
    ${sw_release}   megazone.get_cbts_sw_release_name   session=${session}   timeout=${120}
    [Return]   ${sw_release}

Megazone Client Get SW Version
    [Documentation]   Megazone Client Get SW Version
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | session | no | Connection Session |
    [Arguments]   ${session}=MegazoneClient
    ${sw_version}   megazone.get_sw_version   session=${session}   timeout=${120}
    [Return]   ${sw_version}

Megazone Client Check BTS OnAir
    [Documentation]   Megazone Client Check BTS OnAir
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | session | no | Connection Session |
    [Arguments]   ${session}=MegazoneClient
    ${bts_status}   megazone.get_bts_status   session=${session}
    Should Contain   ${bts_status}   OnAir