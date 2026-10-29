*** Settings ***
Documentation
...     [Author]            "Meghana J"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers ipsec with PSK configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "TRS_CB010465_5GC002215_DPD optimisation_on_Cloud_for_all_tunnels"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB010465"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_CB010465.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/Cloud_Ipsec_Rekeying.robot

Force Tags		CLOUD_F		CA_VRF_BLR2		SBTS00		SBTS24R2	SBTS24R3	QCD_MN_RAN	QCP_RAN_VRF	CRT

***Test case***
[1]CB010465-K-a_TRS_CB010465_5GC002215_DPD optimisation_on_Cloud_for_all_tunnels
	Perform Commissioning on vcu and vdu
	Perform IPSEC PSK configuration on vcu and vdu
	Run	sudo cp ${SECGW_CONF} ${SECGW_BACKUP_COPY}
	Run	sudo cp ${SECGW_IPSEC_FILE} ${SECGW_CONF}
	Run	sudo cp ${SECRETS_CONF} ${SECRETS_BACKUP_COPY}
	Run	sudo cp ${SECRETS_IPSEC_FILE} ${SECRETS_CONF}
	Perform PSK Configuration on vcu and vdu
	Verify ipsec status
	Verify DPD Optimization
	Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
	Attach UE and send ul dl traffic
    Choose algorithm and establish tunnel       ${Algorithm_PFS_File}       ${Algorithm_PFS_File_1}       false
    Attach UE and send ul dl traffic
    Get IKE SPI Value Before Rekeying for cpif pod
    Get IKE SPI Value Before Rekeying for upue pod
	Get IKE SPI Value Before Rekeying for cprt pod
    Get IKE SPI Value Before Rekeying for l2nrt pod
	Sleep	${max_val}
	Stop traffic and detach UE
#step1
    Verify IKE Algorithm for cpif pod
	Verify ESP Algorithm for cpif pod
#step2
	Verify IKE Algorithm for upue pod
	Verify ESP Algorithm for upue pod
#step3
    Verify IKE Algorithm for cprt pod
	Verify ESP Algorithm for cprt pod
#step4
    Verify IKE Algorithm for l2nrt pod
	Verify ESP Algorithm for l2nrt pod
#Step5
	Verify IKE SPI After Rekeying for cpif pod
	Verify IKE SPI After Rekeying for upue pod
	Verify IKE SPI After Rekeying for cprt pod
	Verify IKE SPI After Rekeying for l2nrt pod