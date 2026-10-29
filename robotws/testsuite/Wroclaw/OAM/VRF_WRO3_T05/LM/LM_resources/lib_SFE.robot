*** Settings ***
Documentation    Internal SFE resource library repetetive keywords in multiple tests.
          ...    Author: marcin.sokolowski@nokia.com, przemyslaw.romanczyk@nokia.com, michal.kusiak@nokia.com
          ...
          ...    !! DO NOT COMMIT ANY CHANGES WITHOUT CONTACT WITH AUTHORS FIRST !!
Library         String
Library         OperatingSystem
Library         SSHLibrary
Library         Collections
Library         XML
Library         DateTime
Library         ute_syslog

Library       taf.nms.netact
Library       lib_SFE.py
Library       XML_replacer.py
Resource      lib_WOM.robot
Resource      ../../resources/infomodel.robot

*** Variables ***
@{backup_list}
${test_start_time}
${test_end_time}
${test_duration}

*** Keywords ***
Replace strings in xml
    [Documentation]     this keyword is used to replace strings in the given file
                ...     syntax:  Replace strings in xml    input file  output_file  string1,replacement1  string2,replacement2
                ...     Author: marcin.sokolowski@nokia.com

    [Arguments]    @{kwargs}
    [Timeout]    20s
     ${file}    OperatingSystem.Get File    ${kwargs[0]}
     ${output}=  set variable  ${kwargs[1]}
     Remove Values From List  ${kwargs}  ${kwargs[0]}  ${kwargs[1]}
    FOR    ${arg}    IN    @{kwargs}
        ${string}    ${replace}=    Evaluate    "${arg}".split(",")
        ${file}=    Replace String    ${file}  ${string}   ${replace}
    END
    OperatingSystem.Create File    ${output}    ${file}

Unblock IM port
    [Documentation]    Add rules to enb firewall to allow im connection
    ...                Author: marcin.sokolowski@nokia.com
    [Arguments]    ${ENB_IP}
    [Timeout]    5min
    unblock enb im port  ${ENB_IP}    ${ENB_ROOT_USER}    ${ENB_ROOT_PASS}
    Log  \nIM Port unblocked  console=True

Suite Setup infomodel
    [Documentation]    Setup infomodel keyword from ute_infomodel library wrapped in complementary keywords
    ...                for complete "one keyword" solution for starting infomodel
    ...                Author: marcin.sokolowski@nokia.com
    [Arguments]    ${alias}=default    ${im_port}=12345
    [Timeout]    7min
    ${if_enb_id_exists}=    Run Keyword And Return Status    Variable Should Exist   ${ENB_ID}
    ${if_enb_release_exists}=    Run Keyword And Return Status    Variable Should Exist   ${ENB_RELEASE}
    ${side}=    Run Keyword If    ${if_enb_release_exists}    Check Which Side Is Your AirScale
    Run Keyword If    ${if_enb_id_exists}    Set Suite Variable    ${ENB_SIDE}    ${side}
    Unblock IM port     ${ENB_MPLANE_IP}
    Setup infomodel  address=${ENB_MPLANE_IP}  port=${im_port}  alias=${alias}    #trace_mode=FALSE    im_library_log_dir=${RESULTS}
    Connect infomodel  alias=${alias}

Prepare Plan
    [Arguments]  ${plan_name}  ${parameter_name}  ${parameter_value}  ${class}  ${object}
    [Documentation]  This keyword swaps values in plan template. For arguments uou need to enter plan name in test data files
    ...              folder and parameter name and value. Also the managed object class and managed object name.
    ...              Author: przemyslaw.romanczyk@nokia.com

    Log To Console  \n Preparing plan ${plan_name}
    Replace strings in xml    ${TEST_DATA_FILES}/${plan_name}   ${PLANS_DIR}/${plan_name}    %PLMN%,${PLMN}    %ENB_ID%,${ENB_ID}
    ...    %RELEASE%,${ENB_RELEASE}    %CLASS%,${class}    %OBJECT%,${object}    %PARAMETER_NAME%,${parameter_name}
    ...    %PARAMETER_VALUE%,${parameter_value}
    Log To Console  \n Preparing plan ${plan_name} finished.

Check If Cells OnAir Or PowerSaving Enabled
    [Documentation]
    ...  KW checks whether cell is enabled. If not enabled, checks energy saving, if not - KW failed.
    [Arguments]   ${alias}=default
    ${if_enb_side_exists}=    Run Keyword And Return Status    Variable Should Not Exist   ${ENB_SIDE}
    ${enb_side_temp}=    Run Keyword If    ${if_enb_side_exists}    Check Which Side Is Your AirScale
    Run Keyword If    ${if_enb_side_exists}    Set Suite Variable    ${ENB_SIDE}    ${enb_side_temp}
    ${5G_status}=    Run keyword and return status    variable should exist    ${5G}
#    ${cell_paths}=    create dictionary
#                      ...   FL16A=/MRBTS-1/RAT-1//LNCEL_A-*
#                      ...   FL17A=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
#                      ...   FL17SP=/MRBTS-1/RAT-1//LNCEL_A-*
#                      ...   FL17ASP1=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
#                      ...   FL18=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
#                      ...   SBTS18=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   SBTS18A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   SBTS18SP=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   FL18SP=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   FL18A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   FL19=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   FL19A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   TL19=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
#                      ...   SBTS19A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    Run Keyword If    '${ENB_RELEASE}'=='FL16A'       Set Variable    /MRBTS-1/RAT-1//LNCEL_A-*
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17A'       Set Variable
                       ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17SP'      Set Variable    /MRBTS-1/RAT-1//LNCEL_A-*
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17ASP1'    Set Variable
                       ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
    ...                ELSE IF    '${ENB_RELEASE}'=='FL18'        Set Variable
                       ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
    ...                ELSE IF    '${ENB_RELEASE}'=='SBTS19A'     Set Variable
                       ...   /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-*
    ...                ELSE IF    '${5G_status}'=='True'          Set Variable    //RUNTIME_VIEW-${ENB_SIDE}//NRCELL_R-*
    ...                   ELSE                                    Set Variable    //RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-*
    ${cells}  Query Infomodel
    ...  query=get list ${path}
    ...  alias=${alias}
    FOR  ${cell}  IN  @{cells}
        ${operational_state}  Get from dictionary  ${cell}  operationalState
        ${energy_saving_state}  Get from dictionary  ${cell}  energySavingState
        ${operational_state}  Evaluate  "${operational_state}".upper()
        ${energy_saving_state}  Evaluate  "${energy_saving_state}".upper()
        Run keyword if  '${operational_state}'!='1'  Should be true  '${operational_state}'=='ENABLED' or '${energy_saving_state}'=='ENERGYSAVING'
    END

Get Random Cell
    [Documentation]    Return index of randomly selected cell
    ...                Author: marcin.sokolowski@nokia.com
    [Arguments]  ${alias}=default
    [Timeout]    30s
    # doda? per release

#    ${cell_paths}=    create dictionary
#                      ...   FL16A=/MRBTS-1/RAT-1//LNBTS-1/LCELL-
#                      ...   FL17A=/MRBTS-1/RAT-1//CELL_M-
#                      ...   FL17SP=/MRBTS-1/RAT-1//CELL_M-
#                      ...   FL17ASP1=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
#                      ...   FL18=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1//CELL_M-
#                      ...   SBTS18=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   FL18SP=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   FL18A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   SBTS18SP=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   FL19=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   FL19A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
#                      ...   SBTS19A=//RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    Run Keyword If    '${ENB_RELEASE}'=='FL16A'       Set Variable    /MRBTS-1/RAT-1//LNBTS-1/LCELL-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17A'       Set Variable    /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17SP'      Set Variable    /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17ASP1'    Set Variable
                       ...    /MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1//CELL_M-
    ...                   ELSE                                    Set Variable    //RUNTIME_VIEW-${ENB_SIDE}//LNCEL_R-
    ${cells}   Query Infomodel
    ...    query=get list ${path}*
    ...    alias=${alias}

    ${cells_quantity}=    Get Length   ${cells}
    ${random_cell}=    Evaluate    random.randint(1, ${cells_quantity})    modules=random
    [Return]    ${random_cell}

Check Expected Alarms And Accept Allowed
    [Documentation]
    ...    Keyword check whether expected alarms are present on eNB
    ...    By default expected_alarms list is empty
    ...    Allowed alarms could be declared in eNB configuration file
    ...    Author: michal.kusiak@gmail.com
    ...    Update 7.08.2018
    [Arguments]      ${allowed_alarms}=${ALLOWED_ALARMS}    ${expected_alarms}=&{EMPTY}    ${alarms}=&{EMPTY}   ${new_way}=False
    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  ta_netact_monitor_fm.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    @{active_alarms}    Get Netact Number Alarms    ${netact_alarms}
    ${alarms_to_delete}    Create List
    ${current_date}=    DateTime.Get Current Date
    ${active_alarms_unique}  remove duplicates  ${active_alarms}

    FOR    ${alarm}    IN    @{expected_alarms}
        ${alarm}    Convert To Integer    ${alarm}
        List Should Contain Value    ${active_alarms_unique}    ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    FOR   ${alarm}   IN   @{allowed_alarms}
        ${alarm}   Convert To Integer   ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    Remove Values From List    ${active_alarms_unique}    @{alarms_to_delete}
    Run Keyword If   "${new_way}"=="True"     Add to alarm list    ${active_alarms_unique}   ${alarms}
    ...   ELSE    Should Be Empty    ${active_alarms_unique}

Check Expected Alarms And Accept Allowed v2
    [Documentation]
    ...    Keyword check whether expected alarms are present on eNB
    ...    By default expected_alarms list is empty
    ...    Allowed alarms could be declared in eNB configuration file
    ...    Author: michal.kusiak@gmail.com
    ...    Update 7.08.2018
    [Arguments]      ${allowed_alarms}=${ALLOWED_ALARMS}    ${expected_alarms}=&{EMPTY}    ${alarms}=&{EMPTY}   ${new_way}=False
    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    @{active_alarms}    Get Netact Number Alarms    ${netact_alarms}
    ${alarms_to_delete}    Create List
    ${current_date}=    DateTime.Get Current Date
    ${active_alarms_unique}  remove duplicates  ${active_alarms}

    FOR    ${alarm}    IN    @{expected_alarms}
        ${alarm}    Convert To Integer    ${alarm}
        List Should Contain Value    ${active_alarms_unique}    ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    FOR   ${alarm}   IN   @{allowed_alarms}
        ${alarm}   Convert To Integer   ${alarm}
        Append To List    ${alarms_to_delete}    ${alarm}
    END

    Remove Values From List    ${active_alarms_unique}    @{alarms_to_delete}
    Run Keyword If   "${new_way}"=="True"     Add to alarm list    ${active_alarms_unique}   ${alarms}
    ...   ELSE    Should Be Empty    ${active_alarms_unique}

Add to alarm list
	[Documentation]  Sub keyword to Check Expected Alarms And Accept Allowed
	[Arguments]    ${active_alarms}    ${alarms}
    Append To List  ${alarms}  ${active_alarms}
    Set Suite Variable    ${alarms}

Check If Alarms From ENB and NetAct Are The Same
    [Documentation]
    ...    Gather alarms from eNB and NetAct and check if they are the same.
    ...    Author: michal.kusiak@nokia.com
    ...    Added checking side Airscale and based on this approprite alarms are added to list corrected_alarms
    ...    Which is used to compare alarms  Author: krystian.gordziejewski@nokia.com
    ...    Added alias as parameter  Author: krystian.gordziejewski@gmail.com

    @{enb_alarms}=    Wait Until Keyword Succeeds   5 x    2 s    Get Active Alarms
    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  ta_netact_monitor_fm.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    ${result}  ${missing_alarm}   compare alarms from enb and netact   ${enb_alarms}    ${netact_alarms}
    Run Keyword If  '${ENB_ID}'!='101001'  Should Be True    ${result}  msg=Some alarms in NetAct are missing(${missing_alarm})

Check If Alarms From ENB and NetAct Are The Same v2
    [Documentation]
    ...    Gather alarms from eNB and NetAct and check if they are the same.
    ...    Author: michal.kusiak@nokia.com
    ...    Added checking side Airscale and based on this approprite alarms are added to list corrected_alarms
    ...    Which is used to compare alarms  Author: krystian.gordziejewski@nokia.com
    ...    Added alias as parameter  Author: krystian.gordziejewski@gmail.com

    @{enb_alarms}=    Wait Until Keyword Succeeds   5 x    2 s    Get Active Alarms
    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    ${result}  ${missing_alarm}   compare alarms from enb and netact   ${enb_alarms}    ${netact_alarms}
    Run Keyword If  '${ENB_ID}'!='101001'  Should Be True    ${result}  msg=Some alarms in NetAct are missing(${missing_alarm})

Cm Upload If CLAB
    [Documentation]
    ...    Performs CM Upload if NA is CLAB
    ...    author: marcin.sokolowski@nokia.com
    [Arguments]  ${alias}=default
    run keyword if    '${NA_TYPE}' == 'clab'    CM Upload    ${alias}

Prepare JSON Plans From Directory
    [Documentation]
    ...    Replace values in template plan file.
    ...    Author: michal.popiel@nokia.com
    [Arguments]         ${source_directory}   ${result_directory}=${RESULTS}/plans
    Log To Console     \n Preparing plans from ${source_directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${source_directory}     absolute=True
    ${i}    Set Variable    0
    FOR    ${file}   IN    @{test_data_files_content}
        ${i}  evaluate  ${i} + 1
        Log To Console  ${file} -> plan_${i}.json
        ${plan}  OperatingSystem.Get File   ${file}
        ${plan}  Replace String  ${plan}  %ENB_ID%  ${ENB_ID}
        Create File   ${result_directory}/plan_${i}.json   ${plan}
    END

Prepare and Import All Plans From Directory
    [Documentation]
    ...    Replacing default values in NA plan template and imports it to NA
    ...    Added additional replacement of %LNCEL% if it existing in template - przemyslaw.romanczyk@nokia.com 26.08.17
    ...    author: marcin.sokolowski@nokia.com
    ...    Added Replacing Paths In Xml <- source: XML_replacer.py
    ...    Author: krystian.gordziejewski@nokia.com
    [Arguments]         ${directory}  ${validate}=${True}  &{kwargs}     #${Cell}=1
    Log To Console     \n Preparing and importing plans from ${directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${directory}      absolute=True
    @{files}  OperatingSystem.List Files In Directory  ${RESULTS}
    remove values from list  ${files}  output.xml
    ${scf_file}  get matches  ${files}  *.xml
    ${scf}  parse scf file  ${RESULTS}/${scf_file[0]}
    ${i}            Set Variable    ${0}
    ${create_paths}  get paths from create objects  ${test_data_files_content}  %PLMN%=${PLMN}  %ENB_ID%=${ENB_ID}
    ...     %ENB_RELEASE%=${ENB_RELEASE}  &{kwargs}
    FOR    ${file}   IN    @{test_data_files_content}
        ${i}  evaluate  ${i} + 1
        ${xml}  Parse xml file  ${file}
        Log To Console  ${file} -> plan_${i}.xml
        ${create_paths}  Replacing Paths In Xml  ${xml}  ${scf}  ${RESULTS}/plans  plan_${i}  ${create_paths}  validate=${validate}
         ...    %PLMN%=${PLMN}  %ENB_ID%=${ENB_ID}  %ENB_RELEASE%=${ENB_RELEASE}  file_nr=${i}  &{kwargs}
        Import Plan Depending On Library  local_dir=${RESULTS}/plans/     input_file=plan_${i}.xml     plan_name=${ENB_ID}_plan_${i}
    END

Import Plan Depending On Library
    [Arguments]  ${local_dir}  ${input_file}  ${plan_name}
    Run Keyword And Ignore Error  Remove Plan  plan_name=${plan_name}
    ${status}  run keyword and return status  CM Import  local_dir=${local_dir}     input_file=${input_file}    plan_name=${plan_name}
    Run Keyword If  not ${status}  Import Plan  local_dir=${local_dir}    file_name=${input_file}     plan_name=${plan_name}

Prepare and Import All Plans From Directory v2
    [Documentation]
    ...    Replacing default values in NA plan template and imports it to NA
    ...    Added additional replacement of %LNCEL% if it existing in template - przemyslaw.romanczyk@nokia.com 26.08.17
    ...    author: marcin.sokolowski@nokia.com
    ...    Added Replacing Paths In Xml <- source: XML_replacer.py
    ...    Author: krystian.gordziejewski@nokia.com
    [Arguments]         ${directory}
    Log To Console     \n Preparing and importing plans from ${directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${directory}      absolute=True
    @{files}  OperatingSystem.List Files In Directory  ${RESULTS}
    remove values from list  ${files}  output.xml
    ${scf_file}  get matches  ${files}  *.xml
    ${scf}  parse scf file  ${RESULTS}/${scf_file[0]}
    ${i}            Set Variable    ${0}
    ${create_paths}  get paths from create objects  ${test_data_files_content}  %PLMN%=${PLMN}  %ENB_ID%=${ENB_ID}
    ...    %ENB_RELEASE%=${ENB_RELEASE}
    FOR    ${file}   IN    @{test_data_files_content}
        ${i}  evaluate  ${i} + 1
        ${xml}  Parse xml file  ${file}
        Log To Console  ${file} -> plan_${i}.xml
        Import Plan Depending On Library v2  local_dir=${RESULTS}/plans/     input_file=plan_${i}.xml     plan_name=${ENB_ID}_plan_${i}
    END

Import Plan Depending On Library v2
    [Arguments]  ${local_dir}  ${input_file}  ${plan_name}
    #Run Keyword And Ignore Error  Delete Plan  plan_name=${plan_name}
    Import Configuration  local_dir=${local_dir}    file_name=${input_file}     plan_name=${plan_name}

Provision All Backups
    [Documentation]
    ...    Proision all backup plans from list. Check if onAir after each (due to reset possibility)
    ...    author: marcin.sokolowski@nokia.com
    [Arguments]  ${list}    ${validate}=True   #${alias_na_cm}=default    ${alias_infomodel}=default
    Reverse List  ${list}
    FOR   ${plan}   IN   @{list}
        log to console    \nRestoring from backup plan ${plan}
        Provision Plan    ${plan}    validate=${validate}
#        Wait Until keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled    alias=${alias_infomodel}
    END
    Reverse List  ${list}

Collect Snapshot If Alarms Are Present
    [Arguments]    ${target_dir}=${RESULTS}  ${snapshot_name}=ims_snapshot.ims2  @{alarms}
    [Documentation]
    ...   It is intended to use this kw in order to collect ims snapshot and clear 'diagnostic files collected' alarm
    ...   Author: michal.kusiak@nokia.com

    ${netact_alarms_dicts}=    taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}    only_active=True
    ${netact_alarms_ids}=      Get Netact Alarm Ids    ${netact_alarms_dicts}

    ${bool_list}  Create List

    FOR   ${alarm}   IN   @{alarms}
        ${evaluation}=  Evaluate  ${alarm} in ${netact_alarms_ids}
        Append To List  ${bool_list}  ${evaluation}
    END

    ${any_evaluation}  Evaluate  any(${bool_list})
    ${target_file_name}  Set Variable  ${target_dir}${/}${snapshot_name}

    Run Keyword If  "${any_evaluation}"=="True"  Collect Im Snapshot  target_file_name=${target_file_name}


Set Reset Counter Before Test
    [Documentation]
    ...   Check reset counter before test and assign it to suite variable.
    ...   For start checkpoint.
    ...   Author: michal.popiel@nokia.com
    [Arguments]  ${alias_ta_enb}=ta_enb
    ${reset_count}=    lib_SFE.Get Reset Counter New    source=ddal  alias=${alias_ta_enb}
    Set Suite Variable    ${reset_suite}    ${reset_count}

Check If Reset Counter Incremented
    [Documentation]
    ...   Check if eNB reset counter is incremented by 1 compared to suite variable reset_suite, which is updated, if keyword succeeds.
    ...   For Destructive TCs.
    ...   Author: michal.popiel@nokia.com
    [Arguments]  ${alias_ta_enb}=ta_enb
    ${reset_count}=   lib_SFE.Get Reset Counter New    source=ddal  alias=${alias_ta_enb}
    ${reset_increment}=    Evaluate  ${reset_count} - ${reset_suite}
    ${passed}=             Evaluate    0 < ${reset_increment} < 3
    Run Keyword If   not ${passed}   Fail
    Run Keyword If       ${passed}   Set Suite Variable  ${reset_suite}     ${reset_count}
    Run Keyword If       ${passed}   Log To Console    Reset counter - ${reset_count} (+${reset_increment})

Check If Reset Counter Did Not Change
    [Documentation]
    ...   Check if eNB reset counter did not change.
    ...   For Non-Destructive TCs.
    ...   Author: michal.popiel@nokia.com
    [Arguments]  ${alias_ta_enb}=ta_enb
    ${reset_count}=   lib_SFE.Get Reset Counter New    source=ddal  alias=${alias_ta_enb}
    Should Be Equal    ${reset_count}    ${reset_suite}


Login To OMS
    [Documentation]     Login to OMS with given credentials
    ...                 Author: przemyslaw.romanczyk@nokia.com
    [Arguments]         ${oms_host}=${OMS_HOST}  ${oms_login}=root  ${oms_pass}=siemens
    [Timeout]           40 seconds

                        ${local_oms_connection}=  SSHLibrary.Open Connection        ${oms_host}
                        ${prompt}=    Set Variable If    "${oms_login}" == "root"    \#    $
                        Set Client Configuration    prompt=${prompt}
                        Set Global Variable     ${oms_connection}  ${local_oms_connection}
                        Set Global Variable   ${oms_user}  ${oms_login}
                        SSHLibrary.Switch Connection       ${oms_connection}
                        SSHLibrary.Login  ${oms_login}   ${oms_pass}

Check if CELL status in NA is actual
    [Documentation]    Kw go through all cells if their NA status (operationalState) is consistent with actual state w/ perfirming CM Upload
    ...    Author: marcin.sokolowski@nokia.com
    [Arguments]  ${na_alias}=default    ${im_alias}=default
    ${cell_paths}=    create dictionary
                      ...   FL16A=/MRBTS-1/RAT-1//LNBTS-1/LCELL-
                      ...   FL17A=/MRBTS-1/RAT-1//CELL_M-
                      ...   FL17SP=/MRBTS-1/RAT-1//CELL_M-
                      ...   FL17ASP1=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
                      ...   SBTS17A=/MRBTS-1/RAT-1//CELL_M-
                      ...   FL18=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
                      ...   FL18SP=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
                      ...   FL18A=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    get from dictionary    ${cell_paths}    ${ENB_RELEASE}

    ${rnd_string}=    generate random string    5    UPPER
    ${plan_file}=     Set Variable    ${ENB_ID}_${rnd_string}.xml
    cm export    ${RESULTS}    ${plan_file}    alias=${na_alias}

    ${cells}   Query Infomodel
    ...    query=get list ${path}*
    ...    alias=${im_alias}

    FOR    ${cell}    IN    @{cells}
        ${dist}=    get from dictionary  ${cell}  dist_name
        ${cell_no}=    fetch from right  ${dist}  -
        ${stateInfo}    Get From Dictionary   ${cell}    stateInfo
        ${procedural_state}    Get From Dictionary   ${stateInfo}    proceduralState
        ${procedural_state}=    evaluate    "${procedural_state}".upper()
        ${value}=    run keyword if    '${procedural_state}'=='ONAIRDONE'    set variable    1
        ...          ELSE     Set Variable    0
        ${element_xpath}=    set variable
        ...    .//managedObject[@distName="PLMN-PLMN/MRBTS-${ENB_ID}/LNBTS-${ENB_ID}/LNCEL-${cell_no}"]/p[@name="operationalState"]
        ${na_value}=    XML.get_element_text
        ...                 ${RESULTS}/${plan_file}
        ...                 ${element_xpath}
        Should Be Equal    ${value}    ${na_value}
    END


#Check which side is your AirScale
#	[Documentation]    Check AirScale's side
#	...                Author: krystian.gordziejewski@nokia.com
#	[Arguments]  ${alias}=To_side
#	Set Software Release
##	Run Keyword If    '${ENB_RELEASE}'=='FL18SP'      Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#	       #...    password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=3600  alias=${alias}
##	...    ELSE IF    '${ENB_RELEASE}'=='FL18'        Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#	       #...    password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=3600  alias=${alias}
##	...    ELSE IF    '${ENB_RELEASE}'=='FL18A'       Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#	       #...    password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=3600  alias=${alias}
##	...    ELSE IF    '${ENB_RELEASE}'=='FL17ASP1'    Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#	       #...    password=${ENB_ROOT_PASS}  alias=${alias}
##	...       ELSE                                    Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#	       #...    password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF   '${ENB_RELEASE}'=='FL00'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF   '${ENB_RELEASE}'=='FL19'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='FL19A'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS18SP'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS18'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS18A'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS19'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS19A'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='SBTS19B'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE IF  '${ENB_RELEASE}'=='TL19'  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}
#    #password=${ENB_ROOT_PASS}  use_admin=True  infomodel_port=443  alias=${alias}
##	...             ELSE  Setup Ta Enb    hostname=${ENB_MPLANE_IP}    username=${ENB_ROOT_USER}    password=${ENB_ROOT_PASS}  alias=${alias}
#    Return From Keyword If  '${ENB_RELEASE}'=='FL16A'  1
#    ${status_5g}  run keyword and return status  variable should exist  ${5G}
#    Run keyword If    '${status_5g}' == 'True'    Get Bts L for 5G
#    ${status}  run keyword and return status  variable should exist  ${ENB_SIDE}
#    ${ENB_SIDE}  Run Keyword If  '${status}' == 'False'  Get Bts L  ${ENB_ID}   timeout=60  alias=${alias}  ELSE  Set Variable  ${ENB_SIDE}
#    #[Teardown]  Teardown Ta Enb  ${alias}
#    [Return]  ${ENB_SIDE}

Check which side is your AirScale    #4- right side 1- left side
	[Documentation]    Check AirScale's side
	...                infomodel querry for EQM_R
	...                EQM_R's id shows correct value
	...                EQM_R-1 = primary SMOD on left side (value:1)
	...                EQM_R-2 = primary SMOD on right side (value:4)
	...                Author: szymon.romanowski@nokia.com

    Set Software Release
    ${infomodel_querry}=  Infomodel Get Objects Parameter  //EQM_R-*  dist_name
    ${ENB_SIDE}=    Get Substring    ${infomodel_querry}[0]    -1
	[Return]  ${ENB_SIDE}

Get Bts L for 5G
	[Documentation]    Check AirScale's side for 5G eNB
	...                Author: bartosz.betka@nokia.com
    ${distname_with_bts_l}    Query Infomodel    query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/NRBTS_R-${ENB_ID}/REF-*
    #Log    ${distname_with_bts_l.dist_name}    console=true
    ${ENB_SIDE_TEMP}    Fetch from right    ${distname_with_bts_l.dist_name}    RUNTIME_VIEW-
    ${ENB_SIDE_2}    Fetch from left    ${ENB_SIDE_TEMP}    /MRBTS_R
    Set suite variable    ${ENB_SIDE}    ${ENB_SIDE_2}

Get Bts L
	[Documentation]    Check AirScale's side for 5G eNB
	...                Author: bartosz.betka@nokia.com
    ${distname_with_bts_l}    Query Infomodel    query=get object /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/REF-*
    #Log    ${distname_with_bts_l.dist_name}    console=true
    ${ENB_SIDE_TEMP}    Fetch from right    ${distname_with_bts_l.dist_name}    RUNTIME_VIEW-
    ${ENB_SIDE_2}    Fetch from left    ${ENB_SIDE_TEMP}    /MRBTS_R
    Set suite variable    ${ENB_SIDE}    ${ENB_SIDE_2}

Collecting Snapshot
        [Documentation]  Gather logs from System Module and Radio Modules. Snapshot saved in RESULTS
    ...             Keyword doesn't clear Diagnostic Files Collected alarm
    ...             Author: krystian.gordziejewski@nokia.com

    Set Log Level  NONE
    ${list_of_snapshot_files}   set variable  Snapshot.zip
    @{radio_modules_files}  create list
    @{missing_files}    create list
    ${date}  Get Current Date    UTC   result_format=%Y%m%d-%H%M
    SSHLibrary.open connection  ${ENB_MPLANE_IP}
    SSHLibrary.Login  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
    # Kill AaShell instance if connected
#    ${enb_side}  Check Which Side Is Your AirScale  ${alias}
    ${is_rfSharing}  Get Parameter From Infomodel  //RUNTIME_VIEW-${ENB_SIDE}//FEATCADM_CONF_M-1  rfSharingEnabled
    ${sm_ip}  Set Variable If  ${is_rfSharing}  192.168.255.5  192.168.255.129
    SSHLibrary.Write  kill $(ps aux | grep '[t]elnet 192.168.255')
    SSHLibrary.Read until  ~ >
    # Connect to AaShell
    SSHLibrary.Write  telnet ${sm_ip} 15007
    SSHLibrary.Read until  AaShell>
    # Gather snapshot from SM
    SSHLibrary.Write  log -a -z Snapshot.zip
    wait until keyword succeeds  20x  10s  SSHLibrary.read until  AaShell>
    SSHLibrary.Write  quit
    SSHLibrary.read until  ~ >
    # list all files in zip
    SSHLibrary.Write  unzip -l /ram/Snapshot.zip
    ${files}  SSHLibrary.Read Until  >
    # Add to list all files names without extensions
    ${system_module_files}  get regexp matches  ${files}  (\\d+|\\w+)\\_[\\w\\-\\.]+
    ${number_of_radio_modules}  ${paths}  Get The Number Of RadioModules
    # Gather snapshot form RMs
    FOR  ${i}  IN RANGE  ${number_of_radio_modules}
        ${number}  evaluate  ${i} + 1
        ${path}  get from list  ${paths}  ${i}
        ${ip}  ${name}  Get Ip And Name Of RadioModule  ${path}
        ${name_of_file}  set variable  RMOD_L-${number}.zip
    # Connect to RM
        SSHLibrary.Write  telnet ${ip} 2323
        ${status}  run keyword and return status  SSHLibrary.Read until regexp  (\\$|\\>)
    # If connection fails, open new connection and go to next iteration
        run keyword if  ${status}==False  append to list  ${missing_files}  There is no files from RM ${name}
        run keyword if  ${status}==False  SSHLibrary.open connection  ${ENB_MPLANE_IP}
        run keyword if  ${status}==False  SSHLibrary.Login  ${ENB_ROOT_USER}  ${ENB_ROOT_PASS}
        continue for loop if  ${status}==False
    # Collect snapshot from RM
        SSHLibrary.Write  log -a -z snapshot.zip
        wait until keyword succeeds  5x  5s  SSHLibrary.Read until  Add file
        wait until keyword succeeds  20x  10s  SSHLibrary.Read until regexp  (\\$|\\>)
        SSHLibrary.Write  exit
        SSHLibrary.Read until  >
    # Get snapshot file to SM
        SSHLibrary.Write  ftpget ${ip} /ram/RMOD_L-${number}.zip snapshot.zip
        wait until keyword succeeds  20x  10s  SSHLibrary.Read until  >
        SSHLibrary.Write  unzip -l /ram/RMOD_L-${number}.zip
        ${files}  SSHLibrary.read until  ~ >
    # List and add all filenames without extensions
        ${part_of_files}  get regexp matches  ${files}  (\\d+|\\w+)\\_[\\w\\-\\.]+
        append to list  ${radio_modules_files}  @{part_of_files}
        ${list_of_snapshot_files}  catenate  ${list_of_snapshot_files}  ${name_of_file}
    END
    SSHLibrary.Write  cd /ram
    SSHLibrary.Read until  /ram >
    # Pack all files to one file
    SSHLibrary.Write  tar -cvf /ram/Snapshot_${date}.tar.gz ${list_of_snapshot_files}
    SSHLibrary.Read until  >
    # Get whole snapshot file and save to RESULTS
    SSHLibrary.Get File  /ram/Snapshot_${date}.tar.gz  ${RESULTS}/Snapshot_MRBTS-${ENB_ID}_${active_sw_version}_eNB_${ENB_ID}_${date}.tar.gz
    Check Mandatory Files  ${system_module_files}  ${radio_modules_files}  ${number_of_radio_modules}  ${missing_files}
    [Teardown]  SSHLibrary.Write  rm /ram/Snapshot_${date}.tar.gz ${list_of_snapshot_files}

Get Ip And Name Of RadioModule
    [Documentation]  Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${path}
    #${enb_side}  Check which side is your AirScale
    ${parameter_dict}  query infomodel  get object ${path}
    ${ip}  get from dictionary  ${parameter_dict}  ipAddress
    ${name}  get from dictionary  ${parameter_dict}  productName
    [Return]  ${ip}  ${name}

Check Mandatory Files
    [Documentation]  Check if snapshot contains all mandatory files, depends on number of RM
    [Arguments]  ${system_module_files}  ${radio_modules_files}  ${number_of_radio_modules}  ${missing_files}
    @{mandatory_SM_files_regex}  create list  \\d+11_runtime.zip  \\d+11_pm_1_syslog.zip  \\d+11_im_snapshot.ims2
    ...                                       \\d+11_pm_im_snapshot.ims2  \\d+11_pm_1_sysinfo.zip  \\d+11_pm_2_sysinfo.zip
    ...                                       \\d+11_runtime_sysinfo.zip  .*HwapiSrio.log  .*linux_logs.tar  .*CCNTrace.zip  .*RNWTrace.zip

    @{mandatory_RM_files_regex}     create list  F01_FileDirectory.xml  F01_frozenFrame.log  .*MemoryConsumption_LastDay.csv
    ...                                         .*MemoryConsumption_LastFourHours.csv  .*MemoryConsumption_LastMonth.csv
    ...                                         .*_fault_history_log.txt  .*_pm_collect.log  .*BlackBox.xml  .*runtime.zip  .*startup.zip
    FOR  ${regex}  IN  @{mandatory_SM_files_regex}
        ${count}  get match count  ${system_module_files}  regexp=${regex}
        ${status}  run keyword and return status  should be true  ${count}>0
        run keyword if  ${status}==False  append to list  ${missing_files}  ${regex}
    END
    FOR  ${regex}  IN  @{mandatory_RM_files_regex}
        ${count}  get match count  ${radio_modules_files}  regexp=${regex}
        ${status}  run keyword and return status  should be true  ${count}==${number_of_radio_modules}
        run keyword if  ${status}==False  append to list  ${missing_files}  ${regex}
    END
    ${length}  get length  ${missing_files}
    Run Keyword If  ${length}>0  Log  Snapshot missing files: @{missing_files}  WARN

Get The Number Of RadioModules
    [Documentation]  Keyword gets number of RM and paths
    ...             Author: krystian.gordziejewski@nokia.com

    @{paths}  create list
#    ${enb_side}  Check which side is your AirScale  ${alias}
    ${RM_list}  Query Infomodel  get list //BTS_L-${ENB_SIDE}/EQM_L-1/RMOD_L-*
    FOR  ${element}  IN  @{RM_list}
        ${path}  get from dictionary  ${element}  dist_name
        append to list  ${paths}  ${path}
    END
    ${list_length}  Get Length  ${RM_list}
    [Return]  ${list_length}  ${paths}

Perform LNCEL CCN Check on IOMS
    [Documentation]  Keyword checks if there was ccn generated for every cell for disabled and enabled state during eNB
    ...    reset procedure.
    ...       *  time parameter - is mandatory. It's time when reset procedure begins. Recommended usage:
    ...             ${time}=    DateTime.Get Current Date    time_zone=UTC  result_format=%Y-%m-%d %H:%M:%S  exclude_millis=True
    ...             Reset Bts
    ...             Sleep  20s
    ...             wait until keyword succeeds  8x   2min   Check If Cells OnAir Or PowerSaving Enabled
    ...             Sleep  120s
    ...             Perform LNCEL CCN Check on IOMS    time=${time}
    ...       *  local_store - optional parameter. Recomended to use during stress tests or tests with multiple resets, i.e.:
    ...             Perform LNCEL CCN Check on IOMS  local_store=${RESULTS}/CCN/CCN_logs_${i}.txt
    ...             where ${i} is current iteration number in loop
    ...    author: marcin.sokolowski@nokia.com
    [Arguments]    ${time}    ${local_store}=${RESULTS}/CCN/CCN_logs.txt
    [Timeout]    5 min
    ${cells}=    Create List of Cells
    sort list  ${cells}
    log to console  \nList of cells created
    Delete Temp Log
    Log To Console  \nStarting checking CCNs
    Prepare CMaussrv_trace file
    @{cell_states}=  get_lncel_ccns_from_ioms
    ...                     remote_path=/var/log/oms/temp_log.txt
    ...                     local_path=${local_store}
    ...                     oms_ip=${OMS_HOST}
    ...                     oms_login=${OMS_USER}
    ...                     oms_password=${OMS_PASS}
    ...                     enb_id=${ENB_ID}
    ...                     cells_list=${cells}
    ...                     start_time=${time}
    Log To Console  \nCell states acquired, validating...
    ${result}=  validate cells states  ${cell_states}
    ${comm}=  get from dictionary  ${result}  comment
    ${res}=  get from dictionary  ${result}  result
    log to console    \nValidation complete
    Log  ${comm}
    Delete Temp Log
    should be true  ${res}


Create List of Cells
    [Documentation]  Keyword checks cell_ids and returns a list containing every cell_id. Requires previously setup infomodel
    ...    author: marcin.sokolowski@nokia.com
    [Arguments]  ${alias}=default
    [Timeout]  5 min
    ${list_of_cells}   create list
#    ${side}  Check which side is your AirScale
#    ${cell_paths}    create dictionary
#                      ...   FL16A=/MRBTS-1/RAT-1//LNBTS-1/LCELL-
#                      ...   FL17A=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
#                      ...   FL17SP=/MRBTS-1/RAT-1//CELL_M-
#                      ...   FL17ASP1=/MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//LNCEL_M-
#                      ...   SBTS17A=/MRBTS-1/RAT-1//CELL_M-
#                      ...   SBTS18=/MRBTS-1/RAT-1//CELL_M-
#                      ...   SBTS18SP=/MRBTS-1/RAT-1//CELL_M-
#                      ...   FL18=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
#                      ...   FL18SP=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
#                      ...   FL18A=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
#                      ...   FL19=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
#                      ...   FL19A=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
#                      ...   SBTS19A=/MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    Run Keyword If    '${ENB_RELEASE}'=='FL16A'       Set Variable      /MRBTS-1/RAT-1//LNBTS-1/LCELL-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17A'       Set Variable      /MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17SP'      Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17ASP1'    Set Variable      /MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//LNCEL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='SBTS17A'     Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='SBTS18SP'    Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE                                       Set Variable
                       ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-

    ${cells}   Query Infomodel
    ...             query=get list ${path}*
    ...             alias=${alias}
    FOR    ${cell}    IN    @{cells}
        ${dist}=    get from dictionary  ${cell}  dist_name
        ${cell_no}=    fetch from right  ${dist}  -
        append to list  ${list_of_cells}  ${cell_no}
    END
    [Return]  ${list_of_cells}

Create List Of FDD Cells
    [Documentation]  Keyword checks cell_ids and returns a list containing every cell_id. Requires previously setup infomodel
    ...    author: marcin.sokolowski@nokia.com
    [Arguments]  ${alias}=default
    [Timeout]  5 min
    ${list_of_cells}   create list
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    Run Keyword If    '${ENB_RELEASE}'=='FL16A'       Set Variable      /MRBTS-1/RAT-1//LNBTS-1/LCELL-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17A'       Set Variable      /MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17SP'      Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='FL17ASP1'    Set Variable      /MRBTS-1/RAT-1/MCTRL-${ENB_SIDE}//LNCEL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='SBTS17A'     Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE IF    '${ENB_RELEASE}'=='SBTS18SP'    Set Variable      /MRBTS-1/RAT-1//CELL_M-
    ...                ELSE                                       Set Variable
                       ...    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNBTS_R-${ENB_ID}/LNCEL_R-

    ${cells}   Query Infomodel
    ...             query=get list ${path}*
    ...             alias=${alias}
    FOR    ${cell}    IN    @{cells}
        ${dist}=    get from dictionary  ${cell}  dist_name
        ${cell_no}=    fetch from right  ${dist}  -
        ${tech}=   Get Parameter From Infomodel   //BTS_L-${ENB_SIDE}/BTS_CONF-1//LNBTS_A-${ENB_ID}/LNCEL_A-${cell_no}    cellTechnology
        Run Keyword If   '${tech}'=='FDD'   Append To List   ${list_of_cells}  ${cell_no}
    END
    [Return]  ${list_of_cells}

Prepare CMaussrv_trace file
    [Documentation]  Keyword prepares combined CMasuSrv_trace file for CCN check
    ...    author: marcin.sokolowski@nokia.com
    [Timeout]   5 min
    SSHLibrary.Open Connection
    ...     host=${OMS_HOST}
    ...     alias=prepare
    SSHLibrary.Login
    ...     username=${OMS_USER}
    ...     password=${OMS_PASS}
    SSHLibrary.Execute Command    Catenate
    ...    command=cat /var/log/oms/CMausSrv_trace.txt.3 /var/log/oms/CMausSrv_trace.txt.2 /var/log/oms/CMausSrv_trace.txt.1
    ...    /var/log/oms/CMausSrv_trace.txt > /var/log/oms/temp_log.txt
    log to console  \nAggregated log file created
    SSHLibrary.Close Connection

Delete Temp Log
    [Documentation]  Keyword deletes combined CMasuSrv_trace file for CCN check after use.
    ...    author: marcin.sokolowski@nokia.com
    [Timeout]  5 min
    SSHLibrary.Open Connection
    ...     host=${OMS_HOST}
    ...     alias=deletion
    SSHLibrary.Login
    ...     username=${OMS_USER}
    ...     password=${OMS_PASS}
    SSHLibrary.Execute Command
    ...     command=rm /var/log/oms/temp_log.txt
    ...     return_stdout=False
    log to console  \nTemporary log deleted
    SSHLibrary.Close Connection

Check Expected Faults And Accept Allowed
    [Documentation]
    ...    Keyword check whether expected faults are present on eNB
    ...    By default expected_faults list is empty
    ...    Allowed faults could be declared in eNB configuration file
    ...    Author: krystian.gordziejewski@gmail.com

    [Arguments]      ${allowed_faults}    ${expected_faults}=&{EMPTY}

    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  ta_netact_monitor_fm.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    ${active_faults}  Get Netact Alarm IDs  ${netact_alarms}
#    FOR   ${alarm}  in  @{active_alarms.keys()}
#        ${alarm_info}  get from dictionary  ${active_alarms}  ${alarm}
#        ${alarm_string}  convert to string  ${alarm_info}
#        ${fault}  get regexp matches  ${alarm_string}  (?<=additionalFaultI[dD][:=])\\d+
#        append to list  ${active_faults}  @{fault}
#    END
    ${active_faults_unique}  remove duplicates  ${active_faults}
    ${faults_to_delete}    Create List
    #Check if all of expected alarms are present on eNB

    FOR   ${fault}   IN   @{allowed_faults}
        ${fault}   Convert To Integer   ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    FOR    ${fault}    IN    @{expected_faults}
        ${fault}  convert to integer  ${fault}
        list should contain value    ${active_faults_unique}    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    Remove Values From List    ${active_faults_unique}    @{faults_to_delete}
    Should Be Empty    ${active_faults_unique}

Check Expected Faults And Accept Allowed v2
    [Documentation]
    ...    Keyword check whether expected faults are present on eNB
    ...    By default expected_faults list is empty
    ...    Allowed faults could be declared in eNB configuration file
    ...    Author: krystian.gordziejewski@gmail.com

    [Arguments]      ${allowed_faults}    ${expected_faults}=&{EMPTY}

    ${status}  ${netact_alarms}  run keyword and ignore error  taf.nms.netact.Get Alarms    dist_name=${PLMN}/MRBTS-${ENB_ID}     only_active=True
    ${netact_alarms}  Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE  set variable  ${netact_alarms}
    ${active_faults}  Get Netact Alarm IDs  ${netact_alarms}

    ${active_faults_unique}  remove duplicates  ${active_faults}
    ${faults_to_delete}    Create List
    #Check if all of expected alarms are present on eNB

    FOR   ${fault}   IN   @{allowed_faults}
        ${fault}   Convert To Integer   ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    FOR    ${fault}    IN    @{expected_faults}
        ${fault}  convert to integer  ${fault}
        list should contain value    ${active_faults_unique}    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    Remove Values From List    ${active_faults_unique}    @{faults_to_delete}
    Should Be Empty    ${active_faults_unique}

Get Parameter From Infomodel
    [Documentation]  Keyword gets parameter from infomodel independently from structure of object
    ...             Works only for one object, dont use * in dist_name
    ...             Also works on regex. Don't use .+ and .*
    ...             Returns list if more than one parameter or string if only one parameter
    ...             Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${dist_name}  ${regex_parameter}  ${allow_negative_results}=False  ${alias}=default
    @{parameters}  create list
    ${object}  query infomodel  get object ${dist_name}  alias=${alias}  allow_negative_result=${allow_negative_results}
    ${length}  Get Length  '${object}'
    Run Keyword If  ${allow_negative_results}  Return From Keyword If  ${length}==6  ${object}
    #${string}  convert to string  ${object}
    #${matches}  get regexp matches  ${string}  (?<=')${regex_parameter}': (u'|/|\\s|\\w|-|\\d|\\.|\\[.*\\]|\\:|\\(|\\)|\\+)+
    ${matches}  Get From Dictionary  ${object}  ${regex_parameter}  #added by sr
    #FOR  ${element}  IN  @{matches}
    #    ${matches}  get regexp matches  ${element}  (?<=..:\\s|:\\su')(/|\\s|\\w|-|\\d|\\.|\\[.*\\]|\\:|\\(|\\)|\\+)+
    #    remove values from list  ${matches}  u
    #    append to list  ${parameters}  @{matches}
    #END
    append to list  ${parameters}  ${matches}  #added by sr
    ${length}  get length  ${parameters}
    ${parameter}  run keyword if  ${length}<2  get from list  ${parameters}  0
    return from keyword if  ${length}<2  ${parameter}
    [Return]  ${parameters}

Check OMS
    [Documentation]  Check if configuration from eNB is the same as configuration in config files.
    ...              If not change variables values to proper
    ...              Author: krystian.gordziejewski@nokia.com

#    ${enb_side}  Check Which Side Is Your AirScale  ${alias}
    ${active_sw_version}  get parameter from infomodel  //BTS_L-${ENB_SIDE}/BTS_CONF-1  activeSoftwareVersion  allow_negative_results=True
    ${oms_ip}  Get Parameter From Infomodel  /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//FTM-1  omsIpAddress    allow_negative_results=True
    Parse IOMS Files    ${oms_ip}

Parse IOMS files
    [Documentation]  Read OMS config files and set proper OMS and NA variables.
    ...              Syntax: Parse IOMS Files  ENB_ID  oms_ip
    ...              Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${oms_ip}
    Log  eNB is connected to OMS: ${oms_ip}  WARN  console=True
    ${ioms_directory}  set variable  /home/ute/sfe_wro_robot_oam/trunk/config/Wroclaw/GVe/SFE/ioms
    ${ioms_list}  OperatingSystem.List Directory  ${ioms_directory}
    ${ioms_file}  set variable  ${EMPTY}
    FOR  ${ioms}  IN  @{ioms_list}
        ${s}  ${tmp}  run keyword and ignore error  OperatingSystem.Get File  ${ioms_directory}/${ioms}
        ${lines}  Get Regexp Matches  ${tmp}  OMS_HOST_SB\\s*=\\s*"${oms_ip}"
        ${len}  Get Length  ${lines}
        ${oms_name}  fetch from left  ${ioms}  .
        Run Keyword If  ${len}>0  log to console  Connected to OMS: ${oms_name}
        Exit For Loop IF    ${len}>0
    END
    ${ioms_file}  set variable  ${tmp}
    Set Proper OMS Variables  ${ioms_file}
    Set Proper NA Variables  ${ioms_file}

Set Proper NA Variables
    [Documentation]  Basing on OMS config file read proper NA config file and set to NA variables proper values
    ...              Syntax:  Set Proper NA Variables  parsed_oms_file
    ...              Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${oms_file}
    ${netact_directory}  Set Variable  /home/ute/sfe_wro_robot_oam/trunk/config/Wroclaw/GVe/SFE/netact
    ${netact_import_name}  Get Regexp Matches  ${oms_file}  netact\\.[^\\s+]+
    ${tmp_netact_file_name}  Fetch From Right  ${netact_import_name[0]}  .
    Log To Console  Connected to NetAct: ${tmp_netact_file_name}
    ${netact_file_name}  catenate  SEPARATOR=.  ${tmp_netact_file_name}  py
    ${netact_file}  OperatingSystem.Get File  ${netact_directory}/${netact_file_name}
    ${matches}  Get Regexp Matches  ${netact_file}  (NA|na|LBWAS)\\w+\\s*\\=\\s*(\\"|\\')[^"'\\s]+
    FOR  ${ele}  IN  @{matches}
        ${value}  fetch from right  ${ele}  "
        ${value}  fetch from right  ${value}  '
        ${par}  fetch from left  ${ele}  =
        ${param}  fetch from left  ${par}  ${SPACE}
        Set Global Variable  ${${param}}  ${value}
    END

Set Proper OMS Variables
    [Documentation]  Basing on OMS config file set to OMS variables proper values
    ...              Syntax:  Set Proper OMS Variables  parsed_oms_file
    ...              Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${ioms_file}
    ${matches}  Get Regexp Matches  ${ioms_file}  OMS\\w*\\s*\\=\\s*(\\'|\\")[^"'\\s]+
    FOR  ${ele}  IN  @{matches}
        ${value}  fetch from right  ${ele}  "
        ${value}  fetch from right  ${value}  '
        ${par}  fetch from left  ${ele}  =
        ${param}  fetch from left  ${par}  ${SPACE}
        Set Global Variable  ${${param}}  ${value}
    END

Show Current Configuration
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com

#    ${enb_side}  Check Which Side Is Your AirScale  ${alias}
    ${active_sw_version}  get parameter from infomodel  /MRBTS-1//RUNTIME_VIEW-${ENB_SIDE}//MNL_R-1  activeSWReleaseVersion
    ...    allow_negative_results=True
#    ${distname}  Set Variable If  ${ENB_RELEASE}=='FL19'  //SMOD-*    //RUNTIME_VIEW-${ENB_SIDE}//SMOD_R-1/INVUNIT_R-1
    ${system_module_info}  run keyword and ignore error  get parameter from infomodel  //SMOD-*  variant
    Set Suite Variable  ${active_sw_version}  ${active_sw_version}
    Log  System Module Type: ${system_module_info[1]}  WARN  console=True
    Log  eNB ID: ${ENB_ID}  WARN  console=True
    Log  Active Software Version: ${active_sw_version}  WARN  console=True
    Log  Connected to OMS: ${OMS}  WARN  console=True
    ${NetAct_name}  Get Regexp Matches  ${LBWAS_NODE}  (?i)[a-z]+\\d+
    Log  Connected to NetAct: ${NetAct_name[0]}  WARN  console=True

Show Current SBTS Configuration
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${alias}=default
#    Set Software Release
#    ${enb_side}  Check Which Side Is Your AirScale  ${alias}
    ${active_sw_version}  get parameter from infomodel  /MRBTS-1//RUNTIME_VIEW-${ENB_SIDE}//MNL_R-1  activeSWReleaseVersion  alias=${alias}
    ${system_module_info}  run keyword and ignore error  get parameter from infomodel  //RUNTIME_VIEW-${ENB_SIDE}//SMOD_R-1/INVUNIT_R-1
    ...    inventoryUnitType
    Set Suite Variable  ${active_sw_version}  ${active_sw_version}
    Log  System Module Type: ${system_module_info[1]}  WARN  console=True
    Log  eNB ID: ${ENB_ID}  WARN  console=True
    Log  Active Software Version: ${active_sw_version}  WARN  console=True
    ${NetAct_name}  Get Regexp Matches  ${LBWAS_NODE}  (?i)[a-z]+\\d+
    Log  Connected to NetAct: ${NetAct_name[0]}  WARN  console=True

Show Current SBTS Configuration PM
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com
    [Arguments]  ${alias}=default
    ${active_sw_version}  get parameter from infomodel  /MRBTS-1//RUNTIME_VIEW-${ENB_SIDE}//MNL_R-1  activeSWReleaseVersion  alias=${alias}
    Set Suite Variable  ${active_sw_version}  ${active_sw_version}
    Log  eNB ID: ${ENB_ID}  WARN  console=True
    Log  Active Software Version: ${active_sw_version}  WARN  console=True

Show Software Version
    [Documentation]  Shows actual configuration on ENB basing on config files
    ...              Author: krystian.gordziejewski@nokia.com
    ...              Modified to show only SW build by michal.popiel@nokia.com
    ...              Modified path to get Sysyem Module Type by artur.lebek@nokia.com & mateusz.marcinkow@nokia.com
    [Arguments]  ${alias}=default
    ${active_sw_version}  get parameter from infomodel  /MRBTS-1//RUNTIME_VIEW-${ENB_SIDE}//MNL_R-1  activeSWReleaseVersion  alias=${alias}
    ${system_module_info}  run keyword and ignore error  get parameter from infomodel  /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//SMOD_BP_L-1  fcmVariant
    Set Suite Variable  ${active_sw_version}  ${active_sw_version}
    Log  eNB ID: ${ENB_ID} System Module Type: ${system_module_info[1]}   WARN  console=True
    Log  Active Software Version: ${active_sw_version}  WARN  console=True

Set Software Release
    ${sw_release}  Get Software Release  ${ENB_MPLANE_IP}
    Set Suite variable  ${ENB_RELEASE}  ${sw_release}

SSH to eNB and execute
    [Documentation]  Login do eNB via SSH and execute 'command' and return output.
    [Arguments]  ${command}
    ...  ${enb_mplane}=${ENB_MPLANE_IP}  ${alias}=ssh_enb
    ...  ${login}=toor4nsn  ${password}=oZPS0POrRieRtu
    SSHLibrary.Open Connection  host=${enb_mplane}  alias=${alias}
    SSHLibrary.Login  username=${login}  password=${password}
    ${output}=  SSHLibrary.Execute Command  command=${command}
    [Return]    ${output}
    [Teardown]  SSHLibrary.Close Connection

Set Parameter On Enb Using Admin Or BTSSM
    [Arguments]  ${distname}  ${parameter_name}  ${operation}  ${value}
    Import Library  taf.sbts.oam.coam.admin
    ${status_sbts}  run keyword and return status  Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=Parameter_change
    ${status_fl}   Run Keyword If  not ${status_sbts}  run keyword and return status  Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=3600
    ...    use_ssl=True  alias=Parameter_change
    return from keyword if  ${status_fl}==False  None
    ${activation_status}  run keyword and return status  Perform Parameter Recommissioning  dist_name=${distname}
    ...                         parameter=${parameter_name}  operation=${operation}  value=${value}  alias=Parameter_change
    Run Keyword If  not ${activation_status}    run keyword and return status  Prepare And Setup BTSSM
    ${activation_status_btssm}  Run Keyword If  not ${activation_status}  Run Keyword And Return Status  Perform Parameter Commissioning
    ...    FEATCADM:1:${parameter_name}:${value}  alias=Parameter_change
    [Teardown]  run keyword and ignore error  Run Keywords  Teardown Admin  alias=Parameter_change  AND  Teardown Btssm  alias=Parameter_change

Prepare And Setup BTSSM
    [Arguments]  ${remote_ip}=${ENB_PC_IP}  ${jars_path}=/home/ute/CLITools/lib  ${port}=5900  ${btssm_location}=None
    ...          ${trs_address}=192.168.255.129
    Import Library  ute_btssm
    Install CLI Tools
    Setup Btssm  host_ip=${remote_ip}  jars_path=${jars_path}  ssh_port=${port}  install_location=${btssm_location}
    ...          ne=${trs_address}  alias=Parameter_change
    Kill Sitemanager  alias=Parameter_change

Install CLI Tools
    SSHLibrary.Open Connection  ${ENB_PC_IP}  port=5900
    Login  ute  ute
    Execute Command  unzip -o /media/Burak/\[2\]\\ GloVer/Tools/Tools_linux_64bit.zip -d /home/ute/CLITools
    Execute Command  chmod 777 /home/ute/CLITools/jre/bin/java
    [Teardown]  Close Connection

Prepare Queries For Recommissioning
    [Documentation]
    ...    Replacing default values in NA plan template and imports it to NA
    ...    Added additional replacement of %LNCEL% if it existing in template - przemyslaw.romanczyk@nokia.com 26.08.17
    ...    author: marcin.sokolowski@nokia.com
    ...    Added Replacing Paths In Xml <- source: XML_replacer.py
    ...    Author: krystian.gordziejewski@nokia.com
    [Arguments]         ${directory}   #${Cell}=1   &{kwargs}
    Log To Console     \n Preparing and importing plans from ${directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${directory}      absolute=True
    @{files}  OperatingSystem.List Files In Directory  ${RESULTS}
    remove values from list  ${files}  output.xml
    ${scf_file}  get matches  ${files}  *.xml
    ${i}            Set Variable    ${0}
    FOR    ${file}   IN    @{test_data_files_content}
        ${i}  evaluate  ${i} + 1
        Log To Console  ${file} -> query_${i}
        ${query}  ${backup_query}  Prepare Query For Commissioning  ${RESULTS}/${scf_file[0]}  ${file}
        Append To List  ${queries}  ${query}
        Append To List  ${backup_queries}  ${backup_query}
    END

Recommission All Backups
    [Arguments]  ${backup_queries}
    Reverse List  ${backup_queries}
    FOR  ${query}  IN  @{backup_queries}
        Perform Parameter Commissioning  ${query}
    END

Recommission All Delta Backups
    [Arguments]  ${backup_deltas}  ${alias}=default
    Reverse List  ${backup_deltas}
    FOR  ${delta}  IN  @{backup_deltas}
        Perform Delta Recommissioning  ${delta}  alias=${alias}
    END

Check Faults On ENB
    [Arguments]  ${allowed_faults}=${ALLOWED_FAULTS}  ${expected_faults}=&{EMPTY}
    @{enb_alarms}     Get Active Alarms
    ${faults_list}  create list
    ${faults_ids}  create list
    ${faults_to_delete}  create list
    FOR  ${enb_alarm}  IN  @{enb_alarms}
        ${fault_id}  Get From Dictionary  ${enb_alarm}  faultId
        Append To list  ${faults_ids}  ${fault_id}
    END
    ${faults_list}    Copy list    ${faults_ids}
    Set suite variable    ${faults_list}

    FOR  ${expected_fault}  IN  @{expected_faults}
        ${fault}  convert to integer  ${expected_fault}
        List Should Contain Value  ${faults_ids}  ${fault}
        Append To List  ${faults_to_delete}  ${fault}
    END

    FOR  ${fault}  IN  @{allowed_faults}
        ${fault}  Convert To Integer  ${fault}
        append To List  ${faults_to_delete}  ${fault}
    END

    Remove Values From List  ${faults_ids}  @{faults_to_delete}
    should be empty  ${faults_ids}  msg='Not allowed faults: ${faults_ids}'

Get File To Container
    [Arguments]  ${remote_machine}=${ENB_PC_IP}  ${port}=5900  ${user}=ute  ${password}=ute  ${source}=/tmp/backup_scf.xml
    ...    ${destination}=${RESULTS}/backup_scf.xml
    Open Connection  ${remote_machine}  port=${port}
    Login  ${user}  ${password}
    Get File  ${source}  ${destination}


Plan Jsonizator
    [Documentation]
    ...    Replacing default values in NA plan template and imports it to NA
    ...    Added additional replacement of %LNCEL% if it existing in template - przemyslaw.romanczyk@nokia.com 26.08.17
    ...    author: marcin.sokolowski@nokia.com
    ...    Added Replacing Paths In Xml <- source: XML_replacer.py
    ...    Author: krystian.gordziejewski@nokia.com
    [Arguments]         ${directory}   ${validate}=${True}  &{kwargs}
    Log To Console     \n Preparing and importing plans from ${directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${directory}      absolute=True
    @{files}  OperatingSystem.List Files In Directory  ${RESULTS}
    remove values from list  ${files}  output.xml
    ${scf_file}  get matches  ${files}  *.xml
    ${i}            Set Variable    ${0}
    ${create_paths}  get paths from create objects  ${test_data_files_content}  %PLMN%=${PLMN}  %ENB_ID%=${ENB_ID}
    ...    %ENB_RELEASE%=${ENB_RELEASE}  &{kwargs}
    OperatingSystem.Create Directory  ${RESULTS}/plans
    FOR    ${xml_file}   IN    @{test_data_files_content}
        ${i}  evaluate  ${i} + 1
        Log To Console  ${xml_file} -> delta_plan_${i}.json
        ${create_paths}  Jsonizator   ${RESULTS}/${scf_file[0]}  ${xml_file}  ${RESULTS}/plans/delta_plan_${i}   ${create_paths}
      ...    validate=${validate}  %PLMN%=${PLMN}  %ENB_ID%=${ENB_ID}  %ENB_RELEASE%=${ENB_RELEASE}  file_nr=${i}  &{kwargs}
    END


Compare Expected Value To Actual Value
    [Arguments]  ${object_name}  ${object_id}  ${parameter}  ${expected_value}  ${object_id_2}=${EMPTY}
    ${parameter_value}  Get Parameter From Infomodel  //BTS_L-${ENB_SIDE}/${object_id_2}/${object_name}_A-${object_id}  ${parameter}
    Should Be Equal As Strings  ${parameter_value}  ${expected_value}

Compare All Expected Values With Actual Values
    [Documentation]
    ...    Keyword finds all parameters expected to be updated via selected plan and compares them with corresponding values on eNB.
    ...    Author: artur.lebek@nokia.com
    [Arguments]  ${plans_directory}=${PLANS_DIR}  ${plan_id}=1
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${plans_directory}      absolute=True
    ${file_id}    Evaluate    ${plan_id} - ${1}
    ${xml}  Parse XML  @{test_data_files_content}[${file_id}]
    @{objects}   Get Elements    ${xml}    cmData/managedObject

    FOR    ${object}   IN    @{objects}
        @{parameters}  Get Elements    ${object}    p
        ${object_name}    Set variable    ${object.attrib['class']}
        ${rest}    ${id}    Split String From Right    ${object.attrib['distName']}    separator=-    max_split=1
        ${object_id}    Set variable if    '${object_name}'=='LNBTS'    ${ENB_ID}
         ...                                '${object_name}'!='LNBTS'    ${id}
        ${object_id}    Run keyword if    '${object_name}'=='LNBTS'    Set variable    ${ENB_ID}
         ...             ELSE               Set variable    ${id}
        Compare All Expected Values With Actual Values (Parameters Loop)  ${parameters}  ${object_name}  ${object_id}
    END

Compare All Expected Values With Actual Values (Parameters Loop)
    [Documentation]
    ...    Supporting keyword for "Compare All Expected Values With Actual Values" compares parameters values for selected object.
    ...    Author: artur.lebek@nokia.com
    [Arguments]  ${parameters}  ${object_name}  ${object_id}
    FOR    ${parameter}   IN    @{parameters}
        ${parameter_name}    Set variable    ${parameter.attrib['name']}
        ${expected_value}    Set variable    ${parameter.text}
        ${parameter_value}    Get Parameter From Infomodel    //BTS_L-${ENB_SIDE}//${object_name}_A-${object_id}    ${parameter_name}
        Should Be Equal As Strings    ${parameter_value}    ${expected_value}    ignore_case=True
    END

Random choice
            [Documentation]
            ...    Returning random rmod path or lncell path depending of arguments and existing of variables in configuration file
            ...    Author: jakub.bielawski@nokia.com
            [Arguments]    ${TO_BLOCK}  ${mod}  # LNCEL or RMOD
            ${value_1}=  Run keyword if  '${mod}'=='LNCEL'  Random choice dla  ${TO_BLOCK}  ${mod}
            ...          ELSE    Random choice dla  ${TO_BLOCK}  ${mod}
            [Return]    ${value_1}
Random choice dla
            [Documentation]
            ...    Checking if list of objects are configured for enb
            ...    Author: jakub.bielawski@nokia.com
            [Arguments]    ${TO_BLOCK}  ${mod}
            ${value_2}=  Run keyword and return status  Should Not Be Empty  ${TO_BLOCK}
            ${value_1}=  Run keyword if  '${value_2}'=='True'    Random choice from list  ${TO_BLOCK}  ${mod}
            ...          ELSE    Keyword losujacy sam  ${mod}
            [Return]    ${value_1}

Random choice from list
            [Documentation]
            ...    Returning random path of object from list configured for enb
            ...    Author: jakub.bielawski@nokia.com
            [Arguments]  ${TO_BLOCK}  ${mod}
            ${value_1}=  Evaluate  random.choice(${TO_BLOCK})  random
            ${listaa}=  Keyword making list  ${mod}
            ${value_2}=  Evaluate  random.choice(${listaa})  random
            ${element}  Fetch From left  ${value_2}  ${mod}_R
            ${element}=    Set variable  ${element}${mod}_R-${value_1}
            Log To Console  \n Unit to block path: ${element}
            [Return]    ${element}

Keyword losujacy sam
            [Documentation]
            ...    Returning random path of object from list from object in ENB
            ...    Author: jakub.bielawski@nokia.com
            [Arguments]  ${mod}
            Log To Console  \n No configured list in config - choose random ${mod}
            ${listaa}=  Keyword making list  ${mod}
            ${value_1}=  Evaluate  random.choice(${listaa})  random
            ${element}  Fetch From Right  ${value_1}  ${mod}_R-
#            Log To Console  \n Unit to block path: ${value_1}
            [Return]    ${value_1}
Keyword making list
            [Documentation]
            ...    Keyword ading to list only real object i.e. without IOT
            ...    Author: jakub.bielawski@nokia.com
            [Arguments]  ${mod}
              @{all_cells}=  get ids for all  ${mod}
            FOR   ${cell}    IN   @{all_cells}
                ${status}=      Evaluate    "${mod}_R" in """${cell}"""
                Run Keyword if     ${status}       append to list  ${listaa}  ${cell}
            END
            [Return]    ${listaa}
Set dates
    [Arguments]    ${duration_time}=30    ${interval}=15    ${time_increment}=-15
    #Correct format of date
    Set Suite Variable    ${pm_date_user_format}    %d.%m.%Y %H:%M                #Date format for eNB and OMS
    Set Suite Variable    ${user_date}              %Y.%m.%d %H:%M                #Date format for NetAct
    #Check time and wait 4 minutes if PMs could not reach NetAct
    ${min}=    Get Time    min
    ${minutes}=    Convert To Integer    ${min}
    Run keyword if    59<=${minutes}<60 or 0<=${minutes}<3 or 14<${minutes}<18 or 29<${minutes}<33 or 44<${minutes}<48    Sleep    4 minutes
    #Set current date
    ${actual_time}=    Get Current Date    exclude_millis=True    increment=${time_increment} minutes
    Set Suite Variable    ${end_time}    ${actual_time}
    ${actual_time}=    Subtract Time From Date    ${end_time}    ${duration_time} minutes    exclude_millis=True
    Set Suite Variable    ${start_time}    ${actual_time}
    ${number_of_samples}=    Evaluate    ${duration_time}/${interval}
    Set Suite Variable    ${number_of_samples}
    #Set correct date format for eNB and OMS
    ${start_time_format}=    Convert Date    ${start_time}    ${pm_date_user_format}
    Set Suite Variable    ${start_time_format}
    ${end_time_format}=    Convert Date    ${end_time}    ${pm_date_user_format}
    Set Suite Variable    ${end_time_format}
    #Set correct date format for NetAct
    ${start_time_format_na}=    Convert Date    ${start_time}    ${user_date}
    Set Suite Variable    ${start_time_format_na}
    ${end_time_format_na}=    Convert Date    ${end_time}    ${user_date}
    Set Suite Variable    ${end_time_format_na}

Get counters from eNB and NetAct and compare
    [Arguments]  ${PM_LIST}  ${CURDIR1}  ${time_shift}=0  ${get_counters}=Get Counters from Cell Level
    ${text_file}=    OperatingSystem.Get file    ${CURDIR1}/test_data_files/${PM_LIST}
    ${counters_group_list}=    Split String    ${text_file}    ;
    ${eNB_pm_list}=    Get and parse xml file from eNB  ${start_time_format}    ${end_time_format}
    FOR  ${counters_group}    IN    @{counters_group_list}
        ${name_of_group}    ${counters}=    OperatingSystem.Split_Extension    ${counters_group}
        ${stripped_name}=    Strip String    ${name_of_group}    characters=\n
        ${counters_list}=    Split String    ${counters}
        ${local_moid_part1}=    Set Variable    //*[*/DN/text()="PLMN-PLMN/MRBTS-${ENB_ID}/LNBTS-${ENB_ID}
        ${local_moid_part2}=    Set Variable    "]/*[@measurementType="${stripped_name}"]
        ${NetAct_local_moid_part1}=    Set Variable    DN:NE-LNBTS-${ENB_ID}/LNCEL-
        ${NetAct_local_moid_part2}=    Set Variable    /MCC-555/MNC-10
        Run keyword if    '${get_counters}'=='Get Counters from Cell Level'    Get Counters from Cell Level
       ...    ${eNB_pm_list}    ${cells_id_list}    ${counters_list}    ${number_of_samples}
       ...    ${local_moid_part1}    ${local_moid_part2}    ${NetAct_local_moid_part1}   ${NetAct_local_moid_part2}  ${time_shift}
       ...    ELSE IF    '${get_counters}'=='Get Counters LTE4793'    Get Counters LTE4793
       ...    ${eNB_pm_list}    ${cells_id_list}    ${counters_list}    ${number_of_samples}
       ...    ${local_moid_part1}    ${local_moid_part2}    ${NetAct_local_moid_part1}   ${NetAct_local_moid_part2}
    END

Get counters from eNB and NetAct and compare_PMQAP
    [Arguments]  ${PM_LIST}  ${CURDIR1}  ${time_shift}=45
    ${PMQAP_id_list}=    Create List Of PMQAP
    ${text_file}=    OperatingSystem.Get file    ${CURDIR1}/test_data_files/${PM_LIST}
    ${counters_group_list}=    Split String    ${text_file}    ;
    ${eNB_pm_list}=    Get and parse xml file from eNB    ${start_time_format}    ${end_time_format}
    FOR  ${counters_group}    IN    @{counters_group_list}
        ${name_of_group}    ${counters}=    OperatingSystem.Split_Extension    ${counters_group}
        ${stripped_name}=    Strip String    ${name_of_group}    characters=\n
        ${counters_list}=    Split String    ${counters}
        ${local_moid_part1}=    Set Variable    //*[*/DN/text()="PLMN-PLMN/MRBTS-${ENB_ID}/LNBTS-${ENB_ID}
        ${local_moid_part2}=    Set Variable    [*/DN/text()="PLMN-PLMN/MCC-555/MNC-10"][*/DN/text()="PLMN-PLMN
        ${local_moid_part3}=    Set Variable    "]/*[@measurementType="${stripped_name}"]
        ${NetAct_local_moid_part1}=    Set Variable    DN:NE-LNBTS-${ENB_ID}/LNCEL-
        ${NetAct_local_moid_part2}=    Set Variable    /MCC-555/MNC-10/PMQAP-
        ${dictenb}    ${dictoms}    ${dictNA}=    Get Counters from Cell Level for PMQAP Profiles
       ...    ${eNB_pm_list}    ${cells_id_list}    ${PMQAP_id_list}    ${counters_list}
       ...    ${local_moid_part1}    ${local_moid_part2}    ${local_moid_part3}    ${NetAct_local_moid_part1}
       ...    ${NetAct_local_moid_part2}    ${number_of_samples}    ${time_shift}
    END


Set timeShift according to timeZone
    [Documentation]  Check timezone on ENB and set timeshift for netact
    [Arguments]  ${unit}=min  ${increment}=15
    ${multiplier}  Set variable  1
    Set variable if  '${unit}'=='min'  ${multiplier}  60
    &{time_zon1}    Get Infomodel Object  /MRBTS-*/RAT-*//MNLENT_A-*/SYNC_A-*/TIME_A-*
    ${time_zon2}    Get From Dictionary  ${time_zon1}  timeZone
    ${time_zon3}=    Fetch From Right  ${time_zon2}  (GMT+
    ${time_zon4}=    Fetch From Left  ${time_zon3}  )
    ${time_zon}=    Evaluate  (${time_zon4}*60)-${increment}
    ${time_shift}=  Set variable  ${time_zon}
    [Return]    ${time_shift}

Check if MME distName have real value
    [Documentation]  temp keyword for pronto #Bielawski
    &{abc}=   Get Infomodel Object    /MRBTS-1/RAT-1/RUNTIME_VIEW-${ENB_SIDE}//LNMME_R-0/CONF_REF-1
    ${mme_distname}  Get From Dictionary  ${abc}  distName
    &{abc}=   Get Infomodel Object    ${mme_distname}

Check ENB
    [Arguments]     ${type}=admin  ${expected_faults}=&{EMPTY}
    Wait Until keyword Succeeds    6x    10sec    Check If Cells OnAir Or PowerSaving Enabled  # ${alias}
    Check If Reset Counter Did Not Change
    Wait Until keyword Succeeds    5x    30sec    Check Faults On ENB  ${ALLOWED_FAULTS}   ${expected_faults}
    Run keyword if    '${type}'=='netact'    Check If Alarms From ENB and NetAct Are The Same

Check ENB after reset
    [Arguments]     ${type}=admin  ${expected_faults}=&{EMPTY}
    Wait Until Keyword Succeeds  6x  1min  Check If Reset Counter Incremented
    Wait Until Keyword Succeeds  6x  1min  Check If Cells OnAir Or PowerSaving Enabled
    Wait Until keyword Succeeds    5x    30sec    Check Faults On ENB  ${ALLOWED_FAULTS}   ${expected_faults}
    Run keyword if    '${type}'=='netact'    Check If Alarms From ENB and NetAct Are The Same

Select cell
    [Arguments]  ${cells_list}=${CELL_TO_BLOCK}
    ${cell_id}   Evaluate  random.choice(${cells_list})  random
    Log   \nSelected cell is LNCEL-${cell_id}   WARN   console=True
    [Return]  ${cell_id}

Check message in syslog
    [Documentation]   author: artur.lebek@nokia.com   #NEW KEYWORD
    [Arguments]    ${message}  ${should_exist}=false  ${time}=5  ${vm_ip}=${ENB_PC_IP}  ${vm_port}=5900  ${vm_login}=ute  ${vm_pass}=ute
    SSHLibrary.Open connection  ${vm_ip}  port= ${vm_port}
    ${login_status}  ${error}  Run keyword and ignore error  SSHLibrary.Login  ${vm_login}  ${vm_pass}  delay=10
    Run keyword if    '${login_status}'=='FAIL'    Log  ${error}  WARN  console=True
    ${message_found}    SSHLibrary.Execute command   find /home/ute/syslog/MRBTS-${ENB_ID} -type f -cmin -${time} -exec grep \"${message}\" {} \\;
    @{lines}  Split to lines  ${message_found}
    SSHLibrary.Close connection
    Run keyword if   '${should_exist}'=='true'   Should not be empty  ${lines}    ELSE    Should be empty  ${lines}
    [Return]  ${lines}

Check crashes
    [Documentation]   author: artur.lebek@nokia.com
    [Arguments]    ${time}=5  ${vm_ip}=${ENB_PC_IP}  ${vm_port}=5900  ${vm_login}=ute  ${vm_pass}=ute
    SSHLibrary.Open connection  ${vm_ip}  port= ${vm_port}
    ${login_status}  ${error}  Run keyword and ignore error  SSHLibrary.Login  ${vm_login}  ${vm_pass}  delay=10
    ${status}  ${component}    Run keyword if    '${login_status}'=='PASS'  Check in syslog
    ...    Please contact the owner\\|\\-\\=\\-\\=\\|Invalid memory reference\\|Bus error|ErrorFatality    ${time}
    ...               ELSE     Log  ${error}  WARN  console=True
    SSHLibrary.Close connection
    [Return]  ${component}

Check Sleeping Cell   #TEMP TEST
    [Documentation]   author: artur.lebek@nokia.com
    [Arguments]    ${time}=5  ${vm_ip}=${ENB_PC_IP}  ${vm_port}=5900  ${vm_login}=ute  ${vm_pass}=ute
    SSHLibrary.Open connection  ${vm_ip}  port= ${vm_port}
    ${login_status}  ${error}  Run keyword and ignore error  SSHLibrary.Login  ${vm_login}  ${vm_pass}  delay=10
    ${status}  ${component}    Run keyword if    '${login_status}'=='PASS'  Check in syslog    RTWP\\[dBm\\] per antenna\\: \\-140  ${time}
    ...               ELSE     Log  ${error}  WARN  console=True
    SSHLibrary.Close connection
    [Return]  ${component}

Check in syslog
    [Documentation]   author: artur.lebek@nokia.com
    [Arguments]   ${message}=ERR/  ${time}=5  #in minutes
    Log    \nLogged to vm to check syslog   console=True
    ${diagnostic_print}=    SSHLibrary.Execute command
    ...    find /home/ute/syslog/MRBTS-${ENB_ID} -type f -cmin -${time} -exec grep \"${message}\" {} \\;
    @{lines}  Split to lines  ${diagnostic_print}
    FOR  ${line}  IN  @{lines}
        ${component}=  Fetch From Right    ${line}    of
        Log  Check diagnostic files for: ${component}  ERROR  console=True
    END
    [Return]  ${component}

Set Test Start Time
    [Documentation]   author: artur.lebek@nokia.com
    ${test_start_time}    Get Time    epoch
    Set suite variable    ${test_start_time}

Get Test Duration Time
    [Documentation]   author: artur.lebek@nokia.com
    [Arguments]  ${unit}=s
    ${test_end_time}    Get Time    epoch
    ${test_duration}    Evaluate     ${test_end_time}-${test_start_time}
    ${test_duration_min}    Evaluate    ${test_duration}/60.0
    Run Keyword If    '${unit}'!='min'    Log    ${test_duration_min} min (${test_duration} s)  WARN    console=true
    ${test_duration}    Set variable if    '${unit}'=='min'    ${test_duration_min}    ${test_duration}
    Set suite variable    ${test_duration}
    Set suite variable    ${test_duration_min}

##################################SETUP&TEARDOWN###################################
Test Suite Setup
    [Arguments]  ${infomodel_alias}=default  ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Show Current SBTS Configuration  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Setup TA NetAct    was_host=${NA_WAS}    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}
    ...    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Setup Netact Cm Operations
    Setup Ta Netact Monitor Fm
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Setup Without Netact
    [Arguments]  ${infomodel_alias}=default   ${ute_admin_alias}=default  #${admin_api_log}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Show Software Version    alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}  #admin_api_log_dir=${admin_api_log}
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Teardown If Fail
    [Arguments]  ${backup_list}  ${ute_admin_alias}=default
    Run Keyword And Continue On Failure  ute_admin.Collect Snapshot    target_file_name=${RESULTS}/snapshot/snapshot.zip
    ...    timeout=900  alias=${ute_admin_alias}
    ${status}  ${value}  Run keyword and ignore error  Recommission All Delta Backups    ${backup_list}    alias=${ute_admin_alias}
    Run keyword if    '${status}'=='FAIL'   Provision All Backups    list=${backup_list}
    #Edit: Teardown for NA TCs - artur.lebek 27-11-2019

Test Suite Teardown
    [Arguments]  ${infomodel_alias}=default   ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}
    Teardown Admin  alias=${ute_admin_alias}
    Teardown Ta Netact Monitor Fm
    Teardown Netact Cm Operations
    Teardown Ta Netact
    Get Test Duration Time
    Run keyword and ignore error    Check crashes    ${test_duration_min}

Test Suite Teardown Without Netact
    [Arguments]  ${infomodel_alias}=default   ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}

    Teardown Admin  alias=${ute_admin_alias}
    Get Test Duration Time
    Run keyword and ignore error    Check crashes    ${test_duration_min}

Test Suite Setup PM
    [Arguments]  ${infomodel_alias}=default   ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Show Current SBTS Configuration PM  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Setup TA NetAct    was_host=${NA_WAS}    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}
    ...    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Setup Ta Netact Pm    db_host=${NA_DB}    port=1521   alias=ta_netact_pm
    Setup Ta Netact Monitor Fm  alias=ta_netact
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Teardown PM
    [Arguments]  ${infomodel_alias}=default    ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}
    Teardown Admin  alias=${ute_admin_alias}
    Teardown Ta Netact Monitor Fm  alias=ta_netact
    Teardown Ta Netact
    #Teardown Ta Enb PM
    Teardown Ta Netact Pm  alias=ta_netact_pm
    Get Test Duration Time
    Run keyword and ignore error    Check crashes    ${test_duration_min}

##################################SETUP&TEARDOWNbyDP###################################
Test Suite Setup PM by DP
    [Arguments]  ${infomodel_alias}=default    ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Show Current SBTS Configuration PM  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Setup TA NetAct    was_host=${NA_WAS}    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}
    ...    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Setup Ta Netact Pm    db_host=${NA_DB}    port=1521   alias=ta_netact_pm
    Setup Ta Netact Monitor Fm  alias=ta_netact
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Teardown PM by DP
    [Arguments]  ${infomodel_alias}=default   ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}
    Teardown Admin  alias=${ute_admin_alias}
    Teardown Ta Netact
    Get Test Duration Time
    Run keyword and ignore error    Check crashes    ${test_duration_min}