*** Settings ***
Documentation     author: Zhang Jin
...               contact: jin.2.zhang@nokia-sbell.com
...               squad group: SG_05



Library        AdminCliUtils.py
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn
Library        Collections
Library        XML
#Library        taf.sbts.oam.coam.admin
#Library        taf.sbts.oam.coam.admin   WITH NAME   sbts
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


*** Variables ***
#${mrbts_value}=                         ${tl.gnbs[0].dus[0].instance_id}
${sfp_connector}=                       ${tl.gnbs[0].dus[0].cablinks[0].source.label}
${qsfp_connector}=                      ${tl.gnbs[0].dus[0].cablinks[1].source.label}

${mrbts_value}=                         ${tl.gnbs[0].instance_id}
#${sfp_connector}=                       ${tl.gnbs[0].cablinks[0].source.label}
#${qsfp_connector}=                      ${tl.gnbs[0].cablinks[1].source.label}

${r_id}=                                1
${GN_OAM_ADDR}=                    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_OAM_PWD}=                    ${tl.gnbs[0].cu.oam_http_connection_details.password}


${delta_activate_actCli}=               ${CURDIR}/Delta_Activate_ActCli.json
${delta_deactivate_actCli}=             ${CURDIR}/Delta_Deactivate_ActCli.json
${delta_delete_lane}=                   ${CURDIR}/Delta_Lane_object_delete.json
${delta_create_lane}=                   ${CURDIR}/Delta_SFP_object_create.json

${ADMIN_CLI_scripts_path}=              ${CURDIR}/scripts

${SW_DESTINATION}                       /home/ute


*** Keywords ***

Prepare environment
    Download Admin Cli


Teardown environment

    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature

Teardown environment for CB006147_1

    Delete SFP Lane
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature



ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ...            ${connection}="default"
    coam.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=${connection}

Delete SFP Lane

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}    password=${GN_OAM_PWD}   alias="default2"
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default2"

    ADMIN Perform Delta Recommissioning                 ${delta_delete_lane}
    ...                                                 skip_parameter_relation_errors=True
    ...                                                 connection="default2"


#    coam.Teardown Admin    alias="default2"
    Run Keyword And Ignore Error     coam.teardown    connection="default2"


Create SFP Lane

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}    password=${GN_OAM_PWD}   alias="default2"

    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default2"
    ADMIN Perform Delta Recommissioning       ${delta_create_lane}
    ...                                                 skip_parameter_relation_errors=True
    ...                                                 connection="default2"

#    coam.Teardown Admin    alias="default2"
    Run Keyword And Ignore Error     coam.teardown    connection="default2"


Activate CLI feature

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}    password=${GN_OAM_PWD}   alias="default2"

    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default2"
    ADMIN Perform Delta Recommissioning                 ${delta_activate_actCli}
    ...                                                 skip_parameter_relation_errors=True
    ...                                                 connection="default2"

#    coam.Teardown Admin    alias="default2"
    Run Keyword And Ignore Error     coam.teardown    connection="default2"


Deactivate CLI feature

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}    password=${GN_OAM_PWD}   alias="default2"
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default2"
    ADMIN Perform Delta Recommissioning                 ${delta_deactivate_actCli}
    ...                                                 skip_parameter_relation_errors=True
    ...                                                 connection="default2"

#    coam.Teardown Admin    alias="default2"
    Run Keyword And Ignore Error     coam.teardown    connection="default2"

Download Admin Cli
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}
#    coam.connect to     bts_host=${GN_OAM_ADDR}
    ${swversion}=       coam.get_sw_version    connection=GNB_OAM
    Run Keyword if      '_9999_' in '${swversion}'          AdminCliUtils.get_file_for_Trunk_Load
    ...   ${swversion}
    Run Keyword if      '_0000_' in '${swversion}'          AdminCliUtils.get_file_for_21B_Load
    ...   ${swversion}
    Run Keyword if       '5G21A' in '${swversion}'          AdminCliUtils.get_file_for_21A_Load
    ...   ${swversion}
    Run Keyword if       '5G20B' in '${swversion}'          AdminCliUtils.get_file_for_20B_Load
    ...   ${swversion}
    AdminCliUtils.unzip_file
    OperatingSystem.Directory Should Not Be Empty     /home/ute/ADMIN_CLI
    Run Keyword And Ignore Error     coam.teardown



Transfer ADMIN_CLI scripts
    log  ${ADMIN_CLI_scripts_path}
    log  ${SW_DESTINATION}
    Run  cp ${ADMIN_CLI_scripts_path}/* ${SW_DESTINATION}/ADMIN_CLI/
    Run  sudo chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*
    Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/node/linux/bin/node




Start Agent CLI is successfully
    Transfer ADMIN_CLI scripts

    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature


    ${result}=  Start Process  ${SW_DESTINATION}/ADMIN_CLI/start_cli.sh    ${GN_OAM_ADDR}    ${GN_OAM_PWD}   shell=yes

    #Should Be Equal As Integers     ${result.rc}    0

    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature



SFP data management
    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature
    ${result}=  Run Process  ${SW_DESTINATION}/ADMIN_CLI/sfp_management.sh    shell=yes
    #${result}=  Start Process  ${SW_DESTINATION}/ADMIN_CLI/sfp_management.sh    shell=yes
    log    stdout
    log    ${result.stdout}
    log    stderr
    log    ${result.stderr}
    Should Be Equal As Integers     ${result.rc}    0
    Should contain  ${result.stdout}   "errorCode": 0
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature    
    Terminate All Processes


Lock LANE by CLI is performed successfully
    Transfer ADMIN_CLI scripts
    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature
    ${result}=  Run Process  ${SW_DESTINATION}/ADMIN_CLI/lockLane_successfully.sh
                ...   ${mrbts_value}    ${GN_OAM_ADDR}    ${GN_OAM_PWD}    shell=yes
    log    stdout
    log    ${result.stdout}
    log    stderr
    log    ${result.stderr}
    Should Be Equal As Integers 	${result.rc} 	0
    Should contain  ${result.stdout}   "errorCode": 0
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature

    ${new_value}=    gNB Get Attribute value in SCF
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    log    ${new_value}
    Should Be Equal As Strings    ${new_value}    Locked




Unlock LANE by CLI is performed successfully
    Wait Until Keyword Succeeds     120 sec     20 sec    Activate CLI feature
    ${result}=  Run Process  ${SW_DESTINATION}/ADMIN_CLI/unlockLane_successfully.sh
                ...   ${mrbts_value}    ${GN_OAM_ADDR}    ${GN_OAM_PWD}     shell=yes
    log    ${result.stdout}
    Should Be Equal As Integers 	${result.rc} 	0
    Should contain  ${result.stdout}   "errorCode": 0
    Wait Until Keyword Succeeds     120 sec     20 sec    Deactivate CLI feature

    ${new_value}=    gNB Get Attribute value in SCF
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    Should Be Equal As Strings    ${new_value}    Unlocked


gNB Get Attribute value in SCF
    [Documentation]     Get element value in SCF content
    [Arguments]         ${dist_name}    ${p_name}
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection=GNB_oam
    ${content}=        coam.get_current_scf_content    connection=GNB_oam
    coam.teardown    connection=GNB_oam

    ${xml_root}=        XML.Parse XML    ${content}
    ${result}=          XML.Get Element    ${xml_root}
    ...                 .//managedObject[@distName="${dist_name}"]/p[@name="${p_name}"]
    [Return]            ${result.text}

gNB Set Attribute Value
    [Documentation]     Set gNB Param Value using webUI
    [Arguments]         ${dist_name}    ${p_name}    ${new_value}
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection=cOAM_admin
    Log                 logged in webUI. begin modif of ${dist_name} ${p_name} to ${new_value}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${p_name}    operation=update
    ...                                       value=${new_value}    skip_parameter_relation_errors=True    connection=cOAM_admin
    [Teardown]          coam.teardown    connection=cOAM_admin


Lane lock and unlock in Detailed Site View
    [Arguments]   ${connector_name}
    gNB Set Attribute Value
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    ...    Locked
    ${new_value}=    gNB Get Attribute value in SCF
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    log    ${new_value}
    Should Be Equal As Strings    ${new_value}    Locked
    sleep    60s
    gNB Set Attribute Value
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    ...    Unlocked
    ${new_value}=    gNB Get Attribute value in SCF
    ...    MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
    ...    administrativeState
    Should Be Equal As Strings    ${new_value}    Unlocked
    log    ${new_value}
    sleep    120s
    ADMIN Wait Until BTS OnAir


ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}   password=${GN_OAM_PWD}   alias="default"
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default"
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check BTS onair

#    coam.Teardown Admin    alias="default"
    Run Keyword And Ignore Error     coam.teardown    connection="default"

ADMIN Check BTS onair
    [Arguments]
    ${dict_info}=    coam.Get Bts Info    connection="default"
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir


ADMIN Get and Check Parameter
    [Arguments]    ${dist_name}
    ...            ${dict_param}
    ...            ${value}
    ...            ${timeout}=10
    ...            ${connection}="default"

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}   password=${GN_OAM_PWD}   alias=${connection}

    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection=${connection}
    ${out_parameters}    coam.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${dict_param}
    ...    timeout=${timeout}
    ...    connection=${connection}

    ${dict_value}    Get From Dictionary
    ...    dictionary=${out_parameters}
    ...    key=${dict_param}

    ${dict_value}    Convert To String    ${dict_value}
    Should Match Regexp
    ...    string=${dict_value}
    ...    pattern=${value}

#    coam.Teardown Admin    alias=${connection}
    Run Keyword And Ignore Error     coam.teardown    connection=${connection}


ADMIN Get and Check Parameter not exist
    [Arguments]    ${dist_name}
    ...            ${dict_param}
    ...            ${timeout}=10
    ...            ${connection}="default"

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}   password=${GN_OAM_PWD}   alias=${connection}

    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection=${connection}
    ${out_parameters}    coam.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${dict_param}
    ...    timeout=${timeout}
    ...    connection=${connection}

    should be empty     ${out_parameters}
#    coam.Teardown Admin    alias=${connection}
    Run Keyword And Ignore Error     coam.teardown    connection=${connection}


ADMIN Get and Check Parameter transmission rate
    [Arguments]    ${dist_name}
    ...            ${dict_param}
    ...            ${timeout}=10
    ...            ${connection}="default"

#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}   password=${GN_OAM_PWD}   alias=${connection}
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection=${connection}
    ${out_parameters}    coam.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=${dict_param}
    ...    timeout=${timeout}
    ...    connection=${connection}

    ${dict_value}    Get From Dictionary
    ...    dictionary=${out_parameters}
    ...    key=${dict_param}

#    ${list_a}   create list     10300   25750
#    should contain    ${list_a}    ${dict_value}
    ${result_1}    Run keyword and return status     should be true    ${dict_value}>=10250 and ${dict_value}<=10350
    ${result_2}    Run keyword and return status     should be true    ${dict_value}>=25700 and ${dict_value}<=25800
    should be true     ${result_1} or ${result_2}
    
#    coam.Teardown Admin    alias=${connection}
    Run Keyword And Ignore Error     coam.teardown    connection=${connection}



SFP info Should not include Max transmission rate and Transmission distance
#    coam.Setup Admin    bts_host=${GN_OAM_ADDR}   password=${GN_OAM_PWD}   alias="default2"
    Connect to gnb coam via ssl    bts_host=${GN_OAM_ADDR}    connection="default2"

    FOR     ${i}    IN RANGE    ${1}    ${16}
        ${SFP_status}    coam.get_parameters
        ...          dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}
        ...              connection="default2"
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_RF1}     run keyword and return status    should be equal     ${label}   RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
    END

     FOR     ${a}    IN RANGE    ${1}    ${i}+1
         ADMIN Get and Check Parameter transmission rate
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${a}
         ...                         dict_param=transmissionRate
         ADMIN Get and Check Parameter not exist
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${a}
         ...                         dict_param=transmissionDistance
         ADMIN Get and Check Parameter not exist
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${a}
         ...                         dict_param=maxTransmissionRate
     END

    FOR     ${b}    IN RANGE    ${1}    ${16}
        ${SFP_status}    coam.get_parameters
        ...          dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-${b}
        ...              connection="default2"
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   OPT_IF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END

    FOR     ${c}    IN RANGE    ${1}    ${b}+1
         ADMIN Get and Check Parameter transmission rate
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-${c}
         ...                         dict_param=transmissionRate
         ADMIN Get and Check Parameter not exist
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-${c}
         ...                         dict_param=transmissionDistance
         ADMIN Get and Check Parameter not exist
         ...  dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-${c}
         ...                         dict_param=maxTransmissionRate
     END


#    coam.Teardown Admin    alias="default2"
    Run Keyword And Ignore Error     coam.teardown    connection="default2"








#=====Selenium WebEM Keywords=====#

#Update Selenium Library
#    ${rc}=  Run And Return RC   pip install --upgrade robotframework-seleniumlibrary==3.2.0
#    Should Be Equal As Integers     ${rc}   0
