*** Settings ***
Documentation
...     [Procedure]    				 		"Verification_of_eCPRI_over_IPv4_with_new_internal_architecture"
...     [Author]       				 		"jyotsna"
...     [Maintenance]  				 		"TRS I & V Tools Bangalore Team"
...     [QC_Path]      				 		"QC_Path in Test Plan"
...     [QC_ID]        				 		"QC_ID Test Lab for reporting"
...     [Feature_ID]   				 		"CB009420"
...     [Requirement ID] 			       	""
...     [Funtion_Hash_Tags] 		 		"LBM verification"
...     [Validated_TestLine]    			"ASIL_Half_Rack"
...     [Config]    						""
...     [Runtime param]   					"bts_id is provided at run time."


variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

*** Test Cases ***

[1][1.0] TRS_Verification of eCPRI over IPv4 with new internal architecture
	Login to FCT board
	Login to BB Mode
	capture wireshark
	Restart RU
	Verify the DORA messages in the wireshark


*** keywords ***
Login to FCT board
	Setup Remote Access     remote_device=bts     alias=connection
	Sleep   10

Login to BB Mode

	Continue Keyword Execution On Failure     ${True}
	Execute Interactive Remote Command     command="lxc-attach -n 0x2018"    alias=connection

capture wireshark
	Execute Interactive Remote Command     command="tcpdump -i rlan0.ecpri -w doraMessage.pcap -s 10000"	alias=connection


Restart RU

	Reset	operation=reset_unit
    sleep  300


Verify the DORA messages in the wireshark
	Execute Interactive Remote Command     command="scp -r doraMessage.pcap ute@192.168.255.129:/home/ute\n"	alias=connection