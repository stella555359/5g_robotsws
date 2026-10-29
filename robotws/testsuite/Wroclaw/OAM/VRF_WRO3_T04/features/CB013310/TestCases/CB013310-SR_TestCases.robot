*** Settings ***
Documentation
...    author:           Agnieszka Brzoska
...    contact:          agnieszka.brzoska@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/25R3/CB013310/
...    Description:       Feature extends the role "Application Administrator" for operations:
...                       downloading and activating SCF and browsing the information about certificates

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Resource    ../../../common_resources/connections/connections.robot

*** Variables ***
${local_password}=         Nokia@123
${app_user_account}=       BTSApplication
${read_user_account}=      BTSRead

*** Keywords ***
CB013310-SR_Access_to_SCF_config_and_certs_info_as_BTS_Application_user
    Log    Step 0: Precontition with change parameter,setup account and initialize certificate    console=True
    Change Parameter on BTS                  MRBTS-${BTS_ID}/EQM-1/APEQM-1    actRetResetDuringSiteReset    false
    Setup Local user account                 ${app_user_account}    ${local_password}
    Set CMP Server Settings                  key_pool_type=ECDSA
    Set CMP Server Settings                  key_pool_type=RSA
    Configure CMP                            ca_subject_name=CN=CB007672    bts_id=${SEC_MRBTS}
    Initialize Certificates
    Log    Step 1: Login as BTSApplication    console=True
    ${conn_app}=    Connect to ADMIN         username=${app_user_account}    password=${local_password}
    Log    Step 2: Change parameter, validate and activate SCF    console=True
    Change Parameter on BTS                  MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ...                                      actRetResetDuringSiteReset    true    connection=${conn_app}
    Log    Step 3: Browsing information about certificates   console=True
    ${certs}=    Get Certificates List       connection=${conn_app}
    Should not be empty                      ${certs}
    Log    Step 4: Reboot BTS and check Step 2 and 3 after reboot   console=True
    Reboot BTS and wait until available
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    ${conn_app}=    Connect to ADMIN         username=${app_user_account}   password=${local_password}
    Change Parameter on BTS                  MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ...                                      actRetResetDuringSiteReset    false    connection=${conn_app}
    ${certs}=                                Get Operator Certificates List    connection=${conn_app}
    Should not be empty                      ${certs}
    Log    Step 5: Robustness case with frequent snapshot collection and cancellation at random moments  console=True
    Run keyword and expect error             *Waiting for response*    Collect Snapshot Admin    timeout=10
    ...                                      connection=${conn_app}
    Sleep    10s                             reason=Waiting before cancelation snapshot
    Cancel Collecting Snapshot From BTS      connection=${conn_app}
    Run keyword and expect error             *Waiting for response*    Collect Snapshot Admin    timeout=10
    ...                                      connection=${conn_app}
    Sleep    30s                             reason=Waiting before cancelation snapshot
    Cancel Collecting Snapshot From BTS      connection=${conn_app}
    Run keyword and expect error             *Waiting for response*    Collect Snapshot Admin    timeout=10
    ...                                      connection=${conn_app}
    Sleep    50s                             reason=Waiting before cancelation snapshot
    Cancel Collecting Snapshot From BTS      connection=${conn_app}
    Change Parameter on BTS                  MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ...                                      actRetResetDuringSiteReset    true    connection=${conn_app}
    ${certs}=                                Get Operator Certificates List    connection=${conn_app}
    Should not be empty                      ${certs}
    Log    Step 6: Check BTSReadOnly user account- predicted robustness  console=True
    Setup Local user account                 ${read_user_account}    ${local_password}
    ${conn_read}=    Connect to ADMIN        username=${read_user_account}    password=${local_password}
    Run keyword and expect error            *Operation rejected due to no access permission*     Change Parameter on BTS
    ...                                      MRBTS-${BTS_ID}/EQM-1/APEQM-1    actRetResetDuringSiteReset
    ...                                      false    connection=${conn_read}
    Log    Step 7: Postcondition- disconnect from ADMIN and clear certificate  console=True
    [Teardown]            Run keywords       Run keyword and ignore error    Disconnect from ADMIN    ${conn_app}
    ...    AND                               Run keyword and ignore error    Disconnect from ADMIN    ${conn_read}
    ...    AND                               Clear Certificates
