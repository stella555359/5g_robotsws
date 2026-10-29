*** Settings ***
Documentation     This contains common keywords which are needed to run the Airphone TC.
...               :author Chandana M S
Library           ../Python/AdminHelper.py    WITH NAME    admin_helper
Library           ../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library           ../../Resources/Python/ORANOperations.py    WITH NAME    oran_operations
Library           ../../scripts/Runner/APGNBControl.py   WITH NAME   ap_gnb_control
Library           ../../scripts/Runner/TLEnvCleanup.py   WITH NAME   tl_env_cleanup
Library           taf.collectors.pmcounters    WITH NAME   gnb_pmcounters
Library           taf.analyzer.pmcounter    WITH NAME    pm_analyser
Resource          ute_setup.robot
Resource          gnb.robot
Resource          log.robot
Resource          airphone.robot
Resource          wts.robot
Library           ../Python/Utilities.py    WITH NAME    utilities

*** Variables ***
${TC_index}                   1
${AP_IP}                      192.168.200.1
${GNB_IP}                     192.168.255.129
${GUI_Username}               Nemuadmin
${GUI_Password}               nemuuser
@{Sim_Gnb_list_HO}            2    22    23    24    25
${Gnb_Revert}                 False
&{NgHo_Inter_Intra_params}    actIntraNrNgHo=sourceAndTarget    tNgRelocCancelN=2000    tNgRelocPrepN=2000
...                           tNgRelocOverallN=2000    tNgRelocExecDeltN=2000    suppCnPartialAdNgHo=true
&{NgHo_feature_param}         actIntraNrNgHo=sourceAndTarget
&{InterRAT_params}            actInterRatHoFromEutraToSA=true    actInterRatHoSA=true    actInterRatHoSADlDataForward=true
${profile_id}         1
${target_gnb}         2
${target_cells}       2
${bearer_id}          2
&{nrrel_params}               handoverAllowedSA=XnHoNotAllowed
${WTS_FILE}                   basic_setup.cfg
${WTS_BKUP_FILE}              basic_setup_backup.cfg
${mimomode_closed}            False
&{mimode_params}              dlMimoMode=2x2 Closed Loop Spatial Multiplexing
${bsr_path}                   /home/ute/workspace/bsr_package
${Need_custom_eth3}           False
${Need_custom_eth4}           False
${IS_ORAN}                    False

*** Keywords ***
Suite Common Keywords
    [Arguments]    ${feature_folder}=${EMPTY}
    Create Suite Log Collection Folder    ${feature_folder}
    Check And Kill admin API Process
    Set BTS ID and DIST_NAME
    Run Keyword And Ignore Error    Modify UTE Memory Size
    Run Keyword And Ignore Error    Get disk space and tmp content

Set BTS ID and DIST_NAME
    ${gnb_bts_id}    admin_helper.get bts id
    Set Global Variable    ${BTS_ID}    ${gnb_bts_id}
    Set Global Variable    ${NRBTS_DISTNAME}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set Global Variable    ${NRCELL_DISTNAME}    ${NRBTS_DISTNAME}/NRCELL-1
    Set Global Variable    ${PM_INTERVAL_DISTNAME}    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1

Reboot GNB and Airphone
    Reboot GNB
    Reboot Airphone UE

Common Test Teardown
    [Documentation]    This keyword is used to stop the tcpdump capture and WTS related process at the end of testcase
    ...                The logs which are collected by some of the keywords will be in the Test Log Folder
    ...                Modified Date: 16-03-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    [Arguments]    ${collect_sosreport_at_suite}=False
    Run Keyword And Continue On Failure    Check Alarms and AP_GNB crashes
    Run Keyword And Continue On Failure    Stop logs collected for debug
    WTS Teardown Keywords
    Run Keyword And Ignore Error    Stop pcap collection in gNB and WTS
    Run Keyword And Ignore Error    Get disk space and tmp content
    ap_gnb_control.log gnb crash logs
    ap_gnb_control.log airphone crash logs
    Collect SoSReport Log    ${collect_sosreport_at_suite}
    Run Keyword And Ignore Error    Get disk space and tmp content
    Run Keyword And Ignore Error    Remove Files from tmp on WTS VM
    Run Keyword And Ignore Error    Get disk space and tmp content

Check GNB Crash Logs
    ${crash_logs}=    ap_gnb_control.get_gnb_coredumper_logs
    Run Keyword And Continue On Failure    Run Keyword If     ${crash_logs}   FAIL    GNB crash logs found:\n${crash_logs}

Check AP Crash Logs
    ${crash_logs}=    ap_gnb_control.get_airphone_coredumper_logs
    Run Keyword And Continue On Failure    Run Keyword If     ${crash_logs}    FAIL    AP crash logs found:\n${crash_logs}

Check Alarms
    [Arguments]    ${fault_dict_before_test}    ${fault_dict_after_test}
    ${Additional_alarms}    utilities.find_additional_alarms    ${fault_dict_before_test}    ${fault_dict_after_test}
    Log to console     ${Additional_alarms}
    Run Keyword And Continue On Failure    Run Keywords    Run Keyword If    ${Additional_alarms}    Collect Screenshot
    ...    AND    Run Keyword If    ${Additional_alarms}    Fail    Additional alarms found:\n${Additional_alarms}

Check Alarms and AP_GNB crashes
    ${fault_dict_after_test}=    Run keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${fault_dict_before_test}    ${fault_dict_after_test}
    Check GNB Crash Logs
    Check AP Crash Logs
    Collect Screenshot

Get Alarms
    ${list_alarm}    Get Active Alarms
    ${fault_dict}    utilities.extract_faults    ${list_alarm}
    [Return]    ${fault_dict}

Remove Files from tmp on WTS VM
    [Documentation]    This keyword is used to remove files from /tmp so that the folder is not full.
    ...                Modified Date: 16-03-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run and return rc and output    rm -rf /tmp/*

WTS Teardown Keywords
    [Documentation]    This keyword is used to stop the WTS related process at the end of testcase
    ...                This is logs which are collected by some of the keywords will be in the Test Log Folder
    ...                Modified Date: 02-Jun-2020
    ...                Last Modified by: ramya.2.k@nokia.com
    Run Keyword And Ignore Error    Stop Sim
    Run Keyword If    '${WTS_ACTIVE}'=='True'    Run Keyword And Ignore Error    Collect EGATE Logs
    Run Keyword And Ignore Error    Teardown All Aliases For Wts
    Teardown Edaemon And Egate Process
    Check And Kill Simulator Process
    Check And Kill admin API Process

Common Suite Teardown Keywords
    [Documentation]    This keyword is for any actions that need to be performed at the end of a suite
    ...                Added the SoSReport log collection which is collected in the Suite Log Folder
    ...                Modified Date: 07-Aug-2020
    ...                Last Modified by: m.sangeetha@nokia.com
    Collect SoSReport Log

Reboot Airphone For Recovery
    [Documentation]   This Keyword will reboot Airphone and wait for it to come up. It will also check the ADET
    ...               on AP and retry the reboots for a maximum of 5 times and check if the ADET is up and GNB and
    ...               AP are Configured and Radio State is Installed.
    ...               Modified Date: 05-Jun-2020
    ...               Last Modified by: ashok.santhanam@nokia.com
    ap_gnb_control.Reboot AP And Recover

Reboot gNB To Clean Test Env
    [Documentation]   This Keyword will reboot gNB and wait for it to come up. It will also check the ADET
    ...               on AP and gNB. Retry the reboots for a maximum of 5 times and check if the ADET is up and GNB and
    ...               AP are Configured and Radio State is Installed.
    ...               Modified Date: 13-Nov-2021
    ...               Last Modified by: gopalakrishnan.n@nokia.com
    ap_gnb_control.Reboot gNB And Clean Env

Get disk space and tmp content
    Get disk space in component    ${AP_IP}
    Get disk space in component    ${GNB_IP}
    Get disk space in WTS

Get disk space in component
    [Arguments]    ${ip}
    Run and return rc and output    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${ip} 'df -hk'
    Run and return rc and output    sshpass -p ${NOKIA_PASS} ssh toor4nsn@${ip} 'ls -ltrh /tmp'

Get disk space in WTS
    Run and return rc and output    df -hk
    Run and return rc and output    ls -ltrh /tmp

Perform Cell delete and setup via dlMimoMode
    [Arguments]    ${NUMBER_OF_CELLS}    ${index}    ${gnb_id}=0    ${port}=3600    ${alias}=cOAM
    ...    ${msg_celldeleted}=Cell in state deleted    ${msg_cellready}=Cell in state ready
    Log To Console    Cell delete and setup via mimo_mode started
    Cell Delete and setup via open loop in dlMimoMode    ${gnb_id}    ${port}    ${alias}    ${NUMBER_OF_CELLS}
    Sleep    30s
    ${count_open}    Evaluate    int(${index} * 2 + 1)
    Check Egate Log With Message and count    msg_regexp=${msg_celldeleted}    count=${count_open}
    Check Egate Log With Message and count    msg_regexp=${msg_cellready}    count=${count_open}
    Cell Delete and setup via close loop in dlMimoMode    ${gnb_id}    ${port}    ${alias}    ${NUMBER_OF_CELLS}
    Sleep    60s
    ${count_close}    Evaluate    int(${index} * 2 + 2)
    Check Egate Log With Message and count    msg_regexp=${msg_celldeleted}    count=${count_close}
    Check Egate Log With Message and count    msg_regexp=${msg_cellready}    count=${count_close}

Collect Gnb PM Counters
    [Arguments]    ${target_dir}    ${name}=gnb_pm_counters    ${duration}=15 minutes
    Log To Console    Download gNB PM Counters
    ${webservice}=    Create Dictionary    host=${GNB_IP}    user=${GUI_Username}
    ...    password=${GUI_Password}    port=443
    gnb_pmcounters.create PM collector   name=${name}    webservice=${webservice}   for_last=${duration}
    gnb_pmcounters.setup_collectors    names=${name}
    gnb_pmcounters.collect_collectors    names=${name}    target_dir=${target_dir}
    [Teardown]    gnb_pmcounters.teardown_collectors    names=${name}

Validate Gnb PM Counters
    [Arguments]    ${sa_ue_list}    ${counters}    ${counters_dir}    ${name}    ${nsa_ue_list}=${EMPTY}
    ${expected_counter_value}    Run Keyword If    "${nsa_ue_list}" != "${EMPTY}"    Evaluate
    ...    len(${sa_ue_list})+len(${nsa_ue_list})    ELSE    Evaluate    len(${sa_ue_list})
    Set Test Variable    ${expected_counter_value}
    ${pm_counter_dir}=    Join Path    ${counters_dir}    ${name}
    ${counter_output}=    pm_analyser.get_pi_value    pi_list=${counters}    pi_dir=${pm_counter_dir}    pi_file_pattern=PM*
    ${non_empty_list}    Create List
    Set Test Variable    ${non_empty_list}
    Common Counter Interator    ${counter_output}    Get PM Counters
    Common Counter Interator    ${counters}    Verify PM counter Is Getting Incremented

Common Counter Interator
    [Arguments]    ${list_name}    ${Keyword_name}
    FOR    ${item}    IN    @{list_name}
        Run Keyword    ${Keyword_name}    ${item}
    END

Verify PM counter Is Getting Incremented
    [Arguments]    ${counter}
    FOR    ${element}    IN    @{non_empty_list}
        ${status}    Run Keyword and Return Status    Dictionary Should Contain Key    ${element}    ${counter}
        ${incr_values}    Run Keyword If    ${status}    Evaluate    ${element}.values()[0].values()
        ...    ELSE    Set Variable    Dictionary: ${element} doesnot have ${counter} counter key.
        Run Keyword If    ${status}    Run Keyword and Ignore Error    List Should Contain Value    ${incr_values}    ${expected_counter_value}
        ...    msg=PM counter:${counter} has not been incremented.
    END

Get PM Counters
    [Arguments]    ${pm_dict_out}
    ${pm_ouput_list}    Get Dictionary Items    ${pm_dict_out}
    FOR    ${key}    ${value}    IN    @{pm_ouput_list}
        ${dict_values}    Get Dictionary Values    ${value}
        ${len}    Get length    ${dict_values}[0]
        ${status}    Run Keyword and Return status    Should Be Equal As Integers    ${len}    0
        Continue For Loop If    ${status}
        Append To List    ${non_empty_list}    ${value}
    END

Test Setup For HO cases
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${simulator_gnb_list}=${Sim_Gnb_list_HO}    ${NGBased_HO}=False
    ...     ${interrat_ho}=False    ${ANR_IR}=False    &{kwargs}
    Check and Create test case log folder
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Set variables for TC    &{kwargs}
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Configure LOKI interfaces
    ...    ELSE IF    ${interrat_ho}    Configure Inter RAT handover interfaces
    ...    ELSE     Configure VM interfaces for handover
    Run Keyword If    "${Need_custom_eth3}" == "True"
    ...    Configure Custom eth3 interfaces    Custom_eth3_interfaces=${Custom_eth3_interfaces}
    Run Keyword If    "${Need_custom_eth4}" == "True"
    ...    Configure Custom eth4 interfaces    Custom_eth4_interfaces=${Custom_eth4_interfaces}
    Copy custom config files
    run Keyword if    ${NGBased_HO}    Update WTS config file for ${Handover_Feature}
    run Keyword if    ${NGBased_HO}    Update Gnb with NGBasedHO configuration for ${Handover_Feature}
    run Keyword if    ${interrat_ho}   Update WTS config file for InterRAT handover ${Handover_Feature}
    run Keyword if    ${interrat_ho}   Update Gnb with InterRAT configuration for ${Handover_Feature}
    run Keyword if    ${ANR_IR}        Update WTS config file for ANR InterRAT handover ${Handover_Feature}
    run Keyword if    ${ANR_IR}        Update Gnb with ANR InterRAT configuration for ${Handover_Feature}
    Reboot gNB irrespective of state
    Wait for gNB To Be Ready
    Run Keyword And Ignore Error    Get disk space and tmp content
    Start pcap collection in gNB and WTS    options=-f sctp -i any -s0 -C 200 -W 20 -z gzip
    Collect logs for debug
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/basic_setup.cfg
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Ensure NG Link is Up
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    run Keyword if    "${Handover_Feature}" != "5GC002329" and "${Handover_Feature}" != "CB012582_IRAT"
    ...    Establish X2 link for simulator Gnb    enb_id=1    simulator_gnb_list=${simulator_gnb_list}
    Ensure cell setup completed    AP_IP=${AP_IP}
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
	Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Common Suite Setup
    [Arguments]     ${feature_folder}     ${topology}=CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Suite Common Keywords    feature_folder=${feature_folder}
    Copy and Trigger Mirroring Script    topology=${topology}
    Set Suite Variable    ${IS_ORAN}
    Run Keyword If    ${IS_ORAN}    Update RFM Plugin And Add Netconf Account    ${RFM_Plugin}

Common Suite Teardown
    Common Suite Teardown Keywords

Copy custom config files
    Copy File And Display Warning    ${WTS_CFG_PATH}/${WTS_FILE}    /opt/wts/latest/

Reboot gNB if Cell is on Air
    ${cell_state_flag}    Confirm If gNB Cell State is OnAir
    Run Keyword If    ${cell_state_flag}    Reboot gNB To Clean Test Env
    Run Keyword If    ${cell_state_flag}    Copy and Trigger Mirroring Script
    ...    topology=CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD

Increment TC Index
    ${TC_index}    Evaluate    ${TC_index}+1
    Set Suite Variable    ${TC_index}

Reboot gNB irrespective of state
    Confirm If gNB Cell State is OnAir
    Reboot gNB To Clean Test Env
    Copy and Trigger Mirroring Script    topology=CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD

Reboot GNB based on TC index
    Run Keyword If    '${TC_index}' == '1'    Reboot gNB if Cell is on Air
    Run Keyword If    '${TC_index}' != '1'    Reboot gNB irrespective of state

Collect Logs And Cleanup On Failure
    [Arguments]    ${sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}
    Log To Console    On Failure: Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword and Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword If    "${sa_ue_list}" != "${EMPTY}"    Run Keyword and Ignore Error    Stop Traffic and Detach SA UEs    ${sa_ue_list}
    Run Keyword If    "${nsa_ue_list}" != "${EMPTY}"    Run Keyword and Ignore Error    Stop Traffic And Detach NSA UEs    ${nsa_ue_list}

Test Teardown For HO cases
    [Arguments]    ${sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}    ${handover}=False
    Log    ${handover}
    Simple Test Teardown    ${sa_ue_list}    ${nsa_ue_list}

Simple Test Teardown
    [Arguments]    ${sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'
    ...    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword If    '${TEST_STATUS}' == 'FAIL'    Collect Logs And Cleanup On Failure    ${sa_ue_list}
    ...   ${nsa_ue_list}
    Common Test Teardown
    Increment TC Index

Set variables for APoABIO
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    FOR    ${key}    ${value}    IN    @{items}
        run keyword if   $key == 'dl_tput_list'    Set Test Variable    ${dl_tput_list}    ${value}
        run keyword if   $key == 'A1_carrier_freq'    Set Test Variable    ${A1_carrier_freq}    ${value}
        run keyword if   $key == 'A2_carrier_freq'    Set Test Variable    ${A2_carrier_freq}    ${value}
        run keyword if   $key == 'A3_carrier_freq'    Set Test Variable    ${A3_carrier_freq}    ${value}
        run keyword if   $key == 'A2_carrier_sim_freq'    Set Test Variable    ${A2_carrier_sim_freq}    ${value}
        run keyword if   $key == 'A3_carrier_sim_freq'    Set Test Variable    ${A3_carrier_sim_freq}    ${value}
        run keyword if   $key == 'A2_detach_freq'    Set Test Variable    ${A2_detach_freq}    ${value}
    END

Revert Gnb Configuration using original delta
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${feature}=${EMPTY}    ${interrat}=False    ${ANR_IR}=False
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_HO.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    ${revert_delta}     run keyword if    ${interrat}    Get Revert Delta Param for interrat handover ${Handover_Feature}
    ...    ELSE IF    ${ANR_IR}    Get Revert Delta Param for ANR interrat handover ${Handover_Feature}
    ...    ELSE    Get Revert Delta Param for ${Handover_Feature}
    run Keyword if    ${mimomode_closed}    Get Revert Delta Param for ${feature}
    Recommission GNB With Delta    ${revert_delta}
    Wait for gNB To Be Ready

Revert WTS config file
    Run keyword And Ignore Error    Run And Return Rc And Output
    ...   mv ${WTS_INSTALL_PATH}/${WTS_BKUP_FILE} ${WTS_INSTALL_PATH}/${WTS_FILE}

Revert WTS and Gnb configuration
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${feature}=${EMPTY}    ${interrat}=False    ${ANR_IR}=False
    Run keyword And Continue On Failure    Revert WTS config file
    Run keyword And Continue On Failure    Revert Gnb Configuration using original delta
    ...    Handover_Feature=${Handover_Feature}    feature=${feature}    interrat=${interrat}    ANR_IR=${ANR_IR}

Basic Test Setup
    [Arguments]    ${feature}    ${wts_update}=False    ${scf_update}=False    ${custom_config}=False    ${HO}=False    &{kwargs}
    Check and Create test case log folder
    Set variables for TC    &{kwargs}
    Run Keyword And Ignore Error    Get disk space and tmp content
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Configure LOKI interfaces
    Run Keyword If     "${HO}" == "True"    Configure VM interfaces for handover
    Run Keyword If    "${custom_config}" == "True"    Bring Up TL with Custom Configuration    custom_config_folder=${custom_config_folder}
    ...    update_required=True    output_dir=${OUTPUT_DIR}
    Run Keyword If    '${TOPOLOGY}' == 'CLOUD_5G_I_MP_AP_LO'    Update vendor profile for ecpri72e
    run Keyword if    ${mimomode_closed}    Update Gnb with closed loop dl mimomode for ${feature}
    Update WTS Config File    ${wts_update}    ${feature}    &{kwargs}
    Run Keyword If    '${scf_update}'=='True'    Update GNB scf File    ${feature}    &{kwargs}
    ${status}    Run keyword and return status    Variable Should Exist    $bsr_update
    run keyword if    ${status}    Get and Update BSR Package    bsr_file_name=${bsr_file_name}    bsr_path=${bsr_path}
    Run Keyword If   not ${custom_config}    Reboot GNB irrespective of state
    Wait for gNB To Be Ready
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Start pcap collection in gNB and WTS    options=-f sctp -i any -s0 -C 200 -W 20 -z gzip
    Collect logs for debug

Generic Test Setup
    [Arguments]    ${feature}    ${wts_update}=False    ${scf_update}=False    &{kwargs}
    Basic Test Setup    ${feature}    ${wts_update}    ${scf_update}    &{kwargs}
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}    edaemon_port=${edaemon_port}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    ${cell_deployment}    Evaluate    ${kwargs}.get('cell_deployment', 'SANSA')
    Run Keyword If    '${cell_deployment}' in ['SANSA','SA']    SA Test Setup
    Run Keyword If    '${cell_deployment}' in ['SANSA','NSA']    NSA Test Setup
    Check if cell setup completed
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
	Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Get and Update BSR Package
    [Arguments]    ${bsr_file_name}    ${bsr_path}
    Create BSR Package Folder on VM    ${bsr_path}
    log to console     Locking all cells before BSR update and unlocking after update
    Get all cells from BTS
    FOR    ${each_cell}    IN    @{nrcell_distnames}
        Lock cell and verify the cell state    ${each_cell}
    END
	sleep    30s
    Update BSR File    bsr_file_path=${bsr_path}/${bsr_file_name}
    FOR    ${each_cell}    IN    @{nrcell_distnames}
        Unlock cell and verify gnb state    ${each_cell}
    END

SA Test setup
    Ensure NG Link is Up
    Wait Until Keyword Succeeds    10 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful

NSA Test Setup
    Establish X2 link   enb_id=1   gnb_id=${GNB_ID}

Update WTS config file
    [Arguments]    ${wts_update}    ${feature}    &{kwargs}
    Return From Keyword If    '${wts_update}'=='False'
    Run Keyword And Return If    '${wts_update}'=='True'    Update WTS config file for ${feature}
    ${wts_update_custom_kw}    Run Keyword If    '${wts_update}'=='custom'    Set Variable
    ...    Update WTS config file for ${feature}
    Run Keyword    ${wts_update_custom_kw}    &{kwargs}

Generic Test Teardown
    [Arguments]    ${feature}    ${sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}    ${scf_update}=True
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'
    ...    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword If    '${TEST_STATUS}' == 'FAIL'    Collect Logs And Cleanup On Failure    ${sa_ue_list}
    ...   ${nsa_ue_list}
    Common Test Teardown
    Run Keyword If    '${scf_update}' == 'True'
    ...    Run Keywords    Recommission GNB With Scf    ${${feature}_scf_file}    AND    Wait for gNB To Be Ready
    Run keyword And Ignore Error    run and return rc and output
    ...    cp ${WTS_INSTALL_PATH}/basic_setup_backup.cfg ${WTS_INSTALL_PATH}/basic_setup.cfg

Get distnames
    [Arguments]    &{kwargs}
    Get bts distname
    ${NRCELL_distname_list}    Get cell distnames    ${kwargs['logical_cell_list']}
    @{NRREL_distname_list}    Run Keyword If    'nrrel_list' in ${kwargs['logical_cell_list']}
    ...    Get Rel distnames    ${nrrel_list}

Get bts distname
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}

Get cell distnames
    [Arguments]    ${logical_cell_list}
    @{NRCELL_distname_list}    create list
    FOR    ${logical_cell_id}    IN    @{logical_cell_list}
        ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=${logical_cell_id}
        Append To List    ${NRCELL_distname_list}    ${NRCELL_DISTNAME}
        Set Test Variable    ${NRCELL${logical_cell_id}_DISTNAME}    ${NRCELL_DISTNAME}
    END
    set test variable    ${NRCELL_distname_list}
    [Return]    ${NRCELL_distname_list}

Get Rel distnames
    [Arguments]    ${nrrel_list}
    @{NRREL_distname_list}    create list
    FOR    ${nrerl_id}    IN    @{nrrel_list}
        ${nrrel_distname}    Set Variable    NRREL${nrerl_id}_DISTNAME
        set test variable    ${${nrrel_distname}}    ${NRCELL_DISTNAME}/NRREL-${nrerl_id}
        Append To List    ${NRREL_distname_list}    ${NRCELL_DISTNAME}
    END
    set test variable    ${NRREL_distname_list}
    [Return]    @{NRREL_distname_list}

Get List Of UE IDs
    [Arguments]    ${ue_id}    ${no_of_ues}    ${cell_deployment}
    ${ue_ids_list}    utilities.generate_list_of_ue_ids    ${ue_id}    ${no_of_ues}
    Set Suite Variable    ${${cell_deployment}_UE_List}    ${ue_ids_list}

Update GNB scf file
    [Arguments]    ${feature}    &{kwargs}
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    Set Global Variable    ${${feature}_scf_file}    ${original_scf_path}
    Get distnames    &{kwargs}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${get_delta_kw}    Set Variable    Get Delta for ${feature}
    Run Keyword    ${get_delta_kw}    &{kwargs['delta']}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Set variables for TC
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    FOR    ${key}    ${value}    IN    @{items}
         Set Test Variable    ${${key}}    ${value}
    END

Bring Up TL with Custom Configuration
    [Arguments]    ${custom_config_folder}    ${update_required}=False    ${output_dir}=${OUTPUT_DIR}
    [Documentation]    This keyword is used to bring up the TL for any specific configuration.
    ...     We would intake all 3 node config files "sm"- gNB "sim"- Airphone "wts" - WTS config files
    ...     Update required has to be set to yes to update vLAN info on SCF and SW version updates on iphy.xml files
    tl_env_cleanup.env_reset_after_suite    config_folder=${custom_config_folder}    update_required=${update_required}    output_dir=${output_dir}
    ...    is_oran=${IS_ORAN}

Modify UTE Memory Size
    [Documentation]    This Aims To Prevent Delayed Messaging Between AirPhone and WTS
    Log To Console    Modify UTE Memory Size...
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=40971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=40971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=40971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=40971520

Update RFM Plugin And Add Netconf Account
    [Arguments]    ${rfm_plugin_name}=${EMPTY}
    ${rfm_plugin_path}     Run Keyword If    "${rfm_plugin_name}" != "${EMPTY}"
    ...     oran_operations.Download Rfm Plugin    ${rfm_plugin_name}
    Run Keyword If    "${rfm_plugin_name}" != "${EMPTY}"
    ...     Wait Until Keyword Succeeds     3min     1min     admin_helper.Update RFM Plugin    ${rfm_plugin_path}
    sleep    60s
    Wait Until Keyword Succeeds     3min     1min     admin_helper.Configure Default Netconf Account

Check and Create test case log folder
    ${testlog_path}    Get Variable Value    ${testlog_path}    ${EMPTY}
    Return From Keyword If    '${testlog_path}' != '${EMPTY}'
    Create Test Case Folder
    ${testlog_path}    log_store.get test log folder
    Set Test Variable    ${testlog_path}