*** Settings ***
Documentation   CB006943 Keywords for APoABIO backdoor checks
...
...  author:   Sudarshan Kanapuram
...  contact:  sudarshan.kanapuram@nokia.com

Library    ./testsuite/Bangalore/ORAN/T04/CB006943UTE/Resources/AP_backdoor_process.py    WITH NAME    Backdoor


*** Variables ***
${LMP_IP}                 192.168.200.1
${RU_USERNAME}          oru01
${ROOT_PASSWORD}          oamterm


${ADMIN_XML}          oamterm




*** Keywords ***
Check RU Admin State in AP
    [Documentation]  Check for admin state in RU
	[Arguments]    ${state_to_check}
    Backdoor.Check_admin_state   ${LMP_IP}  ${RU_USERNAME}    ${ROOT_PASSWORD}    ${state_to_check}

RU test fault trigger
    [Documentation]  Generate test fault in AP backdoor
	[Arguments]    ${fname}    ${fid}    ${fsrc}    ${fseverity}    ${fmode}    ${fobjects}
	Backdoor.Send_rpc_for_test_fault    ${LMP_IP}  ${RU_USERNAME}    ${ROOT_PASSWORD}    ${fname}    ${fid}    ${fsrc}    ${fseverity}
	...    ${fmode}    ${fobjects}

RU test fault clear
    [Documentation]  Clear test fault in AP backdoor
	[Arguments]    ${fname}    ${fid}
	Backdoor.Send_rpc_for_test_fault    ${LMP_IP}  ${RU_USERNAME}    ${ROOT_PASSWORD}    f_name=${fname}    f_id=${fid}    f_clear=Yes
