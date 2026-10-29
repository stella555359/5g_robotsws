*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Resource    ./WEBEM.robot
Resource    ./ModalView.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables   ../../libraries/global_vars.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

Resource    ../CaseResource/001_Create_Plan_Copy.robot
Resource    ../CaseResource/002_Create_Plan_Multiple.robot
Resource    ../CaseResource/003_Create_Plan_And_Backup.robot
Resource    ../CaseResource/004_Load_SCF_And_Edit.robot
Resource    ../CaseResource/005_Edit_Activate_Plan.robot
Resource    ../CaseResource/006_Edit_Inactivate_Plan_SCF.robot
Resource    ../CaseResource/009_Automatically_Commission_Detected_HW.robot
Resource    ../CaseResource/010_Create_Plan_In_CW_And_Switch_PE_Edit.robot
Resource    ../CaseResource/011_Create_Plan_In_PE_And_Switch_CW_Edit.robot
Resource    ../CaseResource/012_Create_Plan_In_Site_View.robot
Resource    ../CaseResource/013_Create_Plan_In_Modal_View.robot
Resource    ../CaseResource/014_Create_Plan_With_48_Cells.robot
Resource    ../CaseResource/015_Create_Plan_With_Default_Values_No_Relation_Errors.robot
Resource    ../CaseResource/016_Create_Plan_With_Minimal_Relation_Errors.robot
Resource    ../CaseResource/017_Cell_Addtion_Deletion.robot
Resource    ../CaseResource/018_Cell_Configuring_multiple_CC.robot
Resource    ../CaseResource/019_RF_Addition_For_New_Cell.robot

*** Variables ***
${display}   ${False}

*** Keyword ***
Common Setup
    Log To Console   ${EMPTY}
    Set Suite Variable    ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${MO_NAME}    MRBTS-${BTS_ID}
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    Run Keyword And Ignore Error   Check Extra Reset From Blackbox
    # Set QC Instance ID Test Tag
    ${driver}   COAM WEBUI Login   display=${display}
    Set Suite Variable   ${driver}
    COAM WEBUI Whether Close Start Up View Window
    COAM WEBUI Save BTS Configuration

Common Teardown
    Run Keyword And Ignore Error   Capature Sreenshot COAM   file_dir=${OUTPUT_DIR}
    Run Keyword And Ignore Error   COAM WEBUI Logout   display=${display}
    Check Extra Reset From Blackbox
    CI_interface.Common Case Teardown

Set QC Instance ID Test Tag
    COAM Login
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}
    [Teardown]   COAM Logout
