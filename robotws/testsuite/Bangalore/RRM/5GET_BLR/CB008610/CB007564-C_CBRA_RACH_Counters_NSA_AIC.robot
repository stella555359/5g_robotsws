***Settings***
Force Tags          CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...                 CONFIGS_Bangalore/RRM/ET/CB008610/CB008610_AIC.yml
...                 CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1     CONFIGURED


Documentation
...     author:         nagesh.k_v@nokia.com
...     maintainer:     Nagesh K V
...     INTRODUCTION:   AIC parity of CB007564 Test cases
...     Feature:        CB008610

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Library             OperatingSystem
Library             Collections
Library             String
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Library             ../resources/python/IphyUpdate.py
Library             taf.collectors.pmcounters
Library             taf.analyzer.pmcounter       WITH NAME    check_pm
Library             ./python/utility.py

Suite Setup             Run keywords        Test Suite Setup
...                     AND                 AIC Software Build Info
...                     AND                 Fetch Taf Library used in TL

suite teardown          Run keywords        Kill WTS processes Using WTS_Runner

***Variables***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_fullstack_NSA_call_tdd_cmwv_CB008610.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
#${delta_cu}         ${CURDIR}/config/SBTS23R1/Delta_config_scf_vCU_5GC006898.json
#${delta_du}         ${CURDIR}/config/SBTS23R1/Delta_config_scf_vDU_5GC006898.json
${nwslice_ID}    1
${gw_ID}     1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${Pdu_session_ID}    1
${epc_log_path}     /tmp/
${UE_ID}     1
${NSA_UE_ID}     11
${BEARER_ID}     2
${VDU_SCF_PATH}     ${CURDIR}/config/SBTS23R1/CB008610_vDU_scf.xml
${VCU SCF PATH}     ${CURDIR}/config/SBTS23R1/CB008610_vCU_scf.xml
${iphy_xml}         ${CURDIR}/config/iphy/updated_iphy_AEQK.xml
${gscn_value}   1

***Test Cases***
[1][1]CB007564-C_TC9_CBRA_Init_procedure_counter_M55306C09008_Number_of_Msg3_received_from_from_Ue_performing_RA_for_initial_connection
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...  REQUIREMENTS:
    ...  REFERENCES: N/A
    ...  CONTACTS:  nagesh.k_v@nokia.com
    ...  TESTING TOOLS:  Btslog2, QXDM, EMSSIM, UTE
    ...  REQUIRED LOGS:  Syslog, TTI Trace
    ...  TEST ENVIRONMENT:
    ...    - gNB: 1x AirScale
    ...  DEFINITIONS FROM THE TEST PLAN:
    ...  PRECONDITIONS:
    ...  HISTORY:
    ...      v0.1: 1.07.2022:  Nagesh K V   : first draft
    ...

    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
#    ...         AND                 Trigger Delta Plan For CU     ${delta_cu}
#    ...         AND                 Trigger Delta Plan For CU     ${delta_du}
#    ...         AND                 vDU Send Commission By RestApi       ${VDU_SCF_PATH}
#    ...         AND                 CU Full Commssion By Rest      ${VCU SCF PATH}     ${VCU SCF PATH}
#    ...         AND                 Update And Copy WTS IPHY XML     ${iphy_xml}   ${gscn_value}
#    ...         AND                 AP Reboot Wait For Connection    ${120}
    ...         AND                 Verify RMODs Online Status      ${800}
    ...         AND                 Clear WTS     ${WTS_DIR}
    ...         AND                 Add WTS Ipaddr At VM
    ...         AND                 Start WTS Using WTS_Runner     ${wts_cfg_file}
    ...         AND                 X2AP Link Should be UP
    ...         AND                 Collect Alarms on AIC At Start of Test




#    set test variable      ${LOG_PATH}
#        Start Syslog Monitoring
#        Start CPIF_CPRT Monitoring
#        Start L1L2 Bip Mon    l1hi
#       l1hi, l2hi, l2rt
#        Start TTI Trace Mon

        Log to console     synch with Meas Period..
        Sync With Measurement Period      "vDU_vCU"
        Log to console     ------------ Start NSA Call ---------------
        Log to console     LTE UE Attach
        LTE Attach should be Successful     ${NSA_UE_ID}
        Log to console     5G UE Attach
        UE Attach should be Successful     ${NSA_UE_ID}
        Log to console     Start DL Traffic for NSA
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     dl_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     ul_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID2}
        log to console      start delay of few seconds
        Sleep    4s
        log to console      Stop delay
#        Log to console     Validate Traffic
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID}
        Log to console     UE Detach
        UE Detach should be Successful   ${NSA_UE_ID}
        sleep    4s
        LTE Attach should be Successful     ${NSA_UE_ID}
        Log to console     5G UE Attach
        UE Attach should be Successful     ${NSA_UE_ID}
        Log to console     Start DL Traffic for NSA
        Trigger DL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     dl_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID}
        sleep   5s
        Log to console     Start UL Traffic for SA
        Trigger UL Traffic for NSA    ue_id=${NSA_UE_ID}    Traffic_rate=mbps     ul_rate=5     id=${BEARER_ID}      trf_id=${TRF_ID2}
        log to console      start delay of few seconds
        Sleep    4s
        log to console      Stop delay
#        Log to console     Validate Traffic
        Stop Data Traffic for NSA     ue_id=${NSA_UE_ID}
        Log to console     UE Detach
        UE Detach should be Successful   ${NSA_UE_ID}
        sleep   300s
        Log to console     Collecting vCU and vDU PM Counters..
        Collect pm counter kubectls      "vDU"
#        sleep   100s
        Collect pm counter kubectls      "vCU"
        Get buffer counters and validate vDU    M55306C09006    M55306C09008    ${2}    *MRBTS*
#        Get buffer counters and validate vCU    <Counter>    *gNB5G*

    [Teardown]  Suite Teardown

** Keywords **
Suite Teardown
    Log to Console    \n-----> Teardown Start <-----
    run keyword and ignore error        Kill WTS processes Using WTS_Runner
#    Stop TTI Trace Collect and decode
#    Stop and Collect L1L2 Bip Monitoring    l1hi
#    Stop and Collect CPIF_CPRT Monitoring
#    Stop and Collect Syslog Monitoring
#    Collect Journal Logs vDU    consolidate
#    Collect Journal Logs vCU    nonconsolidate
#    Collect Alarms on AIC At Stop of Test
#    Fetch AIC Commissioning File


Get buffer counters and validate vDU
    [Arguments]    ${RA_CB_INIT_RESOLVED}    ${RA_MSG3_RECEP_INIT}    ${num_of_attempt}    ${pi_file_pattern}
    @{pi_list}=  Create List    ${RA_CB_INIT_RESOLVED}    ${RA_MSG3_RECEP_INIT}
    ${path}   Set Variable    CB007564*/*/k8scounters
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Run Keyword If
        ...    '${counter}' == 'M55306C09006' or '${counter}' == 'M55306C09008'
        ...    Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}     pi_file_pattern=${pi_file_pattern}
        ...    ELSE
        ...    Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-1    pi_id=${counter}     pi_file_pattern=${pi_file_pattern}
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
    END
    should be Equal    ${num_of_attempt}    @{counter_value}[0]
    should be Equal    ${num_of_attempt}    @{counter_value}[1]
    log to console     Validation is success


Get buffer counters and validate vCU
    [Arguments]    ${VOL_UE_TPUT_QOS_06}    ${TIME_UE_TPUT_QOS_06}    ${VOL_UE_TPUT_PMQAP}    ${TIME_UE_TPUT_PMQAP}    ${pi_file_pattern}
    @{pi_list}=  Create List    ${VOL_UE_TPUT_QOS_06}    ${TIME_UE_TPUT_QOS_06}    ${VOL_UE_TPUT_PMQAP}    ${TIME_UE_TPUT_PMQAP}
    ${path}   Set Variable    CB007564*/*/k8scounters
    @{counter_value} =  Create List
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Run Keyword If
        ...    '${counter}' == '${counter}' == 'M55306C09006' or '${counter}' == 'M55306C09006'
        ...    Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${counter}     pi_file_pattern=${pi_file_pattern}
        ...    ELSE
        ...    Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
        ...    moc=MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-1    pi_id=${counter}     pi_file_pattern=${pi_file_pattern}
        ${actual_pm_values}=   convert to integer    ${actual_pm_values}
        Should Be True    ${actual_pm_values}
        Append To List    ${counter_value}    ${actual_pm_values}
    END
    should be Equal    @{counter_value}[0]    @{counter_value}[2]
    should be Equal    @{counter_value}[1]    @{counter_value}[3]
    log to console     Validation is success

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}


########################################### Delta Commission#####################
Trigger Delta Plan For CU
    [Arguments]     ${file}
    CU Rest Login
    ${delta_plan_id}=   CU Genrate Delta Plan
    ${mocs}=    utility.make_paras_cu   ${file}
    FOR     ${key}   IN  @{mocs}
       Log To Console    ${key}
       Run Keyword If   '${mocs['${key}'][0]['operation_type']}'=='create'    Log To Console   MOC_Creation_needed


#    Run Keyword If  ${length}==0   CU Create Delta Plan Managed Object Should Be Successful
#    ...  plan_id=${delta_plan_id}
#    ...  mo_dn=${prefix}
#    ...  name=com.nokia.srbts.tnl:IPRT  instance_id=${index}

       ${prefix}   ${rest}   Run Keyword If  '${mocs['${key}'][0]['operation_type']}'=='create'     Split String From Right   ${key}   /   1
       ${prefix1}   ${index}   Run Keyword If  '${mocs['${key}'][0]['operation_type']}'=='create'   Split String From Right   ${rest}   -   1
       Run Keyword If  '${mocs['${key}'][0]['operation_type']}'=='create'       Log To Console  Prasanta${prefix1}==${index}
       Run Keyword If  '${mocs['${key}'][0]['operation_type']}'=='create'   CU Create Delta Plan Managed Object Should Be Successful
       ...      ${delta_plan_id}   ${prefix}     ${prefix1}   ${index}
#       ...     create_managed_object_of_delta_plan    ${delta_plan_id}    ${key}
       Update Operation Type    ${mocs['${key}']}
       #Log To Console  ${val}
       CU Online Change Mo Parameters via rest    ${mocs['${key}']}      ${key}    ${delta_plan_id}
       Log To Console  MOC_get_updated${mocs['${key}']}
    END
    CU Validate Delta Plan      ${delta_plan_id}
    CU Activate Delta Plan       ${delta_plan_id}
    #CU Online Change Mo Parameters via rest

Update Operation Type
    [Arguments]     ${paras}
    FOR    ${item}  IN  @{paras}
        Set To Dictionary	${item} 	operation_type=add
#        ${item['operation_type']}=      Set Variable    'add'
        #Log To Console  =======>${item}
        #Log To Console  ++++++${item['operation_type']}
    END
     #Log To Console         ================================================
    #Log To Console  ${paras}
#    [Return]    ${paras}



Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}
    [Documentation]   Generate Delta Status Should Be Expected

    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"


Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}


Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once


_Make Sure Delta Plan Is Deleted Once
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Should Be True  ${all_plans.__len__()}==0



Update and Activate Delta Plan Parameter
    [Arguments]  ${plan_name}    ${delta_json_file}     ${restapi_version}=cuoam_19b   ${vdu_index}=0

    vDU Rest Login  ${restapi_version}  ${vdu_index}
    #Check ${mo_dn}    ${delta_dict}   ${operation}
    ${mo_obj_list}=     utility.read_json       ${delta_json_file}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_name}
    ${plan_id}=     Set Variable  ${out["plan_id"]}
    ${action_id}=   Set Variable  ${out["action_id"]}
    Wait Until Keyword Succeeds  30   3     Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success

    FOR     ${item}     IN    @{mo_obj_list[0]}
#       Log to console    ${item}
        ${key}      Convert To String          ${item['distName']}
#       Log to console      ==>${key}
        ${val}      utility.get_value    ${mo_obj_list[1]}   ${key}
        Log to console    ${val}

#        ${out}      vdu.update_vdu_parameter_of_delta_plan  plan_id=${plan_id}   mo_dn=${item['distName']}
#        ...  updated_paras_dict=${val}    operation=replace
#        ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}l

        #Log to console          ${item['operation']}

        ${prefix}   ${rest}   Run Keyword If  '${item['operation']}'=='create'     Split String From Right   ${item['distName']}   /   1
        Run Keyword If  '${item['operation']}'=='create'   Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${prefix}  mo_name=${rest}
        #Log to console    mocgetupdated${item['distName']}==>${val}
        Trigger Delta Plan    ${item['distName']}     ${val}      ${plan_id}    ${item['operation']}
    END



    ${validation_id}  vDU Validate Delta Plan By REST  plan_id=${planid}
    vDU Activate Delta Plan By REST  plan_id=${plan_id}
    [Return]  ${out}

Trigger Delta Plan
    [Arguments]     ${distName}     ${val}     ${plan_id}   ${operation}

    FOR    ${x}  IN     @{val}

        ${x}=       utility.chk_value   ${x}    ${operation}
        #Log to console    mocgetupdated${x}
        ${out}      vdu.update_vdu_parameter_of_delta_plan  plan_id=${plan_id}   mo_dn=${distName}
        ...  updated_paras_dict=${x[0]}    operation=add   timeout=${60}
        ${action_id}  set variable  ${out["action_id"]}
        ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}

    END
    Log to console    mocgetupdated${x[1]}==>${distName}

    ${frameType}    Run Keyword If   ${x[1]}==${0}  Online Get VDU Parameter Value      ${distName}     tddFrameStructure/0/frameStructureType
    Run Keyword If   ${x[1]}==${0}      Log to console    frame_type${frameType}
    ${paras}    Run Keyword If   ${x[1]}==${0} and '${frameType}'!='semiStatic'  Create Dictionary    /tddFrameStructure/0/lteToNrFrameShift=0ms
    ...         /tddFrameStructure/0/tdLteUlDlConfig=tdLteConfig1

    ${out}      Run Keyword If   ${x[1]}==${0} and '${frameType}'!='semiStatic'   vdu.update_vdu_parameter_of_delta_plan
    ...  plan_id=${plan_id}   mo_dn=${distName}   updated_paras_dict=${paras}    operation=remove   timeout=${60}
    ${action_id}  Run Keyword If   ${x[1]}==${0} and '${frameType}'!='semiStatic'    set variable  ${out["action_id"]}
    ${out}    Run Keyword If   ${x[1]}==${0} and '${frameType}'!='semiStatic'   Update Delta Plan Parameter Should Be Successful
    ...   plan_id=${plan_id}   action_id=${action_id}





Update Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}
_Update Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Validate Delta Plan By REST
    [Arguments]  ${plan_id}
    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    vDU Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}

vDU Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}

    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}

_Validate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}
    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

vDU Activate Delta Plan By REST
    [Arguments]  ${plan_id}
    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${LOG_PATH}   local_filename=delta.xml
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
    vDU Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}


vDU Activate Delta Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}

    ${rtn}   Wait until keyword succeeds  600  30s
     ...   _Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}

_Activate Delta Plan Status Should Be Expected
    [Arguments]  ${operation_id}    ${plan_id}   ${expected_status}
    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}
    Log To Console      Activation_status${out["status"]}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Add Delta Plan MO
    [Arguments]  ${plan_id}   ${parent_mo_dn}   ${mo_name}    ${timeout}=60

    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.create_vdu_object_of_delta_plan   delta_plan_id=${plan_id}  parent_mo_dn=${parent_mo_dn}   mo_name=${mo_name}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Add Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}
Add Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}

    ${rtn}  wait until keyword succeeds  20   2
    ...   _Add Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}

_Add Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    ${out}   vdu.get_create_vdu_object_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Online Get VDU Parameter Value
    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}

CU Genrate Delta Plan
    [Arguments]     ${delta_plan_name}=delta_plan
    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
	...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
	[Return]    ${delta_plan_id}
    Builtin.Log     ${delta_plan_name}


CU Online Change Mo Parameters via rest
    [Arguments]     ${para_list}    ${mo_dn}   ${delta_plan_id}   ${delta_plan_name}=delta_plan
    #CU Rest Login
    Log To Console       ${para_list}

    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
    Builtin.Log     ${delta_plan_name}
CU Validate Delta Plan
    [Arguments]     ${delta_plan_id}
    ${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}

CU Activate Delta Plan
    [Arguments]     ${delta_plan_id}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}

_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}
	should be equal as strings  ${res['status']}  success

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	should be equal as strings  ${res['status']}  success

_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
	should be equal as strings  ${res['status']}  success


_Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
	should be equal as strings  ${res['status']}  success

_Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    @{name_list}=   split_string    ${mo_dn}   /
    set test variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}
    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set test variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

CU Create Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${name}  ${instance_id}

    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=${name}
    Log To Console      ${nidd_id}==>${name}
    ${nidd}  convert to string  ${nidd_id}
    ${instance}  convert to integer  ${instance_id}

    ${create_res}=   cu.create_managed_object_of_delta_plan   plan_id=${plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=True
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${create_res['action_id']}

_CU Create Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    ${res}=  cu.get_create_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success

_Get CU Specifical NIDD ID
    [Arguments]  ${name}
    @{all_nidd}   cu.get_nidd
    #Log To Console      ${all_nidd}

    FOR    ${each_nidd}    IN    @{all_nidd}
      ${nidd_id}  set variable if  '${each_nidd['class_name']}'=='${name}'   ${each_nidd["nidd_id"]}
       exit for loop if    '${each_nidd["class_name"]}'=='${name}'
    #Log To Console      @{all_nidd}
    END
    [Return]   ${nidd_id}
