*** Settings ***
Documentation   SSD provisioning during BTS Plug & Play
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.fdsw.rc    WITH NAME    fdsw
Library    OperatingSystem    WITH NAME    os
Library    Collections
Library    String
Library    taf.nms.netact
Library    taf.config.scf     WITH NAME    scf
Library    DateTime
Library    SSHLibrary
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Library    ./testsuite/Bangalore/ORAN/SG04/resources/sg04_local_keywords.py
Library    taf.sw.scout    WITH NAME    scout
Variables   ./testsuite/Bangalore/ORAN/SG04/resources/TL02_parameters.py
Resource   taf/rfrl/common_resources/common_step/interface.robot


Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags       CRT	SBTS23R3    SBTS23R2    FL00    QCD_MN_RAN   QCP_RAN_ST

Test Setup      Preconditions
Test Teardown   Test teardown

*** Variables ***
&{[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NetAct during BTS Plug and Play.}
...    QC_ID_FL00=QC_318286    QC_ID_SBTS23R3=QC_557758    QC_ID_SBTS23R2=QC_504782
    	
*** Test Cases ***
[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NetAct during BTS Plug and Play.
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
    ...      Set QC_Tag
    Step1:Integrate MRBTS from NetAct
    Step2:Prepare configuration plan file
    Step3:Import configuration plan to NetAct
    Step4:Export configuration plan from NetAct   
    Step5: Import SSD plan to NetAct
    Step6:Software delete & Import to NetAct
    Step7:De-integrate MRBTS from NetAct
    Step8:Activate autoconfiguration from NetAct
    Step9:Start configuration reset
    Step10:Set Autoconfiguration
    Step11: Import SSD plan to NetAct
    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin	bts_host=192.168.255.129    port=${btsport}    username=${bts_uname}    password=${bts_pwd}
    ...    use_ssl=${True}    update_interval=5000    name=default
    ${sw_version}=    coam.get_sw_version               
    Log to console  \n ${sw_version} \n
    Log to console   *** Make sure SW build is available in UTE VM (/home/ute/Downloads/) ***
    sleep    30s
    Log to console   --Setup finished--
    sleep    5s


Step1:Integrate MRBTS from NetAct
    Log to console   --\n Step1: Integrate MRBTS With Netact \n--
    ${nms_state}=    coam.get_software_info    timeout=10    connection=default
    ${nms_state}=    coam.get_nms_state    timeout=10    connection=default    detailed_output=${FALSE}    
    Log to console   \n ${nms_state} \n
    Log to console   --\n Open SSH to BTS & remove ne3s file \n--
    Open Connection    192.168.255.129
    ${output}=    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${output}=    SSHLibrary.Execute Command    rm /rom/config/ne3sadapt/configs/ne3sadaptdata.db
    ${output}=    SSHLibrary.Execute Command    reboot
    Log to console   --\n BTS rebooted, Wait for 300s \n--
    sleep    300s

    ${sw_version}=    coam.get_sw_version
    ${mo_release}=    Fetch From Left    ${sw_version}    _ENB

    ${integration_output}=    Integrate MRBTS With Netact    release=${mo_release}
    ...    mr=MRC-Common/MR-Common
    ...    mrbts_address=${btshost}    dist_name=${DIST_NAME}
    ...    security_mode=no TLS    alias=${NETACT_NAME}
    Log    \n${integration_output}    console=${TRUE}
    Log to console   --\n Step1: Passed \n--

Step2:Prepare configuration plan file
    Log to console   --\n Step2: CM Operations Export Actual Configuration \n--
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    Run Keyword And Ignore Error    os.Run    rm /home/ute/Downloads/NetAct*
    export_configuration    NetAct-mrbts-${btsid}-step.xml    local_dir=${LOCAL_DIR}
    ...    dist_names=${DIST_NAME}    ui_values=${TRUE}    alias=${NETACT_NAME}

    Log  \Modify SCF paremeter    console=TRUE
    ##SCF modification start
    ${sw_version}=    coam.get_sw_version
    sleep   10s
    scf.load_scf    ${LOCAL_DIR}NetAct-mrbts-${btsid}-step.xml
    scf_create_from_old    scf_old=${LOCAL_DIR}NetAct-mrbts-${btsid}-step.xml    
    ...    scf_new=${LOCAL_DIR}NetAct-mrbts-${btsid}-step1.xml
    scf.load_scf    ${LOCAL_DIR}NetAct-mrbts-${btsid}-step1.xml
    scf.add_object_to_scf    dist_name=${DIST_NAME}/INTEGRATE-1    class_name=INTEGRATE
    ...    version=INT_01
    scf.save_scf    file_path=${LOCAL_DIR}NetAct-mrbts-${btsid}-step2.xml
    Log to console   --\n SCF OK \n--

    ${import_parameters}=    Create Dictionary
    Set To Dictionary    ${import_parameters}    -useObjectOperationDefinedInImportFile    ${TRUE}
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    Run Keyword And Ignore Error    delete_plan    plan_name=mrbts-${btsid}-step3.xml    alias=${NETACT_NAME}
    sleep    10s
    Log to console   \n--Plan file deletion done--\n 
    import_configuration    NetAct-mrbts-${btsid}-step2.xml    local_dir=${LOCAL_DIR}
    ...    operation_type=plan    file_format=RAML2    plan_name=mrbts-${btsid}-step3.xml
    ...    ui_values=${TRUE}    
    ...    parameters=${import_parameters}
    ...    alias=${NETACT_NAME}
    Log to console   --\n Import OK \n--

    #${export_parameters}=    Create Dictionary
    #Set To Dictionary    ${export_parameters}    -includeMaintenanceregionInfo    ${TRUE}
    #${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    Export Configuration     NetAct-mrbts-${btsid}-step4.xml    local_dir=${LOCAL_DIR}    dist_names=${DIST_NAME}
    ...    class_filter_include=None    operation_type=plan
    ...    plan_name=mrbts-${btsid}-step3.xml    ui_values=${TRUE}
    #...    parameters=${export_parameters}
    ...    alias=${NETACT_NAME}
    Log to console   --\n Export OK \n--
    ${system_rel}=    Fetch From Left    ${sw_version}    _ENB

    scf.load_scf    ${LOCAL_DIR}NetAct-mrbts-${btsid}-step4.xml
    scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=$maintenanceRegionId    
    ...    value=PNP
    scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=$maintenanceRegionCId
    ...    value=1
    scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=AutoConnHWID    
    ...    value=${AutoHWID}
    scf.add_element_to_scf   dist_name=${DIST_NAME}/MNL-1  p_name=plannedSWReleaseVersion
    ...    value=${sw_version}
    scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=hostNameEm
    ...    value=${btshost}
    scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=hostNameNe3sws
    ...    value=${btshost}
    scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=plannedSWReleaseVersion
    ...    value=${sw_version}
    scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=systemReleaseVersion
    ...    value=${system_rel}  
    scf.save_scf    file_path=${LOCAL_DIR}NetAct-mrbts-${btsid}-step5.xml
    ##SCF modification end
    sleep   60s
    Log to console   --\n Step2: Passed \n--

Step3:Import configuration plan to NetAct
    Log to console   --\n Step3: CM Operations Import Configuration \n--
    Run Keyword And Ignore Error    delete_plan    plan_name=mrbts-${btsid}-step6.xml    alias=${NETACT_NAME}
    sleep    10s
    Log to console   \n--Plan file deletion done--\n 
    ${import_parameters}=    Create Dictionary
    Set To Dictionary    ${import_parameters}    -useObjectOperationDefinedInImportFile    ${TRUE}
    import_configuration    NetAct-mrbts-${btsid}-step5.xml    local_dir=${LOCAL_DIR}
    ...    operation_type=plan    file_format=RAML2    plan_name=mrbts-${btsid}-step6.xml
    ...    ui_values=${TRUE}    
    ...    parameters=${import_parameters}
    ...    alias=${NETACT_NAME}
    #sleep   20s
    Log to console   --\n Step3: Passed \n--

Step4:Export configuration plan from NetAct
    Log to console   --\n Step4: CM Operations Export Plan Configuration \n--
    ${export_parameters}=    Create Dictionary
    Set To Dictionary    ${export_parameters}    -includeMaintenanceregionInfo    ${TRUE}
    Export Configuration     mrbts-${btsid}-step7-pnp.xml    local_dir=None    dist_names=${DIST_NAME}
    ...    remote_file_path=/var/opt/nokia/oss/global/racops/import/mrbts-${btsid}-step7-pnp.xml
    ...    class_filter_include=None    operation_type=plan
    ...    plan_name=mrbts-${btsid}-step6.xml    ui_values=${FALSE}
    ...    parameters=${export_parameters}
    ...    alias=${NETACT_NAME}
    Log to console   --\n Step4: Passed \n--

Step5: Import SSD plan to NetAct
    Log to console   --\n Step5: Open SSH & Import failure SSD plan to NetAct \n--
    Open Connection    ${NetAct_host}
    ${output}=    SSHLibrary.Login    ${NetAct_uname}    ${NetAct_pwd}
    SSHLibrary.Put File    ${path_ssd_m1_s2_failure}    /var/tmp    0744 
    ${output}=    SSHLibrary.Execute Command    curl -k -i ${imp_path2} ${imp_header} -u ${NetAct_uname}:${NetAct_pwd} ${imp_url}
    Close All Connections
    Log to console   --\n SSD plan imported & SSH connection closed \n--
    Log to console   --\n Step5: Passed \n--

Step6:Software delete & Import to NetAct
    Log to console   --\n Step6: List Of Imported Builds \n--
    ${sw_version}=    coam.get_sw_version
    ${imported_builds}=    Get List Of Imported Builds    alias=${NETACT_NAME}
    Log    \nImported builds: ${imported_builds}    console=${TRUE}
    Log to console   --\n Delete Old software build from NetAct \n--
    ${sw_info}=    coam.get_software_info    timeout=10    connection=default  
    ${passive_output}=    Get From Dictionary    ${sw_info}    ${passive_sw}             
    Log to console  \n ${passive_output} \n
    Run Keyword And Ignore Error    Delete Build    ${passive_sw}    mo_type=MRBTS    alias=${NETACT_NAME}  
    ${orgi_path}    Set Variable    /home/ute/Downloads/SBTS*
    ${new_path}    Set Variable    /home/ute/Downloads/${sw_version}.zip
    Run Keyword And Ignore Error    os.Move File    ${orgi_path}    ${new_path}
    Log to console   --\n Import software build: ${sw_version}, Wait for 20 mins \n--
    Import Build    /home/ute/Downloads/${sw_version}.zip    alias=${NETACT_NAME}
    ${import_status}=    Is Imported    ${sw_version}    alias=${NETACT_NAME}
    Log to console   --\n Step6: Passed \n--

Step7:De-integrate MRBTS from NetAct
    Log to console   --\n Step7: De-integrate MRBTS from NetAct \n--
    Log to console   --\n Delete object in Monitor \n--
    ${delete_monitor_output}=    delete_object_from_monitor    ${DIST_NAME}    alias=${NETACT_NAME}
    Log    \n${delete_monitor_output}    console=${TRUE}
    Log to console   --\n Delete configuration data of network element \n--
    ${delete_nedata_output}=    delete_ne_data_from_configurator    ${DIST_NAME}    alias=${NETACT_NAME}
    Log    \n${delete_nedata_output}    console=${TRUE}
    Log to console   --\n Step7: Passed \n--

Step8:Activate autoconfiguration from NetAct
    Log to console   --\n Step8: Started unified PNP operation \n--
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    prepare_unified_pnp_coam_site    mrbts-${btsid}-step7-pnp-${datetime}.xml
    ...    mrbts-${btsid}-step7-pnp.xml    alias=${NETACT_NAME}
    Log to console   --\n Step8: Passed \n--

Step9:Start configuration reset
    Log to console   --\n Step9: NetAct MRBTS-${btsid} CONFIGURATION RESET STARTED \n--
    os.Run    rm ${LOCAL_DIR}NCF.xml  
    os.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ffs/run/config/NCF.xml ${LOCAL_DIR}
    scf.load_scf    ${LOCAL_DIR}NCF.xml
    Run Keyword And Ignore Error    scf.remove_element_from_scf    dist_name=AUTOCON-1
    ...    p_name=identificationServerIpAddress    
    scf.add_element_to_scf   dist_name=AUTOCON-1   p_name=identificationServerIpAddress   
    ...    value=${pnp_netactip}
    scf.save_scf    file_path=${LOCAL_DIR}NCF.xml
    Log to console   --\n NMS IP updated in NCF file\n--
    os.Run    sshpass -p oZPS0POrRieRtu scp ${LOCAL_DIR}NCF.xml toor4nsn@192.168.255.129:/ffs/run/config/
    Log to console   --\n NCF file copied to BTS \n--
    sleep   10s
    coam.reset_configuration  remove_operator_certificates=${FALSE}  timeout=600    detailed_output=${True}
    Log to console   --\n Configuration reset started, Wait 300s \n--
    sleep   300s
    Log to console   --\n MRBTS-${btsid} CONFIGURATION RESET COMPLETED \n--
    Log to console   --\n Step9: Passed \n--

Step10:Set Autoconfiguration
    Log to console   --\n Step10: MRBTS-${btsid} sw rollback from rescue console \n--
	fdsw.connect_to    ip_address=192.168.255.129    port=${btsport}    username=${bts_uname}    password=${bts_pwd}
    ...    auto_discover=${TRUE}    name=default
    ${active_sw}=    fdsw.get_active_sw_partition    timeout=10    connection=default
	Log to console   --\n active_sw_partition=${active_sw} \n--
	${sw_slot}=    Convert To Integer    ${active_sw}
	fdsw.software_rollback    sw_slot_id=${sw_slot}    timeout=10    reset_type=FromActive  
	...    connection=default
	Log to console   --\n Rollback to active software from rescue console \n--
	Log to console   --\n Wait 360s \n-- 
	sleep   360s
    Log to console   --\n Step10: Passed \n---

Step11: Import SSD plan to NetAct
    Log to console   --\n Step11: Open SSH & Import working SSD plan to NetAct \n--
    Open Connection    ${NetAct_host}
    ${output}=    SSHLibrary.Login    ${NetAct_uname}    ${NetAct_pwd}
    SSHLibrary.Put File    ${path_ssd_m1_s2}    /var/tmp    0744 
    ${output}=    SSHLibrary.Execute Command    curl -k -i ${imp_path1} ${imp_header} -u ${NetAct_uname}:${NetAct_pwd} ${imp_url}
    Close All Connections
    Log to console   --\n SSD plan imported & SSH connection closed \n--
    Run Keyword And Ignore Error    coam.setup_admin    bts_host=192.168.255.129    port=${btsport}   
    ...     username=${bts_uname}    password=${bts_pwd}
    ...    use_ssl=${True}    update_interval=5000    name=default
    Log to console   --\n Resetting site, Wait for 900s \n--
    coam.reset_site    timeout=300    connection=default    wait_for_reconnection=${TRUE}    detailed_output=${FALSE}
    sleep   900s
    Verify gNB is onAir
    Log to console   --\n Validate MRBTS-${btsid} SSD failed PNP REPORT\n--
    coam.get_pnp_report    output_file_name=${pnp_report1}    timeout=20s    connection=default
    sleep   30s
    ${pnp1}=    os.Get File    ${pnp_report1}
    Should Contain    ${pnp1}    ${output_pnp1}
    Log to console   --\n ##PNP Report1 Verfied## \n--
    Log to console   --\n Validate MRBTS-${btsid} SSD succeded PNP REPORT\n--
    ${pnp2}=    os.Get File    ${pnp_report1}
    Should Contain    ${pnp2}    ${output_pnp2} 
    Log to console   --\n ##PNP Report2 Verfied## \n--
    RP Settings
    Log to console   --\n NetAct MRBTS-${btsid} PLUG & PLAY COMPLETED\n--
    Log to console   --\n Step11: Passed \n--

    
Test teardown
    Log to console   --\n Test teardown Started\n-- 
    Verify gNB is onAir
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--


Suite Precondition
    Add Node    cmwas    ${NetAct_host}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${NetAct_uname}    ${NetAct_pwd}    alias=${NETACT_NAME}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}  

Set Autoconnection Transport Params
    ${mplane}=    Convert To Integer	${pnp_subnet}
    ${vlanid}=    Convert To Integer	${pnp_vlanid}
    coam.set_autoconnection_transport_params    timeout=300    connection=default    mPlaneIpAddress=${pnp_mplaneip}
    ...    mPlaneIpPrefix=${mplane}    defaultGateway=${pnp_defgw}	vlanId=${vlanid}
    ...    identificationServerIpAddress=${pnp_netactip}

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
