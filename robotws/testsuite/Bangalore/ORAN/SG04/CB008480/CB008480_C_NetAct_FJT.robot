*** Settings ***
Documentation   Transceiver PM counter check during Statup of RU from .
Library    OperatingSystem     WITH NAME    os
Library    Collections
Library    taf.nms.netact
#Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
#Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot

Library    ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py

Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py

Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.sbts    WITH NAME    soam

Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    DateTime
Library     taf.sw.dcap.rd   WITH NAME   rd

Library    taf.config.scf.interface.scf     WITH NAME    scf
#Resource   taf/rfrl/bts/robot/gnb.robot
Library    taf.sw.scout    WITH NAME    scout
Resource   taf/rfrl/common_resources/common_step/interface.robot
Variables   ./testsuite/Bangalore/ORAN/SG04/resources/TL02_parameters.py

Test Setup      Preconditions
Test Teardown   Test teardown

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

#Force Tags       CRT    FL00    QCD_MN_RAN   QCP_RAN_VRF

*** Variables ***
&{[1][2.0] TEST CASE_2 - CB008480_C-Transceiver performance measurement counter activation during the start-up of O-RU}

...    QC_ID_FL00=QC_31624   QC_ID_SBTS24R3=QC_852851    QC_ID_SBTS25R1=QC_78982

*** Test Cases ***
[1][2.0] TEST CASE_2 - CB008480_C-Transceiver performance measurement counter activation during the start-up of O-RU
    [Tags]    TRUNK_SG04    24R3    25R1    QCD_MN_RAN    QCP_RAN_ST    8480C
    [Teardown]    run keywords
     ...      Test teardown        AND    Set QC_Tag
    Link SCOUT SCF to Configuration ID for Reporting
    Step1:Prepare configuration plan file
    Step2:Import Plan to Netact
    Step3:NetAct parameter modification for 5mins
    Step4:NetAct parameter modification for 15mins

*** Keywords ***

Preconditions
    Log to console   --Test setup--.
    coam.setup_admin	bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    #DCAP Start
    Log to console   --Setup finished--

Step1:Prepare configuration plan file
    Log to console    \n--Step:1 Started--\n
    Log to console    \n--SCF Download started--\n
    coam.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name='default'
    sleep   30s
    coam.get_current_scf_file    local_dir_path=${scf_pat}     file_name=c_mrbts970_scf.xml
	...    timeout=30    connection=default    #parameters_save_varient=actualValues
    sleep   10s

    scf.load_scf	${scf_path}
    ${plan_version}	scf.get_mo_attribute    dist_name=MRBTS-970/NRBTS-970    attribute=version

    scf.load_scf    ${plan_path}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-970/MNL-1/MNLENT-1/PMMNL-1    attribute=version    value=${plan_version}
    scf.save_scf    ${plan_path}    xml_declaration=True    encoding=UTF-8    standalone=True

    scf.load_scf    ${plan_pathx}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-970/MNL-1/MNLENT-1/PMMNL-1    attribute=version    value=${plan_version}
    scf.save_scf    ${plan_pathx}    xml_declaration=True    encoding=UTF-8    standalone=True

    scf.load_scf	${scf_path}
    ${plan_version1}	scf.get_mo_attribute    dist_name=MRBTS-970    attribute=version

#    scf.load_scf    ${plan_path}
#    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-970    attribute=version    value=${plan_version1}
#    scf.save_scf    ${plan_path}    xml_declaration=True    encoding=UTF-8    standalone=True

#    scf.load_scf    ${plan_pathx}
#    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-970    attribute=version    value=${plan_version1}
#    scf.save_scf    ${plan_pathx}    xml_declaration=True    encoding=UTF-8    standalone=True
    Log to console    \n--Step:1 PASSED--\n

Step2:Import Plan to Netact
    Log to console   \n--Step2: Delete existing plan from Netact--\n
    Run Keyword And Ignore Error    delete_plan    plan_name=NETACT-970-5-0    alias=${NETACT_NAME}
    sleep    10s

    Run Keyword And Ignore Error    delete_plan    plan_name=NETACT-970-6-0    alias=${NETACT_NAME}
    sleep    10s

    Log to console   \n--Plan file deletion done--\n
    Log to console   \n--Import latest Plan to Netact--\n

    import_configuration    NETACT-970-5-0.xml    local_dir=${plan_path1}
    ...    plan_name=NETACT-970-5-0   ui_values=${TRUE}    alias=${NETACT_NAME}
    sleep    10s

    import_configuration    NETACT-970-6-0.xml    local_dir=${plan_path1}
    ...    plan_name=NETACT-970-6-0   ui_values=${TRUE}    alias=${NETACT_NAME}
    sleep    10s

    Log to console   \n--Plan Import to Netact done--\n
    Log to console   \n--Step:2 PASSED--\n

Step3:NetAct parameter modification for 5mins
    Log to console   \n--Step3: Counter Verification from BTS and NetAct for 5mins Started--\n
    Provision Plan    NETACT-970-5-0    ${DIST_NAMES}    backup_plan_name=NETACT-970-1-0-backup
    ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${NETACT_NAME}
    taf.nms.netact.Validate Plan    NETACT-970-5-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Activate Preactivated Plan    NETACT-970-5-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Log to console   \n-- Wait 5Mins for the Counter to Report
    #SLEEP    400s
    coam.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name=default
    @{counter_list}=    create list    'M40027C1'    'M40027C2'    'M40027C3'    'M40027C4'    'M40027C5'    'M40027C6'
    ...    'M40027C7'    'M40027C8'    'M40027C9'    'M40027C10'    'M40027C11'    'M40027C12'    'M40027C13'    'M40027C14'
    ...    'M40027C15'    'M40027C16'    'M40027C17'    'M40027C18'    'M40027C19'    'M40027C20'
    ${result} =    coam.get_pm_counters    counter_ids=${counter_nos}    timeout=600    connection=default
    #${values1}=   set variable  ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS']['M55606C00001'][0]}
    #log   ${values1}
      FOR    ${I}    IN    @{counter_list}
            ${values}=    Get Dictionary Values   ${result['BTS']['MRBTS-970']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST'][${I}]}
	    ${values3}=   Get Dictionary Values   ${result['BTS']['MRBTS-970']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST'][${I}]}
            log to console    ${values}
            Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
      END

    ${results}=    taf.nms.netact.Get PM Counters    technology=${TECHNOLOGY}    measurement=${MEASUREMENT}
    ...                              counters=ALL    filter_by=${FILTER_BY}    mo_names=PLMN-PLMN/MRBTS-970
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=currentMonth
    ...                              alias=${NETACT_NAME}

    Log to console    \n ${results} \n
    ${x1}=    	Get Slice From List    ${results}    -2    0
    #Log to console    \n X1 slice: ${x1} \n
    ${x}=    Get From List    ${results}    -1
    #Log to console    \n ${x} \n
    ${LX}=    Get Dictionary Values    ${x}
    #Log to console    \n ${LX} \n
    ${L1}=    Get From List    ${LX}    2
    ${L2}=    Get From List    ${LX}    3
    ${L3}=    Get From List    ${LX}    6
    ${L4}=    Get From List    ${LX}    7
    ${L5}=    Get From List    ${LX}    10
    ${L6}=    Get From List    ${LX}    11
    ${L7}=    Get From List    ${LX}    12
    ${L8}=    Get From List    ${LX}    13
    ${L9}=    Get From List    ${LX}    18
    ${L10}=    Get From List    ${LX}    19

    Should Be True    40 <= ${L1} <= 59
    Should Be True    ${L2} == 0.0
    Should Be True    0.5 <= ${L3} <= 0.8

    Should Be True    ${L4} == 0.0
    Should Be True    3210 <= ${L5} <= 3319
    Should Be True    ${L6} == 0.0
    Should Be True    6 <= ${L7} <= 7

    Should Be True    6 <= ${L8} <= 7
    Should Be True    0.5 <= ${L9} <= 0.8

    Should Be True    ${L10} == 0.0

    Log to console   --\n Step3: PASSED \n--

Step4:NetAct parameter modification for 15mins
    Log to console   \n--Step4: Counter Verification from BTS and NetAct for 15mins Started--\n
    Provision Plan    NETACT-970-6-0    ${DIST_NAMES}    backup_plan_name=NETACT-970-1-0-backup
    ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${NETACT_NAME}
    taf.nms.netact.Validate Plan    NETACT-970-6-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Activate Preactivated Plan    NETACT-970-6-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Log to console   \n-- Wait 15Mins for the Counter to Report
    SLEEP    1000s
    coam.connect_to    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name=default
    @{counter_list}=    create list    'M40027C1'    'M40027C2'    'M40027C3'    'M40027C4'    'M40027C5'    'M40027C6'
    ...    'M40027C7'    'M40027C8'    'M40027C9'    'M40027C10'    'M40027C11'    'M40027C12'    'M40027C13'    'M40027C14'
    ...    'M40027C15'    'M40027C16'    'M40027C17'    'M40027C18'    'M40027C19'    'M40027C20'
    ${result} =    coam.get_pm_counters    counter_ids=${counter_nos}
    ...    timeout=600    connection=default
    #${values1}=   set variable  ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS']['M55606C00001'][0]}
    #log   ${values1}
      FOR    ${I}    IN    @{counter_list}
            ${values}=    Get Dictionary Values   ${result['BTS']['MRBTS-970']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST'][${I}]}
	    ${values3}=   Get Dictionary Values   ${result['BTS']['MRBTS-970']['EQM-1']['APEQM-1']['RMOD-1']['SFP-1']['OTRST'][${I}]}
            log to console    ${values}
            Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
      END


    ${results}=    taf.nms.netact.Get PM Counters    technology=${TECHNOLOGY}    measurement=${MEASUREMENT}
    ...                              counters=ALL    filter_by=${FILTER_BY}    mo_names=PLMN-PLMN/MRBTS-970
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=currentMonth
    ...                              alias=${NETACT_NAME}

    #Log to console    \n ${results} \n
    ${x1}=    	Get Slice From List    ${results}    -2    0
    #Log to console    \n X1 slice: ${x1} \n
    ${x}=    Get From List    ${results}    -1
    #Log to console    \n ${x} \n
    ${LX}=    Get Dictionary Values    ${x}
    #Log to console    \n ${LX} \n
    ${L1}=    Get From List    ${LX}    2
    ${L2}=    Get From List    ${LX}    3
    ${L3}=    Get From List    ${LX}    6
    ${L4}=    Get From List    ${LX}    7
    ${L5}=    Get From List    ${LX}    10
    ${L6}=    Get From List    ${LX}    11
    ${L7}=    Get From List    ${LX}    12
    ${L8}=    Get From List    ${LX}    13
    ${L9}=    Get From List    ${LX}    18
    ${L10}=    Get From List    ${LX}    19
    Should Be True    40 <= ${L1} <= 59
    Should Be True    ${L2} == 0.0
    Should Be True    0.5 <= ${L3} <= 0.8

    Should Be True    ${L4} == 0.0
    Should Be True    3210 <= ${L5} <= 3319
    Should Be True    ${L6} == 0.0
    Should Be True    6 <= ${L7} <= 7

    Should Be True    6 <= ${L8} <= 7
    Should Be True    0.5 <= ${L9} <= 0.8

    Should Be True    ${L10} == 0.0

    Disabling miOranTrxStats parameter

    Log to console   --\n Step4: PASSED \n--
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}

Suite Precondition
    Add Node    cmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Test teardown
    Log to console   --\n Test teardown Started\n--
    #Run Keyword If		"${dcap_log_status}" == "1.0"   DCAP Stop
    #...    ELSE    DCAP Stop with log Transfer
    RP Settings
    coam.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--


Disabling miOranTrxStats parameter
   coam.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/MNL-1/MNLENT-1/PMMNL-1
   ...                                        parameter=miOranTrxStats
   ...                                        operation=update
   ...                                        value=disabled

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=	scout.request_scf   use_scout_internal_id=True
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

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${scout_id}

	log    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=	Wait Until Keyword Succeeds	2min	10s	Request Scout SCF	${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
DCAP Start
    Log to console    \n-- Connecting to DCAP Server--\n
    rd.connect_to     host=${dcaphost}      port=${dcapport}     rd_version=${dcap_version}    username=${dcap_uname}
    ...     password=${dcap_pwd}    secure=True
    ${bts_info}=    create dictionary    host=${btshost}    port=${btsport}    username=${bts_uname}     password=${bts_pwd}
    #${gnb_custom_profile}=    Create List    Default tracing profile
    ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
    Log to console    \n-- Started GNB Custom Traces --\n
    ${trace_id}=    Get From Dictionary   ${output}   tracer_id
    Log to console    \n DCAP Trace ID: ${trace_id} \n
    Set suite variable    ${trace_id}

DCAP Stop
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n

DCAP Stop with log Transfer
    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=200
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/
