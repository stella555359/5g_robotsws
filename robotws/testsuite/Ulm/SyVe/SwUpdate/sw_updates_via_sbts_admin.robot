*** Settings ***
Documentation
...    This resource file implements automated SBTS SW updates, including SW upgrades or downgrades between different SW releases, on all
...    nodes (i.e. ENBs or GNBs) that belong to the testline under which the test is running. Execution is performed sequentially per node.
...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
...    | Team:        | MN RAN RD VRF ULM 3 (CSV ULM)                     |
...    | Team Email:  | <I_MN_RAN_RD_VRF_ULM_CSV@internal.nsn.com>        |

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# For admin library documentation, see: https://taf-sbts-oam-coam-admin.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
Library    String
Library    DateTime

Library    taf.sbts.oam.coam.admin                                     WITH NAME  admin
Library    taf.rfrl.common_resources.python.reset_bts_configuration    WITH NAME  reset_bts_conf
Library     ../resources/python_libs/tools.py                          WITH NAME  tools

Resource   ../../resources/Common/connect.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/snapshot.robot
Resource   ../CSV/resources/commonKeywords.robot
Resource   ../resources/installation.robot
Resource   resources/Software_upgrade-keywords.robot


Suite Setup   Perform SW Update Test Suite Setup
Suite Teardown   Collect Logs if Software Update Has Failed


*** Variables ***
${P_console}=                   ${True}   # output to console can be enabled via "Set Console Output" from testline.robot
${P_admin_console}=             ${False}
${admin_verbose}=               ${False}
${debug_mode_enabled}=          ${False}
${cfg_reset_verbose}=           ${True}
${force_config_reset}           False     # may be set to force SW_DOWNGRADE case when set to string ('True') or case SW_UPDATE when set to ('None')
${skip_same_sw_update}          True      # may be set to string ('True') to force that SW_UPDATE to already installed SW_VERSION is skipped
${timeout_reset}=               15min
${waittime_alarms}=             2min
${consolewidth}=                140
${barwidth}=                    130
${def_node_type}=               enb
${def_lmp_ip}=                  192.168.255.129
${TARGET_SW_VERSION}=           ${EMPTY}
${TARGET_SW_PACKAGE}=           ${TARGET_SW_VERSION}_release_BTSSM_downloadable_A54.zip
${TARGET_ORU_FW_VERSION}=       ${EMPTY}   # e.g. value '0203'
${TARGET_ORU_FW_PACKAGE}=       FJ-RU-ET1---------${TARGET_ORU_FW_VERSION}.FGF.zip     # e.g. value 'FJ-RU-ET1---------0203.FGF.zip'
${SW_UPDATE_NODES}              ${EMPTY}   # comma-separated filter list of nodes in format <node_type>-<node_id> to be updated
                                           # example:  GNB-0,GNB-1,ENB-0; Will autodetect and appy all nodes, if parameter is left empty.


*** Test Cases ***

Perform SW update via OAM Admin on all SBTS nodes of testline
    [Documentation]   This robot testcase performs a SW update on all SBTS nodes of the testline to the version specified in variable \
    ...    '\${TARGET_SW_VERSION}'.
    ...    The testcase currently supports testlines and TL configuration __init__.py files, that where each BTS node is provided by not more than 1
    ...    single SMOD (CommonUnit) system module. The BTS nodes of the teslline may of type: GNB (ClassicalBts) / ENB (RealEnb) / BTS2G (Bts2G).
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ...    | Team:        | MN RAN RD VRF ULM 3 (CSV ULM)                     |
    [Tags]            swupdate_via_sbts_admin

    ${long_err_string}=   builtin.Catenate   Cannot continue execution! \
    ...   Mandatory robot parameter '\${TARGET_SW_VERSION}' needs to be defined!
    builtin.Should Not Be Equal    ${TARGET_SW_VERSION}    ${EMPTY}    ${long_err_string}
    ${tl_name}=   testline.Get Testline Name
    builtin.Log Variables
    builtin.Log To Console   ${\n}
    builtin.Log To Console   \ This is Robot Testcase: '${TEST NAME}' running on '${tl_name}'\ \   format=*^${consolewidth}

    ${sw_update_nodes_list}=   Identify the SMODs and SBTS nodes on which the SW Update shall be performed

    FOR    ${node_name}    IN   @{sw_update_nodes_list}
        Perform robust SW Upgrade or Downgrade via OAM Admin on SBTS node
        ...   node_type=${node_name.split('-')[0].lower()}   node_id=${node_name.split('-')[1]}
    END



*** Keywords ***

Perform robust SW Upgrade or Downgrade via OAM Admin on SBTS node
    [Documentation]   This robot keyword performs a SW update on the given SBTS node of the testline to the version specified in variable \
    ...    '\${TARGET_SW_VERSION}'.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]     ${node_type}=${def_node_type}   ${node_id}=${0}    ${admin_log_dir}=${P_resultSuiteBaseDir}/admin_logs

    builtin.Log To Console   ${EMPTY}   format=-^${{int($consolewidth)-6}}
    ${long_log_string}=   builtin.Catenate   Performing SW Update on BTS node '${node_type.upper()}-${node_id}' of testline
    ...   '${P_TL_NAME}' to version '${TARGET_SW_VERSION}'
    builtin.Log To Console   ${long_log_string}   format=\ ^${{int($consolewidth)-6}}
    builtin.Log To Console   ${EMPTY}   format=-^${{int($consolewidth)-6}}

    ${sw_update_case_string}   ${initial_sw_version}=
    ...   Perform step 1/12: Preparation and SW Update case type detection   ${node_type}   ${node_id}   ${admin_log_dir}

    IF  'OFEGSA' in '${{','.join($PRIMARY_TL_NODES_DICT['${node_type.upper()}-${node_id}']['radio_types']) }}'
        IF  '${TARGET_ORU_FW_VERSION}' != '${EMPTY}'
        ...   Perform step 1a/12: Perform firmware update of OFEGSA O-RAN RMODs manufactured by FUJITSU
        ...           ${node_type}   ${node_id}   ${admin_log_dir}
        ...   ELSE    builtin.Log To Console
        ...           ${\n}\[${node_type.upper()}-${node_id}: step 1a/12] SKIPPED as firmware update of O-RAN RU of type OFEGSA is disabled! \
        ...           format=.<${barwidth}
    ELSE
        builtin.Log To Console
        ...   ${\n}\[${node_type.upper()}-${node_id}: step 1a/12] SKIPPED as this BTS node has no O-RAN RU of type OFEGSA! \  format=.<${barwidth}
    END

    IF   ${is_sw_downgrade_case == True} or ${{'${force_config_reset}' in ['true','True']}}
    ...   Perform step 2/12: Trigger configuration Reset on BTS   ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 2/12] SKIPPED as this is a '${sw_update_case_string}' case! \   format=.<${barwidth}

    IF   ${is_sw_downgrade_case == True} or ${{'${force_config_reset}' in ['true','True']}}
    ...   Perform step 3/12: Confirm that BTS is in state 'NotCommissioned'   ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 3/12] SKIPPED as this is a '${sw_update_case_string}' case! \   format=.<${barwidth}

    IF   'OFEGSA' in '${{','.join($PRIMARY_TL_NODES_DICT['${node_type.upper()}-${node_id}']['radio_types']) }}'
    ...   Perform step 4a/12: Perform setting of Netconf SSH credentials for interfacing with OFEGSA O-RAN RMODs manufactured by FUJITSU
    ...           ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 4a/12] SKIPPED as this BTS node has no O-RAN RU of type OFEGSA! \  format=.<${barwidth}

    Perform step 5/12: Wait until BTS is ready for SW Update   ${node_type}   ${node_id}   ${admin_log_dir}

    # Note: when attempting on DTAG config to do admin-based SW updated to already installed SW_VERSION, the SW installation hangs forever in 24R3
    ${is_same_sw_case}=   builtin.Set Variable If
    ...   '${{'_'.join($initial_sw_version.split('_')[1::])}}' == '${{'_'.join($TARGET_SW_VERSION.split('_')[1::])}}'   ${True}   ${False}
    IF   ${is_sw_downgrade_case == None} and ${is_same_sw_case} and ${{'${skip_same_sw_update}' in ['true','True']}}
    ...   builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 6/12] SKIPPED as '\${skip_same_sw_update}' is set to 'True'! \   format=.<${barwidth}
    ...   ELSE    Perform step 6/12: Trigger SW Update of SMOD of BTS via SBTS Admin   ${node_type}   ${node_id}   ${admin_log_dir}

    Perform step 7/12: Confirm BTS is in expected state prior to commissiong   ${node_type}   ${node_id}   ${admin_log_dir}
    Perform step 8/12: Perform Commissioning of Intial SCF to BTS   ${node_type}   ${node_id}   ${admin_log_dir}
    Perform step 9/12: Perform handling of Certificate Management settings, if needed   ${node_type}   ${node_id}   ${admin_log_dir}

    IF   ${{ len($PRIMARY_TL_NODES_DICT['${node_type.upper()}-${node_id}']['serial_numbers']) > 1 }}
    ...   Perform step 9a/12: Trigger SW Update of Secondary SMOD of BTS via SBTS Admin   ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 9a/12] SKIPPED as this BTS node has no Secondary SMOD! \  format=.<${barwidth}

    Perform step 9b/12: Copy swconfig.txt to passive partition of BTS   ${node_type}   ${node_id}   ${admin_log_dir}

    ${ru_sw_update_needed_at_step10}   ${proceduralState_at_step10}=
    ...   Perform step 10/12: Check if BTS reaches state 'onAir' and if SW Update already completed   ${node_type}   ${node_id}   ${admin_log_dir}

    IF   ${ru_sw_update_needed_at_step10} or ${is_sw_downgrade_case == True} or ${{'${force_config_reset}' in ['true','True']}}
    ...   Perform step 11/12: Trigger SW Update on RMOD(s) of BTS node via SBTS Admin   ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 11/12] SKIPPED as this is a '${sw_update_case_string}' case! \   format=.<${barwidth}

    ${ru_sw_update_needed_at_step12}   ${proceduralState_at_step12}=
    ...   IF      ${ru_sw_update_needed_at_step10} or ${is_sw_downgrade_case == True} or ${{'${force_config_reset}' in ['true','True']}}
    ...   Perform step 12/12: Confirm that BTS is in state 'onAir' and the SW Update completed   ${node_type}   ${node_id}   ${admin_log_dir}
    ...   ELSE    builtin.Log To Console
    ...           ${\n}\[${node_type.upper()}-${node_id}: step 12/12] SKIPPED as this is a '${sw_update_case_string}' case! \   format=.<${barwidth}

    ${is_success}=   builtin.Set Variable If
    ...   '${proceduralState_at_step10}' in ['onAir','OnAir'] and ${ru_sw_update_needed_at_step10 != True}    ${True}
    ...   '${proceduralState_at_step12}' in ['onAir','OnAir'] and ${ru_sw_update_needed_at_step12 != True}    ${True}
    ...   ${False}

    builtin.Log To Console    ${EMPTY}
    IF   ${is_success}
        builtin.Log To Console   ${EMPTY}   format=-^${{int($consolewidth)-6}}
        builtin.Log To Console
        ...   SUCCESS: BTS node ${node_type.upper()}-${node_id} of testline '${P_TL_NAME}' is 'onAir' and running SW version '${TARGET_SW_VERSION}' :)
        ...   format=\ ^${{int($consolewidth)-6}}
        builtin.Log To Console   ${EMPTY}   format=-^${{int($consolewidth)-6}}
        builtin.Log To Console   ${EMPTY}
    ELSE
        ${long_error_string}=   builtin.Catenate   The SW UPDATE of BTS node ${node_type.upper()}-${node_id} of testline '${P_TL_NAME}'
        ...   to SW version '${TARGET_SW_VERSION}' was NOT COMPLETED SUCCESSFULLY ! \n
        ...   Further error message details: \n
        ...   -> proceduralState_at_step10 = '${proceduralState_at_step10}'\n
        ...   -> proceduralState_at_step12 = '${proceduralState_at_step12}'
        builtin.Fail   ${long_error_string}
    END


Identify the SMODs and SBTS nodes on which the SW Update shall be performed
    [Documentation]   This preparation step for SW Update identifies the SMODs and SBTS nodes on which the SW Update shall be performed.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    ${all_tl_nodes_list}=   builtin.Create List
    ${sw_update_smod_list}=    builtin.Create List
    ${sw_update_nodes_list}=    builtin.Set Variable If    ${SW_UPDATE_NODES == ""}   ${{ [] }}   ${SW_UPDATE_NODES.split(',')}
    ${gnb_count}=  builtin.Set Variable If   ${tl.gnbs != None}   ${tl.gnbs.__len__()}   ${0}
    ${gnb_smod_serials}=   builtin.Create List
    ${enb_count}=  builtin.Set Variable If   ${tl.enbs != None}   ${tl.enbs.__len__()}   ${0}
    ${enb_smod_serials}=   builtin.Create List
    ${bts2g_count}=  IF   ${tl.bts2g_objects != None}    Get Length   ${tl.bts2g_objects}   ELSE   Set Variable   ${0}
    ${bts2g_smod_serials}=   builtin.Create List

    FOR    ${gnb_node}    IN RANGE    ${gnb_count}
        collections.Append To List   ${all_tl_nodes_list}   GNB-${gnb_node}
        collections.Append To List   ${gnb_smod_serials}   @{{ [ el.serial_number for el in $tl.gnbs[${gnb_node}].dus[0].airscale.common_units ] }}
        IF     'GNB-${gnb_node}' in ${PRIMARY_TL_NODES_LIST} and ${SW_UPDATE_NODES == ""}
        ...   collections.Append To List   ${sw_update_nodes_list}   GNB-${gnb_node}
        IF     'GNB-${gnb_node}' in ${PRIMARY_TL_NODES_LIST} and 'GNB-${gnb_node}' in ${sw_update_nodes_list}
        ...   collections.Append To List   ${sw_update_smod_list}
        ...   @{{ [ el.serial_number for el in $tl.gnbs[${gnb_node}].dus[0].airscale.common_units ] }}
    END
    FOR    ${enb_node}    IN RANGE    ${enb_count}
        collections.Append To List   ${all_tl_nodes_list}   ENB-${enb_node}
        collections.Append To List   ${enb_smod_serials}   @{{ [ el.serial_number for el in $tl.enbs[${enb_node}].system_module.common_units ] }}
        IF     'ENB-${enb_node}' in ${PRIMARY_TL_NODES_LIST} and ${SW_UPDATE_NODES == ""}
        ...  collections.Append To List   ${sw_update_nodes_list}   ENB-${enb_node}
        IF     'ENB-${enb_node}' in ${PRIMARY_TL_NODES_LIST} or 'ENB-${enb_node}' in ${sw_update_nodes_list}
       ...   collections.Append To List   ${sw_update_smod_list}
       ...   @{{ [ el.serial_number for el in $tl.enbs[${enb_node}].system_module.common_units ] }}
    END
    FOR    ${bts2g_node}    IN RANGE    ${bts2g_count}
        collections.Append To List   ${all_tl_nodes_list}   BTS2G-${bts2g_node}
        collections.Append To List   ${bts2g_smod_serials}
        ...   @{{ [ el.serial_number for el in $tl.bts2g_objects[${bts2g_node}].system_module.common_units ] }}
        IF     'BTS2G-${bts2g_node}' in ${PRIMARY_TL_NODES_LIST} and ${SW_UPDATE_NODES == ""}
        ...  collections.Append To List   ${sw_update_nodes_list}   BTS2G-${bts2g_node}
        IF     'BTS2G-${bts2g_node}' in ${PRIMARY_TL_NODES_LIST} or 'BTS2G-${bts2g_node}' in ${sw_update_nodes_list}
       ...   collections.Append To List   ${sw_update_smod_list}
       ...   @{{ [ el.serial_number for el in $tl.bts2g_objects[${bts2g_node}].system_module.common_units ] }}
    END

    ${all_smod_serials}=    collections.Combine Lists   ${enb_smod_serials}   ${gnb_smod_serials}   ${bts2g_smod_serials}
    ${all_unique_smod_serials}=   collections.Remove Duplicates   ${all_smod_serials}
    ${sw_update_smod_serials_unique}=   collections.Remove Duplicates   ${sw_update_smod_list}
    ${sw_update_nodes_string}=   builtin.Set Variable   ${{ ','.join($sw_update_nodes_list) }}
    ${primary_tl_nodes_list_string}=   builtin.Set Variable   ${{','.join($PRIMARY_TL_NODES_LIST)}}

    ${long_log_string}=   builtin.Catenate   Testline config file of TL '${P_TL_NAME}' specifies in total:${\n}
    ...  \ ${all_tl_nodes_list.__len__()} BTS node(s) with names ${all_tl_nodes_list} ** PROVIDED BY ** \
    ...  ${all_unique_smod_serials.__len__()} SMOD module(s) with serial number(s) ${all_unique_smod_serials}${\n}
    ...   \ \ +${{'-' * 17}}+${{'-' * 17}}+${{'-' * 19}}++${{'=' * 23}}++${{'=' * 40}}++${\n}
    ...   \ \ | GNB (5G):${{' '* 3}}${gnb_count}${{' '* 3}}| ENB (4G):${{' '* 3}}${enb_count}${{' '* 3}}|
    ...   BTS2G (2G):${{' '* 3}}${bts2g_count}${{' '* 3}}|| SYSTEM MODULES:${{' '* 3}}${all_unique_smod_serials.__len__()}${{' '* 3}}||
    ...   PRIMARY_TL_NODES: ${{$primary_tl_nodes_list_string.ljust(20, ' ')}} ||${\n}
    ...   \ \ +${{'-' * 17}}+${{'-' * 17}}+${{'-' * 19}}++${{'=' * 23}}++${{'=' * 40}}++${\n}

    builtin.Log To Console   ${long_log_string}
    ${long_err_string}=   builtin.Catenate   The number of given or detected SW_UPDATE_NODES (${sw_update_nodes_list.__len__()})
    ...   is greater than the number of unique SMODs of the tesline (${all_unique_smod_serials.__len__()}).${\n}
    ...   Aborting execution ! Please fix testline config file or parametrization of this testcase before retrying:${\n}
    ...     ${{' '* 2}}PRIMARY_TL_NODES_LIST = ${PRIMARY_TL_NODES_LIST}${\n}
    ...     ${{' '* 3}}sw_update_nodes_list = ${sw_update_nodes_list}${\n}
    ...     all_unique_smod_serials = ${all_unique_smod_serials}
    IF   ${{ ${sw_update_nodes_list.__len__()} > ${all_unique_smod_serials.__len__()} }}   Fail   ${long_err_string}
    ${long_log_string}=   builtin.Catenate   \ ${sw_update_smod_serials_unique.__len__()} of ${all_unique_smod_serials.__len__()} SMOD(s) of TL
    ...   '${P_TL_NAME}' will be updated to version '${TARGET_SW_VERSION}'${\n}\ \ \[ALL_SW_UPDATE_SMODS]: ${sw_update_smod_serials_unique}${\n}
    ...   \ \[ALL_SW_UPDATE_NODES]: ${sw_update_nodes_string}${\n}
    builtin.Log To Console   ${long_log_string}
    RETURN  ${sw_update_nodes_list}


Perform step 1/12: Preparation and SW Update case type detection
    [Documentation]  This SW Update step provides preparation steps for the SW Update Procedure on the given node and detects the SW Update case type.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 1/12] Getting current SW Version and current Alarms on BTS \
    ...   format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...    admin_api_log_path=${admin_log_dir}/01_SbtsAdminSetup
    ${current_sw_version}=   admin.Get SW Version    connection=${oam_alias}   timeout=10sec
    # NOTE: ${is_sw_downgrade_case} is set to "Test Variable" by software_upgrade-keywords.Check SW Downgrade
    ${is_sw_downgrade_case}=   software_upgrade-keywords.Check SW Downgrade
    ...  current_sw_load=${current_sw_version}  target_sw_load=${TARGET_SW_VERSION}
    ${sw_update_case_string}=   builtin.Set Variable If
    ...   ${is_sw_downgrade_case == True} or ${{'${force_config_reset}' in ['true','True']}}  SW_DOWNGRADE
    ...   ${is_sw_downgrade_case == None} or ${{'${force_config_reset}' in ['none','None']}}  SW_UPDATE
    ...   ${is_sw_downgrade_case == False}                                                    SW_UPGRADE
    ...   UPDATE_CASE_UNKNOWN
    builtin.Log To Console
    ...   \ \ [SW_UPDATE_PATH_${node_type.upper()}-${node_id}]: ${current_sw_version} --> ${TARGET_SW_VERSION} [${sw_update_case_string}]
    ${active_alarms}   ${faults_table_string}=   gnb.Get Current Alarms From Node    node_id=${node_id}   node_type=${node_type}
    ${ru_sw_update_needed}=  builtin.Set Variable If  "Incompatible SW version detected" in """${faults_table_string}"""   ${True}   ${False}
    ${long_log_string}=   builtin.Catenate  Fault ID 23 (Incompatible SW version detected) is active on SMOD of ${node_type.upper()}-${node_id}${\n}
    ...   \ \ -> SW version on RMOD(s) needs to be updated !
    IF    ${ru_sw_update_needed == True}   builtin.Log To Console   ${long_log_string}
    # [TODO]: check if "Run Keyword and Warn On Failure" below is really needed
    builtin.Run Keyword and Warn On Failure   admin.Teardown   connection=${oam_alias}   # already done inside gnb.Get Current Alarms From Node?
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 1/12] Done!
    RETURN   ${sw_update_case_string}   ${current_sw_version}


Perform step 1a/12: Perform firmware update of OFEGSA O-RAN RMODs manufactured by FUJITSU
    [Documentation]    This keyword updates firmware version of the O-RAN RMODs of type OFEGSA via SBTS admin to the given file
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${should_reset_radios}=${False}   ${rmod_upd_timeout}=10 min
    ...   ${path_to_oru_firmware}=/mnt/etfiles/images/RF_SW/OFEGSA   ${oru_firmware_file}=${TARGET_ORU_FW_PACKAGE}
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 1a/12] perform firmware update of O-RAN RMODs of type OFEGSA \
    ...    format=.<${barwidth}
    ${full_path_to_fw_package}=    builtin.Set Variable    ${path_to_oru_firmware}/${oru_firmware_file}
    builtin.Log To Console   ... updating firmware version of O-RAN Radio module type OFEGSA to '${TARGET_ORU_FW_VERSION}'
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/01a_OranRmodFwUpdate

    builtin.Log To Console   ... triggering O-RAN RMOD FW update procedure with timeout set to ${rmod_upd_timeout} and up to 6 re-tries ...
    ${fw_upd_returnval}=   Wait until keyword succeeds    6x   5 min   admin.Update Software    connection=${oam_alias}
    ...   sw_package=${full_path_to_fw_package}   should_activate=${True}   timeout=${rmod_upd_timeout}  override_ru_software=${True}
    ...   should_reset_radios=${should_reset_radios}   independent_sw_update_type=All
    builtin.Log To Console   The return status of O-RAN RMOD 'Firmware Update' admin function call is: '${fw_upd_returnval}'
    IF   'Software update has been completed' not in '${fw_upd_returnval}'   Fail
    ...   The O-RAN RMOD FW Update admin function call has exited with the unexpected return status: '${fw_upd_returnval}'

    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 1a/12] Done!


Perform step 2/12: Trigger configuration Reset on BTS
    [Documentation]   This SW Update step triggers a Configuration Reset on the given BTS node.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 2/12] Triggering configuration reset on BTS \   format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}   admin_api_log_path=${admin_log_dir}/02_ResetConf
    builtin.Log to Console   ... performing configuration reset on BTS node ${node_type.upper()}-${node_id} with timeout set to ${timeout_reset}
    ...   console=${P_console}
    ${timeout_reset_sec}=   datetime.Convert Time   ${timeout_reset}   result_format=number
    reset_bts_conf.Reset BTS Configuration   connection=${oam_alias}   wait_for_admin_connection_timeout=${timeout_reset_sec}
    ...   detailed_output=${cfg_reset_verbose}   reset_admin_connection=${True}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 2/12] Done!


Perform step 3/12: Confirm that BTS is in state 'NotCommissioned'
    [Documentation]   This SW Update step confirms that the given BTS node is in state 'NotCommissioned'.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${node_state_timeout}=5 min
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 3/12] Confirm that BTS is in state 'NotCommissioned' \
    ...    format=.<${barwidth}
    gnb.Wait for Node state    node_type=${node_type}   node_id=${node_id}   timeout=${node_state_timeout}   target_proceduralState=NotCommissioned
    ...   admin_api_log_path=${admin_log_dir}/03_ConfirmNodeStateIs_NotCommissioned
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/03_ConfirmNodeStateIs_NotCommissioned
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${long_log_message}=   builtin.Catenate   BTS node ${node_type.upper()}-${node_id} is in state 'NotCommissioned' has \
    ...  ${gnb_bts_info['radioModules']['rmod'].__len__()} RMODs commissioned correspondingly!
    #builtin.Log   ${gnb_bts_info['radioModules']['rmod']}   console=${True}   formatter=repr
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 3/12] Done!


Perform step 4a/12: Perform setting of Netconf SSH credentials for interfacing with OFEGSA O-RAN RMODs manufactured by FUJITSU
    [Documentation]    This keyword configures the NETCONF SSH account credentials needed for commucation with ORAN-RU of type OFEGSA.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${oran_user}=fjncuser0  ${oran_pwd}=ncCl2fjRu+autH0   ${timeout}=2 min
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 4a/12] Apply NETCONF RMOD Management Settings for O-RAN RMODs \
    ...    format=.<${barwidth}
    builtin.Log To Console   ... configuring the NETCONF SSH account credentials needed for commucation with ORAN-RU of type OFEGSA
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/04a_NetconfRmodManagement

    # KW "admin.Configure Netconf Radio Management" below works, but is deprecated. Using KW "admin.Configure Netconf Accounts" instead
    admin.Configure Netconf Accounts   connection=${oam_alias}   unsecure_ciphering=False   authentication_method=NoAuthentication  timeout=${timeout}
    ...   accounts=${{[{"id":"1", "defaultNetconfAccount": {"defaultNetconfAccountName":"${oran_user}", "defaultNetconfAccountPwd":"${oran_pwd}"}}]}}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 4a/12] Done!


Perform step 5/12: Wait until BTS is ready for SW Update
    [Documentation]   This SW Update step waits until the SMOD of the given BTS node reports to be ready for Software Update.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${readiness_timeout}=10 min
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 5/12] Wait until BTS is ready for SW Update \
    ...    format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...    admin_api_log_path=${admin_log_dir}/05_WaitForSwUpdateReady
    builtin.Log To Console    ... waiting up to ${readiness_timeout} until BTS node ${node_type.upper()}-${node_id} is ready for Software Update
    admin.Wait SW Update Possible   connection=${oam_alias}   bts_ready=${True}   readiness_timeout=${readiness_timeout}    # timeout=12min
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 5/12] Done!


Perform step 6/12: Trigger SW Update of SMOD of BTS via SBTS Admin
    [Documentation]   This SW Update step triggers the 'Software Update' admin function call on for updating SMOD software.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${smod_upd_timeout}=45 min   ${expected_sw_timeout}=45 min
    ...   ${post_upd_reconn_timeout}=15 min
    builtin.Log To Console
    ...   ${\n}\[${node_type.upper()}-${node_id}: step 6/12] Triggering SMOD SW Update on the BTS to SW Build '${TARGET_SW_VERSION}' \
    ...   format=.<${barwidth}
    installation.Verify Package Path
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/06_SmodSwUpdateProcedure
    ${full_path_to_sw_package}=    installation.Get SW Package Path    version=${TARGET_SW_VERSION}   package_regex=${TARGET_SW_PACKAGE}
    builtin.Log To Console   ... triggering SMOD SW update procedure with timeout set to ${smod_upd_timeout} and up to 3 re-tries ...
    # retry KW 'admin.Update Software' up to 3 times, waiting 5 min after each failed attempt, due to often failures with generic ErrorCode=17
    # (SW Update failed) - [TODO]: clarify with admin lib sw development the root cause of those generic error code 17 failures
    ${sw_upd_returnval}=   Wait until keyword succeeds    3x   5 min   admin.Update Software    connection=${oam_alias}
    ...   sw_package=${full_path_to_sw_package}   should_activate=${True}   timeout=${smod_upd_timeout}  override_ru_software=${True}
    ...   should_reset_radios=${True}   independent_sw_update_type=All
    builtin.Log To Console   The return status of SMOD 'Software Update' admin function call is: '${sw_upd_returnval}'
    IF   'Software update has been completed' not in '${sw_upd_returnval}'   Fail
    ...   The SMOD SW Update admin function call has exited with the unexpected return status: '${sw_upd_returnval}'
    # re-setup admin connection in case 'Software update has been completed' successfully as otherwise HTTP session may become invalid
    admin.Teardown   connection=${oam_alias}
    ${total_post_upd_timeout}=   datetime.Add Time to Time   ${expected_sw_timeout}   ${post_upd_reconn_timeout}   result_format=compact
    builtin.Log To Console    ... waiting up to ${expected_sw_timeout} for the full completion of SMOD SW Update procedure ...
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}   timeout=${post_upd_reconn_timeout}
    ...   admin_api_log_path=${admin_log_dir}/06_SmodSwUpdateProcedurePart2
    ${current_sw_version}=   Wait until keyword succeeds    ${expected_sw_timeout}   1 min   Fail if BTS node is not running the expected SW Version
    ...   node_id=${node_id}   node_type=${node_type}   oam_alias=${oam_alias}   expected_sw_version=${TARGET_SW_VERSION}
    ...   admin_log_dir=${admin_log_dir}
    ${long_log_string}=  builtin.Catenate   The SMOD "Software Update" admin function call on BTS node ${node_type.upper()}-${node_id} has been fully
    ...   completed${\n} and ${node_type.upper()}-${node_id} is now running the expected software version '${current_sw_version}'
    ${long_err_string}=  builtin.Catenate   The SMOD "Software Update" admin function call did not complete successfully !${\n}
    ...   BTS node ${node_type.upper()}-${node_id} is still not running the expected software version:
    ...   \ \ \ expected: '${TARGET_SW_VERSION}'${\n}\ \ \ \ \ actual: '${current_sw_version}'
    IF     '${{'_'.join($current_sw_version.split('_')[1::])}}' == '${{'_'.join($TARGET_SW_VERSION.split('_')[1::])}}'
    ...   builtin.Log To Console   ${long_log_string}   ELSE    Fail    ${long_err_string}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 6/12] Done!


Perform step 7/12: Confirm BTS is in expected state prior to commissiong
    [Documentation]   This SW Update step confirms that the given BTS node is in on of the accepted states to be prepared for the commissioning step.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${node_state_timeout}=5 min
    ${expected_state}=   builtin.Set Variable If
    ...   ${is_sw_downgrade_case == True}        NotCommissioned                                           # SW_DOWNGRADE
    ...   ${is_sw_downgrade_case == False}       NotCommissioned,Commissioned,IntegratedToRan,onAir,OnAir  # SW_UPGRADE
    ...   ${is_sw_downgrade_case == None}        NotCommissioned,Commissioned,IntegratedToRan,onAir,OnAir  # SW_UPDATE
    ...                                          NotCommissioned,Commissioned,IntegratedToRan,onAir,OnAir  # UPDATE_CASE_UNKNOWN
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 7/12] Confirm that BTS is in one of the expected states \
    ...   format=.<${barwidth}
    builtin.Log To Console   \ and BTS running with SW Version '${TARGET_SW_VERSION}'
    ${current_proceduralState}=   builtin.Run Keyword and Ignore Error   gnb.Wait for Node state    node_type=${node_type}   node_id=${node_id}
    ...   timeout=${node_state_timeout}   target_proceduralState=${expected_state}   admin_api_log_path=${admin_log_dir}/07_CheckSwUpdateComplete
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/07_CheckSwUpdateComplete
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${status_proceduralState}=    builtin.Set Variable   ${gnb_bts_info['status']['proceduralState']}
    ${long_error_string}=   builtin.Catenate   Unexpected 'proceduralState' after SMOD SW update
    ...     on ${node_type.upper()}-${node_id}:${\n}\ \ \ expected: '${expected_state}'${\n}\ \ \ \ \ actual: '${status_proceduralState}'
    builtin.Should Be True    '${status_proceduralState}' in '${expected_state}'   ${long_error_string}
    ${swInfo_swVersion}=    builtin.Set Variable   ${gnb_bts_info['swInfo']['swVersion']}
    ${long_error_string}=   builtin.Catenate   Unexpected SW Version after SMOD SW update
    ...     on ${node_type.upper()}-${node_id}:${\n}\ \ \ expected: '${TARGET_SW_VERSION}'${\n}\ \ \ \ \ actual: '${swInfo_swVersion}'
    # NOTE: Comparing below the sw build names after droppimg the first underscore-separated prefix for sw release, due to the trunk/SBST00 specialty.
    builtin.Should Be Equal As Strings   ${{'_'.join($swInfo_swVersion.split('_')[1::])}}   ${{'_'.join($TARGET_SW_VERSION.split('_')[1::])}}
    ...   ${long_error_string}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 7/12] Done!


Perform step 8/12: Perform Commissioning of Intial SCF to BTS
    [Documentation]   This SW Update step commissioning of the initial SCF file (as used and defined within VRF ULM) on the given BTS node.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 8/12] Commissioning initial SCF file to BTS \   format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/08_InitialScfCommissioning
    ${swInfo_swVersion}=   admin.Get SW Version   connection=${oam_alias}
    #${swInfo_swVersion}=    builtin.Set Variable   ${gnb_bts_info['swInfo']['swVersion']}
    ${current_sw_branch}=   builtin.Set Variable If   "_ENB_999" in "${swInfo_swVersion}" or "_FSM3_999" in "${swInfo_swVersion}"   SBTS00
    ...   ${{$swInfo_swVersion.split('_')[0]}}
    ${initial_scf_path}=   Run Keyword   syve_testline.Get ${node_type.upper()} initial config path   ${node_id}
    ...   branch_version=${current_sw_branch}
    builtin.Log to Console  ... performing validation of initial SCF file located at path:${\n}${{' '*5}}'${initial_scf_path}'  console=${P_console}
    ${scf_validation_result}=   builtin.Run Keyword And Warn On Failure    admin.Validate SCF Online    connection=${oam_alias}
    ...   scf_file=${initial_scf_path}   skip_parameter_relation_errors=${False}   timeout=60   detailed_output=${admin_verbose}
    builtin.Log to Console   ... performing commissioning of this initial SCF file on BTS node ${node_type.upper()}-${node_id}   console=${P_console}
    builtin.Wait until keyword succeeds   12x  5 min   admin.Perform Commissioning   connection=${oam_alias}   scf_file=${initial_scf_path}
    ...   skip_parameter_relation_errors=False   should_activate=${True}   timeout=6min
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 8/12] Done!


Perform step 9/12: Perform handling of Certificate Management settings, if needed
    [Documentation]   This SW Update step applies the settings needed for Automatic Certificate Management via CMP servier, which is needed for IPSEC.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}
    builtin.Log To Console
    ...   ${\n}\[${node_type.upper()}-${node_id}: step 9/12] Handling Automatic Certificate Management settings in BTS if needed \
    ...   format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/09_ConfigureAutoCertMgmt
    software_upgrade-keywords.Handle Automatic Certificate Management settings in BTS if needed   node_type=${node_type}   node_id=${node_id}
    ...   admin_api_log_path=${admin_log_dir}/09_ConfigureAutoCertMgmt
    # [TODO]: check if "Run Keyword and Ignore Error" below is really needed
    builtin.Run Keyword and Ignore Error   admin.Teardown   connection=${oam_alias}   # already done inside KW "Handle Automatic Certificate [...]"
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 9/12] Done!


Perform step 9a/12: Trigger SW Update of Secondary SMOD of BTS via SBTS Admin
    [Documentation]   This SW Update step triggers the 'Software Update' admin function call for updating software on Secondary SMOD of BTS node.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${smod_upd_timeout}=25 min   ${2nd_smod_updated_timeout}=25 min
    ...   ${2nd_smod_detect_timeout}=25min  ${post_upd_reconn_timeout}=15 min
    builtin.Log To Console
    ...   ${\n}\[${node_type.upper()}-${node_id}: step 9a/12] Triggering Secondary SMOD SW Update on the BTS to SW Build '${TARGET_SW_VERSION}' \
    ...   format=.<${barwidth}

    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/09a_SecondarySmodSwUpdateProcedurePart2
    ${initial_2nd_smod_detect_result}  ${gnb_bts_info}=   builtin.Run Keyword and Ignore Error
    ...   Fail if BTS node does not detect both SMODs, the Primary and the Secondary SMOD   node_type=${node_type}   node_id=${node_id}
    ...   oam_alias=${oam_alias}   console=${False}
    IF   '${initial_2nd_smod_detect_result}' == 'PASS'
        builtin.Log To Console
        ...   Both SMOD(s) of BTS node ${node_type.upper()}-${node_id} have been already detected - skipping Secondary SMOD 'Software Update'
    ELSE
        builtin.Log To Console   ... waiting up to ${2nd_smod_detect_timeout} until Secondary SMOD is detected with FaultID 23 (Incompatible SW) ...
        # inoring error in keyword call below to account for the case that Secondary SMOD runs already with compatible SW version
        ${detect_2nd_smod_kw_status}  ${detect_2nd_smod_kw_retval}=   builtin.Run Keyword and Ignore Error
        ...   Wait until keyword succeeds    ${2nd_smod_detect_timeout}   1 min
        ...   Fail if BTS node is not reporting Fault ID 23 'Incompatible SW version detected' from Secondary SMOD
        ...   node_type=${node_type}   node_id=${node_id}   console=${False}
        IF   '${detect_2nd_smod_kw_status}' == 'FAIL'   builtin.Log to Console
        ...   Secondary SMOD does not report FaultID 23 (Incompatible SW version detected) - seems to be running already a compatible SW version

        installation.Verify Package Path
        ${full_path_to_sw_package}=    installation.Get SW Package Path    version=${TARGET_SW_VERSION}   package_regex=${TARGET_SW_PACKAGE}
        builtin.Log To Console   ... triggering Secondary SMOD SW update procedure with timeout set to ${smod_upd_timeout} and up to 6 re-tries ...
        # retry KW 'admin.Update Software' up to 6 times, waiting 5 min after each failed attempt, due to often failures with generic ErrorCode=17
        # (SW Update failed) - [TODO]: clarify with admin lib sw development the root cause of those generic error code 17 failures
        ${sw_upd_returnval}=   Wait until keyword succeeds    6x   5 min   admin.Update Software    connection=${oam_alias}
        ...   sw_package=${full_path_to_sw_package}   should_activate=${True}   timeout=${smod_upd_timeout}  override_ru_software=${True}
        ...   should_reset_radios=${True}   independent_sw_update_type=All
        builtin.Log To Console   The return status of Secondary SMOD 'Software Update' admin function call is: '${sw_upd_returnval}'
        IF   'Software update has been completed' not in '${sw_upd_returnval}'   Fail
        ...   The Secondary SMOD SW Update admin function call has exited with the unexpected return status: '${sw_upd_returnval}'
        # re-setup admin connection in case 'Software update has been completed' successfully as otherwise HTTP session may become invalid
        admin.Teardown   connection=${oam_alias}

        ${total_post_upd_timeout}=   datetime.Add Time to Time   ${2nd_smod_updated_timeout}   ${post_upd_reconn_timeout}   result_format=compact
        builtin.Log To Console    ... waiting up to ${2nd_smod_updated_timeout} for the full completion of Secondary SMOD SW Update procedure ...

        ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}   timeout=${post_upd_reconn_timeout}
        ...   admin_api_log_path=${admin_log_dir}/09a_SecondarySmodSwUpdateProcedurePart3
        ${gnb_bts_info}=   Wait until keyword succeeds    ${2nd_smod_updated_timeout}   1 min
        ...   Fail if BTS node does not detect both SMODs, the Primary and the Secondary SMOD   node_type=${node_type}   node_id=${node_id}
        ...   oam_alias=${oam_alias}   console=${False}
    END
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 9a/12] Done!


Perform step 9b/12: Copy swconfig.txt to passive partition of BTS
    [Documentation]   This SW Update step copies the swconfig.txt file to the passive partition of the given BTS node.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 9b/12] Copy 'swconfig.txt' to STB partition and sign it \
    ...    format=.<${barwidth}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/09b_CopySwconfigFile
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${target_sw_release}=   builtin.Set Variable   ${TARGET_SW_VERSION.split('_')[0]}
    ${long_log_string}=   builtin.Catenate   SMOD of BTS node ${node_type.upper()}-${node_id} is of type
    ...   '${gnb_bts_info['systemModules'][${0}]['productName']}' ${\n}and has SW version '${gnb_bts_info['swInfo']['swVersion']}'
    ...   running on active partition, while the target SW release is '${target_sw_release}'
    builtin.Log To Console   ${long_log_string}
    software_upgrade-keywords.Copy swconfig.txt to BTS node    node_type=${node_type}   node_id=${node_id}   branch_version=${target_sw_release}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 9b/12] Done!


Perform step 10/12: Check if BTS reaches state 'onAir' and if SW Update already completed
    [Documentation]   This SW Update step check if the given BTS node reaches already 'onAir' state which would indicate that SW Update is completed.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${timeout_onAir}=10 min
    builtin.Log To Console
    ...   ${\n}\[${node_type.upper()}-${node_id}: step 10/12] Check if BTS reaches 'onAir' state and if SW Update is already completed \
    ...   format=.<${barwidth}
    builtin.Log To Console
    ...   ... waiting up to ${timeout_onAir} for node ${node_type.upper()}-${node_id} to be in state 'onAir' for all cells of all RATs
    builtin.Run Keyword and Ignore Error   gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   timeout=${timeout_onAir}   retry_interval=30s   node_id=${node_id}   node_type=${node_type}
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/10_ConfirmNodeStateIs_CommissionedOrOnAir
    # NOTE: retrieving one more time the current_proceduralState, in case the 'Wait for Node state' keyword has reached timeout and keyword has failed
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    # NOTE: The IF-block below is for printing information about currently running FW version of O-RAN RMODs of type OFEGSA, in case they exist
    IF  'OFEGSA' in '${{','.join($PRIMARY_TL_NODES_DICT['${node_type.upper()}-${node_id}']['radio_types']) }}'
        ${ofegsa_active_fw_versions}=   builtin.Evaluate
        ...   [ rmod['swInfo']['activeSwVersion'] for rmod in ${gnb_bts_info['radioModules']['rmod']} if rmod['productName'] in ['OFEGSA'] ]
        IF  ${{ len($ofegsa_active_fw_versions) > 0 }}
           builtin.Log To Console   ${EMPTY}
           builtin.Log To Console   ${EMPTY}   format=~^${{int($consolewidth)-6}}
           builtin.Log To Console
           ...  O-RAN: RMODs of type OFEGSA on BTS node ${node_type.upper()}-${node_id} are running firmware version '${ofegsa_active_fw_versions}[0]'
           ...  format=\ ^${{int($consolewidth)-6}}
           builtin.Log To Console   ${EMPTY}   format=~^${{int($consolewidth)-6}}
           builtin.Log To Console    ${EMPTY}
        END
    END
    ${current_proceduralState}=    builtin.Set Variable   ${gnb_bts_info['status']['proceduralState']}
    builtin.Log To Console  The reached procedural state of BTS node ${node_type.upper()}-${node_id} is: '${current_proceduralState}'
    ${active_alarms}   ${faults_table_string}=   gnb.Get Current Alarms From Node    node_id=${node_id}   node_type=${node_type}
    ${long_log_string1}=   builtin.Catenate   \ BTS node ${node_type.upper()}-${node_id} has been sucessfully updated
    ...   to SW version '${TARGET_SW_VERSION}'${\n}\ but remained in '${current_proceduralState}' state, not reaching 'onAir' state
    IF   '${current_proceduralState}' not in ['onAir','OnAir']    builtin.Log To Console   ${long_log_string1}
    ${ru_sw_update_needed}=  builtin.Set Variable If  "Incompatible SW version detected" in """${faults_table_string}"""   ${True}   ${False}
    ${long_log_string2}=   builtin.Catenate  Note that Fault ID 23 (Incompatible SW version detected) is active on SMOD of
    ...   ${node_type.upper()}-${node_id}${\n}\ \ -> SW version on RMOD(s) needs to be updated !
    IF   ${ru_sw_update_needed == True}   builtin.Log To Console   ${long_log_string2}
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 10/12] Done!
    RETURN   ${ru_sw_update_needed}   ${current_proceduralState}

Perform step 11/12: Trigger SW Update on RMOD(s) of BTS node via SBTS Admin
    [Documentation]   This SW Update step triggers the 'Software Update' admin function call on for updating RMOD software.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${readiness_timeout}=15 min   ${ru_upd_timeout}=30 min
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 11/12] Aligning the SW version of the RMODs with the SW version on SMOD \
    ...   format=.<${barwidth}
    installation.Verify Package Path
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/11_RmodSwUpdateProcedure
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${long_rmod_filter_expr}=   Catenate   dict(sorted([ (rmod['id']['configuration'], rmod['productName']) if 'productName' in rmod else
    ...   (rmod['id']['configuration'], rmod['productCode']) for rmod in ${gnb_bts_info['radioModules']['rmod']}], key=lambda tup: tup[1] ))
    ${rmod_dict}=    builtin.Evaluate   ${long_rmod_filter_expr}
    ${rmod_dict_pretty_str}=    builtin.Evaluate   pprint.pformat($rmod_dict)   modules=pprint
    ${long_log_message}=   builtin.Catenate   BTS node ${node_type.upper()}-${node_id} has now following
    ...  ${rmod_dict.__len__()} RMODs commissioned:
    builtin.Log To Console   ${long_log_message}${\n}${rmod_dict_pretty_str}
    builtin.Log To Console   ... waiting up to ${readiness_timeout} for BTS node to be ready for RMOD SW update ...
    admin.Wait SW Update Possible   connection=${oam_alias}   bts_ready=${True}  readiness_timeout=${readiness_timeout}  timeout=${readiness_timeout}
    ${full_path_to_sw_package}=    installation.Get SW Package Path    version=${TARGET_SW_VERSION}   package_regex=${TARGET_SW_PACKAGE}
    builtin.Log To Console   ... triggering RMOD SW update procedure with timeout set to ${ru_upd_timeout} ...
    ${sw_upd_returnval}=   Wait until keyword succeeds    6x   5 min     admin.Update Software    connection=${oam_alias}
    ...   sw_package=${full_path_to_sw_package}   should_activate=${True}   timeout=${ru_upd_timeout}   override_ru_software=${True}
    ...   should_reset_radios=${True}   independent_sw_update_type=All
    builtin.Log To Console   The return status of RMOD 'Software Update' admin function call is: '${sw_upd_returnval}'
    IF   'Software update has been completed' not in '${sw_upd_returnval}'   Fail
    ...   The RMOD SW Update admin function call has exited with the unexpected return status: '${sw_upd_returnval}'
    admin.Teardown   connection=${oam_alias}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 11/12] Done!


Perform step 12/12: Confirm that BTS is in state 'onAir' and the SW Update completed
    [Documentation]  This SW Update step following RMOD software update confirms that the given BTS node reaches 'onAir' state and SW Update is done.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]   ${node_type}   ${node_id}   ${admin_log_dir}   ${timeout_onAir}=15 min
    builtin.Log To Console   ${\n}\[${node_type.upper()}-${node_id}: step 12/12] Wait until BTS is in state 'onAir' \   format=.<${barwidth}
    builtin.Log To Console
    ...   ... waiting up to ${timeout_onAir} for node ${node_type.upper()}-${node_id} to be in state 'onAir' for all cells of all RATs
    ${check_onair_kw_status}  ${check_onair_kw_retval}=
    ...   builtin.Run Keyword and Ignore Error  gnb.Wait Until Node To Be Onair State For All Cells With Different Technologies
    ...   timeout=${timeout_onAir}   retry_interval=30s   node_id=${node_id}   node_type=${node_type}
    ${active_alarms}   ${faults_table_string}=   gnb.Get Current Alarms From Node    node_id=${node_id}   node_type=${node_type}
    ${ru_sw_update_needed}=  builtin.Set Variable If  "Incompatible SW version detected" in """${faults_table_string}"""   ${True}   ${False}
    IF   ${ru_sw_update_needed == True}   Fail
    ...  FaultId 23 ('Incompatible SW version detected') is still active on ${node_type.upper()}-${node_id} after SW update procedure completion
    ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ...   admin_api_log_path=${admin_log_dir}/12_ConfirmNodeStateIs_OnAir
    ${current_sw_version}=   admin.Get SW Version    connection=${oam_alias}   timeout=10sec
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${final_proceduralState}=    builtin.Set Variable   ${gnb_bts_info['status']['proceduralState']}
    ${long_wrn_message}=   builtin.Catenate   SMOD and RMODs of BTS node ${node_type.upper()}-${node_id} have been sucessfully
    ...   updated to SW version '${current_sw_version}'${\n} but BTS remained in '${final_proceduralState}' state, not reaching 'onAir' state !
    ${long_err_string}=   builtin.Catenate   BTS node ${node_type.upper()}-${node_id} has an unexpeced SW version at the end of the SW update
    ...   procedure:${\n}\ \ \ expected: '${TARGET_SW_VERSION}'${\n}\ \ \ \ \ actual: '${current_sw_version}'${\n}
    # NOTE: Comparing below the sw build names after droppimg the first underscore-separated prefix for sw release, due to the trunk/SBST00 specialty.
    builtin.Should Be Equal As Strings   ${{'_'.join($current_sw_version.split('_')[1::])}}   ${{'_'.join($TARGET_SW_VERSION.split('_')[1::])}}
    ...   ${long_err_string}
    ${long_log_message}=   builtin.Catenate   SW update for BTS node ${node_type.upper()}-${node_id} successfully completed!
    IF   '${final_proceduralState}' not in ['onAir','OnAir'] or '${check_onair_kw_status}' != 'PASS'
    ...   builtin.Run Keyword And Warn On Failure   Fail   ${long_wrn_message}
    ...   ELSE   builtin.Log To Console   ${long_log_message}
    builtin.Log To Console   [${node_type.upper()}-${node_id}: step 12/12] Done!
    RETURN   ${ru_sw_update_needed}   ${final_proceduralState}


Make sure that primary BTS of TL is not running on DnR partition
    [Documentation]  This preparation step for SW Update makes sure that the primary BTS node of the testline is not running on SW from DnR partition.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    builtin.Log To Console   Making sure the primary BTS node of the testline is currently NOT running on DnR partition ... \  newline=${False}
    ${primary_node_type}=   BuiltIn.Set variable If    ${{$tl.gnbs is not None}}   gnb   enb
    ${current_partition}=   software_upgrade-keywords.Check from which partition BTS has booted   node_type=${primary_node_type}   node_id=${0}

    # [TODO] function reset_bts_conf._fdsw_software_rollback is not exposed to RF as keyword, needs to be be made accessible or re-implemented
    IF   '${current_partition}' in '/ffs/fs3'
        Fail  BTS is currently running from FDSW partition (rescue console)! Exiting DnR partition by performing rollback is not yet implemented! ...
        Skip
        #reset_bts_conf._fdsw_software_rollback     fdsw_log_dir_path=admin_logs/00_FdswRollback
    END
    builtin.Log To Console   Done!


Fail if BTS node is not running the expected SW Version
    [Documentation]    This SW Update helper keyword gets the currently running SW version from the given BTS node and fails if it does not corrspond
    ...  to the provided expected software version. While comparing the SW builds, the prefix of the SW build name until the frist underscore,
    ...  holding the SW stream info, will be ommitted in case of trunk builds, due to the SW build naming differences between target and package name.
    ...  Keyword returns the current SW of the BTS node, when passing. Note that keyword expects the needed admin connection to be handled externally.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_id}   ${node_type}  ${oam_alias}   ${expected_sw_version}   ${admin_log_dir}

    ${admin_kw_status}  ${current_sw_version}=   builtin.Run Keyword and Ignore Error   admin.Get SW Version   connection=${oam_alias}   timeout=10sec
    IF  '${admin_kw_status}' == 'FAIL'
        # re-setup admin connection as assuming that HTTP session has become invalid
        admin.Teardown   connection=${oam_alias}
        ${oam_alias}=   connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
        ...   admin_api_log_path=${admin_log_dir}/06_SmodSwUpdateProcedurePart2
        ${current_sw_version}=   admin.Get SW Version   connection=${oam_alias}   timeout=10sec
    END
    IF    "_ENB_999" in "${expected_sw_version}" or "_FSM3_999" in "${expected_sw_version}"
    ...  builtin.Should Be Equal As Strings   ${{'_'.join($current_sw_version.split('_')[1::])}}   ${{'_'.join($expected_sw_version.split('_')[1::])}}
    ...  ELSE   builtin.Should Be Equal As Strings   ${current_sw_version}   ${expected_sw_version}
    RETURN    ${current_sw_version}


Fail if BTS node is not reporting Fault ID 23 'Incompatible SW version detected' from Secondary SMOD
    [Documentation]    This keyword gets the active alarms from the master SMOD and fails in case the list of alarms does not contain an entry of
    ...    Fault ID 23 (Incompatible SW version detected) that is coming from Secondary SMOD as reporting unit.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}   ${node_id}   ${console}=${False}
    # function below gets admin connection of node by itself or sets it up, if needed
    ${active_alarms}   ${faults_table_string}=   gnb.Get Current Alarms From Node    node_id=${node_id}   node_type=${node_type}   console=${console}
    ${list_of_fault_23_from_2nd_smod}=   builtin.Set Variable
    ...   ${{ [el for el in $active_alarms if el['faultId']==23 and 'SMOD-2' in el['configObjectName']] }}
    IF   ${{ len($list_of_fault_23_from_2nd_smod) == 0 }}
       builtin.Fail  BTS node ${node_type.upper()}-${node_id} is not (yet) reporting FaultID 23 'Incompatible SW version detected' from Secondary SMOD
    ELSE
       builtin.Log to Console   BTS node ${node_type.upper()}-${node_id} reports FaultID 23 'Incompatible SW version detected' from Secondary SMOD
    END
    RETURN   ${active_alarms}


Fail if BTS node does not detect both SMODs, the Primary and the Secondary SMOD
    [Documentation]    This keyword gets the BTS Info dictionary from the master SMOD and fails in case the 'systemModules' field entry does not
    ...    consist of a list that more than one element.
    ...    | Author:      | Masiar Makkinejad <masiar.makkinejad@nokia.com>   |
    [Arguments]    ${node_type}   ${node_id}   ${oam_alias}   ${console}=${False}
    # function below expects that admin connection has been setup already
    ${gnb_bts_info}=   admin.Get Bts Info   connection=${oam_alias}
    ${list_of_smod}=   builtin.Set Variable   ${gnb_bts_info['systemModules']}
    ${list_of_smod_roles}=   builtin.Set Variable   ${{ [ el['activeRole'] for el in $gnb_bts_info['systemModules']] }}
    ${list_of_smod_operationalState}=   builtin.Set Variable   ${{ [ el['status']['operationalState'] for el in $gnb_bts_info['systemModules']] }}
    ${list_of_bbmod_operationalState}=   builtin.Set Variable   ${{ [ el['status']['operationalState'] for el in $gnb_bts_info['basebandModules']] }}
    IF    ${console}   builtin.Log To Console   List roles of the detected SMOD(s): ${list_of_smod_roles}
    IF   ${{ len($list_of_smod) < 2 }} or ${{ 'disabled' in $list_of_smod_operationalState }} or ${{ 'disabled' in $list_of_bbmod_operationalState }}
       builtin.Fail  BTS node ${node_type.upper()}-${node_id} has not (yet) detected the Secondary SMOD and BBMOD(s)
    ELSE
       builtin.Log to Console
       ...   BTS node ${node_type.upper()}-${node_id} has all BBMODs and both SMODs detected and working in roles: ${list_of_smod_roles}
    END
    RETURN   ${gnb_bts_info}


Perform SW Update Test Suite Setup
    builtin.Log To Console   Running Test Suite Setup keyword 'Perform SW Update Test Suite Setup' ...
    Make sure that primary BTS of TL is not running on DnR partition
    testline.Create Test Suite Result Base Directory
    commonKeywords.Identify the list of unique SMODs and associated primary SBTS nodes of the testline   log_to_console=${True}
    IF   ${debug_mode_enabled}
       builtin.Log Variables
       #${tl_pretty_string}=   builtin.Evaluate    pprint.pformat($tl, indent=4, width=${consolewidth}, depth=10)    modules=pprint
       builtin.Log To Console
       ...  ${{'>'*int($consolewidth)}}${\n}\[DEBUG INFO\] The '\$tl' and '\$PRIMARY_TL_NODES_DICT' variables have following attributes:${\n}
       tools.Pretty Print Object    ${tl}
       builtin.Log To Console   ${{'~'*int($consolewidth)}}
       ${PRIMARY_TL_NODES_DICT_pretty_string}=   builtin.Evaluate
       ...   pprint.pformat($PRIMARY_TL_NODES_DICT, indent=4, width=${consolewidth}, depth=10)    modules=pprint
       builtin.Log To Console   \$PRIMARY_TL_NODES_DICT = ${\n}${PRIMARY_TL_NODES_DICT_pretty_string}
       builtin.Log To Console   ${{'<'*int($consolewidth)}}${\n}
    END
    builtin.Log To Console   Running Test Suite Setup keyword 'Perform SW Update Test Suite Setup' completed!${\n}


Collect Logs if Software Update Has Failed
    [Documentation]    This keyword is intended to be used as Suite or Testcase Teardown keyword and will trigger the collection of logs from all
    ...   primary testline nodes, in case the preceeding SW installation testcase has failed.
    #IF   '${SUITE STATUS}' != 'PASS'
    IF   ${False}
        builtin.Log To Console   Collecting logs from all primary TL nodes, as the sw installation has failed ...
        ${target_dir}=    testline.Get test suite result base directory
        Log To Console    \ storing log files at path:${\n}\ \ '${target_dir}'
        FOR   ${tl_node}   IN   @{PRIMARY_TL_NODES_LIST}
            ${node_type}=   builtin.Set Variable    ${{ $tl_node.split('-')[0].lower() }}
            ${node_id}=   builtin.Set Variable    ${{ int($tl_node.split('-')[1]) }}
            builtin.Run Keyword And Warn On Failure   snapshot.Get snapshot for node
            ...   node_id=${node_id}   node_type=${node_type}   target_dir=${target_dir}
        END
        admin.Teardown All Aliases For Admin
    END
    builtin.Log To Console   Log collection done!
