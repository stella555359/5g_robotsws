*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB013483. CB013484 verifies if there are restrictions for parameters when BTS is in India.

Resource    ../Resources/CB013483_resources.robot
Resource     ../../../common_resources/mantaray/mantaray.robot
Resource     ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Library      taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library      taf.config.scf    WITH NAME   scf
Library      OperatingSystem

*** Variables ***
@{parameter_list}=            allowLocalUserDefaultPassword    passwdHistoryLength     localPasswdExpiryPeriod
...                           btsMaxFailedLoginAttempts        btsSessionLoginDelay

@{non_India_values}=          true     1    0    0    1
@{error_list}=                allowLocalUserDefaultPassword = 'false'
...                           shall be greater than or equal to 3
...                           shall be greater than 0
...                           shall not be equal to 0
...                           shall be greater than or equal to 5
${mcc_India}                  404
${mcc_eu}                     540

*** Keywords ***
CB013483-SR-A_02_ITSAR_Compliance_for_India_Deployment_via_NMS
    Log     Step 1: Make sure parameters have India non-compliant values    console=true
    Change Multiple Parameters on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    allowLocalUserDefaultPassword=true
    ...    localPasswdExpiryPeriod=0
    ...    localPasswdWarningPeriod=0
    ...    btsMaxFailedLoginAttempts=0
    ...    btsSessionLoginDelay=1
    Change Parameter on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=1
    Log     Step 2: Change location to India and expect validation errors    console=true
    Run Keyword And Expect Error    *ErrorCode: 23*
    ...    Change mcc parameter    ${mcc_India}
    Log     Step 3: Change parameter values to India compliant and check if validation errors are cleared    console=true
    Change Multiple Parameters on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    allowLocalUserDefaultPassword=false
    ...    localPasswdExpiryPeriod=2
    ...    localPasswdWarningPeriod=1
    ...    btsMaxFailedLoginAttempts=1
    ...    btsSessionLoginDelay=5
    Change Parameter on BTS
    ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=3
    Wait Until Keyword Succeeds     5x    1min    Change mcc parameter
    ...    param_value=${mcc_India}
    Log     Step 4: Try changing parameter values non-compliant to India and check if validation errors are raised
    @{MOC_list}=    Set Variable          MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                           MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                           MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ${lengh}=    get length    ${parameter_list}
    FOR    ${i}  IN RANGE    ${lengh}
        ${param_name}=            Get From List     ${parameter_list}       ${i}
        ${param_value}=           Get From List     ${non_India_values}     ${i}
        ${moc}=                   Get From List     ${MOC_list}             ${i}
        ${error}=                 Get From List     ${error_list}           ${i}
        Run Keyword And Expect Error    *${error}*
        ...    Change Parameter on BTS
        ...    dist_name=${moc}
        ...    param_name=${param_name}
        ...    param_value=${param_value}
    END
    #Part for CB014041 feature (small feature, no sensa to create new test for it)
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    Change mcc parameter    param_value=${mcc_eu}
              ...    AND          Change Parameter on BTS
              ...    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
              ...    param_name=allowLocalUserDefaultPassword
              ...    param_value=true


CB013483-SR-A_04_ITSAR_Compliance_for_non-India_Deployment_via_NMS
    Log    Step 1: Make sure parameters are set to India compliant values    console=true
    ${NMS_LAB}    Integrate BTS to MantaRay without TLS    NIDD_CHECK=True
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    allowLocalUserDefaultPassword=false
    ...    localPasswdExpiryPeriod=90
    ...    btsMaxFailedLoginAttempts=5
    ...    btsSessionLoginDelay=5
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=3
    ...    LAB_NAME=${NMS_LAB}
    Log    Step 2: Make sure BTS location is not set to India   console=true
    Change mcc parameter NMS
    ...    param_value=${mcc_eu}
    ...    LAB_NAME=${NMS_LAB}
    Sleep    60
    Log    Step 3: Configure parameters to India non-complant values   console=true
    Change Multiple Parameters with NMS
    ...    MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    LAB_NAME=${NMS_LAB}
    ...    allowLocalUserDefaultPassword=true
    ...    localPasswdWarningPeriod=0
    ...    localPasswdExpiryPeriod=0
    ...    btsMaxFailedLoginAttempts=0
    ...    btsSessionLoginDelay=2
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=passwdHistoryLength
    ...    param_value=0
    ...    LAB_NAME=${NMS_LAB}
    Change Parameter with NMS
    ...    MOC_DN=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=webEMSessionLogoutTimer
    ...    param_value=120
    ...    LAB_NAME=${NMS_LAB}
    [Teardown]    Deintegrate BTS from MantaRay    ${NMS_LAB}
