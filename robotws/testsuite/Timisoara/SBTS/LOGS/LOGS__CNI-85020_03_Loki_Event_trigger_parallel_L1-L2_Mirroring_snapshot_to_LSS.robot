*** Settings ***
Documentation
...    author: y6lu
...    contact: lu.yu@nokia-sbell.com
...    Description:

Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    taf.transport.ssh  WITH NAME  ssh
Resource   ../resources/pm_logs_frame.robot
Resource   ../resources/pm_logs_general.robot
Resource    ../resources/ssh_utils.robot
Resource   ../resources/verdicts.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/suppress.robot
Resource    ../resources/L3_call.robot

*** Variables ***
${connection}    COAM
${asib_addr}                 192.168.255.129
${asib_username}             toor4nsn
${asib_password}             oZPS0POrRieRtu
${BTS_ip}           192.168.255.129
${BTS_login}        toor4nsn
${BTS_password}     oZPS0POrRieRtu
${UE_TYPE}    qct_dx50
${ue_index}    ${0}
##### Lss config #####
${lssIPaddress}    10.5.20.200
${lssPortNo}       22
${LSS_USER}    coam
${LSS_PASSWORD}    zO&n1W*ktp7!

*** Keywords ***
TC__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    [Documentation]    *****************
    ...    The purpose of this test case is to verify that L2 event trigger Snapshot includes IQ samples and BIP in parallel to LSS.
    ...    *******************
    Step 0: Precondition
    Step 1: config RAD parameter
    Step 2: config LSS Parameters
    Step 3: Start Parallel L1-L2 Mirroring
    Step 4: Make L3 Call To Trigger Alarm
    Step 5: Check Logs

Step 0: Precondition
    Log     \nStep 0: Preconditions  console=${True}
    ${mrbtsId}     Get BTS ID
    Set Test Variable    ${mrbtsId}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${nrbtsID}  ${btsInfo['nrBtsId']}

Step 1: config RAD parameter
    Log     \nStep 1: config RAD parameter     console=${True}
    Config Trigger Event On BBMod

Step 2: config LSS Parameters
    Log     \nStep 2: config LSS Parameters           console=${True}
    Config LSS parameters
    Config LSS User And Password
    config Auto Snapshot Trigger Fault
    Configure NOTE to unhide suppressed faults    R5C6
#    delete snapshot files in LSS

Step 3: Start Parallel L1-L2 Mirroring
    Log    \nStep 3: Start Parallel L1-L2 Mirroring     console=${True}
    #Start Parallel L1-L2 Mirroring From WEBUI
    Start Parallel L1-L2 Mirroring From cli

Step 4: Make L3 Call To Trigger Alarm
    Log    \nStep 4: Make L3 Call To Trigger Alarm    console=${True}
    Make SA L3 Call
    log to console    Auto Snapshot time limited
    Wait Until Keyword Succeeds    1min    30s    Check FID:8101 Raised
    [Teardown]    coam.disable_uplane_l1_iq_capture    connection=${connection}

Step 5: Check Logs
    Log     \nStep 5: Check Logs     console=${True}
    Wait until keyword succeeds    1 min    30s    Check existence of remote snapshot
    Wait until keyword succeeds    5 min    30s    Check Bip Contained

Config Trigger Event On BBMod
    [Arguments]  ${FSP_ID}=fsp-1-1c     ${Event_type}=L1_UL
#    ${loki_select}=fct-1-0b
    #csn.Connect to   hostname=${asib_addr}   username=${asib_username}   password=${asib_password}    alias=gnb
#    ${pre_command}    set variable     ssh toor4nsn@${loki_select} -o StrictHostKeyChecking=no
#    SSHLibrary.Open Connection  host=${asib_addr}
#    SSHLibrary.Login  username=${asib_username}  password=${asib_password}
#    SSHLibrary.Write     text=${pre_command}
#    SSHLibrary.Read Until      expected=password:
#    SSHLibrary.Write     text=oZPS0POrRieRtu
#    SSHLibrary.Read Until      expected=:~#
    SSHLibrary.Open Connection    ${BTS_ip}
    SSHLibrary.Login    ${BTS_login}    ${BTS_password}
    SSHLibrary.Write    > /user/${BTS_login}/.ssh/known_hosts
    SSHLibrary.Write    cat /user/${BTS_login}/.ssh/known_hosts
    Sleep    3s
    SSHLibrary.Read
    SSHLibrary.Write    ssh ${BTS_login}@${FSP_ID}
    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    yes    AND    Sleep    3s
    ${output}=    SSHLibrary.Read
    Run Keyword If    "Password:" in """${output}"""
    ...    Run Keywords    SSHLibrary.Write    ${BTS_password}    AND    Sleep    5s
    Sleep    5s
    SSHLibrary.Write     text=confmgmtbrowser write CommonPhy enableAutoSnapshot${SPACE}1
    SSHLibrary.Write     text=confmgmtbrowser read CommonPhy enableAutoSnapshot
    SSHLibrary.Write     text=confmgmtbrowser write CommonPhy minutesToTrigAutoBTSSnapshot${SPACE}16
    SSHLibrary.Write     text=confmgmtbrowser read CommonPhy minutesToTrigAutoBTSSnapshot
    SSHLibrary.Write     text=confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot${SPACE}1
    SSHLibrary.Write     text=confmgmtbrowser read CommonPhy nbOfEventsToTrigAutoBTSSnapshot
    Run Keyword If    '${Event_type}'=='L1_UL'    SSHLibrary.Write
    ...    text=/usr/lib64/python/antenna_snapshot_config.py --nrevent EPhyEvent_PuschSnapshotVerification
    ...    ELSE IF    '${Event_type}'=='L2'    SSHLibrary.Write
    ...    text=/usr/lib64/python/antenna_snapshot_config.py --nrevent EPhyEvent_L2EventVerification
    ...    ELSE    Run keywords    SSHLibrary.Write    text=confmgmtbrowser write NrDlPhy dlPhyEventEnable${SPACE}3
    ...    AND
    ...    SSHLibrary.Write    text=confmgmtbrowser write NrDlPhy dlPhyCaptureTriggerTypeSpecificValue${SPACE}2
    Sleep     15s
    SSHLibrary.Close Connection

Config LSS parameters
    Change Parameter    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1   actDefaultFaultSnapTriggers    update    true
#    Change Parameter    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1   diagSnapDestination    update    lss
    Set Snapshot Destination To  LSS
#    Perform lssConfig complex parameter activation    lssIPaddress=${lssIPaddress}    lssPortNo=${lssPortNo}

Config LSS User and Password
    [Arguments]    ${new_user}=${LSS_USER}   ${new_password}=${LSS_PASSWORD}
    coam.configure_lss_account    lss_username=${new_user}    lss_password=${new_password}    connection=${connection}

config Auto Snapshot Trigger Fault
    [Arguments]      ${operation}=update
    ${fault_8101}=    Create Dictionary
    ...     faultNumber=8101
    ...     triggerType=onFaultDetection
     @{list}=    create list    ${fault_8101}
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=${operation}
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

delete snapshot files in LSS
    Connect coam to LSS
    log to console    connect to LSS done
    ssh.execute    command=rm -rf /home/ute/coam/*    connection=LSS
    [Teardown]    ssh.disconnect    connection=LSS

Start Parallel L1-L2 Mirroring From cli
    [Arguments]  ${subcellId}=${0}    ${nrcellId}=${21}
    #wait until keyword succeeds     2s    1s
    #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    #...      username=Nemuadmin
    #...      password=nemuuser
    #...      name=COAM
    Change Parameter    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/FEATCADM-1   actCli    update    true
    ${bbmod_dist_list}=    Get Runtime FBB info
    ${bbmod_dist}    set variable    ${bbmod_dist_list[0]}
    @{MO_list}    Split String    ${bbmod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    ${cell_dist}    set variable    ${runtime_info}/NRBTS_R-${nrbtsID}/NRCELL_R-${nrcellId}
    ${subcell_dict}=  Create dictionary  nrcellDN  ${cell_dist}
    ...                                  subcellId  ${subcellId}
    ${nr_ul_subcell_list}    Create List    ${subcell_dict}
    ${nr_dl_subcell_list}    Create List    ${subcell_dict}
    coam.configure_uplane_l1_iq_data    module_dn=${bbmod_dist}    capture_on_event=True
    ...    dl_nr_subcell_list=${nr_dl_subcell_list}
    ...    ul_nr_subcell_list=${nr_ul_subcell_list}    connection=${connection}
    coam.interface_mirroring    operation=Start    parallel_mirroring=True    connection=${connection}

Connect coam to LSS
    [Documentation]
    ...  Establish connection to LSS via SSH
    ssh.Connect To
    ...    hostname=${lssIPaddress}
    ...    username=${LSS_USER}
    ...    password=${LSS_PASSWORD}
    ...    alias=LSS

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${lss_dict}=
    ...                coam.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=lss
    ...                connection=${connection}
    ${list_parameters}=    Get From Dictionary    ${lss_dict['lssConfig']}
    ...                                           lssIPaddress
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    coam.perform_parameter_recommissioning    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                           connection=${connection}

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    coam.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=${connection}

Get Runtime FBB info
    ${FBB_output}=    coam.Get Fbb Info    connection=${connection}
#    ${FBB_output}=    coam.Get Fsm Info    connection=${connection}
    Log Many    ${FBB_output}
    ${runtime_bbmod_list}  create list
    FOR    ${item}    IN    @{FBB_output}
        append to list    ${runtime_bbmod_list}    ${item['id']['internal']}
    END
    [Return]    ${runtime_bbmod_list}

Make SA L3 call
    [Arguments]  ${pci}=62    ${ue_id}=1
    Start UE SA Traffic  expected_pci=${pci}  ue_id=${ue_id}

Check FID:${FID} Raised
    ${FID}    Convert To Integer    ${FID}
    @{fault_list}    create list
    ${active_alarms}    coam.get_active_alarms    connection=${connection}
    FOR    ${alarms}    IN    @{active_alarms}
        Append To List    ${fault_list}    ${alarms}[additionalFaultID]
    END
    should contain    ${fault_list}    ${FID}

Check existence of remote snapshot
    [Arguments]    ${host}=${lssIPaddress}     ${user}=${LSS_USER}    ${pass}=${LSS_PASSWORD}     ${dir}=/home/ute/coam/
    SSHLibrary.Open Connection   ${host}
    SSHLibrary.Login    ${user}    ${pass}
    ${FileList}=    SSHLibrary.List Directory    ${dir}
    log    ${FileList}
#    ${whole_name_lss}    check if snapshot name is defined for lss
#    Should Contain Match    ${FileList1}    ${whole_name_lss}
    Should Contain Match    ${FileList}    Snapshot_MRBTS-${mrbtsId}*

Check Bip Contained
    Connect coam to LSS
    ${value}    ssh.execute    command=cd /home/ute/coam/Snapshot_MRBTS-${mrbtsId}*/ ; cat snapshot_file_list.txt    connection=LSS
    should contain    ${value}    mirroring
    [Teardown]    ssh.disconnect    connection=LSS

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
