*** Settings ***
Documentation
...              [Author]      "Meghana J"
...              [Maintenance] "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***
Perform Basic Commisioning
	Perform Commissioning       scf_file=${BASIC_SCF}   verify_bts_status=False     timeout=400     alias=default
	Sleep	300

Perform Recommissioning with Dynamic Inner IP configuration
	Perform Recommissioning        type=delta      delta_file=${IPSEC}       skip_parameter_relation_errors=${True}      timeout=300

Preconditions
	Run    sudo cp ${IPSEC_CONF} ${BACKUP_PATH}
	Run    sudo mv ${IPSEC_CONF_WITH_UNIQUE_ID_YES} ${IPSEC_CONF}
	Run    sudo ipsec restart
	Sleep	40

Verify IPSec Status after CMP Initialization
	Perform Recommissioning		type=param_path		param_path=CMP-1:caSubjectName		operation=update	value=${CMP_subjectname}	timeout=90
	Sleep	120
	Certificate Configure	operation=install_cmp_certificate	timeout=120
	Sleep	10
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEnabled	operation=update	value=false		timeout=60
	Sleep	10
	Verify IPSec Status NO_STATE
	Perform Recommissioning		type=param		param_path=IPSECC-1:ipSecEnabled	operation=update	value=true		timeout=60
	Sleep	30
	Verify IPSec Status ESTABLISHED
	Certificate Configure	operation=cmp_update_key	timeout=120

Verify IPSec Status NO_STATE
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1    timeout=30
    ${length}=       Get Length    ${ikep_list}
    Log    Total IKEP instances: ${length}

    FOR    ${item}    IN    @{ikep_list}
        ${state}=     Get From Dictionary    ${item}    ikePeerState
        Should Be Equal    ${state}    ${EXPECTED_STATE}
    END

Verify IPSec Status ESTABLISHED
    ${ikep_list}=    Query Admin Infomodel    query=get list //IKEP_R-1    timeout=30
    ${length}=       Get Length    ${ikep_list}
    Log    Total IKEP instances: ${length}

    FOR    ${item}    IN    @{ikep_list}
        ${state}=     Get From Dictionary    ${item}    ikePeerState
        Should Be Equal    ${state}    ${IKEP_State}
    END

Verify IKE and ESP SPI Before and After Rekeying
	Get IKE SPI Value Before Rekeying
	Get ESP SPI value before Rekeying
	Sleep	${max_val}
	Verify IKE SPI After Rekeying
	Verify ESP SPI After Rekeying

Verify ESP SPI Before and After Rekeying
    FOR    ${i}    IN RANGE    1    3
		Get ESP SPI value before Rekeying
		Sleep    ${max_val_esp}
		Verify ESP SPI After Rekeying
    END

Get IKE SPI Value Before Rekeying
	@{IKE_SPI_I_BeforeRekey}=       Create List
	@{IKE_SPI_R_BeforeRekey}=       Create List
	@{IKE_lifetime_list}=        Create List
	FOR    ${i}   IN RANGE     1   11
	${ikeMaxLifeTime}=		Get Parameter		param_path=IKEP-${i}:ikeMaxLifeTime
	Append To List      ${IKE_lifetime_list}     ${ikeMaxLifeTime}
    END
	FOR    ${i}   IN   @{Combination_1_Policy_List}
	   ${index}=       Get index from List    ${Combination_1_Policy_List}        ${i}
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
    FOR    ${i}    IN   @{Combination_1_Policy_List}
       Execute command on ENodeB       ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${initiator_IKEv2_SPI}=         Get From List       ${ipsec_status}     3
       ${responder_IKEv2_SPI}=         Get From List       ${ipsec_status}     4
       Should Not Be Equal As Strings      ${initiator_IKEv2_SPI}      ${IKE_SPI_I_BeforeRekey}[${index}]
       Should Not Be Equal As Strings      ${responder_IKEv2_SPI}      ${IKE_SPI_R_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END

Get ESP SPI value before Rekeying
    @{ESP_SPI_InitiatorList_Before_rekeying}=    Create List
    @{ESP_SPI_ResponderList_Before_rekeying}=    Create List
    ${max_val_esp}=    Set Variable    ${sa_lifetime}
    Set Suite Variable    ${max_val_esp}
    FOR    ${i}    IN    @{Combination_1_Policy_List}
        Execute command on ENodeB    ipsec statusall | grep "ESP SPI" | grep conn${i}
        @{ipsec_status}=    Split String    ${stdout}
        ${initiator_ESP_SPI}=    Get From List    ${ipsec_status}    7
        ${responder_ESP_SPI}=    Get From List    ${ipsec_status}    8
        Append To List    ${ESP_SPI_InitiatorList_Before_rekeying}    ${initiator_ESP_SPI}
        Append To List    ${ESP_SPI_ResponderList_Before_rekeying}    ${responder_ESP_SPI}
    END
    Set Suite Variable    @{ESP_SPI_InitiatorList_Before_rekeying}
    Set Suite Variable    @{ESP_SPI_ResponderList_Before_rekeying}

Verify ESP SPI After Rekeying
    Set Suite Variable      ${index}    0
    FOR    ${i}    IN      @{Combination_1_Policy_List}
       Execute command on ENodeB   ipsec statusall | grep "ESP SPI" | grep conn${i}
       @{ipsec_status}=        Split String    ${stdout}
       ${initiator_ESP_SPI}=       Get From List   ${ipsec_status}     7
       ${responder_ESP_SPI}=   Get From List   ${ipsec_status}     8
       Should Not Be Equal As Strings      ${initiator_ESP_SPI}        ${ESP_SPI_InitiatorList_Before_rekeying}[${index}]
       Should Not Be Equal As Strings      ${responder_ESP_SPI}        ${ESP_SPI_ResponderList_Before_rekeying}[${index}]
       ${index}=   Evaluate    ${index}+1
       Set Suite Variable  ${index}    ${index}
    END

Get IKE ID Value Before Rekeying
	@{IKE_request_ID_BeforeRekey}=       Create List

	FOR    ${i}   IN   @{Combination_1_Policy_List}
	   ${index}=       Get index from List    ${Combination_1_Policy_List}        ${i}
	   Execute command on ENodeB   ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
	   @{ipsec_status}=    Split String        ${stdout}
	   ${IKE_ID_BeforeRekey}=         Get From List       ${ipsec_status}	0
	   ${conn}=    Remove String    ${IKE_ID_BeforeRekey}    :
	   Append To List      ${IKE_request_ID_BeforeRekey}        ${IKE_ID_BeforeRekey}
    END
	Set Suite Variable      @{IKE_request_ID_BeforeRekey}        @{IKE_request_ID_BeforeRekey}

Verify IKE ID After Rekeying
    ${index}=   Set Variable        0
    FOR    ${i}    IN   @{Combination_1_Policy_List}
       Execute command on ENodeB   ipsec statusall | grep "IKEv2 SPI" | grep conn${i}
       @{ipsec_status}=    Split String        ${stdout}
       ${IKE_ID_AfterRekey}=         Get From List       ${ipsec_status}	0
	   ${conn}=    Remove String    ${IKE_ID_AfterRekey}    :
       Should Not Be Equal As Strings      ${IKE_ID_AfterRekey}      ${IKE_request_ID_BeforeRekey}[${index}]
       ${index}=   Evaluate    ${index}+1
    END