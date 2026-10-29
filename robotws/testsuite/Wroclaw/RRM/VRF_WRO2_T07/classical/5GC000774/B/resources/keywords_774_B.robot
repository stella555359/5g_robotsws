*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for ROHC-B

Library          taf.ue
Library          taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    774_B_btslog
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library          testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/B/resources/test_specific_keywords_B.py
Variables        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC000774/B/resources/test_specific_keywords_B.py


*** Variables ***
${pm_interval}              5


*** Keywords ***
5GC000774_B_03_Verification_of_PM_counters_M55320C19001_M55320C19002_M55320C19003_and_M55320C19004
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_b}    bandwidth=20    skip_parameter_relation_errors=${true}
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue    UE_1
    Attach Ue    UE_2
    ${sctp_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    774_B_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   15s
    ${first_call_btslog_dir}=    774_B_btslog.stop_and_collect_btslog           log_name=first_call_btslog

    GnbCounter.Wait for next pm period     interval=${pm_interval}
    ${pi_dir}=   Collect Counters    log_name=TC_03
    check_compressor_decompressor_counters    ${pi_dir}


5GC000774_B_04_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_b}    bandwidth=20    skip_parameter_relation_errors=${true}
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue    UE_1
    Attach Ue    UE_2
    ${sctp_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    774_B_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   15s
    ${first_call_btslog_dir}=    774_B_btslog.stop_and_collect_btslog           log_name=first_call_btslog

    GnbCounter.Wait for next pm period     interval=${pm_interval}
    ${pi_dir}=   Collect Counters    log_name=TC_04

    ${cs_ue}=    get_cs_ue_from_ngap_logs     ${sctp_logs}
    check_rohc_context_counters_04    ${pi_dir}    4    ${cs_ue}


5GC000774_B_05_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_and_M55124C06002_Emergency_Call
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_b}    bandwidth=20    skip_parameter_relation_errors=${true}
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Require Ue   UE_1   capabilities=REAL_UE_SA

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue    UE_1
    ${sctp_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    774_B_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=911   # EMERGENCY CALL
    BuiltIn.Sleep   20s
    ${first_call_btslog_dir}=    774_B_btslog.stop_and_collect_btslog           log_name=first_call_btslog

    GnbCounter.Wait for next pm period     interval=${pm_interval}
    ${pi_dir}=   Collect Counters    log_name=TC_05


5GC000774_B_06_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_Eme_Call_IntragNBintraFreq_HO
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_b}    bandwidth=20    skip_parameter_relation_errors=${true}
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue    UE_1
    Attach Ue    UE_2
    ${sctp_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    774_B_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   15s

    # TODO: perform emergency call over the existing normal call
    Perform Intra HO
    # TODO: drop the emergency call
    ${first_call_btslog_dir}=    774_B_btslog.stop_and_collect_btslog           log_name=first_call_btslog

    GnbCounter.Wait for next pm period     interval=${pm_interval}
    ${pi_dir}=   Collect Counters    log_name=TC_06

    ${cs_ue}=    get_cs_ue_from_ngap_logs     ${sctp_logs}
    check_rohc_context_counters_06    ${pi_dir}    4    ${cs_ue}


5GC000774_B_07_Verification_of_PM_counters_M55135C01001_M55135C01002_M55124C06001_M55124C06002_Voice_Call_IntergNBintraFreq_HO
    Setup and check preconditions in scf   params_to_check=${scf_params_rohc_b}    bandwidth=20    skip_parameter_relation_errors=${true}
    GnbCounter.Wait for next pm period     interval=${pm_interval}

    Require Ue   UE_1   capabilities=REAL_UE_SA
    Require Ue   UE_2   capabilities=REAL_UE_SA

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue    UE_1
    Attach Ue    UE_2
    ${sctp_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    774_B_btslog.start_btslog_on_local_machine     log_name=first_call_btslog
    taf.ue.Start voice call    vc_alias=VC_1    ue_alias=UE_1    to=UE_2
    taf.ue.Await Incoming Voice Call     vc_alias=VC_1    ue_alias=UE_2    action=answer    timeout=20s
    BuiltIn.Sleep   15s
    Perform Inter HO
    BuiltIn.Sleep   10s
    ${first_call_btslog_dir}=    774_B_btslog.stop_and_collect_btslog           log_name=first_call_btslog

    GnbCounter.Wait for next pm period     interval=${pm_interval}
    ${pi_dir}=   Collect Counters    log_name=TC_07

    ${cs_ue}=    get_cs_ue_from_ngap_logs     ${sctp_logs}
    check_rohc_context_counters_07    ${pi_dir}    4    ${cs_ue}


Perform Intra HO
    Gradually increase attenuation      init_value=0    max_value=25    step=2    interval=1    port=${cell_2_gnb_1_ports}


Perform Inter HO
    Gradually increase attenuation      init_value=0    max_value=25    step=2    interval=1    port=${cell_1_gnb_2_ports}


Attach UEs To Different Cells
    Set attenuation    20    port=${cell_1__gnb_1_ports}
    Set attenuation     0    port=${cell_2_gnb_1_ports}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Attach Ue    UE_1


    Set attenuation     0    port=${cell_1__gnb_1_ports}
    Set attenuation    20    port=${cell_2_gnb_1_ports}
    Require Ue   UE_2   capabilities=REAL_UE_SA
    Attach Ue    UE_2
    Nullify attenuation on all ports
#   EACH UE ATTACHED TO A DIFFERENT CELL


Attach UEs To Different gNBs
    Set attenuation    20    port=${cell_1__gnb_1_ports}
    Set attenuation     0    port=${cell_1__gnb_2_ports}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Attach Ue    UE_1


    Set attenuation     0    port=${cell_1__gnb_1_ports}
    Set attenuation    10    port=${cell_1__gnb_2_ports}
    Require Ue   UE_2   capabilities=REAL_UE_SA
    Attach Ue    UE_2
    Nullify attenuation on all ports
#   EACH UE ATTACHED TO A DIFFERENT gNB
