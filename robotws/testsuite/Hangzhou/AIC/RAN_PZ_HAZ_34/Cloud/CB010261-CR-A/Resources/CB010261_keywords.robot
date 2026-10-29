*** Settings ***
Documentation
...    author: Yue 2. Liu
...    contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/cloud_analysis.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Keywords ***
Cloud Full Commission With Customized Scf
    ${Status}    ${key}   run keyword and ignore error   Cloud Get Customized Scf From Case Tag
    ${Customized_vDU_SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_VDU_SCF_Path}
    ${Customized_vCU_SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${Golden_CU_SCF_Path}
    ${Customized_SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[2]    ${False}
    #Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    Run Keyword If    ${Customized_SCF_Status}==${True}
    ...    Cloud Full Commission    cu_scf_path=${Customized_vCU_SCF_Path}    vdu_scf_path=${Customized_vDU_SCF_Path}

Cloud Get Customized Scf From Case Tag
    ${Status}    set variable    ${False}
    ${flag}    set variable    ${False}
    FOR    ${tag}    IN    @{TEST_TAGS}
        ${flag}    run keyword and return status    Should contain    ${tag}    S-
        run keyword if    ${flag}    Log to console    Case TAG:${tag}
        ${vDU_SCF_Path}    run keyword if    ${flag}    Replace String    ${Golden_VDU_SCF_Path}    .xml    _${tag}.xml
        ...           ELSE    set variable     ${Golden_VDU_SCF_Path}
        ${vCU_SCF_Path}    run keyword if    ${flag}    Replace String    ${Golden_CU_SCF_Path}    .xml    _${tag}.xml
        ...           ELSE    set variable    ${Golden_CU_SCF_Path}
        ${Status}    set variable if    ${flag}==${True}    ${True}    ${False}
        exit for loop if    ${flag}
    END
    [Return]   ${vDU_SCF_Path}   ${vCU_SCF_Path}    ${Status}
