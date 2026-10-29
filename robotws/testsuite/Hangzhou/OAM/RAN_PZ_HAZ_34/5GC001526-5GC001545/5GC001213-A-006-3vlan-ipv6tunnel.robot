# *** Settings ***
# Suite Setup       #Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup        #Common Test Setup
# Test Teardown
# Test Timeout      1 hour
# 
# Resource          Resource/5GC001545_YA_Keyword.robot
# 
# Documentation
# ...    author: zora.zhang
# ...    contact: zora.zhang@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001213 in 5G19B program
# 
# Force Tags    CA_5G_OAM      #CLOUD_5G_RPI_SB_ASIKA101L_ABILA101B1_AEUA_18A  #4.835
# ...    PY36
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC001545-YA_5GC001213_06_Basic_U_C_M_planes_mapping_to_different_VLANs_with_IPV6_tunnel
#     [Documentation]
#     ...    *****************
#     ...    - [TEST PURPOSE] To verify gNB IPSec shall keep IPSec configuration persistent
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 06.05.2019   https://jiradc.int.net.nokia.com/browse/WESTLAKE-1057    - Created
#     [Tags]    Owner_zora.zhang@nokia-sbell.com    CRT_22R2    CRT_22R4
#     [Setup]   selenium_coam.enable_virtual_display
#     "Step1": Login BTS via WebUI and check HW state
#     #"Step2": Backup commission file via WebUI
#     #"Step3": Import ipsec commission file
#     #"Step4": Login and check HW state with ipsec commission file
#     #"Step5": Check certificate via WebUI
#     "Step6": Check ipsec tunnel connection is up for 006
#     "Step7": Make traffic from leftsubnet to rightsubnet for 006
#     [Teardown]    Teardown
# 
# *** Keywords ***
# 
