*** Settings ***
Library     taf.ul.gnb.bip.collection   WITH NAME   bip_collection
Library     taf.collectors.l1l2bip      WITH NAME   l1l2bip
Resource    testline.robot

*** Keywords ***
Start BIP Traces
    [Documentation]
    ...
    ...    Wrapper for different trace types
    ...
    ...    | gnb_id    | Id/Number of gNB |
    ...    | option    | Any additional tcpdump options necessary as per user requirements |
    ...    | collector | Name of collector *Impact on log filename* |
    ...    | timeout   | Timeout for the single keywords to collect the traces |
    ...
    [Arguments]    ${gnb_id}=${0}
    ...            ${option}=${EMPTY}
    ...            ${collector}=gnb-${gnb_id}-bip-tcpdump
    ...            ${timeout}=300

    ${comu_type}=  testline.Get Common Unit Type
    Run keyword if  '${comu_type}' == 'ASIM'
    ...  Start BIP Traces with user library
    ...          gnb_id=${gnb_id}
    ...  ELSE
    ...      Start BIP Traces with taf collector
    ...          gnb_id=${gnb_id}
    ...          collector=${collector}
    ...          timeout=${timeout}
    ...          merge_pcap_files=${True}
    ...          remove_zip_file=${True}



Stop BIP Traces
    [Documentation]
    ...
    ...    Wrapper for different trace types
    ...
    ...    | gnb_id |  Id/Number of gNB |
    ...    | collector |  Name of collector used at start command |
    ...    | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to BIP trace file
    ...

    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=gnb-${gnb_id}-bip-tcpdump
    ...            ${target_dir}=${None}

    ${comu_type}=  testline.Get Common Unit Type
    ${outfile}=  Run keyword if  '${comu_type}' == 'ASIM'
    ...      Stop BIB Traces with user library
    ...          gnb_id=${gnb_id}
    ...          target_dir=${target_dir}
    ...  ELSE
    ...      Stop BIP Traces with taf collector
    ...          collector=${collector}
    ...          target_dir=${target_dir}

    [RETURN]  ${outfile}


Start BIP Traces with user library
    [Documentation]
    ...    Start gNB BIP traces, here library taf.ul.gnb.bip.collection is used
    ...
    ...    | gnb_id |  Id/Number of gNB     |
    [Arguments]    ${gnb_id}=${0}
    bip_collection.Use Mirror Script
    bip_collection.Start BIP Trace    gnb_id=${gnb_id}
    BuiltIn.Log    \ngNB${gnb_id} BIP traces (user library) started successfully    console=${P_console}


Stop BIB Traces with user library

    [Documentation]
    ...    Logs are stored in Testcase Log directory by default
    ...
    ...    | gnb_id |  (default=0) Id/Number of gNB |
    ...    | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file incl. filename
    ...
    [Arguments]    ${gnb_id}=${0}  ${target_dir}=${None}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${outfile}=  bip_collection.Stop BIP Trace    gnb_id=${gnb_id}    target_dir=${target_dir}
    BuiltIn.Log    \ngNB${gnb_id} BIP traces stopped and collected successfully    console=${P_console}
    [RETURN]    ${outfile}


Start BIP Traces with taf collector
    [Documentation]
    ...    Start gNB BIP traces using taf.collectors.l1l2bip
    ...
    ...    | gnb_id               | Id/Number of gNB |
    ...    | collector            | name of collector |
    ...    | merge_pcap_files     | whether the pcap files should be merged or not default: True files will be merged. |
    ...    | remove_zip_file=None | flag for deleting zip file after extracting all pcap files. |

    [Arguments]    ${gnb_id}=${0}
    ...            ${collector}=bip_traces
    ...            ${timeout}=300
    ...            ${merge_pcap_files}=${True}
    ...            ${remove_zip_file}=${True}

    ${webservice}=   Get Webservice For Collector   ${tl}   ${gnb_id}

    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${collector}
    ...  webservice=${webservice}
    ...  timeout=${timeout}
    ...  merge_pcap_files=${merge_pcap_files}
    ...  remove_zip_file=${remove_zip_file}

    core.setup_collectors    names=${collector}
    core.start_collectors    names=${collector}
    core.set_suite_alias  ${collector}

    [Return]   ${collector}


Stop BIP Traces with taf collector
    [Documentation]
    ...  | collector | name of collector
    ...  | target_dir | Directory to store the pcap file
    [Arguments]     ${collector}
    ...             ${target_dir}=${None}

    ${target_dir}=    Run Keyword If    '${target_dir}'=='${None}'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}

    core.stop_collectors       names=${collector}
    core.collect_collectors    names=${collector}  target_dir=${target_dir}
    core.teardown_collectors   names=${collector}

    ${pcap_files}=    List Files In Directory    ${target_dir}/${collector}   *.pcap

    ${pcap_full_paths}=    Create List
    FOR    ${file}   IN   @{pcap_files}
        ${full_path}   Join Path    ${target_dir}/${collector}   ${file}
        Append To List    ${pcap_full_paths}   ${full_path}
    END

    [Return]    ${pcap_full_paths}
