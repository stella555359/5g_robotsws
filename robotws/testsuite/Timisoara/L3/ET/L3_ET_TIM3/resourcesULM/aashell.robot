*** Settings ***

Documentation
...   This robot resource file holds keywords to interact with the Aashell of a nodeb.
...   For handing of resources you can also use the following library:
...   [https://taf-ul-hanging-resources.docs.taf.ute.nsn-rdnet.net/en/latest/|taf.ul.hanging_resources]

Library    OperatingSystem

Library    taf.ccs.aashell
Library    python/connect.py            WITH NAME    connect_py
Library    python/robot_extension.py    WITH NAME    rbext_py

Resource   connect.robot
Resource   testline.robot

*** Variables ***

${P_console}              ${False}    # output to console can be enabled via "Set Console Output" from testline.robot

*** Keywords ***

Setup Aashell Session
    [Documentation]
    ...    Setup an aashell session for gNB|eNB given by ``node_id`` and ``node_type``
    ...
    ...    | node_id   | Id of nodeB as index of list in testline configuration |
    ...    | node_type | either enb or gnb |
    ...
    ...    *Returns* The alias for the just created aashell session
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${aashell_alias}   Set Variable   ${node_type}-${node_id}-aashell-session
    ${nb_test_pc}      connect_py.get_test_pc_for_nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}
    &{proxy}   Create Dictionary
    ...   host=${nb_test_pc.default_ssh_connection_details.addr}
    ...   user=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}
    &{hops}  Create Dictionary  proxy=${proxy}

    Run Keyword If   "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
    ...          create_aashell_cli   name=${aashell_alias}
    ...   ELSE   create_aashell_cli   name=${aashell_alias}   hops=${hops}   forwarding_port=1501${node_id}
    taf.ccs.aashell.setup   ${aashell_alias}
    taf.ccs.aashell.set suite alias   ${aashell_alias}
    [Return]   ${aashell_alias}


Teardown Aashell Session
    [Documentation]
    ...    teardown aashell session for the node defined by ``node_type`` and ``node_id``
    ...
    ...    | node_id   | Id of nodeB as index of list in testline configuration |
    ...    | node_type | either enb or gnb |
    ...
    ...    *Return* The status the teardown of taf.ccs.aashell.
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${status}   rbext_py.run_keyword_and_warn_on_failure
    ...   taf.ccs.aashell.teardown  alias=${node_type}-${node_id}-aashell-session
    [Return]   ${status}


Execute Aashell Command on Node
    [Documentation]
    ...    Executes an aashell command on the node defined by ``node_type`` and ``node_id``
    ...    The Keywords will create and teardown the corresponding aashell session.
    ...
    ...    | command   | command to be executed |
    ...    | node_id   | Id of nodeB as index of list in testline configuration |
    ...    | node_type | either enb or gnb |
    ...
    ...    *Return* The output of the executed aashell command.
    [Arguments]   ${command}   ${node_id}=${0}   ${node_type}=gnb   
    
    ${aashell_alias}    Setup Aashell Session   node_id=${node_id}   node_type=${node_type}
    ${aashell_output}   taf.ccs.aashell.Execute aashell command   name=${aashell_alias}   command=${command}
     
    [Return]     ${aashell_output}
    [Teardown]   Teardown Aashell Session    node_id=${node_id}   node_type=${node_type}


Get Resource Usage From Node
    [Documentation]
    ...    Wraps the aashell command ``get_resources_usage``
    ...    The Keywords will create and teardown the corresponding aashell session.
    ...
    ...
    ...    | detailed  | Short or long format of the command output  |
    ...
    ...    *Return* The resource data provided by taf.ccs.aashell.
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${detailed}=${False}
    ${sw_branch}   testline.Get gNB SW branch   ${node_id}
    Run Keyword If  '${sw_branch}'=='SBTS22R1' or '${sw_branch}'=='SBTS22R2'  
    ...  Return from Keyword  

    ${result}  taf.ccs.aashell.get_resources_usage
    ...   name=${node_type}-${node_id}-aashell-session   detailed=${detailed}
    [Return]   ${result}


Store Resource Usage Output
    [Documentation]
    ...    Keyword to store the output from resource usage to test case log folder
    ...
    ...
    ...    | logfilename      | name for logfile, will be written to testcase_log_dir |
    ...    | resource_result  | output from KW "Get resource usage from node" |
    ...
    [Arguments]   ${logfilename}   ${resource_result}
    ${dir}   testline.Get testcase log directory
    ${string_result}   Evaluate   json.dumps(${resource_result})   json
    OperatingSystem.Create File   ${dir}/${logfilename}   ${string_result}


Store Deepdiff Result
    [Documentation]
    ...    Keyword to execute a deepdiff on the resources ``resource_1`` and ``resource_2``.
    ...    The result will be written to the file ``differences.txt``. This file is stored in 
    ...    the test case result directory.
    ...
    [Arguments]   ${resource_1}   ${resource_2}
    ${dir}   testline.Get testcase log directory
    ${diff_filename}   Set Variable   differences.txt
    ${diff_result}   Evaluate   deepdiff.DeepDiff(${resource_1}, ${resource_2})   deepdiff
    ${diff_result_str}   Convert To String   ${diff_result}
    OperatingSystem.Create File   ${dir}/${diff_filename}   ${diff_result_str} 


Compare Resource Usage
    [Documentation]
    ...    Wrapper for the aashell command ``should be equal as resources``
    ...
    ...
    ...    | resource_1 | resource_file                                             | 
    ...    | resource_2 | resource_file                                             | 
    ...    | exclude    | specify what should be not compared                       | 
    ...    | ignore     | boolean, if set to false KW will fail if resources differ | 
    ...
    ...    *Return* The status of the aashell execution as boolean value.
    [Arguments]   ${resource_1}   ${resource_2}   ${exclude}=//bufferPoolFreeCount   ${ignore}=${True}
    ${sw_branch}   testline.Get gNB SW branch
    Run Keyword If   '${sw_branch}'=='SBTS22R1' or '${sw_branch}'=='SBTS22R2'  
    ...   Return from Keyword

    ${status}   Run Keyword And Return Status   taf.ccs.aashell.Should Be Equal As Resources
    ...   ${resource_1}
    ...   ${resource_2}
    ...   exclude=${exclude}
    Run Keyword Unless   ${status}
    ...    Store Resource Usage Output   compare_file_1.json   ${resource_1}
    Run Keyword Unless   ${status}
    ...    Store Resource Usage Output   compare_file_2.json   ${resource_2}
    Run Keyword Unless   ${status}
    ...    BuiltIn.Log   [INFO] Resource usage differs!   console=${P_console}
    Run Keyword Unless   ${status}
    ...    Store Deepdiff Result   ${resource_1}   ${resource_2}
    Run Keyword Unless   ${ignore}
    ...    Run Keyword And Continue On Failure   Should Be True   '${status}'=='${True}'
    [Return]    ${status}
