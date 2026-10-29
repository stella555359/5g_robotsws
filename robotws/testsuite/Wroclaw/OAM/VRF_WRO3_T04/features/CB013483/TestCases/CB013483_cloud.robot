*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB013483. CB013484 verifies if there are restrictions for parameters when BTS is in India.

Resource    ../Resources/CB013483_resources_cloud.robot
Library     ../Resources/CB013483_resources_cloud.py
Resource     ../../../cloud_common_resources/mantaray/mantaray.robot
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/connections/connections.robot

Library      taf.config.scf    WITH NAME   scf
Library      OperatingSystem
Library      DateTime

*** Variables ***

@{parameter_list}=            passwdHistoryLength     localPasswdExpiryPeriod
...                           btsMaxFailedLoginAttempts        btsSessionLoginDelay
@{MOC_list}=                  MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
...                           MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
@{non_India_values}=           1    0    0    1
@{error_list}=                SECADM have passwdHistoryLength >= 3
...                           LUAC have localPasswdExpiryPeriod > 0
...                           btsMaxFailedLoginAttempts <> 0 if (every NRBTS(mcc in range '404'|'405'|'406') exist
...                           btsSessionLoginDelay >= 5 if (every NRBTS(mcc in range '404'|'405'|'406') exist
${mcc_India}=                 404
${mcc_eu}=                    1
${NetAct_name}=               srnclab1027


*** Keywords ***
CB013483-CR-C_21_ITSAR_compliancy_for_WebEM_session_timeout_for_non-India_Deployment_vCU_vDU_via_NMS
    ${NMS_LAB}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vDU   nidd_check=True
    Log    Step 1: Set webEMSessionLogoutTimer to 120 and jwtExpirationTime to 10   console=true
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    webEMSessionLogoutTimer=120
    ...    jwtExpirationTime=10
    Log    Step 2: Open new WebEM session and check if it espires after 2 min    console=true
    ${session_time}=    log_to_webem_and_check_logout_timer_inactive   Nemuadmin    Nokia@123    ${LMP_VDU_IP}
    Log    ${session_time}
    run keyword if    115 <= ${session_time} <= 140    Log    Expiration time is ok
    ...    ELSE  fail
    Log    Step 4: Repeat for mcc=404
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    localPasswdExpiryPeriod=90
    ...    btsMaxFailedLoginAttempts=5
    ...    btsSessionLoginDelay=5
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${MRBTS}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=3
    ...    LAB_NAME=${NMS_LAB}
    Change mcc parameter
    ...    ${mcc_India}
    ...    hw_type=vDU
    ...    LAB_NAME=${NMS_LAB}
    Sleep    60
    ${session_time}=    log_to_webem_and_check_logout_timer_inactive   Nemuadmin    Nokia@123    ${LMP_VDU_IP}
    Log    ${session_time}
    run keyword if    115 <= ${session_time} <= 140    Log    Expiration time is ok
    ...    ELSE  fail
    [Teardown]    Run Keywords   Change mcc parameter
    ...           ${mcc_eu}
    ...           hw_type=vDU
    ...           LAB_NAME=${NMS_LAB}
    ...           AND   Deintegrate Cloud BTS from NMS Lab   LAB_NAME=${NMS_LAB}   hw_type=vDU

CB013483-CR-C_12_Termination_of_Idle_WebEM_Session_for_vDU-Interaction_between_JWT_Expiry_Timer_and_WebEM_Session_Logout_Timer
    Log    Step 1: Set webEMSessionLogoutTimer to 720 and jwtExpirationTime to 15   console=true
    ${dn}=         Create List      MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                             MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${pn}=         Create List      webEMSessionLogoutTimer    jwtExpirationTime
    ${pv1}=        Create List      120    15
    ${pv2}=        Create List      720    10
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv1}    hw_type=vDU
    Log    Step 2: Stay idle on WebEM to check if the session is ended after token expires    console=true
    ${session_time}=    log_to_webem_and_check_logout_timer_inactive   ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${LMP_VDU_IP}
    Log    ${session_time}
    run keyword if    120 <= ${session_time} <= 150    Log    Expiration time is ok
    ...    ELSE  fail
    Log    Step 3: Set webEMSessionLogoutTimer to 120 and jwtExpirationTime to 10   console=true
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv2}    hw_type=vDU
    Sleep    60
    Log    Step 4: Perform actions on WebEM to check if the session is ended after token expires    console=true
    ${session_time}=    log_to_webem_and_check_logout_timer_active   ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${LMP_VDU_IP}
    Log    ${session_time}
    run keyword if    590 <= ${session_time} <= 621    Log    Expiration time is ok
    ...    ELSE  fail

CB013483-CR-C_03_ITSAR_Compliance_for_India_Deployment_vCU_via_NMS
    Log     Step 1: Make sure parameters have India non-compliant values    console=true
    ${NMS_LAB}=     mantaray.Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU   nidd_check=True    preferred_lab=srnclab1047
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    localPasswdWarningPeriod=0
    ...    localPasswdExpiryPeriod=0
    ...    btsMaxFailedLoginAttempts=0
    ...    btsSessionLoginDelay=1
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=0
    ...    LAB_NAME=${NMS_LAB}
    Log     Step 2: Change location to India and expect validation errors    console=true
    Run Keyword And Expect Error    *Validation failed*
    ...    Change mcc parameter
    ...    ${mcc_India}
    ...    hw_type=vCU
    ...    LAB_NAME=${NMS_LAB}
    Log     Step 3: Change parameter values to India compliant and check if validation errors are cleared    console=true
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    localPasswdExpiryPeriod=90
    ...    btsMaxFailedLoginAttempts=5
    ...    btsSessionLoginDelay=5
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=3
    ...    LAB_NAME=${NMS_LAB}
    Change mcc parameter
    ...    ${mcc_India}
    ...    hw_type=vCU
    ...    LAB_NAME=${NMS_LAB}
    Log     Step 4: Try changing parameter values non-compliant to India and check if validation errors are raised
    ${lengh}=    get length    ${parameter_list}
    FOR    ${i}  IN RANGE    ${lengh}
        ${param_name}=            Get From List     ${parameter_list}       ${i}
        ${param_value}=           Get From List     ${non_India_values}     ${i}
        ${moc}=                   Get From List     ${MOC_list}             ${i}
        ${error}=                 Get From List     ${error_list}           ${i}
        Run Keyword And Expect Error    *${error}*
        ...    Change Parameter with NMS
        ...    MOC_DN=${moc}
        ...    param_name=${param_name}
        ...    param_value=${param_value}
        ...    LAB_NAME=${NMS_LAB}
    END
    [Teardown]    Run Keywords    Change mcc parameter      ${mcc_eu}    hw_type=vCU    LAB_NAME=${NMS_LAB}
    ...    AND    Deintegrate Cloud BTS from NMS Lab
    ...    LAB_NAME=${NMS_LAB}
    ...    hw_type=vCU

CB013483-CR-C_07_ITSAR_Compliance_for_non-India_Deployment_vCU_via_NMS
    Log    Step 1: Make sure parameters are set to India compliant values    console=true
    ${NMS_LAB}=     mantaray.Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU   nidd_check=True   preferred_lab=srnclab1047
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    localPasswdExpiryPeriod=90
    ...    btsMaxFailedLoginAttempts=5
    ...    btsSessionLoginDelay=5
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=3
    ...    LAB_NAME=${NMS_LAB}
    Log    Step 2: Make sure BTS location is not set to India   console=true
    Change mcc parameter
    ...    param_value=${mcc_eu}
    ...    hw_type=vCU
    ...    LAB_NAME=${NMS_LAB}
    Sleep    60
    Log    Step 3: Configure parameters to India non-complant values   console=true
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    localPasswdWarningPeriod=0
    ...    localPasswdExpiryPeriod=0
    ...    btsMaxFailedLoginAttempts=0
    ...    btsSessionLoginDelay=2
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=0
    ...    LAB_NAME=${NMS_LAB}
    [Teardown]    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=vCU
