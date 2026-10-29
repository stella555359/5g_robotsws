*** Settings ***
Documentation
            ...  OAM_LM_CNI_120690_02_Verification_of_limitation_mechanism
            ...  = Author =
            ...    _bartosz.wasielewski@nokia.com_
            ...  = Maintainer =
            ...    _bartosz.wasielewski@nokia.com_
            ...    _agnieszka.bala@nokia.com_
            ...  = Reviewer =
            ...    _agnieszka.bala@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    -if specific license is required fo ASOE card,
            ...    -if limitation is possible for ASOE module,
            ...    -if required number of LKs is counted in proper way based on cell+cellType approaching
            ...  = Pre - requirements =
            ...    -license SR000972.T SBTS system module sharing is not avaiable in CLS
            ...    -all other licenses are added to CLS
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
#...                           Start DCAP    host=10.42.62.15    #VM ip

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
${lic_file}             V4400135.XML
${lic_ser_num}          0011231931265
@{modules_list_SR}      SWEM for SRAN CM
${TEST_DATA_FILES}      ${CURDIR}/test_data_files
${RESULTS}              /home/ute/test_results
${PLANS_DIR}            ${RESULTS}/plans

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    Log    \nSetting test variables    console=True
    Wait Until keyword Succeeds   5min    1min    ENB Status Check
    #Set Reset Counter Before Test

Test Preparation
    [Documentation]    This test prepare all necessary files.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Start Capturing Logs
    Log    \nPrepare all necessary files for test    console=True
    Delete License    license_serialnumber=${lic_ser_num}    license_filename=${lic_file}
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykly CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}
    Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}${lic_file}
    Set Suite Variable    ${License1_template}    ${RESULTS}${/}${lic_file}

Provision and Check 1
    [Documentation]    This test checks if alarm 41003 appears if license is missing.
    Log    \nPerform SRAN CM Reports Generation    console=True
    SR Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    10x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Sleep     5min    #This KW must be used here, because 5 min is time of Grace Period. During this time new report will not activated limitation.
    License Check In 41003 Alarm For SBTS part

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \nPerform 2nd SRAN CM Reports Generation    console=True
    SR Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    10x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check

Provision and Check 3
    [Documentation]    This test checks if limitation is cancelled after license adding
    Log    \nLicense Upload.    console=True
    Upload_License    ${License1_template}
    Log    \nLicense uploaded!    console=True
    SR Reports Generation v2
    Wait Until Keyword Succeeds    10x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_FAULTS}

Final Recovery and Checkpoint
    [Documentation]    This test removes not needed files and checks eNB state.
    ENB Status Check
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

SR Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_SR}
        ${module}=    get_modules    moduleName=${swem_module}
  #  \    Log    Generated module is:${module}    console=True
        ${status}=    Generate Reports    ${module[0]}
  #  \    Log    ${status}    console=${TRUE}
    END

5G Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list_5G}
        ${module}=    get_modules    moduleName=${swem_module}
  #  \    Log    Generated module is:${module}    console=True
        ${status}=    Generate Reports    ${module[0]}
  #  \    Log    ${status}    console=${TRUE}
    END

License Check In 41003 Alarm For SBTS part
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    5649: 1/0
    END
    Log    Done!    console=True

License Check In 41003 Alarm For 5gClassicalBTS part
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    5G000011.T
    END
    Log    Done!    console=True

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
        Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
        Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SR Reports Generation v2
