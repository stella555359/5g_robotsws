*** Settings ***

Documentation
    ...     Keywords for dcap handling, default is set to emil traces
    ...
    ...     trace type is generally set by custom profile variable;
    ...     possible options (only gNB (5G) options) are listed here:
    ...    | cp_5g, immediateSnapshot_5g, pmFiles5g, condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component,
    ...    | L2HiRlc_Component, L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,             |
    ...    | L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream
    ...
    ...    these values are defined in
    ...
    ...    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.sw.dcap.rd.interface.rd.start_trace
    ...
    ...    and mapped to a tracer_id and trace interface. This mapping and detailed setting for each profile can be found in dcap code:
    ...
    ...    robotws/.venv/lib/python3.6/site-packages/taf/sw/dcap/rd/cm/cm_base.py
    ...
    ...    several traces can be started and stopped together by creating a list of custom profiles, but at the moment it's not
    ...    possible to start single traces on after the other.
    ...
    ...    The following table shows the tested custom profiles and the supported sequence for each.
    ...    If you mix multiple custom profiles be sure they are compatible with each other.
    ...    Mixing profiles that require only start/stop with profiles that require start/stop/collect works but requires also
    ...    start/stop/collect sequence.
    ...    Consider putting the Collect in the teardown of the keyword, so that if the stop fails you are still able to get some logs.
    ...    Feel free to modify the table if your experience does not match the information provided there or if there is missing data.
    ...
    ...    | Custom Profile          | Start/Stop/Collect  | Start/Collect |
    ...    | cp_5g                   | X                   |               |
    ...    | immediateSnapshot_5g    | X                   |               |
    ...    | pmFiles5g               |                     | X             |
    ...    | condor5gSyslog          |                     |               |
    ...    | SCF5g                   |                     | X             |
    ...    | L2Ps_Component          | (need cells on air) |               |
    ...    | L2Lo_Component          | (need cells on air) |               |
    ...    | L2HiRlc_Component       | (need cells on air) |               |
    ...    | L2HiPdcp_Component      | (need cells on air) |               |
    ...    | L2Ps_Sherpa             | (need cells on air) |               |
    ...    | L2Lo_Sherpa             | (need cells on air) |               |
    ...    | L2HiRlc_Sherpa          | (need cells on air) |               |
    ...    | L2HiPdcp_Sherpa         | (need cells on air) |               |
    ...    | bip_interface_mirroring | (need cells on air) |               |
    ...    | L1stream                |                     |               |
    ...

Library    String

Library    taf.collectors.dcap   WITH NAME   collect_dcap
Library    python/connect.py     WITH NAME   connect_py
Library    taf.config.scf        WITH NAME   scf
Library    taf.collectors.core   WITH NAME   collector_core
# next line is only needed for DCAP WA, to be removed later too!

Resource   testline.robot
Resource   connect.robot

*** Variables ***
${P_admin_console}              ${False}    # debug output to console

*** Keywords ***
Get Installed UTF Version
    [Documentation]
    ...	  Gets the version of the installed DCAP/UTF
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]         ${dcap_alias}
    ${update_data}      ssh.Execute   /usr/local/bin/utf_lab-updates       connection=${dcap_alias}
    ${lines}            Get Lines Matching Pattern    ${update_data}   Currently installed version*
    ${_}   ${version}   Split String   ${lines}   :
    ${version}          Strip String   ${version}
    RETURN    ${version}


Get DCAP Docker Image Version
    [Documentation]
    ...	  Gets the version of the installed bmi container
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]    ${dcap_alias}   ${image_name}

    ${query_image}   Catenate   SEPARATOR=${SPACE}|${SPACE}
    ...   docker ps -a --format '{{json .}}'                  # get list of all docker images in json format
    ...   jq -s -c '.[] | select(.Image | contains("${image_name}"))'   # filter for items with image containing bmi
    ...   jq '.Image'                                         # query the value of the Image

    ${docker_image}    ssh.Execute    ${query_image}    connection=${dcap_alias}

    ${version}    Get Regexp Matches   ${docker_image}    FB......
    ${image_version}   Set Variable    ${version}[0]

    RETURN    ${image_version}


Get BMI Docker Image Version
    [Documentation]
    ...	  Gets the version of the installed bmi container
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]    ${dcap_alias}

    ${bmi_version}   Get DCAP Docker Image Version   dcap_alias=${dcap_alias}    image_name=bmi

    RETURN   ${bmi_version}


Get Emil JSON Server Docker Image Version
    [Documentation]
    ...	  Gets the version of the installed bmi container
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]    ${dcap_alias}

    ${emil_json_server_version}   Get DCAP Docker Image Version   dcap_alias=${dcap_alias}    image_name=emil-json-server

    RETURN   ${emil_json_server_version}


Get Linux Emil Docker Image Version
    [Documentation]
    ...	  Gets the version of the installed bmi container
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]    ${dcap_alias}

    ${linux_emil_version}   Get DCAP Docker Image Version   dcap_alias=${dcap_alias}    image_name=linux-emil

    RETURN   ${linux_emil_version}


Apply Hotfix For FB2502.1
    [Documentation]
    ...   Applies th hotfix for FB2502.1
    ...   See issue: https://gitlabe2.ext.net.nokia.com/nm-collaboration/dcap/dcap-basic/-/issues/1402
    ...   Fixes the problem, that emil trace collection is empty. Also the Json docker is updated for correct decoding.
    ...
    [Arguments]    ${dcap_alias}

    ${linux_emil_version}     Get Linux Emil Docker Image Version    ${dcap_alias}

    IF    '${linux_emil_version}' == 'FB2502.1'
        ${linux_emil_hotfix_command}   Catenate
        ...   utf_lab-hotfix
        ...   install
        ...   tts-docker-releases-local.artifactory-espoo2.int.net.nokia.com/linux-emil:BETA-FB2503.1-89a1d8f31779afbbd25c65947186e2d211da2d80

        ${output}    ssh.Execute    ${linux_emil_hotfix_command}    connection=${dcap_alias}
    END

    ${json_server_version}     Get Emil JSON Server Docker Image Version    ${dcap_alias}

    IF    '${json_server_version}' == 'FB2502.1'

        ${docker_emil_json_server}    Catenate   SEPARATOR=:
        ...        tts-docker-releases-local.artifactory-espoo2.int.net.nokia.com/emil-json-server
        ...        BETA-FB2503.1-89a1d8f31779afbbd25c65947186e2d211da2d80

        ${json_server_hotfix_command}   Catenate
        ...   utf_lab-hotfix
        ...   install
        ...   ${docker_emil_json_server}

        ${output}    ssh.Execute    ${json_server_hotfix_command}    connection=${dcap_alias}
    END


Apply Hotfix For BMI 2415.1
    [Documentation]
    ...	  Applies the hotfix for bmi Version 2415.1, neccessary to collect emil traces.
    ...
    ...   | dcap_alias        | The ssh connection alias  |

    [Arguments]    ${dcap_alias}
    ${hotfix_command}   Catenate
    ...   utf_lab-hotfix
    ...   install
    ...   tts-docker-releases-local.artifactory-espoo2.int.net.nokia.com/bmi:FB2416.1-3282dfc228aa72a5a542ed710babd2c6a1aa71a5
    ${output}    ssh.Execute    ${hotfix_command}    connection=${dcap_alias}

Check For Needed Hotfix Installations
    [Arguments]    ${dcap_alias}

    ${utf_version}    Get Installed UTF Version      ${dcap_alias}
    ${bmi_version}    Get BMI Docker Image Version   ${dcap_alias}

    Set Suite Metadata    UTF Version     ${utf_version}

    IF    '${bmi_version}' == 'FB2415.1'
    ...   Apply Hotfix For BMI 2415.1   ${dcap_alias}

    IF    '${utf_version}' == 'FB2502.1'
    ...   Apply Hotfix For FB2502.1     ${dcap_alias}

Start DCAP Container
    [Documentation]
    ...	starts DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${retry_counter}=6
    ${dcap_alias}   connect.Connect To Test PC Proxy For Node   ${node_id}   ${node_type}

    Run Keyword And Warn On Failure   Check For Needed Hotfix Installations   dcap_alias=${dcap_alias}

    ssh.Execute   /usr/local/bin/utf_lab-controller   connection=${dcap_alias}
    ssh.Assert Exit Status   1   connection=${dcap_alias}
    ...   msg=DCAP startup failed, check DCAP deployment on Test-VM for ${node_type}${node_id}!
    ssh.Execute  /usr/local/bin/utf_lab-controller start  connection=${dcap_alias}

    FOR   ${loop_counter}   IN RANGE   ${retry_counter}
       ssh.Execute   /usr/local/bin/utf_lab-controller status   connection=${dcap_alias}
       ${rc}   ssh.Get Exit Status   connection=${dcap_alias}
       IF   ${rc}==${0}    BREAK

       Log   dcap not yet working, sleep 10s (loop ${loop_counter})   console=${P_admin_console}
       Sleep   10s
    END

    # DCAP FB2408.1 itself is broken. The startup file of the ondemand_flowtracer container is buggy!
    # as temporary WA we allow the KW to fail as the other collectors work correctly!
    # IF   ${rc}!=${0}   FAIL   startup DCAP container failed on Test-VM for ${node_type}${node_id}!
    Run Keyword And Warn On Failure   Should Be True   ${rc}==${0}
    ...   msg=Temporary WA for DCAP FB2408.1: Errors are ignored! To be removed later.


Stop DCAP Container
    [Documentation]
    ...	stops DCAP container on node-related test-vm
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    ${dcap_alias}   connect.Connect To Test PC Proxy For Node   ${node_id}   ${node_type}
    ssh.Execute   /usr/local/bin/utf_lab-controller   connection=${dcap_alias}
    ${rc}   ssh.Get Exit Status   connection=${dcap_alias}
    IF   '${rc}'=='${1}'   ssh.Execute   /usr/local/bin/utf_lab-controller stop   connection=${dcap_alias}


Start DCAP Container For All Nodes
    [Documentation]
    ...	starts DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]   ${node_type}=gnb   ${retry_counter}=6
    ${node_num}   Get Length   ${tl.${node_type}s}
    FOR   ${node_id}   IN RANGE   ${node_num}
       Start DCAP Container   node_id=${node_id}   node_type=${node_type}   retry_counter=${retry_counter}
    END


Stop DCAP Container For All Nodes
    [Documentation]
    ...	stops DCAP container on node-related test-vm for all nodes defined in TL config
    ...
    [Arguments]    ${node_type}=gnb
    ${node_num}   Get Length    ${tl.${node_type}s}
    FOR    ${node_id}    IN RANGE    ${node_num}
           Stop DCAP Container  ${node_id}  ${node_type}
    END


Create DCAP Access Object
    [Documentation]
    ...     Create DCAP access object for tracing, update username/password depending on exisiting
    ...     keycload

    ${result}=     Run   docker ps -a --no-trunc --filter name=basic_keycloak | wc -l
    ${result}=    Convert To Integer    ${result}

    IF   ${result} > ${1}
        ${dcap}     Create Dictionary  host=127.0.0.1  port=9443  username=dcapuser  password=dcapadmin!
    ELSE
        ${dcap}     Create Dictionary  host=127.0.0.1  port=9443  username=${None}  password=${None}
    END

    RETURN   ${dcap}


Start DCAP Tracing
    [Documentation]
    ...     Start DCAP tracing on given Node
    ...
    ...    | node_id        | Id of gNB or eNB                                                          |
    ...    | node_type      | either enb or gnb                                                         |
    ...    | custom_profile | The gNB (5G) custom profile name list of the start trace to be started    |
    ...    | ..             | e.g. one or several of: cp_5g, immediateSnapshot_5g, pmFiles5g,           |
    ...    | ..             | condor5gSyslog, SCF5g, L2Ps_Component, L2Lo_Component, L2HiRlc_Component, |
    ...    | ..             | L2HiPdcp_Component, L2Ps_Sherpa, L2Lo_Sherpa, L2HiRlc_Sherpa,             |
    ...    | ..             | L2HiPdcp_Sherpa, bip_interface_mirroring, L1stream                        |
    ...    | ..             | If the list argument ``custom_profile``is not used cp_5g will be set      |
    ...    | ..             | to activate Emil trace collection!                                        |
    ...
    ...    https://taf-sw-dcap-rd.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.sw.dcap.rd.interface.rd.start_trace
    ...
    ...    *Example*
    ...    | @{my_profile}        Create List  cp_5g  SCF5g
    ...    | Start DCAP Tracing   custom_profile=${my_profile}
    ...
    ...    *Returns*    collector alias
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${custom_profile}=@{EMPTY}

    IF      not ${custom_profile}
        @{profile}      Create List   cp_5g
    ELSE
        @{profile}      Create List   @{custom_profile}
    END

    ${node_type}    String.Convert To Lower Case   ${node_type}
    ${nb_test_pc}   connect_py.Get Test PC For Nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}

    ${dcap}=    Create DCAP Access Object

    &{bts}  Create Dictionary
    ...   host=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.addr}
    ...   port=443
    ...   username=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.username}
    ...   password=${tl.${node_type}s[${node_id}].cu.oam_http_connection_details.password}

    &{trace}   Create Dictionary
    ...   bts=${bts}
    ...   gnb_custom_profile=${profile}

    &{hops}   Create Dictionary
    ...   host=${nb_test_pc.default_ssh_connection_details.addr}
    ...   user=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}

    ${collectorname}   Set Variable   dcap_${node_type}_${node_id}
    IF   "${nb_test_pc.default_ssh_connection_details.addr}"=="${tl.test_pc.default_ssh_connection_details.addr}"
        collect_dcap.Create DCAP Trace Collector    name=${collectorname}   dcap=${dcap}    trace=${trace}
    ELSE
        collect_dcap.Create DCAP Trace Collector    name=${collectorname}   dcap=${dcap}    trace=${trace}   hops=${hops}
    END

    collect_dcap.Setup Collectors   names=${collectorname}
    collect_dcap.Set Suite Alias    ${collectorname}
    collect_dcap.Start Collectors   names=${collectorname}
    RETURN   ${collectorname}

Stop DCAP Tracing
    [Documentation]
    ...     Stop DCAP tracing on given Node
    ...
    ...    | node_id    | Id of gNB or eNB  |
    ...    | node_type  | either enb or gnb |

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb

    ${node_type}   String.Convert To Lower Case   ${node_type}
    collect_dcap.Stop Collectors   names=dcap_${node_type}_${node_id}


Collect DCAP Traces
    [Documentation]
    ...     Collect DCAP traces on given Node
    ...
    ...    | node_id        | Id of gNB or eNB          |
    ...    | node_type      | either enb or gnb         |
    ...    | target_dir     | where traces are stored   |
    ...
    ...    *Returns*    path to collected traces

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb   ${target_dir}=${None}

    ${node_type}    String.Convert To Lower Case   ${node_type}

    IF   $target_dir is None
        ${target_dir}    testline.Get Testcase Log Directory
    END

    collect_dcap.Collect Collectors   names=dcap_${node_type}_${node_id}   target_dir=${target_dir}
    RETURN   ${target_dir}/dcap_${node_type}_${node_id}



Teardown DCAP Collector
    [Documentation]
    ...     Teardown DCAP collector
    ...
    ...    | node_id        | Id of gNB or eNB          |
    ...    | node_type      | either enb or gnb         |
    ...
    ...    *Returns*    None

    [Arguments]   ${node_id}=${0}   ${node_type}=gnb

    ${node_type}    String.Convert To Lower Case   ${node_type}

    collect_dcap.Teardown   alias=dcap_${node_type}_${node_id}

