*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com

Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     testsuite/Krakow/RRM/RAN_PZ/resources/small_cells/tl_configuration_keywords.py
Library     testsuite/Krakow/resources/ue_proxy_cygwin/ue_proxy_cygwin.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Keywords ***
SC Test Preconditions
    [Arguments]    ${attenuation_config}
    Set attenuator configuration    attenuation_config=${attenuation_config}
    Install MCShark Plugin
    start_ue_proxy_on_ue_pc
    Common Preconditions

SC Test Postconditions
    Common Postconditions
    stop_ue_proxy_on_ue_pc
