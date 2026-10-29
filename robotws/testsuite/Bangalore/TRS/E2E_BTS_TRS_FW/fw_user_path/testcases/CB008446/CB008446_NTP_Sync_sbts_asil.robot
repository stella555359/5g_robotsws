*** Settings ***
Documentation
	...		[Procedure]				"The test case is planned to Verify 8446 NTP parameter sync with NCF"
	...		[Date]					"7-9-2024"
	...		[Author]				"Manohar KR"
	...		[QC_Path]				"QC_Path in Test Plan"
	...		[QC_ID]					"QC_ID in Test Lab for reporting"
	...		[Funtion_Hash_Tags]		"NTP","8446"
	...   	[Feature_ID]         	"CB008446"
	...  	[Validation_status]  	"Validated and Passed"
	...   	[Validated_TestLine] 	"5G_3931"
	...   	[Config] 				"NRBTS-1 need to configure with NTP"

Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/resources/common_keywords.robot
#Force Tags      SM TRSIV Test 3    QCD_MN_5G    QCP_5G    CRT	QCP_SBTS00	QCD_MN_SBTS00

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Variables ***
${Configure_NTP_IP}	 /home/ute/fw_user_path/config/2326/4G5G_onair_SMT_singleNTP-2326_WORKING.xml
${Configure_2_NTP}		/home/ute/fw_user_path/config/2326/Update_2NTP_delta.xml


*** Test Cases ***
[1][1.0] CB008446-C_Vefification_of_NTP_server_and_time_zone_configuration_provided_by_SBTS_SW_(via NCF)_in_fallback_from_SBTS_SW_to_SBTS

	[Documentation]		"The test case to verify 8446 NTP sync verification verification"

    Perform Commissioning       scf_file=${Configure_NTP_IP}       verify_bts_status=False		timeout=900
	Check the 1 NTP IP configured in NCF from DHCP
	Perform Recommissioning       type=delta	delta_file=${Configure_2_NTP}      verify_bts_status=False		timeout=900
	Check the NCF by login board
	Check snapshot collection and IM snapshot is successful
	Run Keyword And Ignore Error	Rollback Software		timeout=900	alias=default
	Sleep	500
	Check the NCF by login board
	Run Keyword And Ignore Error	Rollback Software		timeout=900	alias=default
	Sleep	500
	Check the NCF by login board
	Perform Commissioning      scf_file=${Configure_NTP_IP}      verify_bts_status=False		timeout=900
	Check the 1 NTP IP configured in NCF from DHCP


***Keywords***

Perform ping test
       Setup Remote Access    remote_device=bts
       ${stdout}       Remote Command Execute      command=ping -I 10.0.1.111 10.0.1.1 -c 150 -Q 0x70
       Teardown remote Access


Check snapshot collection and IM snapshot is successful
    	${snapshot_file}=       Collect snapshot
        FIle should not be empty        ${snapshot_file}
    	  ${im_snapshot_file}=    Collect IM snapshot
   	 FIle should not be empty        ${im_snapshot_file}

Keywords To Run At End
	Perform Commissioning       scf_file=${default_Comm_file}       verify_bts_status=False		timeout=900


Check the NCF by login board
	Setup Remote Access	remote_device=bts	alias=default
	${output}=		Remote Command Execute		command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.4"       alias=default
   	Should Contain  ${Output}	10.171.8.4
	${output2}=		Remote Command Execute		command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.5"       alias=default
   	Should Contain  ${Output2}	10.171.8.5
	Teardown Remote Access      alias=default
	Sleep	10

Check the 1 NTP IP configured in NCF from DHCP
	Setup Remote Access	remote_device=bts	alias=default
	${output}=		Remote Command Execute		command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.5"       alias=default
   	Should not Contain  ${Output}	10.171.8.5
	${output2}=		Remote Command Execute		command=cat /ffs/run/config/NCF.xml | grep -i "10.171.8.4"       alias=default
   	Should Contain  ${Output2}	10.171.8.4
	Teardown Remote Access      alias=default
	Sleep	10