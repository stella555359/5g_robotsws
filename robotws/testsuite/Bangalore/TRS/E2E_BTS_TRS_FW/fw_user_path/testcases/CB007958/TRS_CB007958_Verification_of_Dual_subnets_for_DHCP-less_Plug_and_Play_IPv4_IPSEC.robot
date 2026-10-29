*** Settings ***

Documentation
    ...     [Procedure]             "The test case is to validate DHCP-less Plug and Play with IPSEC ON TLS Off ipv4 mplaneip"
    ...     [Date]                  "28-03-22"
    ...     [Author]                "Nandini R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "PNP"
    ...     [Feature_ID]            "CB007958"
    ...     [Validation_status]     "tested"
    ...     [Validated_TestLine]    "ASIB_Cloud"


Resource	     ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/../resources/Common_Autoconnection_Autoconfiguration.robot

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00      SBTS22R3     4G_FDD       QCD_MN_RAN        QCP_RAN_ET        CRT		CLOUD_R4BP

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

*** Test Cases ***
TRS_CB007958_Verification_of_Dual subnets for DHCP-less Plug and Play IPv4_Vlan_TLS On and PNP Report and config reset and clear and reset scenario
	Initial Backup File
    Run     sudo sed -i "s/{{vlan_ID}}/1/g" resources/trs_ac_param.json
	Perform Recommissioning     type=delta  delta_file=${ChangeMplaneIP}    skip_parameter_relation_errors=${True}  timeout=300
	Take backup commissioning file
	Build download for Autoconfiguration
	Strongswan configuration for Autoconfiguration VirtualIpv4
	TLS certificate configuration
	Initial Emssim configuration for VirtualIP		${mplane_IP}
	Setup Ems	config_device=emssim1
	Reset	operation=reset_configuration	remove_user_account_credentials=${True}		remove_operator_certificates=${True}
	Set Autoconnection Transport Params		trs_ac_profile=ac_profile1
	Sleep	30
	Run Ems Command		config_device=emssim1	command=slog ${Auto_Conn_Log_path}
	Run Ems Command		config_device=emssim1	command=log on 1
	Run Ems Command		config_device=emssim1	command=autodiscover -off
	Run Ems Command		config_device=emssim1	command=ne3s_activate -password A0zY~rP#8Mx@ -pnp -ac
	Sleep	120
	${command}=     Catenate   proxy_ssl_cert -cert /opt/emssim/proxy/ssl/servercert.pem -key
	...   /opt/emssim/proxy/ssl/serverprivkey.pem -cacert /opt/emssim/proxy/ssl/cacert.pem
	Run Ems Command		config_device=emssim1   command=${command}
	Run Ems Command		config_device=emssim1
	...     command=auto_sw_update -enable -build /home/flexi1/DOWNLOADS/${build_number}_release_BTSSM_downloadable.zip
	Run Ems Command		config_device=emssim1
	...     command=auto_config -plan /home/flexi1/UPLOADS/${filename}.gz -automatic_activate 1 -commissioning_only 1
	Sleep	2500
	Run Ems Command		config_device=emssim1	command=slog
	Run		cp ${Auto_Conn_Log_path} ${CURDIR}/execution_logs/
	Take backup commissioning file
	Check if software on eNB is '${build_number}'
	Verify pnpreport for autoconfiguration with IPSEC
	[Teardown]		Keywords to run at end


*** Keywords ***
Keywords to run at end
	Run Keyword And Ignore Error	Run		sudo rm -rf /home/flexi1/UPLOADS/${filename}.gz
	Run		sudo cp /var/log/emssim/emssim.* /home/flexi1/autoconnection_vlan.log
	teardown Emssim
