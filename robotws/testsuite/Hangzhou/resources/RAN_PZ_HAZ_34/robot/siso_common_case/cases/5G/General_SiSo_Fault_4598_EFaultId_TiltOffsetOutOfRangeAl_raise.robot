*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
General_SiSo_Fault_4598_EFaultId_TiltOffsetOutOfRangeAl_raise
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check If commissioned NRCELL.beamSet.tiltOffset exceeds the Radio’s
    ...    supported steering range, BTS raises alarm with fault 4598: EFaultId_TiltOffsetOutOfRangeAl
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${frame_structure}=1116_3ms_GP1_A5    ${band}=100    ${prach_index}=148    ${actBeamforming}=true
    ...    ${basicBeamSet}=beamSet_5_3   ${numberOfTransmittedSsBlocks}=8 beams    ${tiltOffset}=5
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${status}  run keyword and ignore error  Modify_Band_Frame_Structure  frame_structure=${frame_structure}
    ...    band=${band}    prach_index=${prach_index}
    run keyword if  '${status[0]}'=='FAIL'  fail   not all frame structure pass
    ${modify_params}  Get beamSet Parameters modify parameters list    actBeamforming=${actBeamforming}
    ...    basicBeamSet=${basicBeamSet}    numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}
    Modify Parameters On Webem    modify_params=${modify_params}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Tilt Offset    abbr=tiltOffset    new_value=${tiltOffset}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4598
    [Teardown]    Run keywords    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND   Selenium Logout And Close Browser
