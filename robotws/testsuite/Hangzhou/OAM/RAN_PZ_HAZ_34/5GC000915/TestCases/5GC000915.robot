*** Variables ***
# All these variables can be passed as parameters with eclat using --variable option in session manager
${bts_oam_http}=            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${full_bts_http}=           ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${bts_oam_ssh}=             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${bts_oam_ssh_user}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#${bts_oam_ssh_pwd}=         ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${bts_port}=                443
${cli_host}=                ${tl.test_pc.default_ssh_connection_details.addr}
${cli_host_login}=          ${tl.test_pc.default_ssh_connection_details.username}
${cli_host_pwd}=            ${tl.test_pc.default_ssh_connection_details.password}
${cli_home_path}=           /home/ute
${cli_cmd_path}=            ${cli_home_path}/current
${cli_log_path}=            ${cli_home_path}/logs
${cli_daemon}=              admin-cli.sh
${cli_daemon_cmd}=          ${cli_cmd_path}/${cli_daemon}
${cli_daemon_port}=         9001
${cli_cmd}=                 ${cli_cmd_path}/agent-cli/agent-cli.sh
${nemu_access}=             --bts-username='Nemuadmin' --bts-password='nemuuser'
${debug}=                   ${False}
${console}=                 ${False}


*** Settings ***
Documentation
...     Test Suite Purpose:
...         Tests for Classical platform
...     TL Target:
...         Test remote CLI on classical
...     DESCRIPTION:
...         Launch the cli daemon with peer credentials
...         Test cli commands and returned results
...     AUTHOR (I&V-2):
...         Sebastien RICHER          sebastien.richer@nokia.com

Library     BuiltIn
Library     Collections
Library     String
Library     OperatingSystem
Library     DateTime
Library     SSHLibrary                  prompt=REGEXP:ute.*$   timeout=600 seconds
Library     taf.sbts.oam.coam.admin      WITH NAME   coam
Library     ${CURDIR}/../resources/AdminCliUtils.py                     debug=${debug}     console=${console}
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot


Force Tags    RAN_5G    RAN_5G_TDD    CRT_UTE    CRT_22R1   
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_ASIKR_ABILB4_AZHA_ENB_NETACT    STATE_SW_UPLOADED    SBTS00    CRT_21B     


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND     robot_common_operations.Common Suite Setup
...  AND    Create Directory    /home/ute/current
...    AND      Download Admin Cli    AND    Set Testing Env

Suite Teardown   Run Keywords     Clean Testing Env   AND   robot_common_operations.Common Suite Teardown
Test Setup       robot_common_operations.Common Case Setup
Test Teardown    robot_common_operations.Common Case Teardown



*** Variables ***

*** Test Cases ***

[1]5GC000915_A_2003_915_A_Reset_NRCELL
    [Documentation]     Reset NRCELL

    [Teardown]          Run Keywords    Case Postcondition    AND
    ...    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM

    Case Precondition
    @{current}=         coam.get_managed_objects
    ...                 class_name=NRCELL_R
    ...                 timeout=${600}
    ...                 connection=coam_admin
    &{nrcell}=          Get From List   ${current}
    ...                                 0
    set test variable   ${nrcell.distName}
    Log                 Run cli-admin: resetCell ${nrcell.distName}             console=True
    ${json_data}=       catenate
    ...                 '{"requestId":2003,
    ...                 "parameters":{
    ...                     "name":"resetCell",
    ...                     "parameters":{
    ...                         "id":"${nrcell.distName}"
    ...                     }
    ...                 }}'
    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
	&{res}=             Parse Output    ${res1} 
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 2003
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    # Checking CELL status post reset
    coam_gnb_classical.Connect to gnb coam via ssl
    Wait until keyword succeeds         5 min       10s
    ...                                 coam_gnb_classical.COAM Check GNB cell on air
    
[1]5GC000915_A_1001_915_A_Sfp_management
    [Documentation]     Get sfp information    

    [Teardown]          Case Postcondition

    Case Precondition
    Log                 Run cli-admin: sfpData                                  console=True
    ${json_data}=       catenate
    ...                 '{"requestId":1001,
    ...                 "requestType":"infoModel",
    ...                 "parameters":{
    ...                     "name":"sfpData"
    ...                 }}'
    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
	&{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 1001
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    Log                 Checking returned message content with actual data
    @{current}=         coam.get_managed_objects
    ...                 class_name=SFP_R
    ...                 timeout=${600}
    ...                 connection=coam_admin

[1]5GC000915_A_1031_915_A_Ald_management
    [Documentation]     ALD management       

    [Teardown]          Case Postcondition

    Case Precondition
    Log                 Run cli-admin: getAldList                               console=True
    ${json_data}=       catenate
    ...                 '{"requestId":10311,
    ...                 "parameters":{
    ...                     "name":"getAldList"
    ...                 }}'
    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
	&{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 10311
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    ${ald}=             Get From List   ${res.requestMessage.alds}
    ...                                 0
    Log                 Run cli-admin: getAldById                             console=True
    ${json_data}=       catenate
    ...                 '{"requestId":10312,
    ...                 "parameters":{
    ...                     "name":"getAldById",
    ...                     "parameters": {
    ...                         "id": "${ald.id.runtime}"
    ...                     }
    ...                 }}'
    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
	&{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 10312
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    Log                 Checking returned message content with actual data
    ${checkup_list}=    Create List
    ...                 productCode
    ...                 serialNumber
    ...                 swVersion
    ...                 hwVersion
    ...                 controlProtocol
    ...                 aisgProtocolVersion
    @{current}=         coam.get_managed_objects
    ...                 class_name=ALD_R
    ...                 timeout=${600}
    ...                 connection=coam_admin
    &{current_ald}=     Get From List   ${current}
    ...                                 0
    Data Checkup        ${checkup_list}
    ...                 ${res.requestMessage}
    ...                 ${current_ald.parameters}
    ${3ggReleaseId}=    Get From Dictionary
    ...                 ${res.requestMessage}
    ...                 3gppReleaseId
    Should Be Equal As Integers     ${3ggReleaseId}
    ...                             ${current_ald.parameters.releaseId3Gpp}
    Run keyword if  'branch' in '${release}'  Dictionaries Should Be Equal    ${res.requestMessage.status}
    ...                             ${current_ald.parameters.stateInfo}
    ...    ELSE    Check ALD Status    ${res.requestMessage.status}
    ...                             ${current_ald.parameters}




[1]5GC000915_A_1201_915_A_Measurements
    [Documentation]     Measurements     

    [Teardown]          Case Postcondition

    Case Precondition
    Log                 Run cli-admin: getRealTimeMeasurements                  console=True
    ${json_data}=       catenate
    ...                 '{"requestId":1201,
    ...                 "requestType":"infoModel",
    ...                 "parameters":{
    ...                     "name":"getRealTimeMeasurements"
    ...                 }}'
    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
	&{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 1201
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    Log                 Checking returned message content with actual data
    @{rt_measures}=     coam.get_real_time_measurements
    ...                 timeout=${600}
    ...                 connection=coam_admin
    ${power}    ${vswr}     ${temp}=    Read Measurements       ${res.requestMessage}
    Should not be empty     ${temp}

 

[1]5GC000915_A_2001_915_A_Reset_Ald
    [Documentation]     Reset ALD

    [Teardown]          Case Postcondition

    Case Precondition
    @{current}=         coam.get_managed_objects
    ...                 class_name=ALD_R
    ...                 timeout=${600}
    ...                 connection=coam_admin
    &{ald}=             Get From List   ${current}
    ...                                 0
    Log                 Run cli-admin: unitReset ${ald.distName}                console=True
    ${json_data}=       catenate
    ...                 '{"requestId":2001,
    ...                 "parameters":{
    ...                     "name":"unitReset",
    ...                     "parameters":{
    ...                         "id":"${ald.distName}"
    ...                     }
    ...                 }}'

    ${res1}=             Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data}
  	&{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}
    ...                                 2001
    Should be equal as strings          ${res.requestStatus}
    ...                                 completed
    Should be equal as integers         ${res.errorCode}
    ...                                 0
    # Checking ALD status post reset
    Wait until keyword succeeds         5 min       10s
    ...                                 Check if ALD Online and Enabled


*** Keywords ***
Set Testing Env
    [Documentation]     Environement Setup for Testing
    ${full_bts_http}=   Get Full HTTP   ${bts_oam_http}
    Set Suite Variable  ${full_bts_http}
     Launch Cli Admin Daemon


Clean Testing Env
    [Documentation]     Clean all
    Kill Cli Admin Daemon

Launch Cli Admin Daemon
    [Documentation]     Open a connection to cli host and launch the admin cli daemon
    Log                 Connecting to ${cli_host}                               console=True
    ${timestamp}=       Get Current Date    result_format=%Y_%m_%d_%H%M
    set suite variable  ${timestamp}
    ${debug_options}=   set variable        --debug='${cli_log_path}/5GC000915_${timestamp}'
    ${bts_options}=     set variable        --bts-host='${full_bts_http}' --bts-port='${bts_port}'
    ${cli_options}=     set variable        --cli-port='${cli_daemon_port}'
    Log                 Launching: ${cli_daemon_cmd} ${bts_options} ${cli_options} ${nemu_access} ${debug_options}
    ...                                                                         console=True
    Run                 nohup ${cli_daemon_cmd} ${bts_options} ${cli_options} ${nemu_access} ${debug_options} > stdout.txt 2>&1 &


Kill Cli Admin Daemon
    [Documentation]     Kill the daemon process and exit
    Log                 Stopping ${cli_daemon}                                  console=True
    Run     killall ${cli_daemon}
    Run     killall node

Setup Gnb
    [Documentation]     Set the gnb for admin cli
    [Arguments]         ${bts_addr}
    Log                 Set up gnb for remote cli                               console=True
    coam.connect to     bts_host=${bts_addr}            name=coam_admin
    ${scf}=             coam.get current scf content    connection=coam_admin   timeout=${600}
    ${nrbts}=           get name by class from scf      ${scf}          com.nokia.srbts.nrbts:NRBTS
    Set Parameter       actGeneralConnectivitySilver    ${nrbts}        true
    ${featcadm}=        get name by class from scf      ${scf}          com.nokia.srbts.mnl:FEATCADM
    Set Parameter       actCli                          ${featcadm}     true
    coam.teardown       connection=coam_admin

Unsetup Gnb
    [Documentation]     Set the gnb for admin cli
    [Arguments]         ${bts_addr}
    Log                 Teardown gnb from remote cli                            console=True
    coam.connect to     bts_host=${bts_addr}            name=coam_admin
    ${scf}=             coam.get current scf content    connection=coam_admin   timeout=${600}
    ${featcadm}=        get name by class from scf      ${scf}          com.nokia.srbts.mnl:FEATCADM
    Set Parameter       actCli                          ${featcadm}     false
    coam.teardown       connection=coam_admin

Set Parameter
    [Documentation]     Set the gnb for admin cli
    [Arguments]         ${param}     ${parent}      ${value}
    Log                 Set ${param} to ${value}                                console=True
    &{res}=             coam.perform_parameter_recommissioning
    ...                 dist_name=${parent}
    ...                 skip_parameter_relation_errors=False
    ...                 parameter=${param}
    ...                 operation=update
    ...                 value=${value}
    ...                 timeout=${900}
    ...                 connection=coam_admin
    Should be equal as strings      ${res.commissioningResult.activationResult.resultNode.parameters.result}
    ...                             Success

Check BTS Status
    [Documentation]     Check the status of the bts
    [Arguments]         @{expected_statuses}
    &{status}=          coam.get_bts_statuses
    ...                 connection=coam_admin
    @{expected}=        Create List     @{expected_statuses}
    Status Should Be    ${status.proceduralState}   ${expected}

Check if ALD Online and Enabled
    [Documentation]     Check the status of ALD
    @{current}=         coam.get_managed_objects
    ...                 class_name=ALD_R
    ...                 timeout=${600}
    ...                 connection=coam_admin
    &{ald}=             Get From List   ${current}
    ...                                 0
    Run keyword if  'branch' in '${release}'    Should be equal as strings
    ...    ${ald.parameters.stateInfo.availabilityStatus}      Online    ignore_case=True
    ...    ELSE    Should be equal as strings
    ...    ${ald.parameters.availabilityStatus}      None    ignore_case=True
    Run keyword if  'branch' in '${release}'    Should be equal as strings
    ...    ${ald.parameters.stateInfo.operationalState}        Enabled    
    ...    ignore_case=True
    ...    ELSE    Should be equal as strings  ${ald.parameters.operationalState}        Enabled    
    ...    ignore_case=True

Check if GNSSE Online and Enabled
    [Documentation]     Check the status of GNSSE
    @{current}=         coam.get_managed_objects
    ...                 class_name=GNSSE_R
    ...                 timeout=${600}
    ...                 connection=coam_admin
    &{gnsse}=           Get From List   ${current}
    ...                                 0
    Should be equal as strings          ${gnsse.parameters.stateInfo.availabilityStatus}    Online
    Should be equal as strings          ${gnsse.parameters.stateInfo.operationalState}      Enabled

Case Precondition
    coam.connect_to     bts_host=${full_bts_http}           name=coam_admin    

Case Postcondition    
    coam.teardown       connection=coam_admin
    

Download Admin Cli
    coam.connect to     bts_host=${bts_oam_http}
    ${swversion}=                      coam.get_sw_version
    ${result}    run keyword and return status    should contain any
    ...    ${swversion}
    ...    12.400    14.400    22R1    22R2    21B    21A    20B
    ${release}    Set Variable If    ${result}    branch    trunk
    Set Suite Variable    ${release} 
    Run Keyword if                     '_9999_' in '${swversion}'    AdminCliUtils.get_file_for_Trunk_Load
    ...    ${swversion}
    Run Keyword if                     '_0000_' in '${swversion}'    AdminCliUtils.get_file_for_21B_Load
    ...    ${swversion}  
    Run Keyword if                     '5G21A' in '${swversion}'    AdminCliUtils.get_file_for_21A_Load
    ...    ${swversion}      
    Run Keyword if                     '5G20B' in '${swversion}'    AdminCliUtils.get_file_for_20B_Load
    ...    ${swversion}
    AdminCliUtils.unzip_file                              
    OperatingSystem.Directory Should Not Be Empty      /home/ute/current
    Run Keyword And Ignore Error       coam.teardown

Check ALD Status
    [Arguments]    ${output}    ${current_output}
    Collections.Dictionary Should Contain Item    ${output}     administrativeState
    ...    ${current_output.administrativeState}
	  Collections.Dictionary Should Contain Item    ${output}     operationalState
	  ...    ${current_output.operationalState}
	  Collections.Dictionary Should Contain Item    ${output}     usageState    ${current_output.usageState}
    