*** Settings ***
Library     OperatingSystem

Library     ./python/scf_operation.py         WITH NAME   scfconfig
Library     taf.sbts.oam.coam.admin           WITH NAME   admin
Library     python/robot_extension.py         WITH NAME   rbext_py
Library     python/testline_information.py

Resource    coam_ulm.robot
Resource    connect.robot
Resource    testline.robot
Resource    gnb.robot
Resource    scf_checks.robot

*** Variables ***
${P_console}                        ${False}           # output to console can be enabled via "Set Console Output" from testline.robot
${BTS_PROCEDURAL_STATES}            Configured, OnAir, IntegratedToRan, NotCommissioned    #NotCommissioned is for yaft sw updrage state
${MAX_WAIT_TIME_COAM_CONFIGURED}    15min

*** Keywords ***
Execute delta commissioning
    [Documentation]
    ...
    ...    | delta_scf_template | Path to delta SCF template |
    ...    | resultDir | Result directory to store SCF |
    ...    | gnb_id    | Id/Number of gNB |
    ...    | component | options : (DU|CU), if oam type is cloud coam for vRAN 1.0 |
    ...    | ..        | the DU component is commissioned by default |
    ...    | timeout   | max waiting time before KW fails |
    ...    | ..        | delta commisioning of online modif params return result in less than 180s |
    ...    | ..        | when timeout expires the keyword fails                                    |
    ...    | ..        | for delta commisioning with gNB reboots set timeout 600                   |
    ...
    ...    *Scope* classical gNB only!
    ...
    [Arguments]   ${delta_scf_template}   ${resultDir}   ${gnb_id}=${0}   ${component}=DU   ${timeout}=180
    Return From Keyword If   not ${P_COMISSIONING_REQUIRED}
    ${oam_alias}   connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='classical'   Delta commissioning coam
    ...            delta_scf_template=${delta_scf_template}
    ...            resultDir=${resultDir}
    ...            oam_alias=${oam_alias}
    ...            gnb_id=${gnb_id}
    ...            timeout=${timeout}
    [Teardown]     Set Suite Variable  ${P_COMISSIONING_REQUIRED}  ${True}


Delta commissioning coam
    [Documentation]
    ...    This KW performs delta commissioning based on a given `delta_scf_template` file.
    ...    All used variables in the xml file will be replaced by their values before commissioning.
    ...    The final delta file will be stored in `resultDir` with name gNB${gnb_id}_delta_SCF.xml.
    ...
    ...    | delta_scf_template | Path to delta SCF template |
    ...    | resultDir | Result directory to store SCF |
    ...    | oam_alias | Alias of OAM session |
    ...    | gnb_id    | Id/Number of gNB |
    ...
    [Arguments]   ${delta_scf_template}   ${resultDir}   ${oam_alias}   ${gnb_id}=${0}   ${timeout}=180
    ${in_file_temp}    OperatingSystem.Get File   ${delta_scf_template}
    ${out_file_temp}   Replace Variables   ${in_file_temp}
    ${scf_temp}        Set Variable   ${resultDir}/gNB${gnb_id}_delta_SCF.xml
    OperatingSystem.Create File   ${scf_temp}   ${out_file_temp}

    BuiltIn.Log   Start commissioning of gNB${gnb_id}   console=${P_console}
    ${update_status}   coam_ulm.Perform Delta SCF xml recommission
    ...    delta_scf_path=${scf_temp}
    ...    delta_operation=update
    ...    timeout=${timeout}
    ...    alias=${oam_alias}
    BuiltIn.Log   Commissioning of gNB${gnb_id} is done!   console=${P_console}
    [Return]   ${update_status}


Execute full commissioning
    [Documentation]
    ...    Perform full commissioning, the gNb will reboot. The max waiting time is 660s before the KW fails.
    ...    No further checks will done after the gNB becomes reachable.
    ...
    ...    | scf_path | Path to SCF file |
    ...    | gnb_id   | Id/Number of gNB |
    ...    | skip_relation_errors | whether or not to ignore relation errors (True|False) |
    ...
    ...    *Scope* classical gNB only!
    ...
    [Arguments]   ${scf_path}  ${gnb_id}=0   ${skip_relation_errors}=${True}   ${use_oam_http_connection}=${False}
    ${oam_alias}   Run Keyword If   ${use_oam_http_connection}==${True}
    ...            connect.Setup OAM http session   node_id=${gnb_id}
    ...   ELSE
    ...            connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}

    Wait Until Keyword Succeeds   15min   30s   coam_ulm.Verify BTS Procedural State   alias=${oam_alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}

    BuiltIn.Log    Start commissioning of gNB${gnb_id}   console=${P_console}
    admin.perform commissioning   scf_file=${scf_path}   skip_parameter_relation_errors=${skip_relation_errors}   timeout=660
    ...   connection=${oam_alias}
    BuiltIn.Log   Commissioning of gNB${gnb_id} is done!   console=${P_console}


Execute eNB full commissioning
    [Documentation]
    ...    COAM commissioning keyword for eNB
    ...
    ...    *Scope* classical eNB only!
    ...
    ...    | scf_path | Path to SCF file |
    ...    | enb_id   | Id/Number of eNB |
    ...
    [Arguments]   ${scf_path}   ${enb_id}=0   ${use_oam_http_connection}=${True}
    ${oam_alias}   Run Keyword If   ${use_oam_http_connection}==${True}
    ...            connect.Setup OAM http session  node_id=${enb_id}  node_type=enb
    ...   ELSE
    ...            connect.Setup eNB OAM session   enb_id=${enb_id}

    BuiltIn.Log    Start commissioning of eNB${enb_id}   console=${P_console}
    admin.perform commissioning   scf_file=${scf_path}   skip_parameter_relation_errors=True   timeout=660
    ...   connection=${oam_alias}
    BuiltIn.Log    Commissioning of eNB${enb_id} is done!   console=${P_console}
    [Teardown]   Run Keyword Unless   ${use_oam_http_connection}==${True}  Run Keyword and Ignore Error
    ...   admin.teardown   connection=${oam_alias}


Generate Delta Commissioning File
    [Documentation]
    ...    COAM commissioning keyword
    ...
    ...    *Scope* classical gNB only!
    ...
    ...    | scf_path | Path to SCF file |
    ...    | parameters_list | List of dictionary containing the distname, parameter name and desired value as shown below |
    ...    | target_local_path | path where the delta commissioning file should be stored. | 
    ...    | ..                | if not defined store in Test Suite Config Directory with name delta_scf.xml |
    ...
    ...    *Example*
    ...    |  ${parameter1} | create dictionary | value=8DL4UL | dist_name=NRBTS-1/NRPMRNL-1 | p_name=nrCellType |
    ...    |  ${parameter2} | create dictionary | value=False  | dist_name=NRBTS-1/NRPMRNL-1 | p_name=actUlMuMimo |
    ...    |  ${parameter3} | create dictionary | value=False  | dist_name=NRBTS-1/NRPMRNL-1 | p_name=actDlMuMimo |
    ...    |  ${param_list} | Create list | ${parameter1} | ${parameter2} | ${parameter3} |
    ...    |  ${uploaded_scf} | Generate Delta Commissioning File | scf_path=${TEMPDIR} | parameters_list=${param_list} |
    ...
    ...    *Returns*    path to uploaded scf file
    ...
    [Arguments]   ${scf_path}   ${parameters_list}   ${target_local_path}=${None}
    ${auto_defined_target_directory}   testline.Get Test Suite Config Directory
    ${target_local_path}   Set Variable If   '${target_local_path}'=='${None}'   ${auto_defined_target_directory}/delta_scf.xml
    ...   ${target_local_path}

    ${delta_file_path}   scfconfig.update_scf_return_delta_scf
    ...   scf_local_path=${scf_path}
    ...   parameters_list=${parameters_list}
    ...   target_local_path=${target_local_path}

    Run Keyword and Ignore Error   scf_checks.Check If Commissioning Is Needed
    ...   param_list=${parameters_list}
    ...   scf_file=${scf_path}
    [Return]   ${delta_file_path['updated_scf']}


Commission Managed Object List
    [Documentation]
    ...    Keyword for commissioning a Managed Object List.
    ...    With a list of managed objects, the tester has the possibility to influence the operations
    ...    on different managed objects and parameters. For managed objects, the admin api supports
    ...    the operations "create", "update" and "delete". For paramters, the operation "update" leads
    ...    to an update or the creation of a paramter, "delete" gives the ability to delete an
    ...    optional parameter.
    ...
    ...    *Scope* classical gNB only!
    ...
    ...    *Example*
    ...    | ${nrPlmnDn} | Create Dictionary |
    ...    | ... | parameterName=nrPlmnDN |
    ...    | ... | value= |
    ...    | ... | operation=delete |
    ...    | ${NRPLMNR_1_params} | Create List | ${nrPlmnDn} |
    ...    | ${NRPLMNR_1} | Create Dictionary |
    ...    | ... | distName=MRBTS-1/NRBTS-1/NRDRB_QCI-1 |
    ...    | ... | operation=update |
    ...    | ... | parameters=${NRPLMNR_1_params} |
    ...    | ${managed_objects} | Create List | ${NRPLMNR_1} |
    ...    | Commission Managed Object List | ${managed_objects} |
    ...
    [Arguments]   ${managed_objects}   ${gnb_id}=${0}   ${skip_parameter_relation_errors}=${True}

    ${json_delta}   Evaluate   json.dumps(${managed_objects})   json

    ${oam_alias}    connect.Setup OAM Http session   node_type=gnb   node_id=${gnb_id}
    admin.Perform Delta Recommissioning
    ...   ${json_delta}
    ...   skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...   connection=${oam_alias}

    Wait Until Keyword Succeeds   ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s
    ...   commissioning.Verify BTS Procedural State to Be Configured, Online Or Integrated To Ran
    ...   alias=${oam_alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}


Verify BTS Procedural State to Be Configured, Online Or Integrated To Ran
    [Arguments]   ${alias}=cOAM   ${proceduralStates}=Configured   ${timeout}=30

    ${bts_status}   admin.get_bts_statuses   timeout=${timeout}   connection=${alias}

    Nidd Value Should Be One Of   ${bts_status['proceduralState']}   ${proceduralStates}
    Nidd Value Should Be Equal    ${bts_status['blockingState']}     Unblocked

