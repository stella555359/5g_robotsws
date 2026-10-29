*** Settings ***
Suite Setup           SuiteSetup
Suite Teardown        SuiteTearDown

Force Tags            5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED  SBTS00

Resource           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009407/Resource/CB009407_Resource.robot

*** Variables ***

*** Test Cases ***
[1]CB009407-A_10_MicroDTX_interwork_with_CB008238
    [Documentation]  The purpose of this test case is to verify activation micro-DTX interworking with CB008238
    [Tags]   Trunk_CRT
    [Timeout]
    [Setup]    TestCase.Start
    [Teardown]  TestCase.Stop
    TC.CB009407-A_10_MicroDTX_interwork_with_CB008238

[1]CB009407-A_03_MicroDTX_deactivate
    [Documentation]  The purpose of this test case is to verify deactivation micro-DTX feature on mRRH
    [Tags]   Trunk_CRT
    [Timeout]
    [Setup]    TestCase.Start
    [Teardown]  TestCase.Stop
    TC.CB009407-A_03_MicroDTX_deactivate


*** Keywords ***
SuiteSetup
#    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    gNB.FormatBTSID
#    COAM_WebEM.Login
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{Active_SW_version}    string.split string    string=&{version}[Active]
#    set suite variable    ${Active_SW_version}
#    @{result}    string.split string    ${Active_SW_version}    separator=_
#    ${stream}     convert to string    @{result}[-5]
    ${version}    Basic.GetStreamAndVersion
    log    ${version}
    set suite variable    ${sbts_version}   ${version[1]}
    ${stream}   ${subversion}    Split String   string=${version[1]}   separator=_     max_split=1
#    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${stream}
#    COAM_Admin.Logout
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/SCF_CB009407.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr

SuiteTearDown
    ${SCF}    set variable if    "${stream}"=="SBTS24R2"    SCF_SBTS24R2.xml    SCF_SBTS00.xml
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${SCF}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    TestSuilt.Stop