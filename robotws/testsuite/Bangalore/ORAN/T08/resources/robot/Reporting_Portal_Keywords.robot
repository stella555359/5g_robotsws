*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: This resource file contains keywords for reporting.
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.sw.scout    WITH NAME    scout
Library    ute_reporting_portal

*** Keywords ***

Suite Setup Reporting
	Log To Console    \n-- adding rep_values dictionary --\ne
    ${rep_values}    Create Dictionary
    set suite variable     ${rep_values}

Suite Teardown Reporting
    [Documentation]
    ...   This keyword will handle Scout and reporting portal marking at teardown.
	Log To Console    \n-- Suite teardown started--\n
    coam.setup admin    alias=rp
    ${sw_release}=    coam.get_sw_release_name    connection=rp
    ${build}=    coam.get_sw_version    connection=rp
    coam.teardown    rp
    Log To Console    BTS IS Disconnected

    Link SCOUT SCF to Configuration ID for Reporting
    FOR    ${I}   IN    @{rep_values.keys()}
	    ute_reporting_portal.Report To Rp    name=${I}
		...			result=${rep_values['${I}']}ED
		...			ca=VRF_BLR1
		...			testline=${scout_testline_name}
		...			build=${build}
		...			qc_domain=MN_RAN
		...			tc_execution_id=${TC_ID}
		...			qc_project=RAN_VRF
		...			qc_id=${${I}}[QC_ID_${sw_release}]

		log     name=${I}
		log		result=${rep_values['${I}']}ED
		log 	testline=${scout_testline_name}
		log		build=${build}
		log		qc_domain=MN_RAN
		log		tc_execution_id=${TC_ID}
		log		qc_project=RAN_VRF
		log		qc_id=${${I}}[QC_ID_${sw_release}]
    END

Test Teardown Reporting
    Log to console   \n--End Test--\n
	log to console    printing TEST NAME
	log to console    ${TEST NAME}
    set to dictionary    ${rep_values}      ${TEST NAME}    ${TEST STATUS}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
#    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
# 	use_scout_internal_id= True when running Testcase by reserving TL
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    Log To Console     ${node_id}
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
	Set Suite Variable    ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Suite Variable    ${TC_ID}

Get Hostname
    [Documentation]
    ...    Get HOSTNAME of Testline.
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}

