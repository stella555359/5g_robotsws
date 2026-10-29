*** Settings ***
Documentation
            ...  WRO5_LM_CB008993_CB006584_006_SW_upgrade_during_limitation
            ...  (former: LTE2417-A.015_SW_upgrade_during_limitation)
            ...  = Author =
            ...    _kamil.magierowski@nokia.com_
            ...  = Maintainer =
            ...    _bartosz.wasielewski@nokia.com_
            ...    _marcin.berkowski@nokia.com_
            ...    _agnieszka.bala@nokia.com_
            ...  = Reviewer =
            ...    _damian.swierzewski.ext@nokia.com_
            ...  = Summary =
            ...    This test checks:
            ...    -if alarm details are not change after SW Upgrade
            ...  = Pre - requirements =
            ...    -traffic guard is in inactive state
            ...    -license SR001561.1LK RF unit TX Activation LTU is not avaiable in CLS
            ...    -all other licenses are added to CLS
            ...  = Expected results =
            ...    -Test is marked as PASSED
            ...    -Enb is OnAir after test
            ...    -There are no addtional alarms present after test
            ...  = Additional Info =
            ...    N/A
            ...  Precondition in the SCF: activateOranO1NetconfService=true
            ...     needed for Lic.: SR000041.T "5GC001103, Open O1 readiness LTU" (Feature code: 61395)

Library         Collections
Library         DateTime
Library         OperatingSystem
Library         Process
Library         SSHLibrary
Library         String
Library         XML    use_lxml=True
Library         taf.nms.netact
Library         ute_admin
Library         ute_admin_infomodel
Library         taf.sw.scout      WITH NAME    scout
Library         taf.sw.dcap.rd    WITH NAME    dcap
Library                         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource                        taf/rfrl/uuf4all/uuf4all_keywords.robot

Resource        ../LM_resources/lib_SFE.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

# Suite setup uses keyword to fetch the build automatically from CM execution,
# remove "Set Initial And Candidate" if running from CLI

Suite Setup  Run Keywords     Set Initial And Candidate   AND
...                           Setup NMS    ${NMS_LAB}   AND
...                           Suite Setup Infomodel    im_port=443    AND
...                           Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443    use_ssl=True    timeout=90s    AND
...                           Get And Set Enb Parameters    AND
...                           Get And Set Netact Parameters SRAN     AND
...                           Add Node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}   AND
...                           Add Node    cls-services    ${CLS_API_HOST}   root    ${NA_ROOT_PASS}    AND
...                           Add Node    cls-db    ${CLS_DATABASE_HOST}    root    ${NA_ROOT_PASS}    AND
...                           Run Keyword And Ignore Error    scout.Setup Scout    10_16_UTESRAN3894    #AND
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
${ENB_ROOT_USER}           toor4nsn
${ENB_ROOT_PASS}           oZPS0POrRieRtu
${lic_file}                V0201227.XML
${lic_ser_num}             9991219634801
@{modules_list}            SWEM for SRAN CM
${TEST_DATA_FILES}         ${CURDIR}/test_data_files
${RESULTS}                 /home/ute/test_results
${PLANS_DIR}               ${RESULTS}/plans

#Variables for the SW upgrade lib.:[taf.rfrl.csv4all]
${RP_CA}   VRF_OAM
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T05

@{CUSTOMERS}=                   Generic
${INITIAL}=                     SBTS00_ENB_9999_251118_000004
${CANDIDATE}=                   SBTS00_ENB_9999_251119_000004
##${UPGRADE_ITERATION}=           1
${TEMP_ALLOWED_FAULTS}=         ${None}
@{CUSTOM_ALLOWED_ALARMS}        4700    4744    4293    7115
#Alarm 7115 (FID-4744) "O-RAN O1 Netconf service failure" - alarm connected with ONAP and lic.
#Alarm 7110 (FID-4293) "IP Traffic Capacity Limit" - Standard LM alarm during checking lic. mechanism
&{node1}                        node_alias=LM_BTS
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
@{nodes}                        ${node1}

*** Test Cases ***
Start Checkpoint
    [Documentation]    This test checks if eNB is ready for test.
    #Log    \nStart DCAP Trace    console=True
    #${trace_id}=    Start DCAP Trace
    Append To List    ${ALLOWED_ALARMS}    7115    #alarm for failed connection to o1
    Append To List    ${ALLOWED_FAULTS}    4639    4744    #fid for failed connection to o1
    Start Capturing Logs
    Log    \nCheck status of eNB before test    console=True
    Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}${lic_file}
    Set Suite Variable    ${License1_template}    ${RESULTS}${/}${lic_file}
    Wait Until keyword Succeeds   5min    1min     ENB Status Check
    #Set Reset Counter Before Test

Test Preparation
    [Documentation]    This test prepare all necessary files.
    Log    \nPrepare all necessary files for test    console=True
    Delete License    license_serialnumber=${lic_ser_num}    license_filename=${lic_file}
    Log    \nBackup current configuration via NetAct    console=True
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykły CM UPLOAD
    Export Configuration    ${ENB_ID}_full_backup.xml    ${RESULTS}

Provision and Check 1
    [Documentation]    This test changes limitation values and checks if alarm 41003 appears when license is missing.
    Log    \nSSH Execution Command on Enb    console=True
    Set Test Variable    ${command}    (cd /opt/trs/bin ; ./trs-iptrafficlim-d execute SetRndParams 5 10 7200)
    Traffic Guard Parameter Changer    ${command}
    Log    \nTraffic Guard parameter changed to 10 sec    console=True
    Log    \nReports Generation and 41003 Alarm Checking    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Sleep    5min    #This KW must be used here, because 3 min is the time of Grace Period.
    License Check In 41003 Alarm For RP001033_003

Provision and Check 2
    [Documentation]    This test checks if limitation starts after Grace Period.
    Log    \n2nd Reports Generation and IP limitation checking    console=True
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    5x    1min    Check Expected Alarms And Accept Allowed v2    ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    General Limitation Check
    Sleep    3min    ##This KW must be used here, because alarms details are going down every 5 sec. We need wait for last value (50%)

Provision and Check 3
    [Documentation]    This test checks diagnotic info of limitation alarm.
    Log    \nChecking limitation level    console=True
    Diagnostic Info
    Set Suite Variable    ${Diagnostic_info_1}    ${diagnostic_info}
    Log    \nUpgrade BTS    console=True

Provision and Check 4
    [Documentation]    This test upgrades eNB with new SW and compares limitation alarms after that.
    Log    \nDownloading specific build in progress...   console=True
    Perform SW upgrade
    Sleep    3min
    Wait Until Keyword Succeeds    10x    1min    Check If Cells OnAir Or PowerSaving Enabled
#    #Check If Reset Counter Incremented
    Log    \nSW update done!   console=True


Provision and Check 5
    [Documentation]    This test checks if limitation level is the same as before SW update
    Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None    verbose=True    schedule=None
    ...    ignore_errors=False    timeout=7200    # zwykły CM UPLOAD
    SWEM Reports Generation v2
    ${list_of_expected_faults}=    Create List    41003    7110
    Wait Until Keyword Succeeds    10x    1min    Check Expected Alarms And Accept Allowed v2   ${ALLOWED_ALARMS}    ${list_of_expected_faults}
    Diagnostic Info
    Set Suite Variable    ${Diagnostic_info_2}    ${diagnostic_info}
    Should Be Equal As Strings     ${Diagnostic_info_1}     ${Diagnostic_info_2}
    License Check In 41003 Alarm For RP001033_003

Provision and Check 6
    [Documentation]    This test checks if limitation is cancelled after license adding.
    Log    \nLicense uploading    console=True
    Log    \nCurrent directory is: ${CURDIR}.    console=True#
    Upload_License    ${License1_template}
    SWEM Reports Generation v2
    Wait Until Keyword Succeeds    10x    1min    Check Expected Faults And Accept Allowed v2    ${ALLOWED_FAULTS}
    Set Test Variable    ${command}    (cd /opt/trs/bin ; ./trs-iptrafficlim-d execute SetRndParams 0 0 5)
    Traffic Guard Parameter Changer    ${command}
    Sleep    1min

Final Recovery and Checkpoint
    [Documentation]    This test removes not needed files and checks eNB state.
    Log    \nRecovery and final check    console=True
    Set Test Variable    ${command}    (cd /opt/trs/bin ; ./trs-iptrafficlim-d execute SetRndParams 0 0 0)
    Traffic Guard Parameter Changer    ${command}
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

SWEM Reports Generation
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    Get Module    moduleName=${swem_module}    detailed=${FALSE}
#        Log    Generated module is:${module}    console=True
        ${report_id}=    ta_netact_swam.Generate Reports    ${module}    day=-1
#        Log    Current module ID is:${report_id}    console=True
    END

SWEM Reports Generation v2
    [Documentation]  This keyword generates SWEM reports based on specific module.
    FOR  ${swem_module}  IN  @{modules_list}
        ${module}=    get_modules    moduleName=${swem_module}
#        Log    Generated module is:${module}    console=True
        ${status}=    Generate Reports    ${module[0]}
    END
  #  \    Log    ${status}    console=${TRUE}

Traffic Guard Parameter Changer
   [Documentation]     This Keyword changing Traffic Guard parameters.
   ...                 Argument is a command which must be executed on eNB.
   [Arguments]        ${command}
    SSHLibrary.Open Connection    host=${ENB_MPLANE_IP}
    SSHLibrary.Login        ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    SSHLibrary.Execute Command    ${command}
    SSHLibrary.Close Connection

Address Is Pingable
    [Documentation]    Keyword checks if M-Plane address of eNB is pingable
    [Arguments]    ${ENB_MPLANE_IP}
    ${rc}=    Run And Return Rc    ping -c 1 ${ENB_MPLANE_IP}
    Should Be Equal As Integers    ${rc}    0

eNB Should Be Unavailable
    [Documentation]    Keyword checks if M-Plane address of eNB is not pingable
    Wait Until Keyword Succeeds    300x    1 sec    Run keyword and expect error  *
    ...  Address Is Pingable    ${ENB_MPLANE_IP}

Diagnostic Info
    [Documentation]  This keyword checks limitation level.
    ${result}=    Convert To Integer    7110
    ${active_alarms}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR    ${result}    IN    @{active_alarms}
        Run Keyword If  '${result.specificProblem}' == '7110'    Set Suite Variable    ${diagnostic_info}    ${result['additionalText3']}
    END

#Suite Precondition
#    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
#
#Suite Postcondition
#    Clean All    alias=${NETACT_NAME}

Upload in Teardown
    [Documentation]  This keyword uploads deleted licenses and generates SWEM reports when test fails (to clean limitation alarm before next test)
    FOR    ${lic_file}    IN    @{licence_list}
      Copy File    ${CURDIR}/../LM_resources/Licenses/${lic_file}    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
      Upload License    ${RESULTS}${/}Lic_To_Upload${/}${lic_file}
    END
    Log    \nLicenses uploaded!    console=True
    SWEM Reports Generation v2

License Check In 41003 Alarm For RP001033_003
    [Documentation]     This Keyword checks licenses needed by NetAct.
    ${alarms_list}=    taf.nms.netact.Get Alarms    PLMN-PLMN/MRBTS-${ENB_ID}
    FOR  ${alarm}  IN  @{alarms_list}
         ${alarm_number}=     Get From Dictionary    ${alarm}   specificProblem
         ${description}=     Get From Dictionary    ${alarm}   additionalText1
         Run Keyword If    ${alarm_number} == 41003    Run Keywords    Log    ${description}    console=True    AND
                                                                         ...    Should Contain    ${description}    61395: 4/0
    END
    Log    Done!    console=True

Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW
    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

Perform SW upgrade
    [Documentation]    This Keyword upgrades enb with new software
    #ute_admin.Update Software    sw_package=${sw_path}    should_activate=True    timeout=2100
    e2e_tl_upgrade_test
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${node1}
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}
