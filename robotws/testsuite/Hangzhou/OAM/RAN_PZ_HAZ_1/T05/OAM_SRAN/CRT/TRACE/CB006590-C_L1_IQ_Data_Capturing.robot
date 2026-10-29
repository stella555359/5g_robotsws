*** Settings ***
Documentation     [PURPOSE]
#Force Tags   CB006590      trunk   branch   CDRT
#Library      taf.sbts.oam.coam.admin	WITH NAME	admin
Library      Collections
Library      OperatingSystem
Library      String
#Library      taf.internal.node


*** Variables ***
${module_dn}
	#MRBTS-22262/EQM-1/APEQM-1/CABINET-1/BBMOD-3
${nr_cell_dn}
#=  MRBTS-22262/NRBTS-10774/NRCELL-1
${subcell_id}
#=  4
${lte_cell_id}
${dl_nr_subcell_list}
${ul_nr_subcell_list}
#${USERNAME}     Nemuadmin
#${PASSWORD}=    nemuuser
${bts_ip}=    10.97.97.135
#${bts_ip}=    10.97.91.52
#${bts_ip}=    10.68.195.138
${PORT}=    443
${mrbts_id}
${outdoor}=     ${FALSE}
${nodejs_path}      node
${technology}
${ss}


*** Keywords ***
L1 IQ data capture commands with WebEM Remote Tool
    [Documentation]    Short description.
	Step 1: L1 IQ data capture Pre-condition
	Step 2: Configure Uplane L1 IQ Data     ${technology}
	Step 3: Collect UPlane L1 IQ Data
#	Step 4: Post Check For L1 IQ Data

Step 1: L1 IQ data capture Pre-condition
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.connect to	bts_host=${bts_ip}
	Enable Internal Trace
	SMOD Check For L1 IQ Data
	Get Bundle path
	Get Nodejs path
	#${cell_dn}   ${subcell_id}=      Get Cell DN And subcellId With Cell Id     ${cell_list}[-1]    technology=LTE
	${cell_list}   ${bbmod_id}=  Get Cell List Host By a BBPOOL     5G
	Run Keyword If  ${cell_list}==[]    Run Keywords    Get Module DN for LTE   AND Return From Keyword

	${module_dn}=    Get BBMOD DN With Id    ${bbmod_id}
	${cell_dn}   ${subcell_id}=      Get Cell DN And subcellId With Cell Id     ${cell_list}[-1]
	${matchs}=    Get Regexp Matches  ${cell_dn}   MRBTS-(\\d+)    1
	${mrbts_id}=    Set Variable    ${matchs}[0]
	Set Test Variable   ${module_dn}
	Set Test Variable   ${subcell_id}
	Set Test Variable   ${mrbts_id}
	Set Test Variable   ${cell_dn}
	${nr_cell_dn}=      Set Variable      ${cell_dn}
	Set Test Variable   ${nr_cell_dn}
	${technology}=  Set Variable    NR
    Set Test Variable   ${technology}

Get Module DN for LTE
    [Documentation]    Short description.
    Log To Console  NR not configured. Try with LTE.
	${cell_list}   ${bbmod_id}=  Get Cell List Host By a BBPOOL     LTE
	${module_dn}=    Get BBMOD DN With Id    ${bbmod_id}
	Set Test Variable   ${module_dn}
	${lte_cell_id}=    Set Variable    ${cell_list}[-1]
    Set Test Variable   ${lte_cell_id}
    ${technology}=  Set Variable    LTE
    Set Test Variable   ${technology}

Enable Internal Trace
    [Documentation]    Short description.
    Log     Enable internal trace.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     TRBLCADM_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    $${dist_name}   MRBTS_A-(\\d+)/MNL_A-(\\d+)/MNLENT_A-(\\d+)/TRBLCADM_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   actInternalTrace   update  true

SMOD Check For L1 IQ Data
    [Documentation]    Short description.
    ${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    ${smods}=   Set Variable    ${bts_info}[systemModules]
    FOR     ${smod}     IN  @{smods}
        ${outdoor}=     Run Keyword And Return Status   Should Match Regexp  ${smod}[productName]    ASO|FSMF
        Set Test Variable   ${outdoor}
        Run Keyword If      ${outdoor}==${TRUE}     Log To Console      Outdoor module.
    END

Get Cell DN And subcellId With Cell Id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cell_id}: <description>
    ...        ${technology}: <description>
    ...
    ...    Returns:
    ...        ${cell_dn}: <description>
    ...        ${subcell_id}: <description>
    [Arguments]     ${cell_id}   ${technology}=5G
    log     ${cell_id}
    ${cell_class}=  Set Variable If     '${technology}'=='5G' or '${technology}'=='NR'   NRCELL
    ...     '${technology}'=='LTE'  LNCEL
    ${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    ${cell_dn}=   Set Variable    ${EMPTY}
    ${subcell_id}=   Set Variable    ${EMPTY}
    ${cells}=    Set Variable If     '${technology}'=='5G' or '${technology}'=='NR'       ${bts_info}[cells][nr]
    ...     '${technology}'=='LTE'   ${bts_info}[cells][lte]
    FOR     ${cell}  IN  @{cells}
        ${matchs}=     Get Regexp Matches     ${cell}[id][configuration]     ${cell_class}-(\\d+)   1
        Continue For Loop If    ${matchs}==[]
        ${t_cell_id}=     Set Variable    ${matchs}[0]
        Log     ${t_cell_id}, ${cell_id}
        Run Keyword If  '${t_cell_id}'=='${cell_id}'    Exit For Loop If    '${technology}'=='LTE'
        ${subcell_id}   ${cell_dn}=  Run Keyword If  '${t_cell_id}'=='${cell_id}'
        ...     Get Subcell id From data  ${cell_dn}  ${technology}   ${cell}
        Run Keyword If   '${t_cell_id}'=='${cell_id}'    Exit For Loop
    END
    ${result}=     Run keyword And Return Status       Should Not Be Empty     ${cell_dn}
    Run Keyword If  ${result}==${FALSE}
    ...     Log To Console      Unable to get NR Cell DN!
    Should Be True  ${result}==${TRUE}
    [RETURN]    ${cell_dn}   ${subcell_id}

Get Subcell id From data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${cell_dn}: <description>
    ...        ${technology}: <description>
    ...        ${cell}: <description>
    ...
    ...    Returns:
    ...        ${subcell_id}: <description>
    ...        ${cell_dn}: <description>
    [Arguments]     ${cell_dn}  ${technology}   ${cell}
	${cell_dn}=   Set Variable    ${cell}[id][configuration]
	${matchs}=      Get Regexp Matches     ${cell}[subCellList][0]     Subcell-(\\d)   1
	${subcell_id}=     Set Variable    ${matchs}[0]
	Set test variable   ${subcell_id}
	[RETURN]    ${subcell_id}   ${cell_dn}

Get Cell List Host By a BBPOOL
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${technology}: <description>
    ...
    ...    Returns:
    ...        ${cell_list}: <description>
    ...        ${bbmod_id}: <description>
    [Arguments]     ${technology}=5G
    ${pools}=   Create List
    ${bbmod_id}=    Set Variable
    ${bbpools}=		taf.sbts.oam.coam.admin.get_managed_objects		BBPOOL_R
    should not be empty     ${bbpools}
    @{cell_list}=  Create List
    ${bbmod_runtime_id}=   Set Variable    ${EMPTY}
    FOR     ${bbpool}   IN  @{bbpools}
        Log     ${technology}, ${bbpool}[parameters][bbPoolTech]
        ${is_match}=    Run Keyword And Return Status   Should Be True
        ...     '${bbpool}[parameters][bbPoolTech]'=='${technology}'
        Continue For Loop If    ${is_match}==${FALSE}
        ${cell_list}    ${bbmod_id}       Get pools and cell list with bbpool   ${bbpool}      ${pools}   ${cell_list}
        ${status}=    Run Keyword And Return status    should not be empty    ${cell_list}
        Exit For Loop If    ${status}
    END

    ${result}=     Run keyword And Return Status       Should Not Be Empty     ${cell_list}
    Run Keyword If  ${result}==${FALSE}
    ...     Log To Console  No NR Cell Found!
    Should Be True  ${result}==${TRUE}
    Log List    ${pools}
    #Should Not Be Empty  ${cell_list}
    [RETURN]    ${cell_list}  ${bbmod_id}

Get pools and cell list with bbpool
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bbpool}: <description>
    ...        ${pools}: <description>
    ...        ${cell_list}: <description>
    ...
    ...    Returns:
    ...        ${cell_list}: <description>
    ...        ${bbmod_id}: <description>
    [Arguments]     ${bbpool}   ${pools}    ${cell_list}
	${cell_list}=    Set Variable     ${bbpool}[parameters][bbPoolCellsList]
	${bbPowerGroup}=    Set Variable     ${bbpool}[parameters][bbPwrGroupDNList][0]
	${bbmod_runtime_ids}=          Get Regexp Matches     ${bbPowerGroup}     MOD_R-(\\d)   1
	${bbmod_runtime_id}=   Set Variable    ${bbmod_runtime_ids}[0]
	${bbmod_id}=    Get BBMOD Configuration Id With Runtime Id  ${bbmod_runtime_id}
	&{pool}=    Create Dictionary   cell list   ${cell_list}    bbmod id    ${bbmod_id}
	append to list    ${pools}    ${pool}
	[RETURN]    ${cell_list}    ${bbmod_id}

Get BBMOD Configuration Id With Runtime Id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bbmod_runtime_id}: <description>
    ...
    ...    Returns:
    ...        ${bbmod_id}: <description>
    [Arguments]     ${bbmod_runtime_id}
    ${bbmod_id}=    Set Variable    ${EMPTY}
    ${bbmod_type}=  Set Variable If     ${outdoor}==${TRUE}     SMOD  ${outdoor}==${FALSE}    BBMOD
    ${bbmods}=		taf.sbts.oam.coam.admin.get_managed_objects		${bbmod_type}_R
    FOR     ${bbmod}   IN  @{bbmods}
        Log     ${bbmod}
        ${match}=   Run Keyword And Return Status   Should Contain  ${bbmod}[distName]
        ...     ${bbmod_type}_R-${bbmod_runtime_id}
        ${bbmod_ids}=   Run Keyword If  ${match}==${TRUE}  Get Regexp Matches      ${bbmod}[parameters][configDN]
        ...      ${bbmod_type}_A-(\\d+)  1
        ${bbmod_id}=    Set Variable If   ${match}==${TRUE}     ${bbmod_ids}[0]
        Run Keyword If  ${match}==${TRUE}   Exit For Loop
#        IF      ${match}==${TRUE}
#            ${bbmod_ids}=    Get Regexp Matches      ${bbmod}[parameters][configDN]      ${bbmod_type}_A-(\\d+)  1
#            ${bbmod_id}=    Set Variable    ${bbmod_ids}[0]
#            Exit For Loop
#        END
    END

    ${result}=     Run keyword And Return Status       Should Not Be Empty      ${bbmod_id}
    Run Keyword If  ${result}==${FALSE}
    ...     Log To Console  Unable to get BBMOD ID!
    Should Be True  ${result}==${TRUE}
    [RETURN]    ${bbmod_id}

Get BBMOD DN With Id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${bbmod_id}: <description>
    ...
    ...    Returns:
    ...        ${bbmod_dn}: <description>
    [Arguments]     ${bbmod_id}
    Log     ${bbmod_id}
    ${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    ${bbmod_dn}=    Set Variable    ${EMPTY}

    @{bbmods}=      Set Variable If     ${outdoor}==${FALSE}    ${bts_info}[basebandModules]    ${outdoor}==${TRUE}
    ...     ${bts_info}[systemModules]
    Log List    ${bbmods}
    FOR     ${bbmod}    IN  @{bbmods}
        Log     ${bbmod}
        ${bbmod_dn}=    Set Variable    ${bbmod}[id][configuration]
        ${matchs}=   Get Regexp Matches      ${bbmod_dn}    MOD-(\\d+)    1
        ${t_bbmod_id}=   Set Variable    ${matchs}[0]
        Log     ${t_bbmod_id}, ${bbmod_id}
        ${bbmod_dn}=    Set Variable If  '${t_bbmod_id}'=='${bbmod_id}'  ${bbmod}[id][configuration]
        Run Keyword If  '${t_bbmod_id}'=='${bbmod_id}'  Exit For Loop
#        IF      '${t_bbmod_id}'=='${bbmod_id}'
#            ${bbmod_dn}=    Set Variable    ${bbmod}[id][configuration]
#            Exit For Loop
#        END
    END
    ${result}=     Run keyword And Return Status       Should Not Be Empty      ${bbmod_dn}
    Run Keyword If  ${result}==${FALSE}
    ...     Log To Console  Unable to get BBMOD DN!
    Should Be True  ${result}==${TRUE}
    [RETURN]    ${bbmod_dn}

Get Subcell Id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nr_cell_id}: <description>
    [Arguments]     ${nr_cell_id}
    Log     Get Subcell Id from BTS info
    ${result}= 			taf.sbts.oam.coam.admin.get_bts_info
	Log		${result}[cells][nr]

Get Bundle path
    [Documentation]    Short description.
    ${dir}=		Run
    ...     python -c "import taf.internal.sbts.admin.cli as cli;import os;print(os.path.dirname(cli.__file__))"
	${bundle_path}=		Run		python -c 'import os;print(os.path.join("${dir}", "resource","bin", "main.bundle.js"))'
	OperatingSystem.File Should Exist   ${bundle_path}
	Set Test Variable      ${bundle_path}

Get Nodejs path
    [Documentation]    Short description.
    Set Test Variable   ${nodejs_path}      node
    Return From Keyword

    ${cmd}=     Catenate    SEPARATOR=${EMPTY}
    ...     "
    ...     import os;import inspect;import taf.internal.node;
    ...     print(os.path.dirname(inspect.getfile(taf.internal.node)))
    ...     "
    ${dir}=		Run     python -c ${cmd}
    ${nodejs_path}=      Run
    ...		python -c 'import os;print(os.path.join("${dir}", "resources","linux","bin", "node"))'
    OperatingSystem.File Should Exist   ${nodejs_path}
    Set Test Variable   ${nodejs_path}

Step 2: Configure Uplane L1 IQ Data
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${technology}: <description>
    [Arguments]     ${technology}=NR
    ${temp}=    Catenate
    ...     "dlNrSubcellList":[{"nrcellDN":"${nr_cell_dn}","subcellId":${subcell_id}}],
    ...     "ulNrSubcellList":[{"nrcellDN":"${nr_cell_dn}","subcellId":${subcell_id}}]
    ${target}=  Set Variable If
    ...     '${technology}'=='NR' or '${technology}'=='5G'
    ...     ${temp}
    ...     '${technology}'=='LTE'       "dlLteCellList":[${lte_cell_id}],"ulLteCellList":[${lte_cell_id}]

    ${DATA}=    Catenate
    ...     '{"requestId":1,"parameters":{"name":"configureUPlaneL1IQData","parameters":
    ...     {"moduleDN":"${module_dn}",${target},"captureOnEvent":true}}}'

    #${DATA}=    Set Variable    '{"requestId":1,"parameters":{"name":"configureUPlaneL1IQData","parameters":
    #{"moduleDN":"${module_dn}","l":[{"nrcellDN":"${nr_cell_dn}","subcellId":${subcell_id}}],"captureOnEvent":true}}}'

    Log     ${DATA}
    ${cmd}=     Catenate    SEPARATOR=${SPACE}
    ...     '${nodejs_path} --expose_gc --no-warnings ${bundle_path}
    ...     --bts-username=${USERNAME} --bts-password=${PASSWORD}
    ...     --bts-host=${bts_ip} --bts-port=${PORT} --data=${DATA} --format="human"'
	Log     ${cmd}
	${output}=  Run     '${cmd}'
	Log     ${output}
	Should Contain  ${output}   "requestMessage": "Succeeded"
	Operation Should Be Successful      Configure UPlane L1 IQ data

Step 3: Collect UPlane L1 IQ Data
    [Documentation]    Short description.
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${output_file}=   Set Variable    L1IQData_MRBTS-${mrbts_id}_${timestamp}.tgz
    ${DATA}=    Catenate
    ...     '{"requestId":1,"parameters":{"name":"collectUPlaneL1IQData",
    ...     "parameters":{"moduleDN":"${module_dn}","sfn":65535,"slot":0,"captureMode":"ScheduleSynchronousStopOfOngoingContinuousCapture"}}}'

    Log     ${DATA}
    ${cmd}=     Catenate    SEPARATOR=${SPACE}
    ...     '${nodejs_path} --expose_gc --no-warnings ${bundle_path}
    ...     --bts-username=${USERNAME} --bts-password=${PASSWORD} --bts-host=${bts_ip} --bts-port=${PORT}
    ...     --data=${DATA} --format="human" --output-file=${output_file}'
	Log     ${cmd}
	${output}=  Run     '${cmd}'
	Log     ${output}
	Should Contain  ${output}   "requestMessage": "Succeeded"
	Operation Should Be Successful      Collect UPlane L1 IQ data

Operation Should Be Successful
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${operation}: <description>
    [Arguments]     ${operation}
    ${operations_history_file}=  Set Variable    operationHistoryFiles.txt
    ${DATA}=    Set Variable    '{"requestId":1,"requestType":"infoModel","parameters":{"name":"getOperationHistory"}}'
    Log     ${DATA}
    ${cmd}=     Catenate    SEPARATOR=${SPACE}
    ...     '${nodejs_path} --expose_gc --no-warnings ${bundle_path}
    ...     --bts-username=${USERNAME} --bts-password=${PASSWORD} --bts-host=${bts_ip} --bts-port=${PORT}
    ...     --data=${DATA} --format="human" --output-file=${operations_history_file}'
	Log     ${cmd}
	${output}=  Run     '${cmd}'
	Log     ${output}
	${cmd}=     Set Variable    'cat ${operations_history_file} | grep "${operation}" | head -1'
	Log     ${cmd}
	${output}=  Run     '${cmd}'
	Should Contain  ${output}   Succeeded

Step 4: Post Check For L1 IQ Data
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
