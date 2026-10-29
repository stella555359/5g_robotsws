*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/25R2/CB012187/
...    Description:     Verify that AllowedLifetime and AllowedIdlePeriod parameters are working as they shoould.

Resource    ../Resources/CB012187-CR_Keywords.robot
Resource    ../../../cloud_common_resources/emssim/emssim_setup.robot

Library     DateTime

*** Variables ***
${idle_per_value}=     Inactivity_Period_Update
${life_time_value}=    Lifetime_Update

${stress_attempts}=    31    #Number of repetitions (+1) of each stress set
${read_only_stress_attempts}=    11    #Number of repetitions (+1) of each stress set
${primary_crldp}=      10.42.54.11:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary

${sys_username}=      BTSSystem
${app_username}=      BTSApplication
${sec_username}=      BTSSecurity
${read_username}=     BTSRead
${local_password}=    Qwerty!23$

*** Keywords ***
Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_WebEM_without_privileges_vCU
    Log                                  Precondition: LUACREQ object should not exist    console=True
    ${exist}=                            Check if Object Exists in Scf File    object_name=LUACREQ-1
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/CMD-1    hw_type=vCU
    Run Keyword If                       ${exist}    Run Keyword and Ignore Error    Delete Object on BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/CMD-1/LUACREQ-1    hw_type=vCU
    ${pre_dn}=    Create List            MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${pre_pn}=    Create List            sysAdmAllowedLifetime       sysAdmAllowedIdlePeriod
    ...                                  localUserAllowedLifetime    localUserAllowedIdlePeriod
    ${pre_pv}=    Create List            10    10    10    10
    Change Multiple Parameters on BTS    ${pre_dn}    ${pre_pn}    ${pre_pv}    hw_type=vCU
    Log                                  Step 1/9: Login as Application Admin    console=True
    Setup Local User Account             account_type=${app_username}    password=${local_password}
    ...                                  status=active    hw_type=vCU
    ${conn_app}=                         Connect to ADMIN     username=${app_username}
    ...                                  password=${local_password}    alias=app    hw_type=vCU
    Log                                  Step 2/10: Try to change parameters as Application Admin    console=True
    ${dn}=        Create List            MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${pn_sys}=    Create List            sysAdmAllowedLifetime       sysAdmAllowedIdlePeriod
    ${pn_loc}=    Create List            localUserAllowedLifetime    localUserAllowedIdlePeriod
    ${pv}=        Create List            100    100
    Run Keyword and Expect Error         *user_restricted*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_sys}    ${pv}    hw_type=vCU    pre-connection=${conn_app}
    Run Keyword and Expect Error         *user_restricted*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_loc}    ${pv}    hw_type=vCU    pre-connection=${conn_app}
    Disconnect from ADMIN                connection=${conn_app}    hw_type=vCU
    Log                                  Step 3/12: Login as Read Only user    console=True
    Setup Local User Account             account_type=${read_username}    password=${local_password}
    ...                                  status=active    hw_type=vCU
    ${conn_read}=                        Connect to ADMIN     username=${read_username}
    ...                                  password=${local_password}    alias=read    hw_type=vCU
    Log                                  Step 4/13: Try to change parameters as Read Only user    console=True
    Run Keyword and Expect Error         *Method Not Allowed*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_sys}    ${pv}    hw_type=vCU    pre-connection=${conn_read}
    Run Keyword and Expect Error         *Method Not Allowed*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_loc}    ${pv}    hw_type=vCU    pre-connection=${conn_read}
    Disconnect from ADMIN                connection=${conn_read}    hw_type=vCU
    Log                                  Step 5: Connect as CNUM Application Admin    console=True
    Configure CMP                        ca_subject_name=C=PL, O=Common, CN=IPSEC    hw_type=vCU
    Update CMP Server Settings           hw_type=vCU
    Initialize Certificate               hw_type=vCU
    Setup environment for EMSSIM         hw_type=vCU
    ${nms_dn}=    Create List            MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${nms_pn}=    Create List            actRestrictLoginToCnum    appAdmActivated
    ...                                  secAdmActivated    readOnlyActivated
    ${nms_pv}=    Create List            true    true    true    true
    Change Multiple Parameters on BTS    ${nms_dn}    ${nms_pn}    ${nms_pv}    hw_type=vCU
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA    hw_type=vCU
    execute_command_on_emssim            command=ldap_user_add ${app_username} ${local_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${app_username} -password
    ...                                              ${local_password} -type bts_application -status enabled
    execute_command_on_emssim            command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_app}=                    Connect to ADMIN     username=${app_username}
    ...                                  password=${local_password}    alias=app    hw_type=vCU
    Log                                  Step 6/15: Try to change parameters as Application Admin    console=True
    Run Keyword and Expect Error         *user_restricted*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_sys}    ${pv}    hw_type=vCU    pre-connection=${conn_cnum_app}
    Run Keyword and Expect Error         *user_restricted*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_loc}    ${pv}    hw_type=vCU    pre-connection=${conn_cnum_app}
    Disconnect from ADMIN                connection=${conn_cnum_app}    hw_type=vCU
    Log                                  Step 7: Connect as CNUM Read Only User    console=True
    execute_command_on_emssim            command=ldap_user_add ${read_username} ${local_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${read_username} -password
    ...                                              ${local_password} -type bts_read -status enabled
    execute_command_on_emssim            command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_read}=                   Connect to ADMIN     username=${read_username}
    ...                                  password=${local_password}    alias=app    hw_type=vCU
    Log                                  Step 8/16: Try to change parameters as Read Only user    console=True
    Run Keyword and Expect Error         *Method Not Allowed*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_sys}    ${pv}    hw_type=vCU    pre-connection=${conn_cnum_read}
    Run Keyword and Expect Error         *Method Not Allowed*
    ...                                  Change Multiple Parameters on BTS
    ...                                  ${dn}    ${pn_loc}    ${pv}    hw_type=vCU    pre-connection=${conn_cnum_read}
    Disconnect from ADMIN                connection=${conn_cnum_read}    hw_type=vCU
    [Teardown]    Run Keywords           Disconnect From EMSSIM    ${emssim_connection}
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  connection=${conn_app}     hw_type=vCU
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  connection=${conn_read}    hw_type=vCU
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  connection=${conn_cnum_app}     hw_type=vCU
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  connection=${conn_cnum_read}    hw_type=vCU
    ...    AND                           Delete All Certificates         hw_type=vCU

Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_REST_API_with_BTS_Local_User_Accounts_vCU
    Log                                  Precondition: LUACREQ object should not exist    console=True
    ${exist}=                            Check if Object Exists in Scf File    object_name=LUACREQ-1
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/CMD-1    hw_type=vCU
    Run Keyword If                       ${exist}    Run Keyword and Ignore Error    Delete Object on BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/CMD-1/LUACREQ-1    hw_type=vCU
    ${pre_dn}=    Create List            MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${pre_pn}=    Create List            sysAdmAllowedLifetime       sysAdmAllowedIdlePeriod
    ...                                  localUserAllowedLifetime    localUserAllowedIdlePeriod
    ${pre_pv}=    Create List            10    10    10    10
    Change Multiple Parameters on BTS    ${pre_dn}    ${pre_pn}    ${pre_pv}    hw_type=vCU
    Log                                  Step 2/4: Try to update parameters with value -1    console=True
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedLifetime
    ...                                  param_value=-1    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedIdlePeriod
    ...                                  param_value=-1    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedLifetime
    ...                                  param_value=-1    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedIdlePeriod
    ...                                  param_value=-1    hw_type=vCU
    Log                                  Step 3/5: Try to update parameters with value 10000    console=True
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedLifetime
    ...                                  param_value=10000    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedIdlePeriod
    ...                                  param_value=10000    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedLifetime
    ...                                  param_value=10000    hw_type=vCU
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedIdlePeriod
    ...                                  param_value=10000    hw_type=vCU
    Log                                  Step 6-7: Change parameters to special value 0    console=True
    ${dn}=    Create List                MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${pn}=    Create List                sysAdmAllowedLifetime       sysAdmAllowedIdlePeriod
    ...                                  localUserAllowedLifetime    localUserAllowedIdlePeriod
    ${pv}=    Create List                0    0    0    0
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU
    Log                                  Step 8-9: Verify ExpDate parameters    console=True
    Sleep                                10s    reason=Give some time to those parameters
    ${sysAdmLifetime}=                   Check Parameter Value    param_name=sysAdmLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${sysAdmIdlePer}=                    Check Parameter Value    param_name=sysAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${localUserLifetime}=                Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${secAdmIdlePer}=                    Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${appAdmIdlePer}=                    Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${readOnlyIdlePer}=                  Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    Run Keyword and Continue on Failure    Should be Empty    ${sysAdmLifetime}
    Run Keyword and Continue on Failure    Should be Empty    ${sysAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${localUserLifetime}
    Run Keyword and Continue on Failure    Should be Empty    ${secAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${appAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${readOnlyIdlePer}
    Log                                  Step 10-11: Change parameters to max value 9999    console=True
    ${pv9}=    Create List               9999    9999    9999    9999
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv9}    hw_type=vCU
    Log                                  Step 12-17: Verify ExpDate parameters    console=True
    Sleep                                10s    reason=Give some time to those parameters
    ${sysAdmLifetime}=                   Check Parameter Value    param_name=sysAdmLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${sysAdmIdlePer}=                    Check Parameter Value    param_name=sysAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${localUserLifetime}=                Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${secAdmIdlePer}=                    Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${appAdmIdlePer}=                    Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${readOnlyIdlePer}=                  Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${currentDate}=                        Get Current Date
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDate}     time=10000 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain    ${sysAdmLifetime}       ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Run Keyword and Continue on Failure    Should Contain    ${sysAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${localUserLifetime}    ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${readOnlyIdlePer}      ${expectedDate}
    Change Multiple Parameters on BTS    ${pre_dn}    ${pre_pn}    ${pre_pv}    hw_type=vCU
    Log                                  Step 19: Login as Security Admin    console=True
    Setup Local User Account             account_type=${sec_username}    password=${local_password}
    ...                                  status=active    hw_type=vCU
    ${conn_sec}=                         Connect to ADMIN     username=${sec_username}
    ...                                  password=${local_password}    alias=sec    hw_type=vCU
    Log                                  Step 2/4: Try to update parameters with value -1    console=True
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedLifetime
    ...                                  param_value=-1    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedIdlePeriod
    ...                                  param_value=-1    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedLifetime
    ...                                  param_value=-1    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedIdlePeriod
    ...                                  param_value=-1    hw_type=vCU    pre-connection=${conn_sec}
    Log                                  Step 3/5: Try to update parameters with value 10000    console=True
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedLifetime
    ...                                  param_value=10000    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=sysAdmAllowedIdlePeriod
    ...                                  param_value=10000    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedLifetime
    ...                                  param_value=10000    hw_type=vCU    pre-connection=${conn_sec}
    Run Keyword and Expect Error         *Incorrect value*    Change Parameter On BTS
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  param_name=localUserAllowedIdlePeriod
    ...                                  param_value=10000    hw_type=vCU    pre-connection=${conn_sec}
    Log                                  Step 6-7: Change parameters to special value 0    console=True
    ${dn}=    Create List                MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${pn}=    Create List                sysAdmAllowedLifetime       sysAdmAllowedIdlePeriod
    ...                                  localUserAllowedLifetime    localUserAllowedIdlePeriod
    ${pv}=    Create List                0    0    0    0
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN                connection=${conn_sec}    hw_type=vCU
    Log                                  Step 8-9: Verify ExpDate parameters    console=True
    Sleep                                10s    reason=Give some time to those parameters
    ${sysAdmLifetime}=                   Check Parameter Value    param_name=sysAdmLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${sysAdmIdlePer}=                    Check Parameter Value    param_name=sysAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${localUserLifetime}=                Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${secAdmIdlePer}=                    Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${appAdmIdlePer}=                    Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${readOnlyIdlePer}=                  Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    Run Keyword and Continue on Failure    Should be Empty    ${sysAdmLifetime}
    # We can't check that one because of the other system admin connections
    # Run Keyword and Continue on Failure    Should Contain    ${sysAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should be Empty    ${localUserLifetime}
    Run Keyword and Continue on Failure    Should be Empty    ${secAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${appAdmIdlePer}
    Run Keyword and Continue on Failure    Should be Empty    ${readOnlyIdlePer}
    ${conn_sec}=                         Connect to ADMIN     username=${sec_username}
    ...                                  password=${local_password}    alias=sec    hw_type=vCU
    Log                                  Step 10-11: Change parameters to max value 9999    console=True
    ${pv9}=    Create List               9999    9999    9999    9999
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv9}    hw_type=vCU    pre-connection=${conn_sec}
    Disconnect from ADMIN                connection=${conn_sec}    hw_type=vCU
    Log                                  Step 12-17: Verify ExpDate parameters    console=True
    Sleep                                10s    reason=Give some time to those parameters
    ${sysAdmLifetime}=                   Check Parameter Value    param_name=sysAdmLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${sysAdmIdlePer}=                    Check Parameter Value    param_name=sysAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${localUserLifetime}=                Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${secAdmIdlePer}=                    Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${appAdmIdlePer}=                    Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${readOnlyIdlePer}=                  Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                  dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vCU
    ${currentDate}=                        Get Current Date
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDate}     time=10000 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain    ${sysAdmLifetime}       ${expectedDate}
    # We can't check that one because of the other system admin connections
    # Run Keyword and Continue on Failure    Should Contain    ${sysAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${localUserLifetime}    ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain    ${readOnlyIdlePer}      ${expectedDate}
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${conn_sec}    hw_type=vCU

Check_if_handler_LUACRES_is_present_after_restart_or_plan_activation_vDU
    Log           Precondition: LUACREQ object should not exist    console=True
    ${exist}=     Check if Object Exists in Scf File      object_name=LUACREQ-1
    ...           dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1    hw_type=vDU
    Run Keyword If    ${exist}    Run Keyword and Ignore Error    Delete Object on BTS
    ...                           dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    hw_type=vDU
    Log           Precondition: LUAC parameters are not equal 0    console=True
    ${pre_dn}=    Create List    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                          MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${pre_pn}=    Create List    sysAdmAllowedIdlePeriod       sysAdmAllowedLifetime
    ...                          localUserAllowedIdlePeriod    localUserAllowedLifetime
    ${pre_pv}=    Create List    30    30    30    30
    Change Multiple Parameters on BTS    ${pre_dn}    ${pre_pn}    ${pre_pv}    hw_type=vDU
    Log           Step 1-3: Create LUACREQ object    console=True
    ${pn}=        Create List    localUserAllowedIdlePerUpdate    localUserAllowedLifetimeUpdate
    ${pv}=        Create List    ${idle_per_value}    ${life_time_value}
    Create Object with Multiple Parameters on BTS     dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                               param_names=${pn}    param_values=${pv}    hw_type=vDU
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should be True    ${exist_1}
    Should be True    ${exist_2}
    Log            Step 4: Perform Reset    console=True
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Log            Step 5: Check if LUACREQ and LUACRES objects still exist    console=True
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should be True    ${exist_1}
    Should be True    ${exist_2}
    Log            Step 6: Try to change parameters values in LUACREQ object   console=True
    ${dn}=         Create List    MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ${pn}=         Create List    sysAdmAllowedIdlePerUpdate    sysAdmAllowedLifetimeUpdate
    ${pv}=         Create List    ${idle_per_value}    ${life_time_value}
    Run Keyword and Expect Error    *is unmodifiable*    Change Multiple Parameters on BTS
    ...                                                  ${dn}    ${pn}    ${pv}    hw_type=vDU
    Log            Step 7: Change local user parameters in LUAC object and verify them in LUAC_R object    console=True
    ${dn}=         Create List    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${pn}=         Create List    localUserAllowedIdlePeriod    localUserAllowedLifetime
    ${pv}=         Create List    50    50
    Change Multiple Parameters on BTS      ${dn}    ${pn}    ${pv}    hw_type=vDU
    Sleep                                  10s    reason=Give some time to those parameters
    ${localUserLifetime}=                  Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${secAdmIdlePer}=                      Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${appAdmIdlePer}=                      Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${readOnlyIdlePer}=                    Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${currentDate}=                        Get Current Date
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDate}     time=51 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain      ${localUserLifetime}    ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${readOnlyIdlePer}      ${expectedDate}
    Log            Step 8: Check if LUACREQ and LUACRES objects still exist    console=True
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should be True    ${exist_1}
    Should be True    ${exist_2}
    Log            Step 9: Delete LUACREQ object   console=True
    Run Keyword and Ignore Error    Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                     hw_type=vDU
    ${exist}=      Check if Object Exists in Scf File       object_name=LUACREQ-1
    ...            dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1     hw_type=vDU
    Should not be True    ${exist}
    Log            Step 10: Check if LUACREQ and LUACRES objects don't exist    console=True
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should not be True     ${exist_1}
    Should not be True     ${exist_2}
    [Teardown]    Run Keyword and Ignore Error    Delete Object on BTS
    ...                                           dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    hw_type=vDU

BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_vDU
    Log           Precondition: LUACREQ object should not exist    console=True
    ${exist}=     Check if Object Exists in Scf File      object_name=LUACREQ-1
    ...           dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1    hw_type=vDU
    Run Keyword If    ${exist}    Run Keyword and Ignore Error    Delete Object on BTS
    ...                           dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    hw_type=vDU
    Log           Precondition: LUAC parameters are not equal 0    console=True
    ${pre_dn}=    Create List    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                          MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${pre_pn}=    Create List    sysAdmAllowedIdlePeriod       sysAdmAllowedLifetime
    ...                          localUserAllowedIdlePeriod    localUserAllowedLifetime
    ${pre_pv}=    Create List    30    30    30    30
    Change Multiple Parameters on BTS    ${pre_dn}    ${pre_pn}    ${pre_pv}    hw_type=vDU
    Log                                  Step 1: Connect as CNUM Application Admin    console=True
    Configure CMP                        ca_subject_name=C=PL, O=Common, CN=IPSEC    hw_type=vDU
    Update CMP Server Settings           hw_type=vDU
    Initialize Certificate               hw_type=vDU
    Setup environment for EMSSIM         hw_type=vDU
    ${nms_dn}=    Create List            MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${nms_pn}=    Create List            actRestrictLoginToCnum    appAdmActivated
    ...                                  secAdmActivated    readOnlyActivated
    ${nms_pv}=    Create List            true    true    true    true
    Change Multiple Parameters on BTS    ${nms_dn}    ${nms_pn}    ${nms_pv}    hw_type=vDU
    ${emssim_connection}=                Connect and Activate EMSSIM    cert_type=RSA    hw_type=vDU
    execute_command_on_emssim            command=ldap_user_add ${app_username} ${local_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${app_username} -password
    ...                                              ${local_password} -type bts_application -status enabled
    execute_command_on_emssim            command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_app}=                    Connect to ADMIN     username=${app_username}
    ...                                  password=${local_password}    alias=app    hw_type=vDU
    Log                                  Step 2/6: Try to create LUACREQ object    console=True
    ${pn}=                               Create List    localUserAllowedIdlePerUpdate    localUserAllowedLifetimeUpdate
    ${pv}=                               Create List    ${idle_per_value}    ${life_time_value}
    Run Keyword and Expect Error         *user_restricted*    Create Object with Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    param_names=${pn}
    ...                                  param_values=${pv}    hw_type=vDU    pre-connection=${conn_cnum_app}
    Disconnect from ADMIN                connection=${conn_cnum_app}     hw_type=vDU
    Log                                  Step 3: Connect as CNUM Read Only user    console=True
    execute_command_on_emssim            command=ldap_user_add ${read_username} ${local_password} -a RW
    ...                                  connection=${emssim_connection}
    Sleep    30                          reason=Executing command
    ${command}=                          Catenate    user_info_update -username ${read_username} -password
    ...                                              ${local_password} -type bts_read -status enabled
    execute_command_on_emssim            command=${command}
    ...                                  connection=${emssim_connection}
    Sleep    90                          reason=Executing command
    ${conn_cnum_read}=                   Connect to ADMIN     username=${read_username}
    ...                                  password=${local_password}    alias=app    hw_type=vDU
    Log                                  Step 4/7: Try to create LUACREQ object    console=True
    Run Keyword and Expect Error         *Method Not Allowed*    Create Object with Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    param_names=${pn}
    ...                                  param_values=${pv}    hw_type=vDU    pre-connection=${conn_cnum_read}
    Disconnect from ADMIN                connection=${conn_cnum_read}     hw_type=vDU
    Log                                  Step 8: Connect as BTS Application Admin    console=True
    Setup Local User Account             account_type=${app_username}    password=${local_password}
    ...                                  status=active    hw_type=vDU
    ${conn_app}=                         Connect to ADMIN     username=${app_username}
    ...                                  password=${local_password}    alias=app    hw_type=vDU
    Log                                  Step 9/13: Try to create LUACREQ object    console=True
    Run Keyword and Expect Error         *user_restricted*    Create Object with Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    param_names=${pn}
    ...                                  param_values=${pv}    hw_type=vDU    pre-connection=${conn_app}
    Disconnect from ADMIN                connection=${conn_app}     hw_type=vDU
    Log                                  Step 10: Connect as BTS Read Only user    console=True
    Setup Local User Account             account_type=${read_username}    password=${local_password}
    ...                                  status=active    hw_type=vDU
    ${conn_read}=                        Connect to ADMIN     username=${read_username}
    ...                                  password=${local_password}    alias=read    hw_type=vDU
    Log                                  Step 11/14: Try to create LUACREQ object    console=True
    Run Keyword and Expect Error         *Method Not Allowed*    Create Object with Multiple Parameters on BTS
    ...                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    param_names=${pn}
    ...                                  param_values=${pv}    hw_type=vDU    pre-connection=${conn_read}
    Disconnect from ADMIN                connection=${conn_read}     hw_type=vDU
    Log                                  Step 16: Create LUACREQ object without local user parameters    console=True
    ${pn}=                               Create List     sysAdmAllowedIdlePerUpdate    sysAdmAllowedLifetimeUpdate
    ${pv}=                               Create List     ${idle_per_value}    ${life_time_value}
    Create Object with Multiple Parameters on BTS        dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                  param_names=${pn}    param_values=${pv}    hw_type=vDU
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should be True                                       ${exist_1}
    Should be True                                       ${exist_2}
    Log                           Step 17: Try to create LUACREQ object with local user parameters    console=True
    ${pn}=                        Create List     localUserAllowedIdlePerUpdate    localUserAllowedLifetimeUpdate
    ${pv}=                        Create List     ${idle_per_value}    ${life_time_value}
    Run Keyword and Expect Error                         *Unsupported operation*
    ...                                                  Create Object with Multiple Parameters on BTS
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                  param_names=${pn}    param_values=${pv}    hw_type=vDU
    ${exist_1}=    Check if Object Exists in Scf File    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1
    ...                                                  object_name=LUACREQ-1    hw_type=vDU
    ${exist_2}=    Run Keyword and Return Status         Check Parameter Value
    ...                                                  dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1/LUACRES-1
    ...                                                  param_name=luacResId     hw_type=vDU
    Should be True    ${exist_1}
    Should be True    ${exist_2}
    Log                             Step 19: Delete LUACREQ object    console=True
    Run Keyword and Ignore Error    Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                     hw_type=vDU
    ${exist}=                       Check if Object Exists in Scf File      object_name=LUACREQ-1
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1    hw_type=vDU
    Should not be True              ${exist}
    ${step}=                        Catenate    Step 20-21: Try to create LUACREQ object while local user
    ...                                         parameters in LUAC object are equal to special value 0
    Log                             ${step}     console=True
    ${zero_dn}=    Create List      MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${zero_pn}=    Create List      localUserAllowedIdlePeriod    localUserAllowedLifetime
    ${zero_pv}=    Create List      0    0
    Change Multiple Parameters on BTS    ${zero_dn}    ${zero_pn}    ${zero_pv}    hw_type=vDU
    Run Keyword and Expect Error    *not equal 0*    Create Object with Multiple Parameters on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                             param_names=${pn}    param_values=${pv}    hw_type=vDU
    Log                             Step 22: Change local user parameters in LUAC object   console=True
    ${ten_pv}=    Create List       10    10
    Change Multiple Parameters on BTS    ${zero_dn}    ${zero_pn}    ${ten_pv}    hw_type=vDU
    Log                             Step 23-26: Create LUACREQ object with local user parameters   console=True
    Create Object with Multiple Parameters on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                              param_names=${pn}    param_values=${pv}    hw_type=vDU
    Log                             Step 27: Try to activate system admin parameters in LUACREQ object   console=True
    ${dn}=    Create List           MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1    MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ${pn}=    Create List           sysAdmAllowedIdlePerUpdate    sysAdmAllowedLifetimeUpdate
    ${pv}=    Create List           ${idle_per_value}    ${life_time_value}
    Run Keyword and Expect Error    *is unmodifiable*    Change Multiple Parameters on BTS
    ...                                                  ${dn}    ${pn}    ${pv}    hw_type=vDU
    Log                             Step 28: Delete LUACREQ object    console=True
    Run Keyword and Ignore Error    Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                     hw_type=vDU
    ${exist}=                       Check if Object Exists in Scf File      object_name=LUACREQ-1
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1    hw_type=vDU
    Should not be True              ${exist}
    Log                             Step 29: Connect as CNUM Security Admin    console=True
    execute_command_on_emssim       command=ldap_user_add ${sec_username} ${local_password} -a RW
    ...                             connection=${emssim_connection}
    Sleep    30                     reason=Executing command
    ${command}=                     Catenate    user_info_update -username ${sec_username} -password
    ...                                         ${local_password} -type bts_security -status enabled
    execute_command_on_emssim       command=${command}
    ...                             connection=${emssim_connection}
    Sleep    90                     reason=Executing command
    ${conn_cnum_sec}=               Connect to ADMIN     username=${sec_username}
    ...                             password=${local_password}    alias=app    hw_type=vDU
    Log                             Step 30: Create LUACREQ object    console=True
    ${pn}=                          Create List       localUserAllowedIdlePerUpdate    localUserAllowedLifetimeUpdate
    ${pv}=                          Create List       ${idle_per_value}    ${life_time_value}
    Create Object with Multiple Parameters on BTS     dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                               param_names=${pn}    param_values=${pv}    hw_type=vDU
    ...                                               pre-connection=${conn_cnum_sec}
    Log                                    Step 31: Update localUserAllowedLifetime parameter   console=True
    Change Parameter On BTS                dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                    param_name=localUserAllowedLifetime
    ...                                    param_value=50    hw_type=vDU    pre-connection=${conn_cnum_sec}
    Log                                    Step 32: Verify localUserLifetimeExpDate parameter    console=True
    ${localUserLifetime}=                  Check Parameter Value    param_name=localUserLifetimeExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ...                                    pre-connection=${conn_cnum_sec}
    ${currentDate}=                        Get Current Date
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDate}     time=51 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain      ${localUserLifetime}    ${expectedDate}
    Log                             Step 33: Delete LUACREQ object    console=True
    Run Keyword and Ignore Error    Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1/LUACREQ-1
    ...                                                     hw_type=vDU    pre-connection=${conn_cnum_sec}
    ${exist}=                       Check if Object Exists in Scf File      object_name=LUACREQ-1
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CMD-1    hw_type=vDU
    ...                             pre-connection=${conn_cnum_sec}
    Should not be True              ${exist}
    Log                             Step 34-35: Create LUACREQ object via NMS    console=True
    Wait Until Keyword Succeeds     10x    30sec    Create LUACREQ via EMSsim on vDU    ${emssim_connection}
    Log                             Step 36: Update localUserAllowedIdlePeriod parameter via NMS     console=True
    execute_command_on_emssim       command=edit localUserAllowedIdlePeriod.LUAC-1-1-1 50
    ...                             connection=${emssim_connection}
    Sleep    90                     reason=Executing command
    Disconnect from ADMIN                  connection=${conn_cnum_sec}     hw_type=vDU
    Log                                    Step 37-39: Verify local user Idle Period parameters   console=True
    Sleep                                  10s    reason=Give some time to those parameters
    ${secAdmIdlePer}=                      Check Parameter Value    param_name=secAdmIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${appAdmIdlePer}=                      Check Parameter Value    param_name=appAdmIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${readOnlyIdlePer}=                    Check Parameter Value    param_name=readOnlyIdlePerExpDate
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1    hw_type=vDU
    ${currentDate}=                        Get Current Date
    ${expectedDate_plus}=                  Add Time to Date    date=${currentDate}     time=51 days
    ${expectedDate}=                       Fetch From Left     ${expectedDate_plus}    ${SPACE}
    Run Keyword and Continue on Failure    Should Contain      ${secAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${appAdmIdlePer}        ${expectedDate}
    Run Keyword and Continue on Failure    Should Contain      ${readOnlyIdlePer}      ${expectedDate}
    [Teardown]    Run Keywords    Disconnect From EMSSIM          ${emssim_connection}
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                           connection=${conn_app}     hw_type=vDU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                           connection=${conn_read}    hw_type=vDU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                           connection=${conn_cnum_app}     hw_type=vDU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                           connection=${conn_cnum_read}    hw_type=vDU
    ...    AND                    Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                           connection=${conn_cnum_sec}     hw_type=vDU
    ...    AND                    Delete All Certificates         hw_type=vCU

Stressful_robustness_test_for_REST_API_vDU
    ${object_exist}=     Check if Object Exists in Scf File    object_name=CRLDPCONFIG-1
    ...                  dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/    hw_type=vDU
    Run Keyword If       ${object_exist}    Delete Object on BTS
    ...                                     dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1    hw_type=vDU
    ${state_before}=     Get Current BTS State         hw_type=vDU
    ${alarms_before}=    Get Active Alarms From BTS    hw_type=vDU
    ${alarms_list}=      Get from Dictionary    ${alarms_before}    alarms
    @{fault_ids_before}=     Create List
    FOR    ${fault}    IN    @{alarms_list}
        ${fault_id}=         Get From Dictionary    ${fault}    fault_id
        Append to List       ${fault_ids_before}    ${fault_id}
    END
    Set Test Variable    ${state_before}
    Set Test Variable    ${fault_ids_before}
    FOR    ${try}    IN RANGE    1    ${stress_attempts}
        Log    Stress test as System Admin, nr: ${try}    console=True
        Run Keyword and Continue on Failure    Positive stress set
    END
    Setup Local User Account    account_type=${read_username}    password=${local_password}    status=active    hw_type=vDU
    ${conn_read_1}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read1    hw_type=vDU
    ${conn_read_2}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read2    hw_type=vDU
    ${conn_read_3}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read3    hw_type=vDU
    ${conn_read_4}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read4    hw_type=vDU
    ${conn_read_5}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read5    hw_type=vDU
    ${conn_read_6}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read6    hw_type=vDU
    @{read_conns}=     Create List    ${conn_read_1}    ${conn_read_2}    ${conn_read_3}
    ...                               ${conn_read_4}    ${conn_read_5}    ${conn_read_6}
    Set Test Variable    @{read_conns}
    FOR    ${try}    IN RANGE    1    ${read_only_stress_attempts}
        Log    Stress test as Read Only User, nr: ${try}    console=True
        Run Keyword and Continue on Failure    Negative stress set
    END
    Disconnect from all Read Only sessions
    ${conn_read_1}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read1    hw_type=vDU
    ${conn_read_2}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read2    hw_type=vDU
    ${conn_read_3}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read3    hw_type=vDU
    ${conn_read_4}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read4    hw_type=vDU
    ${conn_read_5}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read5    hw_type=vDU
    ${conn_read_6}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read6    hw_type=vDU
    @{read_conns}=     Create List    ${conn_read_1}    ${conn_read_2}    ${conn_read_3}
    ...                               ${conn_read_4}    ${conn_read_5}    ${conn_read_6}
    Set Test Variable    @{read_conns}
    FOR    ${try}    IN RANGE    1    ${read_only_stress_attempts}
        Log    Stress test as Read Only User, nr: ${try}    console=True
        Run Keyword and Continue on Failure    Negative stress set
    END
    Disconnect from all Read Only sessions
    ${conn_read_1}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read1    hw_type=vDU
    ${conn_read_2}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read2    hw_type=vDU
    ${conn_read_3}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read3    hw_type=vDU
    ${conn_read_4}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read4    hw_type=vDU
    ${conn_read_5}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read5    hw_type=vDU
    ${conn_read_6}=    Connect to ADMIN    username=${read_username}    password=${local_password}
    ...                                    alias=read6    hw_type=vDU
    @{read_conns}=     Create List    ${conn_read_1}    ${conn_read_2}    ${conn_read_3}
    ...                               ${conn_read_4}    ${conn_read_5}    ${conn_read_6}
    Set Test Variable    @{read_conns}
    FOR    ${try}    IN RANGE    1    ${read_only_stress_attempts}
        Log    Stress test as Read Only User, nr: ${try}    console=True
        Run Keyword and Continue on Failure    Negative stress set
    END
    [Teardown]    Disconnect from all Read Only sessions
