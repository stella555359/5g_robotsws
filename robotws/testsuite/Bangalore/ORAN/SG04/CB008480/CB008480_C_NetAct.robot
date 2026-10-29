*** Settings ***
Documentation   Transiver PM counter check during Statup of RU from .
Library    OperatingSystem     WITH NAME    os
Library    Collections
Library    taf.pdu    WITH NAME    pdu
Library    taf.nms.netact
Library    String
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
#Library    ./testsuite/Bangalore/ORAN/SG04/resources/commissioning.py
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sa_cell_id.py
Library    taf.transport.ssh
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library    SSHLibrary    WITH NAME    sshlib
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.selenium.sbts    WITH NAME    soam
#Library    taf.analyzer.yang  WITH NAME	yang
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    DateTime
Library    taf.rfrl.utilities.tl_config
Library    taf.rfrl.bts.commissioning
Library    taf.config.scf.interface.scf     WITH NAME    scf
Resource   taf/rfrl/bts/robot/gnb.robot
Library    taf.sw.scout    WITH NAME    scout
Resource   taf/rfrl/common_resources/common_step/interface.robot
Variables   ./testsuite/Bangalore/ORAN/SG04/resources/TL02_parameters.py

Test Setup      Preconditions
Test Teardown   Test teardown

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags       CRT  SBTS23R2    SBTS23R3  FL00    QCD_MN_RAN   QCP_RAN_ST


*** Variables ***
&{[1][2.0] TEST CASE_2 - CB008480_C-Transceiver performance measurement counter activation during the start-up of O-RU}
...    QC_ID_FL00=QC_297172    QC_ID_SBTS23R3=QC_557755    QC_ID_SBTS23R2=QC_504779

*** Test Cases ***
[1][2.0] TEST CASE_2 - CB008480_C-Transceiver performance measurement counter activation during the start-up of O-RU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag 
    Link SCOUT SCF to Configuration ID for Reporting
    Step1:Prepare configuration plan file
    Step2:Import Plan to Netact
    Step3:NetAct parameter modification for 5mins
    Step4:NetAct parameter modification for 15mins
    
*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin	bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    Verify gNB is onAir
    Log to console   --Setup finished--

Step1:Prepare configuration plan file
    Log to console    \n--Step:1 Started--\n
    Log to console    \n--SCF Download started--\n
    taf.sbts.oam.coam.admin.Connect To    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name='default'
    sleep   30s
    coam.get_current_scf_file    local_dir_path=${scf_pat}     file_name=nom_mrbts930_scf.xml
	...    timeout=30    connection=default    #parameters_save_varient=actualValues
    sleep   10s

    scf.load_scf	${scf_path}
    ${plan_version}	scf.get_mo_attribute    dist_name=MRBTS-964/NRBTS-964    attribute=version  
  
    scf.load_scf    ${plan_path}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-964/NRBTS-964/NRPMRNL-1    attribute=version    value=${plan_version}
    scf.save_scf    ${plan_path}    xml_declaration=True    encoding=UTF-8    standalone=True
    
    scf.load_scf    ${plan_pathx}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-964/NRBTS-964/NRPMRNL-1    attribute=version    value=${plan_version}
    scf.save_scf    ${plan_pathx}    xml_declaration=True    encoding=UTF-8    standalone=True
    	
    scf.load_scf	${scf_path}
    ${plan_version1}	scf.get_mo_attribute    dist_name=MRBTS-964    attribute=version
    
    scf.load_scf    ${plan_path}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-964    attribute=version    value=${plan_version1}
    scf.save_scf    ${plan_path}    xml_declaration=True    encoding=UTF-8    standalone=True	

    scf.load_scf    ${plan_pathx}
    scf.set_mo_attribute	dist_name=PLMN-PLMN/MRBTS-964    attribute=version    value=${plan_version1}
    scf.save_scf    ${plan_pathx}    xml_declaration=True    encoding=UTF-8    standalone=True
    Log to console    \n--Step:1 PASSED--\n

Step2:Import Plan to Netact
    Log to console   \n--Step2: Delete existing plan from Netact--\n    
    Run Keyword And Ignore Error    delete_plan    plan_name=NETACT-964-5-0    alias=${NETACT_NAME}
    sleep    10s

    Run Keyword And Ignore Error    delete_plan    plan_name=NETACT-964-6-0    alias=${NETACT_NAME}
    sleep    10s

    Log to console   \n--Plan file deletion done--\n  
    Log to console   \n--Import latest Plan to Netact--\n

    import_configuration    NETACT-964-5-0.xml    local_dir=${plan_path1}
    ...    plan_name=NETACT-964-5-0   ui_values=${TRUE}    alias=${NETACT_NAME}
    sleep    10s

    import_configuration    NETACT-964-6-0.xml    local_dir=${plan_path1}
    ...    plan_name=NETACT-964-6-0   ui_values=${TRUE}    alias=${NETACT_NAME}
    sleep    10s

    Log to console   \n--Plan Import to Netact done--\n
    Log to console   \n--Step:2 PASSED--\n

Step3:NetAct parameter modification for 5mins
    Log to console   \n--Step3: Counter Verification from BTS and NetAct for 5mins Started--\n
    Provision Plan    NETACT-964-5-0    ${DIST_NAMES}    backup_plan_name=NETACT-964-1-0-backup
    ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${NETACT_NAME}
    taf.nms.netact.Validate Plan    NETACT-964-5-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Activate Preactivated Plan    NETACT-964-5-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    SLEEP    320s
    taf.sbts.oam.coam.admin.Connect To    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name=default
    @{counter_list}=    create list    'M55606C00001'    'M55606C00002'    'M55606C00003'    'M55606C00004'    'M55606C00005'    'M55606C00006'
    ...    'M55606C00007'    'M55606C00008'    'M55606C00009'    'M55606C00010'
    ${result} =    taf.sbts.oam.coam.admin.get_pm_counters    counter_ids=${counter_nos}
    ...    timeout=600    connection=default
    #${values1}=   set variable  ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS']['M55606C00001'][0]}
    #log   ${values1}
      FOR    ${I}    IN    @{counter_list}
            ${values}=    Get Dictionary Values   ${result['BTS']['SMOD']['SFP-1']['RMOD-1']['OTRXS'][${I}]}
	    ${values3}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS'][${I}]}
            log to console    ${values}
            Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
      END
    

    
    ${results}=    taf.nms.netact.Get PM Counters    technology=${TECHNOLOGY}    measurement=${MEASUREMENT}
    ...                              counters=ALL    filter_by=${FILTER_BY}    mo_names=${MO_NAME}
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=today
    ...                              alias=${NETACT_NAME}

    #Log to console    \n ${results} \n
    ${x1}=    	Get Slice From List    ${results}    -2    0
    Log to console    \n X1 slice: ${x1} \n
    ${x}=    Get From List    ${results}    -1  
    Log to console    \n ${x} \n  
    ${LX}=    Get Dictionary Values    ${x}       
    #Log to console    \n ${LX} \n
    ${L1}=    Get From List    ${LX}    0
    ${L2}=    Get From List    ${LX}    1
    ${L3}=    Get From List    ${LX}    2
    ${L4}=    Get From List    ${LX}    3
    ${L5}=    Get From List    ${LX}    4
    ${L6}=    Get From List    ${LX}    5
    ${L7}=    Get From List    ${LX}    6
    ${L8}=    Get From List    ${LX}    7
    ${L9}=    Get From List    ${LX}    8
    ${L10}=    Get From List    ${LX}    9

    Should Be True    ${L1} == 49.3             
    Should Be True    ${L2} == 42.0    
    Should Be True    ${L3} == 1240.0   
    Should Be True    ${L4} == 1234.0  
    Should Be True    ${L5} == 12200.0   
    Should Be True    ${L6} == 11800.0   
    Should Be True    ${L7} == 12.2 
    Should Be True    ${L8} == 11.8  
    Should Be True    ${L9} == 1010.0    
    Should Be True    ${L10} == 987.0     
  
    Log to console   --\n Step3: PASSED \n--    

Step4:NetAct parameter modification for 15mins
    Log to console   \n--Step4: Counter Verification from BTS and NetAct for 15mins Started--\n
    Provision Plan    NETACT-964-6-0    ${DIST_NAMES}    backup_plan_name=NETACT-964-1-0-backup
    ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${NETACT_NAME}
    taf.nms.netact.Validate Plan    NETACT-964-6-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    Activate Preactivated Plan    NETACT-964-6-0    ${DIST_NAMES}    alias=${NETACT_NAME}
    SLEEP    920s
    taf.sbts.oam.coam.admin.Connect To    bts_host=192.168.255.129    bts_port=443    username='Nemuadmin'
	...    password='nemuuser'    use_ssl=True    name=default
    @{counter_list}=    create list    'M55606C00001'    'M55606C00002'    'M55606C00003'    'M55606C00004'    'M55606C00005'    'M55606C00006'
    ...    'M55606C00007'    'M55606C00008'    'M55606C00009'    'M55606C00010'
    ${result} =    taf.sbts.oam.coam.admin.get_pm_counters    counter_ids=${counter_nos}
    ...    timeout=600    connection=default
    #${values1}=   set variable  ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS']['M55606C00001'][0]}
    #log   ${values1}
      FOR    ${I}    IN    @{counter_list}
            ${values}=    Get Dictionary Values   ${result['BTS']['SMOD']['SFP-1']['RMOD-1']['OTRXS'][${I}]}
	    ${values3}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS'][${I}]}
            log to console    ${values}
            Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
      END

    
    ${results}=    taf.nms.netact.Get PM Counters    technology=${TECHNOLOGY}    measurement=${MEASUREMENT}
    ...                              counters=ALL    filter_by=${FILTER_BY}    mo_names=${MO_NAME}
    ...                              object_aggregation=${OBJECT_AGGREGATION}    time_aggregation=${TIME_AGGREGATION}
    ...                              time_filter=today
    ...                              alias=${NETACT_NAME}

    #Log to console    \n ${results} \n
    ${x}=    Get From List    ${results}    -1  
    Log to console    \n ${x} \n  
    ${LX}=    Get Dictionary Values    ${x}       
    #Log to console    \n ${LX} \n
    ${L1}=    Get From List    ${LX}    0
    ${L2}=    Get From List    ${LX}    1
    ${L3}=    Get From List    ${LX}    2
    ${L4}=    Get From List    ${LX}    3
    ${L5}=    Get From List    ${LX}    4
    ${L6}=    Get From List    ${LX}    5
    ${L7}=    Get From List    ${LX}    6
    ${L8}=    Get From List    ${LX}    7
    ${L9}=    Get From List    ${LX}    8
    ${L10}=    Get From List    ${LX}    9

    Should Be True    ${L1} == 49.3             
    Should Be True    ${L2} == 42.0    
    Should Be True    ${L3} == 1240.0   
    Should Be True    ${L4} == 1234.0  
    Should Be True    ${L5} == 12200.0   
    Should Be True    ${L6} == 11800.0   
    Should Be True    ${L7} == 12.2 
    Should Be True    ${L8} == 11.8  
    Should Be True    ${L9} == 1010.0    
    Should Be True    ${L10} == 987.0

    Disabling miNrOranTrxStats parameter     
    taf.sbts.oam.coam.admin.teardown
    RP Settings  
  
    Log to console   --\n Step3: PASSED \n--

Suite Precondition
    Add Node    cmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}

Test teardown
    Log to console   --\n Test teardown Started\n-- 
    Verify gNB is onAir
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
	Run Keyword If		"${sw_release}" == "None"
	...   Log   -- RP Settings step is for reporting portal purpose only, if this step alone fails, you can update QC manually-- 	html=true
	...   console=true
    Log to console   --\n Test teardown COMPLETED \n--

Disabling miNrOranTrxStats parameter 
   taf.sbts.oam.coam.admin.Perform Parameter Recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRPMRNL-1
   ...                                        parameter=miNrOranTrxStats
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

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=	Wait Until Keyword Succeeds	2min	10s	Request Scout SCF	${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
