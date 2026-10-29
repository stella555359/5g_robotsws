*** Settings ***
Documentation
...          author:
...          contact:
...          description:
Library      BuiltIn
Library      Collections
Library      String
Library      OperatingSystem
Library      taf.transport.ssh         WITH NAME    ssh
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Library      ${CURDIR}/../SRAN/resources/python/QTListener.py
Library      ${CURDIR}/../SRAN/resources/python/common.py
Suite Setup        NSA ENB Setup
Suite Teardown     NSA ENB Teardown

*** Test Cases ***
Install eNB package
    [Tags]     enbUpgrade    enbUP
    Install eNB package on cOAM    bts_host=${enb_host}
    Wait Until Keyword Succeeds    5min  1min    Check active eNB SW version on cOAM    bts_host=${enb_host}
    [Teardown]    Run Keywords    ssh.reset_cache
    ...           AND             coam.teardown    connection=coam_admin

Verify eNB setup
    [Tags]     enbUpgrade    enbOnair
    ${online}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    1min  30s    coam.connect to
    ...                            bts_host=${enb_host}    update_interval=1000  name=coam_admin
    IF    ${online}
        ${online}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    10min  1min    Verify BTS Setup
    END
    Set Suite Variable    ${online}
    Run Keyword If    not ${online}     Fail    enb cell setup failed!!!!
    [Teardown]    coam.teardown    connection=coam_admin

Perform eNB Recommissioning via OAM webUI
    [Tags]     enbUpgrade    enbReCommission
    [Setup]    Requires TC    Verify eNB setup
    Wait Until Keyword Succeeds    1min  30s    coam.connect_to    bts_host=${enb_host}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    Save SCF For Classical
    ${scf_path}    Set Variable    ${OUTPUT_DIR}/scf_from_webui_${tl.tl_cloud_topology}_ENB.xml
    Log To Console    \n --> INFO: path to SCF: ${scf_path}
    ${scf_validation_result}    coam.validate_scf    ${scf_path}    connection=coam_admin
    Log to console    \n --> Validation status: ${scf_validation_result['niddValidationResult']['status']}
    Log To Console    \n --> Activating SCF ... ...
    coam.perform_commissioning     scf_file=${scf_path}    skip_parameter_relation_errors=False
    ...                            timeout=660    connection=coam_admin
    [Teardown]    coam.teardown    connection=coam_admin

Perform eNB commissioning via OAM webUI using default SCF file
    [Tags]     enbCommission
    [Setup]    Requires TC    Verify eNB setup
    Wait Until Keyword Succeeds    1min  30s    coam.connect_to    bts_host=${enb_host}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    Set eNB SCF Directory
    ${enb_tl}           Get Variable Value       ${tl.enbs[0].system_module.common_units[0].tl_enb}
    ${tl_cloud_name}    Convert To Upper Case    ${tl.tl_cloud_topology}
    ${scf_path}    Set Variable    ${eNB_scf_dir}/Configuration_scf_${enb_tl}.xml
    Log To Console    \n --> INFO: path to SCF: ${scf_path}
    ${scf_validation_result}    coam.validate_scf    ${scf_path}    connection=coam_admin
    Log to console    \n --> Validation status: ${scf_validation_result['niddValidationResult']['status']}
    Log To Console    \n --> Activating SCF ... ...
    coam.perform_commissioning     scf_file=${scf_path}    skip_parameter_relation_errors=False
    ...                            timeout=660    connection=coam_admin
    [Teardown]    coam.teardown    connection=coam_admin

Verify eNB Cell setup
    [Tags]     enbUpgrade    enbOnair
    [Setup]    Requires TC    Verify eNB setup
    Wait Until Keyword Succeeds    1min  30s    coam.connect to
    ...                            bts_host=${enb_host}    update_interval=1000  name=coam_admin
    ${online}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    3min  1min    Verify COAM 4G Cell Setup
    Set Suite Variable    ${online}
    Run Keyword If    not ${online}     Fail    enb cell setup failed!!!!
    [Teardown]    coam.teardown    connection=coam_admin

*** Keywords ***

Install eNB package on cOAM
    [Arguments]        ${bts_host}=${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    Log To Console    \n --> Performing eNB SW upgrade ... ...
    coam.connect to   bts_host=${bts_host}    update_interval=1000
	...		name=coam_admin
    coam.update_software    sw_package=${AF_PATH}    timeout=2400    connection=coam_admin
    Log To Console    \n --> Activating new eNB SW ... ...
    BuiltIn.Sleep              2min

Verify BTS Setup
    [Arguments]            ${connection}=coam_admin
    ${bts_info}            coam.get_bts_statuses    timeout=30    connection=${connection}
    Log Many               ${bts_info}
    Dictionary Should Contain Item    ${bts_info}    operationalState    Enabled
    ${proceduralState}            Get From Dictionary    ${bts_info}    proceduralState
    @{allowedProceduralStates}    Create List    OnAir
    List Should Contain Value     ${allowedProceduralStates}    ${proceduralState}

Verify COAM 4G Cell Setup
    ${cell_info}           coam.get_cells_info    cell_type=lte    timeout=30    connection=coam_admin
    Log Many               ${cell_info}
    Should Not Be Empty    ${cell_info}
    ${index}               Set Variable    ${1}
    FOR    ${elem}   IN    @{cell_info}
        Should contain     ${elem['status']['operationalState']}      Enabled       ignore_case=True
        Should contain     ${elem['status']['administrativeState']}   Unlocked      ignore_case=True
        Log To Console     \n RF${index} => ${elem['status']['operationalState']}
        ${index}           Set Variable    ${index + 1}
    END
    Verify BTS Setup

Set eNB SCF Directory
    [Documentation]     Sets enb SCF directory path.
    ${eNB_scf_dir}      Set Variable    /home/ute/qt_configs/branches/eNB
    BuiltIn.Set Suite Variable     ${eNB_scf_dir}

Check active eNB SW version on cOAM
    [Arguments]        ${bts_host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    coam.connect_to    bts_host=${bts_host}
    ...    update_interval=1000    name=coam_admin
    ${sw_version}      coam.get_sw_version    timeout=30    connection=coam_admin
    ${strip_prefix}    sw_version_parse_coam    ${sw_version}
    ${strip_prefix}    Fetch From Left         ${strip_prefix}         marker=T
    ${AF_PATH_check}   Run Keyword And Return Status    Should Contain     ${AF_PATH}     ${strip_prefix}
    ${AF_PATH2_check}  Run Keyword And Return Status    Should Contain     ${AF_PATH2}    ${strip_prefix}
    ${check_result}    Evaluate    ${AF_PATH_check} or ${AF_PATH2_check}
    Should Be True     ${check_result}

Save SCF For Classical
    Log To Console        \n\t\t- - - Collecting SCF file [...] - - -
    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}
    ...                          file_name=scf_from_webui_${tl.tl_cloud_topology}_ENB.xml
    ...                          connection=coam_admin
    Log To Console    \t\t- - - Collecting SCF file [DONE] - - -

Get eNB ipaddr
    ${enb_oam}    Get Variable Value    ${tl.enbs[0].oam_ip}
    ${enb_lmp}    Get Variable Value    ${tl.enbs[0].system_module.common_units[0].lmp_connection.addr}
    ${enb_host}    Set Variable If    '${enb_oam}'=='None'    ${enb_lmp}    ${enb_oam}
    Log To Console      \t- eNB OAM: https://${enb_host}\n
    Run Keyword If    '${enb_host}'=='None'    Fatal Error    Please check your eNB ip !!!
    Run Keyword If    '192.168.255.' in '${enb_host}'    Fatal Error    Please check your eNB ip !!!
    Set Suite Variable    ${enb_host}

NSA ENB Setup
    Log To Console      ============================== [ SUITE SETUP ] ===============================\n
    Log To Console      \t\t - - - Setting variables for NSA ENB cases - - -
    Get eNB ipaddr
    Log To Console      \n============================ [ SUITE SETUP DONE ] ============================
    Log To Console      ------------------------------------------------------------------------------

NSA ENB Teardown
    Log To Console      ============================== [ SUITE TEARDOWN ] ===============================\n
    Log To Console      \t\t - - - Start to check if TLs need to be turned off - - -
    Create File        ${OUTPUT_DIR}/data_after_test.txt    ${EMPTY}
    ${online}    Get Variable Value     ${online}    ${True}
    Run Keyword If     ${online}    Append To file
    ...    ${OUTPUT_DIR}/data_after_test.txt    online=true
    ...    ELSE
    ...    Append To File    ${OUTPUT_DIR}/data_after_test.txt    online=false
    Log To Console      \t\t - - - Save SCF if test succeeded - - -
    Run Keyword If All Tests Passed    Run Keywords
    ...                                coam.connect to
    ...                                bts_host=${enb_host}    update_interval=1000  name=coam_admin
    ...                         AND    Save SCF For Classical
    Log To Console      \n============================ [ SUITE TEARDOWN DONE ] ============================
    Log To Console      ------------------------------------------------------------------------------
    [Teardown]    coam.teardown    connection=coam_admin
