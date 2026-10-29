*** Settings ***
Documentation
...    Test suite for regression testing of feature CB010576
...    author:      Patryk Wojcik
...    contact:     patryk.wojcik@nokia.com
...    maintainer:  patryk.wojcik@nokia.com


Library                     taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library                     testsuite.Krakow.OAM.regression.RAN_PZ_KRK3.CB010576.resources.CB010576_resources.CoamBts    WITH NAME    CoamBts
Library                     ./resources/CB010576_resources.py
Library                     ./resources/rules_generator.py
Resource                    taf/rfrl/bts/robot/gnb.robot
Resource                    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables                   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables                   ./resources/variables.py

Test Setup                  Common Preconditions
Test Teardown               Common Postconditions

Suite Setup                 Common Suite Setup With OnAir Test Line Preparation
Suite Teardown              Run Keywords   Common Suite Teardown    AND
                            ...   Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Variables ***
@{allowed_alarms}           SSH enabled
...                         R&D Service Port enabled
...                         Service account root access is enabled
...                         Ethernet port security is disabled
...                         ToP reference missing
...                         LMP access via port 443
${SITE_RESET_ITERATIONS}    20

*** Test Cases ***
CB010576_SR_E_CB008487_Manually trigger the Service Account synchronization to RU MODULE with WebEM
    CoamBts.Set_value_of_actsynctoru    value=true
    CoamBts.Sync_to_radio_modules
    Ssh to ru serviceuser    ru_id=0  password=${serviceuser_bts_pswd}
    Ssh to ru serviceuser    ru_id=1  password=${serviceuser_bts_pswd}

CB010576_SR_E_CB008487_BTS Service Account Password Provisioning via WebEM
    ${password_too_long}                generate_too_long_password
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_too_long}
    ${password_too_short}               generate_too_short_password
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_too_short}
    ${password_lowercase}               generate_password_without_uppercase
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_lowercase}
    ${password_uppercase}               generate_password_without_lowcase
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_uppercase}
    ${password_with_only_one_digit}     generate_password_only_one_digit
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_with_only_one_digit}
    ${password_without_special_char}    generate_password_with_only_alphanumeric
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_without_special_char}
    ${password_with_forbidden_char}     generate_password_with_not_allowed_symbol
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_with_forbidden_char}
    ${password_correct}                 generate_correct_password
    ${wronguser}                        generate_too_long_username
    CoamBts.Verify_password_for_service_account     username=${wronguser}   new_password=${password_correct}
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_derived_from_username}
    CoamBts.Verify_password_for_service_account     username=serviceuser    new_password=${password_derived_from_username2}

CB010576_SR_E_CB008487_Verify automatic synchronization with different webEM accounts
    CoamBts.Set_password_and_enable_local_user_account    account_type=BTS Security Administrator        password=${tl.creds[1].password}
    CoamBts.Set_password_and_enable_local_user_account    account_type=BTS Application Administrator     password=${tl.creds[2].password}
    CoamBts.Set_password_and_enable_local_user_account    account_type=BTS Read-Only User                password=${tl.creds[3].password}
    Try to change flag for service account synchronization    username=${tl.creds[0].username}     password=${tl.creds[0].password}
    Try to change flag for service account synchronization    username=${tl.creds[1].username}     password=${tl.creds[1].password}
    Try to change flag for service account synchronization    username=${tl.creds[2].username}     password=${tl.creds[2].password}
    Try to change flag for service account synchronization    username=${tl.creds[3].username}     password=${tl.creds[3].password}
