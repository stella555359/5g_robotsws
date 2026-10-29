*** Settings ***
Documentation
...   Author: jieting.zhan@nokia-sbell.com
...   Contact: shunxin.jin@nokia-sbell.com
...   Description: this robot case focus on MantaRay


Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Start DCAP Container    node_id=${0}   node_type=gnb
Suite Teardown    Run keywords    Common Suite Teardown For AIC

Force Tags
...      PY36
...      CRT             #Tag Item
...      TRUNK
...      RAN_PZ_HAZ_1             #Competence Area
#...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          RRM_Selenium.robot
#Resource          ../../../../OAM/RAN_PZ_HAZ_1/HAZ11/resources/hran_frame_taf_oam.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${instance_id}    11560
${global_bts_id}    11071
${COMMISSIONING_PATH}    /home/ute/testline_configuration/7_5_UTE5GAIC015T004/${instance_id}_scf_plan_for_case.xml
${TEST_LOG_DIRECTORY}    /home/ute/test_results/CB012125
#${adaptationVersions}    com.nokia.srbts.nrbts:NRBTSVDU25R1
#NA1057
#&{NETACT}    was_host=10.68.122.63    fm_host=10.68.122.63    user=omc    password=Medsql!_1893
#NA1046
#&{NETACT}    was_host=10.43.48.159    fm_host=10.43.48.159    user=omc    password=Medsql!_1893
#NA1016
&{NETACT}    was_host=10.41.146.167    fm_host=10.41.146.167    user=omc    password=Medsql!_1893
${MantaRay_FCT_File_Path}    /d/oss/global/var/racprs/work
#${exportfile}    /home/ute/testline_configuration/7-5-UTESRAN002T11072/FCE_Output_Calculate_Plan_1710844451.xml
&{PDCCH_Parameters1}    searchSpaceType=Type2    periodicity=sl10    slotOffset=0    duration=7    monitoringSymbolWithinSlot=symbol_0
&{PDCCH_Parameters2}    searchSpaceType=Type2    periodicity=sl10    slotOffset=2    duration=4    monitoringSymbolWithinSlot=symbol_0
&{PDCCH_Parameters3}    searchSpaceType=Type2    periodicity=sl10    slotOffset=0    duration=7    monitoringSymbolWithinSlot=symbol_0
&{Paging_Parameters1}    numOfPagingFrames=quaterT    pagingOffset=1    numPagingOccsnPagingFrame=one    fPdcchMonOccsnPo=2
&{Paging_Parameters2}    numOfPagingFrames=quaterT    pagingOffset=1    numPagingOccsnPagingFrame=one    fPdcchMonOccsnPo=0
&{Paging_Parameters3}    numOfPagingFrames=halfT    pagingOffset=1    numPagingOccsnPagingFrame=one    fPdcchMonOccsnPo=2
&{expect_output_non_NIDD_parameter}    NRCELL-3="pagingOccasionRate":"25"    NRCELL-4="pagingOccasionRate":"25"    NRCELL-5="pagingOccasionRate":"50"

*** Test Cases ***
CB012125_20_Mix_audit_configure_feature_using_MantaRay_with_actual_configuration_conf25_conf26_conf27_24R3
    [Tags]      CRT    CB012125_20
    [Documentation]
    ...    Author: jieting.zhan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
	...                    2024.08.17, Jin Shunxin, optimize case to suit TRUNK 25R1
    [Setup]    MantaRay Case Precondition
#    vDU Update Full SCF By Rest    scf_path=${COMMISSIONING_PATH}    vdu_index=1
#    Sleep    120s
#    Wait Until Keyword Succeeds    20min    1min    vDU Check All Cells Status for case scf    vdu_index=1
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${instance_id}
    Log To Console    Case start.    console=${True}
    GetFceCapabilities And Check    FCT_Tool=Paging
	GetFceCapabilities And Check    FCT_Tool=PDCCH

    ${NA_exe_result}    Calculate Configuration And Check    targetCell=NRCELL-3,NRCELL-4,NRCELL-5
    ...    outputPlanName=${Paging_Cal_Plan_Name}    toolName=Paging
    Check output non-NIDD parameter    ${NA_exe_result}    ${expect_output_non_NIDD_parameter}

    ${NA_exe_result}    Audit Configuration And Check    targetCell=NRCELL-3,NRCELL-4,NRCELL-5
    ...    outputPlanName=${Paging_Audit_Plan_Name}    toolName=Paging
    Wait Until Keyword Succeeds    5min    1min      Export Delta Plan    PLAN_NAME=${Paging_Audit_Plan_Name}

    ${NA_exe_result}    Calculate Configuration And Check    targetCell=NRCELL-3,NRCELL-4,NRCELL-5
    ...    outputPlanName=${PDCCH_Cal_Plan_Name}    toolName=PDCCH
    Wait Until Keyword Succeeds    5min    1min      Export Delta Plan    PLAN_NAME=${PDCCH_Cal_Plan_Name}
    Provision the plan SyVe    PLAN_NAME=${Paging_Audit_Plan_Name}
    Sleep    120s
    Provision the plan SyVe    PLAN_NAME=${PDCCH_Cal_Plan_Name}
    Sleep    120s
    Wait Until Keyword Succeeds    10min    1min    vDU Check All Cells Status Should Be Onair    vdu_index=1
    Check Parameters after Case
    Verify Call on each cell
    [Teardown]    MantaRay Case Postcondition

CB013289-A_US#B3_TC31_PCMD_Monitoring_of_patial_QoS_Flow_forwarding_status_during_IRAT_HO_to_LTE_at_gNB-CU-CP_no_data_forwarding
    [Tags]    CRT    TC31
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
    [Setup]    Case Precondition
    Initialize PA Signal For TL11071 Cell4
    Parameter Updated In vCU For CB013289 TC31
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    Prepare And Attach UE    ue_index=0    ui_version=S21
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0    capabilities=samsung
    sleep    5s    reason=wait call stable
    Trigger A2 By Modify PA Signal
    Trigger B2 By Modify PA Signal
    sleep    5s    reason=wait call stable
    Check VONR Call Status after HO
    Stop VONR Call For UE    ue_index=0
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    ${flag}    Set Variable    False
    FOR    ${trace_file}    IN    @{trace_file_path}
        ${flag}    Check Emil Log for TC31    ${trace_file}    ${flag}    dcap-master
        exit for loop if    '${flag}'=='True'
    END
    should be equal    ${flag}    True    Check emil log failed!
    [Teardown]    Case Postcondition

*** Keywords ***
Verify Call on each cell
	Initial PA Signal
    ${target_cell}    Get All cell nrCellIdentity    cellid=3
    ${initial_att_values}    Adjust PA Signal    RU_id=0    du_id=1    adjust_att_value=0
    Prepare And Attach UE    ue_index=0
    #Start Call For UE    ue_index=0    direction=dl
    ${attached_cell}    Get Serving Cell Id    ${tl.ues[0].serial_number}
    Should Be Equal    ${target_cell}    ${attached_cell}
	#Recover Attenuation Values    initial_att_values=${initial_att_values}    RU_id=0    vendor=TOPYOUNG    du_id=1
	Adjust PA Signal    RU_id=0    du_id=1    adjust_att_value=120
    ${initial_att_values}    Adjust PA Signal    RU_id=1    du_id=1    adjust_att_value=0
    Prepare And Attach UE    ue_index=0
    #Start Call For UE    ue_index=0    direction=dl
    Get Serving Cell Id    ${tl.ues[0].serial_number}
	#Recover Attenuation Values    initial_att_values=${initial_att_values}    RU_id=1    vendor=TOPYOUNG    du_id=1
	Adjust PA Signal    RU_id=1    du_id=1    adjust_att_value=120
    ${initial_att_values}    Adjust PA Signal    RU_id=2    du_id=1    adjust_att_value=0
    Prepare And Attach UE    ue_index=0
    #Start Call For UE    ue_index=0    direction=dl
    Get Serving Cell Id    ${tl.ues[0].serial_number}
	#Recover Attenuation Values    initial_att_values=${initial_att_values}    RU_id=2    vendor=TOPYOUNG    du_id=1
	Adjust PA Signal    RU_id=2    du_id=1    adjust_att_value=120

Get All cell nrCellIdentity
    [Arguments]    ${cellid}=3
    vDU Login By Rest    gnb_index=0    vdu_index=1
    ${cell_nci}=    Online Get VDU Parameter Value
    ...    MRBTS-${instance_id}/NRBTS-${MRBTS_ID}/NRCELL-${cellid}    nrCellIdentity
    [Return]    ${cell_nci}
    [Teardown]    vDU Logout By Rest    vdu_index=1

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=S21
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Log to Console    \n***Prepare to attach.***
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE attached.***
    [Return]     ${ue_${ue_index}_type}

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    Log to Console    \n***UE detached.***

Initial PA Signal
    [Arguments]    ${initial_att_value}=120
    Log to Console    \n***Start to initial PA power...***
    ${attenuation_port_numbers}     Get Attenuation port    RU_id=0    du_id=0
	${port_number}    Get Length    ${attenuation_port_numbers}
	${original_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=TopYoung    du_id=0
    ${initial_att_values}    create dictionary
	FOR    ${index}    IN RANGE    ${port_number}
	    Set To Dictionary    ${initial_att_values}    ${attenuation_port_numbers[${index}]}    ${initial_att_value}
	    Log to Console    ${initial_att_values}
	END
    Modify Attenuation Value    ${initial_att_values}    RU_id=0    du_id=0
    sleep    10s
    Log to console    \n***Attenuation ports initialized......***

Adjust PA Signal
    [Arguments]    ${RU_id}=0    ${du_id}=0    ${adjust_att_value}=0
    Log to Console    \n***Start to ajust PA power....or you may say that attenuation ports power...***
    ${attenuation_port_numbers}     Get Attenuation port    RU_id=${RU_id}    du_id=${du_id}
	${port_number}    Get Length    ${attenuation_port_numbers}
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=${RU_id}    vendor=TopYoung    du_id=${du_id}
    ${channels_to_modify}    create dictionary
	FOR    ${index}    IN RANGE    ${port_number}
		Set To Dictionary    ${channels_to_modify}    ${attenuation_port_numbers[${index}]}    ${adjust_att_value}
	END
    Modify Attenuation Value    ${channels_to_modify}    RU_id=${RU_id}    du_id=${du_id}
    sleep    10s
    Log to console    \n***Attenuation ports ajusted......***
	[Return]    ${initial_att_values}

vDU Check All Cells Status for case scf
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    check cells configured by case required scf_recommended
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    #Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    #should be true    ${on_line}==${cell_number}
    [Teardown]  vdu.disconnect    ${alias}

Check Parameters after Case
    ${check_result}    Create List
    ${Check_status}    Run Keyword And Return Status    Check Paging Parameters In Full Plan    targetCell=NRCELL-3
    ...    PAGING_Parameters_Checklist=${Paging_Parameters1}
    Append to List    ${check_result}    ${Check_status}
    ${Check_status}    Run Keyword And Return Status    Check Paging Parameters In Full Plan    targetCell=NRCELL-4
    ...    PAGING_Parameters_Checklist=${Paging_Parameters2}
    Append to List    ${check_result}    ${Check_status}
    ${Check_status}    Run Keyword And Return Status    Check Paging Parameters In Full Plan    targetCell=NRCELL-5
    ...    PAGING_Parameters_Checklist=${Paging_Parameters3}
    Append to List    ${check_result}    ${Check_status}
    ${Check_status}    Run Keyword And Return Status    Check PDCCH Parameters In Full Plan    targetCell=NRCELL-3
    ...    PDCCH_Parameters_Checklist=${PDCCH_Parameters1}
    Append to List    ${check_result}    ${Check_status}
    ${Check_status}    Run Keyword And Return Status   Check PDCCH Parameters In Full Plan    targetCell=NRCELL-4
    ...    PDCCH_Parameters_Checklist=${PDCCH_Parameters2}
    Append to List    ${check_result}    ${Check_status}
    ${Check_status}    Run Keyword And Return Status   Check PDCCH Parameters In Full Plan    targetCell=NRCELL-5
    ...    PDCCH_Parameters_Checklist=${PDCCH_Parameters3}
    Append to List    ${check_result}    ${Check_status}
    [Return]    ${check_result}

Check output non-NIDD parameter
	[Arguments]    ${NA_exe_result}    ${expect_output_non_NIDD_parameter}
	FOR    ${key}    IN    @{NA_exe_result.keys()}
		Should Be Equal    ${NA_exe_result["${key}"]}    ${expect_output_non_NIDD_parameter["${key}"]}
	END


Select Expected FCT From Droplist
    [Arguments]    ${expected_feature_name}
    Log    Select Desired FCT From Droplist    console=True
    ${fce_list_objects}    SBTS WEM Select Feature On CA    ${expected_feature_name}
    Set Test Variable    ${fce_list_objects}


Start Calculate And Check Results
    Log    Start Calculate And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Calculate On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Calculate operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
		Should Not Be Equal As Strings    ${item['Severity']}    error
    END


Audit and Check Result
    Log    Audit And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Audit On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Audit operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
		Should Not Be Equal As Strings    ${item['Severity']}    error
    END


Apply All Success And Check Result Into Planned Configuration
    Log    Apply All Into Planned Configuration  console=True
    ${apply_result}    Compare And Apply Success And Check Result On CA



Check FCE Installed On Netact
    Log    Step ${index}: Check FCE Installed On Netact   console=True
    ${filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${FCT_features}    Get FCT Features On NetAct    ${filter}
    Run Keyword If    '${FCT_features.__len__()}'=='${0}'    Install New FCT On NetAct

MantaRay Case Precondition
    Log To Console    Case Precondition
    #Set Test Variable    ${NEED_RECOVER}    ${False}
    Setup NetAct    ${NETACT}
    vDU Login By Rest    vdu_index=1
    ${vdu_data}=    vdu.get_vdu_state_data
    ${vdu_version}    set variable    ${vdu_data['software_version']}
    vDU Logout By Rest    vdu_index=1
#    ${WFT_version}    Replace String    ${VDU_VERSION}    25R1    00
    ${WFT_version}    set variable    vDUCNF00_${VDU_VERSION.split("_")[1]}
    ${fce_worker_name}    ${fct_files_name}    AIC Download FCE And FCT    target_version=${WFT_version}
    ...    target_download_path=${TEST_LOG_DIRECTORY}/TestFiles    release_name=vDUCNF00   clean_folder=${TRUE}
	${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}    ${PAGING_FCT_NAME}    Unzip FCT    ${TEST_LOG_DIRECTORY}/TestFiles/${fct_files_name}
	Set Test Variable    ${PDCCH_FCT_NAME}
	Set Test Variable    ${PUCCH_FCT_NAME}
	Set Test Variable    ${PAGING_FCT_NAME}
    ${time}    Get Time    epoch
    #Set Test Variable    ${REMOTE_FCT_FILE}    /d/oss/global/var/racprs/work/${time}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${COMMISSIONING_PATH}
    ${NRBTS_RELEASE}    L_XML.Get Element Attribute    ${scf_content}    version    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Test Variable    ${NRBTS_RELEASE}    com.nokia.srbts.nrbts:${NRBTS_RELEASE.split("_")[0]}
    ${elements_nrcell}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${LIST_NRCELL_DN}    Create List
    FOR    ${element}    IN    @{elements_nrcell}
		${dn}    L_XML.Get Element Attribute    ${element}    distName
		Append To List    ${LIST_NRCELL_DN}    ${dn}
    END
    Set Test Variable    ${LIST_NRCELL_DN}
    Set Test Variable    ${Paging_Cal_Plan_Name}    FCE_Paging_Calculate_Plan_25_${time}
    Set Test Variable    ${Paging_Cal_Plan_Name1}    FCE_Paging_Calculate_Plan_50_${time}
    Set Test Variable    ${Paging_Audit_Plan_Name}    FCE_Paging_Audit_Plan_${time}
    Set Test Variable    ${PDCCH_Cal_Plan_Name}    FCE_PDCCH_Calculate_Plan_${time}
    Set Test Variable    ${PDCCH_Audit_Plan_Name}    FCE_PDCCH_Audit_Plan_${time}

MantaRay Case Postcondition
    Log To Console    \n Case Postcondition
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${Paging_Cal_Plan_Name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${Paging_Audit_Plan_Name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PDCCH_Cal_Plan_Name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PDCCH_Audit_Plan_Name}
    #Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    #${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${REMOTE_FCT_FILE}
    #Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${REMOTE_FCT_FILE}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PDCCH_FCT_NAME}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PUCCH_FCT_NAME}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PAGING_FCT_NAME}
    #Teardown NetAct
    SSHLibrary.Close All Connections

AIC Download FCE And FCT
    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=SBTS00    ${clean_folder}=${TRUE}
    [Documentation]    Helper keyword for downloading fce and fct
    ...    Author:
    ...    Contact:
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_version | Yes | e.g. SBTS00_ENB_9999_230608_000013 |
    ...    | target_download_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: SBTS00 |
    ${download_command}    Set Variable    sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...     https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
    Run Keyword If    '${status}' == 'False'    OperatingSystem.Create Directory    ${target_download_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
    Log To Console    \nStart Download FCE For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCE For ${target_version}...........
    Log To Console    \nStart Download FCT For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
    #Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCT For ${target_version}...........
    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
    [Return]     ${fce_worker}    ${fct_files}



GetFceCapabilities And Check
    [Arguments]    ${FCT_Tool}=PDCCH
    Log To Console    Step 1 : GetFceCapabilities And Check
    ${param_name_mapping}    Create Dictionary    Tool Name=fullToolName    Abbreviated Tool Name=toolName
    ...    Description=toolDescription    Version=toolVersion    Category=toolCategory
    ...    Support Release(s) \\ NIDD adaptationId(s)=supportedAdaptationVersions
    ${ParmName_Excel_list}    Get Dictionary Keys    ${param_name_mapping}
    ${FCT_Tool_Name}    Set Variable If    '${FCT_Tool}' == 'PDCCH'    ${PDCCH_FCT_NAME}
    ...    '${FCT_Tool}' == 'PUCCH'    ${PUCCH_FCT_NAME}    ${PAGING_FCT_NAME}
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${TEST_LOG_DIRECTORY}/TestFiles/${FCT_Tool_Name}    GENERAL-METADATA    ${ParmName_Excel_list}
    ${feature_filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Run Keyword If    '${feature.__len__()}'=='${0}'    Install New FCT To NetAct    ${FCT_Tool_Name}
    #${feature}    Get FCT Features On NetAct    ${feature_filter}
    #Should Be Equal As Integers    ${feature.__len__()}    ${1}
    #${feature_netact}    Set Variable    ${feature[0]}
    #${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    #${multi_supportedAdaptationVersions}    Pop From Dictionary    ${feature_netact}    supportedAdaptationVersions
    #${supportedAdaptationVersions}    Create List
    #FOR    ${sub_list}    IN    @{multi_supportedAdaptationVersions}
    #Append To List    ${supportedAdaptationVersions}    @{sub_list}
    #END
    #${excel_supportedAdaptationVersions}    Pop From Dictionary    ${FCT_Info}    Support Release(s) \\ NIDD adaptationId(s)
    #Sort List    ${excel_supportedAdaptationVersions}
    #Sort List    ${supportedAdaptationVersions}
    #Lists Should Be Equal    ${supportedAdaptationVersions}    ${excel_supportedAdaptationVersions}
    #${Category}    Pop From Dictionary    ${FCT_Info}    Category
    #${Category}    Set Variable If    '${Category}'=='None'    ${EMPTY}    ${Category}
    #Set To Dictionary    ${FCT_Info}    Category    ${Category}
    #FOR    ${param}    IN    @{ParmName_Excel_list}
    #${netact_param_name}    Get From Dictionary    ${param_name_mapping}    ${param}
    #Should Be Equal As Strings    ${FCT_Info["${param}"]}    ${feature_netact["${netact_param_name}"]}
    #END

GetFctMetadata And Check
    Log To Console    Step 2: GetFctMetadata And Check
    ${additionalInputParameters}    Get Fct Metadata On NetAct    ${NRBTS_RELEASE}
    ${ADDIN_Param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/${FCT_FILE_NAME}    PARAMETER-METADATA
    ${param_dic_excel}    Create Dictionary
    ${param_dic_netact}    Create Dictionary
    FOR    ${param}    IN    @{ADDIN_Param}
		Set To Dictionary    ${param_dic_excel}    ${param["Parent Parameter"]}.${param["Abbreviation"]}    ${param["Default Value"]}
    END
    FOR    ${param}    IN    @{additionalInputParameters}
		${defaultValue}    Pop From Dictionary    ${param}    defaultValue    ${None}
		Set To Dictionary    ${param_dic_netact}    ${param["name"]}    ${defaultValue}
    END
    Dictionaries Should Be Equal    ${param_dic_excel}    ${param_dic_netact}
    Set Test Variable    ${ADDIN_PARAMS_NETACT}    ${additionalInputParameters}

Calculate Configuration And Check
    [Arguments]    ${targetCell}=NRCELL-1    ${additionalInputParameters}=${EMPTY}    ${inputConfigurationType}=actual    ${toolName}=PDCCH
    ...    ${inputPlanName}=${EMPTY}    ${outputPlanName}=FCEoutputDeltaPlan
    Log To Console    Step 2: CalculateConfiguration And Check
	${list_target_DN}    Create List
	${cell_list}    Split String    ${targetCell}    ,
	FOR    ${nrcell}    IN    @{cell_list}
		${list_target_DN}    Create Target DN List For NRCell      ${nrcell}    ${list_target_DN}
	END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{list_target_DN}
    ${additionalInputParameters}    Set Variable If    '${inputPlanName}' == ''   []
    ${adaptationVersions}    Set Variable    ${NRBTS_RELEASE}
    ${cmd}    Create FCT Create Configuration Command    ${str_targetObjects}   ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
#	${calculation_detail_line}    Should Match Regexp    ${stdout}    \\{.*\\}
	${calculation_detail_line}    Get Regexp Matches    ${stdout}    \\{.*\\}
	Log    ${calculation_detail_line}
	${additionalOutputParameters_list}    create dictionary
    Run Keyword If    '${toolName}' == 'Paging'    Get AdditionalOutputParameter    ${calculation_detail_line}    ${additionalOutputParameters_list}
    SSHLibrary.Close Connection
    [Return]    ${additionalOutputParameters_list}

Audit Configuration And Check
    [Arguments]    ${targetCell}=NRCELL-1    ${additionalInputParameters}=${EMPTY}    ${inputConfigurationType}=actual    ${toolName}=PDCCH
    ...    ${inputPlanName}=${EMPTY}    ${outputPlanName}=FCEoutputDeltaPlan
    Log To Console    Start Audit Configuration And Check
	${list_target_DN}    Create List
    ${cell_list}    Split String    ${targetCell}    ,
	FOR    ${nrcell}    IN    @{cell_list}
		${list_target_DN}    Create Target DN List For NRCell      ${nrcell}    ${list_target_DN}
	END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{list_target_DN}
    ${additionalInputParameters}    Set Variable If    '${inputPlanName}' == ''   []
    ${adaptationVersions}    Set Variable    ${NRBTS_RELEASE}
    ${cmd}    Create FCT Audit Configuration Command    ${str_targetObjects}   ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Execute Command    rm -rf /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.File Should Not Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    SSHLibrary.File Should Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.Get File    /d/oss/global/var/racops/export/AuditReportFromActual.csv    ${TEST_LOG_DIRECTORY}/NetActLogs/
    ${audit_detail_line}    Get Regexp Matches    ${stdout}    \\{.*\\}
	Log    ${audit_detail_line}
	${additionalOutputParameters_list}    create dictionary
	Run Keyword If    '${toolName}' == 'Paging'    Get AdditionalOutputParameter    ${audit_detail_line}    ${additionalOutputParameters_list}
    SSHLibrary.Close Connection
    [Return]    ${additionalOutputParameters_list}

Get AdditionalOutputParameter
    [Arguments]    ${output_detail_line}    ${additionalOutputParameters_list}
    FOR    ${result}    IN    @{output_detail_line}
		${result_cell_dn}    Get Regexp Matches    ${result}    \NRCELL-\\d
		${additionalOutputParameter}    Get Regexp Matches    ${result}    \"pagingOccasionRate":"\\d\\d"
		Log    ${result_cell_dn}
		Log    ${additionalOutputParameter}
		Log    ${additionalOutputParameter}[0]
		Set To Dictionary    ${additionalOutputParameters_list}    ${result_cell_dn}[0]    ${additionalOutputParameter}[0]
	END
	[Return]    ${additionalOutputParameters_list}

Export Delta Plan
    [Arguments]    ${PLAN_NAME}
    Log    Export Delta Plan    console=True
    ${exportfile}    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${PLAN_NAME}.xml
    ...    dist_names=PLMN-PLMN/MRBTS-${instance_id}    plan_name=${PLAN_NAME}    operation_type=plan    ui_values=true
    Set Test Variable    ${exportfile}
    [Return]    ${exportfile}

Check Calculate PDCCH Parameters In Delta Plan
    [Arguments]    ${targetCell}    ${PDCCH_Parameters_Checklist}    ${delta_plan}
    ${scf_content}    L_XML.Parse Xml    ${delta_plan}
    ${distName_cell}    Set Variable    PLMN-PLMN/MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${Text_bwpDN}    L_XML.Get Elements Texts    ${scf_content}
    ...                         .//managedObject[@distName="${distName_cell}"]/list[@name="cellBwpList"]/item/p[@name="bwpDN"]
    ${element_PDCCH_CONFIG_COMMON}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="PDCCH_CONFIG_COMMON"]
    ${distName_PDCCH_CONFIG_COMMON}    Create List
    FOR    ${element}    IN    @{element_PDCCH_CONFIG_COMMON}
		${dn}    L_XML.Get Element Attribute    ${element}    distName
		Append To List    ${distName_PDCCH_CONFIG_COMMON}    ${dn}
    END
    Log To Console    ${distName_PDCCH_CONFIG_COMMON}
    FOR    ${bwpDN}    IN    @{Text_bwpDN}
		Check Parameters Of PDCCH    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    END


Check PDCCH Parameters In Full Plan
    [Arguments]    ${targetCell}    ${PDCCH_Parameters_Checklist}
    ${backup_scf_file}    Get VDU SCF    vdu_index=1    gnb_index=0
    ${scf_content}    L_XML.Parse Xml    ${backup_scf_file}
    ${distName_cell}    Set Variable    MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${Text_bwpDN}    L_XML.Get Elements Texts    ${scf_content}
    ...                       .//managedObject[@distName="${distName_cell}"]/list[@name="cellBwpList"]/item/p[@name="bwpDN"]
    ${element_PDCCH_CONFIG_COMMON}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON"]
    ${distName_PDCCH_CONFIG_COMMON}    Create List
    FOR    ${element}    IN    @{element_PDCCH_CONFIG_COMMON}
		${dn}    L_XML.Get Element Attribute    ${element}    distName
		Append To List    ${distName_PDCCH_CONFIG_COMMON}    ${dn}
    END
    Log To Console    ${distName_PDCCH_CONFIG_COMMON}
    FOR    ${bwpDN}    IN    @{Text_bwpDN}
		Check Parameters Of PDCCH    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    END

Get VDU SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${backup_scf_file}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}/NetActLogs
    ...    filename=scf_recommended.xml    include_runtime_data=${False}
    [Return]    ${backup_scf_file}

Check Calculate PAGING Parameters In Delta Plan
    [Arguments]    ${targetCell}    ${delta_plan}
    ${scf_content}    L_XML.Parse Xml    ${delta_plan}
    ${distName_cell}    Set Variable    PLMN-PLMN/MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
		${p_value}    Run Keyword If    '${p_name}' == 'fPdcchMonOccsnPo'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="fPdcchMonOccsnPo"]/p
    ...    ELSE        L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
		Log To Console    ${p_value}
		Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END

Check PAGING Parameters In Full Plan
    [Arguments]    ${targetCell}    ${PAGING_Parameters_Checklist}
    ${backup_scf_file}    Get VDU SCF    vdu_index=1    gnb_index=0
    ${scf_content}    L_XML.Parse Xml    ${backup_scf_file}
    ${distName_cell}    Set Variable    MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PAGING_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
		${p_value}    Run Keyword If    '${p_name}' == 'fPdcchMonOccsnPo'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="fPdcchMonOccsnPo"]/p
    ...     ELSE        L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
		Log To Console    ${p_value}
        Should Be Equal As Strings    ${p_value}    ${PAGING_Parameters_Checklist["${p_name}"]}
    END

Provision the plan SyVe
    [Arguments]    ${PLAN_NAME}
    Log    Provision the plan SyVe    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    NetAct Provision Plan    plan_name=${PLAN_NAME}    dist_names=PLMN-PLMN/MRBTS-${instance_id}
    ...    backup_plan_name=${PLAN_NAME}_backup    create_backup_plan=True    provisioning_operation=activate
    #Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    #Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    ${PDCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PDCCH\\w+\\.xlsx
	${PUCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PUCCH\\w+\\.xlsx
	${Paging_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+Paging\\w+\\.xlsx
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PDCCH_FCT_NAME}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PUCCH_FCT_NAME}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${Paging_FCT_NAME}
    [Return]    ${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}    ${Paging_FCT_NAME}

Install New FCT To NetAct
    [Arguments]    ${fct_tool_name}
    ${MantaRay_FCT_File}    Set Variable    ${MantaRay_FCT_File_Path}/${fct_tool_name}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${TEST_LOG_DIRECTORY}/TestFiles/${fct_tool_name}    ${MantaRay_FCT_File}
    Install FCT On NetAct    ${MantaRay_FCT_File}

Install FCT On NetAct
    [Arguments]    ${mantaray_fct_file}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${mantaray_fct_file} -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Install FCT Operation finished.
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${stdout}

Get FCT Features On NetAct
    [Arguments]    ${filter}=${EMPTY}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    racclimx.sh -op FCT_List -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\[.*\\]
    ${FCT_features}    Evaluate    ${detail_line}
    Return From Keyword If    "${filter}"==""    ${FCT_features}
    FOR    ${feature}    IN    @{FCT_features}
		${is_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${feature}    ${filter}
		Continue For Loop If    ${is_match}
		${feature_version}    Remove String    ${feature}[toolVersion]    .
		${filter_version}    Remove String    ${filter}[toolVersion]    .
		${feature_version_num}    Convert To Integer    ${feature_version}
		${filter_version_num}    Convert To Integer    ${filter_version}
		Run Keyword If    '${feature}[toolName]' != '${filter}[toolName]' or ${feature_version_num} < ${filter_version_num}
    ...    Remove Values From List    ${FCT_features}    ${feature}
    END
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${FCT_features}

Create Target DN List For NRCELL
    [Arguments]    ${nrcell}    ${list_target_DN}
    FOR    ${nrcell_dn}    IN    @{LIST_NRCELL_DN}
		${nrcell_id}    Should Match Regexp    ${nrcell_dn}     NRCELL-\\d
		Run Keyword If    '${nrcell}' == '${nrcell_id}'    Append To List    ${list_target_DN}    PLMN-PLMN/${nrcell_dn}
		Exit For Loop If    '${nrcell}' == '${nrcell_id}'
	END
	[Return]    ${list_target_DN}

Create FCT Create Configuration Command
    [Arguments]    ${targetObjects}    ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    ${cmd}    Run Keyword If    '${inputConfigurationType}' == 'actual'    Catenate
    ...    racclimx.sh -op FCT_Create_Configuration_Plan -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -outputPlanName ${outputPlanName} -v
    ...       ELSE IF    '${inputConfigurationType}' == 'plan'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -planName ${inputPlanName}
    ...    -outputPlanName ${outputPlanName} -v
    [Return]    ${cmd}

Create FCT Audit Configuration Command
    [Arguments]    ${targetObjects}    ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    ${cmd}    Run Keyword If    '${inputConfigurationType}' == 'actual'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -outputPlanName ${outputPlanName}
    ...    -compareFeedbackLevel parameterLevel -compareExportDifferenceReport AuditReportFromActual.csv -v
    ...       ELSE IF    '${inputConfigurationType}' == 'plan'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -planName ${inputPlanName}
    ...    -outputPlanName ${outputPlanName} -compareFeedbackLevel parameterLevel
    ...    -compareExportDifferenceReport AuditReportFromActual.csv -v
    [Return]    ${cmd}

Check If Netact Plan Is Deleted
    [Arguments]    ${plan_name}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}    ${ui_values}=false
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}    ui_values=${ui_values}
    Run Keyword If    ${status}    Log    Plan ${plan_name} at ${local_dir}/${file_name} import success.    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} at ${local_dir}/${file_name} is fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} at ${local_dir}/${file_name} is fail.

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan    ${ui_values}=None
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    '${status}' == 'False'    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    operation_type=${operation_type}    dist_names=${dist_names}
    ...    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}
    ${exportfile}=    Join Path    ${local_dir}    ${file_name}
    [Return]    ${exportfile}

NetAct Provision Plan
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}
    ...    ${provisioning_operation}    ${ignore_errors}=False
    log    ${backup_plan_name}    console=True
    ${status}=    Run Keyword And Return Status    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}    ignore_errors=${ignore_errors}
    Run Keyword If    ${status}    Log    Provision plan ${plan_name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Provision plan ${plan_name} failed!    level=ERROR
    ...    AND    Fail    Provision plan ${plan_name} failed!


Check Parameters Of PDCCH
    [Arguments]    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    FOR    ${distName}    IN    @{distName_PDCCH_CONFIG_COMMON}
		${result}    Run Keyword And Return Status    Should Contain    ${distName}    ${bwpDN}
		Exit For Loop If    ${result}
    END
    ${element_searchSpaceCommon_item}    L_XML.Get Elements    ${scf_content}
    ...    .//managedObject[@distName="${distName}"]/list[@name="searchSpaceCommon"]/item
    FOR    ${element}    IN    @{element_searchSpaceCommon_item}
		${text_p}    L_XML.Get Element Text    ${element}    .//p[@name="searchSpaceType"]
		Exit For Loop If    '${text_p}' == 'Type2'
    END
    Log To Console    ${element}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
		${p_value}    L_XML.Get Element Text    ${element}    .//p[@name="${p_name}"]
		Log To Console    ${p_value}
		Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END

Check Parameters Of Paging
    [Arguments]    ${scf_content}
    ${element_searchSpaceCommon_item}    L_XML.Get Elements    ${scf_content}
    ...    .//managedObject[@distName="${distName}"]/list[@name="searchSpaceCommon"]/item
    FOR    ${element}    IN    @{element_searchSpaceCommon_item}
		${text_p}    L_XML.Get Element Text    ${element}    .//p[@name="searchSpaceType"]
		Exit For Loop If    '${text_p}' == 'Type2'
    END
    Log To Console    ${element}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
		${p_value}    L_XML.Get Element Text    ${element}    .//p[@name="${p_name}"]
		Log To Console    ${p_value}
		Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END




NetAct CM Upload
    [Arguments]    ${dist_names}    ${parameters}=None    ${check_feedback}=${False}
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Upload Configuration    dist_names=${dist_names}
    ...                                                                                        parameters=${parameters}
    Run Keyword If    '${status}'=='PASS'    Log    CM Upload operation succesfully finished for ${dist_names}    console=True
    ...    ELSE    Run Keywords    Log    CM Upload operation failed for ${dist_names}    level=ERROR
    ...    AND    Fail    CM Upload operation failed for ${dist_names}
    Return From Keyword If    not ${check_feedback}
    ${feedback}    Replace String Using Regexp    ${feedback}    \\n\\t    ${EMPTY}
    ${feedback_list}    Split String    ${feedback}    \n
    Should Not Contain    ${feedback}     Content mismatch with metadata detected
    FOR    ${item}    IN     @{feedback_list}
		${status}    Run Keyword And Return Status    Should Contain    ${item}    Feedback received:DN: ${dist_names}
		Run Keyword If    not ${status}    Remove Values From List    ${feedback_list}    ${item}
    END
    ${feedback}   Convert To String    ${feedback_list}
    Should Contain    ${feedback}    5G/LTE/SRAN upload finished
    Should Contain    ${feedback}    5G/LTE/SRAN HW upload finished
    Should Not Contain    ${feedback}    Error
    Should Not Contain    ${feedback}    Warning


Setup NetAct
    [Arguments]     ${NETACT}
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect WEB URL
    netact.Add WEB URL    ${web_url}    ${NETACT['user']}    ${NETACT['password']}


Teardown NetAct
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All

Initialize PA Signal For TL11071 Cell4
	SetInitializePAValue    pa_port=1-9;10;11;12;13-16;    pa_value=120;0;120;0;120;

Trigger A2 By Modify PA Signal
    ${source_pa_port_list}     Create List     10    12
    ${source_pa_value_list}    Create List     0    25
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${5}

Trigger B2 By Modify PA Signal
    ${source_pa_port_list}     Create List     16
    ${source_pa_value_list}    Create List     120    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${60}

Parameter Updated In vCU For CB013289 TC31
    @{para_list}          Create List    actInterRatHoSADlDataForward    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod    dataForwarding
	...                                  dataForwarding    dataForwarding    dataForwarding    dataForwarding
    @{mo_list_vcu}        Create List    MRBTS-11071/NRBTS-11071    MRBTS-11071/NRBTS-11071    MRBTS-11071/NRBTS-11071/NRADJECELL-1
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-1    MRBTS-11071/NRBTS-11071/NRDRB_5QI-2
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-5    MRBTS-11071/NRBTS-11071/NRDRB_5QI-7
	...                                  MRBTS-11071/NRBTS-11071/NRDRB_5QI-9
    @{value_list_true}    Create List    true    IRATDirectDataFwdOnNg    directDataFwd    IRATDataFwd
	...                                  IRATDataFwd    IRATDataFwd    IRATDataFwd    IRATDataFwd
	Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    Set Test Variable    ${webem_info}
    [return]    ${webem_info}

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${vdu_custom_profile}=${None}    ${vcu_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Check VONR Call Status after HO
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status after HO***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${log_file_paths}

Check Emil Log for TC31
    [Arguments]    ${trace_file}    ${flag}    ${connection}
    ${message_filter}    Create List    User data=CU: PduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}

    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${return_info}    Run Keyword And Ignore Error    Check PDU Session Resource Info Record    ${trace}
        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
        exit for loop if    '${flag}'=='True'
    END
    [Return]    ${flag}

Check PDU Session Resource Info Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[CuVendorExtensionRecordDataType][pduSessionResourceInfoRecord][data]

    ${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    ${forwardingTarget}=    Set Variable    ${record_data}[forwardingTarget]
    ${forwardingType}=    Set Variable    ${record_data}[forwardingType]
    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]

    Should Be Equal    ${trigger}    handover
    Should Be Equal    ${result}    success
    Should Be Equal    ${forwardingTarget}    eutran
    Should Be Equal    ${forwardingType}    direct

    ${expected_refused_qfis}    Create List    ${3}    ${4}
    ${expected_refused_eradids}    Create List    ${2}    ${3}
    ${actual_refused_qfis}    Create List
    ${actual_refused_eradids}    Create List
    FOR    ${session}    IN    @{modified_pdu_sessions}
        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]
        ${forwarding_refused_qos_flows}=    Set Variable    ${session}[forwardingRefusedQosFlows]
        ${refused_qfi_info}    ${refused_erabId_info}    Get qfi and erabId in forwardingQosFlows list    ${forwarding_refused_qos_flows}
        append to list    ${actual_refused_qfis}    ${refused_qfi_info}
        append to list    ${actual_refused_eradids}    ${refused_erabId_info}
    END
#    Should Be Equal    ${expected_refused_qfis}    ${actual_refused_qfis}
#    Should Be Equal    ${expected_refused_eradids}    ${actual_refused_eradids}

Get qfi and erabId in forwardingQosFlows list
    [Arguments]    ${forwarding_qos_flows}
    ${qfi_list}    Create List
    ${erabId_list}    Create List
    FOR    ${flow_info}    IN    @{forwarding_qos_flows}
        ${qfi}=    Set Variable    ${flow_info}[qfi]
        ${erabId}=    Set Variable    ${flow_info}[erabId]
        append to list    ${qfi_list}    ${qfi}
        append to list    ${erabId_list}    ${erabId}
    END
    [Return]   ${qfi_list}    ${erabId_list}

Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
#    vDU Login By Rest
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest