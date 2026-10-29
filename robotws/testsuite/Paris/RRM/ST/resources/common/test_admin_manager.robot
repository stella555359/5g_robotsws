*** Settings ***
Documentation    This file contains test cases for AdminManager class.

Library           Collections
Library           OperatingSystem
Library           Process
Library           ./python/admin_manager.py     WITH NAME    AdminManager


*** Test Cases ***
Collect RMOD Info
    [Documentation]    This test case collects RMOD info using the AdminManager class.
    # if we want to collect info only for RMOD ID 1, we can pass the rmod_id as an argument
    ${rmod_id}=    Set Variable    1
    ${rmod_info}=    AdminManager.get_rmod_conf    rmod_id=${rmod_id}
    Log    ${rmod_info}
    Log    Ipadresse for RMOD_ID ${rmod_id} is ${rmod_info['ipAddress']}

    # if we want to collect all RMOD info, we can pass the rmod_id as None
    ${rmod_info_list}=    AdminManager.get_rmod_conf    rmod_id=${None}
    Log    info of all RMODs: ${rmod_info_list}
