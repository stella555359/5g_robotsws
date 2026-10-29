*** Settings ***
Documentation     [PURPOSE] UE General keywords
Library	    taf.ue
Library	    taf.ue.android
#Library	    ute_ue
Library		SSHLibrary
Library		String
Library		Collections


*** Variables ***
${ue_pc_ip}=			${EMPTY}
${login}=				${EMPTY}
${password}=			${EMPTY}
${serial_number}=		${EMPTY}
${starting_cell}=		${EMPTY}
${Endeavored_Not_Required}	${TRUE}
${mcc}	262
${mnc}	03


*** Keywords ***
Endeavored UE Attach
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	Run Keyword And Ignore Error    Attach Ue    ${UE}
	${status}=	Run Keyword And Return Status	UE Is Attached Successfully		${serial_number}
	Return From Keyword If    ${status}

	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command
	...     adb2 -s ${serial_number} shell "settings put global airplane_mode_on 0;service call phone 27"	sudo=False
	${status}=	Run Keyword And Return Status	UE Is Attached Successfully		${serial_number}
	Return From Keyword If    ${status}

	Endeavored Attach	${serial_number}
	UE Is Attached Successfully		${serial_number}

Endeavored Attach
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command	adb2 -s ${serial_number} shell "service call connectivity 54 i32 0"	sudo=False
	Sleep	5s
	UE Is Attached Successfully	${serial_number}

Endeavored Detach
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command	adb2 -s ${serial_number} shell "service call connectivity 54 i32 1"	sudo=False
	Sleep	5s
	UE Is Detached Successfully	${serial_number}

Endeavored UE Detach
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	Log	${serial_number}
	Run keyword and ignore error    Detach Ue    ${UE}
	${detached}=    Run keyword and return status    UE Is Detached Successfully	${serial_number}
	Return From Keyword If    ${detached}

	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command
	...     adb2 -s ${serial_number} shell "settings put global airplane_mode_on 1;service call phone 27"	sudo=False
	${detached}=	Run Keyword And Return Status	UE Is Detached Successfully		${serial_number}
	Return From Keyword If    ${detached}

	Log To Console	"Detach Ue" keyword failed. Try with endeavored way....
	Endeavored Detach	${serial_number}

Require Ue Custom
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
	[Arguments]	    ${UE_alias}		${required_ue}
	${empty_list}=  Create List
	${result}=    Run Keyword And Return Status    Log     ${required_ues}
	${required_ues}=    Set Variable If  ${result}==${TRUE}    ${required_ues}     ${empty_list}
	Set Test Variable   ${required_ues}
	${ue_is_required}=      Run Keyword And Return Status   Should Contain     ${required_ues}   ${UE_alias}
	Run Keyword If     ${ue_is_required}==${FALSE}
	...	Run Keywords
		...	Require Ue	${UE_alias}	${required_ue}
		...	AND		Append To List	${required_ues}     ${UE_alias}
	Log     ${required_ues}

UE RRC IDLE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
	[Arguments]		${interval}		${UE_alias}=${UE_alias}		${required_ue}=Nokia_X7
	Log to Console		Trigger UE RRC_IDLE
	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Require Ue Custom	${UE_alias}	${required_ue}
	Sleep	5s
	Endeavored UE Attach    ${serial_number}
	Check If It Is Correct Cell ID	${UE_alias}		${eutraCelId}
	${ip}=  Get UE Info     ${UE_alias}   IP
	Disable Enable Mobile Data		${interval}     ${UE_alias}
	sleep	5s
	Endeavored UE Detach	${serial_number}
	Reboot UE   ${serial_number}
	Close SSH Connection to UE PC

UE RRC ACTIVE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
    ...        ${extra}: <description>
	[Arguments]		${interval}=10		${UE_alias}=${UE_alias}		${required_ue}=Nokia_X7     ${extra}=0.1
	Log    ${extra}
	Log to Console		Keep RRC active for ${interval}s
	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Log		${starting_cell}
	Log		${required_ue}
	Require Ue Custom	${UE_alias}	${required_ue}
	Sleep	5s
	Endeavored UE Attach    ${serial_number}
	Check If It Is Correct Cell ID	${UE_alias}		${eutraCelId}
	Start Data Transfer  TEST_TRAFFIC   ${UE_alias}   direction=dl      duration=${interval} seconds
	sleep	${interval}s
#	sleep   ${extra}s
	Stop Data Transfer  TEST_TRAFFIC
	Endeavored UE Detach	${serial_number}
    Reboot UE   ${serial_number}
	Close SSH Connection to UE PC

UE RRC ACTIVE with random cell
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
    ...        ${extra}: <description>
	[Arguments]		${interval}		${UE_alias}=${UE_alias}		${required_ue}=Nokia_X7     ${extra}=0.1
	Log to Console		Keep RRC active for ${interval}s
	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Log		${starting_cell}
	Log		${required_ue}
	Require Ue Custom	${UE_alias}	${required_ue}
	Sleep	5s
    Endeavored UE Attach    ${serial_number}
    #Check If It in Correct Cell ID   ${UE_alias}		${cell_id_list}
    Start Data Transfer  TEST_TRAFFIC   ${UE_alias}   direction=dl
	sleep	${interval}s
	sleep   ${extra}s
	Stop Data Transfer  TEST_TRAFFIC
	Endeavored UE Detach	${serial_number}
    Reboot UE   ${serial_number}
	Close SSH Connection to UE PC

Check If It in Correct Cell ID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    ...        ${DESIRED_CELL_ID}: <description>
	[Arguments]	${UE_alias}		${DESIRED_CELL_ID}
    ${CELL_ID}=    Get Ue Info    ${UE_alias}   CELL_ID
    List Should Contain Value     ${DESIRED_CELL_ID}      '${CELL_ID}'
    #Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}

Reboot UE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
    [Arguments]		${serial_number}
    SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command     adb2 -s ${serial_number} shell reboot	    sudo=False
	Wait Until Keyword Succeeds		1min		5s	UE Is Offline	${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	Log     Wait 200s to get UE ready
	Sleep   200

Attach UE And Start Traffic
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
    ...        ${duration}: <description>
	[Arguments]		${UE_alias}=${UE_alias}		${required_ue}=Nokia_X7     ${duration}=30
	Log    ${duration}
	Log to Console		Attach UE And Start Traffic
#	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Log		${starting_cell}
	Log		${required_ue}
#	Require Ue Custom	${UE_alias}	${required_ue}
	Sleep	5s
	Endeavored UE Attach    ${serial_number}
	Check If It Is Correct Cell ID	${UE_alias}		${eutraCelId}
	Start Data Transfer  TEST_TRAFFIC   ${UE_alias}   direction=dl
#	await_data_transfer_finish      TEST_TRAFFIC

Attach UE And Start ICMP Ping
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    ...        ${required_ue}: <description>
    ...        ${ping_count}: <description>
    ...
    ...    Returns:
    ...        ${attached_cell_id}: <description>
	[Arguments]		${UE_alias}=${UE_alias}		${required_ue}=Nokia_X7     ${ping_count}=30
	Log to Console		Attach UE And Start Traffic
	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Log		${starting_cell}
	Log		${required_ue}
	Require Ue Custom	${UE_alias}	${required_ue}
	Sleep	5s
	Endeavored UE Attach    ${serial_number}
    ${attached_cell_id}=    get_ue_info		${UE_alias}    CELL_ID
    ${ue_ip}=    get_ue_info		${UE_alias}    IP
	Start Data Transfer  TEST_TRAFFIC   ${UE_alias}   direction=dl  protocol=icmp      ping_host_ip=${ue_pc_ip}
	...     ping_count=${ping_count}     allowed_packet_loss=10
	[return]    ${attached_cell_id}

Detach UE And Stop Traffic
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
	[Arguments]		${UE_alias}=${UE_alias}
	Log    ${UE_alias}
#	Run Keyword And Ignore Error    Stop Data Transfer  TEST_TRAFFIC
	Run Keyword And Ignore Error    stop_data_transfers_for_all_ues
	Endeavored UE Detach	${serial_number}
	Reboot UE   ${serial_number}
	Close SSH Connection to UE PC

Multi UE Attach
    [Documentation]    Short description.
	Set Up Env	${required_ue}
	Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Run Keyword And Ignore Error	Require Ue	UE1	Nokia_X7
	Run Keyword And Ignore Error	Require Ue	UE2	Honor_8
	Detach Ue	UE1
	Detach Ue	UE2
	FOR		${index}	IN RANGE	0	100
		Sleep	5s
		Log To Console		Round: ${index}.
		${status}=	Run Keyword And Return Status	Attach Ue	UE1
		${status}=	Run Keyword And Return Status	Attach Ue	UE2
		Start Data Transfer  TEST_TRAFFIC1   UE1   direction=dl
		Start Data Transfer  TEST_TRAFFIC2   UE2   direction=dl
		${interval}=	evaluate	${index}%15
		sleep	${interval}s
		Stop Data Transfer  TEST_TRAFFIC1
		Stop Data Transfer  TEST_TRAFFIC2
		Detach Ue	UE1
		Detach Ue	UE2
	END
	Close SSH Connection to UE PC

Set Up Env
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${required_ue}: <description>
	[Arguments]		${required_ue}
	Log	${tl.ues}
	${UEs}=	Set Variable	${tl.ues}
	Log 	${UEs}
	FOR		${ue}	IN	@{UEs}
		Log		${ue.capabilities}
		Log     ${required_ue}
		${status}=	Run Keyword And Return Status	List Should Contain Value	${ue.capabilities} 	${required_ue}
		Continue For Loop If		${status}==${FALSE}
        ${ue_pc}=               Set Variable    ${ue.ssh_connection_details}
		${ue_pc_ip}=			Set Variable	${ue_pc.addr}
		${login}=				Set Variable	${ue_pc.username}
		${password}=			Set Variable    ${ue_pc.password}
		${serial_number}=		Set Variable    ${ue.serial_number}
		${starting_cell}=		Set Variable	${ue.service_call_attach}
		Set Test Variable	${ue_pc_ip}
		Set Test Variable	${login}
		Set Test Variable	${password}
		Set Test Variable	${serial_number}
		Set Test Variable	${starting_cell}
		Set Test Variable	${required_ue}
		Exit For Loop If            ${status}==${TRUE}
	END

Check If It Is Correct Cell ID
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    ...        ${DESIRED_CELL_ID}: <description>
	[Arguments]	${UE_alias}		${DESIRED_CELL_ID}
    ${CELL_ID}=    Get Ue Info    ${UE_alias}   CELL_ID
	Run Keyword If	${CELL_ID}==-1
	...	Run Keywords
		...	Check Cell ID with Adb command
		...	AND	Return From Keyword
    Should Be Equal    ${DESIRED_CELL_ID}    ${CELL_ID}
	Run Keyword And Ignore Error    log_ue_info		${UE_alias}

Check Cell ID with Adb command
    [Documentation]    Short description.
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command	adb2 -s ${serial_number} shell "logcat -b radio| grep ${eutraCelId} | head"	sudo=False
	Log     If kw "Read Command Output" failed with timmeout, UE may attached to other cell.
	${output}=		Read Command Output     timeout=30
	Log		${output}
	${status}=	Run Keyword And Return Status	Should Contain	${output}	mCi=${eutraCelId}	ignore_case=${TRUE}
	Run Keyword If	${status}==${FALSE}
	...	Should Contain	${output}	ci = ${eutraCelId}		ignore_case=${TRUE}

UE is Inactive
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    [Arguments]    ${UE_alias}
    Disable Mobile Data		${serial_number}
    ${result}=      Run Keyword And Return Status    Get Ue Info     ${UE_alias}     IP
    Should Be True      ${result}==${FALSE}

UE is Active
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${UE_alias}: <description>
    [Arguments]    ${UE_alias}
    Enable Mobile Data		${serial_number}
    ${result}=      Run Keyword And Return Status    Get Ue Info     ${UE_alias}     IP
    Should Be True      ${result}==${TRUE}
    ${ip}=   Get Ue Info     ${UE_alias}     IP

Disable Enable Mobile Data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${UE_alias}: <description>
	[Arguments]		${interval}     ${UE_alias}
	List UE		${serial_number}
    Wait Until Keyword Succeeds		30s		5s		UE is Inactive      ${UE_alias}
    sleep	${interval}
    Wait Until Keyword Succeeds		30s		5s		UE is Active        ${UE_alias}

Open SSH Connection to UE PC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ue_pc_ip}: <description>
    ...        ${login}: <description>
    ...        ${password}: <description>
	[Arguments]  ${ue_pc_ip}    ${login}	${password}
    SSHLibrary.open connection    ${ue_pc_ip}		alias=UE_PC     timeout=30s
    SSHLibrary.login    ${login}		${password}		allow_agent=${False}	look_for_keys=${False}
#    ...     keep_alive_interval=5s

Close SSH Connection to UE PC
    [Documentation]    Short description.
	SSHLibrary.Switch Connection	UE_PC
    SSHLibrary.Close Connection
	Run Keyword And Ignore Error	SSHLibrary.Switch Connection	DEFAULT

List UE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	UE Is Online	${serial_number}

Enable Mobile Data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]  ${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command
	...     adb2 -s ${serial_number} shell svc data enable | grep -v daemon | grep -v out		sudo=False
	${output}=		Read Command Output
	Should Be Empty		${output}

Disable Mobile Data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]  ${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command
	...     adb2 -s ${serial_number} shell svc data disable | grep -v daemon | grep -v out		sudo=False
	${output}=		Read Command Output
	Should Be Empty		${output}

Set Up UE
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${required_ue}: <description>
	[Arguments]	${required_ue}
	Log to console    .
	Log to console    Set up UE: ${required_ue}
	Set Up Env	${required_ue}
	Wait Until Keyword Succeeds		60s		5s
	...     Open SSH Connection to UE PC		${ue_pc_ip}		${login}	${password}
	Get IMSI    ${serial_number}    ${mcc}    ${mnc}
	SSHLibrary.Start Command	adb2 devices
	${output}=		Read Command Output
	Log		${output}
	${matchs}=	Get Regexp Matches		${output}	${serial_number}([\\s]*)device
	Length Should Be	${matchs}	1
	#Kill Total Control	${serial_number}
	Log 	Reboot UE with SN: ${serial_number} If UE uptime excced 1 day
	${up_days}=		Get UE Up Days	${serial_number}
	${len}=	Get Length	${up_days}
	Run Keyword If	${len}>0    Reboot UE   ${serial_number}
	SSHLibrary.Execute Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	${output}=	SSHLibrary.Execute Command	adb2 devices		sudo=False
	Should Contain	${output}	${serial_number}
	${up_days}=		Get UE Up Days	${serial_number}
	Length Should Be	${up_days}	0
	Enable Mobile Data	${serial_number}
	Set Up Env	${required_ue}
	Require Ue Custom	${UE}	${required_ue}
	If UE Attach Is Possible	${serial_number}
	Close SSH Connection to UE PC

If UE Attach Is Possible
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	${attached}=	Run keyword And Return Status		UE Is Attached	${serial_number}
	Run Keyword If	${attached}==${TRUE}
		...	Endeavored UE Detach	${serial_number}
	...	ELSE
		...	Run Keywords
			...	Endeavored UE Attach	${serial_number}
			...	AND	Endeavored UE Detach	${serial_number}

Verify if UE is Attached
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	${Endeavored_Not_Required}=	Run keyword And Return Status	UE Is Attached Successfully		${serial_number}

Verify if UE is Detached
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	${Endeavored_Not_Required}=	Run keyword And Return Status	UE Is Detached Successfully		${serial_number}

Get UE Up Days
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
    ...
    ...    Returns:
    ...        ${up_days}: <description>
	[Arguments]	${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command	adb2 -s ${serial_number} shell uptime	sudo=False
	${output}=		Read Command Output
	Log		${output}
	${up_days}=		Get Regexp Matches	${output}	up([\\s\\w:]*) ([\\d]+) day	2
	[RETURN]	${up_days}

UE Is Attached Successfully
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]		${serial_number}
	Wait Until Keyword Succeeds		3min		2s		UE Is Attached	${serial_number}
#	Check If It Is Correct Cell ID	${UE_alias}		${eutraCelId}

UE Is Attached
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]		${serial_number}
#	${ip}=  Get UE Info     ${UE_alias}   IP
	${ip}=	Get UE Ip	${serial_number}
	${len}=	Get Length	${ip}
	Should Be True	${len}>=1
	Log To Console	UE ${required_ue} IP: ${ip[0]}

UE Is Detached Successfully
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]		${serial_number}
	Wait Until Keyword Succeeds		30s		1s		UE Is Detached	${serial_number}

UE Is detached
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]		${serial_number}
	${ip}=	Get UE Ip	${serial_number}
	Length Should Be	${ip}	0

Get UE Ip
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
    ...
    ...    Returns:
    ...        ${UE_IP}: <description>
	[Arguments]		${serial_number}
	Log    ${serial_number}
	SSHLibrary.Start Command	adb2 -s ${serial_number} wait-for-device	sudo=False
	SSHLibrary.Start Command	adb2 -s ${serial_number} shell ip addr		sudo=False
	${output}=		Read Command Output
	Should Not Be Empty		${output}
	Log		${output}
	${UE_IP}=	Get Regexp Matches	${output}	1[079]([\\d]*)\\.([\\d]+)\\.([\\d]+)\\.([\\d]+)
	[RETURN]	${UE_IP}

Kill Total Control
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	Log    ${serial_number}
	SSHLibrary.Start Command		netstat -aon | grep 11013 | awk -F " " '{print $5}' | sort | uniq 	sudo=False
	${output}=		Read Command Output
	${process}=		replace string	${output}	\r	${EMPTY}
	Log		${output}
	${status}=	Run Keyword And Return Status	should not be empty		${process}
	Run Keyword If	${status} == ${FALSE}	Return From Keyword
	Log		Kill Totol Control
	Log		Kill PID: ${process}
	SSHLibrary.Start Command	TASKKILL /F /PID ${process}		sudo=False
	${output}=		Read Command Output
	SSHLibrary.Start Command		netstat -aon | grep 11013 | awk -F " " '{print $5}' | sort | uniq  		sudo=False
	${output}=		Read Command Output
	Should Be Empty		${output}

UE Is Offline
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	SSHLibrary.Start Command		adb2 devices		sudo=False
	${output}=		Read Command Output
	Should Not Contain		${output}	${serial_number}

UE Is Online
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${serial_number}: <description>
	[Arguments]	${serial_number}
	SSHLibrary.Start Command		adb2 devices		sudo=False
	${output}=		Read Command Output
	Should Contain		${output}		${serial_number}

Get IMSI
    [Documentation]    Get UE's IMSI, works for Mate30Pro5G
    ...
    ...    Args:
    ...        ${serial_number}: <description>
    ...        ${mcc}: <description>
    ...        ${mnc}: <description>
    [Arguments]	 ${serial_number}    ${mcc}    ${mnc}
    FOR    ${id}    IN RANGE    1    10
        SSHLibrary.Start Command    adb -s ${serial_number} shell service call iphonesubinfo ${id}    sudo=False
        ${output}=		Read Command Output
        ${matchs}=    Get Regexp Matches    ${output}    '([0-9.\\s]+)'    1
        ${imsi}=    Catenate    SEPARATOR=${EMPTY}    @{matchs}
        ${imsi}=    Replace String    ${imsi}    .    ${EMPTY}
        ${imsi}=    Replace String    ${imsi}    '    ${EMPTY}
        ${imsi}=    Replace String    ${imsi}    ${SPACE}    ${EMPTY}
        ${is_imsi}=    Run Keyword And Return Status    Should Contain    ${imsi}    ${mcc}${mnc}
        Run keyword If    ${is_imsi}    Set Test Variable    ${imsi}
        Run keyword If    ${is_imsi}    Log To Console    IMSI: ${imsi}
        Exit For Loop If    ${is_imsi}
    END
