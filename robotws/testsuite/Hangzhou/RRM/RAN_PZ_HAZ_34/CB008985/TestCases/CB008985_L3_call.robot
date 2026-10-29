# *** Settings ***
# Resource    ./../../CB008985/Resources/CB008985_keywords.robot
# Resource    ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
# 
# 
# Documentation    Suite description
# ...    author: Qi Xin
# ...    contact: xin.qi@nokia-sbell.com
# ...    squad group: MMW_SG1l
# ...    Feature CB008985-peak-tput
# Force Tags      5G_RRM
# Suite Setup  8985 NonCA Suite preparation       NSA_SA=NSA     prepare_ue=${true}
# Suite Teardown  Run keyword and ignore error    Suite teardown common
# 
# 
# *** Variables ***
# ${ENB_ID}                           ${tl.enbs[0].instance_id}
# 
# *** Test Cases ***
# [1]CB008985_A5_1_tddFr1_SA_call_on_one_supercell_1116_0ms_with_xsubcell
#     [Tags]  CIT_TRUNK  CIT_23R1
#     [Documentation]     Author: Qi Xin
#     ...    Description: This case is to verify SA peak tput of one Supercell, UDP
#     ...    step 1>  Perform UE attach and start bi-direction data transmission.
#     ...    step 2>  UE moves across coverage area of serving subcell and its neighbor subcells(operator can adjust
#     ...    the attenuator to change subcell coverage for UE).
#     [Setup]   8985 Case Setup   NSA_SA=SA
#     log to console    \nPART1: Attach and check tput on subcell0
#     Adjust PA And Check Attach Status   CA_enable=${False}      pa_values_mapping=${NONCA_SUBCELL0_ATTACH_PA_INIT}
#     ...       4G_check=${False}      NSA_SA=${NSA_SA}
#     Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID}
#     ...    exp_ul_indiv=${PCELL_EXP_UL_TP}      exp_dl_indiv=${PCELL_EXP_DL_TP}
#     ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${DL_TPUT_Iperf}
#     Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both
# 
#     log to console    \nPART2: Attach and check tput on subcell2
#     Adjust PA And Check Attach Status     pa_values_mapping=${NONCA_SUBCELL2_ATTACH_PA_INIT}        NSA_SA=${NSA_SA}  4G_check=${False}
#     Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID}
#     ...    exp_ul_indiv=${PCELL_EXP_UL_TP}      exp_dl_indiv=${PCELL_EXP_DL_TP}
#     ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${DL_TPUT_Iperf}
# 
#     [Teardown]  run keyword and ignore error     run keywords
#     ...         Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_SUBCELLS_MUTE}     AND
#     ...         Common case teardown    detach_ue=${True}
# 
# [1]CB008985_A2_1_tddFr1_NSA_call_on_one_supercell_1116_0ms_with_3subcell
#     [Tags]  CIT_TRUNK   CIT_23R1
#     [Documentation]     Author: Qi Xin
#     ...    Description: This case is to verify NSA peak tput of one Supercell, UDP
#     ...    step 1>  Perform UE attach and start bi-direction data transmission.
#     ...   step 2>  UE moves across coverage area of serving subcell and its neighbor subcells(operator can adjust
#     ...    the attenuator to change subcell coverage for UE).
#     [Setup]     8985 Case Setup   NSA_SA=NSA
#     log to console    \nPART1: Attach and check tput on subcell0
#     Adjust PA And Check Attach Status   CA_enable=${False}      pa_values_mapping=${NONCA_SUBCELL0_ATTACH_PA_INIT}
#     ...       4G_check=${True}      NSA_SA=${NSA_SA}
#     Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID}
#     ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA}      exp_dl_indiv=${PCELL_EXP_DL_TP}
#     ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${DL_TPUT_Iperf}
# 
#     Run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=both
# 
#     log to console    \nPART2: Attach and check tput on subcell2
#     Adjust PA And Check Attach Status     CA_enable=${False}   pa_values_mapping=${NONCA_SUBCELL2_ATTACH_PA_INIT}
#     ...       NSA_SA=${NSA_SA}  4G_check=${True}
# 
#     Start data transfer and Check Tput As Expected    cell_id=${PCELL_ID}
#     ...    exp_ul_indiv=${PCELL_EXP_UL_TP_NSA}      exp_dl_indiv=${PCELL_EXP_DL_TP}
#     ...    ul_iperf_tput=${UL_TPUT_Iperf}     dl_iperf_tput=${DL_TPUT_Iperf}
#     [Teardown]  run keyword and ignore error     run keywords
#     ...         Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_SUBCELLS_MUTE}     AND
#     ...         Common case teardown    detach_ue=${True}
# 
# *** Keywords ***
