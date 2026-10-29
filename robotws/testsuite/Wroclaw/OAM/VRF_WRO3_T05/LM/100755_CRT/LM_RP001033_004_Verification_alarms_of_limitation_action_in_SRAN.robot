*** Settings ***
Documentation
            ...  OAM_LM_RP001033_004_Verification_alarms_of_limitation_action_in_SRAN
            ...  (former: LTE2621-B.047_Verification_alarms_of_General_Limitation_part9)
            ...  = Author =
            ...    _damian.porebski@nokia.com_
            ...  = Maintainer =
            ...    _bartosz.wasielewski@nokia.com_
            ...    _agnieszka.bala@nokia.com_
            ...  = Reviewer =
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    -if limitation starts after Grace Period
            ...    -if Ip Traffic Limitation is active when SR001004LK SBTS Data User LK license is missing
            ...    -if limitation is cancelled after license adding
            ...  = Pre - requirements =
            ...    -Activate modulation scheme UL is not set to 64 QAM
            ...    -license SR001004LK SBTS Data User LK is not avaiable in CLS
            ...    -license RL000286LK 64 QAM in UL LTU is not avaiable in CLS
            ...    -all other licenses are added to CLS
            ...    -at least one UE has been atached to eNB
            ...  = Expected results =
            ...    -Test is marked as PASSED
            ...    -Enb is OnAir after test
            ...    -There are no addtional alarms present after test
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
...                             Run Keyword And Ignore Error    Clear Test Data Files    AND
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
@{licence_list}         V5100175.XML    U5000838.XML
@{lic_serial_number}    0011159199105    9991058588929
@{modules_list_PM}      SWEM for SRAN PM
@{modules_list_CM}      SWEM for LTE FDD CM
${TEST_DATA_FILES}      ${CURDIR}/../LM_resources/Plans/LM_RP001033_004_Verification_alarms_of_limitation_action_in_SRAN/
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    Start Capturing Logs
    Log    \nSetting test variables    console=True
    Log    \nDone!    console=True
    ${list_length}=    Get Length    ${licence_list}
    Set Suite Variable   ${list_length}    ${list_length}
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Prepare Test Data Files
    Wait Until keyword Succeeds   5min    1min     ENB Status Check

Test Preparation
    [Documentation]    This test prepare all necessary files.
    Log    \nPrepare all necessary files for test    console=True
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${licence_list[${i}]}
    END
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}
    Prepare and Import All Plans From Directory v2    ${TEST_DATA_FILES}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appeares if license is missing.
    Log    \nReports Generation and Alarm 41003 Checking.    console=True
    Log    \nPerform SWEM PM Reports Generation    console=True
    SWEM PM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Sleep     5min
    License Check In 41003 Alarm For RP001033_004 part I

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Reports Generation and IP Traffic Limitation Checking.    console=True
    Log    \nPerform SWEM PM Reports Generation    console=True
    SWEM PM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    20x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 3
    [Documentation]    This test activates 64 QAM modulation.
    Log    \nProvision with 64 QAM in uplink Activation and Checking.    console=True
    Provision Plan     plan_name=${ENB_ID}_plan_1
    Run Keyword And Ignore Error    Delete Plan    plan_name=${ENB_ID}_plan_1
    Wait Until Keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Log    \nProvision plan with Data Session Profiling acvitation done    console=True
    Upload_configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None

Provision and Check 4
    [Documentation]    This test checks if General Limitation didn't change after HVF activation - Grace Period
    Log    \n3rd Reports Generation and Checking After HFV Activation.    console=True
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM CM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    20x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Sleep     5min
    General Limitation Check
    License Check In 41003 Alarm For RP001033_004 part II

Provision and Check 5
    [Documentation]    This test checks if General Limitation didn't change after HVF activation - Limitation Mechanism
    Log    \n4th Report Generation and Check General Limitation.    console=True
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM CM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    20x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 6
    [Documentation]    This test deactivates 64 QAM modulation.
    Log    \nProvision with 64 QAM in uplink Deactivation and Check.    console=True
    Provision Plan    plan_name=${ENB_ID}_plan_2
    Run Keyword And Ignore Error    Delete Plan    plan_name=${ENB_ID}_plan_2
    Wait Until Keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Log    \nProvision plan with 64 QAM in uplink deacvitation done.    console=True
    Check If Alarms From ENB And NetAct Are The Same v2

Provision and Check 7
    [Documentation]    This test checks if General Limitation still exists after 64 QAM deactivation process.
    Log    \n5th Reports Generation and Check After HFV Deactivation.    console=True
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM CM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    20x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}

Provision and Check 8
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicense Upload.    console=True
    Log    ${CURDIR}
    FOR    ${lic_file}    IN    @{licence_list}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nPerform SWEM PM Reports Generation    console=True
    SWEM PM Reports Generation v2
    SWEM CM Reports Generation v2
    Wait Until Keyword Succeeds    20x    1min    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}

Final Recovery and Checkpoint
    [Documentation]    This test removes not needed files and checks eNB state.
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
    Log    \nTest passed!    console=True

*** Keywords ***
ENB Status Check
    [Arguments]  ${expected}=&{EMPTY}
    Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}    ${expected}
    Check If Alarms From ENB and NetAct Are The Same v2

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

SWEM PM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_PM}
        ${module}=    get_modules    moduleName=${swem_module}
        ${status}=    Generate Reports    ${module[0]}    day=-1
    END

SWEM CM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_CM}
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
    SWEM PM Reports Generation v2
    SWEM CM Reports Generation v2

License Check In 41003 Alarm For RP001033_004 part I
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
     FOR  ${alarm}  IN  @{alarms_list}
         ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    5647: 5/0
     END
    Log    Done!    console=True

License Check In 41003 Alarm For RP001033_004 part II
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
        ${description}=     Get From Dictionary    ${alarm}   additionalText1
        Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    5647: 5/0   AND
                                                                         ...    Should Contain    ${description}    19722: 2/0
    END
    Log    Done!    console=True

Prepare Test Data Files
    [Documentation]     This Keyword checks moves plans to results folder.
     @{path_to_files}=    OperatingSystem.List Files In Directory    path=${TEST_DATA_FILES}    absolute=True
     ${i}    Set Variable    ${0}
     FOR    ${file}   IN    @{path_to_files}
         ${i}  evaluate  ${i} + 1
         Log To Console  ${file} -> plan_${i}.xml
         Copy File    ${file}    ${RESULTS}${/}plans${/}plan_${i}.xml
     END
Clear Test Data Files
    [Documentation]     This Keyword deletes plans from CM Operation Manager.
    @{path_to_files}=    OperatingSystem.List Files In Directory    path=${TEST_DATA_FILES}    absolute=True
    ${i}    Set Variable    ${0}
    FOR    ${file}   IN    @{path_to_files}
        ${i}  evaluate  ${i} + 1
        Delete Plan    plan_name=${ENB_ID}_plan_${i}
    END
