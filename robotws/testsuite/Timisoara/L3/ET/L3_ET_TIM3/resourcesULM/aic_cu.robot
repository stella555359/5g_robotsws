*** Settings ***

Documentation   Common KWs for AIC CU


Library   OperatingSystem

Library   taf.gnb.oam.coam.cu                WITH NAME    coam_cu
Library   python/gnb.py                      WITH NAME    gnb_internal
Library   python/testline.py                 WITH NAME    testline_py
Library   python/robot_extension.py          WITH NAME    rbext_py

Resource   testline.robot
Resource   networking.robot

*** Keywords ***
Connect to OAM CU
    [Documentation]
    ...
    ...     Creates a Session to connect to OAM CU.
    ...     If no alias given in `alias` an alias is constructed in following way: gnb-`gnb_id`-oam-cu.
    ...
    ...     | gnb_id | Id of gnb                         |
    ...     | alias  | alias to identify this connection |
    ...
    ...     *Returns*   oam session to CU for specified gNB
    ...
    [Arguments]   ${gnb_id}=${0}   ${alias}=gnb-${gnb_id}-oam-cu
    ${cu_oam_session}   coam_cu.connect to
    ...   host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...   port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    ...   username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...   password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...   secure=${True}
    ...   alias=${alias}
    [Return]   ${alias}


Disconnect from OAM CU
    [Documentation]
    ...
    ...     Releases the connection to OAM CU.
    ...
    ...     | alias | alias to identify the connection |
    ...
    [Arguments]  ${alias}
    rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${alias}


Reboot CU
    [Documentation]
    ...
    ...     Reboot CU and wait until CU oam http connection address is reachable.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]   ${gnb_id}=${0}
    ${session}   Connect to OAM CU   gnb_id=${gnb_id}
    coam_cu.reset_cu   connection=${session}

    networking.Wait Until Ping Failed
    ...   ip_addr=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...   iterations=500

    networking.Wait Until Ping Succeeds
    ...   ip_addr=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...   iterations=500

    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${session}


Wait until F1 Link Status is available
    [Documentation]
    ...
    ...     Wait for CU F1 status available. Fails if still not available after timeout expires.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]   ${gnb_id}=${0}   ${timeout}=2min
    Wait Until Keyword Succeeds   10s   ${timeout}   F1 Link Status Of CU Should Be Available
    ...   gnb_id=${gnb_id}


F1 Link Status of CU Should Be Available
    [Documentation]
    ...
    ...     Checks if CU F1 status is available. Fails if not.
    ...
    ...     | gnb_id | Id of gnb |
    ...
    [Arguments]   ${gnb_id}=${0}
    ${session}     Connect to OAM CU      gnb_id=${gnb_id}
    ${cu_status}   coam_cu.get_du_state   connection=${session}

    Should be Equal   ${cu_status['f1_link_status']['available']}      ${1}
    ...               msg=F1 Link Status of CU is not available.

    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${session}


Get CU SW Version
    [Documentation]
    ...
    ...     This keyword returns the CU software version in the specified gNB.
    ...
    ...     | gnb_id  | Id of gnb |
    ...
    ...     *Returns*   string with CU software version
    ...
    [Arguments]   ${gnb_id}=${0}
    ${session}         Connect to OAM CU   gnb_id=${gnb_id}
    ${CU_sw_version}   coam_cu.get_active_software_version   connection=${session}

    ${cu_sw}   testline_py.reform_coam_sw_version   ${CU_sw_version}
    Log To Console   ${\n}CU SW Version: ${cu_sw}
    [Return]     ${cu_sw}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${session}


Get CU Current Plan File
    [Documentation]
    ...
    ...     Gets the current CU plan file (scf) and copies it to the location given
    ...     in the `resultConfigDir`. If no path given, the file is placed in
    ...     the Test Suite Config Directory. If filename not given in `gnbScfName`
    ...     a default name if constructed in following way: scf_gnb_`gnb_id`_cu.xml
    ...
    ...     | gnbScfName      | scf file name                    |
    ...     | resultConfigDir | path where to copy the plan file |
    ...     | gnb_id          | Id of gnb                        |
    ...
    ...     *Returns*   plan filename with full path
    ...
    [Arguments]   ${gnbScfName}=${None}   ${resultConfigDir}=${None}   ${gnb_id}=${0}
    ${resultConfigDir}   Run Keyword If   '${resultConfigDir}'=='None'
    ...          testline.Get Test Suite Config Directory
    ...   ELSE   Set Variable  ${resultConfigDir}

    ${gnbScfName}   Set Variable If   '${gnbScfName}'=='None'   scf_gnb_${gnb_id}_cu.xml   ${gnbScfName}
    ${path}      OperatingSystem.Join Path   ${resultConfigDir}   ${gnbScfName}
    ${session}   Connect to OAM CU   gnb_id=${gnb_id}
    coam_cu.get_current_plan_file
    ...   path=${path}
    ...   timeout=60
    ...   connection=${session}
    [Return]     ${path}
    [Teardown]   rbext_py.run_keyword_and_warn_on_failure   coam_cu.disconnect   ${session}


Get distNames from AiC CU
    [Documentation]
    ...
    ...     This TL specific keyword returns a list of distnames that are present in the CU OAM Plan
    ...
    ...     | regex     | Regular expression of the distname that is required to be matched with the DU OAM plan  |
    ...     | gnb_id    | Id of gnb |
    ...
    ...     *Returns*   a list of distnames matching the regular expression given
    ...
    [Arguments]   ${regex}   ${gnb_id}=0
    ${scf_path}      Get CU Current Plan File   gnb_id=${gnb_id}
    ${scf_content}   OperatingSystem.Get File   ${scf_path}

    ${distNames}     gnb_internal.get_distNames_from_scf
    ...   regex=${regex}
    ...   scf_content=${scf_content}
    [Return]    ${distNames}

