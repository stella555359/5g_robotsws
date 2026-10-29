*** Settings ***
Documentation
            ...  WRO5_LM_CB008369_CB009843_eCPRI_7-2e_RF_sharing_and_NR_TDD_cells_mMIMO
            ...  = Author =
            ...    _alicja.tomczak@nokia.com_
            ...  = Maintainer =
            ...    _alicja.tomczak@nokia.com_
            ...  = Reviewer =
            ...    _szymon.romanowski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - Capacity limitation (CB009843 and CB008369)
            ...    - if required licenses will visible in BTS-1 and BTS-2
            ...    - License Keys (LK) to be checked:
            ...        - RCOM00036LK - 	Nokia Dual Boost for RF7.1 mMIMO LTU,
            ...        - RCOM00035LK - 	ABIP Baseband Capacity Activation LTU,
            ...        - RCOM00038LK - 	ABIQ Baseband Capacity Activation LTU,
            ...  = Pre - requirements =
            ...    - eNB is OnAir
            ...    - There are no free licenses in CLS:
            ...      - RCOM00036LK, RCOM00035LK, RCOM00038LK (Licenses are removed during Test Preparation Step)
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
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.nms.netact
Library         taf.sw.scout      WITH NAME    scout
Library         taf.sw.dcap.rd    WITH NAME    dcap

Resource        ../LM_resources/lib_SFE.robot
#Resource        ../../../../../../CBRS/CNI_NIDD/Resources/DcapLib.robot

Suite Setup  Run Keywords     Setup NMS    ${NMS_LAB}   AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Set Suite Variable    ${5G}    TRUE    AND
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}    AND
...                           Run Keyword And Ignore Error    scout.Setup Scout    1_16_UTESRAN2143


Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Upload in Teardown    AND
#...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Stop DCAP Trace    AND
...                             Stop Capturing Logs And Collect    ${SUITE_STATUS}    AND
...                             Run Keyword And Ignore Error    Start Capturing Logs    AND
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
@{licence_list}         V4400430.XML    V4400408.XML    V4300291.XML
@{lic_serial_number}    0011102245297   0011125511489   0011097118385
@{modules_list}         SWEM for SRAN CM
#${TEST_DATA_FILES}      ${CURDIR}/../LM_resources/Plans/WRO5_LM_CB008369_CB009843_eCPRI_7-2e_RF_sharing_and_NR_TDD_cells_mMIMO/
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${Standby_BTS_ID}       8958

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Run Keyword And Ignore Error    Start Capturing Logs
    Append To List    ${ALLOWED_ALARMS}    7652     7305
    Append To List    ${ALLOWED_FAULTS}    4738     7107
    Log    \nCheck status of eNB before test    console=True
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
    #Set Reset Counter Before Test

Test Preparation
    [Documentation]    This test prepares all necessary files.
    Log    \nPrepare all necessary files for test.    console=True
    ${list_length}=    Get Length    ${licence_list}
    FOR    ${i}    IN RANGE    ${list_length}
        Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${licence_list[${i}]}
    END
    Log    \nLKs Deleted successfully    console=True
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${Standby_BTS_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}
    Export Configuration    ${Standby_BTS_ID}_full_backup.xml    ${RESULTS}
    Append To List    ${ALLOWED_ALARMS}    7220    7305
#    Prepare and Import All Plans From Directory v2    ${TEST_DATA_FILES}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Wait Until Keyword Succeeds    5x    1min    License Check In 41003 Alarm For BTS-1
    Wait Until Keyword Succeeds    5x    1min    License Check In 41003 Alarm For BTS-2
    Log    \nNumber of needed licenses is correct!    console=True

Provision and Check 2
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \n2nd Raports Generation and General Limitation Checking.    console=True
    Sleep    5min
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003     7110
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Wait Until Keyword Succeeds    5x    2min    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 3
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{licence_list}
      Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
      Set Test Variable    ${License_template}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
      Upload License    ${License_template}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    5x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_FAULTS}

Final Checkpoint
    [Documentation]    This test restores initial eNB configuration and checks if it is OnAir.
    Check If Alarms From ENB And NetAct Are The Same v2
    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}
    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_ALARMS}
    #Check If Reset Counter Did Not Change
    Log    \nLog testline id from scout to RePo    console=True
    Run Keyword And Ignore Error    scout.Request Scf
    #Log    \nCollect and Stop DCAP trace ID-${trace_id}   console=True
    #Collect DCAP Logs    ${trace_id}    RAT_1ST_dcap    /home/ute/test_results/Test/DcapLogs-${trace_id}.zip
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

SWEM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    get_modules    moduleName=${swem_module}
  #  \    Log    Generated module is:${module}    console=True
        ${status}=    Generate Reports    ${module[0]}
  #  \    Log    ${status}    console=${TRUE}
    END

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
      Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
      Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2

License Check In 41003 Alarm For BTS-1
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
         ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    64322: 2/0    AND
                                                                         ...    Should Contain    ${description}    63982: 4/0    AND
                                                                         ...    Should Contain    ${description}    66641: 4/0
    END
    Log    MRBTS-${ENB_ID} Done!    console=True

License Check In 41003 Alarm For BTS-2
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${Standby_BTS_ID}
    FOR  ${alarm}  IN  @{alarms_list}
         ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    63982: 2/0    AND
                                                                         ...    Should Not Contain    ${description}    64322:    AND
                                                                         ...    Should Not Contain    ${description}    66641:
    END
    Log    MRBTS-${Standby_BTS_ID} Done!    console=True


Check Expected Alarms And Accept Allowed for BTS-2
    [Documentation]
    ...    Keyword check whether expected alarms are present on eNB
    ...    By default expected_alarms list is empty
    ...    Allowed alarms could be declared in eNB configuration file
    ...    Author: michal.kusiak@gmail.com
    ...    Update 7.08.2018
    [Arguments]      ${allowed_alarms}=${ALLOWED_ALARMS}    ${expected_alarms}=&{EMPTY}    ${alarms}=&{EMPTY}   ${new_way}=False
    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_names=${Standby_BTS_ID}     active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=PLMN-PLMN/MRBTS-${Standby_BTS_ID}
    ...  ELSE  set variable  ${netact_alarms}
    @{active_alarms}    Get Netact Number Alarms    ${netact_alarms}
    ${alarms_to_delete}    Create List
    ${current_date}=    DateTime.Get Current Date
    ${active_alarms}  remove duplicates  ${active_alarms}

    FOR    ${alarm}    IN    @{expected_alarms}
        ${alarm}    Convert To Integer    ${alarm}
        List Should Contain Value    ${active_alarms}    ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    FOR   ${alarm}   IN   @{allowed_alarms}
        ${alarm}   Convert To Integer   ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    Remove Values From List    ${active_alarms}    @{alarms_to_delete}
    Run Keyword If   "${new_way}"=="True"     Add to alarm list    ${active_alarms}   ${alarms}   ELSE    Should Be Empty    ${active_alarms}
