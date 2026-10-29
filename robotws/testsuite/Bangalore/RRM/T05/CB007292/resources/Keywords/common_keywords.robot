*** Settings ***
Documentation     This contains common keywords which are common for running test cases
...                bhakti.ka_patel@nokia.com

Resource    ../Variables/common_variables.robot

*** Keywords ***
Verify UE registration and pdu setup
    [Arguments]    ${UE_ID}
    ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${UE_register_complete_pattern}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    sleep    5s
    Read WTS Output For Pattern And Print matching Lines    ${pdu_setup}    ${Timeout_SA}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    log    ${output}


Start UTE WTS
    [Arguments]         ${wts_configuration_file}
    Stop Edaemon Egate

    Log to Console                 Starting WTS...
    ${status}    Run Keyword And Return Status    File Should Exist    ${test_property_file}
    log     ${status}
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${cfg_filename}  set variable   ${AP_CONFIG_BASIC}/${wts_configuration_file}
    wtsrunner.configure                      file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min


Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

X2AP Link Should be UP
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${eNB_ID}    target=${eNB_target}
    Read WTS Output For Pattern And Print matching Lines    ${X2_link_pattern}    ${Timeout_NSA}
    log to console    \nx2_is_ok

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    S1 link check for eNB
    Log to console              \nng_link_status_is_ok

NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and '${4G5G_Combo}'=='1'
    ...    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link in UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

Search pattern should Exists In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}

S1 link check for eNB
    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${S1_link_pattern_dual_stack}
    Log                S1_link_status_is_ok

