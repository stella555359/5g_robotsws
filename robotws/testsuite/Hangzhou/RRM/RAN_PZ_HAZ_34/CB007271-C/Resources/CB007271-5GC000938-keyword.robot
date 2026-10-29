*** Settings ***
Documentation     author: shanxu
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: shangyu.xu@nokia-sbell.com

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    csn
#Library    taf.selenium.gnb.oam.coam.classical        WITH NAME    selenium_coam
Library    taf.rfrl.common_resources.python.ssh_common_commands    WITH NAME    ssh_common_commands

Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource          ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py


*** Variables ***

${dltp}    10
${ultp}    5
${counter_path}    BTS/CELLS/NRCELL-2/NRACH/RA_MSG3_RECEP    #BTS/CELLS/NRCELL-2/NRACH
${SCF_TEMPLATE_PATH}    ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T921
${du_scf_name}    SCF_0.800.xml




*** Keywords ***
Suite setup
    admin_cli.connect to    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=COAM

Suite teardown
    admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error    COAM WEBUI Logout    display=${true}

Precondition
    [Arguments]    ${prachconfigurationindex_expect}=${12}    ${prachsequencetype_expect}=Unrestricted     ${zeroCorrelationZoneconfig_except}=${15}
    ...    ${cbraPreamblesPerSsb_except}=n64    ${ChBwdl_except}=20MHz    ${ChBwul_except}=20MHz    ${actPrachMultiplexing_except}=${true}
    ...    ${pucchModeSelect_except}=longPucch    ${raResponseWindow_except}=sl20    ${msg1FrequencyStart_except}=${7}
    ...    ${nbrOfSsbPerRachOccasion_except}=one    ${powerRampingStep_except}=dB2    ${powerRampingStepHighPriorityCfra_except}=dB2
    ...    ${prachRootSequenceIndex_except}=${0}    ${initialPreambleReceivedTargetPower_except}=${-104}    ${preambleTransMax_except}=n10
    ...    ${totalNumberOfRAPreambles_except}=${64}    ${raContentionResolutionTmr_expect}=sf64    ${rsrpThresholdSSB_expect}=${19}
    ...    ${maxHarqMsg3Tx_except}=${5}    ${maxUlHarqTx_except}=${5}
    log to console    \n in precondition stage
    Check GNB cell on air
    #run keyword if    ${actPrachMultiplexing_except}==${true}
    #...    Scf commission and wait on-air    scf_name=${du_scf_name}
    @{MOs}    enblte.get_managed_objects    class_name=NRCELL_A    connection=COAM
    #log to console    @{MOs}
    &{dict_pattern}=    enblte.get_parameters    dist_name=${MOs[0]['distName']}   connection=COAM
    set suite variable    &{dict_pattern}

    run keyword if    ${dict_pattern['prachConfigurationIndex']} != ${prachconfigurationindex_expect}
    ...    Set parameter    key=prachConfigurationIndex    value=${prachconfigurationindex_expect}
    run keyword if    '${dict_pattern['prachSequenceType']}' != '${prachsequencetype_expect}'
    ...    Set parameter    key=prachSequenceType    value=${prachsequencetype_expect}
    run keyword if    ${dict_pattern['zeroCorrelationZoneConfig']} != ${zeroCorrelationZoneconfig_except}
    ...    Set parameter    key=zeroCorrelationZoneConfig    value=${zeroCorrelationZoneconfig_except}
    run keyword if    '${dict_pattern['cbraPreamblesPerSsb']}' != '${cbraPreamblesPerSsb_except}'
    ...    Set parameter    key=cbraPreamblesPerSsb    value=${cbraPreamblesPerSsb_except}
    run keyword if    '${dict_pattern['pucchModeSelect']}' != '${pucchModeSelect_except}'
    ...    Set parameter    key=pucchModeSelect    value=${pucchModeSelect_except}
    run keyword if    '${dict_pattern['raResponseWindow']}' != '${raResponseWindow_except}'
    ...    Set parameter    key=raResponseWindow    value=${raResponseWindow_except}
    run keyword if    ${dict_pattern['msg1FrequencyStart']} != ${msg1FrequencyStart_except}
    ...    Set parameter    key=msg1FrequencyStart    value=${msg1FrequencyStart_except}
    run keyword if    '${dict_pattern['nbrOfSsbPerRachOccasion']}' != '${nbrOfSsbPerRachOccasion_except}'
    ...    Set parameter    key=nbrOfSsbPerRachOccasion    value=${nbrOfSsbPerRachOccasion_except}
    run keyword if    '${dict_pattern['powerRampingStep']}' != '${powerRampingStep_except}'
    ...    Set parameter    key=powerRampingStep    value=${powerRampingStep_except}
    run keyword if    '${dict_pattern['powerRampingStepHighPriorityCfra']}' != '${powerRampingStepHighPriorityCfra_except}'
    ...    Set parameter    key=powerRampingStepHighPriorityCfra    value=${powerRampingStepHighPriorityCfra_except}
    run keyword if    ${dict_pattern['prachRootSequenceIndex']} != ${prachRootSequenceIndex_except}
    ...    Set parameter    key=prachRootSequenceIndex    value=${prachRootSequenceIndex_except}
    run keyword if    ${dict_pattern['initialPreambleReceivedTargetPower']} != ${initialPreambleReceivedTargetPower_except}
    ...    Set parameter    key=initialPreambleReceivedTargetPower    value=${initialPreambleReceivedTargetPower_except}
    run keyword if    '${dict_pattern['preambleTransMax']}' != '${preambleTransMax_except}'
    ...    Set parameter    key=preambleTransMax    value=${preambleTransMax_except}
    run keyword if    ${dict_pattern['totalNumberOfRAPreambles']} != ${totalNumberOfRAPreambles_except}
    ...    Set parameter    key=totalNumberOfRAPreambles    value=${totalNumberOfRAPreambles_except}
    run keyword if    '${dict_pattern['raContentionResolutionTmr']}' != '${raContentionResolutionTmr_expect}'
    ...    Set parameter    key=raContentionResolutionTmr    value=${raContentionResolutionTmr_expect}
    run keyword if    ${dict_pattern['rsrpThresholdSSB']} != ${rsrpThresholdSSB_expect}
    ...    Set parameter    key=rsrpThresholdSSB    value=${rsrpThresholdSSB_expect}
    run keyword if    ${dict_pattern['actPrachMultiplexing']} != ${actPrachMultiplexing_except}
    ...    Set parameter    key=actPrachMultiplexing    value=${actPrachMultiplexing_except}

    ${maxHarqMsg3Tx}    Get NIDD parameter value    class_name=NRCELLGRP_A    pattern=maxHarqMsg3Tx    connection=COAM
    run keyword if    ${maxHarqMsg3Tx} != ${maxHarqMsg3Tx_except}
    ...    set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELLGRP-0    key=maxHarqMsg3Tx    value=${maxHarqMsg3Tx_except}

    ${maxUlHarqTx}    Get NIDD parameter value    class_name=NRCELLGRP_A    pattern=maxUlHarqTx    connection=COAM
    run keyword if    ${maxUlHarqTx} != ${maxUlHarqTx_except}
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELLGRP-0    key=maxUlHarqTx    value=${maxUlHarqTx_except}

    ${ChBwdl}    Get NIDD parameter value    class_name=NRCELL_FDD_A    pattern=chBwDl    connection=COAM
    run keyword if    '${ChBwdl}' != '${ChBwdl_except}'
    ...    set bandwidth    value=${ChBwdl_except}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair

Check GNB cell on air
    [Documentation]
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    COAM Check All Cells Onair

Scf commission and wait on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    log to console    step1:scf commission and wait for on-air
    Conect to DU COAM
    admin_cli.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
	sleep    60s
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair
#   Get cell numbers

Conect to DU COAM
    [Arguments]    ${connection}=COAM
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
                  ...      username=${WEBUI_USER}
                  ...      password=${WEBUI_PASSWORD}
                  ...      name=${connection}

Set parameter
    [Arguments]    ${key}    ${value}    ${dict_name}=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    admin_cli.perform_parameter_recommissioning    dist_name=${dict_name}    parameter=${key}
    ...    operation=update    value=${value}    connection=COAM
    sleep    60s

set bandwidth
    [Arguments]    ${value}

    ${cellBwpList0_5}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-9    cellBwpId=0
    ${cellBwpList1_5}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-30    cellBwpId=1
    @{cellBwpList_params_5}    create list    ${cellBwpList0_5}    ${cellBwpList1_5}

    ${cellBwpList0_10}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_10}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_10}    create list    ${cellBwpList0_10}    ${cellBwpList1_10}

    ${cellBwpList0_15}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_15}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_15}    create list    ${cellBwpList0_15}    ${cellBwpList1_15}

    ${cellBwpList0_20}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-4    cellBwpId=0
    ${cellBwpList1_20}    Create Dictionary    bwpDN=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/BWP_PROFILE-33    cellBwpId=1
    @{cellBwpList_params_20}    create list    ${cellBwpList0_20}    ${cellBwpList1_20}

    run keyword if    '${value}'=='5MHz'
    #...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=type0CoresetConfigurationIndex    value=0    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_5}

    run keyword if    '${value}'=='10MHz'
    #...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=type0CoresetConfigurationIndex    value=7    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_10}

    run keyword if    '${value}'=='15MHz'
    #...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=type0CoresetConfigurationIndex    value=7    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_15}

    run keyword if    '${value}'=='20MHz'
    #...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=type0CoresetConfigurationIndex    value=7    AND
    ...    Set parameter    dict_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2    key=cellBwpList    value=${cellBwpList_params_20}
    log to console    Open WEBEM
    selenium_coam.enable_virtual_display

    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
    ...    username=Nemuadmin    password=nemuuser    version=SBTS22R3

    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink    new_value=350000
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink    new_value=430160
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Synchronization channel number    new_value=5377
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink    new_value=${value}
    selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink    new_value=${value}

    run keyword if    '${value}'=='5MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=0
    run keyword if    '${value}'=='10MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7
    run keyword if    '${value}'=='15MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7
    run keyword if    '${value}'=='20MHz'
    ...     selenium_coam.set_parameter_value   dist_name=MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-2
    ...    filter_param=Coreset configuration Index    new_value=7
    log to console    Active parameter
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${true}   execute=${true}

    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair
    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    OperatingSystem.Run    ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -

L3 call setup for NSA
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    #power_ue.Verify attach    ue_type=${UE_TYPE}    4G_check=True   5Grach_ed=${5Grach_ed_0}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    reset_sol=ue_reboot
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

L3 call setup second
    [Arguments]    ${UE_TYPE}=qct_dx50    ${ue_index}=${0}    ${4G_check}=Flase
    log to console    L3 call setup and check
    Log To Console    \n ### Prepare UE ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    Log To Console    \n ### verify UE Attach ###
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=${4G_check}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Check PM counters
    [Arguments]    ${connection}=COAM
    wait until keyword succeeds     2s    1s
    ...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...      username=Nemuadmin
    ...      password=nemuuser
    ...      name=${connection}
    ${reportingIntervalPm}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    run keyword if    "${reportingIntervalPm}" != "5min"     Set reportingIntervalPm to 5min
    ...    ELSE    log   Already 5min!
    ${reportingIntervalPm_1}    Get NIDD parameter value    class_name=PMCADM_A    pattern=reportingIntervalPm    connection=COAM
    #sleep    ${reportingIntervalPm_1}
    log to console    sleep
    ${sb1_dlcounter} =    Get the Counter value from COAM    counter_id=M55306C06001
    ...    dic_path=${counter_path}    min_len=${0}
    log to console    ${sb1_dlcounter}
    should be true    ${sb1_dlcounter} > 0

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    log to console    ${counter_id}    ${dic_path}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=COAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length  ${counter_value}
    should be true  ${len} > ${min_len}
    [Return]    ${counter_value[0]}

Set reportingIntervalPm to 5min
    COAM Update Parameter    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=5min
    sleep    5s

Modify HBTE Channel Vaules
    [Arguments]    ${channels}    ${value}=63    ${ru_id}=0    ${gnb_id}=0
    #${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${channels}
    ...    vendor=HBTE
    ${channels_to_modify}    Create Dictionary
    FOR    ${channel}    IN    @{channels}
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

teardown
    log to console    \n in teardown stage
    Run Keyword And Ignore Error     admin_cli.teardown    connection=COAM
    Run Keyword And Ignore Error     power_ue.UE Detach    ue_index=${0}    ue_type=inseego
    Run Keyword And Ignore Error
    ...    Connect and Modify the parameter on enblte   dist_name=MRBTS-925/LNBTS-925/LNCEL-44922    parameter=administrativeState    value=unlocked
    CI_interface.Common Case Teardown

