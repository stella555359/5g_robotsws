*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource       taf/ul/ettf/main.robot
Resource       resources/CB013728_resources.robot
Resource       resources/CB013728_keywords.robot
Library        resources/tti_trace_keywords.py
Library        ta5g_cell_operations
Library        ta5g_tshark
Library        taf.ul.ettf.setups
Library        ta5g_testline_management
Library        ta5g_iphy
Library        ta5g_egate

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair Without Confirmation   lua_cfg=${basic_setup}
...            AND             Set eNB params
...            AND             Wait For All Cells To Be Enabled    timeout=600

*** Variables ***
${basic_setup}=   ${CURDIR}/config/wts_13728.cfg
${scfc}=          scf_13728.xml
${iphy}=          ${CURDIR}/config/iphy_13728.xml

*** Test Cases ***
CB013728_A#01_Online_modification_of_actProactGrantsUlLteOnlyMode_parameter
    #Attach UE, SgNB addition, testmodes set
    Create aliases  ue_id=101
    Set RLO parameters
    Set RLR parameters
    Attach UE  ue_id=101
    SgNB Addition  ue_id=101

    #Check PUG scheduling
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants

    #Trigger and verify RLO
    Expect RLO messages flow  ue_id=101
    Trigger RLO  ue_id=101  scell_id=5
    Check if RLO messages flow occurred  ue_id=101
    Pcap verify RLO messages content  ue_id=101  cellGroup=0  dataSplitThreshold=inf

    #Check no PUG scheduling
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is not eligible for proactive UL grants

    #Enable actProactGrantsUlLteOnlyMode and check PUG scheduling
    Set feature activation flag 'actProactGrantsUlLteOnlyMode' on NRCELL-1 to true
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants

    #Disable actProactGrantsUlLteOnlyMode and check no PUG scheduling
    Set feature activation flag 'actProactGrantsUlLteOnlyMode' on NRCELL-1 to false
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is not eligible for proactive UL grants

    #Trigger and verify RLR
    Expect RLR messages flow  ue_id=101
    Trigger RLR  ue_id=101  scell_id=5
    Check if RLR messages flow occurred  ue_id=101
    Pcap verify RLR messages content  ue_id=101    cellGroup=1    dataSplitThreshold=b102400

    #Check PUG scheduling and detach UE
    Collect TTI Traces during 10 seconds of traffic
    Convert TTI trace pcap
    Run Keyword and Continue on Failure  Verify that UE is eligible for proactive UL grants
    [Teardown]    Run Keywords    Detach UE  ue_id=101
    ...    AND    Add Scout Data Info To Testcase

*** Keywords ***
Verify that UE is eligible for proactive UL grants
    Verify proactive scheduling  present=True

Verify that UE is not eligible for proactive UL grants
    Verify proactive scheduling  present=False
