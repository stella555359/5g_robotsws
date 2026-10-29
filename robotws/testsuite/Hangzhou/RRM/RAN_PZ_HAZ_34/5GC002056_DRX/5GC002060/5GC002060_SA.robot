# *** Settings ***
# Documentation
# ...                         TL Target: Classical
# ...                         Author: Philippe Maron
# ...                         Feature: 5GC002060_A_B_C_D
# 
# Variables                   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002060/Resources/5GC002060paramsTDD.yaml
# Resource                    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002060/Resources/5GC002060keysTDD.robot
# Library                     BuiltIn
# Library                     OperatingSystem
# Library                     Collections
# Library                     String
# Library                     taf.transport.ssh           WITH NAME    ssh
# Library                     taf.sbts.oam.coam.admin      WITH NAME    coam
# Library                     taf.collectors.core         WITH NAME    core
# Library                     taf.collectors.tcpdump      WITH NAME    tcpdump
# Library						ute_reporting_portal
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Force Tags                             RAN_5G    RAN_5G_TDD    CRT_UTE    CRT_22R3
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AEQI_ENB    STATE_SW_UPLOADED    SBTS00 
# 
# 
# Suite Setup    Run Keywords    CI_interface.Common Suite Setup
# 
# 
# *** Variables ***
# 
# # Setting of values from parameters in the file __init__.py
# ${ip_addr}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${5GC002060_37}=            FAILED
# ${5GC002060_38}= 	        FAILED
# ${5GC002522_38}= 	        FAILED
# # Setting of values from parameters in the file ue_config.yml are now done with Initialize UE params keyword
# 
# *** Test Cases ***
# 
# 
# [1]5GC002060_A_1_SA-classical-cmw-TDD_Feature_Activation
#     [Documentation]                    This test case verify the activation of feature 5GC002060-A in case 160mS used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping
#     ...    Then, a bad configuration using 160 mS DLC is tried, relation errors should be raised
#     ...                                when validating
#     ...    Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost. 
#     [Setup]    Test Setup
#     [Teardown]    5GC002060keysTDD.Test Teardown
# 
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive    attach_mode=5G_SA
#     StaticSACall_DrxLongCycle160_lowDLTraffic    ${cells_id}   ${cellgrps_id}   
# 
# [1][1.0] 5GC002060_38_NREG_FGCR-8916_SA_classical_cmw_TDD_MSC_StaticCall_DrxLongCycle160_Apple_Counters.robot
#     [Documentation]  This test case verify the latency added by feature 5GC002060-A in case DLC160APPLE used
#     ...              First the gNB is configure with feature deactivated and network is verified
#     ...              checking that no packet lost in a 120 packets ping, the average latency is saved to verify
#     ...              the introduced latency is no more than expected
#     ...    Then a DLC160APPLE configuration is used and activated, a UE is attached and a verification is done
#     ...                       on the used parameters.
#     ...    A 120 ping is then launch and no packets should be lost,.the average latency should be less equal
#     ...                                to the latency without drx activated plus the drx cyle (160 in this case)
#     [Setup]    Test Setup    
#     
# 
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive    attach_mode=5G_SA    
#     StaticCall_DrxLongCycle160_Apple_Counters    ${cells_id}   ${cellgrps_id}    ${refrtt}
# 
# 
# [1][1.0] 5GC002060_37_NREG_FGCR-8916_SA_classical_cmw_TDD_Feature_Activation_DLC_160mS_Apple.robot
#     [Documentation]                    This test case verify the activation of feature 5GC002060-A in case 160mS used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping
#     ...                       Then, a bad configuration using 160 mS DLC is tried, relation errors should be raised
#     ...                                when validating
#     ...                   Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost.
#     ...    NOTE : ALL THESE STEPS HAVE BEEN DONE IN TEST 5GC002060_2
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     log                                5GC002060_1 test is checked
# 	  Set suite variable                 ${5GC002060_37}  PASSED
# 
# 
# [1][1.0] 5GC002522_38_NREG_FGCR-8916_SA_classical_cmw_TDD_MSC_StaticCall_DrxLongCycle160_Apple_Counters.robot
#     [Documentation]                    This test case verify the latency added by feature 5GC002060-A in case DLC160APPLE used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping, the average latency is saved to verify
#     ...                                the introduced latency is no more than expected
#     ...                                Then a DLC160APPLE configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost,.the average latency should be less equal
#     ...                                to the latency without drx activated plus the drx cyle (160 in this case)
#     [Setup]    Test Setup
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     StaticCall_DrxLongCycle160_Apple_lowDLTraffic
# 
