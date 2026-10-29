*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Tom
...             :contact  : tom.toby@nokia.com

Library     taf.config.scf   WITH NAME    scf

Resource    ./resources/Keywords/CB009215_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables  ***
${scf}           ${CURDIR}/config/gnb_scf/CB009215_IA_SCF.xml
${iphy}          ${CURDIR}/config/ap_iphy/4cells_IntFQ.iphy
${rad_parameter}        0x58012d=3;0x580758=0;0x580690=0;0x58057a=4;0x58057c=0x7800;0x58057e=0x100
${NSA_HO_IAFR_Pattern_Check}    Sending SgNB Modification Confirm

*** Test Cases ***
[1][1.0] CB009215-IA#1_2_MeNB_configured_measurement_gap_setup_during_SgNB_modification_procedure_with_PRB_pooling_if_DRX_is_configured
    [Documentation]     CB009215-IA#1: MeNB configured measurement gap setup during SgNB modification procedure
    ...                  with PRB pooling
    [Tags]    QC_28305   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB009215_IA_1
    ${Log_Path}      CreateLog Directory    ${Test_CaseNumber}
    Log to Console      \nStarting the test\n
	[Setup]      Run Keywords     Create Basic Interface on UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     CB009215 Backup TL Config
    ...     AND     Add RD Parameters Directly On GNB     ${rad_parameter}
    ...     AND     Full Commision scf and iphy      ${scf}      ${iphy}
    ...     AND     Sleep   420s
    ...     AND     Wait Coam Site to be Ready
    ...     AND     Start UTE WTS      meas_gap.cfg
    Basic Bring up
    Start pcap collection in gNB CU     gnbTcpdump_UE_Attach
    Register Multiple NSA UEs       11      22      1
    Register Multiple NSA UEs       23      24      2
    Register Multiple NSA UEs       25      26      3
    Register Multiple NSA UEs       27      28      4
    Stop pcap collection in gNB     gnbTcpdump_UE_Attach      ${Log_Path}
    Sleep   5s
    Start pcap collection in gNB CU     gnbTcpdump_perUE_measgap
    Sleep   2s
    CB009215-IA MeNB configured measurement gap setup   11   gp0:20  ms0     perUE       off
    Stop pcap collection in gNB     gnbTcpdump_perUE_measgap      ${Log_Path}
    CB009215-IA MeNB configured measurement gap setup   12   gp0:4  ms0     perUE       off
    CB009215-IA MeNB configured measurement gap setup   13   gp0:10  ms0     perUE       off
    CB009215-IA MeNB configured measurement gap setup   14   gp0:5  ms0     perUE       on
    CB009215-IA MeNB configured measurement gap setup   15   gp1:20  ms0     perUE       on
    CB009215-IA MeNB configured measurement gap setup   16   gp0:12  ms0     perUE       on
    Start pcap collection in gNB CU     gnbTcpdump_perFR1_measgap
    Sleep   2s
    CB009215-IA MeNB configured measurement gap setup   17   gp1:2  ms0     perFR1       off
    Stop pcap collection in gNB     gnbTcpdump_perFR1_measgap      ${Log_Path}
    CB009215-IA MeNB configured measurement gap setup   18   gp1:10  ms0     perFR1       off
    CB009215-IA MeNB configured measurement gap setup   19   gp0:5  ms0     perFR1       off
    CB009215-IA MeNB configured measurement gap setup   20   gp1:15  ms0     perFR1       on
    CB009215-IA MeNB configured measurement gap setup   21   gp0:16  ms0     perFR1       on
    CB009215-IA MeNB configured measurement gap setup   22   gp0:8  ms0     perFR1       on
    Log to Console   \nVerification of UE Context Modification Response from PCAP\n
    ${id}      Get physCellId value
    ...     /home/ute/logs/CB009215_IA_1/gnbTcpdump_perUE_measgap/gnbTcpdump_perUE_measgap.pcap
    Log to Console     Physicall cell ID updation from UE Context Modification Response: ${id}\n
#	CB009215 Restore TL Config
    Log to Console      \nStarting Tear Down for Test Case
