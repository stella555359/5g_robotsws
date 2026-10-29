# *** Settings ***
# Library    ./TestData/Rjio_variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
# Resource    ./Resources/Rjio_keywords.robot
# 
# 
# Documentation
# ...    Author: Jiangjing Lin
# ...    Contact: jiangjing.lin@nokia-sbell.com
# ...    squad group:SG_08
# ...    E2E Rjio
# 
# Force Tags    PY36
# 
# 
# *** Variables ***
# ${loop_times}    99999
# @{ue_index_list}    ${0}
# *** Test Cases ***
# [1]multe_ue_detach_attach
#     Set Whole Attenuator Ports    attenuator_out_ports=${matrixPA_out_ports}    attenuator_rows=${matrixPA_rows}    exp_pa_value=${63}
#     Set PA Value For Pointed Port    PA_Port_List=${matrixPA_TDD908}    attenuator_index=${1}    value=${0}
#     multe_ue_detach_attach    times=${loop_times}    ue_index_list=${ue_index_list}
# 
# 
# *** Keywords ***
