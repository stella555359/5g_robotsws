*** Settings ***
Documentation

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../cloud_common_resources/rest_api/rest_api.robot
Resource    ../../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
${nms_name}    srnclab1047


*** Keywords ***
CB010214_D_BTS_System_Administrator_login_with_1RW_session_is_authorized_vCU
    Log    Step 1: Settings account for dcuser on Cloud BTS    console=True
    ${sw_version}=    _Get Active SW For NMS Integration    hw_type=vCU
    Change Service Account Password    username=dcuser    new_password=QAws123!@#    old_password=QAws123!@#    hw_type=vCU
    Log    Step 2: Changing the btsEMMaxSimulSession, btsEMRestrictAccSession, btsEMRestrictedAccessLogoutTimer    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictedAccessLogoutTimer    param_value=120    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsEMMaxSimulSession    param_value=10    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictAccSession    param_value=OneRWsessionAllowed    hw_type=vCU
    Log    Step 3: Integrate with NetAct without TLS    console=true
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU    sw_release=${sw_version}   preferred_lab=${nms_name}
    Log    Step 4: Creating 10 read-only session for Nemuadmin    console=True
    @{tokens}    Create List
    FOR    ${i}      IN RANGE    0    10
        ${login}=    rest_api.Perform REST login    ${Nemuadmin}    vCU    True
        ${token}=    rest_api.Get Token Value    ${login}
        Append To List    ${tokens}    ${token}
    END
    Log      Step 5: Login with read-write session for Nemuadmin and expect error    console=True
    Run Keyword and Expect Error   *    Connect to ADMIN    hw_type=vCU
    Sleep    130    reason=Wait until one read-only session will be closed because of read-write session
    Log      Step 6: Login with read-write session after 120s (after btsEMRestrictedAccessLogoutTimer)    console=True
    ${conn}=             Connect to ADMIN    hw_type=vCU
    ${sessions}=         Get Sessions List    hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate    len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal      ${session_count}    ${10}
    Log       Step 7: Login second read-write session and expect fail due to OneRWsessionAllowed    console=True
    Run Keyword and Expect Error   *    Connect to ADMIN    hw_type=vCU
    Log       Step 8: Closing all sessions (read-write and read-only)    console=True
    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    FOR    ${i}    IN RANGE    0    ${tokens.__len__()}
        rest_api.Perform REST logout    ${tokens}[${i}]    vCU
    END
    Log       Step 10: Login as dcuser    console=True
    ${login_1}=    rest_api.Perform REST login    ${DCUSER_PASS}    vCU
    ${token_1}=    rest_api.Get Token Value    ${login_1}
    rest_api.Perform REST logout   ${token_1}    vCU
    Log       Step 11: Changing the btsEMRestrictAccSession parameter to RWsessionCtrlNotActivated    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictAccSession    param_value=RWsessionCtrlNotActivated    hw_type=vCU
    Log       Step 12: Login read-write session (10 sessions)    console=True
    FOR    ${nr}    IN RANGE    0    9
        Connect to ADMIN            hw_type=vCU    alias=admin${nr}
    END
    # 9 sessions are established in loop, 1 is established later (to have one connection to proceed on BTS)
    ${conn}=    Connect to ADMIN          hw_type=vCU
    Run Keyword and Expect Error    *     Connect to ADMIN    hw_type=vCU
    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}  hw_type=vCU
    Log       Step 13: Deintegrate with NetAct and check if all sessions are established still    console=True
    ${sessions}=    Get Sessions List     hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate         len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal    ${session_count}    ${10}
    Log       Step 14: Login as dcuser       console=True
    ${login_1}=    rest_api.Perform REST login     ${DCUSER_PASS}    vCU
    ${token_1}=    rest_api.Get Token Value        ${login_1}
    rest_api.Perform REST logout   ${token_1}      vCU
    Log       Step 15: Changing the btsEMRestrictAccSession parameter to OneRWsessionAllowed    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1    pre-connection=${conn}    perform_logout=${False}
    ...                             param_name=btsEMRestrictAccSession    param_value=OneRWsessionAllowed    hw_type=vCU
    Sleep     130    reason=Wait until 9 sessions are terminated due to OneRWsessionAllowed
    ${sessions}=    Get Sessions List    hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate        len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal                      ${session_count}    ${1}
    Log       Step 16: Create second read-write session and expect error    console=True
    Run Keyword and Expect Error   *    Connect to ADMIN    hw_type=vCU
    Log       Step 17: Creating 9 sessions read-only    console=True
    @{tokens1}     Create List
    FOR    ${i}    IN RANGE    0    9
         ${login}=          rest_api.Perform REST login    ${Nemuadmin}    vCU    True
         ${token}=         rest_api.Get Token Value        ${login}
         Append To List    ${tokens1}             ${token}
    END
    Log       Step 18: Checking if 10 sessions (9 read-only and 1 read-write) are established    console=True
    ${sessions}=         Get Sessions List    hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate    len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal      ${session_count}    ${10}
    Disconnect from ADMIN     connection=${conn}    hw_type=vCU
    FOR    ${i}    IN RANGE    0    ${tokens1.__len__()}
        rest_api.Perform REST logout    ${tokens1}[${i}]    vCU
    END
    Log       Step 19: Setting up BTSSecurity account    console=True
    Setup Local User Account           account_type=BTSSecurity    password=QAws123!@#
    ...                                status=active    hw_type=vCU
    ${login}=    rest_api.Perform REST login    ${BTSSecurity}    vCU
    Log       Step 20: Login as Nemuadmin and expect error - one session is possible (BTSSecurity is logged)    console=True
    Run Keyword and Expect Error   *   Connect to ADMIN    hw_type=vCU
    Sleep     130    reason=Wait until BTSSecurity session is terminated due to Nemuadmin session
    Log       Step 21: Login as Nemuadmin and check if only one sessios is active    console=True
    ${conn}=             Connect to ADMIN       hw_type=vCU
    ${sessions}=         Get Sessions List      hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate               len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal      ${session_count}    ${1}
    [Teardown]  Run Keywords
    ...         Run Keyword and ignore error    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                                         param_name=btsEMRestrictAccSession
    ...                                         param_value=RWsessionCtrlNotActivated    hw_type=vCU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=btsMaxFailedLoginAttempts
    ...                                         param_value=0    hw_type=vCU

CB010214_E_Change_btsEMRestrictAccSession_for_local_users_vDU
    Log    Step 1: Settings account for dcuser on Cloud BTS    console=True
    ${sw_version}=    _Get Active SW For NMS Integration    hw_type=vDU
    Change Service Account Password    username=dcuser    new_password=QAws123!@#    old_password=QAws123!@#    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictedAccessLogoutTimer    param_value=120    hw_type=vDU
    Log    Step 2: Setting the btsEMMaxSimulSession, btsEMRestrictAccSession and btsEMRestrictedAccessLogoutTimer    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsEMMaxSimulSession    param_value=10    hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictAccSession    param_value=NoRWsessionAllowed    hw_type=vDU
    Log    Step 3: Performing reset and watiing for expected state (onAir)    console=True
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Log    Step 4: Checking if after reset parameters have the same values    console=True
    ${btsEMMaxSimulSession}=                Check Parameter Value    param_name=btsEMMaxSimulSession
    ...                                     dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    hw_type=vDU
    Should Be Equal                         ${btsEMMaxSimulSession}    10
    ${btsEMRestrictAccSession}=             Check Parameter Value    param_name=btsEMRestrictAccSession
    ...                                     dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1    hw_type=vDU
    Should Be Equal                         ${btsEMRestrictAccSession}    NoRWsessionAllowed
    ${btsEMRestrictedAccessLogoutTimer}=    Check Parameter Value    param_name=btsEMRestrictedAccessLogoutTimer
    ...                                     dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1    hw_type=vDU
    Should Be Equal                         ${btsEMRestrictedAccessLogoutTimer}    120
    Log    Step 5: Integrating Cloud BTS with NMS Lab without TLS    console=True
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vDU    sw_release=${sw_version}   preferred_lab=${nms_name}
    @{tokens}    Create List
    Log    Step 6: Performing 10 logins via REST API with Nemuadmin account    console=True
    FOR    ${i}    IN RANGE    0    10
         ${login}=        rest_api.Perform REST login    ${Nemuadmin}    vDU    True
         ${token}=         rest_api.Get Token Value      ${login}
         Append To List    ${tokens}            ${token}
    END
    Log    Step 7: Performing 11. login via REST API and expect error    console=True
    ${login_2}=        rest_api.Perform REST login    login_command=${Nemuadmin}    hw_type=vDU    read_only=True
    Should Contain     ${login_2}            Too many simultaneous sessions
    Log    Step 8: Performing logout via REST API    console=true
    FOR    ${i}    IN RANGE    0    ${tokens.__len__()}
        rest_api.Perform REST logout    ${tokens}[${i}]    vDU
    END
    Log    Step 9: Performing 10 logins via REST API with Nemuadmin account    console=True
    @{tokens1}     Create List
    FOR    ${i}    IN RANGE    0    10
         ${login}=         rest_api.Perform REST login    ${Nemuadmin}    vDU    True
         ${token}=         rest_api.Get Token Value       ${login}
         Append To List    ${tokens1}            ${token}
    END
    Log    Step 10: Perform login via REST API with dcuser account    console=True
    ${login_1}=    rest_api.Perform REST login    ${DCUSER_PASS}    vDU
    ${token_1}=    rest_api.Get Token Value       ${login_1}
    rest_api.Perform REST logout                  ${token_1}    vDU
    Log    Step 11: Deintegrating Cloud BTS from NMS Lab    console=True
    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vDU
    Log    Step 12: Login to Nemuadmin and expect error because 10 session RO are established    console=True
    Run Keyword and Expect Error    *     Connect to ADMIN    hw_type=vDU
    Sleep    130    reason=Wait until one read-only session will be closed because of read-write session
    Log    Step 13: Login with read-write session and change parameter    console=True
    Change Parameter on BTS               dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                                   param_name=btsEMRestrictAccSession    param_value=OneRWsessionAllowed    hw_type=vDU
    ${conn}=    Connect to ADMIN          hw_type=vDU
    Log    Step 14: Perform login via REST API with dcuser account    console=True
    ${login_1}=    rest_api.Perform REST login     ${DCUSER_PASS}    vDU
    ${token_1}=    rest_api.Get Token Value        ${login_1}
    rest_api.Perform REST logout                   ${token_1}    vDU
    Disconnect from ADMIN                 connection=${conn}    hw_type=vDU
    Log    Step 15: Changing btsEMRestrictAccSession to NoRWsessionAllowed value    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictAccSession    param_value=NoRWsessionAllowed    hw_type=vDU
    FOR    ${i}    IN RANGE    0    ${tokens1.__len__()}
        rest_api.Perform REST logout    ${tokens1}[${i}]    vDU
    END
    ${btsEMRestrictAccSession}=    Check Parameter Value    param_name=btsEMRestrictAccSession
    ...                            dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1    hw_type=vDU
    Should Be Equal                ${btsEMRestrictAccSession}    NoRWsessionAllowed
    Log    Step 16: Integrating Cloud BTS with NMS Lab without TLS    console=True
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vDU    sw_release=${sw_version}   preferred_lab=${nms_name}
    Log    Step 17: Login as Nemuadmin read-write session and expect error due to login restriction    console=True
    Run Keyword And Expect Error    *     Connect to ADMIN    hw_type=vDU
    Log    Step 18: Deintegrating Cloud BTS from NMS Lab    console=True
    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vDU
    ${conn}=    Connect to ADMIN          hw_type=vDU
    Log    Step 19: Changing btsEMRestrictAccSession to RWsessionCtrlNotActivated value    console=True
    Change Parameter on BTS               dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1    pre-connection=${conn}    perform_logout=${False}
    ...                                   param_name=btsEMRestrictAccSession    param_value=RWsessionCtrlNotActivated    hw_type=vDU
    Disconnect from ADMIN                 connection=${conn}    hw_type=vDU
    Log    Step 20: Integrating Cloud BTS with NMS Lab without TLS    console=True
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vDU    sw_release=${sw_version}   preferred_lab=${nms_name}
    Log    Step 21: Creating 10 session read-write for Nemuadmin and expect error login 11. times    console=True
    FOR    ${nr}    IN RANGE    0    9
        Connect to ADMIN        hw_type=vDU    alias=admin${nr}
    END
    ${conn}                              Connect to ADMIN    hw_type=vDU
    Run Keyword And Expect Error    *    Connect to ADMIN    hw_type=vDU
    Disconnect from ADMIN                hw_type=vDU    connection=${conn}
    FOR    ${nr}    IN RANGE     0    9
        Disconnect from ADMIN    hw_type=vDU    connection=admin${nr}
    END
    @{tokens2}    Create List
    Log    Step 22: Performing 10 logins via REST API with dcuser account    console=True
    FOR    ${i}    IN RANGE    0    9
         ${login}=         rest_api.Perform REST login    ${Nemuadmin}    vDU    True
         ${token}=         rest_api.Get Token Value       ${login}
         Append To List    ${tokens2}            ${token}
    END
    ${login_correct}    rest_api.Perform REST login    ${Nemuadmin}    vDU    True
    ${login_error}      rest_api.Perform REST login    ${Nemuadmin}    vDU    True
    Should Contain      ${login_error}    Too many simultaneous sessions
    ${token_correct}    rest_api.Get Token Value       ${login_correct}
    rest_api.Perform REST logout   ${token_correct}          vDU
    Log    Step 23: Deintegrating Cloud BTS from NMS Lab    console=True
    Deintegrate Cloud BTS from NMS Lab              LAB_NAME=${NMS_LAB}    hw_type=vDU
    ${conn}=             Connect to ADMIN          hw_type=vDU
    Log    Step 24: Checking if Nemuadmin has 10 session active    console=True
    ${sessions}=         Get Sessions List    hw_type=vDU    pre-connection=${conn}
    ${session_count}=    Evaluate             len([x for x in ${sessions} if x['user']== 'Nemuadmin'])
    Should Be Equal      ${session_count}    ${10}
    FOR    ${i}    IN RANGE    0    ${tokens2.__len__()}
        rest_api.Perform REST logout    ${tokens2}[${i}]    vCU
    END
    Disconnect from ADMIN                         hw_type=vDU    connection=${conn}
    [Teardown]  Run Keywords
    ...         Run Keyword and ignore error    Disconnect from ADMIN    connection=${conn}    hw_type=vDU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                                         param_name=btsEMRestrictAccSession
    ...                                         param_value=RWsessionCtrlNotActivated    hw_type=vDU
    ...         AND                             Run Keyword And Ignore Error
    ...                                         Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vDU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=btsEMMaxSimulSession    param_value=10    hw_type=vDU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=btsMaxFailedLoginAttempts
    ...                                         param_value=0    hw_type=vDU

CB010214_D_B_Use_dcuser_for_DCAP_vCU
    Log    Step 1: Changing parameter to allowed maximum 10 session at the same time    console=True
    ${sw_version}=    _Get Active SW For NMS Integration    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictedAccessLogoutTimer    param_value=120    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsEMMaxSimulSession    param_value=10    hw_type=vCU
    Log    Step 2: Changing parameter to restrict login    console=True
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=btsEMRestrictAccSession    param_value=NoRWsessionAllowed    hw_type=vCU
    Log    Step 3: Setting the DCAP user credentials    console=True
    Change Service Account Password    username=dcuser    new_password=QAws123!@#    old_password=QAws123!@#    hw_type=vCU
    Log    Step 4: Integrating Cloud BTS with NMS Lab without TLS and verifying login restriction    console=True
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU    sw_release=${sw_version}   preferred_lab=${nms_name}
    Run Keyword and Expect Error    *    Connect to ADMIN    hw_type=vCU
    @{tokens}    Create List
    Log    Step 5: Performing 10 logins via REST API with dcuser account    console=True
    FOR    ${i}    IN RANGE    0    10
        ${login}=         rest_api.Perform REST login    ${DCUSER_PASS}    vCU
        ${token}=         rest_api.Get Token Value        ${login}
        Append To List    ${tokens}             ${token}
    END
    Sleep    5s
    Log    Step 6: Verifying that 10 sessions were established by dcuser    console=True
    Deintegrate Cloud BTS from NMS Lab             LAB_NAME=${NMS_LAB}    hw_type=vCU
    ${conn}=             Connect to ADMIN          hw_type=vCU
    ${sessions}=         Get Sessions List         hw_type=vCU    pre-connection=${conn}
    ${session_count}=    Evaluate                  len([x for x in ${sessions} if x['user']== 'dcuser'])
    Should Be Equal    ${session_count}    ${10}
    Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    Log    Step 6: Performing 10 login via REST API with Nemuadmin account   console=True
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU    sw_release=${sw_version}   preferred_lab=${nms_name}
    @{tokens1}    Create List
    FOR    ${i}    IN RANGE    0    10
        ${login}=         rest_api.Perform REST login    ${Nemuadmin}    vCU    True
        ${token}=         rest_api.Get Token Value       ${login}
        Append To List    ${tokens}             ${token}
    END
    FOR    ${i}    IN RANGE    0    ${tokens.__len__()}
        rest_api.Perform REST logout         ${tokens}[${i}]    vCU
    END
    FOR    ${i}    IN RANGE    0    ${tokens1.__len__()}
        rest_api.Perform REST logout         ${tokens1}[${i}]    vCU
    END

    Log    Step 7: Deintegrating Cloud BTS from NMS Lab and resetting session limit to 1    console=True
    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsEMMaxSimulSession    param_value=1    hw_type=vCU
    Log    Step 8: Performing 1 login via REST API with dcuser account    console=True
    ${login_1}=           rest_api.Perform REST login    ${DCUSER_PASS}    vCU
    ${token_1}=           rest_api.Get Token Value       ${login_1}
    Log    Step 11: Establish 2. session with dcuser via REST API failed because restricted session limit to 1    console=True
    ${login_2}=           rest_api.Perform REST login    ${DCUSER_PASS}    vCU
    Should Contain        ${login_2}    Too many simultaneous sessions
    rest_api.Perform REST logout   ${token_1}    vCU
    [Teardown]  Run Keywords
    ...        Run Keyword and ignore error     Disconnect from ADMIN    connection=${conn}    hw_type=vCU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                                         param_name=btsEMRestrictAccSession
    ...                                         param_value=RWsessionCtrlNotActivated    hw_type=vCU
    ...         AND                             Run Keyword And Ignore Error
    ...                                         Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vCU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=btsEMMaxSimulSession    param_value=10    hw_type=vCU
    ...         AND                             Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=btsMaxFailedLoginAttempts
    ...                                         param_value=0    hw_type=vCU
