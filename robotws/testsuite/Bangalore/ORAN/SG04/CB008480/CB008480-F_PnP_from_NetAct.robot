*** Settings ***
Documentation   SSD provisioning from NetAct during BTS Plug & Play
Library    taf.nms.nom     WITH NAME    nom
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.fdsw.rc	WITH NAME  rc
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.nms.netact
Library    taf.config.scf     WITH NAME    scf
Library    DateTime
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Resource   taf/rfrl/common_resources/common_step/interface.robot

Suite Setup    Suite Precondition
Suite Teardown    Suite Postcondition

Test Setup      Preconditions
Test Teardown   Test teardown
Force Tags       CRT  SBTS22R3  SBTS22R4  FL00    QCD_MN_RAN   QCP_RAN_ST

*** Variables ***
&{[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NetAct during BTS Plug and Play.}
...     QC_ID_SBTS22R3=QC_318316    QC_ID_FL00=QC_318286
${btsid}=    578
${location}=    /home/ute/results
${acplan_path1}=    /${LOCAL_DIR}/netact_mrbts${btsid}_pnp.xml
${NETACT_NAME}=    srnclab1042
${WEB_URL}=    https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${HOSTNAME}=    10.43.48.16
${USERNAME}=    omc
${PASSWORD}=    Medsql!_1893
${DIST_NAME}=    PLMN-PLMN/MRBTS-${btsid}
${LOCAL_DIR}=    /tmp/
${MRBTS_MO_RELEASE}=    SBTS22R4
${MRBTS_MO_ADDRESS}=    10.43.197.216
${MRBTS_MO_MR}=         MRC-COMMON/MR-COMMON
${SECURITY_MODE}=       no TLS
${pnp_report}=    /home/ute/results/nom-pnp-report.txt
${DEL_SW_VERSION}=    SBTS22R4_ENB_9900_220627_000015
${UPG_SW_VERSION}=    SBTS00_ENB_9999_220725_000005
${AutoHWID}=   L1202800763
${SW_PACKAGE_PATH}=    /home/ute/Downloads/${UPG_SW_VERSION}_release_BTSSM_downloadable.zip
${AutoUser}=   wsuser
${AutoPWD}=   A0zY~rP#8Mx@
${pnp_subnet}=    28
${pnp_vlanid}=    1102
${pnp_mplaneip}=    10.43.197.216
${pnp_defgw}=    10.43.197.208
${pnp_netactip}=    10.43.48.28


*** Test Cases ***
[1][2.0] CB008480_F O-RU Secure Sensitive Data (SSD) provisioning from NetAct during BTS Plug and Play.
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag 
    Step1:Integrate MRBTS from NetAct
    Step2:Prepare configuration plan file
    Step3:Software delete & Import to NetAct
    Step4:De-integrate MRBTS from NetAct
	Step5:Activate autoconfiguration from NetAct
    Step6:Start configuration reset from WebEM
	Step7:Set autoconnection parameters from WebEM



*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    #Verify gNB is onAir
    Log to console   --Setup finished--
    sleep    5s


Step1:Integrate MRBTS from NetAct
    Log to console   --\n Integrate MRBTS With Netact \n--
    ${integration_output}=    Integrate MRBTS With Netact    release=${MRBTS_MO_RELEASE}    mr=${MRBTS_MO_MR}
    ...    mrbts_address=${MRBTS_MO_ADDRESS}    dist_name=${DIST_NAME}
    ...    security_mode=${SECURITY_MODE}    alias=${NETACT_NAME}
    Log    \n${integration_output}    console=${TRUE}
    Log to console   --\n Step:1 Passed \n--


Step2:Prepare configuration plan file
    Log to console   --\n CM Operations Export Actual Configuration \n--
    #${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    export_configuration    mrbts-${btsid}-step1.xml    local_dir=${LOCAL_DIR}
    ...    dist_names=${DIST_NAME}    ui_values=${TRUE}    alias=${NETACT_NAME}

    Log  \Modify SCF paremeter    console=TRUE
	#SCF modification start
    ${sw_version}=	coam.get_sw_version
    sleep   10s
	scf.load_scf    /tmp/mrbts-${btsid}-step1.xml
    scf.set_mo_attribute    dist_name=${DIST_NAME}   attribute=operation    value=create
	scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=AutoConnHWID    value=${AutoHWID}
	scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=$maintenanceRegionId    value=PNP
	scf.add_element_to_scf   dist_name=${DIST_NAME}   p_name=$maintenanceRegionCId    value=1
	scf.add_element_to_scf   dist_name=${DIST_NAME}/MNL-1  p_name=plannedSWReleaseVersion    value=${UPG_SW_VERSION}
	scf.add_object_to_scf    dist_name=${DIST_NAME}/INTEGRATE-1    class_name=com.nokia.integrate:INTEGRATE
	...    version=INT_01
	scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=hostNameEm
	...    value=${pnp_mplaneip}
	scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=hostNameNe3sws
	...    value=${pnp_mplaneip}
	scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=plannedSWReleaseVersion
	...    value=${UPG_SW_VERSION}
	scf.add_element_to_scf   dist_name=${DIST_NAME}/INTEGRATE-1    p_name=systemReleaseVersion
	...    value=${MRBTS_MO_RELEASE}
	scf.save_scf    file_path=${acplan_path1}
	#SCF modification end
    sleep   10s

    Log to console   --\n CM Operations Import Configuration \n--
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    import_configuration    netact_mrbts${btsid}_pnp.xml    local_dir=${LOCAL_DIR}
    ...    plan_name=mrbts-${btsid}-step2-${datetime}.xml   ui_values=${TRUE}    alias=${NETACT_NAME}
    sleep   20s

    Log to console   --\n Test CM Operations Export Plan Configuration \n--
    Export Configuration     mrbts-${btsid}-step3-${datetime}.xml    local_dir=${LOCAL_DIR}    dist_names=${DIST_NAME}
    ...    class_filter_include=None    operation_type=plan
    ...    plan_name=mrbts-${btsid}-step2-${datetime}.xml    ui_values=${FALSE}    alias=${NETACT_NAME}
    Log to console   --\n Step:2 Passed \n--


Step3:Software delete & Import to NetAct
    Log to console   --\n List Of Imported Builds \n--
    ${imported_builds}=    Get List Of Imported Builds    alias=${NETACT_NAME}
    Log    \nImported builds: ${imported_builds}    console=${TRUE}
    Log to console   --\n Delete Old software build from NetAct \n--
    Run Keyword And Ignore Error    Delete Build    ${DEL_SW_VERSION}    mo_type=MRBTS    alias=${NETACT_NAME}
    Log to console   --\n Import software build, Wait for 20 mins \n--
    Import Build    ${SW_PACKAGE_PATH}    alias=${NETACT_NAME}
    ${import_status}=    Is Imported    ${UPG_SW_VERSION}    alias=${NETACT_NAME}
    Log to console   --\n Step:1 Passed \n--


Step4:De-integrate MRBTS from NetAct
    Log to console   --\n De-integrate MRBTS from NetAct \n--
    ${deintegration_output}=    Deintegrate MRBTS From Netact    dist_name=${DIST_NAME}   alias=${NETACT_NAME}
    ${deintegration_output}=    unregister_ne3s    dist_name=${DIST_NAME}   alias=${NETACT_NAME}
    Log    \n${deintegration_output}    console=${TRUE}
    sleep    10s
    Log to console   --\n Delete object in Monitor \n--
    ${delete_monitor_output}=    delete_object_from_monitor    ${DIST_NAME}    alias=${NETACT_NAME}
    Log    \n${delete_monitor_output}    console=${TRUE}
    Log to console   --\n Delete configuration data of network element \n--
    ${delete_nedata_output}=    delete_ne_data_from_configurator    ${DIST_NAME}    alias=${NETACT_NAME}
    Log    \n${delete_nedata_output}    console=${TRUE}


Step5:Activate autoconfiguration from NetAct
    Log to console   --\n Started unified PNP operation \n--
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    prepare_unified_pnp_coam_site    mrbts-${btsid}-step3-${datetime}.xml   
	...    mrbts-${btsid}-step3-${datetime}.xml    alias=${NETACT_NAME}


Step6:Start configuration reset from WebEM
    Log to console   --\n NOM MRBTS-${btsid} CONFIGURATION RESET STARTED \n--
    Log to console   --\n Wait 600s \n--
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'
	...    password='nemuuser'   use_ssl=True
    sleep   30s
    coam.reset_configuration  remove_operator_certificates=${FALSE}  timeout=600    detailed_output=${True}
    Log to console   --\n NOM MRBTS-${btsid} CONFIGURATION RESET COMPLETED \n--


Step7:Set autoconnection parameters from WebEM
    Log to console   --\n NOM MRBTS-${btsid} AUTOCONNECTION PARAMETER SENT\n--
    Log to console   --\n Wait 600s \n--
    coam.connect_to     bts_host=192.168.255.129   bts_port=443  username='Nemuadmin'   password='nemuuser'
	...    use_ssl=True	name='default'
    ${mplane}=    Convert To Integer	${pnp_subnet}
    ${vlanid}=    Convert To Integer	${pnp_vlanid}
    coam.set_autoconnection_transport_params	timeout=120	connection=default	mPlaneIpAddress=${pnp_mplaneip}
	...    mPlaneIpPrefix=${mplane}    defaultGateway=${pnp_defgw}	vlanId=${vlanid}
	...    identificationServerIpAddress=${pnp_netactip}
    sleep   600s
    Log to console   --\n NOM MRBTS-${btsid} PNP REPORT STARTED\n--
    coam.get_pnp_report    output_file_name=${pnp_report}    timeout=20s    connection=default
    sleep   60s
    Verify gNB is onAir
    RP Settings
    Log to console   --\n NOM MRBTS-${btsid} PLUG & PLAY COMPLETED\n--


Test teardown
    #[Arguments]    ${outputPath}=/tmp/btslog2
    Log to console   --\n Test teardown Started\n--
    Verify gNB is onAir
    sleep    100       
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--


Suite Precondition
    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}
    ${web_url}=    Detect WEB URL    alias=${NETACT_NAME}
    Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${NETACT_NAME}

Suite Postcondition
    Delete Node    cmwas    alias=${NETACT_NAME}
    Clean All    alias=${NETACT_NAME}
