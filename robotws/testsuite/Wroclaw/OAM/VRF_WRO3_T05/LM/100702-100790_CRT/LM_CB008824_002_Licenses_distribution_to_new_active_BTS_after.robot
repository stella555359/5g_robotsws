*** Settings ***
Documentation
            ...  WRO5_LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after_doing_controlled_switchover
            ...  = Author =
            ...    _szymon.romanowski@nokia.com_
            ...  = Maintainer =
            ...    _szymon.romanowski@nokia.com_
            ...  = Reviewer =
            ...    _agnieszka.bala@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    - if required licenses monitored by SWEM for SRAN CM module are required for active BTS with
            ...      redundacyRole = active and there is no aditional lks required for standby BTS in feature CB008824
            ...    - if required licenses are still required for standby BTS after controlled switchover
            ...    - License Keys (LK) to be checked:
            ...        - RCOM00027LK - ABIN Baseband Capacity Activation LK1,
            ...  = Pre - requirements =
            ...    - eNB is OnAir and redundacyRole set to active
            ...    - Standby eNB is configured and cell is Offline, redundancyRole set to standby
            ...    - There are no free licenses in CLS:
            ...      - RCOM00027LK (Licenses are removed during Test Preparation Step)
            ...    - by deafult BTS 100702 have active redundancy role and BTS 100790
            ...  = Expected results =
            ...    - Test is marked as PASSED
            ...    - eNB is OnAir after test, 2nd eNB is configured
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
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}    AND
...                           Run Keyword And Ignore Error    scout.Setup Scout    1_16_UTE4G2020


Suite Teardown  Run Keywords    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Provision Plan
                                ...    plan_name=${ENB_ID}_full_backup    AND
...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Upload in Teardown    AND
#...                             Run Keyword And Ignore Error    Run Keyword If Any Tests Failed    Stop DCAP Trace    AND
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
@{licence_list}         V3700051.XML
@{lic_serial_number}    0011136936673
@{modules_list}         SWEM for SRAN CM
${TEST_DATA_FILES}      ${CURDIR}/../LM_resources/Plans/LM_CB008824_002_Licenses_distribution_to_new_active_BTS_after/
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans
${Standby_BTS_ID}       100790

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Start Capturing Logs
    Append To List    ${ALLOWED_ALARMS}    7652
    Append To List    ${ALLOWED_FAULTS}    4738
    Log    \nCheck status of eNB before test    console=True
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
    Prepare Test Data Files
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
    Prepare and Import All Plans From Directory v2    ${TEST_DATA_FILES}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    2x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Wait Until Keyword Succeeds    2x    1min    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_ALARMS}
    Wait Until Keyword Succeeds    2x    1min    License Check In 41003 Alarm For BTS-1
    Log    \nNumber of needed licenses is correct!    console=True


Provision and Check 2
    [Documentation]    This test send provision to change redundancy role parameter
    Log    \nProvisioning    console=True
    #provision1
    Provision Plan     plan_name=100702_plan_3
    #provision2
    Provision Plan     plan_name=100702_plan_2
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${Standby_BTS_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200


Provision and Check 3
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nRaports Generation and Alarm 41003 Checking.    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    2x    1min    Check Expected Alarms And Accept Allowed for BTS-2
    ...    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Wait Until Keyword Succeeds    2x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}
    Wait Until Keyword Succeeds    2x    1min    License Check In 41003 Alarm For BTS-2
    Log    \nNumber of needed licenses is correct!    console=True

Provision and Check 4
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicenses upload.    console=True
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Set Test Variable    ${License_template}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${License_template}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    2x    1min    Check Expected Faults And Accept Allowed v2   ${ALLOWED_FAULTS}
    Wait Until Keyword Succeeds    2x    1min    Check Expected Alarms And Accept Allowed for BTS-2    ${ALLOWED_ALARMS}

Provision and Check 5
    [Documentation]    This test send provision to restore redundancy role parameter
    Log    \nRestoring configuration   console=True
    Provision Plan     plan_name=100702_plan_4
    Provision Plan     plan_name=100702_plan_1
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${Standby_BTS_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200


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
                                                                         ...    Should Contain    ${description}    15947: 1/0
    END
    Log    MRBTS-${ENB_ID} Done!    console=True

License Check In 41003 Alarm For BTS-2
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${Standby_BTS_ID}
    FOR  ${alarm}  IN  @{alarms_list}
         ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    15947: 1/0
    END
    Log    MRBTS-${Standby_BTS_ID} Done!    console=True

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
