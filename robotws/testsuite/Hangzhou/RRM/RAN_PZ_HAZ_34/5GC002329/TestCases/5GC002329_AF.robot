# *** Settings ***
# Resource    ./../Resources/5GC002329_keywords.robot
# 
# Documentation    Suite description
# ...    author: Fang Dandan
# ...    contact: dandan.fang@nokia-sbell.com
# ...    squad group: MMW_SG1
# ...    Feature 5GC002329-AF
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup  2329_AF Suite preparation
# Suite Teardown  run keyword and ignore error    CA Suite teardown
# 
# *** Test Cases ***
# 5GC002329-AF_010_B0_A2_measurement_on_Pcell_for_Pcell_change_successful_M55145C03001_M55145C03002
#     [Tags]    CIT_TRUNK    CIT_22R1    CIT_22R2    CRT_22R1    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    author: journey.jin@nokia-sbell.com
#     ...  Step1: configure 2329 CA
#     ...  Step2: configured A1 scell addition,enable A2 pcell switch on pcell
#     ...  Step3: check 2329 CA setup and UL DL trafic
#     ...  Step4: adjust pcell signal is bad than scell,trigger a2 measurement report
#     ...  Step5: check pcell change from 2329 CA to 1390 CA
#     ...  Step6: check 1390 CA UL DL traffic
#     [Setup]    case setup   NSA_SA=${NSA_SA}     pcell_change_type=A2
#     #first with 2329 CA
#     init PA and verify CA work normal    pcell_change_type=A2
# #   Set scell as notBarred as HO will be rejected if target cell is cellReserved or cell bared. Requirement introduced by customer issue 02848445
#     Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=all    timeout=${TIMER_FOR_MODIFY_VIA_API}
# 
#     #pcell change from 2329 CA to 1390 CA
#     ${starting_log_timestamp}    Prepare for counter log
#     Adjust PA and verify Pcell change successful    pcell_change_type=A2
#     Pcell id and scell id redefined in order to match with different pcell       ca_group_type=F+T
# 
#     #init PA to check Tput
#     Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
#     ...     filter=L2Lo
# 
#     #Qualcom UE UL Rank1 Issue Check
#     Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
#     ...    target_avg_percent=0.8   min_percent=0.6
#     ...    exp_ul_indiv=${PCELL_EXP_UL},-1     exp_dl_indiv=${PCELL_EXP_DL},${SCELL_EXP_DL}
# 
# #    run keyword and continue on failure    Check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}
# #    ...    exp_ul=${PCELL_EXP_UL},-1    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}    log=${tput_log}
# 
#     run keyword and continue on failure    Check PM counter M55145C03001 M55145C03002
#     ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}
# 
#     [Teardown]     run keyword and ignore error      run keywords
#     ...    Common case teardown    detach_ue=${True}    restapi_restore_nidd=${RESTAPI_DISABLE_A2_PCELL_CHANGE}
#     ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
# 
# 
# 5GC002329-AF_005_B2_Scell_A1_based_Pcell_change_for_SA_call_covBasedA1
#     [Tags]    CRT_TRUNK    CRT_22R1   CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    author: dandan.fang@nokia-sbell.com
#     ...  Step1: configured Pcell id and Scell ID, to meet 1390 CA requirement
#     ...  Step2: configured A1 scell addition , enable Pcell switch on Pcell,enable A1 pcell switch on Scell
#     ...  Step3: Pcell signal good, Scell signal bad, check UE attach normal , Scell addition normal,
#     ...         Pcell switch A1 event is configured on Scell
#     ...  Step4: check 1390 UL DL traffic
#     ...  Step5: adjust Scell signal good, check pcell changed from FDD to TDD, old scell released,
#     ...         new scell added.
#     ...  Step6: check 2329 UL DL traffic
#     ...  Manual Guide Link:
#     ...  https://confluence.ext.net.nokia.com/display/5GRANHZ/5GC002329-AF_005_B2_Scell_A1_based_Pcell_change_for_SA_call_covBasedA1
#     [Setup]       case setup   NSA_SA=${NSA_SA}     init_ca_type=F+T
#     #Here, scell signal is bad, then data can not peak, so just expected result for scell just as 150Mbps
#     init PA and verify CA work normal      exp_dl=${PCELL_EXP_DL},${50}
# #   Set scell as notBarred as HO will be rejected if target cell is cellReserved or cell bared. Requirement introduced by customer issue 02848445
#     Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=all    timeout=${TIMER_FOR_MODIFY_VIA_API}
# 
#     #Pcell good, Scell good
#     Adjust PA and verify Pcell change successful    pa_values_mapping=${INIT_PA_F_T}
#     Pcell id and scell id redefined in order to match with different pcell       ca_group_type=T+F
# 
#     ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min
#     ...     filter=L2Lo
# 
#     #Qualcom UE UL Rank1 Issue Check
#     Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
#     ...    target_avg_percent=0.8   min_percent=0.6
#     ...    exp_ul_indiv=${PCELL_EXP_UL},-1     exp_dl_indiv=${PCELL_EXP_DL},${SCELL_EXP_DL}
#     ...    customized_log_name=traffic_after_A1_handover
# 
# #    run keyword and continue on failure    Check tput via power UE    cell_id=${PCELL_ID},${SCELL_ID}
# #    ...    exp_ul=${PCELL_EXP_UL},-1    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}    log=${tput_log}
# #    ...    customized_log_name=traffic_after_A1_handover
# 
#     [Teardown]     run keyword and ignore error      run keywords    Common case teardown    detach_ue=${True}
#     ...    AND    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
# 
# 
# 
# *** Keywords ***
# case setup
#     [Documentation]    author: dandan.fang@nokia-sbell.com
#     ...      2329 case setup
#     ...      parameters : pcell_change_type A1 or A2 based on Pcell
#     [Arguments]    ${NSA_SA}=${NSA_SA}    ${init_ca_type}=T+F     ${pcell_change_type}=A1
#     run keyword if    '${pcell_change_type}'=='A1'
#     ...    Pcell id and scell id redefined in order to match with different pcell      ca_group_type=${init_ca_type}
#     Connect to gnb coam via ssl
#     enable pcell switch between 2329 and 1390     pcell_change_type=${pcell_change_type}
#     run keyword if    '${pcell_change_type}'=='A1'
#     ...    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}    timeout=2min
#     Common case setup    NSA_SA=${NSA_SA}
# 
# 2329_AF Suite preparation
#     [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${None}
#     Import NIDD variables for 2329
#     import variables      ${CURDIR}/../TestData/NIDD_modify_pcell_switch_2329.py
#     set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_BEFORE_PCELL_SWITCH}
#     set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_PCELL_SWITCH_1390_COMMISSION}
#     set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_PCELL_SWITCH_COMMISSION}
# 
#     CA Suite preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}    enb_default_scf_file=${enb_default_scf_file}
# 
# enable pcell switch between 2329 and 1390
#     [Documentation]    author: dandan.fang@nokia-sbell.com
#     ...   configured Scell addition as covBasedA1
#     ...   Enable Pcell changed according to A1 or A2 based on Pcell
#     [Arguments]    ${pcell_change_type}=A1
#     #Precondition: Enable A1Meas Scell addition on Pcell
#     Modify sCell addition method to covBasedA1    cell_index=${PCELL_ID}
#     ...           a1ThresholdSCellAddSsbRsrp_FDD=${A1_THRESHOLD_SCELL_ADD_SSB_RSRP}
#     #then enable Pcell Switch on Pcell and Scell
#     run keyword if    '${pcell_change_type}'=='A1'
#     ...    Configure A1 Meas Pcell Switch    a1ThresholdPCellSwitchSsbRsrp=${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
#     ...    ELSE    run keywords    Configure A2 Meas Pcell Switch    a2ThresholdPCellSwitchSsbRsrp=${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
#     ...    AND    Configure A2 Measurement For SCell Release Enabled
# 
# Adjust PA and verify Pcell change successful
#     [Documentation]    author: dandan.fang@nokia-sbell.com
#     ...   pcell signal bad, scell good, trigger pcell switch
#     ...   A1 meas report should be happened on Scell
#     ...   Pcell ID should be changed to Scell ID and old Scell released
#     ...   New scell added after Pcell switch
#     [Arguments]    ${NSA_SA}=${NSA_SA}    ${enb_default_scf_file}=${None}     ${tcpdump_log_name}=pcell_switch_triggered
#     ...   ${pa_values_mapping}=${INIT_PA_F_T}    ${pcell_change_type}=A1
#     Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
# 
# #    run keyword if    '${pcell_change_type}'=='A1'    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
# #    ...    ELSE    Initialize attenuator for specified RU     exp_pa_value=${PCELL_BAD}    ru_index=${PCELL_RU_INDEX}
# 
#     run keyword if    '${pcell_change_type}'=='A1'    Initialize attenuator values for testline  pa_values_mapping=${INIT_PA_F_T}
#     ...    ELSE    Adjust attenuator multi ports to same value draft version     pa_value=${PCELL_BAD}    ru_index=${PCELL_RU_INDEX}
#     sleep    15s
#     ${ue_attach_log}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
# 
#     run keyword if   '${pcell_change_type}'=='A1'    run keyword and continue on failure
#     ...    Verify A1 report for scell to trigger pcell switch in cpif log
#     ...    log_path_pcap=${ue_attach_log}       a1_rsrp_thres=${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
#     ...    ELSE    run keyword and continue on failure     Verify A2 report for pcell to trigger pcell swith in cpif log
#     ...    log_path_pcap=${ue_attach_log}       a2_rsrp_thres=${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}
# 
#     run keyword and continue on failure     Verify Pcell ID Changed after pcell switch through RRC reconfiguration
#     ...         log_path_pcap=${ue_attach_log}
# 
#     run keyword and continue on failure     Verify new scell add after pcell switch through RRC Info
#     ...         log_path_pcap=${ue_attach_log}
# 
#     [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}
# 
# Adjust attenuator multi ports to same value draft version
#     [Documentation]    Author: Liu Zheng
#     ...    currently only suport 2 ports and 4 ports
#     [Arguments]    ${attenuator_index}=${0}        ${attenuator_device}=ATTEN_0
#     ...    ${gnb_index}=${0}    ${ru_index}=${PCELL_RU_INDEX}
#     ...    ${pa_value}=${PCELL_BAD}
#     ...    ${pa_port_num}=${4}
#     Connect to Attenuator    attenuator_index=${0}    alias=${attenuator_device}
#     ${atten_ports}    gnb_classical_hangzhou.Get Attenuation Channels For RU    gnb_id=${gnb_index}
#     ...    RU_id=${ru_index}
#     ${pa_values_2}    create list    ${pa_value}    ${pa_value}
#     ${pa_values_4}    create list    ${pa_value}    ${pa_value}    ${pa_value}    ${pa_value}
#     ${pa_values}    set variable if    ${pa_port_num}==${4}    ${pa_values_4}    ${pa_values_2}
#     set_ports_attenuation    ports=${atten_ports}    values=${pa_values}    confirm=${False}
#     ...    attenuator_device=${attenuator_device}
#     read_ports_attenuation     ports=${atten_ports}    attenuator_device=${attenuator_device}
# 
# init PA and verify CA work normal
#     [Documentation]    author: dandan.fang@nokia-sbell.com
#     ...   init Pcell signal good, scell bad, 1390 CA worked, A1 for Scell configured
#     [Arguments]     ${tcpdump_log_name}=ue_attach_ca_a1_for_scell   ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
#     ...   ${exp_ul}=${PCELL_EXP_UL},-1    ${pcell_change_type}=A1
#     run keyword if    '${pcell_change_type}'=='A1'    Run Keywords
#     ...    Initialize attenuator for specified RU    exp_pa_value=${PCELL_GOOD}    ru_index=${PCELL_RU_INDEX}
#     ...    AND    Initialize attenuator for specified RU     exp_pa_value=${SCELL_BAD}    ru_index=${SCELL_RU_INDEX}
#     sleep    5s
# 
# 
#     run keyword and continue on failure  CA L3 call tput check with UL rank1 issue ignored for T+F TDD cell
#     ...    NSA_SA=${NSA_SA}        scell_addition_method=covBasedA1
#     ...    tcpdump_log_name=${tcpdump_log_name}        customized_log_name=traffic_after_attach
#     ...    check_scell_activation=${True}         duration=1200
#     ...    exp_ul_indiv=${exp_ul}     exp_dl_indiv=${exp_dl}
#     ...    target_avg_percent=0.8   min_percent=0.6
# 
# #    Run keyword and continue on failure    CA_L3_call_tput    scell_addition_method=covBasedA1
# #    ...     tcpdump_log_name=${tcpdump_log_name}        customized_log_name=traffic_after_attach
# #    ...     NSA_SA=${NSA_SA}      exp_dl=${exp_dl}       exp_ul=${exp_ul}
# #    ...     cell_id=${PCELL_ID},${SCELL_ID}
# 
#     #attach_f1ap_logpath is test variable defined in CA/Resources/CA_keywords.robot set test variable
#     run keyword if    '${pcell_change_type}'=='A1'    run keyword and continue on failure
#     ...    Verify A1 configured on scell when pcell switch enabled in cpif log    log_path_pcap=${attach_f1ap_logpath}
#     ...    ELSE    run keyword and continue on failure    Verify A2 configured on pcell when pcell switch enabled in cpif log
#     ...    log_path_pcap=${attach_f1ap_logpath}
# 
#     [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}
# 
# 
# 
# Check PM counter M55145C03001 M55145C03002
#     [Documentation]    author: journey.jin@nokia-sbell.com
#     ...    M55145C03001:Nbr of A2 based inter-frequency intra-DU HO attempts for SA per PLMN-ID
#     ...    M55145C03002:Nbr of A2 based successful inter-frequency intra-DU HOs for SA per PLMN-ID
#     [Arguments]       ${starting_log_timestamp}
#     ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
#     ${cell_check_list}    create list     ${SCELL_ID}
#     ${list_measurement_ids}    create list    M55145C03001    M55145C03002
#     ${dict_measurements_value}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
#     ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}
# 
#     ${M55145C03001}    set variable    ${dict_measurements_value['${scell_id}']['M55145C03001']}
#     ${M55145C03002}    set variable    ${dict_measurements_value['${scell_id}']['M55145C03002']}
#     run keyword and continue on failure     should be equal as strings      ${M55145C03001}       1
#     run keyword and continue on failure     should be equal as strings      ${M55145C03002}       1
