*** Settings ***
Documentation
...     [Author]                    "SHREYA CHOUDHARY"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "28:11:2022"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB008431"
...     [Validated_TestLine]        "IAV_BLR_TL074"
...     [Procedure]                 "CB008431_VerificationOfCommands_Using_SystemAdministrator_User"
...     [Precondition]              "ASIL + ABIA hardware is required"
...     [Config]                    "Application Administrator User account should be created"
...     [Function_Hash_Tags]        "User Accounts System Admin System Security"

*** Keywords ***
Verification of BTS account
    [Arguments]   ${alias}     ${username}     ${password}
    Setup Oamops     dut=bts     username=${username}     password=${password}     alias=${alias}
    Sleep     10

Certificate restore verification
    [Arguments]   ${alias}
    Certificate Configure     operation=restore_vendor_certificate     alias=${alias}     timeout=120
    Sleep     10

Certificate deletion verification
    [Arguments]   ${alias}
    Certificate Configure     operation=delete_cert     all_certs=${True}     alias=${alias}     timeout=120
    Sleep     10

Active Alarms
    [Arguments]   ${alias}
    Verify Alarm     alarm_type=active     should_exist=True     alias=${alias}
    Sleep     10

Alarm History
    [Arguments]   ${alias}
    Verify Alarm     faulfid=4003     alarm_type=history     should_exist=False     alias=${alias}
    Sleep     10

Get Certificate List
    [Arguments]   ${alias}
    Certificate Configure     operation=get_certificate_list     all_certs=${True}     alias=${alias}     type=BTS     timeout=120
    Sleep     10

Reset Configuration
    [Arguments]   ${alias}
    Reset     operation=reset_configuration     alias=${alias}     remove_site_id=False     remove_security_credentials=True     timeout=300
    Sleep     10

Certificate Automatic Management
    [Arguments]   ${alias}     ${ref}     ${key}
    Certificate Configure     operation=set_certificate_automatic_management     alias=${alias}     reference_number=${ref}
    ...  preshared_key=${key}     key_pool_type=ECDSA     timeout=120
    Sleep     10

Get Certificate Revocation List
    [Arguments]   ${alias}
    Certificate Configure     operation=get_certificate_revocation_list     alias=${alias}     timeout=120
    Sleep     10

Update Certificate Revocation List
    [Arguments]   ${alias}
    Certificate Configure     operation=update_certificate_revocation_list     alias=${alias}     timeout=120
    Sleep     10

Initialize CMP Certificate
    [Arguments]   ${alias}
    Certificate configure     operation=install_cmp_certificate     alias=${alias}     key_pool_type=ECDSA     timeout=120
    Sleep     10

Update CMP Key
    [Arguments]   ${alias}
    Certificate Configure     operation=cmp_update_key     alias=${alias}     key_pool_type=ECDSA     timeout=120
    Sleep     10

Reset RAT
    [Arguments]   ${alias}
    Reset     operation=reset_rat     alias=${alias}     rat=LTE     timeout=300
    Sleep     10

Snapshot Verification
    [Arguments]   ${alias}
    Collect Snapshot     request_timeout=None     operation_timeout=300     alias=${alias}
    Sleep     10

BTS Status Verification
    [Arguments]   ${alias}
    Verify Bts Status     req_rat=all     should_be_onair=${True}     wait_for=60     timeout=120     alias=${alias}
    Sleep     10

Site Block
    [Arguments]   ${alias}
    Block     alias=${alias}     operation=Site     timeout=300
    Sleep     10

Site Unblock
    [Arguments]   ${alias}
    Unblock     alias=${alias}     operation=Site     timeout=300     wait_for_reconnection=True
    Sleep     10

Commissioning Verification
    [Arguments]   ${alias}     ${scf_file}
    Perform Commissioning     scf_file=${scf_file}     verify_bts_status=False     alias=${alias}     timeout=600
    Sleep     10

Recommissioning Verification
    [Arguments]   ${alias}     ${delta_xml}
    Perform Recommissioning     type=delta     delta_file=${delta_xml}     should_activate=True     skip_parameter_relation_errors=True
    ...  alias=${alias}   rat=5g     timeout=120
    Sleep     10

Synchronization Information
    [Arguments]   ${alias}
    Get Sync Info     alias=${alias}     timeout=120
    Sleep     10

Mirroring Logs Verification
    [Arguments]   ${alias}
    Collect Mirroring Logs     dut=bts     output_file_name=sample_log     detailed_output=False     timeout=120     alias=${alias}
    Sleep     10

Get User Login Details
    [Arguments]   ${alias}
    Get User Login Info     dut=bts     alias=${alias}     timeout=120
    Sleep     10

Nms State Verification
    [Arguments]   ${alias}
    Get Nms State     dut=bts     detailed_output=False     alias=${alias}     timeout=60
    Sleep     10

SW Rollback Verification
    [Arguments]     ${alias}
    Rollback Software       verify_bts_status=true      is_config_reset=false       timeout=300      alias=${alias}
    Sleep     10

SCF Generation
    [Arguments]      ${alias}      ${scf_file}
    Generate Scf       target_file=${scf_file}       alias=${alias}     timeout=300      rat=5g
    Sleep    10

Create user account
    [Arguments]      ${username}     ${password}
    User Account Manage     operation=manage_local_user_account     new_username=${username}     new_password=${password}     enable=${True}
    Sleep     10
