*** Settings ***

Library     BuiltIn
Library     OperatingSystem
Library     taf.sw.dcap.rd		WITH NAME	rd
Library     SSHLibrary

Documentation   DCAP_UTF


*** Variables ***
${DCAP_port}    9443
&{bts_info}      alias=gnb_1    host=192.168.255.129    username=Nemuadmin    password=nemuuser
    ...     port=443    bts_id=1
${cell_info}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-23174/NRCELL_R-1

*** Keywords ***
Start Local Dcap Lite
    [Documentation]    Start Dcap Lite
    ...    - Start Dcap Lite on the virtual machine
    ${rs}      OperatingSystem.Run       DCAP_Basic_controller restart
    Log    Dcap Lite started on the virtual machine

Stop Local Dcap Lite
    [Documentation]    Stop Dcap Lite
    ...    - Stop Dcap Lite on the virtual machine
    ${rs}      OperatingSystem.Run       DCAP_Basic_controller stop
    Log    Dcap Lite stopped on the virtual machine

Start Dcap Lite
	Log to console  ...waiting to run dcap server on ${tl.test_pcs[0].default_ssh_connection_details.addr}

  	SSHLibrary.open connection    ${tl.test_pcs[0].default_ssh_connection_details.addr}    prompt=$   timeout=600 seconds
  	SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
  	SSHLibrary.Write    cd /home/ute

  	SSHLibrary.Write    DCAP_Basic_controller restart
  	SSHLibrary.Read Until Prompt
    BuiltIn.Sleep   2s
    SSHLibrary.close connection

Stop Dcap Lite
    Log to console  ...waiting to stop dcap server on ${tl.test_pcs[0].default_ssh_connection_details.addr}

  	SSHLibrary.open connection    ${tl.test_pcs[0].default_ssh_connection_details.addr}    prompt=$   timeout=600 seconds
  	SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
  	SSHLibrary.Write    cd /home/ute

  	SSHLibrary.Write    DCAP_Basic_controller stop
  	SSHLibrary.Read Until Prompt
    BuiltIn.Sleep   2s
    SSHLibrary.close connection

Connect To DCAP
    rd.connect_to    ${tl.test_pcs[0].default_ssh_connection_details.addr}     ${DCAP_port}     username=${None}
	...    password=${None}    rd_version=dcapv3    secure=${True}

Create Bts On DCAP
    [Arguments]    ${host}=192.168.255.129    ${bts_alias}=gnb_1
    rd.create_bts    ${host}    bts_alias=${bts_alias}

Start DCAP log
    [Arguments]    ${bts_info}
	${gnb_custom_profile}=    Create List    L2Ps_Component
    # ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    # ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
	${output}=    rd.start_trace     bts=${bts_info}    gnb_custom_profile=${gnb_custom_profile}    wait_for_activation=${True}
	${tracer_id}=    Get DCAP Trace ID    ${output}

Get DCAP Tracer ID
    [Arguments]    ${output}
    Log    ${output}
	Log    Dcap started, ID: ${output}[tracer_id]
    ${tracer_id}      Convert To Integer      ${output}[tracer_id]
    set suite variable    ${tracer_id}

Stop And Download DCAP log
    Stop DCAP log
    Download log from DCAP

Stop DCAP log
    log to console    \n Stop DCAP log
    rd.stop_trace    trace_id=${tracer_id}

Download log from DCAP
    [Arguments]    ${target_dir}=${OUTPUT_DIR}/${TEST_NAME}
	log to console    Download log from DCAP
    ${dcap_file_path}    rd.get_results    result_id=${tracer_id}   target_dir=${target_dir}
    RETURN    ${dcap_file_path}

Teardown DCAP
    rd.delete_bts

How To Use In DCAP
    ### Steup
    Start Local Dcap Lite
    Connect To DCAP
    Create Bts On DCAP    host=192.168.255.129    bts_alias=gnb_dcap
    ### Start DCAP log
    ${gnb_custom_profile}=    Create List    L2Ps_Component
    ${output}    rd.start_trace     duration=-1    bts=${bts_info}
    ...    gnb_custom_profile=@{gnb_custom_profile}
    # ...    wait_for_activation=True

    # ${output}=    rd.start_trace     bts=${bts_info}
    # ...               bts_custom_profile=${bts_custom_profile}
    # ...               gnb_custom_profile=${gnb_custom_profile}
    # ...               cells=${cells}
    # ...               l1_trace=${l1_trace}
    # ...               wait_for_activation=${True}
	${tracer_id}=    dcap.Get DCAP Tracer ID    ${output}

    BuiltIn.Sleep  10s

    dcap.Stop And Download DCAP log

    dcap.Download log from DCAP

    BuiltIn.Sleep    150s

    ### Teardown
    # dcap.Teardown DCAP
    # Stop Local Dcap Lite
