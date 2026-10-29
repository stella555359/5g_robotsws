*** Settings ***
Documentation
...   author: Marek Halama
...   contact: marek.halama@nokia.com
...   This is the ROBOT KEYWORDS file for feature CNI-98256


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/test_specific_keywords_98256.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008116/resources/test_specific_keywords_98256.py

*** Variables ***
${PM_INTERVAL_98256}=                     5

*** Keywords ***
CNI_98256_B_15_Intra_gNB_HO_with_UPIP_activated_and_IP_preferred
    [Documentation]   This test case aims to check the behavior of Nokia gNB in SA mode
     ...              during the intra gNB Handover with UPIP activated and
     ...              Integrity protection Indication value set to 'preferred'.
	setup_parameters_98256
	initialise attenuator
	${ports_PCI_50}  Create list    5    6    7    8
    ${ports_PCI_51}  Create list    1    2    3    4
    ${ports_other_cells}      Create list    9    10    11    12
	set attenuation             value_string=90            port=${ports_PCI_51}
	set attenuation             value_string=0             port=${ports_PCI_50}
    set attenuation             value_string=90             port=${ports_other_cells}
	GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_98256}
    Start DL data transfer and collect L1L2 98256
    gradually decrease attenuation  init_value=90    min_value=0  step=90  interval=1  port=${ports_PCI_51}
    gradually increase attenuation  init_value=0    max_value=90  step=5  interval=1  port=${ports_PCI_50}
    Log Stop
    Check Maximum UE Rate In Pcap Log 98256   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Pcap Log 98256   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Prot Algorithm for AES In Pcap Log 98256   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Algorithm for AES In Pcap Log 98256   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Setup Request 98256   pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Result In Bearer Context Setup Response 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Result In Initial Context Setup Response 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In PDU Session Resource Setup Request 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Indication In Bearer Context Modification Request 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    Check Integrity Protection Result In Bearer Context Modification Response 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    test_specific_keywords_98256.Check Ipi In Pdu Session Resource Setup Response 98256  pcap_file=${LOG_PATH}/${test_name}_tcpdump_SMOD_MASTER.pcap
    GnbCounter.Wait for next pm period   interval=${PM_INTERVAL_98256}
    Check Ho Attempt Counter
    Check Ho Success Counter
    Check Upip Pref Attempt Counter
    Check Upip Pref Admitted Counter
    Check Upip Pref Not Admitted Counter
    Check Upip Req Attempt Counter
    Check Upip Req Admitted Counter
    Check Upip Failed Counter
