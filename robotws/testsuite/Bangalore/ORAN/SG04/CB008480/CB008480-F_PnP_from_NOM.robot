*** Settings ***
Documentation   SSD provisioning from NOM during BTS Plug & Play
Library    taf.nms.nom     WITH NAME    nom
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.fdsw.rc	WITH NAME  rc
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.config.scf     WITH NAME    scf
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Resource   taf/rfrl/common_resources/common_step/interface.robot
Variables   ./testsuite/Bangalore/ORAN/SG04/resources/TL04_parameters.py


Test Setup      Preconditions
Test Teardown   Test teardown
Force Tags       CRT  SBTS22R3  SBTS22R4  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NOM during BTS Plug and Play.}
...         QC_ID_SBTS22R3=QC_318315    QC_ID_SBTS22R4=QC_381599    QC_ID_FL00=QC_318287


*** Test Cases ***
[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NOM during BTS Plug and Play.
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag
    Step1:Prepare configuration plan file
    Step2:Activate autoconfiguration to NOM
    Step3:Import SSD RAMl file to NOM
    Step4:Start configuration reset from WebEM
    Step5:set autoconnection parameters from WebEM


*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin    bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	coam.Get Active alarms
    coam.Get Alarm History
    Log to console   --Setup finished--
    sleep    5s


Step1:Prepare configuration plan file
    Log to console   --\n SCF Download started \n--
    Log to console   --\n Step:1 started \n--
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'
	...    password='nemuuser'   use_ssl=True    name='default'
    sleep   30s
     coam.get_current_scf_file    ${dwl_path}    nom_mrbts930_scf.xml    timeout=30    
	...    connection=default    export_type=configuration    parameters_save_variant=actualValues

	#SCF modification start
    ${sw_version}=	coam.get_sw_version
    sleep   10s
	scf.load_scf    ${path_pnp_scf}
	scf.add_element_to_scf   dist_name=MRBTS-${btsid}   p_name=AutoConnHWID    value=${AutoHWID}
	scf.add_element_to_scf   dist_name=MRBTS-${btsid}/MNL-1  p_name=plannedSWReleaseVersion    value=${sw_version}
	scf.add_object_to_scf    dist_name=MRBTS-${btsid}/MRBTSINT-AUTO   class_name=com.nokia.nms.integration:MRBTSINT
	...    version=1.0
	scf.add_element_to_scf   dist_name=MRBTS-${btsid}/MRBTSINT-AUTO     p_name=password  value=${AutoPWD}
	scf.add_element_to_scf   dist_name=MRBTS-${btsid}/MRBTSINT-AUTO     p_name=sbiNetConnectedTo
	...    value=sbi-default-ipv4
	scf.add_element_to_scf   dist_name=MRBTS-${btsid}/MRBTSINT-AUTO     p_name=username  value=${AutoUser}
	scf.save_scf    file_path=${path_pnp_ac}
	#SCF modification end

    sleep   10s
    Log to console   --\n Step:1 Passed \n--


Step2:Activate autoconfiguration to NOM
    Log to console   --\n Step:2 NOM CONNECTION STARTED \n--
    Run Keyword And Ignore Error    delete_the_client    5    ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    ${nom_secret}=    nom.register_the_client   5     ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    Log to console    \n-- ${nom_secret}--\n
    nom.connect_to    ${nom_usr_mgmt}    ${nom_apigw2}    5    ${nom_secret}    443
	  ...    ${user_nom}    ${pwd_nom}    nom_v1   True
    SLEEP    10s
	  Log to console   --\n NOM CONNECTION ESTABLISHED \n--
     
    ${sw_version}=	coam.get_sw_version
    sleep   10s
    	  Log to console   --\n IMPORT SBTS BUILD TO NOM, Wait for 30 mins \n--
    ${import_sw}=    nom.import_sw_package    ${dw2_path}/${sw_version}_release_BTSSM_downloadable.zip
    ...    MRBTS    ne_sw_version=${sw_version}
    	  ...    file_name=${sw_version}_release_BTSSM_downloadable.zip    timeout=3600
    Log to console   --\n SBTS BUILD IMPORTED  ${import_sw} \n--
	
    Log to console   --\n IMPORTING MRBTS-${btsid} AUTOCONNECTION PLAN TO NOM \n--
    nom.import_plan	${path_pnp_ac}	name=CB008480-PNP-AC-${btsid}	overwrite=${TRUE}
    ...    plan_type=Autoconfiguration
    sleep   20s
    Log to console   --\n NOM MRBTS-${btsid} AUTOCONNECTION PLAN IMPORTED \n--
    
    nom.import_plan	${path_pnp_dereg}	name=CB008480-PNP-dereg  overwrite=${TRUE}  plan_type=Deintegration
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} DEINTEGRATE PLAN IMPORTED \n--
    ${deint}=    nom.deintegrate_ne  plan_name=CB008480-PNP-dereg  timeout=30    purge_data=${TRUE}
    ...    run_async=${True}
    sleep   30s
    
    Log to console   --\n NOM MRBTS-${btsid} DEINTEGRATED: ${deint} \n--
    #get_operation_feedbacks    ${deint}
    ${autoconfig}=    nom.activate_autoconfiguration	plan_name=CB008480-PNP-AC-${btsid}
  	...    apply_templates=${TRUE}	validate=${TRUE}    timeout=30	overwrite=${TRUE}
    ...    user_defined_name=Activate autoconfiguration plan
    sleep   30s
    Log to console   --\n NOM MRBTS-${btsid} AUTOCONFIGURATION ACTIVATED: ${autoconfig} \n--
    #taf.sbts.oam.coam.admin.teardown


Step3:Import SSD RAMl file to NOM
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    Run Keyword And Ignore Error	nom.delete_ssd    ${integrated_ids}    timeout=20s
    ...    run_async=${FALSE}    user_defined_name=Delete planned SSD
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} EXISTING SSD PLAN DELETED \n--
    ${ssd_m1_s2}=    Get File    ${path_ssd_m1_s2}
    nom.import_ssd_raml    ${ssd_m1_s2}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED COMPLETED \n--


Step4:Start configuration reset from WebEM
    Log to console   --\n NOM MRBTS-${btsid} CONFIGURATION RESET STARTED \n--
    Log to console   --\n Wait 600s \n--
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'
	...    password='nemuuser'   use_ssl=True
    sleep   30s
    coam.reset_configuration  remove_operator_certificates=${FALSE}  timeout=600    detailed_output=${True}
    Log to console   --\n NOM MRBTS-${btsid} CONFIGURATION RESET COMPLETED \n--


Step5:Set autoconnection parameters from WebEM
    Log to console   --\n NOM MRBTS-${btsid} AUTOCONNECTION PARAMETER SENT\n--
    Log to console   --\n Wait 600s \n--
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'   password='nemuuser'
	...    use_ssl=True	name='default'
    ${mplane}=    Convert To Integer	${pnp_subnet}
    ${vlanid}=    Convert To Integer	${pnp_vlanid}
    coam.set_autoconnection_transport_params	timeout=120	connection=default	mPlaneIpAddress=${pnp_mplaneip}
	...    mPlaneIpPrefix=${mplane}    defaultGateway=${pnp_defgw}	vlanId=${vlanid}
	...    identificationServerIpAddress=${pnp_nomip}
    sleep   600s
    Log to console   --\n NOM MRBTS-${btsid} PNP REPORT STARTED\n--
    coam.get_pnp_report    output_file_name=${path_pnp_report}    timeout=20s    connection=default
    sleep   200s
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	  coam.Get Active alarms
    coam.Get Alarm History
    Verify gNB is onAir
    RP Settings
    Log to console   --\n NOM MRBTS-${btsid} PLUG & PLAY COMPLETED\n--


Test teardown
    Log to console   --\n Test teardown Started\n--
    Verify gNB is onAir
    sleep    10s        
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--
