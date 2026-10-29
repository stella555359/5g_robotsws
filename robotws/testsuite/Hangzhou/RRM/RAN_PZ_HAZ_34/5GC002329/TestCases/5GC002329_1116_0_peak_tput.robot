# *** Settings ***
# Force Tags    PY36
# Resource    ./../Resources/5GC002329_keywords.robot
# 
# Documentation    Suite description
# ...    author: Wu rong
# ...    contact: rong.2.wu@nokia-sbell.com
# ...    squad group: MMW_SG1l
# ...    Feature 5GC002329-peak-tput
# 
# Suite Setup  2329 Suite preparation    is_pdl_checking_needed=${true}
# Suite Teardown  run keyword and ignore error    CA Suite teardown
# 
# *** Test Cases ***
# 5GC002329_20M_100M_1116_0ms_6_symbols_bufferbase_beamforming_TCP
#     [Tags]  CIT_TRUNK    CRT_22R1   CRT_22R2    CRT_22R3    CIT_22R4
#     [Documentation]     Author: Wu Rong
#     ...    Description: This case is to verify peak tput of Pcell:100M Scell:20M
#     ...    Frame structure 1116_0, beamset_2, ScellAdditionMethod:blind
#     ...    ScellActivationMethod:Bufferbased and with beamforming, TCP
#     ...    step 1>  Attach UE to TDD FR1 cell(F1) as PCell and with carrier aggregation (FDD cell as SCell)
#     ...    step 2>  UE start dL data transfer
#     ...    step 3>  UE stop dL data transfer, UE start uL data transfer
#     ...    step 4>  UE stop uL data transfer, UE start uL/dL data transfer
# 
#     [Setup]     Common case setup   NSA_SA=${NSA_SA}   is_pdl_checking_needed=${true}
# 
#     CA_L3_call_tput_DL_UL_Bi
#     ...    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#     ...    exp_dl_indiv=${PCELL_DL_EXP_TPUT_100M_1116_3},${SCELL_DL_EXP_TPUT_20M_1116_3}
#     ...    exp_ul_indiv=${PCELL_UL_EXP_TPUT_100M_1116_3},-1
#     ...    tput_duration=300s
#     ...    protocol=tcp
# 
#     [Teardown]  run keyword and ignore error    Common case teardown    detach_ue=${True}
