*** Settings ***
Documentation    RF resource for cplane coolection puproses. Keywords base on tcpdump which is runned on sysmod.
...              An output file is collected as a .pcap it propably needs to parsed as pdml or json.
...              Simple usage ex.
...                  Setup and start cplane logs <- setup and start tcpdumps on sysmod
...                  Here is a test logics
...                  Stop cplane logs <- stop tcpdump and get .pcap file
...                  Here can be parsing and veryfication logic

Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library          taf.collectors.tcpdump     WITH NAME    tcpdump

*** Keywords ***
Setup cplane tcpdump collector
    [Arguments]
    ...    ${name}=cplane_collector
    ...    ${host}=192.168.255.129

    Set suite variable    ${cplane_collector}    ${name}
    ${sysmod_executor}    Create Dictionary
    ...     host=${host}
    ...     user=toor4nsn
    ...     password=oZPS0POrRieRtu

    tcpdump.create_tcpdump_collector
    ...     name=${cplane_collector}
    ...     options=-i any sctp
    ...     executor=${sysmod_executor}
    core.Setup collectors    ${cplane_collector}
    core.Set Suite Alias     ${cplane_collector}

Start cplane logs
    log to console    starting cplane logs
    core.Start collectors    ${cplane_collector}

Stop cplane logs
    [Arguments]    ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/
    log to console    stopping cplane logs
    core.Stop collectors      ${cplane_collector}
    core.Collect collectors   ${cplane_collector}    target_dir=${log_dir}
    core.Teardown collectors    ${cplane_collector}

Setup and start cplane logs
    Setup cplane tcpdump collector
    Start cplane logs
