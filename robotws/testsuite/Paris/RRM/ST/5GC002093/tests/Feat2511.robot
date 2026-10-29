#(py27_new) localuser@iv-ps328:~/MN/UTE/robotws/testsuite/Paris/RRM/ST/5GC002093/tests$
# ~/MN/UTE/robotws/testsuite/Paris/RRM/ST/5GC002093/tests/
# robot --dryr -V /home/localuser/testline_configuration/7_20_UTE5GCLASSSV328/
# -b debug.log -d ~/CV328_ExecLogs_Feat2511/ Feat2511.robot
# robot --exitonfailure -V /home/localuser/testline_configuration/7_20_UTE5GCLASSSV328/
# -b debug.log -d ~/CV328_ExecLogs_Feat2511/ Feat2511.robot

*** Settings ***
Documentation
...  contact: Nathalie.caudy@nokia.com

Library      ute_ue                    WITH NAME   ue
Library      taf.transport.ssh         WITH NAME   ssh
Library      taf.ccs.aashell           WITH NAME   cli
Library      taf.sbts.oam.coam.admin   WITH NAME   coam
Library      ../../resources/pm_analyze.py          WITH NAME    pm_analyze
Library      ../../resources/swconfig_handler.py    WITH NAME    swconf

Variables         ../../../../resources/ST/python/custom.py

Resource     ../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource     ../../resources/sg_radio_perf/robot/preconditions.robot
Resource     ../../resources/pm_collection.robot
Resource     ../resources/keywords_5GC002093.robot

Force Tags      CA_RAN_PZ_NPS    QCD_MN_RAN   QCP_RAN_ST    SBTS00   SBTS22R4    SBTS22R3

Suite Setup        Setup Sequence
Suite Teardown     Teardown Sequence

*** Variables ***
${GN_OAM_IP}=    10.14.49.161
${MeasPeriod}=    5
${gNB}=          0
${DEBUG_MODE_CONSOLE}=    True

*** Test Cases ***
Test_Feat2511_a
    Recommission actLoadCsiPeriodicity    p_value=false      should_activate=True
    Recommission csiReportPeriodicity     p_value=slots320   should_activate=True
    Log To Console      \n*** beforeAttachUEs
    AttachUE_With_Reboot    alias=UE_1      capabilities=Capa_UE_1
    Log To Console      UE_1 10.0.116.133 attached
    AttachUE_With_Reboot    alias=UE_2      capabilities=Capa_UE_2
    Log To Console      UE_2 10.0.116.203 attached
    Log To Console   *** beginning of traffic
    TrafficAskey_720s

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=0
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

    set suite variable     ${sumOfM55301C200xx}    0
    KW Counter Sum
    log To Console        \n in TC Feat2511 case 1 sumOfM55301C200xx value for Cell1 : ${sumOfM55301C200xx}
    log To Console        \n should be 3750
    #Should Be Equal
    #...   ${sumOfM55301C200xx}     ${3750}
    #...   log To Console    The sum of M55301C200xx is ${sumOfM55301C200xx}, different from 3750

    DetachUe_noRequireUE       alias=UE_1
    Log To Console      \n  UE_1 10.0.116.133 detached
    DetachUe_noRequireUE       alias=UE_2
    Log To Console      UE_2 10.0.116.203 detached


Test_Feat2511_b
    #Recommission actLoadCsiPeriodicity    p_value=false      should_activate=False
    Recommission csiReportPeriodicity     p_value=slots40   should_activate=True
    Log To Console      \n*** beforeAttachUEs 2
    #AttachUE_noRequireUE    alias=UE_1
    AttachUE_With_Reboot    alias=UE_1      capabilities=Capa_UE_1
	Log To Console      UE_1 10.0.116.133 attached
    AttachUE_With_Reboot    alias=UE_2      capabilities=Capa_UE_2
    #AttachUE_noRequireUE    alias=UE_2
    Log To Console      UE_2 10.0.116.203 attached
    Log To Console   *** beginning of traffic 2

    TrafficAskey_720s

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=0
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

    set suite variable     ${sumOfM55301C200xx}    0
    KW Counter Sum
    log To Console        \n in TC Feat2511 case 2 sumOfM55301C200xx value for Cell1 : ${sumOfM55301C200xx}
    log To Console    The sum of M55301C200xx should be 30000
#    Should Be Equal
#    ...   ${sumOfM55301C200xx}     ${30000}
#    ...   log To Console    The sum of M55301C200xx is ${sumOfM55301C200xx}, different from 30000

    DetachUe_noRequireUE       alias=UE_1
    Log To Console      \n  UE_1 10.0.116.133 detached
    DetachUe_noRequireUE       alias=UE_2
    Log To Console      UE_2 10.0.116.203 detached


Test_Feat2511_c
    Recommission actLoadCsiPeriodicity    p_value=true      should_activate=True
    #Recommission csiReportPeriodicity     p_value=slots40   should_activate=True
    Log To Console      \n*** beforeAttachUEs 3
    #AttachUE_noRequireUE    alias=UE_1
    AttachUE_With_Reboot    alias=UE_1      capabilities=Capa_UE_1
    Log To Console      UE_1 10.0.116.133 attached
    AttachUE_With_Reboot    alias=UE_2      capabilities=Capa_UE_2
    #AttachUE_noRequireUE    alias=UE_2
    Log To Console      UE_2 10.0.116.203 attached
    Log To Console   *** beginning of traffic 3

    TrafficAskey_720s

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=0
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

    set suite variable     ${sumOfM55301C200xx}    0
    KW Counter Sum
    log To Console        \n in TC Feat2511 case 3 sumOfM55301C200xx value for Cell1 : ${sumOfM55301C200xx}

    Should Be Equal
    ...   ${sumOfM55301C200xx}     ${30000}
    ...   log To Console    The sum of M55301C200xx is ${sumOfM55301C200xx}, different from 30000


*** Keywords ***
KW Counter Sum
    ${res}=      Collect PM Files And Get Last Period Filename
    ...    oam_type=sbts
    ...    name=gnb_pmcounters
    ...    scope=testcase

    ${res_path}=    set variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/gnb_pmcounters
    Set Test Variable    ${PM_PATH}        ${res_path}
    Set Test Variable    ${PM_FILENAME}    ${res}
    log To Console        \n counters path: ${PM_PATH}
    log To Console        \n in file ${PM_FILENAME}
    Set Test Variable    ${l_sumOfM55301C200xx}        0

    FOR    ${index}    IN RANGE    20     36
        ${counter}=    Set Variable   M55301C200${index}
        ${pi_M55301C200XX_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
        ...          pi_dir=${PM_PATH}
        ...          pi_name=${counter}
        ...          file_name=${PM_FILENAME}
        ...          cell=1
        log To Console        \n ${counter} value for Cell1 : ${pi_M55301C200XX_Cell1}
        ${l_sumOfM55301C200xx} =    Evaluate   ${l_sumOfM55301C200xx} + ${pi_M55301C200XX_Cell1}
    END
    set suite variable     ${sumOfM55301C200xx}    ${l_sumOfM55301C200xx}
    log To Console        \nin keyword sumOfM55301C200xx value for Cell1 : ${sumOfM55301C200xx}

Recommission actLoadCsiPeriodicity
    [Arguments]         ${p_value}=false     ${cellgrp}=0     ${gNB}=0    ${connection}=coam_admin    ${should_activate}=True
    # set the DST_NAME
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELLGRP-${cellgrp}
    Log To Console   \n in "Recommission actLoadCsiPeriodicity"
    Log To Console   dist_name= ${name}
    Log To Console   actLoadCsiPeriodicity value=${p_value}

    coam.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=actLoadCsiPeriodicity
    ...      operation=update
    ...      value=${p_value}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=${should_activate}
    ...      connection=${connection}
    sleep                 2s

Recommission csiReportPeriodicity
    [Arguments]         ${p_value}=slots320     ${cell}=1     ${gNB}=0    ${connection}=coam_admin    ${should_activate}=True
    # set the DST_NAME
    ${name}=      set variable      MRBTS-${MRBTS_NB[${gNB}]}/NRBTS-${NRBTS_NB[${gNB}]}/NRCELL-${cell}
    # parameter correponds to the list_name periodicCsiAcquisition
    # value corresponds to the parameter name and value: csiReportPeriodicity slots320
    ${p_dict}=    Create Dictionary    csiReportPeriodicity=${p_value}

    ${p_list}=    Create List    ${p_dict}
    Log To Console    p_dict = ${p_dict}
    Log To Console    p_list = ${p_list}

    coam.perform_parameter_recommissioning
    ...      dist_name=${name}
    ...      parameter=periodicCsiAcquisition
    ...      operation=update
    ...      value=${p_list}
    ...      skip_parameter_relation_errors=True
    ...      should_activate=${should_activate}
    ...      connection=${connection}
    sleep                 2s


Setup Sequence
    # enables to initialize the alias coam_admin
    # otherwise AliasLookupError: "Unrecognized alias: u'coam_admin'
    coam.connect to     bts_host=${GN_OAM_IP}       name=coam_admin
    Log To Console      \n *** Setup Sequence: open cnx coam_admin to 10.14.49.161 done
    Setup Testline Suite Variables
#    TestSuite Basic PreConditions     archive_gnb_config=${True}   archive_type=scf   gnb=${gnb_id}


Teardown Sequence
    Log To Console      in the Teardown Sequence
    Recommission actLoadCsiPeriodicity    p_value=true      should_activate=True
    Recommission csiReportPeriodicity     p_value=slots320   should_activate=True
    DetachUe       alias=UE_1      capabilities=Capa_UE_1
    Log To Console      \n TearDownSequence UE_1 10.0.116.133 detached
    DetachUe       alias=UE_2      capabilities=Capa_UE_2
    Log To Console      UE_2 10.0.116.203 detached
    TestSuite Basic Teardown     restore_gnb_config=False    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin