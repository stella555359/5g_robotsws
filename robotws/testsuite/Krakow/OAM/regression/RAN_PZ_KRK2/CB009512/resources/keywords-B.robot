*** Settings ***
Documentation
...    Author: Lukasz Wlosowicz, lukasz.wlosowic@nokia.com
...    Maintainer: Lukasz Wlosowicz, lukasz.wlosowic@nokia.com
...
...    Note: 'param_is_deleted' is a special made up value and recognized only in keywords from this resource, it is not a valid param value for BTS.

Library      Collections
Library      OperatingSystem
Library      taf.nms.netact    WITH NAME    netact
Library      taf.sbts.oam.coam.admin    WITH NAME    admin
Library      taf.sbts.oam.sc.rest.rest    WITH NAME    sc_rest
Library      taf.selenium.sc    WITH NAME    sc
Library      taf.config.scf    WITH NAME    scf
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv4all
Library      taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    commissioning
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    asirHubOp
Library      testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.GnbAsir    WITH NAME    GnbAsirOp
Library      testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME    AsirWebEM
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      ./utils/helpers.py
Library      ./keywords-B.py

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./deltas.py
Variables    ./variables-B.py


*** Variables ***
${BTS_ID}=                                   ${tl.gnbs[0].global_bts_id}
${N-1_RELEASE_SW}=                           ${None}
${N_RELEASE_SW}=                             ${None}

${BTS_ADDRESS}=                              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${BTS_MPLANE_ADDRESS}=                       ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${BTS_PORT}=                                 ${tl.gnbs[0].cu.oam_http_connection_details.port}
${USE_SSL}=                                  True
${ASIR_WEBEM_PORT}=                          3601

${NETACT_NAME}=                              srnclab2002
${WEB_URL}=                                  https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${CMWAS_HOSTNAME}=                           10.82.47.15
${NETACT_USERNAME}=                          omc
${NETACT_PASSWORD}=                          Medsql!_1893

${NETACT_MRBTS_MO_RELEASE}=                  ${None}
${MRBTS_MO_ADDRESS}=                         ${BTS_MPLANE_ADDRESS}
${MRBTS_MO_MR}=                              MRC-COMMON/MR-COMMON
${NE_ID_VALUE}=                              PLMN-PLMN/MRBTS-${BTS_ID}
${MRBTS_MO_DIST_NAME}=                       ${NE_ID_VALUE}
${SECURITY_MODE}=                            no TLS

${SEC_ADMIN_PASSWORD}=                       Krk1234!
${APP_ADMIN_PASSWORD}=                       ${SEC_ADMIN_PASSWORD}
${READ_ONLY_USER_PASSWORD}=                  ${SEC_ADMIN_PASSWORD}

${APP_ADMIN_PASSWORD_TC14}=                  Krk1234!@#
${READ_ONLY_USER_PASSWORD_TC14}=             ${APP_ADMIN_PASSWORD_TC14}

${CNUM_SYS_ADMIN_USERNAME}=                  KRKSYS
${CNUM_SEC_ADMIN_USERNAME}=                  KRKSEC
${CNUM_APP_ADMIN_USERNAME}=                  KRKAPP
${CNUM_READ_ONLY_USER_USERNAME}=             KRKREAD
${CNUM_SYS_ADMIN_PASSWORD}=                  ${SEC_ADMIN_PASSWORD}
${CNUM_SEC_ADMIN_PASSWORD}=                  ${SEC_ADMIN_PASSWORD}
${CNUM_APP_ADMIN_PASSWORD}=                  ${SEC_ADMIN_PASSWORD}
${CNUM_READ_ONLY_USER_PASSWORD}=             ${SEC_ADMIN_PASSWORD}

${LOGIN_RESTRICTED_TO_CNUM_ERR_MESSAGE}=     Local account blocked: local account usage has been restricted, please provide hosting BTS’s CNUM
...                                          credentials manually

${VIRTUAL_DISPLAY}=                          ${True}

@{CUSTOM_ALARMS}=                            4297    4479    4655    6150    6261    61011    61510    61618    61648    61649

&{NODE_UPGRADE}=                             testline_object=${tl.gnbs[0]}
...                                          custom_allowed_alarms=${CUSTOM_ALARMS}

&{NODE_FIRST_ROLLBACK}=                      testline_object=${tl.gnbs[0]}
...                                          custom_allowed_alarms=${CUSTOM_ALARMS}

&{NODE_SECOND_ROLLBACK}=                     testline_object=${tl.gnbs[0]}
...                                          custom_allowed_alarms=${CUSTOM_ALARMS}

&{SECPRM_VALUES_TO_SET_BEFORE_UPGRADE}=      emAccessPriorityLogoutTimer=190
...                                          localPasswdExpiryPeriod=199
...                                          localPasswdWarningPeriod=19
...                                          webEMSessionLogoutTimer=1900

&{SECPRM_BEFORE_FIRST_ROLLBACK}=             emAccessPriorityLogoutTimer=param_is_deleted
...                                          localPasswdExpiryPeriod=110
...                                          localPasswdWarningPeriod=10
...                                          webEMSessionLogoutTimer=1000

&{SECPRM_BEFORE_SECOND_ROLLBACK}=            emAccessPriorityLogoutTimer=200
...                                          localPasswdExpiryPeriod=220
...                                          localPasswdWarningPeriod=20
...                                          webEMSessionLogoutTimer=param_is_deleted

&{EXPECTED_ACTIVE_BUTTONS_READ_ONLY}=        edit=${False}
...                                          load file=${False}
...                                          load template=${False}
...                                          detect=${False}
...                                          view=${True}
...                                          save=${True}
...                                          reset=${False}
...                                          accounts=${False}

&{EXPECTED_ACTIVE_BUTTONS_SYS_ADMIN}=        edit=${True}
...                                          load file=${True}
...                                          load template=${True}
...                                          detect=${True}
...                                          view=${True}
...                                          save=${True}
...                                          reset=${True}
...                                          accounts=${True}

&{EXPECTED_ACTIVE_BUTTONS_SEC_ADMIN}=        edit=${True}
...                                          load file=${False}
...                                          load template=${False}
...                                          detect=${False}
...                                          view=${True}
...                                          save=${True}
...                                          reset=${False}
...                                          accounts=${True}

&{EXPECTED_ACTIVE_BUTTONS_APP_ADMIN}=        edit=${True}
...                                          load file=${True}
...                                          load template=${False}
...                                          detect=${False}
...                                          view=${True}
...                                          save=${True}
...                                          reset=${False}
...                                          accounts=${False}

*** Keywords ***
Get SW release from BTS and set NetAct MRBTS release variable
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=get_sw_release
    ${bts_software_info}=    admin.Get software info    connection=get_sw_release
    ${bts_release}=    Extract release from BTS software info    ${bts_software_info}
    Set suite variable    ${BTS_RELEASE}
    admin.Teardown admin    connection=get_sw_release
    Run keyword if    '${NETACT_MRBTS_MO_RELEASE}'!='${None}'    Set suite variable    ${NETACT_MRBTS_MO_RELEASE}
    Run keyword if    '${NETACT_MRBTS_MO_RELEASE}'=='${None}'    Set suite variable    ${NETACT_MRBTS_MO_RELEASE}    ${BTS_RELEASE}

Integrate to NetAct and activate user accounts on BTS
    netact.Add WEB URL    ${WEB_URL}    ${NETACT_USERNAME}    ${NETACT_PASSWORD}    alias=${NETACT_NAME}
    netact.Add node    cmwas    ${CMWAS_HOSTNAME}    ${NETACT_USERNAME}    ${NETACT_PASSWORD}    alias=${NETACT_NAME}
    netact.Integrate MRBTS with NetAct    release=${NETACT_MRBTS_MO_RELEASE}    mr=${MRBTS_MO_MR}    mrbts_address=${MRBTS_MO_ADDRESS}
    ...    dist_name=${MRBTS_MO_DIST_NAME}    security_mode=${SECURITY_MODE}    alias=${NETACT_NAME}
    Log    IF FOLLOWING ACTIVATION FAILS, PLEASE DOUBLECHECK THAT CNUM USERS ARE CONFIGURED ON THE NETACT CLAB.    console=${True}
    netact.Activate CNUM    ${NE_ID_VALUE}    alias=${NETACT_NAME}    ldap_access_type=PREFER TLS    ip_type=IPv4
    [Teardown]    Run keywords
    ...    netact.Delete node    cmwas    alias=${NETACT_NAME}    AND
    ...    netact.Clean all    alias=${NETACT_NAME}

Deactivate CNUM and deintegrate from NetAct
    netact.Add WEB URL    ${WEB_URL}    ${NETACT_USERNAME}    ${NETACT_PASSWORD}    alias=${NETACT_NAME}
    netact.Add node    cmwas    ${CMWAS_HOSTNAME}    ${NETACT_USERNAME}    ${NETACT_PASSWORD}    alias=${NETACT_NAME}
    ${result}=    Run keyword and continue on failure    netact.Deactivate CNUM    ${NE_ID_VALUE}    alias=${NETACT_NAME}
    ${deintegration_output}=    netact.Deintegrate MRBTS from NetAct    dist_name=${MRBTS_MO_DIST_NAME}    alias=${NETACT_NAME}
    [Teardown]    Run keywords
    ...    netact.Delete node    cmwas    alias=${NETACT_NAME}    AND
    ...    netact.Clean all    alias=${NETACT_NAME}

Setup for TC14
    keywords-B.Set allowed alarms
    keywords-B.Set allowed alarms for ASiR
    Common preconditions with watching alarms
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    username=Nemuadmin    password=nemuuser
    ...    use_ssl=${USE_SSL}    name=SYS_adm_conn
    Set actRestrictLoginToCnum    value=false    admin_alias=SYS_adm_conn
    Set secAdmActivated to true if needed
    Set appAdmActivated and readOnlyActivated to false
    AsirWebEM.Clean browser
    AsirWebEM.Set virtual enable    virtual_enable=${VIRTUAL_DISPLAY}
    Set initial params values via ASiR WebEM

Setup for TC19
    keywords-B.Set allowed alarms
    keywords-B.Set allowed alarms for ASiR
    Common preconditions with watching alarms
    AsirWebEM.Clean browser
    AsirWebEM.Set virtual enable    virtual_enable=${VIRTUAL_DISPLAY}
    Set initial params values via ASiR WebEM
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    username=Nemuadmin    password=nemuuser
    ...    use_ssl=${USE_SSL}    name=Local_sys_adm_conn
    Set secAdmActivated appAdmActivated and readOnlyActivated to true if needed
    Set actRestrictLoginToCnum    value=true    admin_alias=Local_sys_adm_conn

Teardown for TC19
    AsirWebEM.Logout
    AsirWebEM.Clean browser
    Set actRestrictLoginToCnum    value=false    admin_alias=CNUM_sys_adm_conn
    admin.Teardown admin    connection=Local_sys_adm_conn
    admin.Teardown admin    connection=CNUM_sys_adm_conn
    Common postconditions with watching alarms
    GnbAsirOp.Teardown all browsers
    asirHubOp.Perform ASiR recommissioning    delta=${enabledefaultpasswdalarm_false}

Verify access to ASiR WebEM's functionalities for Local System Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for Local System Admin
    AsirWebEM.Login    user_name=Nemuadmin    user_password=nemuuser
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=Nemuadmin    expected_role=BTS System Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_SYS_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_SYS_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for Local Security Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for Local Security Admin
    AsirWebEM.Login    user_name=sec_alias    user_password=${SEC_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=sec_alias    expected_role=BTS Security Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_SEC_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_SEC_ADM}
    Verify user cannot modify params in ASiR WebEM    ${TC14_PARAMS_FORBIDDEN_SEC_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for Local Application Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for Local Application Admin
    AsirWebEM.Login    user_name=app_alias    user_password=${APP_ADMIN_PASSWORD_TC14}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=app_alias    expected_role=BTS Application Administrator
    Run keyword if    '${BTS_RELEASE}'=='SBTS25R2'    Set to dictionary    ${EXPECTED_ACTIVE_BUTTONS_APP_ADMIN}    load file=${False}
    Log    As of 25R3 Application Admin is permitted to access Load File function so 'load file' button is active for him.    console=${True}
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_APP_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_APP_ADM}
    Verify user cannot modify params in ASiR WebEM    ${TC14_PARAMS_FORBIDDEN_APP_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for Local Read-only User
    Log to console    Verifying access to ASiR WebEM's functionalities for Local Read-only user
    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${False}    user_name=read_alias    user_password=${READ_ONLY_USER_PASSWORD_TC14}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=read_alias    expected_role=BTS Read-Only User
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    ${can_read_only_user_enter_parameter_editor}=    Run keyword and return status    AsirWebem.Enter config man    sub_menu=edit
    Should not be true    ${can_read_only_user_enter_parameter_editor}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for CNUM System Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for CNUM System Admin
    AsirWebEM.Login    user_name=${CNUM_SYS_ADMIN_USERNAME}    user_password=${CNUM_SYS_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=${CNUM_SYS_ADMIN_USERNAME}    expected_role=BTS System Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_SYS_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_SYS_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for CNUM Security Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for CNUM Security Admin
    AsirWebEM.Login    user_name=${CNUM_SEC_ADMIN_USERNAME}    user_password=${CNUM_SEC_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=${CNUM_SEC_ADMIN_USERNAME}    expected_role=BTS Security Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_SEC_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_SEC_ADM}
    Verify user cannot modify params in ASiR WebEM    ${TC14_PARAMS_FORBIDDEN_SEC_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for CNUM Application Admin
    Log to console    Verifying access to ASiR WebEM's functionalities for CNUM Application Admin
    AsirWebEM.Login    user_name=${CNUM_APP_ADMIN_USERNAME}    user_password=${CNUM_APP_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read/write
    ...    expected_username=${CNUM_APP_ADMIN_USERNAME}    expected_role=BTS Application Administrator
    Run keyword if    '${BTS_RELEASE}'=='SBTS25R2'    Set to dictionary    ${EXPECTED_ACTIVE_BUTTONS_APP_ADMIN}    load file=${False}
    Log    As of 25R3 Application Admin is permitted to access Load File function so 'load file' button is active for him.    console=${True}
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_APP_ADMIN}
    Recommission params via ASiR WebEM and verify if changed successfully    ${TC14_PARAMS_ALLOWED_APP_ADM}
    Verify user cannot modify params in ASiR WebEM    ${TC14_PARAMS_FORBIDDEN_APP_ADM}
    AsirWebEM.Logout

Verify access to ASiR WebEM's functionalities for CNUM Read-only User
    Log to console    Verifying access to ASiR WebEM's functionalities for CNUM Read-only user
    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${False}    user_name=${CNUM_READ_ONLY_USER_USERNAME}
    ...    user_password=${CNUM_READ_ONLY_USER_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_READ_ONLY_USER_USERNAME}    expected_role=BTS Read-Only User
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    ${can_read_only_user_enter_parameter_editor}=    Run keyword and return status    AsirWebem.Enter config man    sub_menu=edit
    Should not be true    ${can_read_only_user_enter_parameter_editor}

Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Security Admin
    Log to console    Verifying if access to ASiR WebEM's functionalities is degraded to read-only for CNUM Security Admin
    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${False}    user_name=${CNUM_SEC_ADMIN_USERNAME}
    ...    user_password=${CNUM_SEC_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_SEC_ADMIN_USERNAME}    expected_role=BTS Security Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    ${can_read_only_user_enter_parameter_editor}=    Run keyword and return status    AsirWebem.Enter config man    sub_menu=edit
    Should not be true    ${can_read_only_user_enter_parameter_editor}
    AsirWebEM.Logout

Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Application Admin
    Log to console    Verifying if access to ASiR WebEM's functionalities is degraded to read-only for CNUM Application Admin
    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${False}    user_name=${CNUM_APP_ADMIN_USERNAME}
    ...    user_password=${CNUM_APP_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_APP_ADMIN_USERNAME}    expected_role=BTS Application Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    ${can_read_only_user_enter_parameter_editor}=    Run keyword and return status    AsirWebem.Enter config man    sub_menu=edit
    Should not be true    ${can_read_only_user_enter_parameter_editor}
    AsirWebEM.Logout

Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Read-only User
    Verify access to ASiR WebEM's functionalities for CNUM Read-only User

Setup for TC20 with upgrade from N-1 to N
    keywords-B.Set allowed alarms
    keywords-B.Set allowed alarms for ASiR
    Common preconditions    collect_syslog=${False}    collect_ru_console_log=${False}
    commissioning.Perform BTS delta commissioning    delta=${actlogincredpartitionsync_true}
    Set SECPRM values before upgrade
    Upgrade from N-1 to target build

Teardown for TC20
    ${SECPRM_IN_TEARDOWN}=    Get current SECPRM params values from ASiR
    ${does_SECPRM_have_good_values_already}=    Compare selected SECPRM params dicts
    ...    ${SECPRM_IN_TEARDOWN}    ${SECPRM_VALUES_TO_SET_BEFORE_UPGRADE}
    Run keyword if    not ${does_SECPRM_have_good_values_already}    Modify SECPRM parameters on ASiR
    ...    ${SECPRM_VALUES_TO_SET_BEFORE_UPGRADE}    ${SECPRM_IN_TEARDOWN}
    gnbbbu.Connect    force=${True}
    Common postconditions    collect_syslog=${False}    collect_snapshot_from_ru=${False}

Upgrade from N-1 to target build
    [Documentation]
    ...    KW Upgrade from N-1 to target build.
    ...    This keyword works inside testcase (can be Test Setup) but it won't work in Suite Setup (csv4all lib constraint)
    [Timeout]    48h
    Set suite variable    @{CRITICAL_FAULTS}    0010    0016    1806    1868    4341    4352    4383
    ${N-1_RELEASE_SW}=    Run keyword if    '${N-1_RELEASE_SW}'=='${None}'    Get CM source build    ELSE    Set variable    ${N-1_RELEASE_SW}
    ${N_RELEASE_SW}=    Run keyword if    '${N_RELEASE_SW}'=='${None}'    Get target build    ELSE    Set variable    ${N_RELEASE_SW}
    Set to dictionary    ${NODE_UPGRADE}    source_sw    ${N-1_RELEASE_SW}
    Set to dictionary    ${NODE_UPGRADE}    target_sw    ${N_RELEASE_SW}
    Set to dictionary    ${NODE_FIRST_ROLLBACK}    source_sw    ${N_RELEASE_SW}
    Set to dictionary    ${NODE_FIRST_ROLLBACK}    target_sw    ${N-1_RELEASE_SW}
    Set to dictionary    ${NODE_SECOND_ROLLBACK}    source_sw    ${N-1_RELEASE_SW}
    Set to dictionary    ${NODE_SECOND_ROLLBACK}    target_sw    ${N_RELEASE_SW}
    @{NODES_UPGRADE}=    Create List    ${NODE_UPGRADE}
    @{NODES_FIRST_ROLLBACK}=    Create List    ${NODE_FIRST_ROLLBACK}
    @{NODES_SECOND_ROLLBACK}=    Create List    ${NODE_SECOND_ROLLBACK}
    Set Suite Variable    @{NODES_UPGRADE}
    Set Suite Variable    @{NODES_FIRST_ROLLBACK}
    Set Suite Variable    @{NODES_SECOND_ROLLBACK}
    csv4all.E2E TL upgrade test
    ...                            nodes_details=${NODES_UPGRADE}
    ...                            test_nodes_details=${NODE_UPGRADE}
    ...                            iterations_per_node=${1}
    ...                            report=${False}
    ...                            calculate_kpi=${False}

Rollback from N to N-1
    [Timeout]    48h
    csv4all.E2E TL rollback test
    ...    ${NODES_FIRST_ROLLBACK}
    ...    ${NODE_FIRST_ROLLBACK}

Rollback from N-1 to N
    [Timeout]    48h
    csv4all.E2E TL rollback test
    ...    ${NODES_SECOND_ROLLBACK}
    ...    ${NODE_SECOND_ROLLBACK}

Set SECPRM values before upgrade
    ${current_secprm}=    Get current SECPRM params values from ASiR
    ${does_SECPRM_have_good_values_already}=    Compare selected SECPRM params dicts    ${current_secprm}    ${SECPRM_VALUES_TO_SET_BEFORE_UPGRADE}
    IF    not ${does_SECPRM_have_good_values_already}
        Log    Setting initial values for selected SECPRM's params before Upgrade    console=${True}
        Modify SECPRM parameters on ASiR    ${SECPRM_VALUES_TO_SET_BEFORE_UPGRADE}    ${current_secprm}
    END

Validate SECPRM values on ASiR
    [Arguments]    ${expected_values_dict}
    ${asir_scf_filepath}=    asirHubOp.Get current SCF file    local_dir_path=/tmp/    file_name=asir_scf_validate.xml
    ${actual_secprm_object}=    asirHubOp.Get all params under class name    scf_file_path=${asir_scf_filepath}
    ...    class_name=com.nokia.asi:SECPRM
    ${extracted_values_dict}=    Extract selected SECPRM params dict    ${actual_secprm_object}
    Validate values of selected SECPRM params    ${extracted_values_dict}    ${expected_values_dict}

Get current SECPRM params values from ASiR
    ${asir_scf_filepath}=    asirHubOp.Get current SCF file    local_dir_path=/tmp/    file_name=asir_scf_secprm.xml
    ${actual_secprm_object}=    asirHubOp.Get all params under class name    scf_file_path=${asir_scf_filepath}
    ...    class_name=com.nokia.asi:SECPRM
    ${extracted_secprm_dict}=    Extract selected SECPRM params dict    ${actual_secprm_object}
    [Return]    ${extracted_secprm_dict}

Modify SECPRM parameters on ASiR
    [Arguments]    ${new_values_dict}    ${current_values_dict}
    ${delta_secprm}=    Prepare delta to modify SECPRM    ${new_values_dict}    ${current_values_dict}
    asirHubOp.Perform ASiR recommissioning    delta=${delta_secprm}
    Validate SECPRM values on ASiR    ${new_values_dict}

Get current webEMSessionLoginDelay from ASiR
    ${asir_scf_filepath}=    asirHubOp.Get current SCF file    local_dir_path=/tmp/    file_name=asir_scf_logindelay.xml
    ${actual_secprm_object}=    asirHubOp.Get all params under class name    scf_file_path=${asir_scf_filepath}
    ...    class_name=com.nokia.asi:SECPRM
    ${current_value}=    Extract webEMSessionLoginDelay    ${actual_secprm_object}
    [Return]    ${current_value}

Modify webEMSessionLoginDelay on ASiR if needed
    [Arguments]    ${new_value}
    ${current_value}=    Get current webEMSessionLoginDelay from ASiR
    Set test variable    ${webEMSessionLoginDelay_value_to_restore}    ${current_value}
    Return from keyword if    '${current_value}'=='${new_value}'
    ${delta_webEMSessionLoginDelay}=    Prepare delta to modify webEMSessionLoginDelay    ${new_value}    ${current_value}
    asirHubOp.Perform ASiR recommissioning    delta=${delta_webEMSessionLoginDelay}
    ${value_after_recommissioning}=    Get current webEMSessionLoginDelay from ASiR
    Should be equal    ${value_after_recommissioning}    ${new_value}

Restore webEMSessionLoginDelay on ASiR if needed
    ${current_value}=    Get current webEMSessionLoginDelay from ASiR
    Return from keyword if    '${current_value}'=='${webEMSessionLoginDelay_value_to_restore}'
    ${delta_webEMSessionLoginDelay}=    Prepare delta to modify webEMSessionLoginDelay    ${webEMSessionLoginDelay_value_to_restore}
    ...    ${current_value}
    asirHubOp.Perform ASiR recommissioning    delta=${delta_webEMSessionLoginDelay}
    ${value_after_recommissioning}=    Get current webEMSessionLoginDelay from ASiR
    Should be equal    ${value_after_recommissioning}    ${webEMSessionLoginDelay_value_to_restore}

Verify actlogincredpartitionsync is set to true
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=admin_verify_actlogincredpartitionsync
    ${actLoginCredPartitionSync_list}=    Create list    actLoginCredPartitionSync
    ${featcadm_params}=    admin.Get parameter by class    connection=admin_verify_actlogincredpartitionsync    class_name=FEATCADM
    ...    parameter_list=${actLoginCredPartitionSync_list}
    Run keyword unless    '${featcadm_params[0]['parameters']['actLoginCredPartitionSync']}' == 'True'    Fail
    ...    actLoginCredPartitionSync is not set to true
    admin.Teardown admin    connection=admin_verify_actlogincredpartitionsync

Set allowed alarms
    Set test variable    @{allowed_alarms}    SSH enabled
    ...                                       R&D Service Port enabled
    ...                                       Service account root access is enabled
    ...                                       Ethernet port security is disabled
    ...                                       LMP access via port 443
    ...                                       LMP connectivity detected
    ...                                       CBRS Vendor Certificate is about to expire or expired
    ...                                       CRL Update Failure
    ...                                       CRL Update failure or certificate revoked
    ...                                       IP Traffic Capacity Limit

Set allowed alarms for ASiR
    Set test variable    @{ASIR_ALLOWED_ALARMS}    ${61648}    ${4459}

Recover N release SW build on BTS if needed
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=admin_recover_1
    ${bts_software_info}=    admin.Get software info    connection=admin_recover_1
    ${active_sw}    ${passive_sw}    Extract SW builds names and convert to SBTS00 format    ${bts_software_info}
    admin.Teardown admin    connection=admin_recover_1

    Return from keyword if    '${active_sw}'=='${N_RELEASE_SW}'
    Run keyword if    '${active_sw}'=='${N-1_RELEASE_SW}' and '${passive_sw}'=='${N_RELEASE_SW}'    Rollback from N-1 to N
    Run keyword if    '${active_sw}'=='${N-1_RELEASE_SW}' and '${passive_sw}'!='${N_RELEASE_SW}'    Upgrade from N-1 to target build

    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=admin_recover_2
    ${bts_software_info}=    admin.Get software info    connection=admin_recover_2
    ${active_sw}    ${passive_sw}    Extract SW builds names and convert to SBTS00 format    ${bts_software_info}
    admin.Teardown admin    connection=admin_recover_2

    Run keyword unless    '${active_sw}'=='${N_RELEASE_SW}'    Fatal error    failed to upgrade to target build.

Rollback to N-1 release SW build on BTS If needed
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=admin_recover_1
    ${bts_software_info}=    admin.Get software info    connection=admin_recover_1
    ${active_sw}    ${passive_sw}    Extract SW builds names and convert to SBTS00 format    ${bts_software_info}
    admin.Teardown admin    connection=admin_recover_1

    Return from keyword if    '${active_sw}'=='${N-1_RELEASE_SW}'
    Run keyword if    '${active_sw}'=='${N_RELEASE_SW}' and '${passive_sw}'=='${N-1_RELEASE_SW}'    Rollback from N to N-1

    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=admin_recover_2
    ${bts_software_info}=    admin.Get software info    connection=admin_recover_2
    ${active_sw}    ${passive_sw}    Extract SW builds names and convert to SBTS00 format    ${bts_software_info}
    admin.Teardown admin    connection=admin_recover_2

    Run keyword unless    '${active_sw}'=='${N-1_RELEASE_SW}'    Fatal error    failed to restore to N-1 build.

Set passwords and activate BTSSecurity BTSApplication and BTSRead users on BTS
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    use_ssl=${USE_SSL}    name=set_passwords
    admin.Set user account    old_username=BTSSecurity    old_password=nemuuser
    ...    new_username=${EMPTY}    new_password=${SEC_ADMIN_PASSWORD}
    ...    connection=set_passwords    timeout=${120}
    admin.Set user account    old_username=BTSApplication    old_password=nemuuser
    ...    new_username=${EMPTY}    new_password=${APP_ADMIN_PASSWORD}
    ...    connection=set_passwords    timeout=${120}
    admin.Set user account    old_username=BTSRead    old_password=nemuuser
    ...    new_username=${EMPTY}    new_password=${READ_ONLY_USER_PASSWORD}
    ...    connection=set_passwords    timeout=${120}
    admin.Change local account state    account_type=BtsSecurity    enable=True
    ...    connection=set_passwords    timeout=${120}
    admin.Change local account state    account_type=BtsApplication    enable=True
    ...    connection=set_passwords    timeout=${120}
    admin.Change local account state    account_type=BtsRead    enable=True
    ...    connection=set_passwords    timeout=${120}
    [Teardown]    admin.Teardown admin    connection=set_passwords

Verify username role and access mode in ASiR WebEM
    [Arguments]    ${expected_access_mode}=${None}    ${expected_username}=${None}    ${expected_role}=${None}
    ${user_info_dict}=    AsirWebEM.Get user info
    Run keyword if    '${expected_access_mode}'!='${None}'
    ...    Should be equal    ${user_info_dict}[access_mode]    ${expected_access_mode}
    Run keyword if    '${expected_username}'!='${None}'
    ...    Should be equal    ${user_info_dict}[username]    ${expected_username}
    Run keyword if    '${expected_role}'!='${None}'
    ...    Should be equal    ${user_info_dict}[role]    ${expected_role}
    Run keyword if    '${expected_access_mode}'=='${None}' and '${expected_username}'=='${None}' and '${expected_role}'=='${None}'
    ...    Fail    At least one of arguments must be other than None, please set arguments correctly.

Set secAdmActivated to true if needed
    ${parameter_list}=	Create list    secAdmActivated
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=SYS_adm_conn
    ${secAdmActivated}=    Set variable    ${output[0]['parameters']['secAdmActivated']}
    Return from keyword if    '${secAdmActivated}'=='True'
    admin.Perform parameter recommissioning    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    secAdmActivated    update    true    connection=SYS_adm_conn
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=SYS_adm_conn
    ${secAdmActivated}=    Set variable    ${output[0]['parameters']['secAdmActivated']}
    Run keyword unless    '${secAdmActivated}'=='True'    Fail    Failed to recommission secAdmActivated to true

Set appAdmActivated and readOnlyActivated to false
    ${delta}=    Prepare delta to act deact BTSApplication and BTSRead users    mrbts_id=${BTS_ID}    value=false
    admin.Perform delta recommissioning    delta_file=${delta}    connection=SYS_adm_conn
    ${parameter_list}=	Create list    appAdmActivated    readOnlyActivated
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=SYS_adm_conn
    ${appAdmActivated}=    Set variable    ${output[0]['parameters']['appAdmActivated']}
    ${readOnlyActivated}=    Set variable    ${output[0]['parameters']['readOnlyActivated']}
    Run keyword unless    '${appAdmActivated}'=='False' and '${readOnlyActivated}'=='False'
    ...    Fail    Failed to recommission appAdmActivated and readOnlyActivated to false

Set secAdmActivated appAdmActivated and readOnlyActivated to true if needed
    ${parameter_list}=	Create list    secAdmActivated    appAdmActivated    readOnlyActivated
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=Local_sys_adm_conn
    ${secAdmActivated}=    Set variable    ${output[0]['parameters']['secAdmActivated']}
    ${appAdmActivated}=    Set variable    ${output[0]['parameters']['appAdmActivated']}
    ${readOnlyActivated}=    Set variable    ${output[0]['parameters']['readOnlyActivated']}
    Return from keyword if    '${secAdmActivated}'=='True' and '${appAdmActivated}'=='True' and '${readOnlyActivated}'=='True'
    ${delta}=    Prepare delta to act deact BTSSecurity BTSApplication and BTSRead users    mrbts_id=${BTS_ID}    value=true
    admin.Perform delta recommissioning    delta_file=${delta}    connection=Local_sys_adm_conn
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=Local_sys_adm_conn
    ${secAdmActivated}=    Set variable    ${output[0]['parameters']['secAdmActivated']}
    ${appAdmActivated}=    Set variable    ${output[0]['parameters']['appAdmActivated']}
    ${readOnlyActivated}=    Set variable    ${output[0]['parameters']['readOnlyActivated']}
    Run keyword unless    '${secAdmActivated}'=='True' and '${appAdmActivated}'=='True' and '${readOnlyActivated}'=='True'
    ...    Fail    Failed to recommission secAdmActivated, appAdmActivated and readOnlyActivated to true

Set secAdmActivated appAdmActivated and readOnlyActivated to false
    ${delta}=    Prepare delta to act deact BTSSecurity BTSApplication and BTSRead users    mrbts_id=${BTS_ID}    value=false
    admin.Perform delta recommissioning    delta_file=${delta}    connection=CNUM_sys_adm_conn
    ${parameter_list}=	Create list    secAdmActivated    appAdmActivated    readOnlyActivated
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=CNUM_sys_adm_conn
    ${secAdmActivated}=    Set variable    ${output[0]['parameters']['secAdmActivated']}
    ${appAdmActivated}=    Set variable    ${output[0]['parameters']['appAdmActivated']}
    ${readOnlyActivated}=    Set variable    ${output[0]['parameters']['readOnlyActivated']}
    Run keyword unless    '${secAdmActivated}'=='False' and '${appAdmActivated}'=='False' and '${readOnlyActivated}'=='False'
    ...    Fail    Failed to recommission secAdmActivated, appAdmActivated and readOnlyActivated to false

Set actRestrictLoginToCnum
    [Documentation]    The 'value' argument must be lower case!! i.e. true or false
    [Arguments]    ${value}    ${admin_alias}
    admin.Perform parameter recommissioning    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    actRestrictLoginToCnum    update    ${value}
    ...    connection=${admin_alias}
    ${parameter_list}=    Create list    actRestrictLoginToCnum
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=${admin_alias}
    ${actRestrictLoginToCnum}=    Set variable    ${output[0]['parameters']['actRestrictLoginToCnum']}
    ${boolean}=    Convert to boolean    ${value}
    Run keyword unless    '${actRestrictLoginToCnum}'=='${boolean}'    Fail    Failed to recommission actRestrictLoginToCnum to ${value}

Set appAdmActivated and readOnlyActivated to true via Security Admin
    ${delta}=    Prepare delta to act deact BTSApplication and BTSRead users    mrbts_id=${BTS_ID}    value=true
    admin.Perform delta recommissioning    delta_file=${delta}    connection=SEC_adm_conn
    ${parameter_list}=	Create list    appAdmActivated    readOnlyActivated
    ${output}=    admin.Get parameter by class    class_name=LUAC    parameter_list=${parameter_list}    connection=SEC_adm_conn
    ${appAdmActivated}=    Set variable    ${output[0]['parameters']['appAdmActivated']}
    ${readOnlyActivated}=    Set variable    ${output[0]['parameters']['readOnlyActivated']}
    Run keyword unless    '${appAdmActivated}'=='True' and '${readOnlyActivated}'=='True'
    ...    Fail    Failed to recommission appAdmActivated and readOnlyActivated to true

Recommission params via ASiR WebEM and verify if changed successfully
    [Arguments]    ${expected_params}
    AsirWebem.Enter config man    sub_menu=edit
    AsirWebem.Modify parameter    ${expected_params}
    AsirWebem.Prevalidate
    AsirWebem.Activate
    ${scf_path}=    AsirWebEM.Save SCF
    Verify ASiR params    scf_file_path=${scf_path}    expected=${expected_params}

Set initial params values via ASiR WebEM
    sc_rest.Connect to    host=${BTS_ADDRESS}    port=${ASIR_WEBEM_PORT}    username=Nemuadmin    password=nemuuser
    sc_rest.Get current SCF file    ${OUTPUT_DIR}    asir_scf_bkp.xml
    sc_rest.Disconnect
    ${are_params_good_already}=    Compare actual ASiR params    scf_file_path=${OUTPUT_DIR}/asir_scf_bkp.xml    expected=${INITIAL_ASIR_PARAMS}
    IF    not ${are_params_good_already}
        AsirWebEM.Login    user_name=Nemuadmin    user_password=nemuuser
        Recommission params via ASiR WebEM and verify if changed successfully    ${INITIAL_ASIR_PARAMS}
        AsirWebEM.Logout
    END

Verify login error message for user
    [Arguments]    ${username}    ${password}    ${expected_error_message}
    ${error_message}=    AsirWebEM.Login and return error message    user_name=${username}    user_password=${password}
    Should be equal as strings    ${error_message}    ${expected_error_message}    msg=Login error message different than expected

