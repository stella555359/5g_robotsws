*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot

*** Variables ***
@{enb_id}    241    38321    36721    38221
${enb_instance}     ${tl.enbs[0].instance_id}
${connection_name}    GNB_OAM
@{bts_index}    ${0}    ${1}

*** Test Cases ***
[1]commission scf to bts for Prerequisite
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Set Suite Variable    ${tl_gnb2_scf_${sw_version}}    ${sw_version}_gNB2_Golden_SCF.xml
    IF    ${enb_instance} == ${enb_id}[0] or ${enb_instance} == ${enb_id}[1]    #TL348 or #TL383
        Set Test Variable    ${scf_path}     /opt/workspace/CRT/Master/SCF_file/
    ELSE IF    ${enb_instance} == ${enb_id}[2] or ${enb_instance} == ${enb_id}[3]    #TL367 or #TL382
        Set Test Variable    ${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
    END
    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
    ...    golden_scf_name=${tl_gnb1_scf_${sw_version}}    golden_scf_name_gnb2=${tl_gnb2_scf_${sw_version}}
    check alarms and faults on multi bts
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'   collect snapshot for multi bts

*** Keywords ***
check alarms and faults on multi bts
    FOR    ${i}    IN    @{bts_index}
        connect and loop time check alarms on bts    gnb_index=${i}    connection=${connection_name}_${i}
    END

connect and loop time check alarms on bts
    [Arguments]    ${gnb_index}=${0}    ${connection}=${connection_name}_${gnb_index}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection}
    loop time check alarms on bts    gnb_index=${gnb_index}
    [Teardown]    Disconnect With BTS    connection=${connection}

loop time check alarms on bts
    [Arguments]    ${gnb_index}=${0}    ${connection}=${connection_name}_${gnb_index}
    FOR    ${per_time}    IN RANGE    ${12}
        Get and check fault id    connection=${connection}
        Sleep    10s
    END

collect snapshot for multi bts
    FOR    ${index}    IN    @{bts_index}
        collect snapshot for bts    gnb_index=${index}
    END

collect snapshot for bts
    [Arguments]    ${gnb_index}=${0}    ${connection}=${connection_name}_${gnb_index}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection}
    Save snapshot with BTS    connection=${connection}
    [Teardown]    Disconnect With BTS    connection=${connection}