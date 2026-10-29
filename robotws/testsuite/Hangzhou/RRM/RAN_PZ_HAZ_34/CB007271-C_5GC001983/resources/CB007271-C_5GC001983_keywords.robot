*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           BuiltIn
Library           taf.transport.ssh      WITH NAME    csn
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library           licence_keeper.licence_keeper     WITH NAME    LK
Library           ute_reporting_portal
Library    taf.pdu       WITH NAME    pdu
*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${eNB_ip}                 ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${7432_eNB_PB_ASIK_IP}         ${tl.enbs[1].airscale.common_units[0].pdu_port.pdu.addr}
${7432_eNB_PB_ASIK_PORT}       ${tl.enbs[1].airscale.common_units[0].pdu_port.port_no}
${737_eNB_PB_ASIK_IP}         ${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
${737_eNB_PB_ASIK_PORT}       ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}
${model}    HBTE
${MR_NR_BTS_NRCELL_737}        MRBTS-10432/NRBTS-10432/NRCELL-1
${MR_NR_BTS_NRCELL1_7372}       MRBTS-10431/NRBTS-10431/NRCELL-1
${MR_NR_BTS_NRCELL2_7372}       MRBTS-10431/NRBTS-10431/NRCELL-2
${bts_host_737}                10.71.209.230
${bts_host_7372}               10.71.209.235
${gnb737_cell_dist_name}       /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
${gnb7372_cell1_dist_name}      /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1
${gnb7372_cell2_dist_name}      /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-2

*** Keywords ***
########### Commission SCF #################
Suite Setup
    Power Off pDU    model=${model}    pdu_ip=${7432_eNB_PB_ASIK_IP}    pdu_port=${7432_eNB_PB_ASIK_PORT}
    Commission GNB SCF

Power Off pDU
    [Arguments]    ${model}    ${pdu_ip}    ${pdu_port}
    Log To Console    Power Off pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power Off    port=${pdu_port}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    Sleep    15s

Power On pDU
    [Arguments]    ${model}    ${pdu_ip}    ${pdu_port}
    Log To Console    Power On pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power On    port=${pdu_port}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias

Commission GNB SCF
    [Arguments]
    Log To Console  Commission GNB SCF
    Set Default scf name    SBTS_scf_name=SCF_SBTS00_1983    Branch_scf_name=SCF_SBTS22R3_1983
    Setup Commission SCF    gNB_ip=${gNB_ip}    default_scf=${default_scf}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}    connection=GNB
    log to console    Commission GNB scf successful

Set Default scf name
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${connection}=GNB
    Log To Console  Set Default scf name
    Connect to gnb coam via ssl     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    set suite variable    ${version_list}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}${SBTS_scf_name}.xml
    ...    ${CURDIR_path}${Branch_scf_name}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    log to console   Set Default scf name successful
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]  ${gNB_ip}    ${default_scf}     ${connection}=GNB
    Log To Console  Setup Commission SCF
    Connect to gnb coam via ssl     connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check BTS Should Be Normal
    [Arguments]    ${bts_host}=${gNB_ip}     ${connection}=GNB
    log to console    Check BTS Should Be Normal
    Connect to gnb coam via ssl     connection=${connection}
    Wait Until BTS Should Be Normal    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Check BTS Cell On Air    alias=${connection}

#Gnb Cell Should Be Onair
#    [Arguments]  ${alias}=default  ${cell_type }=nr
#    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
#    ${bts_info}   coam.get_bts_info   connection=${alias}   timeout=10
#    ${cell_list}    Set Variable   ${bts_info['cells']['nr']}
#    FOR    ${cell}    IN    @{cell_list}
#        ${status}   Set Variable   ${cell['status']}
#        check cell onair    ${status}
#    END
#    log to console    Gnb Cell is Onair

#check cell onair
#    [Arguments]  ${status}
#    Should Contain   ${status['proceduralStatus']}   configured
#    Should Contain   ${status['operationalState']}   enabled
#    Should Contain   ${status['usageState']}   Active

Check BTS Cell On Air
    [Arguments]  ${connection}=GNB
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${status}            coam.get_bts_statuses       connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}

########### modify SCF #################
Modify GNB parameter_ulMimoMode_2m2
    log to console    Modify parameter_ulMimoMode_2m2
    Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_ulMimoMode_2m2}     gNB_ip=${gNB_ip}

Modify GNB parameter_actUlOpenLoopPwrCtrl_p0NominalSrs
    log to console    Modify parameter_actUlOpenLoopPwrCtrl_p0NominalSrs
    Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_actUlOpenLoopPwrCtrl_p0NominalSrs}
    ...    gNB_ip=${gNB_ip}

Recovery GNB parameter_actUlOpenLoopPwrCtrl_p0NominalSrs
    log to console    Recovery parameter_actUlOpenLoopPwrCtrl_p0NominalSrs
    Modify Common parameter via Coam      input_list=${GNB_RECOVERY_Parameter_actUlOpenLoopPwrCtrl_p0NominalSrs}
    ...    gNB_ip=${gNB_ip}

Modify GNB Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl
    log to console    Modify parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl
    Modify Common parameter via Coam      input_list=${GNB_MODIFY_Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl}
    ...    gNB_ip=${gNB_ip}

Recovery GNB Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl
    log to console    Recovery parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl
    Modify Common parameter via Coam      input_list=${GNB_RECOVERY_Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl}
    ...    gNB_ip=${gNB_ip}

Modify Common parameter via Coam
    [Arguments]  ${input_list}  ${gNB_ip}  ${connection}=GNB
    FOR    ${item}    IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        Wait Until Keyword Succeeds   10min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}
        ...    connection=${connection}
        Connect to gnb coam via ssl     connection=${connection}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]
        ...    value=${dict_value}[2]    operation=update    skip_parameter_relation_errors=${True}
        ...    should_activate=${True}    connection=${connection}
        sleep    2min
    END
    Wait Until Keyword Succeeds   10min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}
    ...    connection=${connection}
    log to console  change parameter successful

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

################ case keywords ############################
COAM get alarm
    [Arguments]    ${connection}=GNB
    Connect to gnb coam via ssl     connection=${connection}
    sleep    1min
    Log To Console    begin to get alarm...
    ${output_alarms}    coam_gnb_classical.COAM Get active alarms    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{output_alarms}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]   ${faultid_list}

Save Snapshot Log
    [Arguments]    ${connection}=GNB    ${timeout}=600s
    Log To Console    Save Snapshot Log
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${OUTPUT DIR}/snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${connection}    timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error   coam.Teardown  connection=${connection}

##############  Teardown  #############
Commmon Case Teardown
    CI_interface.Common Case Teardown

Commmon Case002 Teardown
    Recovery GNB parameter_actUlOpenLoopPwrCtrl_p0NominalSrs
    CI_interface.Common Case Teardown

Commmon Case004 Teardown
    Recovery GNB Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl
    CI_interface.Common Case Teardown

Suite Teardown
    run keyword and continue on failure    Save Snapshot Log
