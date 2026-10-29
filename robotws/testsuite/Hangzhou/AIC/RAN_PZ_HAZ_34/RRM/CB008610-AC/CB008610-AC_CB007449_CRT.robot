# *** Settings ***
# Documentation
# ...   author: lixtang
# ...   contact: lixia.tang@nokia-sbell.com
# ...   squad group: RAN_PZ_HAZ3_SG03
# ...   Feature CB008610-AC CB007499 in 5G22R4 program
# 
# Force Tags    CRT_TRUNK
# Suite Setup
# Suite Teardown
# Test Timeout    30 minutes
# 
# Resource    Resources/CB008610-AC_CB007449_common_keyword.robot
# 
# 
# *** Variables ***
# ${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}
# ${MODIFY_DU_SCF}    SCF_0.300_DU_CB008610_AC.xml
# 
# *** Test Cases ***
# [1]CB008610-AC_CB007449-BF_03_Apply_Frequency_Offset_Compensation_to_Long_PUCCH_1116_3ms_100MHz_beamSet#4
#     [Documentation]    The user scenario validates the fact, that the PUCCH resource distribution (according to various settings)
#     ...     is successful - without final validation of capacity.
#     [Setup]    Test Case Setup
#     log to console    \n*** Commission SCF ***
#     vDU Full Commission SCF    scf_file=${SCF_Template_path_DU}/${MODIFY_DU_SCF}
#     OAM Precondition Cell Should Be Onair
#     One UE Attach
#     UE Start Traffic
#     Sleep   20s
#     UE Check Bi Tput
#     UE Stop Traffic
#     One UE Detach
#     [Teardown]    Test Case Teardown
# *** Keywords ***
# 
# 
# 
