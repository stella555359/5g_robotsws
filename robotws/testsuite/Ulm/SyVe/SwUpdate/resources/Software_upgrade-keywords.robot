*** Settings ***
Documentation    Keyword files for software upgrade procedure
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin                              WITH NAME   admin
Library    ../../../resources/Common/python/alarm_handling.py   WITH NAME   alarm_py
Library    ../sw_update_kw.py

Resource   ../../../resources/Common/testline.robot
Resource   ../../../resources/Common/log_collection.robot
Resource   ../../../resources/Common/btslog.robot
Resource   ../../../resources/Common/snapshot.robot
Resource   ../../../resources/Common/commissioning.robot
Resource   ../../../resources/Common/connect.robot
Resource   ../../../resources/Common/gnb.robot
Resource   ../../../resources/Common/alarm_handling.robot
Resource   ../../resources/syve_testline.robot
Resource   ../../resources/installation.robot
Resource   ../../resources/enb.robot

Resource   tti_dec.robot


*** Keywords ***
Execute Update GNB Software
    [Documentation]    function to update SW for gNBs
    ${gnb_num}=    Get Length    ${tl.gnbs}
    Set Test Variable    ${gnb_num}
    @{GNB_SW_UPDATE_NODE_LIST}=    Get Node Ids From Node Names   ${GNB_SW_UPDATE_NODES}
    Set Suite Variable    @{GNB_SW_UPDATE_NODE_LIST}
    Log Source And Target Software Versions For All GNBs That Shall Be Updated
    FOR   ${gnb_id}   IN    @{GNB_SW_UPDATE_NODE_LIST}
        Perform GNB SW Update    gnb_id=${gnb_id}
        Log To Console    \ngNB-${gnb_id} Sw updated successfully
    END


Execute Update ENB Software
    [Documentation]    function to update SW for eNBs
    ${enb_num}=    Get Length    ${tl.enbs}
    Set Test Variable    ${enb_num}
    @{ENB_SW_UPDATE_NODE_LIST}=    Get Node Ids From Node Names   ${ENB_SW_UPDATE_NODES}
    Set Suite variable    @{ENB_SW_UPDATE_NODE_LIST}
    Log Source And Target Software Versions For All ENBs That Shall Be Updated
    FOR   ${enb_id}   IN    @{ENB_SW_UPDATE_NODE_LIST}
        Perform ENB SW Update    enb_id=${enb_id}
        Log To Console    \neNB-${enb_id} Sw updated successfully
    END


Log Source And Target Software Versions For All GNBs That Shall Be Updated
    Log To Console      ${\n}
    ${sw_versions_info_string}=   Catenate    ${\n}   [CURRENT_SW_VERSIONS_ON_ALL_NODES]
    FOR   ${gnb_id}    IN    @{GNB_SW_UPDATE_NODE_LIST}
        ${current_gnb_sw_load}=    testline.Get gNB SW Version    ${gnb_id}
        Set Test Variable   ${current_gnb${gnb_id}_sw_load}    ${current_gnb_sw_load}
        ${sw_versions_info_string}=   Catenate    ${sw_versions_info_string}   ${SPACE} GNB-${gnb_id}: ${current_gnb${gnb_id}_sw_load}  |
        Log To Console
        ...    ${SPACE} [SW_UPDATE_PATH_GNB-${gnb_id}]: ${current_gnb${gnb_id}_sw_load} --> ${TARGET_SW_VERSION_GNB}
    END
    Log To Console      ${sw_versions_info_string}


Perform GNB SW Update
    [Arguments]    ${gnb_id}=0   ${load_init}=True   ${with_onair_state_check}=${True}
    ${current_gNB_sw_load}     testline.Get gNB SW Version    ${gnb_id}
    ${current_gNB_sw_branch}   Fetch From Left     ${current_gNB_sw_load}     _
    ${target_gNB_sw_branch}    Fetch From Left     ${TARGET_SW_VERSION_GNB}   _
    Set Test Variable    ${current_gNB_sw_branch}
    Set Test Variable    ${target_gNB_sw_branch}
    Log To Console      ${\n}current SW version on gNB-${gnb_id}: ${current_gNB_sw_load} and software branch ${current_gNB_sw_branch}
    Log To Console      ${\n}target SW version on gNB-${gnb_id}: ${TARGET_SW_VERSION_GNB} and software branch ${target_gNB_sw_branch}

    ${is_same_sw_case}   Set Variable If
    ...   '${{'_'.join($current_gNB_sw_load.split('_')[1::])}}' == '${{'_'.join($TARGET_SW_VERSION_GNB.split('_')[1::])}}'   ${True}   ${False}
    Check SW Downgrade    current_sw_load=${current_gNB_sw_load}    target_sw_load=${TARGET_SW_VERSION_GNB}
    ...    current_sw_branch=${current_gNB_sw_branch}    target_sw_branch=${target_gNB_sw_branch}
    Log To Console      ${\n}Downgrade is '${SW_DOWNGRADE}' and target SW already installed is '${is_same_sw_case}'

    Log To Console      ${\n}Check if gNB_${gnb_id} is online
    Check GNB Status Before Installation   gnb_id=${gnb_id}

    IF   '${SW_DOWNGRADE}'=='${True}'
        Install GNB Via Yaft   TARGET_SW_VERSION_GNB=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}
    ELSE IF   '${is_same_sw_case}'=='${True}'
        Load GNB Init SCF File    gnb_id=${gnb_id}
    ELSE
        Install GNB Using WEBEM And Load Init   load_init=${load_init}   TARGET_SW_VERSION_GNB=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}
    END

    IF    ${with_onair_state_check}    Wait Until Node To Be Onair State    node_id=${gnb_id}
    Run Keyword And Ignore Error    Install TTI Dec     version=${TARGET_SW_VERSION_GNB}    gnb_id=${gnb_id}
    Run Keyword And Ignore Error    Extra Check For Node After Installation    node_id=${gnb_id}   node_type=gnb


Extra Check For Node After Installation
    [Arguments]    ${node_id}=0   ${node_type}=gnb
    IF  '${node_type}'=='gnb'    Wait until X2 Link Status is Available    gnb_id=${node_id}
    syve_testline.Check Truck Roll Fault IDs    node_id=${node_id}   node_type=${node_type}


Install GNB Using WEBEM And Load Init
    [Arguments]    ${TARGET_SW_VERSION_GNB}   ${gnb_id}=0   ${load_init}=True
    Check GPS Receiver Upgrade Alarms   node_type=gnb   node_id=${gnb_id}
    Install Package Via WEBEM    version=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}
    Log To Console      ${\n}Sw Updated Successfully - loading init file is '${load_init}'
    IF  '${load_init}'=='${True}'    Load GNB Init SCF File    gnb_id=${gnb_id}


Install GNB Via Yaft
    [Arguments]    ${TARGET_SW_VERSION_GNB}    ${gnb_id}=0
    Install Package Via Yaft
    ...    version=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}    package_regex=${TARGET_SW_VERSION_GNB}_release_BTSSM_downloadable_A54.zip
    Log To Console      ${\n}Scf init file for gNB-${gnb_id} started
    Run Keyword And Ignore Error    Load GNB Init SCF File    gnb_id=${gnb_id}    timeout=10 min
    Handle Automatic Certificate Management Settings In BTS If Needed   node_type=gnb   node_id=${gnb_id}

    #sometimes radio units are disconnected after init and needs another restart before new installation
    ${capacityUnitType}=     testline.Get Capacity Unit Type    gnb_id=${gnb_id}
    Set Suite Variable    ${capacityUnitType}
    Log To Console    ${\n}Identified Capacity Unit Type: ${capacityUnitType}
    IF    'ABIL' in '${capacityUnitType}'
    ...    Run Keyword And Ignore Error    gnb.Perform GNB Reboot    gnb_id=${gnb_id}
    ...    ELSE    GNB PDU Reset   gnb_id=${gnb_id}
    Run Keyword And Ignore Error    Wait Until All DUs Up    gnb_id=${gnb_id}
    Run Keyword And Ignore Error    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}   timeout=15 min

    Log To Console      ${\n}Install software again via WEBEM
    Install Package Via WEBEM    version=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}    yaft=True


Load GNB Init SCF File
    [Arguments]    ${gnb_id}=0    ${timeout}=25 min    ${load_source_branch}=False
    Copy CPruntime From LV1 To GNB    gnb_id=${gnb_id}
    ${scf_file_name}    Get Variable Value    ${SCF_FILE_NAME}    scf.xml
    Run Keyword And Ignore Error    Copy Swconfig From LV1 To GNB    gnb_id=${gnb_id}  side=active  scf_file_name=${scf_file_name}
    Check GPS Receiver Upgrade Alarms   node_type=gnb   node_id=${gnb_id}
    IF    '${load_source_branch}'=='${True}'    Set Test Variable    ${branch_scf}    ${current_gNB_sw_branch}
    ...   ELSE    Set Test Variable    ${branch_scf}    ${target_gNB_sw_branch}
    ${init_gnb_scf_path}=    syve_testline.Get GNB Initial Config Path    gnb_id=${gnb_id}    branch_version=${branch_scf}
    ...                                                                   scf_file_name=${scf_file_name}
    ${status_full_comm}=    Run Keyword And Return Status    commissioning.Execute Full Commissioning    scf_path=${init_gnb_scf_path}
    ...                     gnb_id=${gnb_id}  use_oam_http_connection=${True}
    Log To Console      ${\n}Scf init file for gNB-${gnb_id} is loaded
    ${status_DUs}=    Run Keyword And Return Status     Wait Until All DUs Up    gnb_id=${gnb_id}
    ${status_gNBOnAir}=    Run Keyword And Return Status   Wait Until Node To Be Onair State   node_id=${gnb_id}   timeout=${timeout}
    IF    '${status_full_comm}'=='False' or '${status_DUs}'=='False' or '${status_gNBOnAir}'=='False'
    ...                 syve_testline.Check Truck Roll Fault IDs    node_id=${gnb_id}    node_type=gnb


Copy Swconfig From LV1 To GNB
    [Documentation]    copy swconfig based on TL from entity-tools for gNB nodes
    [Arguments]    ${gnb_id}=0    ${side}=passive    ${scf_file_name}=scf.xml
    Set Test Variable    ${branch_scf}    ${target_gNB_sw_branch}
    ${init_gnb_scf_path}=    syve_testline.Get GNB Initial Config Path    gnb_id=${gnb_id}    branch_version=${branch_scf}
    ${gnb_path}=    Fetch From Left   ${init_gnb_scf_path}   /scf
    ${scf_file_name_without_extension}    Fetch From Left     ${scf_file_name}    .xml
    ${postfix}    Fetch From Right    ${scf_file_name_without_extension}    scf
    ${pc_alias}=    connect.Connect To Test PC Proxy For Node    node_id=${gnb_id}
    Set Test Variable    ${gnb_add}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.addr}
    Set Test Variable    ${gnb_user}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.username}
    Set Test Variable    ${gnb_pass}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.password}
    ${alias_cu}=    connect.Connect To Node Common Unit    node_id=${gnb_id}
    ssh.execute   mount -o remount,rw,async /ffs/stb  connection=${alias_cu}
    IF    '${side}'=='active'
      ssh.execute  sshpass -p ${gnb_pass} scp ${gnb_path}/swconfig${postfix}.txt ${gnb_user}@${gnb_add}:/ffs/run/swconfig.txt  connection=${pc_alias}
    ELSE
      ssh.execute  sshpass -p ${gnb_pass} scp ${gnb_path}/swconfig${postfix}.txt ${gnb_user}@${gnb_add}:/ffs/stb/swconfig.txt  connection=${pc_alias}
    END
    ssh.disconnect    ${pc_alias}


Check GPS Receiver Upgrade Alarms
    [Documentation]    Check if gps receiver firmware upgrade is active
    ...                and waits until its complete otherwise fails.
    [Arguments]    ${node_type}=gnb   ${node_id}=0
    ${gps_receiver_alarm_firmware_upgrade_ongoing}   Set Variable   4420
    Wait Until Keyword Succeeds   30min   20sec   Alarm Should Not Be Active
    ...   node_type=${node_type}   node_id=${node_id}   faultId=${gps_receiver_alarm_firmware_upgrade_ongoing}


Alarm Should Not Be Active
    [Documentation]    Check if given alarm is active.
    [Arguments]    ${node_type}=gnb   ${node_id}=0   ${faultId}=${None}
    IF   $faultId is None   Fail   Missing argument faultId!
    ${active_alarms}  alarm_handling.Get All Alarms From Node   node_type=${node_type}   node_id=${node_id}
    ...   time_sort=${True}   with_historic=${False}   log_level=TRACE
    ${alarm_active}    alarm_py.Is Alarm Active
    ...   alarm_list=${active_alarms}   filter_raw=faultId:${faultId}   log=${TRUE}
    Should Not Be True   ${alarm_active}


Check GNB Status Before Installation
    [Documentation]    1. KW checks if gnb is commissioned (cells are configured). (could be replaced by bts commissioning state)
    ...                2. Performs full commissioning if needed
    ...                3. checks if incompatible SW alarm is active if .e.g yaft was done but RMODs aren't upgraded yet
    ...                4. triggers another SW upgrade for RMOD SW replacement
    ...                5. waits until gnb become onAir
    ...                6. performs another SCF loading (???)
    [Arguments]    ${gnb_id}=0
    ${node_status}=    Run Keyword And Return Status    Check Node Cells Not Empty
    ...    node_id=${gnb_id}  node_type=gnb

    IF   not ${node_status}
        ${init_gnb_scf_path}    syve_testline.Get GNB Initial Config Path    gnb_id=${gnb_id}
        commissioning.Execute Full Commissioning    scf_path=${init_gnb_scf_path}  gnb_id=${gnb_id}  use_oam_http_connection=${True}
        Run Keyword And Ignore Error    Wait Until Node To Be Onair State   node_id=${gnb_id}  node_type=gnb   timeout=10 min
    END

    ${active_alarms}  alarm_handling.Get All Alarms From Node  node_id=${gnb_id}  node_type=gnb
    ...   time_sort=${True}   with_historic=${False}   log_level=TRACE
    ${alarm_incompatible_sw_version_detected}   Set Variable   faultId:23
    ${incompatible_sw_gNB}    alarm_py.Is Alarm Active
    ...   alarm_list=${active_alarms}   filter_raw=${alarm_incompatible_sw_version_detected}   log=${TRUE}
    IF    ${incompatible_sw_gNB}    Install Package Via WEBEM
    ...    version=${TARGET_SW_VERSION_GNB}   gnb_id=${gnb_id}    yaft=True

    ${onAir_status_gNB}=    Run Keyword And Return Status
    ...    Wait Until Node To Be Onair State   node_id=${gnb_id}   timeout=300 sec
    IF    ${onAir_status_gNB}==False
    ...    Load GNB Init SCF File    gnb_id=${gnb_id}    timeout=15 min    load_source_branch=True


Log Source And Target Software Versions For All ENBs That Shall Be Updated
    Log To Console      ${\n}
    ${sw_versions_info_string}=   Catenate    ${\n}   [CURRENT_SW_VERSIONS_ON_ALL_NODES]
    FOR   ${enb_id}    IN    @{ENB_SW_UPDATE_NODE_LIST}
        ${current_enb_sw_load}=    testline.Get ENB SW Version    ${enb_id}
        Set Test Variable   ${current_enb${enb_id}_sw_load}    ${current_enb_sw_load}
        ${sw_versions_info_string}=   Catenate    ${sw_versions_info_string}   ${SPACE} ENB-${enb_id}: ${current_enb${enb_id}_sw_load}  |
        Log To Console
        ...    ${SPACE} [SW_UPDATE_PATH_ENB-${enb_id}]: ${current_enb${enb_id}_sw_load} --> ${TARGET_SW_VERSION_ENB}
    END
    Log To Console      ${sw_versions_info_string}


Perform ENB SW Update
    [Arguments]    ${enb_id}=0   ${load_init}=True
    ${current_eNB_old_sw_load}=    testline.Get ENB SW Version    ${enb_id}
    ${current_eNB_old_sw_branch}=      Fetch From Left     ${current_eNB_old_sw_load}     _
    ${current_eNB_sw_branch}=    syve_testline.Get ENB SW Branch    ${enb_id}
    ${current_eNB_sw_load}=    Evaluate    '${current_eNB_old_sw_load}'.replace('${current_eNB_old_sw_branch}','${current_eNB_sw_branch}')
    ${target_eNB_sw_branch}=      Fetch From Left     ${TARGET_SW_VERSION_ENB}     _
    Set Test Variable    ${current_eNB_sw_branch}
    Set Test Variable    ${target_eNB_sw_branch}
    Log To Console      ${\n}current SW version on eNB-${enb_id}: ${current_eNB_sw_load} and software branch ${current_eNB_sw_branch}
    Log To Console      ${\n}target SW version on eNB-${enb_id}: ${TARGET_SW_VERSION_ENB} and software branch ${target_eNB_sw_branch}
    ${is_same_sw_case}=   Set Variable If
    ...   '${{'_'.join($current_eNB_sw_load.split('_')[1::])}}' == '${{'_'.join($TARGET_SW_VERSION_ENB.split('_')[1::])}}'   ${True}   ${False}
    Check SW Downgrade    current_sw_load=${current_eNB_sw_load}    target_sw_load=${TARGET_SW_VERSION_ENB}
    ...    current_sw_branch=${current_eNB_sw_branch}    target_sw_branch=${target_eNB_sw_branch}
    Log To Console      ${\n}Downgrade is '${SW_DOWNGRADE}' and target SW already installed is '${is_same_sw_case}'
    Log To Console      ${\n}Check if eNB_${enb_id} is online
    Check ENB Status Before Installation    enb_id=${enb_id}
    IF   '${SW_DOWNGRADE}'=='${True}'
         Install ENB Via Yaft   TARGET_SW_VERSION_ENB=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}
    ELSE IF   '${is_same_sw_case}'=='${True}'
         Load ENB Init SCF File    enb_id=${enb_id}
    ELSE
         Install ENB Using WEBEM And Load Init   load_init=${load_init}   TARGET_SW_VERSION_ENB=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}
    END
    Wait Until Node To Be Onair State    node_id=${enb_id}    node_type=enb
    Run Keyword And Ignore Error    Extra Check For Node After Installation    node_id=${enb_id}  node_type=enb


Install ENB Using WEBEM And Load Init
    [Arguments]    ${TARGET_SW_VERSION_ENB}   ${enb_id}=0   ${load_init}=True
    Install ENB Package Via WEBEM    version=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}
    Log To Console      ${\n}SW Updated Successfully - loading init file is '${load_init}'
    IF  '${load_init}'=='${True}'    Load ENB Init SCF File    enb_id=${enb_id}


Install ENB Via Yaft
    [Arguments]    ${TARGET_SW_VERSION_ENB}    ${enb_id}=0
    installation.Install ENB Package Via Yaft
    ...    version=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}    package_regex=${TARGET_SW_VERSION_ENB}_release_BTSSM_downloadable_A54.zip
    Log To Console      ${\n}Scf init file for eNB-${enb_id} started
    Run Keyword And Ignore Error    Load ENB Init SCF File    enb_id=${enb_id}
    Handle Automatic Certificate Management Settings In BTS If Needed   node_type=enb   node_id=${enb_id}
    Install ENB Package Via WEBEM    version=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}    yaft=True


Load ENB Init SCF File
    [Arguments]    ${enb_id}=0   ${load_source_branch}=False
    Run Keyword And Ignore Error    Copy Swconfig From LV1 To ENB    enb_id=${enb_id}  side=active
    Check GPS Receiver Upgrade Alarms   node_type=enb   node_id=${enb_id}
    IF    '${load_source_branch}'=='${True}'    Set Test Variable    ${branch_scf}    ${current_eNB_sw_branch}
    ...   ELSE    Set Test Variable    ${branch_scf}    ${target_eNB_sw_branch}
    ${init_enb_scf_path}=    syve_testline.Get ENB Initial Config Path    enb_id=${enb_id}    branch_version=${branch_scf}
    ${status_full_comm}=   Run Keyword And Return Status    commissioning.Execute ENB Full Commissioning    scf_path=${init_enb_scf_path}
    ...        enb_id=${enb_id}   use_oam_http_connection=${True}
    IF   ${status_full_comm}
        Log To Console      ${\n}Scf init file for eNB-${enb_id} is loaded
    ELSE
        Log To Console      ${\n}Scf init file for eNB-${enb_id} unsuccessfully loaded!
    END

Copy Swconfig From LV1 To ENB
    [Documentation]    copy swconfig based on TL from entity-tools for eNB nodes
    [Arguments]    ${enb_id}=0    ${side}=passive
    Set Test Variable    ${branch_scf}    ${target_eNB_sw_branch}
    ${init_enb_scf_path}=    syve_testline.Get ENB Initial Config Path    enb_id=${enb_id}    branch_version=${branch_scf}
    ${enb_path}=    Fetch From Left   ${init_enb_scf_path}   /scf.xml
    ${pc_alias}=    connect.Connect To Test PC Proxy For Node    node_id=${enb_id}  node_type=enb
    Set Test Variable    ${enb_add}  ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.addr}
    Set Test Variable    ${enb_user}  ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.username}
    Set Test Variable    ${enb_pass}  ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.password}
    IF    '${side}'=='active'
    ...    ssh.execute    sshpass -p ${enb_pass} scp ${enb_path}/swconfig.txt ${enb_user}@${enb_add}:/ffs/run    connection=${pc_alias}
    ...    ELSE    ssh.execute    sshpass -p ${enb_pass} scp ${enb_path}/swconfig.txt ${enb_user}@${enb_add}:/ffs/stb    connection=${pc_alias}
    ssh.disconnect    ${pc_alias}


Check ENB Status Before Installation
    [Arguments]    ${enb_id}=0
    ${init_enb_scf_path}=    syve_testline.Get ENB Initial Config Path    enb_id=${enb_id}
    ${node_status}=    Run Keyword And Return Status    Check Node Cells Not Empty
    ...    node_id=${enb_id}  node_type=enb

    IF   not ${node_status}
        commissioning.Execute ENB Full Commissioning    scf_path=${init_enb_scf_path}  enb_id=${enb_id}   use_oam_http_connection=${True}
        Run Keyword And Ignore Error    Wait Until Node To Be Onair State   node_id=${enb_id}  node_type=enb   timeout=10 min
    END

    ${active_alarms}  alarm_handling.Get All Alarms From Node  node_id=${enb_id}  node_type=enb
    ...   time_sort=${True}   with_historic=${False}   log_level=TRACE
    ${alarm_incompatible_sw_version_detected}   Set Variable   faultId:23
    ${incompatible_sw_eNB}    alarm_py.Is Alarm Active
    ...   alarm_list=${active_alarms}   filter_raw=${alarm_incompatible_sw_version_detected}   log=${TRUE}

    IF    ${incompatible_sw_eNB}    Install ENB Package Via WEBEM
    ...    version=${TARGET_SW_VERSION_ENB}   enb_id=${enb_id}    yaft=True

    ${onAir_status_eNB}=    Run Keyword And Return Status    gnb.Wait Until Node To Be Onair State
    ...    node_id=${enb_id}  node_type=enb   timeout=300 sec

    IF    ${onAir_status_eNB}==False
    ...    Load ENB Init SCF File    enb_id=${enb_id}   load_source_branch=True


Copy CPruntime From LV1 To GNB
    [Documentation]    copy cpruntime based on TL from entity-tools for gNB nodes
    [Arguments]    ${gnb_id}
    Set Test Variable    ${branch_scf}    ${target_gNB_sw_branch}
    ${init_gnb_scf_path}=    syve_testline.Get GNB Initial Config Path    gnb_id=${gnb_id}    branch_version=${branch_scf}
    ${gnb_path}=    Fetch From Left   ${init_gnb_scf_path}   /scf.xml
    Set Test Variable    ${gnb_add}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.addr}
    Set Test Variable    ${gnb_user}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.username}
    Set Test Variable    ${gnb_pass}  ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.password}
    OperatingSystem.Run    sshpass -p ${gnb_pass} scp ${gnb_path}/cp_runtime.ini ${gnb_user}@${gnb_add}:/ffs/run


Check SW Downgrade
    [Documentation]  This keyword may be used to check if the sw update from \${current_sw_load} to \${target_sw_load} is a SW_UPGRADE or SW_DOWNGRADE
    ...  case wrt. the change of SW Release or SW Branch, respectively. Updates without change of the SW Branch are returned as \${None} case.
    ...    | Editor:     | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${current_sw_load}    ${target_sw_load}    ${current_sw_branch}=${None}    ${target_sw_branch}=${None}
    # NOTE: using string "SBTS99" instead of "SBTS00" to compare against "Trunk" SW stream to allow for simple judgement by alphabetical order later
    ${current_sw_branch}=   Set Variable If
    ...    "_ENB_999" in "${current_sw_load}" or "_FSM3_999" in "${current_sw_load}"   SBTS99
    ...    ${current_sw_branch == None}                                                    ${{ $current_sw_load.split('_')[0] }}
    ...    ${current_sw_branch}
    ${target_sw_branch}=   Set Variable If
    ...    "_ENB_999" in "${target_sw_load}" or "_FSM3_999" in "${target_sw_load}"     SBTS99
    ...    ${target_sw_branch == None}                                                     ${{ $target_sw_load.split('_')[0] }}
    ...    ${target_sw_branch}
    ${IS_SW_DOWNGRADE_CASE}=    Set Variable If
    ...    '${target_sw_branch}' == '${current_sw_branch}'      ${None}
    ...    '${target_sw_branch}' > '${current_sw_branch}'       ${False}
    ...    '${target_sw_branch}' < '${current_sw_branch}'       ${True}
    ...    ${None}
    Set Test Variable    ${SW_DOWNGRADE}    ${IS_SW_DOWNGRADE_CASE}
    Set Suite Variable   ${IS_SW_DOWNGRADE_CASE}
    RETURN   ${IS_SW_DOWNGRADE_CASE}

GNB PDU Reset
    [Documentation]    PDU reset gNB node
    [Arguments]    ${gnb_id}=0    ${time_interval}=10
    Log To Console    ${\n}INFO: Power cycle gNB_${gnb_id}.
    ${pdu}         Set Variable    ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].pdu_port.pdu}
    ${pdu_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[${0}].airscale.common_units[${0}].pdu_port.port_no}
    testline.PDU power reset    ${pdu}    ${pdu_port}    time_interval=${time_interval}


Check Node Cells Not Empty
    [Arguments]    ${node_id}=${0}  ${node_type}=gnb
    ${class_name}       Set Variable If     '${node_type}'=='gnb'   NRCEL   LNCEL
    ${oam_alias}        connect.Setup OAM HTTP Session  node_id=${node_id}  node_type=${node_type}
    ${list_cells}       testline.Get All Ids Of Class   alias=${oam_alias}  class=${class_name}
    ${num_of_cells}     Get Length  ${list_cells}
    IF      ${num_of_cells} < 1             FAIL    No ${class_name} configured!


Prepare And Check If Connectivity Between BTS And CMP Is Needed
    [Documentation]   Keyword checks if setting of ReferenceId and Pre-Shared-Key on BTS is needed on BTS.
    ...    This is assumed to be the case if substring 'ipsectest' contained in 'caSubjectName' of CMP managedObject of BTS.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]     ${node_type}=gnb   ${node_id}=${0}   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    ${tl_name}=     testline.Get Testline Name
    ${oam_connection_alias}=   Wait Until Keyword Succeeds    3 min   20 sec   connect.Setup OAM HTTP Session
    ...   node_type=${node_type}    node_id=${node_id}   admin_api_log_path=${admin_api_log_path}

    # case FSMF/FSMr3: set ${ref_psk_setting_needed} always to ${True} as parameter querry via admin-cli not supported
    ${ref_psk_setting_needed}=    Set Variable   ${True}
    IF  '${node_type}' == 'enb' and $tl.${node_type}s is not None
        IF  $tl.enbs[int($node_id)].system_module.common_units[0].hardware_type in ['FSMF']
            RETURN   ${oam_connection_alias}   ${ref_psk_setting_needed}
        END
    END

    # case Airscale eNB/gNB: querry scf parameters
    ${parameter_list}=     Create List   caSubjectName
    ${operation_status}=   admin.Get parameter by Class
    ...    connection=${oam_connection_alias}
    ...    class_name=CMP
    ...    parameter_list=${parameter_list}
    ...    detailed_output=${True}
    ${operation_status_dict2string}=   Convert To String    ${operation_status}
    ${ref_psk_setting_needed}=   Set Variable If   "ipsectest" in """${operation_status_dict2string}"""   ${True}   ${False}

    RETURN  ${oam_connection_alias}   ${ref_psk_setting_needed}


Apply Setting Of ReferenceId And Pre-Shared-Key On BTS For Connectivity To CMP
    [Documentation]   This keyword sets the given ReferenceId and Pre-Shared-Key credentials in the Automatic Certificate Management of BTS
    ...    and triggers the initialization of the certificate, i.e. the re-fetching from CMP in best-effort mode (ie. ignoring failures)
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]         ${oam_connection_alias}     ${reference_number}=37415      ${preshared_key}=XX3v-aVFH-Wyrq-r7Tn   ${detailed_output}=${True}

    Log To Console   Setting Automatic Certificate Management Configuration on BTS with RefID=${reference_number} and PreSharedKey=${preshared_key}
    ${operation_status}=   admin.Set Certificate Automatic Management
    ...    connection=${oam_connection_alias}
    ...    reference_number=${reference_number}
    ...    preshared_key=${preshared_key}
    ...    detailed_output=${detailed_output}

    Log To Console   Triggering Initilize Certificates procedure on BTS to re-fetch always latest available certificate from CPM
    ${cert_init_kw_status}   ${operation_status}=   Run Keyword And Warn On Failure   admin.CMP Initialize Certificate
    ...    connection=${oam_connection_alias}
    ...    detailed_output=${detailed_output}
    ...    timeout=180
    IF    '${cert_init_kw_status}' != 'PASS'
        Log   Execution of the 'Initilize Certificates' procedure on BTS has failed with this operation status:\n${operation_status}
    ...   WARN
    END

    RETURN  ${operation_status}


Handle Automatic Certificate Management Settings In BTS If Needed
    [Documentation]   This keyword checks if the setting of Automatic Certification Management configuration is needed on BTS
    ...   (as the case for IPsec-enabled BTS, f.ex.) and applies it if it is the case.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]     ${node_type}=gnb   ${node_id}=${0}   ${admin_api_log_path}=${OUTPUT DIR}/admin_logs
    ${oam_connection_alias}   ${ref_psk_setting_needed}=    Prepare And Check If Connectivity Between BTS And CMP Is Needed
    ...   node_type=${node_type}    node_id=${node_id}   admin_api_log_path=${admin_api_log_path}
    ${operation_status}=    IF    ${ref_psk_setting_needed}
    ...   Apply Setting Of ReferenceId And Pre-Shared-Key On BTS For Connectivity To CMP    ${oam_connection_alias}
    ...   ELSE    Log To Console    Skipping setting of Automatic Certificate Management configuration on BTS as not required (non-IPsec-enabled BTS)
    Run Keyword And Warn On Failure   admin.Teardown   connection=${oam_connection_alias}

    RETURN   ${operation_status}

Get Details For SSH Access Via LMP To BTS Node
    [Documentation]   This keyword returns the details for accessing the given BTS node via SSH and LMP port.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}     # noqa: W0919
    ${node_lmp_ip}=   Set Variable If   ${node_type == 'gnb'}
    ...    ${tl.gnbs[${node_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.addr}
    ...    ${tl.enbs[${node_id}].system_module.common_units[${0}].lmp_connection.addr}
    ${node_lmp_user}=    Set Variable If   ${node_type == 'gnb'}
    ...    ${tl.gnbs[${node_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.username}
    ...    ${tl.enbs[${node_id}].system_module.common_units[${0}].lmp_connection.username}
    ${node_lmp_pwd}=      Set Variable If   ${node_type == 'gnb'}
    ...    ${tl.gnbs[${node_id}].dus[${0}].airscale.common_units[${0}].lmp_connection.password}
    ...    ${tl.enbs[${node_id}].system_module.common_units[${0}].lmp_connection.password}
    RETURN   ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}

Copy Swconfig.txt To BTS Node
    [Documentation]   This keyword copies the TL-specifc swconfig.txt file from 'entitytest-tools' repo working copy to both SW partitions of the
    ...    specified BTS node and signs the swconfig.txt file afterwards. It will also do the same on the correponding SW partition of Secondary
    ...    System Module of the specified BTS node, in case it exists.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}   ${branch_version}=None
    ${initial_scf_filepath}=   Run Keyword   syve_testline.Get ${node_type.upper()} Initial Config Path   ${node_id}
    ...   branch_version=${branch_version}
    ${initial_scf_dir}=    string.Fetch From Left   ${initial_scf_filepath}   /scf.xml
    ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}=   Get Details For SSH Access Via LMP To BTS Node   node_type=${node_type}  node_id=${node_id}
    ${long_log_string}=   Catenate   SEPARATOR=${EMPTY}   ... copying swconfig.txt from '${initial_scf_dir}/swconfig.txt' \n
    ...   ${{' ' * 4}}to both partitions '/ffs/run' and '/ffs/stb' on BTS node ${node_type.upper()}-${node_id}
    Log To Console   ${long_log_string}   console=${P_console}
    # copying and signing swconfig.txt to active partition on primary SMOD -------------------------------------------------------------
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} scp ${initial_scf_dir}/swconfig.txt ${node_lmp_user}@${node_lmp_ip}:/ffs/run
    Should Be Equal     ${rc}   ${0}   Copying swconfig.txt to active partition of BTS failed with return code
    ...  '${rc}' and following stdout:\n${output}
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'crasign /ffs/run/swconfig.txt'
    Should Be Equal     ${rc}   ${0}   Signing of /ffs/run/swconfig.txt failed with RC '${rc}' and following stdout:\n${output}
    # copying and signing swconfig.txt to passive partition on primary SMOD -------------------------------------------------------------
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'mount -o remount,rw,async /ffs/stb'
    Should Be Equal     ${rc}   ${0}   Mounting /ffs/stb on BTS has failed with return code '${rc}' and following stdout:\n${output}
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} scp ${initial_scf_dir}/swconfig.txt ${node_lmp_user}@${node_lmp_ip}:/ffs/stb
    Should Be Equal     ${rc}   ${0}   Copying swconfig.txt to passive partition '/ffs/stb' of BTS failed with return code
    ...  '${rc}' and following stdout:\n${output}
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'crasign /ffs/stb/swconfig.txt'
    Should Be Equal     ${rc}   ${0}   Signing of /ffs/stb/swconfig.txt failed with RC '${rc}' and following stdout:\n${output}
    # checking existence of swconfig.txt files on primary SMOD -------------------------------------------------------------
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'ls -al /ffs/*/swconfig.txt*'
    Should Be Equal     ${rc}   ${0}
    ...   Checking the existence of swconfig.txt files on Primary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
    # checking for the existence of a secondary SMOD itself ----------------------------------------------------------------
    ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o StrictHostKeyChecking=no
    ...   -o UserKnownHostsFile=/dev/null -o ProxyCommand="sshpass -e ssh -W %h:%p ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a
    ...   ls -al /ffs/run <<< ${node_lmp_pwd}'
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
    # execute part below if secondary SMOD exists --------------------------------------------------------------------------
    IF  ${rc} == 0
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a "ls -al /ffs/run/swconfig.txt*" <<< ${node_lmp_pwd}'
        ${swconfig_file}=   Set Variable If   ${{os.path.exists('${initial_scf_dir}/swconfig_2nd.txt')}}   swconfig_2nd.txt   swconfig.txt
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Log To Console   Note: BTS node ${node_type.upper()}-${node_id} has a Secondary SMOD connected!
        ${long_log_string}=   Catenate   SEPARATOR=${EMPTY}   ... copying swconfig.txt from '${initial_scf_dir}/${swconfig_file}' \n
        ...   ${{' ' * 4}}to both partitions '/ffs/run' and '/ffs/stb' on Secondary SMOD of BTS node ${node_type.upper()}-${node_id}
        Log To Console   ${long_log_string}   console=${P_console}
        # copying and signing swconfig.txt to active partition on secondary SMOD -------------------------------------------------------------
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass scp -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${initial_scf_dir}/${swconfig_file} ${node_lmp_user}@fct-4a:/ffs/run/swconfig.txt <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...   Copying swconfig.txt to partition '/ffs/run' on Secondary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a "crasign /ffs/run/swconfig.txt" <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...  Signing of swconfig.txt in partition '/ffs/run' of Secondary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
        # copying and signing swconfig.txt to passive partition on secondary SMOD -------------------------------------------------------------
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a "mount -o remount,rw,async /ffs/stb" <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...   Mounting partition '/ffs/stb' on Secondary SMOD of BTS has failed with return code '${rc}' and following stdout:\n${output}
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass scp -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${initial_scf_dir}/${swconfig_file} ${node_lmp_user}@fct-4a:/ffs/stb/swconfig.txt <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...   Copying swconfig.txt to partition '/ffs/stb' on Secondary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a "crasign /ffs/stb/swconfig.txt" <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...  Signing of swconfig.txt in partition '/ffs/run' of Secondary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
        # checking existence of swconfig.txt files on secondary SMOD ---------------------------------------------------------------------------
        ${long_ssh_command}=   Catenate   /bin/bash -c 'env SSHPASS=${node_lmp_pwd} sshpass ssh -o ProxyCommand="sshpass -e ssh -W %h:%p
        ...   ${node_lmp_user}@${node_lmp_ip}" ${node_lmp_user}@fct-4a "ls -al /ffs/*/swconfig.txt*" <<< ${node_lmp_pwd}'
        ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_command}
        Should Be Equal     ${rc}   ${0}
        ...  Checking the existence of swconfig.txt files on Secondary SMOD of BTS failed with return code '${rc}' and following stdout:\n${output}
    END


Enable SSH Access On DNR Partition Via Fs3_swconfig.txt
    [Documentation]   This keyword enabled SSH access on DNR partition by putting swconfig.txt with needed R&D flags to /ffs/fs3 and signing it.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}

    ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}=   Get Details For SSH Access Via LMP To BTS Node   node_type=${node_type}  node_id=${node_id}

    ${long_log_string}=   Catenate   SEPARATOR=${EMPTY}   ... copying fs3_swconfig.txt from '${CURDIR}/fs3_swconfig.txt' \n
    ...   ${{' ' * 4}}to DnR (FDSW) partition '/ffs/fs3' on BTS node ${node_type.upper()}-${node_id}
    Log To Console   ${long_log_string}   console=${P_console}

    # mount DNR partition via systemctl script
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'systemctl start ffs-fs3.mount'
    Should Be Equal     ${rc}   ${0}   Mounting /ffs/fs3 on BTS has failed with return code '${rc}' and following stdout:\n${output}

    # copy fs3_swconfig.txt to BTS
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} scp ${CURDIR}/fs3_swconfig.txt ${node_lmp_user}@${node_lmp_ip}:/ffs/fs3
    Should Be Equal     ${rc}   ${0}   Copying fs3_swconfig.txt to BTS failed with return code '${rc}' and following stdout:\n${output}

    # sign fs3_swconfig.txt
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'crasign /ffs/fs3'
    Should Be Equal     ${rc}   ${0}   Signing of fs3_swconfig.txt on BTS failed with return code '${rc}' and following stdout:\n${output}

    # unmount DNR partition via systemctl script
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'systemctl stop ffs-fs3.mount'
    Should Be Equal     ${rc}   ${0}   Un-mounting /ffs/fs3 on BTS has failed with return code '${rc}' and following stdout:\n${output}

    # get boot_dnr_counter value
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'uboot_env get boot_dnr_counter'
    Should Be Equal     ${rc}   ${0}   Getting 'boot_dnr_counter' value has failed with return code '${rc}' and following stdout:\n${output}


Check From Which Partition BTS Has Booted
    [Documentation]   This keyword checks from which partition the currently running BTS Sw has booted and returns partition mounting point path.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}

    ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}=   Get Details For SSH Access Via LMP To BTS Node   node_type=${node_type}  node_id=${node_id}
    # check target path of symbolic link to mount point at path /ffs/run
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'readlink -f /ffs/run'
    Should Be Equal     ${rc}   ${0}   Checking running partition on BTS has failed with return code '${rc}' and following stdout:\n${output}
    ${current_partition}=   Should Match Regexp   ${output}   /ffs/fs[123]   Could not find active partition info in '${output}'
    Log To Console   \ \ BTS node ${node_type.upper()}-${node_id} is currently running on partition '${current_partition}'
    RETURN   ${current_partition}


Exit DnR Partition And Wait Until BTS Is Again Accessible Via SSH
    [Documentation]   This keyword triggers BTS to reboot into currenty active regular flash partition and waits until BTS is again reachable via SSH
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}   ${timeout}=10min

    ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}=   Get Details For SSH Access Via LMP To BTS Node   node_type=${node_type}  node_id=${node_id}

    # get uboot_env active_partition
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'uboot_env get active_partition'
    Should Be Equal   ${rc}   ${0}   Getting 'active_partition' uboot_env has failed with return code '${rc}' and following stdout:\n${output}
    ${_}  ${active_partition_id}=   Should Match Regexp   ${output}   active_partition=(\\d)
    ...   Could not find active partition info in '${output}'
    ${ddal_ffs_enum}=   Set Variable   DDAL_FFS_FS${active_partition_id}

    # exit from boot to DnR: reset boot dnr counter to zero / set via DDAL function ddal_boot_set_linux_active
    Log To Console   Setting active partition on next boot via DDAL to '${ddal_ffs_enum}'
    ${long_ssh_cmd}=   Catenate   SEPARATOR=${EMPTY}   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} \
    ...  'uboot_env set boot_dnr_counter=0; sleep 1; ddal -s ddal_boot_set_reset_loop_count 0'
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output   ${long_ssh_cmd}
    Should Be Equal     ${rc}   ${0}
    ...   Setting active partition on next boot via DDAL to '${ddal_ffs_enum}' has failed with return code '${rc}' and following stdout:\n${output}

    # trigger reboot via SSH
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'sync; sleep 1; systemctl reboot'
    Should Be Equal     ${rc}   ${0}   Triggering BTS reboot via SSH has failed with return code '${rc}' and following stdout:\n${output}

    Log To Console   BTS node ${node_type.upper()}-${node_id} has been rebooted via SSH to exit DnR partition ...
    Sleep   30sec   ... waiting time after reboot trigger before checking for SSH accessibility
    Log To Console   ... waiting up to ${timeout} until BTS is again reachable via SSH on LMP ...
    Wait Until Keyword Succeeds   ${timeout}   1min  Fail If BTS Is Not Reachable Via SSH On LMP   node_type=${node_type}  node_id=${node_id}
    Sleep   2min   ... waiting time after first ping reply before continuing with next step

Fail If BTS Is Not Reachable Via SSH On LMP
    [Documentation]   This keyword checks if BTS is again reachable via SSH at IP address of LMP. It passes if it is and fails if it isn't.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}=gnb   ${node_id}=${0}
    ${node_lmp_ip}   ${node_lmp_user}   ${node_lmp_pwd}=   Get Details For SSH Access Via LMP To BTS Node   node_type=${node_type}  node_id=${node_id}
    ${rc}   ${output}=   OperatingSystem.Run And Return Rc And Output
    ...   sshpass -p ${node_lmp_pwd} ssh ${node_lmp_user}@${node_lmp_ip} 'nc -vzw 2 ${node_lmp_ip} 22'
    Should Be Equal   ${rc}   ${0}   BTS node ${node_type.upper()}-${node_id} is currently not reachable via SSH port 22 on IP ${node_lmp_ip}!
