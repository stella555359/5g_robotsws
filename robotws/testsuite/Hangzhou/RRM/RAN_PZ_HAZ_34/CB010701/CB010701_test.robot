# *** Settings ***
# Resource    ./Resources/CB010701_common_keywords.robot
# Variables   ./Resources/CB010701_variables.py
# 
# Documentation
# ...   author: xiaodan.li
# ...   contact: xiaodan.li@nokia-sbell.com
# ...   squad group: SG_03
# 
# Suite Setup    Common Suite Setup for COAM
# 
# Suite Teardown    Run keywords
# ...    Common Suite Teardown for COAM    AND
# ...    Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# *** Variables ***
# ${golden_scf_name}    Configuration_scf_GNB1.xml
# 
# *** Test Cases ***
# [1]CB010701_feature_open_and_close_test
#     [Documentation]    This user scenario to verify loop open and closed the CB010701 feature prameter.
#     [Timeout]    3 hour
#     [Setup]    robot_common_operations.Common Case Setup
#     FOR    ${index}    IN RANGE    ${100}
#         Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_CB010701_close}
#         Check Unexpect Alarm whether exist
#         Online modify NIDD on gnb    Modify_Para_Online=${Modify_Para_Online_CB010701_open}
#         Check Unexpect Alarm whether exist
#     END
