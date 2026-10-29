*** Settings ***
Documentation    Scenario specific keywords for subfeature CB013715

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library       OperatingSystem

Library       taf.config.wts               WITH NAME       wts_cfg
Library       taf.transport.ssh            WITH NAME       ssh

# Library TRF
Library       resources/TARF/python/tools.py                   WITH NAME       nps_tarf_tools
Library       resources/TARF/python/ScfChanges.py
Library       resources/TARF/python/Dev_lib.py
Library       resources/TARF/python/bearer_stats.py            WITH NAME       bearer_stats_helpers
Library       resources/TARF/python/template_functions.py      WITH NAME       template

# Library DSS
Library       ../resources/DSS/python/dss_tools.py               WITH NAME       nps_dss_tools

# Library CB013715
Library       ./resources/python/CB013715_tools.py
Library       ./resources/python/CellCalculator/CellDss.py       WITH NAME       CellDss
Library       ./resources/python/ParameterParser.py              WITH NAME       yaml_parser
Library       ./resources/python/DlResourceErrorCaseChecker.py   WITH NAME       DlResourceErrorCaseChecker

# Resources SWENG
Resource      ../../../resources/SWENG/robot/SetConfig.robot

# Resources CB013715
Resource      resources/TARF/robot/ute-wtssim-ue-Keywords.robot
Resource      resources/TARF/robot/Scenario-Common-Keywords.robot
Resource      resources/TARF/robot/TARF-Keywords.robot
Resource      resources/TARF/robot/aashell.robot
Resource      resources/TARF/robot/DedicatedXmlConfig.robot
Resource      ./CB013715-FDD_initial_commissioning.robot
Resource      ./CB013715_scenario_validations.robot
Resource      resources/robot/DSS_Kw_TestSetup.robot
Resource      resources/robot/DSS_keywords.robot

# Variables     ./CB013715_variables.yaml

*** Variables ***

${yaml_file_path}      ${CURDIR}/Parameters.yaml

&{cSrs}   10MHz=7
    ...   15MHz=10
    ...   20MHz=13
    ...   30MHz=20
    ...   40MHz=25
    ...   50MHz=33
    ...   60MHz=42
    ...   70MHz=45
    ...   80MHz=51
    ...   90MHz=56
    ...   100MHz=63

@{ue_p_delay_initial}   100  50  100  50   50    140
${default_noise}         -860
${default_pathloss}      75

${PATTERN_DL_70_SA_OK}                   0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
${PATTERN_DL_100_SA_OK}                  1011110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111
${PATTERN_DL_100_SA_OK_NO_PRBPOOLING}    1011111011-1111111111-1011111011-1111111111-1011111011-1111111111-1011111011-1111111111
${PATTERN_DL_90_SA_OK}                   1011111011-1111101111-1011111011-1110111111-1011111011-1101111111-1011111011-1111011111
${PATTERN_DL_90_SA_OK_NO_PRBPOOLING}     1011111011-1111101111-1011111011-1110111111-1011111011-1101111111-1011111011-1111011111
# dssFixedMbsfnPattern applied in CellSetupResp is  00000000000000000010000000000000000000100000000000000000001000000000000000000010
# dssFixedNormalPattern applied in CellSetupResp is 01000000000000000000010000000000000000000100000000000000000001000000000000000100
${dss_fixed_mbsfn_pattern}               00000000000000000010000000000000000000100000000000000000001000000000000000000010
${dssFixedNormalPattern}                 01000000000000000000010000000000000000000100000000000000000001000000000000000100

# allowed value : min_share, max_share, min_max_equal_share, normal share for UL Allocation Type (supported by CRMSim)
#  and DL Allocation Type (not supported by CRMSim for the moment)
${ALLOCATION_TYPE}                       min_max_equal_share

${target_bler}               100,100,100,95,90,50,10,1,0.5,0.1,0,0,0,0,0

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    ${msg}=    set Variable   ${consTraceColorBgRed}${consTraceColorYellow}Scenario Execution: ${scenario_name}${defColor}
    BuiltIn.log to console    =========================================================================================
    BuiltIn.log to console    ${msg}
    BuiltIn.log to console    =========================================================================================
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    BuiltIn.log    [INFO] The following Keywords were Run: ${scenario_specific_keywords}    level=INFO   console=True
    Test-Suite-Setup-Resources-Keywords.Log config in result file  config=CB013715_${TOPOLOGY_LABEL}_${TOPOLOGY_VARIANT}
    ${full_file_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_file}    Set Variable    ${configuration_directory}/scf_${scenario_name}.xml

    IF     "${logs_and_traces_flags["CellSetup_Syslogs"]}"=="True"
        ${nrCellIdentity}=    Get nrCellIdentity From coam ADMIN    cell_grp=0    cell_nr=${fdd_cell_1}
        ${path_cell_setup_traces}=    set variable    ${LOG_PATH}/initial_cell_setup_trace
        ${commandToRun}     Catenate     cd ${path_cell_setup_traces}; find . -name "*.json" -type f | grep ${nrCellIdentity} |
        ...                              grep cellSetupRsp | grep -v cellcsirs | sed -e 's/^\\.\\///g'
        ${ret}    ${syslogfiles}     Run Keyword And Ignore Error    Run   ${commandToRun}
        IF    '${ret}' == 'PASS'
            ${sysLog_files}    Split String    ${syslogfiles}    separator=\n
            Sort List          ${sysLog_files}
            FOR    ${syslog}    IN    @{sysLog_files}
                ${status}    ${dssFixedMbsfnPattern}    Run Keyword And Ignore Error
                ...    Get dssFixedMbsfnPattern Bitmap From Log    ${path_cell_setup_traces}/${syslog}
                IF     '${status}' == 'PASS'
                    set suite variable     ${dssFixedMbsfnPattern}
                    dated log    [INFO] dssFixedMbsfnPattern = ${dssFixedMbsfnPattern} from ${syslog}
                END
            END
        END
    END
    Return From Keyword

Run Feature specific keywords before attach
    CB013715_scenario_validations.Load scf values for validations    scenario=${scenario_name}
    ${attached_ue_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    Set Test Variable  ${attached_ue_list}
    sort list  ${attached_ue_list}
    run keyword if    'DSS' in '${scenario_name}'       run keyword and continue on failure   Preparations before attach for scenario_Dss
    run keyword if    'wPL' in '${scenario_name}'         Apply ul_sinr Testmode to All UEs before attach
    run keyword if    'wTA_Init' in ${TEST TAGS}          run keyword and continue on failure    Initiate Timing Advance
    run keyword if    'W_BEAMS_CTRL' in ${TEST TAGS}      run keyword and continue on failure    Update Beam Control Parameters
    Return From Keyword

Run Feature specific keywords after attach before traffic is started
    run keyword if    'DSS' in '${scenario_name}'   run keyword and continue on failure   Preparations for scenario_Dss
    Save CSI report and UE info dictionary
    run keyword and ignore error   common_Dss_CellSetup.get and display ue_summary     alias=ap_egate    wtsObj=${wtsObj}
    run keyword if    'wTA_Init' in ${TEST TAGS}      run keyword and continue on failure   Initiate Lmf Ecid Meas with meas_qty NR_Timing_Advance
    run keyword if    'wTA_UeSpeed' in ${TEST TAGS}   run keyword and continue on failure   Initiate Timing Advance with ue_speed 30
    # variables defined into CB013715_variables.yaml
    IF   'wTA_velocity' in '${scenario_name}'
        IF         '${low_speed_and_approaching_gNB}'=='True'
            run keyword and continue on failure   Initiate UE as low speed and approaching gNB
        ELSE IF    '${high_speed_and_approaching_gNB}'=='True'
            run keyword and continue on failure   Initiate UE as high speed and approaching gNB
        ELSE IF    '${high_speed_and_leaving_gNB}'=='True'
            run keyword and continue on failure   Initiate UE as high speed and leaving gNB
        ELSE
            run keyword and continue on failure   Initiate UE as low speed and leaving gNB
        END
    END
    IF   'w_EVENT_CA_FDD_DSS_TDD' in '${scenario_name}'
        ${attached_ues_dict}=    template.Get Attach List    scenario_name=${scenario_name}    ue_type=sa
        ...                                                  with_auto_attach=${TRUE}
        ${attached_ues_list}=  get dictionary keys  ${attached_ues_dict}
        sort list  ${attached_ues_list}
        FOR    ${ue}    IN    @{attached_ues_list}
            Send A1 MR for scell addition and Verify whether gNB Configures CA and Deconfigures A1 Measurement at the UE
            ...         ue_id=${ue}    carrier_freq=${CARRIER_FREQ_3}
        END
    END
    Return From Keyword

Run Feature specific keywords during traffic before detach
    [Arguments]    ${traffic_duration}
    BuiltIn.log    traffic_duration is ${traffic_duration}
    # ${time_to_wait}     set variable     10s    # in case of 60s traffic duration in JSON
    ${time_to_wait}     set variable     2s
    BuiltIn.Sleep    ${time_to_wait}    Wait for start Traffic
    nps_tarf_tools.log_to_console_with_time_prefix    End Of Sleep_${time_to_wait} to Wait for start Traffic   level=INFO
    robot_extension.Run Keyword And Warn On Failure    Display Traffic Data Rate
    Save CSI report and UE info dictionary
    run keyword if    '${scenario_name}'=='scenario_TDD_7491_G_On_wMsg2'
    ...     Run Keywords       run keyword and continue on failure
    ...                        Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Msg2
    ...        AND             Save CSI report and UE info dictionary
    run keyword if    '${scenario_name}'=='scenario_TDD_7491_G_On_wPaging'
    ...     Run Keywords       run keyword and continue on failure
    ...                        Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Paging
    ...        AND             Save CSI report and UE info dictionary
    Run Keyword If  not 'wPaging' in '${scenario_name}' and 'wPLSimulate' in ${TEST TAGS}
    ...    Run keywords
    ...    ute-wtssim-ue-Keywords.Simulate Pathloss    pathloss_start_dB=${pathloss_start_dB}+${1}    pathloss_end_dB=${pathloss_end_dB}
    ...                                                pathloss_step_dB=1
    ...    AND    ute-wtssim-ue-Keywords.Simulate Pathloss    pathloss_start_dB=${pathloss_end_dB}    pathloss_end_dB=${pathloss_start_dB}
    ...                                                       pathloss_step_dB=-1
    run keyword if  '${scenario_name}'=='scenario_TDD_7491_H_On_5GC001116_3_5GC001070_5GC001070_6ssb_wPaging' and 'wPL_Variation' not in ${TEST TAGS}
    ...     Run Keywords       run keyword and continue on failure
    ...                        Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Paging
    ...        AND             Save CSI report and UE info dictionary
    run keyword if    '${scenario_name}'=='scenario_TDD_7491_H_On_5GC001116_3_5GC001070_5GC001070_6ssb_wPaging' and 'wPL_Variation' in ${TEST TAGS}
    ...     Run Keywords       run keyword and continue on failure
    ...                        Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Paging_wPLVariation
    ...        AND             Save CSI report and UE info dictionary
    Return From Keyword

Run Feature specific keywords after traffic before detach
    Return From Keyword

Run Feature specific keywords after detach
    return from keyword if    'wPL' not in '${scenario_name}'
    FOR  ${ue_id}  IN  @{attached_ue_list}
        ute-wtssim-ue-Keywords.Associate UEs to testmode    ue_id=${ue_id}   testmode=ul_sinr    profile_id=2    action=deactivate
    END

    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...            cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
    BuiltIn.Sleep    1s    reason=wait command to be executed
    Return From Keyword

#-----------For Test Execution - scenario_13715--------------------------------------------------------------------------------------[150 characters]
Preparations before attach for scenario_Dss
    ${scf_path}  COAM Get SCF   local_dir_path=${LOG_PATH}   file=SCF.xml   alias=coam_gnb
    # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure   TARF-Keywords.Admin Validate SCF   scf_path_file=${LOG_PATH}/SCF.xml
    ...                                                                                  dir=${LOG_PATH}

Preparations for scenario_Dss
    # CqiOffset is set as small as possible to minimize potential HARQ DTX impact on verification. Done via Suite Setup
    # FOR  ${ue_id}  IN  @{attached_ue_list}
    #     Change ue CQI on Airphone to 11 for ue ${ue_id}
    # END
    BuiltIn.Sleep    3    Wait for cqiSelection to approach configured CQI input
    ${csi_report_and_ue_info_dict}  ${_}=  template.get_csi_report_configured_for_scenario  ${scenario_name}
    Set Test Variable    ${csi_report_and_ue_info_dict}

Change CQI on Airphone to ${cqi}
    Update UE Channel State Information  profile_id=2  cqi=${cqi}  cqi_mode=fixed
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=csi_override  profile_id=2  action=activate

Change ue CQI on Airphone to ${cqi} for ue ${ueid}
    Update UE Channel State Information  profile_id=2  cqi=${cqi}  cqi_mode=fixed
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=${ueid}  testmode=csi_override  profile_id=2  action=activate

Changing CQI values
    ${cqi_mode}=   Set Variable    oneway
    ${cqi}=        Set Variable    0
    ${cqi_min}=    Set Variable    0
    ${cqi_max}=    Set Variable    11
    ${cqi_step}=   Set Variable    1
    ${cqi_period}=     Set Variable    3
    # CSI period probably depends on frequency and TDD/FDD
    ${csi_period}=     Set Variable    0.16

    ${list_of_nsa_ue_to_be_attached}=   template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    # Run Keyword If    ${SUITE_DEBUG_MODE}     dated log    list_of_nsa_ue_to_be_attached=${list_of_nsa_ue_to_be_attached}
    # Run Keyword If    ${SUITE_DEBUG_MODE}     dated log    list_of_sa_ue_to_be_attached=${list_of_sa_ue_to_be_attached}
    Run Keyword If    ${SUITE_DEBUG_MODE}     Run Keyword And Ignore Error    nps_tarf_tools.display_dictionnary_parameters_of_the_TestCase
    ...                                                                                               ${list_of_nsa_ue_to_be_attached}
    ...                                                                                               title=list_of_nsa_ue_to_be_attached
    Run Keyword If    ${SUITE_DEBUG_MODE}     Run Keyword And Ignore Error    nps_tarf_tools.display_dictionnary_parameters_of_the_TestCase
    ...                                                                                               ${list_of_sa_ue_to_be_attached}
    ...                                                                                               title=list_of_sa_ue_to_be_attached
    ${num_sa_ue}=  Get Length  ${list_of_sa_ue_to_be_attached}
    ${num_nsa_ue}=  Get Length  ${list_of_nsa_ue_to_be_attached}
    Run Keyword If    ${num_sa_ue}!=${0}    Update UE Channel State Information
    ...    profile_id=2  cqi_mode=${cqi_mode}  cqi=${cqi}
    ...    cqi_min=${cqi_min}  cqi_max=${cqi_max}
    ...    cqi_step=${cqi_step}  cqi_period=${cqi_period}
    Run Keyword If    ${num_sa_ue}!=${0}    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=csi_override
    ...                                                                                       profile_id=2  action=activate

    Run Keyword If    ${num_nsa_ue}!=${0}    Update UE Channel State Information
    ...    profile_id=3  cqi_mode=${cqi_mode}  cqi=${cqi}  cqi_min=${cqi_min}  cqi_max=${cqi_max}
    ...    cqi_step=${cqi_step}  cqi_period=${cqi_period}
    Run Keyword If    ${num_nsa_ue}!=${0}    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=101  testmode=csi_override
    ...                                                                                        profile_id=3  action=activate


    ${tOneway}=    Evaluate    __import__('math').ceil((${cqi_max}-${cqi})/${cqi_step}*${cqi_period}*${csi_period})
    BuiltIn.Sleep  ${tOneway}

Changing CQI values for HR
    ${cqi_mode}=   Set Variable    oneway
    ${cqi}=        Set Variable    8
    ${cqi_min}=    Set Variable    0
    ${cqi_max}=    Set Variable    15
    ${cqi_step}=   Set Variable    1
    ${cqi_period}=     Set Variable    3
    # CSI period probably depends on frequency and TDD/FDD
    ${csi_period}=     Set Variable    0.16

    Update UE Channel State Information  profile_id=2  cqi_mode=${cqi_mode}  cqi=${cqi}  cqi_min=${cqi_min}  cqi_max=${cqi_max}
    ...    cqi_step=${cqi_step}  cqi_period=${cqi_period}
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=csi_override  profile_id=2  action=activate

    ${tOneway}=    Evaluate    __import__('math').ceil((${cqi_max}-${cqi})/${cqi_step}*${cqi_period}*${csi_period})
    BuiltIn.Sleep  ${tOneway}

Changing CQI values and triggering CSI DTX
    ${cqi_mode}=   Set Variable    oneway
    ${cqi}=        Set Variable    8
    ${cqi_min}=    Set Variable    0
    ${cqi_max}=    Set Variable    15
    ${cqi_step}=   Set Variable    1
    ${cqi_period}=     Set Variable    3
    # CSI period probably depends on frequency and TDD/FDD
    ${csi_period}=     Set Variable    0.16

    Update UE Channel State Information  profile_id=2  cqi_mode=${cqi_mode}  cqi=${cqi}  cqi_min=${cqi_min}  cqi_max=${cqi_max}
    ...    cqi_step=${cqi_step}  cqi_period=${cqi_period}
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=csi_override  profile_id=2  action=activate

    ${tOneway}=    Evaluate    __import__('math').ceil((${cqi_max}-${cqi})/${cqi_step}*${cqi_period}*${csi_period})
    BuiltIn.Sleep  ${tOneway}

    Update UE Radio Link Failure  profile_id=2  num_stop_csi_report=100
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=2  action=activate


Stop CSI DTX
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=2  action=deactivate

Save CSI report and UE info dictionary
    ${FILE PATH}=     Set Variable     ${ts_log_dir}/csi_report_and_ue_info_${scenario_name}.json
    ${EXISTS}    Run Keyword And Return Status    File Should Exist    ${FILE PATH}
    Run Keyword If    ${EXISTS}    OperatingSystem.Remove File    ${FILE PATH}
    ${ue_groups}=  Get Dictionary Keys  ${csi_report_and_ue_info_dict}
    FOR  ${ue_group}  IN  @{ue_groups}
        ${rntis_in_ue_group}=    template.get_rntis_for_ue_group    scenario_name=${scenario_name}    ue_group_name=${ue_group}
        Set To Dictionary    ${csi_report_and_ue_info_dict["${ue_group}"]}    rntis    ${rntis_in_ue_group}
    END
    FOR  ${ue_group}  IN  @{ue_groups}
        ${rntis_in_ue_group}=    template.get_rntis_lte_for_ue_group    scenario_name=${scenario_name}    ue_group_name=${ue_group}
        Set To Dictionary    ${csi_report_and_ue_info_dict["${ue_group}"]}    rntis_lte    ${rntis_in_ue_group}
    END
    nps_tarf_tools.write_dictionary_to_json    dir_path=${ts_log_dir}/
    ...                                         dictionary=${csi_report_and_ue_info_dict}
    ...                                         filename=csi_report_and_ue_info_${scenario_name}.json

Apply ul_cell_noise Testmode to All UEs before attach
    ${noise}=    Set Variable if  'TDD' in '${scenario_name}'    ${-740}    ${-760}
    Send Egate Command and verify output
    ...    cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    BuiltIn.Sleep    1s    reason=wait command to be executed
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...    cmd=ul_cell_noise_testmode_nr profile_id=2    pass_regexp=ul_cell_noise_testmode_nr Parameters
    #activate ul_cell_noise
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
    BuiltIn.Sleep    1s    reason=wait command to be executed

Apply ul_sinr Testmode to All UEs before attach
    ${attached_ue_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    Set Test Variable  ${attached_ue_list}
    # sinr_target_pusch  pathloss
    ${pathloss_start_dB}=    set variable if    'FDD' in '${scenario_name}'  105    95
    ${pathloss_end_dB}=    set variable if    'FDD' in '${scenario_name}'    126    119
    ${pathloss_start_dB}=    set variable if    'TDD' in '${scenario_name}'  105    95
    ${pathloss_end_dB}=    set variable if    'TDD' in '${scenario_name}'    126    119

    Set Test Variable    ${pathloss_start_dB}
    Set Test Variable    ${pathloss_end_dB}
    ute-wtssim-ue-Keywords.Configure NR UL SINR testmode    profile_id=4    pathloss=${pathloss_start_dB}
    FOR  ${ue_id}  IN  @{attached_ue_list}
        ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=${ue_id}  testmode=ul_sinr  profile_id=4  action=activate
    END

Triggering HARQ DTX
    ute-wtssim-ue-Keywords.Update UE Radio Link Failure  profile_id=4  num_stop_dlharq_tx=5
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=4  action=activate
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=4  action=deactivate
    BuiltIn.Sleep    0.5
    ute-wtssim-ue-Keywords.Update UE Radio Link Failure  profile_id=4  num_stop_dlharq_tx=5
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=4  action=activate
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=1  testmode=rlf  profile_id=4  action=deactivate

#-----------For Test Execution - scenario_TC_NSA_TDD_Msg2----------------------------------------------------------------------------[150 characters]
Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Msg2
    BuiltIn.log    ---> Scenario '${scenario_name}' started    console=yes
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${False}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    #--- SA attach UE1 -------------------------------------------------------------------------------------------------------------[150 characters]
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_1}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_1}
    BuiltIn.Log To Console    Initiate_Timing_Advance for ue ${ue_id_1} is OK
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_2}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_2}
    Scenario-Common-Keywords.Run SA Attach Scripts    list_of_sa_ue_to_be_attached=${non_attached_ues_dict}   ignore_auto_attach=${True}
    BuiltIn.log    ---> UE${ue_id_1} attached    console=yes
    BuiltIn.log    ---> UE${ue_id_2} attached    console=yes
    BuiltIn.sleep   1s
    ute-wtssim-ue-Keywords.ue_rrc_reestablish on UE    ue_id=${ue_id_1}   cell_id=${tdd_cell_1}    loop_number=9
    BuiltIn.sleep   1s
    ute-wtssim-ue-Keywords.ue_rrc_reestablish on UE    ue_id=${ue_id_2}   cell_id=${tdd_cell_2}    loop_number=15
    BuiltIn.sleep   1s
    # ${ue_parameters}=  Get From Dictionary  ${non_attached_ues_dict}  ${ue_id_1}
    # ${optional_args}=  Set Variable  ${ue_parameters["optional_dual_connectivity_args"]}
    # BuiltIn.log     optional_args=${optional_args}    console=yes
    # ${bearer_id}=  Set Variable  ${ue_parameters["bearer"]}
    # Start data traffic in egate  ue_id=${ue_id_1}  id=${bearer_id}   direction=dl  mbps=5  trf_id=1
    # Start data traffic in egate  ue_id=${ue_id_1}  id=${bearer_id}   direction=ul  mbps=5  trf_id=1
    # BuiltIn.log    ---> User Data on UE${ue_id_1} started    console=yes
    # BuiltIn.sleep   2s

    #--- Deregister UE1 -------------------------------------------------------------------------------------------------------------[150 characters]
    # FOR  ${nsa_attach_params}  IN  ${non_attached_ues_dict}
    #    Scenario-Common-Keywords.Detach LTE UE  ${nsa_attach_params}
    # END
    # BuiltIn.log    ---> UEs[${ue_id_1}] detached    console=yes
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Save RNTIs

#-----------For Test Execution - scenario_TC_NSA_TDD_Paging--------------------------------------------------------------------------[150 characters]
Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Paging
    BuiltIn.log    ---> Scenario '${scenario_name}' started    console=yes
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${False}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    ute-wtssim-ue-Keywords.Changing cell Noise level for all cells    noise=${default_noise}    cell_id=1
    ute-wtssim-ue-Keywords.Changing cell Noise level for all cells    noise=${default_noise}    cell_id=2
    ute-wtssim-ue-Keywords.Changing UE Pathloss level for all UEs  non_attached_ues_list=${non_attached_ues_list}
    ...                                                            pathloss_value=${default_pathloss}
    #--- SA attach UE1 -------------------------------------------------------------------------------------------------------------[150 characters]
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_1}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_1}
    BuiltIn.Log To Console    Initiate_Timing_Advance for ue ${ue_id_1} is OK
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_2}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_2}
    BuiltIn.sleep    1s
    Scenario-Common-Keywords.Run SA Attach Scripts    list_of_sa_ue_to_be_attached=${non_attached_ues_dict}   ignore_auto_attach=${True}
    BuiltIn.log    ---> UE${ue_id_1} attached    console=yes
    BuiltIn.log    ---> UE${ue_id_2} attached    console=yes
    BuiltIn.sleep   1s
    # ute-wtssim-ue-Keywords.Simulate Pathloss    pathloss_start_dB=${pathloss_start_dB}+${1}    pathloss_end_dB=${pathloss_end_dB}
    # ...                                         pathloss_step_dB=1
    BuiltIn.log    ---> UE${ue_id_1} Paging from AMF on UE    console=yes
    ute-wtssim-ue-Keywords.Paging from AMF on UE    ue_id=${ue_id_1}    loop_number=10
    BuiltIn.sleep   1s
    BuiltIn.log    ---> UE${ue_id_2} Paging from AMF on UE    console=yes
    ute-wtssim-ue-Keywords.Paging from AMF on UE    ue_id=${ue_id_2}    loop_number=10
    BuiltIn.sleep   1s

    # ${ue_parameters}=  Get From Dictionary  ${non_attached_ues_dict}  ${ue_id_1}
    # ${optional_args}=  Set Variable  ${ue_parameters["optional_dual_connectivity_args"]}
    # BuiltIn.log     optional_args=${optional_args}    console=yes
    # ${bearer_id}=  Set Variable  ${ue_parameters["bearer"]}
    # ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue_id_1}  id=${bearer_id}   direction=dl  mbps=5  trf_id=1
    # ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue_id_1}  id=${bearer_id}   direction=ul  mbps=5  trf_id=1

    #--- Deregister UE  -------------------------------------------------------------------------------------------------------------[150 characters]
    ${status}=    Run Keyword And Return Status     ute-wtssim-ue-Keywords.UE Deregister    ${ue_id_1}
    Run Keyword If    not ${status}    BuiltIn.log    Try to Deregister SA UE on UE${ue_id_1} FAILED!    level=ERROR
    ...    ELSE                        BuiltIn.Log To Console    UE${ue_id_1} is deregistered from 5G in SA Mode!
    ${status}=    Run Keyword And Return Status     ute-wtssim-ue-Keywords.UE Deregister    ${ue_id_2}
    Run Keyword If    not ${status}    BuiltIn.log    Try to Deregister SA UE on UE${ue_id_2} FAILED!    level=ERROR
    ...    ELSE                        BuiltIn.Log To Console    UE${ue_id_1} is deregistered from 5G in SA Mode!
    BuiltIn.log    ---> UEs[${ue_id_1}] detached    console=yes
    BuiltIn.log    ---> UEs[${ue_id_2}] detached    console=yes
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Save RNTIs

Run Feature specific keywords during traffic before detach for scenario_TC_SA_TDD_Paging_wPLVariation
    BuiltIn.log    ---> Scenario '${scenario_name}' started    console=yes
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${False}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    ute-wtssim-ue-Keywords.Changing cell Noise level for all cells    noise=${default_noise}    cell_id=1
    ute-wtssim-ue-Keywords.Changing cell Noise level for all cells    noise=${default_noise}    cell_id=2
    ute-wtssim-ue-Keywords.Changing UE Pathloss level for all UEs  non_attached_ues_list=${non_attached_ues_list}
    ...                                                            pathloss_value=${default_pathloss}
    #--- SA attach UE1 -------------------------------------------------------------------------------------------------------------[150 characters]
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_1}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_1}
    BuiltIn.Log To Console    Initiate_Timing_Advance for ue ${ue_id_1} is OK
    ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue_id_2}-${1}]}
    CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue_id_2}
    BuiltIn.sleep    1s
    Scenario-Common-Keywords.Run SA Attach Scripts    list_of_sa_ue_to_be_attached=${non_attached_ues_dict}   ignore_auto_attach=${True}
    BuiltIn.log    ---> UE${ue_id_1} attached    console=yes
    BuiltIn.log    ---> UE${ue_id_2} attached    console=yes
    BuiltIn.sleep   1s
    Simulate Pathloss and Ues Paging   pathloss_start_dB=${pathloss_start_dB}+${1}
    ...                                pathloss_end_dB=${pathloss_end_dB}
    ...                                pathloss_step_dB=1
    ...                                ue1_id=${ue_id_1}
    ...                                ue2_id=${ue_id_2}
    BuiltIn.sleep   2s

    #--- Deregister UE  -------------------------------------------------------------------------------------------------------------[150 characters]
    ${status}=    Run Keyword And Return Status     ute-wtssim-ue-Keywords.UE Deregister    ${ue_id_1}
    Run Keyword If    not ${status}    BuiltIn.log    Try to Deregister SA UE on UE${ue_id_1} FAILED!    level=ERROR
    ...    ELSE                        BuiltIn.Log To Console    UE${ue_id_1} is deregistered from 5G in SA Mode!
    ${status}=    Run Keyword And Return Status     ute-wtssim-ue-Keywords.UE Deregister    ${ue_id_2}
    Run Keyword If    not ${status}    BuiltIn.log    Try to Deregister SA UE on UE${ue_id_2} FAILED!    level=ERROR
    ...    ELSE                        BuiltIn.Log To Console    UE${ue_id_1} is deregistered from 5G in SA Mode!
    BuiltIn.log    ---> UEs[${ue_id_1}] detached    console=yes
    BuiltIn.log    ---> UEs[${ue_id_2}] detached    console=yes
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Save RNTIs

Simulate Pathloss and Ues Paging
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=129    ${pathloss_step_dB}=1    ${ue1_id}=1     ${ue2_id}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
        ute-wtssim-ue-Keywords.Configure NR UL SINR testmode    profile_id=9    pathloss=${pathloss}
        BuiltIn.sleep     1s
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue1_id}  direction=dl  mbps=150  trf_id=2  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue1_id}  direction=dl  mbps=50   trf_id=3  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue1_id}  direction=ul  mbps=100  trf_id=4  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue2_id}  direction=dl  mbps=150  trf_id=2  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue2_id}  direction=dl  mbps=50   trf_id=3  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${ue2_id}  direction=ul  mbps=100  trf_id=4  pdu=1  qfi=1  seconds=30
        BuiltIn.sleep     3s
        ute-wtssim-ue-Keywords.Paging from AMF on UE    ue_id=${ue1_id}    loop_number=1
        BuiltIn.sleep     1s
        ute-wtssim-ue-Keywords.Paging from AMF on UE    ue_id=${ue2_id}    loop_number=1
    END

#-----------For Test Execution - others----------------------------------------------------------------------------------------------[150 characters]

run Keywords during traffic
    Deregister UEs
    Register UEs and Start Traffic

Online modification of NIDD parameters
    AL2 threshold modification
    Set pdcchCqiOffsetHR to 50
    Deregister UEs
    Register UEs and Start Traffic
    Set pdcchCqiOffsetHR to 0

set administrativeState to ${administrativeState} for Cell ${tdd_cell_id}
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_path}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${dist_name}=    Set Variable    ${distName_NRCELL[${tdd_cell_id}-1]}
    ${commissioning_data}=  CB013715_commissioning.get_data_for_commissioning_administrativeState    scf_data=${scf_content}
    ...                                                                          dist_name=${dist_name}
    ...                                                                          administrativeState=${administrativeState}
    ${config_change_needed}    Run Keyword And Return Status    Should Not Be Empty      ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  BuiltIn.Log to console  Following SCF Paramaters will be changed for ${scenario_name}: ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  commissioning.Commission Managed Object List  ${commissioning_data}
    ...    ELSE     BuiltIn.Log to console     the requested change already exists and will NOT be overwritten!
    # update local scf
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb


Set actHighSpeedCell to ${value} with prachSequenceType to ${prachSequenceType} and prachConfigurationIndex to ${prachIndex} on Cell ${tdd_cell_id}
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_path}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${dist_name}=    Set Variable    ${distName_NRCELL[${tdd_cell_id}-1]}
    ${value_cast_to_boolean}    convert to Boolean    ${value}
    ${zeroCorrelationZoneConfig}    set variable if    '${prachSequenceType}'=='RestrictedTypeB'     12    14
    ${commissioning_data}=  CB013715_commissioning.Get Data For Commissioning    scf_data=${scf_content}    dist_name=${dist_name}
    ...                                                                          actHighSpeedCell=${value_cast_to_boolean}
    ...                                                                          prachSequenceType=${prachSequenceType}
    ...                                                                          prachConfigurationIndex=${prachIndex}
    ...                                                                          zeroCorrelationZoneConfig=${zeroCorrelationZoneConfig}
    ${config_change_needed}    Run Keyword And Return Status    Should Not Be Empty      ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  BuiltIn.Log to console  Following SCF Paramaters will be changed for ${scenario_name}: ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  commissioning.Commission Managed Object List  ${commissioning_data}
    ...    ELSE     BuiltIn.Log to console     the requested change already exists and will NOT be overwritten!
    # update local scf
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb


vesrion1 Set actHighSpeedCell to ${value} with prachSequenceType to ${prachSequenceType}
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ScfChanges.Load Scf    ${scf_content}
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_path}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${dist_name}=    Set Variable    ${distName_NRCELL[${tdd_cell_2}-1]}
    ScfChanges.Add Robot Change     regex=${dist_name}     p_name=actHighSpeedCell             value=${value}
    IF    '${value}'=='true'
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=prachSequenceType            value=${prachSequenceType}
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=dlDMRSAdditionalPosition     value=Two additional DMRS
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=ulDMRSAdditionalPosition     value=Two additional DMRS
    ELSE
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=prachSequenceType            value=${prachSequenceType}
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=dlDMRSAdditionalPosition     value=One additional DMRS
        ScfChanges.Add Robot Change     regex=${dist_name}     p_name=ulDMRSAdditionalPosition     value=One additional DMRS
    END
    ${commissioning_data}=  ScfChanges.Get Modifications For Commissioning
    ${config_change_needed}    Run Keyword And Return Status    Should Not Be Empty      ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  Log to console  Following SCF Paramaters will be changed for ${scenario_name}: ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  commissioning.Commission Managed Object List  ${commissioning_data}
    ELSE     BuiltIn.Log to console     the requested change already exists and will NOT be overwritten!

Set actHighSpeedCell to ${value} with prachSequenceType to ${prachSequenceType} and prachRootSequence to ${prachRootSequence} on Cell ${tdd_cell_id}
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${scf_path}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${dist_name}=    Set Variable    ${distName_NRCELL[${tdd_cell_id}-1]}
    ${value_cast_to_boolean}    convert to Boolean    ${value}
    ${commissioning_data}=  CB013715_commissioning.Get Data For Commissioning    scf_data=${scf_content}    dist_name=${dist_name}
    ...                                                                          actHighSpeedCell=${value_cast_to_boolean}
    ...                                                                          prachSequenceType=${prachSequenceType}
    ...                                                                          prachRootSequenceIndex=${prachRootSequence}
    ${config_change_needed}    Run Keyword And Return Status    Should Not Be Empty      ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  BuiltIn.Log to console  Following SCF Paramaters will be changed for ${scenario_name}: ${commissioning_data}
    Run Keyword If  ${config_change_needed}
    ...  commissioning.Commission Managed Object List  ${commissioning_data}
    ...    ELSE     BuiltIn.Log to console     the requested change already exists and will NOT be overwritten!
    # update local scf
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb


AL2 threshold modification
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ScfChanges.Load Scf    ${scf_content}
    ${suite_folder}=    testline-Keywords.Get test suite result base directory
    ${dist_name}=    Set Variable    MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    ScfChanges.Add Robot Change     regex=${dist_name}      list_name=dynamicAggregationLevelHRSet    p_name=cqiDciCssAl2HR     value=130
    ScfChanges.Add Robot Change    regex=${dist_name}    list_name=dynamicAggregationLevelHRSet    p_name=lowOlcCqiOffsetHR    value=1
    ${commissioning_data}=  ScfChanges.Get Modifications For Commissioning
    commissioning.Commission Managed Object List  ${commissioning_data}

Set pdcchCqiOffsetHR to ${value}
    ${scf_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    ${scf_content}=  OperatingSystem.Get File    ${scf_path}
    ScfChanges.Load Scf    ${scf_content}
    ${suite_folder}=    testline-Keywords.Get test suite result base directory
    ${dist_name}=    Set Variable    MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+
    ScfChanges.Add Robot Change     regex=${dist_name}      list_name=dynamicAggregationLevelHRSet     p_name=pdcchCqiOffsetHR     value=${value}
    ${commissioning_data}=  ScfChanges.Get Modifications For Commissioning
    commissioning.Commission Managed Object List  ${commissioning_data}

Register UEs and Start Traffic
    ${ue_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa
    ${ue_list}=  get dictionary keys  ${ue_dict}
    Log to Console  Attaching UEs to 5G
    Scenario-Common-Keywords.Run SA Attach Scripts  ${ue_dict}
    # CQI change needed for re-initializing testmode for UE
    Change CQI on Airphone to 13
    FOR  ${id}  IN  @{ue_list}
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${id}  direction=dl  mbps=150  trf_id=2  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${id}  direction=dl  mbps=50   trf_id=3  pdu=1  qfi=1  seconds=30
        ute-wtssim-ue-Keywords.Start data traffic in egate  ue_id=${id}  direction=ul  mbps=100  trf_id=4  pdu=1  qfi=1  seconds=30
    END
    BuiltIn.sleep    3s     Wait for start Traffic

UE Deregister
    [Documentation]
    ...
    ...    | ue_id              | Specified UE ID                                   |
    ...    | ue_deregister_type | Type of UE initiated deregister procedure         |
    ...    | by                 | Device type initiating the deregister procedure   |
    ...
    [Arguments]   ${ue_id}=1   ${ue_deregister_type}=switch_off   ${by}=ue
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_deregister id=${ue_id} ue_deregister_type=${ue_deregister_type} by=${by}
    ...   pass_regexp=UE${ue_id}: detached|UE${ue_id} .* already turned off
    BuiltIn.Log   UE${ue_id} deregistration is successful   console=${P_console}

Deregister UEs
    ${ue_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa
    ${ue_list}=  get dictionary keys  ${ue_dict}
    FOR  ${id}  IN  @{ue_list}
        # ute-wtssim-ue-Keywords.UE Deregister     ue_id=${id}
        CB013715_scenario_modifications.UE Deregister     ue_id=${id}
    END

Display Traffic Data Rate
    ${bearer_stats_attribs_nsa}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    ${all_bearer_stats}=  create list
    ${status}  ${output_nsa}=  run keyword and ignore error  ute-wtssim-ue-Keywords.Get Bearer Stats From Egate
    ...  ue_id=${bearer_stats_attribs_nsa["ues"]}  trf_id=${bearer_stats_attribs_nsa["trf_ids"]}
    ...  id=${bearer_stats_attribs_nsa["bearers"]}  dir=bi
    ${list_of_nsa_ue_to_be_attached}=   template.get_attach_list  scenario_name=${scenario_name}  ue_type=nsa
    nps_tarf_tools.log_to_console_with_time_prefix    list_of_nsa_ue_to_be_attached is ${list_of_nsa_ue_to_be_attached}   level=INFO
    ${ue_nsa_number}=  get length  ${list_of_nsa_ue_to_be_attached}
    IF    '${status}'=='FAIL'
        Run Keyword if    '${ue_nsa_number}'!='${0}'
        ...    nps_tarf_tools.log_to_console_with_time_prefix    Bearer Stats not collected for NSA    level=INFO
    ELSE
        Log to console    Current throughput for UE${bearer_stats_attribs_nsa["ues"]} is ${output_nsa} bps
        Append To List  ${all_bearer_stats}  ${output_nsa}
        # ${attached_ues_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
        # sort list  ${attached_ues_list}
        ${attached_ues_dict}=    template.Get Attach List   scenario_name=${scenario_name}    ue_type=nsa
        ...                                                 with_auto_attach=${TRUE}
        ${attached_ues_list}=  get dictionary keys  ${attached_ues_dict}
        sort list  ${attached_ues_list}
        ${scell_idx}     set variable    0-10
        FOR  ${ue_id}  IN  @{attached_ues_list}
            ${pdsch_ue_stats}    ute-wtssim-ue-Keywords.Get PDSCH UE Stats for Given CC    ue_id=${ue_id}    scell_idx=${scell_idx}
	        nps_tarf_tools.log_to_console_with_time_prefix     ue_stats_nr for UedId=${ue_id}   level=INFO
	        bearer_stats_helpers.get_tput_from_ue_stats    ue_stats_str=${pdsch_ue_stats}     UeId=${ue_id}    dir=PDSCH
	        ${pusch_ue_stats}    ute-wtssim-ue-Keywords.Get PUSCH UE Stats for Given CC   ue_id=${ue_id}    scell_idx=${scell_idx}
	        nps_tarf_tools.log_to_console_with_time_prefix     ue_stats_nr for UedId=${ue_id}   level=INFO
	        bearer_stats_helpers.get_tput_from_ue_stats    ue_stats_str=${pusch_ue_stats}     UeId=${ue_id}    dir=PUSCH
        END
    END
    ${list_of_sa_ue_to_be_attached}=    template.get_attach_list  scenario_name=${scenario_name}  ue_type=sa
    ${ue_sa_number}=  get length  ${list_of_sa_ue_to_be_attached}
    nps_tarf_tools.log_to_console_with_time_prefix    list_of_sa_ue_to_be_attached is ${list_of_sa_ue_to_be_attached}  level=INFO
    ${status}  ${output_sa}=  Run Keyword And Ignore Error    ute-wtssim-ue-Keywords.Get Bearer Stats From Egate
    ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
    ...  qfi=${bearer_stats_attribs_sa["qfis"]}  dir=bi
    IF    '${status}'=='FAIL'
        Run Keyword if    '${ue_sa_number}'!='${0}'
        ...    nps_tarf_tools.log_to_console_with_time_prefix     Bearer Stats not collected for SA    level=INFO
    ELSE
        Log to console    Current throughput for UE${bearer_stats_attribs_sa["ues"]} is ${output_sa} bps
        Append To List  ${all_bearer_stats}  ${output_sa}
        # ${attached_ues_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
        # sort list  ${attached_ues_list}
        ${attached_ues_dict}=    template.Get Attach List    scenario_name=${scenario_name}    ue_type=sa
        ...                                                  with_auto_attach=${TRUE}
        ${attached_ues_list}=  get dictionary keys  ${attached_ues_dict}
        sort list  ${attached_ues_list}
        FOR  ${ue_id}  IN  @{attached_ues_list}
            ${ue_parameters}=  Get From Dictionary  ${attached_ues_dict}  ${ue_id}
            # nps_tarf_tools.log_to_console_with_time_prefix    ====> get throughput for ue${ue_id}    level=INFO
            ${ul_throughput_for_ue}=  nps_dss_tools.get_bearer_stats_SA   ue=${ue_id}
            ...                                                           pdu=${ue_parameters["pdu"]}   qfi=1    direction=ul  alias=ap_egate
            nps_tarf_tools.log_to_console_with_time_prefix     ul throughput for ue${ue_id} is ${ul_throughput_for_ue} Mbps    level=INFO
            ${ul_tput_round_value}=     Evaluate      round(${ul_throughput_for_ue})

            ${dl_throughput_for_ue}=  nps_dss_tools.get_bearer_stats_SA   ue=${ue_id}
            ...                                                           pdu=${ue_parameters["pdu"]}   qfi=1    direction=dl  alias=ap_egate
            nps_tarf_tools.log_to_console_with_time_prefix     dl throughput for ue${ue_id} is ${dl_throughput_for_ue} Mbps    level=INFO
            ${dl_tput_round_value}=     Evaluate      round(${dl_throughput_for_ue})

            ute-wtssim-ue-Keywords.Display PDSCH and PUSCH ue_stats_nr    ue_id=${ue_id}    CallType=SA
            ...                                                           DlTput=${dl_tput_round_value}     UlTput=${ul_tput_round_value}
        END
    END
    bearer_stats_helpers.Write To Json File  ${ts_log_dir}/${scenario_name}_bearer_stats.json  ${all_bearer_stats}
    ${df} =    bearer_stats_helpers.Convert Bearer Stats to DF    json_file=${ts_log_dir}/${scenario_name}_bearer_stats.json
    ...                                                           write_to_pickle=${False}
    bearer_stats_helpers.Write Csv    ${ts_log_dir}/${scenario_name}_bearer_stats.csv    ${all_bearer_stats}

Display Traffic Data Rate Version1
    ${bearer_stats_attribs_nsa}  ${bearer_stats_attribs_sa}=  template.get_bearer_stat_params  scenario_name=${scenario_name}
    ${tp}=  Run Keyword And Ignore Error    ute-wtssim-ue-Keywords.Get Bearer Stats From Egate
    ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
    ...  qfi=${bearer_stats_attribs_sa["qfis"]}  dir=bi
    Log to console    Current throughput for UE${bearer_stats_attribs_sa["ues"]} is ${tp} bps

    ${attached_ue_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    FOR  ${ue_id}  IN  @{attached_ue_list}
        # nps_tarf_tools.log_to_console_with_time_prefix    ====> get throughput for ue${ue_id}    level=INFO
        ${ul_throughput_for_ue}=  nps_dss_tools.get_bearer_stats_SA   ue=${ue_id}
        ...                                                           pdu=1   qfi=1    direction=ul  alias=ap_egate
        nps_tarf_tools.log_to_console_with_time_prefix     ul throughput for ue${ue_id} is ${ul_throughput_for_ue} Mbps    level=INFO

        ${dl_throughput_for_ue}=  nps_dss_tools.get_bearer_stats_SA   ue=${ue_id}
        ...                                                           pdu=1   qfi=1    direction=dl  alias=ap_egate
        nps_tarf_tools.log_to_console_with_time_prefix     dl throughput for ue${ue_id} is ${dl_throughput_for_ue} Mbps    level=INFO
    END

Get UE IDs from Scenario
    ${attached_ue_list}=    Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    sort list  ${attached_ue_list}
    ${ue_id}=      set variable    ${attached_ue_list}[0]
    ${ue_id_2}=    set variable    ${attached_ue_list}[1]
    ${ue_id_3}=    set variable    ${attached_ue_list}[2]
    ${ue_id_4}=    set variable    ${attached_ue_list}[3]
    ${ue_id_5}=    set variable    ${attached_ue_list}[4]
    ${ue_id_6}=    set variable    ${attached_ue_list}[5]
    Set Test Variable    ${ue_id}
    Set Test Variable    ${ue_id_2}
    Set Test Variable    ${ue_id_3}
    Set Test Variable    ${ue_id_4}
    Set Test Variable    ${ue_id_5}
    Set Test Variable    ${ue_id_6}

#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]
Change RD Parameters in swconfig File for CB013715
    [Documentation]     Add or Modify the RAD params
    ...                 0x58057A=4 : L2 feature flags : ERR & WRN & INF & DBG
    ...                 0x58057C=0x3800 : rdFeatureFlagBitmap1
    ...                     bit 11 - PRB_POOLING.BASIC,
    ...                     bit 12   PRB_POOLING.DL,
    ...                     bit 13 - PRB_POOLING.UL ==> binary 0011 1000 0000 0000
    ...                 0x58057C=0x10000 : rdFeatureFlagBitmap1
    ...                     bit 16   BWP
    Dated Log New Line   Add RAD params......
    dated log    -----> field=0x3F007C value=500 #GNB BIP size, unit is M
    dated log    -----> field=0x4B000F value=1 # 1=RF_SW_Version_check_disabled
    dated log    -----> field=0x5801CB value=0 # 0=rdFakeUeSchedulingEnable
    dated log    -----> field=0x580955 value=10 # 10=rdMeaningfulDlLoadMeasurementDifference
    dated log    -----> field=0x580956 value=10 # 10=rdMeaningfulUlLoadMeasurementDifference

    ${rad_param_1}=      create dictionary       field=0x3F007C    value=500
    ${rad_param_2}=      create dictionary       field=0x4B000F    value=1   # RF_SW_Version_check_disabled
    ${rad_param_3}=      create dictionary       field=0x5801CB    value=0   # rdFakeUeSchedulingEnable
    ${rad_param_4}=      create dictionary       field=0x580955    value=10   # rdMeaningfulDlLoadMeasurementDifference
    ${rad_param_5}=      create dictionary       field=0x580956    value=10   # rdMeaningfulUlLoadMeasurementDifference
    # ${rad_param_list}=       Create List         ${rad_param_1}     ${rad_param_2}    ${rad_param_3}
    # ...                                          ${rad_param_4}     ${rad_param_5}
    ${rad_param_list}=       Create List      0x3F007C=500
    ...                                       0x4B000F=1
    ...                                       0x5801CB=0
    ...                                       0x580955=10
    ...                                       0x580956=10
    # SetConfig.Set Fields in swconfig DU       param_list=${rad_param_list}
    testline-Keywords.Update SW Config file on System Module    param_list=${rad_param_list}

    ${l2ps_debug_swconfig_gnb}=      Set L2PS Debug Specific RAD
    TARF-Keywords.Update gNB Swconfig Content   ${l2ps_debug_swconfig_gnb}
    Dated Log New Line   RAD params update completed
    Return from keyword


Set L2PS Debug Specific RAD
    ${swconfig_gnb}    Create List
    return from keyword    ${swconfig_gnb}

Set L2PS Debug Specific RAD Exemple
    [Documentation]   Author: Ch SAMSON , set L2PS debug Rad parameters

    ${l2ps_0x58057a}=      create dictionary          field=0x58057a     value=4
    # ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x10000
    # ${l2ps_0x58057b}=      create dictionary          field=0x58057b     value=0x2
    # ${l2ps_0x58057d}=      create dictionary          field=0x58057d     value=0x200
    # ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x2800
    # ${l2ps_0x580580}=      create dictionary          field=0x580580     value=0x800
    ${l2ps_0x58057c}=      create dictionary          field=0x58057c     value=0x2000

    ${swconfig_gnb}=       run Keyword if    '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'     Create List     ${l2ps_0x58057a}
    ...                                                                                                   ${l2ps_0x58057c}
    # ...                                                                                                   ${l2ps_0x580580}
    ...   ELSE                                                                            Create List

    run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log    -----> field=0x58057a value=4 # ERR & WRN & INF & DBG
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x10000 #rdFeatureFlagBitmap1 (L2.L2_PS.BWP)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057b value=0x2 #rdFeatureFlagBitmap1 (L2.L2_PS.CELL)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057d value=0x200 #rdFeatureFlagBitmap1 (L2.L2_PS.UL.DCI)

    # rdFeatureFlagBitmapLevel  (0x57A) = 4
    # rdFeatureFlagBitmap5 (0x580580) = 0x400 (L2.L2_PS.NBR_SAS_CONGESTIONCTRL)
    # rdFeatureFlagBitmap5 (0x580580) = 0x800 (L2.L2_PS.PRB_POOLING.SPECIAL_DBG)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x1800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.DL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2800    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.UL)
    # rdFeatureFlagBitmap1  (0x58057c) = 0x2000    (L2.L2_PS.PRB_POOLING.UL)

    # ${text}=     Catenate    (L2.L2_PS.PRB_POOLING.BASIC and L2.L2_PS.PRB_POOLING.UL)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x2800 #rdFeatureFlagBitmap1 ${text}
    ${text}=     Catenate    (L2.L2_PS.PRB_POOLING.UL)
    run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x58057c value=0x2000 #rdFeatureFlagBitmap1 ${text}
    # ${text}=    Catenate     (L2.L2_PS.PRB_POOLING.SPECIAL_DBG)
    # run Keyword if  '${SHOULD_UPDATE_DEBUG_L2PS_RAD}' == '1'  dated log  -----> field=0x580580 value=0x800 #rdFeatureFlagBitmap5 ${text}

    [return]    ${swconfig_gnb}

Add RD Parameters in AP swconfig File
    [Documentation]    Additional AP RD flags
    @{ap_params}=  create list  0x70698=-150     # To reduce PUSCH SINR by 10dB on gNB side
    Dated Log New Line   Add AP RAD params......
    dated log    -----> field=0x70698 value=-150  #To reduce PUSCH SINR by 10dB on gNB side
    testline-Keywords.Update SW Config file on AP System Module  param_list=${ap_params}
    # Set suite variable    ${force_reboot}    ${true}

#-----------For basic configuration Changes------------------------------------------------------------------------------------------[150 characters]
Update Basic Configuration File
    wts_cfg.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    wts_cfg.Insert    set_qosflow id=4 5qi=7    after    set_qosflow id=3
    wts_cfg.Insert    set_qosflow id=5 5qi=8    after    set_qosflow id=4
    wts_cfg.Modify    command=nwslice_set id=1    modification=qos_flows=1,2,3,4,5
    wts_cfg.Insert    amf_param id=1 empty_pdu_session_list=on                                             after    nwslice_set id=1
    wts_cfg.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
    CB013715_scenario_modifications.Update SpecificParameters to setup DSS configuration In WTS Cfg File      ${TestDSSContext}
    common_Dss_Keywords.Modify Bandwidth Parameters for WTS   ${TestDSSContext}  w_force_ue_capa=False    w_rename=False
    IF    ${cell2_is_Dss}
        CB013715_scenario_modifications.Modify basic_setup for cell2    ${TestDSSContextCell2}
    END

# BEWARE : with 2 Cells !!!!
Update gNBId and eNBId In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup DSS configuration
    [Arguments]            ${cfg_file}    ${eNBId}=2     ${gNBId}=1

    # for eNB
    run    command=sed -i 's|set_enb id=1|set_enb id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|enb_param id=1|enb_param id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=1 enb=1|set_cell id=1 enb=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|enb_endc_param id=1|enb_endc_param id=${eNBId}|g' ${cfg_file}
    run    command=sed -i 's|trace enb=1|trace enb=${eNBId}|g' ${cfg_file}

    # for gNB
    run    command=sed -i 's|set_gnb id=2|set_gnb id=${gNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=1 gnb=2|set_cell id=1 gnb=${gNBId}|g' ${cfg_file}
    run    command=sed -i 's|set_cell id=2 gnb=2|set_cell id=2 gnb=${gNBId}|g' ${cfg_file}
    # adaptation of set_ue simulated id=
    run    command=sed -i 's|enb=1|enb=${eNBId}|g' ${cfg_file}


# to setup DSS configuration In WTS Cfg File
# done once during test suite setup
Update SpecificParameters to setup DSS configuration In WTS Cfg File
    [Documentation]        Update WTS basic.cfg config file with settings needed to setup DSS configuration
    ...      LTE Cell
    ...          set_enb
    ...              id=1
    ...          set_cell
    ...              id=1
    ...              plmn
    ...              earfcn=68787:133323
    ...              enb_id_macro
    ...              xp_management    ===>  ex:  xp_management=on xp=10.0.1.137:32742 xpu=10.0.1.137:32742
    ...              eci
    ...       NR Cell
    ...           set_gnb
    ...               id=2
    ...               gnb_id=0x00000001
    ...               plmn
    ...               xp_management    ===>  ex:  xp_management=on xp=10.0.1.111:32742 xpu=10.0.1.111:32742
    ...           set_cell
    ...               id=1
    ...               gnb=2
    ...       mme_pool_area
    ...               id=1
    ...               plmn
    ...       set_uec file=AirPhoneConfig_19A_V6.0-FDD-FullStack-10MHz_DSS.xml
    ...
    [Arguments]                     ${testParam}

    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # ${new_cfg_filename}    Set Variable    new_${tl.core.cfg_filename}
    # ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Copy file    ${current_cfg_file}    ${current_cfg_file}_bkp

    #---------------------------------------------------------------------------------------------------
    # CRM Partnership Creation (Cell-1.1 -> Cell-2.1)
    #---------------------------------------------------------------------------------------------------
    # ENB CONFIGURATION (default configuration is 10MHz)
    #  Cell-1.1
    #---------------------------------------------------------------------------------------------------
    ${cmd}       catenate    plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    ...                      enb_id_macro=0x00001
    ...                      xp_management=on
    ...                      xp=${testParam.scfFile.xpif_xpifremote.ipAddress}:32742
    ...                      xpu=${testParam.scfFile.xpif_xpifremote.ipAddress}:32742
    ${line}    Set Variable  ${cmd}
    wts_cfg.Modify    set_enb id=1    ${line}

    # earfcn is updated to be in same BW (LTE and NR)
    # both LTE and NR freq are aligned (normalized freq are different betwenn LTE and NR )
    # ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68787:133323
    # lte earfcn=68771:133307 can be used with nrarfcnDl=127100 and nrarfcnUl=136300
    # ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68771:133307
    ${cmd}    catenate    bw=${testParam.seq.bandwidth}
    ...                   eci=0x0000101
    ...                   earfcn=${testParam.scfFile.nrcellfdd.lteearfcnDl}:${testParam.scfFile.nrcellfdd.lteearfcnUl}
    ${line}    Set Variable    ${cmd}
    # ...  bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=${testParam.scfFile.nrcellfdd.lteearfcnDl}:${testParam.scfFile.nrcellfdd.lteearfcnUl}
    wts_cfg.Modify    set_cell id=1 enb=1    ${line}
    # this works for 15Mhz and 20MHz and for 10MHz with BLE=4PRBs (lagacy case)
    #  for LTE
    # Band Name Bandwidth (MHz) Mode Earfcn DL Downlink (MHz)  Earfcn    UL Uplink (MHz)
    #  71   600     35           FDD    68787     637.10       133323      683.10
    #
    # for NR
    # Band  Name  Mode   ,    Downlink nr-arfcn Frequency (MHz) , Uplink nr-arfcn     Frequency (MHz)
    # n71   600    FD    ,         127420          637.1               136620             683.1
    #

    # new settings to test CB013715 BW=10MHz
    #  for LTE
    # Band Name Bandwidth (MHz) Mode Earfcn DL Downlink (MHz)  Earfcn    UL Uplink (MHz)
    #  71   600	    35	        FDD	    68792	637.60	       133328	    683.60
    #
    # for NR
    # Band  Name  Mode   ,    Downlink nr-arfcn Frequency (MHz) , Uplink nr-arfcn     Frequency (MHz)
    # n71	600   FDD	          127520	      637.6	             136720	            683.6
    #

    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    # Cell-2.1
    #---------------------------------------------------------------------------------------------------
    ${cmd}       catenate    gnb_id=0x0000000${testParam.Context.gNBId}
    ...                      plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    ...                      xp_management=on
    ...                      xp=${testParam.scfFile.ipif.localIpAddr}:32742
    ...                      xpu=${testParam.scfFile.ipif.localIpAddr}:32742
    ${line}    Set Variable   ${cmd}
    wts_cfg.Modify    set_gnb id=2    ${line}

    # ${line}    Set Variable    nr_arfcn=136620:127420
    # ${line}    Set Variable     nr_arfcn=136620:127420 tdd_cell=off
    ${line}    Set Variable     nr_arfcn=${testParam.scfFile.nrcellfdd.nrarfcnUl}:${testParam.scfFile.nrcellfdd.nrarfcnDl} tdd_cell=off
    #  nr_arfcn=${ul_nr_arfcn}:${dl_nr_arfcn}   => Done during each test cases
    wts_cfg.Modify    set_cell id=${fdd_cell_1} gnb=2    ${line}
    # DSS Tests are mono Cell only !!! => remove second cell if present
    # Run Keyword And Ignore Error     wts_cfg.Delete    set_cell id=2 gnb=2
    #---------------------------------------------------------------------------------------------------
    # EPC CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Modify    mme_pool_area id=1    plmn=${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}

    #---------------------------------------------------------------------------------------------------
    # UE CONFIGURATION
    #---------------------------------------------------------------------------------------------------
    #  ue_nr_capacities is updated during the test cases
    wts_cfg.Modify    set_ue simulated id=1     enb=${testParam.Context.gNBId}

    # to prevent againt suci is not present in cfg file
    ${status}    ${ue_suci}=  Run Keyword And Ignore Error       wts_cfg.Get parameter    set_ue simulated id=1    suci
    ${new_ue_suci}=     Run Keyword if    '${ue_suci}'!='None'
    ...                nps_dss_tools.Modify suci for UE  ${ue_suci}  ${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    # ${new_ue_suci}=  nps_dss_tools.Modify suci for UE  ${ue_suci}  ${testParam.scfFile.nrbts.mcc}:${testParam.scfFile.nrbts.mnc}
    Run Keyword if    '${ue_suci}'!='None'     Run keywords
    ...                      wts_cfg.Modify     set_ue simulated id=1  suci=${new_ue_suci}     AND
    ...                      Dated log     cfg Modify : new_ue_suci is ${new_ue_suci}

    Modify basic_setup.cfg for 2FDD Setup Dss Cell1    ${testParam}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${current_cfg_file}
    # remove "mapped_earfcn= ..." from the file
    Run          command=sed -i -e 's/mapped_earfcn=[0-9]*:[0-9]*//g' ${current_cfg_file}
    Run          command=sed -i -e 's/GNB_NG_ADDR="10.0.1.2"/GNB_NG_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${current_cfg_file}
    Run          command=sed -i -e 's/GNB_X2_ADDR="10.0.1.2"/GNB_X2_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${current_cfg_file}
    CB013715_scenario_modifications.Update gNBId and eNBId In WTS Cfg File    ${current_cfg_file}  eNBId=${testParam.Context.eNBId}
    ...                                                                       gNBId=${testParam.Context.gNBId}
    # BEWARE that enb in set_ue simulated cmd means gnbId !!!
    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    wts_cfg.Modify     set_ue simulated id=1    enb=${testParam.Context.gNBId}
    Dated log     cfg Modify : "set_ue simulated id=1 enb=" modified with ${testParam.Context.gNBId}
    wts_cfg.Save Wts Cfg        ${current_cfg_file}
    # update variable which contain the WTS (basic_*.cfg) config filename
    # ${tl.core.cfg_filename}   set variable     ${new_cfg_filename}

Modify basic_setup.cfg for 2FDD Setup Dss Cell1
    [Arguments]                     ${testParam}
    wts_cfg.Modify
    ...    set_cell id=${fdd_cell_1} gnb=2
    ...       nr_arfcn=${testParam.scfFile.nrcellfdd.nrarfcnUl}:${testParam.scfFile.nrcellfdd.nrarfcnDl} gscn=${gscn_fdd_cell_1}

Modify basic_setup for cell2
    [Arguments]                     ${testParam}

    ${current_cfg_file}    Set Variable    ${tl.core.dir_path}/${tl.core.cfg_filename}
    # ${new_cfg_filename}    Set Variable    new_${tl.core.cfg_filename}
    # ${new_cfg_file}    Set Variable    ${tl.core.dir_path}/${new_cfg_filename}

    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    Copy file    ${current_cfg_file}    ${current_cfg_file}_bkp_before_cell2_modify

    # earfcn is updated to be in same BW (LTE and NR)
    # both LTE and NR freq are aligned (normalized freq are different betwenn LTE and NR )
    # ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68787:133323
    # lte earfcn=68771:133307 can be used with nrarfcnDl=127100 and nrarfcnUl=136300
    # ${line}    Set Variable    bw=${testParam.seq.bandwidth} eci=0x0000101 earfcn=68771:133307
    #---------------------------------------------------------------------------------------------------
    # eNB CONFIGURATION
    # Cell-1.2
    #---------------------------------------------------------------------------------------------------
    ${cmd}    catenate      set_cell id=2 enb=1 eci=0x0000102 pci=4:0 tac=222 proxy=$DAEMON_IP:12220|$DAEMON_IP:8890
    ...                              earfcn=${testParam.scfFile.nrcellfdd.lteearfcnDl}:${testParam.scfFile.nrcellfdd.lteearfcnUl}
    ...                              bw=${testParam.seq.bandwidth}
    ...                              mapped_earfcn=4200:22200 mandatory_for_activation=off
    wts_cfg.Insert  ${cmd}  after   set_cell id=1

    #  for LTE
    # Band Name Bandwidth (MHz) Mode Earfcn DL Downlink (MHz)  Earfcn    UL Uplink (MHz)
    #  71   600     35           FDD    68787     637.10       133323      683.10
    #
    # for NR
    # Band  Name  Mode   ,    Downlink nr-arfcn Frequency (MHz) , Uplink nr-arfcn     Frequency (MHz)
    # n71   600    FD    ,         127420          637.1               136620             683.1
    #

    #---------------------------------------------------------------------------------------------------
    # GNB CONFIGURATION
    # Cell-2.2
    #---------------------------------------------------------------------------------------------------
    # ${line}    Set Variable    nr_arfcn=136620:127420
    # ${line}    Set Variable     nr_arfcn=136620:127420 tdd_cell=off
    ${line}    Set Variable     nr_arfcn=${testParam.scfFile.nrcellfdd.nrarfcnUl}:${testParam.scfFile.nrcellfdd.nrarfcnDl} tdd_cell=off
    #  nr_arfcn=${ul_nr_arfcn}:${dl_nr_arfcn}   => Done during each test cases
    wts_cfg.Modify    set_cell id=2 gnb=2    ${line}

    Modify basic_setup.cfg for 2FDD Setup Dss Cell2    ${testParam}

    #---------------------------------------------------------------------------------------------------
    # Save and Use it
    #---------------------------------------------------------------------------------------------------
    wts_cfg.Save Wts Cfg        ${current_cfg_file}
    # remove "mapped_earfcn= ..." from the file
    Run          command=sed -i -e 's/mapped_earfcn=[0-9]*:[0-9]*//g' ${current_cfg_file}
    Run          command=sed -i -e 's/GNB_NG_ADDR="10.0.1.2"/GNB_NG_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${current_cfg_file}
    Run          command=sed -i -e 's/GNB_X2_ADDR="10.0.1.2"/GNB_X2_ADDR="${testParam.scfFile.ipif.localIpAddr}"/g' ${current_cfg_file}
    CB013715_scenario_modifications.Update gNBId and eNBId In WTS Cfg File    ${current_cfg_file}  eNBId=${testParam.Context.eNBId}
    ...                                                                       gNBId=${testParam.Context.gNBId}
    # BEWARE that enb in set_ue simulated cmd means gnbId !!!
    wts_cfg.Load Wts Cfg        ${current_cfg_file}
    wts_cfg.Modify     set_ue simulated id=1    enb=${testParam.Context.gNBId}
    Dated log     cfg Modify : "set_ue simulated id=1 enb=" modified with ${testParam.Context.gNBId}
    wts_cfg.Save Wts Cfg        ${current_cfg_file}

Modify basic_setup.cfg for 2FDD Setup Dss Cell2
    [Arguments]                     ${testParam}
    wts_cfg.Modify
    ...    set_cell id=${fdd_cell_2} gnb=2
    ...       nr_arfcn=${testParam.scfFile.nrcellfdd.nrarfcnUl}:${testParam.scfFile.nrcellfdd.nrarfcnDl} gscn=${gscn_fdd_cell_2}


Update Basic Configuration File Previous Version
    wts_cfg.Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
        wts_cfg.insert    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh      after  set_amf id=1
        run keyword if    '10MHz' in '${SUITE_NAME}'    Modify basic_setup.cfg for 2TDD+2FDD Setup Cell1 n41
        ...    ELSE                                     Modify basic_setup.cfg for 2TDD+2FDD Setup
    wts_cfg.Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
    return from keyword

Modify basic_setup.cfg for 2TDD+2FDD Setup
    wts_cfg.Modify    set_cell id=${tdd_cell_1} gnb=2    nr_arfcn=636666:636666 gscn=${gscn_tdd_cell_1}

Modify basic_setup.cfg for 2TDD+2FDD Setup Cell1 n41
    wts_cfg.Modify    set_cell id=${tdd_cell_1} gnb=2    nr_arfcn=519000:519000 gscn=${gscn_tdd_cell_1}


Update Basic Configuration File OLD
    wts_cfg.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
      ${SUITE PATH}=  nps_tarf_tools.get_directory   ${SUITE SOURCE}
      ${ue_nr_capabilities}=  nps_tarf_tools.read_dictionary_from_json   ${SUITE PATH}/resources/CB012738_UE_NR_Capability.json
      run keyword if    '${SW_POSTFIX}'=='FDD'    wts_cfg.Modify    ue_param id=1    ue_nr_capabilities=${ue_nr_capabilities['FDD']}
      ...  ELSE                                   wts_cfg.Modify    ue_param id=1    ue_nr_capabilities=${ue_nr_capabilities['TDD']}
    wts_cfg.Save Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}

#-----------For test Setup Dss Changes-----------------------------------------------------------------------------------------------[150 characters]
DssUlSubcarrierReqErrorCaseChecker
    [arguments]    ${testParam}    ${start_prb}     ${amount_of_prb}
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${fdd_cell}=     set variable     ${testParam.Context.gNBId_cellid}
    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    # ${fdd_cell_1} is ${testParam.Context.gNBId_cellid}
    ${nbrOfBlankedPRBsLowEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsLowEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}

    ${msg1FrequencyStart}	scf.get_value_from_scf   p_name=msg1FrequencyStart    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${lte_dl_bandwidth}=    set variable If    '${bwPrb}' == '52'      50
    ...                                        '${bwPrb}' == '79'      75
    ...                                        '${bwPrb}' == '106'     100    100
    ${min_nr_dss_ratio}=    scf.get_value_from_scf  p_name=minNrDssRatio    list_name=lteNrDssUlRatio
    ...                                             dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRDSSLTE-1
    ${max_nr_dss_ratio}= 	scf.get_value_from_scf  p_name=maxNrDssRatio    list_name=lteNrDssUlRatio
    ...                                             dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRDSSLTE-1

    # ul Checker for Cellsetup
    ${cRbSizeUl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeUL} - ${nbrOfBlankedPRBsHighEdgeUL}
    ${min_max_ul_prb}   ${is_valid_start_prb}    ${is_amount_of_prb_in_range}    ${is_min_amount_of_prb_valid}  ${is_max_amount_of_prb_valid}=
    ...     CellDss.UlSubcarrierReqErrorCaseChecker       lte_dl_bandwidth=${lte_dl_bandwidth}
    ...                                        min_nr_dss_ratio=${min_nr_dss_ratio}
    ...                                        max_nr_dss_ratio=${max_nr_dss_ratio}
    ...                                        nbr_of_blanked_prbs_low_edge_ul_scf=${nbrOfBlankedPRBsLowEdgeUL}
    ...                                        nbr_of_blanked_prbs_high_edge_ul_scf=${nbrOfBlankedPRBsHighEdgeUL}
    ...                                        ul_bandwidth=${bwPrb}
    ...                                        msg1frequencyStart=${msg1FrequencyStart}
    ...                                        cRbStartUl=${nbrOfBlankedPRBsLowEdgeUL}
    ...                                        ul_dedicated_bwp_size=${cRbSizeUl}
    ...                                        prbs_in_static_area=${6}
    ...                                        start_prb=${start_prb}
    ...                                        amount_of_prb=${amount_of_prb}

    nps_tarf_tools.log_to_console_with_time_prefix     min_max_ul_prb=${min_max_ul_prb}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     is_valid_start_prb=${is_valid_start_prb}    level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     is_amount_of_prb_in_range=${is_amount_of_prb_in_range}    level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     is_min_amount_of_prb_valid=${is_min_amount_of_prb_valid}    level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     is_max_amount_of_prb_valid=${is_max_amount_of_prb_valid}    level=INFO
    Append To File   ${resultCellSetupFile}   \nmin_max_ul_prb: ${min_max_ul_prb}
    Append To File   ${resultCellSetupFile}   \nis_valid_start_prb: ${is_valid_start_prb}
    Append To File   ${resultCellSetupFile}   \nis_amount_of_prb_in_range: ${is_amount_of_prb_in_range}\n
    Append To File   ${resultCellSetupFile}   \nis_min_amount_of_prb_valid: ${is_min_amount_of_prb_valid}\n
    Append To File   ${resultCellSetupFile}   \nis_max_amount_of_prb_valid: ${is_max_amount_of_prb_valid}\n
    IF    not ${is_amount_of_prb_in_range}
        ${msg}=    catenate   AssignedPRB is out of range against minNrDssRatio or maxNrDssRatio, amountOfPrb=${amount_of_prb},
        ...                   minUlPrb=${min_max_ul_prb['min']}, maxUlPrb=${min_max_ul_prb['max']}
        BuiltIn.log     ${msg}    level=WARN    console=yes
        Append To File   ${resultCellSetupFile}   ${msg}
    END
    IF    not ${is_valid_start_prb}
        ${msg}=    catenate   no valid PRB Area found, start_prb=${start_prb} not valid!!!
        BuiltIn.log     ${msg}    level=WARN    console=yes
        Append To File   ${resultCellSetupFile}   ${msg}
    END
    IF    not ${is_min_amount_of_prb_valid}
        ${msg}=    catenate   no valid PRB Area found, min_amount_of_prb not valid!!!
        BuiltIn.log     ${msg}    level=WARN    console=yes
        Append To File   ${resultCellSetupFile}   ${msg}
    END
    IF    not ${is_max_amount_of_prb_valid}
        ${msg}=    catenate   no valid PRB Area found, is_max_amount_of_prb not valid!!!
        BuiltIn.log     ${msg}    level=WARN    console=yes
        Append To File   ${resultCellSetupFile}   ${msg}
    END
    Append To File   ${resultCellSetupFile}   \n

DssDlSubcarrierReqErrorCaseChecker
    [arguments]    ${testParam}    ${allocated_normal_subframes}     ${dss_fixed_mbsfn_pattern}
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${fdd_cell}=     set variable     ${testParam.Context.gNBId_cellid}
    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    # ${fdd_cell_1} is ${testParam.Context.gNBId_cellid}
    ${nbrOfBlankedPRBsLowEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsLowEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}

    ${msg1FrequencyStart}	scf.get_value_from_scf   p_name=msg1FrequencyStart    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${lte_dl_bandwidth}=    set variable If    '${bwPrb}' == '52'      50
    ...                                        '${bwPrb}' == '79'      75
    ...                                        '${bwPrb}' == '106'     100    100
    ${min_nr_dss_ratio}=    scf.get_value_from_scf  p_name=minNrDssRatio    list_name=lteNrDssDlRatio
    ...                                             dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRDSSLTE-1
    ${max_nr_dss_ratio}= 	scf.get_value_from_scf  p_name=maxNrDssRatio    list_name=lteNrDssDlRatio
    ...                                             dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRDSSLTE-1

    # dl Checker for Cellsetup
    ${cRbSizeUl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeUL} - ${nbrOfBlankedPRBsHighEdgeUL}
    ${allocated_normal_subframes_bitmap}    Replace String   ${allocated_normal_subframes}    -    ${EMPTY}
    ${allocated_normal_subframes_bitmap_revert}    DlResourceErrorCaseChecker.reverse_bits    ${allocated_normal_subframes_bitmap}
    # nps_tarf_tools.log_to_console_with_time_prefix     allocated_normal_subframes=${allocated_normal_subframes_bitmap_revert}    level=INFO
    # nps_tarf_tools.log_to_console_with_time_prefix        dss_fixed_mbsfn_pattern=${dss_fixed_mbsfn_pattern}           level=INFO
    ${is_slot_based_ratio_in_range}    ${ratio}=   DlResourceErrorCaseChecker.check_allocation_in_range_when_needed
    ...                                       allocated_normal_subframes=${allocated_normal_subframes_bitmap_revert}
    ...                                       dss_fixed_mbsfn_pattern=${dss_fixed_mbsfn_pattern}
    ...                                       min_nr_dss_ratio=${min_nr_dss_ratio}
    ...                                       max_nr_dss_ratio=${max_nr_dss_ratio}
    nps_tarf_tools.log_to_console_with_time_prefix     min_nr_dl_dss_ratio=${min_nr_dss_ratio}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     max_nr_dl_dss_ratio=${max_nr_dss_ratio}           level=INFO
    nps_tarf_tools.log_to_console_with_time_prefix     is_dl_slot_based_ratio_in_range=${is_slot_based_ratio_in_range}    level=INFO
    Append To File   ${resultCellSetupFile}   \nmin_nr_dl_dss_ratio: ${min_nr_dss_ratio}
    Append To File   ${resultCellSetupFile}   \nmax_nr_dl_dss_ratio: ${max_nr_dss_ratio}
    Append To File   ${resultCellSetupFile}   \nis_dl_slot_based_ratio_in_range: ${is_slot_based_ratio_in_range}
    nps_tarf_tools.log_to_console_with_time_prefix    slotBasedRatio: ${ratio}, lteNrDssDlRatio(min: ${min_nr_dss_ratio}, max: ${max_nr_dss_ratio})
    IF    not ${is_slot_based_ratio_in_range}
        ${msg}=    catenate   allocatedNormalSubframes is out of range against lteNrDssDlRatio(minNrDssRatio or maxNrDssRatio)
        ...                    ==> Resource allocation failure message sent to CRM,
        BuiltIn.log     ${msg}    level=WARN    console=yes
        Append To File   ${resultCellSetupFile}   ${msg}
    END
    Append To File   ${resultCellSetupFile}   \n
    DlResourceErrorCaseChecker.convert_dl_allocation_to_df    allocated_normal_subframes=${allocated_normal_subframes_bitmap}
    ...                                                       dss_fixed_mbsfn_pattern=${dss_fixed_mbsfn_pattern}
    ...                                                       min_nr_dss_ratio=min_nr_dss_ratio=${min_nr_dss_ratio}
    ...                                                       max_nr_dss_ratio=max_nr_dss_ratio=${max_nr_dss_ratio}
    ...                                                       dl_ratio=${ratio}


update Dss Specific parameters
    [arguments]    ${testParam}    ${dl_qos_load_meas_timer}=200    ${ul_qos_load_meas_timer}=200
    DSS_keywords.Update DSS gNBId_cellid with "${fdd_cell_1}" into "${testParam}"
    nps_tarf_tools.log_to_console_with_time_prefix   gNBId_cellid is ${testParam.Context.gNBId_cellid}
    ...                                             level=INFO
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${fdd_cell}=     set variable     ${testParam.Context.gNBId_cellid}
    ${max_nr_dss_ratio}= 	scf.get_value_from_scf  p_name=maxNrDssRatio    list_name=lteNrDssDlRatio
    ...                                             dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRDSSLTE-1
    # modification DL Ratio into the test param Ctx
    # take into account  ${PATTERN_DL_100_SA_OK_NO_PRBPOOLING} when PrbPooling deactivated
    ${actSlowPrbPooling_SCF}=         Get actSlowPrbPooling from SCF       CellId=${testParam.Context.gNBId_cellid}
    IF    '${actSlowPrbPooling_SCF}'=='false'
        IF    '${max_nr_dss_ratio}' == '90'
            DSS_keywords.Update DSS DL pattern with     ${testParam}     ${PATTERN_DL_90_SA_OK_NO_PRBPOOLING}
        ELSE
            DSS_keywords.Update DSS DL pattern with     ${testParam}     ${PATTERN_DL_100_SA_OK_NO_PRBPOOLING}
        END
    ELSE
        IF    '${max_nr_dss_ratio}' == '90'
            DSS_keywords.Update DSS DL pattern with     ${testParam}     ${PATTERN_DL_90_SA_OK}
        ELSE
            DSS_keywords.Update DSS DL pattern with     ${testParam}     ${PATTERN_DL_100_SA_OK}
         END
    END
    Dated log       DL pattern into TestParam is ${testParam.seq.dl_allocated_normal_subframes}
    DSS_keywords.Update DSS UL Allocation type with     ${testParam}     ${ALLOCATION_TYPE}
    Dated log       UL allocation Type into TestParam is ${testParam.seq.ul_allocation_type}
    DSS_keywords.Update DSS DL Allocation type with     ${testParam}     ${ALLOCATION_TYPE}
    Dated log       DL allocation Type into TestParam is ${testParam.seq.dl_allocation_type}

    ${ratio}=      DlResourceErrorCaseChecker.reverse_bits_pattern_from_crmsim_and_calculate_ratio    ${testParam.seq.dl_allocated_normal_subframes}
    ...                                                                                               ${dss_fixed_mbsfn_pattern}
    ${dl_allocated_normal_subframes_reverse}=  DlResourceErrorCaseChecker.reverse_bits  ${testParam.seq.dl_allocated_normal_subframes}
    dated log      with DL PATTERN = ${dl_allocated_normal_subframes_reverse}
    dated log      and dss_fixed_mbsfn_pattern = ${dss_fixed_mbsfn_pattern}
    dated log      ===> the dl ratio is ${ratio}

    ${test_scf_file}       COAM Get SCF      local_dir_path=${LOG_PATH}      file=SCF.xml   alias=coam_gnb
    Set Suite Variable     ${test_scf_file}
    ${actLteNrDssFastAlloc_SCF}=         Get actLteNrDssFastAlloc from SCF       CellId=${testParam.Context.gNBId_cellid}
    ${lteNrDssFastAllocPerfEnh_SCF}=     Get lteNrDssFastAllocPerfEnh from SCF   CellId=${testParam.Context.gNBId_cellid}
    ${actLteNrDssLteCatM_SCF}=           Get actLteNrDssLteCatM from SCF         CellId=${testParam.Context.gNBId_cellid}

    ${dl_qos_timer}    set Variable If    '${actLteNrDssFastAlloc_SCF}' == 'true'   ${10}
    ...                                                                             ${dl_qos_load_meas_timer}
    ${ul_qos_timer}    set Variable If    '${actLteNrDssFastAlloc_SCF}' == 'true'   ${10}
    ...                                                                             ${ul_qos_load_meas_timer}
    DSS_keywords.Update DSS dl qos load meas timer "${dl_qos_timer}" ms and ul qos load meas timer "${ul_qos_timer}" ms into "${testParam}"
    Dated log       DL qos_load_meas_timer into TestParam is ${testParam.seq.dl_qos_load_meas_timer} ms
    Dated log       UL qos_load_meas_timer into TestParam is ${testParam.seq.ul_qos_load_meas_timer} ms

    # actLteNrDssFastAlloc = false,  actLteNrDssLteCatM = false
    # lteNrDssFastAllocPerfEnh = exc_msg_reduction_static or disabled
    Update DSS actLteNrDssLteCatM with "${actLteNrDssLteCatM_SCF}" into "${testParam}"
    Dated log       actLteNrDssLteCatM=${testParam.scfFile.nrdsslte.actLteNrDssLteCatM} into TestParam updated
    Update DSS superfast_allocation with "${actLteNrDssFastAlloc_SCF}" into "${testParam}"
    Dated log       superfast_allocation=${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc} into TestParam updated
    Update DSS lteNrDssFastAllocPerfEnh with "${lteNrDssFastAllocPerfEnh_SCF}" into "${testParam}"
    Dated log       lteNrDssFastAllocPerfEnh=${testParam.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh} into TestParam updated

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${fdd_cell}=     set variable     ${testParam.Context.gNBId_cellid}
    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    # ${fdd_cell_1} is ${testParam.Context.gNBId_cellid}
    ${nbrOfBlankedPRBsLowEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeUL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeUL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsLowEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsLowEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${nbrOfBlankedPRBsHighEdgeDL}	 scf.get_value_from_scf   p_name=nbrOfBlankedPRBsHighEdgeDL    dist_name=${distName_NRCELL[${fdd_cell}-1]}
    ${size}=        CB013715_tools.calculate_coreset4_size        bwPrb=${bwPrb}
    ...                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ...                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}
    # w_ul_Dss_Prb_First_Alloc defined in CB013715_variables.yaml
    IF    '${w_ul_Dss_Prb_First_Alloc}' == 'max'
        # 5Prbs below and High Edge reserved for PUCCH
        ${ULNbrOfPrb}=    Evaluate     ${bwPrb}-${nbrOfBlankedPRBsLowEdgeUL}-${nbrOfBlankedPRBsHighEdgeUL}-${5}-${5}
    ELSE
        ${ULNbrOfPrb}=    set variable     ${w_ul_Dss_Prb_First_Alloc}
    END
    Update DSS ULNbrOfPrb with "${ULNbrOfPrb}" into "${testParam}"
    Dated log       ULNbrOfPrb=${testParam.seq.ULNbrOfPrb} into TestParam updated

    ${rdMeaningfulDlLoadMeasurementDifference}=    robot_extension.Run Keyword And Warn On Failure    Get Rad Value Using Aashell
    ...                                                                                               rad_param=0x580955
    nps_tarf_tools.log_to_console_with_time_prefix     rdMeaningfulDlLoadMeasurementDifference[0x580955]=${rdMeaningfulDlLoadMeasurementDifference}
    ...                                               level=INFO
    set suite variable    ${rdMeaningfulDlLoadMeasurementDifference}
    ${rdMeaningfulUlLoadMeasurementDifference}=    robot_extension.Run Keyword And Warn On Failure    Get Rad Value Using Aashell
    ...                                                                                               rad_param=0x580956
    nps_tarf_tools.log_to_console_with_time_prefix     rdMeaningfulUlLoadMeasurementDifference[0x580956]=${rdMeaningfulUlLoadMeasurementDifference}
    ...                                               level=INFO
    set suite variable    ${rdMeaningfulUlLoadMeasurementDifference}

    Test-Suite-Setup-Resources-Keywords.Log config in result CellSetup file  ${ts_log_dir}/cell_setup_trace_initial
    ...                                                                      config=CB013715_${TOPOLOGY_LABEL}_${TOPOLOGY_VARIANT}
    Append To File   ${resultCellSetupFile}   \nchBwDl: ${testParam.scfFile.nrcellfdd.chBwDl}
    Append To File   ${resultCellSetupFile}   \nchBwUl: ${testParam.scfFile.nrcellfdd.chBwUl}
    Append To File   ${resultCellSetupFile}   \nnrarfcnDl: ${testParam.scfFile.nrcellfdd.nrarfcnDl}
    Append To File   ${resultCellSetupFile}   \nnrarfcnUl: ${testParam.scfFile.nrcellfdd.nrarfcnUl}
    Append To File   ${resultCellSetupFile}   \nactLteNrDss: ${testParam.scfFile.nrbts.actLteNrDss}
    Append To File   ${resultCellSetupFile}   \nlteNrDssMode: ${testParam.scfFile.nrcell.lteNrDssMode}
    Append To File   ${resultCellSetupFile}   \nactLteNrDssLteCatM: ${testParam.scfFile.nrdsslte.actLteNrDssLteCatM}
    Append To File   ${resultCellSetupFile}   \nactLteNrDssFastAlloc: ${testParam.scfFile.nrdsslte.actLteNrDssFastAlloc}
    Append To File   ${resultCellSetupFile}   \nlteNrDssFastAllocPerfEnh: ${testParam.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}
    Append To File   ${resultCellSetupFile}   \n
    Append To File   ${resultCellSetupFile}   \ndl_qos_load_meas_timer: ${testParam_dss.seq.dl_qos_load_meas_timer}
    Append To File   ${resultCellSetupFile}   \nul_qos_load_meas_timer: ${testParam_dss.seq.ul_qos_load_meas_timer}
    Append To File   ${resultCellSetupFile}   \n
    Append To File   ${resultCellSetupFile}   \nrdMeaningfulDlLoadMeasurementDifference: ${rdMeaningfulDlLoadMeasurementDifference}
    Append To File   ${resultCellSetupFile}   \nrdMeaningfulUlLoadMeasurementDifference: ${rdMeaningfulUlLoadMeasurementDifference}
    Append To File   ${resultCellSetupFile}   \n
    Append To File   ${resultCellSetupFile}   \nnbrOfBlankedPRBsLowEdgeUL: ${nbrOfBlankedPRBsLowEdgeUL}
    Append To File   ${resultCellSetupFile}   \nnbrOfBlankedPRBsHighEdgeUL: ${nbrOfBlankedPRBsHighEdgeUL}
    Append To File   ${resultCellSetupFile}   \nnbrOfBlankedPRBsLowEdgeDL: ${nbrOfBlankedPRBsLowEdgeDL}
    Append To File   ${resultCellSetupFile}   \nnbrOfBlankedPRBsHighEdgeDL: ${nbrOfBlankedPRBsHighEdgeDL}
    Append To File   ${resultCellSetupFile}   \n
    DssUlSubcarrierReqErrorCaseChecker    testParam=${testParam}    start_prb=${nbrOfBlankedPRBsLowEdgeUL}    amount_of_prb=${ULNbrOfPrb}
    DssDlSubcarrierReqErrorCaseChecker    testParam=${testParam}    allocated_normal_subframes=${testParam.seq.dl_allocated_normal_subframes}
	...                                                             dss_fixed_mbsfn_pattern=${dss_fixed_mbsfn_pattern}


Configure_DSS_5g_Periodic_UL_Fast_Allocation
    [Arguments]         ${param}     ${alias}=default     ${wtsObj}=wts
    ${actLteNrDssFastAlloc_SCF}=         Get actLteNrDssFastAlloc from SCF       CellId=${param.Context.gNBId_cellid}
    dated log    [INFO] actLteNrDssFastAlloc=${actLteNrDssFastAlloc_SCF}
    return from keyword if    '${actLteNrDssFastAlloc_SCF}' == 'false'
    # Configure Periodic UL Fast Allocation              ${alias}    ${wtsObj}
    Configure Periodic UL Fast Allocation Version2     ${alias}    ${wtsObj}


Configure Periodic UL Fast Allocation
    [Arguments]                 ${alias}=default        ${wtsObj}=wts

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # to take into account ul_Dss_Prb_fast_Alloc_list later !!!
    ${ul_Dss_Prb_fast_Alloc_list_to_update}      set variable     ${ul_Dss_Prb_fast_Alloc_list}
    ${nbUlPattern}=     Evaluate     len(@{ul_Dss_Prb_fast_Alloc_list})

    # 3 PRB area defined because of longPUCCH
    ${nbrOfBlankedPRBsLowEdgeUL}=     set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}
    ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    DssUlSubcarrierReqErrorCaseChecker    testParam=${Param}    start_prb=${prb_nr_pusch_low_area_start}    amount_of_prb=${Param.seq.ULNbrOfPrb}
    ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${Param.seq.ULNbrOfPrb}
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
        ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,5|${prb_nr_pusch_area}|47,5
        ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,5|${prb_nr_pusch_area}|74,5
        ...  ELSE                                                                           set variable   0,5|${prb_nr_pusch_area}|101,5
    ELSE
        ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
        ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
        ...                                                                          106
        ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${5}
        ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
        ${ul_allocated_prb_list}=    set variable   ${prb_nr_pucch_low_area_start},5|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},5
    END

    CB013715_scenario_modifications.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                          alias=${alias}    wtsObj=${wtsObj}

    # ${ul_allocated_prb_list }=  Catenate   1,20

    # 5 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},20
    IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
        ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,5|${prb_nr_pusch_area}|47,5
        ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,5|${prb_nr_pusch_area}|74,5
        ...  ELSE                                                                           set variable   0,5|${prb_nr_pusch_area}|101,5
    ELSE
        ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
        ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
        ...                                                                          106
        ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${5}
        ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
        ${ul_allocated_prb_list}=    set variable   ${prb_nr_pucch_low_area_start},5|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},5
    END

    CB013715_scenario_modifications.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                                          alias=${alias}    wtsObj=${wtsObj}

    CB013715_scenario_modifications.DSS UL Cell Periodic Resource Allocation Phase3     alias=${alias}   wtsObj=${wtsObj}

    # Param variable is visible under the test suite

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    # ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1
    ...                                                                                  alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

Configure Periodic UL Fast Allocation Version2
    [Arguments]                 ${alias}=default        ${wtsObj}=wts

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # to take into account ul_Dss_Prb_fast_Alloc_list
    ${ul_Dss_Prb_fast_Alloc_list_to_update}      set variable     ${ul_Dss_Prb_fast_Alloc_list}
    ${nbUlPattern}=     Evaluate     len(@{ul_Dss_Prb_fast_Alloc_list})

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${nbrOfBlankedPRBsLowEdgeUL}=     set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeUL}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeUL}
    ${prb_nr_pusch_low_area_start}=    Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}+${5}
    ${fdd_cell}=     set variable     ${Param.Context.gNBId_cellid}
    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}

    # 3 PRB area defined because of longPUCCH
	FOR     ${i}   IN RANGE  ${nbUlPattern}
	    IF     ',' in '${ul_Dss_Prb_fast_Alloc_list_to_update}[${i}]'
            ${PARTS}=       Split String        ${ul_Dss_Prb_fast_Alloc_list_to_update}[${i}]     ,
            ${startPrb}=      Evaluate         int(${PARTS}[0])
            ${NbrOfPrb}=      Evaluate         int(${PARTS}[1])
            ${prb_nr_pusch_low_area_start}=    set variable   ${startPrb}
            ${ULNbrOfPrb}=    set variable   ${NbrOfPrb}
        ELSE IF     '${ul_Dss_Prb_fast_Alloc_list_to_update}[${i}]' == 'max'
            # 5Prbs below and High Edge reserved for PUCCH
            ${ULNbrOfPrb}=    Evaluate     ${bwPrb}-${nbrOfBlankedPRBsLowEdgeUL}-${nbrOfBlankedPRBsHighEdgeUL}-${5}-${5}
        ELSE
            ${ULNbrOfPrb}=    set variable   ${ul_Dss_Prb_fast_Alloc_list_to_update}[${i}]
	    END
	    DssUlSubcarrierReqErrorCaseChecker    testParam=${Param}    start_prb=${prb_nr_pusch_low_area_start}    amount_of_prb=${ULNbrOfPrb}
        ${prb_nr_pusch_area}=    set variable    ${prb_nr_pusch_low_area_start},${ULNbrOfPrb}
        IF    ${nbrOfBlankedPRBsLowEdgeUL} == ${0} and ${nbrOfBlankedPRBsHighEdgeUL} == ${0}
            ${ul_allocated_prb_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,4|${prb_nr_pusch_area}|47,4
            ...  ELSE          run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    set variable   0,4|${prb_nr_pusch_area}|74,4
            ...  ELSE                                                                           set variable   0,4|${prb_nr_pusch_area}|101,4
        ELSE
            ${bw}=    set variable if    '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    52
            ...                          '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'    79
            ...                                                                          106
            ${prb_nr_pucch_high_area_start}=    Evaluate    ${bw}-${nbrOfBlankedPRBsHighEdgeUL}-${4}
            ${prb_nr_pucch_low_area_start}=     Evaluate    ${nbrOfBlankedPRBsLowEdgeUL}
            ${ul_allocated_prb_list}=    set variable   ${prb_nr_pucch_low_area_start},4|${prb_nr_pusch_area}|${prb_nr_pucch_high_area_start},4
        END
        CB013715_scenario_modifications.DSS enb crm periodic allocation pattern UL   ul_allocated_prb_list=${ul_allocated_prb_list}
        ...                                          allocation_type=${Param.seq.ul_allocation_type}
        ...                                          alias=${alias}    wtsObj=${wtsObj}
	END

    CB013715_scenario_modifications.DSS UL Cell Periodic Resource Allocation Phase3     alias=${alias}   wtsObj=${wtsObj}

    # Param variable is visible under the test suite

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic UL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1
    ...                                                                                  alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

DSS enb crm periodic allocation pattern UL
    [Arguments]     ${ul_allocated_prb_list}=1,35    ${allocation_type}=max_share
    ...             ${alias}=default
    ...             ${wtsObj}=wts
    [Documentation]    This keyword is used for DSS Phase3 UL Fast Allocation
    sleep   1

    ${delay_if_auto}      set Variable        10
    ${msg}    Catenate    DSS enb_crm_periodic_allocation_pattern with allocation_start_time=auto and
    ...                    delay_if_auto=${delay_if_auto} and
    ...                    ul_allocated_prb_list=${ul_allocated_prb_list} with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_allocation_pattern enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    ...                      allocation_start_time=auto delay_if_auto=${delay_if_auto} ul_allocated_prb_list=${ul_allocated_prb_list}
    ...                      allocation_type=${allocation_type}
    Call Method    ${wtsObj}   execute_egate_command      cmd=${cmd}      alias=${alias}

    log to console  \n***DSS enb_crm_periodic_allocation_pattern  UL completed***

DSS UL Cell Periodic Resource Allocation Phase3
    [Arguments]     ${periodicity}=30
    ...             ${loopback}=on
    ...             ${alias}=default
    ...             ${wtsObj}=wts
    [Documentation]    This keyword is used for DSS Phase3 Fast Allocation - feature 7738 for UL
    sleep   2
    ${pattern}=      Set Variable        Response SequenceNumber\=
    ${msg}    Catenate    DSS UL Cell Periodic Resource Allocation Phase3 UL with periodicity=${periodicity} and
    ...                    loopback=${loopback} and periodicity_and_load_indication=on and
    ...                    periodicity_messages_logged=500 with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_resource_allocation enb=${Param.Context.eNBId} cell=${Param.Context.eNBId_cellid}
    ...                        tgt_enb=${Param.Context.gNBId} tgt_cell=${Param.Context.gNBId_cellid} dir=UL
    ...                        periodicity=${periodicity}
    ...                        loopback=${loopback}
    ...                        periodicity_and_load_indication=on
    # ...                        periodicity_messages_logged=500
    ...                        periodicity_messages_logged=100

    ${output}    Call Method    ${wtsObj}  execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=40     alias=${alias}

    ${output}      String.Get Lines Matching Regexp          ${output}    ${pattern}   partial_match=${TRUE}
    Log To Console    \n${output}
    Should Not Be Empty     ${output}
    log to console  \n***DSS UL Cell Periodic Resource Area Allocation completed***

Configure_DSS_5g_Periodic_DL_Fast_Allocation
    [Arguments]         ${param}     ${alias}=default     ${wtsObj}=wts
    ${actLteNrDssFastAlloc_SCF}=         Get actLteNrDssFastAlloc from SCF       CellId=${param.Context.gNBId_cellid}
    dated log    [INFO] actLteNrDssFastAlloc=${actLteNrDssFastAlloc_SCF}
    return from keyword if    '${actLteNrDssFastAlloc_SCF}' == 'false'
    Configure Periodic DL Fast Allocation     ${alias}    ${wtsObj}

Configure Periodic DL Fast Allocation
    [Arguments]                 ${alias}=default        ${wtsObj}=wts

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # to take into account ul_Dss_Prb_fast_Alloc_list
    ${dl_Dss_Prb_fast_Alloc_list_to_update}      set variable     ${dl_Dss_Prb_fast_Alloc_list}
    ${nbDlPattern}=     Evaluate     len(@{dl_Dss_Prb_fast_Alloc_list})

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${test_scf_file}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${fdd_cell}=     set variable     ${Param.Context.gNBId_cellid}
    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}

	FOR     ${i}   IN RANGE  ${nbDlPattern}
	    ${dl_allocated_normal_subframes}=  set variable     ${dl_Dss_Prb_fast_Alloc_list_to_update}[${i}]
        ${ratio}=      nps_tarf_tools.calculate_ratio_bits_1    ${dl_allocated_normal_subframes}
        dated log      with DL PATTERN = ${dl_allocated_normal_subframes}, the ratio wo mbsfn is ${ratio}
        dated log    dssFixedMbsfnPattern applied in CellSetupResp is ${dss_fixed_mbsfn_pattern}
        dated log    dssFixedNormalPattern applied in CellSetupResp is ${dssFixedNormalPattern}
        ${ratio}=      DlResourceErrorCaseChecker.reverse_bits_pattern_from_crmsim_and_calculate_ratio    ${dl_allocated_normal_subframes}
        ...                                                                                               ${dss_fixed_mbsfn_pattern}
        ${dl_allocated_normal_subframes_reverse}=    DlResourceErrorCaseChecker.reverse_bits    ${dl_allocated_normal_subframes}
        dated log      with DL PATTERN = ${dl_allocated_normal_subframes_reverse}
        dated log      with dss_fixed_mbsfn_pattern = ${dss_fixed_mbsfn_pattern}
        dated log      ===> the dl ratio (normal + mbsfn subframe) is ${ratio}
	    DssDlSubcarrierReqErrorCaseChecker    testParam=${Param}    allocated_normal_subframes=${dl_allocated_normal_subframes}
	    ...                                                         dss_fixed_mbsfn_pattern=${dss_fixed_mbsfn_pattern}
        # to manage DL PRB BLANKING case
        ${nbrOfBlankedPRBsHighEdgeDL}   set variable   ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
        ${nbrOfBlankedPRBsLowEdgeDL}   set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
        ${max_prb}      run Keyword if     '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'      set variable    52
        ...    ELSE IF                     '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'      set variable    79
        ...    ELSE                                                                          set variable    106
        ${dl_prb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
        ...        Evaluate    ${max_prb}-${nbrOfBlankedPRBsHighEdgeDL}-${nbrOfBlankedPRBsLowEdgeDL}
        ...   ELSE    set variable    ${max_prb}
        ${msg}=   Catenate    max_dl_prb=${dl_prb} for dl_prb_area_allocation_list with
        ...                   actPRBBlanking=${Param.scfFile.nrcell.actPRBBlanking}
        ...                   nbrOfBlankedPRBsHighEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
        ...                   nbrOfBlankedPRBsLowEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
        dated Log     ----------> ${msg}
        ${DL_StartPrb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
        ...        Evaluate    ${nbrOfBlankedPRBsLowEdgeDL}
        ...   ELSE    set variable    0
        ${dl_prb_area_allocation_list}=
        ...   Catenate    SEPARATOR=   0:${DL_StartPrb},${dl_prb}+1:${DL_StartPrb},${dl_prb}+2:${DL_StartPrb},${dl_prb}+3:${DL_StartPrb},${dl_prb}+
        ...     4:${DL_StartPrb},${dl_prb}+5:${DL_StartPrb},${dl_prb}+6:${DL_StartPrb},${dl_prb}+7:${DL_StartPrb},${dl_prb}+
        ...     8:${DL_StartPrb},${dl_prb}+9:${DL_StartPrb},${dl_prb}+10:${DL_StartPrb},${dl_prb}+11:${DL_StartPrb},${dl_prb}+
        ...     12:${DL_StartPrb},${dl_prb}+13:${DL_StartPrb},${dl_prb}+14:${DL_StartPrb},${dl_prb}+15:${DL_StartPrb},${dl_prb}+
        ...     16:${DL_StartPrb},${dl_prb}+17:${DL_StartPrb},${dl_prb}+18:${DL_StartPrb},${dl_prb}+19:${DL_StartPrb},${dl_prb}+
        ...     20:${DL_StartPrb},${dl_prb}+21:${DL_StartPrb},${dl_prb}+22:${DL_StartPrb},${dl_prb}+23:${DL_StartPrb},${dl_prb}+
        ...     24:${DL_StartPrb},${dl_prb}+25:${DL_StartPrb},${dl_prb}+26:${DL_StartPrb},${dl_prb}+27:${DL_StartPrb},${dl_prb}+
        ...     28:${DL_StartPrb},${dl_prb}+29:${DL_StartPrb},${dl_prb}+30:${DL_StartPrb},${dl_prb}+31:${DL_StartPrb},${dl_prb}+
        ...     32:${DL_StartPrb},${dl_prb}+33:${DL_StartPrb},${dl_prb}+34:${DL_StartPrb},${dl_prb}+35:${DL_StartPrb},${dl_prb}+
        ...     36:${DL_StartPrb},${dl_prb}+37:${DL_StartPrb},${dl_prb}+38:${DL_StartPrb},${dl_prb}+39:${DL_StartPrb},${dl_prb}+
        ...     40:${DL_StartPrb},${dl_prb}+41:${DL_StartPrb},${dl_prb}+42:${DL_StartPrb},${dl_prb}+43:${DL_StartPrb},${dl_prb}+
        ...     44:${DL_StartPrb},${dl_prb}+45:${DL_StartPrb},${dl_prb}+46:${DL_StartPrb},${dl_prb}+47:${DL_StartPrb},${dl_prb}+
        ...     48:${DL_StartPrb},${dl_prb}+49:${DL_StartPrb},${dl_prb}+50:${DL_StartPrb},${dl_prb}+51:${DL_StartPrb},${dl_prb}+
        ...     52:${DL_StartPrb},${dl_prb}+53:${DL_StartPrb},${dl_prb}+54:${DL_StartPrb},${dl_prb}+55:${DL_StartPrb},${dl_prb}+
        ...     56:${DL_StartPrb},${dl_prb}+57:${DL_StartPrb},${dl_prb}+58:${DL_StartPrb},${dl_prb}+59:${DL_StartPrb},${dl_prb}+
        ...     60:${DL_StartPrb},${dl_prb}+61:${DL_StartPrb},${dl_prb}+62:${DL_StartPrb},${dl_prb}+63:${DL_StartPrb},${dl_prb}+
        ...     64:${DL_StartPrb},${dl_prb}+65:${DL_StartPrb},${dl_prb}+66:${DL_StartPrb},${dl_prb}+67:${DL_StartPrb},${dl_prb}+
        ...     68:${DL_StartPrb},${dl_prb}+69:${DL_StartPrb},${dl_prb}+70:${DL_StartPrb},${dl_prb}+71:${DL_StartPrb},${dl_prb}+
        ...     72:${DL_StartPrb},${dl_prb}+73:${DL_StartPrb},${dl_prb}+74:${DL_StartPrb},${dl_prb}+75:${DL_StartPrb},${dl_prb}+
        ...     76:${DL_StartPrb},${dl_prb}+77:${DL_StartPrb},${dl_prb}+78:${DL_StartPrb},${dl_prb}+79:${DL_StartPrb},${dl_prb}

        dated Log     ----------> dl_prb_area_allocation_list = ${dl_prb_area_allocation_list}

        CB013715_scenario_modifications.DSS enb crm periodic allocation pattern
        ...                              dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
        ...                              dl_allocation_type=${Param.seq.dl_allocation_type}
        ...                              dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
        ...                              wtsObj=${wtsObj}
        ...                              alias=${alias}
	END
    CB013715_scenario_modifications.DSS DL Cell Periodic Resource Allocation Phase3   wtsObj=${wtsObj}   alias=${alias}

    # Rq: Param variable is visible under the test suite

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} completed*** ${normal}

    # ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1
    # ...                                                                                  alias=${alias}
    # Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    # Log To Console    \n${output}

DSS enb crm periodic allocation pattern
    [Arguments]     ${dl_allocated_normal_subframes}=0011101110-0111101110-0011101110-0111101110-0011101110-0111101110-0011101110-0111101110
    ...             ${dl_allocation_type}=max_share
    ...             ${dl_prb_area_allocation_list}=${empty}
    ...             ${wtsObj}=wts
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 DL Fast Allocation
    sleep   1

    ${delay_if_auto}      set Variable        20
    # ${pattern}     Set Variable        Received DSS DL Resource Area Allocation Response
    ${msg}    Catenate    DSS enb_crm_periodic_allocation_pattern with allocation_start_time=auto and
    ...                    delay_if_auto=${delay_if_auto} and allocation_type=${dl_allocation_type} and
    ...                    dl_allocated_normal_subframes=${dl_allocated_normal_subframes} with alias=${alias}
    Dated Log New Line      ${msg}

    ${cmd}    Catenate      enb_crm_periodic_allocation_pattern enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                   allocation_start_time=auto delay_if_auto=${delay_if_auto} dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                   allocation_type=${dl_allocation_type}
    ...                   dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ${l_pattern}=   Set variable     Received DSS DL Resource Area Allocation Failure
    ${cmdStr1}=   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.Context.WtsWaitingPattern}'=='${l_pattern}'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                Catenate      ${cmd}    prb_area_A_sib1br=${Param.seq.CatMinfo.prb_area_A_sib1br}
    ...                                        prb_area_B_sib1br=${Param.seq.CatMinfo.prb_area_B_sib1br}
    ...                                        prb_area_C_sib1br=${Param.seq.CatMinfo.prb_area_C_sib1br}
    ...                                        prb_area_D_sib1br=${Param.seq.CatMinfo.prb_area_D_sib1br}
    ...                                        prb_area_catm_paging=${Param.seq.CatMinfo.prb_area_catm_paging}
    ...    ELSE    Set variable    ${cmd}
    ${output}    Call Method    ${wtsObj}  execute_egate_command    cmd=${cmd}    alias=${alias}
    log to console  \n***DSS DL enb_crm_periodic_allocation_pattern completed***

DSS DL Cell Periodic Resource Allocation Phase3
    [Arguments]     ${periodicity}=30
    ...             ${loopback}=on
    ...             ${wtsObj}=wts
    ...             ${alias}=default
    [Documentation]    This keyword is used for DSS Phase3 Fast Allocation - feature 7738
    sleep   5
    ${pattern}     Set Variable        Received DSS DL Resource Area Allocation Response
    ${periodicity_messages_logged}     set variable     100
    ${msg}    Catenate    DSS DL Cell Periodic Resource Allocation Phase3 with periodicity=${periodicity} and
    ...                    loopback=${loopback} and periodicity_and_load_indication=on and
    ...                    periodicity_messages_logged=${periodicity_messages_logged} with alias=${alias}
    Dated Log New Line      ${msg}
    ${cmd}    Catenate      enb_crm_periodic_resource_allocation enb=${Param.Context.eNBId} cell=1
    ...                        tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    ...                        periodicity=${periodicity}
    ...                        loopback=${loopback}
    ...                        periodicity_and_load_indication=on
    # ...                        periodicity_messages_logged=500
    ...                        periodicity_messages_logged=${periodicity_messages_logged}
    ${output}    Call Method    ${wtsObj}  execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=40     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    log to console  \n***DSS DL Cell Periodic Resource Area Allocation completed***

Periodic DL Fast Allocation With Same Pattern
    [Arguments]                 ${alias}=default
    [Documentation]       Procedure used by 2574 ; 2 same 100% DL pattern used with dl_prb_area_allocation_list for 10/15/20MHz wo prbBlanking

    ${msg_console}=   Catenate   ***DSS ${Param.Context.DSS_Phase} CRM Periodic DL Fast Allocation BW=${Param.seq.bandwidth} with alias=${alias}***
    Log to console   \n${blue} ${msg_console} ${normal}

    # ${dl_allocated_normal_subframes}=  Catenate   1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110
    ${dl_allocated_normal_subframes}=  Catenate   1001110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,
    ...     52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,
    ...     52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,
    ...     52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,
    ...     52+79:0,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,79+2:0,79+3:0,79+4:0,79+5:0,79+6:0,79+7:0,79+8:0,79+9:0,79+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,79+16:0,79+17:0,79+18:0,79+19:0,79+20:0,79+21:0,79+22:0,79+23:0,79+24:0,79+25:0,79+26:0,79+27:0,79+28:0,
    ...     79+29:0,79+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,79+36:0,79+37:0,79+38:0,79+39:0,79+40:0,79+41:0,79+42:0,79+43:0,79+44:0,79+45:0,
    ...     79+46:0,79+47:0,79+48:0,79+49:0,79+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,79+56:0,79+57:0,79+58:0,79+59:0,79+60:0,79+61:0,79+62:0,
    ...     79+63:0,79+64:0,79+65:0,79+66:0,79+67:0,79+68:0,79+69:0,79+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,79+76:0,79+77:0,79+78:0,
    ...     79+79:0,79
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
    ...     106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
    ...     106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
    ...     106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    # ${dl_allocated_normal_subframes}=  Catenate   1011111110-1111111110-1011111110-1111111110-1011111110-1111111110-1011111110-1111111110
    ${dl_allocated_normal_subframes}=  Catenate   1001110011-1111111111-1011110011-1111111111-1011110011-1111111111-1011110011-1111111111

    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=  0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...     52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,
    ...     52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,
    ...     52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,
    ...     52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,
    ...     52+79:0,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=   0:0,79+1:0,79+2:0,79+3:0,79+4:0,79+5:0,79+6:0,79+7:0,79+8:0,79+9:0,79+10:0,79+11:0,
    ...     79+12:0,79+13:0,79+14:0,79+15:0,79+16:0,79+17:0,79+18:0,79+19:0,79+20:0,79+21:0,79+22:0,79+23:0,79+24:0,79+25:0,79+26:0,79+27:0,79+28:0,
    ...     79+29:0,79+30:0,79+31:0,79+32:0,79+33:0,79+34:0,79+35:0,79+36:0,79+37:0,79+38:0,79+39:0,79+40:0,79+41:0,79+42:0,79+43:0,79+44:0,79+45:0,
    ...     79+46:0,79+47:0,79+48:0,79+49:0,79+50:0,79+51:0,79+52:0,79+53:0,79+54:0,79+55:0,79+56:0,79+57:0,79+58:0,79+59:0,79+60:0,79+61:0,79+62:0,
    ...     79+63:0,79+64:0,79+65:0,79+66:0,79+67:0,79+68:0,79+69:0,79+70:0,79+71:0,79+72:0,79+73:0,79+74:0,79+75:0,79+76:0,79+77:0,79+78:0,
    ...     79+79:0,79
    ...    ELSE    Catenate    SEPARATOR=   0:0,106+1:0,106+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,
    ...     106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,106+26:0,
    ...     106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,
    ...     106+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,
    ...     106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+70:0,106+71:0,
    ...     106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    common_Dss_CellSetup.DSS enb crm periodic allocation pattern   dl_allocated_normal_subframes=${dl_allocated_normal_subframes}
    ...                                                          dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                          alias=${alias}

    common_Dss_CellSetup.DSS DL Cell Periodic Resource Allocation Phase3     alias=${alias}

#---------Feature Specific-----------------------------------------------------------------------------------------------------------[150 characters]
Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ueid}
    ${profile_id}=     Evaluate    ${ueid}+${4}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...  cmd=ue_ta_nr profile_id=${profile_id} ue_p_delay_initial=${delay_initial}
    # ute-wtssim-ue-Keywords.Send Egate Command and verify output
    #     ...  cmd=ue_testmode_set_nr id=${ueid} testmode=ta action=activate profile_id=${ueid}+${4}
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=${ueid}  testmode=ta  profile_id=${profile_id}  action=activate

Initiate Timing Advance
    ${configured_ues}=  Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    FOR    ${ue}    IN    @{configured_ues}
        ${delay_initial}=    set variable     ${ue_p_delay_initial[${ue}-${1}]}
        CB013715_scenario_modifications.Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ue}
    END
    BuiltIn.Log To Console    Initiate_Timing_Advance is OK

Initiate Timing Advance with ue_speed ${ue_speed}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...  cmd=ue_ta_nr profile_id=1 nb_reps_ta_sim=255 ue_speed=${ue_speed} ue_p_delay_max=288 ue_p_delay_min=0 ue_p_delay_initial=100
    ${configured_ues}=  Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    FOR    ${ue}    IN    @{configured_ues}
        ute-wtssim-ue-Keywords.Send Egate Command and verify output
        ...  cmd=ue_testmode_set_nr id=${ue} testmode=ta action=activate profile_id=1
    END
    BuiltIn.Log To Console    Initiate_Timing_Advance with ue_speed ${ue_speed} is OK

Initiate Lmf Ecid Meas with meas_qty NR_Timing_Advance
    ${configured_ues}=  Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    FOR    ${ue}    IN    @{configured_ues}
        ${cmd}=    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue} nrppa_transaction_id=1 lmf_ue_measurement_id=1
	    ...                               report_characteristics=OnDemand meas_qty=NR_Timing_Advance
        ute-wtssim-ue-Keywords.Send Egate Command and verify output    cmd=${cmd}
    END
    BuiltIn.Log To Console    Set_lmf_send_ecid_meas_req is OK

Initiate UE as ${speed} speed and ${speed_direction} gNB
    ${configured_ues}=  Scenario-Common-Keywords.Get UE IDs configured for Scenario    scenario_name=${scenario_name}
    ${ue_id_1}=    set variable    ${configured_ues}[0]
    ute-wtssim-ue-Keywords.Set UE-${ue_id_1} as ${speed} Speed UE ${speed_direction} gNB
    BuiltIn.Log To Console    Set UE-${ue_id_1} as ${speed} Speed UE ${speed_direction} gNB is OK

Update Beam Control Parameters
    ${attach_ue_ids}=  Scenario-Common-Keywords.Get UE Ids configured for scenario  scenario_name=${scenario_name}
    sort list  ${attach_ue_ids}
    IF   '${numberOfTransmittedSsBlocks_NRCELLGrp[0]}'=='2 beams'
        ${beam_control_dict}=  CB013715_tools.create_beam_control_for_beamset_2_dict
    ELSE
        ${beam_control_dict}=  CB013715_tools.Create Beam Control Dict
    END
    ${ue_number}=  get length  ${attach_ue_ids}
    FOR  ${id}  IN RANGE  0  ${ue_number}
	    ${beam_control}=  Get from dictionary    ${beam_control_dict}     ${id}
	    ute-wtssim-ue-Keywords.Configure Beam Control Testmode    profile_id=${attach_ue_ids}[${id}]
        ...                                                       &{beam_control}
        ute-wtssim-ue-Keywords.Associate UEs to testmode    ue_id=${attach_ue_ids}[${id}]
        ...                                                 testmode=beam_control
        ...                                                 profile_id=${attach_ue_ids}[${id}]
        ...                                                 action=activate beamaction=attach
    END

Send A1 MR for scell addition and Verify whether gNB Configures CA and Deconfigures A1 Measurement at the UE
    [Arguments]   ${ue_id}    ${carrier_freq}
    ${egate_log}  ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A1 srsrp_nr=55 srsrq_nr=55
    ...    pass_regexp=rrcReconfigurationComplete
    ${Rrc_after_A1_based_scell_addition}    Set variable    ${testCaseDir}/Rrc_after_A1_based_scell_addition_UE_${ue_id}.log
    Create File    ${Rrc_after_A1_based_scell_addition}   ${egate_log}
    ${msg}=    Catenate     Send A1 MR for scell addition and Verify whether gNB Configures CA and Deconfigures A1 Measurement at the UE
    nps_tarf_tools.log_to_console_with_time_prefix     ${msg}          level=INFO
    ${status}    ${msg}    BuiltIn.Run Keyword And Warn On Failure     Verify Measurement ID is absent   event_type=A1  ue_id=${ue_id}
    ...                                                                                                  carrier_freq=${carrier_freq}
    IF     '${status}'=='PASS'
         nps_tarf_tools.log_to_console_with_time_prefix     Verify A1 Measurement ID is absent: PASS successfully      level=INFO
    ELSE
         nps_tarf_tools.log_to_console_with_time_prefix     Verify A1 Measurement ID is absent: failed [${msg}]        level=WARN
    END
    ${status}    ${msg}    BuiltIn.Run Keyword And Warn On Failure     TARF-Keywords.Verify Sequence in File   ${ue_id}
    ...                                                                                     ${Rrc_after_A1_based_scell_addition}    @{CA_MSG_SEQ}
    IF     '${status}'=='PASS'
         nps_tarf_tools.log_to_console_with_time_prefix     Verify CA Sequence in File: PASS successfully      level=INFO
    ELSE
         nps_tarf_tools.log_to_console_with_time_prefix     Verify CA Sequence in File: failed [${msg}]        level=WARN
    END

Verify Measurement ID is configured
    [Arguments]  ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${meas_ids}     Get NR Measurement IDs     ${event_type}  ue_id=${ue_id}  carrier_freq=${carrier_freq}
    ${cnt}          Get Length    ${meas_ids}
    Run Keyword If  ${cnt} == 0  Fail  No ${event_type} measurement id found

Verify Measurement ID is absent
    [Arguments]  ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${status}  Run Keyword And Return Status   Verify Measurement ID is configured  ${event_type}  ${ue_id}  carrier_freq=${carrier_freq}
    Run Keyword if  ${status}  Fail  ${event_type} measurement id is configured

Get NR Meas Obj Id
    [Arguments]   ${meas_output}  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${oId}          String.Get Regexp Matches  ${meas_output}  (\\d+)\[ \]+NR\[ \]+${carrier_freq}\[ \]+  1
    ${cnt}          Get length    ${oId}
    Run Keyword if  ${cnt} == 0  Fail  Measurement Object:${carrier_freq} not found
    [Return]  ${oId}[0]

Get NR Measurement IDs
    [Arguments]   ${event_type}  ${ue_id}=1  ${carrier_freq}=${NRCELL-1.nrarfcn_gscn}
    ${measIds}        Create List
    ${meas_output}    ute-wtssim-ue-Keywords.Send Egate Command and verify output    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=EGATE>
    ${objId}          Get NR Meas Obj Id   meas_output=${meas_output}  carrier_freq=${carrier_freq}
    @{reports}        String.Get Regexp Matches  ${meas_output}
    ...               (\\d+)\\s+NR\\s+Event${event_type}\\s+rsrp rsrq( sinr)*\\s+\\d\\s+\\d+ (ms|min)\\s+\\d+\\s+  1

    FOR  ${report}  IN  @{reports}
       ${measId}   String.Get Regexp Matches  ${meas_output}  (\\d+)\[ \]+${objId}\[ \]+${report}\[ \]+  1
       ${cnt}      Get length      ${measId}
       Run Keyword If  ${cnt} > 1   Fail  MeasID not unique
       Run Keyword If  ${cnt} == 1  Collections.Append To List  ${measIds}  ${measId}[0]
    END
    [Return]  ${measIds}

Load Imput Yaml File
    yaml_parser.load_parameter_file    ${yaml_file_path}

Fetch Blanking Parameters From yaml
    [Arguments]    ${sce_name}
    ${blanking_params}    yaml_parser.get_feature_parameters_dict   sce_name=${sce_name}    param_section=blanking_params
    [Return]    ${blanking_params}

update PrbBlanking parameters wo commissioning
    # ${scenario_name} should be visible here
    Load Imput Yaml File
    ${blanking_params_dict}    Fetch Blanking Parameters From yaml    sce_name=${scenario_name}
    set suite variable     ${parameters_PrbBlanking['actPRBBlanking']}                ${blanking_params_dict['actPRBBlanking']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}     ${blanking_params_dict['nbrOfBlankedPRBsLowEdgeDL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}     ${blanking_params_dict['nbrOfBlankedPRBsLowEdgeUL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}    ${blanking_params_dict['nbrOfBlankedPRBsHighEdgeDL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}    ${blanking_params_dict['nbrOfBlankedPRBsHighEdgeUL']}
    set suite variable     ${parameters_PrbBlanking['type0CoresetConfigurationIndex']}    ${blanking_params_dict['type0CoresetConfigurationIndex']}
    set suite variable     ${parameters_PrbBlanking['aggregationLevel']}                  ${blanking_params_dict['aggregationLevel']}
    set suite variable     ${parameters_PrbBlanking['msg1FrequencyStart']}                ${blanking_params_dict['msg1FrequencyStart']}
    set suite variable    ${w_actPRBBlanking}      True

update PrbBlanking parameters and perform commissioning
    # ${scenario_name} should be visible here
    ${w_calculate_delta_scf}    set variable       false
    Load Imput Yaml File
    ${blanking_params_dict}    Fetch Blanking Parameters From yaml    sce_name=${scenario_name}
    set suite variable     ${parameters_PrbBlanking['actPRBBlanking']}                ${blanking_params_dict['actPRBBlanking']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}     ${blanking_params_dict['nbrOfBlankedPRBsLowEdgeDL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}     ${blanking_params_dict['nbrOfBlankedPRBsLowEdgeUL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}    ${blanking_params_dict['nbrOfBlankedPRBsHighEdgeDL']}
    set suite variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}    ${blanking_params_dict['nbrOfBlankedPRBsHighEdgeUL']}
    set suite variable     ${parameters_PrbBlanking['type0CoresetConfigurationIndex']}    ${blanking_params_dict['type0CoresetConfigurationIndex']}
    set suite variable     ${parameters_PrbBlanking['aggregationLevel']}                  ${blanking_params_dict['aggregationLevel']}
    set suite variable     ${parameters_PrbBlanking['msg1FrequencyStart']}                ${blanking_params_dict['msg1FrequencyStart']}
    set suite variable    ${w_actPRBBlanking}      True
    set suite variable    ${gnb_scf}    ${test_scf_file}
    scf.load_scf    ${gnb_scf}
        IF   '10MHz' in '${SUITE_NAME}' and 'NSAOnly' in '${SUITE_NAME}' and '${w_actPRBBlanking}'=='True'
            CB013715_initial_commissioning.Initial commissioning for Cell1 with PRB Blanking for cellDepType=NSA  ${TestDSSContext}
            ...                                                                                                   gnb_scf=${gnb_scf}
        ELSE
            BuiltIn.log     test scenario not supported here : Review the test plz     level=ERROR
        END
    scf.save_scf    ${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml

   # add here check of NIDD configuration
    robot_extension.Run Keyword And Warn On Failure   TARF-Keywords.Admin Validate SCF
    ...                                                   scf_path_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml
    ...                                                   dir=${LOG_PATH}

    Run Keyword If    '${w_calculate_delta_scf}'=='true'     Dated log     calculate_delta_scf...
    ...    ELSE                                              Dated log     no calculate_delta_scf...
    ${delta_scf_path}=    Set variable    ${configuration_directory}/delta_SCF_updated_${scenario_name}.xml
    Run Keyword If    '${w_calculate_delta_scf}'=='true'    scf.calculate_delta_scf
    ...                                               target_scf_path=${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml
    ...                                               actual_scf_path=${gnb_scf_updated}    delta_scf_path=${delta_scf_path}
    ${is_commissioning_needed}=    Run Keyword If    '${w_calculate_delta_scf}'=='true'    Check if commissioning is needed    ${delta_scf_path}
    ...                               ELSE                                                 set Variable     ${True}

    Return from keyword if    not ${is_commissioning_needed}

    ${oam_alias}=    set variable     coam_gnb
    nps_tarf_tools.log_to_console_with_time_prefix  perform_commissioning [${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml]
    ...                                            level=INFO
    admin.perform_commissioning  scf_file=${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=true  timeout=600

    # need to update blanked Prb into TestDSSContext
    set suite variable     ${test_scf_file}    ${configuration_directory}/SCFC_gNB0_DU_orig_updated_${scenario_name}.xml
    DSS_keywords.Update Blanked PRBs into "${TestDSSContext}" for cellID "${fdd_cell_1}"

Get dssFixedMbsfnPattern Bitmap From Log
    [Arguments]    ${log_file_path}
    ${json_string}=    OperatingSystem.Get File    ${log_file_path}
    ${parsed_json}=    Evaluate    json.loads('''${json_string}''')    json
    ${extracted_dssSubframeReservation}=    Collections.Get From Dictionary    ${parsed_json}    dssSubframeReservation
    ${extracted_bitmap}=    Collections.Get From Dictionary    ${extracted_dssSubframeReservation}    dssFixedMbsfnPattern
    [Return]    ${extracted_bitmap}
