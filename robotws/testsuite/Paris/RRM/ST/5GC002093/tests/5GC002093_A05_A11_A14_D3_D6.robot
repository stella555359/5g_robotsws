#(py27_new) localuser@iv-ps328:~/MN/UTE/robotws/testsuite/Paris/RRM/ST/5GC002093/tests$
# ~/MN/UTE/robotws/testsuite/Paris/RRM/ST/5GC002093/tests/
# robot --dryr -V /home/localuser/testline_configuration/7_20_UTE5GCLASSSV328/
#-b debug.log -d ~/CV328_ExecLogs_Feat2093/
# OR cd ~/MN/UTE/robotws/testsuite/Paris/RRM/ST/resources/sg_radio_perf/sh
# ./to_be_run_CV328_CIT.sh SBTS00_ENB_9999_230306_000014
# ./to_be_run_CV328_CRT.sh SBTS23R2_ENB_0000_000022_000000
# obsolete robot -t "TryAttach1" -V CV328/ -b debug.log -d ./logs/
# robot --exitonfailure -V /home/localuser/testline_configuration/7_20_UTE5GCLASSSV328/
#-b debug.log -d ~/CV328_ExecLogs_Feat2093/ 5GC002093_A05_A11_A14_D3_D6.robot

*** Settings ***
Documentation
...  contact: Nathalie.caudy@nokia.com

Library      ute_ue                    WITH NAME       ue
Library      taf.transport.ssh         WITH NAME       ssh
Library      taf.ccs.aashell           WITH NAME     cli
Library      taf.sbts.oam.coam.admin   WITH NAME   coam

Library      ../../resources/pm_analyze.py          WITH NAME      pm_analyze
Library      ../../resources/swconfig_handler.py     WITH NAME     swconf

Variables         ../../../../resources/ST/python/custom.py

Resource     ../../resources/sg_radio_perf/robot/Keywords_gNB.robot
Resource     ../../resources/sg_radio_perf/robot/preconditions.robot
Resource     ../../resources/pm_collection.robot
Resource     ../resources/keywords_5GC002093.robot

#Force Tags      CA_RAN_PZ_NPS    QCD_MN_RAN   QCP_RAN_ST    SBTS00   SBTS22R4    SBTS22R3

Suite Setup        Setup Sequence
Suite Teardown     Teardown Sequence

*** Variables ***
${GN_OAM_IP}=    10.14.49.161
${gNB_id}=       0
${expected_gain} =   1.4
${MeasPeriod}=    5
${gNB}=          0
${DEBUG_MODE_CONSOLE}=    True
${QC_A_05}=     False

*** Test Cases ***
[1][1.0] 5GC002093_A_05_Functionnal_Test_DL_MIMO4x4_3cells_2UE_MU_MIMO_60MHz_SemiStatic_3_7_cell2_cmW
    [Setup]	Get Scout Bts Name
    [Teardown]  Set Scout Confid Id
    SetFlagOnSwConfig      flag=0x580220      value=0
    log       \n*** SetFlagOnSwConfig RRobin done      console=${DEBUG_MODE_CONSOLE}

#    RebootUE       ue=${tl.ues[0]}
#    Log To Console  UE_1 reboot done
    AttachUE       alias=UE_1      capabilities=Capa_UE_1
    #AttachUE_With_Reboot    alias=UE_1      capabilities=Capa_UE_1
    Log To Console      UE_1 10.0.116.133 attached

    #RebootUE       ue=${tl.ues[1]}
    #Log To Console  UE_2 reboot done
    AttachUE       alias=UE_2      capabilities=Capa_UE_2
    #AttachUE_With_Reboot    alias=UE_2      capabilities=Capa_UE_2
    #AttachUE    alias=UE_2      capabilities=Capa_UE_2
    Log To Console      UE_2 10.0.116.203 attached

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=10
    TrafficAskey_450M
    Log To Console   *** after Traffic 1 - 680MBps
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

#    ${M55308C17001_RR1}=    Get Counter Value     counter_name=M55308C17001
#    set suite variable     ${M55308C17001_RR}   ${M55308C17001_RR1}
#    Log To Console   \n M55308C17001_RR= ${M55308C17001_RR}
#    Log To Console   \n M55308C17001_RR shouldbe around 380000

    ${M55308C10001_RR1}=    Get Counter Value     counter_name=M55308C10001
    set suite variable     ${M55308C10001_RR}   ${M55308C10001_RR1}
    Log To Console   \n M55308C10001_RR= ${M55308C10001_RR}
    Log To Console   \n M55308C10001_RR shouldbe around 63000000

    Should Be True
    ...  61500000 < ${M55308C10001_RR}
    ...  \n M55308C10001_RR has not reached the expected value for 2 UEs having traffic, Probably only 1 UE is having traffic


    #added
    #${M55301C10004_RR1}=    Get Counter Value     counter_name=M55301C10004
    #Log To Console   \n M55301C10004_RR1= ${M55301C10004_RR1}
    #Log To Console   \n M55301C10004 should be around 380000

    #Should Be True
    #...  340000 < ${M55308C17001_RR}
    #...  \n M55308C17001_RR has not reached the expected value for 2 UEs having traffic, Probably only 1 UE is having traffic

    ${M55601C00002}=    Get Counter Value     counter_name=M55601C00002
    Log To Console   \n M55601C00002= ${M55601C00002}
    Should Be Equal       ${M55601C00002}     ${900}

    DetachUe_noRequireUE       alias=UE_1
    DetachUe_noRequireUE       alias=UE_2
    Log To Console   *** End of Part 1 the 2UEs are detached

    SetFlagOnSwConfig      flag=0x580220      value=1
    Log To Console   \n *** PART2 SetFlagOnSwConfig Metric Based done

    AttachUE_noRequireUE       alias=UE_1
    Log To Console      \n part2 UE_1 10.0.116.133 attached

    AttachUE_noRequireUE       alias=UE_2
    Log To Console      UE_2 10.0.116.203 attached

    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=15
    TrafficAskey
    WaitForNextMeasPeriod      ${gNB}         ${MeasPeriod}    additional_time_sec=70

#    ${M55308C17001_MB1}=    Get Counter Value     counter_name=M55308C17001
#    set suite variable     ${M55308C17001_MB}   ${M55308C17001_MB1}
#    Log To Console   \n M55308C17001_MB1= ${M55308C17001_MB1}

    ${M55308C10001_MB1}=    Get Counter Value     counter_name=M55308C10001
    set suite variable     ${M55308C10001_MB}   ${M55308C10001_MB1}
    Log To Console   \n M55308C10001_MB1= ${M55308C10001_MB1}


    #added
    #${M55301C10004_MB1}=    Get Counter Value     counter_name=M55301C10004
    #Log To Console   \n M55301C10004_MB1= ${M55301C10004_MB1}
    #Log To Console   \n should be around 576000

    ${M55601C00002_MB1}=    Get Counter Value     counter_name=M55601C00002
    Log To Console   \n M55601C00002_MB1= ${M55601C00002_MB1}
    Should Be Equal       ${M55601C00002_MB1}     ${900}

    ${cpt1_MB_mimimum_value} =    Evaluate    float(${M55308C10001_RR}) * float(${expected_gain})
    Should Be True
    ...  0 < ${cpt1_MB_mimimum_value} < ${M55308C10001_MB}
    ...  The gain between RR and MB is fewer than ${expected_gain}

    ${QC_A_05_1}=     Set Variable     ${True}
    set suite variable     ${QC_A_05}  ${QC_A_05_1}

    ###### pour EDA M55301C10001 M55301C10002 M55301C10003 M55301C10004

    ${pi_M55301C10004}=  pm_analyze.Get Pi Value From File
              ...  pi_dir=${PM_PATH}
              ...  pi_name=M55301C10004
              ...  file_name=${PM_FILENAME}
    log To Console     \n*** EDA M55301C10004 value: ${pi_M55301C10004} in file ${PM_FILENAME}


    ${pi_M55301C10001_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_pATH}
    ...          pi_name=M55301C10001
    ...          file_name=${PM_FILENAME}
    ...          cell=1
    log To Console        \nEDA pi_M55301C10001_Cell1 value for Cell1 : ${pi_M55301C10001_Cell1}

    ${pi_M55301C10002_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_pATH}
    ...          pi_name=M55301C10002
    ...          file_name=${PM_FILENAME}
    ...          cell=1
    log To Console        \nEDA pi_M55301C10002_Cell1 value for Cell1 : ${pi_M55301C10002_Cell1}

    ${pi_M55301C10003_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_pATH}
    ...          pi_name=M55301C10003
    ...          file_name=${PM_FILENAME}
    ...          cell=1
    log To Console        \nEDA pi_M55301C10003_Cell1 value for Cell1 : ${pi_M55301C10003_Cell1}

    ${pi_M55301C10004_Cell1}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_pATH}
    ...          pi_name=M55301C10004
    ...          file_name=${PM_FILENAME}
    ...          cell=1
    log To Console        \nEDA pi_M55301C10004_Cell1 value for Cell1 : ${pi_M55301C10004_Cell1}

    ${pi_M55301C10004_Cell2}   pm_analyze.get_pi_value_for_one_cell_from_file
    ...          pi_dir=${PM_pATH}
    ...          pi_name=M55301C10004
    ...          file_name=${PM_FILENAME}
    ...          cell=2
    log To Console        \nEDA pi_M55301C10004_Cell2 value for Cell2 : ${pi_M55301C10004_Cell2}


    ${cpt_AllRanks} =    Evaluate
    ...    int(${pi_M55301C10001_Cell1}) + int(${pi_M55301C10002_Cell1}) + int(${pi_M55301C10003_Cell1}) + int(${pi_M55301C10004_Cell1})
    log To Console        \nEDA cpt_AllRanks for Cell1 : ${cpt_AllRanks}

    ${percentage_Rank4} =    Evaluate   float(${pi_M55301C10004_Cell1}) / float(${cpt_AllRanks}) * float(100)
    log To Console        \nEDA percentage_Rank4 for Cell1 : ${percentage_Rank4}

    should be true
    ...    99 < ${percentage_Rank4}
    ...    less than 99% of the PDSCH transmissions are with rank4

    Log to console      ${percentage_Rank4} of the PDSCH transmissions are with rank4
    Log to console      ***** TEST IS PASS *****


[1][1.0] 5GC002093_A_11_Performance_Test_DL_MIMO4x4_3cells_2UE_MU_MIMO_60MHz_SemiStatic_3_7_cell2_cmW
    [Setup]	Get Scout Bts Name
    [Teardown]  Set Scout Confid Id
    Should Be True     ${QC_A_05} == True


[1][1.0] 5GC002093_A_14_KPI_Test_DL_MIMO4x4_3cells_2UE_MU_MIMO_60MHz_SemiStatic_3_7_cell2_cmW
    [Setup]	Get Scout Bts Name
    [Teardown]  Set Scout Confid Id
    Should Be True     ${QC_A_05} == True


[1][1.0] 5GC002093_D_3_Functionnal_Test_DL_MIMO4x4_3cells_2UE_MU_MIMO_capa_100cell2_cmW
    [Setup]	Get Scout Bts Name
    [Teardown]  Set Scout Confid Id
    Should Be True     ${QC_A_05} == True


[1][1.0] 5GC002093_D_6_Performance_Test_DL_MIMO4x4_3cells_2UE_MU_MIMO_capa_100cell2_cmW
    [Setup]	Get Scout Bts Name
    [Teardown]  Set Scout Confid Id
    Should Be True     ${QC_A_05} == True


*** Keywords ***
Run Json Macro
    [Documentation]    Connect to pc ue of the first UE,
    ...                and run the "0_CV328_json_2RUs_172.22.8.xxx right" macro.
    ...                The macro must be present in the MobaXterm macro list.

    ${pc_ue_cnx}    ssh.connect_to
    ...    ${tl.ues[0].ssh_connection_details.addr}
    ...    ${tl.ues[0].ssh_connection_details.username}
    ...    ${tl.ues[0].ssh_connection_details.password}
    ...    alias=pcue_alias

    ${cmd}    Set Variable
    ...    "/cygdrive/c/Program Files (x86)/Mobatek/MobaXterm/MobaXterm.exe" -exitwhendone -runmacro "0_CV328_json_2RUs_172.22.8.xxx right"

    Log To Console    \n Running Macro "0_CV328_json_2RUs_172.22.8.xxx right"...
    ${res}=    ssh.Execute   ${cmd}    connection=${pc_ue_cnx}
    ssh.disconnect  connection=${pc_ue_cnx}


Setup Sequence
    # enables to initialize the alias coam_admin
    # otherwise AliasLookupError: "Unrecognized alias: u'coam_admin'
    #Run Json Macro
    coam.connect to     bts_host=${GN_OAM_IP}       name=coam_admin
    Log To Console      \n *** Setup Sequence: open cnx coam_admin to 10.14.49.161 done
    Setup Testline Suite Variables
    Log To Console      \n After SetupTestlineSuiteVariables gnb_id ${gnb_id}
    TestSuite Basic PreConditions     archive_gnb_config=${False}   archive_type=all   gnb=${gnb_id}
    Log To Console      \n AfterTestSuite BasicPreConditions

Teardown Sequence
    Run Keyword And Warn On Failure    DetachUe_noRequireUE    alias=UE_1
    Log To Console      \n TearDownSequence UE_1 10.0.116.133 detached
    Run Keyword And Warn On Failure    DetachUe_noRequireUE    alias=UE_2
    Log To Console      UE_2 10.0.116.203 detached
    TestSuite Basic Teardown     restore_gnb_config=False    restore_type=scf
    Keywords_gNB.Teardown cOAM Session with alias    alias=coam_admin

