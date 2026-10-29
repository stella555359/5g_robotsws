# *** Settings ***
# Suite Setup          SISO Coam Suite setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         1h
# 
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008562_SG05/resource/CB008562_resource.robot
# 
# Documentation
# ...    Author:liu yue
# ...    contact:yue.2.liu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB008562 in SBTS23R1 program
# 
# Force Tags   5G_RAN    5G_RAN_TDD
# 
# *** Variables ***
# 
# *** Test Cases ***
# 
# [1]CB008562_SR_B_5G_AQQL_03_RSSI_online_Monitoring
#     [Tags]    1S-2CC-8D-4U
#     ${cell_list}    create list    ${1}
#     ${ue_list}    create list    ${0}
#     Ue Attach and Start DL UL Traffic    ue_index_list=${ue_list}
#     Antenna Line Online Monitoring
#     [Teardown]    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_list}
