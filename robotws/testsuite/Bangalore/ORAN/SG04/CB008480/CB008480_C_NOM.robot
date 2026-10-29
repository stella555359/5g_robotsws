*** Settings ***
Documentation   Transceiver performance measurement counter activation during the start-up of O-RU-NOM
Library    taf.nms.nom     WITH NAME    nom
Library       taf.collectors.simple    WITH NAME    simple
Library       taf.collectors.core    WITH NAME    core
Library    taf.sbts.oam.coam.admin.interface.admin  WITH NAME  coam
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Library    OperatingSystem    WITH NAME    os
Library    Collections
Library    String
Library    taf.config.scf.interface.scf     WITH NAME    scf
Resource   taf/rfrl/common_resources/common_step/interface.robot

Test Setup      Preconditions
Test Teardown   Test teardown
Force Tags       CRT  SBTS22R3  SBTS22R4  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[1][2.0] TEST CASE_1 - CB008480_C-Transceiver performance measurement counter activation and deactivation on Multiple O-RU Configuration}
...    QC_ID_SBTS22R3=QC_299156    QC_ID_SBTS22R4=QC_381594    QC_ID_FL00=QC_297171

${bts_id}=    930
${scf_path}=    /home/ute/Downloads/nom_mrbts930_scf.xml
${plan_path}=    /home/ute/Plan/Plan-930-7.xml
${user_nom}=   nom02
${pwd_nom}=   Qwer_151122
${nom_apigw1}=    https://apigw.srncnms12.srnblr.nsn-rdnet.net
${nom_apigw2}=    apigw.srncnms12.srnblr.nsn-rdnet.net
${nom_usr_mgmt}=    https://user-mgmt.srncnms12.srnblr.nsn-rdnet.net
${counter_nos}=	M55606C00001,M55606C00002,M55606C00003,M55606C00004,M55606C00005,M55606C00006,M55606C00007,M55606C00008,M55606C00009,M55606C00010
*** Test Cases ***
[1][2.0] TEST CASE_1 - CB008480_C-Transceiver performance measurement counter activation and deactivation on Multiple O-RU Configuration
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag
    Step1:Prepare configuration plan file
    Step2:Transiver PM counter check during Statup of RU from NOM
    Step3:Netconf log collection


*** Keywords ***

Preconditions
    Log to console    \n--Test setup--\n
    coam.setup_admin
    ${sw_version}=    coam.get_sw_version
    Log to console    \n ${sw_version} \n
    #Verify gNB is onAir
    Log to console    \n--Setup finished--\n
    sleep    5s


Step1:Prepare configuration plan file
    Log to console    \n--Step:1 Started--\n
    Log to console    \n--SCF Download started--\n
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'
	...    password='nemuuser'   use_ssl=True    name='default'
    sleep   30s
    coam.collect_scf    target_file_name=${scf_path}    export_type=configuration
	...    timeout=30    connection=default    parameters_save_varient=actualValues
    sleep   10s
    scf.load_scf	${scf_path}
    ${plan_version}	scf.get_mo_attribute    dist_name=MRBTS-930/NRBTS-930/NRPMRNL-1    attribute=version    
    scf.load_scf    ${plan_path}
    scf.set_mo_attribute	dist_name=MRBTS-930/NRBTS-930/NRPMRNL-1    attribute=version    value=${plan_version}
    scf.save_scf    ${plan_path}    xml_declaration=True    encoding=UTF-8    standalone=True
    Log to console    \n--Step:1 PASSED--\n

Step2:Transiver PM counter check during Statup of RU from NOM
    Log to console    \n--Step2: Started--\n
    Log to console    \n--NOM CONNECTION STARTED--\n
    Run Keyword And Ignore Error    delete_the_client    5    ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    ${nom_secret}=    nom.register_the_client   5     ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    Log to console     \n--${nom_secret}--\n
    nom.connect_to    ${nom_usr_mgmt}    ${nom_apigw2}    5    ${nom_secret}    443
	...    ${user_nom}    ${pwd_nom}    nom_v1   True
    SLEEP    10s
    Log to console    \n--NOM CONNECTION ESTABLISHED--\n
    nom.import_plan	${plan_path}	name=Plan-930-7	overwrite=${TRUE}
    sleep   20s
    Log to console    \n--PLAN IMPORTED--\n
    nom.download_plan    plan_name=Plan-930-7   timeout=100
    sleep    20s
    Log to console    \n--PLAN DOWNLOADED--\n
    nom.validate_plan    plan_name=Plan-930-7   timeout=100
    sleep    20s
    Log to console    \n--PLAN VALIDATED--\n
    nom.activate_plan    plan_name=Plan-930-7   timeout=100
    sleep    20s
    Log to console    \n--PLAN ACTIVATED--\n
    SLEEP    10m
    @{counter_list}=    create list    'M55606C00001'    'M55606C00002'    'M55606C00003'    'M55606C00004'    'M55606C00005'
    ...    'M55606C00006'    'M55606C00007'    'M55606C00008'    'M55606C00009'    'M55606C00010'
    ${result} =   coam.get_pm_counters      counter_ids=${counter_nos}		timeout=600    connection=default    
     FOR    ${I}    IN    @{counter_list}
            ${values}=    Get Dictionary Values   ${result['BTS']['SMOD']['SFP-1']['RMOD-1']['OTRXS'][${I}]}
	    ${values1}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-1']['RMOD-2']['OTRXS'][${I}]}
	    ${values2}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-1']['RMOD-3']['OTRXS'][${I}]}
	    ${values3}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-2']['RMOD-1']['OTRXS'][${I}]}
	    ${values4}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-2']['RMOD-2']['OTRXS'][${I}]}
	    ${values5}=   Get Dictionary Values   ${result['BTS']['SMOD']['SFP-2']['RMOD-3']['OTRXS'][${I}]}
            #log to console    ${values}
            Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
	    Should Be True    ${values[-1]}>0
     END 
    Log to console   \n--step:2 Passed--\n

Step3:Netconf log collection
    Log to console    \n--STEP3: NETCONF LOG COLLECTION STARTED--\n
    Netconf File Collection
    sleep    60
    RP Settings
    Log to console    \n--STEP3 PASSED--\n 

Netconf File Collection
    ${proxy}       Create Dictionary    host=10.45.151.33    user=ute    password=BT5l@bus3rl0g1n
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    #core.start_collectors    names=coredump
    sleep    30s
    #core.stop_collectors    names=coredump
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace.log

Test teardown
    Log to console   \n--Test teardown Started--\n
    #Verify gNB is onAir
    interface.Common step trigger
    Log to console   \n--Test teardown COMPLETED--\n
