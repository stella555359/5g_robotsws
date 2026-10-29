***Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords     Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown

*** Variables ***
${ip_address}	 192.168.255.129
${username}  	 toor4nsn
${password}		 oZPS0POrRieRtu
${new_password}	 Test@123#
${pwd_history_length_MOC}   SECADM-1:passwdHistoryLength
${existing_passwd}  oZPS0POrRieRtu

*** Test Cases ***
[1][1.0] TRS_SEC_Password history length service account

#Execution
	Check Default password history length
    Change password and check status     ${new_password}    pass
	Set password history length		3
     Check Changed password history length
    Change password and check status     ${new_password}    fail
	[Teardown]		Keywords to run at end

*** Keywords ***
Check Default password history length
    ${pwd_history_length}=      Get Parameter   param_path=${pwd_history_length_MOC}
	Should Be Equal As Integers 	${pwd_history_length}    0

Change password and check status
    [Arguments]  ${new_password}    ${status}
	Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p ${existing_passwd} ssh toor4nsn@192.168.255.129     alias=default
    Execute Interactive Remote Command      command=passwd      alias=default
    Execute Interactive Remote Command      command=${new_password}
    ${output}=   Execute Interactive Remote Command      command=${new_password}
    Run Keyword if   '${status}'=='pass'    Should Contain   ${output}  password updated successfully
    Run Keyword if   '${status}'=='fail'    Should Contain   ${output}  Password has been already used. Choose another.

Set password history length
    [Arguments]   ${value}
    Perform Recommissioning     type=param           param_path=${pwd_history_length_MOC}  operation=update    value=${value}    timeout=300


Check Changed password history length
    ${pwd_history_length}=      Get Parameter   param_path=${pwd_history_length_MOC}
    Should Be Equal As Integers     ${pwd_history_length}    3


Keywords to run at end
	Set password history length		0
	Reverting back the default password

Reverting back the default password
    Setup Remote Access         remote_device=bts
    Execute Interactive Remote Command      command=sshpass -p ${new_password} ssh toor4nsn@192.168.255.129     alias=default
    Execute Interactive Remote Command      command=passwd      alias=default
    Execute Interactive Remote Command      command=${existing_passwd}
    Execute Interactive Remote Command      command=${existing_passwd}
