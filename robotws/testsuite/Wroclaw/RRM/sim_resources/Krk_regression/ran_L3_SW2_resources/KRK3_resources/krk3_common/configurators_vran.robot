*** Settings ***
Documentation
...            Keywords for modifying and uploading configuration files
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Library    taf.gnb.oam.coam.vdu       WITH NAME    coam_vdu
Library    taf.gnb.oam.coam.cu        WITH NAME    coam_vcu
Library    ute_fsmaccess
Library    ute_async
Resource   configurators.robot
Resource   taf/rfrl/cbts/interfaces.robot

*** Keywords ***
Hardware Check
    [Documentation]    Runs checks to determine if critical HW components are available.
    Get information about hardware
    Wait Until Keyword Succeeds    3 times    3s
    ...                            Wait for response from ap and gnb components
    Wait until RMODs availability status is 'on line'
    Wait until F1 link is available

Get information about hardware
    Get CU SW version
    Get DU SW version
    Get AP SW release

Wait for response from ap and gnb components
    ute_async.start_async     ute_fsmaccess     wait_until_host_is_available    ${AP_IP}      alias=ap     timeout=20
    ute_async.start_async     ute_fsmaccess     wait_until_host_is_available     ${OAM_DU}[host]     alias=vdu       timeout=20
    ute_async.start_async     ute_fsmaccess     wait_until_host_is_available    ${OAM_CU}[host]        alias=vcu       timeout=20

    Log to console   Waiting on the response from airphone and gnb components
    ute_async.wait_for_async_result    alias=ap     timeout=20
    ute_async.wait_for_async_result    alias=vdu    timeout=20
    ute_async.wait_for_async_result    alias=vcu    timeout=20

    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error    ute_async.stop_async    alias=ap
    ...   AND     Run Keyword And Ignore Error    ute_async.stop_async    alias=vdu
    ...   AND     Run Keyword And Ignore Error    ute_async.stop_async    alias=vcu

Upload Configs
    [Documentation]    Uploads IP_ADDR, IPHY, DELTA_VCU, DELTA_VDU configuration files for vRAN deployment
    ...                and reboots GNB and AP if required.
    ...                Supports user flag ``skip:config`` for skipping configuration upload.
    ...                - ``config``: Dictionary with paths to configuration files. Valid items: ip_addr, iphy, delta_vcu, delta_vdu
    ...                - ``forced_reboot``: Forced reboot after config upload, Default: no
    ...                Example:
    ...                | robot -v skip:config test_suite.robot
    [Arguments]    ${config}    ${forced_reboot}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Be True    '${forced_reboot}' in ('yes','no')    msg=Invalid KW parameter: forced_reboot
    Should Contain Any    ${config}    ip_addr   iphy    delta_vcu    delta_vdu
    ...    msg=Config dictionary does not contain any valid item: ip_addr, iphy, delta_vcu, delta_vdu
    #---------------------------------------------------------------------------------------------------------------
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    Run Keyword If    ${skip_config}    Run Keywords
    ...    Log to Console    Skipping configuration upload
    ...    AND    Return From Keyword
    ${reboot_required}    Set Variable If    'iphy' in ${config} or '${forced_reboot}' == 'yes'    ${True}    ${False}
    Run Keyword If    'ip_addr' in ${config}    Add IP Addresses To Local Interfaces    @{config.ip_addr}
    Run Keyword If    'iphy' in ${config}    Fix and Upload iphy    iphy=${config.iphy}
    Run Keyword If    'delta_vcu' in ${config}    Upload delta vcu    delta_vcu=${config.delta_vcu}
    Run Keyword If    'delta_vdu' in ${config}    Upload delta vdu    delta_vdu=${config.delta_vdu}
    ${reboot_from_delta_vcu}    Set Variable If    'delta_vcu' in ${config}   ${True}    ${False}
    ${reboot_from_delta_vdu}    Set Variable If    'delta_vdu' in ${config}   ${True}    ${False}
    Run Keyword If    ${reboot_required} and not ${reboot_from_delta_vcu} and not ${reboot_from_delta_vdu}
    ...               Reboot GNB And AP

Reboot GNB and AP
    Reboot vCU
    Reboot vDU
    Reboot AP Via Ssh
    Wait Until Keyword Succeeds  7min  20s   Hardware Check

Reboot vCU
    Log to console  Reset vCU
    ${conn_cu}    vcu.connect_to   host=${OAM_CU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    vcu.reset_cu  connection=${conn_cu}
    [Teardown]    vcu.disconnect   connection=${conn_cu}

Reboot vDU
    Log to console  Reset vDU
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    vdu.reset_vdu   vdu_connection=${conn_du}
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Import additional VRAN variables
    Set suite variable  ${NAMESPACE_CU}  ${tl.cloud_hostings[0].namespace}
    Set suite variable  ${NAMESPACE_DU}  ${tl.cloud_hostings[1].namespace}
    Set suite variable  &{MASTER_CU}
    ...  hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...  alias=cu_master
    Set suite variable  &{MASTER_DU}
    ...  hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...  alias=du_master
    Set suite variable  &{OAM_CU}
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  secure=${True}
    ...  alias=cu_admin
    Set suite variable  &{OAM_DU}
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...  secure=${True}
    ...  connection_name=du_admin
    Set suite variable  ${RRH_VLAN}  ${tl.ues[0].preferred_vlan_id}
    Set suite variable    ${AP_IP}    192.168.200.1
    ${FHUC_VLANS}=  Get variable value  ${tl.gnbs[0].dus[0].fhuc_vlans}  ${None}
    Set suite variable  ${FHUC_VLANS}
    Set suite variable  ${VCU_MASTER_IP}   ${OAM_CU}[host]
    Set suite variable  ${VDU_MASTER_IP}   ${OAM_DU}[host]

Check if cells are configured
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vdu.get_vdu_cells_status    vdu_connection=${conn_du}
    Log To Console   ${cell_info}
    Should Be Equal   ${cell_info[0]["procedural_status"]}   configured
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Upload delta vcu
    [Documentation]    Sends JSON/XML delta commissioning file to vcu in vran deployment.
    ...                - ``delta_vcu``: Pathfile to delta file
    [Arguments]    ${delta_vcu}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${delta_vcu}
    #---------------------------------------------------------------------------------------------------------------
    Log To Console    Uploading new delta: ${delta_vcu}
    vcu_cm.Enable M2M Rest API Via Delta Commission
    ${path}   ${extension}=    Split Extension     ${delta_vcu}
    Run Keyword If    '${extension}' == 'json'    vcu_cm.Fast Delta Commissioning With Delta Json File    ${delta_vcu}
    Run Keyword If    '${extension}' == 'xml'     vcu_cm.Fast Delta Commissioning With Delta XML File     ${delta_vcu}

Upload delta vdu
    [Documentation]    Sends JSON/XML delta commissioning file to vdu in vran deployment.
    ...                - ``delta_vdu``: Pathfile to delta file
    [Arguments]    ${delta_vdu}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${delta_vdu}
    #---------------------------------------------------------------------------------------------------------------
    Log To Console    Uploading new delta: ${delta_vdu}
    vdu_cm.Enable M2M Rest API Via Delta Commission
    ${path}   ${extension}=    Split Extension     ${delta_vdu}
    Run Keyword If    '${extension}' == 'json'    vdu_cm.Fast Delta Commissioning With Delta Json File    ${delta_vdu}
    Run Keyword If    '${extension}' == 'xml'     vdu_cm.Fast Delta Commissioning With Delta XML File     ${delta_vdu}
