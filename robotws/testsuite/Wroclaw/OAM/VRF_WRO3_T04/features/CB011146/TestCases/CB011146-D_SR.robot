*** Settings ***
Documentation
...    author:          Agnieszka Brzoska
...    contact:         agnieszka.brzoska@nokia.com
...    Test Plan (QC):  Root/Test_Sets/25R3/New_Features/VRF_WRO3_T04/CB011146
...    Description:     The CB011146 feature introduces new REST API interface.

Resource    ../../../common_resources/rest_api/rest_api.robot

*** Keywords ***
CB011146-SR-D_M2m_user_account_operations
    Add Multiple Alarms to Watchdog List    61642    4775
    Log    Step 0: Precondition- setup user account    console=True
    Setup Local user account      ${app_user_account}    ${app_password}
    Log    Step 1: Change parameter on BTS    console=True
    Change Parameter on BTS       MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    btsMaxFailedLoginAttempts    0
    Log    Step 2: Log to Webem with wrong REST creditentials several times   console=True
    #Using a loop to perform multiple login attempts
    FOR    ${index}               IN RANGE    5
    ${login_status}=              Perform REST login    ${wronglogin_2}
    Should Contain                ${login_status}    Authentication failed
    Sleep    5s                   reason=btsSessionLoginDelay
    END
    Log    Step 3: Log to WebEM with correct REST creditentials  console=True
    ${rest_login}=               Perform REST login    ${login_2}
    Log    Step 4: Perform logout from webEM using REST command   console=True
    ${token_value}=              Get Token Value       ${rest_login}
    ${output}=                   Perform REST logout   ${token_value}
    Should Contain               ${output}             HTTP Status: 204
    Log    Step 5: Change parameter on BTS- btsMaxFailedLoginAttempts    console=True
    Change Parameter on BTS      MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    btsMaxFailedLoginAttempts    2
    Log    Step 6: Change parameter on BTS- lockout duration    console=True
    Change Parameter on BTS     MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    btsAccountLockoutDuration    1
    Log    Step 7: Log to Webem with wrong creditentials 3 times- we want to lock account   console=True
    #Using a loop to perform multiple login attempts
    FOR    ${index}             IN RANGE    3
    ${login_status}=            Perform REST login    ${wronglogin_2}
    Should Contain              ${login_status}    Authentication failed
    Sleep    5s                 reason=btsSessionLoginDelay
    END
    ${login_status}=            Perform REST login    ${wronglogin_2}
    Should Contain              ${login_status}       Locked user
    Sleep    15s                reason=btsSessionLoginDelay
    Log    Step 8: Try to log to WebEM with correct creditentials- account is locked    console=True
    ${rest_login}=             Perform REST login    ${login_2}
    Should contain             ${rest_login}    Account locked due to a predefined number of consecutive failed logins
    Log    Step 9: Log as Admin and change BTS account lockout duration to different value    console=True
    ${rest_login}=    Perform REST login    ${login_2}
    Should Contain             ${rest_login}         SSL connection using TLS
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    btsAccountLockoutDuration    2
    Log    Step 10: Change parameter and log in to BTSApplication    console=True
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    jwtExpirationTime    10
    ${rest_login_1}=           Perform REST login   ${login_3}
    Should Contain             ${rest_login_1}    SSL connection using TLS
    Log    Step 11: Using wrong credential until account is locked    console=True
    #Using a loop to perform multiple login attempts
    FOR    ${index}           IN RANGE    3
    ${login_status}=          Perform REST login    ${wronglogin_3}
    Should Contain            ${login_status}    Authentication failed
    Sleep    5s               reason=btsSessionLoginDelay
    END
    ${login_status}=          Perform REST login    ${wronglogin_3}
    Should Contain            ${login_status}       Locked user
    Sleep    15s              reason=btsSessionLoginDelay
    Log    Step 12: Check SW version using token from step 10 and compare it with SW from WebEM    console=True
    ${token_value}=           Get Token Value    ${rest_login_1}
    ${rest_sw_version}=       Get Information using REST Command    ${get_sw}    ${token_value}
    ${connection}=            Connect to ADMIN
    ${webem_sw_version}=      coam_admin.Get SW Version        connection=${connection}
    Disconnect from ADMIN     ${connection}
    Should Contain            ${rest_sw_version}    ${webem_sw_version}
    Log    Step 13: Enable parameter enableUserAccountCtrlAlarm and activate cnum user- check alarm    console=True
    Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    enableUserAccountCtrlAlarm    true
    ${NMS_LAB}                Integrate BTS to MantaRay with TLS
    nms.activate_cnum
    ...                       ne_id_value=PLMN-PLMN/MRBTS-${BTS_ID}
    ...                       alias=${NMS_LAB}
    ...                       ldap_access_type=STARTTLS
    ...                       ip_type=IPv4
    Wait Until Keyword Succeeds    10min    1min    Wait For CNUM alarm
    Log    Step 14: Waiting for expiration token and try to use inactive token    console=True
    Sleep    600s             reason=waiting about 10min until token expired
    ${token_value}=           Get Token Value       ${rest_login_1}
    ${rest_sw_version}=       Get Information using REST Command    ${get_sw}    ${token_value}
    ${connection}=            Connect to ADMIN
    ${webem_sw_version}=      coam_admin.Get SW Version        connection=${connection}
    Disconnect from ADMIN     ${connection}
    Should Not Contain        ${rest_sw_version}    ${webem_sw_version}
    [Teardown]                Run keywords    Run Keyword and ignore error   Clear Certificates
    ...    AND                Change Parameter on BTS    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    enableUserAccountCtrlAlarm    false
    ...    AND                Run Keyword and ignore error    nms.deactivate_cnum    ne_id_value=PLMN-PLMN/MRBTS-${BTS_ID}
    ...                       alias=${NMS_LAB}
    ...    AND                Deintegrate BTS from MantaRay    ${NMS_LAB}
    ...    AND                Clear Certificates
