*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          ./resources/CB010513_common_keywords.robot

*** Test Cases ***
[1][1.0]CB0010513-SR-L_1_Check_DL_numMinPRBAlloc_with_non-BF_100Mhz_dlMimoMode_40
	[Documentation]
    [Tags]
    [Setup]    Case_Setup
	Start_BTS_Logs
	${SCF_CB010513_100Mhz}    Replace String    ${Golden_SCF_Path}    .xml    _CB010513_100Mhz.xml
	Commissioning SCF And Check On Air    scf_path=${SCF_CB010513_100Mhz}
	Stop_BTS_Logs
	Check_numMinPrbAllocDl_from_BTSLOG
    [Teardown]    Case_Teardown

[1][1.0]CB0010513-SR-L_4_Check_DL_numMinPRBAlloc_with_non-BF_80Mhz_dlMimoMode_40
	[Documentation]
    [Tags]
    [Setup]    Case_Setup
	Start_BTS_Logs
	${SCF_CB010513_80Mhz}    Replace String    ${Golden_SCF_Path}    .xml    _CB010513_80Mhz.xml
	Commissioning SCF And Check On Air    scf_path=${SCF_CB010513_80Mhz}
    Stop_BTS_Logs
	Check_numMinPrbAllocDl_from_BTSLOG
    [Teardown]    Case_Teardown

[1][1.0]CB0010513-SR-L_11_Check_DL_numMinPRBAlloc_with_non-BF_60Mhz_dlMimoMode_60
	[Documentation]
    [Tags]
    [Setup]    Case_Setup
	Start_BTS_Logs
	${SCF_CB010513_60Mhz}    Replace String    ${Golden_SCF_Path}    .xml    _CB010513_60Mhz.xml
	Commissioning SCF And Check On Air    scf_path=${SCF_CB010513_60Mhz}
    Stop_BTS_Logs
	Check_numMinPrbAllocDl_from_BTSLOG
    [Teardown]    Case_Teardown
