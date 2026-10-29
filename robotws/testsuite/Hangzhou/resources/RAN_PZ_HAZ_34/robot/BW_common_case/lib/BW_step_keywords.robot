*** Settings ***
Documentation    This is common keywords for BW related cases
...              Please do not modify the file without notification to author
...              author: cailanwen,lijianhua,linjiangjin,chenshufei
...              contact: lanwen.cai@nokia-sbell.com
...              squad group: SG_08

Library     taf.rfrl.common_resources.python.stream_manager
Library     replace_param.py
Library     checkSRS.py
Library     tti_log_analysis.py
Library     tti_log_analysis.TTI_trace_log_analysis
Library     taf.rfrl.common_resources.python.TTI_Trace    WITH NAME    tti
Library     taf.hw.rf_attenuator    WITH NAME   attenuator
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter  WITH NAME  coam_parameter
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_log.robot
Resource    ../../rrm_log_check.robot
Resource    ../../BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Keywords ***
Get gNB mrbtsID and nrbtsID
    [Arguments]  ${cell_id}=1
    ${scf_path}    COAM Download scf from cluster
    ${nrcell_info}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell_id}" | head -n 1
    ${mrbtsID}    Run    echo ${nrcell_info}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${nrbtsID}    Run    echo ${nrcell_info}|grep -oE "NRBTS-[0-9]+"| awk -F '-' '{print $2}'
    set test variable  ${mrbtsID}
    set test variable  ${nrbtsID}
    [Return]    ${mrbtsID}    ${nrbtsID}

Get parameter in SCF
    [Arguments]    ${para}    ${dist_value}    ${connection}=GNB_OAM
    ${parameter}    coam_parameter.get_single_value_from_scf_file    parameter=${para}    dist_name=${dist_value}    connection=${connection}
    [Return]    ${parameter}

Modify Parameters for TDD bandwidth by config
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to modify TDD bandwith by config in variables_xxxx.py
    ...    for one cell
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${modify_scf_paratmer}    ${gnb_type}='NSA'
    log to console    \n***modify TDD bandwidth Parameters***
#    ${mrbtsID}    ${nrbtsID}   Get gNB mrbtsID and nrbtsID
    set suite variable    ${dist_name}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    replace_parameter_dist_name    ${modify_scf_paratmer}    ${dist_name}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_scf_paratmer}    timeout=15min
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type=${gnb_type}

Check L3 Call And Download TTI
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Check L3 Call And Download TTI
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${dl_tp}=300M
    ...    ${ul_tp}=100M
    ...    ${duration}=${600}
    ...    ${dl_exp}=60
    ...    ${ul_exp}=20
    ...    ${protocol}=udp
    ...    ${gnb_type}=NSA
    ...    ${cell_id}=1
    ...    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=0.95
    ...    ${min_percent}=0.85
    log to console    \n***Start UE attach***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    Run keyword if    '${gnb_type}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    4G_check=False    5Grach_ed=${5Grach_ed}
    Teardown the Aasyslog save progress
    ${traffic_duration}    evaluate    ${duration}*2+100
    log to console    \n***Start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}
    run keyword if    '${protocol}'!='tcp'    power_ue.Start traffic    ue_type=${ue_type}
    ...    direction=ul    throughput=${ul_tp}    duration=${traffic_duration}    protocol=${protocol}
    sleep    60s
    log to console    \n***Start check Throughput***
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    run keyword and continue on failure    run keyword if    '${protocol}'!='tcp'    power_ue.Check Bi Tput
    ...    ue_type=${ue_type}    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...     dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE    power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}    cells=${cell_id}
    ...    target_throughput=${dl_exp}
#    run keyword if    '${hw_type}'=='ASIK'    TTI LOG Capture and Download
    [Teardown]    Stop UE L3 Call

Stop UE L3 Call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]L3 call
    ...    *******************
    ...    Owner_Li jianhua@nokia-sbell.com
    log to console    \n***Stop UE L3 Call***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach  ue_type=${ue_type}

UL_and_DL_LA_data_traffic
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check L3 call of BW feature
    ...    ******************
    ...    History of changes
    ...    10.20.2020 - - Created
    ...    Owner_lanwen.cai@nokia-sbell.com
    ...    *******************
    [Arguments]    ${modify_scf_paratmer}    ${tput}    ${protocol}=udp    ${gnb_type}=NSA    ${cell_id}=1
    ...    ${connection}=GNB_OAM    ${target_avg_percent}=0.95    ${min_percent}=0.85
    Modify Parameters for TDD bandwidth by config    modify_scf_paratmer=${modify_scf_paratmer}    gnb_type=${gnb_type}
#    ${hw_type}    check_fsm    ipaddr=${asik_addr}
#    set suite variable    ${hw_type}
    Check L3 Call And Download TTI
    ...           ul_tp=${tput['ul_send']}
    ...           dl_tp=${tput['dl_send']}
    ...           ul_exp=${tput['ul_exp_tp']}
    ...           dl_exp=${tput['dl_exp_tp']}
    ...           protocol=${protocol}
    ...           gnb_type=${gnb_type}
    ...           cell_id=${cell_id}
    ...           connection=${connection}
    ...           target_avg_percent=${target_avg_percent}
    ...           min_percent=${min_percent}
#    ${list_index_dl}    run keyword if    '${hw_type}'=='ASIK'    get_dl_params_col_index    file_path=${filepath_dl}
#    ${list_index_ul}    run keyword if    '${hw_type}'=='ASIK'    get_ul_params_col_index    file_path=${filepath_ul}
#    run keyword and continue on failure    run keyword if   '${hw_type}'=='ASIK'    Check TTI DL
#    ...    tti_trace_index_dl=${list_index_dl}
#    ...    expects=${TTI_dl_check}
#    ...    percentage=${TTI_percentage}
#    run keyword and continue on failure    run keyword if    '${hw_type}'=='ASIK' and '${protocol}'!='tcp'    Check TTI UL
#    ...    tti_trace_index_ul=${list_index_ul}
#    ...    expects=${TTI_ul_check}
#    ...    percentage=${TTI_percentage}
    [Teardown]    run keyword and ignore error   csn.disconnect    connection=ASIK Master

Get HBTE Attenuation value
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]get PA value
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    ${value_1}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0]}    attenuator_device=HBTE
    ${value_2}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1]}    attenuator_device=HBTE
    ${value_3}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2]}    attenuator_device=HBTE
    ${value_4}    attenuator.read_attenuation    port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3]}    attenuator_device=HBTE
    ${PA_original_value}    create list    ${value_1}    ${value_2}    ${value_3}    ${value_4}
    set suite variable    ${PA_original_value}
    [return]    ${PA_original_value}

Set HBTE Attenuation port12 to max
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]set PA port1 and port2 value to 127  for 4X4 MIMO change to 2X2 MIMO
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${value_1}=${127}    ${value_2}=${127}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${att_port_0}    value=${value_1}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${att_port_1}    value=${value_2}    attenuator_device=HBTE
    ${value_port1}    attenuator.read_attenuation    port=${att_port_0}    attenuator_device=HBTE
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    attenuator.read_attenuation    port=${att_port_1}    attenuator_device=HBTE
    should be equal    ${value_port2}    ${value_2}

recover HBTE Attenuation value
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]recover PA value
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]    ${PA_original_value}
    attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    attenuator.set_attenuation    port=${att_port_0}    value=${PA_original_value[0]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${att_port_1}    value=${PA_original_value[1]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${att_port_2}    value=${PA_original_value[2]}    attenuator_device=HBTE
    attenuator.set_attenuation    port=${att_port_3}    value=${PA_original_value[3]}    attenuator_device=HBTE
    ${value_port1}    attenuator.read_attenuation    port=${att_port_0}    attenuator_device=HBTE
    should be equal    ${value_port1}    ${PA_original_value[0]}
    ${value_port2}    attenuator.read_attenuation    port=${att_port_1}    attenuator_device=HBTE
    should be equal    ${value_port2}    ${PA_original_value[1]}
    ${value_port3}    attenuator.read_attenuation    port=${att_port_2}    attenuator_device=HBTE
    should be equal    ${value_port3}    ${PA_original_value[2]}
    ${value_port4}    attenuator.read_attenuation    port=${att_port_3}    attenuator_device=HBTE
    should be equal    ${value_port4}    ${PA_original_value[3]}

Commission SCF With Specific Band If Needed
    [Arguments]    ${band}    ${connection}=GNB_OAM
    ${band_from_scf}    Get BandInfo From SCF
    ${status}    run keyword and return status    should be equal    ${band}    ${band_from_scf}
    return from keyword if    '${status}'=='${True}'
    ${band_info}    Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{band}
        ${band_info}=    Catenate    SEPARATOR=_    ${band_info}    ${item}
    END
    ${band_info}     Replace String    ${band_info}    0 M    0M
    ${scf_path}     Replace String    ${Golden_SCF_Path}    .xml    ${band_info}.xml
    COAM Commission with scf file    scf_file_path=${scf_path}   timeout=15min
