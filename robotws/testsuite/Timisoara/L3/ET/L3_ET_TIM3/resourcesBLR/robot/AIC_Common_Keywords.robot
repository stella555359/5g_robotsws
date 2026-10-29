*** Settings ***
Library             OperatingSystem
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Resource            taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource            taf/rfrl/cbts/robot/vcu/vcu_cm.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Library             String
Library             SSHLibrary
Resource            Common_Keywords.robot
Resource           taf/rfrl/common_resources/robot/coam.robot
Resource           Setup_Env.robot
Resource           Airphone.robot
Resource           common_log_collection.robot


*** Variables ***
@{NR_cell1}   NRCELL-1
${HOST_IP}    192.168.200.1
${USERNAME}   toor4nsn
${PASSWORD}   oZPS0POrRieRtu


*** Keywords ***
Prepare AIC TL with all config files
    [Arguments]    ${vcu_scf_path}    ${vdu_scf_path}    ${RMOD_name}    ${iphy_xml_path}
    [Documentation]  This Keyword takes input of vCU,vDU,RMOD,iphyxml file path from the user
    ...  and do vCU full commissioning ,updates TL specific fhuc vlan in vDU scf ,vDU commissioning
    ...  greps TargetBD contents from vDU and updates in iphyxml along with TL specific fhm vlan
    ...  author:shekhar_vijay.barewar@nokia.com
    ${Plan_vcu_scf_path}      Fetch From Right    ${vcu_scf_path}    /
    ${Plan_vcu_scf_path}      Catenate    SEPARATOR=    Plan_    ${Plan_vcu_scf_path}
    Run Keywords    log to console    vCU commissioning with ${Plan_vcu_scf_path} started
    ...    AND    CU Full Commssion By Rest   ${vcu_scf_path}    ${Plan_vcu_scf_path}
    ...    AND    Grep vDU FHUC vlanid from default path and Replace in vDU delta_or_Scf file  ${vdu_scf_path}
    ...    AND    log to console    vDU commissioning started
    ...    AND    vDU Send Commission By RestApi   ${vdu_scf_path}
    ...    AND    Update vDU TargetBDxml contents in AP_iphyxml    ${RMOD_name}    ${iphy_file_path}
    ...    AND    AP Reboot Wait For Connection    ${120}
    ...    AND    Verify RMODs Online Status   ${300}
Update vDU TargetBDxml contents in AP_iphyxml
    [Arguments]    ${RMOD_name}    ${iphy_xml_path}
    ${alias}    get_unique_id_string
    ssh_conn.Connect To Vdu Cloud Hosting    using_tenant=${True}   prompt=${EMPTY}   vdu_index=0   gnb_index=0
    ...  alias=${alias}
    ${ns}   tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${preferredVlanId}     Grep vDU FHM vlanid from default path
    ${Build_version}  ${SwFileKey_version}=      Grep Build and SwFileKey version from vDU_TargetBDxml   ${ns}   ${alias}    ${RMOD_name}
    Set Suite Variable  ${preferredVlanId}
    Set Suite Variable  ${Build_version}
    Set Suite Variable  ${SwFileKey_version}
    Update the Contents in Iphyxml    ${iphy_xml_path}

Grep Build and SwFileKey version from vDU_TargetBDxml
    [Arguments]    ${namespace}   ${alias}    ${RMOD_name}=AEQP
    ${TargetBDfile_Contents}=      ssh_conn.execute_kubectl_exec_cmd
    ...  pod_name=oamfh-0
    ...  container_name=oamfh
    ...  namespace=${namespace}
    ...  conn_alias=${alias}
    ...  command=bash -c "grep -i ${RMOD_name} /ffs/run/RFSW/*.xml"
    ${Bld_version}    Get Regexp Matches    ${TargetBDfile_Contents}    resourceSWVersion="(.*?)"
    ${Bld_version}    Get From List     ${Bld_version}    index=0
    ${Bld_version}    Fetch From Right  ${Bld_version}  resourceSWVersion=
    ${Bld_version}=    Replace String   ${Bld_version}  "  ${empty}
    ${SwFlKey_version}    Get Regexp Matches    ${TargetBDfile_Contents}    <swFileKey>(.*?)</swFileKey>
    ${SwFlKey_version}    Get From List     ${SwFlKey_version}    index=0
    ${SwFlKey_version}    Fetch From left   ${SwFlKey_version}     </swFileKey>
    ${SwFlKey_version}=    Fetch From Right    ${SwFlKey_version}    <swFileKey>
   [Return]    ${Bld_version}  ${SwFlKey_version}
Grep vDU FHM vlanid from default path
    ${fhm_section}    Run   grep -A 2 "fhm:" ~/testline_init_results/execution/configs/testline_configuration/vdu-cnf.yaml |grep -Eo '[^"]+'
    ${fhmvlan}=   Get Regexp Matches    ${fhm_section}   \\d+
    [Return]    ${fhmvlan}
Update the Contents in Iphyxml
    [Arguments]    ${iphy_path}
    ${cmd1}  Set Variable   sed -i 's|<bldVersion>.*</bldVersion>|<bldVersion>${Build_version}</bldVersion>|g' ${iphy_path}
    ${cmd2}  Set Variable   sed -i 's|<buildversion>.*</buildversion>|<buildversion>${Build_version}</buildversion>|g' ${iphy_path}
    ${cmd3}  Set Variable   sed -i 's|<version>.*</version>|<version>${Build_version}</version>|g' ${iphy_path}
    ${cmd4}  Set Variable   sed -i 's|<preferredVlanId>.*</preferredVlanId>|<preferredVlanId>${preferredVlanId}[0]</preferredVlanId>|g' ${iphy_path}
    ${cmd5}  Set Variable   sed -i 's|<name>.*</name>|<name>${SwFileKey_version}</name>|g' ${iphy_path}
    ${cmd6}  Set Variable   scp ${iphy_path} toor4nsn@192.168.200.1:/rom/simmode/iphy.xml
    ${status1}    run    ${cmd1}
    ${status2}    run    ${cmd2}
    ${status3}    run    ${cmd3}
    ${status4}    run    ${cmd4}
    ${status5}    run    ${cmd5}
    ${status6}    run    ${cmd6}
    log to console   build_swkeyfile_version_vlan updated and iphy pushed successfully
#    Open Connection     ${HOST_IP}
#    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
Grep vDU FHUC vlanid from default path and Replace in vDU delta_or_Scf file
    [Arguments]    ${File_path}
    Log to console  Searching the vDU FHUC vlan from testline init result default path
    ${vlanid} =   run    command=grep -i "fhuc_vlans" ~/testline_init_results/execution/configs/testline_configuration/__init__.py -m 1
    BuiltIn.log     ${vlanid}
    Log to console    changing vlan value
    ${vlan}     Get Regexp Matches     ${vlanid}     \\d+
    ${cmd}    Set Variable    sed -i 's|<p name="vlanId">.*</p>|<p name="vlanId">${vlan}[0]</p>|g' ${File_path}
    ${status}    run    command=${cmd}
    Builtin.log       changing vlan changed done with ${vlan}
    Log to console    changing vlan changed done with ${vlan}
vDU Rest Login
    [Arguments]  ${restapi_version}=cuoam_19b  ${vdu_index}=0  ${gnb_index}=0  ${alias}=default
    [Documentation]  login vdu webem.
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ${oam_httpaddr}   set variable   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_19b'  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE  vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}


vDU Rest Logout
    [Arguments]  ${vdu_index}=0  ${alias}=default
    [Documentation]  vDU Rest Logout
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...   11.9.2020,chris.l.cao@nokia-sbell.com, change to use 'Wait Until VDU OAM Up'
    ...
    vdu.disconnect  ${alias}

Get Plan file vDU
    [Arguments]  ${local_path}   ${file_name}    ${runtime_data}
    [Documentation]  Get Plan file vDU
    ...  history change:
    ...  author:vivek.gv@nokia.com
    ...    history change: <date>,<who>,<what and how>
    ...
    vDU Rest Login
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${local_path}  filename=${file_name}  include_runtime_data=${runtime_data}
    [Teardown]      vDU Rest Logout
    [return]    ${scf_file_with_fullpath}

vDU Send Commission By RestApi
    [Arguments]  ${scf_path}    ${restapi_version}=cuoam_19b   ${vdu_index}=0
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.32021, calla.wang@nokia-sbell.com, add sleeping after activated plan file to ensure the restapi can be connected
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    None
    log to console  \n*** start send commission on vdu ***
    vDU Rest Login  ${restapi_version}  ${vdu_index}
    ${upload_plan_response}=  vdu.upload_plan    ${scf_path}
    wait until keyword succeeds  2min  5s  Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  2min  5s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    sleep  90s
    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}
    [Teardown]      vDU Rest Logout

Upload Plan Operation Should Be Successful
    [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  23.7.2020,chris.l.cao@nokia-sbell.com, add retry mechanism
    ...  13.8.2020,chris.l.cao@nokia-sbell.com, extend retry window from 20s to 240s
    ...  11.3.2021,calla.wang@nokia-sbell.com, restore the previous logic, no need to login vdu once again and nested wait until
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
#    ${rtn}  Wait Until Keyword Succeeds  600   20
#     ...   Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
#     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    [Return]  ${rtn}


VDU Save Active Alarm To A File
    [Arguments]  ${Start_End}   ${file_name}  ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: vivek.gv@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | Start_End  | Man | "Start" if you start at begining of test-execution, "End" if triggred after execution |
    ...    | file_name  | man | name of the logfile |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Save Active Alarm To A File |
    ...
    vdu rest login   vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    ${out}  convert to string  ${out}
    dictionary_to_file    ${out}   ${file_name}_${Start_End}
    Builtin.log     ${out}


VDU Save Historical Alarm To A File
    [Arguments]   ${Start_End}  ${file_name}    ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: vivek.gv@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | Start_End  | Man | "Start" if you start at begining of test-execution, "End" if triggred after execution |
    ...    | file_name  | Man | name of the logfile |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Save Historical Alarm To A File |
    ...
    vdu rest login   vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_historical_alarms
    ${out}  convert to string  ${out}
    dictionary_to_file   ${out}   ${file_name}_${Start_End}
    Builtin.log     ${out}


dictionary_to_file
    [Arguments]     ${dict_values}       ${file_path}
    [Documentation]  dictionary_to_yaml_file
    ...    author: vivek.gv@nokia.com
    Create File     ${EXECDIR}/${file_path}     ${dict_values}

CU Rest Login
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_21b
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...                             other senarios should be use default value - cuoam_19b |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |  CU Rest Login   |    0   |
    ${host}   set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    #${host}   set variable if   ':' in '''${host_ip}'''   [${host_ip}]    ${host_ip}
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    #...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

CU Rest Logout
    [Arguments]  ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    cu.disconnect   connection=${connection}

Get Plan file CU
    [Arguments]  ${plan_file_path}
    [Documentation]  Get Plan file CU
    ...  history change:
    ...  author:vivek.gv@nokia.com
    ...    history change: <date>,<who>,<what and how>
    ...
    CU Rest Login
    cu.Get_Current_Plan_File  path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    [Teardown]      CU Rest Logout
    [return]

VCU Save Active Alarm To A File
    [Arguments]  ${Start_End}   ${file_name}
    [Documentation]  VCU Save  Alarm To A File
    ...    author: vivek.gv@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | Start_End  | Man | "Start" if you start at begining of test-execution, "End" if triggred after execution |
    ...    | file_name  | man | name of the logfile |
    ...    | vcu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Save Active Alarm To A File |
    ...
    CU Rest Login
    ${out}    cu.get_active_alarms
    ${out}  convert to string  ${out}
    dictionary_to_file    ${out}   ${file_name}_${Start_End}
    Builtin.log     ${out}
    [Teardown]      CU Rest Logout

VCU Save Historical Alarm To A File
    [Arguments]   ${Start_End}  ${file_name}
    [Documentation]  VCU Save Historical Alarm To A File
    ...    author: vivek.gv@nokia.com
    ...    | Input Parameters | Man. | Description |
    ...    | Start_End  | Man | "Start" if you start at begining of test-execution, "End" if triggred after execution |
    ...    | file_name  | Man | name of the logfile |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Save Historical Alarm To A File |
    ...
    CU Rest Login
    ${out}    cu.get_historical_alarms
    ${out}  convert to string  ${out}
    dictionary_to_file   ${out}   ${file_name}_${Start_End}
    Builtin.log     ${out}
    [Teardown]      CU Rest Logout

CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest   ${alias}=${None}   ${restapi_version}=cuoam_21b
    [Documentation]  Login to CU via rest or webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  solution | No |  rest or webui, rest in default |
    ...    |  alias | No. | alias that identifies this connection, if the argument is given,
    ...                     the alias must be given to the CU Logout keyword as connection argumument. |

    ...    *RETURN VALUE*
    ...    the restapi connection alias
    ...    Example
    ...    |  CU Login  |     |
    ${alias}=   run keyword if  "${solution}"=="rest"    CU Rest Login   ${gnb_index}  ${alias}   ${restapi_version}
    #...   ELSE    CU Webui Login    ${gnb_index}
    [Return]   ${alias}

CU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via rest.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  path_of_commission_file  | Yes. | Path of commission file |
        ...    |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commssion By Rest  |   /tmp/commission.xml  |    3219_plan_file   |
     CU Login  ${gnb_index}
     log to console   \n*** Start plan upload operation on VCU***
     ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
     log to console   \n*** Wait plan upload operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    ${upload_operation_info["action_id"]}    success
     log to console   \n*** Start plan validate operation ***
     ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan validate operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
     log to console   \n*** Start plan activate operation ***
     ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan activate operation success in 5 mins ***
     wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
     [Teardown]    run keyword and ignore error   CU Logout

CU Check Plan Upload Status Should Be As Expected
   [Arguments]  ${operation_id}   ${expected_status}
   [Documentation]   Check plan upload status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  operation_id  | Yes. |  Operation id for uploading plan file  |
        ...    |  expected_status  | Yes. |  Expected upload status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Upload Status Should Be As Expected   |  a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success   |
   ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"


CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...    |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Validate Status Should Be As Expected  |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"


CU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan activate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  plan_id  | Yes. |  Plan file id  |
        ...    |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...    |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Activate Status Should Be As Expected   |  sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
   ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"


CU Logout
    [Arguments]     ${solution}=rest   ${connection}=${None}
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${solution}"=="rest"    CU Rest Logout  ${connection}
    #...   ELSE    CU Webui Logout

CU Get SW Version
    CU Rest Login
    ${vCUswVersion}         cu.get active software version
    Builtin.log      ${vCUswVersion}
    CU Rest Logout
    [return]    ${vCUswVersion}

AIC Verify RMODs Online Status
    [Arguments]  ${WaitTimeInSec}
    [Documentation]
    ...  history change:
    ...  author:vivek.gv@nokia.com
    ...
    log to console      "\n ---> Verify RMODs Online Status <---"
    ${oam_httpaddr}   set variable   ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ${oam_web_ip}   set variable if   ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Verify RMODs Are Enabled      ${oam_web_ip}     ${WaitTimeInSec}


Fast Delta Commission vDU With Delta XML File
    [Arguments]     ${delta_du}    ${timeout}=${600}
#    [Tags]  xml_delta_commission_vdu
    vdu_cm.Fast Delta Commissioning With Delta XML File     ${delta_du}    timeout=${timeout}

Fast Delta Commission vCU Using Delta XML File
    [Arguments]     ${delta_cu}    ${timeout}=${600}
#    [Tags]  xml_delta_commission_cu
    vcu_cm.Fast Delta Commissioning With Delta XML File    ${delta_cu}    timeout=${timeout}

Start L2Ps TTI logs from vDU
    [Arguments]   ${Cell_list}=${NR_cell1}
    [Documentation]   Keyword is required to pass cell list as an argument
	...  example:  @{cell_list}   NRCELL-1  NRCELL-2  ---> for cell1 and cell2
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=Nokia@123
    ${nr_cell_dns}   Create List
    FOR  ${cell}  IN  @{Cell_list}
         Append To List   ${nr_cell_dns}   MRBTS-1/NRBTS-1/${cell}
    END
    ${l2_stream_config}=  Create Dictionary
    ...  trace_type=Component
    ...  target_component=L2Ps
    ...  nr_cell_dn_list=${nr_cell_dns}
    @{l2_stream_configuration}    Create List    ${l2_stream_config}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth9 udp and dst 172.16.2.10 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create vdu l2stream collector
    ...  name=l2stream
    ...  webservice=${webservice}
    ...  destination_ip_addr=172.16.2.10
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    l2stream3.Set Suite Alias     l2stream
    core.setup_collectors      names=l2stream
    core.start_collectors      names=l2stream

Stop L2Ps TTI logs from vDU
    [Arguments]   ${test_scenario}=ttitracelog
    ${common_log_path}      Create Dictionary
    ${log_dir_gnb}           Set Variable          ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${test_scenario}
    Set suite Variable       ${log_dir_gnb}
    core.stop_collectors      names=l2stream
    core.collect_collectors      names=l2stream  target_dir=${log_dir_gnb}
    core.teardown_collectors      names=l2stream
    Move File    ${log_dir_gnb}/l2stream/tcpdump/tcpdump.pcap   ${log_dir_gnb}/tcpdump_ttitrace.pcap
    Set To Dictionary     ${common_log_path}        ttitrace    ${log_dir_gnb}
    [Return]        ${common_log_path}
