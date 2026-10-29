*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    master_vDU    RAN_5G    RAN_5G_TDD    RAN_Aic    CRT
...    CLOUD_5GC_dRNIC_1vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    owner-jianfen.shen    release-5G22R4    team-DevHZ5_SG02    vDUCNF00

Resource    ../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/1du/2cell
@{PARAMS_IN_SCF_CU}    @{5GC000743CU_full}

@{5GC000743CU_full}
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=40890
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=false
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=30
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=22
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-22
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=23

@{5GC000743CU_Delta}
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=0
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:allowedMeasBw=mbw6
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:presenceAntPort1=true
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXHigh=31
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:threshXLow=31
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qRxLevMin=-30
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:qQualMin=-3
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:pMaxEutra=-30
...    NRBTS/NRSYSINFO_PROFILE-1:tReselectionEutra=7

*** Test Cases ***
5GC000743_A_ET_reconfigured SIB5 right
    [Documentation]
    ...    1. The purpose of this test case is to check reconfigured SIB5 message is right
    ...    2. Test Case Steps:
    ...         a. reconfig SIB5 message
    ...    3. Expected Results:
    ...         setp a: check reconfig SIB5 message in wireshark
    [Tags]    QC_190130
    Reconfig SIB5
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}/a2a_5GC000743/a2a.ini    wait_string=GNBCUConfigurationUpdateAcknowledge::4

*** Keywords ***
Reconfig SIB5
    Delta Commission Parameters cu    ${5GC000743CU_Delta}
