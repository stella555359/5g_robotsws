*** Settings ***

Documentation    BTS 1061 port number 1 should be 0db others should be 120db. 
...    Loging into BTS 1062 block the Cell NR Cell and check on-air status of LTE cell and 
...    Set liner attenuation of port 1 to 50db and LTE cell PVA port-5 into reduced from 120db to 10db. 
...    set those action in loop of 4 times.
...    functionality Contains
...    1. taf.attenuator which is belongs to PVA handling.
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.selenium.sbts    WITH NAME    selenium_sbts
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.nms.netact    WITH NAME    nms_netact
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library    taf.collectors.core           WITH NAME      core
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.hw.rf_attenuator.attenuator  WITH NAME  attenuator
Library    taf.transport.ssh    WITH NAME    SSH
Library    taf.sw.reporting_portal    WITH NAME    rp
Library    ../python/swconfig_analysis.py    WITH NAME    swconfig
Resource   UE_keywords.resource
Resource   variables/QC_Variables.robot
Resource   variables/Rjio_variables.robot
Variables  variables/CB012601_Variables.py


*** Keywords *** 
SCF Commission BTS Status Check
    [Documentation]    Get BTS Status, Get Active SW Build
    ...    As per SW Release, Selecting Lastest Customer SCF
    ...    Performing Scf Commission via admin Connection
    ...    Verfiy BTS Status upto 900 sec incase of Status is Not "OnAir"

    coam.connect_to
    Set Test Variable    ${COUNT}   ${1}
    BuiltIn.Log To Console    [ INFO ]: SCF Commission Planned to Perform
    WHILE    ${COUNT} <= 30
        ${status}    coam.get_bts_statuses
        IF    '${status}[proceduralState]' == 'OnAir'
            # Add Alarm Chech
            BuiltIn.Log To Console    [ INFO ]: Before SCF Commission BTS Status is '${status}[proceduralState]'
            BREAK
        ELSE
            Sleep    30s
            ${COUNT}    Evaluate    ${COUNT}+${1}
        END
    END
    ${bts_sw}    coam.get_software_info
    ${act_sw}    BuiltIn.Convert To String    ${bts_sw}[Active SW version]
    @{release}    Split String    string=${act_sw}    separator=_
    IF  ${release}[2] == 9999
        ${act_sw_version}    Replace String    string=${act_sw}    search_for=${release}[0]    replace_with=SBTS00
        BuiltIn.Set Test Variable    ${act_sw_version}
        BuiltIn.Set Test Variable    ${release_version}    SBTS00
    ELSE
        BuiltIn.Set Test Variable    ${act_sw_version}    ${act_sw}
        BuiltIn.Set Test Variable    ${release_version}    ${release}[0]
    END
    BuiltIn.Log To Console    [ INFO ]: SCF Commission Started with scf_file=${scf_file_path}/SCF_${release_version}.xml
    coam.perform_commissioning    bts_id=${MRBTS_ID}    scf_file=${scf_file_path}/SCF_${release_version}.xml
    WHILE    ${COUNT} <= 30
        ${status}    coam.get_bts_statuses
        IF    '${status}[proceduralState]' == 'OnAir'
            # Add Alarm Chech
            BuiltIn.Log To Console    [ INFO ]: After SCF Commission BTS Status is '${status}[proceduralState]'
            BREAK
        ELSE
            Sleep    30s
            ${COUNT}    Evaluate    ${COUNT}+${1}
        END
    END
    [Teardown]    Run Keyword    coam.teardown


Report To Reporting Portal
    [Documentation]    Report to reporting portal by using with taf.sw.reproting_portal 
    ...    Using for All Testcase veridict to update in RP.  
    [Arguments]    ${verdict}  ${QC_ID}  ${target_build}  ${RP_QC_PROJECT}
    FOR    ${tag}    IN    @{TEST_TAGS}
        IF  '${tag}' == 'Mantaray'
            BuiltIn.Set Test Variable    ${tool}    MantaRay NM
            BREAK
        ELSE
            BuiltIn.Set Test Variable    ${tool}    WebEM
        END
        BuiltIn.Log To Console    [ INFO ]: Pipe line fix.
    END
    ${Tool_name}    Convert To String    ${tool}
    # ${CUSTOMERS_LIST}   Convert To String    Reliance India
    # ${BTS_TYPE}    Convert To String    SA
    # ${testline_type}    Convert To String    ${RP_HW_ID}
    ${build}    Convert To String    ${target_build}
    ${link_to_reporting_portal}  rp.report to rp
    ...  name=${TEST_NAME}
    ...  result=${verdict}
    ...  ca=${RP_CA}
    ...  build=${build}
    ...  testline=${testline_name}
    ...  qc_domain=${RP_QC_DOMAIN}
    ...  qc_project=${RP_QC_PROJECT}
    ...  qc_id=${QC_ID}
    ...  tool=${Tool_name}
    # ...  label=${testline_type}
    ...  tc_execution_id=${TC_EXE_ID}
    ...  location=${RP_LOCATION}
    ...  customer=@{RP_Customer}
    ...  organization=${RP_organization}
    BuiltIn.Log To Console  Reporting Portal link: ${link_to_reporting_portal}
    BuiltIn.Log Many    ${link_to_reporting_portal}

Perform Parameter Recommissiong
    [Documentation]    Parameter recommission from taf.sbts.oam.coam.admin
    ...    : Operation can be used update or delete
    [Arguments]    ${Dist_name}    ${Parameter}
    ...    ${Operation}    ${Value}
    ...    ${connection}    ${activate}=${True}
    admin.perform_parameter_recommissioning    dist_name=${Dist_name}
    ...    parameter=${Parameter}
    ...    operation=${Operation}
    ...    value=${Value}
    ...    should_activate=${activate}
    ...    connection=${connection}

Verify_all_cells_should_be_onair
    [Documentation]    Author: Arunkumar A
    ...                Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM
    Log to console    Verify all cells are on air
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...        22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END

Configure_online_set_rad_parmeter
    [Documentation]  Keyword does the function of swconfig flag enabled via online rad_parameter
    [Arguments]    ${domain}    ${persistency}    ${rad_parameter_name}    ${set_value}    ${connection}=LTE_OAM

    coam.set_rad_debug_parameters    domain=${domain}    persistency=${persistency}  name=${rad_parameter_name}  
    ...    value=${set_value}  detailed_output=${True}    connection=${connection}
    
Configure_online_reset_rad_parmeter
    [Documentation]  Keyword does the function of swconfig flag enabled via online rad_parameter
    [Arguments]    ${domain}    ${persistency}    ${rad_parameter_name}    ${set_value}    ${connection}=LTE_OAM
    coam.reset_bts_rad_parameters    component=${domain}   params=${rad_parameter_name}     timeout=120s     connection=${connection}

verify_the_flag_enalbed_in_swconfig_file
    [Documentation]    Keyword does the verification of string(flags) finding in swconfig.txt 
    [Arguments]    
    ${flag_available}    swconfig.enable_ssh_connection     hostname=${Sys_module_login_ip}    
    ...    username=${Sys_module_login_username}    password=${Sys_module_login_password}
    ...    list_of_flag=@{bad_UL_BLER_flags}    swconfigfilepath=${swconfigfilepath}     
    RETURN    ${flag_available}
    
Load_defult_SWconfigfile
    [Documentation]   Need to be implement
    [Arguments]     
    ${Standard_swconfigfile_path}    Set Variable    ${backup_remote_path}
    SSH.Upload File    local_path=${Standard_swconfigfile_path}    remote_path=${sw_config_path}    connection=${sysmod_alias}
    RETURN    

ssh_connection_to_system_module
    [Arguments]    
    
    SSH.Connect To    hostname=${Sys_module_login_ip}    username=${Sys_module_login_username}
    ...    password=${Sys_module_login_password}     alias=${sysmod_alias}
    SSH.Send Command  command=cd /ffs/run    connection=${sysmod_alias}
    SSH.Send Command  command=ls -lrt | grep swconfig.txt    connection=${sysmod_alias}
    Set Suite Variable    ${remote_path}        ${swconfigfilepath}
    ${swconfigfile_available}    SSH.File Exists    remote_path=${remote_path}    connection=${sysmod_alias}
    Set Suite Variable    ${swconfigfile_available}
    RETURN    ${swconfigfile_available}

Modified_Swconfigfile_for_adding_flag
    [Documentation]
    [Arguments]

    SSH.Download File    remo=te_path=${backup_remote_path}    local_path=${remote_path}
    ...    connection=${sysmod_alias}
    # Check file contain 

Configure_QC_ID_for_Reportng_portal
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID}
    # RETURN    ${TEST_QC_ID}

Get Qc Id According To Sw Release
    [Documentation]    Used for qc report depends on SW release
    [Arguments]    ${active_sw}
    ${release}=    Fetch From Left    ${active_sw}    _
    ${branch_check}=    Split string    ${active_sw}     separator=_    max_split=3
    ${sw_release}
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    ${QC_Project}
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable   RAN_VRF
    ...     ELSE    Set Variable    RAN_VRF
    Set Suite Variable    ${sw_release}
    Set Suite Variable  ${QC_Project}
    ${TEST_QC_ID}    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID}
    RETURN    ${TEST_QC_ID}

Configure_QC_ID_for_Reportng_portal_MP_TestCase
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}_MP]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID}  

Configure_QC_ID_for_Reportng_portal_MP_TestCase_1063
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}_MP_1063]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID} 

Configure_QC_ID_for_Reportng_portal_BTS_1063
    [Documentation]    Author: arunkumar.a@nokia.com Qc test instance id will select depends on ${5G_TARGET_SW} 
    ${release}=    Fetch From Left    ${5G_TARGET_SW}    _
    ${branch_check}=    Split string    ${5G_TARGET_SW}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${branch_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${release}
    Set Suite Variable    ${sw_release}
    ${TEST_QC_ID}=    Set Variable    ${${TEST_NAME}}[QC_ID_${sw_release}_1063]
    Set Test Variable        ${TEST_QC_ID}
    Log To Console   QC_ID : ${TEST_QC_ID} 

robot_sw_release_from_sw_version

    [Arguments]    ${active_sw_version}    ${Passive_sw_version}   
    ${activeSoftwareSBTS}    Set Variable    ${active_sw_version}
    ${passiveSoftwareSBTS}    Set Variable    ${Passive_sw_version}
    ${ActiveSWstr}    BuiltIn.Convert To String    ${activeSoftwareSBTS}
	Set Suite Variable    ${OUT_ENB_ACTIVE_SW}    ${ActiveSWstr}
	${passive_release}=    Fetch From Left    ${passiveSoftwareSBTS}    _
	${passive_check}=    Split string    ${passive_release}     separator=_    max_split=3
	${passive_branch}=    BuiltIn.Convert To String    ${passive_check[0]}
	${ActiveSWstr}  BuiltIn.Convert To String    ${activeSoftwareSBTS}
	${active_release}=    Fetch From Left    ${ActiveSWstr}    _
	${active_check}=    Split string    ${ActiveSWstr}     separator=_    max_split=3
	${active_branch}=    BuiltIn.Convert To String    ${active_check[0]}
    BuiltIn.Log To Console    [ INFO ]: Active SW Release: ${active_branch}
    BuiltIn.Log To Console    [ INFO ]: Passive SW Release: ${passive_branch}
    @{sw_release_version}    Create List    ${active_branch}    ${passive_branch}    
    RETURN    @{sw_release_version}

Convert_sw_version_depends_on_release

    [Arguments]    ${sw_index}
    @{passive_check}=    Split string    ${sw_index}     separator=_    max_split=3
    ${sw_release}=
    ...     Run Keyword If    "${passive_check[2]}"=="9999"    Set Variable    SBTS00
    ...     ELSE    Set Variable    ${passive_check}[0]
    ${converted_SW_version}    Catenate    SEPARATOR=_    ${sw_release}  ${passive_check}[1]  
    ...    ${passive_check}[2]
    ...    ${passive_check}[3]
    RETURN    ${converted_SW_version}

do_rollback_when_target_sw_need_active

    [Arguments]    ${activeSoftwareSBTS}    ${passiveSoftwareSBTS}    ${5G_TARGET_SW}    ${connection}
    ${converted_activeSoftwareSBTS}    Convert_sw_version_depends_on_release    sw_index=${activeSoftwareSBTS}
    ${converted_passiveSoftwareSBTS}    Convert_sw_version_depends_on_release    sw_index=${passiveSoftwareSBTS}
    Run Keyword If    '${converted_passiveSoftwareSBTS}' == '${5G_TARGET_SW}'    BuiltIn.Log To Console    
    ...    [ INFO ]: SW Rollback is started. Expected start in 60 seconds.  
    Run Keyword If    '${converted_passiveSoftwareSBTS}' == '${5G_TARGET_SW}'  
    ...    Run Keywords    admin.rollback_software    connection=${connection}    
    ...    AND  BuiltIn.Log To Console    [ INFO ]: SW Rollback is started. Expected start in 60 seconds. 
    ...    AND    Sleep    5m
    Run Keyword If  '${converted_activeSoftwareSBTS}'=='${5G_TARGET_SW}' 
    ...     BuiltIn.Log To Console  [ INFO ]: SW Rollback Not needed. Active SW: ${activeSoftwareSBTS}
    Run Keyword If  ('${converted_activeSoftwareSBTS}'!='${5G_SOURCE_SW}' and '${converted_passiveSoftwareSBTS}' != '${5G_SOURCE_SW}')
    ...    Run Keywords  BuiltIn.Log To Console  [ INFO ]: SW Rollback won't perform due to provided Source SW not available.
    ...    AND    FAIL   [ ERROR ]: Source Build not available in BTS. TEST FAIL 
    RETURN    ${True}

do_rollback_when_source_sw_need_active
    [Arguments]      ${activeSoftwareSBTS}    ${passiveSoftwareSBTS}    ${5G_SOURCE_SW}    ${connection}
    ${converted_activeSoftwareSBTS}    Convert_sw_version_depends_on_release    sw_index=${activeSoftwareSBTS}
    ${converted_passiveSoftwareSBTS}    Convert_sw_version_depends_on_release    sw_index=${passiveSoftwareSBTS}     
    Run Keyword If  '${converted_passiveSoftwareSBTS}' == '${5G_SOURCE_SW}'
    ...    Run Keywords  admin.rollback_software    connection=${connection}
    ...    AND    BuiltIn.Log To Console   [ INFO ]: SW Rollback is started. Expected start in 60 seconds.    
    ...    AND    Sleep    5m
    Run Keyword If  '${converted_activeSoftwareSBTS}' == '${5G_SOURCE_SW}'
    ...     BuiltIn.Log To Console  [ INFO ]: SW Rollback Not needed. Active SW: ${activeSoftwareSBTS}
    Run Keyword If  ('${converted_activeSoftwareSBTS}'!='${5G_SOURCE_SW}' and '${converted_passiveSoftwareSBTS}' != '${5G_SOURCE_SW}')
    ...    Run Keywords  BuiltIn.Log To Console  [ INFO ]: SW Rollback won't perform due to provided Source SW not available.
    ...    AND    FAIL   [ ERROR ]: Source Build not available in BTS. TEST FAIL    
    RETURN    ${True}

Get_active_Passive_sw_from_bts
    [Arguments]    ${connection}=connection
    ${software_version}=    admin.get_software_info    timeout=30    connection=${connection}
	Set Test Variable    ${activeSoftwareSBTS}    ${software_version['Active SW version']}
	Set Test Variable    ${passiveSoftwareSBTS}    ${software_version['Passive SW version']}
	BuiltIn.Log To Console    [ INFO ]: Active SW Version: ${software_version['Active SW version']}
    BuiltIn.Log To Console    [ INFO ]: Passive SW Version: ${software_version['Passive SW version']}
    @{active_passive_sw_version}    create List    ${activeSoftwareSBTS}    ${passiveSoftwareSBTS}
    RETURN    @{active_passive_sw_version}

Connect_to_admin
    
    [Arguments]        ${connection}=connection
    admin.connect_to    name=${connection}
    RETURN    ${True}

Teardown_to_admin
    
    [Arguments]        ${connection}=connection
    admin.Teardown    connection=${connection}
    RETURN    ${True}

do_target_sw_as_active_sw

    [Documentation]    ${5G_TARGET_SW} is given in main suite. 
    [Arguments]    ${5G_TARGET_SW}    ${connection}=SW_ROLLBACK
	${admin_connection_status}    Connect_to_admin    connection=${connection}    
	@{active_passive_sw_version}    Get_active_Passive_sw_from_bts    connection=${connection}
    @{active_passive_release}    robot_sw_release_from_sw_version    active_sw_version=${active_passive_sw_version}[0]
    ...        Passive_sw_version=${active_passive_sw_version}[1]
    ${rollback_status}    do_rollback_when_target_sw_need_active    activeSoftwareSBTS=${active_passive_sw_version}[0]
    ...    passiveSoftwareSBTS=${active_passive_sw_version}[1]    5G_TARGET_SW=${5G_TARGET_SW}    connection=${connection}
    [Teardown]    Run Keywords    Teardown_to_admin    connection=${connection}    AND    
    ...   Run Keyword If    '${active_passive_sw_version}[1]' != '${5G_TARGET_SW}'    BuiltIn.Log To Console    [ INFO ]: SW Rollback Completed.
    RETURN    ${True}

do_source_sw_as_active_sw
    [Documentation]    ${5G_SOURCE_SW} is given in main suite.
    [Arguments]    ${5G_SOURCE_SW}    ${connection}=SW_ROLLBACK
	${admin_connection_status}    Connect_to_admin    connection=${connection}
	@{active_passive_sw_version}    Get_active_Passive_sw_from_bts    connection=${connection}
    @{active_passive_release}    robot_sw_release_from_sw_version    active_sw_version=${active_passive_sw_version}[0]
    ...        Passive_sw_version=${active_passive_sw_version}[1]
    ${rollback_status}    do_rollback_when_source_sw_need_active    activeSoftwareSBTS=${active_passive_sw_version}[0]
    ...    passiveSoftwareSBTS=${active_passive_sw_version}[1]    5G_SOURCE_SW=${5G_SOURCE_SW}    connection=${connection}
    [Teardown]    Run Keywords    Teardown_to_admin    connection=${connection}    AND
    ...   Run Keyword If    '${active_passive_sw_version}[1]' != '${5G_SOURCE_SW}'
    ...   BuiltIn.Log To Console    [ INFO ]: SW Rollback Completed.
    RETURN    ${True}

SCF_Commission
    [Documentation]    Keyword can fetch user input as xml file and does full commission
    [Arguments]     ${mrbts_id}    ${Commission_file}   ${connection}     
    admin.perform_commissioning    bts_id=${mrbts_id}    scf_file=${Commission_file}    connection=${connection}

BTS_Commission_verfy_on_air_status
    [Arguments]    ${scf_file_path}    ${MRBTS_ID}=${testline_name}    
    ...    ${connection}=LTEENB
    admin.Connect_to      name=${connection}
    SCF_Commission    mrbts_id=${MRBTS_ID}   Commission_file=${scf_file_path}    connection=${connection}
    builtIn.Log To Console    [ INFO ]: BTS verification is Started. 
    Wait Until Keyword Succeeds    10 min    30 s    verify the bts required status onair    connection=${connection}
    admin.Teardown    connection=${connection}

verify the bts required status onair
    [Arguments]    ${connection}=connection    ${Required_BTS_Status}=OnAir		

    # Connect_to_admin    connection=${connection}
    ${bts_status}   admin.get_bts_statuses    connection=${connection}
    Set Suite Variable    ${bts_status}
    Should Be Equal     first="${bts_status}[proceduralState]"  second="${Required_BTS_Status}"    

check_link_status_admin
    [Arguments]    ${connection}
    admin.check_link_status    connection=${connection}    detailed_output=${True}

taf_attenuator_objects
    [Documentation]  Author: Arunkumar A 
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${attenuation_ports}   ${set_value}

    ${Attenuator_device_config}  attenuator.setup_attenuator
    ...        ip_addr=${Attenuator_ip_addr}  
    ...        port=${Attenuator_com_port}  
    ...        attenuation_port_numbers=${attenuation_ports}
    ...        vendor=${Attenuator_vendor}
    ...        model=${Attenuator_model}
    Sleep    3s
    FOR  ${port}  IN  @{attenuation_ports}
        ${port_value}  attenuator.read_attenuation  port=${port}    attenuator_device=${Attenuator_device_config}
        Sleep    2s
        Run Keyword If   '${port_value}' != '${set_value}'  attenuator.set_attenuation    port=${port}  value=${set_value}  confirm=${True}
        ...    confirmation_delay=5    attenuator_device=${Attenuator_device_config}
        ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END
    RETURN    ${Attenuator_device_config}

Setup Attenuation Using Taf
    [Documentation]    Setup attenuation used Topyoung module.
    ...    :param - attenuator ip
    ...    :param - port of telnet connection 
    ...    :param - attenuation port used for attenuate
    ...    :param - vendor & module with respect to hardware component
    [Arguments]    ${ports}
    ${Attenuator_device_config}  attenuator.setup_attenuator
    ...        ip_addr=${Attenuator_ip_addr}
    ...        port=${Attenuator_com_port}  
    ...        attenuation_port_numbers=${ports}
    ...        vendor=${Attenuator_vendor}
    ...        model=${Attenuator_model}
    Sleep    3s
    RETURN    ${Attenuator_device_config}

Set_attenuation_on_single_port
    [Documentation]    Set attenuation on single port
    ...    :param - port : Port which needs to be attenuate
    ...    :param - value : Value should be 0 -120 dB
    ...    :param - attenuation_config : Return Attenuator.
    [Arguments]    ${port}    ${value}    ${Attenuator_device_config}
    attenuator.set_attenuation    port=${port}  value=${value}  confirm=${True}
    ...    confirmation_delay=5    attenuator_device=${Attenuator_device_config}
    Sleep    2s        # Majorly required due to Hardware response.

set_attenuation_on_multi_port
    [Documentation]    Set attenuation on single port
    ...    :param - port : Port which needs to be attenuate
    ...    :param - value : Value should be 0 -120 dB
    ...    :param - attenuation_config : Return Attenuation port.

    [Arguments]    ${ports}    ${value}    ${Attenuator_device_config}
    FOR    ${port}    IN    @{ports}
        Set_attenuation_on_single_port    port=${port}
        ...        value=${value}
        ...        Attenuator_device_config=${att} 
        Sleep    2s
    END
taf_attenuator_linear_object
    [Documentation]  Author: Arunkumar A 
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${attenuation_ports}    ${start_value}    ${end_value}
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}  
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    FOR   ${attenuation_port}  IN  @{attenuation_ports}
        Attenuator.set_linear_fading_scenario  port=${attenuation_port}  start_value=${start_value}  end_value=${end_value}  interval=3
        ...      unit=S  attenuator_device=${Attenuator_device_config}
        Attenuator.read_ports_attenuation  ports=${attenuation_ports}  attenuator_device=${Attenuator_device_config}
        Attenuator.set_ports_attenuation  ports=${ports}  values=${values}
        ...       confirmation_delay=3  attenuator_device=${attenuator_device}
    END
