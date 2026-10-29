*** Settings ***
Suite Setup       8748 SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Variables    ../../TestData/CB008748_A_variables.py
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource
...  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/ALD/General_SiSo_ALD_Configuration_Management_ALD_site_commissioning.robot

Documentation
...   author: Tong Chen
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02
...   Feature CB008748_A

Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CIT
...   PY39

*** Test Cases ***
[1]General_SiSo_Commissioning_BTS_Template_Commissioning
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
    [Timeout]   2h
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    set test variable    ${execution_env_type}    DEBUG
    General_SiSo_ALD_Configuration_Management_ALD_site_commissioning
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}

*** Keywords ***
SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ...        ru_username=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
        ...        ru_password=${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        Check startup runtime and soap file in ru log    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

8748 SISO Coam Suite Setup
    SISO Coam Suite Setup
    ${version}     get software version
    Load Case SCF and Commission SCF for 8748       scf_file=commissionings/HGZ/7_5_UTE5G402T980/SCF_${version}_977.xml

Load Case SCF and Commission SCF for 8748
    [Arguments]    ${scf_file}
    Selenium Login And Disable Screen Lock
    log to console  ${CURDIR}
    ${SCF_PATH}     Get Substring  ${CURDIR}  0  -69
    log to console    ${SCF_PATH}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_file}
    Wait Until Keyword Succeeds    15min    30s    Verify all cells should be onair

get software version
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    String.Get Substring    ${current_version['Active']}    0    8
    [Return]     ${stream}
