*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: CB008048, CB008967-F-CR and CB010797 feature related keywords

Library     SSHLibrary
Library     BuiltIn
Library     Process
Library     String
Library     DateTime
Library     Collections
Library     OperatingSystem     WITH NAME    os
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.nms.netact    WITH NAME    NMS
Library     taf.hw.pdu    WITH NAME    pdu
Library     taf.file.pack
Library     taf.analyzer.netconf		WITH NAME	Netconf
Library     taf.collectors.simple    WITH NAME    simple
Library     ./../../../T02/resources/python/snapshotFileIdentifier.py
Library    ../../../resources/python/netconf_validation.py
Resource     ./common_keywords.robot

*** Variables ***
${netconf_file}    RMOD_L-1_NetconfRpcMessageTrace.log
${mirxwindow_dist}      MRBTS-30004/EQM-1/APEQM-1/RMOD-1
${mitrrxwindow_dist}    MRBTS-30004/TNLSVC-1/TNL-12/ETHSVC-1/ETHLK-1
${timezone}=     +00:00
${TECHNOLOGY}=    NRBTS-Nokia AirScale BTS 5G
${MEASUREMENT}=    Transport RX Window Statistics
${COUNTERS}=    ['TRANSPORT_RX_ON_TIME', 'TRANSPORT_RX_EARLY', 'TRANSPORT_RX_LATE', 'TRANSPORT_RX_CORRUPT', 'TRANSPORT_RX_TOTAL']
${MO_NAME}=    PLMN-PLMN/MRBTS-30004
${OBJECT_AGGREGATION}=    MRBTS
${TIME_AGGREGATION}=    RAW
${FILTER_BY}=    MRBTS
${FJT_trunk_Build}=       FJ-RU-ET1---------0500_converted.FGF
${FJT_trunk_Build_version}=       FJ-RU-ET1---------0500.FGF_0500
${FJT_branch_N-1_Build}=       FJ-RU-ET1---------0500_converted.FGF
${FJT_branch_N-1_Build_version}=       FJ-RU-ET1---------0500.FGF_0500
${FJT_branch_N-2_Build}=       FJ-RU-ET1---------0401.FGF_downloadable
${FJT_branch_N-2_Build_version}=       FJ-RU-ET1---------0401.FGF_0401
${RAML_PATH_Public_Key_based}    /home/ute/MRBTS_30004/RAML/Step4_30608_public_key_based_without_public_Key.xml
${RAML_PATH_2SSD}    /home/ute/MRBTS_30004/RAML/Step8_2SSDORU.xml
${RAML_PATH_Add_NETCONFAC}    /home/ute/MRBTS_30004/RAML/Step14_addtional_account.xml
${RAML_PATH_Add_Default_NETCONFAC}    /home/ute/MRBTS_30004/RAML/Default_Netconf_account.xml
@{PATTERNS}     authenticationMethodSshServer: PublicKeyBased    fjncuser0    fjnuser0
${ssh_authentication_text}    "SSH client authentication failure"
${wrong_netconf_credentials}    [{"id":"1","defaultNetconfAccount":{"defaultNetconfAccountName":"fjncuser0",
...                             "defaultNetconfAccountPwd":"ncCl2Ru+autH"}}]
${correct_netconf_credentials}    [{"id":"1","defaultNetconfAccount":{"defaultNetconfAccountName":"fjncuser0",
...                               "defaultNetconfAccountPwd":"ncCl2fjRu+autH0"}}]
@{mirxwindow_counters}    M55604C00001    M55604C00002    M55604C00003    M55604C00004    M55604C00006
@{mitrrxwindow_counters}    M55605C00001    M55605C00002    M55605C00003    M55605C00004    M55605C00006
${DN}    PLMN-PLMN/MRBTS-30004
${DELTA_FILE_PATH}    SCF/DELTA_FILE.json
${rpc_get}    get
${rpc_reply}    software-inventory
${subtag}    build-name
${active}    active
@{WEBEM_PATTERNS}     authenticationMethodSshServer: DeactivationOfSSHPublicKeyValidationAtFirstConnection
...                   checkAuthenticationResult(): Ssh Client Authentication Failure
...                   status: active faultId: 4641    Authentication successful    status: inactive faultId: 4641
${trunk_version}=      26R1
${branch_N-1_version}=      25R3
${branch_N-2_version}=      25R2
${delta_file_for_Temps_activate}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG09/CB008048/SCF/ORAN_TEMP_CONFG.json
${delta_file_for_Temps_deactivate}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG09/CB008048/SCF/ORAN_TEMP_CONFG_DEACTIVATE.json
${distname_featcadm}=    MRBTS-30004/MNL-1/MNLENT-1/FEATCADM-1
${distname_pmmnl}=    MRBTS-30004/MNL-1/MNLENT-1/PMMNL-1
${miOranEpeStats_name}=    miOranEpeStats
${windowStatsValue}=    5min
${parameter_actkpi}=    actKpiAlarms
${value_actkpi}=    true
${value_true}=    true
${BTS_path}=    /home/ute/Logs
${operation_value}=    update
${vdu_connection}=    vDU
@{faults}=    4586    4587    4588

${Cell_Destnation}     MRBTS-30004/NRBTS-30004/NRCELL-1
${rtwp_min}=    -99.9
${rtwp_max}=    -60.5
${rssi_min}=    -141.0
${rssi_max}=    -90.5
${sinr_min}=    -27.0
${sinr_max}=    -19.0
&{R1A1}=  radioRId=${1}  antlRId=${1}
&{R1A2}=  radioRId=${1}  antlRId=${2}
&{R1A3}=  radioRId=${1}  antlRId=${3}
&{R1A4}=  radioRId=${1}  antlRId=${4}
@{list}=     &{R1A1}    &{R1A2}    &{R1A3}    &{R1A4}

###########CB007518Variables################
${host_vDU}    10.43.196.131
${host_vCU}    10.43.196.130
${PORT}        443
${USER}        Nemuadmin
${PWD}         Nokia@123
${mrbtsid}              MRBTS-30004
${rmod_id}=              RMOD-1
${portnum}=              6
${pdu_host_ip}=          10.41.155.25
@{cells}=                1
${incorrectSNO}=         00012
${correctSNO}=           00011
@{fault_list}=           10    4675    4282

*** Keywords ***
Verification of RU reception window Measurement counters WEBEM & MantaRay
    [Documentation]
    [Tags]   TC0
    Log to console    \n--TestCase Execution Started--
    ${start_time}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S
    ${start_time}=    Evaluate    f'${start_time}${timezone}'
    Log to console    \n--Sleeping for 5 mins to fetch counters--
    sleep    300s
    Log to console    \n--Fetching mirxwindow counters--
    Counter Validation_mirxwindow    #${start_time}
    Delta_Commissioning    ${DELTA_FILE_PATH}
    Log to console    \n--Sleeping for 5 mins to fetch counters--
    sleep    400s
    Log to console    \n--Fetching mirxwindow and mitrrxwindow counters via webem--
    Counter Validation_mirxwindow    #${start_time}
    Counter Validation_mitrrxwindow    #${start_time}
    Log to console    \n--vDU reset ongoing--
    ResetVdu
    Wait until keyword succeeds    15min    10s    Check vDU Cell status
    Log to console    \n--vDU reset completed and fetching counters--
    Counter Validation_mirxwindow    #${start_time}
    Counter Validation_mitrrxwindow    #${start_time}
    Fetch counters from netact

Multiple ORU/vDU resets via WEBEM along with L3 call
    [Documentation]    Verification TCP DL UL data transfer after multiple ORU/vDU resets via WEBEM
    [Tags]  TC1
    Log to console    \n--TestCase Execution Started--\n
    Check vDU Cell status
    Attach UE and start data transfer
    FOR    ${i}    IN RANGE    1    4
        Log to console    \n--vDU reset ${i}--
        ResetVdu
        Log to console    \nVDU RESET ONGOING
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        sleep    30s
        Log to console    \n--vDU lock unlock--
        vDU_lock_unlock
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        Log to console    \n--RANNIC reset--
        RANNIC_Reset
        sleep    90s
        Wait until keyword succeeds    20min    10sec    Check vDU Cell status
        Log to console    \n--Cells lock unlock--
        Cells_lock_unlock
        Wait until keyword succeeds    10min    10sec    Check vDU Cell status
        Log to console    \n--ORU reset ${i}--
        ORU Reset with status
    END
    Attach UE and start data transfer
    Log to console    \n--TestCase Execution Done--\n

ORU Software upgrade from MANTARAY
    [Documentation]
    [Tags]   TC0
    Log to console    \n--CB008048_ORU_SW_upgrade_from_NMS_and_call_verification--
    Check ORU and vDU SW version and upgrade ORU
    Attach UE and start data transfer
    Snapshot_vDU
    Extract netconf from snapshot
    Validate netconf log    ${out}    ${netconf_file}
    Log to console    \n--TestCase Execution Done--

Verification of Mantaray import SSD RAML file
    [Documentation]     This test case is to import SSD RAML file via Mantaray when authenticationMethod sshserver = “Public key based”
    ${cell_status}=    Check vDU Cell status
    Run Keyword If    '${cell_status}' == 'on line'
    ...    Log to console    Cell is on air, continuing with SSD Import and provisioning.
    ...    ELSE    Default_NetConf_Provision

    Import_SSDRAML   ${RAML_PATH_Public_Key_based}

    Log to console    Public_Key_based RAML file without public key defined provision started
    Run Keyword And Ignore Error    Provision_SSDRAML    ${DN}
    Log to console    SSD provision Failure is expected as RAML file doesn't has public key
    Delete_SSDRAML    ${DN}
    ORU Reset with status

    Import_SSDRAML   ${RAML_PATH_2SSD}

    Log to console    Provisioning the SSD RAML file with with 2 SSD ORU & public key specified with Default Netconf credentials
    ${Result1}=    Provision_SSDRAML    ${DN}
    IF    '${Result1['message']}' != 'All are successful' and '${Result1['status']}' != 'Completed'
    ...    Fail    SSD Provision failed with message: ${Result1['message']}
    ...    ELSE    LOG    Provisioning succeeded
    Delete_SSDRAML    ${DN}
    ORU Reset with status
    Wait Until Keyword Succeeds    15 times    20    Check vDU Cell status

    Import_SSDRAML   ${RAML_PATH_Add_NETCONFAC}

    Log to console    Provisioning the SSD RAML file with public key specified and included Additional Netconf credentials for SSDORU-1
    ${Result2}=    Provision_SSDRAML    ${DN}
    IF    '${Result2['message']}' != 'All are successful' and '${Result2['status']}' != 'Completed'
    ...    Fail    SSD Provision failed with message: ${Result2['message']}
    ...    ELSE    LOG    Provisioning succeeded
    Delete_SSDRAML    ${DN}
    ORU Reset with status
    Wait Until Keyword Succeeds    15 times    20    Check vDU Cell status
    Stop_and_Collect_Syslog_Monitoring
    Search Text In Unzipped Syslogs With Multiple Patterns    @{PATTERNS}

Verification of change or replace SSDORU parameters change from WebEM
    Log to console    \n--Verification of change or replace SSDORU parameters change under same authentication method from WebEM--\n
    Check vDU Cell status
    Wait until keyword succeeds    2min    10sec    Load wrong netconf credentials
    Log to console    \n--O-RU reset started--\n
    ${rmods_list}=    Create List    1
    admindu.reset_rmods    rmods_list=${rmods_list}    reset_reason=user    raw=True
    ...    graceful_cell_shutdown=True    timeout=500    vdu_connection=${vdu_connection}
    Log to console    \n--O-RU reset Completed--\n
    sleep    300s
    Wait until keyword succeeds    5min    10sec    Assert alarm active
    Wait until keyword succeeds    2min    10sec    Load correct netconf credentials
    Wait until keyword succeeds    5min    10sec    Check vDU Cell status
    Attach UE and start data transfer
	Stop_and_Collect_Syslog_Monitoring
	Search Text In Unzipped Syslogs With Multiple Patterns    @{WEBEM_PATTERNS}

Counter validation
    [Arguments]    ${distname}    @{counters}
    FOR    ${counter}    IN    @{counters}
        ${result} =    admindu.get_counter_values    counter_id=${counter}    dimension_dn=${distname}
        ...    vdu_connection=${vdu_connection}
        log    ${result}
        Should not be empty    ${result}
    END

Counter Validation_mirxwindow
    Counter validation    ${mirxwindow_dist}    @{mirxwindow_counters}

Counter Validation_mitrrxwindow
    Counter validation    ${mitrrxwindow_dist}    @{mitrrxwindow_counters}

Fetch counters from netact
	Log to console    \n--fetching counters from netact--
    ${results}=    NMS.get_pm_counters    technology=${TECHNOLOGY}    measurement=${MEASUREMENT}
    ...                              counters=ALL    filter_by=${FILTER_BY}    mo_names=${MO_NAME}
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=today
    ...                              alias=${NETACT_NAME}
    Log to console    \n ${results}
    Should not be empty    ${results}

ORU SW upgrade
    [Arguments]    ${ORU_SW}    ${ORU_SW_version}
    Log to console    \n--RU SW version isn't compatible with vDU version hence upgrading--
    ${operation_id}=    Start SWM Operation    provision    ${DN}    package=${ORU_SW}    alias=${Netact_name}
    Sleep    600s
    ${status}=    Get Progress of SWM Operation    ${operation_id}    alias=${Netact_name}
    ${RU_SW_status}=    admindu.get_rmods_status    vdu_connection=${vdu_connection}    timeout=300    raw=True
    Log    ${RU_SW_status[0]['activeSwVersion']}
    Wait until keyword succeeds    15min    5sec    Check_vDU_Cell_status
    Should be equal as strings    ${RU_SW_status[0]['activeSwVersion']}    ${ORU_SW_version}
    Log to console    \n--ORU SW upgrade completed for build ${ORU_SW_version}--

Check ORU and vDU SW version and upgrade ORU
    ${VDU_data}=	admindu.get_vdu_state_data    vdu_connection=${vdu_connection}    raw=True

    ${trunk}=     Run Keyword And Return Status    Should Contain    ${VDU_data['softwareVersion']}    ${trunk_version}
    ${N-1}=     Run Keyword And Return Status    Should Contain    ${VDU_data['softwareVersion']}    ${branch_N-1_version}
    ${RU_SW_status}=    admindu.get_rmods_status    vdu_connection=${vdu_connection}    timeout=300    raw=True
    ${current_RU_SW}=    	Set Variable    ${RU_SW_status[0]['activeSwVersion']}
    Run Keyword If     ${trunk} and '${current_RU_SW}' != '${FJT_trunk_Build_version}'
    ...    ORU SW upgrade    ${FJT_trunk_Build}    ${FJT_trunk_Build_version}
    ...    ELSE IF     ${N-1} and '${current_RU_SW}' != '${FJT_branch_N-1_Build_version}'
    ...    ORU SW upgrade    ${FJT_branch_N-1_Build}    ${FJT_branch_N-1_Build_version}
    ...    ELSE IF     ${N-1} and '${current_RU_SW}' == '${FJT_branch_N-1_Build_version}'
    ...    Log to console    \n--RU SW version is compatible with the vDU version--
    ...    ELSE IF     ${trunk} and '${current_RU_SW}' == '${FJT_trunk_Build_version}'
    ...    Log to console    \n--RU SW version is compatible with the vDU version--

Get_active_alarms_vDU
    ${alarms_list}=    admindu.vdu_get_active_alarms    vdu_connection=${vdu_connection}    timeout=300    raw=True
    Log to console    ${alarms_list['alarms']}
    Should be empty    ${alarms_list['alarms']}

Check_For_Unexpected_Alarms
    [Arguments]    ${Active_alarm}
	${allowed_alarms}=    Expected_alarms
    ${unexpected_alarms} =    Evaluate    [alarm for alarm in ${Active_alarm} if alarm not in ${allowed_alarms}]
	Log to console    Unexpected alarms are:${unexpected_alarms}
    Run Keyword If    len(${unexpected_alarms}) > 0    Fail    Unexpected alarms detected: ${unexpected_alarms}

Validate Alarms
    ${current_alarms} =    Create List    ${allowed_alarm_1}    ${allowed_alarm_2}    ${unexpected_alarm}
    Check For Unexpected Alarms    ${current_alarms}

Expected_alarms
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654
    ...     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649
    ...     fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655
    ...     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652
    ...     fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641
    ...     fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592
    ...     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000
    ...     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}   Create alarm    alarm_id=7102     fault_id=49
    ...     fault_name=Cell blocked
    ${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740
    ...     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}
    ...    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...    ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}
    ...    ${allowed_alarm_9}  #${allowed_alarm_10}
    [Return]    ${allowed_alarms}

Create alarm
    [Arguments]    ${alarm_id}    ${fault_id}    ${fault_name}
    ${alarm}=    Create Dictionary    alarm_id=${alarm_id}    fault_id=${fault_id}    fault_name=${fault_name}
    [Return]    ${alarm}

Default_NetConf_Provision
    Log to console    \n--CU As cell is not on air, proceeding with default netconf credentials provisioning--\n
    ${ssh_alarm}=    Get_active_alarms_vDU
	${alarms}=    Get From Dictionary    ${ssh_alarm}    alarm
	FOR    ${alarm}    IN    @{alarms}
        ${fault_id}=    Get From Dictionary    ${alarm}    fault_id
        IF    '${fault_id}' == '4641'
	        Import_SSDRAML   ${RAML_PATH_Add_Default_NETCONFAC}
            Provision_SSDRAML    ${DN}
            Wait Until Keyword Succeeds    15 times    20s    Check vDU Cell status
        END
    END


Import_SSDRAML
    [Arguments]    ${input_file}
	LOG    Importing SSDRAML File is in progress
    ${import_status}=    NMS.import_ssd    input_file=${input_file}    file_format=RAML2    overwrite=True    alias=${NETACT_NAME}
	sleep    60s
	Run Keyword If    '${import_status["message"]}' == 'SSD import successfully completed'     LOG    ${import_status["message"]}
    ...     ELSE    fail    SSD import failed

Provision_SSDRAML
    [Arguments]    ${Scope}
	LOG    Starting SSDRAML provisioning process
    ${Provision_Status}=    NMS.provision_ssd    scope=${Scope}    timeout=300    alias=${NETACT_NAME}
	sleep    120s
	LOG    ${Provision_Status}
    Run Keyword And Ignore Error    LOG    ${Provision_Status['additionInfo'[0]['failureReason']]}
	Run Keyword And Ignore Error    LOG    ${Provision_Status['additionInfo'[0]['status']]}
	Run Keyword And Ignore Error    LOG    ${Provision_Status['message']}
    Run Keyword And Ignore Error    LOG    ${Provision_Status['status']}
    [Return]    ${Provision_Status}

Delete_SSDRAML
    [Arguments]    ${Scope}
	LOG    Starting SSDRAML Deletion process
	Nms.delete_ssd    scope=${Scope}    delete_any_mo=True    alias=${NETACT_NAME}
	LOG    SSDRAML Deletion process Completed
    sleep    60s

Load wrong netconf credentials
    Log to console    \n--Loading wrong netconf credentials--
    ${wrong_credentials}=    Evaluate    ${wrong_netconf_credentials}
    ${result}=    admindu.add_netconf_accounts    accounts_info=${wrong_credentials}
	...    timeout=60    vdu_connection=${vdu_connection}

Load correct netconf credentials
    Log to console    \n--Loading correct netconf credentials--
    ${correct_credentials}=    Evaluate    ${correct_netconf_credentials}
    ${result}=    admindu.add_netconf_accounts    accounts_info=${correct_credentials}
	...    timeout=60    vdu_connection=${vdu_connection}

Assert alarm active
    Log to console    \n--Assert alarm active--
    ${alarms}=    admindu.vdu_get_active_alarms    timeout=120    vdu_connection=${vdu_connection}
    Log to console    \n${alarms['alarms'][0]['fault_name']}
    Should be equal as strings    ${alarms['alarms'][0]['fault_name']}    SSH client authentication failure
    Log to console    \n--Fault Id 4641 is active--

Extract netconf from snapshot
    os.Copy file    ${out}/Snapshot_vDU/Snapshot_*.zip    ${out}/Snapshot_vDU/Snapshotfile.zip
    @{getWithoutFilerValue}=     snapshotGetWithoutFilter    Snapshotfile.zip    ${out}/Snapshot_vDU/    RMOD_L-1_NetconfRpcMessageTrace
    log     ${getWithoutFilerValue}[0]
    log     ${getWithoutFilerValue}[1]
    log     ${getWithoutFilerValue}[2]
    ${netconf_file_path}=    String.Replace string    ${getWithoutFilerValue}[2]    results//    results/
    Extract
   	...    path=${netconf_file_path}
   	...    output_dir=${out}
   	...    .=*.log
    ${netconf_filename}=    os.List Files In Directory    ${out}    *_NetconfRpcMessageTrace.log
    Log to console    \n--Netconf filename is: ${netconf_filename}[0]--
    os.Copy file    ${out}/${netconf_filename}[0]    ${out}/RMOD_L-1_NetconfRpcMessageTrace.log

snapshotFileIdentifier
    @{getWithoutFilerValue}=    snapshotFileIdentifier.snapshotGetWithoutFilter
    ...    filename=${out}/Snapshotfile.zip
    ...    path=${out}
    ...    fileToBeChecked=NetconfRpcMessageTrace
    [Return]    @{getWithoutFilerValue}

Validate netconf log
    [Arguments]    ${netconf_file_path}    ${netconf_file}
    ${a}=    validate_netconf_reply_message      ${netconf_file_path}/${netconf_file}    ${rpc_get}    ${rpc_reply}    ${subtag}
    run keyword and continue on failure   Should not be empty    ${a}
    Log to console    \n--Netconf log validation completed--

CB008967-F-CR_Verification of kpialarmtrigger for RMOD Temperature counters_O-RU Counters_O_RAN_RADIO_TEMPERATURE
    Perform Parameter Recommissioning    ${distname_featcadm}    ${parameter_actkpi}    ${value_actkpi}
    Perform Parameter Recommissioning    ${distname_pmmnl}    ${miOranEpeStats_name}    ${windowStatsValue}
    Perform delta commissioning for kpialarmtrigger for all temperatures    ${delta_file_for_Temps_activate}
    sleep    200s    #Delay is needed after commissioning so sleep is given 200s
    ${alarm_info}=    ActiveAlarms
    ${faults_length}=    Get Length    ${faults}
    Log to console    ${alarm_info['alarms']}
    FOR    ${i}    IN RANGE    ${faults_length}
        ${fault_id}=    Get From Dictionary    ${alarm_info['alarms'][${i}]}    fault_id
        List Should Contain Value    ${faults}    ${fault_id}
    END
    Perform delta commissioning for kpialarmtrigger for all temperatures    ${delta_file_for_Temps_deactivate}
    ${alarms_cleared}=     ActiveAlarms
    ${alarms_length} =    Get Length    ${alarms_cleared}[alarms]
    FOR    ${i}    IN RANGE    ${alarms_length}
         ${fault_id}=    Get From Dictionary    ${alarms_cleared['alarms'][${i}]}    fault_id
         List Should Not Contain Value    ${faults}    ${fault_id}
    END

Perform Parameter Recommissioning
    [Arguments]    ${parameter_dist_name}    ${parameter_name}     ${value}
    admindu.perform_parameter_recommissioning
    ...    dist_name=${parameter_dist_name}
    ...    parameter=${parameter_name}
    ...    operation=${operation_value}
    ...    value=${value}
    ...    should_activate=${value_true}
    ...    timeout=300
    ...    vdu_connection=${vdu_connection}

Perform delta commissioning for kpialarmtrigger for all temperatures
    Log to console    Temperature counter related formulas are commissioned in kpiAlarmTriggers
    [Arguments]    ${delta_file_for_Temps}
    admindu.perform_delta_recommissioning    delta_file=${delta_file_for_Temps}   timeout=300   wait_for_completion=True    vdu_connection=vDU
    Log to console    Delta commissioning completed for kpiAlarmTriggers

ActiveAlarms
    ${alrdata}=    admindu.vdu_get_active_alarms    timeout=300
    ...    vdu_connection=vDU
    log    ${alrdata}
    [Return]    ${alrdata}

CB010797-D_RF-Diagnostic_CLI
    [Documentation]    Verification of RF Diagnostic Functionality along with UL/DL Data
    [Tags]  TC1
    Log to console    \n--TestCase Execution Started--\n
    Check vDU Cell status
    Attach UE and Start UL Data transfer
    RFDiagnosticsTest along with verification
    Stop UL Data transfer
    Log to console    \n--TestCase Execution Done--\n

CB010797-E_Antenna Line Online Monitoring
    [Documentation]    Verification of ALM Functionality along with UL/DL Data Post VDU restart
    [Tags]  TC2
    Log To Console    \n--TestCase Execution Started--\n
    ResetVdu
    Wait until keyword succeeds    15min    10s    Check vDU Cell status
    Setup_VDU
    Attach UE and Start UL Data transfer
    Start Antenna Monitoring & Verify ETP & RTWP
    Stop UL Data transfer

RFDiagnosticsTest along with verification
    ${trigger}=      admindu.start_rf_diagnostic_test
        	 ...     nr_cell_id=1
        	 ...     act_remote_rf_diag=True
        	 ...     rx_antenna_rssi_high_threshold=-30
        	 ...     rx_antenna_rssi_low_threshold=-110
	         ...     tx_antenna_vswr_high_threshold=3
	         ...     rx_antenna_rtwp_high_threshold=0
		     ...     rx_antenna_rtwp_low_threshold=0
		     ...     timeout=240
		     ...     vdu_connection=${vdu_connection}

    ${result}=       admindu.get_diagnostic_rf_diagnostic_test_results
    		     ...     timeout=60
    		     ...     vdu_connection=${vdu_connection}

    ${len}=    Get Length    ${result['rf_diagnostic_test_results']}
    FOR    ${k}    IN RANGE    ${len}
        Run Keyword And Ignore error    Exit For Loop If    ${nr_cell_id} == ${result['rf_diagnostic_test_results'][${k}]['nr_cell_id']}
        ${antenna_details}=    Copy List    ${result['rf_diagnostic_test_results'][${k}]['general_test_info']['detailed_result']}
        ${nr_cell_id}=    Set Variable    ${result['rf_diagnostic_test_results'][${k}]['nr_cell_id']}
        FOR    ${i}    IN RANGE    0    4
            Log to console    \n${antenna_details[${i}]['rtwp']}
            ${rtwp}=    Set Variable    ${antenna_details[${i}]['rtwp']}
            ${rssi}=    Set Variable    ${antenna_details[${i}]['rssi_dbm']}
            ${sinr}=    Set Variable    ${antenna_details[${i}]['sinr_db']}
            Should be true    ${rtwp} >= ${rtwp_min} and ${rtwp} <= ${rtwp_max}
            Should be true    ${rssi} >= ${rssi_min} and ${rssi} <= ${rssi_max}
            Should be true    ${sinr} >= ${sinr_min} and ${rssi} <= ${sinr_max}
        END
    END

Convert To Dict List & Verify ETP & RTWP
    [Arguments]    @{evaluated}

    # Step 2: Check it's a list of dicts
    ${is_list}=    Evaluate    isinstance(${evaluated}, list)
    ${all_dicts}=    Evaluate    all(isinstance(item, dict) for item in ${evaluated})
    IF    '${is_list}' == 'False' or '${all_dicts}' == 'False'
        Fail    Parsed data is not a list of dictionaries
    END

    # Step 3: Copy items to true Robot list using quoted index access
    @{temp_result}=    Create List
    FOR    ${item}    IN    @{evaluated}
        ${is_dict}=    Evaluate    isinstance(${item}, dict)
        IF    not ${is_dict}
            ${item}=    Evaluate    __import__('ast').literal_eval(${item})
        END

        ${is_now_dict}=    Evaluate    isinstance(${item}, dict)
        IF    not ${is_now_dict}
            Fail    Item is not a dictionary: ${item}
        END

        Append To List    ${temp_result}    ${item}
    END

    # Step 4: Log non-VSWR
    FOR    ${item}    IN    @{temp_result}
        ${type}=    Get From Dictionary    ${item}    measurementType
        IF    '${type}' != 'VSWR'
        # TO Do As per Requiremenet using Dictionary and values....
            Validate ALM Measurement Item    ${item}
        END
    END
    [Return]    ${temp_result}

Validate ALM Measurement Item
    [Arguments]    ${item}

    # Step 1: Convert to dict if it's still a string
    ${is_dict}=    Evaluate    isinstance(${item}, dict)
    IF    not ${is_dict}
        ${item}=    Evaluate    __import__('ast').literal_eval(${item})
    END

    # Step 2: Get type and measurements
    ${type}=    Get From Dictionary    ${item}    measurementType
    ${measurements}=    Get From Dictionary    ${item}    measurements

    # Step 3: Validate based on type
    IF    '${type}' == 'RTWP'
        FOR    ${m}    IN    @{measurements}
            ${value}=    Get From Dictionary    ${m}    value
            ${float_val}=    Evaluate    float(${value})
#            IF  -110 =< ${float_val} >= -80
            IF    ${float_val} >= -80 and ${float_val} <= -110
                Fail    RTWP value too high: -110 =< ${float_val} >= -80
            END
        END
    ELSE IF    '${type}' == 'ETP'
        FOR    ${m}    IN    @{measurements}
            ${value}=    Get From Dictionary    ${m}    value
            ${float_val}=    Evaluate    float(${value})
            IF    ${float_val} != 10000.0
               IF  ${float_val} >= 180 and ${float_val} <= 195
                    Fail    ETP value too low: ${float_val} (IF  195 => ${float_val} <= 180 or == 10000)
                END
            END
        END
    END

Start Antenna Monitoring & Verify ETP & RTWP
    ${trigger}=    admindu.start_antenna_monitoring    antennas=@{list}    vdu_connection=${vdu_connection}
    Sleep    20s
    admindu.stop_antenna_monitoring    monitor_id=${1}    vdu_connection=${vdu_connection}
    @{result}=    admindu.get_antenna_monitoring_results    monitor_id=${1}    vdu_connection=${vdu_connection}
    Convert To Dict List & Verify ETP & RTWP      @{result}

Attach UE and Start UL Data transfer
    ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Log to console    \nData transfer started
    ta_ultracaller.start_datatransfer   ${UE_alias}     ${data_transfer_protocol}     direction=@{direction_ul}

Stop UL Data transfer
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Log to console    \nData transfer completed
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Run Keyword And Ignore error    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
    ...     thrughtput=${throughput_ul}    deviation=${deviation_ul}

Test Predefine RU Configuration
    Log to Console    \n---CB007518-B:Connected Predefined Radio---\n
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    prodCodePlanned    TA08029-B311/01
    Wait until Keyword succeeds    5m    20s    Fetch_predefined_status    false    unchanged    true
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/MNL-1    autoInstallOfPredefinedRu    false
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    predefined    true
    Wait until Keyword succeeds    5m    20s    Fetch_predefined_radio_cell_status    enabled    on line    disabled    off line
    Wait until Keyword succeeds    5m    20s    Check_total_alarms_on_predefined_radio    ${0}
    Log to Console    \n---CB007518-B:Disconnected Predefined Radio---\n
    pdu.power_off    port=${portnum}    pdu_device=RRB
    Wait until Keyword succeeds    5m    20s    Check_total_alarms_on_predefined_radio    ${1}
    Wait until Keyword succeeds    5m    20s    Fetch_predefined_status    true    changed    false
    Wait until Keyword succeeds    5m    20s    Fetch_predefined_radio_cell_status    disabled    not installed    disabled    off line
    Log to Console    \n---CB007518-B:Connected Predefined Radio---\n
    pdu.power_on    port=${portnum}    pdu_device=RRB
    Wait until Keyword succeeds    10m    20s    Fetch_predefined_radio_cell_status    enabled    on line    disabled    off line
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/MNL-1    autoInstallOfPredefinedRu    true
    Wait until Keyword succeeds    10m    20s    Fetch_predefined_radio_cell_status    enabled    on line    enabled    on line
    Wait until Keyword succeeds    5m    20s    Fetch_predefined_status    false    unchanged    true
    Wait until Keyword succeeds    5m    20s    Check_total_alarms_on_predefined_radio    ${0}
    Log to Console    \n---CB007518-C:Incorrect SerialNumber to Raise FID:4282---\n
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    serialNumberPlanned    ${incorrectSNO}
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    predefined    true
    Wait until Keyword succeeds    5m    20s    Check_total_alarms_on_predefined_radio    ${1}
    Perform_Parameter_Recommissioning_vDU     ${mrbtsid}/EQM-1/APEQM-1/${rmod_id}    serialNumberPlanned    ${correctSNO}
    Wait until Keyword succeeds    10m    20s    Check_total_alarms_on_predefined_radio    ${0}
    Wait until Keyword succeeds    10m    20s    Fetch_predefined_status    false    changed    true
    Wait until Keyword succeeds    10m    20s    Fetch_predefined_radio_cell_status    enabled    on line    enabled    on line
    Wait until keyword succeeds    10m    10s    Check vDU Cell status

Perform_Parameter_Recommissioning_vDU
    [Arguments]    ${dist_name}      ${parameter}     ${value}
    admindu.perform_parameter_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    vdu_connection=vDU
    ...    operation=update
    ...    timeout=120
    ...    should_activate=true

Fetch_predefined_status
    [Arguments]      ${predefinedstate}    ${autoinstallvaluechange}     ${stateofautoinstallparam}
    ${pred_value}=    admindu.search_parameter_of_current_plan    mo_dn=${mrbtsid}/EQM-1/APEQM-1/${rmod_id}
    ...    para_name=predefined    timeout=30    vdu_connection=vDU
    run keyword and continue on failure    should contain    ${pred_value}     ${predefinedstate}
    ${autoinstallvalue}=    admindu.get_managed_object_parameters_of_current_plan     dist_name=${mrbtsid}/MNL-1
    ...       timeout=30     vdu_connection=vDU
    run keyword and continue on failure    should contain
    ...    ${autoinstallvalue}[parameters][1][simple_parameter][name]    autoInstallOfPredefinedRu
    run keyword and continue on failure    should contain
    ...    ${autoinstallvalue}[parameters][1][simple_parameter][state]     ${autoinstallvaluechange}
    run keyword and continue on failure    should contain
    ...    ${autoinstallvalue}[parameters][1][simple_parameter][value]    ${stateofautoinstallparam}

Fetch_predefined_radio_cell_status
    [Arguments]      ${radioOPstate}    ${radioAVLstate}    ${cellopstate}    ${cellavailstate}
    ${rmodstatus}=    admindu.get_rmods_status    timeout=30    vdu_connection=vDU
    run keyword and continue on failure    should contain    ${rmodstatus}[0][availability_status]    ${radioAVLstate}
    run keyword and continue on failure    should contain    ${rmodstatus}[0][operational_state]    ${radioOPstate}
    FOR    ${cellid}    IN    @{cells}
        ${cellstatus}=    admindu.get_cell_specific_info     cell_id=${cellid}     timeout=30     vdu_connection=vDU
        run keyword and continue on failure    should contain    ${cellstatus}[basicCell][operationalState]    ${cellopstate}
        run keyword and continue on failure    should contain    ${cellstatus}[availabilityStatus]    ${cellavailstate}
    END

Check_total_alarms_on_predefined_radio
    [Arguments]    ${numAlarm}
    ${alarmsinfo}=    admindu.vdu_get_active_alarms    timeout=30    vdu_connection=vDU
    ${totalalarms}=     Convert to String    ${alarmsinfo}[total]
    Should be True    "${totalalarms}"=="${numAlarm}"
    IF    "${totalalarms}">"${0}"
        FOR    ${i}   IN RANGE    ${totalalarms}
            ${fault_id}=    Convert to String    ${alarmsinfo}[alarms][0][fault_id]
            run keyword and continue on failure    should contain any    ${fault_id}    @{fault_list}
        END
    END