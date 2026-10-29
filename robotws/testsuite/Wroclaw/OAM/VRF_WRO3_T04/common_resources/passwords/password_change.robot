*** Settings ***
Documentation    Password changed Keyword and variables with usage example.
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library     taf.fdsw.rc                WITH NAME    rescue


*** Variables ***
${DEFAULT_ADMIN_USERNAME}           Nemuadmin
${DEFAULT_ADMIN_PASS}               nemuuser
${BTS_IP}                           192.168.255.129

*** Keywords ***
Setup Service User Account
    [Documentation]    Description:    WEBem CLI for changing Service User Account information
    ...                Input:          username - the username for account
    ...                                new_password - new password for account
    ...                                old_password - old password for account
    ...                Output:         None (the KW Succeeds or not)
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${username}   ${new_password}    ${old_password}   ${connection}
    Log    Setup ${username} account        console=true
    coam_admin.modify_web_service_user      username=${username}
    ...                                     password=${new_password}
    ...                                     old_username=${username}
    ...                                     old_password=${old_password}
    ...                                     connection=${connection}


Configuration Reset
    [Documentation]    Description:    KW for rescue console reset: depends on choosen
    ...                Input:          new_pass - new password
    ...                                scf_path - path to downloaded Scf
    ...                                new_username = default id Nemuadmin
    ...                                reset_type =
    ...                                {1: Without removing certificates and credentials
    ...                                2: Without removing certificates and credentials with reset WiFi
    ...                                3: With certificate from active partition
    ...                                4: With certificate from active partition  with reset WiFi
    ...                                5: With credentials from active partition
    ...                                6: With credentials from active partition  with reset WiFi
    ...                                7: With certificates and credentials from active partition
    ...                                8: With certificates and credentials from active partition  with reset WiFi
    ...                                9: Repair center}
    ...                Output:         None (the KW Succeeds or not)
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]       ${new_pass}    ${scf_path}   ${new_username}=Nemuadmin    ${reset_type}=3
    Log               Check if the BTS is dual or single-core    console=true
    ${smod_check}=    Check SMOD   username=${new_username}    password=${new_pass}
    Log               The configuration reset is starting...    console=true
    Wait Until Keyword Succeeds  20m  30s      Check If BTS Is Pingable
    ${connect}=    Wait Until Keyword Succeeds    15min    1min
    ...               coam_admin.connect_to   bts_host=${BTS_IP}   username=${new_username}  password=${new_pass}
    ${conf_reset}=    Run Keyword And Ignore Error    coam_admin.reset_configuration    remove_operator_certificates=True
    ...               remove_user_account_credentials=True
    ...               timeout=1800
    ...               connection=${connect}
    ...               detailed_output=true
    ...               reset_type=ConfigurationWithDiagnosticAndRecoverySw
    Log               The configuration reset is ongoing. The status of configuration reset:${conf_reset}    console=true
    ${conn}=          Wait Until Keyword Succeeds    10min    1min    rescue.connect_to   ip_address=${BTS_IP}   port=443
    ...               username=${new_username}    password=${new_pass}
    ${slot_id}=          rescue.get_active_sw_partition    connection=${conn}
    @{reset_options}=    rescue.get_available_reset_options    slot_id=${slot_id}    connection=${conn}
    Log    The available options for reset are: ${reset_options}    console=true
    rescue.software_rollback    sw_slot_id=${slot_id}    reset_type=${reset_options}[${reset_type}]    connection=${conn}
    Log    The software is uploading...   console=true
    Run Keyword If   '${smod_check}'=='True'    FDSW connect on ESM    new_pass=${new_pass}    reset_type=${reset_type}
    ...               new_username=${new_username}
    Log               Uploading SCF    console=true
    Run Keywords      Wait Until Keyword Succeeds  3x  5min     Upload Scf After Reset  ${scf_path}
    ...    AND        Wait Until Keyword Succeeds  3x  7min     Wait Until BTS reach Configured or OnAir state
    ...    AND        Run Keyword And Ignore Error    admin.Disconnect from ADMIN    ${connect}

FDSW connect on ESM
    [Documentation]    Description:    KW for rescue console reset on 2nd node
    ...                Output:         None (the KW Succeeds or not)
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${new_pass}    ${reset_type}    ${new_username}
    ${VM_pass}=     password_change.Get VM Password
    ${VM_IP_NODE_2}=  Set Variable  ${tl.test_pcs[1].default_ssh_connection_details.addr}
    rescue.setup_remote    ssh_host=${VM_IP_NODE_2}   ssh_port=22    ssh_username=ute   ssh_password=${VM_pass}
    ${connected_to_fdsw_bts1}      Run Keyword And Return Status    Wait Until Keyword Succeeds    20x    20s    rescue.connect_to
    ...    ip_address=127.0.0.1    port=8888    username=${new_username}    password=${new_pass}    secure=True    name=esm_fdsw
    Run Keyword if      '${connected_to_fdsw_bts1}'=='True'    Log    Connected to FDSW on ESM    console=true
    ...                  ELSE    Log    Connection to FDSW on ESM failed    console=true
    ${slot_id}=          rescue.get_active_sw_partition    connection=esm_fdsw
    @{reset_options}=    rescue.get_available_reset_options    slot_id=${slot_id}        connection=esm_fdsw
    rescue.software_rollback    sw_slot_id=${slot_id}    reset_type=${reset_options}[${reset_type}]        connection=esm_fdsw
    Log    Deleteting configuration with credentials from active partition on ESM    console=true

Upload Scf After Reset
    [Documentation]    Description:    KW for uploading scf after configuration reset
    ...                Input:          path to downloaded Scf
    ...                Output:         None (the KW Succeeds or not)
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]     ${scf_path}
    ${connection}=  admin.Connect to ADMIN    password=${DEFAULT_ADMIN_PASS}
    Log             Uploading scf  console=true
    coam_admin.perform_commissioning    scf_file=${scf_path}  skip_parameter_relation_errors=False  should_activate=True
    ...             timeout=900  connection=${connection}
    [Teardown]      admin.Disconnect from ADMIN

Get VM Password
    ${VM_PASS}   Run   sudo cat /etc/ute/vncpasswd
    [Return]     ${VM_PASS}

Check SMOD
    [Arguments]    ${username}    ${password}
    ${connection}=  Wait Until Keyword Succeeds    10min    1min
    ...             admin.Connect to ADMIN    username=${username}    password=${password}
    ${bts_info}=    coam_admin.get_fsm_info    connection=${connection}
    ${bts_info}=    convert to string     ${bts_info}
    ${status}=      Get Regexp Matches     ${bts_info}  SMOD_R-\\d+
    ${SMOD_2}=      Run Keyword and Return Status    Should contain  ${status}    SMOD_R-2
    [Return]        ${SMOD_2}
    [Teardown]    Run Keyword And Ignore Error
    ...           admin.Disconnect From ADMIN    connection=${connection}
