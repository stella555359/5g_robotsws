*** Settings ***
Documentation     author: Chen Kaijia
...               contact: kaijia.chen@nokia-sbell.com
...               squad group: MMW_SG_04

#Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
#Resource          taf/rfrl/common_resources/robot/coam.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           ../Resources/check_tem.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Rus_Txpower_check.robot

*** Variables ***
${ROOT_USERNAME}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ROOT_USERNAME1}       ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ROOT_PASSWORD1}       ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${DU_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${LMP_IP}              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${scf_path}          ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/

*** Keywords ***
Input default SCF
    [Timeout]  20 min
    [Arguments]      ${timeout}=10 min
    ${connection}    CB007308-5G-AB_common_keywords.Connect to DU
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R4
    ${default_scf}    set variable if    ${if_common_load}   ${scf_path}SCF_SBTS22R4_7841.xml
    ...    ${scf_path}SCF_Trunk_7841.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
    [Teardown]     CB007308-5G-AB_common_keywords.Disconnect from DU

Check BTS is in On Air
    CB007308-5G-AB_common_keywords.Connect to DU
    ADMIN Wait Until BTS OnAir
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU

Check BTS startup
    CB007308-5G-AB_common_keywords.Connect to DU
    Admin Reset BTS
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU

BTS detects cooled SFP+/SFP28
    CB007308-5G-AB_common_keywords.Connect to DU
    ADMIN Wait Until BTS OnAir
    ${ii}    Get RF2 Runtime number
    CB007308-5G-AB_common_keywords.Connect to DU
    Check if static data SFP for fronthaul    ii=${ii}
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU

BTS detects cold SFP+/SFP28 startup and compare the temperature
    CB007308-5G-AB_common_keywords.Connect to DU
    ADMIN Wait Until BTS OnAir
    Compare the temperature for FH and BH SFP
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU

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
    [Arguments]    ${ii}
    ${Cooled_Transceiver}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${ii}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${Cooled_Transceiver1}    Get SCF single Value from current xml file
    ...   parameter=cooledTransceiverDeclaration   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    run keyword if    '${Cooled_Transceiver}'=='true' and '${Cooled_Transceiver1}'=='true'    log to console    PASS    ELSE    Fail

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
    [Arguments]    ${parameter}    ${i}    ${ii}
    ${TEM1}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${ii}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM2}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM3}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    [Return]    ${TEM1}    ${TEM2}    ${TEM3}


Check RF2 SFP Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==37 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value_RF2}=                get_temperature_value
    [Return]    ${temperature_value_RF2}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

Check EIF1 SFP Module temperature
    ssh connect to DU
    ssh.send command                    command=awk 'NR==99 {print $3}' /tmp/sfp.csv > temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ssh.download_file                   remote_path=/user/toor4nsn/temperature.csv
    ...                                 local_path=./temperature.csv
    ...                                 connection=cOAM_toor4nsn
    ${temperature_value_EIF1}=                get_temperature_value
    [Return]    ${temperature_value_EIF1}
    [Teardown]  ssh.disconnect          connection=cOAM_toor4nsn

Compare the temperature for FH and BH SFP
    ${i}    Get EIF1 Runtime number
    ${ii}    Get RF2 Runtime number
    CB007308-5G-AB_common_keywords.Connect to DU
    ${TEMHIGH_RF2}    ${TEMHIGH_EIF1}    ${TEMHIGH_RMOD_opt1}    Check SFP temperature
    ...    parameter=temperatureHighAlarmThreshold    i=${i}    ii=${ii}
    ${TEMLOW_RF2}    ${TEMLOW_EIF1}    ${TEMLOW_RMOD_opt1}    Check SFP temperature
    ...    parameter=temperatureLowAlarmThreshold    i=${i}    ii=${ii}
    ${temperature_value_RF2}    Check RF2 SFP Module temperature
    ${temperature_value_EIF1}    Check EIF1 SFP Module temperature
    ${RMOD_SFP_TEMP_value}    Get temperature for RMOD SFP
    Should Be True    ${TEMLOW_RF2}<=${temperature_value_RF2}<=${TEMHIGH_RF2}
    ...               ${TEMLOW_EIF1}<=${temperature_value_EIF1}<=${TEMHIGH_EIF1}
    Should Be True    ${TEMLOW_RMOD_opt1}<=${RMOD_SFP_TEMP_value}<=${TEMHIGH_RMOD_opt1}

Get temperature for RMOD SFP
    ${connection}    CB007308-5G-AB_common_keywords.Connect to DU    alias=gnb
    ${RMOD_SFP_TEMP}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1
    ...                 pattern=modTemp    connection=${connection}
    ${RMOD_SFP_TEMP_value}    get from dictionary    ${RMOD_SFP_TEMP}    modTemp
    [Return]    ${RMOD_SFP_TEMP_value}
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU    alias=${connection}

ssh connect to DU
    [Arguments]  ${ip_address}=${LMP_IP}  ${alias}=cOAM_toor4nsn  ${password}=${ROOT_PASSWORD1}
    ${connection}=  ssh.Connect to  ${ip_address}
    ...                             ${ROOT_USERNAME1}
    ...                             ${password}
    ...                             alias=${alias}
    [Return]  ${connection}

Get EIF1 Runtime number
    ${connection}    CB007308-5G-AB_common_keywords.Connect to DU    alias=gnb
    FOR     ${i}    IN RANGE    ${1}    ${50}
        ${SFP_status}    run keyword and return status    coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...              connection=${connection}
        ${SFP_status}    run keyword if     ${SFP_status}
        ...   coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...     connection=${connection}     ELSE    Continue For Loop
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU    alias=${connection}

Get RF2 Runtime number
    ${connection}    CB007308-5G-AB_common_keywords.Connect to DU    alias=gnb
    FOR     ${i}    IN RANGE    ${1}    ${50}
        ${SFP_status}    run keyword and return status    coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
       ...       connection=${connection}
       ${SFP_status}    run keyword if      ${SFP_status}
       ...   coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
       ...       connection=${connection}      ELSE      Continue For Loop
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_RF2}     run keyword and return status    should be equal     ${label}   RF2
        Exit For Loop If    '${if_RF2}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    CB007308-5G-AB_common_keywords.Disconnect from DU    alias=${connection}


