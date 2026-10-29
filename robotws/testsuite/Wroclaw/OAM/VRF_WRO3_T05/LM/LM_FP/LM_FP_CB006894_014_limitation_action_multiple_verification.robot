*** Settings ***
Documentation
            ...  OAM_LM_CB006894_014_limitation_action_multiple_verification_Power_RM_Rel.5
            ...  = Author =
            ...    _damian.porebski@nokia.com_
            ...  = Maintainer =
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Reviewer =
            ...    _damian.swierzewski.ext@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - If defined Sale Items are protected correctly
            ...    - If limitation started after Grace Period after removing licenses RL000144LK 20W Incremental Power for Flexi LTU from CLS
            ...    - If limitation is cancelled after licenses RL000144LK 20W Incremental Power for Flexi LTU adding
            ...  = Pre - requirements =
            ...    - eNB is OnAir
            ...    - Licenses RL000144LK 20W Incremental Power for Flexi LTU are added to CLS
            ...    - Licenses SR001561.1LK RF unit TX Activation LTU are added to CLS
            ...    - Licenses SR001561.2LK RF unit RX Activation LTU are added to CLS
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
Resource        taf/rfrl/common_resources/common_step/interface.robot
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
...                           Run Keyword And Ignore Error    scout.Setup Scout    1_16_UTE4G2020    #AND
#...                           Start DCAP    host=10.42.135.237    #VM ip

Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Upload in Teardown    AND
#...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Stop DCAP Trace    AND
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
@{licence_list}         V0300205.XML    V0200550.XML
@{lic_serial_number}    0011179931249    9991174076097
@{backup_list}
@{modules_list}         SWEM for SRAN CM
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans


*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Start Capturing Logs
    Log    \nCheck status of eNB before test    console=True
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
    #Set Reset Counter Before Test

Test Preparation
    [Documentation]    This test prepare all necessary files.
    Log    \nPrepare all necessary files for test    console=True
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykĹ‚y CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}
    ${list_length}=    Get Length    ${licence_list}
    Set Suite Variable   ${list_length}    ${list_length}
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END

Provision and Check 1
    [Documentation]    SWEM report generation and license deletion
     Log    \nSWEM Reports Generation    console=True
     SWEM Reports Generation v2
     Log    \nLicenses deleting    console=True
     FOR    ${i}    IN RANGE    ${list_length}
         Delete License    license_serialnumber=${lic_serial_number[${i}]}    license_filename=${licence_list[${i}]}
     END
     Log    \nSWEM report generation and license deletion - done!    console=True

Provision and Check 2
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Log    \nNumber of needed licenses is correct!    console=True
    Sleep    5min    #This KW must be used here, because 4 min is time of Grace Period. During this time new report will not activated limitation.
    License Check In 41003 Alarm For RP001561_002

Provision and Check 3
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Raports Generation and General Limitation Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 4
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicense upload.    console=True
    FOR    ${lic_file}    IN    @{licence_list}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    5x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}

Final Checkpoint
    [Documentation]    This test removes not needed files and checks eNB state.
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
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

License Check In 41003 Alarm For RP001561_002
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR    ${alarm}    IN    @{alarms}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
        ${description}=     Get From Dictionary    ${alarm}   additionalText1
        Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                       ...    Should Contain    ${description}    5650: 17/0   AND
                                                                       ...    Should Contain    ${description}    35876: 2/0   AND
                                                                       ...    Exit For Loop
    END

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
#        Log    Generated module is:${module}    console=True
        ${status}=    Generate Reports    ${module[0]}
#        Log    ${status}    console=${TRUE}
    END

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{license_list}
        Copy File    ${CURDIR}/licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2
