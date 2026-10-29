*** Settings ***
Library             taf.sbts.oam.coam.admin    WITH NAME    SbtsAdmin

*** Variables ***
${WEBUI_IP}=                192.168.255.129
${WEBUI_USERNAME}=          Nemuadmin
${WEBUI_PASSWORD}=          nemuuser

*** Keywords ***
OAM_Admin_Login
    [Arguments]   ${bts_host}=${WEBUI_IP}   ${username}=${WEBUI_USERNAME}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${connection}=COAM

    SbtsAdmin.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${connection}

COAM_Admin_Logout
    [Arguments]   ${connection}=COAM
    SbtsAdmin.teardown      connection=${connection}

COAM_Admin_GetBTSStatus
    [Arguments]   ${component}      ${connection}=COAM
    [Documentation]  Cuicui Wang: This Keyword Is To Get Element Status
    ...    | Para | Man. | Description |
    ...    | ${component} | Yes | gNB Element Such As 'basebandModules' or 'radioModules' |
    ...    | ${connection} | No | The Name Of Connection |

    ${bts_info}   SbtsAdmin.get_bts_info   connection=${connection}   timeout=10
    ${component_status}  Run keyword If  ${component} == 'radioModules'  Run Keyword
    ...   Set Variable If  'CDD' in '${tl.tl_cloud_topology}' or 'DAS' in '${tl.tl_cloud_topology}'
    ...       ${bts_info['radioModules']['rmod']}
    ...       ${bts_info['radioModules']['asirmod']}
    ...   ELSE  Set Variable  ${bts_info[${component}]}

    [Return]   ${component_status}

COAM_Admin_CheckUnitsStatusNormal
    [Arguments]   ${component}      ${bts_host}=${WEBUI_IP}    ${connection}=COAM
    [Documentation]  Cuicui Wang: This Keyword Is To Check If Element Status Is Online Or Not
    ...    | Para | Man. | Description |
    ...    | ${component} | Yes | gNB Element Such As 'basebandModules' or 'radioModules' |
    ...    | ${connection} | No | The Name Of Connection |

#    ${bts_host}  Set Variable If  '${bts_host}' !='null'  ${bts_host}
#    ...  ${tl.master_bts} == 'gNB'    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#    ...  ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}

    OAM_Admin_Login      bts_host=${bts_host}    connection=${connection}
    ${component_status}   COAM_Admin_GetBTSStatus      ${component}      connection=${connection}
    FOR    ${element}  IN  @{component_status}
        Log To Console  ${element['status']}
        ${status_key}  Get Dictionary Keys  ${element['status']}
        ${status}  Set Variable If  'availabilityStatus' not in ${status_key}  Online
    ...  ${element['status'][u'availabilityStatus']}
        Should Contain   ${status}   Online
    END
    [Teardown]    COAM_Admin_Logout      connection=${connection}

COAM_Admin_UpdateSW
    [Arguments]   ${file_path}   ${activate}=yes   ${bts_host}=${WEBUI_IP}     ${connection}=COAM
    [Documentation]  Cuicui Wang: This Keyword Is To Upgrade gNB Build.
    ...    | Para | Man. | Description |
    ...    | ${file_path} | Yes | gNB Build Path |
    ...    | ${activate} | No | If Active New build, Default Value Is Yes |
    ...    | ${connection} | No | The Name Of Connection |

    Log To Console   \n=====Start Software Updating...=====

#    ${bts_host}  Set Variable If  '${bts_host}' !='null'  ${bts_host}
#    ...  ${tl.master_bts} == 'gNB'    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#    ...  ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}

    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    OAM_Admin_Login     bts_host=${bts_host}    connection=${connection}
    ${output_str}   SbtsAdmin.Update_Software   sw_package=${file_path}
    ...    should_activate=${True}   timeout=${3600}   connection=${connection}
    Log To Console  \n=====Software update status: ${output_str}=====
    Should Contain  ${output_str}   completed
    Log To Console  \n=====Software Update Finished, Waiting For Resetting...=====
    # COAM_Admin_Logout  connection=${connection}
    sleep  30s
    Log To Console  \n=====Reset finished!=====
    [Teardown]    COAM_Admin_Logout      connection=${connection}

Check RadioModule Status
    [Arguments]   ${component}      ${bts_host}=${WEBUI_IP}    ${connection}=COAM
    [Documentation]  Cuicui Wang: This Keyword Is To Check ASIR Status Is Online Or Not.
    ...    | 1 | Get BTS Status |
    ...    | 2 | Check if all status is Online or not |
    ...    | 3 | Return status |
    ...
    ...    | Para | Default Value | Description |
    ...    | ${component} | 'null' | Element Name Like 'radioModules' Or 'basebandModules' |
    ...    | ${connection} | COAM | Alise Of Connection |
    ...    | ${status} | Return Value | Status Of Element |

#    ${bts_host}  Set Variable If  '${bts_host}' !='null'  ${bts_host}
#    ...  ${tl.master_bts} == 'gNB'    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#    ...  ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}

    ${status}    Set Variable    Offline
    OAM_Admin_Login      bts_host=${bts_host}    connection=${connection}
    ${component_status}   COAM_Admin_GetBTSStatus      ${component}      connection=${connection}
    FOR    ${element}  IN  @{component_status}
        ${status_key}  Get Dictionary Keys  ${element['status']}
        ${status}  Set Variable If  'availabilityStatus' not in ${status_key}  Online
    ...  ${element['status'][u'availabilityStatus']}
        Exit For Loop if  '${status}'!='Online'
    END
    [Teardown]    COAM_Admin_Logout      connection=${connection}
    [Return]   ${status}
