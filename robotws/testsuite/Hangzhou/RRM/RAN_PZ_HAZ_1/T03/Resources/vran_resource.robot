*** Settings ***
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../Resources/Common/Airphone.robot
Library           ../../Resources/Classical/python/plib2/pet_robot.py
Library           ../Resources/python/traffic_model_schedule.py
Library           traffic_model_schedule.TrafficModel    WITH NAME    traffic_model
Library           traffic_model_schedule.BenchmarkKpi    WITH NAME    BK
Resource          pa_pb_resource.robot
Resource          iperf_resource.robot
Resource          feature_resource.robot
Resource          log_resource.robot
*** Variables ***
${RELEASE}    vDUCNF00
*** Keywords ***
#duplicate KW for classical and vran
Get Load Scf Path
    [Documentation]    if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_posttag}=VDU0    ${release}=${RELEASE}
    ${matches}    Get Matches    ${TEST TAGS}    regexp=SCF_[0-9a-zA-Z-_]+
    ${scf_need_tag}    Get Length    ${matches}
    Return From Keyword If    ${scf_need_tag}==${0}
    ${matches}    Split String    ${matches[0]}    SCF_
    ${scf_file_path}    Get Load Scf Path Without Tag    scf_prefix=${matches[-1]}
    ...    scf_posttag=${scf_posttag}    release=${RELEASE}
    [Return]    ${scf_file_path}

Get Load Scf Path Without Tag
    [Documentation]    if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${scf_prefix}=GLODEN    ${scf_posttag}=VDU0    ${release}=${RELEASE}
    ...    ${base_scf_path}=${SCF_DIR_PATH}
    ...    ${file_suffix}=xml
    ${TestLine_Name_without_localtion}    Split String    ${TestLine_Name}    .
    ${scf_file_path}    Run keyword If    '${scf_posttag}'=='VDU0'
    ...    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}.${file_suffix}
    ...    ELSE    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}.${file_suffix}
    ${scf_file_path}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${scf_file_path}
    ...    ELSE    Join Path    ${base_scf_path}    ${TestLine_Name_without_localtion[-1]}
    ...    ${scf_prefix}_${scf_posttag}_${release}.${file_suffix}
    ${is_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    path=${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist}'=='False'
    ...    Replace String    ${scf_file_path}    _${release}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    ${scf_file_path}    Run Keyword If    '${is_exist}'=='False' and '${scf_posttag}'=='BTS0'
    ...    Replace String    ${scf_file_path}    _${scf_posttag}    ${EMPTY}
    ...    ELSE    Set Variable    ${scf_file_path}
    [Return]    ${scf_file_path}

Get Release Of SW
    [Arguments]    ${sw}
    ${release_list}    Split String    ${sw}    _
    [Return]    ${release_list}[0]

Commission VRAN SCF Until On Air
    Run Keyword If    '${DEBUG_MODE}'!='${True}'    Commissioning VCU SCF
    Run Keyword If    '${DEBUG_MODE}'!='${True}'    Commissioning VDU SCF
    wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair For All DUs

Commissioning V${type}U SCF
    Log to console    \n***Commissioning VCU SCF And Check On Air***
    ${vxu_version}    Run Keyword    Get v${type}U Version
    ${vxu_release}    Run Keyword    Get Release Of SW    ${vxu_version}
    ${vxu_number}    Run Keyword    Get v${type}U Number
    FOR    ${xu_index}    IN RANGE   ${vxu_number}
        ${path}    Get Load Scf Path    scf_posttag=V${type}U${xu_index}    release=${vxu_release}
        ${file_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${path}
        Continue For Loop If    '${file_exist}'=='${False}'
        Run Keyword    "${type}""=="C"
        ...    vCU Full Commssion By Rest    scf_path=${path}
        ...    ELSE IF    "${type}""=="D"
        ...    vDU Update Full SCF By Rest    scf_path=${path}
    END

AIC Case Setup
    [Arguments]    ${airphone_config_tag}=${None}
    ...    ${call_type}=sa
    ...    ${base_path}=${None}
    Run Keyword If    '_AP_' in '${TESTLINE_TYPE}'
    ...    Setup All Airphone Env     airphone_config_tag=${airphone_config_tag}
    ...    call_type=${call_type}
    ...    base_path=${base_path}
    ...    ELSE    Commission VRAN SCF Until On Air
    # Init Attenuation All Max

AIC Upgrade Other vDU by Kuafu
    [Arguments]    ${bts_index}=${0}    ${update_if_same_version}=${False}
    ...    ${expect_version}=${None}
    ${vdu_number}    Run Keyword    Get vDU Number
    Log To Console    ${update_if_same_version},${bts_index},${expect_version} is not used
    FOR    ${du_index}    IN RANGE    ${vdu_number}
        Continue For Loop If    '${du_index}'=='${0}'
        AIC Upgrade By Kuafu    vxu=vdu    bts_index=${bts_index}    du_index=${du_index}
        ...    update_if_same_version=${update_if_same_version}    expect_version=${expect_version}
    END

AIC Upgrade vCU And vDu by Kuafu For All
    ${gnb_length}    Get Length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_length}
        AIC Upgrade vCU And vDu by Kuafu For One BTS    bts_index=${gnb_index}
    END

AIC Upgrade vCU And vDu by Kuafu For One BTS
    [Documentation]    If you need to upgrade both vcu and vdu, please append the vcu version to the end of single run
    [Arguments]    ${bts_index}=${0}
    ${expect_version}    Get Expect Sw Version
    Run Keyword If    "vDUCNF" in '${expect_version}'
    ...    Run Keywords
    ...    AIC Upgrade By Kuafu    vxu=vdu    bts_index=${bts_index}    du_index=${0}    expect_version=${expect_version}
    ...    AND
    ...    AIC Upgrade Other vDU by Kuafu    bts_index=${bts_index}    expect_version=${expect_version}
    ...    ELSE IF    "vCUCNF" in '${expect_version}'
    ...    AIC Upgrade By Kuafu    vxu=vcu    bts_index=${bts_index}    du_index=${0}    expect_version=${expect_version}
    ...    ELSE
    ...    Fail    Upgrade version is not supported: ${expect_version}

    ${key_list}    Create List    CM_ARTIFACTS    -1    name
    ${Expect_cu_Sw_Version}    Get Info From UTE Reservation File    key_list=${key_list}
    Return From Keyword If    '${Expect_cu_Sw_Version}'=='${expect_version}'
    Run Keyword If    "vDUCNF" in '${Expect_cu_Sw_Version}'
    ...    Run Keywords
    ...    AIC Upgrade By Kuafu    vxu=vdu    bts_index=${bts_index}    du_index=${0}    expect_version=${Expect_cu_Sw_Version}
    ...    AND
    ...    AIC Upgrade Other vDU by Kuafu    bts_index=${bts_index}    expect_version=${expect_version}
    ...    ELSE IF    "vCUCNF" in '${Expect_cu_Sw_Version}'
    ...    AIC Upgrade By Kuafu    vxu=vcu    bts_index=${bts_index}    du_index=${0}    expect_version=${Expect_cu_Sw_Version}
    ...    ELSE
    ...    Return From Keyword

AIC Upgrade By Kuafu
    [Arguments]    ${vxu}=vdu    ${bts_index}=${0}    ${du_index}=${0}    ${update_if_same_version}=${False}
    ...    ${expect_version}=${None}
    [Documentation]    Upgrade vDU/vcu by kuafu
    ${sw_version}    Run Keyword If    '${vxu}'=='vcu'    Get vCU Version    gnb_index=${bts_index}
    ...    ELSE    Get vDU Version    vdu_index=${du_index}    gnb_index=${bts_index}
    ${is_same}    Compare Sw Version    ${sw_version}    ${expect_version}
    Run Keyword If    ${is_same} and not ${update_if_same_version}
    ...    Run Keywords
    ...    Log To Console    v${vxu} is already on the expected version: ${expect_version}
    ...    AND    Return From Keyword
    # (self, product_type, info_type, bts_index=0, du_index=0, ru_index=0, *args, **kwargs):
    ${update_info}    Run Keyword If    '${vxu}'=='vdu'
    ...    get_site_info    product_type=vdu    info_type=ssh
    ...    bts_index=${bts_index}    du_index=${du_index}
    ...    ELSE
    ...    get_site_info    product_type=vcu    info_type=ssh
    ...    bts_index=${bts_index}    du_index=${du_index}
    # ...    ${tl.cloud_hostings[${bts_index}].control_nodes[0].default_ssh_connection_details}
    ${cmd_list}    Create List    ${update_info.addr}
    ...                           ${update_info.username}
    ...                           ${update_info.password}
    ${cu_master_username}    Set Variable    ${tl.gnbs[${bts_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$|\\[${cu_master_username}@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To   ip=${update_info.addr}    username=${update_info.username}   password=${update_info.password}
    ...   prompt=${prompt}
    ...   alias=vxu_master
    ${kuafu_version}    issh.execute    command=cd ~;ls -dt */ | grep kuafu | grep -v '\.tar\.gz$' | head -n 1    alias=vxu_master
    Should Contain    ${kuafu_version}    kuafu-v
    ${kuafu_version_clean}    Evaluate    '''${kuafu_version}'''.strip().split('/')[0]
    ${version}=    Evaluate    re.search(r'kuafu-v(\\d+\\.\\d+\\.\\d+)', '''${kuafu_version_clean}''').group(1)    re
    Log    Kuafu version: ${version}
    ${expect_version_used_in_kuafu}    split string   ${expect_version}    _
    Append To List    ${cmd_list}    ${version}
    ...    ${vxu}
    ...    ${expect_version_used_in_kuafu}[-1]
    ${cmd}    Catenate    @{cmd_list}
    ${ret}    OperatingSystem.Run     python ${CURDIR}/python/kuafu_upgrade.py ${cmd}
    Log    Upgrade result: ${ret}
    Sleep    3 minutes    reason=Wait for upgrade to complete
    Run Keyword If    '${vxu}'=='vdu'
    ...    Run Keywords
    ...    wait until keyword succeeds    30 min    1 min    vDU Check All Cells Status Should Be Onair For All DUs
    ...    gnb_index=${bts_index}
    ...    AND
    ...    wait until keyword succeeds    15 min    30 sec    Check All Cells On Air In Multiple vCU
        Run Keyword If    '${vxu}'=='vcu'
    ...    Run Keywords
    ...    wait until keyword succeeds    30 min    1 min    Check All Cells On Air In Multiple vCU
    ...    AND
    ...    wait until keyword succeeds    15 min    30 sec    vDU Check All Cells Status Should Be Onair For All DUs
    ...    gnb_index=${bts_index}
    ${sw_version}    Run Keyword If    '${vxu}'=='vcu'    Get vCU Version    gnb_index=${bts_index}
    ...    ELSE    Get vDU Version    vdu_index=${du_index}    gnb_index=${bts_index}
    ${is_same}    Compare Sw Version    ${sw_version}    ${expect_version}
    Should Be True    ${is_same}    msg=Upgrade failed, sw version is not the expected version: ${sw_version} != ${expect_version}
    [Teardown]    Run Keyword And Ignore Error    issh.Disconnect    alias=vxu_master