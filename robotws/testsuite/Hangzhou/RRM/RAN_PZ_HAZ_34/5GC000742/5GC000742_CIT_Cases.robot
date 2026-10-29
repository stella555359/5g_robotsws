*** Settings ***
Documentation    author: Cheng Jiajing  Weng Hongyang
...               contact: jiajing.1.cheng@nokia-sbell.com  hongyang.weng@nokia-sbell.com
...               squad group: SG_01
...               feature : 5GC000742-B
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    TestSuite.Init
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   TestSuite.Destroy
Force Tags
...    PY36
Resource          ../5GC000742/Resources/5GC000742_Resources.robot


*** Test Cases ***
[1][2.0] 5GC000742_B_017_2_Support of generic slot format_semiStatic_u1_d4
    [Tags]    5GC000742_B    CIT_21B    CRT_22R1      CIT_21A    CRT_TRUNK    CRT_22R4
    [Setup]           Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7305,7523
                      ...          AND    TestCase.CommonStart
    [Teardown]        Run Keywords    TestCase.CommonStop
    TC.5GC000742_B_017_2_Support of generic slot format_semiStatic_u1_d4


#[1][2.0] 5GC000742_B_006_Dynamic reconfiguration of SA cell in served cell information
#    [Tags]    5GC000742_B    CRT_19B    CRT_20A
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    TC.5GC000742_B_006_Dynamic reconfiguration of SA cell in served cell information



*** Keywords ***
TestSuite.Init
    Setup My Suite
TestSuite.Destroy
    TestSuilt.Destroy