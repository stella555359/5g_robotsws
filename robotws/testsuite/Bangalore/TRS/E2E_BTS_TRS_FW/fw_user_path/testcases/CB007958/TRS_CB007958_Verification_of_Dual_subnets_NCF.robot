*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to validate Dual subnets for DHCP-less Plug and Play with NCF"
    ...     [Date]                  "04-03-2022"
    ...     [Author]                "Nandini R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "PNP"
    ...     [Feature_ID]            "CB007958"
    ...     [Validation_status]     "tested"
    ...     [Validated_TestLine]    "ASOE"

Resource	     ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/../resources/Common_Autoconnection_Autoconfiguration.robot

Force Tags		CA_E2ET_BTSTRSPZ	SBTS00 	SBTS22R3	5G_RAN		QCD_MN_RAN  	QCP_RAN_ET	CRT	    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup		Run Keywords	Suite Setup Preconditions
...             AND		Setup Oamops
Suite Teardown	Run Keywords	Suite Teardown Postconditions
...             AND		Teardown Oamops

*** Test Cases ***
[1]TRS_CB007958_Verification_of_CB007958 Dual subnets for DHCP-less Plug and Play_NCF
	Initial Backup File
	Perform Recommissioning     type=delta  delta_file=${ChangeMplaneIP}    skip_parameter_relation_errors=${True}  timeout=300
	Take backup commissioning file
	${Vlan_ID}=		Query Admin Infomodel		query=${Single_Vlan_ID_Query}
	Run		sed -i "s/{{vlan_ID}}/${Vlan_ID}/g" ${NCF_template_SCF_file}
	Build download for Autoconfiguration
	Initial Emssim configuration for VirtualIP		${mplane_IP}
	Setup Ems	config_device=emssim1
	Reset	operation=reset_configuration	remove_user_account_credentials=${True}		remove_operator_certificates=${True}
	Sleep   30
	Perform Recommissioning        type=ncf        scf_file=${NCF_template_SCF_file}   verify_bts_status=${False}     timeout=300
	Sleep   60
	Enb Configuration Should Be Discovered		config_device=emssim1		enb_id=1
	Setup Oamops		bts_host=${mplane_IP}		alias=MplaneLogin
	Perform Software Download And Update	package=/home/flexi1/DOWNLOADS/${build_number}_release_BTSSM_downloadable.zip	wft_profile=sbtstrunk_00
	...		timeout=3600	alias=MplaneLogin
	Perform Commissioning		scf_file=${target_file}		verify_bts_status=False		alias=MplaneLogin
	Sleep	180
	Take backup commissioning file
	Check if software on eNB is '${build_number}'
	[Teardown]		Keywords to run at end

*** Keywords ***
Keywords to run at end
	Run Keyword And Ignore Error	Run		sudo rm -rf /home/flexi1/UPLOADS/${filename}.gz
	Run		sudo cp /var/log/emssim/emssim.* /home/flexi1/autoconnection_vlan.log
	teardown Emssim
	Teardown Oamops		alias=MplaneLogin
