*** Settings ***
Documentation     author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

#Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
#Resource          taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           ../Resources/check_tem.py

*** Variables ***
${ROOT_USERNAME}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${DU_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${LMP_IP}=             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${alias}
    ${conn}    set variable    ${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Admin Reset BTS
    [Arguments]    ${alias}=cOAM_admin
    coam.Reset Site    connection=${alias}


Check if static data SFP for fronthaul
    ${Cooled_Transceiver}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${Cooled_Transceiver1}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    run keyword if    '${Cooled_Transceiver}'=='true' or '${Cooled_Transceiver1}'=='true'    log to console    PASS    ELSE    Fail

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

#CB006942-D
Check SFP temperature
    [Arguments]    ${parameter}
    ${TEM1}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM2}    Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    [Return]    ${TEM1}    ${TEM2}


Check SFPS Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==37 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value}=                get_temperature_value
    [Return]    ${temperature_value}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

compare the temperature for SFP
    ${TEM1}    ${TEM2}    Check SFP temperature   parameter=temperatureHighAlarmThreshold
    ${TEMHIGH}    set variable if    '${TEM1}'=='[]'    ${TEM2}    ${TEM1}
    ${TEM1}    ${TEM2}    Check SFP temperature    parameter=temperatureLowAlarmThreshold
    ${TEMLOW}    set variable if    '${TEM1}'=='[]'    ${TEM2}    ${TEM1}
    ${temperature_value}    Check SFPS Module temperature
    Should Be True    ${TEMLOW}<=${temperature_value}<=${TEMHIGH}

ssh connect to DU
    [Arguments]  ${ip_address}=${LMP_IP}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}