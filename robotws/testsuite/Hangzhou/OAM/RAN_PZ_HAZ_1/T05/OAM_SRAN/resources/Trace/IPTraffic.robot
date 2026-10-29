*** Settings ***
Documentation     [PURPOSE] IP Traffic General keywords
Library		SSHLibrary


*** Keywords ***
Start IP Traffic Capturing at BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_ip}: <description>
    ...        ${target_ip}: <description>
    ...
    ...    Returns:
    ...        ${tcpdump_pid}: <description>
    ...        ${traffic_file_name}: <description>
	[Arguments]		${bts_ip}   ${target_ip}=${EMPTY}
	${lowStr}=	Generate Random String	12	[LOWER]
	${traffic_file_name}=	Set Variable	traffic_${lowStr}.pcap
	Set Test Variable	${traffic_file_name}
	${start_time}=		Get Current Date
	Set Test Variable	${start_time}
	SSHLibrary.open connection		${bts_ip}	alias=BTS		timeout=10s
    SSHLibrary.login				toor4nsn		oZPS0POrRieRtu
	SSHLibrary.Switch Connection 	BTS
	Kill Unkonwn processes
	Start Command		pgrep tcpdump
	${output}=		Read Command Output
	${processes}=	Split String	${output}	\n
	${default_cmd}=     Set Variable    tcpdump -i any host ${bts_ip} -s 0 -w /user/toor4nsn/${traffic_file_name} &
	${new_cmd}=    Set Variable    tcpdump -i any host ${target_ip} -s 0 -w /user/toor4nsn/${traffic_file_name} &
	Run Keyword If  '${target_ip}'=='${EMPTY}'  Start Command	${default_cmd}	ELSE    Start Command    ${new_cmd}
	#${output}=		Read Command Output
	Start Command		pgrep tcpdump
	${output}=		Read Command Output
	${processes_new}=	Split String	${output}	\n
	FOR		${pid}	IN	@{processes_new}
		${status}=	Run Keyword And Return Status	Should Contain	${processes}	${pid}
		${tcpdump_pid}=		Set Variable If	${status}==${FALSE}		${pid}
		Set Test Variable	${tcpdump_pid}
		Exit For Loop If		${status}==${FALSE}
	END
	Should Be True	${tcpdump_pid}>0
	SSHLibrary.Switch Connection 	DEFAULT
	[RETURN]	${tcpdump_pid}	${traffic_file_name}

Stop IP Traffic Capturing at BTS
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${traffic_file_name}: <description>
	Log		${tcpdump_pid}
	SSHLibrary.Switch Connection 	BTS
	Start Command		pgrep tcpdump
	${output}=		Read Command Output
	SSHLibrary.Execute Command		kill -15 ${tcpdump_pid}; sleep 10s
	Start Command		pgrep tcpdump
	${output}=		Read Command Output
	${processes}=	Split String	${output}	\n
	Should Not Contain		${processes}	${tcpdump_pid}
	SSHLibrary.Get File	/user/toor4nsn/${traffic_file_name}     ${Test Results Dir}/${traffic_file_name}
	Start Command		rm /user/toor4nsn/*cap
	SSHLibrary.Switch Connection 	DEFAULT
	[RETURN]	${traffic_file_name}

Kill Unkonwn processes
    [Documentation]    Short description.
    SSHLibrary.Switch Connection 	BTS
	Start Command		ps -ef | grep tcpdump | grep -v "var/tmp" | grep -v grep
	${output}=		Read Command Output
	Log     ${output}
	${processes_line}=	Split String	${output}	\n
	FOR		${line}	IN	@{processes_line}
		${line_split}=		Split String	${line}		${SPACE}
		Remove Values From List		${line_split}	${SPACE}	${EMPTY}
		Log		${line_split}
		${len}=		Get Length		${line_split}
		Continue For Loop If	${len}<1
		${pid}=		Set Variable	${line_split}[1]
		SSHLibrary.Execute Command		kill -9 ${pid}
	END
