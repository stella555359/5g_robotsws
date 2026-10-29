#(py27) localuser@iv-ps328:~/TafProject/robotws/testsuite/Paris/RRM/ST/5GC002093/tests$
# /home/localuser/TafProject/robotws/testsuite/Paris/RRM/ST/5GC002093/tests/
# robot --dryr -V CV328/ -b debug.log -d ./logs/ EDA.robot
# OR ~/TafProject/robotws/testsuite/Paris/RRM/ST/resources/sg_radio_perf/sh
# ./to_be_run_cv328.sh
# robot --exitonfailure -V CV328/ -b debug.log -d ./logs/ EDA.robot

# copy from: 5GC002093_A05_A11_A14_D3_D6_1TC.robot

*** Settings ***
Documentation
...  contact: Nathalie.caudy@nokia.com

Library      ute_ue                   WITH NAME    ue
Library      taf.transport.ssh        WITH NAME    ssh
Library      taf.ccs.aashell          WITH NAME    cli
Library      taf.gnb.oam.coam.admin   WITH NAME    coam

Library      ../resources/pm_analyze.py          WITH NAME       pm_analyze
Library      ../../resources/swconfig_handler.py     WITH NAME     swconf
Resource     ../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource     ../../resources/sg_radio_perf/robot/preconditions.robot
Resource     ../../resources/pm_collection.robot
Resource     ../resources/keywords_EDA.robot

Suite Setup        EDA Setup Sequence
Suite Teardown     EDA Teardown Sequence

*** Variables ***
${GN_OAM_IP}=    10.14.49.161
${MeasPeriod}=    5
${gNB}=          0
${DEBUG_MODE_CONSOLE}=    True

*** Test Cases ***

TC_2UEs_checkEDA_counters
    [Documentation]     in the scf we should have
    ...    actSpatialStreamPooling = False
    ...    actFdmEnhancedScheduling = True

    AttachUE_With_Reboot    alias=UE_1      capabilities=Capa_UE_1
	Log To Console      UE_1 10.0.116.133 rebooted and attached
    # capabilities=REAL_ANDROID_UE
    AttachUE_With_Reboot    alias=UE_2      capabilities=Capa_UE_2
	Log To Console      UE_2 10.0.116.203 rebooted and attached
    TrafficAskey
    Log To Console   *** beginning of traffic

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=0
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

#    ${M55308C03002_RR1}=    Get Counter Value     counter_name=M55308C03002
#    set suite variable     ${M55308C03002_RR}   ${M55308C03002_RR1}
#    Log To Console   \n ***1 M55308C03002_RR= ${M55308C03002_RR}

    ${res}=      Collect PM Files And Get Last Period Filename
	...    oam_type=coam
	...    name=gnb_pmcounters
	...    scope=testcase

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable    ${PM_PATH}        ${res_path}
    Set Test Variable    ${PM_FILENAME}    ${res}

    Log To Console    ${PM_PATH}= ${PM_PATH}
	${pi_M55308C03002}=  pm_analyze.Get Pi Value From File
              ...  pi_dir=${PM_PATH}
              ...  pi_name=M55308C03002
              ...  file_name=${PM_FILENAME}
    log To Console     \n***2 EDA M55308C03002 value: ${pi_M55308C03002} in file ${PM_FILENAME}

    ${pi_M55308C03002_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_PATH}
    ...          pi_name=M55308C03002
    ...          file_name=${PM_FILENAME}
    ...          cell=1
	
    ${pi_M55335C03008_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_PATH}
    ...          pi_name=M55335C03008
    ...          file_name=${PM_FILENAME}
    ...          cell=1
	
    ${pi_M55335C03011_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_PATH}
    ...          pi_name=M55335C03011
    ...          file_name=${PM_FILENAME}
    ...          cell=1
	
	
    log To Console        \n in file ${PM_FILENAME}
    log To Console        \nEDA pi_M55308C03002_Cell1 value for Cell1 : ${pi_M55308C03002_Cell1}
    log To Console        \nEDA pi_M55335C03008_Cell1 value for Cell1 : ${pi_M55335C03008_Cell1}
    log To Console        \nEDA pi_M55335C03011_Cell1 value for Cell1 : ${pi_M55335C03011_Cell1}
	
	${min_3002} =    Evaluate   float(413600) * float(0.99)
	${min_3008} =    Evaluate   float(735000) * float(0.99)
	${min_3011} =    Evaluate   float(14064) * float(0.99)

	${max_3002} =    Evaluate   float(413600) * float(1.01)
	${max_3008} =    Evaluate   float(735000) * float(1.01)
	${max_3011} =    Evaluate   float(14064) * float(1.01)

	should be true
	...    ${min_3002} < ${pi_M55308C03002_Cell1} < ${max_3002}
    log To Console        \n M55308C03002 ${min_3002} < ${pi_M55308C03002_Cell1} < ${max_3002}

	should be true
	...    ${min_3008} < ${pi_M55335C03008_Cell1} < ${max_3008}
    log To Console        \n M55308C03002 ${min_3008} < ${pi_M55335C03008_Cell1} < ${max_3008}

	should be true
    ...    ${min_3011} < ${pi_M55335C03011_Cell1} < ${max_3011}
    log To Console        \n M55308C03002 ${min_3011} < ${pi_M55335C03011_Cell1} < ${max_3011}


    Log to console      \n ***** TEST IS PASS *****
	
	
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=0


*** Keywords ***
EDA Setup Sequence
    # enables to initialize the alias coam_admin
    # otherwise AliasLookupError: "Unrecognized alias: u'coam_admin'
    coam.connect to     bts_host=${GN_OAM_IP}       name=coam_admin
    Log To Console      \n *** Setup Sequence: open cnx coam_admin to 10.14.49.161 done
    coam.teardown   connection=coam_admin

EDA Teardown Sequence
    DetachUe       alias=UE_1      capabilities=Capa_UE_1
    Log To Console      \n TearDownSequence UE_1 10.0.116.133 detached
    DetachUe       alias=UE_2      capabilities=Capa_UE_2
    Log To Console      UE_2 10.0.116.203 detached
    TestSuite Basic Teardown     restore_gnb_config=True    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin
