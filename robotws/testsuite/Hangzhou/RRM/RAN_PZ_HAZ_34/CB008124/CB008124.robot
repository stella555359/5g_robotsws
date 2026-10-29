# *** Settings ***
# Suite Setup
# Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout
# 
# #Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# 
# Resource          Resources/CB008124-keyword.robot
# 
# Documentation
# ...    author: shanxu
# ...    contact: shangyu.xu@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_3_SG
# 
# Force Tags    CRT_TRUNK
# ...    PY36
# 
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB008124-SR-E_01_IWK1_5GC000704_ULCG_config_setup_during_Intra-gNB_Intra-freq_HO_With_same_UE_CG_activation_status_Wi
# ...th_same_UE_CG_profile_params
#     [Documentation]
#     [Tags]
#     [Setup]
#     [Teardown]    teardown
#     Scf commission and wait on-air    scf_name=SCF_CB008124.xml
#     Set PA prepare
#     L3 call setup
#     Start Traffic UL
#     Handover and check syslog
#     Stop Traffic UL
#     L3 call detach
# 
# 
# *** Keywords ***
# Handover and check syslog
#     ${range}    set variable    10
#     FOR    ${i}    IN RANGE    1    ${range}
#         Start Btslog Collect
#         Set PA HO from cell1 to cell2
#         Stop btslog and check
#         Start Btslog Collect
#         Set PA HO from cell2 to cell1
#         Stop btslog and check
#     END
# 
# Set PA prepare
#     @{channels}=    create list    1    2    3    4    5    6    7    8
#     Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
#     @{channels}=    create list    9    10    11    12
#     Modify HBTE Channel Vaules    channels=${channels}    value=10    ru_id=1    gnb_id=0
# 
# Set PA HO from cell1 to cell2
#     @{channels}=    create list    1    2    3    4    5    6    7    8
#     Modify HBTE Channel Vaules    channels=${channels}    value=10    ru_id=0    gnb_id=0
#     @{channels}=    create list    9    10    11    12
#     Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=1    gnb_id=0
#     sleep    50s
# 
# Set PA HO from cell2 to cell1
#     @{channels}=    create list    1    2    3    4    5    6    7    8
#     Modify HBTE Channel Vaules    channels=${channels}    value=0    ru_id=0    gnb_id=0
#     @{channels}=    create list    9    10    11    12
#     Modify HBTE Channel Vaules    channels=${channels}    value=10    ru_id=1    gnb_id=0
#     sleep    50s
# 
# 
# 
# 
# 
# 
# 
