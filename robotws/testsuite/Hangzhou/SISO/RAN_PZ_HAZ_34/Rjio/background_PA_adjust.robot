# *** Settings ***
# Library    ./TestData/Rjio_variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
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
# @{matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    129    146    163    180
# 
# *** Test Cases ***
# [1]adjust_matrix_PA_for_case_71
#     FOR    ${index}    IN RANGE    99999
#         log to console    set    A1B9/A2B10/A3B11/A4B12 to 45
#         Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${45}
#         sleep    15s
#         log to console    set    A1B9/A2B10/A3B11/A4B12 to 10
#         Set PA Value For Pointed Port    PA_Port_List=${matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4}    attenuator_index=${1}    value=${10}
#         sleep    15s
#     END
# 
# *** Keywords ***
