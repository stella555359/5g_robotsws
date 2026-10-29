*** Settings ***

Documentation
...   This robot resource file holds keywords for commissioning on classical gNB.
...   It provides functions to perform full and delta changes as well as other support KWs.
...   For delta commissioning 2 different approaches are used:
...   1. data are stored in parameter dictionaries
...   2. path to prepared SCF file

Library     OperatingSystem

Library     python/scf_operation.py          WITH NAME   scfconfig
Library     taf.sbts.oam.coam.admin          WITH NAME   admin
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
Execute Delta Commissioning
    [Documentation]
    ...
    ...    | delta_scf_template | Path to delta SCF template |
    ...    | resultDir | Result directory to store SCF |
    ...    | gnb_id    | Id/Number of gNB |
    ...    | component | options : (DU|CU), if oam type is cloud coam for vRAN 1.0 |
    ...    | ..        | the DU component is commissioned by default |
    ...    | skip_parameter_relation_errors | whether or not to ignore relation errors (True|False) |
    ...    | timeout   | max waiting time before KW fails |
    ...    | ..        | delta commisioning of online modif params return result in less than 180s |
    ...    | ..        | when timeout expires the keyword fails                                    |
    ...    | ..        | for delta commisioning with gNB reboots set timeout 600                   |
    ...
    ...    *Scope* classical gNB only!
    ...
    [Arguments]   ${delta_scf_template}   ${resultDir}   ${gnb_id}=${0}   ${skip_parameter_relation_errors}=False    ${timeout}=180
    IF   not ${P_COMISSIONING_REQUIRED}   RETURN
    ${oam_alias}   connect.Setup OAM HTTP Session   node_type=gnb   node_id=${gnb_id}
    IF   '${tl_info.deployment_type(${gnb_id})}'=='classical'
        Delta Commissioning COAM
        ...            delta_scf_template=${delta_scf_template}
        ...            resultDir=${resultDir}
        ...            oam_alias=${oam_alias}
        ...            gnb_id=${gnb_id}
        ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
        ...            timeout=${timeout}
    END
    [Teardown]     Set Suite Variable  ${P_COMISSIONING_REQUIRED}  ${True}


Delta Commissioning COAM
    [Documentation]
    ...    This KW performs delta commissioning based on a given `delta_scf_template` file.
    ...    All used variables in the xml file will be replaced by their values before commissioning.
    ...    The final delta file will be stored in `resultDir` with name gNB${gnb_id}_delta_SCF.xml.
    ...
    ...    | delta_scf_template             | Path to delta SCF template |
    ...    | resultDir                      | Result directory to store SCF |
    ...    | oam_alias                      | Alias of OAM session |
    ...    | gnb_id                         | Id/Number of gNB |
    ...    | skip_parameter_relation_errors | whether or not to ignore relation errors (True|False) |
    ...    | timeout                        | timeout in s for commissioning, until commissioning will be failed |
    ...
    [Arguments]   ${delta_scf_template}   ${resultDir}   ${oam_alias}   ${gnb_id}=${0}   ${skip_parameter_relation_errors}=False    ${timeout}=180
    ${in_file_temp}    OperatingSystem.Get File   ${delta_scf_template}
    ${out_file_temp}   Replace Variables   ${in_file_temp}
    ${scf_temp}        Set Variable   ${resultDir}/gNB${gnb_id}_delta_SCF.xml
    OperatingSystem.Create File   ${scf_temp}   ${out_file_temp}

    Log   Start commissioning of gNB${gnb_id}   console=${P_console}
    ${update_status}   coam_ulm.Perform Delta SCF XML Recommission
    ...    delta_scf_path=${scf_temp}
    ...    delta_operation=update
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    timeout=${timeout}
    ...    alias=${oam_alias}
    Log   Commissioning of gNB${gnb_id} is done!   console=${P_console}
    RETURN   ${update_status}


Execute Full Commissioning
    [Documentation]
    ...    Perform full commissioning, the gNb will reboot.
    ...    No further checks will done after the gNB becomes reachable.
    ...
    ...    | scf_path | Path to SCF file |
    ...    | gnb_id   | Id/Number of gNB |
    ...    | skip_relation_errors | whether or not to ignore relation errors (True|False) |
    ...    | timeout | timeout in s for commissioning, until commissioning will be failed |
    ...
    ...    *Scope* classical gNB only!
    ...
    [Arguments]   ${scf_path}  ${gnb_id}=0   ${skip_relation_errors}=${False}   ${use_oam_http_connection}=${False}    ${timeout}=660
    IF   ${use_oam_http_connection}==${True}
        ${oam_alias}     connect.Setup OAM HTTP Session   node_id=${gnb_id}
    ELSE
        ${oam_alias}     connect.Setup OAM HTTP Session   node_type=gnb   node_id=${gnb_id}
    END


    Wait Until Keyword Succeeds   15min   30s   coam_ulm.Verify BTS Procedural State   alias=${oam_alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}

    Log    Start commissioning of gNB${gnb_id}   console=${P_console}
    admin.Perform Commissioning   scf_file=${scf_path}   skip_parameter_relation_errors=${skip_relation_errors}   timeout=${timeout}
    ...   connection=${oam_alias}
    Log   Commissioning of gNB${gnb_id} is done!   console=${P_console}


Teardown Session After ENB Full Commissioning
    [Documentation]
    ...    This KW is a WA to allow confitional Teardown execution with 'IF' marker.
    ...
    ...    *Scope* classical eNB only!
    ...
    ...    | use_oam_http_connection | boolean defining if the session should be terminated |
    ...    | alias                   | admin session alias |
    ...
    [Arguments]   ${use_oam_http_connection}   ${alias}
    IF    ${use_oam_http_connection} != ${True}
        TRY
            admin.Teardown    connection=${alias}
        EXCEPT
            Log    Teardown failed but continuing    WARN
        END
    END


Execute ENB Full Commissioning
    [Documentation]
    ...    COAM commissioning keyword for eNB
    ...
    ...    *Scope* classical eNB only!
    ...
    ...    | scf_path | Path to SCF file |
    ...    | enb_id   | Id/Number of eNB |
    ...    | skip_relation_errors | whether or not to ignore relation errors (True|False) |
    ...    | timeout | timeout in s for commissioning, until commissioning will be failed |
    ...
    [Arguments]   ${scf_path}   ${enb_id}=0   ${use_oam_http_connection}=${True}    ${skip_relation_errors}=False    ${timeout}=660

    IF   ${use_oam_http_connection}==${True}
        ${oam_alias}     connect.Setup OAM HTTP Session  node_id=${enb_id}  node_type=enb
    ELSE
        ${oam_alias}     connect.Setup ENB OAM Session   enb_id=${enb_id}
    END

    Log    Start commissioning of eNB${enb_id}   console=${P_console}
    admin.Perform Commissioning   scf_file=${scf_path}   skip_parameter_relation_errors=${skip_relation_errors}    timeout=${timeout}
    ...   connection=${oam_alias}
    Log    Commissioning of eNB${enb_id} is done!   console=${P_console}

    [Teardown]   Teardown Session After ENB Full Commissioning
                 ...   use_oam_http_connection=${use_oam_http_connection}
                 ...   alias=${oam_alias}


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

    ${delta_file_path}   scfconfig.Update SCF Return Delta SCF
    ...   scf_local_path=${scf_path}
    ...   parameters_list=${parameters_list}
    ...   target_local_path=${target_local_path}

    Run Keyword And Ignore Error   scf_checks.Check If Commissioning Is Needed
    ...   param_list=${parameters_list}
    ...   scf_file=${scf_path}
    RETURN   ${delta_file_path['updated_scf']}


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
    [Arguments]   ${managed_objects}   ${gnb_id}=${0}   ${skip_parameter_relation_errors}=${False}

    ${json_delta}   Evaluate   json.dumps(${managed_objects})   json

    ${oam_alias}    connect.Setup OAM HTTP Session   node_type=gnb   node_id=${gnb_id}
    admin.Perform Delta Recommissioning
    ...   ${json_delta}
    ...   skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...   connection=${oam_alias}

    Wait Until Keyword Succeeds   ${MAX_WAIT_TIME_COAM_CONFIGURED}   30s
    ...   commissioning.Verify BTS Procedural State To Be Configured, Online Or Integrated To Ran
    ...   alias=${oam_alias}
    ...   proceduralStates=${BTS_PROCEDURAL_STATES}


Verify BTS Procedural State To Be Configured, Online Or Integrated To Ran
    [Arguments]   ${alias}=cOAM   ${proceduralStates}=Configured   ${timeout}=30

    ${bts_status}   admin.Get BTS Statuses   timeout=${timeout}   connection=${alias}

    Nidd Value Should Be One Of   ${bts_status['proceduralState']}   ${proceduralStates}
    Nidd Value Should Be Equal    ${bts_status['blockingState']}     Unblocked

