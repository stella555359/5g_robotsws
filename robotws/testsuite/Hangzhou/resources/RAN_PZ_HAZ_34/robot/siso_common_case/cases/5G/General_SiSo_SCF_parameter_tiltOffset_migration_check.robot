*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/scf_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_SCF_parameter_tiltOffset_migration_check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check migration check tiltOffset parameter
    ...    used in 5GC001991-D feature to realize electric tilt.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${frame_structure}=1116_3ms_GP1_A5    ${band}=100    ${prach_index}=148    ${actBeamforming}=true
    ...    ${basicBeamSet}=beamSet_6_2    ${numberOfTransmittedSsBlocks}=8 beams    ${tiltOffset}=0
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${status}  run keyword and ignore error  Modify_Band_Frame_Structure  frame_structure=${frame_structure}
    ...    band=${band}    prach_index=${prach_index}
    run keyword if  '${status[0]}'=='FAIL'  fail   not all frame structure pass
    ${scf_file_update_path}  Modify beamSet Parameters via SCF    actBeamforming=${actBeamforming}    basicBeamSet=${basicBeamSet}
    ...    numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}    tiltOffset=${tiltOffset}
    COAM Commission with scf file    scf_file_path=${scf_file_update_path}    timeout=600
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4598
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
