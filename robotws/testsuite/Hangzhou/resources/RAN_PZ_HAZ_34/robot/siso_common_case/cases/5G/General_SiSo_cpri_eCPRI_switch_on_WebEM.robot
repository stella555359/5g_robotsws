*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
*** Variables ***

*** Keywords ***
General_SiSo_cpri_eCPRI_switch_on_WebEM
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify remote update of RU from CPRI to eCRPI fronthaul
    ...    protocol type via WebEM interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 26.02.2021 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=${1}  ${switch_to_radio_protocol}=ECPRI
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    ${5793_SCF}   run keyword if    '${radio_protocol_temp}'=='CPRI'    Replace String    ${Case_SCF_Path}    .xml    _5793_CPRI.xml
    ...           ELSE    Replace String    ${Case_SCF_Path}    .xml    _5793_eCPRI.xml
    Commissioning SCF And Check On Air      scf_path=${5793_SCF}
    ${cell_list}  create list  ${cell_id}
    ${current_pkg}   Download SW  SW=${Active_SW_version}
    run keyword if    '${radio_protocol_temp}'=='${switch_to_radio_protocol}'    Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
    run keyword and ignore error   Get UE From Init File and Make call  cell_list=${cell_list}
    Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
    run keyword and ignore error   Get UE From Init File and Make call  cell_list=${cell_list}
    [Teardown]  run keywords  Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}    AND
    ...    delete Downloaded    ${current_pkg}
