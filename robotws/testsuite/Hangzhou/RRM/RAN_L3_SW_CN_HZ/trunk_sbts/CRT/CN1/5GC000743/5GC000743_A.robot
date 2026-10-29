*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    team-SG2
...               owner-flore.du    5GC000743    release-5G21A
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1:tReselectionEutra=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=40890
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw100
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=false
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-34
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=23

@{PARAMS_TO_RECONFIG_SIB5}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1:tReselectionEutra=7
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=true
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=31
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=31
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=-30


*** Test Cases ***
5GC000743_A_ET_configured_and_reconfigured_SIB5_right
    [Documentation]
    ...    1. The purpose of this test case is to check configured SIB5 when bts setup and reconfigured SIB5 message after setup is right
    ...    2. Test Case Steps:
    ...         a. bts on air
    ...         b. reconfig SIB5 message
    ...    3. Expected Results:
    ...         setp a: check configured SIB5 message when bts setup is right in wireshark
    ...         setp b: check reconfig SIB5 message is right in wireshark
    [Tags]    QC_62342
    Delta Commission Parameters    ${PARAMS_TO_RECONFIG_SIB5}
    Check Wireshark Log    a2a_ini_file=${CURDIR}/a2a_5GC000743/a2a_reconfig.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::4

*** Keywords ***
Perform Steps After Onair
    check wireshark log    a2a_ini_file=${CURDIR}/a2a_5GC000743/a2a_config.ini    wait_string=NGSetupResponse::2

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
