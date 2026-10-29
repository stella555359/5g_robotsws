*** Settings ***
Documentation
...              [Author]      "Nandini R"
...              [Maintenance] "TRS I & V Tools Bangalore Team"

*** Keywords ***
Choose algorithm and establish tunnel
	[Arguments]		${Algorithm_File}		${PFS_Flag}
	${RandomChossenIkeEncryption}=			Evaluate	random.choice(@{IKEEncryptionLList})	random
	Remove Values From List		${IKEEncryptionLList}		${RandomChossenIkeEncryption}
	${RandomChossenIkeAuthentication}=		Evaluate	random.choice(@{IKEAuthnenticationLList})	random
	Remove Values From List		${IKEAuthnenticationLList}		${RandomChossenIkeAuthentication}
	${RandomChossenESPEncryption}=			Evaluate	random.choice(@{ESPEncryptionMethod})	random
	Remove Values From List		${ESPEncryptionMethod}		${RandomChossenESPEncryption}
	${RandomChossenESPAuthentication}=		Evaluate	random.choice(@{ESPAuthenticationMethod})	random
	Remove Values From List		${ESPAuthenticationMethod}		${RandomChossenESPAuthentication}
	${RandomChosenDHAlgorithm}=			Evaluate	random.choice(@{IKEDHGroupList})	random
	Remove Values From List		${IKEDHGroupList}	${RandomChosenDHAlgorithm}
	${RandomPFSDHGroup}=	Evaluate	random.choice(@{PFSDHGroupList})	random
	Set Suite Variable		${RandomChossenIkeEncryption}		${RandomChossenIkeEncryption}
	Set Suite Variable		${RandomChossenIkeAuthentication}	${RandomChossenIkeAuthentication}
	Set Suite Variable		${RandomChossenESPEncryption}		${RandomChossenESPEncryption}
	Set Suite Variable		${RandomChossenESPAuthentication}	${RandomChossenESPAuthentication}
	Set Suite Variable		${RandomChosenDHAlgorithm}			${RandomChosenDHAlgorithm}
	Set Suite Variable 		${RandomPFSDHGroup}		${RandomPFSDHGroup}
	Run     cp ${Algorithm_File} ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
	Perform Recommissioning		type=delta		delta_file=${Algorithm_Delta}
	Enable Ipsec on SecureGW
	Enable Ipsec on Admin

Get IKE SPI Value Before Rekeying
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
	@{IKE_SPI_I_BeforeRekey}=       Create List
	@{IKE_SPI_R_BeforeRekey}=       Create List
	@{IKE_lifetime_list}=        Create List

	${index}=		Get Length		${policy_list}
	${index}=		Evaluate		${index}+1

	FOR    ${i}   IN RANGE     1   ${index}
		${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime
	   Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{policy_list}
	   ${index}=       Get index from List    ${policy_list}        ${i}
	   ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
	   Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
	   Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
	   @{ipsec_status}=    Split String        ${stdout}
	   ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
	   ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
	   Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
	   Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
	   ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
    END
	Set Suite Variable      @{IKE_SPI_I_BeforeRekey}        @{IKE_SPI_I_BeforeRekey}
	Set Suite Variable      @{IKE_SPI_R_BeforeRekey}        @{IKE_SPI_R_BeforeRekey}
	Set Suite Variable      ${max_val}      ${max_val}

Verify IKE SPI After Rekeying
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{policy_list}
       Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END

Verify IKE Algorithm
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
	FOR    ${i}     IN     @{policy_list}
		Execute command on ENodeB		ipsec statusall | grep "IKE proposal" | grep conn${i}
		${IKE_Authentication_enB}=		Get From Dictionary		${IKEAuthenticationDict}	${RandomChossenIkeAuthentication}
		Should Match Regexp			'${stdout}'			${IKE_Authentication_enB}
		${IKE_Encryption_enB}=		Get From Dictionary		${IKEEncryptionDict}	${RandomChossenIkeEncryption}
		Should Match Regexp			'${stdout}'		${IKE_Encryption_enB}
	END

Verify ESP Algorithm
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
	FOR    ${i}     IN     @{policy_list}
		Execute command on ENodeB    ipsec statusall | grep conn${i}
    	${ESP_Algorithm_Line}=    Get Line    ${stdout}   -2
		${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
       Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary 	${ESPAuthenticationDict}	${RandomChossenESPAuthentication}
		Should Match Regexp  	 	'${ESP_Algorithm_Line}'		${ESP_Authentication_Algorithm_enB}
    END

Get the combination from conf file in enB
	Enable Ipsec On Bts
	Sleep 	60
	Execute command on ENodeB		cp /etc/ipsec.conf /tmp/ipsec.conf
	Setup Enb Fsm Access
	File Should Exist On Enb		/tmp/ipsec.conf
	Disable Ipsec On Bts
	Sleep 	30
	Get Enb File	/tmp/ipsec.conf   /home/ute/bts_ipsec.conf
	${ike_value}=	Run		awk '/ike=/' /home/ute/bts_ipsec.conf | sed -n '2p'
	${esp_value}=	Run		awk '/esp=/' /home/ute/bts_ipsec.conf | sed -n '1p'
	Run 	sed -i 's/\bike=.*$/${ike_value}/' ${SECGW_CONF}
	Run 	sudo sed -i 's/esp=.*/${esp_value}/g' ${SECGW_CONF}
	Teardown Enb Fsm Access

Check IKE Rekeying time on eNB in Seconds
	${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}-${sleep}
	${min_val}=     Evaluate        ${sa_lifetime}-(${rekey_margin}+${rekey_margin}*${rekeyfuzz}/100)-${sleep}
	${rekeying_time}=     Evaluate        ${rekeying_time}*60
	Should Be True		${rekeying_time} > ${min_val}
	Should Be True		${rekeying_time} <= ${max_val} + 60

Check IKE Rekeying time on eNB in hours
	${rekeying_hour_value}=			Evaluate		${sa_lifetime}/3600
	Should Be True		${rekeying_time} == ${rekeying_hour_value}-1

Verify PFS DH Algorithm to be same as opted in BTS
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
	${PFSDHGroupDict}			Create Dictionary	DH2=MODP_1024		DH14=MODP_2048		DH19=ECP_256		DH20=ECP_384
	FOR    ${i}     IN     @{policy_list}
		${status}=     Run     sudo ipsec statusall | grep conn${i}
    	${ESP_Algorithm_Line}=    Get Line    ${status}   -2
		${PFS_DH_Algorithm_enB}=	Get From Dictionary		${PFSDHGroupDict}		${RandomPFSDHGroup}
		Should Match Regexp 		'${ESP_Algorithm_Line}'		${PFS_DH_Algorithm_enB}
    END

Change Ipsec conf file in VM to enable PFS
    [Arguments]     ${ESP_value}=${Ipsec_Conf_with_PFS}
	Run 	sudo sed -i 's/esp=.*/${ESP_value}/g' ${SECGW_CONF}
    Run     sudo ipsec restart

Get ESP SPI value before Rekeying
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
    @{ESP_SPI_InitiatorList_Before_rekeying}=       Create List
    @{ESP_SPI_ResponderList_Before_rekeying}=       Create List
    ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
    Set Suite Variable      ${max_val}
    FOR    ${i}   IN       @{policy_list}
       Execute command on ENodeB       ipsec statusall | grep "ESP SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_ESP_SPI}=       Get From List       ${ipsec_status}     7
       ${responder_ESP_SPI}=       Get From List       ${ipsec_status}     8
       Append To List      ${ESP_SPI_InitiatorList_Before_rekeying}        ${initiator_ESP_SPI}
       Append To List      ${ESP_SPI_ResponderList_Before_rekeying}        ${responder_ESP_SPI}
    END
    Set Suite Variable      @{ESP_SPI_InitiatorList_Before_rekeying}        @{ESP_SPI_InitiatorList_Before_rekeying}
    Set Suite Variable      @{ESP_SPI_ResponderList_Before_rekeying}        @{ESP_SPI_ResponderList_Before_rekeying}
    Log To Console		${max_val}
	Sleep		${max_val}
	Sleep   60s

Verify ESP SPI After Rekeying
	[Arguments]		${policy_list}=${Combination_1_Policy_List}
    Set Suite Variable      ${index}    0
    FOR    ${i}    IN      @{policy_list}
       Execute command on ENodeB   ipsec statusall | grep "ESP SPI" | grep conn${i}
       @{ipsec_status}=        Split String    ${stdout}
       ${initiator_ESP_SPI}=       Get From List   ${ipsec_status}     7
       ${responder_ESP_SPI}=   Get From List   ${ipsec_status}     8
       Should Not Be Equal As Strings      ${initiator_ESP_SPI}        ${ESP_SPI_InitiatorList_Before_rekeying}[${index}]
       Should Not Be Equal As Strings      ${responder_ESP_SPI}        ${ESP_SPI_ResponderList_Before_rekeying}[${index}]
       ${index}=   Evaluate    ${index}+1
       Set Suite Variable  ${index}    ${index}
    END

Choose GCM/GMAC for IKE and establish tunnel
    ${RandomGCM}=   Evaluate    random.choice(@{IKE_GCM_List})  random
    ${RandomChossenIkeEncryption}=      Catenate    SEPARATOR=_     ENC         ${RandomGCM}
    ${RandomChossenIkeAuthentication}=      Catenate    SEPARATOR=_     AUTH            ${RandomGCM}
    Set Suite variable      ${RandomChossenIkeAuthentication}    ${RandomChossenIkeAuthentication}
    Set Suite variable      ${RandomChossenIkeEncryption}    ${RandomChossenIkeEncryption}
    ${RandomChossenESPEncryption}=          Evaluate    random.choice(@{ESPEncryptionMethod})   random
    Remove Values From List     ${ESPEncryptionMethod}      ${RandomChossenESPEncryption}
    Set Suite variable      ${RandomChossenESPEncryption}    ${RandomChossenESPEncryption}
    ${RandomChossenESPAuthentication}=      Evaluate    random.choice(@{ESPAuthenticationMethod})   random
    Remove Values From List     ${ESPAuthenticationMethod}      ${RandomChossenESPAuthentication}
    ${RandomChosenDHAlgorithm}=         Evaluate    random.choice(@{IKEDHGroupList})    random
    Remove Values From List     ${IKEDHGroupList}   ${RandomChosenDHAlgorithm}
    Run Keyword If      '${RandomChossenESPEncryption}' == 'ENC_AES_GCM_ICV16_128'      Set Suite Variable       ${RandomChossenESPAuthentication}
	...    AUTH_AES_GCM_ICV16_128
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GCM_ICV16_256'      Set Suite Variable       ${RandomChossenESPAuthentication}
	...    AUTH_AES_GCM_ICV16_256
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GMAC_128'           Set Suite Variable      ${RandomChossenESPAuthentication}
	...    AUTH_AES_GMAC_128
    ...         ELSE IF     '${RandomChossenESPEncryption}' == 'ENC_AES_GMAC_256'           Set Suite Variable      ${RandomChossenESPAuthentication}
    ...    AUTH_AES_GMAC_256
    ...         ELSE        Set Suite Variable      ${RandomChossenESPAuthentication}     ${RandomChossenESPAuthentication}

    ${RandomPFSDHGroup}=    Evaluate    random.choice(@{PFSDHGroupList})    random
    Set Suite variable      ${RandomPFSDHGroup}  ${RandomPFSDHGroup}
    Run     cp ${Algorithm_PFS_File} ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
    Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
    Perform Recommissioning     type=delta      delta_file=${Algorithm_Delta}
    Enable Ipsec on SecureGW
    Enable Ipsec on Admin