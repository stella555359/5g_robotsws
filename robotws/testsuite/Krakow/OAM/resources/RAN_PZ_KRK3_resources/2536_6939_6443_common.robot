*** Settings ***
Documentation    CM FM PM KPI testing resources for 5GC002536/CB006939/CB006443
...              author:    Lukasz Rzodeczko
...              maintainer:    Lukasz Rzodeczko    lukasz.rzodeczko@nokia.com
...                             Marek Bodziony      marek.bodziony@nokia.com

Library     Collections
Library     DateTime
Library     testsuite.Krakow.OAM.resources.RAN_PZ_KRK3_resources.PM.pm.DU       WITH NAME      pmDU
Library     testsuite.Krakow.OAM.resources.RAN_PZ_KRK3_resources.PM.pm.CU       WITH NAME      pmCU
Library     taf.transport.ssh               WITH NAME   ssh
Library     taf.selenium.gnb.oam.coam.cu    WITH NAME   cu
Library     taf.gnb.oam.coam.cu             WITH NAME   cu_admin
Library     taf.sbts.oam.coam.admin         WITH NAME   du_admin
Library     ./CUCommonInterface.py
Library     ./DUCommonInterface.py
Library     testsuite/Krakow/OAM/resources/RAN_PZ_KRK3_resources/XTower/xtower_helper.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot

*** Variables ***
${CU_ID}=              ${tl.gnbs[0].instance_id}
${GNB_ID}=             1${tl.gnbs[0].global_bts_id}
${NRBTS_ID}=            ${tl.gnbs[0].global_bts_id}
${PM_counters_DU_dir}=      /ffs/run/uri/PERFMON_FILES/
${disable_PMs}=         disable_PM-cloud_DU.json
${enable_PMs}=          enable_PM-cloud_DU.json
${min_expected_number_of_PM_files_21B}=     59
${min_expected_number_of_PM_conters_21B}=   2632
${min_expected_number_of_PM_files}=     60
${min_expected_number_of_PM_conters}=   2771
${PM_measurement_dir}=          /mnt/services/PM9/storage/results
${PM_file_creation_status}      NO_RUN
${WEBUI_ADDRESS_CU}=    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBEM_USERNAME}=      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}=      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${CU_SSH_PASS}=         ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${CU_SSH_LOGIN}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${NUMB_OF_ALARMS}=      9500
${CU_PEAK_ALARM_RATE}=  500
${PLAN_DESCRIPTION}=    The Lord once stood by the shore ${GNB_ID} 2137
${path_to_scfs}         /home/ute/scf
${url_path_to_scfc}     http://10.83.200.250/sctest/Temp_trash/gabrys/Comissions
${x_tower_vm_name}      ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.addr}
${x_tower_username}     ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.username}
${x_tower_password}     ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.password}
${nom_plan_username}    ${tl.nms.nom.ssh_connections_info[0].username}
${nom_plan_password}    ${tl.nms.nom.ssh_connections_info[0].password}

*** Keywords ***
Check PM data compression factor and total number of PM counters
    ${PM_measurement_temp_dir}=     pmDU.Create TEMP_DIR for PM verification
    pmDU.Get latest PM measurement file from DU     path=${PM_counters_DU_dir}   temp_dir=${PM_measurement_temp_dir}
    ${PM_compressed_size}=          pmDU.Get compressed PM measurement size    temp_dir=${PM_measurement_temp_dir}
    pmDU.Uncompress PM measurement files    temp_dir=${PM_measurement_temp_dir}
    ${PM_uncompressed_size}=      pmDU.Get uncompressed PM measurement size    temp_dir=${PM_measurement_temp_dir}
    pmDU.Check compression factor    pm_uncompressed_size=${PM_uncompressed_size}  pm_compressed_size=${PM_compressed_size}

    Check PM counters on DU

    [Teardown]      pmDU.Remove TEMP_DIR  temp_dir=${PM_measurement_temp_dir}

Check duration of PM data file creation time DU
    pmDU.Check duration of PM data creation time     path=${PM_counters_DU_dir}

${PM_requested_state:Enable|Disable} all PM measurements on DU
    Run keyword if  '${PM_requested_state}' == 'Enable'
    ...     Load and activate delta_plan    plan_name=${enable_PMs}
    ...     ELSE
    ...     Load and activate delta_plan    plan_name=${disable_PMs}
    Wait Until Keyword Succeeds     900s    20s     Verify Setup Of All Cells

Load and activate delta_plan
    [Arguments]     ${plan_name}
    ${delta}=   pmDU.prepare_delta_plan_for_testline
    ...             delta_plan=${plan_name}
    ...             mrbts_id=${GNB_ID}
    ...             nrbts_id=${NRBTS_ID}
    Perform Delta Commissioning On gNB
    ...     delta=${delta}
    ...     skip_parameter_relation_errors=${False}
    ...     should_activate=${True}

Make sure that PM measurements are collected in ${pm_interval:5min|15min|30min|60min} interval
    Perform Configuration Parameter Recommissioning On gNB
    ...     dist_name=MRBTS-${GNB_ID}/MNL-1/MNLENT-1/PMCADM-1
    ...     param_name=reportingIntervalPm
    ...     operation=update
    ...     param_value=${pm_interval}
    ...     skip_parameter_relation_errors=${False}
    ...     should_activate=${True}

Check PM data compression factor and total number of PM measurement and PM counters
    ${PM_measurement_temp_dir}=     pmCU.Create TEMP_DIR for PM verification

    pmCU.Get latest PM measurement files from CU     path=${PM_measurement_dir}    temp_dir=${PM_measurement_temp_dir}
    ${PM_compressed_size}=          pmCU.Get compressed PM measurement size    temp_dir=${PM_measurement_temp_dir}
    pmCU.Uncompress PM measurement files    temp_dir=${PM_measurement_temp_dir}
    ${PM_uncompressed_size}=      pmCU.Get uncompressed PM measurement size    temp_dir=${PM_measurement_temp_dir}
    pmCU.Check compression factor    pm_uncompressed_size=${PM_uncompressed_size}  pm_compressed_size=${PM_compressed_size}

    pmCU.Check total number of PM measurement files
    ...     temp_dir=${PM_measurement_temp_dir}
    ...     expected=${min_expected_number_of_PM_files}

    pmCU.Check total number of PM counters
    ...     temp_dir=${PM_measurement_temp_dir}
    ...     expected=${min_expected_number_of_PM_conters}

    [Teardown]  pmCU.Remove TEMP_DIR  temp_dir=${PM_measurement_temp_dir}

Check duration of PM data file creation time CU
    pmCU.Check duration of PM data creation time     path=${PM_measurement_dir}

Verify gNB-DU PM file size with compression factor and number of PM counters
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        pmDU.Wait for next PM measurement
        Check PM data compression factor and total number of PM counters
        Check duration of PM data file creation time DU
    END
    Set global variable            ${PM_file_creation_status}       PASS

Verify gNB-CU PM file size with compression factor and number of PM measurement and PM counters
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        pmCU.Wait for next PM measurement
        Check PM data compression factor and total number of PM measurement and PM counters
        Check duration of PM data file creation time CU
    END
    Set global variable            ${PM_file_creation_status}       PASS

Verify gNB-DU duration of PM data file creation time
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    Run keyword IF  "${PM_file_creation_status}" != "PASS"
    ...             Check duration of PM data file creation time on gNB-DU      num_of_tries=${num_of_tries}

Verify gNB-CU duration of PM data file creation time
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    Run keyword IF  "${PM_file_creation_status}" != "PASS"
    ...             Check duration of PM data file creation time on gNB-CU      num_of_tries=${num_of_tries}

Verify gNB-DU CPU load impact with PM enabled
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Disable all PM measurements on DU
        ${CPU_load_PMs_disabled}=   pmDU.Get CPU load
        Enable all PM measurements on DU
        ${CPU_load_PMs_enabled}=    pmDU.Get CPU load
        pmDU.Verify CPU load     with_pm_enabled=${CPU_load_PMs_enabled}     with_pm_disabled=${CPU_load_PMs_disabled}
    END

Check duration of PM data file creation time on gNB-DU
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        pmDU.Wait for next PM measurement
        Check duration of PM data file creation time DU
    END

Check duration of PM data file creation time on gNB-CU
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        pmCU.Wait for next PM measurement
        Check duration of PM data file creation time CU
    END

Verify gNB-DU Capacity for Active Alarms
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    du_admin.change_rnd_port_security    True
    du_admin.enable_ssh_access
    du_admin.disable_ethernet_port_security
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Verify Setup Of All Cells
        ${alarms_before_test}=    du_admin.get_active_alarms_number
        ${path_to_delta}   Prepare Delta To Create 95 RMODs
        ${output}    du_admin.perform_delta_recommissioning    ${path_to_delta}
        Remove File    ${path_to_delta}
        Wait until Keyword Succeeds     25 min   30 sec    Check if 'No connection to unit' appeared 95 times
        ${total_alarm_number}     Evaluate    95+${alarms_before_test}
        ${alarm_number}    du_admin.get_active_alarms_number
        Should Be True  ${alarm_number} == ${total_alarm_number}
        ${path_to_delta}=   Prepare Delta To Delete 95 RMODs
        ${clear_alarms_start} =    Get Current Date    result_format=%Y%m%d%H%M%S
        Append To List    ${CLEAR_ALARMS_DICT}[Start]    ${clear_alarms_start}
        ${output}=    du_admin.perform_delta_recommissioning    ${path_to_delta}
        Wait until Keyword Succeeds     20 sec   5 sec    Check if 'No connection to unit' appeared 0 times
        ${clear_alarms_end} =    Get Current Date    result_format=%Y%m%d%H%M%S
        Append To List    ${CLEAR_ALARMS_DICT}[End]    ${clear_alarms_end}
        Verify Setup Of All Cells
    END
    [Teardown]    Run Keywords    Remove File    ${path_to_delta}
    ...   AND     Teardown DU admin connection

Verify gNB-DU Peak Alarm rate
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        ${end_to_end}=    Check if operation time is within the limit
        ...       ${CLEAR_ALARMS_DICT}[Start][${attempt}]    ${CLEAR_ALARMS_DICT}[End][${attempt}]   60    ${end_to_end}
    END
    [Teardown]     Run Keywords    Save KPIs to file    DU_peak_alarm_time    ${end_to_end}
    ...   AND     Run Keyword if    '${pass_test}' == 'False'   Fail    At least one try is not within its time limit

Setup DU admin connection
    du_admin.setup_admin

Teardown DU admin connection
    du_admin.teardown_admin

Setup CU admin connection
    cu_admin.Connect To    ${WEBUI_ADDRESS_CU}  443   ${WEBEM_USERNAME}  ${WEBEM_PASSWORD}   secure=True    alias=CU

Teardown CU admin connection
    cu_admin.Disconnect    connection=CU

Setup CU ssh connection
    ssh.Connect To  ${WEBUI_ADDRESS_CU}  ${CU_SSH_LOGIN}  ${CU_SSH_PASS}

Teardown CU ssh connection
    ssh.Disconnect

Login to CU-WebEm
    ${webui_address}=      Set Variable      https://${WEBUI_ADDRESS_CU}/login
    cu.enable_virtual_display
    cu.Login                ${webui_address}    ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    version=${version}

Logout from CU-WebEm
    cu.Logout
    cu.disable_virtual_display

Set test variables
    Run Keywords    Set Test Variable    ${pass_test}    True
    ...    AND   Set list as test variable   end_to_end
    ...    AND   Set list as test variable   bts_target

Prepare Delta To ${operation:Delete|Create} ${numb_of_rmods} RMODs
    ${build}=    DUCommonInterface.Get Bts Sw Version
    ${branch}=    Fetch from left   ${build}     _
    ${path_to_json}=   Run Keyword if   '${branch}' == '5G21B'   Set variable    ${CURDIR}/add_rmod.json
    ...   ELSE    Set Variable    ${CURDIR}/add_rmod_trunk.json
    ${json}=     Run Keyword If  '${operation}' == 'Create'    Get File  ${path_to_json}
    ...   ELSE     Get File  ${CURDIR}/delete_rmod.json
    ${json}= 	Get Substring 	${json}    1    -2
    ${json}=    Replace String    ${json}    {distname}   MRBTS-${GNB_ID}/EQM-1/APEQM-1
    Create File    ${OUTPUT_DIR}/delta.json
    Append To File   ${OUTPUT_DIR}/delta.json    [
    ${numb_of_rmods}=    Evaluate    ${numb_of_rmods}+2
    FOR  ${rmod}  IN RANGE  2  ${numb_of_rmods}
        ${rmod_str}=       Convert To String    ${rmod}
        ${prepared_json}=  Replace String    ${json}    {id}    ${rmod_str}
        Append To File   ${OUTPUT_DIR}/delta.json    ${prepared_json}
        Run Keyword if     '${numb_of_rmods-1}' != '${rmod}'     Append To File   ${OUTPUT_DIR}/delta.json    ,
    END
    Append To File   ${OUTPUT_DIR}/delta.json    ]
    ${path_to_delta}=    Set Variable   ${OUTPUT_DIR}/delta.json
    [Return]     ${path_to_delta}

Check if operation time is within the limit
    [Arguments]   ${start}   ${end}    ${limit}    ${list}    ${convert_to_date}=${FALSE}    ${date_format}=%m/%d/%y %I:%M:%S %p
    ${start}= 	 Run Keyword If   '${convert_to_date}'=='True'   Convert Date 	${start}   date_format=${date_format}
    ...   ELSE   Set Variable    ${start}
    ${end}= 	 Run Keyword If   '${convert_to_date}'=='True'   Convert Date 	${end}   date_format=${date_format}
    ...   ELSE   Set Variable    ${end}
    ${whole_operation_time}=    Subtract Date From Date    ${end}    ${start}
    ${status}=     Evaluate   0 <= ${whole_operation_time} <= ${limit}
    Run Keyword if    '${status}' == 'False'    Run keywords
    ...                             Set Test Variable    ${pass_test}    ${status}
    ...             AND             Log	    Operation time over the limit (${whole_operation_time} > ${limit})	    WARN
    Append To List    ${list}    ${whole_operation_time}
    [Return]    ${list}

Set list as test variable
    [Arguments]   ${list_name}
    ${list}=   Create List
    Set Test Variable   ${${list_name}}   ${list}

Check if '${alarm}' Appeared ${number} Times
    ${active_alarms}=    du_admin.get_active_alarms
    ${number_of_alarms}=    Evaluate    ${number}*2
    Should Contain X Times    '${active_alarms}'   ${alarm}   ${number_of_alarms}

Save KPIs to file
    [Arguments]   ${file_name}   ${end_to_end}   ${bts_target}=${None}    ${path_to_file}=${OUTPUT_DIR}/kpis
    ${current_date}=    Get Current Date    result_format=%y.%m.%d_%H:%M
    ${end_to_end_avr}=    Get average from list   ${end_to_end}
    ${bts_target_avr}=    Run Keyword if   ${bts_target}!=${None}    Get average from list   ${bts_target}
    Run   mkdir ${path_to_file}
    Run   ${path_to_file}/${file_name}_${current_date}
    Run   echo 'end to end times: ${end_to_end} average ${end_to_end_avr}' >> ${path_to_file}/${file_name}_${current_date}
    Run Keyword If   ${bts_target}!=${None}
    ...   Run   echo 'bts target times: ${bts_target} average ${bts_target_avr}' >> ${path_to_file}/${file_name}_${current_date}

Get average from list
    [Arguments]    ${list}
    ${sum}=    Set Variable    0
    ${lenght}=   Get Length    ${list}
    FOR    ${item}    IN    @{list}
        ${sum}=   Evaluate    ${item}+${sum}
    END
    ${average}=    Evaluate   ${sum}/${lenght}
    [Return]    ${average}

Set Suite variables for DU
    ${ACTIVATION_DICT}= 	Create Dictionary
    Set Suite Variable    ${ACTIVATION_DICT}    ${ACTIVATION_DICT}
    ${offline_validation_start}=   Create List
    ${offline_validation_end}=   Create List
    ${OFFLINE_VALIDATION_DICT}=   Create Dictionary    Start   ${offline_validation_start}    End    ${offline_validation_end}
    Set Suite Variable    ${OFFLINE_VALIDATION_DICT}  ${OFFLINE_VALIDATION_DICT}
    ${clear_alarms_start_list}=   Create List
    ${clear_alarms_end_list}=   Create List
    ${CLEAR_ALARMS_DICT}=   Create Dictionary    Start   ${clear_alarms_start_list}    End    ${clear_alarms_end_list}
    Set Suite Variable    ${CLEAR_ALARMS_DICT}    ${CLEAR_ALARMS_DICT}

Set suite variables for CU
    ${release}    Fetch From Left    ${ENB_BUILD}    _
    ${version}    Set Variable If    "${release}"=="5G21B"    21B    "${release}"!="5G21B"    22R1
    Set Suite variable    ${version}    ${version}
    Run Keyword If    "${version}"=="21B"    Set number of minimum expected PMs for release 21B
    ${PREACTIVATION_DICT}= 	Create Dictionary
    Set Suite Variable    ${PREACTIVATION_DICT}    ${PREACTIVATION_DICT}

Verify gNB-CU Capacity for Active Alarms
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Setup CU admin connection
        gnbcu.verify_if_cells_are_enabled
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        Generate alarm 7114 ${NUMB_OF_ALARMS} times
        Sleep    5s
        ${active_alarms}=    cu_admin.Get Active Alarms    connection=CU
        ${total_nuber_of_alarms}    Evaluate    ${NUMB_OF_ALARMS}+${alarms_before_test}[total]
        Should Be True    ${active_alarms}[total] == ${total_nuber_of_alarms}
        Clear alarms and check if they are removed    ${NUMB_OF_ALARMS}    ${alarms_before_test}
        gnbcu.verify_if_cells_are_enabled
        Teardown CU admin connection
    END

Generate Alarm ${id} ${number_of_alarms} Times
    ${number_of_alarms}=    Evaluate    ${number_of_alarms}+1
    FOR  ${alarm}  IN RANGE  1  ${number_of_alarms}
        ${output}=   ssh.Execute
        ...   command=sudo /opt/nokia/bin/flexalarm -sp=${id} -mo=test_alarm_${alarm} -ap=test_alarm_ap -se=0 -iinfo="Robot" -raise
    END

Clear Generated Alarm ${id} ${number_of_alarms} Times
    ${number_of_alarms}=    Evaluate    ${number_of_alarms}+1
    FOR  ${alarm}  IN RANGE  1  ${number_of_alarms}
        ${output}=   ssh.Execute
        ...   command=sudo /opt/nokia/bin/flexalarm -sp=${id} -mo=test_alarm_${alarm} -ap=test_alarm_ap -se=0 -iinfo="Robot" -clear
    END

Clear alarms and check if they are removed
        [Arguments]  ${number_of_alarms}   ${alarms_before_test}    ${connection}=CU
        Clear generated alarm 7114 ${number_of_alarms} times
        Sleep  5s
        ${alarms_after_test}=    cu_admin.Get Active Alarms    connection=${connection}
        Should Be True    ${alarms_after_test} == ${alarms_before_test}

Verify gNB-CU Capacity for Alarm History
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Setup CU admin connection
        gnbcu.verify_if_cells_are_enabled
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        ${hist_alarms_before_test}=    cu_admin.Get Historical Alarms    connection=CU
        ${Date}=    Generate And Clear Fake Alarm 7114 8000 Times
        Sleep    5s
        ${hist_alarms}=    cu_admin.Get Historical Alarms    connection=CU
        Should Be True    ${hist_alarms}[total] >= 8000
        Append To List    ${numb_of_alarms}    ${hist_alarms}[total]
        ${alarms_after_test}=    cu_admin.Get Active Alarms    connection=CU
        Should Be True    ${alarms_after_test} == ${alarms_before_test}
        ${alarm_min}  Convert to integer   8000
        ${hist_alarms}=    cu_admin.Get Historical Alarms    items_per_page=${alarm_min}   filter_by_text=${Date}  connection=CU
        Should be true    ${hist_alarms}[total] == 8000
        gnbcu.verify_if_cells_are_enabled
        Teardown CU admin connection
    END

Generate And Clear Fake Alarm ${id} ${number_of_alarms} Times
    ${number_of_alarms}=    Evaluate    ${number_of_alarms}+1
    ${Date}=    Get Current Date    result_format=%Y%m%d%H%M%S
    FOR  ${alarm}  IN RANGE  1  ${number_of_alarms}
      ${output}=  ssh.Execute
      ...    command=sudo /opt/nokia/bin/flexalarm -sp=${id} -mo=HistAlarm${alarm}_${Date} -ap=test_alarm_ap -se=0 -iinfo="Robot" -raise
      ${output}=  ssh.Execute
      ...    command=sudo /opt/nokia/bin/flexalarm -sp=${id} -mo=HistAlarm${alarm}_${Date} -ap=test_alarm_ap -se=0 -iinfo="Robot" -clear
    END
    [Return]    ${Date}

Verify gNB-CU Peak Alarm rate
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        gnbcu.verify_if_cells_are_enabled
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        ${trigger_alarms_start} =    Get Current Date    result_format=%Y%m%d%H%M%S
        Generate alarm 7114 ${CU_PEAK_ALARM_RATE} times
        Sleep  1s
        ${active_alarms}=    cu_admin.Get Active Alarms    connection=CU
        ${trigger_alarms_end} =    Get Current Date    result_format=%Y%m%d%H%M%S
        ${total_nuber_of_alarms}    Evaluate    ${CU_PEAK_ALARM_RATE}+${alarms_before_test}[total]
        Should Be True    ${active_alarms}[total] == ${total_nuber_of_alarms}
        ${end_to_end}=    Check if operation time is within the limit
        ...       ${trigger_alarms_start}    ${trigger_alarms_end}   60    ${end_to_end}
        Clear alarms and check if they are removed    ${CU_PEAK_ALARM_RATE}    ${alarms_before_test}
        gnbcu.verify_if_cells_are_enabled
    END

Verify gNB-CU Duration of Alarm Event Reporting WebEm
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Setup CU admin connection
        gnbcu.verify_if_cells_are_enabled
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        ${trigger_alarms_start} =    Get Current Date    result_format=%Y%m%d%H%M%S
        Generate alarm 7114 1 times
        Sleep  1s
        ${active_alarms}=    cu_admin.Get Active Alarms    connection=CU
        ${trigger_alarms_end}=    Get Current Date    result_format=%Y%m%d%H%M%S
        ${active_alarms_str}=    Convert To String   ${active_alarms}
        Should Contain    ${active_alarms_str}    test_alarm_1
        ${total_nuber_of_alarms}    Evaluate    1+${alarms_before_test}[total]
        Should Be True    ${active_alarms}[total] == ${total_nuber_of_alarms}
        ${end_to_end}=    Check if operation time is within the limit
        ...       ${trigger_alarms_start}    ${trigger_alarms_end}   5    ${end_to_end}
        Clear alarms and check if they are removed    1    ${alarms_before_test}
        gnbcu.verify_if_cells_are_enabled
        Teardown CU admin connection
    END

Verify Duration of CM Activation Operation 1 DU Full plan WebEM service outage
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Verify Setup Of All Cells
        ${operation_begins}    ${close_click}=    load_current_scf_download_it_and_activate
        ${syslog_path}=    Uzip syslog and return its path
        ${activation_started}=    Search for message in syslog and return its date
        ...                       ${syslog_path}    [INF/SysAdapter/URI/EM]*PlanActivateIndScenario] start    1
        ${activation_finished}=    Search for message in syslog and return its date
        ...                       ${syslog_path}    [INF/SysAdapter/URI/EM]*PlanActivateIndScenario] stop    2
        Run    rm ${syslog_path}
        ${bts_target}=    Check if operation time is within the limit
        ...                    ${activation_started}[0]   ${activation_finished}[1]    575    ${bts_target}    True    %d.%m %H:%M:%S
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}    ${close_click}    600    ${end_to_end}
        Wait Until Keyword Succeeds    5 min   10 sec    Verify Setup Of All Cells
    END

Uzip syslog and return its path
    [Arguments]  ${syslog_zip_path}=/tmp/btslog2/syslog_files.tgz
    File Should Exist    ${syslog_zip_path}
    ${output}=    Run    tar xvf ${syslog_zip_path} -C ${OUTPUT_DIR}
    Run   rm ${syslog_zip_path}
    Should Contain 	${output} 	.LOG
    ${file_name}   Should Match Regexp    ${output}   SYS.*LOG
    ${path_to_syslog}  Set Variable    ${OUTPUT_DIR}/${file_name}
    [Return]    ${path_to_syslog}

Search for message in syslog and return its date
    [Arguments]    ${syslog_path}    ${message_regex}    ${number_of_messages}
    ${output} =   Grep File   ${syslog_path}    ${message_regex}
    ${date} =	Get Regexp Matches    ${output}    \\d{2}.\\d{2}\\s\\d{2}:\\d{2}:\\d{2}
    ${cnt}=    Get Length    ${date}
    Should Be Equal As Numbers  ${cnt}  ${number_of_messages}
    [Return]    ${date}

Verify Duration of CM Provision Operation 1 DU Full plan WebEM service outage
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Verify Setup Of All Cells
        ${validation_click}  ${validation_end}  ${operation_begins}  ${close_click}  load_current_scf_validate_it_and_provision
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}    ${close_click}    660    ${end_to_end}
        Wait Until Keyword Succeeds    5 min   10 sec    Verify Setup Of All Cells
        Append to List    ${OFFLINE_VALIDATION_DICT}[Start]   ${validation_click}
        Append to List    ${OFFLINE_VALIDATION_DICT}[End]   ${validation_end}
    END

Verify Duration of CM offline Validation Operation 1 DU Full plan WebEM Valid succ
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        ${end_to_end}=    Check if operation time is within the limit
        ...       ${OFFLINE_VALIDATION_DICT}[Start][${attempt}]    ${OFFLINE_VALIDATION_DICT}[End][${attempt}]   140    ${end_to_end}
    END

Verify Duration of CM offline Validation Operation 1 DU Full plan WebEM Valid err
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Verify Setup Of All Cells
        ${operation_begins}  ${validation_end}   load_scf_with_err_and_validate_it
        ${end_to_end}=    Check if operation time is within the limit
        ...       ${operation_begins}    ${validation_end}   140    ${end_to_end}
        Verify Setup Of All Cells
    END

Verify Duration of CM Validation Operation CU Full Plan Validation Succesfull WebEm
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        gnbcu.verify_if_cells_are_enabled
        ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
        Get Active CU Configuration   ${OUTPUT_DIR}/full_plan_${current_date}
        ${status}=    cu.load_commissioning_file_and_check_load_status    ${OUTPUT_DIR}/full_plan_${current_date}
        ...           full_plan_${current_date}    validate_plan=no
        cu.choose_plan      full_plan_${current_date}
        ${operation_begins}=    Get Current Date    result_format=%Y%m%d%H%M%S
        ${validation_output}=    cu.validate_plan   timeout=120
        cu.delete_plan
        ${validation_end}=    Get time from robot output log  Validate plan operation finished
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}   ${validation_end}    120    ${end_to_end}
        ${validation_output}=    Convert To String    ${validation_output}
        Should Contain X Times    ${validation_output}    None    5
        gnbcu.verify_if_cells_are_enabled
        Remove File    ${OUTPUT_DIR}/full_plan_${current_date}
    END

Get time from robot output log
        [Arguments]    ${message}
        ${selenium_output}=    Run   cat ${OUTPUT_DIR}/output.xml | grep '${message}' | tail -1
        ${time} =	Get Regexp Matches    ${selenium_output}    \\d{8} \\d{2}:\\d{2}:\\d{2}
        ${time} = 	         Convert Date 	${time}[0]   exclude_millis=yes
        [Return]    ${time}

Verify Duration of CM Download Operation 1 CU Full plan WebEM
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
        ${load_finished}    CUCommonInterface.load_current_scf_and_return_end_time    ${OUTPUT_DIR}    full_plan_${current_date}
        ${operation_begins}=    Get time from robot output log    load-scf\
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}   ${load_finished}    10    ${end_to_end}
        Remove File    ${OUTPUT_DIR}/full_plan_${current_date}
    END

Verify Duration of CM Activate Operation CU Full Plan site level service outage WebEM
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Xtower Start      device_name=${x_tower_vm_name}     host=${x_tower_vm_name}    login=${x_tower_username}     password=${x_tower_password}
        Xtower X2 Start    device_name=${x_tower_vm_name}     host=${x_tower_vm_name}   login=${x_tower_username}    password=${x_tower_password}
        Wait Until Keyword Succeeds    5x    1min    Wait For Cells To Be Enabled     timeout=600
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
        Set Test Variable   ${current_date}    ${current_date}
        Get Active CU Configuration   ${OUTPUT_DIR}/full_plan_${current_date}
        cu.load_commissioning_file_and_check_load_status    ${OUTPUT_DIR}/full_plan_${current_date}
        ...           full_plan_${current_date}    validate_plan=no
        ${status}=     cu.activate_plan     download_plan_without_activation=True    timeout=120
        Should Be True     '${status}'=='Download operation has succeeded'
        ${plans}=    get_all_plans
        cu.choose_plan      full_plan_${current_date}
        cu.delete_plan
        cu.choose_plan    ${plans}[Active configuration:][plan][2]
        ${operation_begins}=    Get Current Date    result_format=%Y%m%d%H%M%S
        ${status}=     cu.activate_plan    timeout=300
        ${activation_finished}=    Get Current Date    result_format=%Y%m%d%H%M%S
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}   ${activation_finished}    300    ${end_to_end}
        Should Be True     '${status}'=='Plan activation has finished successfully'
        Wait Until Keyword Succeeds    10 min   30sec    Check 1600 cells status on CU with connection: CU
        ${alarms_after_test}=    cu_admin.Get Active Alarms    connection=CU
        Run Keyword And Ignore Error   Should Be True    ${alarms_after_test}[total] == ${alarms_before_test}[total]
        gnbcu.verify_if_cells_are_enabled
    END

Check ${numb_of_cells} cells status on CU with connection: ${connection}
    ${cell_status}=    cu_admin.get_cells_statuses   connection=${connection}
    ${cell_status}=    Convert To String    ${cell_status}
    ${cell_status}=    Replace String    ${cell_status}    u'    '
    Should Contain X Times    ${cell_status}    'administrative_state': 'Unlocked'
    ...                       ${numb_of_cells}
    Should Contain X Times    ${cell_status}    'operational_state': 'enabled'
    ...                       ${numb_of_cells}

Verify Duration of CM Provision Operation CU Full Plan site level service outage WebEM
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Setup CU admin connection
        ${alarms_before_test}=    cu_admin.Get Active Alarms    connection=CU
        ${current_date}=    Get Current Date    result_format=%Y%m%d%H%M%S
        Set Test Variable   ${current_date}    ${current_date}
        ${operation_begins}   ${activation_finished}    CUCommonInterface.load_current_scf_and_provision_it
        ...                   ${OUTPUT_DIR}    full_plan_${current_date}
        ${end_to_end}=    Check if operation time is within the limit    ${operation_begins}   ${activation_finished}    320    ${end_to_end}
        Wait Until Keyword Succeeds    10 min   30sec    Check 1600 cells status on CU with connection: CU
        ${alarms_after_test}=    cu_admin.Get Active Alarms    connection=CU
        Run Keyword And Ignore Error    Should Be True    ${alarms_after_test}[total] == ${alarms_before_test}[total]
        Teardown CU admin connection
    END

Verify Duration of CM Validation Operation CU Delta Plan Validation Succesfull NetAct WebEm
    [Arguments]     ${num_of_tries}=${NUMBER_OF_TRIES}
    ${cells} =    Set Variable    1600
    ${cells_num} =    Convert To Number   ${cells}
    FOR  ${attempt}  IN RANGE  0  ${num_of_tries}
        Wait Until Keyword Succeeds    8x    10s    gnbcu.verify_if_cells_are_enabled
        ${add_or_subtract}=    Evaluate    -${add_or_subtract}
        ${output} =    cu_admin.generate_delta_plan    delta_plan    ${PLAN_DESCRIPTION}    CU
        ${plan_id} =    Get From Dictionary    ${output}    plan_id
        Sleep    10
        ${search_param_in_delta_plan}    cu_admin.search_parameters_of_delta_plan    ${plan_id}
        ...                              maxNumOfUsersNRCell    CU    items_per_page=${cells_num}
        Change Parameter In All Cells Via WebEm    ${search_param_in_delta_plan}    ${add_or_subtract}    ${plan_id}    ${cells}
        ${status_dict} =    cu_admin.validate_delta_plan    ${plan_id}    CU
        ${validation_started} =    Get Current Date    result_format=%m/%d/%y %I:%M:%S %p
        ${validation_finished}=    Wait Until Operation Finished    ${status_dict['action_id']}    ${plan_id}    CU    Delta Validation
        ${status_dict} =    cu_admin.activate_delta_plan    plan_id=${plan_id}    connection=CU
        ${activation_started} =    Get Current Date    result_format=%m/%d/%y %I:%M:%S %p
        ${activation_finished}=    Wait Until Operation Finished    ${status_dict['operation_id']}    ${plan_id}    CU    Delta Activation
        Append To List    ${start_activation_times}    ${activation_started}
        Append To List    ${finish_activation_times}    ${activation_finished}
        ${bts_target} =    Check if operation time is within the limit    ${validation_started}
        ...                ${validation_finished}    40    ${bts_target}    True
        ${validation_time} =    Get From List    ${bts_target}    -1
        Log To Console    \nChange parameter in all cells - validation time: ${validation_time}
        cu_admin.delete_delta_plan    ${plan_id}    CU
        Wait Until Keyword Succeeds    8x    10s    gnbcu.verify_if_cells_are_enabled
    END

Change Parameter In All Cells Via WebEm
    [Arguments]  ${search_param_in_delta_plan}  ${add_or_subtract}  ${plan_id}  ${number_of_cells}
    FOR    ${cell}    IN RANGE    0    ${number_of_cells}
        ${mo_uuid}=  Fetch From Right  ${search_param_in_delta_plan['items'][${cell}]['mo_uuid']}  /
        ${value}     Fetch From Right  ${search_param_in_delta_plan['items'][${cell}]['parameter']['simple_parameter']['value']}  /
        ${value}=    Evaluate    ${value} + ${add_or_subtract}
        ${value}=    Convert To String    ${value}
        ${dict}=     Create Dictionary
        ...    operation_type    replace
        ...    parameter_path    /maxNumOfUsersNRCell
        ...    value             ${value}
        ${list_of_param}=    Create List    ${dict}
        ${status_dict} =  cu_admin.update_parameters_of_delta_plan  ${plan_id}  ${mo_uuid}  ${list_of_param}  CU
        Wait Until Operation Finished    ${status_dict['action_id']}    ${plan_id}    CU    Delta Update
    END

Wait Until Operation Finished
    [Arguments]    ${action_id}    ${plan_id}    ${alias}    ${operation}
    Wait Until Keyword Succeeds    240s  300ms  ${operation}    ${action_id}    ${plan_id}    ${alias}
    ${operation_finished}=    Get Current Date    result_format=%m/%d/%y %I:%M:%S %p
    [Return]    ${operation_finished}

Set Activation Lists
    ${add_or_subtract} =    Set Variable    -1
    ${start_activation_times} =    Create List
    ${whole_activation_times} =    Create List
    ${finish_activation_times}=    Create List
    Set Test Variable     ${add_or_subtract}
    Set Suite Variable    ${start_activation_times}
    Set Suite Variable    ${whole_activation_times}
    Set Suite Variable    ${finish_activation_times}

Delta Validation
    [Arguments]    ${action_id}    ${plan_id}    ${alias}
    ${status_dict}=  cu_admin.get_action_state_of_validating_delta_plan  ${plan_id}  ${action_id}  ${alias}
    Run Keyword If   '${status_dict['status']}' != 'success'    Fail

Delta Activation
    [Arguments]    ${action_id}    ${plan_id}    ${alias}
    ${status_dict}=  cu_admin.get_operation_state_of_activating_delta_plan  ${plan_id}  ${action_id}  ${alias}
    Run Keyword If   '${status_dict['status']}' != 'success'    Fail

Delta Update
    [Arguments]    ${action_id}    ${plan_id}    ${alias}
    ${status_dict}=  cu_admin.get_action_state_of_updating_parameters_of_delta_plan  ${plan_id}  ${action_id}  ${alias}
    Run Keyword If   '${status_dict['status']}' != 'success'    Fail

Verify Duration of CM Activate Operation CU Delta Plan no service outage NetAct WebEm
    FOR  ${attempt}  IN RANGE  0  ${NUMBER_OF_TRIES}
        ${bts_target} =    Check if operation time is within the limit    ${start_activation_times}[${attempt}]
        ...                ${finish_activation_times}[${attempt}]    80    ${bts_target}    True
        ${activation_time} =    Get From List    ${bts_target}    -1
        Log To Console    \nChange parameter in all cells - activation time: ${activation_time}
    END

Test Suite Setup
    [Arguments]    ${branch}=21B
    Log to console      \n-- Start suite setup --\n
    ${scf_base_name}    Set Variable If    "${NRBTS_ID}"=="470"    _6443_22R2_470.xml
    ...                  "${NRBTS_ID}"=="466"    _2536_21B_466.xml
    ...                  "${NRBTS_ID}"=="479"    _6443_22R2_479.xml
    Set Suite variable    ${scf_base_name}    ${scf_base_name}
    Create Directory    ${path_to_scfs}
    Sleep     10s
    log to console      - Perform full commisioning on Cloud gNB
    OperatingSystem.Run     wget -P ${path_to_scfs} ${url_path_to_scfc}/CU${scf_base_name}
    OperatingSystem.Run     wget -P ${path_to_scfs} ${url_path_to_scfc}/DU${scf_base_name}
    @{DU_scf}       Create List    ${path_to_scfs}/DU${scf_base_name}
    Run Keyword If    '${branch}' == '22R2'
    ...    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    20 min    5 min
    ...    Perform Full Commissioning On Cloud Gnb       cu_scf_path=${path_to_scfs}/CU${scf_base_name}
    ...    du_scf_path=@{DU_scf}  prefix_tag=False  readiness_timeout=1800  except_ongoing_operation=True
    ...    ELSE IF    '${branch}' == '21B'
    ...    Run Keyword And Ignore Error    Perform Full Commissioning On Cloud Gnb    cu_scf_path=${path_to_scfs}/CU${scf_base_name}
    ...    du_scf_path=@{DU_scf}  prefix_tag=False  readiness_timeout=1800  except_ongoing_operation=True
    log to console      - Start Xtower
    Xtower Start      device_name=${x_tower_vm_name}     host=${x_tower_vm_name}    login=${x_tower_username}     password=${x_tower_password}
    Xtower X2 Start    device_name=${x_tower_vm_name}     host=${x_tower_vm_name}   login=${x_tower_username}    password=${x_tower_password}
    ${states}=    Create List   Configured   OnAir
    Wait Until Keyword Succeeds  20min  30s  Verify Procedural and Blocking State  procedural_states=${states}
    ${alarm_presence}=    Run Keyword And Ignore Error     gnbalarm.Check If Sw Incompatible Alarm Occurred   awaiting_time=0
    log     ${alarm_presence}
    Run Keyword If     "${alarm_presence}[0]" == "FAIL"
    ...                Wait Until Keyword Succeeds  20min  30s  Download and update same SW version  timeout=1200
    ...                ELSE    Run Keyword If  ${alarm_presence}[1]
    ...                Wait Until Keyword Succeeds  20min  30s  Download and update same SW version  timeout=1200
    log to console      - Wait for cells to be OnAir
    Wait Until Keyword Succeeds    5x    1min    Wait For Cells To Be Enabled     timeout=600
    log to console      \n-- Suite setup finished --\n

Set number of minimum expected PMs for release 21B
    Set Suite variable    ${min_expected_number_of_PM_files}     ${min_expected_number_of_PM_files_21B}
    Set Suite variable    ${min_expected_number_of_PM_conters}   ${min_expected_number_of_PM_conters_21B}
