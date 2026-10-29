*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008127-2bands
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        CB008127-commissioning.robot
Resource        CB008127-commissioning-2bands.robot
Resource        CB008127-wts.robot
Resource        CB008127-parameter-settings.robot
Resource        CB008127-keywords.robot
Resource        CB008127-keywords-egate.robot
Resource        CB008127-keywords-egate-verify.robot
Resource        CB008127-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup CB008127 2bands
Suite Teardown    Suite Teardown CB008127

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB008127_AB_Second_RRC_Reconfiguration_for_InterFreq_A2_after_Xn_handover_using_measurement_profile
    [Documentation]    AB_Second_RRC_Reconfiguration_for_InterFreq_A2_after_Xn_handover_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    [Tags]    t16
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Prepare Counters And Expected Values T16
    Upload Wts Cfg File     ${resultBaseDir}/basic_wts_CB008127_2bands.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t16
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Set Sib Period For Gnb3

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Ue Change Location            ue_id=7   cell=2
    Register UE                   ue_id=7
    Start PDU Session             ue_id=7

    Set Ue History                ue_id=7
    Set Ue Nr Capabilites         ue_id=7   ue_nr_capabilities=${ue7_nr_cap_t16}

    Send A3     ue_id=7  meas_id=1   nrsrp_nr=90   phycell_id=50    check=a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    Save Egate Log From A3 Event     log_instance=1
    Display Measurement Config    ue_id=7     log=_1

    Send Event A2 With Srsrp Srsrq Nr   ue_id=7    meas_id=11   srsrp_srsrq_nr=11
    Send A3     ue_id=7  meas_id=13   nrsrp_nr=90   phycell_id=51   check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Save Egate Log From A3 Event     log_instance=2
    Display Measurement Config    ue_id=7     log=_2

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    Release UE           ue_id=7

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127
    Verify Egate Logs T16

    [Teardown]   Perform Postconditions Of Test Scenario CB008127


CB008127_AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    [Documentation]    AB_Second_RRC_Reconfiguration_for_A1_based_traffic_steering_after_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t17
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Prepare Counters And Expected Values T17

    Update SCF 2bands T17
    Upload Wts Cfg File     ${resultBaseDir}/basic_wts_CB008127_2bands.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t17
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Set Sib Period For Gnb3

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Ue Change Location            ue_id=7   cell=2
    Register UE                   ue_id=7
    Start PDU Session             ue_id=7

    Set Ue History                ue_id=7
    Set Ue Nr Capabilites         ue_id=7    ue_nr_capabilities=${ue7_nr_cap_t16}

    Send A3     ue_id=7  meas_id=1   nrsrp_nr=90   phycell_id=50    check=a2-Threshold rsrp : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    Display Measurement Config    ue_id=7

    Send A1     ue_id=7   meas_id=11    srsrp_nr=85   srsrq_nr=85   check=eventId eventA4
    Display Measurement Config    ue_id=7     log=_2

    Send A4 Nrsrq No Handover     ue_id=7   meas_id=1
    Wait For Expiry Of A4Fr1SupervisionTimer And A4RetryTimer
    Send A4 Nrsrq Handover     ue_id=7   meas_id=1     check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Display Measurement Config    ue_id=7     log=_3

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    Release UE           ue_id=7

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127 T17
    Verify Egate Logs T17

    [Teardown]   Perform Postconditions Of Test Scenario CB008127


CB008127_AB_Second_RRC_Reconfiguration_using_measurement_profile_after_NG_handover
    [Documentation]    AB_Second_RRC_Reconfiguration_using_measurement_profile_after_NG_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t18
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Prepare Counters And Expected Values T18

    Update SCF 2bands T18
    Update Wts File For TC CB008127 2bands T18
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_2bands_t18.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t18
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Set Sib Period For Gnb3

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Ue Change Location            ue_id=7   cell=2
    Register UE                   ue_id=7
    Start PDU Session             ue_id=7

    Set Ue History                ue_id=7
    Set Ue Nr Capabilites         ue_id=7      ue_nr_capabilities=${ue7_nr_cap_t16}

    Send A3     ue_id=7  meas_id=1   nrsrp_nr=90   phycell_id=50    check=a2-Threshold rsrq : ${a2MeashoSsbRsrp_a2ThresholdhoSsb}[6],
    Display Measurement Config    ue_id=7

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    Release UE           ue_id=7

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127
    Verify Egate Logs T18

    [Teardown]   Perform Postconditions Of Test Scenario CB008127


CB008127_AB_Second_RRC_Reconfiguration_after_interRAT_HO_from_LTE_using_measurement_profile
    [Documentation]    AB_Second_RRC_Reconfiguration_after_interRAT_HO_from_LTE_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    [Tags]    t19
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Create Ips For Simulated Gnb 4

    Prepare Counters And Expected Values T19

    Update SCF 2bands T19
    Update Wts File For TC CB008127 2bands T19
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_2bands_t19.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t19
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Register UE                   ue_id=7
    Start PDU Session             ue_id=7

    Send Event A2 With Srsrp Srsrq Nr   ue_id=7     meas_id=1   srsrp_srsrq_nr=11
    Save Egate Log From A2 Event        ue_id=7     log_instance=1
    Display Measurement Config          ue_id=7     log=_1

    Send B2    ue_id=7   meas_id=5   nrsrp_nr=30   nrsrq_nr=30

    Set Ue Nr Capabilites         ue_id=7   ue_nr_capabilities=${ue7_nr_cap_t16}
    Trigger And Check InterRat Handover     ue_id=7    check=a2-Threshold rsrp : ${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[6],
    Display Measurement Config    ue_id=7     log=_2

    Send Event A2 With Srsrp Srsrq Nr   ue_id=7    meas_id=1   srsrp_srsrq_nr=11
    Save Egate Log From A2 Event   ue_id=7     log_instance=2
    Display Measurement Config    ue_id=7     log=_3
    Send A3 With Nrsrq Nr
    Send A3 With Nrsrq Nr And Check   check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Display Measurement Config    ue_id=7     log=_4

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    Release UE           ue_id=7

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127 T19
    Verify Egate Logs T19

    [Teardown]   Perform Postconditions Of Test Scenario CB008127



CB008127_AB_Interworking_with_MFBI_during_incoming_Xn_handover
    [Documentation]    AB_Interworking_with_MFBI_during_incoming_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t22
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Prepare Counters And Expected Values T22

    Update SCF 2bands T22
    Update Wts File For TC CB008127 2bands MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_2bands_MFBI.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t22
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Set Sib Period For Gnb3 T22

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Ue Change Location            ue_id=7   cell=2
    Register UE                   ue_id=7
    Start PDU Session             ue_id=7

    Set Ue History                ue_id=7
    Set Ue Nr Capabilites         ue_id=7   ue_nr_capabilities=${ue7_nr_cap_t22}

    Send A3     ue_id=7  meas_id=1    nrsrp_nr=90   phycell_id=50    check=a2-Threshold rsrp : 72,
    Save Egate Log From A3 Event      log_instance=1
    Display Measurement Config        ue_id=7     log=_1

    Send Event A2 With Srsrp Srsrq Nr   ue_id=7     meas_id=12   srsrp_srsrq_nr=75
    Display Measurement Config          ue_id=7     log=_2

    Send A3     ue_id=7  meas_id=15     nrsrp_nr=90   phycell_id=51    check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    Save Egate Log From A3 Event        log_instance=2
    Display Measurement Config          ue_id=7     log=_3

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    Release UE           ue_id=7

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval


    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Counter CB008127
    Verify Egate Logs T22

    [Teardown]   Perform Postconditions Of Test Scenario CB008127


CB008127_PX_SA_Distribution_of_mapping_selection_and_measurement_profile_usage
    [Documentation]    PX_SA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider
    [Tags]    t23
    [Setup]   Perform Preconditions Of Test Scenario CB008127

    Create Ips For Simulated Gnb 4

    Prepare Counters And Expected Values T23

    Update SCF 2bands T23
    Update Wts File For TC CB008127 2bands T23
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_2bands_t23.cfg

    Start Wireshark Trace
    Activate SCF 2bands And Bring Tl OnAir t23
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword And Warn On Failure     Prepare For Dcap Tracing
    Run Keyword And Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace

    Set Ue Nr Capabilites No Check      ue_id=4    ue_nr_capabilities=${ue4_nr_cap_t23}
    Register UE                         ue_id=4
    Start PDU Session With Slice        ue_id=4    gw_id=4     nwslice_id=1   log=_1
    Display Measurement Config          ue_id=4    log=_1

    Send Event A2 With Srsrp Srsrq Nr   ue_id=4    meas_id=1   srsrp_srsrq_nr=11
    Display Measurement Config          ue_id=4    log=_2

    Start 2nd PDU Session With Slice    ue_id=4    gw_id=5     nwslice_id=2
    Display Measurement Config          ue_id=4    log=_3

    UE PDU Session Release              ue_id=4   pdu=1

    Start PDU Session With Slice        ue_id=4    gw_id=4     nwslice_id=1   log=_2
    Display Measurement Config          ue_id=4    log=_4

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    UE Deregister                       ue_id=4

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Warn On Failure     Dcap Tracing Stop

    Verify Egate Logs T23
    Verify Counter CB008127 T23


    [Teardown]   Perform Postconditions Of Test Scenario CB008127



*** Keywords ***

Suite Setup CB008127 2bands
    [Documentation]    [PRIVATE]    Prepare TL for CB008127
    ...       :Autor: Sylvia Schneider
    Create Ips For Simulated Gnb
    Create Test Suite Folders
    Get Test Variables And Upload Start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From GNB
    Get Version Mcc Mnc From GNB SCF    ${current_SCF_gnb}
    gnb.Store Current Swconfig From GNB
    Store Current Swconfig From Airphone
    Store Current WTS Config
    Update Wts File For TC CB008127 2bands
    Update SCF File For TC CB008127 Common 2bands
    Update Iphy File 2bands


Update Iphy File 2bands
    [Documentation]    [PRIVATE]    update iphy file 2bands
    ...       :Autor: Sylvia Schneider

    Get Gnb TargetBD File
    Get ResourceBuildKey And SwFileKey For AEHC From TargetBD File
    Update Iphy With AEHC Data For 2nd Rmod


Get Gnb TargetBD File
    [Documentation]    [PRIVATE]    get gnb TargetBD file
    ...       :Autor: Sylvia Schneider
    ${gNBCommUnit_alias}    Connect To Node Common Unit
    ${file_name}   ssh.Execute      ls /ffs/run/TargetBD_SBTS*.xml   connection=${gNBCommUnit_alias}
    ${file_name}   Remove String   ${file_name}   \n   \r
    ssh.Download File   remote_path=${file_name}   local_path=${resultBaseDir}/TargetBD.xml   connection=${gNBCommUnit_alias}
    [Teardown]    ssh.Disconnect   connection=${gNBCommUnit_alias}


Get ResourceBuildKey And SwFileKey For AEHC From TargetBD File
    [Documentation]    [PRIVATE]    get resourceBuildKey and swFileKey for AEHC from TargetBD file
    ...       :Autor: Sylvia Schneider
    ${target_xml}    Parse XML      ${resultBaseDir}/TargetBD.xml
    ${TargetBD_resourceBuildKey}    Get Element Attribute    ${target_xml}    resourceSWVersion    xpath=.//hwResource[@resourceBuildKey="LTX_AEHC"]
    Set Suite Variable      ${TargetBD_resourceBuildKey}
    ${TargetBD_swFileKey}           Get Element Text         ${target_xml}    xpath=.//hwResource[@resourceBuildKey="LTX_AEHC"]
    Set Suite Variable      ${TargetBD_swFileKey}


Update Iphy With AEHC Data For 2nd Rmod
    [Documentation]    [PRIVATE]    update iphy with AEHC data for 2nd rmod
    ...       :Autor: Sylvia Schneider

    Log To Console    update iphy file
    ${ACU_alias}    Connect To Airphone Common Unit
    ssh.Execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>

    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>6351<\/GSCN>
    ${upd2}    Replace String Using Regexp    ${upd1}      <cardName>.*</cardName>     <cardName>AEHC</cardName>
    ${upd3}    Replace String Using Regexp    ${upd2}      <bldVersion>.*</bldVersion>     <bldVersion>${TargetBD_resourceBuildKey}</bldVersion>
    ${upd4}    Replace String Using Regexp    ${upd3}      <productCode>.*</productCode>     <productCode>475124A</productCode>
    ${upd5}    Replace String Using Regexp    ${upd4}      <resourceBuildKey>.*</resourceBuildKey>     <resourceBuildKey>LTX_AEHC</resourceBuildKey>
    ${upd6}    Replace String Using Regexp    ${upd5}      <name>.*</name>     <name>${TargetBD_swFileKey}</name>
    ${upd7}    Replace String Using Regexp    ${upd6}      <version>.*</version>     <version>${TargetBD_resourceBuildKey}</version>

    ${new contents}      Catenate         SEPARATOR=</RE>   ${all_parts}[0]            ${upd7}
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


Wait For Expiry Of A4Fr1SupervisionTimer And A4RetryTimer
    [Documentation]    [PRIVATE]    wait for expiry of a4Fr1SupervisionTimer and a4RetryTimer, each 10 secs
    ...       :Autor: Sylvia Schneider
    Sleep   20s