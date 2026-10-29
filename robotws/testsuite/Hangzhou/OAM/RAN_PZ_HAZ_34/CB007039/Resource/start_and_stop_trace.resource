*** Settings ***
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core

***keywords***
Start TTITrace and Sherpa
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ...  release=SBTS22R4    #Optional, Default it takes latest release
    ${l2_stream_config_1}=  Create Dictionary
    ...  up_sw=L2HiRlc
    ...  trace_type=Component

    ${l2_stream_config_1_1}=  Create Dictionary
    ...  up_sw=L2HiPdcp
    ...  trace_type=Component

    ${l2_stream_config_2}=  Create Dictionary
    ...  up_sw=L2HiRlc
    ...  trace_type=Sherpa

    ${l2_stream_config_2_1}=  Create Dictionary
    ...  up_sw=L2HiPdcp
    ...  trace_type=Sherpa


    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}     ${l2_stream_config_1_1}    ${l2_stream_config_2_1}    ${l2_stream_config_2}
#    tcpdump.create tcpdump collector
#    ...  name=tcpdump
#    ...  options=-i eth1 udp and dst 10.57.167.40 and dst port 5678
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  source_ip_addr=10.71.211.228
    ...  destination_ip_addr=10.57.167.40
    ...  dscp=0
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}

    l2stream3.Set Suite Alias     l2stream3

    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3

Stop TTITrace and Sherpa
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3
    core.teardown_collectors    names=l2stream3