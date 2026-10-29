*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage Topology description of the TL
...
...             == Description ==
...             This library is a Wrapper on python services from Topology.py
...
...             *Concepts:*.
...
...             On a TL, in /home/ute/testline_init_results/logs/INFO_log.txt file,
...             There is a field providing the full name of the topology of the TL, as reserved thru UTE Cloud tool.
...             This can be something like : CLOUD_5G_I_BO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD.
...             This descriptor is a concatenation of some tags (CLOUD_5G, _I_, BO, AP_LO, SANSA, FS, ECPRI, CWWV, TDD),
...             each of them representing a specific characteristic of the TL.
...             They are as follows:
...
...             | ARCHI      | CLOUD_5G foir classical, CLOUD_5GC for CloudBTS, ... |
...             | GNB HW     | KL (ASIK/ABIL), BL (ASIB/ABIL)|, ...                 |
...             | SIMU HW    | AP_KL (Airphone ASIK/ABIL), ...                      |
...             | DEPLOYMENT | SA, NSA, SANSA                                       |
...             | L1         | FS (Full Stack), L1BP (L1 ByPass)                    |
...             | FH MODE    | CPRI, ECPRI                                          |
...             | RF MODE    | CMWV, MMWV                                           |
...             | DUPLEX     | TDD, FDD                                             |
...
...             At Suite Setup step, this file is parsed and analyzed (Topology.py),
...             And main charcateristics are displayed.
...             Then, this library provides some services to get some fields, and provide toogle flags
...             as global variables, to ease write of tests requiring different behavior upon their values.
...
...             *Example:*
...
...             | Run keyword if \ \ \ \${isSANSA}\ \ \ \Do Action1\ \ \ \ \ Do Action2|


Library                             ../python/Topology.py        WITH NAME   Topo

*** Keywords ***
TOPO Read
    [Documentation]                 INTERNAL USAGE
    ...                             Service to parse INFO_log.txt and build topology instance,
    ...                             then set all toogle flags
    ...                             This service is internal since it is called automatically by Suite Setup
    ...                             And there is no use to call it another time
    # Read topology and display it, field by field
    ${TLConfig.topo}                Topo.set
    call method                     ${TLConfig.topo}                        display
    # Set some toogle flags
    ${isSANSA}                      TOPO isSANSA
    Set Suite Variable              ${isSANSA}
    ${isDeploySA}                   TOPO isDeploySA
    Set Suite Variable              ${isDeploySA}
    ${isAic}                        Call method                             ${TLConfig.topo}    isAic
    ${isClassical}                  Call method                             ${TLConfig.topo}    isClassical
    ${isCloudBts}                   Call method                             ${TLConfig.topo}    isCloudBts
    Set Suite Variable              ${isAic}
    Set Suite Variable              ${isClassical}
    Set Suite Variable              ${isCloudBts}

TOPO isSANSA
    [Documentation]                 Update global variable flag : isSANSA
    ...                             to indicate if topology is SANSA or not
    ${isSANSA}                      Call method                             ${TLConfig.topo}
    ...                             isSANSA
    [Return]                        ${isSANSA}

TOPO isDeploySA
    [Documentation]                 Update global variable flag : isDeploySA
    ...                             isDeploySA is True if :
    ...                             1) topology is SA
    ...                             2) topology is SANSA and flag SA is activated thru robot command
    ...                             to indicate we want to do some SA tests
    ${isDeploySA}                   Call method                             ${TLConfig.topo}
    ...                             isDeploySA
    [Return]                        ${isDeploySA}

