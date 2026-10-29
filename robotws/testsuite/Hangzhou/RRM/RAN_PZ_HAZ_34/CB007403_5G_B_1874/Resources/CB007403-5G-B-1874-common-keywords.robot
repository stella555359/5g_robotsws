*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.config.scf    WITH NAME    cscf

*** Variables ***
${MRBTS_ID}               ${tl.gnbs[0].instance_id}
${NRBTS_ID}               ${tl.gnbs[0].global_bts_id}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${target}                 ${OUTPUT_DIR}/btslog.log
${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
${LOG_PATH}               ${OUTPUT_DIR}
${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_file_path}            ${output_dir}
${luashark_path}              /opt/ute/luashark/luashark_script/generated_luashark

*** Keywords ***
Get Version
    [Arguments]     ${conn}=cOAM_admin
    Log To Console    Get Version
    Connect to gnb coam via ssl    connection=${conn}    bts_host=${DU_IP}
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=   coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}
Modify scf file
    [Timeout]  20 min
    [Arguments]    ${value1}=n64    ${value2}=64    ${MRBTS_ID}=${tl.gnbs[0].instance_id}    ${timeout}=10 min    ${scf_mame}=SCF_C.xml
    ...    ${value3}=50    ${value4}=n32    ${value5}=64    ${value6}=51    ${value7}=22452    ${value8}=2073399    ${value9}=true
    ...    ${conn}=cOAM_admin
    Connect to gnb coam via ssl    connection=cOAM_admin    bts_host=${DU_IP}
    coam.get_current_scf_file    local_dir_path=${output_dir}    file_name=${scf_mame}    connection=cOAM_admin    timeout=60
    Disconnect from DU
    ${scf_path}     set vari able    ${output_dir}/${scf_mame}
    cscf.load_scf    ${scf_path}
    cscf.modify_scf_element    value=${value1}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=cbraPreamblesPerSsb
    cscf.modify_scf_element    value=${value2}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=totalNumberOfRAPreambles
    cscf.modify_scf_element    value=${value3}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=physCellId
    cscf.modify_scf_element    value=${value7}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=gscnOrSsPbchArfcn
    cscf.modify_scf_element    value=${value8}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    p_name=nrarfcn
    cscf.modify_scf_element    value=${value4}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    p_name=cbraPreamblesPerSsb
    cscf.modify_scf_element    value=${value5}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    p_name=totalNumberOfRAPreambles
    cscf.modify_scf_element    value=${value6}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    p_name=physCellId
    cscf.modify_scf_element    value=${value7}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    p_name=gscnOrSsPbchArfcn
    cscf.modify_scf_element    value=${value8}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2    p_name=nrarfcn
    cscf.modify_scf_element    value=${value9}    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    p_name=actIntraFreqIntraGnbMobilityNSA
    cscf.save_scf    ${output_dir}/scf.xml
    Connect to gnb coam via ssl    connection=${conn}    bts_host=${DU_IP}
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
    [Teardown]    Remove File    ${scf_path}

Trigger A3 measurement report for 1874 case
    [Arguments]    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport 1 0 0 0 1{8 [50] [[50] [55] [30]] [] [[1{0[[50] [55]
    ...    [30]]}] []] [] []} [0(1{[51] [[71] [77] [30]] [][ [1{0[[71] [77] [30]]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    5GC000573_common_keyword.match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

Check btslog
    [Arguments]    ${command}=grep 'Free cfPreamble32 for ssbIndex'   ${target}=${target}    ${connection}=ute
    log to console    Check btslog meassage...
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${target} |${command}
    ...    connection=${connection}
    ${free}  csn.Read Output    connection=${connection}
    should not be empty    ${free}
    log to console    Check btslog meassage successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Adjust Enb
    [Arguments]    ${index}=locked  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-3
    ...    ${parameter}=administrativeState
    Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}

1095 Download Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    ssh.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    40s
    ${buffer}=         ssh.readOutput    connection=${connect}
    5GC000573_common_keyword.Copy Viavi Log    logs_path=${new_path}
    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

1095 Check_TP_And_Bler
    [Arguments]  ${dir_path}    ${ul_min_tp}    ${ul_max_tp}    ${dl_min_tp}    ${dl_max_tp}    ${bler_value}
    ${ul_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${dl_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${ul_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=ul    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${dl_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=dl    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}
