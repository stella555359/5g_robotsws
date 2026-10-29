*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace check_gnb_state.robot
Resource         ./../common_setup_teardown.robot
*** Variables ***
${SCF_PATH}    ${CURDIR}/config
*** Test Cases ***
Test Case Recover Testline
    Recover Testline
*** Keywords ***
Recover Testline
    #Suite Setup Update GNB    log=${False}
    Get All Testline Information And Set Suite Variable
    Set Suite Variable    ${RRU_TYPE}    AEQE
    Suite Setup Copy WTS Config Files From QT
    Send Swconfig for GNB    ${gnb_swconfig_file}
    Send Swconfig for AP    ${ap_swconfig_file}
    Modify IPHY File Version By Airphone Automatically And Send To Airphone    ${ap_iphy_file}
    Full Commission With SCF File    ${gnb_scf_file}
#    Reboot TL And Check Configured

Full Commission With SCF File
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning，please use the scf with full configuration saved.
    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${scf_file}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_scf_path}
    ${scf_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_scf_path}    ${scf_file}
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    Modify File Parameter    ${scf_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify VlanId In SCF File    ${scf_path}
    ${new_scf_path}    Migration SCF To New Release    ${scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
#    COAM.Setup Admin
#    COAM.Perform Commissioning
#    ...    bts_id=${bts_id[0]}
#    ...    scf_file=${new_scf_path}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=300
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown