*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-103502 Automation

Library     BuiltIn
Library     String
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem

Library     taf.transport.ssh       WITH NAME    csn
Library     taf.collectors.btslog   WITH NAME    btslog
Library     taf.collectors.core     WITH NAME    core
Library     taf.sbts.oam.coam.admin    WITH NAME    coam

Library     wft.py

Resource    COAM.robot
Resource    Download.robot
# Resource    LogCollection.robot

Resource    ../../common/taf_coam.robot
# Resource    ../../common/L3_Call.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Variables   ../../libraries/global_vars.py


*** Variables ***


*** Keyword ***
Common Suite Setup
    Log To Console   ${EMPTY}
    robot_common_operations.Common Suite Setup
    COAM Login

    COAM Backup SCF   file_name=new_version_scf.xml
    Set Suite Variable   ${NEW_VERSION_SCF_PATH}   ${OUTPUT_DIR}/new_version_scf.xml

    ${active_sw_version}   ${passive_sw_version}   ${planned_sw_version}   COAM Get SW Version
    ${active_sw_version}   Transfer Release SBTS00 Package   ${active_sw_version}
    ${passive_sw_version}   Transfer Release SBTS00 Package   ${passive_sw_version}
    ${version_list}   Create List   ${active_sw_version}   ${passive_sw_version}

    Set Suite Variable   ${NEW_SW_VERSION}   ${active_sw_version}
    Set Suite Variable   ${OLD_SW_VERSION}   ${passive_sw_version}

    ${isSameFPGA}   is_Same_FPGA   version_list=${version_list}
    Set Suite Variable   ${isSameFPGA}
    Run Keyword If   ${isSameFPGA}   Log To Console   FPGA Version Same. Skip To Run The Test Cases.
    Return From Keyword If   ${isSameFPGA}

    coam.rollback_software   connection=COAM   timeout=${600}
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair

    COAM Backup SCF   file_name=old_version_scf.xml
    Set Suite Variable   ${OLD_VERSION_SCF_PATH}   ${OUTPUT_DIR}/old_version_scf.xml

    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Common Suite Teardown
    Run Keyword If   ${isSameFPGA}   Log To Console   FPGA Version Same. Skip To Run The Test Cases.
    Return From Keyword If   ${isSameFPGA}

    Wait Until Keyword Succeeds   10m   1m   COAM Login

    ${active_sw_version}   ${passive_sw_version}   ${planned_sw_version}   COAM Get SW Version
    ${active_sw_version}   Transfer Release SBTS00 Package   ${active_sw_version}
    ${passive_sw_version}   Transfer Release SBTS00 Package   ${passive_sw_version}

    Run Keyword If   "${active_sw_version}"=="${NEW_SW_VERSION}" and "${passive_sw_version}"=="${OLD_SW_VERSION}"   Recovery Rollback And Update
    Run Keyword If   "${active_sw_version}"=="${OLD_SW_VERSION}" and "${passive_sw_version}"=="${NEW_SW_VERSION}"   Recovery Update

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   COAM Logout
    ...   AND
    ...   robot_common_operations.Common Suite Teardown


Recovery Rollback And Update
    coam.rollback_software   connection=COAM   timeout=${600}
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    COAM SCF Commission   filepath=${OLD_VERSION_SCF_PATH}
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


    coam.update_software   sw_package=${NEW_PACKAGE_PATH}   should_activate=${True}   timeout=${3600}   connection=COAM
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    COAM SCF Commission   filepath=${NEW_VERSION_SCF_PATH}
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Recovery Update
    Wait Until Keyword Succeeds   2x   1m    COAM SCF Commission   filepath=${OLD_VERSION_SCF_PATH}
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair

    coam.update_software   sw_package=${NEW_PACKAGE_PATH}   should_activate=${True}   timeout=${3600}   connection=COAM
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
    COAM SCF Commission   filepath=${NEW_VERSION_SCF_PATH}
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair
