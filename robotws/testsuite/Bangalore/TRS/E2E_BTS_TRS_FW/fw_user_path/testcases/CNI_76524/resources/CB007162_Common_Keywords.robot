*** Settings ***
Documentation
...		[Author]     	"Pooja CK"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"

Library		 	 ${CURDIR}/Webem_display.py
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
	Input Text	//*[@name="oldPassword"]	${Old_Password}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@name="password"]
	Input Text	//*[@name="password"]	${New_Password}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@name="confirmPassword"]
	Input Text	//*[@name="confirmPassword"]	${New_Password_Confirm}

Login to the BTS Webpage
	[Arguments]		${Webpage_URL}
		#Start WebEM X display [needed for cloud single run execution] and open browser
	${status}=      Webem_display.Start_WebEM_XDisplay
	Open Browser	${Webpage_URL}	browser=firefox    alias=secondary

Confirm WebEM Legal Notice
	Wait Until Element Is Visible    //*[@a-text="Confirm"]//button		${Max_Timeout}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    	//*[@a-text="Confirm"]//button

Enter the BTS credentials
	[Arguments]		${Username}		${Password}
	Wait Until Element Is Visible    //*[@id="login-username"]    ${Max_Timeout}
	Wait Until Element Is Enabled    //*[@id="login-username"]    ${Max_Timeout}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@id="login-username"]
	Input Text	//*[@id="login-username"]	${Username}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Element    //*[@id="login-password"]
	Input Text	//*[@id="login-password"]	${Password}
	Wait Until Keyword Succeeds    ${Max_Timeout}    ${Retry_Timeout}    Click Button	//*[@class="login-btn-container"]//button
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
	Run Keyword And Ignore Error    Perform Recommissioning     type=param  param_path=${allowSysAdminDefaultPassword_Moc}  value=true  timeout=120
    ...     operation=update
	Execute command on ENodeB		rm /ffs/run/config/users.json;reboot
	Sleep	300s

Disable '${account_type}' account
    User Account Manage     operation=change_account_state     account_type=${account_type}    enable=${False}

Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Loginbanner Verification
#primary
    ${stdout}=      Get Parameter     param_path=${secadm_moc_Log_banner}        alias=default
    Setup Remote Access  remote_device=Primarybts
    ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal     ${stdout}     ${output}

#secondary
    ${stdout}=      Get Parameter     param_path=${secadm_moc_Log_banner}      alias=secondary
    Setup Remote Access  remote_device=Secondarybts
    ${output}=         Remote Command Execute      command=cat /etc/ssh/banner
    Should Be Equal     ${stdout}     ${output}

Common SecOps
##Enable ssh
       Check SSH Login       Primarybts
       Check SSH Login      Secondarybts
       Sleep    60
       Verify Alarm     faultid=61649   rat=5g      should_exist=${True}     occurrences=2
#Enable R&D port
       Change Rnd Port Security    enable=True     timeout=300     alias=secondary
       Sleep   60
#Disable SOE
       Change Ethernet Port Security   disable=True     timeout=300     alias=secondary
       Sleep   60
       Verify Alarm   faultid=4654     rat=5g      severity=major       should_exist=${True}      occurrences=1
       Verify Alarm   faultid=4654     rat=5g      severity=major       should_exist=${True}      occurrences=1     alias=secondary
#Disable R&D port
       Change Rnd Port Security    disable=True     timeout=300     alias=secondary
       Sleep   60
       Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       Verify Alarm   faultid=61652     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       ...  alias=secondary
#Enable SOE
       Change Ethernet Port Security   enable=True     timeout=300     alias=secondary
       Sleep   60
       Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       Verify Alarm   faultid=4654     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       ...  alias=secondary
#Disable SSH
       Change Ssh Access   disable=True     timeout=300     alias=secondary
       Sleep   60
       Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       Verify Alarm   faultid=61524     rat=5g      alarm_type=history      severity=major       should_exist=${False}      occurrences=0
       ...  alias=secondary

Send Packets
    [Arguments]     ${protocol}     ${type}
    Set Suite Variable      ${protocol}     ${protocol}
    Set Suite Variable      ${type}     ${type}
    Traffic Setup           device=device_1         alias=mplane
    ${packet_speed}     ${time} =       Traffic Start       profile=${type}      alias=mplane
    Traffic Teardown    alias=mplane
    Run Keyword If      '${type}'=='mplane_rate_limit_drop'     Should be True      ${packet_speed} > ${mplane_rate_limit}
    ...     msg=Packets not received at required rate of more than ${mplane_rate_limit} packets/sec
    ...     ELSE        Should be True      ${packet_speed} < ${mplane_rate_limit}
    ...     msg=Packets not received at required rate of less than ${mplane_rate_limit} packets/sec
    ${packets}=     Evaluate    ${packet_speed} * ${time}
    Set Suite Variable      ${packets}      ${packets}
    Set Suite Variable      ${packet_speed}     ${packet_speed}
    Set Suite Variable      ${time}     ${time}
    [Teardown]      Run Keyword And Ignore Error        Traffic Teardown    alias=mplane

Verify Rate Limit
    Log     ${rate_limit_counters_list}
    ${counters_list}=       Get Dictionary Values   ${rate_limit_counters_list}
    FOR    ${counter}    IN    @{counters_list}
       ${counter_param_dict}=      Get Dictionary Values   ${counter}
       Final Calculations  ${counter_param_dict}
    END
    ${counters_increased} =     Evaluate    ${packets} - ${rate_limit_counters_increased}
    ${rate_limiting_speed} =    Evaluate    ${counters_increased} / ${time}
    ${packets_tolerance}=       Evaluate        ${mplane_rate_limit} * 0.1
    ${packets_min}=     Evaluate        ${mplane_rate_limit} - ${packets_tolerance}
    ${packets_max}=     Evaluate        ${mplane_rate_limit} + ${packets_tolerance}
    Should be True      ${packets_min} < ${rate_limiting_speed} < ${packets_max}
    ...     msg=Rate Limiting not within 10% of expected ${mplane_rate_limit} packets/sec

Verify Rate Limit for not mplane IP
    Log     ${rate_limit_counters_list}
    ${counters_list}=       Get Dictionary Values   ${rate_limit_counters_list}
    FOR    ${counter}    IN    @{counters_list}
       ${counter_param_dict}=      Get Dictionary Values   ${counter}
       Final Calculations  ${counter_param_dict}
    END
    ${counters_increased} =     Evaluate    ${packets} - ${rate_limit_counters_increased}
    ${rate_limiting_speed} =    Evaluate    ${counters_increased} / ${time}
    ${packets_tolerance}=       Evaluate        ${not_mplane_rate_limit} * 0.1
    ${packets_min}=     Evaluate        ${not_mplane_rate_limit} - ${packets_tolerance}
    ${packets_max}=     Evaluate        ${not_mplane_rate_limit} + ${packets_tolerance}
    Should be True      ${packets_min} < ${rate_limiting_speed} < ${packets_max}
    ...     msg=Rate Limiting not within 10% of expected ${not_mplane_rate_limit} packets/sec

Final Calculations
    [Arguments]     ${counter_param_dict}
    @{counter_check}=    Create List
    FOR    ${items}    IN    @{counter_param_dict}
        ${rate_limit_counters_increased}=           Get From Dictionary  ${items}  final_counter_value
        Set Suite Variable      ${rate_limit_counters_increased}        ${rate_limit_counters_increased}
        Append To List      ${counter_check}    ${rate_limit_counters_increased}
    END

Verify ping test success
    ${output}=  Run     ping -I eth0 ${enb_mPlane_ip} -c 5
    Should Contain     ${output}    5 packets transmitted, 5 received, 0% packet loss

Verify ping test failure
    ${output}=  Run     ping -I eth1 ${enb_mPlane_ip} -c 1000
    Should Contain     ${output}    100% packet loss

Get IPs
    ${enb_mPlane_ip} =  Get Parameter       param_path=${mplane_ip_moc_path}
    Set Suite Variable      ${enb_mPlane_ip}        ${enb_mPlane_ip}

Get parameter values
    ${cplane_ipv4}=    Get Parameter    param_path=${cplane_ip_moc_path}
    ${mplane_ipv4}=    Get Parameter    param_path=${mplane_ip_moc_path}
    Set Suite Variable    ${mplane_ipv4}
    Set Suite Variable    ${cplane_ipv4}
