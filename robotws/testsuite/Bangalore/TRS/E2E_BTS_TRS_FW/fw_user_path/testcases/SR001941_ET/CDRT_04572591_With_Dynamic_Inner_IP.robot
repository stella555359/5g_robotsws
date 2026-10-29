*** Settings ***
Documentation

...		[Procedure]	"CDRT_04572591_With_Dynamic_Inner_IP"
...		[Date]		"16-04-2025"
...		[Author]	"Prashanth"
...		[Feature_ID]	"SR001941"
...		[Maintenance]	"TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Common_Ipsec_Rekeying.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Test Cases ***
[1]CDRT_04572591_With_Dynamic_Inner_IP

	${alarms}        Verify Alarm
	Perform Basic Commisioning
	Perform Recommissioning with Dynamic Inner IP configuration
	Preconditions
	Verify IPSec Status ESTABLISHED
	Get IKE SPI Value Before Rekeying
	Verify IPSec Status after CMP Initialization
	Get ESP SPI value before Rekeying
	Verify ESP SPI After Rekeying
	Verify IKE SPI After Rekeying
	Run Keyword And Ignore Error    Verify Alarm      prev_alarms=${alarms}     check_unexpected_alarms=${True}

*** Keywords ***
Perform Basic Commisioning
	Perform Commissioning       scf_file=${BASIC_SCF}   verify_bts_status=False     timeout=400     alias=default
	Sleep	200

Perform Recommissioning with Dynamic Inner IP configuration
	Perform Recommissioning        type=delta      delta_file=${IPSEC}       skip_parameter_relation_errors=${True}      timeout=300

Preconditions
	Run    sudo cp ${IPSEC_CONF} ${BACKUP_PATH}
	Run    sudo mv ${IPSEC_CONF_WITH_UNIQUE_ID_YES} ${IPSEC_CONF}
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

Update IKE Max Lifetime
	Perform Recommissioning		type=param_path		param_path=IKEP-1:ikeMaxLifeTime	operation=update	value=3600	timeout=90
	Perform Recommissioning		type=param_path		param_path=IKEP-2:ikeMaxLifeTime	operation=update	value=3600	timeout=90

Verify IKE and ESP SPI Before and After Rekeying
	Get IKE SPI Value Before Rekeying
	Get ESP SPI value before Rekeying
	Sleep	${max_val}
	Verify IKE SPI After Rekeying
	Verify ESP SPI After Rekeying

Update SA Max Lifetime
	Perform Recommissioning		type=param_path		param_path=IPSECP-1:saMaxLifeTime		operation=update	value=300	timeout=90
	Perform Recommissioning		type=param_path		param_path=IPSECP-2:saMaxLifeTime		operation=update	value=300	timeout=90

Verify ESP SPI Before and After Rekeying
    FOR    ${i}    IN RANGE    1    3
		Get ESP SPI value before Rekeying
		Sleep    ${max_val_esp}
		Verify ESP SPI After Rekeying
    END