*** Settings ***
Documentation     [PURPOSE] Trace General keywords
Library     String
Library     BuiltIn
Library		Screenshot
Library     OperatingSystem
Library     Process
Library     taf.sbts.oam.coam.admin
Resource    gui-keywords/GUIKeywords.robot
Resource	SyveCmKeywords.robot
Resource    SQL.robot
Resource    ../hran_frame_sbts.robot
# Library    taf.ul.swing.core    WITH NAME    RemoteSwingLibrary


*** Variables ***
${temp}=    ${-1}


*** Keywords ***
Log to console with time
    [Documentation]  Keyword display, log output with time.
    [Arguments]  ${output}
	${year}  ${month}  ${day}  ${hour}  ${min}	${sec}=  Get Time  format=year,month,day,hour,min,sec
	${time_now}=	Set Variable	${year}-${month}-${day} ${hour}:${min}:${sec}
    Log  ${time_now} | ${output}  console=True

Suite Setup For Trace
    [Documentation]  Trace suite setup.
    Import Test Line Variable
    Install Swing
    Import Library      taf.ul.swing.core    WITH NAME    RemoteSwingLibrary
#    Update Environment Variable And Import RemoteSwingLibrary
#    Import Library      RemoteSwingLibrary
    Configure Wireshark NTRSTR Protocol
    Trace Target Check
    Open SSH Connection
    Setup For CM Resource
    Clear Jave Cache
    Log Environment Variables
    Login With tty
    Update Display for RemoteSwingLibrary
    Log Variables
    Setup connection with admin
    Run Keyword And Ignore Error    Delete CTRLTS Object
    Run Keyword And Ignore Error    Create CTRLTS Object
    TraceViewer Application Is Started

X11vnc Is Running
    [Documentation]    Short description.
    ${output}=      Run     ps -ef | grep x11 | grep -v grep
    log     ${output}
    ${output}=      Run     ps -ef | grep x11 | grep -v grep | wc -l
    Should Be True   '${output}'=='1'

Import Test Line Variable
    [Documentation]    Short description.
    ${host_name}=   Run     hostname
    ${host_name}=   Replace String      ${host_name}    -   _
    ${host_name}=   Replace String Using Regexp      ${host_name}    _\\d\$   ${EMPTY}
    Set Suite Variable   ${host_name}
    ${variable_path}=   Set Variable    /home/ute/testline_configuration/${host_name}/__init__.py
#    Run Keyword And Ignore Error     Import Variables    ${CURDIR}${/}..${/}..${/}Variables${/}${host_name}.py
    OperatingSystem.File Should Exist           ${variable_path}
    Import Variables   ${variable_path}

Clear Jave Cache
    [Documentation]    Short description.
    ${output}=  Run     javaws -clearcache
    Log     ${output}

Login With tty
    [Documentation]    Short description.
    wait until keyword succeeds		120s		10s    X11vnc Is Running
    ${tty_login}=    tty Login Check
    Run keyword If  ${tty_login}==${TRUE}
    ...     Return From Keyword
    Login with tty via vncdotool

Login with tty via vncdotool
    [Documentation]    Short description.
    Install vncdotool
    Install pyopenssl
    Install cryptography
    Install service identity
    ${vm_password}=    Get Test PC Password
    ${vnc_password}=    Get VNC Password
    wait until keyword succeeds		600s		30s    tty Login with vncdo command     ${vnc_password}

Get VNC Password
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${vncpassword}: <description>
    ${output}=      Run     ps -ef | grep -i x11 |grep -v grep
    Log     ${output}
    ${matchs}=  Get Regexp Matches      ${output}   passwdfile ([^ ]+)  1
    ${vncpassword_file_path}=     Set Variable    ${matchs}[0]
    ${vncpassword}=     Run     sudo cat ${vncpassword_file_path}
    Log To Console      VM password: ${vncpassword}
    [RETURN]	${vncpassword}

tty Login with vncdo command
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${vm_password}: <description>
    [Arguments]  ${vm_password}
    ${output}=      Run     ps -ef
    Log     ${output}
    ${file_name}=       Generate String With Prefix And Timestamp       screen
    ${output}=      Run     vncdo -p \"${vm_password}\" capture /home/ute/test_results/${file_name}.png
    ${output}=      Run     uptime
    Log     ${output}
    ${output}=      Run     vncdo -p \"${vm_password}\" move 1000 535 click 1 type \"${vm_password}\" key enter
    ${status}=      tty Login Check
    Should Be True      ${status}

get vncdo path
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${vncdo_path}: <description>
    ${output}=      Run     whereis vncdo
    Log     ${output}
    ${output_split}=    Split String         ${output}      ${SPACE}
    ${vncdo_path}=  Set Variable    ${output_split}[1]
    [RETURN]	${vncdo_path}

Get Test PC Password
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${vm_password}: <description>
    ${vm_password}=         Set Variable    ${tl.test_pc.default_ssh_connection_details.password}
    [RETURN]	${vm_password}

tty Login Check
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${staus}: <description>
    ${display}=     Get Display
    ${output}=      Run     who
    Log     ${output}
    ${staus}=   Run Keyword And Return Status   Should Contain      ${output}   (${display})
    [RETURN]	${staus}

Install Swing
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${version}: <description>
    [Arguments]  ${version}=1.0.13
    ${output}=      Run     pip install taf.ul.swing.core==${version}
    Log     ${output}
    ${output}=      Run     pip list
    Log     ${output}
    Should Contain  ${output}   taf.ul.swing.core

Install pyopenssl
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${version}: <description>
    [Arguments]  ${version}=22.0.0
    ${output}=      Run     pip install pyopenssl==${version}
    Log     ${output}
    ${output}=      Run     pip list
    Log     ${output}
    Should Contain  ${output}   pyOpenSSL

Install cryptography
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${version}: <description>
    [Arguments]  ${version}=38.0.4
    ${output}=      Run     pip install cryptography==${version}
    Log     ${output}
    ${output}=      Run     pip list
    Log     ${output}
    Should Contain  ${output}   cryptography

Install service identity
    [Documentation]    Short description.
    ${output}=      Run     pip install service_identity
    Log     ${output}
    ${output}=      Run     pip list
    Log     ${output}
    Should Contain  ${output}   service-identity

Install vncdotool
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${version}: <description>
    [Arguments]  ${version}=0.12.0
    ${output}=      Run     pip install vncdotool==${version}
    Log     ${output}
    ${output}=      Run     vncdo --version
    Log     ${output}
    Should Contain  ${output}   ${version}

TraceViewer Application Is Started
    [Documentation]    Short description.
    Launch TraceViewer    ${netact}[SDV_DESKTOP_ADMIN_USER]    ${netact}[SDV_DESKTOP_ADMIN_PASSWORD]
    ${close_all_dialog_in_teardown}=    Set Variable    ${TRUE}
    Set Suite Variable   ${close_all_dialog_in_teardown}

Suite Teardown For Trace
    [Documentation]    Short description.
    Teardown NetAct
    Close SSH Connection
#    Close Trace Viewer

Common TC Setup For Trace
    [Documentation]    Short description.
    Log Variables
    Create dirs for logs
    Start Infomodel     bts_host=${bts_ip}
    ${active_sw_version}    Infomodel Get Active SW Version    module=MSM    im_param=activeBuildDescriptorId
    ${trunk_build}=     Run Keyword And Return Status   Should Contain      ${active_sw_version}    ENB_9999_
    ${tmp}=    Run Keyword If    ${trunk_build}    Replace String Using Regexp    ${active_sw_version}    \\d+R\\d   00
    ${active_sw_version}=   Set Variable If    ${trunk_build}    ${tmp}      ${active_sw_version}
    Set Suite Variable   ${active_sw_version}
    Log To Console      ${active_sw_version}
    Reset Variables
    ${start_time}=	Get Current DateTime From BTS	${bts_ip}
	Set Test Variable	${start_time}
    Setup connection with admin
    Run keyword and ignore error     taf.sbts.oam.coam.admin.stop_ip_capture_file
	start ip capture file with admin

Delete CTRLTS Object
    [Documentation]    Short description.
    ${parameter}=      Create List
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...     dist_name=MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/CTRLTS-1
    ...     parameter=${parameter}
    ...     operation=delete

Create CTRLTS Object
    [Documentation]    Short description.
    Remove ueTraceInterfaceSelection From CTRLTS
    Log List    ${ctrlts}
    taf.sbts.oam.coam.admin.perform_object_recommissioning
    ...     dist_name=MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/CTRLTS-1
    ...     parameter=${ctrlts}
    ...     operation=create

Remove ueTraceInterfaceSelection From CTRLTS
    [Documentation]    Short description.
#    [Arguments]     @{ctrlts_}
    Log     ${release}
    Return From Keyword If      "${release}">"SBTS23R1"
    ${index}=   Set Variable    0
    FOR     ${par}      IN      @{ctrlts}
        Run Keyword If      "${par}[parameterName]"=="ueTraceInterfaceSelection"
            ...     Remove From List   ${ctrlts}    ${index}
        ${index}=   Evaluate    ${index}+1
    END
    Log     ${ctrlts}
    # [RETURN]    @{ctrlts}

Setup connection with admin
    [Documentation]    Short description.
	taf.sbts.oam.coam.admin.connect to	bts_host=${bts_ip}
	${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
	Log     ${bts_info}
	${ver}=     Set Variable    ${bts_info}[swInfo][swVersion]
	${release}=     Fetch From Left    ${ver}      _
	Set Suite Variable      ${release}

Get Current DateTime From BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bts_ip}: <description>
    ...
    ...    Returns:
    ...        ${output}: <description>
	[Arguments]		${bts_ip}
	SSHLibrary.open connection		${bts_ip}	alias=BTS		timeout=10s
    SSHLibrary.login				toor4nsn		oZPS0POrRieRtu
	SSHLibrary.Switch Connection 	BTS
	Start Command		date "+%Y-%m-%d %H:%M:%S"
	${output}=		Read Command Output
	SSHLibrary.Switch Connection 	DEFAULT
	[RETURN]	${output}

Reset Variables
    [Documentation]    Short description.
    ${trace_reference_list}=    Create List
    Set Test Variable   ${trace_reference_list}
    ${trace_reference}=         Set Variable    -1
    Set Test Variable   ${trace_reference}
    ${vars}=    Get Variables
    Log Dictionary      ${vars}

start ip capture file with admin
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.start_ip_capture_file     measurement_point=NE_Terminated     uplane_capturing=${TRUE}

download ip capture file with admin
    [Documentation]    Short description.
	taf.sbts.oam.coam.admin.stop_ip_capture_file
	taf.sbts.oam.coam.admin.generate_ip_capture_file
	${my_string}=	Generate String With Prefix And Timestamp	${mrbts_id}
	${target_file_name}=    Set Variable    ${Test Results Dir}/${my_string}.pcap.gz
	taf.sbts.oam.coam.admin.download_ip_capture_file  target_file_name=${target_file_name}

Common TC Teardown For Trace
    [Documentation]    Short description.
    download ip capture file with admin
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    Run Keyword If Test Failed		Take Screenshot When Test Failed
    Run Keyword And Ignore Error    Kill Unkonwn Processes
    Run Keyword And Ignore Error    Teardown All Aliases For Infomodel
    Run Keyword And Ignore Error    Update Test Result to QC
    Run Keyword And Ignore Error    Close Trace Analysis
    ${required_ues}=    Create List
    Run Keyword If  ${close_all_dialog_in_teardown}==${TRUE}    Close All Dialogs

Update Test Result to QC
    [Documentation]    Short description.
    Get_QCID
    ${QCID_NUM}  fetch from right  ${QC_ID}  _
    Run Keyword If Test Passed      Send ReP With Scf Id  ${QCID_NUM}  bts_id=10_5_SRAN-MRBTS-${mrbts_id}
    ...     sw=${active_sw_version}  testline_name=10_5_SRAN-MRBTS-${mrbts_id}

Update Display for RemoteSwingLibrary
    [Documentation]    Short description.
    ${display}=  Get Display
    Run Keyword And Ignore Error    Set Environment Variable    DISPLAY  ${display}
#    Log to Console      DISPLAY: ${display}
    ${new_display}=     Run Keyword And Ignore Error   Get Environment Variable    DISPLAY
#    Start Process    sudo Xvfb :0 -ac -screen 0 1680x1050x24    shell=yes

Get Display
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${display}[0]: <description>
    ${output}=  Run     ps -ef | grep vnc|grep display | grep -v grep
    ${display}=     Get Regexp Matches	${output}   -display (:\\d)     1
    [RETURN]    ${display}[0]

Update Environment Variable And Import RemoteSwingLibrary
    [Documentation]    Short description.
    Log Environment Variables
    ${pythonpath}=  Get Environment Variable    PYTHONPATH
    ${remoteswinglibrary_path}      ${remoteswinglibrary_file}=     Get RemoteSwingLibrary Path
    Set Environment Variable    PYTHONPATH  ${remoteswinglibrary_file}:${pythonpath}
    ${output}=		Run	    echo $PYTHONPATH
    Log     ${output}
    ${output}=		Run	    cat ${remoteswinglibrary_path}/RemoteSwingLibrary.py|grep -i remoteswinglibrary
    ${update_not_required}=     Run Keyword And Return Status    Should Match Regexp
    ...     ${output}    remoteswinglibrary-[\\d\\.]+jar
    ${remoteswinglibrary_file_}=    Replace String  ${remoteswinglibrary_file}      /   \\/
    ${cmd}=  Catenate    SEPARATOR=     sed -i 's/AGENT_PATH =/AGENT_PATH = \\"${remoteswinglibrary_file_}
    ...     \\" \#AGENT_PATH =/g' ${remoteswinglibrary_path}/RemoteSwingLibrary.py
#   ${cmd}=     Set Variable    sed -i 's/AGENT_PATH =/AGENT_PATH = \\"${remoteswinglibrary_file_}\\"
#   \#AGENT_PATH =/g' ${remoteswinglibrary_path}/RemoteSwingLibrary.py
    Run Keyword If  ${update_not_required}==${FALSE}    Run	    ${cmd}
#    ${java9_or_newer}=  Java Version Check
    Import Library      RemoteSwingLibrary

Get RemoteSwingLibrary Path
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${remoteswinglibrary_path}: <description>
    ...        ${remoteswinglibrary_file}: <description>
    ${pythonpath}=  Get Environment Variable    PYTHONPATH
    @{paths}=   Split String    ${pythonpath}   :
    ${remoteswinglibrary_path}=     Set Variable    ${EMPTY}
    FOR     ${path}     IN      @{paths}
        ${status}=    Run Keyword And Return Status   Should Contain      ${path}   remoteswinglibrary
        ${remoteswinglibrary_path}=     Set Variable If    ${status}==${TRUE}     ${path}
        Exit For Loop If    ${status}==${TRUE}
    END
    Should Not Be True  '${remoteswinglibrary_path}'=='${EMPTY}'
    OperatingSystem.Directory Should Exist      ${remoteswinglibrary_path}
#    ${output}=		Run	    ls ${remoteswinglibrary_path}/*jar
    ${output}=		Run	    ls ${remoteswinglibrary_path}
    Should Match Regexp    ${output}    remoteswinglibrary-[\\d\\.]+jar
    ${remoteswinglibrary_file}=  Set Variable    ${output}
    [RETURN]    ${remoteswinglibrary_path}  ${remoteswinglibrary_file}

Update Java Agent Path
    [Documentation]    Short description.
    ${cmd}=     Set Variable    sed -i 's/AGENT_PATH =/AGENT_PATH = \\"${remoteswinglibrary_file_}\\"
#    ...\#AGENT_PATH =/g' ${remoteswinglibrary_path}/RemoteSwingLibrary.py

Java Version Check
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${java9_or_newer}: <description>
    ${java_version}=    Run     java -version
    ${matchs}=   Get regexp matches  ${java_version}     java version "\\d+\.(\\d+)     1
    ${ver}=     Convert To Integer      ${matchs}[0]
    ${java9_or_newer}=    Set Variable If     ${ver}<=8     ${FALSE}    ${TRUE}
    [RETURN]   ${java9_or_newer}

Configure Wireshark NTRSTR Protocol
    [Documentation]    Short description.
    ${output}=     Run     cat /home/ute/.config/wireshark/preferences|grep 49151
    ${update_not_required}=     Run Keyword And Return Status   Should Contain  ${output}   49151
    Run Keyword If  ${update_not_required}==${TRUE}     Return From Keyword
    ${output}=     Run     mkdir /home/ute/.config/wireshark
    ${output}=     Run     echo 'ntrstr.port: 20500,20501,49151,49392'>>/home/ute/.config/wireshark/preferences
    ${output}=     Run     cat /home/ute/.config/wireshark/preferences

Trace Target Check
    [Documentation]    Short description.
	${trace_target}=	Set Variable	${TraceConfiguration['TraceTarget']}
	${trace_target}=	Convert To Upper Case	${trace_target}
	${trace_target_split}=	Split String	${trace_target}	/
	Should Contain	${trace_target_split[0]}		MRBTS-
	Should Contain	${trace_target_split[1]}		LNBTS-
	Should Contain	${trace_target_split[2]}		LNCEL-
	${mrbts_distname}=	Set Variable	${trace_target_split}[0]
	${lnbts_fqdn}=	Set Variable	${trace_target_split}[1]
	${lncel_name}=	Set Variable	${trace_target_split}[2]
	${mrbts_id}=	evaluate	"${mrbts_distname}".split('-')[1]
	${lnbts_id}=	evaluate	"${lnbts_fqdn}".split('-')[1]
	${lncel_id}=	evaluate	"${lncel_name}".split('-')[1]
	Set Suite Variable	${mrbts_distname}
	Set Suite Variable	${lnbts_fqdn}
	Set Suite Variable	${lncel_name}
	Set Suite Variable	${mrbts_id}
	Set Suite Variable	${lnbts_id}
	Set Suite Variable	${lncel_id}
	Set suite Variable	${MRBTS_DN}	PLMN-PLMN/MRBTS-${mrbts_id}
	Log		${mrbts_distname} ${lnbts_fqdn} ${lncel_name} ${mrbts_id} ${lnbts_id} ${lncel_id}

Take Screenshot When Test Failed
    [Documentation]    Short description.
	${my_string}=	Generate String With Prefix And Timestamp	screenShot
	Screenshot.Set Screenshot Directory		${Test Results Dir}/
	Take Screenshot		${my_string}.jpg

Generate String With Prefix And Timestamp
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${prefix}: <description>
    ...
    ...    Returns:
    ...        ${myString}: <description>
	[Arguments]    ${prefix}
	${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}${month}${day}${hour}${min}
	${myString}=	Generate Random String		4		[LOWER]
	${myString}=	catenate	SEPARATOR=_		${prefix}		${timestamp}	${myString}
	[RETURN]	${myString}

Close Trace Viewer
    [Documentation]    Short description.
    Close Window	regexp=^TraceViewer.*
    Select Dialog	regexp=^.*Confirm.*
    Click On Component	Yes

New Cell Trace Activation Is Started
    [Documentation]    Short description.
    wait until keyword succeeds    60s    15s    Activate Cell Trace

New Cell Trace Activation Window Is Opened
    [Documentation]    Short description.
    wait until keyword succeeds    6m    30s    Open New Cell Trace Window

Trace Is Activated successfully
    [Documentation]    Short description.
    Sleep   10s
	Latest Operation Should be Successful
    wait until keyword succeeds		60s		2s    Trace Is Activating
    ${cmd}=  Catenate    SEPARATOR=${SPACE}
    ...     SELECT TRACE_REFERENCE FROM (SELECT * FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE
    ...     '%${lnbts_id}%' ORDER BY START_TIME DESC) WHERE ROWNUM=1
	${trace_reference}=		Run Sql Statement    ${cmd}
    ${trace_reference}=    Strip String    ${trace_reference}
	Set Test Variable	${trace_reference}
	Log To Console  Trace reference: ${trace_reference}
	wait until keyword succeeds		180s	15s    Trace Is Active
	log to console    Trace Is activated

Trace Is Active
    [Documentation]    Short description.
	${trace_state}		Run Sql Statement
	...     SELECT STATE FROM TRC.COR_TRACE_HEADER WHERE TRACE_REFERENCE=${trace_reference}
	Should Be Equal		${trace_state}		ACTIVE

Trace Is Activating
    [Documentation]    Short description.
	${trace_after}=    Run Sql Statement
	...     SELECT count(*) FROM TRC.COR_TRACE_HEADER WHERE TRACE_TARGET LIKE '%${lnbts_id}%'
	Should Be True		${trace_after}-${trace_before}>=1
	log to console    Trace Is activating
