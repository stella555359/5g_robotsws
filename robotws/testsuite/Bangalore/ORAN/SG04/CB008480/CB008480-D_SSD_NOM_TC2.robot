*** Settings ***
Documentation   SSD Import & Provisioning from NOM [TC02]
Library    taf.nms.nom     WITH NAME    nom
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    OperatingSystem    WITH NAME    os
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    Collections
Library    DateTime
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
&{[1][1.0] Test_Case_2-CB008480_D NOM import SSD RAML file provision it to gNB}      QC_ID_SBTS22R3=QC_389413     QC_ID_FL00=QC_389402


*** Test Cases ***
[1][1.0] Test_Case_2-CB008480_D NOM import SSD RAML file provision it to gNB
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    [Teardown]    run keywords
     ...      Set QC_Tag
    Step1:Import & Provision SSD from NOM (only SSDBTS MO with Method 02)
    Step2:Reset all ORUs
    Step3:Import & Provision SSD from NOM (Default netconf with Method 02)
    Step4:Import & Provision SSD from NOM (Additional netconf with Method 02)
    Step5:Netconf log collection



*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin    bts_host=192.168.255.129
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    Verify gNB is onAir
    delete_files_netconf
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	  coam.Get Active alarms
    coam.Get Alarm History
    Log to console   --Setup finished--
    sleep    5s


Step1:Import & Provision SSD from NOM (only SSDBTS MO with Method 02)
    Log to console   --\n Step:1 NOM CONNECTION STARTED \n--
    Run Keyword And Ignore Error    delete_the_client    5    ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    ${nom_secret}=    nom.register_the_client   5     ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    Log to console    \n NOM client id: ${nom_secret} \n
    nom.connect_to    ${nom_usr_mgmt}    ${nom_apigw2}    5    ${nom_secret}    443
	...    ${user_nom}    ${pwd_nom}    nom_v1   True
    SLEEP    10s
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    Log to console   --\n DELETING EXISTING SSD PLAN FROM NOM FOR MRBTS-${btsid} \n--
    ${integrated_ids}=    Create List   MRBTS-930
    nom.delete_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}
    ...    user_defined_name=Delete planned SSD
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} EXISTING SSD PLAN DELETED \n--
    Log to console   --\n STARTING NOM SSD PLAN IMPORT FOR MRBTS-${btsid} \n--
    ${ssd_m2_s1}=    os.Get File    ${path_ssd_m2_s1}
    nom.import_ssd_raml    ${ssd_m2_s1}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED FOR ONLY SSDBTS WITH METHOD-02 \n--
    Log to console   --\n PROVISIONING NOM SSD PLAN TO MRBTS-${btsid} \n--
    ${feedback1}    nom.provision_ssd    ${integrated_ids}    timeout=30s    run_async=${FALSE}
    ...    user_defined_name=SSD Provision
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION FOR ONLY SSDBTS WITH METHOD-02 COMPLETED \n--
    Log to console   --\n ${feedback1} \n--
    Log to console  \n--Step:1 PASSED--  \n--


Step2:Reset all ORUs
    Log to console    \n--Step:2 Reset All ORU--\n
    ${RMODS}  coam.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      Run Keyword And Ignore Error	coam.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=60s
    END
    #Log to console  \n--Wait for 2 min for O-RUs to come UP --\n
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	  coam.Get Active alarms
    coam.Get Alarm History
    Log to console  \n-- Step:2 PASSED --\n


Step3:Import & Provision SSD from NOM (Default netconf with Method 02)
    Log to console   --\n Step:3 NOM CONNECTION ESTABLISHED \n--
    Log to console   --\n STARTING NOM SSD PLAN IMPORT FOR MRBTS-${btsid} \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m2_s2}=    os.Get File    ${path_ssd_m2_s2}
    nom.import_ssd_raml    ${ssd_m2_s2}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH DEFAULT NETCONF METHOD-02 \n--
    Log to console   --\n PROVISIONING NOM SSD PLAN TO MRBTS-${btsid} \n--
    ${feedback2}    nom.provision_ssd    ${integrated_ids}    timeout=30s    run_async=${FALSE}
	  ...    user_defined_name=SSD Provision
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH DEFAULT NETCONF METHOD-02  \n--
    Log to console   --\n ${feedback2} \n--
    Log to console  \n--Wait for 2 min to O-RUs comeup--\n
    Sleep    120s
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	  coam.Get Active alarms
    coam.Get Alarm History
	  Verify gNB is onAir
    Log to console  \n--Step:3 PASSED--\n


Step4:Import & Provision SSD from NOM (Additional netconf with Method 02)
    Log to console   --\n Step:4 NOM CONNECTION ESTABLISHED \n--
    Log to console   --\n STARTING NOM SSD PLAN IMPORT FOR MRBTS-${btsid} \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m2_s3}=    os.Get File    ${path_ssd_m2_s3}
    nom.import_ssd_raml    ${ssd_m2_s3}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH ADDITIONAL NETCONF METHOD-02 \n--
    Log to console   --\n PROVISIONING NOM SSD PLAN TO MRBTS-${btsid} \n--
    ${feedback3}    nom.provision_ssd    ${integrated_ids}    timeout=30s    run_async=${FALSE}
    ...    user_defined_name=SSD Provision
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH ADDITIONAL NETCONF METHOD-02  \n--
    Log to console   --\n ${feedback3} \n--
    Log to console  \n--Wait for 2 min to O-RUs comeup--\n
    sleep   120s
    ${Alarm_no}=    coam.Get Active alarms number
    Log to console  \n No of Active alarms : ${Alarm_no} \n
	  coam.Get Active alarms
    coam.Get Alarm History
    Verify gNB is onAir
    Log to console  \n--Step:4 PASSED--\n


Step5:Netconf log collection
    Log to console   \n--Test Step-5: Netconf log collection--\n
    Netconf File Collection
    sleep    60
    RP Settings
    Log to console  \n--Wait for 1 min for Netconf log collection --\n
    Log to console   \n-- Step-5 PASSED --\n


Netconf File Collection
    ${proxy}       Create Dictionary    host=${vm_host}    user=${vm_user}    password=${vm_pwd}
    ${executor}    Create Dictionary    host=192.168.255.129    user=toor4nsn    password=oZPS0POrRieRtu
    ...     proxy=${proxy}
    simple.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/node_FHNET00/tmp
    ...    file_pattern=.*
    ...    executor=${executor}
    ...    target_file_name=coredump1.log
    core.setup_collectors    names=coredump
    sleep    30s
    core.collect_collectors    names=coredump    target_dir=/home/ute/results
    core.teardown_collectors    names=coredump
    os.Run    tar -zxvf /home/ute/results/coredump/coredump1.log.tgz -C /home/ute/results/coredump
    ${datetime}=    Get Current Date    result_format=%Y%m%d-%H%M
    os.Move File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log
	...    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace_TC2.log
	os.Move File    /home/ute/results/coredump/RMOD_L-2_NetconfRpcMessageTrace.log
	...    /home/ute/results/RMOD_L-2_NetconfRpcMessageTrace_TC2.log
    os.Move File    /home/ute/results/coredump/RMOD_L-3_NetconfRpcMessageTrace.log
	...    /home/ute/results/RMOD_L-3_NetconfRpcMessageTrace_TC2.log


Test teardown
    Log to console   --\n Test teardown Started\n--
    Verify gNB is onAir
    sleep    100        
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--
