*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04
Library           ute_admin
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.hw.rf_attenuator    WITH NAME    att
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot


*** Variables ***
${MRBTS_ID}                      ${tl.gnbs[0].instance_id}
${WEBUI_URL}                     https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${DU_IP}                         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBEM_USERNAME}                ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}                ${tl.gnbs[0].cu.oam_http_connection_details.password}
${GNSS_Constellation_mode}       /MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
${scf_path}                    ${CURDIR}/../../../../commissionings/HGZ/${testline_name}/
${vendor}                        HBTE
${max_attenuation_value}         127
${att_ipaddr}                    ${tl.attenuator.ip_addr}
${att_connection_port}           ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}                  ${tl.attenuator.port}
${att_port_5}                    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}                    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7}                    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}                    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}


*** Keywords ***
perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update    ${connection}=cOAM_admin
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

Input default SCF
    [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS
    ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_SBTS00.xml
    ...    ${scf_path}SCF_0_800_DU.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    Disconnect from DU

COAM Commission with scf file ignore error
    [Documentation]  Author: Liu Steven
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

getParas and check
    [Arguments]    ${GNSSE_actual}    ${GNSSvalue}    ${alias}=cOAM_admin
    Connect to DU
    Log To Console      \n start get trig_stat
    ${get_managed_objects}     coam.get_managed_objects     class_name=GNSSE_R    connection=${alias}
    ${param}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${qciTab7}    get from dictionary     ${param}    ${GNSSE_actual}
    ${GNSSvalueint}    Convert To Integer    ${GNSSvalue}
    should be equal    ${qciTab7}    ${GNSSvalueint}
    [Teardown]    Disconnect from DU

getPara and check
    [Arguments]    ${GNSSE_actual}    ${GNSSvalue}    ${alias}=cOAM_admin
    Connect to DU
    Log To Console      \n start get trig_stat
    ${get_managed_objects}     coam.get_managed_objects     class_name=GNSSE_R    connection=${alias}
    ${param}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${qciTab7}    get from dictionary     ${param}    ${GNSSE_actual}
    should be equal    ${qciTab7}    ${GNSSvalue}
    [Teardown]    Disconnect from DU

Login Page Via WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=40s    ${retry_interval}=5s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]   ${alias}=default  ${cell_type}=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${operationalState}    Enabled
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal    ${tmp}    Enabled
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
    Should Be Equal    ${tmp}    Online
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal    ${tmp}    Unlocked
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal    ${tmp}    Unblocked
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal    ${tmp}    Active

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}        ${att_port1}=${att_port_7}
    ...    ${att_port2}=${att_port_8}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

Collect snapshot coam
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/snapshot_${date}.zip
    ...        coverage=Full
    ...        force=True
    ...        timeout=720
    ...        connection=cOAM_admin
    [Return]    ${snapshot_path}/snapshot_${date}.zip

DU GNSS Reset
    log to console      DU GNSS Reset
    selenium_coam.enable_virtual_display
    selenium_coam.login               url=https://${DU_IP}
    ...                    username=${WEBEM_USERNAME}
    ...                    password=${WEBEM_PASSWORD}
    selenium_coam.disable_screen_lock
    selenium_coam.reset_gnss
    [Teardown]          selenium_coam.logout

Check If Cell Is OnAir
    LOG TO CONSOLE    \n####### Chceck If Cell Is OnAir #######
    coam.connect_to    bts_host=${DU_IP}
    WAIT UNTIL KEYWORD SUCCEEDS    2 min    0 sec    Check Cell State
    [Teardown]    coam.teardown_admin

Check Cell State
    ${results}    coam.get_cells_info
    SHOULD BE TRUE    '${results[0]['status']['availabilityStatus']}' == 'Online'    msg=Cell is not Online

get satellite number
     [Arguments]    ${alias}=cOAM_admin
     ${bts_hw_info}=    coam.Get Bts Info    connection=${alias}
     ${gnsse}    Collections.Get From Dictionary    ${bts_hw_info}    gnsse
     ${satellite}    Collections.Get From Dictionary    ${gnsse}[0]    satelliteInformation
     ${len} =    Get Length    ${satellite}
     [Return]  ${len}
