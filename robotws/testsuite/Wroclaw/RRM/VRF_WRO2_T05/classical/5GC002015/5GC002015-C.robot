*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com
...   This is the ROBOT for feature 5GC002015-C 10MHz 64 QAM and 20MHz 256 QAM

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002015/resources/keywords_2015.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_kw.py
Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/variables.py
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot


#Force Tags      CA_5G_RRM   QCD_MN_5G   QCP_5G   5G_RAN  5G_RAN_FDD  5G_RAN_FDD_MP   STATE_ON_AIR   CIT

#
#Suite Setup     Run keywords
#      ...       Connecting to Coam      AND
#      ...       Reserve UEs For tests
#
#
#Suite Teardown  Run keywords
#        ...     Disconnecting from Coam


*** Variables ***
${UE_mode}              NSA
${UE_name}              UE_1
${alias_dt_dl}          DT_DL_NSA
${alias_dt_ul}          DT_UL_NSA


*** Keywords ***
[1]5GC002015_C_11_5GC002015_C_TC_11_SA_Classical_attach_traffic_with_1_DMRS_10Mhz_64QAM_2_2_MIMO_MCS20
    [Documentation]    The purpose of this test 5GC002015-C_Func_1Call1S_Tput_Class_ASIK_ABIL_10MHz_64QAM_2x2_DMRS_1UE
    ...                is to verify that there's an increase in DL throughput at the threshold MCS
    ...                when PDSCH_DMRS_FDM is activated.
    ...                This test uses bidirectional traffic with one single symbol DMRS instance,
    ...                10MHz bandwidth, 64QAM and DL rank2.

    Set test variable  ${filename}  PCAPs/tcpdumpL2L1_filtering_on_2015-C_11.pcap
    Load scf for NR    ${resource_path_2015}    2015-C_SCFs    2015-C_NR_Configuration_scf.xml
    Turn on parameter actDlDataDmrsFdm
    ...     chBwDl=10MHz
    ...     chBwUl=10MHz
    ...     dlDMRSAdditionalPosition=No additional DMRS
    ...     actDl256Qam=false
    Run Keyword And Ignore Error       Pcap L2L3 collection
    Start L1L2 Logs                       30          50
    Attach UE       ${UE_name}
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
#    Check UE IP     ${UE_name}    ${UE_mode}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    Stop L1L2 Logs And Download PCAP    30    ${UE_mode}    ASIK    dir=${OUTPUT DIR}/${filename}
    ${tpt_feature_on}           Get Average Throughput     ${alias_dt_dl}
    Detach UE    ${UE_name}
    Turn off parameter actDlDataDmrsFdm
    Attach UE    ${UE_name}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_off}          Get Average Throughput     ${alias_dt_dl}
    Detach UE    ${UE_name}
    Run Keyword And Ignore Error       Pcap L2L3 log download
    keywords_2015.Compare Two Truputs             ${tpt_feature_on}       ${tpt_feature_off}
    Check Amount Of MCS


[1]5GC002015_C_10_5GC002015_C_TC_10_SA_Classical_attach_traffic_with_2_DMRS_20Mhz_256QAM_2_2_MIMO
    [Documentation]    The purpose of this test 5GC002015-C_Func_1Call1S_Tput_Class_ASIK_ABIL_20MHz_256QAM_2x2_DMRS_1UE
    ...                is to verify that there's an increase in DL throughput at higher MCS when
    ...                PDSCH_DMRS_FDM is activated.
    ...                This test uses bidirectional traffic with two single symbol DMRS
    ...                instances (one additional DMRS), 20MHz bandwidth, 256QAM and DL rank2

    Set test variable  ${filename}  PCAPs/tcpdumpL2L1_filtering_on_2015-C_10.pcap
    Load scf for NR    ${resource_path_2015}    2015-C_SCFs    2015-C_NR_Configuration_scf.xml
    Turn on parameter actDlDataDmrsFdm
        ...     chBwDl=20MHz
        ...     chBwUl=20MHz
        ...     dlDMRSAdditionalPosition=One additional DMRS
        ...     actDl256Qam=true
    Run Keyword And Ignore Error         Pcap L2L3 collection
    Start L1L2 Logs                       30          50
    Attach UE       ${UE_name}
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
#    Check UE IP     ${UE_name}    ${UE_mode}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_on}           Get Average Throughput     ${alias_dt_dl}
    Stop L1L2 Logs And Download PCAP    30    ${UE_mode}    ASIK    dir=${OUTPUT DIR}/${filename}
    Detach UE    ${UE_name}
    Turn off parameter actDlDataDmrsFdm
    Attach UE    ${UE_name}
    Start Traffic UDP DLUL                 ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_off}          Get Average Throughput      ${alias_dt_dl}
    Detach UE    ${UE_name}
    Run Keyword And Ignore Error        Pcap L2L3 log download
    keywords_2015.Compare Two Truputs             ${tpt_feature_on}       ${tpt_feature_off}
    Check Amount Of MCS


[1]5GC002015_C_12_5GC002015_C_TC_12_SA_Classical_attach_traffic_with_1_DMRS_10Mhz_256QAM_2_2_MIMO_MCS20
        [Documentation]    The purpose of this test
    ...                5GC002015-C_Func_1Call1S_Tput_Class_ASIK_ABIL_20MHz_256QAM_2x2_DMRS_1UE
    ...                is to verify that there's an increase in DL throughput at higher MCS when
    ...                PDSCH_DMRS_FDM is activated.
    ...                This test uses bidirectional traffic with two single symbol DMRS
    ...                instances (one additional DMRS), 10MHz bandwidth, 256QAM and DL rank2

    Set test variable  ${filename}  PCAPs/tcpdumpL2L1_filtering_on_2015-C_12.pcap
    Load scf for NR    ${resource_path_2015}    2015-C_SCFs    2015-C_NR_Configuration_scf.xml
    Turn on parameter actDlDataDmrsFdm
    ...     chBwDl=10MHz
    ...     chBwUl=10MHz
    ...     dlDMRSAdditionalPosition=No additional DMRS
    ...     actDl256Qam=true
    Run Keyword And Ignore Error       Pcap L2L3 collection
    Start L1L2 Logs                       30          50
    Attach UE       ${UE_name}
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
#    Check UE IP     ${UE_name}    ${UE_mode}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    Stop L1L2 Logs And Download PCAP    30    ${UE_mode}    ASIK    dir=${OUTPUT DIR}/${filename}
    ${tpt_feature_on}           Get Average Throughput     ${alias_dt_dl}
    Detach UE    ${UE_name}
    Turn off parameter actDlDataDmrsFdm
    Attach UE    ${UE_name}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_off}          Get Average Throughput     ${alias_dt_dl}
    Detach UE    ${UE_name}
    Run Keyword And Ignore Error       Pcap L2L3 log download
    keywords_2015.Compare Two Truputs             ${tpt_feature_on}       ${tpt_feature_off}
    Check Amount Of MCS


[1]5GC002015_C_22_5GC002015_C_TC_22_SA_Classical_attach_DL_traffic_with_2_DMRS_5Mhz_256QAM_2_2_MIMO
    [Documentation]    The purpose of this test
    ...                5GC002015-C_Func_1Call1S_Tput_Class_ASIK_ABIL_20MHz_256QAM_2x2_DMRS_1UE
    ...                is to verify that there's an increase in DL throughput at higher MCS when
    ...                PDSCH_DMRS_FDM is activated.
    ...                This test uses bidirectional traffic with two single symbol DMRS
    ...                instances (one additional DMRS), 5MHz bandwidth, 256QAM and DL rank2

    Set test variable  ${filename}  PCAPs/tcpdumpL2L1_filtering_on_2015-C_22.pcap
    Turn on parameter actDlDataDmrsFdm
        ...     chBwDl=5MHz
        ...     chBwUl=5MHz
        ...     dlDMRSAdditionalPosition=One additional DMRS
        ...     actDl256Qam=true
    Run Keyword And Ignore Error         Pcap L2L3 collection
    Start L1L2 Logs                       30          50
    Attach UE       ${UE_name}
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
#    Check UE IP     ${UE_name}    ${UE_mode}
    Start Traffic UDP DLUL                ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_on}           Get Average Throughput     ${alias_dt_dl}
    Stop L1L2 Logs And Download PCAP    100   ${UE_mode}    ASIK    dir=${OUTPUT DIR}/${filename}
    Detach UE    ${UE_name}
    Turn off parameter actDlDataDmrsFdm
    Attach UE    ${UE_name}
    Start Traffic UDP DLUL                 ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_off}          Get Average Throughput      ${alias_dt_dl}
    Detach UE    ${UE_name}
    Run Keyword And Ignore Error        Pcap L2L3 log download
    keywords_2015.Compare Two Truputs             ${tpt_feature_on}       ${tpt_feature_off}
    Check Amount Of MCS


[1]5GC002015_C_26_5GC002015_C_TC_26_SA_Classical_attach_Bidir_traffic_with_2_DMRS_15Mhz_64QAM_2_2_MIMO_with_PDSCH_at_SSB_Slots
    [Documentation]    The purpose of this test 5GC002015-C_Func_1Call1S_Tput_Class_ASIK_ABIL_20MHz_256QAM_2x2_DMRS_1UE
    ...                is to verify that there's an increase in DL throughput at higher MCS when
    ...                PDSCH_DMRS_FDM is activated.
    ...                This test uses bidirectional traffic with two single symbol DMRS
    ...                instances (one additional DMRS), 20MHz bandwidth, 256QAM and DL rank2

    Set test variable  ${filename}  PCAPs/tcpdumpL2L1_filtering_on_2015-C_26.pcap
    Load scf for NR    ${resource_path_2015}    2015-C_SCFs    2015-C_26.xml
    Run Keyword And Ignore Error  Check adb devices
    Run Keyword And Ignore Error         Pcap L2L3 collection
    Start New L1L2 Logs
    Wait until keyword succeeds  5x  10 seconds    Attach UE     ${UE_name}
    ${UE_IP}    ute_ue.Get Ue Info    UE_1   IP
    Start ULDL UDP NSA    100Mbits/sec   15MBits/sec
    ${tpt_feature_on}           Get Average Throughput     ${alias_dt_dl}
    Stop New L1L2 Logs And Download PCAP
    Stop Data Transfer    DT_DL_NSA
    Stop Data Transfer    DT_UL_NSA
    Run keyword and Ignore Error        Detach UE    ${UE_name}
    #UE Reboot Before Test
    Deactivate feature 2534
    Wait until keyword succeeds  5x  10 seconds    Attach UE     ${UE_name}
    Start Traffic UDP DLUL                 ${UE_name}        ${alias_dt_dl}       ${alias_dt_ul}
    ${tpt_feature_off}          Get Average Throughput      ${alias_dt_dl}
    Stop Data Transfer    DT_DL_NSA
    Stop Data Transfer    DT_UL_NSA
    Run keyword and Ignore Error        Detach UE    ${UE_name}
    Run Keyword And Ignore Error        Pcap L2L3 log download
    keywords_2015.Compare Two Truputs             ${tpt_feature_on}       ${tpt_feature_off}
    Log to Console    >Tput compared with success.<
    keywords_2015.Check Amount Of MCS
    Log to Console    >MCS verified.<
    Verify PM Counters 2015
