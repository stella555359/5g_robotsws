*** Settings ***
Documentation    Author: liangliang.heng@nokia-sbell.com
Library         taf.transport.ssh   WITH NAME   csn
Variables       ../../libraries/nms_vars.py
Variables   ../libraries/var.py
Resource        ../../common/taf_coam.robot
Library         String
Library         OperatingSystem
Library         Collections
Library         XML   use_|xml|=True
Library         DateTime

*** Variables ***
# Parameters name translation in order to get them from __init__.py
${netact_nodeip}            10.108.248.82
${NetAct_info}
${NA_USER}
${NA_PASS}
${BTSID}                    MRBTS-${tl.gnbs[0].instance_id}
${INSID}                    ${BTSID}/NRBTS-${tl.gnbs[0].global_bts_id}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${NA_EXPORT_DIR}=           /var/opt/oss/global/racops/export
${NA_IMPORT_DIR}=           /var/opt/oss/global/racops/import
${LOCAL_TMP_DIR}=           /tmp
${VALIDATION}=              True
${upload_backup_dir}=       /var/opt/nokia/oss/global/sct/backup_sites/mrbts

*** Keywords ***
Connect to NetAct WasNode and execute command
    [Arguments]   ${wasNode_IP}   ${omc_uername}   ${omc_passowrd}   ${command}   ${expect_output}=default
    ${connect_NetAct}=  csn.connect_to    ${wasNode_IP}
    ...   ${omc_uername}    ${omc_passowrd}    alias=WasNode   timeout=60
    ${output}=   csn.execute   command=${command}   connection=WasNode   timeout=300
    run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
    [Return]  ${output}
    [Teardown]  run keyword and ignore error  csn.disconnect    connection=${connect_NetAct}

CM Upload in Backend
    ${DN}=    set variable    PLMN-PLMN/${BTSID}
    ${upload_command}=   set variable  racclimx.sh -v -op Upload -DN ${DN}
    ${expect_output}=    set variable   The operation was successfully completed.:Upload is Successful
    Connect to NetAct WasNode and execute command   wasNode_IP=${netact_nodeip}   omc_uername=${NA_USER}   omc_passowrd=${NA_PASS}
    ...   command=${upload_command}   expect_output=${expect_output}

Check actPCMDReport flag
    [Arguments]              ${status}
    ${value}=                NA Get Param Value   ${INSID}   actPCMDReport
    Log to console           actPCMDReport value is ${value}
    ${result}=               should be equal      ${value}      ${status}
    run keyword if           '${value}' == '${status}'    Log to console   Checking actPCMDReport value is ${value}
    Return from keyword      ${value}

Change actPCMDReport
    [Arguments]              ${status}
    Log to console           \*** Changing actPCMDReport to ${status}
    ${value}=                NA Set Param Value   ${INSID}    actPCMDReport    ${status}
    Log to console            Checking actPCMDReport final value
    ${value}=                NA Get Param Value   ${INSID}     actPCMDReport
    Log to console           Final value of actPCMDReport = ${value}
    should be equal          ${value}    ${status}

Start To Capture Wireshark between ASIK and CA4MN on ASIK
    [Arguments]         ${filename}    ${CA4MN_IP}=${dcap_server_ip}
    csn.connect to    hostname=${OAM_IP}     username=${asik_username}     password=${asik_password}    alias=gNB
    sleep    3s
    ${SMOD_name}   Get SMOD Product Name
    log to console   SMOD_name=${SMOD_name}
    Run Keyword If     '${SMOD_name}'=='ASIB'
    ...   csn.send_command  command=tcpdump -i br1 -n src ${OAM_IP} and dst host ${CA4MN_IP} -w ${remote_path}/${filename}   connection=gNB
    ...   ELSE IF  '${SMOD_name}'=='ASIK'
    ...   csn.send_command  command=tcpdump -i fp0 -n src ${OAM_IP} and dst host ${CA4MN_IP} -w ${remote_path}/${filename}   connection=gNB
    ...   ELSE   csn.send_command  command=tcpdump -i br0 -n src ${OAM_IP} and dst host ${CA4MN_IP} -w ${remote_path}/${filename}   connection=gNB
    sleep    5
    log to console      ${filename} file is created under ${remote_path}

Configure PCMD Parameters
    ${list_params}=         Prepare list of modifications for Netact plan
    Log to console          Uploading NetAct with initial configuration of ${BTSID}
    NA CM Upload BTS        ${BTSID}
    Log to console          Preparing and provisioning NetAct plan on ${BTSID}
    NA Add Parameters       ${BTSID}     ${list_params}

Prepare list of modifications for Netact plan
    Log to console         Prepare list of modifications
#    ${list_line1}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tceIpAddress            10.101.60.41
    ${list_line1}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tceIpAddress            10.57.195.82
    ${list_line2}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tcePortNumber           49148
    ${list_line3}=         create list   PLMN-PLMN/${BTSID}/MNL-1/TCEADM-1/TCE-1        None   None   tceIdentifier             1
    ${list_line4}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   actCellTraceReportingCU   false
    ${list_line5}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   actPCMDReporting          true
    ${list_line6}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   cellMaxActiveUEsTraced    100
    ${list_line7}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   jobType                   TraceOnly
    ${list_line8}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   nrMtraceCuId              1
    ${list_line9}=         create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mcc           450
    ${list_line10}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mnc           5
    ${list_line11}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   mncLength     2
    ${list_line12}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   nrRanTraceReference   1   traceId       94
    ${list_line13}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   nrTceIdentifier           1
    ${list_line14}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   scope                     allResources
    ${list_line15}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceNGAPSetting          none
    ${list_line16}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceNRRRCSetting         none
    ${list_line17}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceX2Setting            none
    ${list_line18}=        create list   PLMN-PLMN/${INSID}/NRCTRLTS-1/NRMTRACECU-1   None   None   traceXNSetting            none
    ${list_line19}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   actPCMDReporting          true
    ${list_line20}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   cellMaxActiveUEsTraced    100
    ${list_line21}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   jobType                   TraceOnly
    ${list_line22}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   nrMtraceDuId              1
    ${list_line23}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mcc           450
    ${list_line24}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mnc           5
    ${list_line25}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   mncLength     2
    ${list_line26}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   nrRanTraceReference   1   traceId       94
    ${list_line27}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   nrTceIdentifier       1
    ${list_line28}=        create list   PLMN-PLMN/${INSID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1   None   None   scope           allResources
    ${list_params}=        create list   ${list_line1}    ${list_line2}   ${list_line3}   ${list_line4}    ${list_line5}    ${list_line6}
     ...                                  ${list_line7}    ${list_line8}   ${list_line9}   ${list_line10}   ${list_line11}   ${list_line12}
    ...                                  ${list_line13}   ${list_line14}   ${list_line15}   ${list_line16}   ${list_line17}   ${list_line18}
    ...                                  ${list_line19}   ${list_line20}   ${list_line21}   ${list_line22}   ${list_line23}   ${list_line24}
     ...                                  ${list_line25}   ${list_line26}   ${list_line27}   ${list_line28}
    Return from Keyword    ${list_params}

NA Get Param Value
    [Timeout]           5 minutes
    [Arguments]         ${dist_name}   ${PARAMETER}
        ${exported_file}=       set variable    export_for_get.xml
        CM Export
        ...                     ${dist_name}
        ...                     ${LOCAL_TMP_DIR}
        ...                     ${exported_file}
        ...                     ALL_MOCS
        ...                     true
        ${value}=               Get Element Text
        ...                     ${LOCAL_TMP_DIR}/${exported_file}
        ...                     //managedObject[@distName="PLMN-PLMN/${dist_name}"]/p[@name="${PARAMETER}"]
    [Return]            ${value}

Compute TimeStamp
        ${date} =   DateTime.Get Current Date    exclude_millis=True
        ${date} =   Replace String      ${date}         ${SPACE}    _
        ${date} =   Replace String      ${date}         -           ${EMPTY}
        ${date} =   Replace String      ${date}         :           ${EMPTY}
        [return]  ${date}

NA Set Param Value
    [Timeout]           10 minutes
    [Arguments]         ${dist_name}   ${PARAMETER}    ${VALUE}     ${check_error}=True

        ${timestamp} =   Compute TimeStamp
        ${old_plan_file}=           Set Variable    exported_${timestamp}.xml
        ${new_plan_file}=           Set Variable    modified_${timestamp}.xml
        ${changed_plan_name}=       Set Variable    robot_set_${timestamp}
        ${delta_plan_name}=         Set Variable    robot_delta_${timestamp}
        Log to console              Netact plan creation : ${delta_plan_name}

        ${element_xpath}=  Set Variable
        ...  //managedObject[@distName="PLMN-PLMN/${dist_name}"]/p[@name="${PARAMETER}"]

        CM Export    ${dist_name}  ${LOCAL_TMP_DIR}  ${old_plan_file}    ALL_MOCS    true
        Set Current Element Value
                            ...     PLAN_FILE=${LOCAL_TMP_DIR}/${old_plan_file}
                            ...     NEW_PLAN_FILE=${LOCAL_TMP_DIR}/${new_plan_file}
                            ...     ELEMENT_XPATH=${element_xpath}
                            ...     NEW_VALUE=${VALUE}
        CM Import               ${LOCAL_TMP_DIR}  ${new_plan_file}  ${changed_plan_name}  UIValues=true   USE_OBJECT_OPERATION=false
        Prepare Delta Plan      ${changed_plan_name}    ${delta_plan_name}
        ${stdout_provision}=    Provision Plan          ${delta_plan_name}      check_error=${check_error}
        Remove Plan             ${delta_plan_name}

        [Return]     ${stdout_provision}

NA Add Parameters
    [Timeout]           10 minutes
    [Arguments]         ${bts_dist_name}   ${list_parameters}      ${check_error}=True

        ${timestamp} =   Compute TimeStamp
        ${old_plan_file}=           Set Variable    exported_${timestamp}.xml
        ${new_plan_file}=           Set Variable    modified_${timestamp}.xml
        ${changed_plan_name}=       Set Variable    robot_set_${timestamp}
        ${delta_plan_name}=         Set Variable    robot_delta_${timestamp}
        # ${backup_plan_name}=        Set Variable    robot_backup_${timestamp}

        CM Export    ${bts_dist_name}  ${LOCAL_TMP_DIR}  ${old_plan_file}    ALL_MOCS    true
        Add Parameters
			    ...	    ${list_parameters}
                            ...     ${LOCAL_TMP_DIR}/${old_plan_file}
                            ...     ${LOCAL_TMP_DIR}/${new_plan_file}
        CM Import               ${LOCAL_TMP_DIR}  ${new_plan_file}  ${changed_plan_name}  UIValues=true   USE_OBJECT_OPERATION=false
        Log to console          ${changed_plan_name} imported
        Prepare Delta Plan      ${changed_plan_name}    ${delta_plan_name}
        Log to console          ${delta_plan_name} delta plan to provision
        ${stdout_provision}=    Provision Plan          ${delta_plan_name}      check_error=${check_error}
        # ...                     create_backup_plan=true        backup_plan_name=${backup_plan_name}
        # Remove Plan             ${delta_plan_name}

        [Return]

NA CM Upload BTS
    [Timeout]           15 minutes
    [Arguments]         ${bts_dist_name}

                        ${bts_id}=  Fetch From Right    ${bts_dist_name}    -
                        csn.connect_to    hostname=${netact_nodeip}
                        ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
                        ${touch_cmd}=       set variable         touch /tmp/empty_file
                        csn.execute   command=${touch_cmd}     connection=WasNode
                        ${upload_cmd}=    set variable    racclimx.sh -op Upload -DN PLMN-PLMN/${bts_dist_name} -v
                        csn.execute    command=${upload_cmd}    connection=WasNode
                        #run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
                        ${find_cmd}=   set variable   find /d/oss/global/var/cmmne3s/work -type f -name "MRBTS*" -newer /tmp/empty_file
                        ${output}=   csn.execute   command=${find_cmd}   connection=WasNode   timeout=300
                        should match regexp     ${output}       MRBTS${bts_id}_[0-9]+_UL.xml.gz
                        run keyword and ignore error  csn.disconnect    connection=WasNode

CM Export    # MF
    [Documentation]     Run Export Actual Configuration in NetAct for specified dist_name and save actual configuration to OUTPUT_FILE
                ...         - ${dist_name} - distinguish name of managed object to be exported (without PLMN)
                ...         - ${LOCAL_DIR}
                ...         - ${OUTPUT_FILE}
                ...         - ${CLASS_FILTER} - A comma separated string of MOCs to be exported, e.g. LNBTS,LNCEL. By default all MOCs are exported.
                ...         - ${UI_VALUES} - false (by default) or true

    [Timeout]           15 minutes
    [Arguments]         ${dist_name}    ${LOCAL_DIR}    ${OUTPUT_FILE}    ${CLASS_FILTER}=ALL_MOCS    ${UI_VALUES}=false
                        ${EXPORTED_FILE}=    SetVariable    CRT_ROBOT.xml

                        ${cmd}=    Set Variable    racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation actualExport
                        ${cmd}=    Set Variable    ${cmd} -DN PLMN-PLMN/${dist_name} -fileName ${EXPORTED_FILE} -UIValues ${UI_VALUES} -v
                        ${cmd}=    Set Variable If    '${CLASS_FILTER}'!='ALL_MOCS'   ${cmd} -classFilter ${CLASS_FILTER}   ${cmd}
                        ${expect_output}=    set variable       Status received: Finished
                        csn.connect_to    hostname=${netact_nodeip}
                        ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
                        ${output}=   csn.execute   command=${cmd}   connection=WasNode   timeout=300
                        run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
                        # Should Contain    ${stdout}    Export finished
                        # Log to Console       *** Status CM Export = ${stdout}
                        ${Status}=    Run Keyword And Return Status
                                        ...    csn.Download File
                                        ...    remote_path=${NA_EXPORT_DIR}/${EXPORTED_FILE}
                                        ...    local_path=${LOCAL_DIR}/${OUTPUT_FILE}
                                        ...    connection=WasNode
                        ${remove_file_cmd}=    Set Variable    rm -f ${NA_EXPORT_DIR}/${EXPORTED_FILE}
                        ${output}=   csn.execute   command=${remove_file_cmd}   connection=WasNode   timeout=300
                        Run Keyword If  ${Status}==False  Fail  Cannot get plan file
                        ${Status}=  Run Keyword And Return Status
                                               ...  OperatingSystem.File Should Not Be Empty  ${LOCAL_DIR}/${OUTPUT_FILE}
                        run keyword and ignore error  csn.disconnect    connection=WasNode
                        Run Keyword If  ${Status}==False  Fail  Local plan file is empty
                        ${content}=   Grep File    ${LOCAL_DIR}/${OUTPUT_FILE}    <p name=
                        ${size}=     Get Length    ${content}
                        Run Keyword If    ${size}==0    Fail  Exported file has no param inside

CM Import
    [Documentation]     Import plan given as ${INPUT_FILE} located in ${LOCAL_DIR} as Netact plan name=${PLAN_NAME}
   ...      NA CLI Command: ``racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation planImport
   ...      -fileName ${INPUT_FILE} -planName ${PLAN_NAME} -UIValues ${UIValues} -v -useObjectOperationDefinedInImportFile true ``
   ...          - ${LOCAL_DIR} - directory where plan file is stored on local mashine
   ...          - ${INPUT_FILE} - plan file
   ...          - ${PLAN_NAME} - name of newly created plan in Netact
   ...          - ${UIValues} :
   ...                           - true  - UI Values are used in plan file
   ...                           - false - internal values are used in plan file
   ...                           - (default value = false)
   ...          - ${USE_OBJECT_OPERATION} :
   ...                           - true  - Object operation taken from plan
   ...                           - false - Object operation taken care by NetAct
   ...                           - (default value = true)
   ...          - ${skip_existing}:
   ...                           - True  - Existing objects are not overwritten in import
   ...                           - False - Existing objects are overwritten in import
   ...                           - (default value = False)
   ...      Returns as string standard output (stdout) from operation's execution.
   ...      Timeout for this keyword is set to 5 minutes.
    [Timeout]           15 minutes
    [Arguments]     ${LOCAL_DIR}    ${INPUT_FILE}    ${PLAN_NAME}    ${UIValues}=false    ${USE_OBJECT_OPERATION}=true    ${skip_existing}=False
    csn.connect_to    hostname=${netact_nodeip}
        ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
#     SSHLibrary.Switch Connection  ${NA_CONNECTION}
#     Remove Plan     ${PLAN_NAME}
    csn.Upload File   local_path=${LOCAL_DIR}/${INPUT_FILE}   remote_path=${NA_IMPORT_DIR}/${INPUT_FILE}  connection=WasNode
#    SSHLibrary.Put File    ${LOCAL_DIR}/${INPUT_FILE}    ${NA_IMPORT_DIR}/${INPUT_FILE}
    csn.File Exists    remote_path=${NA_IMPORT_DIR}/${INPUT_FILE}     connection=WasNode
#    SSHLibrary.File Should Exist    ${NA_IMPORT_DIR}/${INPUT_FILE}
    ${cmd}=    Set Variable    racclimx.sh -op Import_Export -fileFormat RAML2 -importExportOperation planImport
    ${cmd}=    Set Variable    ${cmd} -fileName ${INPUT_FILE} -planName ${PLAN_NAME} -UIValues ${UIValues}
    ${cmd}=    Set Variable    ${cmd} -useObjectOperationDefinedInImportFile ${USE_OBJECT_OPERATION} -v -setSystemTemplate false
    ${cmd}=    Set Variable If    ${skip_existing}    ${cmd} -skipExisting true   ${cmd}
#    ${stdout}  ${stderr}  ${rc}    Exec NA CLI Command    ${cmd}
    ${expect_output}=    Set Variable     Status received: Finished
    ${output}   csn.execute   command=${cmd}   connection=WasNode   timeout=300
    run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
    ${remove_file_cmd}=    Set Variable    rm ${NA_IMPORT_DIR}/${INPUT_FILE}
    ${stdout}   csn.execute   command=${remove_file_cmd}   connection=WasNode   timeout=300
    run keyword and ignore error  csn.disconnect    connection=WasNode
    # Should Not Contain  ${stdout}  failed
    # does not fully work on our NA !!!   Should Contain    ${stdout}    0 object(s) failed
    # ! EXPERIMENTAL RETURN - MAY NOT WORK PROPERLY  - ADDED BY MF!
    [Return]    ${stdout}

Remove Plan
    [Documentation]     Removes plan from NetAct. Keyword won't fail if NA Plan not exists.
                ...     NA CLI Command: racclimx.sh ``-op planDeletion -planName ${PLAN_TO_REMOVE} -v``
                ...     Timeout for this keyword is set to 5 minutes.
    [Timeout]           15 minutes
    [Arguments]         ${PLAN_TO_REMOVE}
    ${remove_plan_cmd}=    set variable   racclimx.sh -op planDeletion -planName ${PLAN_TO_REMOVE} -v
    csn.connect_to    hostname=${netact_nodeip}
    ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
    Run Keyword And Ignore Error   csn.execute   command=${remove_plan_cmd}   connection=WasNode   timeout=300
    run keyword and ignore error  csn.disconnect    connection=WasNode

Set Current Element Value
    [Documentation]     Set element defined as ${ELEMENT_XPATH} to new value and save it as ${NEW_PLAN_FILE}
                ...     Timeout: 10 secs
    [Timeout]           10s
    [Arguments]         ${PLAN_FILE}  ${NEW_PLAN_FILE}  ${ELEMENT_XPATH}  ${NEW_VALUE}
    ${root}=  Parse XML  ${PLAN_FILE}
    Set Element Text  source=${root}  xpath=${ELEMENT_XPATH}  text=${NEW_VALUE}
    Save XML  ${root}  ${NEW_PLAN_FILE}
    ${xml_new_value}=  Get Element Text  ${NEW_PLAN_FILE}  ${ELEMENT_XPATH}
    Should Be Equal As Strings  ${xml_new_value}  ${NEW_VALUE}

Add Parameters
    [Documentation]     Add parameters (and associated MO/list/item if missing) from a given XML.
    [Timeout]           30s
	[arguments]	${list_params}	${input_xml}	${output_xml}
	${root}=	XML.Parse XML	${input_xml}

	FOR	${param}	IN	@{list_params}
		${MO}=	set variable	${param[0]}
		${mo_xpath}=	set variable	//managedObject[@distName="${MO}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=${mo_xpath}
		run keyword if	${exist}	XML.Set Element Attribute	${root}	  operation	update	 ${mo_xpath}
       Set Suite Variable      ${g_level_MO}   0
       run keyword if  not ${exist}    create MO_0     ${root}    ${MO}
    END
    FOR	${param}	IN	@{list_params}
		${list}=	set variable	${param[1]}
		Continue For Loop If	'${list}' == 'None'
		${MO}=	set variable	${param[0]}
		${list_path}=	set variable	//managedObject[@distName="${MO}"]/list[@name="${list}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=${list_path}
		Continue For Loop If	${exist}
		XML.add element		${root}		<list name="${list}"/>	 xpath=//managedObject[@distName="${MO}"]
    END
	FOR	${param}	IN	@{list_params}
		${list}=	set variable	${param[1]}
		Continue For Loop If	'${list}' == 'None'
		${item}=	set variable	${param[2]}
		${MO}=	set variable	${param[0]}
		${list_path}=	set variable	//managedObject[@distName="${MO}"]/list[@name="${list}"]
		${exist}=	run keyword and return status	XML.Element Should Exist	${root}	 xpath=(${list_path}/item)[${item}]
		Continue For Loop If	${exist}
		XML.add element		${root}		<item/>	 xpath=//managedObject[@distName="${MO}"]/list[@name="${list}"]
    END
	FOR	${param}	IN	@{list_params}
		${MO}=		set variable	${param[0]}
		${list}=	set variable	${param[1]}
		${item}=	set variable	${param[2]}
		${name}=	set variable	${param[3]}
		${value}=	set variable	${param[4]}
		${path}=	set variable	//managedObject[@distName="${MO}"]
		${path}=	set variable if	  '${list}' == 'None'	${path}
		...		${path}/list[@name="${list}"]/item[${item}]
		${exist}=	run keyword and return status	XML.Element Should exist	${root}		xpath=${path}/p[@name="${name}"]
		run keyword if	 ${exist}	XML.Set Element Text	${root}	  text=${value}	  xpath=${path}/p[@name="${name}"]
		...	ELSE			XML.Add Element		${root}	   <p name="${name}">${value}</p>	xpath=${path}
    END
	XML.save XML	${root}		${output_xml}

Prepare Delta Plan
    [Documentation]     Make delta from given plan name and save it as ${DELTA_PLAN_NAME} in Netact
               ...      NA Command:
               ...          ``racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v``
               ...      Timeout is set to 300 seconds.
    [Arguments]         ${NA_PLAN_NAME}  ${DELTA_PLAN_NAME}
    [Timeout]           300s

#    Remove Plan     ${DELTA_PLAN_NAME}
    ${cmd}=    set variable   racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v
#    ${stdout}  ${stderr}  ${rc}
#    ...  Exec NA CLI Command  racclimx.sh -op Compare -planName ${NA_PLAN_NAME} -deltaPlanName ${DELTA_PLAN_NAME} -v
    csn.connect_to    hostname=${netact_nodeip}
    ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
    ${output}=   csn.execute   command=${cmd}   connection=WasNode   timeout=300
    ${expect_output}=    Set Variable     Status received: Finished
    run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
#    Remove Plan     ${NA_PLAN_NAME}
    ${remove_plan_cmd}=    set variable  racclimx.sh -op planDeletion -planName ${NA_PLAN_NAME} -v
    Run Keyword And Ignore Error
        ...  csn.execute   command=${remove_plan_cmd}  connection=WasNode   timeout=300
    run keyword and ignore error  csn.disconnect    connection=WasNode

Provision Plan
    [Documentation]     Provision plan with given name as argument.
    ...      NA Command:
    ...          ``racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -v``
    ...      Returns as string standard output (stdout) from operation's execution.
    ...      Keyword timeut is set to 15 minutes.
    [Arguments]         ${NA_PLAN_NAME}
    ...     ${return_stdout_on_failure}=False
    ...     ${provisioning_operation}=activate
    ...     ${validate}=${VALIDATION}
    ...     ${create_backup_plan}=false
    ...     ${backup_plan_name}=None
    ...     ${check_error}=True
    [Timeout]           20 minutes
    log   return_stdout_on_failure='${return_stdout_on_failure}' check_error='${check_error}'
    ${cmd}=   set variable    racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -backupPlanName ${backup_plan_name}
    ${cmd}=   set variable    ${cmd} -provisioningOperation ${provisioning_operation} -createBackupPlan ${create_backup_plan} -v
    ${cmd_no_val}=   set variable    racclimx.sh -op Provision -planName ${NA_PLAN_NAME} -validateBeforePreactivationForLTE false
    ${cmd_no_val}=   set variable    ${cmd_no_val} -provisioningOperation ${provisioning_operation}
    ${cmd_no_val}=   set variable    ${cmd_no_val} -createBackupPlan ${create_backup_plan} -backupPlanName ${backup_plan_name} -v

    csn.connect_to    hostname=${netact_nodeip}
    ...   username=${NA_USER}    password=${NA_PASS}    alias=WasNode   timeout=60
    csn.execute   command=${cmd}   connection=WasNode   timeout=300
    ${stdout}   Run Keyword if  "${validate}"=="True"   csn.execute   command=${cmd}   connection=WasNode   timeout=300
    ...  ELSE   csn.execute   command=${cmd_no_val}   connection=WasNode   timeout=300
    run keyword and ignore error  csn.disconnect    connection=WasNode
    [Return]    ${stdout}

create MO_0
    [Documentation]     create MO_0 in xm
    [Arguments]     ${root}   ${MO}
    ${class}=       fetch from right        ${MO}   /
    ${father}=      fetch from left         ${MO}   /${class}
    ${class}=       fetch from left         ${class}        -
    ${exist}=       run keyword and return status   XML.element should exist        ${root}    xpath=//managedObject[@distName="${father}"]
    ${level_MO}=    evaluate        ${g_level_MO}+1
    Set Suite variable      ${g_level_MO}     ${level_MO}
    run keyword if    not ${exist}    create MO_${g_level_MO}         ${root}         ${father}
    ${version}=     XML.get element attribute       ${root}   version         xpath=//managedObject[@distName="${father}"]
    XML.add element         ${root}         <managedObject distName="${MO}" class="${class}" version="${version}" operation="update"/>
    ...    xpath=//cmData
