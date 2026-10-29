# *** Settings ***
# Documentation
# ...                         TL Target: Classical
# ...                         Author: Philippe Maron
# ...                         Feature: 5GC002060_A_B
# 
# 
# Variables                   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002060/Resources/5GC002060paramsTDD.yaml
# Resource                    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002060/Resources/5GC002060keysTDD.robot
# Library                     BuiltIn
# Library                     OperatingSystem
# Library                     Collections
# Library                     String
# Library						ute_reporting_portal
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Force Tags                             RAN_5G    RAN_5G_TDD    CRT_UTE     CRT_22R3
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AEQI_ENB    STATE_SW_UPLOADED    SBTS00
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords    CI_interface.Common Suite Setup
# ...    AND     robot_common_operations.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# *** Variables ***
# 
# # Setting of values from parameters in the file __init__.py
# ${ip_addr}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${5GC002060_1}=		        FAILED
# ${5GC002060_6}=		        FAILED
# ${Test_Result}=		        FAILED
# ${5GC002060_35}=		    FAILED
# # Setting of values from parameters in the file ue_config.yml are now done with Initialize UE params keyword
# ${5GC002060_37}=            FAILED
# ${5GC002060_38}= 	        FAILED
# ${5GC002522_38}= 	        FAILED
# 
# *** Test Cases ***
# [1]5GC002060_2_NREG_NSA-classical-cmw-TDD_MSC_StaticCall_DrxLongCycle160_lowDLTraffic
#     [Documentation]    This test case verify the latency added by feature 5GC002060-A in case DLC160 used
#     ...                First the gNB is configure with feature deactivated and network is verified
#     ...                checking that no packet lost in a 120 packets ping, the average latency is saved to verify
#     ...                the introduced latency is no more than expected
#     ...                Then a DLC160 configuration is used and activated, a UE is attached and a verification is done
#     ...                on the used parameters.
#     ...                A 120 ping is then launch and no packets should be lost,.the average latency should be less equal
#     ...                to the latency without drx activated plus the drx cyle (160 in this case)
#     Test Setup
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive NSA
#     StaticCall_DrxLongCycle160_lowDLTraffic    ${cells_id}   ${cellgrps_id}    ${refrtt}
# 
# 
# 
# [1][1.0] 5GC002060_1_NREG_NSA-classical-cmw-TDD_Feature Activation
#     [Documentation]    This test case verify the activation of feature 5GC002060-A in case 160mS used
#     ...                First the gNB is configure with feature deactivated and network is verified
#     ...                checking that no packet lost in a 120 packets ping
#     ...                Then, a bad configuration using 160 mS DLC is tried, relation errors should be raised
#     ...                when validating
#     ...                Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                on the used parameters.
#     ...                A 120 ping is then launch and no packets should be lost.
#     ...    NOTE : ALL THESE STEPS HAVE BEEN DONE IN TEST 5GC002060_2
#     log                     5GC002060_1 test is checked
#     Should match regexp		${5GC002060_1}    	  PASSED
# 
# 
# [1]5GC002060_6_NREG_NSA-classical-cmw-TDD_MSC_StaticCall_DrxLongCycle160_Counters
#     [Documentation]    This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
#     ...     First the gNB is configure DLC 160 configuration, then the the begining of next reporting period is waited
#     ...     A UE is attached and it is pinged every 5 second for a little more than the test duration
#     ...     to maintained it connected
#     ...     At the end of the ping, the last pm counter file is retrived and the counters are checked.
#     ...     In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
#     ...     In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in correct range
#     ...     At least one counter M55308C11001 should be not equal to 0
#     ...    NOTE : ALL THESE STEPS HAVE BEEN DONE IN TEST 5GC002060_2
#     [Tags]    CDRT_21B    CRT_21A
#     [Teardown]    5GC002060keysTDD.Test Teardown
# 
#     log                     5GC002060_6 test is checked
#     Should match regexp		${5GC002060_6}    	  PASSED
# 
# [1]5GC002060_7_NREG_NSA-classical-cmw-TDD_MSC_StaticCall_DrxLongCycle320_lowDLTraffic
#     [Documentation]    This test case verify the latency added by feature 5GC002060-A in case DLC320 used
#     ...                First the gNB is configure with feature deactivated and network is verified
#     ...                checking that no packet lost in a 120 packets ping, the average latency is saved to verify
#     ...                the introduced latency is no more than expected
#     ...                Then a DLC320 configuration is used and activated, a UE is attached and a verification is done
#     ...                on the used parameters.
#     ...         A 120 ping is then launch and no packets should be lost,.the average latency should be less equal
#     ...                                to the latency without drx activated plus the drx cyle (320 in this case)
#     Test Setup
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive NSA
#     StaticCall_DrxLongCycle320_lowDLTraffic    ${cells_id}   ${cellgrps_id}    ${refrtt}
# 
# 
# [1]5GC002060_35_NREG_NSA-classical-cmw-TDD_Feature Activation_DLC 320mS
#     [Documentation]                    This test case verify the activation of feature 5GC002060-A in case 320mS used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping
#     ...                            Then, a bad configuration using 320mS DLC is tried, relation errors should be raised
#     ...                                when validating
#     ...                    Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost.
#     ...    NOTE : ALL THESE STEPS HAVE BEEN DONE IN TEST 5GC002060_7
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     log                                5GC002060_35 test is checked
#     Should match regexp                ${5GC002060_35}         PASSED
# 
# [1]5GC002060_11_NREG_NSA-classical-cmw-TDD_MSC_StaticCall_DrxLongCycle320_Counters
#     [Documentation]  This test case verify the counters associated with DRx feature M55308C11001 and M55308C11002.
#     ...    First the gNB is configure DLC 320 configuration, then the the begining of next reporting period is waited
#     ...    A UE is attached and it is pinged every 5 second for a little more than the test duration
#     ...    to maintained it connected
#     ...    At the end of the ping, the last pm counter file is retrived and the counters are checked.
#     ...    In case M55308C11001 is 0, M55308C11002 should be 0 (cells where there is no UE)
#     ...    In case M55308C11001 is not 0, the ration  M55308C11002 / M55308C11001 is verify to be in correct range
#     ...                                At least one counter M55308C11001 should be not equal to 0
# 
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     Test Setup
#     # Get Cells list:
#     ${cells_id}                        Get list of all cells
#     StaticCall_DrxLongCycle320_Counters        ${cells_id}   ${cellgrps_id}
# 
# [1]5GC002060_36_NREG_NSA-classical-cmw-TDD_Feature Activation_DLC 640mS
#     [Documentation]                    This test case verify the activation of feature 5GC002060-A in case 640mS used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping
#     ...                          Then, a bad configuration using 640mS DLC is tried, relation errors should be raised
#     ...                                when validating
#     ...    Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost.
# 
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     Test Setup
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive NSA
#     StaticCall_DrxLongCycle640_lowDLTraffic    ${cells_id}   ${cellgrps_id}
# 
# [1]5GC002060_39_NREG_NSA-classical-cmw-TDD_Feature Activation_DLC 80mS
#     [Documentation]                    This test case verify the activation of feature 5GC002060-A in case 80mS used
#     ...                                First the gNB is configure with feature deactivated and network is verified
#     ...                                checking that no packet lost in a 120 packets ping
#     ...                      Then, a bad configuration using 80 mS DLC is tried, relation errors should be raised
#     ...                                when validating
#     ...                  Then a good configuration is used and activated, a UE is attached and a verification is done
#     ...                                on the used parameters.
#     ...                                A 120 ping is then launch and no packets should be lost.
# 
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     Test Setup
#     ${cells_id}   ${cellgrps_id}    ${refrtt}     StaticCall FeatureNotActive NSA
#     StaticCall_DrxLongCycle80_lowDLTraffic    ${cells_id}   ${cellgrps_id}
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
# 
#     [Teardown]    5GC002060keysTDD.Test Teardown
#     Test Setup
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive SA    attach_mode=5G_SA
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
#     Test Setup
# 
#     ${cells_id}   ${cellgrps_id}    ${refrtt}    StaticCall FeatureNotActive SA    attach_mode=5G_SA
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
# 	Set suite variable                 ${5GC002060_37}  PASSED
# 
# 
# 
# 
