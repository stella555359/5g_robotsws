*** Settings ***
Documentation
...
...             Resources for CB006597

Library     ute_ue
Library     taf.rfrl.ue.logs.qxdm_logs.QxdmLogsCollector      WITH NAME  QxdmLogsCollector
Library     taf.rfrl.ue.logs.qxdm_logs.LicenseKeeperKeywords  WITH NAME  LicenseKeeperKeywords
Library     attenuator_keywords.py
Library     resources_CB006597.py
Library     pcap_parser.py     WITH NAME   parser

*** Keywords ***
Attenuate DU
    [Documentation]     Change attenuation on ports
    ...     :param attenuate_ports: port numbers to be attenuated
    ...     :param restore_ports: port numbers where attenuation is to be set to 0
    [Arguments]     ${attenuate_ports}      ${restore_ports}
    Initialise Attenuator
    Set attenuation                             value_string=0
    ...                                         port=${restore_ports}
    Gradually increase attenuation              max_value=110
    ...                                         step=10
    ...                                         interval=10
    ...                                         port=${attenuate_ports}

Restore attenuation
    [Documentation]     Restore attenuation to original values
    Initialise Attenuator
    Set attenuation                             value_string=0
    ...                                         port=${ports_gnb1}
    Set attenuation                             value_string=110
    ...                                         port=${ports_gnb2}

Extract syslog
    [Documentation]     Extract syslog to a given clear log directory
    ...     :param directory: syslog location
    [Arguments]     ${directory}
    log to console      ${directory}
    Run    tar -xf ${directory}/btslog_REST_GNB0_DU0_76004_76004/syslog_files.tgz -C ${directory}

Commission feature CB006597
    [Documentation]     Commission feature CB006597
    Perform Configuration Parameter Recommissioning On gNB
    ...                                         dist_name=MRBTS-{}/NRBTS-{}
    ...                                         param_name=actRrcReleasePreference
    ...                                         operation=update
    ...                                         param_value=true
    ...                                         skip_parameter_relation_errors=${true}

Decommission feature CB006597
    [Documentation]     Decommission feature CB006597
    Perform Configuration Parameter Recommissioning On gNB
    ...                                         dist_name=MRBTS-{}/NRBTS-{}
    ...                                         param_name=actRrcReleasePreference
    ...                                         operation=update
    ...                                         param_value=false
    ...                                         skip_parameter_relation_errors=${true}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ute_ue.Require UE                           ue_alias=${UE_alias}
    ...                                         capabilities=${capabilities}
    ute_ue.Detach UE                            ue_alias=${UE_alias}

Check if counter in range
    [Documentation]     Check if counter in desired range
    ...     :param counter: counter id
    ...     :param counter_min: counter min value
    ...     :param counter_max: counter max value
    [Arguments]     ${counter}     ${counter_min}       ${counter_max}
    Run Keyword If     not (${counter_min} <= ${counter} <= ${counter_max})     Fail

Check CB006597 syslog messages
    [Documentation]     Verify if OutOfConnected messages in syslog
    ...     :param directory: syslog location
    [Arguments]     ${directory}
    Extract syslog      directory=${directory}
    search_syslog_for_message                   message=sending messages::e1ap::BearerContextReleaseCommand
    ...                                         syslog_dir=${directory}
    search_syslog_for_message                   message=Remove UE context
    ...                                         syslog_dir=${directory}
    search_syslog_for_message                   message=[Message] received F1APUeContextReleaseComplete
    ...                                         syslog_dir=${directory}

Check ngap messages in pcap
    [Documentation]     Verify if OutOfConnected messages in pcap
    ...     :param directory: pcap location
    [Arguments]     ${directory}
    parser.check_pcap_entry_value               pcap_dir=${directory}
    ...                                         display_filter=ngap.UEContextReleaseRequest_element
    ...                                         parameter=ngap.radioNetwork
    ...                                         value=unspecified
    parser.check_pcap_entry_value               pcap_dir=${directory}
    ...                                         display_filter=ngap.UEContextReleaseCommand_element
    parser.check_pcap_entry_value               pcap_dir=${directory}
    ...                                         display_filter=ngap.UEContextReleaseComplete_element

Check HO messages
    [Documentation]     Verify if HO messages in pcap
    ...     :param directory: pcap location
    [Arguments]     ${directory}
    parser.check_HO_messages                    pcap_dir=${directory}
    ...                                         message=xnap_16_5_0_2103_n03.HandoverRequest_element
    parser.check_HO_messages                    pcap_dir=${directory}
    ...                                         message=xnap_16_5_0_2103_n03.HandoverRequestAcknowledge_element
    parser.check_HO_messages                    pcap_dir=${directory}
    ...                                         message=xnap_16_5_0_2103_n03.SNStatusTransfer_element
    parser.check_HO_messages                    pcap_dir=${directory}
    ...                                         message=xnap_16_5_0_2103_n03.UEContextRelease_element


Start QXDM collection
    [Arguments]     ${collection_time}
    Kill All QXDM processes
    Upload QxdmLogCatch Script
    Extend QXDM and QCAT license
    Start Collecting QXDM logs                  duration=${collection_time}

Download QXDM log
    [Arguments]     ${log_dir}
    Wait till collecting qxdm hdf log is finished
    Convert QXDM log to txt
    qxdm_collection.Download QXDM logs          log_dir=${log_dir}
