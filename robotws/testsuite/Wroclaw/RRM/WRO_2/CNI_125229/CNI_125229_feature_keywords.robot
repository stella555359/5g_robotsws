*** Settings ***
Documentation    Keywords for the CNI-125229

Library     Process
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME    ru_operation
Library     ta5g_egate
Library     ta5g_cell_operations
Resource    ../keywords/messaging.robot
Resource    ../keywords/L3_Call.robot
Resource    ../keywords/traffic.robot


*** Variables ***
${ARTIFACTORY_LOCATION}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/list/mnpute-rotta-local/zapatyla
${BSR_FILENAME}=            BSR_AQQL_6_H6_ALN60_ARP60_P12_COVERAGE_00808_00002.zip
${BSR_FILEPATH}=            ${ARTIFACTORY_LOCATION}/${BSR_FILENAME}
${ARTI_USER}=               zapatyla
${ARTI_PASS}=               cmVmdGtuOjAxOjE3OTQxMzUwMjc6U2R3R3duaUVPWmhRRlJpQnJvTWhZZkF3aG9Y
${BSR_TARGET_FILEPATH}=     ${CURDIR}/config

${WTS_DIR}=    /opt/iphy/latest

@{eth3_ips}=    61    62    63    64    131    132    133    134    135    136    137    138    139
@{eth4_ips}=    3    4    5    6    7    8    9    10    11    12    13

@{cell_list}=    1    2    3    4    5    6    7    8    9    10    11    12


*** Keywords ***
Configure Eth3 And Eth4 Interfaces
    Configure Interfaces    eth=eth3    ips_range=${eth3_ips}
    Configure Interfaces    eth=eth4    ips_range=${eth4_ips}

Configure Interfaces
    [Arguments]    ${eth}    ${ips_range}
    FOR    ${ip}    IN    @{ips_range}
        Run    sudo ip addr add 10.0.1.${ip}/24 dev ${eth}
    END

Install Bsr Package
    [Arguments]    ${user}=${ARTI_USER}    ${password}=${ARTI_PASS}    ${target_path}=${BSR_TARGET_FILEPATH}
    ...            ${bsr_path}=${BSR_FILEPATH}    ${bsr_file}=${BSR_FILENAME}
    Run Process    wget --user ${user} --password ${password} -P ${target_path} ${bsr_path}    shell=yes
    coam.Setup Admin
    ${ret}=    coam.Update Software    sw_package=${target_path}/${bsr_file}
    [Teardown]    Run Keywords    coam.Teardown Admin    AND
    ...           Remove File    path=${target_path}/${bsr_file}

Wait For Gnb Environment Stabilization
    ru_operation.Wait For All Radio Units To Be Online
    Wait For All Cells To Be Configured

Configure Wts Environment
    [Arguments]    ${lua_cfg}    ${cell_list}=${cell_list}
    Stop Edaemon And Egate Processes
    Log To Console    Starting WTS...
    Setup Edaemon And Egate
    Wait For Wts Is Ready To Use    lua_cfg=${lua_cfg}    cell_list=${cell_list}
    Setup X2 Connection

Stop Edaemon And Egate Processes
    ${pid}=    Run    pgrep edaemon
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}
    ${pid}=    Run    pgrep egate
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}

Wait For Wts Is Ready To Use
    [Arguments]    ${lua_cfg}    ${cell_list}
    Execute Egate Command And Wait For Data    cfg_sim file\=${lua_cfg} entry\=run_configuration()
    ...                                        pass_regexp=(SimMode is ready now|UEC-1 is active)
    ...                                        timeout=300
    Wait For Sib1 Reception    timeout=600    cell_list=${cell_list}
    Wait Until Keyword Succeeds    120sec    15sec
    ...                            Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Setup Edaemon And Egate
    Setup Edaemon    edaemon_port=10000    tool_dir=${WTS_DIR}    alias=edaemon_dl
    Start Edaemon Process    alias=edaemon_dl
    Setup Edaemon    edaemon_port=30000    tool_dir=${WTS_DIR}    alias=edaemon_ul
    Start Edaemon Process    alias=edaemon_ul
    Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process

Setup X2 Connection
    ${pattern}=    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    ${output}=    Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...           pass_regexp=${pattern}    timeout=60
    ${output}=    Get Lines Matching Regexp    string=${output}    pattern=${pattern}    partial_match=${True}
    Log To Console    \n${output}
    Log    x2_is_ok

Attach Multiple Ues To The Different Cells And Start Data Traffic
    [Arguments]    ${ue_ids}    ${pdu_ids}    ${gw_ids}    ${cell_ids}    ${inactive_timer}
    ...            ${gnb_id}=2    ${gnb_ip}=10.0.1.2    ${dl_mbps}=100    ${ul_mbps}=50
    ${ues_number}=    Get Length    ${ue_ids}
    Create Gnb Device With Alias 'gNB${gnb_id}' Identified By ip=${gnb_ip}
    Enable Internal Mirroring For Alias    gNB${gnb_id}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Create Ue Alias    alias=UE${ue_ids}[${ue_index}]    ue_id=${ue_ids}[${ue_index}]    id_type=wts_5g
        Expect Ue Attach Messages Flow     ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Expect Pdu Messages Flow    ue_id=${ue_ids}[${ue_index}]    gNB_id=${gnb_id}
        Sleep    3    # waiting for messages capturing to be stabilized
        Attach Ue And Establish Pdu Session    ue_id=${ue_ids}[${ue_index}]    cell_id=${cell_ids}[${ue_index}]    enb_id=${gnb_id}
        ...                                    pdu_id=${pdu_ids}[${ue_index}]    gw_id=${gw_ids}[${ue_index}]
        Check If Ue Attach Messages Flow Occurred    ue_id=${ue_ids}[${ue_index}]
        Check If Pdu Messages Flow Occurred    ue_id=${ue_ids}[${ue_index}]
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}] trf_id=1 dir=dl mbps=${dl_mbps}
        Execute Egate Command    cmd=trf_data_start ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}] trf_id=2 dir=ul mbps=${ul_mbps}
        Wait For Traffic To Stabilize    inactive_timer=${inactive_timer}
        Execute Egate Command    cmd=ue_stats_nr id=${ue_ids}[${ue_index}]
    END

Stop Data Traffic And Release Multiple Ues
    [Arguments]    ${ue_ids}    ${pdu_ids}
    ${ues_number}=    Get Length    ${ue_ids}
    FOR    ${ue_index}    IN RANGE    ${ues_number}
        Execute Egate Command    cmd=trf_data_stop ue=${ue_ids}[${ue_index}] pdu=${pdu_ids}[${ue_index}]
        Release Ue    ue_id=${ue_ids}[${ue_index}]   pdu_id=${pdu_ids}[${ue_index}]
    END

Release Ue
    [Arguments]    ${ue_id}    ${pdu_id}
    Release Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister Ue    ue_id=${ue_id}
