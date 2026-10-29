*** Settings ***
Documentation                       Wrapper on Topology.py services

Library                             ../python/Topology.py        WITH NAME   Topo

*** Keywords ***
TOPO Read
    ${TLConfig.topo}                Topo.set
    call method                     ${TLConfig.topo}                        display
    TOPO Get Flags

TOPO isSANSA
    ${isSANSA}                      Call method                             ${TLConfig.topo}
    ...                             isSANSA
    [Return]                        ${isSANSA}

TOPO isDeploySA
    ${isDeploySA}                   Call method                             ${TLConfig.topo}
    ...                             isDeploySA
    [Return]                        ${isDeploySA}


TOPO Get Flags
    ${isSANSA}                      TOPO isSANSA
    Set Suite Variable              ${isSANSA}
    ${isDeploySA}                   TOPO isDeploySA
    Set Suite Variable              ${isDeploySA}
