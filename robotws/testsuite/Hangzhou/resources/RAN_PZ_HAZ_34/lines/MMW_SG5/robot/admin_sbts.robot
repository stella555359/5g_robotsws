# @Time    : 2022/3/14 15:09
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : admin_sbts.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common admin sbts keywords
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Verify BTS Status Is "${status}"
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Connect to gnb coam via ssl
    ${bts_status}    coam.get_bts_statuses    connection=GNB_OAM
    Should Be Equal As Strings    ${bts_status['proceduralState']}    ${status}

Get BTS Active Alarms ID List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${alarm_list}    Create List
    ${alarms}    coam.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{alarms}
        Append To List    ${alarm_list}    ${alarm['faultId']}
    END
    Sort List    ${alarm_list}
    [Return]    ${alarm_list}

Verify The Target Alarm ID State In ENB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${alarm_id}    ${if_exist}=true    ${enb_index}=0    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    connection=${connection}
    ${alarm_list}    Create List
    ${alarms}    coam.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{alarms}
        Append To List    ${alarm_list}    ${alarm['faultId']}
    END
    Sort List    ${alarm_list}
    Run Keyword If    '${if_exist}'=='true'    List Should Contain Value    ${alarm_list}    ${alarm_id}
    ...    ELSE    List Should Not Contain Value    ${alarm_list}    ${alarm_id}
    [Return]    ${alarm_list}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Get BTS Cells DistName List Via ActiveRole
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${active_role}    ${cell_type}=nr    ${connection}=GNB_OAM
    ${bts_info}    coam.get_bts_info    connection=${connection}
    FOR    ${system_module}    IN    @{bts_info['systemModules']}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings    ${system_module['activeRole']}    ${active_role}
        ${rest}    ${smod_r_id}    Split String From Right    ${system_module['id']['internal']}    -    1
        Run Keyword If    ${passed}    Set Test Variable    ${PRIMARY_SMOD_R_ID}    ${smod_r_id}
    END
    @{rmod_ids}    Create List
    FOR    ${cables}    IN    @{bts_info['cables']}
        ${passed}    Run Keyword And Return Status    Should Contain    ${cables['firstEndPointId']['internal']}
        ...    BBMOD_R-${PRIMARY_SMOD_R_ID}
        ${rest}    ${rmod_r_id}    ${last}    Split String From Right    ${cables['secondEndPointId']['internal']}
        ...    /    2
        ${passed}    Run Keyword If    ${passed}    Run Keyword And Return Status    List Should Not Contain Value
        ...    ${rmod_ids}    ${rmod_r_id}
        Run Keyword If    ${passed}    Append To List    ${rmod_ids}    ${rmod_r_id}
    END
    @{cells_distname}    Create List
    FOR    ${cell}    IN    @{bts_info['cells']['${cell_type}']}
        ${rest}    ${rmod_r_id}    ${last}    Split String From Right    ${cell['carrierList'][0]['antennaLineId']['internal']}
        ...    /    2
        ${passed}    Run Keyword And Return Status    List Should Contain Value    ${rmod_ids}    ${rmod_r_id}
        Run Keyword If    ${passed}    Append To List    ${cells_distname}    ${cell['id']['configuration']}
    END
    [Return]    ${cells_distname}

Modify Parameter On BTS With Activate
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=true    connection=${connection}

Modify Parameters in the Same Object With Activate
    [Documentation]    Author: chun.li@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter}    ${connection}=GNB_OAM
    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    operation=update
    ...    skip_parameter_relation_errors=true    connection=${connection}

Modify Parameter On ENB With Activate
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    ...    ${bts_host}=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=ENB_OAM
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    value=${value}    operation=update
    ...    skip_parameter_relation_errors=true    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify BTS X2LinkStatus Is "${available or unavailable}"
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    @{lteenb_r_list}    coam.Get managed objects    class_name=LTEENB_R    connection=GNB_OAM
    &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${lteenb_r_list[0]['distName']}
    ...    pattern=x2LinkStatus    connection=GNB_OAM
    ${x2LinkStatus}    Get From Dictionary    ${dict_x2_link_status}    x2LinkStatus
    Should Be Equal As Strings    ${x2LinkStatus}    ${available or unavailable}

Get NR Cell Identity Via Index "${index}"
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${nrcell_r_list}    coam.Get managed objects    class_name=NRCELL_R    connection=GNB_OAM    timeout=${900}
    FOR    ${nrcell}    IN    @{nrcell_r_list}
        ${rest}    ${cell_index}    Split String From Right    ${nrcell['distName']}    -    1
        ${nr_cell_identity}    Set Variable    ${nrcell['parameters']['nrCellIdentity']}
        Exit For Loop If    ${index}==${cell_index}
    END
    [Return]    ${nr_cell_identity}

Enable BTS NR Cell Via ENB Cell LnRelGnbCellId
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${nr_cell_id}    ${lncel_id}=1    ${enb_index}=0    ${lnrelgnbcell_max_number}=256
    ...    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    connection=${connection}
    ${scf_file}    COAM Download scf from cluster    connection=${connection}
    scf.Load Scf    file_path=${scf_file}
    FOR    ${num}    IN RANGE    ${lnrelgnbcell_max_number}
        ${pass}    ${cell_id}    Run Keyword And Ignore Error    scf.Get Value From Scf
        ...    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-${lncel_id}/LNRELGNBCELL-${num}
        ...    p_name=nrCellId
        ${lnrel_gnb_cell_id}    Set Variable    ${num}
        Run Keyword If    '${pass}'=='PASS'    Exit For Loop If    ${cell_id}==${nr_cell_id}
    END
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-${lncel_id}
    ...    parameter=defaultLnRelGnbCellId    value=${lnrel_gnb_cell_id}    operation=update    connection=${connection}
    Run    rm -f ${scf_file}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Enable BTS Single NR Cell For SA Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${nr_cell_id}
    ${cell_list}    Get All Cell Id
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword If    '${cell}'=='${nr_cell_id}'    Modify Parameter On BTS With Activate
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}    parameter=administrativeState    value=Unlocked
        ...    ELSE    Modify Parameter On BTS With Activate
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell}    parameter=administrativeState    value=Locked
    END

Verify BTS Alarm Exist
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    fault_id : 50    fault_name: BTS blocked
    [Arguments]    ${fault_id}    ${fault_name}    ${fault_info}=None    ${alarm_object_id}=None    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    @{alarm_list}    coam.get_active_alarms    connection=${connection}
    Should Contain    '${alarm_list}'    'faultId': ${fault_id}
    Should Contain    '${alarm_list}'    'faultName': '${fault_name}'
    Run Keyword If    '${fault_info}'!='None'    Should Contain    '${alarm_list}'    'supplAlarmInfo': '${fault_info}'
    # update on 2025/09/02 check alarm object
    @{alarm_object_ids}    Create List
    FOR    ${alarm}    IN    @{alarm_list}
        Continue For Loop If    '${alarm['faultId']}'!='${fault_id}'
        FOR    ${alarmingObjectId}    IN    @{alarm["alarmingObjectIds"]}
            Append To List    ${alarm_object_ids}    ${alarmingObjectId["configuration"]}
        END
    END
    Run Keyword If    '${alarm_object_id}'!='None'
    ...    List Should Contain Value    ${alarm_object_ids}    ${alarm_object_id}

Verify BTS Alarm Configuration Alarming Objects
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/08 15:28
    ...    fault_id : 10    fault_name: No connection to unit
    ...    objects: [[MRBTS-2026] MRBTS-2026/EQM-1/APEQM-1/RMOD-2, [MRBTS-2026] MRBTS-2026/EQM-1/APEQM-1/RMOD-3]
    [Arguments]    ${fault_id}    ${fault_name}    ${objects}=None    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    @{alarm_list}    coam.get_active_alarms    connection=${connection}
    @{configObjectName}    Create List
    FOR    ${alarm}    IN    @{alarm_list}
        Run Keyword If    '${alarm["faultId"]}'=='${fault_id}' and '${alarm["faultName"]}'=='${fault_name}'
        ...    Append To List    ${configObjectName}    ${alarm["configObjectName"]}
    END
    Sort List    ${configObjectName}
    Lists Should Be Equal    ${configObjectName}    ${objects}

Verify BTS Alarm Not Exist
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    fault_id : 50    fault_name: BTS blocked
    [Arguments]    ${fault_id}    ${fault_name}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    @{alarm_list}    coam.get_active_alarms    connection=${connection}
    Should Not Contain    '${alarm_list}'    'faultId': ${fault_id}
    Should Not Contain    '${alarm_list}'    'faultName': '${fault_name}'

Modify Parameter On Webem And PDL Verification Passed
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    dist_name = MRBTS-2003/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter = eCpriMasterStatisticsInterval
    ...    value = 15min
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result}    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${value}    skip_parameter_relation_errors=True
    ...    should_activate=False    connection=${connection}
    Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    [Return]    ${result}

Modify Parameter On Webem And PDL Verification Failed
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    dist_name = MRBTS-2003/MNL-1/MNLENT-1/PMMNL-1
    ...    parameter = eCpriMasterStatisticsInterval
    ...    value = 15min
    [Arguments]    ${dist_name}    ${parameter}    ${value}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result}    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=update    value=${value}    skip_parameter_relation_errors=True
    ...    should_activate=False    connection=${connection}
    Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}    FAIL
    [Return]    ${result}

Convert BTS Mode To NSA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Lock AMF to disable SA call
    Connect to gnb coam via ssl
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    ...    parameter=administrativeState    value=Locked

Convert BTS Mode To SA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Unlock AMF to enable SA call
    Connect to gnb coam via ssl
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/SERVEDAMF-1
    ...    parameter=administrativeState    value=Unlocked

Lock BTS All 5G Cells
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        coam.lock    dist_name=${cell_info['id']['configuration']}    connection=${connection}
        ...    timeout=60
    END

Unlock BTS All 5G Cells
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        coam.unlock    dist_name=${cell_info['id']['configuration']}    connection=${connection}
        ...    timeout=60
    END

_Reset And Check Success BaseBand Coam
    [Documentation]   Author: xudong.1.li@nokia-sbell.com
    ...               Description:Reset BaseBand and check if success
    ...               ${baseband_index}:value from MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-.....
    [Arguments]  ${MRBTS_ID}    ${timeout}=600    ${baseband_index}=1   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${output}    coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${baseband_index}
    ...    force_radio_reset=${True}    reset_type=Warm    timeout=${timeout}    connection=${connection}
    ${result}    set variable    ${output[1]['resultNode']['parameters']['status']}
    Should Be Equal As Strings  ${result}    Succeeded
    LOG TO CONSOLE    ${\n}======BaseBand Reset Succeeded.
    [Return]  ${result}

Get Current SITE SoftWare Version
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${result}    coam.get_sw_version    connection=${connection}
    [Return]  ${result}

_Update SW SBTS
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...                Description: upgrade SBTS SW
    ...                ${sw_path}: the path where sw is. eg:
    ...                /home/ute/MMW_SG5/SW/SBTS23R1_ENB_0000_000758_000000_release_BTSSM_downloadable_A54.zip
    [Arguments]  ${sw_path}    ${timeout}=600    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    log to console  ${\n}======start to upgrade sw
    ${result}    coam.update_software    sw_package=${sw_path}    timeout=${timeout}    connection=${connection}
    [Return]  ${result}

_Rollback SW SBTS
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...                Description: rollback SBTS SW
    [Arguments]  ${timeout}=600    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    log to console  ${\n}======start to Rollback sw
    ${result}    coam.rollback_software    timeout=${timeout}    connection=${connection}
    [Return]  ${result}

_DownLoad Target SW to UTE
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...    Description: Download target sw to UTE
    ...    package_link=https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
    ...    target_version
    ...    local_path=/home/ute/Downloads
    [Arguments]        ${package_link}    ${target_version}    ${local_path}=/home/ute/Downloads
    csn.Connect to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=VMute

    set suite variable    ${upgrade_package_path}    ${local_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     Fetch SW Package From Server    package_link=${package_link}
    ...    target_version=${target_version}    local_path=${local_path}
#    @{result}    string.split string    string=${target_version}    separator=_
#    ${sw_head}     convert to string    ${result[0]}
#    ${sw_full_link}    Set Variable
#    ...    ${package_link}${sw_head}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
#    ${passed}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_path}
#    Run Keyword If    ${passed}     OperatingSystem.Empty Directory    ${local_path}
#    ...    ELSE    OperatingSystem.Create Directory   ${local_path}
#    Run And Return Rc And Output    wget --no-proxy ${sw_full_link} -P ${local_path}
#    ${sw_package_path}    OperatingSystem.List Directory    ${local_path}    absolute=${TRUE}
#    OperatingSystem.File Should Exist    ${sw_package_path[0]}
#    [Return]     ${sw_package_path[0]}
    [Return]    ${upgrade_package_path}
    [Teardown]    Run Keyword And Ignore Error   csn.disconnect    connection=VMute

Fetch SW Package From Server
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...    Description: Fetch SW Package From Server
    ...    package_link=https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
    ...    target_version
    [Arguments]        ${package_link}    ${target_version}    ${local_path}=/home/ute/Downloads
    ...    ${artifactory_token}="Authorization: Bearer cmVmdGtuOjAxOjE3OTI5MjExOTA6ME1uaG1sTzdKYTduOVpVNnM1TVpJcDNueVND"
    @{result}    string.split string    string=${target_version}    separator=_
    ${sw_head}     convert to string    ${result[0]}
    ${sw_full_link}    Set Variable
    ...    ${package_link}${sw_head}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    ${passed}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_path}
    Run Keyword If    ${passed}     OperatingSystem.Empty Directory    ${local_path}
    ...    ELSE    OperatingSystem.Create Directory   ${local_path}
    Run And Return Rc And Output
    ...    wget --no-proxy --header=${artifactory_token} ${sw_full_link} -P ${local_path}
    ${sw_package_path}    OperatingSystem.List Directory    ${local_path}    absolute=${TRUE}
    OperatingSystem.File Should Exist    ${sw_package_path[0]}
    ${upgrade_package_path}     set variable    ${sw_package_path[0]}
    [Return]     ${upgrade_package_path}

Update SWCONFIG FILE On Smod
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...      Description: Update SWCONFIG FILE On Smod
    ...      ${para_update} should be a Dictionary. eg: ${dict_flags}     0x190030=0    0x4F0214=0
    [Arguments]    ${para_update}
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${keys}  Get Dictionary Keys   ${para_update}
    FOR    ${key}    IN    @{keys}
        ${output} =   csn.execute    command=cat /ffs/run/swconfig.txt |grep -i '${key}'    connection=ASIK Master
        ${pass}    Run Keyword And Return Status    Should Match Regexp    ${output}    ${key}
        Run Keyword If    ${pass}     csn.execute
        ...    command=cd /ffs/run/ && sed -i -e 's/${key}=.*/${key}=${para_update}[${key}]/' swconfig.txt
        ...    connection=ASIK Master
        ...    ELSE   csn.execute    command=cd /ffs/run/ && echo "${key}=${para_update}[${key}]" >> swconfig.txt
        ...    connection=ASIK Master
    END
    [Teardown]  run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check Flags On Smod SWCONFIG FILE
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...         Description: Check Flags On Smod SWCONFIG FILE
    ...         ${except_dict}: should be a Dictionary. eg: ${dict_flags}     0x190030=0    0x4F0214=0
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    [Arguments]    ${except_dict}
    ${keys}  Get Dictionary Keys   ${except_dict}
    FOR    ${key}    IN    @{keys}
        ${output} =   csn.execute    command=cat /ffs/run/swconfig.txt |grep -i '${key}=${except_dict}[${key}]'
        ...    connection=ASIK Master
        ${pass}    Run Keyword And Return Status    Should Match Regexp    ${output}    ${key}
        should be equal    ${pass}    ${True}
    END
    [Teardown]  run keyword and ignore error  csn.disconnect    connection=ASIK Master

Delta Commission And PDL Verification Passed
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...    dist_name = MRBTS-2012/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    parameter = timeZone
    ...    value = 15min
    [Arguments]    ${delta_file}    ${timeout}=600    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${result}    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    timeout=${timeout}    connection=${connection}
    Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    [Return]    ${result}

COAM get ru sw version from target BD file
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    ...              Description: Get expected RU sw version from ASIK
    ...              ${ru_resource_build_key}: Should be the resourceBuildKey value in the TargetBD*.xml file under folder /ffs/run on ASIK
    ...                                        Example value: LTX_AEQB
    [Arguments]        ${asik_alias}=ASIK Master  ${ru_index}=1  ${directory}=/ffs/stb
    Log To Console  COAM get ru sw version from target BD file
    #Connect to Common Unit Master  alias=${asik_alias}
    ${ru_type}    get ru type    ru_index=${ru_index}
    ${ru_resource_build_key}  Set Variable  LTX_${ru_type}_E1
    ${cmd_get_target_bd_file}    set variable    ls ${directory}/TargetBD_SBTS*.xml
    ${target_bd_file_path}    csn.execute    command=${cmd_get_target_bd_file}    connection=${asik_alias}
    ${target_bd_file_path}    Strip string    ${target_bd_file_path}
    ${cmd_get_exp_ru_build_version}    set variable    more ${target_bd_file_path}|grep 'hwResource resourceBuildKey="${ru_resource_build_key}'
    ${output_ru_build_version}    csn.execute    command=${cmd_get_exp_ru_build_version}    connection=${asik_alias}
    @{ru_build_version}    Get Regexp matches    ${output_ru_build_version}    resourceSWVersion="(.*)"    1
    Should not be empty    ${ru_build_version[0]}    msg=Fail to get ru build version from ${target_bd_file_path} on ASIK
    [Return]  ${ru_build_version[0]}
    [Teardown]  Run Keywords  run keyword and ignore error  csn.disconnect    connection=ASIK Master
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections

Replace Swconfig Through Local File
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${swconfig_local_path}    ${swconfig_remote_path}=/ffs/run/swconfig.txt
    ...    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${hostname}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${alias}=ASIK Master
    Run Keyword And Ignore Error    run process
    ...    sudo sshpass -p ${password} scp ${swconfig_local_path} ${username}@${hostname}:/ffs/run/   shell=yes
    Connect To BTS Csn Via Lmp
    csn.execute    command=chmod 777 ${swconfig_remote_path}    connection=${alias}
    ${swconfig_output}    csn.execute    command=cat ${swconfig_remote_path}    connection=${alias}
    log to console    \n ${swconfig_output}
    csn.execute    command=crasign ${swconfig_remote_path}    connection=${alias}

MM5_Get_All_RUs_SN_Number
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${Ru_Index_List}    Get RU index list    connection=${connection}
    Sort List   ${Ru_Index_List}
    @{Ru_SN_List}    Create list
    FOR    ${ru_index}    IN    @{Ru_Index_List}
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
        Append to List   ${Ru_SN_List}    ${ru_info['serialNumber']}
    END
    [Return]  ${Ru_SN_List}

Verify RU Reset Via Uptime On WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/08 11:05
    [Arguments]    ${rus_index}    ${except_uptime}=10
    Selenium Login And Disable Screen Lock
    FOR    ${ru_index}    IN    @{rus_index}
        ${ru_info}    selenium_sbts.get_ru_info    ru_index=${ru_index}
        ${match}    ${uptime}    Should Match Regexp    ${ru_info["Uptime"]}    (\\d+)m
        Should Be True    ${uptime}<${except_uptime}
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Get RU Reset Via Uptime On WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/11 14:01
    [Arguments]    ${ru_index}
    Selenium Login And Disable Screen Lock
    ${ru_info}    selenium_sbts.get_ru_info    ru_index=${ru_index}
    ${match}    ${uptime}    Should Match Regexp    ${ru_info["Uptime"]}    (\\d+)m
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    [Return]    ${uptime}

Get All Cells Distnames
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/03 16:39
    [Arguments]    ${ignore_lte_cells}=False    ${connection}=GNB_OAM
    @{all_cells}    Create List
    ${nr_cells}    coam.get_cells_info    cell_type=nr     connection=${connection}
    FOR    ${cell_info}    IN    @{nr_cells}
        Append To List    ${all_cells}    ${cell_info["id"]["configuration"]}
    END

    Return From Keyword If    ${ignore_lte_cells}==True    ${all_cells}
    ${lte_cells}    coam.get_cells_info    cell_type=lte    connection=${connection}
    FOR    ${cell_info}    IN    @{lte_cells}
        Append To List    ${all_cells}    ${cell_info["id"]["configuration"]}
    END
    [Return]    ${all_cells}

Convert software version to WFT build version
    [Arguments]    ${sw_version}
    ${SW_version_list}    split string    ${sw_version}    _
    ${trunk_or_branch}    get from list    ${SW_version_list}    2
    ${stream}=    Run keyword if    ${trunk_or_branch}==${9999} or ${trunk_or_branch}==${9990}    Set Variable   SBTS00
    ...   ELSE       Set Variable   ${SW_version_list[0]}
    Set List Value    ${SW_version_list}    0    ${stream}
    ${new_sw_version}    Catenate    SEPARATOR=_    @{SW_version_list}
    [Return]    ${new_sw_version}    ${stream}