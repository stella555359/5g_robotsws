*** Settings ***
Documentation   SSD Provision from NOM with methods change
Library    taf.nms.nom     WITH NAME    nom
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    OperatingSystem    WITH NAME    os
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    Collections
Library    ./testsuite/Bangalore/ORAN/SG04/resources/GetFileName.py
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/collect_logs.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/reportingportal_Keywords.robot
Resource   ./testsuite/Bangalore/ORAN/SG04/resources/alarm.robot
Library    ./testsuite/Bangalore/ORAN/SG04/resources/deletefiles.py
Resource   taf/rfrl/common_resources/common_step/interface.robot


Test Setup      Preconditions
Test Teardown   Test teardown
#Force Tags       CRT  SBTS22R3  SBTS22R4  FL00    QCD_MN_RAN   QCP_RAN_ST


*** Variables ***
${btsid}=    930
${location}=    /home/ute/results
${nom_apigw1}=    https://apigw.srncnms13.srnblr.nsn-rdnet.net
${nom_apigw2}=    apigw.srncnms13.srnblr.nsn-rdnet.net
${nom_usr_mgmt}=    https://user-mgmt.srncnms13.srnblr.nsn-rdnet.net
${user_nom}=   oran13
${pwd_nom}=    Qwer_2204
${path_ssd_m1_s1}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m1-s1.xml
${path_ssd_m1_s2}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m1-s2.xml
${path_ssd_m1_s3}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m1-s3.xml
${path_ssd_m3_s1}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m3-s1.xml
${path_ssd_m3_s2}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m3-s2.xml
${path_ssd_m3_s3}=    ./testsuite/Bangalore/ORAN/SG04/CB008480/mr930-ssd-m3-s3.xml
${vm_host}=    10.45.151.33
${vm_user}=    ute
${vm_pwd}=    BT5l@bus3rl0g1n
${bts_host}=    192.168.255.129
${bts_user}=    toor4nsn
${bts_pwd}=    oZPS0POrRieRtu

*** Test Cases ***
CB008480_D NOM import SSD RAML file and provision it to gNB with change of authenticationMethodSshServer method
    #[Tags]    CRT    QCD_MN_RAN    QCP_RAN_ST
    #[Teardown]    run keywords
    # ...      Set QC_Tag 
    Step1:Import & Provision SSD from NOM (only SSDBTS MO with Method 01)
    Step2:Reset all ORUs
    Step3:Import & Provision SSD from NOM (Default netconf with Method 01)
    Step4:Import & Provision SSD from NOM (Additional netconf with Method 01)
    Step5:Import & Provision SSD from NOM (Default netconf with Method 03)
    Step6:Reset all ORUs
    Step7:Import & Provision SSD from NOM (Additional netconf with Method 03)
    Step8:Netconf log collection


*** Keywords ***

Preconditions
    Log to console   --Test setup--
    coam.setup_admin
    ${sw_version}=    coam.get_sw_version
    Log to console  \n ${sw_version} \n
    Verify gNB is onAir
    delete_files_netconf
    Log to console   --Setup finished--
    sleep    5s


Step1:Import & Provision SSD from NOM (only SSDBTS MO with Method 01)
    Log to console   --\n Step:1 NOM CONNECTION STARTED \n--
    Run Keyword And Ignore Error    delete_the_client    5    ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    ${nom_secret}=    nom.register_the_client   5     ${user_nom}    ${pwd_nom}    ${nom_apigw1}
    Log to console    \n-- ${nom_secret}--\n
    nom.connect_to    ${nom_usr_mgmt}    ${nom_apigw2}    5    ${nom_secret}    443
	...    ${user_nom}    ${pwd_nom}    nom_v1   True
    SLEEP    10s
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    nom.delete_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=Delete planned SSD
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} EXISTING SSD PLAN DELETED \n--
    ${ssd_m1_s1}=    os.Get File    ${path_ssd_m1_s1}
    nom.import_ssd_raml    ${ssd_m1_s1}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED FOR ONLY SSDBTS WITH METHOD-01 \n--
    ${feedback1}    nom.provision_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=SSD Provision
    sleep   30s
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION FOR ONLY SSDBTS WITH METHOD-01 COMPLETED \n--
    Log to console   --\n ${feedback1} \n--
    Log to console  \n--Step:1 PASSED--  \n--

Step2:Reset all ORUs
    ${RMODS}  coam.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      Run Keyword And Ignore Error	coam.reset_unit    dist_name=${RMOD}    reset_type=Warm    timeout=60s
    END
    Log to console  \n-- Step:2 PASSED --\n


Step3:Import & Provision SSD from NOM (Default netconf with Method 01)
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m1_s2}=    os.Get File    ${path_ssd_m1_s2}
    nom.import_ssd_raml    ${ssd_m1_s2}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH DEFAULT NETCONF METHOD-01 \n--
    ${feedback2}    nom.provision_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=SSD Provision
    sleep   30
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH DEFAULT NETCONF METHOD-01  \n--
    Log to console   --\n ${feedback2} \n--
    Log to console  \n--Step:3 PASSED--\n

Step4:Import & Provision SSD from NOM (Additional netconf with Method 01)
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m1_s3}=    os.Get File    ${path_ssd_m1_s3}
    nom.import_ssd_raml    ${ssd_m1_s3}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH ADDITIONAL NETCONF METHOD-01 \n--
    ${feedback3}    nom.provision_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=SSD Provision
    sleep   30s
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH ADDITIONAL NETCONF METHOD-01  \n--
    Log to console   --\n ${feedback3} \n--
    Log to console  \n--Wait for 2 min to O-RUs comeup--\n
    Sleep    120s
    Verify gNB is onAir
    Log to console  \n-- Step:4 PASSED --\n


Step5:Import & Provision SSD from NOM (Default netconf with Method 03)
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m3_s2}=    os.Get File    ${path_ssd_m3_s2}
    nom.import_ssd_raml    ${ssd_m3_s2}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH DEFAULT NETCONF METHOD-03 \n--
    ${feedback4}    nom.provision_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=SSD Provision
    sleep   30s
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH DEFAULT NETCONF METHOD-03  \n--
    Log to console   --\n ${feedback4} \n--
    Log to console  \n--Wait for 2 min to O-RUs comeup--\n
    Sleep    120s
    Verify gNB is onAir
    Log to console  \n-- Step:5 PASSED --\n


Step6:Reset all ORUs
    ${RMODS}  coam.get_ids_for_all  RMOD
    Log to console  \n--Performing RMODs reset--\n
    FOR    ${RMOD}    IN  @{RMODS}
      coam.reset_unit    dist_name=${RMOD}    reset_type=Warm
    END
    Log to console  \n--Wait for 2 min to O-RUs RESET --\n
    Sleep    120s
    Log to console  \n-- Step:6 PASSED --\n


Step7:Import & Provision SSD from NOM (Additional netconf with Method 03)
    Log to console   --\n NOM CONNECTION ESTABLISHED \n--
    ${integrated_ids}=    Create List   MRBTS-930
    ${ssd_m3_s3}=    os.Get File    ${path_ssd_m3_s3}
    nom.import_ssd_raml    ${ssd_m3_s3}    complete_bts_overwrite=${TRUE}
    sleep   10s
    Log to console   --\n NOM MRBTS-${btsid} SSD PLAN IMPORTED WITH ADDITIONAL NETCONF METHOD-03 \n--
    ${feedback5}    nom.provision_ssd    ${integrated_ids}    timeout=20s    run_async=${FALSE}    user_defined_name=SSD Provision
    sleep   30s
    Log to console   --\n NOM MRBTS-${btsid} SSD PROVISION COMPLETED WITH ADDITIONAL NETCONF METHOD-03  \n--
    Log to console   --\n ${feedback5} \n--
    Log to console  \n--Wait for 2 min to O-RUs comeup--\n
    Sleep    120s
    Verify gNB is onAir
    Log to console  \n--Step:7 PASSED--\n


Step8:Netconf log collection
    Log to console   \n--Test Step-8: Netconf log collection--\n
    Netconf File Collection
    sleep    60
    #RP Settings
    Log to console  \n--Wait for 1 min for Netconf log collection --\n
    Log to console   \n-- Step-8 PASSED --\n


Netconf File Collection
    ${proxy}       Create Dictionary    host=${vm_host}    user=${vm_user}    password=${vm_pwd}
    ${executor}    Create Dictionary    host=${bts_host}    user=${bts_user}    password=${bts_pwd}
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
    os.Copy File    /home/ute/results/coredump/RMOD_L-1_NetconfRpcMessageTrace.log    /home/ute/results/RMOD_L-1_NetconfRpcMessageTrace_M3.log
	os.Copy File    /home/ute/results/coredump/RMOD_L-2_NetconfRpcMessageTrace.log    /home/ute/results/RMOD_L-2_NetconfRpcMessageTrace_M3.log
    os.Copy File    /home/ute/results/coredump/RMOD_L-3_NetconfRpcMessageTrace.log    /home/ute/results/RMOD_L-3_NetconfRpcMessageTrace_M3.log


Test teardown
    #[Arguments]    ${outputPath}=/tmp/btslog2
    Log to console   --\n Test teardown Started\n--
    Verify gNB is onAir
    sleep    100       
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    interface.Common step trigger
    Log to console   --\n Test teardown COMPLETED \n--
