# *** Settings ***
# Documentation     author: Deng Xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: RAN_PZ_HAZ3_SG02
# 
# 
# Resource    ./Resource/common_keywords.robot
# 
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# 
# *** Variables ***
# ${TS_CASE_LOG_PATH}    /home/ute/
# ${apn}    dxdata2
# 
# *** Test Cases ***
# [1]CNI-99458_006_FR2_Classical_SA_CP-RT_PMI_event_for_PMI_ticket_DU_RRCSetup_Record
#     Start DCAP log
#     sleep    100s
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     Should Not Be Empty    ${UE_IP}
#     sleep    100s
#     Stop DCAP log and convert to txt type
#     Check PMI ticket DuRrcSetup
#     CPE UE detach
#     
# [1]CNI-99458_003_FR2_Classical_SA_CP-RT_PMI_event_for_PMI_ticket_DRB ID_Setup_Up_Bearer
#     Check PMI ticket DuBearer DRB-ID
#      
# [1]CNI-99458_005_FR2_Classical_SA_CP-RT_PMI_event_for_PMI_ticket_Scell-ID_Setup_Scell 
#     Check PMI ticket DuCaConfig SCellId
