*** Settings ***
Library    ./python/scf_operation.py  WITH NAME   scfconfig
Library    taf.sbts.oam.coam.admin                WITH NAME   admin

Resource    ./coam_ulm.robot
Resource    ./connect.robot
Resource    ./testline.robot
Resource    ./gnb.robot

*** Variables ***
${P_console}        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot
${COMISSIONING_REQUIRED}    ${True}
@{BTS_PROCEDURAL_STATES}             Configured    OnAir   IntegratedToRan
${MAX_WAIT_TIME_COAM_CONFIGURED}     15 min

*** Keywords ***
Execute delta commissioning
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param delta_scf_template: Path to delta SCF template
    ...    :param resultDir: Result directory to store SCF
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param component: (default=DU, options : DU/CU) If oam type is cloud coam for vRAN 1.0
    ...          the DU component is commissioned by default
    ...    :param timeout: (default=180) commisioning result timeout
    ...          delta commisioning of online modif params return result in less than 180s
    ...          when timeout expires the keyword fails
    ...          for delta commisioning with gNB reboots set timeout 600
    ...
    [Arguments]    ${delta_scf_template}    ${resultDir}    ${gnb_id}=${0}    ${component}=DU    ${timeout}=180
    Return From Keyword If    not ${COMISSIONING_REQUIRED}
    ${oam_alias}=    connect.Setup OAM session    gnb_id=${gnb_id}
    ${oam_type}=    testline.Get OAM type   gnb_id=${gnb_id}
    Run Keyword If  '${oam_type}'=='coam' or '${oam_type}'=='cloud_coam' and '${component}'=='DU'
    ...  Delta commissioning coam
    ...            delta_scf_template=${delta_scf_template}
    ...            resultDir=${resultDir}
    ...            oam_alias=${oam_alias}
    ...            gnb_id=${gnb_id}
    ...            timeout=${timeout}
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM session    connection=${oam_alias}    gnb_id=${gnb_id}


Delta commissioning coam
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param delta_scf_template: Path to delta SCF template
    ...    :param resultDir: Result directory to store SCF
    ...    :param oam_alias: Alias of OAM session
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]     ${delta_scf_template}    ${resultDir}    ${oam_alias}    ${gnb_id}=${0}    ${timeout}=180
    ${in_file_temp}=    Get file    ${delta_scf_template}
    ${out_file_temp}=    Replace variables    ${in_file_temp}
    ${scf_temp}=    Set variable    ${resultDir}/gNB${gnb_id}_delta_SCF.xml
    Create File    ${scf_temp}    ${out_file_temp}
    BuiltIn.Log    Start commissioning of gNB${gnb_id}    console=${P_console}
    ${update_status}   coam_ulm.Perform Delta SCF xml recommission
    ...    delta_scf_path=${scf_temp}
    ...    delta_operation=update
    ...    timeout=${timeout}
    ...    alias=${oam_alias}
    BuiltIn.Log    Commissioning of gNB${gnb_id} is done!    console=${P_console}
    [Return]    ${update_status}


Execute full commissioning
    [Documentation]    :Author: Jing Liang
    ...    COAM commissioning keyword
    ...    :param scf_path: Path to SCF file
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...
    [Arguments]    ${scf_path}    ${gnb_id}=0
    ${oam_alias}=    connect.Setup OAM session    gnb_id=${gnb_id}
    wait until keyword succeeds    15min   30s     coam_ulm.Verify BTS Procedural State   alias=${oam_alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}
    BuiltIn.Log    Start commissioning of gNB${gnb_id}    console=${P_console}
    admin.perform commissioning    scf_file=${scf_path}    skip_parameter_relation_errors=True    timeout=660
    ...    connection=${oam_alias}
    BuiltIn.Log    Commissioning of gNB${gnb_id} is done!    console=${P_console}
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM session    connection=${oam_alias}    gnb_id=${gnb_id}


Execute eNB full commissioning
    [Documentation]    :Author: Amr Aboushehata
    ...    COAM commissioning keyword
    ...    :param scf_path: Path to SCF file
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...
    [Arguments]    ${scf_path}    ${enb_id}=0
    ${oam_alias}=    connect.Setup eNB OAM session    enb_id=${enb_id}
    BuiltIn.Log    Start commissioning of eNB${enb_id}    console=${P_console}
    admin.perform commissioning    scf_file=${scf_path}    skip_parameter_relation_errors=True    timeout=660
    ...    connection=${oam_alias}
    BuiltIn.Log    Commissioning of eNB${enb_id} is done!    console=${P_console}
    [Teardown]    Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}


Generate Delta Commissioning File
    [Documentation]    :Author: Srihari Janardhan
    ...    COAM commissioning keyword
    ...    :param scf_path: Path to SCF file
    ...    :param parameters_list:    List of dictionary containing the distname, parameter name and desired value as shown below
    ...      ${parameter1}=  create dictionary  value=8DL4UL  dist_name=NRBTS-1/NRPMRNL-1  p_name=nrCellType
    ...      ${parameter2}=  create dictionary  value=False   dist_name=NRBTS-1/NRPMRNL-1  p_name=actUlMuMimo
    ...      ${parameter3}=  create dictionary  value=False   dist_name=NRBTS-1/NRPMRNL-1  p_name=actDlMuMimo
    ...      ${param_list}=  Create list  ${parameter1}  ${parameter2}  ${parameter3}
    ...    :target_local_path:  path where the delta commissioning file should be stored
    ...                         Default : Stored in Test Suite Config Directory with name delta_scf.xml
    ...
    [Arguments]  ${scf_path}  ${parameters_list}  ${target_local_path}=None
    ${auto_defined_target_directory}=  Get Test Suite Config Directory
    ${target_local_path}=  Set variable if  '${target_local_path}' == 'None'  ${auto_defined_target_directory}/delta_scf.xml
    ...  ${target_local_path}
    ${delta_file_path}=  scfconfig.update_scf_return_delta_scf  scf_local_path=${scf_path}  parameters_list=${parameters_list}
    ...  target_local_path=${target_local_path}
    Run Keyword and ignore Error  Check if Commissioning is needed    param_list=${parameters_list}    scf_file=${scf_path}
    [Return]  ${delta_file_path['updated_scf']}


Commission Managed Object List
    [Documentation]   :Author: Thomas Nuecker
    ...    Keyword to commissioning a Managed Object List
    ...    With a list of managed objects, the tester has the possibility to influence the operations
    ...    on different managed objects and parameters. For managed objects, the admin api supports
    ...    the operations "create", "update" and "delete". For paramters, the operation "update" leads
    ...    to an update or the creation of a paramter, "delete" gives the ability to delete an
    ...    optional parameter.
    ...
    ...    Example:
    ...
    ...     ${nrPlmnDn}=    Create Dictionary
    ...     ...     parameterName=nrPlmnDN
    ...     ...     value=
    ...     ...     operation=delete
    ...     ${NRPLMNR_1_params}=   Create List   ${nrPlmnDn}
    ...
    ...     ${NRPLMNR_1}=    Create Dictionary
    ...     ...     distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1
    ...     ...     operation=update
    ...     ...     parameters=${NRPLMNR_1_params}
    ...
    ...     ${managed_objects}=    Create List    ${NRPLMNR_1}
    ...     Commission Managed Object List    ${managed_objects}

    [Arguments]    ${managed_objects}     ${gnb_id}=${0}    ${skip_parameter_relation_errors}=${True}

    ${json_delta}=     Evaluate    json.dumps(${managed_objects})    json

    ${oam_alias}=    connect.Setup OAM session    gnb_id=${gnb_id}
    admin.Perform Delta Recommissioning
    ...     ${json_delta}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     connection=${oam_alias}

    wait until keyword succeeds  ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s
    ...     commissioning.Verify BTS Procedural State to Be Configured, online or integrated to run
    ...         alias=${oam_alias}     proceduralStates=${BTS_PROCEDURAL_STATES}

    [Teardown]    connect.Teardown OAM session    connection=${oam_alias}


Verify BTS Procedural State to Be Configured, online or integrated to run
    [Arguments]    ${alias}=cOAM    ${proceduralStates}=Configured    ${timeout}=30

    ${bts_status}=    admin.get_bts_statuses    timeout=${timeout}    connection=${alias}

    List Should Contain Value    ${proceduralStates}    ${bts_status['proceduralState']}
    should be equal    ${bts_status['blockingState']}       Unblocked      ignore_case=true

Check if Commissioning is needed
    [Documentation]     :Author:  Valentin Hirzel valentin.hirzel@nokia.com
    ...  :param_list:  The list of parameters that should be checked before executing the SCF. Schema is the same as described in
    ...  "Generate Delta Commissioning File".
    ...  This Keyword should apply to all Test-Cases, that use both the Generate Delta "Generate Delta Commissioning File"
    ...  and "Execute Delta Commissioning". The Keyword aims to reduce time spent on recurring and unnecessary SCF Commissioning.

    [Arguments]  ${param_list}  ${scf_file}
    scf.load_scf  ${scf_file}
    ${changeList}=  Create List
    FOR  ${value}  IN  @{param_list}
        ${status}  ${readValue}=  Run Keyword and ignore Error  scf.get_value_from_scf  dist_name=${value["dist_name"]}  p_name=${value["p_name"]}
        ${readValue}=  Convert to Lower Case  ${readValue}
        ${value["value"]}=  Convert to Lower Case  ${value['value']}
        ${readValue}=  Set Variable IF  '${status}'=='FAIL'  ${status}  ${readValue}
        Run Keyword IF  '${readValue}' == '${value['value']}'  BuiltIn.Log  ${value['value']} Already set  console=${P_console}
        ...  ELSE  Append to List  ${changeList}  ${value}
    END
    ${length}=  Get Length  ${changeList}
    ${COMISSIONING_REQUIRED}=  Set Variable IF  '${length}' == '0'  False  True
    BuiltIn.Log    Comissioning needed: ${COMISSIONING_REQUIRED}    console=${P_console}
