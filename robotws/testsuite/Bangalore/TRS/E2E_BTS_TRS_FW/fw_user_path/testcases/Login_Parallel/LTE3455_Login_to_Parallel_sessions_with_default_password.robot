*** Settings ***
Documentation
...     [Procedure]             "SOE verification with parameter disable, enable and persistency check after upgrade"
...     [Author]                "Nandini P"
...     [Maintenance]           "TRS I & V Bangalore Team"
...     [Function_Hash_Tags]    "SOE"
Force Tags    SM TRSIV Test 3       CRT

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Library         Selenium2Library
Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for testteardown

***variables***
${default_alarm}    User Account has Default Password


*** Test Cases ***
[1]LTE3455_Login_to_Parallel_sessions_with_default_password
#Step 0:
    Perform Recommissioning     type=param      param_path=MRBTS-3737/MNL-1/AMGR-1:enableDefaultPasswdAlarm
    ...     operation=update        value=true      timeout=300
	Sleep	60
#Step 1:
	 Verify alarm should exist
     Kill the admin process
	 sleep		60
	 FOR	${i}     IN RANGE 		1 		6
	 		Setup Oamops		alias=conn${i}
	 END
        Run Keyword And Expect Error        *Status reached: http sessionId invalid*     Setup Oamops    alias=conn6
#Step 2:
	 FOR 		${i}		IN RANGE		1		6
	 		Verify alarm should exist		conn${i}
	 END
     Kill the admin process
	 Setup Oamops		alias=test
	 Perform Recommissioning        type=param param_path=MRBTS-3737/MNL-1/AMGR-1:enableDefaultPasswdAlarm
     ...        operation=update        value=${false}      timeout=300


***Keywords***

Verify alarm should exist
	[Arguments]			${alias}=default
	Download Alarm File from eNB		${alias}
	List Should Contain Value    ${SEM_alarms}    ${default_alarm}

Verify alarm should not exist
	Download Alarm File from eNB
	List Should Not Contain Value    ${SEM_alarms}    ${default_alarm}

Download Alarm File from eNB
	[Arguments]			${alias}=default
	${alarms}=		Verify Alarm				alias=${alias}
	Set Suite Variable 		${Active_alarms}		${alarms}
	${SEM_alarms}=		Create List
	${Dict}=	Create Dictionary
	${len}=		Get Length		${alarms}
	FOR 	${i}	IN RANGE	0	${len}
	    	Log Dictionary		${alarms}[${i}]
			${val}=		Get From Dictionary		${alarms}[${i}]		faultName
			Append To List		${SEM_alarms}		${val}
			Set To Dictionary	${Dict}		${i}	${val}
	END
	Set Suite Variable 		${SEM_alarms}		${SEM_alarms}
	Set Suite Variable 		${Dict}		${Dict}

Kill the admin process
	${output}=       Run       ps -aef | grep admin
    ${str2}=        Get Lines Containing String      ${output}     gnome-terminal
    @{first}=   Split To Lines   ${output}
    Remove Values From List    ${first}    ${str2}
    FOR    ${ELEMENT}    IN    @{first}
           ${words}=       Split string    ${ELEMENT}
           ${pid}=     Get from list        ${words}     1
           Run     sudo kill -9 ${pid}
    END
