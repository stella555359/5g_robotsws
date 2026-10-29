*** Settings ***
Documentation
...    author: Li Yingying
...    contact: yuanyuan.li@nokia-sbell.com
...    squad group: MMW_HZ_SG_03

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    SSHLibrary    WITH NAME    ssh_lib
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
*** Variables ***
${mrbtsId}    ${tl.gnbs[0].instance_id}
${nrbtsId}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=Nemuadmin
                  ...      password=nemuuser
                  ...      name=${connection}

Check If File Is Not Empty
    [Documentation]
    ...  Checks if file is not empty
    [Arguments]    ${filename}
    File Should Not Be Empty    ${filename}

Delete snapshot
    [Documentation]
   	...  Removes directory
    [Arguments]    ${local_file_path}
    run  rm -rf ${local_file_path}

CaseTeardown
    [Arguments]       ${connection}=COAM
    Log    \n *** Case teardown
    admin_cli.teardown    connection=${connection}
    CI_interface.Common Case Teardown

Set mrbtsId and nrbtsId variables
    Conect to DU COAM
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=COAM
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.du.5g:MRBTS"]
    ${nrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]

    set suite variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}
    set suite variable   ${nrbtsId}   ${nrbtsId_element.attrib['distName']}

Remove TRBLCADM Object
    [Documentation]
    ...    to remove TRBLCADM object with required parameters
    @{list}=    create list
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning
    ...                                  parameter=${list}
    ...                                  dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                  operation=delete
    ...                                  skip_parameter_relation_errors=${True}
    ...                                  should_activate=${True}

Create TRBLCADM Object
    [Documentation]
    ...    to create TRBLCADM object with required parameters
    ${dict1}=    create dictionary    parameterName=actCoreDumpFileCollection
    ...          operation=update
    ...          value=${true}
    ${dict2}=    create dictionary    parameterName=actInternalTrace
    ...          operation=update
    ...          value=${true}
    ${dict3}=    create dictionary    parameterName=actRemoteSyslogTransmission
    ...          operation=update
    ...          value=${false}
    ${dict4}=    create dictionary    parameterName=snapshotUploadDelayForFault6450
    ...          operation=update
    ...          value=1
    @{parameter_list}=    create list    ${dict1}    ${dict2}    ${dict3}    ${dict4}
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin_cli.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=COAM

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${lss_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=lss
    ...                connection=COAM
    ${list_parameters}=    Get From Dictionary    ${lss_dict['lssConfig']}
    ...                                           lssIPaddress
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                           connection=COAM

Get External Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and sends it to remote LSS server
    [Arguments]    ${coverage}
    ...            ${timeout}
    admin_cli.get_remote_snapshot    ${coverage}    ${timeout}    connection=COAM

Check for existence of remote snapshot
    [Arguments]    ${host}
    ...            ${user}
    ...            ${pass}
    ...            ${dir}
    ssh_lib.Open Connection   ${host}
    ssh_lib.Login    ${user}    ${pass}
    ${FileList}=    ssh_lib.List Directory    ${dir}
    log    ${FileList}
    Should Contain Match    ${FileList}    Snapshot_${mrbtsId}*

Extract Snapshot
    [Documentation]
    ...  Extracts snapshot.zip to directory
    [Arguments]    ${snapshot_path}
    ...            ${extract_directory}
    Run    unzip ${snapshot_path} -d ${extract_directory}


Check For Summary File
    [Documentation]
    ...  Checks for snapshot file list
    [Arguments]    ${extract_directory}
    OperatingSystem.File Should Exist    ${extract_directory}/snapshot_file_list.txt

COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Set miNrF1CD to 5min
    COAM Update Parameter    dist_name=${nrbts_id}/NRPMRNL-1    parameter=miNrF1CD     value=5min
    sleep    5s

Set miNrF1CD to 15min
    COAM Update Parameter    dist_name=${nrbts_id}/NRPMRNL-1    parameter=miNrF1CD     value=15min
    sleep    5s

Set miNrF1UDInterface to 5min
    COAM Update Parameter    dist_name=${nrbts_id}/NRPMRNL-1    parameter=miNrF1UDInterface     value=5min
    sleep    5s

Set miNrF1UDInterface to 15min
    COAM Update Parameter    dist_name=${nrbts_id}/NRPMRNL-1    parameter=miNrF1UDInterface     value=15min
    sleep    5s


Set reportingIntervalPm to 5min
    COAM Update Parameter    dist_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=5min
    sleep    5s


Set reportingIntervalPm to 15min
    COAM Update Parameter    dist_name=${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=15min
    sleep    5s

unzip snapshot log and check PM files
    [Arguments]    ${local_file_path}
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    #csn.execute    command=cp ${snapshot_log} ${SAVE LOG DIRECTORY}    connection=ute
    csn.SendCommand    command=mkdir /home/ute/snapshot    connection=ute
    ${snapshot_extract}    Set Variable    /home/ute/snapshot
    csn.execute    command=unzip -o ${local_file_path} -d ${snapshot_extract}    connection=ute
    sleep     5s
    csn.SendCommand    command=cat /home/ute/snapshot/snapshot_file_list.txt    connection=ute
    ${pmfile}    csn.read output    connection=ute
    ${matched_content}    Should Match Regexp      ${pmfile}    BTS.*?_PM.BTS.*?.xml
    should not be empty    ${matched_content}
    csn.send_command     command=rm -rf /home/ute/snapshot/*    connection=ute
    #csn.Disconnect    connection=ute


Check if counter is configured
    [Arguments]  ${expected_value}   ${parameter_name}
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=COAM
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${value}=   Get Element Text   ${XML}   .//p[@name="${parameter_name}"]
    Should be equal   ${value}   ${expected_value}


Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}
   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period


PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   Wait Until Keyword Succeeds                     6 min
   ...                                            1 min
   ...                                             Wait For Right Period
   Sleep                                           60

Wait For Right Period
   ${list}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
#   ${actualTime_snapshot}=     Get Current Date    result_format=%M
#   ...                                    time_zone=UTC
#   ${actualHour_snapshot}=     Get Current Date    result_format=%H
#   ...                                    time_zone=UTC
   ${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   set suite variable                   ${actualTime}
   set suite variable                    ${actualHour}
#   set suite variable                    ${actualTime_snapshot}
#   set suite variable                    ${actualHour_snapshot}
   set suite variable                    ${actualEpoch}
   set suite variable                    ${date}
   set suite variable                    ${date_nodash}


Check if counter group is fully collected
   [Documentation]    ${counter_id} is a counter ID
   [Arguments]  ${counter_id}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-435*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   Check if counters are collected in proper objects   ${counter_id}   ${epoch_minus_interval_string}




Check if counters are collected in proper objects
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${measurement_id}   ${epoch}
   ${counter_values}=   admin_cli.get pm counters   ${counter_id}    connection=COAM
   ${string_values}=   Convert To String   ${counter_values}
   Should Contain   ${string_values}  ${epoch}


ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=${True}
    ...            ${should_activate}=${True}
    ...            ${timeout}=300
    ${delta_file_new}    Change MRBTS and NRBTS id of Delta SCF    file_path=${delta_file}
    Conect to DU COAM    connection=COAM
    admin_cli.Perform Delta Recommissioning
    ...                                        delta_file=${delta_file_new}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        connection=COAM
    [Teardown]   admin_cli.teardown    connection=COAM


Change MRBTS and NRBTS id of Delta SCF
    [Arguments]     ${file_path}
    Run    cp -r ${file_path} ${file_path}.bak
    Run    sed -i "s|MRBTSID|${mrbtsId}|" ${file_path}
    Run    sed -i "s|NRBTSID|${nrbtsId}|" ${file_path}
    set suite variable    ${modified_file}    ${CURDIR}/dlta_scf_new.json
    Run    cp -r ${file_path} ${modified_file}
    Run    mv ${file_path}.bak ${file_path}
    [Return]  ${modified_file}
