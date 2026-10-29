*** Settings ***
Documentation
...     [Procedure]    				 		"CB005832_check_the_loopback_connectivity_for_M_plane"
...     [Author]       				 		"jyotsna"
...     [Maintenance]  				 		"TRS I & V Tools Bangalore Team"
...     [QC_Path]      				 		"QC_Path in Test Plan"
...     [QC_ID]        				 		"QC_ID in Test Lab For reporting"
...     [Feature_ID]   				        "CB005832"
...     [Funtion_Hash_Tags] 		 		"LBM verification"
...     [Validation_status]                 "Validated and Passed"
...     [Validated_TestLine]                "ASIM_TL001_10.58.143.122"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

#Suite Setup     Setup Oamops
#Suite Teardown  Teardown Oamops

Suite Setup       Pre-conditions for testsuite
Suite Teardown    Post-conditions for test teardown

*** Variables ***
${profile}          /home/ute/Downloads/SBTS23R3_ENB_0000_000166_000000_release_BTSSM_downloadable_A54.zip

*** Test Cases ***
[1][1.0] CB005832_Loopback_for_eCPRI_Sw_update_rollback_and_reboot
	Enable LBM config and check for LBM and LBR messages
	Modify lbmCCperiodicity
	Disable the parameter actlbmOnFronthaul
	Enable the parameter actlbmOnFronthaul
	Do site reset and check the LBM status
	Disable actlbmOnFronthaul and validate
	Modify the vlan under OAMMA and Check if loopback is success
	Upgrade sw and check the LBM status
    Do sw rollback and check the LBM status
*** keywords ***
Enable LBM config and check for LBM and LBR messages
	Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
	check for LBM and LBR messages	conn1
Modify lbmCCperiodicity
    ${value_periodicity}=         Evaluate    random.choice(range(0, 61))  random
    Perform Recommissioning     type=param      rat=common     param_path=${lbm_periodicity}  operation=update    value=${value_periodicity}
    ...     timeout=300
    sleep    30
Disable the parameter actlbmOnFronthaul
	Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=false     timeout=300
    Sleep    30
Enable the parameter actlbmOnFronthaul
	Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
    Sleep    30
Do site reset and check the LBM status
	Reset Bts       should_be_onair=False
    Sleep   300
	check for LBM and LBR messages	conn2
Disable actlbmOnFronthaul and validate
    Perform Recommissioning     type=param      rat=common     param_path=${actLbmOnFronthaul}  operation=update    value=false     timeout=300
Modify the vlan under OAMMA and Check if loopback is success
    Perform Recommissioning     type=param      rat=common     param_path=MRBTS-1/TNLSVC-1/TNL-2/ETHAPP-1/OAMMA-1:vlanId  operation=update
    ...    value=111    timeout=300
#    Verify Alarm        faultid=${61009}     should_exist=${true}
	Perform Recommissioning     type=param      rat=common     param_path=MRBTS-1/TNLSVC-1/TNL-2/ETHAPP-1/OAMMA-1:vlanId  operation=update
    ...    value=4093    timeout=300
#    Verify Alarm        faultid=${61009}     should_exist=${false}
	check for LBM and LBR messages	conn3
Upgrade sw and check the LBM status
	Perform Software Download And Update       package=${profile_1}      activate_sw=true      update_timeout=2200
    Sleep      600
    check for LBM and LBR messages  conn4
Do sw rollback and check the LBM status
    Perform Recommissioning     type=param      rat=5g     param_path=${actLbmOnFronthaul}  operation=update    value=true     timeout=300
    Sleep    100
	Rollback Software       timeout=800
	check for LBM and LBR messages	conn5
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
