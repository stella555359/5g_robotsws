*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]  Test Line Initialization And Backup
#                   Prerequisite : Not applicable
#                   Scope        : Not applicable
#
...               \nTest Case Scenario author : vincent.boulet@nokia.com
...               \nCreation Date             : 2024-09-17
...               \nModified Date             : 2025-04-30
#
#                 Version    Date       Author                          Notes
#                 0.1        FB2419     vincent.boulet@nokia.com        Creation robot for test line initialization and backup
#                 0.2        FB2420     vincent.boulet@nokia.com        Test Teardown is introduced with KW Procedure Scout Data
#                 0.3        FB2425     vincent.boulet@nokia.com        Add the pip list command and delete unused repositories
...               \n1.0      FB2509     vincent.boulet@nokia.com        Change address to 192.168.255.129 for each connection since CB011146
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                               OperatingSystem

# Resources
Resource                              ../../../resources/SWENG/robot/GenericTest.robot
Resource                              ../../../resources/SWENG/robot/Scf.robot
Resource                              ../../../resources/SWENG/robot/Tools.robot
Resource                              ../../../resources/SWENG/robot/Topology.robot

# Tags
#vbo#n/a#Force Tags                   CA_5G_SW_FR-Villarceaux    RRM    PY39    CONFIGURED    5G_RAN    RAN_5G

# Suites
Suite Setup                           Suite Setup Initialization And Backup    keep_all_data_in_file=${True}
Suite Teardown                        Suite Teardown
Test Teardown                         Test Teardown Initialization And Restore

*** Variables ***
&{TL_PARAM}                           test_name=TL_INIT_BACKUP_RESTORE
${TestSharkTool}                      MC_SHARK

# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
# Suite #
Suite Setup Initialization And Backup
    [Arguments]             ${keep_all_data_in_file}=${False}

    Dated Log                         ----Suite Setup Initialization And Backup----
    ${timestamp_suite_setup}=         DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_setup}
    #
    Dated Log                         ----/opt/wts/latest Initialization----
    ${basic_setup_backup}=            Set Variable    /opt/wts/latest/basic_setup_backup.cfg
    ${basic_setup_default}=           Set Variable    /opt/wts/latest/basic_setup_default.cfg
    ${status}   ${ret}   Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${basic_setup_backup}
    Run Keyword If   "${status}" == "PASS"
    ...    Dated Log                  > ${basic_setup_backup} is already present
    ...         ELSE    Run Keywords
    ...           Run                 rm -f /opt/wts/latest/basic_setup_*
    ...    AND    Run                 rm -f /opt/wts/latest/basic_wts*
    ...    AND    Run                 cp -f /opt/wts/latest/basic_setup.cfg ${basic_setup_backup}
    ...    AND    Dated Log           > ${basic_setup_backup} is created
    ...    AND    Run                 cp -f ${basic_setup_backup} ${basic_setup_default}
    #
    Dated Log                         ----Suite Setup From Scratch----
    Setup.Suite Setup From Scratch    automaticTeardown=${True}    keepAllUeDataInCfgFile=${keep_all_data_in_file}
    #
    Dated Log                         ----Backup Files----
    Backup.Backup Files
    #
    Dated Log                         ----Get SCF File(s)----
    ${scf_suite_backup}=              Oam.OAM Get SCF File    file=SCF_DU_backup.xml
    Set Suite Variable                ${scf_suite_backup}
    Dated Log                         > DU backup file is ${scf_suite_backup}
    Dated Log                         ------------------------------------------------------------------------------


Test Teardown Initialization And Restore
    [Arguments]             ${wts_path}=/opt/wts/latest
    ...                     ${downloads_path}=~/Downloads
    ...                     ${tmp_save_info_path}=/tmp/SAVE_INFO
    ...                     ${testline_init_results}=testline_init_results

    Dated Log                         ----Suite Teardown Initialization And Restore----
    # Not applicable #Restore Files
    Dated Log                         ----Create working directory----
    Run                               if [ -d ${tmp_save_info_path} ]; then rm -rf ${tmp_save_info_path}/*; else mkdir -p ${tmp_save_info_path}; fi
    Dated Log                         ----Create downloads directory----
    Run                               if [ -d ${downloads_path} ]; then ls -l ${downloads_path}/*; else mkdir -p ${downloads_path}; fi
    Dated Log                         ----Save SCF*_backup.xml----
    Run                               cp -f ${LOG_PATH}/SCF*_backup.xml ${tmp_save_info_path}
    Dated Log                         ----Save Status_Before_Testsuite.txt----
    Run                               cp -f ${LOG_PATH}/Status_Before_Testsuite.txt ${tmp_save_info_path}
    Dated Log                         ----Save and clean-up wts directory----
    ${basic_setup_backup}=            Set Variable    ${wts_path}/basic_setup_backup.cfg
    Run                               rm -f ${wts_path}/basic_wts*
    Run                               cp -f ${basic_setup_backup} ${wts_path}/basic_setup.cfg
    Run                               cp -f ${LOG_PATH}/*basic*.cfg ${tmp_save_info_path}
    Run                               cp -f ${wts_path}/basic_setup_*.cfg ${tmp_save_info_path}
    Run                               cp -f ${wts_path}/sosReport*.cfg ${tmp_save_info_path}
    Dated Log                         ----Save _init_.py configuration----
    # Run    /home/ute/testline_configuration/${test_line_name_dir}/__init__.py ${tmp_save_info_path}
    #
    Dated Log                         ----Save testline_init results----
    Run                               ls -lR ~/${testline_init_results} > ${tmp_save_info_path}/${testline_init_results}.txt
    Run                               cp -f ~/${testline_init_results}/logs/INFO_log.txt ${tmp_save_info_path}
    Run                               tar -cvf ${tmp_save_info_path}/${testline_init_results}.tar ~/${testline_init_results}
    Dated Log                         ----Save eth3 and eth4 configuration----
    Run                               ip addr show dev eth3 > ${tmp_save_info_path}/ip_addr_eth3.txt
    Run                               ip addr show dev eth4 > ${tmp_save_info_path}/ip_addr_eth4.txt
    Dated Log                         ----Save GNB information----
    Run                               scp toor4nsn@192.168.255.129:/ffs/run/TargetBD*xml ${tmp_save_info_path}
    Run                               scp toor4nsn@192.168.255.129:/ffs/run/swconfig.txt ${tmp_save_info_path}/gnb_swconfig.txt
    Run                               scp toor4nsn@192.168.255.129:/ffs/run/gnb_swconfig*.txt ${tmp_save_info_path}
    Run                               scp toor4nsn@192.168.255.129:/ffs/run/swpool/OAM/vendor*.xml ${tmp_save_info_path}
    Dated Log                         ----Save AP information----
    Run                               scp toor4nsn@192.168.200.129:/ffs/run/TargetBD*xml ${tmp_save_info_path}
    Run                               scp toor4nsn@192.168.200.129:/ffs/run/swconfig.txt ${tmp_save_info_path}/ap_swconfig.txt
    Run                               scp toor4nsn@192.168.200.129:/ffs/run/ap_swconfig*.txt ${tmp_save_info_path}
    Run                               scp toor4nsn@192.168.200.129:/ffs/run/simmode/iphy.xml ${tmp_save_info_path}/ap_iphy.xml
    Run                               scp toor4nsn@192.168.200.129:/ffs/run/simmode/ap_iphy*.xml ${tmp_save_info_path}
    Run                               pip list > ${tmp_save_info_path}/pip_list_taf.txt
    Run                               rm -rf ~/MN/UTE/robotlte
    #
    ${timestamp_suite_teardown}=      DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    Set Suite Variable                ${timestamp_suite_teardown}
    Dated Log                         ---------------------------------------------
    Dated Log                         > Runtime: ${timestamp_suite_setup} -> ${timestamp_suite_teardown}
    Dated Log                         ------------------------------------------------------------------------------
    #
    ${save_info_dir}=                 DateTime.Get Current Date    result_format=%Y%m%d_%H%M_SAVE_INFO_default
    Dated Log                         > Copy files into ${downloads_path}/${save_info_dir}
    Run                               cp -prv ${tmp_save_info_path} ${downloads_path}/${save_info_dir}
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Test Cases ***
CB008375_Test_Line_Initialization_And_Backup
    #vbo#n/a#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log                         ----Test initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TL_PARAM}
    Dated Log New Line                > Test name is ${param.test_name}

    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
