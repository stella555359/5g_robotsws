*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     taf.ul.generic_tshark_json_parser

*** Keywords ***

Create sctp json source
    create json source
    ...    tshark_command=tshark -i eth3 -T json -f 'sctp' -l
    ...    source_alias=eth3_sctp
#    ...    protocol=sctp   # if protocol is enabled, than ip.src filed won't be visible
    ...    filter_as_query=sctp.chunk_type is present
    ...    start=${True}

Expect that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} will be terminated
    expect for records
    ...     sctp.chunk_type eq "7" and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq "8" and ip.src eq "${ip_addr_dst}"
    ...     sctp.chunk_type eq "14" and ip.src eq "${ip_addr_src}"
#    ...     sctp.chunk_type eq 7
#    ...     sctp.chunk_type eq 8
#    ...     sctp.chunk_type eq 14
    ...     expect_alias=sctp_shutdown_shutdownack_shutdowncomplete
    ...     timeout=180


Expect that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} will be established
    expect for records
    ...     sctp.chunk_type eq '1' and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq '2' and ip.src eq "${ip_addr_dst}"
    ...     sctp.chunk_type eq '10' and ip.src eq "${ip_addr_src}"
    ...     sctp.chunk_type eq '11' and ip.src eq "${ip_addr_dst}"
#    ...     sctp.chunk_type eq 1
#    ...     sctp.chunk_type eq 2
#    ...     sctp.chunk_type eq 10
#    ...     sctp.chunk_type eq 11
    ...     expect_alias=sctp_init_initack_cookieecho_cookieack
    ...     timeout=180

Verify that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} has been terminated
    verify that records occurred
    ...     expect_alias=sctp_shutdown_shutdownack_shutdowncomplete

Verify that SCTP connection between ${ip_addr_src} and ${ip_addr_dst} has been established
    verify that records occurred
    ...     expect_alias=sctp_init_initack_cookieecho_cookieack

