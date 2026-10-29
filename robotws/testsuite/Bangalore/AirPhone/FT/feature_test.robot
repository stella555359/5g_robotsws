*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This Suite Contains Feature Test Cases Tags
                 ...              :Drafted,30.05.2025,vadivelan.manickavasagam@nokia.com

Library    BuiltIn
Library    String
Library    OperatingSystem
Library    ute_wtssim
Library    Collections
Library    DateTime
Library    Process
Library    taf.transport.ssh  WITH NAME  SSH
Library    taf.config.scf   WITH NAME      scf
Library    taf.wts.runner    WITH NAME    wtsrunner


Suite Setup       Common Optimized FT Suite Setup
Suite Teardown    Common FT Suite Teardown

*** Variables ***
${DEAFAULT_TOPOLOGY}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
${DEAFAULT_LOGPATH}    /home/ute/logs/
${DEAFAULT_CUSTOM_PATH}    /home/ute/robotws/testsuite/Bangalore/AirPhone/FT
${TEST_REPO_ACTIVATE}    source /home/ute/test_repo/bin/activate
${TESTLINE_CONFIG_REPO}    /home/ute/testline_configuration/
${DEAFAULT_TESTLINE}    7_2_UTE5GCLASSICALBM47
${ROTTA_LOGS}    True
${FT_OUTPUT}    /home/ute/logs/output.log  # Define the output log file path

${CB008235_TC03_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_A/CB008235_A_TC_03.robot

${CB008235_TC04_BM_48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_A/CB008235_A_TC_04.robot

${CB008235_TC08_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...     /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_A/CB008235_A_TC_08.robot

${CB008235_C_TC01_16UE_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD -b debug.log -d /home/ute/logs/ -V
...      /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_C/CB008235_C_TC_01_16R2UE.robot

${CB008235_D_TC01_IWK_ULDMRS_FDM_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD -b debug.log -d /home/ute/logs/ -V
...      /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_D/CB008235_D_TC_01.robot

${CB008235_D_TC02_IWK_CB008662_Adapt_ReTx_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD -b debug.log -d /home/ute/logs/ -V
...      /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_D/CB008235_D_TC_02.robot

${CB008235_D_TC03_IWK_RIMRS_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD -b debug.log -d /home/ute/logs/ -V
...      /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_D/CB008235_D_TC_03.robot

${CB008235_D_TC04_IWK_CB010708_D_MU_IRC_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...     TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_D/CB008235_D_TC_04.robot

${CB008235_E_TC01_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...     TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB008235/CB008235_E/CB008235_E_TC01.robot

${CB012564_A_TC01_72E_RIMRS_BM48_COMMAND}    cd; source /home/ute/test_repo/bin/activate; robot -L TRACE -v
...      TOPOLOGY:CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...      -b debug.log -d /home/ute/logs/ -V /home/ute/testline_configuration/7_2_UTE5GCLASSICALBM48/
...      /home/ute/robotws/testsuite/Bangalore/AirPhone/FT/CB012564/CB012564_A_TC_01.robot

*** Test Cases ***
Test Case CB008235_TC03
    [Tags]    CB008235-CB008235_TC03_SA_4R2_UE_BM48
    Run Process And Check Status    ${CB008235_TC03_BM48_COMMAND}

Test Case CB008235_TC04
    [Tags]    CB008235-CB008235_TC04_SA_8R1_UE_BM48
    Run Process And Check Status    ${CB008235_TC04_BM_48_COMMAND}

Test Case CB008235_TC08
    [Tags]    CB008235-CB008235_TC08_NSA_8R1_UE_BM48
    Run Process And Check Status    ${CB008235_TC08_BM48_COMMAND}

Test Case CB008235_C_TC01
    [Tags]    CB008235-CB008235_C_TC01_16UE_GROUP_PAIRING__BM48
    Run Process And Check Status    ${CB008235_C_TC01_16UE_BM48_COMMAND}

Test Case CB008235_D_TC01
    [Tags]    CB008235-CB008235_D_TC01_IWK_ULDMRS_FDM_BM48
    Run Process And Check Status    ${CB008235_D_TC01_IWK_ULDMRS_FDM_BM48_COMMAND}

Test Case CB008235_D_TC02
    [Tags]    CB008235-CB008235_D_TC02_IWK_CB008662_Adapt_ReTx_BM48
    Run Process And Check Status    ${CB008235_D_TC02_IWK_CB008662_Adapt_ReTx_BM48_COMMAND}

Test Case CB008235_D_TC03
    [Tags]    CB008235-CB008235_D_TC03_IWK_RIMRS_BM48
    Run Process And Check Status    ${CB008235_D_TC03_IWK_RIMRS_BM48_COMMAND}

Test Case CB008235_D_TC04
    [Tags]    CB008235-CB008235_D_TC04_IWK_CB010708_D_MU_IRC_BM48
    Run Process And Check Status    ${CB008235_D_TC04_IWK_CB010708_D_MU_IRC_BM48_COMMAND}

Test Case CB008235_E_TC01
    [Tags]    CB008235-CB008235_E_TC_01_PUSCH_TYPEA
    Run Process And Check Status    ${CB008235_E_TC01_BM48_COMMAND}

Test Case CB012564_A_TC01
    [Tags]    CB012564-CB012564_A_TC01_72E_RIMRS_BM48
    Run Process And Check Status    ${CB012564_A_TC01_72E_RIMRS_BM48_COMMAND}

Feature Test
    [Tags]    FT
    Log To Console    Feature Testing

Upload Logs from Big Disk To rotta
    [Tags]    UploadLogsFromBigDiskToRotta
    Run    mkdir -p ${EXECDIR}/logs/FT_LOGS
    Run    mv /home/ute/FT_LOGS/* ${EXECDIR}/logs/FT_LOGS

*** Keywords ***
Run Process And Check Status
   [Arguments]    ${COMMAND}
   ${result} =    Run Process    /bin/bash    -c    ${COMMAND}    stdout=${FT_OUTPUT}    stderr=${FT_OUTPUT}    cwd=/
   Log File    ${FT_OUTPUT}
   Log To Console    ${FT_OUTPUT}
   Should Be Equal As Numbers    ${result.rc}    0    Execution of the TestCase failed

Common Optimized FT Suite Setup
    ${INPUT_TOPOLOGY}    Get Variable Value    ${TOPOLOGY}    ${DEAFAULT_TOPOLOGY}
    Set Suite Variable    ${INPUT_TOPOLOGY}
    ${INPUT_LOG_PATH}    Get Variable Value    ${LOG_PATH}    ${DEAFAULT_LOGPATH}
    Set Suite Variable    ${INPUT_LOG_PATH}
    ${INPUT_TESTLINE}    Get Variable Value    ${TESTLINE}    ${DEAFAULT_TESTLINE}
    Set Suite Variable    ${INPUT_TESTLINE}
    ${INPUT_CUSTOM_PATH}    Get Variable Value    ${CUSTOM_PATH}    ${DEAFAULT_CUSTOM_PATH}
    Set Suite Variable    ${INPUT_CUSTOM_PATH}

Common FT Suite Teardown
    Log To Console    Logs are Stored at BIG DISK!! Run ft_logs once all the
    ...    Test Cases are Completed to Upload all the Logs from BIG DISK to ROTTA
