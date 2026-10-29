*** Settings ***
Documentation
...               author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.config.scf    WITH NAME    cscf
Library           ../../CB007608_B-573/Resources/5GC000573_common.py

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
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}

*** Keywords ***
Get Version
    Log To Console    Get Version
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    _
    ${versiontitle}    set variable    ${version_list[0]}
    [Return]    ${versiontitle}
    [Teardown]    coam.Teardown  connection=${conn}

COAM Commission with scf file ignore error
    [Arguments]  ${scf_file_path}=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_gNB1.xml
    ...    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    Connect to gnb coam via ssl
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

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
    Connect to DU
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
    ${conn}    Connect to DU
    COAM Commission with scf file ignore error    scf_file_path=${output_dir}/scf.xml     connection=${conn}
    RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
    [Teardown]    Remove File    ${scf_path}

Trigger A3 measurement report for 1874 case
    [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=55    ${serving_cell_sinr}=30    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=77
    ...    ${neigh_cell_sinr}=30    ${tm500_alias}=e500
    log to console  Start to trigger A2 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{4[[50] [55] [30]]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{4[[71] [77] [30]]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
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








