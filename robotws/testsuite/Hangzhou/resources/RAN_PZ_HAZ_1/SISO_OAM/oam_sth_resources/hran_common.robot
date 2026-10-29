*** Settings ***
Documentation     [PURPOSE] Admin General keywords
Resource          ca_swm_general.robot
Resource          hran_frame_sbts.robot


*** Variables ***
${command_del_uboot}=   Catenate	SEPARATOR=	  \nuboot_env del netboot\nuboot_env del netboot_interface\n
...  uboot_env del macspeed\nuboot_env del bootpretries\nuboot_env del tftpretries\nuboot_env del bootptimeout\n
...  uboot_env del disable_watchdog\n

${command_set_uboot}=    Catenate	SEPARATOR=
...  \nuboot_env set netboot=netboot_first\nuboot_env set netboot_interface=lmp\n
...  uboot_env set macspeed=1G\nuboot_env set bootpretries=2\nuboot_env set tftpretries=2\n
...  uboot_env set bootptimeout=3000\nuboot_env set disable_watchdog=1\n

${command_del_R3_uboot}=    set variable    \nuboot_env del uboot_recovery\n
${command_set_R3_uboot}=    set variable    \nuboot_env set uboot_recovery=1\n


*** Keywords ***
_Get Active Sw Version By Admin
    [Documentation]    Author:amaand.li@nokia.com
    ${path}    Get InUse BTS_L Object Path_MAT
    ${version}    Get Parameter Value By Admin    dist_name=${path}/BTS_CONF-1    parameter_name=activeSoftwareVersion
    [Return]    ${version}

Get InUse BTS_L Object Path_MAT
    [Arguments]    ${mode}=2
    [Documentation]
    ${path}    Get Variable Value    ${BTS_L_OBJ_PATH}    NULL
    Return From Keyword If    '${path}'!='NULL'    ${path}
    ${path2}    Run Keyword If    ${mode}==2    _Get InUse BTS_L Object Path By Admin_MRAT
    Set Suite Variable    ${BTS_L_OBJ_PATH}    ${path${mode}}
    Return From Keyword    ${path${mode}}

_Get InUse BTS_L Object Path By Admin_MRAT
    [Documentation]    Short description.
    Start Admin
    ${obj_list}    Get Objects By Class Name    BTS_L    alias=hfv
    ${len}    Get Length    ${obj_list}
    Return From Keyword If    ${len}>0    ${obj_list[0]['distName']}
    Fail    No BTS_L Object Path Found
    [Teardown]    Stop Admin

Get Parameter Value By Admin
    [Arguments]    ${dist_name}    ${parameter_name}=NULL
    [Documentation]    | Get Parameter Value By Admin | /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1 | btsId |
    Start Admin   alias=tmp
    ${dic}    taf.sbts.oam.coam.admin.Get Parameters    ${dist_name}    alias=tmp
    Log Dictionary    ${dic}
    Return From Keyword If    '${parameter_name}'=='NULL'    ${dic}
    ${value}    Get From Dictionary    ${dic}    ${parameter_name}
    [Teardown]    taf.sbts.oam.coam.admin.Teardown Admin   alias=tmp
    [Return]    ${value}

Delete_uboot_parameters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${commands}: <description>
    [Arguments]    ${commands}=${command_del_uboot}
    Set Connection Parameters     192.168.255.129
    ${commands}    set variable if    'FSMF' in '${SMOD1}[HW_TYPE]' or 'FSIH' in '${SMOD1}[HW_TYPE]'
    ...  ${command_del_R3_uboot}    ${command_del_uboot}
    ca_swm_general.Run Remote Linux Command    ${commands}

    ${ip_to_secondary_core}  Run keyword if  ${smod2_variable_exists}
    ...  Get Command To Secondary Core  sm_variant=${SMOD2}[HW_TYPE]
    ${commands_smod2}  Run keyword if  ${smod2_variable_exists}
    ...   set variable if    'FSMF' in '${SMOD2}[HW_TYPE]' or 'FSIH' in '${SMOD2}[HW_TYPE]'
    ...  ${command_del_R3_uboot}    ${command_del_uboot}
    Run keyword if  ${smod2_variable_exists}
    ...  Run keywords  Set Connection Parameters  ${ip_to_secondary_core}   via_ip=192.168.255.129
    ...  AND  Run Remote Linux Command  ${commands_smod2}

Add_uboot_parameters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${commands}: <description>
    [Arguments]    ${commands}=${command_set_uboot}
    Set Connection Parameters     192.168.255.129
    ${commands}    set variable if    'FSMF' in '${SMOD1}[HW_TYPE]' or 'FSIH' in '${SMOD1}[HW_TYPE]'
    ...  ${command_set_R3_uboot}    ${command_set_uboot}
    ca_swm_general.Run Remote Linux Command    ${commands}
    ${ip_to_secondary_core}  Run keyword if  ${smod2_variable_exists}
    ...  Get Command To Secondary Core  sm_variant=${SMOD2}[HW_TYPE]
    ${commands_smod2_set}  Run keyword if  ${smod2_variable_exists}
    ...   set variable if    'FSMF' in '${SMOD2}[HW_TYPE]' or 'FSIH' in '${SMOD2}[HW_TYPE]'
    ...  ${command_set_R3_uboot}    ${command_set_uboot}
    Run keyword if  ${smod2_variable_exists}
    ...  Run keywords  Set Connection Parameters  ${ip_to_secondary_core}   via_ip=192.168.255.129
    ...  AND  Run Remote Linux Command  ${commands_smod2_set}

Delete_uboot_Platform_R3_parameters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${commands}: <description>
    [Arguments]    ${commands}=${command_del_R3_uboot}
    Set Connection Parameters     192.168.255.129
    ca_swm_general.Run Remote Linux Command    ${commands}

Add_uboot_Platform_R3_parameters
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${commands}: <description>
    [Arguments]    ${commands}=${command_set_R3_uboot}
    Set Connection Parameters     192.168.255.129
    ca_swm_general.Run Remote Linux Command    ${commands}
