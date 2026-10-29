*** Settings ***
Documentation
...    author:             Agnieszka Brzoska
...    contact:            agnieszka.brzoska@nokia.com
...    Test Plan (QC):     /VRF_WRO3_T04/25R3/CB013310/
...    Description:        Feature extends the role "Application Administrator" for operations:
...                        downloading and activating SCF and browsing the information about certificates


Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
${local_password}=        Nokia@1234
${MRBTS_CU}=              ${tl.gnbs[0].cu.global_bts_id}
${MRBTS}=                 ${tl.gnbs[0].instance_id}
${app_user_account}=      BTSApplication
${read_user_account}=     BTSRead
@{CRAN}                   vCU    vDU

*** Keywords ***
CB013310-CR_Access_to_SCF_config_and_certs_info_as_BTS_Application_user_vCU_vDU
    FOR    ${i}    IN    @{CRAN}
        ${MRBTS_IP}    Set Variable If    '${i}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
        Log    Step 0: Precontition- change parameter,setup account and initialize certificate    console=True
        Change Parameter on BTS                  MRBTS-${MRBTS_IP}/TNLSVC-1/PMTNLINT-1    ipFilteringInterval
        ...                                      15min    hw_type=${i}
        Setup Local User Account                 ${app_user_account}    ${local_password}    active    hw_type=${i}
        Configure CMP                            ca_subject_name=CN=CB007672    hw_type=${i}
        Update CMP Server Settings               hw_type=${i}
        Initialize Certificate                   hw_type=${i}
        Log    Step 1: Login as BTSApplication    console=True
        ${conn_app}=    Connect to ADMIN         username=${app_user_account}    password=${local_password}    hw_type=${i}
        Log    Step 2: change parameter, validate and activate SCF   console=True
        Change Parameter on BTS                  MRBTS-${MRBTS_IP}/TNLSVC-1/PMTNLINT-1    ipFilteringInterval
        ...                                      30min    hw_type=${i}    pre-connection=${conn_app}
        Log    Step 3: Browsing information about certificates   console=True
        ${certs}=    Check Certificates          hw_type=${i}    pre-connection=${conn_app}
        Should not be empty                      ${certs}
        Log    Step 4: Reboot BTS and check Step 2 and 3 after reboot   console=True
        Perform Reset and Wait for Expected State    state=onAir   hw_type=${i}
        Check if Unit Status is OnAir            hw_type=${i}
        ${conn_app}=    Connect to ADMIN         username=${app_user_account}    password=${local_password}    hw_type=${i}
        Log    Step 5: change parameter, validate and activate SCF   console=True
        Change Parameter on BTS                  MRBTS-${MRBTS_IP}/TNLSVC-1/PMTNLINT-1    ipFilteringInterval
        ...                                      5min    hw_type=${i}    pre-connection=${conn_app}
        Log    Step 6: Browsing information about certificates   console=True
        ${certs}=    Check Certificates          hw_type=${i}    #connection=${conn_app}
        Should not be empty                      ${certs}
        Log    Step 7: Robustness case with frequent snapshot collection and cancellation at random moments  console=True
        ${id}=    Trigger Snapshot Collection    hw_type=${i}
        Sleep    10                              reason=Waiting before cancelation snapshot
        Run Keyword If    '${i}'=='vCU'    vcu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    connection=${conn_app}
        ...    ELSE IF    '${i}'=='vDU'    vdu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    vdu_connection=${conn_app}
        Sleep    40                              reason=Waiting before next triggering snapshot${i}${i}
        ${id}=    Trigger Snapshot Collection    hw_type=${i}
        Sleep    30                              reason=Waiting before cancelation snapshot
        Run Keyword If    '${i}'=='vCU'    vcu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    connection=${conn_app}
        ...    ELSE IF    '${i}'=='vDU'    vdu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    vdu_connection=${conn_app}
        Sleep    40                              reason=Waiting before next triggering snapshot
        ${id}=    Trigger Snapshot Collection    hw_type=${i}
        Sleep    50                              reason=Waiting before cancelation snapshot
        Run Keyword If    '${i}'=='vCU'    vcu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    connection=${conn_app}
        ...    ELSE IF    '${i}'=='vDU'    vdu_admin.Cancel Snapshot Operation      operation_id=${id}
        ...                                timeout=10    vdu_connection=${conn_app}
        Log    Step 8: Check BTSReadOnly user account- predicted robustness  console=True
        Setup Local User Account                 ${read_user_account}    ${local_password}    active    hw_type=${i}
        ${conn_read}=    Connect to ADMIN        username=${read_user_account}    password=${local_password}    hw_type=${i}
        Run keyword and expect error             *Method Not Allowed*    Change Parameter on BTS
        ...                                      MRBTS-${MRBTS_IP}/TNLSVC-1/PMTNLINT-1    ipFilteringInterval
        ...                                      30min   hw_type=${i}    pre-connection=${conn_read}
        Log    Step 9: Browsing information about certificates   console=True
        Run keyword and expect error             *Method Not Allowed*   Check Certificates
        ...                                      hw_type=${i}    pre-connection=${conn_read}
    END
    Log    Step 10: Postcondition- disconnect from ADMIN and clear certificate  console=True
    [Teardown]                               Run keywords
    ...                                      Run keyword and ignore error   Disconnect from ADMIN
    ...                                      ${conn_app}    hw_type=vDU
    ...    AND                               Run keyword and ignore error    Disconnect from ADMIN
    ...                                      ${conn_read}    hw_type=vDU
    ...    AND                               Delete All Certificates    hw_type=vDU
    ...    AND                               Run keyword and ignore error   Disconnect from ADMIN
    ...                                      ${conn_app}    hw_type=vCU
    ...    AND                               Run keyword and ignore error    Disconnect from ADMIN
    ...                                      ${conn_read}    hw_type=vCU
    ...    AND                               Delete All Certificates    hw_type=vCU
