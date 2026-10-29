*** Settings ***
Documentation
            ...  OAM_LM_CB006894_015_limitation_action_multiple_BB_card_configuration
            ...  = Author =
            ...    _agnieszka.bala@nokia.com_
            ...  = Maintainer =
            ...    _agnieszka.bala@nokia.com_
            ...    _bartosz.wasielewski@nokia.com_
            ...    _damian.porebski@nokia.com_
            ...  = Reviewer =
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - required number of LKs is counted in proper way based on cell+cellType approaching
            ...      checking Type & Bandwidth
            ...    - license limitation is possible when ABIO/ABIN card is in use together with ABIA/ABIL - limitation appears
            ...    - if required licenses monitored by SWEM for SRAN CM module are missing. License Keys (LK) to be checked:
            ...        - RCOM00030LK - ABIO Baseband Capacity Activation LK1,
            ...        - SR001376LK - AirScale System Module Activation LK2,
            ...        - RCOM00027LK - ABIN Baseband Capacity Activation LK3,
            ...    - license limitation can be removed after required licenses adding.
            ...  = Pre - requirements =
            ...    - Licenses LK1, LK2, LK3 required for SBTS are not available in CLS,
            ...    - SBTS is in OnAir state
            ...    - There is no active license limitation in SBTS,
            ...    - productVariantPlanned parameter is set to 10 [to select SBTS mode (sBTS)].
            ...    - actCategoryAlarms parameter is set to true.
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
...                           Set Suite Variable    ${5G}    TRUE    AND
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
@{licence_list}         V0200218.XML    V3700051.XML    V0200220.XML    V4400430.XML    V4400408.XML
@{lic_serial_number}    9991047978289    0011136936673    9991056296065    0011102245297    0011125511489
@{modules_list}         SWEM for SRAN CM
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    Log    \nSetting test variables    console=True
    Log    \nLicenses preparing    console=True
    ${list_length}=    Get Length    ${licence_list}
    Set Suite Variable   ${list_length}    ${list_length}
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Wait Until keyword Succeeds   5min    1min     ENB Status Check

Test Preparation
    [Documentation]    This test prepare all necessary files.
    Log    \nPrepare all necessary files for test    console=True
    Log    \nLicenses deleting    console=True
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${licence_list[${i}]}
    END
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykĹ‚y CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appeares if license is missing.
    Log    \nReports Generation and Alarm 41003 Checking.    console=True
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Sleep     5min    #This KW must be used here, because 5 min is time of Grace Period. During this time new report will not activated limitation.
    License Check In 41003 Alarm For OAM_LM_ CB005985_RP002887_005

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Reports Generation and IP Traffic Limitation Checking.    console=True
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    20x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check


Provision and Check 3
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{licence_list}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nPerform SWEM CM Reports Generation    console=True
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    20x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}

Final Recovery and Checkpoint
    [Documentation]    This test removes not needed files and checks eNB state.
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
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

ENB Status Check
    [Arguments]  ${expected}=&{EMPTY}
    Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}    ${expected}
    Check If Alarms From ENB and NetAct Are The Same v2

SWEM CM Reports Generation
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_CM}
        ${module}=    Get Module    moduleName=${swem_module}    detailed=${FALSE}
        Log    Generated module is:${module}    console=True
        ${report_id}=    Generate Reports    ${module}
        Log    Current module ID is:${report_id}    console=True
    END

SWEM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    get_modules    moduleName=${swem_module}
        ${status}=    Generate Reports    ${module[0]}
    END

License Check In 41003 Alarm For OAM_LM_ CB005985_RP002887_005
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
        ${description}=     Get From Dictionary    ${alarm}   additionalText1
        Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                               ...    Should Contain    ${description}    57761: 2/0    AND
                               ...    Should Contain    ${description}    15947: 2/0    AND
                               ...    Should Contain    ${description}    57415: 1/0    AND
                               ...    Should Contain    ${description}    66641: 2/0    AND
                               ...    Should Contain    ${description}    63982: 2/0
    END
    Log    Done!    console=True

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2
