*** Settings ***
Documentation     [SUITE PURPOSE] Automation of Feature CB014386 sub-feature B
...               Prerequisite : GNB and Airphone should be installed
...               Scope :
...               Online Activation of PUCCH_F1 Non8RX Receiver Pre-Whitening
...               1/ Perform_Delta_SCF_Commision_B_B5
...               2/ Cell Setup NSA
...               3/ UE Register Multi UE SA
...               4/ PDU Session Multi UE SA
...               5/ Traffic DL/UL 10Mbps Multi UE
...               6/ Activate UL interference
...               9/ Check Pool_Size + PUCCH_F1_DTX PM Counters before Pre-Whitening
...               10/ Activate Pre-Whitening
...               11/ Check Pool_Size + PUCCH_F1_DTX PM Counters after Pre-Whitening
...
...               Test Case Scenario author   : loic.marzin@nokia.com
...               Test Case Scenario contact  : loic.marzin@nokia.com
...               Test Case automation author : loic.marzin@nokia.com
...               Test Case automation contact: loic.marzin@nokia.com
...               Creation Date               : 23-Sep-2025
...               Modified Date               : 17-Oct-2025

Resource                        ../../../resources/SWENG/robot/GenericTest.robot
Resource                        ../../../resources/SWENG/robot/Setup.robot
Resource                        resources/robot/CB014386_keywords.robot
Variables                       ../../../resources/SWENG/python/ReadConfig.py

Suite Setup                     CB014386_Keywords.Setup 14386_B_B5
Suite Teardown                  CB014386_Keywords.Teardown 14386

*** Variables ***
${TestSharkTool}                MC_SHARK

${CellID}                       1

${LogFileSuffix}                B_B5

# UE Profiles for call Setup
&{UE_1}                             ue=1                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

&{UE_2}                             ue=2                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

&{UE_3}                             ue=3                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

&{UE_4}                             ue=4                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

&{UE_5}                             ue=5                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=1                                burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

&{UE_6}                             ue=6                                    profile=1
...                                 bearer=${None}                          testMode=False
...                                 pdu=1                                   qfi=1
...                                 type=${None}                            gw=1
...                                 trf_id=10                               burst=${None}
...                                 target_gnb=2                            target_cells=2
...                                 throughput=10                           testModeValue=csi_report_override
...                                 maxThroughputPerTransfer=175            trfDuration=10s
...                                 deviation=25                            period_ms=${None}

@{UE_list}                          ${UE_1}    ${UE_2}    ${UE_3}    ${UE_4}    ${UE_5}    ${UE_6}

*** Test Cases ***
[1][1.0] CB014386-B_B5_Online_Activation_PUCCH_F1_Non8RX_PreWhitening
    TC 14386 B_B5       ${UE_list}

*** Keywords ***
TC 14386 B_B5
    [Documentation]                 Generic test for CB014386_B_B5 :
    ...                             1/ Perform_Delta_SCF_Commision_B-B5
    ...                             2/ Cell_Setup_NSA
    ...                             3/ UE_Register_Multi_SA
    ...                             4/ PDU_Session_Multi_SA
    ...                             5/ Traffic_DL_UL_Mbps_Multi_SA
    ...                             6/ Activate_UL_interference
    ...                             7/ Check_Counters_B_B5_Before_PreWhitening
    ...                             8/ Activate_PreWhitening
    ...                             9/ Check_Counters_B_B5_After_PreWhitening

    [Arguments]                     ${param}
    Init Sequence                   ${param}
    Step                            Perform_Delta_SCF_Commision_B_B5
    Step                            Cell_Setup_NSA                                 depends=Perform_Delta_SCF_Commision_B-B5
    Step                            UE_Register_Multi_SA                           depends=Cell_Setup_SA
    Step                            PDU_Session_Multi_SA                           depends=UE_Register_Multi_SA
    Step                            Traffic_DL_UL_Mbps_Multi_SA                    depends=PDU_Session_Multi_SA
    Step                            Activate_UL_interference                       depends=Traffic_DL_UL_Mutil_SA
    Step                            Check_Counters_B_B5_Before_PreWhitening        depends=Activate_UL_interference
    Step                            Activate_PreWhitening                          depends=Check_Counters_B_B5_Before_PreWhitening
    Step                            Check_Counters_B_B5_After_PreWhitening         depends=Activate_PreWhitening
    [Teardown]                      Teardown 14386 B_B5

Teardown 14386 B_B5
    ${message}=  Evaluate  "\\033[44mTest Teardown\\033[0m"
    BuiltIn.Log      ${message}   console=yes
    [Teardown]       GenericTest.Display diagnosis
