*** Settings ***
Documentation
...     [Procedure]                    "Loopback_Connectivity_Check_For_M_Plane"
...     [Author]       				   "jyotsna"
...     [Maintenance]                  "TRS I & V Tools Bangalore Team"
...     [QC_Path]                      "QC_Path in Test Plan"
...     [QC_ID]                        "QC_ID in Test Lab for reporting"
...     [Feature_ID]                   "CB009420"
...     [Funtion_Hash_Tags]            "LBM verification"
...     [Validation_status]            "Validated and Passed"



variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

*** Test Cases ***
[1][1.0] CB005832_Loopback_check_for_M_plane_Basic_config_modify_deletion_check
	Enable LBM config and check for LBM & LBR messages are captured
    Disable the parameter actlbmOnFronthaul
    Enable the parameter actlbmOnFronthaul
    Modify the vlan under OAMMA and Check if loopback is success
	Configure fronthaul and check LBM config with same periodicity and check for LBM status

*** keywords ***
Enable LBM config and check for LBM & LBR messages are captured
	Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
    Sleep    30
	check for LBM and LBR messages	conn1

Disable the parameter actlbmOnFronthaul
    Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=false     timeout=300
    Sleep    30
Enable the parameter actlbmOnFronthaul
    Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
    Sleep    30
Modify the vlan under OAMMA and Check if loopback is success
    Perform Recommissioning     type=param      rat=common     param_path=MRBTS-1/TNLSVC-1/TNL-2/ETHAPP-1/OAMMA-1:vlanId  operation=update
    ...    value=111    timeout=300
#   Verify Alarm        faultid=${61009}     should_exist=${true}
    check for LBM and LBR messages  conn2
    Perform Recommissioning     type=param      rat=common     param_path=MRBTS-1/TNLSVC-1/TNL-2/ETHAPP-1/OAMMA-1:vlanId  operation=update
    ...    value=4093    timeout=300
    ${abcd}=     Query Admin infomodel       query=get list //OAMMA_R-1
    Should not be empty   ${abcd}
    Verify Alarm        faultid=${61009}     should_exist=${false}
    check for LBM and LBR messages  conn3
Configure fronthaul and check LBM config with same periodicity and check for LBM status
	Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
    Sleep    30
    ${value_periodicity}=         Evaluate    random.choice(range(0, 61))  random
	Perform Recommissioning     type=param      rat=common     param_path=${lbm_periodicity}  operation=update
    ...    value=${value_periodicity}     timeout=300
    sleep    30
	check for LBM and LBR messages	conn4
check for LBM and LBR messages
	[Arguments]	  ${connection}
	Setup Remote Access     remote_device=bts     alias=${connection}
	Sleep   10
	Continue Keyword Execution On Failure     ${True}
	Execute Interactive Remote Command     command=${cmd2}    alias=${connection}
	Execute Interactive Remote Command     command=${cmd3}    alias=${connection}
#	Sleep    200
	Execute Interactive Remote Command     command=${BBMOD_copy}    alias=${connection}
	Execute Interactive Remote Command     command=${cmd_yes}    alias=${connection}
	Execute Interactive Remote Command     command=${SMOD_pwd}    alias=${connection}
	Execute Interactive Remote Command     command=${exit_command}    alias=${connection}
	Get File From Remote Host    source=/user/toor4nsn/test1.pcap      destination=/home/ute    alias=${connection}
	Teardown Remote Access     alias=${connection}
    Sleep    100
	Analyse Pcap        pcap_filename=${LBM_pcap_file_location}        analysis=verify_LBM_LBR_message
    ...       filter_file_name=${traffic_filter_file_name1}
