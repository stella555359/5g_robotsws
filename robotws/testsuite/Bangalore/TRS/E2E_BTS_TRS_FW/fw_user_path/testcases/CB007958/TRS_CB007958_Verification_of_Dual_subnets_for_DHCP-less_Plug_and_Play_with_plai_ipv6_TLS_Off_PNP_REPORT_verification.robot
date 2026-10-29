*** Settings ***

Documentation
    ...     [Procedure]             "The test case is to validate DHCP-less Plug and Play with plain TLS Off ipv6 mplaneip"
    ...     [Date]                  "15-03-2022"
    ...     [Author]                "Nandini R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "PNP"
    ...     [Feature_ID]            "CB007958"
    ...     [Validation_status]     "tested"
    ...     [Validated_TestLine]    "ASIL_Cloud"

Resource	     ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/../resources/Common_Autoconnection_Autoconfiguration.robot

Force Tags    CA_E2ET_BTSTRSPZ     SBTS00     SBTS22R3     5G_RAN     QCD_MN_RAN     QCP_RAN_ET    CRT  	CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

*** Test Cases ***
[1]TRS_CB007958_Verification_of_Dual subnets for DHCP-less Plug and Play with plain ipv6 TLS Off_PNP REPORT verification
	Initial Backup File
	${Vlan_ID}=		Query Admin Infomodel		query=${Single_Vlan_ID_Query}
    Run     sudo sed -i "s/{{vlan_ID}}/${Vlan_ID}/g" resources/trs_ac_param.json
	Perform Recommissioning     type=delta  delta_file=${Add_IPv6_Mplane}    skip_parameter_relation_errors=${True}  timeout=300
	Take backup commissioning file
	Build download for Autoconfiguration
	Initial Emssim configuration for Virtual Ipv6		${mplane_ipv6_IP}
	Setup Ems	config_device=emssim1
    Reset   operation=reset_configuration   remove_user_account_credentials=${True}     remove_operator_certificates=${True}
    Run     sudo ip -6 route del ${mplane_ipv6_IP} via fc00::2 dev eth3
    Set Autoconnection Transport Params     trs_ac_profile=ac_profile2
    Sleep   300
    Setup Remote Access    remote_device=bts
    Get File From Remote Host   /var/log/Autoconnection.log     /tmp/Autoconnection.log
    ${res}= 	Run     cat /tmp/Autoconnection.log | grep -E "ping is started using secondary ip" | wc -l
    Should Be True     ${res} >= ${1}
    ${res}= 	Run     cat /tmp/Autoconnection.log | grep -E "ping to dst Ip: <TRSW_65>fc00::1</TRSW_65> Success" | wc -l
    Should Be True     ${res} >= ${1}
    ${res}= 	Run     cat /tmp/Autoconnection.log | grep -E "BTS backhaul connection Succeeded" | wc -l
    Should Be True     ${res} >= ${1}
    Run     sudo ip -6 route add ${mplane_ipv6_IP} via fc00::2 dev eth3
	Sleep	60
	Run Ems Command		config_device=emssim1	command=slog ${Auto_Conn_Log_path}
	Run Ems Command		config_device=emssim1	command=log on 1
	Run Ems Command		config_device=emssim1	command=autodiscover -off
	Run Ems Command		config_device=emssim1	command=ne3s_activate -password A0zY~rP#8Mx@ -pnp -ac
	Sleep	30
	Run Ems Command		config_device=emssim1
    ...     command=auto_sw_update -enable -build /home/flexi1/DOWNLOADS/${build_number}_release_BTSSM_downloadable.zip
	Run Ems Command		config_device=emssim1
	...     command=auto_config -plan /home/flexi1/UPLOADS/${filename}.gz -automatic_activate 1 -commissioning_only 1
	Sleep	2200
	Run Ems Command		config_device=emssim1	command=slog
	Run		cp ${Auto_Conn_Log_path} ${CURDIR}/execution_logs/
	Take backup commissioning file
	Check if software on eNB is '${build_number}'
	Verify pnpreport for autoconfiguration
	[Teardown]		Keywords to run at end

*** Keywords ***
Keywords to run at end
	Run Keyword And Ignore Error	Run		sudo rm /home/flexi1/UPLOADS/${filename}.gz
	Run		sudo cp /var/log/emssim/emssim.* /home/flexi1/autoconnection_vlan.log
	teardown Emssim
