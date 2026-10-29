*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com
...                 Maintainer: Sudha Adi

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    Collections
Library    OperatingSystem    WITH NAME     os
Library    String
Library    taf.transport.ssh    WITH NAME    ssh
Library    SSHLibrary
Library    Process
Library    BuiltIn
Library    DateTime
Library     ./testsuite/Bangalore/ORAN/T02/resources/python/snapshotFileIdentifier.py
Resource    ./testsuite/Bangalore/ORAN/T02/resources/robot/OperationKeywords.robot
Library     taf.file.pack

*** Variables ***
${RP_CA}=                       	VRF_ORAN
${RP_LOCATION}=                 	VRF_BLR1
${RP_ORGANIZATION}=             	VRF_BLR1_T02
${QC_DOMAIN}=                   	MN_RAN
${QC_PROJECT}=                  	RAN_VRF
@{CUSTOMERS}                   	 	DTAG
${INITIAL_SW}                  		SBTS26R1_ENB_0000_000613_000000
${TARGET_SW}                   		SBTS00_ENB_9990_260123_000002
@{CUSTOM_ALLOWED}              		4655  61524  4654  61652  6261  61649  2412  7517  6135  4367  4352
${ITERATIONS}                  		1
${SHOULD_BE_REPORTED}          		${True}
${REPORT_COMMENT}              		${None}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    	${True}
${RESTORE_TARGET_SW}=                   ${True}
${USE_DCAP}                           	${False}
${STOP_TEST_AFTER_FAIL}               	${False}
&{vm_dict}                  host=10.43.54.41
...                         user=ute
...                         password=BT5l@bus3rl0g1n
&{NODE3}                    node_vm=${vm_dict}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE3}
@{UPGRADE_NODES}            ${NODE3}
${EMAIl_RECIPIENTS}=         sudha.adi@nokia.com
${ONLINE_PARAMETER_DELTA}=      ${None}
${SITE_RESET_DELTA}=            ${None}
${NR_RAT_RESET_DELTA}=          /home/ute/robotws/testsuite/Bangalore/ORAN/T02/DTAG/JSON/NR_Rat_reset.json
${LTE_RAT_RESET_DELTA}=         /home/ute/robotws/testsuite/Bangalore/ORAN/T02/DTAG/JSON/LTE_Rat_reset.json
${WCDMA_RAT_RESET_DELTA}=       ${None}
${GSM_RAT_RESET_DELTA}=         /home/ute/robotws/testsuite/Bangalore/ORAN/T02/DTAG/JSON/GSM_Rat_reset.json
${QC_ID_SW_UUF_TRUNK}=                50314
${QC_ID_SW_UUF_BRANCH}=               247062
${QC_ID_SITE_RESET_TRUNK}=            192960
${QC_ID_SITE_RESET_BRANCH}=           247071
${QC_ID_RU_RESET_TRUNK}=              31061
${QC_ID_RU_RESET_BRANCH}=             247077
${QC_ID_BBMOD_RESET_TRUNK}=           31062
${QC_ID_BBMOD_RESET_BRANCH}=          247076
${QC_ID_LOCK_UNLOCK_NR_TRUNK}=        31060
${QC_ID_BLCK_UNBLCK_GSM_TRUNK}=       31068
${QC_ID_BLCK_UNBLCK_GSM_BRANCH}=      247072
${QC_ID_BLCK_UNBLCK_LTE_TRUNK}=       31063
${QC_ID_BLCK_UNBLCK_NR_TRUNK}=        31070
${QC_ID_BLCK_UNBLCK_NR_BRANCH}=       247067
${QC_ID_LOCK_UNLOCK_LTE_TRUNK}=       31067
${QC_ID_LOCK_UNLOCK_LTE_BRANCH}=      247068
${QC_ID_DEL_ONLNE_PAR_MOD_TRUNK}=     31064
${QC_ID_DEL_ONLNE_PAR_MOD_BRANCH}=    247073
${QC_ID_DEL_SITE_RST_REQ_TRUNK}=      31059
${QC_ID_DEL_SITE_RST_REQ_BRANCH}=     247078
${QC_ID_DEL_NR_RAT_RST_TRUNK}=        31066
${QC_ID_DEL_LTE_RAT_RST_TRUNK}=       31065
${QC_ID_DEL_GSM_RAT_RST_TRUNK}=       31069
${QC_ID_RU_LOCK_UNLOCK_TRUNK}=        31056
${QC_ID_RU_LOCK_UNLOCK_BRANCH}=       247079
${MCG_host}=    			10.43.54.48
${UE_PC_IP}                 10.43.54.48                                              # Windows UE PC IP
${BTS_M_plane_ip}           10.43.24.5                                               # BTS M PLane IP
${Windows_user}             inbabtslabuser                                            # Windows UE PC username
${Windows_pass}             BT5l@bus3rl0g1n
${file_path}=    pcilock.log
${BTS_ADDRESS}     192.168.255.129
${Build_path}=    /home/ute/UUF_SW/FJT/
@{Build_name}=    FJ-RU-ET1---------0580.FGF    FJ-RU-ET1---------0686.FGF    FJ-RU-ET1---------0600.FGF
@{Required_bts_status} =     OnAir
${connection}=    BTS_Session
${resettype}=    HARD
${BTS_path}=    /home/ute/logs
@{fault_list}=      4655    4654    61649    61524    61652    6261

*** Keywords ***

CallSimnovus
    	Log to console      \nAll SIMNOVUS calls started
    	SSHLibrary.Open Connection    host=${MCG_host}
    	SSHLibrary.Login    username=${Windows_user}    password=${Windows_pass}    delay=100
    	${output1}=    SSHLibrary.Execute Command    dir
    	${stdout}    ${stderr}=    Execute Command    echo pwd    return_stderr=True
    	log    ${stdout}
    	log    ${stderr}
    	${stdout}    ${stderr}=    SSHLibrary.Execute Command    python C:\\Simnovus/pciLockCommand.py
    	...                                                      return_stderr=True
    	log    ${stdout}
    	log    ${stderr}
    	SSHLibrary.get file    C:\\Simnovus/pcilock.log
    	SSHLibrary.Close All Connections
    	Extract_Log_Data

Extract_Log_Data
    	${file_contents}=    os.Get File    ${file_path}
    	${table_data}    Create List      \n    Type    PCI    EARFCN    Attach
    	${pattern}    Set Variable    (\\w+) : Attach is\.* succesful to PCI (\\d+) and earfcn (\\d+)
    	${matches}    Get Regexp Matches    ${file_contents}    ${pattern}
    	${matches}=    remove duplicates    ${matches}
    	Log    ${matches}
    	${matches}=    Convert To String    ${matches}
    	@{match}=    Split String    ${matches},
    	FOR   ${i}    IN    @{match}
        	Log    ${i}
        	${status}    Run Keyword And Ignore Error    Should Contain    ${i}    Attach is succesful
        	log    ${status}[0]
        	${info}    Get Regexp Matches    ${i}    ${pattern}    1
        	${pci}    Get Regexp Matches    ${i}    ${pattern}    2
        	${earfcn}    Get Regexp Matches    ${i}    ${pattern}    3
        	log   ${info}
        	Run Keyword And Ignore Error   Append To List   ${table_data}    \n
        	Run Keyword And Ignore Error   Append To List   ${table_data}    ${info}[0]    ${pci}[0]     ${earfcn}[0]
       	    ...                                              ${status}[0]
    	END
    	${convertListToString}=    Evaluate    "\t".join(${table_data})
    	${test6}=                 Catenate             SEPARATOR=   ${convertListToString}
    	Log    ${test6}

Collect Snapshotlog
	[Arguments]    ${itr}
	admin.collect_snapshot    target_file_name=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${itr}/Snapshotfile.zip

Extract netconf from snapshot
	[Arguments]    ${itr}
        @{getWithoutFilterValue}=     snapshotGetWithoutFilter    Snapshotfile.zip    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${itr}/
        ...    NetconfRpcMessageTrace
        log     ${getWithoutFilterValue}
        log     ${getWithoutFilterValue}[0]
        log     ${getWithoutFilterValue}[1]
        log     ${getWithoutFilterValue}[2]
        ${netconf_file_path} =    Set Variable    ${getWithoutFilterValue}[2]
        FOR    ${FILE_PATH}    IN    @{getWithoutFilterValue}[2]
            Log To Console    Fetching file: ${FILE_PATH}
            taf.file.pack.Extract
   	    ...    path=${FILE_PATH}
   	    ...    output_dir=${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${itr}/
   	    ...    .=*.log
        END
        BuiltIn.Log    ${netconf_file_path}
        ${netconf_filename}=    os.List Files In Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${itr}/    *RPC*.log
        FOR    ${file_name}    IN    @{netconf_filename}
            ${build_softwareslot_info}=    software_slot_info    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/${itr}/${file_name}    ${Build_name}
            log    ${build_softwareslot_info}
        END
        [RETURN]    ${build_softwareslot_info}

Validate Active SW version
          [Arguments]    ${build_softwareslot_info}    ${build_upgraded}
          Log    ${build_softwareslot_info}[2]
          Log    ${build_softwareslot_info}[1]
          FOR    ${i}    IN RANGE    1    3
	  	IF   '${build_softwareslot_info}[${i}][1]' == 'true'
	  		Should Be Equal    ${build_upgraded}    ${build_softwareslot_info}[${i}][3]
	  		log    ${build_softwareslot_info}[${i}][1]
	  		log    ${build_softwareslot_info}[${i}][3]
	  		Log to Console  Upgrade Successful
	  	END
	  END

Update_Software
	[Arguments]    ${Build_path}    ${build}
	admin.update_software    sw_package=${Build_path}${build}   should_activate=True    timeout=3500
	Wait Until Keyword Succeeds    10min    30s    Check_BTS_State
	Reset ORU

Reset ORU
    ${oru_id}    admin.get_ids_for all   RMOD
    FOR    ${id}    IN    @{oru_id}
	${ORU_info}=      admin.get_parameters_for      class_name=RMOD      id_num=${id}
	Set Suite Variable    ${ORU}    ${ORU_info}
	Log    ${ORU.productCode}
    Run Keyword If  '${ORU.productCode}'=='TA08029-B312/01'
	...    admin.reset_unit      dist_name=${ORU.id}
    ...                   reset_type=${resettype}
    ...                   timeout=300
	...    ELSE       Log to console    \n--${ORU.productName} is not reseted--\n
	END

Test Setup ORU SW
	Log to console    \n--Test Setup--\n
	${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
        ${CurrentDate}=    Convert to String     ${CurrentDate}
        Set global variable    ${Date}    ${CurrentDate}
        os.Create Directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
        os.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
        admin.setup_admin    bts_host=${BTS_ADDRESS}
        OperationKeywords.Start BTS logs

*** Test Cases ***

To check call verification for DTAG
    [Tags]    Remaining
    CallSimnovus

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}    kpi2c=600    kpi2d=600
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_SW_UUF}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_SW_UUF_TRUNK}
    ${QC_ID_SW_UUF}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_SW_UUF_BRANCH}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_SW_UUF}
    ...          qc_project=${QC_PROJECT}

To check call verification for DTAG1
    [Tags]    Remaining
    CallSimnovus

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}    kpi1a=500    kpi1b=500    kpi1c=500
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_SITE_RESET}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_SITE_RESET_TRUNK}
    ${QC_ID_SITE_RESET}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_SITE_RESET_BRANCH}
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_SITE_RESET}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS_RU_RESET}     kpi51a=235     kpi51b=235	kpi51c=135
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_RU_RESET}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_RU_RESET_TRUNK}
    ${QC_ID_RU_RESET}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_RU_RESET_BRANCH}
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RU_RESET}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS_BB_RESET}     kpi5=350
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_BBMOD_RESET}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_BBMOD_RESET_TRUNK}
    ${QC_ID_BBMOD_RESET}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_BBMOD_RESET_BRANCH}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BBMOD_RESET}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]	Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=55     kpi16b=55
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_LOCK_UNLOCK_NR_TRUNK}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_BLOCK_UNBLOCK_GSM}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_BLCK_UNBLCK_GSM_TRUNK}
    ${QC_ID_BLOCK_UNBLOCK_GSM}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_BLCK_UNBLCK_GSM_BRANCH}
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLOCK_UNBLOCK_GSM}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]	Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=10
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLCK_UNBLCK_LTE_TRUNK}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_BLCK_UNBLCK_NR}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_BLCK_UNBLCK_NR_TRUNK}
    ${QC_ID_BLCK_UNBLCK_NR}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_BLCK_UNBLCK_NR_BRANCH}
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=12
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLCK_UNBLCK_NR}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_LOCK_UNLOCK_LTE}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_LOCK_UNLOCK_LTE_TRUNK}
    ${QC_ID_LOCK_UNLOCK_LTE}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_LOCK_UNLOCK_LTE_BRANCH}
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_LOCK_UNLOCK_LTE}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]	Remaining
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_DEL_ONLNE_PAR_MOD}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_DEL_ONLNE_PAR_MOD_TRUNK}
    ${QC_ID_DEL_ONLNE_PAR_MOD}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_DEL_ONLNE_PAR_MOD_BRANCH}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}    ${NODE3}
    ...          iterations_per_node=10
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_ONLNE_PAR_MOD}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]	Remaining
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_DEL_SITE_RST_REQ}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_DEL_SITE_RST_REQ_TRUNK}
    ${QC_ID_DEL_SITE_RST_REQ}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_DEL_SITE_RST_REQ_BRANCH}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          delta=${SITE_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_SITE_RST_REQ}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_NR_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          delta=${LTE_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_LTE_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE3}
    ...          iterations_per_node=10
    ...          delta=${GSM_RAT_RESET_DELTA}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_GSM_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    [Tags]   Remaining
    coam.Setup Admin     username=Nemuadmin     password=nemuuser
    ${sw_release}=    coam.Get Sw Release Name
    ${QC_ID_RU_LOCK_UNLOCK}    Set Variable If    '${sw_release}' == 'SBTS00'    ${QC_ID_RU_LOCK_UNLOCK_TRUNK}
    ${QC_ID_RU_LOCK_UNLOCK}    Set Variable If    '${sw_release}' == 'SBTS26R1'    ${QC_ID_RU_LOCK_UNLOCK_BRANCH}
    E2E TL RU LOCK UNLOCK    ${NODES}  ${NODE3}
    ...          iterations_per_node=14
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RU_LOCK_UNLOCK}
    ...          qc_project=${QC_PROJECT}

CB008957-B_Download and installation of software on O-RU
    [Timeout]   24h
    [Tags]    Remaining
    [Setup]    Test Setup ORU SW
    FOR    ${i}    IN RANGE    15
       Collect Snapshotlog    PRE_${i}
       ${build_softwareslot_info}=     Extract Netconf from Snapshot    PRE_${i}
       ${Build_to_upgrade}    Set Variable    ${build_softwareslot_info}[0]
       Update_Software    ${Build_path}    ${Build_to_upgrade}.zip
       Run Keyword and Continue on Failure    OperationKeywords.Check ActiveFaultandAlarmID    @{fault_list}
       ${build_upgraded}      Set Variable    ${Build_to_upgrade}
       Collect Snapshotlog    POST_${i}
       ${build_softwareslot_info}=    Extract Netconf from Snapshot    POST_${i}
       Validate Active SW version    ${build_softwareslot_info}    ${build_upgraded}
    END
    [Teardown]    OperationKeywords.Test Teardown
