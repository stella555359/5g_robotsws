*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is 255UE attach test script for CB009211

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common MultiBTS Suite Setup For RRM
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM

# Test Timeout       120 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__
# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# &{fault_61510}           faultId=${61510}
# &{fault_4459}            faultId=${4459}
# &{fault_8000}            faultId=${8000}
# &{fault_7300}            faultId=${7300}
# &{fault_61616}           faultId=${61616}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_4459}
# ...    &{fault_8000}    &{fault_7300}    &{fault_61616}

# ${Ignore_Cell_Id_For_Sib}    5    6    9    12

# *** Test Cases ***
# Mutiple UE attach test
#     [Documentation]
#     ...    author: Dacheng Zhang
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_TMO_255UE
#     ...    base_path=${CURDIR}/APCFG
#     ...    call_type=sansa
#     FOR    ${i}    IN RANGE    253
#         Log To Console      ${\n}============= Start to Attach the UE ${i+1} =============${\n}
#         Airphone.Airphone Execute Egate Command    cmd=ue_register id\=${i+1}
#         ...    pass_regexp=now Registered
#         sleep    2s
#         Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=${i+1} pdu\=1 trf_type\=internal
#         ...    pass_regexp=${None}
#         sleep    1s
#         Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${i+1} nwslice\=1 gw\=${i+1}
#         ...    pass_regexp=Initial Context Setup Successful
#         sleep    3s
#         Log To Console      ${\n}============= Start DL Data traffic on UE =============${\n}
#         Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=${i+1} pdu\=1 qfi\=1 dir\=dl mbps\=5
#         ...    pass_regexp=${None}
#         sleep    2s
#     END