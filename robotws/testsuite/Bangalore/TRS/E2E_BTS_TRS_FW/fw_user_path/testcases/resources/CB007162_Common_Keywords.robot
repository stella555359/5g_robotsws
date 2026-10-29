*** Settings ***
Documentation
...		[Author]     	"Vivin"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Library          ute_btssm
Library			 SeleniumLibrary

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Enter details to update default BTS credentials
	[Arguments]		${Old_Password}		${New_Password}		${New_Password_Confirm}
	Wait Until Element Is Visible    //*[@name="oldPassword"]    ${Max_Timeout}
	Wait Until Element Is Enabled    //*[@name="oldPassword"]    ${Max_Timeout}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@name="oldPassword"]
	...		#Enter old password
	Input Text	//*[@name="oldPassword"]	${Old_Password}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@name="password"]
	...		#Enter new password
	Input Text	//*[@name="password"]	${New_Password}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@name="confirmPassword"]
	...		#Confirm new password
	Input Text	//*[@name="confirmPassword"]	${New_Password_Confirm}


Login to the BTS Webpage
	[Arguments]		${Webpage_URL}
		#Start WebEM X display [needed for cloud single run execution] and open browser
	${status}=      Webem_display.Start_WebEM_XDisplay
	Open Browser	${Webpage_URL}	browser=firefox    alias=secondary
		#Confirm page security
#	Run Keyword and Ignore Error 	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Button   //*[@id="details-button"]
#	Run Keyword and Ignore Error 	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@id="proceed-link"]


Confirm WebEM Legal Notice
	Wait Until Element Is Visible    //*[@a-text="Confirm"]//button		${Max_Timeout}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    	//*[@a-text="Confirm"]//button
#	Wait Until Element Is Visible    //*[@a-text="Close"]//button		${Max_Timeout}
#	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    	//*[@a-text="Close"]//button


Enter the BTS credentials
	[Arguments]		${Username}		${Password}
		#Enter Username
	Wait Until Element Is Visible    //*[@id="login-username"]    ${Max_Timeout}
	Wait Until Element Is Enabled    //*[@id="login-username"]    ${Max_Timeout}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@id="login-username"]
	Input Text	//*[@id="login-username"]	${Username}
		#Enter Password
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@id="login-password"]
	Input Text	//*[@id="login-password"]	${Password}
		#Click on Login button on screen
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Button	//*[@ng-reflect-label="Login"]
	Sleep	5s

Fault "4459 - User Account has Default Password" for Nemuadmin should be present
	Sleep	60
	${Alarm_list}=  Verify Alarm        faultid=4459     rat=lte     should_exist=True   occurrences=1     check_unexpected_alarms=${false}
    :FOR    ${i}    IN  @{Alarm_list}
    \   ${fault_id}=    Get From Dictionary     ${i}    faultId
    \   ${status}=      Continue For Loop If    ${fault_id}!=4459
    \   ${supplAlarmInfo}=      Get From Dictionary     ${i}    supplAlarmInfo
	\	Should contain		${supplAlarmInfo}		Bts Sys Admin (Nemuadmin)
    \   Exit For Loop If    ${fault_id}==4459



Fault "4459 - User Account has Default Password" for Nemuadmin should not be present
	${Alarm_list}=  Verify Alarm        faultid=4459     rat=lte     should_exist=True   occurrences=1     check_unexpected_alarms=${false}
    :FOR    ${i}    IN  @{Alarm_list}
    \   ${fault_id}=    Get From Dictionary     ${i}    faultId
    \   ${status}=      Continue For Loop If    ${fault_id}!=4459
    \   ${supplAlarmInfo}=      Get From Dictionary     ${i}    supplAlarmInfo
	\	Should not contain		${supplAlarmInfo}		Bts Sys Admin (Nemuadmin)
    \   Exit For Loop If    ${fault_id}==4459


Fetch Mplane IP
    ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_ip_moc}
    Set Suite Variable          ${mplane_ipv4}



Enable '${account_type}' account
	User Account Manage		operation=change_account_state		account_type=${account_type}	enable=${True}


Restore BTS environment
	Run Keyword And Ignore Error		Perform Recommissioning     type=param	param_path=${allowSysAdminDefaultPassword_Moc}
	...		value=true    timeout=120		operation=update
	Execute command on ENodeB		rm /ffs/run/config/users.json;reboot
	Sleep	300s