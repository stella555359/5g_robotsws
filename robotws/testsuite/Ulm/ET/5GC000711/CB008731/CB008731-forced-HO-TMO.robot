*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731 TMO
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot

Resource        CB008731-commissioning-forced-HO-TMO.robot
Resource        CB008731-wts-forced-HO-TMO.robot
Resource        CB008731-parameter-settings-force-HO.robot
Resource        CB008731-parameter-definitions.robot
Resource        CB008731-verify-counter.robot
Resource        CB008731-verify-wireshark.robot
Resource        CB008731-keywords-egate-verify-force-HO.robot
#Resource        CB008731-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/bsr_package_installation.robot


Suite Setup       Suite Setup CB008731_force_HO
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***



CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    [Documentation]    CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    [Tags]    t11
    [Setup]   keywords.Perform Preconditions Of Test Scenario 711A 8731

    keywords.Start Wireshark Trace
    CB008731-commissioning-forced-HO-TMO.Activate SCF And Bring Tl onAir Force HO TMO
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    keywords-wts.Check Wts In Active State

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    keywords.Set Sib Period
    keywords.Change Location            ue_id=21,51,81   enb=3   cell=1
    keywords.Change Location            ue_id=1-10       enb=2   cell=4
    wts_ue.Set Traffic Type             ue_id=1-10,21,51,81    pdu_id=1    trf_type=internal   log_traffic_stats=off

    keywords.Change Ue Capabilities     ue_id=21,51   ue_nr_capabilities=${cap_21_51}
    keywords.Change Ue Capabilities     ue_id=81      ue_nr_capabilities=${cap_81}

    Log to console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    UE21 UE51 UE81 Register And Start Pdu And Start DL Traffic
    UE21 UE51 UE81 Handover To eNB4 Cell1

    keywords.Change Ue Capabilities     ue_id=81   ue_nr_capabilities=${cap_21_51}
    UE21 UE51 Handover To To eNB2 Cell4
    UE81 Handover To To eNB2 Cell4 Which Fails

    CB008731-commissioning-forced-HO-TMO.Set actForceHoInsuffUeCap To True
    UE81 Handover To To eNB2 Cell4

    UE21 UE51 UE81 Increase Dl Traffic And Start Ul Traffic

    UE1 Up To UE10 Register And Start Pdu And Start DL Traffic

    Trigger Scell Addition For UE81
    Trigger Scell Release For UE81

    Log to console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    Release All UEs
    Save Last SCF

    Run Keyword And Warn On Failure        keywords-tracing.Dcap Tracing Stop

    Run Keyword And Continue On Failure    CB008731-verify-counter.Verify counter forced-HO-TMO
    Run Keyword And Continue On Failure    CB008731-verify-wireshark.verify wireshark 8731 force HO TMO
    Run Keyword And Continue On Failure    CB008731-keywords-egate-verify-force-HO.Verify Egate Log Force HO TMO

    [Teardown]   Perform Postconditions Of Test Scenario 711A 8731 Trace






*** Keywords ***

Suite Setup CB008731_force_HO
    [Documentation]    [PRIVATE]    Prepare TL for CB008731_force_HO
    ...       :Autor: Sylvia Schneider
    Create Ips For Simulated gnb TMO
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From gNB
    keywords.Get Version mcc mnc From gNB SCF    ${current_SCF_gnb}
    gnb.Store Current Swconfig From gNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    bsr_package_installation.Install All BSR Packages Found In SCF

    CB008731-wts-forced-HO-TMO.Update Wts File For TC CB008731 force HO TMO
    CB008731-commissioning-forced-HO-TMO.Update SCF File For CB008731 force HO TMO


Create Ips For Simulated gnb TMO
    [Documentation]    [PRIVATE]    create IPs used for WTS TMO
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3
    FOR   ${ip}   IN   3  4  5  6
       Log To Console    create IP 10.0.1.${ip}
       ute_workarounds.Configure IP On VM    ip=10.0.1.${ip}        interface=eth3
    END


UE21 UE51 UE81 Register And Start Pdu And Start DL Traffic
    [Documentation]    [PRIVATE]    UE21 UE51 UE81 Register And Start Pdu And Start DL Traffic
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
    FOR   ${ue_id}   IN   21  51   81
        keywords.Register UE             ue_id=${ue_id}
        keywords.Start PDU Session       ue_id=${ue_id}   check=rrcReconfigurationComplete
        wts_ue.Start Data Traffic In Egate   ue_id=${ue_id}    direction=dl     trf_id=1    mbps=10   pdu=1   qfi=1
    END
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_21_51_81_reg_pdu_trf.pcap


UE21 UE51 UE81 Handover To eNB4 Cell1
    [Documentation]    [PRIVATE]    UE21 UE51 UE81 Handover To eNB4 Cell1
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
    FOR   ${ue_id}   IN   21  51   81
        keywords.Send B2            ue_id=${ue_id}   B2_meas_id=19   check=UE${ue_id}: Successful handover from ENB-3.1 to ENB-4.1
    END
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_21_51_81_ho_enb4_cell1.pcap


UE21 UE51 Handover To To eNB2 Cell4
    [Documentation]    [PRIVATE]    UE21 UE51 Handover To To eNB2 Cell4
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
    FOR   ${ue_id}   IN   21  51
        keywords.Trigger Handover To 5G
        ...   ue_id=${ue_id}
        ...   check=UE${ue_id}: Inter-eNB handover from ENB-4.1 to EXT_ENB-2.4 performed
        ...   target_cell=4
        ...   plmn=310:260
    END
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_21_51_ho_enb2_cell4.pcap


UE81 Handover To To eNB2 Cell4 which fails
    [Documentation]    [PRIVATE]    UE81 Handover To To eNB2 Cell4 which fails
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
        keywords.Trigger Handover To 5G Which Is Cancelled And Check
        ...   ue_id=81
        ...   cause=GNB-4: UE81: Received Handover Preparation Failure from AMF for UE with AMF UE NGAP ID 6 and RAN UE NGAP ID
        ...   target_cell=4
        ...   plmn=310:260
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_81_ho_enb2_cell4_failure.pcap


UE81 Handover To To eNB2 Cell4
    [Documentation]    [PRIVATE]    UE81 Handover To To eNB2 Cell4
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
    keywords.Trigger Handover To 5G
    ...   ue_id=81
    ...   check=UE81: Inter-eNB handover from ENB-4.1 to EXT_ENB-2.4 performed
    ...   target_cell=4
    ...   plmn=310:260
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_81_ho_enb2_cell4.pcap


UE21 UE51 UE81 Increase Dl Traffic And Start Ul Traffic
    [Documentation]    [PRIVATE]    UE21 UE51 UE81 Increase Dl Traffic And Start Ul Traffic
    ...       :Autor: Sylvia Schneider
    wts_ue.Start Data Traffic In Egate   ue_id=21,51,81     direction=dl     trf_id=1    mbps=100   pdu=1   qfi=1
    wts_ue.Start Data Traffic In Egate   ue_id=21,51,81     direction=ul     trf_id=1    mbps=20    pdu=1   qfi=1
    Sleep   10s   wait for stable traffic

    FOR   ${type}   IN   pdsch   pusch
       FOR    ${ue_id}   IN   21  51  81
          ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
          ...    cmd=ue_stats_nr id=${ue_id} scell=0-5 type=${type}
          ...    return_output=True
          ...    alias=ap_egate
          Create File    ${resultDir}/egate_throughput_${type}_ue${ue_id}_after_irat_and_increase_traffic.txt    ${output_egate}
       END
    END


UE1 Up To UE10 Register And Start Pdu And Start DL Traffic
    [Documentation]    [PRIVATE]    UE1 Up To UE10 Register And Start Pdu And Start DL Traffic
    ...       :Autor: Sylvia Schneider
    keywords.Start Wireshark Trace
    FOR   ${ue_id}   IN RANGE   1  11
        keywords.Register UE And Start PDU Session             ue_id=${ue_id}
        wts_ue.Start Data Traffic In Egate   ue_id=${ue_id}    direction=dl     trf_id=1    mbps=100   pdu=1   qfi=1
        wts_ue.Start Data Traffic In Egate   ue_id=${ue_id}    direction=ul     trf_id=1    mbps=20    pdu=1   qfi=1
    END
    keywords.Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_1_upt_10_reg_pdu_trf.pcap
    Wait For Stable Traffic And Get Ue Stats From All Ues  run=after_attach_all_Ues


Display Measurements
    [Documentation]    [PRIVATE]    Display Measurements
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${run}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_disp id=81
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/meas_disp_ue81_${run}.txt    ${output_egate}


Trigger Scell Addition For UE81
    [Documentation]    [PRIVATE]    Trigger Scell Addition For UE81
    ...       :Autor: Sylvia Schneider
    Display Measurements   run=before_A1_sCelladdition

    ${cmd}     Set Variable   ue_measurement_send_nr id=81 meas_id=4 event=A1 srsrp_nr=50 srsrq_nr=50
    ${check}   Set Variable   PhysCellId:58. SCellIndex 1 activated successfully at airphone
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    timeout=15
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/add_scell.txt    ${output_egate}

    Wait For Stable Traffic And Get Ue Stats From All Ues  run=after_A1_sCelladdition


Trigger Scell Release For UE81
    [Documentation]    [PRIVATE]    Trigger Scell Release For UE81
    ...       :Autor: Sylvia Schneider
    Display Measurements   run=before_A2_sCellrelease

    ${cmd}     Set Variable   ue_measurement_send_nr id=81 meas_id=6 event=A2 srsrp_nr=55 scell=1
    ${check}   Set Variable   sCellToReleaseList
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    timeout=15
    ...    pass_regexp=${check}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/release_scell.txt    ${output_egate}

    Wait For Stable Traffic And Get Ue Stats From All Ues  run=after_A2_sCellrelease


Wait For Stable Traffic And Get Ue Stats From All Ues
    [Documentation]    [PRIVATE]    Wait For Stable Traffic And Get Ue Stats From All Ues
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${run}
    Sleep   10s   wait for stable traffic

    FOR   ${type}   IN   pdsch   pusch
       FOR    ${ue_id}   IN   1  2  3  4  5  6  7  8  9  10  21  51  81
          ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
          ...    cmd=ue_stats_nr id=${ue_id} scell=0-5 type=${type}
          ...    return_output=True
          ...    alias=ap_egate
          Create File    ${resultDir}/egate_throughput_${type}_ue${ue_id}_${run}.txt    ${output_egate}
       END
    END


Stop All Traffic
    [Documentation]    [PRIVATE]    stop all traffic UE2
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}
    ${cmd}    Set Variable   trf_data_stop ue=${ue_id} pdu=1 qfi=1
    Log To Console    execute on wts: ${cmd}
    ${output_egate}  ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_stopTraffic_${ue_id}.txt    ${output_egate}


release all UEs
    [Documentation]    [PRIVATE]    release all UEs
    ...       :Autor: Sylvia Schneider
    FOR   ${ue_id}   IN   1  2  3  4  5  6  7  8  9  10  21  51  81
      Stop All Traffic                                         ue_id=${ue_id}
      Run Keyword And Ignore Error    UE PDU Session Release   ue_id=${ue_id}   pdu=1
      Run Keyword And Ignore Error    UE Deregister            ue_id=${ue_id}
    END
