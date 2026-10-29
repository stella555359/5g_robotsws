*** Settings ***
Resource    ../tshark.robot
Resource    ../testline.robot
Library     OperatingSystem


*** Test Cases ***
Test Start Stop Tshark on Test PC Eth0
    [TAGS]              TSHARK
    Start Tshark on Test PC     collector=trace_eth3    options=-i eth0
    Sleep                       2s  Wait 2s to collect some packets!
    ${tshark_dump_file}         Stop Tshark on Test PC  collector=trace_eth3
    File Should Exist           ${tshark_dump_file}
    File Should Not Be Empty    ${tshark_dump_file}

Test Start Tshark on S1 Interface of TestPC
    [TAGS]              TSHARK
    ${enb_type}     Run Keyword If  $tl.enbs is None
    ...             Pass Execution  Test/KW belongs to TL with real Enb only!
    ...     ELSE    Set Variable   ${tl_info.deployment_type(node_id=${0}, node_type='enb')}
    Run Keyword If  '${enb_type}'=='simulated'
    ...             Pass Execution  Test/KW isn't applicable for simulated Enb!
    ${s1_collector}             Start Tshark on S1 Interface of TestPC
    Sleep                       2s  Wait 2s to collect some packets!
    ${tshark_dump_file}         Stop Tshark on Test PC  collector=${s1_collector}
    File Should Exist           ${tshark_dump_file}
    File Should Not Be Empty    ${tshark_dump_file}

Test Start Tshark for Trace Session
    [TAGS]              TSHARK
    ${tce_collector}                Start Tshark for Trace Session
    Sleep                       2s  Wait 2s to collect some packets!
    ${tshark_dump_file}         Stop Tshark on Test PC  collector=${tce_collector}
    File Should Exist           ${tshark_dump_file}
    File Should Not Be Empty    ${tshark_dump_file}
