*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-J of "LA for HR DRBs"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     taf.config.wts                                 WITH NAME    wts
Library     ../../../L2/libraries/template_functions.py    WITH NAME    template
Resource    ../../../../resources/Common/testline.robot
Resource    ../../../../resources/Common/wts_ue.robot
Resource    CB008246-J_initial_commissioning.robot

*** Variables ***

${target_bler}           100,100,100,95,90,50,10,1,0.5,0.1,0,0,0,0,0


*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}
    testline.Set Console Output    Output=${True}


Run Feature specific keywords before attach
    ${attached_ue_list}=    template.Get_UE_IDs_configured_For_Scenario    scenario_name=${scenario_name}
    Sort List  ${attached_ue_list}
    Set Test variable    ${attached_ue_list}
    ${string_attached_ue_list}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set Test Variable    ${string_attached_ue_list}

    Apply ul_cell_noise Testmode to All UEs before attach
    Apply ul_sinr Testmode to All UEs before attach
    Apply DL csi_override Testmode to All UEs before attach
    Apply DL BLER simulation to all UEs before attach


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  @{varargs}
    Sleep  1s
    IF    not 'TC05' in '${scenario_name}' and not 'TC06' in '${scenario_name}'    Perform HR DRB Addition And Start Of Traffic

#UL pathloss simulation
    IF    'DFTsOFDM' in '${scenario_name}'    Apply UL Pathloss Simulation To All UEs During Traffic

    Stop DL BLER simulation to all UEs after UL pathloss simulation
    Perfom stop traffic on HR DRB and delete it

Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    wts_ue.Associate UEs To Testmode    ue_id=${string_attached_ue_list}   testmode=ul_sinr    profile_id=2    action=deactivate
    wts_ue.Associate UEs To Testmode    ue_id=${string_attached_ue_list}   testmode=csi_override    profile_id=${1}  scell=primary  action=deactivate

    Send Egate Command and verify output    cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
    Sleep    1s    reason=wait command to be executed
    Log   UL CELL NOISE TESTMODE NR profile_id=2 is deactivated    console=${True}

#-----------For Suite Setup----------------------------------------------------------------------------------------------------------[150 characters]
Make necessary changes to SCF
    Update Requested RnD flags in SW config file
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}

    Change Reporting Interval for CB008246  interval_duration=${pm_reporting_interval}
    Enable and disable some Functionality according to CFAM
    Activate CB008246
    Configure SCF File for subfeature CB008246-B

    ${modified_scf}=    Set variable    ${configuration_directory}/SCF_suite_specific_scf_file.xml
    scf.save_scf    file_path=${modified_scf}
    ${delta_scf_path}=    Set variable    ${configuration_directory}/SCF_suite_specific_delta_scf_file.json
    scf.calculate_delta_scf    target_scf_path=${modified_scf}    actual_scf_path=${original_gnb_scf}    delta_scf_path=${delta_scf_path}
    ${is_commissioning_needed}=    CB008246-J_scenario_modifications.Check if commissioning is needed    ${delta_scf_path}

    IF    not ${is_commissioning_needed}   RETURN
    ${oam_alias}=    connect.Setup OAM http session
    admin.perform_commissioning  scf_file=${modified_scf}  connection=${oam_alias}
    ...  skip_parameter_relation_errors=False  timeout=300
    connect.Teardown OAM http session


Check if commissioning is needed
    [Arguments]    ${delta_config_file}
    ${delta_size}=    Get file size    ${delta_config_file}
    ${is_commissioning_needed}=    Evaluate    ${delta_size} > 2
    RETURN    ${is_commissioning_needed}


#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]
Update Requested RnD flags in SW config file
    @{J_rd_params}=  create list  0x5801cb=0 #rdFakeUeSchedulingEnable

    gnb.Update SW Config file on System Module  param_list=${J_rd_params}

    @{AP_MOD_RD_FLAGS}=  Create List
    ...    0x5C0009=3 #to avoid AP reboot during NIDD modify
    ...    0x70700=6400 #OpenLoopPowerControlForFDD
    Update SW Config file on AP System Module    param_list=${AP_MOD_RD_FLAGS}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Update Basic Configuration File
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts.Insert    set_qosflow id=4 5qi=7    after    set_qosflow id=3
    wts.Insert    set_qosflow id=5 5qi=8    after    set_qosflow id=4
    wts.Modify    command=nwslice_set id=1    modification=qos_flows=1,2,3,4,5
    wts.Insert    amf_param id=1 empty_pdu_session_list=on                                             after    nwslice_set id=1
    wts.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}


Apply Ul_Cell_Noise Testmode To All UEs Before Attach
    ${noise}=    Set Variable If  'TDD' in '${SCENARIO_NAME}'    ${-700}    ${-540}
    wts_ue.Send Egate Command And Verify Output
    ...    cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    Sleep    1s    reason=wait command to be executed
    Send Egate Command and verify output    cmd=ul_cell_noise_testmode_nr profile_id=2    pass_regexp=ul_cell_noise_testmode_nr Parameters
    Log   UL CELL NOISE TESTMODE NR profile_id=2 and noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise} is configured
    ...    console=${True}
    #activate ul_cell_noise
    Send Egate Command and verify output    cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
    Sleep    1s    reason=wait command to be executed
    Log   UL CELL NOISE TESTMODE NR profile_id=2 and noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise} is activated
    ...    console=${True}


Apply Ul_Sinr Testmode To All UEs Before Attach
    ${PATHLOSS_START_dB}=    Set Variable If    'FDD' in '${SCENARIO_NAME}'  90    90
    ${PATHLOSS_END_dB}=      Set Variable If    'FDD' in '${SCENARIO_NAME}'  125    120

    Set Test Variable    ${PATHLOSS_START_dB}
    Set Test Variable    ${PATHLOSS_END_dB}
    wts_ue.Configure NR UL SINR testmode    profile_id=2    pathloss=${PATHLOSS_START_dB}
    wts_ue.Associate UEs To Testmode  ue_id=${string_attached_ue_list}  testmode=ul_sinr  profile_id=2  action=activate


Apply DL csi_override Testmode to All UEs before attach
    wts_ue.Update UE Channel State Information  profile_id=${1}  cqi=4  cqi_mode=fixed  ri=0  ri_mode=fixed
    wts_ue.Associate UEs To Testmode    ue_id=${string_attached_ue_list}    profile_id=${1}    scell=primary  testmode=csi_override  action=activate



Apply DL BLER simulation to all UEs before attach
    wts_ue.Configure NR Advanced BLER Testmode  profile_id=${1}  target_bler_profile_id=1  target_bler=${target_bler}  target_mcs=10
    ...    rank=0  mcs_table=all  p_target_bler_profile_id=1
    wts_ue.Associate UEs To Testmode    ue_id=${string_attached_ue_list}    profile_id=${1}    scell=primary    testmode=adv_bler    action=activate


Perform HR DRB addition and start of traffic
    FOR  ${ue_id}  IN  @{attached_ue_list}
        Add/Del PDU Session   ue_id=${ue_id}    qosflows_action=qosflows_to_add=4,5
    END
    wts_ue.Start Data Traffic In Egate    ue_id=${string_attached_ue_list}    direction=dl    protocol=udp    ack_mode=off    trf_id=4
    ...    cl_trf_stats=on    mbps=5    pdu=1    qfi=2
    wts_ue.Start Data Traffic In Egate    ue_id=${string_attached_ue_list}    direction=ul    protocol=udp    ack_mode=off    trf_id=5
    ...    cl_trf_stats=on    mbps=5    pdu=1    qfi=2
    wts_ue.Start Data Traffic In Egate    ue_id=${string_attached_ue_list}    direction=dl    protocol=udp    ack_mode=off    trf_id=6
    ...    cl_trf_stats=on    mbps=5    pdu=1    qfi=3
    wts_ue.Start Data Traffic In Egate    ue_id=${string_attached_ue_list}    direction=ul    protocol=udp    ack_mode=off    trf_id=7
    ...    cl_trf_stats=on    mbps=5    pdu=1    qfi=3
    Sleep    1s


Apply UL pathloss simulation to all UEs during traffic
    Simulate UL Pathloss    PATHLOSS_START_dB=${PATHLOSS_START_dB}+${1}    PATHLOSS_END_dB=${PATHLOSS_END_dB}    pathloss_step_dB=2

    IF    'TC05' in '${scenario_name}' or 'TC06' in '${scenario_name}'
    ...    Perform HR DRB Addition And Start Of Traffic

    Simulate UL Pathloss    PATHLOSS_START_dB=${PATHLOSS_END_dB}    PATHLOSS_END_dB=${PATHLOSS_START_dB}    pathloss_step_dB=-2

    Run Keyword and Ignore Error    Display Bearer Stats for All UEs


Simulate UL Pathloss
    [Arguments]    ${PATHLOSS_START_dB}=80    ${PATHLOSS_END_dB}=115    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${PATHLOSS_START_dB}    ${PATHLOSS_END_dB}    ${pathloss_step_dB}
        wts_ue.Configure NR UL SINR testmode    profile_id=2    pathloss=${pathloss}
    END


Stop DL BLER simulation to all UEs after UL pathloss simulation
    wts_ue.Update UE Channel State Information  profile_id=${1}  cqi=8  cqi_mode=fixed  ri=1  ri_mode=fixed
    wts_ue.Associate UEs To Testmode    ue_id=${string_attached_ue_list}    profile_id=${1}    scell=primary    testmode=adv_bler  action=deactivate
    Sleep    1s


Perfom stop traffic on HR DRB and delete it
    wts_ue.Stop Data Traffic In Egate    ue_id=${string_attached_ue_list}    direction=bi    trf_id=4,5,6,7
    Sleep   1s   and let the last data packets get through before release
    FOR  ${ue_id}  IN  @{attached_ue_list}
        Add/Del PDU Session   ue_id=${ue_id}    qosflows_action=qosflows_to_del=4,5
    END
    Sleep   1s

Display Bearer Stats for All UEs
    ${_}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    wts_ue.Display bearer stats for multiple UE'S  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}
    ...  pdu=${bearer_stats_attribs_sa["pdus"]}  qfi=${bearer_stats_attribs_sa["qfis"]}


Display Traffic Data Rate
    ${_}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    ${tp}=  Run Keyword And Ignore Error    wts_ue.Get Bearer Stats From Egate
    ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
    ...  qfi=${bearer_stats_attribs_sa["qfis"]}  dir=bi
    Log to console    Current DL throughput for UE1 is ${tp} bps


Add/Del PDU Session
    [Arguments]    ${ue_id}    ${qosflows_action}
    wts_ue.Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 ${qosflows_action} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID .* handled successfully
    Log   ue_pdu_session_modify ue=${ue_id} pdu=1 ${qosflows_action} by=amf executed   console=${True}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
