*** Settings ***
Documentation    internal_ap_operate

*** Keywords ***

Wait '${time}' for stable running
    sleep    ${time}

Modify L1ByPTestModeConfiguration
    [Arguments]    ${H0}    ${V0}    ${H1}    ${V1}    ${ueNum}=8    ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${modify_list0} =    create list    @{empty}
    FOR    ${ue}    IN RANGE    ${ueNum}
        ${list0}    create list
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ue}"]//NrRxBfCumulSpatialCovMatVNegative45
        ${modify_list0}    Combine Lists    ${modify_list0}    ${list0}
    END
    ${modify_list1}    create list
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ${modify_list}    Combine Lists    ${modify_list0}    ${modify_list1}
    #${modify_list}    Combine Lists    ${modify_list2}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}

Set Pos By Modify L1ByPTestModeConfiguration
    [Arguments]    ${H0}    ${V0}    ${H1}    ${V1}    ${H2}    ${V2}    ${H3}    ${V3}    ${ueId}=0
    ...        ${srsNumCountSwitchProfile1}=0    ${srsNumCountSwitchProfile2}=0    ${srsNumCountSwitchProfile3}=0    ${srsNumCountSwitchProfile4}=0
    ...        ${puschNumCountSwitch1}=0    ${puschNumCountSwitch2}=0    ${puschNumCountSwitch3}=0    ${puschNumCountSwitch4}=0
    ...        ${UlRank1}=1    ${UlRank2}=1    ${UlRank3}=1    ${UlRank4}=1
    ...        ${Sinr1}=33    ${Sinr2}=33    ${Sinr3}=33    ${Sinr4}=33
    ...        ${ulPmiRank1Sinr1}=22   ${ulPmiRank1Sinr2}=22    ${ulPmiRank1Sinr3}=22    ${ulPmiRank1Sinr4}=22
    ...        ${ifenable}=1
    ...        ${ComaMultiplier}=4
    copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
    Import Variables    ${test_log_directory()}/coma.py
    ${original_xml}    set variable    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    ${modify_list0} =    create list    @{empty}
    ${list0} =    create list
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V0}}|//*[@TestProfile\="Profile-1"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V1}}|//*[@TestProfile\="Profile-2"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V2}}|//*[@TestProfile\="Profile-3"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVNegative45
    ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHPlus45
    ...    text|${Hindex${H3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatHNegative45
    ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVPlus45
    ...    text|${Vindex${V3}}|//*[@TestProfile\="Profile-4"]//UeId[@ueid\="${ueId}"]//NrRxBfCumulSpatialCovMatVNegative45
    ${modify_list0}    Combine Lists    ${modify_list0}    ${list0}
    ${modify_list1}    create list
    ...    text|${ifenable}|//*[@FormatVersion\="1"]//enable_5GC002396
    ...    text|${ComaMultiplier}|//*[@FormatVersion\="1"]//ComaMultiplier
    ...    text|${srsNumCountSwitchProfile1}|//*[@TestProfile\="Profile-1"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile2}|//*[@TestProfile\="Profile-2"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile3}|//*[@TestProfile\="Profile-3"]//srsNumCountSwitchProfile
    ...    text|${srsNumCountSwitchProfile4}|//*[@TestProfile\="Profile-4"]//srsNumCountSwitchProfile
    ...    text|${puschNumCountSwitch1}|//*[@TestProfile\="Profile-1"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch2}|//*[@TestProfile\="Profile-2"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch3}|//*[@TestProfile\="Profile-3"]//puschNumCountSwitchProfile
    ...    text|${puschNumCountSwitch4}|//*[@TestProfile\="Profile-4"]//puschNumCountSwitchProfile
    ...    text|${UlRank1}|//*[@TestProfile\="Profile-1"]//UlRank
    ...    text|${UlRank2}|//*[@TestProfile\="Profile-2"]//UlRank
    ...    text|${UlRank3}|//*[@TestProfile\="Profile-3"]//UlRank
    ...    text|${UlRank4}|//*[@TestProfile\="Profile-4"]//UlRank
    ...    text|${Sinr1}|//*[@TestProfile\="Profile-1"]//Sinr
    ...    text|${Sinr2}|//*[@TestProfile\="Profile-2"]//Sinr
    ...    text|${Sinr3}|//*[@TestProfile\="Profile-3"]//Sinr
    ...    text|${Sinr4}|//*[@TestProfile\="Profile-4"]//Sinr
    ...    text|${ulPmiRank1Sinr1}|//*[@TestProfile\="Profile-1"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr2}|//*[@TestProfile\="Profile-2"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr3}|//*[@TestProfile\="Profile-3"]//ulPmiRank1Sinr
    ...    text|${ulPmiRank1Sinr4}|//*[@TestProfile\="Profile-4"]//ulPmiRank1Sinr
    ${modify_list}    Combine Lists    ${modify_list0}    ${modify_list1}
    #${modify_list}    Combine Lists    ${modify_list2}    ${extra_modify}
    Modify Xml    ${original_xml}    ${original_xml}    ${modify_list}

Attach SA ue with capability to 5g cell
    [Arguments]    ${uenum}    ${pattern}    ${from}=1
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    FOR    ${num}    IN RANGE    ${from}    ${uenum}+${from}
        ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
        Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${num}    timeout=60    ue_capability=${ue_ability}
        airphone_set_traffic_type    ${num}    1    internal
        ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${num}    1    1    ${num}
        ${newNum}=    evaluate    ${num}+8
        Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${num}    1    1    ${newNum}
        Wait '2s' for stable running
    END

Attach SA '${uenum}'ue to 5g cell
    FOR    ${num}    IN RANGE    1    ${uenum}+1
        Airphone SA Attach    ue_id=${num}
        airphone_set_traffic_type    ${num}    1    internal
        Airphone Pdu Session Setup    ${num}    1    1    ${num}
        Wait '4s' for stable running
    END

Attach SA ue with capability
    [Arguments]    ${UE_ID}     ${pattern}
    ${ue_ability}    Obtain Ue Capability    ${pattern}
    Airphone SA Attach    ue_id=${UE_ID}    ue_capability=${ue_ability}

Stop '${UENUM}'UE DL Traffic
    FOR    ${num}    IN RANGE    1    ${UENUM}+1
        airphone_sa_stop_data_traffic    ${num}    DL
    END


Detach '${UENUM}'UE
    FOR    ${num}    IN RANGE    1    ${UENUM}+1
        airphone_sa_detach    ue_id=${num}    timeout=30
    END

SA send multiple trf data
    [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=7200s    trf_id=${num}
    END

Trigger ul bler
    [Arguments]    ${ue_id}    ${cell}=0    ${bler_rate}=100,100
    airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=${bler_rate}
	airphone_execute_egate_command	ue_testmode_set_nr id\=${ue_id} scell\=${cell} testmode\=bler profile_id\=1 action\=activate

Stop nsa ue data and detach
    [Arguments]    ${ue_id}     ${dir}
    Airphone NSA Stop Data Traffic     ${ue_id}     ${dir}
    Airphone NSA Detach    ${ue_id}

SA stop DL Data Traffic And Detach UE
    [Arguments]    ${ue_id}    ${number}
    FOR    ${num}    IN RANGE    ${ue_id}    ${ue_id}+${number}
        airphone_sa_stop_data_traffic    ${num}    DL
        airphone_sa_detach    ue_id=${num}
    END

ul_sinr_testmode_active
    [Arguments]    ${ue_id}    ${profile_id}    ${sinr_srs}    ${sinr_pucch}    ${noise_srs}
    airphone_execute_egate_command
    ...    ul_sinr_testmode_nr profile_id\=${profile_id} sinr_target_srs\=${sinr_srs} sinr_target_pucch\=${sinr_pucch} noise_srs\=${noise_srs}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${profile_id}

csi_override_testmode_active
    [Arguments]    ${ueid}    ${profile_id}    ${ri}    ${cqi}=15
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${profile_id} cqi\=${cqi} cqi_mode\=fixed ri\=${ri} ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=activate profile_id\=${profile_id}

csi_override_testmode_deactive
    [Arguments]    ${ueid}    ${profile_id}
    Airphone Execute Egate Command    ue_testmode_set_nr id\=${ueid} testmode\=csi_override action\=deactivate profile_id\=${profile_id}

ue_srs_beam_pos_active
    [Arguments]    ${ue_id}    ${profile_id}    ${init_pos}
    airphone_execute_egate_command
    ...    ue_srs_beam_pos_nr profile_id\=${profile_id} srsMode\=fixed init_pos\=${init_pos}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=ue_srs_beam_pos action\=activate profile_id\=${profile_id}

ul_mimo_srs_beam_pos_active
    [Arguments]    ${ue}    ${profile}    ${init}    ${sub}    ${scell}=0    ${step}=10    ${puxch}=0    ${u}=trigger_puxch_update
    ...    ${iq}=init_quad_pos    ${sq}=init_sub_quad_pos    ${m}=multi_path_config    ${mu_path}=0    ${p}=profile_id    ${y}=test_type
    ...    ${t}=UL_MIMO
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr ${p}\=${profile} mode\=fixed ${iq}\=${init} ${sq}\=${sub} step\=${step} ${u}\=${puxch} ${m}\=${mu_path} ${y}\=${t}
	airphone_execute_egate_command
	...    ue_testmode_set_nr id\=${ue} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${profile} scell\=${scell}

ul_mimo_srs_beam_pos_deactive
    [Arguments]    ${ue}    ${profile}    ${scell}=0
    airphone_execute_egate_command
	...    ue_testmode_set_nr id\=${ue} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=${profile} scell\=${scell}

ABIL_ul_bler_testmode_active
    [Arguments]     ${profile_id}    ${error}    ${bit_error}=ul_bler_bit_error    ${period}=5    ${duration}=0    ${ue_id}=1    ${scell}=0
    airphone_execute_egate_command
    ...    bler_testmode_nr profile_id\=${profile_id} ${bit_error}\=${error} ${bit_error}_periodicity\=${period} ${bit_error}_duration\=${duration}
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=bler action\=activate profile_id\=${profile_id} scell\=${scell}

ABIL_ul_bler_testmode_deactive
    [Arguments]     ${profile_id}=1    ${ue_id}=1    ${scell}=0    ${testmode}=bler
    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${ue_id} testmode\=${testmode} action\=deactivate profile_id\=${profile_id} scell\=${scell}

ul_cell_noise_testmode_active
    [Arguments]     ${gnb}=1    ${cell_id}=1    ${profile_id}=1    ${noise_pusch}=-600
    airphone_execute_egate_command    ul_cell_noise_testmode_nr profile_id\=${profile_id} noise_pusch\=${noise_pusch}
    airphone_execute_egate_command
    ...    cell_testmode_set_nr cell_id\=${cell_id} gnb\=${gnb} testmode\=ul_cell_noise profile_id\=${profile_id} action\=activate

ul_cell_noise_testmode_deactive
    [Arguments]    ${gnb}=1    ${cell_id}=1    ${profile_id}=1
    airphone_execute_egate_command
    ...    cell_testmode_set_nr cell_id\=${cell_id} gnb\=${gnb} testmode\=ul_cell_noise profile_id\=${profile_id} action\=deactivate

ul_sinr_pusch_active
    [Arguments]    ${ue_id}    ${profile_id}    ${sinr_pusch}
    airphone_execute_egate_command
    ...    ul_sinr_testmode_nr profile_id\=${profile_id} sinr_target_pusch\=${sinr_pusch}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${profile_id}

ul_sinr_testmode_delete
    [Arguments]    ${profile_id}
    airphone_execute_egate_command
    ...    ul_sinr_testmode_nr profile_id\=${profile_id}  delete\=1

ul_sinr_pathloss_active
    [Arguments]    ${ue_id}    ${profile_id}    ${pcmax}    ${pathloss}
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${profile_id} pcmax\=${pcmax} pathloss\=${pathloss}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${profile_id}
