*** Settings ***

Documentation
...   This robot resource file holds keywords to interact with the Aashell of a nodeb.
...   For handing of resources you can also use the following library:
...   [https://taf-ul-hanging-resources.docs.taf.ute.nsn-rdnet.net/en/latest/|taf.ul.hanging_resources]

Library    OperatingSystem

Library    taf.ccs.aashell
Library    ../python/connect.py                                      WITH NAME    connect_py
Library    ../../../../resources/DSS/python/robot_extension.py       WITH NAME    robot_extension
Library    ../python/tools.py                                        WITH NAME    nps_fct_tools

Resource   testcase-Keywords.robot

*** Variables ***
${default_value}         No match found

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

    &{default_hop}   Create Dictionary
    ...   host=192.168.255.129
    ...   user=toor4nsn
    ...   password=oZPS0POrRieRtu

    &{proxy}   Create Dictionary
    ...   host=${nb_test_pc.default_ssh_connection_details.addr}
    ...   user=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}

    &{hops}  Create Dictionary
    ...   host=192.168.255.129
    ...   user=toor4nsn
    ...   password=oZPS0POrRieRtu
    ...   proxy=${proxy}

    Run Keyword If   "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
    ...          create_aashell_cli   name=${aashell_alias}   hops=${default_hop}
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
    ${status}   robot_extension.run_keyword_and_warn_on_failure
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

    ${aashell_alias}    aashell.Setup Aashell Session   node_id=${node_id}   node_type=${node_type}
    ${aashell_output}   taf.ccs.aashell.Execute aashell command   name=${aashell_alias}   command=${command}

    [Return]     ${aashell_output}
    [Teardown]   aashell.Teardown Aashell Session    node_id=${node_id}   node_type=${node_type}


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
    ${dir}   testcase-Keywords.Get testcase log directory
    ${string_result}   Evaluate   json.dumps(${resource_result})   json
    OperatingSystem.Create File   ${dir}/${logfilename}   ${string_result}


Store Deepdiff Result
    [Documentation]
    ...    Keyword to execute a deepdiff on the resources ``resource_1`` and ``resource_2``.
    ...    The result will be written to the file ``differences.txt``. This file is stored in
    ...    the test case result directory.
    ...
    [Arguments]   ${resource_1}   ${resource_2}
    ${dir}   testcase-Keywords.Get testcase log directory
    ${diff_filename}   Set Variable   differences.txt
    ${diff_result}   Evaluate   deepdiff.DeepDiff(${resource_1}, ${resource_2})   deepdiff
    ${diff_result_str}   Convert To String   ${diff_result}
    OperatingSystem.Create File   ${dir}/${diff_filename}   ${diff_result_str}


Set Rad Parameter Using Aashell
    [Documentation]
    ...     This keyword sets the rnd params in the common module.
    ...
    ...     | rad_param       | rad param to set |
    ...     | rad_param_value | value for rad param |
    ...     | gnb_id          | Id of gnb [0.. ] |
    ...     | du_id           | Id of DU [0.. ] |
    ...
    [Arguments]   ${rad_param}   ${rad_param_value}   ${gnb_id}=${0}   ${du_id}=${0}
    BuiltIn.log     du_id=${du_id}
    aashell.Execute Aashell Command on Node     command=rad -mw ${rad_param} ${rad_param_value}\r
    ...                                         node_id=${gnb_id}   node_type=gnb

Extract Hexadecimal Value
    [arguments]       ${nonDefaultRadMaster}    ${rad_param}=${EMPTY}
    return from keyword if    '${rad_param}'=='${EMPTY}'    ${default_value}
    ${pattern}    Set Variable    \\[${rad_param}\\] '.*' = (0x[a-fA-F0-9]+)
    # dated log     pattern=${pattern}
    ${matches}    String.Get Regexp Matches    ${nonDefaultRadMaster}    ${pattern}    1
    ${matches_found}=     set Variable if  ${matches}   ${matches[0]}    ${default_value}
    [return]   ${matches_found}


Get Rad Value Using Aashell
    [Documentation]
    ...     This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     | rad_param | Rad Parameter [0x580017] |
    ...     | gnb_id    | Id of gnb [0.. ]         |
    ...     | du_id     | Id of DU [0.. ]          |
    ...
    ...    *Returns* IF rad_param is empty prints all non default R&D parameters of RadMaster.
    ...              Else the "Current val" of rad_param. in a list e.g.: [u'0x0']
    ...
    [Arguments]   ${rad_param}=${EMPTY}   ${gnb_id}=${0}   ${du_id}=${0}

     BuiltIn.log     du_id=${du_id}
    ${uppercase_rad_param}    Convert To Upper Case    ${rad_param}
    ${domain}=   nps_fct_tools.extract domain from rad  ${uppercase_rad_param}

    ${nonDefaultRadMaster}    Run Keyword    aashell.Execute Aashell Command on Node   command=rad -mr ${domain} \r
    ...                                                                                node_id=${gnb_id}   node_type=gnb
    # dated log     nonDefaultRadMaster=${nonDefaultRadMaster}

    ${radMasterValue}   Run Keyword If   '${rad_param}'=='${EMPTY}'    Set Variable                 ${nonDefaultRadMaster}
    ...                     ELSE                                       Extract Hexadecimal Value    ${nonDefaultRadMaster}  ${rad_param}

    # ${radMasterValue_2}   Run Keyword If   '${rad_param}'=='${EMPTY}'    Set Variable                 ${nonDefaultRadMaster}
    # ...   ELSE          String.Get regexp matches   ${nonDefaultRadMaster}
    # ...                 \\[${rad_param}\\] '.*' = (0x[a-fA-F0-9]*)
    [Return]   ${radMasterValue}

Get AaShell SW Config
    [Documentation]
    ...     This keyword Prints all non default R&D parameters of RadMaster.
    ...
    ...     | rad_param | Rad Parameter [0x580017] |
    ...     | gnb_id    | Id of gnb [0.. ]         |
    ...     | du_id     | Id of DU [0.. ]          |
    ...     | comu_id   | Id of Common Unit [0..1] |
    ...
    ...    *Returns* IF rad_param is empty prints all non default R&D parameters of RadMaster.
    ...              Else the "Current val" of rad_param. e.g.: [u'0x0']
    ...
    [Arguments]   ${rad_param}=${EMPTY}   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}

    BuiltIn.log     du_id=${du_id} and comu_id=${comu_id}
    ${nonDefaultRadMaster}   aashell.Execute Aashell Command on Node   command=rad -mu \r
    ...                                                                node_id=${gnb_id}   node_type=gnb

    ${radMasterValue}   Run Keyword If   '${rad_param}'=='${EMPTY}'     Set Variable    ${nonDefaultRadMaster}
    ...                     ELSE                                        String.Get regexp matches   ${nonDefaultRadMaster}
    ...                                                                         \\[${rad_param}\\] Default val = .*; Current val = (.*)   1
    [Return]   ${radMasterValue}
