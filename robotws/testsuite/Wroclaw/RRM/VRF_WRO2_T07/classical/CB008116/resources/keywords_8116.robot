*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB008116


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/test_specific_keywords_8116.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/test_specific_keywords_8116.py


*** Keywords ***
CB008116-A_1_Integrity_Protection_in_DL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and AES IP algorithm.
	Setup and check preconditions in scf   params_to_check=${aes_params}
    Start DL data transfer and collect L1L2
    Check Maximum UE Rate In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Prot Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Setup Request   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap


CB008116-A_2_Integrity_Protection_in_DL_with_SNOW_3G_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and SNOW 3G algorithm.
    Setup and check preconditions in scf   params_to_check=${snow_params}
    Start DL data transfer and collect L1L2
    Check Maximum UE Rate In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Prot Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Setup Request   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap


CB008116-A_3_Integrity_Protection_in_DL_with_ZUC_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in DL direction and ZUC algorithm.
    Setup and check preconditions in scf   params_to_check=${zuc_params}
    Start DL data transfer and collect L1L2
    Check Maximum UE Rate In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Prot Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Setup Request   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap


CB008116-A_4_Integrity_Protection_in_UL_with_AES_IP_algorithm_ASIB_ABIO
    [Documentation]   This test case describes the behavior of Nokia gNB in SA mode for the successful setup
     ...              and operation of integrity protection for user plane traffic at any data rate,
     ...              up to and including, the highest data rate supported by the 5G-UE in UL direction and AES IP algorithm
    Setup and check preconditions in scf   params_to_check=${aes_params}
    Start UL data transfer and collect L1L2
    Check Maximum UE Rate In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Prot Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Algorithm for AES In Pcap Log   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Setup Request   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
