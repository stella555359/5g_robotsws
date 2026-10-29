*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : 5GC002637-A

Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    csn
Library     taf.config.scf.interface.scf     WITH NAME   scf
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.ul.mobile.ui.android    WITH NAME    android_mobile
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace


*** Variables ***
${gnb_ip}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gnb_ip1}                 ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${gNB_username}            ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}            ${tl.gnbs[0].cu.oam_http_connection_details.password}
${eNB_ip}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${TEST_PC_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}
${control_pc}              ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}         ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}         ${tl.ues[0].ssh_connection_details.password}
${TS_CASE_LOG_PATH}        ${output_dir}
${ul_power_port_list}      ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}      ${tl.ues[0].iperf_details.ports[3:6]}
${ul_tput_udp}             400M
${dl_tput_udp}             2000M
${att_ipaddr}              ${tl.attenuator.ip_addr}
${att_api_port}            ${tl.attenuator.port}
${att_connection_port}     ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${CURDIR_path}             ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T737/
${apn_NSA}                 dxdata1
${apn_SA}                  SA
${mode_name}               5G/LTE/3G/2G (auto connect)
${serial_number}           ${tl.ues[0].serial_number}
${gnb1_bts_id}             MRBTS-${tl.gnbs[1].instance_id}
${gnb1_nrbts_id}           NRBTS-${tl.gnbs[1].global_bts_id}
${gnb1_cell_dist_name}     /${gnb1_bts_id}/${gnb1_nrbts_id}/NRCELL-1
${gnb0_cell_dist_name1}    /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
${gnb1_cell_dist_name1}    /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1


*** Keywords ***
########### check bts on air #################
Reset Station
    [Arguments]  ${host_ip}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=20min
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log to console    Restart Station
    coam.reset_site   timeout=${timeout}  connection=${connection}

Check cell on air
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s    ${alias}=default
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${alias}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

########## modify parameter ###################
Modify Value On DU
    [Arguments]    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=coam_admin
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    run keyword if  ${is_common}    Modify Common parameter via Coam    input_list=${common_modify_list}    connection=${connection}
    Check cell on air    alias=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Add Object in SCF
    [Arguments]  ${default_scf}    ${object_list}    ${new_scf_name}
    scf.load_scf       file_path=${default_scf}
    FOR    ${item}    IN    @{object_list}
        ${source_dist_name}    Get From Dictionary    ${item}    source_dist_name
        ${target_dist_name}    Get From Dictionary    ${item}    target_dist_name
        scf.clone_mo_with_descendant_mos    source_mo_dist_name=${source_dist_name}    target_mo_dist_name=${target_dist_name}
    END
    ${new_scf}    set variable    ${output_dir}/${new_scf_name}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Modify Parameter in SCF
    [Arguments]  ${input_scf}    ${para_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR     ${item}    IN    @{para_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${p_name}    Get From Dictionary    ${item}    p_name
        ${value}    Get From Dictionary    ${item}    value
        scf.modify_scf_element     dist_name=${dist_name}    p_name=${p_name}     value=${value}    list_name=${list_name}
    END
    ${new_scf}    set variable    ${output_dir}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

Add Element in SCF
    [Arguments]  ${input_scf}    ${element_list}    ${modify_scf}
    scf.load_scf       file_path=${input_scf}
    FOR    ${item}    IN    @{element_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${list_name}    Get From Dictionary    ${item}    list_name
        ${elements}    Get From Dictionary    ${item}    elements
        scf.add_elements_to_list    dist_name=${dist_name}    list_name=${list_name}     elements=${elements}
    END
    ${new_scf}    set variable    ${output_dir}/${modify_scf}
    scf.save_scf        file_path=${new_scf}
    [Return]  ${new_scf}

#################### Case Setup and Teardown ########################
Common Case Setup
#    Block Cell and check if success
    Setup Commission SCF_4G
    sleep   5min
#    modify enb defaultLnRelGnbCellId parameter

modify enb defaultLnRelGnbCellId parameter
    [Arguments]     ${value}=${4}
    log to console  modify enb defaultLnRelGnbCellId parameter
    Connect to gnb coam via ssl    bts_host=${Enb_ip}    username=${gNB_username}    password=${gNB_password}    connection=ENB_OAM
    ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-10432/LNBTS-10432/LNCEL-1
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=ENB_OAM
    [Teardown]    coam.Teardown     connection=ENB_OAM

Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${if_22R2_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
    ...    ${if_22R2_load}    ${CURDIR_path}SCF_SBTS22R2.xml    ${CURDIR_path}SCF_SBTS22R3.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Set Default scf name_NSA
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${if_22R2_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
    ${default_scf_NSA}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00_NSA.xml
    ...    ${if_22R2_load}    ${CURDIR_path}SCF_SBTS22R2_NSA.xml    ${CURDIR_path}SCF_SBTS22R3_NSA.xml
    set suite variable    ${default_scf_NSA}
    log to console   ${default_scf_NSA}
    [Return]  ${default_scf_NSA}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF_5G_SA
    [Arguments]    ${connection}=GNB_OAM
    ${default_scf}    Set Default scf name
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}
    Check cell on air    alias=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF_5G_NSA
    [Arguments]    ${connection}=GNB_OAM
    ${default_scf_NSA}    Set Default scf name_NSA
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_NSA}
    Check cell on air    alias=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF_4G
    [Arguments]    ${connection}=ENB_OAM
    Connect to gnb coam via ssl    bts_host=${eNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    COAM Commission with scf file    scf_file_path=${CURDIR_path}SCF_SBTS00_4G.xml    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify SCF And Commission SCF
    [Arguments]    ${para_list}    ${modify_scf}
    ${default_scf}    Set Default scf name
    ${new_scf}    Modify Parameter in SCF    input_scf=${default_scf}    para_list=${para_list}   modify_scf=${modify_scf}
    Setup Commission SCF    scf_file_path=${new_scf}
    sleep    2min

Commmon Case Teardown
    Run Keyword And Ignore Error     Clear All DU Connection From UTE    connect_ip=${gNB_ip}
#    Run Keyword And Ignore Error    detach multi power ue    ue_num=${1}
    CI_interface.Common Case Teardown

Clear All DU Connection From UTE
    [Arguments]    ${connect_ip}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.send_command    command=ps -ef | grep ${connect_ip} | awk '{print $2}' | xargs kill -9    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

###################### Capture TTI Log #########################
start tti trace
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}

Stop tti trace log
    [Arguments]
    log to console  stop capture tti trace
    Stop TTI trace log capturing
    ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
    [Return]    ${UL_DL_csv_file_path_dict}

###################### UE Relevant #########################
attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_index=${item}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

########### PA Relevant #################
Adjust the HBTE attenuation value
    [Arguments]      ${value_list}    ${port_list}   ${port_list1}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_list}[${i}]
        ${value_port}    att.read_attenuation    port=${port_list1}[${i}]
        should be equal    ${value_port}    ${value_list}[${i}]
    END

Adjust the HBTE attenuation value Multi Times
    [Arguments]  ${begin_value}    ${end_value}    ${step}    ${time}    ${port_list}    ${port_list1}
    FOR    ${i}    IN RANGE    ${begin_value}    ${end_value}    ${step}
        ${value_list}    create list    ${i}    ${i}    ${i}    ${i}
        Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}    port_list1=${port_list1}
        sleep    ${time}
    END

############## Case Step ####################
Case Setup_SA
    [Arguments]    ${flag}
    Setup Commission SCF_5G_SA
#    attach multi power ue    ue_num=${1}
#    run keyword if    '${flag}'=='NSA'    Switch UE to NSA model
#    run keyword if    '${flag}'=='SA'    Switch UE to SA model
    ${port_list1}    create list    ${1}    ${2}    ${3}    ${4}
    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
    ${value_list}    create list    ${50}    ${50}    ${50}    ${50}
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}    port_list1=${port_list1}
#    detach multi power ue    ue_num=${1}

Case Setup_NSA
    [Arguments]    ${flag}
#    attach multi power ue    ue_num=${1}
#    run keyword if    '${flag}'=='NSA'    Switch UE to NSA model
#    run keyword if    '${flag}'=='SA'    Switch UE to SA model
    Setup Commission SCF_5G_NSA
    ${port_list1}    create list    ${1}    ${2}    ${3}    ${4}
    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
    ${value_list}    create list    ${50}    ${50}    ${50}    ${50}
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}    port_list1=${port_list1}
#    detach multi power ue    ue_num=${1}

Case1 Adjust the HBTE attenuation
    [Arguments]  ${direction}
    ${port_list1}    create list    ${1}    ${2}    ${3}    ${4}
    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
    Star tti adjust PA and check tti    port_list=${port_list}    port_list1=${port_list1}    begin_value=${10}
    ...    end_value=${60}    step=${10}    flag=add    direction=${direction}
    sleep  10s
    Star tti adjust PA and check tti    port_list=${port_list}    port_list1=${port_list1}    begin_value=${60}
    ...    end_value=${0}    step=${-5}    flag=reduce    direction=${direction}

Common Check TTI Log
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}    ${flag}
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${csv_path}    replace_csv_content    file_path=${csv_path}
    ${ul_csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    UL
    ${ul_csv_path}    replace_csv_content    file_path=${ul_csv_path}
    ${tpc_list}    TTI_Trace.get_ulTpc_Or_dlTpc_Tpc    file_path=${csv_path}    direction=${direction}
    ${Pathloss_list}    TTI_Trace.get_ulLaPhr_Pathloss    file_path=${ul_csv_path}
    ${LaPhr_list}    TTI_Trace.get_ulLaPhr_sfn    file_path=${ul_csv_path}

    ${Pathloss_Status}    Check_Pathloss_Status    input_list=${Pathloss_list}    expect_diff=2    flag=${flag}
    ${TPC_Status}    Check_TPCcommand_Trend    TPC_value_list=${tpc_list}    tolerance=0.2    flag=${flag}
    ${LaPhr_result}    Check_LaPhr_Sfn_cycle    LaPhr_list=${LaPhr_list}    tolerance=0.6

#    Run Keyword And Continue On Failure    Should Be Equal    ${Pathloss_Status}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${TPC_Status}    ${True}
#    Run Keyword And Continue On Failure    Should Be Equal    ${LaPhr_result}    ${True}

Star tti adjust PA and check tti
    [Arguments]    ${port_list}    ${port_list1}    ${begin_value}    ${end_value}    ${step}    ${flag}    ${direction}
    start tti trace
    Adjust the HBTE attenuation value Multi Times    begin_value=${begin_value}    end_value=${end_value}    step=${step}
    ...    time=0.5    port_list=${port_list}    port_list1=${port_list1}
    ${UL_DL_csv_file_path_dict}    Stop tti trace log
    Common Check TTI Log   UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}    direction=${direction}    flag=${flag}

############## SA/NSA Change ####################
Switch UE to NSA model
   android_mobile.setup
    ...   ui_version=one ui 3.1
    ...   host=${control_pc}
    ...   username=${control_pc_name}
    ...   password=${control_pc_pass}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test
   android_mobile.switch_network_mode    mode_name=${mode_name}    mobile=test
   android_mobile.switch_apn    apn_name=${apn_NSA}      mobile=test
   ${access_name}   android_mobile.get_access_point_name         mobile=test
   log to console    ${access_name}
   android_mobile.disable_volte_calls      mobile=test
   android_mobile.teardown    mobile=test


Switch UE to SA model
    android_mobile.setup
    ...   ui_version=one ui 3.1
    ...   host=${control_pc}
    ...   username=${control_pc_name}
    ...   password=${control_pc_pass}
    ...   port=22
    ...   serial_number=${serial_number}
    ...   alias=test
   android_mobile.switch_network_mode       mode_name=${mode_name}      mobile=test
   android_mobile.switch_apn    apn_name=${apn_SA}      mobile=test
   ${access_name}   android_mobile.get_access_point_name         mobile=test
   log to console    ${access_name}
    android_mobile.enable_volte_calls    mobile=test
   android_mobile.teardown    mobile=test

############## lock/Unlock Station ####################
Check if Cell Blocked
    [Arguments]    ${host_ip}=${gnb_ip1}    ${dist_name}=/MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1    ${connection}=GNB_OAM
#    ${dist_name}=/MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
#    ${info}    coam.get_subcells_info    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${info}    coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    should be equal as strings      ${info['stateInfo']['blockingState']}     Blocked
    log to console    CELL_1 is ${info['stateInfo']['blockingState']}
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

Check if Cell Unblocked
    [Arguments]  ${host_ip}    ${dist_name}=/MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${info}    coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    should be equal as strings      ${info['stateInfo']['blockingState']}     Unblocked
    log to console    CELL_1 is ${info['stateInfo']['blockingState']}
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

Block Cell through admin
    [Arguments]  ${host_ip}    ${dist_name}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${info}    coam.block_cell     dist_name=${dist_name}    connection=${connection}
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

#Unlock RU through admin
#    [Arguments]  ${RU id}
#    ${result}=      admin_cli.unlock_RU   dist_name=${RU id}
#    should be equal as strings  ${result}   completed

Check Cell Status
    [Arguments]    ${host_ip}=${gnb_ip1}    ${dist_name}=/MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${info}    coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    [Return]  ${info['stateInfo']['blockingState']}
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}


Block Cell and check if success
    [Arguments]    ${host_ip}=${gnb_ip1}    ${dist_name}=${gnb1_cell_dist_name}    ${dist_name1}=${gnb1_cell_dist_name1}
    ${status}    Check Cell Status    host_ip=${host_ip}    dist_name=${dist_name1}
    run keyword if     '${status}'=='Unblocked'    Block Cell through admin    host_ip=${host_ip}    dist_name=${dist_name}
    Wait until keyword succeeds    3min    10sec     Check if Cell Blocked    host_ip=${host_ip}    dist_name=${dist_name1}
