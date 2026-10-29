# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# ...   author: kaijia.chen@nokia-sbell.com
# ...   contact: kaijia.chen@nokia-sbell.com
# ...   squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# Suite Teardown    Tests_suite_Teardown
# 
# Resource    resource/AHAC_Common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# Test Timeout    30 minutes
# 
# *** Test Cases ***
# [1]5GC002481-AHAC-03-5GC000478_A_Radio_Link_Failure_initialized_by_SgNB_unsuccessful_procedure_due_to_radio_link_recovery
#     [Tags]    5GC002056   CRT_21A    CRT_TRUNK    CRT_21B     CRT_22R1   CRT_22R2    CRT_22R3
#     [Documentation]
#     ...    5GC002481-AHAC-03:RLF initiated by SgNB unsuccessful procedure due to RLF
#     ...    -21.12.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Change Threshold    DU_OAM_IP=${gNB_OAM_IP}    Actual_value_1=1    Actual_value_2=1
#     ...                                            Actual_value_3=1    Actual_value_4=1
#     Change InitRlf    DU_OAM_IP=${gNB_OAM_IP}    Actual_value_5=true    Actual_value_6=false
#     ...                                          Actual_value_7=false    Actual_value_8=false
#     ...                                          Actual_value_9=false    Actual_value_10=false
#     Adjust HBTE Attenuation    port_value1=${10}
#     Start Catch BTS Log
#     power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${1}
#     power_ue.UE Attach    ue_type=askey_sigspark    ue_index=${1}
#     power_ue.Verify attach    ue_type=askey_sigspark    ue_index=${1}
#     power_ue.Start traffic    ue_type=askey_sigspark    direction=ul    throughput=10MKbits/sec    ue_index=${1}   ue_mode=NSA
#     power_ue.Check throughput    ue_type=askey_sigspark    direction=ul    throughput=2    ue_index=${1}
#     Adjust HBTE Repeatedly
#     Stop BTS Log and Check Timer Start and Stop
#     [Teardown]    Run keywords
#     ...        power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${1}    AND
#     ...        CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Adjust HBTE Repeatedly
#     Adjust HBTE Attenuation    port_value1=${70}
#     sleep    2s
#     Adjust HBTE Attenuation    port_value1=${10}
#     sleep    5s
#     Adjust HBTE Attenuation    port_value1=${80}
#     sleep    3s
#     Adjust HBTE Attenuation    port_value1=${10}
#     sleep    5s
#     Adjust HBTE Attenuation    port_value1=${80}
#     sleep    5s
#     Adjust HBTE Attenuation    port_value1=${10}
#     sleep    20s
