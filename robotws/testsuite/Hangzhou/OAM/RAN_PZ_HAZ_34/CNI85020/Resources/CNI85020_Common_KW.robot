*** Settings ***
Documentation
...    author:
...    contact:
...    Description:

Library  taf.selenium.sbts    WITH NAME    selenium_coam
Library  taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     taf.transport.ssh    WITH NAME    csn
Library    SSHLibrary    WITH NAME    ssh_lib
Library   OperatingSystem

Resource            ../../common/coam_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010636/Resources/CB010636_CDE.robot

*** Variables ***
${connection}    COAM
${OAM_HOST}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${asib_addr}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asib_username}             ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asib_password}             ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${UE_TYPE}    qct_dx50
${ue_index}    ${0}
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_api_port}             ${tl.attenuator[0].port}

##### Lss config #####
${lssIPaddress}    10.57.155.89
${lssPortNo}       22
${LSS_USER}    coam
${LSS_PASSWORD}    djsd@3T2yyUwewe!

*** Keywords ***
Make L3 Call
    [Arguments]    ${UE_TYPE}=${UE_TYPE}    ${dltp}=${100}    ${ultp}=${10}    ${4G_check}=${False}
    ...    ${ue_index}=${0}
    Log To Console    \n ### Prepare UE ###
    Log To Console    \n ### parameter ${dltp} and ${ultp} is not used  ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    Log To Console    \n ###UE Start traffic ###
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=50M    duration=60
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=200M    duration=60

Make Spark Attach
    [Arguments]    ${attach_mode}=${attach_mode}    ${UE_MODE}=${UE_MODE}    ${nettpye}=${nettype}
    ...    ${apn_address}=${apn_address}    ${ue_index}=${0}
    Run keyword and ignore error     power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${UE_TYPE}
        ...    get_spark_license=${False}
    log to console       configure UE${ue_index} mode
    Run keyword and ignore error      spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${ue_index}
    log to console       Attach UE${ue_index} and Verify Status
    Run keyword and ignore error     Attach UE and verify Status  ue_index=${ue_index}
        ...    attach_mode=${attach_mode}
    sleep    3s
    Run keyword and ignore error     Start Spark Traffic    ue_index=${ue_index}
        ...     attach_mode=${attach_mode}    ue_mode=${ue_mode}    nettpye=${nettpye}   apn_address=${apn_address}
    sleep    10s

Attach UE and verify Status
    log to console       UE attach
    [Arguments]    ${attach_mode}   ${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${UE_TYPE}   attach_mode=${attach_mode}
    log to console       UE attach verify
    sleep   5s
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False

Start Spark Traffic
    log to console       Start Traffic
    [Arguments]    ${ue_index}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}
    log to console       parameter ${attach_mode} and ${nettpye} is not used
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul      apn_address=${apn_address}
    ...    throughput=${data_tranfer}    duration=4000    ue_type=${UE_TYPE}    ue_mode=${ue_mode}    protocol=UDP
    sleep    3s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=4000   ue_type=${UE_TYPE}    ue_mode=${ue_mode}

stop traffic and ue detach
    [Arguments]    ${UE_MODE}=${UE_MODE}   ${apn_address}=${apn_address}    ${ue_index}=${0}
    log to console     Stop traffic    console = yes
    Run keyword and ignore error     power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
    Run keyword and ignore error     power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
	...    apn_address=${apn_address}
    log to console      UE Detach    console = yes
    Run keyword and ignore error     power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${ue_index}

Config Trigger Event On BBMod
    [Arguments]  ${loki_select}=asp-5b     ${Event_type}=L1_UL
    #csn.Connect to   hostname=${asib_addr}   username=${asib_username}   password=${asib_password}    alias=gnb
    ${pre_command}    set variable     ssh toor4nsn@${loki_select} -o StrictHostKeyChecking=no
    ssh_lib.Open Connection  host=${asib_addr}
    ssh_lib.Login  username=${asib_username}  password=${asib_password}
    ssh_lib.Write     text=${pre_command}
    ssh_lib.Read Until      expected=password:
    ssh_lib.Write     text=oZPS0POrRieRtu
    ssh_lib.Read Until      expected=:~#
    ssh_lib.Write     text=confmgmtbrowser write CommonPhy enableAutoSnapshot${SPACE}1
    ssh_lib.Write     text=confmgmtbrowser read CommonPhy enableAutoSnapshot
    ssh_lib.Write     text=confmgmtbrowser write CommonPhy minutesToTrigAutoBTSSnapshot${SPACE}16
    ssh_lib.Write     text=confmgmtbrowser read CommonPhy minutesToTrigAutoBTSSnapshot
    ssh_lib.Write     text=confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot${SPACE}1
    ssh_lib.Write     text=confmgmtbrowser read CommonPhy nbOfEventsToTrigAutoBTSSnapshot
    Run Keyword If    '${Event_type}'=='L1_UL'    ssh_lib.Write
    ...    text=/usr/lib64/python/antenna_snapshot_config.py --nrevent EPhyEvent_PuschSnapshotVerification
    ...    ELSE IF    '${Event_type}'=='L2'    ssh_lib.Write
    ...    text=/usr/lib64/python/antenna_snapshot_config.py --nrevent EPhyEvent_L2EventVerification
    ...    ELSE    Run keywords    ssh_lib.Write    text=confmgmtbrowser write NrDlPhy dlPhyEventEnable${SPACE}3
    ...    AND
    ...    ssh_lib.Write    text=confmgmtbrowser write NrDlPhy dlPhyCaptureTriggerTypeSpecificValue${SPACE}2
    #[Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb



Connect coam to LSS
    [Documentation]
    ...  Establish connection to LSS via SSH
    csn.Connect To
    ...    hostname=${lssIPaddress}
    ...    username=${LSS_USER}
    ...    password=${LSS_PASSWORD}
    ...    alias=LSS

delete snapshot files in LSS
    Connect coam to LSS
    log to console    connect to LSS done
    csn.execute    command=rm -rf /home/ute/coam/*    connection=LSS
    [Teardown]    csn.disconnect    connection=LSS

Check existence of remote snapshot
    [Arguments]    ${host}=${lssIPaddress}     ${user}=${LSS_USER}    ${pass}=${LSS_PASSWORD}     ${dir}=/home/ute/coam/
    ssh_lib.Open Connection   ${host}
    ssh_lib.Login    ${user}    ${pass}
    ${FileList}=    ssh_lib.List Directory    ${dir}
    log    ${FileList}
#    ${whole_name_lss}    check if snapshot name is defined for lss
#    Should Contain Match    ${FileList1}    ${whole_name_lss}
    Should Contain Match    ${FileList}    Snapshot_${mrbtsId}*

Check Bip Contained
    Connect coam to LSS
    ${value}    csn.execute    command=cd /home/ute/coam/Snapshot_${mrbtsId}*/ ; cat snapshot_file_list.txt    connection=LSS
    should contain    ${value}    mirroring
    [Teardown]    csn.disconnect    connection=LSS

Local Collect snapshot coam And Check
    [Timeout]   30m
    [Arguments]   ${local_file_path}=None   ${connection}=COAM
    Run    rm -rf /home/ute/snapshot/*
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${local_file_path}   Set Variable If
    ...   '${local_file_path}'=='None'   ${OUTPUT_DIR}/snapshot_coam_${curr_data}.zip
    ...   ${true}   ${local_file_path}
    Run Keyword And Ignore Error   admin_cli.collect_snapshot   target_file_name=${local_file_path}   timeout=${2100}   connection=${connection}
    Run    mkdir /home/ute/snapshot
    ${snapshot_extract}    Set Variable    /home/ute/snapshot
    Run    unzip -o ${local_file_path} -d ${snapshot_extract}
    ${value}    Run    cat /home/ute/snapshot/snapshot_file_list.txt
    should contain    ${value}    mirroring
    #[Return]   ${snapshot_extract}

Start Parallel L1-L2 Mirroring From WEBUI
    [Arguments]    ${ul}=@{ul}    ${dl}=@{dl}
    taf_coam.COAM WEBUI LOGIN   version=SBTS23R3    display=${false}
	#@{ul}    Create List    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
	#@{dl}    Create List    [BBMOD_R-1(ABIN)] [PCI: 112]NRCELL-2: Subcell 1
    selenium_coam.configure_iq_capture    ul_subcell_index_list=${ul}    dl_subcell_index_list=${dl}
    ...    enable_capture_on_event=${True}
    selenium_coam.start_parallel_l1_l2_mirroring
    [Teardown]  taf_coam.COAM WEBUI Logout

Start Parallel L1-L2 Mirroring From cli
    [Arguments]  ${subcellId}=${0}    ${nrcellId}=${1}
    #wait until keyword succeeds     2s    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM
    Change Parameter    ${mrbtsId}/MNL-1/MNLENT-1/FEATCADM-1   actCli    update    true
    ${bbmod_dist_list}=    Get Runtime FBB info
    ${bbmod_dist}    set variable    ${bbmod_dist_list[0]}
    @{MO_list}    Split String    ${bbmod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    ${cell_dist}    set variable    ${runtime_info}/NRBTS_R-${nrbtsID}/NRCELL_R-${nrcellId}
    ${subcell_dict}=  Create dictionary  nrcellDN  ${cell_dist}
    ...                                  subcellId  ${subcellId}
    ${nr_ul_subcell_list}    Create List    ${subcell_dict}
    ${nr_dl_subcell_list}    Create List    ${subcell_dict}
    admin_cli.configure_uplane_l1_iq_data    module_dn=${bbmod_dist}    capture_on_event=True
    ...    dl_nr_subcell_list=${nr_dl_subcell_list}
    ...    ul_nr_subcell_list=${nr_ul_subcell_list}    connection=COAM
    admin_cli.interface_mirroring    operation=Start    parallel_mirroring=True    connection=${connection}
    #[Teardown]    admin_cli.teardown    connection=COAM

Stop BIP Log
    admin_cli.interface_mirroring    operation=Stop    connection=${connection}
    #admin_cli.collect_mirroring_logs    output_file_name=${CURDIR}/interface_mirroring.zip    connection=${connection}

Set mrbtsId variable
    Connect to gnb coam via ssl
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=GNB_OAM
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.srbts:MRBTS"]
    set suite variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}

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
    ...                                           connection=${connection}

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${lss_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=lss
    ...                connection=${connection}
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
    ...                                           connection=${connection}

config Auto Snapshot Trigger Fault
    [Arguments]      ${operation}=update
    ${fault_8101}=    Create Dictionary
    ...     faultNumber=8101
    ...     triggerType=onFaultDetection
     @{list}=    create list    ${fault_8101}
    coam.perform_parameter_recommissioning        dist_name=${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=${operation}
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Config LSS parameters
    Change Parameter    ${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1   actDefaultFaultSnapTriggers    update    true
    Change Parameter    ${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1   diagSnapDestination    update    lss
    Perform lssConfig complex parameter activation    lssIPaddress=${lssIPaddress}    lssPortNo=${lssPortNo}

Config LSS User and Password
    [Arguments]    ${new_user}=${LSS_USER}   ${new_password}=${LSS_PASSWORD}
    #${new_user_encode}    Encode    ${new_user}
    #${new_password_encode}    Encode    ${new_password}
    #${request_data}    Set Variable    {"username":"${new_user}","password":"${new_password}"}
    #${ret}    Run Process    curl    https://${OAM_HOST}/api/asm/v1/account/users/lss    -k    -X    PATCH    -H    Accept: application/json
    #...    -H    Authorization: Bearer ${token}    -H    Content-Type: application/json
    #...    --data-binary    ${request_data}
    admin_cli.configure_lss_account    lss_username=${new_user}    lss_password=${new_password}    connection=${connection}

Get Runtime FBB info
    [Arguments]     ${connection}=COAM
    ${FBB_output}=    admin_cli.Get Fbb Info    connection=${connection}
    Log Many    ${FBB_output}
    ${runtime_bbmod_list}  create list
    FOR    ${item}    IN    @{FBB_output}
        append to list    ${runtime_bbmod_list}    ${item['id']['internal']}
    END
    [Return]    ${runtime_bbmod_list}

Check FID:${FID} Raised
    ${FID}    Convert To Integer    ${FID}
    @{fault_list}    create list
    ${active_alarms}    admin_cli.get_active_alarms    connection=${connection}
    FOR    ${alarms}    IN    @{active_alarms}
        Append To List    ${fault_list}    ${alarms}[additionalFaultID]
    END
    should contain    ${fault_list}    ${FID}

Check None Unexpect Alarms
    ${bts_alarm}    admin_cli.Get Active Alarms 	  timeout=20    connection=${connection}
    should not contain    ${bts_alarm}    8101
    should not contain    ${bts_alarm}    6450

Precondition
    [Arguments]
	Run Keyword And Ignore Error    robot_common_operations.Common case setup
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check GNB cell on air    connection=${connection}
    Check None Unexpect Alarms
    Set mrbtsId variable

Teardown
    admin_cli.disable_uplane_l1_iq_capture    connection=${connection}
    admin_cli.teardown    connection=${connection}
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
