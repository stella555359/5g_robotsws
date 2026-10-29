*** Settings ***
Documentation     [PURPOSE] gui General keywords
Library     OperatingSystem
Library     ../../lib/JnlpDownloader.py


*** Variables ***
${LIB_PATH}    external-libs/target


*** Keywords ***
Launch TraceViewer
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${username}: <description>
    ...        ${password}: <description>
    [Timeout]    300s
    [Arguments]    ${username}    ${password}
	${remote_port}=		Set Variable	50907
	Set Suite Variable	${remote_port}
#    ${status}=     Run Keyword And Return Status       Wait Until Keyword Succeeds		5min	10s
#    ...     Start TraceViewer Application	${username}    ${password}	${remote_port}
    ${status}=     Run Keyword And Return Status       Start TraceViewer Application
    ...     ${username}    ${password}	${remote_port}
    Run Keyword If  ${status}==${FALSE}
    ...     Log To Console
    ...     Error: Pls analysis orbtrc.xxx.txt file to check why Trace Viewer failed to start.
    Should Be True  ${status}==${TRUE}
    Kill Unused Process  port_in_use=${remote_port}

Start TraceViewer Application
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${remote_port}: <description>
	[Arguments]    ${username}    ${password}	${remote_port}=50907
	${remote_port}=		evaluate	${remote_port}+1
	Set Suite Variable	${remote_port}
	Log to Console		Start TraceViewer appliation on port ${remote_port}
	${jnlpPath}=	Join Path	/home/ute/test_results  trace.jnlp
    download_jnlp_file    ${jnlpPath}    ${username}    ${password}     ${netact}[SDV_WEBSPHERE_CLUSTER_FQDN]
    OperatingSystem.Get File    ${jnlpPath}
    ${status}  ${message} =  Run Keyword And Ignore Error    Run    %{TEX_JAVAWS}
    Run Keyword If  '${status}' == 'FAIL'    Set Global Variable    ${javaws_command}    javaws
            ...      ELSE    Set Global Variable    ${javaws_command}    %{TEX_JAVAWS}
    RemoteSwingLibrary.Setup    javaws_path=/usr/bin/javaws
#	Start Application	TraceViewer	${javaws_command} -J-Djava.security.policy=../mypolicy ${jnlpPath} -silent
#	...     300 seconds    close_security_dialogs=True    remote_port=${remote_port}
    RemoteSwingLibrary.Start Application    jnlp_file=${jnlpPath}   remote_port=${remote_port}   timeout=${900}
    ...     close_security_dialogs=${True}  alias=TraceViewer
    RemoteSwingLibrary.Select Window	regexp=^TraceViewer.*
	${title}=	Get Selected Window Title
	${title}=	Replace String	${title}	${SPACE}	${EMPTY}
	@{split_title}=		Split String	${title}	-
	${gui_lab_name}=	Set Variable	${split_title}[1]
	${status}=	Run Keyword And Return Status	Should contain
	...     ${netact}[SDV_WEBSPHERE_CLUSTER_FQDN]    ${gui_lab_name}
	Run Keyword If	${status}==${FALSE}
		...	Log To Console		TraceViewer application lab name mismatch ${gui_lab_name}:${remote_port}. Try again...
	Should Be True	${status}==${TRUE}

Kill Unused Process
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${port_in_use}: <description>
    [Arguments]    ${port_in_use}
    ${user}=    Run     whoami
    ${output_1}=  Run     sudo netstat -tanp| grep ${port_in_use}
    LOG     ${output_1}
    ${matchs}=	Get Regexp Matches      ${output_1}   (\\d+)/java  1
    ${len}=     Get Length  ${matchs}
    Return From Keyword If  ${len}<=0
    ${process_in_use}=  Set Variable    ${matchs}[0]
    ${output_2}=  Run     sudo ps -ef | grep java | grep jnlp | grep -v ${process_in_use}
    LOG     ${output_2}
    ${matchs}=	Get Regexp Matches      ${output_2}   ${user}\\s+(\\d+)\\s+    1
    FOR     ${pid}      IN      @{matchs}
        ${output_1}=  Run     sudo kill -9 ${pid}
    END

Close TraceViewer
    [Documentation]    Short description.
    [Timeout]    60s
    Close All Dialogs
    Close Window	regexp=^TraceViewer.*
    Select Dialog	regexp=^.*Confirm.*
    Click On Component	Yes
    system exit

Close All Windows
    [Documentation]    Short description.
    Close All Dialogs
    Run Keyword And Ignore Error    Close Window    regexp=^Trace Analysis.*
