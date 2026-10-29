*** Settings ***
Library         taf.sbts.oam.coam.admin  
Library    OperatingSystem
Library    ute_fsmaccess
Library    taf.analyzer.netconf     WITH NAME    netconf
Library        taf.transport.ssh
Library        Collections
Library    String
Library                SSHLibrary
Library                     ute_reporting_portal
Library    taf.sw.scout    WITH NAME    scout
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource    ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot

Force Tags       CRT  SBTS23R2	SBTS22R4    SBTS23R1  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[6.0] CB007041_ Verify Enabling debug logs (0x750000) for Netconf agent from web EM.}
...	QC_ID_FL00=QC_539082    QC_ID_SBTS23R3=QC_486944	QC_ID_SBTS23R2=QC_539991

${Fault_ID}=
${outputPath}=    /tmp/btslog2
${TIMESTAMP}=   0
${tc}=       sam
${btsid}=    1
${distName}=    MRBTS-${btsid}/EQM-1/APEQM-1/RMOD-1
${distName_1}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1
${distName_2}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/SFP_R-1
${distName_3}=    MRBTS-${btsid}/EQM_R-4/APEQM_R-1/RMOD_R-1/FAN_R-1
${bts_id}=    0
${du_id}=    0
${runs}=    1
${location}=    /home/ute/results

*** Test Cases ***
[6.0] CB007041_ Verify Enabling debug logs (0x750000) for Netconf agent from web EM.
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag
    #Link SCOUT SCF to Configuration ID for Reporting 
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    taf.sbts.oam.coam.admin.setup_admin    bts_host=192.168.255.129 
    ${a}=  taf.sbts.oam.coam.admin.get_cell_list
    log  ${a}
    ${b}=  taf.sbts.oam.coam.admin.Get Non Default Rad Debug
    log  ${b}
	Link SCOUT SCF to Configuration ID for Reporting	
    Run keyword And Continue On Failure  taf.sbts.oam.coam.admin.set_rad_debug_parameters  
    ...    domain=OamNetconf   
    ...    persistency=Persistent   
    ...    name=NetconfLog  
    ...    value=true  
    ...    detailed_output="True" 
    Validation   [0x750000 = 1]
    Run keyword And Continue On Failure  taf.sbts.oam.coam.admin.reset   
    sleep  06m
    Run keyword And Continue On Failure  taf.sbts.oam.coam.admin.collect_snapshot  
    ...    target_file_name=/home/ute/Automation/CRT/snapshot_Check2.zip
    Run keyword And Continue On Failure  taf.sbts.oam.coam.admin.set_rad_debug_parameters  
    ...    domain=OamNetconf   
    ...    persistency=Persistent   
    ...    name=NetconfLog  
    ...    value=false  
    ...    detailed_output="True"  
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin 
    Validation   [0x750000 = 0]
    RP Settings

*** Keywords ***

Validation

    [Arguments]    ${grepCheck}

    SSHLibrary.Open Connection   192.168.255.129
    SSHLibrary.Login   toor4nsn  oZPS0POrRieRtu
    SSHLibrary.File Should Exist  /ffs/run/swconfig.txt
    SSHLibrary.Get File   /ffs/run/swconfig.txt   /home/ute/swconfig.txt
    SSHLibrary.Close All Connections
    ${errors} =   OperatingSystem.Grep File   /home/ute/swconfig.txt   [${grepCheck}]
    Log To Console  ${errors}
    
Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
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

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${CONFIGURATION}

    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=	Wait Until Keyword Succeeds		2min	10s	Request Scout SCF	${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
