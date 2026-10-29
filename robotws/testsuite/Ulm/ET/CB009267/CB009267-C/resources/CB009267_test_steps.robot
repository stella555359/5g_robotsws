*** Settings ***
Documentation    Test Steps for CB009267

Resource   ../../../../resources/Common/wts_ue.robot
Library    ../../../L2/libraries/template_functions.py    WITH NAME    template


*** Variables ***
${default_pathloss}         75
${target_bler}           100,100,100,98,95,90,50,10,5,1,0.5,0.1,0,0,0



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

Run Scenario specific Keywords Before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    IF                'PM_1744_overheating' in '${scenario_name}'         CB009267_5G_PM_1744_FR1 Before Attach
    ...    ELSE IF    'PM_1077' in '${scenario_name}'                     CB009267_5G_PM_1077_FR1 Before Attach
    ...    ELSE IF    'PM_1078' in '${scenario_name}'                     CB009267_5G_PM_1078_FR1 Before Attach
    ...    ELSE IF    'PM_1743' in '${scenario_name}'                     CB009267_5G_PM_1743_FR1 Before Attach
    ...    ELSE IF    'PM_1816_UL_NACK_flooding' in '${scenario_name}'    CB009267_5G_PM_1816_and_1815_FR1 Before Attach
    ...    ELSE IF    'PM_1815_UL_NACK_flooding' in '${scenario_name}'    CB009267_5G_PM_1816_and_1815_FR1 Before Attach
    ...    ELSE IF    'PM_1744_1823_overheat_and_recover' in '${scenario_name}'  CB009267_5G_PM_1744_1823_FR2 Before Attach
    ...    ELSE IF    'PM_1746_overheating' in '${scenario_name}'         CB009267_5G_PM_1746_FR1 Before Attach
    ...    ELSE IF    'PM_1746_1825_overheat_and_recover' in '${scenario_name}'  CB009267_5G_PM_1746_1825_FR2 Before Attach
    ...    ELSE IF    'PM_1755' in '${scenario_name}'                     CB009267_5G_PM_1755_FR1 Before Attach   # (SA) SCell Deact with UE ovht
    ...    ELSE IF    'PM_1760_overheating' in '${scenario_name}'         CB009267_5G_PM_1760_FR1 Before Attach   # (NSA) SCell Deact with UE ovht
    ...    ELSE IF    'PM_1851' in '${scenario_name}'                     CB009267_5G_PM_1851_FR1 Before Attach   # (SA) SCell Deact with SCell ovht
    ...    ELSE IF    'PM_1851_overheating_fr2' in '${scenario_name}'     CB009267_5G_PM_1851_FR2 Before Attach   # (SA) SCell Deact with SCell ovht
    ...    ELSE IF    'PM_1853_overheating_fr1' in '${scenario_name}'     CB009267_5G_PM_1853_FR1 Before Attach   # (NSA) SCell Deact with SCell ovht
    ...    ELSE IF    'PM_1853_overheating_fr2' in '${scenario_name}'     CB009267_5G_PM_1853_FR2 Before Attach   # (NSA) SCell Deact with SCell ovht
    ...    ELSE IF    'PM_1813_low_split_pwr' in '${scenario_name}'       CB009267_5G_PM_1813_FR1 Before Attach
    ...    ELSE IF    'PM_1855_low_buffer' in '${scenario_name}'          CB009267_5G_PM_1855_FR1 Before Attach
    ...    ELSE IF    'PM_1857_low_buffer' in '${scenario_name}'          CB009267_5G_PM_1857_FR1 Before Attach
    ...    ELSE IF    'PM_1754' in '${scenario_name}'                     CB009267_5G_PM_1754_FR2 Before Attach
    ...    ELSE IF    'PM_1824' in '${scenario_name}'                     CB009267_5G_PM_1824_FR2 Before Attach
    ...    ELSE IF    'PM_1826' in '${scenario_name}'                     CB009267_5G_PM_1824_FR2 Before Attach


Run Feature Specific Keywords After Attach Before Traffic Is Started
    RETURN


Run Feature Specific Keywords During Traffic Before Detach
    [Arguments]  @{varargs}
    Log    Run Feature specific keywords during traffic before detach
    IF                'PM_1744_overheating' in '${scenario_name}'         CB009267_5G_PM_1744_FR1 During Traffic Before Detach sa
    ...    ELSE IF    'PM_1077' in '${scenario_name}'                     CB009267_5G_PM_1077_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1078' in '${scenario_name}'                     CB009267_5G_PM_1078_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1743' in '${scenario_name}'                     CB009267_5G_PM_1743_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1816_UL_NACK_flooding' in '${scenario_name}'    CB009267_5G_PM_1816_and_1815_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1815_UL_NACK_flooding' in '${scenario_name}'    CB009267_5G_PM_1816_and_1815_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1744_1823_overheat_and_recover' in '${scenario_name}'  CB009267_5G_PM_1744_1823_FR2 During Traffic Before Detach
    ...    ELSE IF    'PM_1746_overheating' in '${scenario_name}'         CB009267_5G_PM_1746_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1746_1825_overheat_and_recover' in '${scenario_name}'  CB009267_5G_PM_1746_1825_FR2 During Traffic Before Detach
    ...    ELSE IF    'PM_1755' in '${scenario_name}'                     CB009267_5G_PM_1755_FR1 During Traffic Before Detach sa
    ...    ELSE IF    'PM_1760_overheating' in '${scenario_name}'         CB009267_5G_PM_1760_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1851' in '${scenario_name}'                     CB009267_5G_PM_1851_FR1 During Traffic Before Detach sa    # SCell ovht
    ...    ELSE IF    'PM_1851_overheating_fr2' in '${scenario_name}'     CB009267_5G_PM_1851_FR2 During Traffic Before Detach    # SCell ovht
    ...    ELSE IF    'PM_1853_overheating_fr1' in '${scenario_name}'     CB009267_5G_PM_1853_FR1 During Traffic Before Detach    # SCell ovht
    ...    ELSE IF    'PM_1853_overheating_fr2' in '${scenario_name}'     CB009267_5G_PM_1853_FR2 During Traffic Before Detach    # SCell ovht
    ...    ELSE IF    'PM_1813_low_split_pwr' in '${scenario_name}'       CB009267_5G_PM_1813_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1855_low_buffer' in '${scenario_name}'          CB009267_5G_PM_1855_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1857_low_buffer' in '${scenario_name}'          CB009267_5G_PM_1857_FR1 During Traffic Before Detach
    ...    ELSE IF    'PM_1754' in '${scenario_name}'                     CB009267_5G_PM_1754_FR2 During Traffic Before Detach
    ...    ELSE IF    'PM_1824' in '${scenario_name}'                     CB009267_5G_PM_1824_FR2 During Traffic Before Detach sa
    ...    ELSE IF    'PM_1826' in '${scenario_name}'                     CB009267_5G_PM_1824_FR2 During Traffic Before Detach nsa


Run Feature Specific Keywords After Traffic Before Detach
    ${attached_ue_list}=    template.Get Ue Ids Configured For Scenario    scenario_name=${scenario_name}
    Sort List  ${attached_ue_list}
    Set Test Variable    ${attached_ue_list}
    ${string_attached_ue_list}=    Catenate    SEPARATOR=,    @{attached_ue_list}
    Set Test Variable    ${string_attached_ue_list}
    Log To Console    Attached UE's: ${string_attached_ue_list}
    wts_ue.Send Egate Command And Verify Output    ue_stats id=${string_attached_ue_list} type=pdsch,pusch
    Log To Console    ue_stats id=${string_attached_ue_list} type=pdsch,pusch
    Sleep    0.5s
    wts_ue.Send Egate Command And Verify Output    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000
    Log To Console    ue_stats_nr id=${string_attached_ue_list} type=pdsch,pusch scell=0-5 delay=60000
    Sleep    0.5s

    TRY
        Display Traffic Data Rate
    EXCEPT    AS    ${error}
        Log  Error in "Display Traffic Data Rate": ${error}  level=ERROR  console=yes
    END


Run Feature specific keywords after detach
    IF                'PM_1816_UL_NACK_flooding' in '${scenario_name}'    Deactivate Cell Noise Test Modes After Detach
    ...    ELSE IF    'PM_1815_UL_NACK_flooding' in '${scenario_name}'    Deactivate Cell Noise Test Modes After Detach
    ...    ELSE IF    'PM_1754' in '${scenario_name}'                     Deactivate Cell Noise Test Modes After Detach
    ...    ELSE IF    'PM_1824' in '${scenario_name}'                     Deactivate Csi Override Test Modes After Detach sa
    ...    ELSE IF    'PM_1826' in '${scenario_name}'                     Deactivate Csi Override Test Modes After Detach nsa

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Display Traffic Data Rate
    IF  'NSA' in '${SUITE_NAME}'
        ${bearer_stats_attribs_nsa}  ${_} =  template.Get Bearer Stat Params  scenario_name=${scenario_name}
        ${tp}=  wts_ue.Get Bearer Stats From Egate
        ...    ue_id=${bearer_stats_attribs_nsa["ues"]}  trf_id=${bearer_stats_attribs_nsa["trf_ids"]}
        ...  id=${bearer_stats_attribs_nsa["bearers"]}
        Log To Console    Current DL throughput for all UEs is ${tp} bps
    ELSE
        ${_}  ${bearer_stats_attribs_sa}=  template.Get Bearer Stat Params  scenario_name=${scenario_name}
        ${tp}=  wts_ue.Get Bearer Stats From Egate
        ...  ue_id=${bearer_stats_attribs_sa["ues"]}  trf_id=${bearer_stats_attribs_sa["trf_ids"]}  pdu=${bearer_stats_attribs_sa["pdus"]}
        ...  qfi=${bearer_stats_attribs_sa["qfis"]}
        Log To Console    Current DL throughput for all UEs is ${tp} bps
    END


CB009267_5G_PM_1744_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1744_FR1 Before Attach
    wts_ue.Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=5 cqi_mode=overheating overheating_cnt=15


CB009267_5G_PM_1744_FR1 During Traffic Before Detach ${sa_nsa}
    Log To Console    CB009267_5G_PM_1744_FR1 During Traffic Before Detach - overheating UEs
    Sleep  1

    ${scell}=  Set Variable If     '${sa_nsa}' == 'sa'      1    6

    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=${scell} testmode=csi_override action=activate profile_id=5
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=${scell} testmode=csi_override action=deactivate profile_id=5
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

CB009267_5G_PM_1077_FR1 Before Attach
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=1 pathloss=130
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}


CB009267_5G_PM_1077_FR1 During Traffic Before Detach
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} testmode=ul_sinr action=activate profile_id=1
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} testmode=ul_sinr action=deactivate profile_id=1
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

CB009267_5G_PM_1078_FR1 Before Attach
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=${default_pathloss}
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${id}  IN  @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${id} scell=1 testmode=ul_sinr profile_id=3 action=activate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END


CB009267_5G_PM_1078_FR1 During Traffic Before Detach
    Sleep  1
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=164
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    Sleep  1
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=${default_pathloss}
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    Sleep  1


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

CB009267_5G_PM_1743_FR1 Before Attach
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=nsa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=${default_pathloss}
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR  ${id}  IN  @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${id} scell=1 testmode=ul_sinr profile_id=3 action=activate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END


CB009267_5G_PM_1743_FR1 During Traffic Before Detach
    Sleep  1
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=164
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    Sleep  1
    ${egate_command}=  Set Variable  ul_sinr_testmode_nr profile_id=3 pathloss=${default_pathloss}
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    Sleep  1


CB009267_5G_PM_1754_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1754_FR2 Before Attach
    Change Cell Noise Level For All Cells Before Attach
    Configure Pwr_ctrl Testmode
    Configure Adv_bler Testmode
    wts_ue.Configure NR BLER Testmode  profile_id=1  target_mcs=2  target_bler=${target_bler}  mcs_table=all  rank=0
    wts_ue.Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=5 cqi=4 cqi_mode=fixed ri=0 ri_mode=fixed


Configure Pwr_ctrl Testmode
    ${egate_command}=    Set Variable    power_control_testmode_nr profile_id=2 pusch_tx_power_offset=-400
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}


Configure Adv_bler Testmode
    ${egate_command}=    Set Variable    adv_bler_testmode_nr profile_id=${1} target_bler_profile_id=${1}
    ${egate_command}=    Set Variable    ${egate_command} target_bler=98.1,2.1,3.1,4.1,5.1,6.1,7.1,8.1,9.1,10.1,11.1,12.1,13.1,14.1,15.1
    ${egate_command}=    Set Variable    ${egate_command} target_mcs=2 mcs_table=qam64 rank=0 p_target_bler_profile_id=${1}
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output    cmd=${egate_command}


CB009267_5G_PM_1754_FR2 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1754_FR2 During Traffic Before Detach
    Sleep  1
    Simulate Bad Channel Condition In DL Using Bler Testmode


Simulate Bad Channel Condition In DL Using Bler Testmode
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR  ${ue}  IN  @{attached_ues_list}
        ${egate_command}=    Set Variable    ue_testmode_set_nr id=${ue} profile_id=${5} scell=secondary testmode=csi_override action=activate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output    cmd=${egate_command}
        Sleep  0.5

        ${egate_command}=    Set Variable    ue_testmode_set_nr id=${ue} profile_id=${1} scell=secondary testmode=bler action=activate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output    cmd=${egate_command}
    END

    Sleep  2

    FOR  ${ue}  IN  @{attached_ues_list}
        ${egate_command}=    Set Variable    ue_testmode_set_nr id=${ue} profile_id=${5} scell=secondary testmode=csi_override action=deactivate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output    cmd=${egate_command}
        Sleep  0.5

        ${egate_command}=    Set Variable    ue_testmode_set_nr id=${ue} profile_id=${1} scell=secondary testmode=bler action=deactivate
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output    cmd=${egate_command}
    END
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

CB009267_5G_PM_1816_and_1815_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1816_and_1815_FR1 Before Attach
    Change Cell Noise Level For All Cells Before Attach
    ${egate_command}=    Set Variable    ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-400
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    ${egate_command}=    Set Variable    ul_sinr_testmode_nr profile_id=2 sinr_target_pusch=-400
    Log To Console    ${egate_command}
    wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}


Change Cell Noise Level For All Cells Before Attach
    wts_ue.Send Egate Command And Verify Output
    ...    cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${-600} noise_prach=${-600} noise_pusch=${-600} noise_srs=${-600}
    Sleep    1s    reason=wait command to be executed
    wts_ue.Send Egate Command And Verify Output    cmd=ul_cell_noise_testmode_nr profile_id=2    pass_regexp=ul_cell_noise_testmode_nr Parameters
    #activate ul_cell_noise
    wts_ue.Send Egate Command And Verify Output    cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
    Sleep    1s    reason=wait command to be executed


CB009267_5G_PM_1816_and_1815_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1816_and_1815_FR1 During Traffic Before Detach
    ${ue_type}=    Set Variable If    'PM_1815' in '${scenario_name}'    nsa    sa
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${ue_type}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=primary testmode=ul_sinr action=activate profile_id=1
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=primary testmode=ul_sinr action=deactivate profile_id=1
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=secondary testmode=ul_sinr action=activate profile_id=2
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        ${egate_command}=  Set Variable  ue_testmode_set_nr id=${ue} scell=secondary testmode=ul_sinr action=deactivate profile_id=2
        Log To Console    ${egate_command}
        wts_ue.Send Egate Command And Verify Output   cmd=${egate_command}
    END


Deactivate Cell Noise Test Modes After Detach
    Send Egate Command And Verify Output    cmd=cell_testmode_set_nr cell_id=all gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
    Sleep    1s    reason=wait command to be executed


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1744_1823_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1744_1823_FR2 Before Attach (1744 FR1 reuse)
    CB009267_5G_PM_1744_FR1 Before Attach

CB009267_5G_PM_1744_1823_FR2 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1744_1823_FR2 During Traffic Before Detach - scheduling suspended and recovered (1744 FR1 reuse)
    CB009267_5G_PM_1744_FR1 During Traffic Before Detach sa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1746_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1746_FR1 Before Attach (1744 FR1 reuse)
    CB009267_5G_PM_1744_FR1 Before Attach

CB009267_5G_PM_1746_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1746_FR1 During Traffic Before Detach - overheating UEs (1744 FR1 reuse)
    Sleep    6s
    CB009267_5G_PM_1744_FR1 During Traffic Before Detach nsa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1746_1825_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1746_1825_FR2 Before Attach (1744 FR1 reuse)
    CB009267_5G_PM_1744_FR1 Before Attach

CB009267_5G_PM_1746_1825_FR2 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1746_1825_FR2 During Traffic Before Detach - scheduling suspended and recovered (1744 FR1 reuse)
    CB009267_5G_PM_1744_FR1 During Traffic Before Detach nsa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1755_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1755_FR1 Before Attach


CB009267_5G_PM_1755_FR1 During Traffic Before Detach ${sa_nsa}
    Log To Console    CB009267_5G_PM_1755_FR1 During Traffic Before Detach - SCELL deactivation based on UE overheating
    Sleep    3

    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output   cmd=ue_assistance_send_nr ue_id=${ue} forOverheating=on reducedCCsDL=0 reducedCCsUL=0
    END
    Sleep    2
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output   cmd=ue_assistance_send_nr ue_id=${ue} forOverheating=on reducedCCsDL=1 reducedCCsUL=1
    END
    Sleep    2


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1760_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1760_FR1 Before Attach


CB009267_5G_PM_1760_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1760_FR1 During Traffic Before Detach - SCELL deactivation based on UE overheating (1755 FR1 reuse)
    CB009267_5G_PM_1755_FR1 During Traffic Before Detach nsa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1851_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1851_FR1 Before Attach
    wts_ue.Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=5 cqi=0 cqi_mode=fixed


CB009267_5G_PM_1851_FR1 During Traffic Before Detach ${sa_nsa}
    Log To Console    CB009267_5G_PM_1851_FR1 During Traffic Before Detach - SCELL deactivation due to scell overheating
    Sleep    3

    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_testmode_set_nr id=${ue} scell=secondary testmode=csi_override action=activate profile_id=5
    END
    Sleep    1
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output   cmd=ue_assistance_send_nr ue_id=${ue} forOverheating=on reducedCCsDL=0 reducedCCsUL=0
    END
    Sleep    2
        FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_testmode_set_nr id=${ue} scell=secondary testmode=csi_override action=deactivate profile_id=5
    END
    Sleep    1
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output   cmd=ue_assistance_send_nr ue_id=${ue} forOverheating=on reducedCCsDL=1 reducedCCsUL=1
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1851_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1851_FR2 Before Attach


CB009267_5G_PM_1851_FR2 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1851_FR2 During Traffic Before Detach - SCELL deactivation based on SCELL overheating (1755 FR1 reuse)
    CB009267_5G_PM_1755_FR1 During Traffic Before Detach sa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1853_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1853_FR1 Before Attach (1851 FR1 reuse)
    CB009267_5G_PM_1851_FR1 Before Attach


CB009267_5G_PM_1853_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1853_FR1 During Traffic Before Detach - SCELL deactivation based on SCELL overheating (1851 FR1 reuse)
    CB009267_5G_PM_1851_FR1 During Traffic Before Detach nsa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1853_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1853_FR2 Before Attach


CB009267_5G_PM_1853_FR2 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1853_FR2 During Traffic Before Detach - overheating SCell (cqi=0) (1755 FR1 reuse)
    CB009267_5G_PM_1755_FR1 During Traffic Before Detach nsa


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1813_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1813_FR1 Before Attach - Set up test mode profiles
    # (source: CB006137-ET-C-B2503_Single_UE_UL_CA_Call_with_dynamic_UL_power_sharing_scell_suspend_resume_for_PC3)
    ${cmd}=  Catenate    phr_override_testmode_nr profile_id=6 phr_start=-33
    ...    phr_mode=Fixed phr_min=0 phr_max=30 phr_step_size=5 phr_period=10 pc_max=23
    wts_ue.Send Egate Command And Verify Output    ${cmd}


CB009267_5G_PM_1813_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1813_FR1 During Traffic Before Detach - Activate PHR

    Sleep  0.5

    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        # For PCell
        Activate Power Headroom Report For UE ${ue} On Scell 0
        # For 1st SCell
        Activate Power Headroom Report For UE ${ue} On Scell 1
    END


Activate Power Headroom Report For UE ${ue} On Scell ${scell_idx}
    Log To Console    Start UE ${ue} sending Power Headroom Report to gNB for scell ${scell_idx}
    wts_ue.Send Egate Command And Verify Output
    ...    cmd=ue_testmode_set_nr id=${ue} testmode=phr_override action=activate profile_id=6 scell=${scell_idx}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1855_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1855_FR1 Before Attach

CB009267_5G_PM_1855_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1855_FR1 During Traffic Before Detach
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    Sleep  1
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_stop ue=${ue} dir=dl trf_id=2 pdu=2
        Sleep  2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_stop ue=${ue} dir=ul trf_id=4 pdu=2
        Sleep  2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_start ue=${ue} dir=dl trf_id=2 protocol=udp ack_mode=off cl_trf_stats=on pdu=2 qfi=1 mbps=150
        Sleep  2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_start ue=${ue} dir=ul trf_id=4 protocol=udp ack_mode=off cl_trf_stats=on pdu=2 qfi=1 mbps=150
        Sleep  2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_start ue=${ue} dir=dl trf_id=2 protocol=udp ack_mode=off cl_trf_stats=on pdu=2 qfi=1 kbps=150
        Sleep  2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_start ue=${ue} dir=ul trf_id=4 protocol=udp ack_mode=off cl_trf_stats=on pdu=2 qfi=1 kbps=150
        Sleep  2
    END
    Sleep  1
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

CB009267_5G_PM_1857_FR1 Before Attach
    Log To Console    CB009267_5G_PM_1857_FR1 Before Attach

CB009267_5G_PM_1857_FR1 During Traffic Before Detach
    Log To Console    CB009267_5G_PM_1857_FR1 During Traffic Before Detach
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=nsa    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    Sleep  3
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_stop ue=${ue} dir=dl trf_id=2 id=2
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=trf_data_stop ue=${ue} dir=ul trf_id=3 id=2
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
CB009267_5G_PM_1824_FR2 Before Attach
    Log To Console    CB009267_5G_PM_1824_FR2 Before Attach
    wts_ue.Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=5 cqi=0 cqi_mode=fixed


CB009267_5G_PM_1824_FR2 During Traffic Before Detach ${sa_nsa}
    Log To Console    CB009267_5G_PM_1824_FR2 During Traffic Before Detach - SCELL suspension and then deactivation
    Sleep    2

    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_testmode_set_nr id=${ue} scell=secondary testmode=csi_override action=activate profile_id=5
    END


Deactivate Csi Override Test Modes After Detach ${sa_nsa}
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=${sa_nsa}    with_auto_attach=${TRUE}
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    FOR    ${ue}    IN    @{attached_ues_list}
        wts_ue.Send Egate Command And Verify Output
        ...    cmd=ue_testmode_set_nr id=${ue} scell=secondary testmode=csi_override action=deactivate profile_id=5
    END
    Sleep    1s    reason=wait command to be executed

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
