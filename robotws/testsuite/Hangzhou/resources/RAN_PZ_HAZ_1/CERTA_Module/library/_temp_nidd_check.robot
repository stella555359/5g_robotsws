*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   For the Temp NIDD Check.

Library            BuiltIn
Library            Collections
Library            DateTime
Library            json
Library            OperatingSystem
Library            Process
Library            String
Library            XML
Library            taf.sbts.oam.coam.admin                      WITH NAME    temp_nidd_coam
Library            temp_nidd_worker/Get_latest_build_name.py    WITH NAME    temp_nidd_wft
Library            taf.transport.ssh                            WITH NAME    temp_nidd_ssh
Variables          temp_nidd_worker/temp_nidd_dictionary.py

*** Variables ***
${delta_plan_folder}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/CERTA_Module/library/temp_nidd_worker/

${23R2_delta_file}      23R2_delta_plan.json
${23R3_delta_file}      23R3_delta_plan.json
${23R4_delta_file}      23R4_delta_plan.json
${24R1_delta_file}      24R1_delta_plan.json
${24R2_delta_file}      24R2_delta_plan.json
${24R3_delta_file}      24R3_delta_plan.json
${25R1_delta_file}      25R1_delta_plan.json
${25R2_delta_file}      25R2_delta_plan.json

${23R2_scf_file}        23R2_SCF.xml


*** Keywords ***
Classical Temp Nidd Check
    [Arguments]    ${operation}
    ...            ${gnb_index}=${0}
    ...            ${cudu_index}=${0}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${timeout}=${7200}
    Log To Console    ${cudu_index}
    ${supported_operation}    Create List    upgrade
    ...                                      full_commission
    ...                                      delta_plan_update
    # ...                                      set_temp_nidd
    ...                                      check_temp_nidd
    ...                                      check_target_nidd
    ${is_supported_operation}    Run Keyword And Return Status
    ...    List Should Contain Value    ${supported_operation}    ${operation}
    Run Keyword If
    ...    '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation no support yet. Please contact the model owner.

    _temp_nidd.Create Log File

    Run Keyword And Ignore Error    _temp_nidd.logout    connection=default
    Run Keyword And Ignore Error    _temp_nidd.logout    connection=temp_nidd_connection
    ${connection}    _temp_nidd.login    connection=${None}
    ...                                  gnb_index=${gnb_index}
    ...                                  alias=temp_nidd_connection

    Run Keyword    _temp_nidd.${operation}_operation    connection=${connection}
        ...                                             target_release=${target_release}
        ...                                             target_version=${target_version}
        ...                                             gnb_index=${gnb_index}
        ...                                             timeout=${timeout}

    _temp_nidd.logout    connection=${connection}

_temp_nidd.upgrade_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}

    Log To Console    ${timeout}
    ${temp_nidd_log_info}    Set Variable    BTS in upgrading to ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${sbts_sw_version}    ${sbts_sw_branch}    _temp_nidd.Get SBTS SWB Version And Branch    connection=${connection}
    ${temp_nidd_log_info}    Set Variable    The current SWB version is ${sbts_sw_version}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${temp_nidd_log_info}    Set Variable    The current SWB branch is ${sbts_sw_branch}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

    ${upgrade_release}    set variable if    "${target_release}"=="Trunk"    SBTS00    SBTS${target_release}

    ${wft_build}    Run Keyword If    "${target_version}"=="${None}"    _temp_nidd.Get SRAN Promotion Builds On Wft    branch=${upgrade_release}
    ${latest_build}    set variable if    "${target_version}"!="${None}"    ${target_version}    ${wft_build}

    ${temp_nidd_log_info}    Set Variable    To be upgraded SWB version of ${upgrade_release} is ${latest_build}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${current_swb_not_satisfied}    set variable if    "${latest_build}"!="${sbts_sw_version}"    True    False
    ${temp_nidd_log_info}    Set Variable    Current SWB need upgrade? ${current_swb_not_satisfied}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}


    Run Keyword If    ${current_swb_not_satisfied}    _temp_nidd.Upgrade Current SWB    swb_version=${latest_build}
    ...                                                                                 connection=${connection}
    ...                                                                                 gnb_index=${gnb_index}

    _temp_nidd.Check SWB Version    connection=${connection}    target_sw_version=${latest_build}
    ${temp_nidd_log_info}    Set Variable    BTS upgrade to ${target_release} SWB version ${latest_build} done!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

_temp_nidd.delta_plan_update_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}
    Log To Console    ${target_version}
    Log To Console    ${gnb_index}
    ${temp_nidd_log_info}    Set Variable    BTS in delta commissioning in ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    _temp_nidd.Update Delta Plan    connection=${connection}
    ...                             delta_file=${delta_plan_folder}${target_release}_delta_plan.json
    ...                             timeout=${timeout}

_temp_nidd.full_commission_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}
    Log To Console    ${target_version}
    Log To Console    ${gnb_index}
    ${temp_nidd_log_info}    Set Variable    BTS in full commissioning in ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

    _temp_nidd.Modify VlanId In SCF File    scf_path=${delta_plan_folder}${target_release}_SCF.xml

    _temp_nidd.Full Commission    connection=${connection}
    ...                           scf_file=${delta_plan_folder}${target_release}_SCF.xml
    ...                           timeout=${timeout}

_temp_nidd.set_temp_nidd_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}
    Log To Console    ${connection}
    Log To Console    ${target_version}
    Log To Console    ${gnb_index}
    Log To Console    ${timeout}
    ${temp_nidd_log_info}    Set Variable    BTS in setting the temprary NIDD parameters of ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    _temp_nidd.Check And Set Nidd    release=${target_release}    action=set    type=temp

_temp_nidd.check_temp_nidd_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}
    Log To Console    ${connection}
    Log To Console    ${target_version}
    Log To Console    ${gnb_index}
    Log To Console    ${timeout}
    ${temp_nidd_log_info}    Set Variable    BTS in checking the temprary NIDD parameters of ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    _temp_nidd.Check And Set Nidd    release=${target_release}    action=check    type=temp

_temp_nidd.check_target_nidd_operation
    [Arguments]    ${connection}
    ...            ${target_release}=${target_release}
    ...            ${target_version}=${target_version}
    ...            ${gnb_index}=${gnb_index}
    ...            ${timeout}=${timeout}
    Log To Console    ${connection}
    Log To Console    ${target_version}
    Log To Console    ${gnb_index}
    Log To Console    ${timeout}
    ${temp_nidd_log_info}    Set Variable    BTS in checking the target NIDD parameters of ${target_release}, please wait!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    _temp_nidd.Check And Set Nidd    release=${target_release}    action=check    type=target

### Check Temp Nidd Operation ###################################################################
_temp_nidd.Check And Set Nidd
    [Arguments]    ${release}    ${action}    ${type}
    ${temp_nidd_log_info}    Set Variable    ${release} Nidd Data is: ${${type}_nidd_${release}}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${nidd_dic_key}      Get Dictionary Keys      ${${type}_nidd_${release}}
    # ${temp_nidd_log_info}    Set Variable    ${release} Nidd Data Keys: ${nidd_dic_key}
    # _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    FOR    ${mo}    IN    @{nidd_dic_key}
        ${para_dic}    Get From Dictionary    ${${type}_nidd_${release}}    ${mo}
        _temp_nidd.Check And Set Each Parameter    ${action}    ${mo}    ${para_dic}
    END

_temp_nidd.Check And Set Each Parameter
    [Arguments]    ${action}    ${mo}    ${para_dic}
    @{mo_list_single}    Create List    ${mo}
    ${para_key}    Get Dictionary Keys    ${para_dic}
    FOR    ${para}    IN    @{para_key}
        ${value}    Get From Dictionary    ${para_dic}    ${para}
        @{para_list_single}    Create List    ${para}
        @{value_list_single}    Create List    ${value}
        # ${temp_nidd_log_info}    Set Variable    Handling NIDD Parameter: @{mo_list_single},@{para_list_single},@{value_list_single}
        # _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

        ${out}    Run Keyword If    '${action}' == 'check'    Run Keyword
        ...       Parameter Operation    operation=parameter_value_check   product_type=gnb
        ...                              para_list=@{para_list_single}    mo_list=@{mo_list_single}
        Run Keyword If    '${action}' == 'check'    Run Keyword    _temp_nidd.Check Single Parameter    ${out}    ${mo}    ${para}    ${value}

        ${out}    Run Keyword If    '${action}' == 'set'    Run Keyword
        ...       Parameter Operation    operation=parameter_update   product_type=gnb
        ...                              para_list=@{para_list_single}    value_list=@{value_list_single}    mo_list=@{mo_list_single}
        Run Keyword If    '${action}' == 'set'    Run Keyword    Sleep    10s
    END

_temp_nidd.Check Single Parameter
    [Arguments]    ${out}    ${mo}    ${para}    ${value}
    # ${temp_nidd_log_info}    Set Variable    GNB Parameter Check Result: ${out}
    # _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${mo_value}    Get From Dictionary    ${out}    ${mo}
    ${para_value}    Get From Dictionary    ${mo_value}    ${para}
    Run Keyword If    '${value}' == '${para_value}'    _temp_nidd.Log And Output    temp_nidd_log_info=PASS:    with_return=True
    Run Keyword If    '${value}' != '${para_value}'    _temp_nidd.Log And Output    temp_nidd_log_info=FAIL:    with_return=True
    ${temp_nidd_log_info}    Set Variable    ${mo} ${para} expected value: ${value}; current value: ${para_value}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

### Full Commission Operation #####################################################################
_temp_nidd.Full Commission
    [Arguments]    ${connection}    ${scf_file}    ${timeout}=${600}
    Log To Console    ${timeout}
    ${out}    Parameter Operation    operation=full_commission   product_type=gnb    scf_path=${scf_file}
    ${temp_nidd_log_info}    Set Variable    GNB scf commission result: ${out}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    Sleep    100s
    _temp_nidd.Check SMOD BBMOD RMOD    connection=${connection}

### Delta Plan Update Operation ###################################################################
_temp_nidd.Update Delta Plan
    [Arguments]    ${connection}    ${delta_file}    ${timeout}=${600}
    temp_nidd_coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                             skip_parameter_relation_errors=${true}
    ...                                             should_activate=${true}
    ...                                             timeout=${timeout}
    ...                                             connection=${connection}
    Sleep    100s
    _temp_nidd.Check SMOD BBMOD RMOD    connection=${connection}

### Upgrade Operation #############################################################################
_temp_nidd.Get SBTS SWB Version And Branch
    [Arguments]    ${connection}
    ${oam_sw_version}=     _temp_nidd.GetSBTSSWVersion    connection=${connection}
    ${sbts_sw_version}    ${sbts_sw_branch}    _temp_nidd.Convert SWB Version To Trunk Branch    SW_version=${oam_sw_version}
    ${temp_nidd_log_info}    Set Variable    *** The SBTS OAM SWB Version is: ${sbts_sw_version} ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${temp_nidd_log_info}    Set Variable    *** The SBTS OAM SWB Branch is: ${sbts_sw_branch} ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    [Return]    ${sbts_sw_version}    ${sbts_sw_branch}

_temp_nidd.GetSBTSSWVersion
    [Arguments]    ${connection}
    ${sw_info}    temp_nidd_coam.get_software_info    connection=${connection}    timeout=10
    ${active_sw_version}    Set Variable    ${sw_info['Active SW version']}
    Run Keyword If    "${active_sw_version}"=="" or "${active_sw_version}"=="-"    Fail    Please Enter Correct Parameter!
    ${passive_sw_version}    Set Variable    ${sw_info['Passive SW version']}
    Run Keyword If    "${passive_sw_version}"=="" or "${passive_sw_version}"=="-"    Fail    Please Enter Correct Parameter!
    ${planned_sw_version}    Set Variable    ${sw_info['Planned SW version']}
    [Return]    ${active_sw_version}

_temp_nidd.Convert SWB Version To Trunk Branch
    [Arguments]    ${SW_version}
	${SW_version_list1}    split string  ${SW_version}    _
    ${branch_orig}    get from list    ${SW_version_list1}    0
	${trunk_or_branch}    get from list    ${SW_version_list1}    2
	${SW_version_list2}    split string    ${SW_version}    ENB
	${SBTS_VER_FULL}    get from list    ${SW_version_list2}    1
	${branch}    set variable if     ${trunk_or_branch}==${9999}    SBTS00    ${branch_orig}
	${new_sw_version}    set variable if    ${trunk_or_branch}==${9999}    SBTS00_ENB${SBTS_VER_FULL}    ${branch_orig}_ENB${SBTS_VER_FULL}
	[Return]    ${new_sw_version}    ${branch}

_temp_nidd.Get SRAN Promotion Builds On Wft
    [Arguments]    ${branch}    ${release_prefix}=${branch}_ENB    ${suffix}=A54
	...            ${promotion_tags}=RAN_MRAT_CRT
    Log To Console    ${suffix}
    Log To Console    ${promotion_tags}
    ${package_states}    Create List    RELEASED    RELEASED_WITH_RESTRICTIONS
    ${promote_build_namelist}    temp_nidd_wft.get namelist of builds     branch=${branch}
    ...                                                                   release_prefix=${release_prefix}
    ...                                                                   package_states=${package_states}
    # ...                                                                   promotion_tags=${promotion_tags}
    ${latest_build_name}    get from list    ${promote_build_namelist}    0
    [Return]    ${latest_build_name}

_temp_nidd.Upgrade Current SWB
    [Arguments]    ${swb_version}    ${connection}    ${gnb_index}
    ${temp_nidd_log_info}    Set Variable    Upgrade gNB to SWB Version: ${swb_version} start ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    _temp_nidd.Upgrade gNB With Indicated Version    indicated_sw_version=${swb_version}    connection=${connection}    gnb_index=${gnb_index}
    ${temp_nidd_log_info}    Set Variable    Upgrade gNB to SWB Version: ${swb_version} done! ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

_temp_nidd.Upgrade gNB With Indicated Version
    [Arguments]    ${indicated_sw_version}    ${connection}    ${gnb_index}

    temp_nidd_ssh.Connect to    hostname=127.0.0.1    username=ute    password=ute    alias=temp_nidd_vm
    ${swb_cmd}=    Catenate
    ...    mkdir ${indicated_sw_version} &&
    ...    cd ${indicated_sw_version} &&
    ...    wget http://files.ute.nsn-rdnet.net/builds/enb/base/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable.zip
    temp_nidd_ssh.execute    command=${swb_cmd}    connection=temp_nidd_vm
    temp_nidd_ssh.disconnect    connection=temp_nidd_vm
    ${temp_nidd_log_info}    Set Variable    SWB package downloaded to VM, start to upgrade to BTS...
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

    temp_nidd_coam.update_software    sw_package=/home/ute/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable.zip
    ...                               should_activate=${True}
    ...                               timeout=${3600}
    ...                               connection=${connection}
    ${temp_nidd_log_info}    Set Variable    Software Update Finished, Waiting For BTS Resetting...
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    # Sleep    100s

    Run Keyword And Ignore Error    _temp_nidd.logout    connection=${connection}
    Wait until keyword succeeds    10 min    30 sec    _temp_nidd.login    connection=${None}
    ...                                                                    gnb_index=${gnb_index}
    ...                                                                    alias=${connection}

    _temp_nidd.Check SMOD BBMOD RMOD    connection=${connection}

    temp_nidd_ssh.Connect to    hostname=127.0.0.1    username=ute    password=ute    alias=temp_nidd_vm
    ${swb_cmd}=    Catenate
    ...    rm -rf ${indicated_sw_version}
    temp_nidd_ssh.execute    command=${swb_cmd}    connection=temp_nidd_vm
    temp_nidd_ssh.disconnect    connection=temp_nidd_vm
    ${temp_nidd_log_info}    Set Variable    SWB package in VM is deleted to save VM space!
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

_temp_nidd.Check SMOD BBMOD RMOD
    [Arguments]    ${connection}
    ${temp_nidd_log_info}    Set Variable    Wait for the components stable.
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    Run Keyword And Ignore Error    _temp_nidd.Check Boards    connection=${connection}    board=Systemboard
    Run Keyword And Ignore Error    _temp_nidd.Check Boards    connection=${connection}    board=Basebandboard
    Run Keyword And Ignore Error    _temp_nidd.Check Boards    connection=${connection}    board=RU
    ${temp_nidd_log_info}    Set Variable    BTS upgrade done and SMOD,BBMOD,RMOD are stable.
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

_temp_nidd.Check Boards
    [Arguments]    ${connection}    ${board}
    Wait until keyword succeeds    10 min    10 sec    _temp_nidd.Check GNB ${board} Status    connection=${connection}

_temp_nidd.Check GNB Systemboard Status
    [Arguments]    ${connection}
    ${temp_nidd_log_info}    Set Variable    Check Systemboard status from GNB
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${hw_info}    temp_nidd_coam.get_detected_hw_info    connection=${connection}
    @{list_system}    Set variable    ${hw_info['systemModules']}
    ${count_system}    Get length    ${list_system}
    Should be true    ${count_system}>=${1}    msg=Check systemboard status failed as total systemboard number is less than 1
    FOR    ${system}    IN    @{list_system}
        _temp_nidd.Status Check    status=${system['status']}    checked_part=systemModules
    END

_temp_nidd.Check GNB Basebandboard Status
    [Arguments]    ${connection}
    ${temp_nidd_log_info}    Set Variable    Check Basebandboard status from GNB
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${hw_info}    temp_nidd_coam.get_detected_hw_info    connection=${connection}
    @{list_baseband}    Set variable    ${hw_info['basebandModules']}
    ${count_baseband}    Get length    ${list_baseband}
    Should be true    ${count_baseband}>=${1}    msg=Check basebandboard status failed as total basebandboard number is less than 1
    FOR    ${baseband}    IN    @{list_baseband}
        _temp_nidd.Status Check    status=${baseband['status']}    checked_part=basebandModules
    END

_temp_nidd.Check GNB RU Status
    [Arguments]    ${connection}    ${ru_sn}=all
    ${temp_nidd_log_info}    Set Variable    Check RU status from GNB
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${hw_info}    temp_nidd_coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR    ${ru}    IN    @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        _temp_nidd.Status Check    status=${ru['status']}    checked_part=RU
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

_temp_nidd.Status Check
    [Arguments]    ${status}   ${checked_part}
    ${has_availabilityStatus}    ${value}    Run Keyword And Ignore Error
    ...    dictionary should contain key    ${status}    availabilityStatus
    Run Keyword If    '${has_availabilityStatus}'=='PASS'    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['availabilityStatus']}    Online
    ...    msg=Current ${checked_part} availabilityStatus is not in Online status    ignore_case=${True}
    ...    ELSE    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['operationalState']}    enabled
    ...    msg=Current ${checked_part} operationalState is not in enabled status    ignore_case=${True}

_temp_nidd.Check SWB Version
    [Arguments]    ${connection}    ${target_sw_version}
    ${temp_nidd_log_info}    Set Variable    *** Checking SWB version start ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${current_sw_version}    ${current_sw_branch}    _temp_nidd.Get SBTS SWB Version And Branch    connection=${connection}
    Should Be True    "${current_sw_version}" == "${target_sw_version}"
    ${temp_nidd_log_info}    Set Variable    *** Checking SWB version done! ***
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

### Connection ####################################################################################
_temp_nidd.login
    [Arguments]    ${connection}=${None}    ${alias}=temp_nidd_connection    ${gnb_index}=${0}
    Return From Keyword If    ${connection}!=${None}    ${connection}
    temp_nidd_coam.connect_to    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    [Return]    ${alias}

_temp_nidd.logout
    [Arguments]    ${connection}=temp_nidd_connection
    temp_nidd_coam.teardown    connection=${connection}
    [Return]    ${connection}

### Log and Output ####################################################################################
_temp_nidd.Create Log File
    ${log_file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${OUTPUT_DIR}/temp_nidd_log.txt
    ${datetime}    Get Current Date
    Run Keyword If    '${log_file_exist}'=='False'    OperatingSystem.Create File    ${OUTPUT_DIR}/temp_nidd_log.txt       ***\n
    OperatingSystem.Append To File    ${OUTPUT_DIR}/temp_nidd_log.txt    =====================================================\n
    OperatingSystem.Append To File    ${OUTPUT_DIR}/temp_nidd_log.txt    ${datetime}: This is the log file for temp_nidd_check\n
    OperatingSystem.Append To File    ${OUTPUT_DIR}/temp_nidd_log.txt    =====================================================\n

_temp_nidd.Log And Output
    [Arguments]    ${temp_nidd_log_info}    ${with_return}=True
    ${datetime}    Get Current Date
    Run Keyword If    '${with_return}' == 'True'
    ...               Log To Console    ${datetime}: ${temp_nidd_log_info}\n
    Run Keyword If    '${with_return}' == 'True'
    ...               OperatingSystem.Append To File    ${OUTPUT_DIR}/temp_nidd_log.txt    ${datetime}: ${temp_nidd_log_info}\n
    Run Keyword If    '${with_return}' == 'False'
    ...               Log To Console    ${datetime}: ${temp_nidd_log_info}
    Run Keyword If    '${with_return}' == 'False'
    ...               OperatingSystem.Append To File    ${OUTPUT_DIR}/temp_nidd_log.txt    ${datetime}: ${temp_nidd_log_info}

### SCF Handling ####################################################################################
_temp_nidd.Modify VlanId In SCF File
    [Arguments]    ${scf_path}
    ${vlanif_distname}    Set Variable    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ${vlan_id_fetched}    Set Variable    ${tl.gnbs[0].cu.x2c.vlan_id}
    ${vlan_id}    Convert To String    ${vlan_id_fetched}
    ${vlan_id_scf}    _temp_nidd.Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    ${temp_nidd_log_info}    Set Variable    VlanId in Testline: ${vlan_id}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}
    ${temp_nidd_log_info}    Set Variable    VlanId in Origin SCF file: ${vlan_id_scf}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

    _temp_nidd.Set Single Value From Scf File    file_path=${scf_path}
    ...                                          dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}
    ${vlan_id_scf}    _temp_nidd.Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    ${temp_nidd_log_info}    Set Variable    VlanId in Edited SCF file: ${vlan_id_scf}
    _temp_nidd.Log And Output    temp_nidd_log_info=${temp_nidd_log_info}

_temp_nidd.Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | actDddsReduction | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

_temp_nidd.Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${suite_log_directory}/SCF_before_suite.xml |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | vlanId | 1901 |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | actDddsReduction | false | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}
