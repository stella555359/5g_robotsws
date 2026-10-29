*** Settings ***
Documentation
            ...  CNI55294_NB-IoT_License_Control
            ...  = Author =
            ...    _damian.porebski@nokia.com_
            ...  = Maintainer =
            ...    _damian.porebski@nokia.com_
            ...  = Reviewer =
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - Capacity limitation (RP001033 SBTS Limitation Actions for License Management) for LTE mode
            ...    - If limitation started after Grace Period after removing licenses RL000370LK from CLS
            ...    - If limitation is cancelled after licenses RL000370LK adding
            ...  = Pre - requirements =
            ...    - eNB is OnAir, pvp=lteBTS
            ...    - There are no free licenses in CLS:
            ...      - RL000370LK (Licenses are removed during Test Preparation Step)
            ...  = Expected results =
            ...    - Test is marked as PASSED
            ...    - eNB is OnAir after test
            ...    - There are no addtional alarms present after test
            ...  = Additional Info =
            ...    N/A

Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         ute_admin_infomodel
Library         taf.nms.netact
Library         taf.sbts.oam.coam.admin

Resource        ../LM_resources/lib_SFE.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot


Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}   AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}

Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Upload in Teardown    AND
...                             Stop Capturing Logs And Collect    ${SUITE_STATUS}    AND
...                             Run Keyword And Ignore Error    interface.Common step trigger    AND
...                             Teardown Infomodel    AND
...                             Teardown Admin    AND
...                             Delete Node    cls-services    AND
...                             Delete Node    cls-db         AND
...                             Delete Node    cmwas         AND
...                             Clean All


*** Variables ***
${NMS_LAB}              srnclab2009
${ENB_ROOT_USER}        toor4nsn
${ENB_ROOT_PASS}        oZPS0POrRieRtu
@{backup_list}
@{license_list}         U0100172.XML
@{lic_serial_number}    9991240111409
@{modules_list}         SWEM for LTE FDD CM    SWEM for SRAN CM

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    Start Capturing Logs
    Log    \nCheck status of eNB before test    console=True
    Wait Until keyword Succeeds   5min    1min     ENB Status Check

Test Preparation
    [Documentation]    This test prepares all necessary files.
    Log    \nPrepare all necessary files for test.    console=True
    ${list_length}=    Get Length    ${license_list}
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${license_list[${i}]}
    END
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykĹ‚y CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}
    Append To List    ${ALLOWED_ALARMS}    7220

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Log    \nNumber of needed licenses is correct!    console=True
    Sleep    5min
    License Check In 41003 Alarm For IoT part

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Raports Generation and General Limitation Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 3
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{license_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Set Test Variable    ${License_template}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${License_template}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    5x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}

Final Checkpoint
    [Documentation]    This test restores initial eNB configuration and checks if it is OnAir.
    Check If Alarms From ENB And NetAct Are The Same v2
    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}
    Log    \nTest passed!    console=True

*** Keywords ***
General Limitation Check
    [Documentation]     This Keyword checks what kind of limitation is active.
    ...                 Check_list argument is list of expected limitations types which must be checked.
    ${alarms}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    @{list_of_expected_alarms}=    Create List    ${EMPTY}
    Append To List    ${list_of_expected_alarms}    IP Traffic Capacity Limit
    @{list_of_limitation_alarms}=    Create List    ${EMPTY}
    ${problemID}=    Set Variable    ${EMPTY}
    FOR  ${alarm}  IN  @{alarms}
        ${problemID}=    Set Variable  ${alarm.specificProblem}
        Run Keyword If    ${problemID} == 7110    Append To List  ${list_of_limitation_alarms}  ${alarm.additionalText1}
    END
    Log To Console    @{list_of_limitation_alarms}
    Log To Console    @{list_of_expected_alarms}
    List Should Contain Sub List  ${list_of_limitation_alarms}  ${list_of_expected_alarms}

SWEM Reports Generation
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    Get Module    moduleName=${swem_module}    detailed=${FALSE}
        Log    Generated module is:${module}    console=True
        ${report_id}=    Generate Reports    ${module}
        Log    Current module ID is:${report_id}    console=True
    END

ENB Status Check
    [Arguments]  ${expected}=&{EMPTY}
    Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}    ${expected}
    Check If Alarms From ENB and NetAct Are The Same v2

SWEM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    get_modules    moduleName=${swem_module}
        ${status}=    Generate Reports    ${module[0]}
    END

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2

License Check In 41003 Alarm For IoT part
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
        ${description}=     Get From Dictionary    ${alarm}   additionalText1
        Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    34274: 1/0
    END
    Log    Done!    console=True
