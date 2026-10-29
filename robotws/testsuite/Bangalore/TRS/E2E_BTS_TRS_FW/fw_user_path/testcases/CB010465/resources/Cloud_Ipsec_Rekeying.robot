*** Settings ***
Documentation
...              [Author]      "Meghana J"
...              [Maintenance] "TRS I & V Tools Bangalore Team"

*** Variables ***
${bash}         --bash
*** Keywords ***
Choose algorithm and establish tunnel
	[Arguments]		${Algorithm_PFS_File}	${Algorithm_PFS_File_1}		${PFS_Flag}
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
	Run     cp ${Algorithm_PFS_File_1} ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeAuthentication}}/${RandomChossenIkeAuthentication}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPEncryption}}/${RandomChossenESPEncryption}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenESPAuthentication}}/${RandomChossenESPAuthentication}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChosenDHAlgorithm}}/${RandomChosenDHAlgorithm}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{PFS_Flag}}/${PFS_Flag}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomChossenIkeEncryption}}/${RandomChossenIkeEncryption}/g' ${Algorithm_Delta_1}
	Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta}
	Run     sudo sed -i 's/{{RandomPFSDHGroup}}/${RandomPFSDHGroup}/g' ${Algorithm_Delta_1}
	Setup Oamops    dut=cbts    alias=vcu
	Perform Recommissioning		type=delta		delta_file=${Algorithm_Delta}   dut=cbts    alias=vcu
    Sleep   60
	Teardown Oamops  dut=cbts   alias=vcu
 	Run	sudo ipsec restart
	Setup Oamops    dut=dbts    alias=vdu
	Perform Recommissioning		type=delta		delta_file=${Algorithm_Delta_1}   dut=dbts    alias=vdu
    Sleep   60
	Teardown Oamops  dut=dbts   alias=vdu
	Run	sudo ipsec restart

Get IKE SPI Value Before Rekeying for cpif pod
    Setup Oamops    dut=cbts    alias=vcu
	@{IKE_SPI_I_BeforeRekey}=       Create List
	@{IKE_SPI_R_BeforeRekey}=       Create List
	@{IKE_lifetime_list}=        Create List

	FOR    ${i}   IN RANGE  1   4
	${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime     dut=cbts    alias=vcu
	Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{Combination_1_Policy_List}
   ${index}=       Get index from List    ${Combination_1_Policy_List}        ${i}
	   ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
       Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
	   Setup Oamops    dut=vcu_7186
       Setup Remote Access    remote_device=${dut}.ocp     alias=${dut}
       Execute Interactive Remote Command
       ...      command=kubectl exec -it -n ${cu_name_${dut}} ${cran_pod_name_${dut}} -c ${cran_pod_agent_${dut}} -- bash     alias=${dut}
       ${std}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut}
       ${ex}=       Execute Interactive Remote Command       command=${exit}    alias=${dut}
	   @{ipsec_status}=    Split String     ${std}
	   ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
	   ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
	   Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
	   Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
	   ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
       Teardown Oamops  dut=vcu_7186
    END
	Set Suite Variable      @{IKE_SPI_I_BeforeRekey_cpif}        @{IKE_SPI_I_BeforeRekey}
	Set Suite Variable      @{IKE_SPI_R_BeforeRekey_cpif}        @{IKE_SPI_R_BeforeRekey}
	Set Suite Variable      ${max_val}      ${max_val}
    Teardown Oamops  dut=cbts   alias=vcu

Get IKE SPI Value Before Rekeying for upue pod
    Setup Oamops    dut=cbts    alias=vcu
	@{IKE_SPI_I_BeforeRekey}=       Create List
	@{IKE_SPI_R_BeforeRekey}=       Create List
	@{IKE_lifetime_list}=        Create List

	FOR    ${i}   IN RANGE  1   4
	${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime     dut=cbts    alias=vcu
	Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{Combination_2_Policy_List}
   ${index}=       Get index from List    ${Combination_2_Policy_List}        ${i}
	   ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
       Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
       Setup Oamops    dut=vcu_7186
       Setup Remote Access    remote_device=${dut}.ocp     alias=${dut}
       Execute Interactive Remote Command
       ...      command=kubectl exec -it -n ${cu_name_${dut}} ${cran_upue_pod_name_${dut}} -c ${cran_upue_pod_agent_${dut}} -- bash   alias=${dut}
       ${std}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut}
       ${ex}=       Execute Interactive Remote Command      command=${exit}     alias=${dut}
	   @{ipsec_status}=    Split String     ${std}
	   ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
	   ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
	   Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
	   Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
	   ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
       Teardown Oamops  dut=vcu_7186
    END
	Set Suite Variable      @{IKE_SPI_I_BeforeRekey_upue}        @{IKE_SPI_I_BeforeRekey}
	Set Suite Variable      @{IKE_SPI_R_BeforeRekey_upue}        @{IKE_SPI_R_BeforeRekey}
	Set Suite Variable      ${max_val}      ${max_val}
    Teardown Oamops		dut=cbts	alias=vcu

Get IKE SPI Value Before Rekeying for cprt pod
    Setup Oamops    dut=dbts    alias=vdu
    @{IKE_SPI_I_BeforeRekey}=       Create List
    @{IKE_SPI_R_BeforeRekey}=       Create List
    @{IKE_lifetime_list}=        Create List

    FOR    ${i}   IN RANGE  1   2
    ${ikeMaxLifeTime}=      Get Parameter       param_path=IKEP-${i}:ikeMaxLifeTime     dut=dbts    alias=vdu
    Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
    FOR    ${i}   IN   @{Combination_3_Policy_List}
   ${index}=       Get index from List    ${Combination_3_Policy_List}        ${i}
       ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
       Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
       Setup Oamops    dut=vdu_7186
       Setup Remote Access    remote_device=${dut1}.ocp     alias=${dut1}
       Execute Interactive Remote Command
       ...  command=kubectl exec -it -n ${cu_name_${dut1}} ${cran_cprt_pod_name_${dut1}} -c ${cran_cprt_pod_agent_${dut1}} -- bash      alias=${dut1}
       ${std}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut1}
       @{ipsec_status}=    Split String     ${std}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
       Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
       ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
    END
	Teardown Oamops  dut=vdu_7186
    Set Suite Variable      @{IKE_SPI_I_BeforeRekey_cprt}        @{IKE_SPI_I_BeforeRekey}
    Set Suite Variable      @{IKE_SPI_R_BeforeRekey_cprt}        @{IKE_SPI_R_BeforeRekey}
    Set Suite Variable      ${max_val}      ${max_val}
	${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut1}
    Teardown Oamops		dut=dbts	alias=vdu

Get IKE SPI Value Before Rekeying for l2nrt pod
	Setup Oamops    dut=dbts    alias=vdu
    @{IKE_SPI_I_BeforeRekey}=       Create List
    @{IKE_SPI_R_BeforeRekey}=       Create List
    @{IKE_lifetime_list}=        Create List

    FOR    ${i}   IN RANGE  1   2
    ${ikeMaxLifeTime}=      Get Parameter       param_path=IKEP-${i}:ikeMaxLifeTime     dut=dbts    alias=vdu
    Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
    FOR    ${i}   IN   @{Combination_4_Policy_List}
   ${index}=       Get index from List    ${Combination_4_Policy_List}        ${i}
       ${sa_lifetime}=     Get From List       ${IKE_lifetime_list}     ${index}
       Set Suite Variable      ${sa_lifetime}      ${sa_lifetime}
       Setup Oamops    dut=vdu_7186
       Setup Remote Access    remote_device=${dut1}.ocp     alias=${dut1}
       Execute Interactive Remote Command
       ...  command=kubectl exec -it -n ${cu_name_${dut1}} ${cran_l2nrt_pod_name_${dut1}} -c ${cran_l2nrt_pod_agent_${dut1}} -- bash   alias=${dut1}
       ${std}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut1}
       @{ipsec_status}=    Split String     ${std}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Append To List      ${IKE_SPI_I_BeforeRekey}        ${initiator_IKEv2_SPI}
       Append To List      ${IKE_SPI_R_BeforeRekey}        ${responder_IKEv2_SPI}
       ${max_val}=     Evaluate    ${sa_lifetime}-${rekey_margin}
    END
	Teardown Oamops  dut=vdu_7186
    Set Suite Variable      @{IKE_SPI_I_BeforeRekey_l2nrt}        @{IKE_SPI_I_BeforeRekey}
    Set Suite Variable      @{IKE_SPI_R_BeforeRekey_l2nrt}        @{IKE_SPI_R_BeforeRekey}
    Set Suite Variable      ${max_val}      ${max_val}
    ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut1}
	Teardown Oamops		dut=dbts	alias=vdu

Verify IKE SPI After Rekeying for cpif pod
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_1_Policy_List}
       Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
       Execute Interactive Remote Command
       ...      command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_pod_name_${dut2}} -c ${cran_pod_agent_${dut2}} -- bash   alias=${dut2}
       ${stdout}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut2}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey_cpif}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey_cpif}[${index}]
       ${index}=   Evaluate    ${index}+1
	   ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
    END

Verify IKE SPI After Rekeying for upue pod
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_2_Policy_List}
       Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
       Execute Interactive Remote Command
       ...     command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_upue_pod_name_${dut2}} -c ${cran_upue_pod_agent_${dut2}} -- bash   alias=${dut2}
       ${stdout}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut2}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey_upue}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey_upue}[${index}]
       ${index}=   Evaluate    ${index}+1
	   ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
    END

Verify IKE SPI After Rekeying for cprt pod
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_3_Policy_List}
       Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
       Execute Interactive Remote Command
       ...     command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_cprt_pod_name_${dut3}} -c ${cran_cprt_pod_agent_${dut3}} -- bash   alias=${dut3}
       ${stdout}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut3}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey_cprt}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey_cprt}[${index}]
       ${index}=   Evaluate    ${index}+1
	   ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END

Verify IKE SPI After Rekeying for l2nrt pod
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_4_Policy_List}
       Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
       Execute Interactive Remote Command
       ...   command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_l2nrt_pod_name_${dut3}} -c ${cran_l2nrt_pod_agent_${dut3}} -- bash   alias=${dut3}
       ${stdout}=     Execute Interactive Remote Command      command=${status} | grep "IKEv2 SPI" | grep conn${i}  alias=${dut3}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     12
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     13
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey_l2nrt}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey_l2nrt}[${index}]
       ${index}=   Evaluate    ${index}+1
	   ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END

Verify IKE Algorithm for cpif pod
	FOR    ${i}     IN     @{Combination_1_Policy_List}
		Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
        Execute Interactive Remote Command
        ...     command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_pod_name_${dut2}} -c ${cran_pod_agent_${dut2}} -- bash   alias=${dut2}
        ${stdout1}=     Execute Interactive Remote Command      command=${status} | grep "IKE proposal" | grep conn${i}  alias=${dut2}
		${IKE_Authentication_enB}=		Get From Dictionary		${IKEAuthenticationDict}	${RandomChossenIkeAuthentication}
		Should Match Regexp         '${stdout1}'            ${IKE_Authentication_enB}
		${IKE_Encryption_enB}=		Get From Dictionary		${IKEEncryptionDict}	${RandomChossenIkeEncryption}
		Should Match Regexp         '${stdout1}'            ${IKE_Encryption_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
	END

Verify IKE Algorithm for upue pod
	FOR    ${i}     IN     @{Combination_2_Policy_List}
		Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
        Execute Interactive Remote Command
        ...    command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_upue_pod_name_${dut2}} -c ${cran_upue_pod_agent_${dut2}} -- bash   alias=${dut2}
        ${stdout1}=     Execute Interactive Remote Command      command=${status} | grep "IKE proposal" | grep conn${i}  alias=${dut2}
		${IKE_Authentication_enB}=		Get From Dictionary		${IKEAuthenticationDict}	${RandomChossenIkeAuthentication}
		Should Match Regexp         '${stdout1}'            ${IKE_Authentication_enB}
		${IKE_Encryption_enB}=		Get From Dictionary		${IKEEncryptionDict}	${RandomChossenIkeEncryption}
		Should Match Regexp         '${stdout1}'            ${IKE_Encryption_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
	END

Verify IKE Algorithm for cprt pod
    FOR    ${i}     IN     @{Combination_3_Policy_List}
		Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
        Execute Interactive Remote Command
        ...    command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_cprt_pod_name_${dut3}} -c ${cran_cprt_pod_agent_${dut3}} -- bash   alias=${dut3}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep "IKE proposal" | grep conn${i}  alias=${dut3}
        ${IKE_Authentication_enB}=      Get From Dictionary     ${IKEAuthenticationDict}    ${RandomChossenIkeAuthentication}
        Should Match Regexp         '${stdout2}'            ${IKE_Authentication_enB}
        ${IKE_Encryption_enB}=      Get From Dictionary     ${IKEEncryptionDict}    ${RandomChossenIkeEncryption}
        Should Match Regexp         '${stdout2}'            ${IKE_Encryption_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END

Verify IKE Algorithm for l2nrt pod
    FOR    ${i}     IN     @{Combination_4_Policy_List}
		Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
        Execute Interactive Remote Command
        ...  command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_l2nrt_pod_name_${dut3}} -c ${cran_l2nrt_pod_agent_${dut3}} -- bash   alias=${dut3}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep "IKE proposal" | grep conn${i}  alias=${dut3}
        ${IKE_Authentication_enB}=      Get From Dictionary     ${IKEAuthenticationDict}    ${RandomChossenIkeAuthentication}
        Should Match Regexp         '${stdout2}'            ${IKE_Authentication_enB}
        ${IKE_Encryption_enB}=      Get From Dictionary     ${IKEEncryptionDict}    ${RandomChossenIkeEncryption}
        Should Match Regexp         '${stdout2}'            ${IKE_Encryption_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END

Verify ESP Algorithm for cpif pod
	FOR    ${i}     IN     @{Combination_1_Policy_List}
		Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
        Execute Interactive Remote Command
        ...     command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_pod_name_${dut2}} -c ${cran_pod_agent_${dut2}} -- bash   alias=${dut2}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep conn${i}  alias=${dut2}
    	${ESP_Algorithm_Line}=    Get Line    ${stdout2}   -3
		${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary 	${ESPAuthenticationDict}	${RandomChossenESPAuthentication}
		Should Match Regexp  	 	'${ESP_Algorithm_Line}'		${ESP_Authentication_Algorithm_enB}
        ${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
   END

Verify ESP Algorithm for upue pod
	FOR    ${i}     IN     @{Combination_2_Policy_List}
		Setup Remote Access    remote_device=${dut2}.ocp     alias=${dut2}
        Execute Interactive Remote Command
        ...     command=kubectl exec -it -n ${cu_name_${dut2}} ${cran_upue_pod_name_${dut2}} -c ${cran_pod_agent_${dut2}} -- bash   alias=${dut2}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep conn${i}  alias=${dut2}
    	${ESP_Algorithm_Line}=    Get Line    ${stdout2}   -3
		${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
		${ESP_Authentication_Algorithm_enB}=	Get From Dictionary 	${ESPAuthenticationDict}	${RandomChossenESPAuthentication}
		Should Match Regexp  	 	'${ESP_Algorithm_Line}'		${ESP_Authentication_Algorithm_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut2}
    END

Verify ESP Algorithm for cprt pod
    FOR    ${i}     IN     @{Combination_3_Policy_List}
		Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
        Execute Interactive Remote Command
        ...    command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_cprt_pod_name_${dut3}} -c ${cran_cprt_pod_agent_${dut3}} -- bash   alias=${dut3}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep conn${i}  alias=${dut3}
        ${ESP_Algorithm_Line}=    Get Line    ${stdout2}   -3
        ${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
        ${ESP_Authentication_Algorithm_enB}=    Get From Dictionary     ${ESPAuthenticationDict}    ${RandomChossenESPAuthentication}
        Should Match Regexp         '${ESP_Algorithm_Line}'     ${ESP_Authentication_Algorithm_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END

Verify ESP Algorithm for l2nrt pod
    FOR    ${i}     IN     @{Combination_4_Policy_List}
		Setup Remote Access    remote_device=${dut3}.ocp     alias=${dut3}
        Execute Interactive Remote Command
        ...  command=kubectl exec -it -n ${cu_name_${dut3}} ${cran_l2nrt_pod_name_${dut3}} -c ${cran_l2nrt_pod_agent_${dut3}} -- bash   alias=${dut3}
        ${stdout2}=     Execute Interactive Remote Command      command=${status} | grep conn${i}  alias=${dut3}
        ${ESP_Algorithm_Line}=    Get Line    ${stdout2}   -3
        ${ESP_Encryption_Algorithm_enB}=        Get From Dictionary     ${ESPEncryptionDict}    ${RandomChossenESPEncryption}
        Should Match Regexp     '${ESP_Algorithm_Line}'       ${ESP_Encryption_Algorithm_enB}
        ${ESP_Authentication_Algorithm_enB}=    Get From Dictionary     ${ESPAuthenticationDict}    ${RandomChossenESPAuthentication}
        Should Match Regexp         '${ESP_Algorithm_Line}'     ${ESP_Authentication_Algorithm_enB}
		${ex}=      Execute Interactive Remote Command      command=${exit}     alias=${dut3}
    END