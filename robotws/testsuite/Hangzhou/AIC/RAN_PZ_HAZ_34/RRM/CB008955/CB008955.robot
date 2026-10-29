# *** Settings ***
# Documentation
# ...    author: tina.luo
# ...    contact: tina.luo@nokia-sbell.com
# ...    squad group: RAN_PZ_MMW_CN_2_SG03
# ...    Feature :  CB008955
# Suite Setup
# Suite Teardown
# 
# Resource     Resources/CB008955_Common_keywords.robot
# Variables    Resources/CB008955_Parameters.py
# 
# Force Tags      CRT_TRUNK
# 
# *** Variables ***
# ${EXP_DL_8955_0201}    15
# ${DL_8955_0201}    20M
# ${EXP_DL_8955_0202}    1350
# ${EXP_DL_8955_0301}    1300
# ${EXP_DL_8955_0302}    1250
# ${DL_8955_0202}    1500M
# ${EXP_DL_8955_0203}   500
# ${scf_path_CB008955}    ${commissionings_path}/HGZ/${testline_name}
# ${MODIFY_DU_SCF_CB008955}     SCF_0.300_DU_100M.xml
# ${CU_SCF_CB008955}     SCF_0.250_vCU.xml
# ${UE_TYPE}    ${tl.ues[0].capabilities[1]}
# @{du_counter_id_list}   M55308C00019   M55308C10008
# @{Params_key}     dlInterferenceAvoidance/0/dataBufferThreshold      dlInterferenceAvoidance/0/endMcs
# ...       dlInterferenceAvoidance/0/prbAllocationDirection    dlInterferenceAvoidance/0/rank
# ...       dlInterferenceAvoidance/0/rbgLimit   dlInterferenceAvoidance/0/startMcs
# @{Params1_value}    60000      29   highPerforming_Low2high   4    0     25
# @{Params2_value}    60000      29   highPerforming_Low2high   2    2     20
# 
# *** Test Cases ***
# [1]CB008955-A-AIC_02_UE_Classification_Check_MCS_RANK_DataBuffer_Atleast1UE_PM_Counter
#     [Documentation]
#     ...    Purpose of the feature is to increase overall throughput performance
#     ...    in the cluster of cells by limiting the interference level experienced by high performing UEs.
#     ...    This is achieved by differentiation between UEs based on their performance profile and modification
#     ...    of the frequency domain scheduling in such a way that arrangement
#     ...    of the DL resource assignments differs for both classes of UEs.
#     [Setup]   Test Case set up
#    # CU Full Commission Fix Error    path_of_commission_file=${scf_path_CB008955}/${CU_SCF_CB008955}
#     vDU Full Commission SCF Fix Error     path_of_commission_file=${scf_path_CB008955}/${MODIFY_DU_SCF_CB008955}
#     wait until keyword succeeds   900  30   OAM Precondition Cell Should Be Onair
#   #  X2 Link Should be UnLock
#     Modify DU 8955 Parameter    Modify_Params1_key=${Params_key}    Modify_Params1_value=${Params1_value}
#     #-------NE for MCS-------
#     Attach UE with DL traffic and check Counter
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_03}
#     ...     DLThroughput=${DL_8955_0202}    EXP_DLThroughput=${EXP_DL_8955_0203}
#     ...     IFEligilble= ${False}
#     #-------NE for RANK-------
#     Attach UE with DL traffic and check Counter
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_01}
#     ...     DLThroughput=${DL_8955_0202}    EXP_DLThroughput=${EXP_DL_8955_0203}
#     ...     IFEligilble= ${False}
#     #-------NE for buffer-------
#     Attach UE with DL traffic and check Counter
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_02}
#     ...     DLThroughput=${DL_8955_0201}    EXP_DLThroughput=${EXP_DL_8955_0201}
#     ...     IFEligilble= ${False}
#     #-------E-UE-------
#     Attach UE with DL traffic and check Counter
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_02}
#     ...     DLThroughput=${DL_8955_0202}    EXP_DLThroughput=${EXP_DL_8955_0202}
#     ...     IFEligilble= ${True}
# 
# [1]CB008955-A-AIC_03_UE_allocation_with_RGBLimit_without_BWP_Atleast1UE_PM_Counter
#     [Documentation]
#     ...    Purpose of the feature is to increase overall throughput performance
#     ...    in the cluster of cells by limiting the interference level experienced by high performing UEs.
#     ...    This is achieved by differentiation between UEs based on their performance profile and modification
#     ...    of the frequency domain scheduling in such a way that arrangement
#     ...    of the DL resource assignments differs for both classes of UEs.
#     [Setup]   Test Case set up
#    # CU Full Commission Fix Error    path_of_commission_file=${scf_path_CB008955}/${CU_SCF_CB008955}
#     vDU Full Commission SCF Fix Error     path_of_commission_file=${scf_path_CB008955}/${MODIFY_DU_SCF_CB008955}
#     wait until keyword succeeds   900  30   OAM Precondition Cell Should Be Onair
#     X2 Link Should be UnLock
#     Modify DU 8955 Parameter    Modify_Params1_key=${Params_key}    Modify_Params1_value=${Params2_value}
#     #-------E for low2high-------
#     Attach UE with DL traffic and check TTitrace Counter with rbglimit
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_02}
#     ...     DLThroughput=${DL_8955_0202}    EXP_DLThroughput=${EXP_DL_8955_0301}
#     ...     prbAllocationDirection=low2high
#     Online Set prbAllocationDirection To high2low
#     wait until keyword succeeds   900  30   OAM Precondition Cell Should Be Onair
#     #-------E for high2low -------
#     Attach UE with DL traffic and check TTitrace Counter with rbglimit
#     ...     ATTENUATION_VALUE=${ATTENUATION_VALUE_8955_02_02}
#     ...     DLThroughput=${DL_8955_0202}    EXP_DLThroughput=${EXP_DL_8955_0302}
#     ...     prbAllocationDirection=high2low
# 
# *** Keywords ***
# Attach UE with DL traffic and check Counter
#     [Arguments]   ${ATTENUATION_VALUE}   ${DLThroughput}     ${EXP_DLThroughput}
#     ...           ${IFEligilble}   ${gnb_index}=0     ${vdu_index}=0
#     Adjust HBTE ATT Values seperate    attenuation_values_of_all_ports=${ATTENUATION_VALUE}   pa_index=0
#     Adjust HBTE ATT Values seperate    attenuation_values_of_all_ports=${ATTENUATION_VALUE_cell2_8955}   pa_index=1
# 	UE attach with DL traffic  dltarget_throughput=${EXP_DLThroughput}    data_send_dl=${DLThroughput}
# 	${wait_time}    Get wait value minutes    interval=5min
#     sleep    ${wait_time}min
#     sleep    5min
#     Stop traffic according to direction and protocol   tp_direction=dl
#     Check 8955 Performance counter   ${IFEligilble}
#     [teardown]       power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
# 
# Attach UE with DL traffic and check TTitrace Counter with rbglimit
#     [Arguments]   ${ATTENUATION_VALUE}   ${DLThroughput}     ${EXP_DLThroughput}
#     ...           ${prbAllocationDirection}     ${gnb_index}=0     ${vdu_index}=0
#     Adjust HBTE ATT Values seperate    attenuation_values_of_all_ports=${ATTENUATION_VALUE}   pa_index=0
#     Adjust HBTE ATT Values seperate    attenuation_values_of_all_ports=${ATTENUATION_VALUE_cell2_8955}   pa_index=1
# 	UE attach with DL traffic  dltarget_throughput=${EXP_DLThroughput}    data_send_dl=${DLThroughput}
#     ${Trace_log}      Collect TTItrace
# 	${wait_time}    Get wait value minutes    interval=5min
# 	sleep    ${wait_time}min
#     Stop traffic according to direction and protocol   tp_direction=dl
#     Check counter value greater than 0    ${du_counter_id_list}
#     ${local_dl_csv}     Decoder TTITrace    ${Trace_log}
#     ${TTI_result}   Check TTI trace for Eligible UE    ${local_dl_csv}
#     Run Keyword If  'low2high' in '${prbAllocationDirection}'      Check TTItrace value for low2high    ${TTI_result}
#     ...     ELSE        Check TTItrace value for high2low     ${TTI_result}
#     [teardown]       power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
