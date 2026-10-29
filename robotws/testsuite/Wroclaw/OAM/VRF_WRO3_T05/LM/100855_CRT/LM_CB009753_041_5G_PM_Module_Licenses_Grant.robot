*** Settings ***
Documentation
            ...  OAM_LM_CB009753_042_General_Limitaiton_Check
            ...  = Author =
            ...    _szymon.romanowski@nokia.com_
            ...  = Maintainer =
            ...    _szymon.romanowski@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...  = Pre - requirements =
            ...  = Expected results =
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
@{licence_list}         V0100110.XML    V0100111.XML    V2600258.XML    V4300225.XML
@{lic_serial_number}    9991189991041    9991253862785      0011234431185    0011070918049
@{modules_list_PM}      SWEM for 5G RAN PM    SWEM for SRAN PM
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Append To List    ${ALLOWED_ALARMS}    7115    #alarm for failed connection to o1
    Append To List    ${ALLOWED_FAULTS}    4639    4744    #fid for failed connection to o1
    Start Capturing Logs
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
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykly CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM PM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Log    \nNumber of needed licenses is correct!    console=True
    Sleep    5min
    License Check In 41003 For ValuePack

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Raports Generation and General Limitation Checking.    console=True
    SWEM PM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    10x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
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
    SWEM PM Reports Generation v2
    Wait Until Keyword Succeeds    10x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}

Final Checkpoint
    [Documentation]    This test restores initial eNB configuration and checks if it is OnAir.
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

ENB Status Check
    [Arguments]  ${expected}=&{EMPTY}
    Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}    ${expected}
    Check If Alarms From ENB and NetAct Are The Same v2

SWEM PM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_PM}
        ${module}=    get_modules    moduleName=${swem_module}
        ${status}=    Generate Reports    ${module[0]}    day=-1
    END

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM PM Reports Generation v2

License Check In 41003 For ValuePack
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
        ${description}=     Get From Dictionary    ${alarm}   additionalText1
        Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    64696: 36/0    AND
                                                                         ...    Should Contain    ${description}    67421: 37/0    AND
                                                                         ...    Should Contain    ${description}    70063: 1/0     AND
                                                                         ...    Should Contain    ${description}    64697:
    END
    Log    Done!    console=True
