*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
Library     taf.config.scf   WITH NAME    scf

Resource    ./resources/Keywords/CB009215_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables  ***
${scf}           ${CURDIR}/config/gnb_scf/6cells_Scf.xml
${iphy}          ${CURDIR}/config/ap_iphy/6cells_iphy.xml
${rad_parameter}        0x58012d=3;0x580758=0;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100
${LUA_FILE}        ${CURDIR}/resources/Keywords/scripts.lua

*** Test Cases ***
[1][1.0] CB009215-F#1_Activation_and_deactivation_of_automated_prachConfigurationIndex_assignment_for_FDD_cells
    [Tags]    QC_28304   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB009215_F_1

    ${Log_Path}      CreateLog Directory    ${Test_CaseNumber}
    Log to Console      \nStarting the test\n
	[Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     CB009215 Backup TL Config
    ...     AND      Add RD Parameters Directly On GNB    ${rad_parameter}
    ...     AND     Full Commision scf and iphy      ${scf}      ${iphy}
    ...     AND     Sleep   420s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      basic_6cells.cfg
    Basic Bring up
    Log to Console      All cells on-air
    Log to Console      Get configured prach value
    Log to console      Enable autoprach feature
    Start pcap collection in gNB CU     gnbTcpdump_FeatureEnable
    admin.Setup admin
    Online NIDD parameter change    paramName=actAutoPrachConfigIndexFdd            paramValue=true
    ...                             paramDst=MRBTS-1/NRBTS-1
    admin.Teardown admin
    Stop pcap collection in gNB     gnbTcpdump_FeatureEnable      ${Log_Path}
    Sleep   40s
    Log to Console      Prach Values realigned
    Wait Coam Site to be Ready
    Log to console      Establish call to FDD cell 1
    Make SA calls to all the cells       1   1
    Log to console      Establish call to FDD cell 2
    Make SA calls to all the cells       4   4
    Log to console      Establish call to FDD cell 3
    Make SA calls to all the cells       7   7
    Log to console      Establish call to FDD cell 4
    Make SA calls to all the cells       10   10
    Log to console      Establish call to FDD cell 5
    Make SA calls to all the cells       13   13
    Log to console      Establish call to FDD cell 6
    Make SA calls to all the cells       16   16
    Log to console      Verification for changing prach value and checking reconfiguration
    admin.Setup admin
    Online NIDD parameter change    paramName=administrativeState            paramValue=Locked
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-3
    admin.Teardown admin
    Sleep   40s
    admin.Setup admin
    Online NIDD parameter change    paramName=prachConfigurationIndex            paramValue=42
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-3
    Online NIDD parameter change    paramName=administrativeState            paramValue=Unlocked
    ...                             paramDst=MRBTS-1/NRBTS-1/NRCELL-3
    admin.Teardown admin
    Sleep   50s
    Wait Coam Site to be Ready
    Log to console      Establish call to FDD cell 1
    Make SA calls to all the cells      2   2
    Log to console      Establish call to FDD cell 2
    Make SA calls to all the cells      5   5
    Log to console      Establish call to FDD cell 3
    Make SA calls to all the cells      8   8
    Log to console      Establish call to FDD cell 4
    Make SA calls to all the cells      11   11
    Log to console      Establish call to FDD cell 5
    Make SA calls to all the cells      14   14
    Log to console      Establish call to FDD cell 6
    Make SA calls to all the cells      17   17
    Log to console      Disabling feature
    admin.Setup admin
    Online NIDD parameter change    paramName=actAutoPrachConfigIndexFdd            paramValue=false
    ...                             paramDst=MRBTS-1/NRBTS-1
    admin.Teardown admin
    Sleep   50s
    Wait Coam Site to be Ready
    Log to console      Establish call to FDD cell 1
    Make SA calls to all the cells      3   3
    Log to console      Establish call to FDD cell 2
    Make SA calls to all the cells      6   6
    Log to console      Establish call to FDD cell 3
    Make SA calls to all the cells      9   9
    Log to console      Establish call to FDD cell 4
    Make SA calls to all the cells      12   12
    Log to console      Establish call to FDD cell 5
    Make SA calls to all the cells      15   15
    Log to console      Establish call to FDD cell 6
    Make SA calls to all the cells      18   18
    Log to Console      \nAutoPrachConfiguration successfully enabled & disabled for FDD cells
    Log to Console      \nUE NR call verified to FDD cells for each case
    Log to Console      \nStarting Tear Down for Test Case
    RAT Block Unblock

*** Keywords ***
Make SA calls to all the cells
    [Arguments]    ${UEID}=${UEID}    ${gw_ID}=${gw_ID}
    [Documentation]    This keyword shall register UE and establish GBR and Non-GBR data calls
    Start pcap collection in gNB CU     gnbTcpdump_UE ${UE_ID}
    Enable Internal TG   ${UEID}      1
    wtsrunner.ue_register   id=${UEID}
    sleep   20s
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UEID}   nwslice=1   gw=${gw_ID}
    Sleep   10s
    Pass Lua File       ${LUA_FILE}
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    Stop pcap collection in gNB     gnbTcpdump_UE ${UE_ID}      ${Log_Path}
