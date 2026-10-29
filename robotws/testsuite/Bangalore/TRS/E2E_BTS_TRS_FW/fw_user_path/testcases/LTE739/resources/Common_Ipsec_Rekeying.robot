*** Settings ***
Documentation
...              [Author]      "Nandini R"
...              [Maintenance] "TRS I & V Tools Bangalore Team"
Resource       ${CURDIR}/Admin_Common_Library.robot

*** Keywords ***
Choose algorithm and establish tunnel
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
	Run     cp ${Algorithm_PFS_File} ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
	Perform Recommissioning		type=delta		delta_file=${Algorithm_Delta}
    Sleep   60
	Enable Ipsec on Admin
	Enable Ipsec on SecureGW
    Sleep   60

Get IKE SPI Value Before Rekeying
	@{IKE_SPI_I_BeforeRekey}=       Create List
	@{IKE_SPI_R_BeforeRekey}=       Create List
	@{IKE_lifetime_list}=        Create List

	FOR    ${i}   IN RANGE     1   9
	${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime
	Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{Combination_2_Policy_List}
	   ${index}=       Get index from List    ${Combination_2_Policy_List}        ${i}
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
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_2_Policy_List}
       Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END

Verify IKE Algorithm
	FOR    ${i}     IN     @{Combination_2_Policy_List}
		Execute command on ENodeB		ipsec statusall | grep "IKE proposal" | grep conn${i}
		${IKE_Authentication_enB}=		Get From Dictionary		${IKEAuthenticationDict}	${RandomChossenIkeAuthentication}
		Should Match Regexp			'${stdout}'			${IKE_Authentication_enB}
		${IKE_Encryption_enB}=		Get From Dictionary		${IKEEncryptionDict}	${RandomChossenIkeEncryption}
		Should Match Regexp			'${stdout}'		${IKE_Encryption_enB}
	END

Verify ESP Algorithm
	FOR    ${i}     IN     @{Combination_2_Policy_List}
		Execute command on ENodeB    ipsec statusall | grep conn${i}
    	${ESP_Algorithm_Line}=    Get Line    ${stdout}   -2
		${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary 	${ESPAuthenticationDict}	${RandomChossenESPAuthentication}
		Should Match Regexp  	 	'${ESP_Algorithm_Line}'		${ESP_Authentication_Algorithm_enB}
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