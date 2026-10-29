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
...             On a TL, in /home/ute/testline_init_results/logs/INFO_log.txt file (case: agent-sim),
...             or in /home/ute/testline_init_results/agent.log file (case agent-ca),
...             There is a field providing the full name of the topology of the TL, as reserved thru UTE Cloud tool.
...             This can be something like : CLOUD_5G_I_BO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD.
...             This descriptor is a concatenation of some tags (CLOUD_5G, _I_, BO, AP_LO, SANSA, FS, ECPRI, CWWV, TDD),
...             each of them representing a specific characteristic of the TL.
...             They are as follows:
...
...             | ARCHI      | CLOUD_5G for classical, CLOUD_5GC for VRAN, ...      |
...             | GNB HW     | BL (ASIB/ABIL), BO (ASIB/ABIO), LO (ASIL/ABIO), ...  |
...             | SIMU HW    | AP_LO (Airphone ASIL/ABIO), ...                      |
...             | DEPLOYMENT | SA, NSA, SANSA                                       |
...             | L1         | FS (Full Stack), L1BP (L1 ByPass)                    |
...             | FH MODE    | CPRI, ECPRI                                          |
...             | RF MODE    | CMWV, MMWV                                           |
...             | DUPLEX     | TDD, FDD                                             |
...
...             At Suite Setup step, this file is parsed and analyzed (Topology.py),
...             And main charateristics are displayed. The number of GNBs and VMwts
...             is also computed and displayed.
...
...             The library provides also some services to get some fields and some toggle flags
...             as global variables, to ease writing tests requiring different behavior upon their values.
...
...             *Example:*
...
...             | Run keyword if \ \ \ \${isSANSA}\ \ \ \Do Action1\ \ \ \ \ Do Action2|


Library                             ../../../RRM/ET/resources/python/luashark_tools.py
Library                             luashark_tools.analyzer      WITH NAME   analyzer
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
    Set Suite Variable              ${isAic}
    ${isRinLine2}                   Call method                             ${TLConfig.topo}    isRinLine2
    Set Suite Variable              ${isRinLine2}
    ${isClassical}                  Call method                             ${TLConfig.topo}    isClassical
    Set Suite Variable              ${isClassical}
    ${duplexMode}                   Call method                             ${TLConfig.topo}    getDuplexMode
    Set Suite Variable              ${duplexMode}
    # Compute number of GNBs in topology
    ${nbGNB}                        Call Method                             ${TLConfig.topo}    getNbGNB
    Set Suite Variable              ${nbGNB}
    # FTS adding, Compute number of VMwts in topology
    ${nbVMwts}                         Call Method                             ${TLConfig.topo}    getnbVMwts
    Set Suite Variable              ${nbVMwts}
    Dated Log                Topology has ${nbGNB} GNBs and ${nbVMwts} WTS (Airphones)
    # Add Global variable to know ran type
    ${isORAN}                       Call Method                             ${TLConfig.topo}    isORAN
    Set Suite Variable              ${isORAN}
    # VRAN case: install McShark if needed (to be reactivated if needed)
    # Run keyword if                  ${isAic} or ${isRinLine2}               WA for McShark Installation

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

WA for McShark Installation
    [Documentation]                 This KW check the presence of the mcshark.buster.so and re-install it if its size is not relevant
    # Get info on mcshark installation:
    ${sw_build}=                    analyzer.getBuild
    ${file_path}=                   analyzer.get_analyzer_path
    ${file_size}=                   run                     stat -c "%s" ${file_path}
    # Check of mcshark installation:
    Run Keyword If  ${file_size} <= 100
    ...             Run Keywords    Dated Log New Line      WARNING: McShark is incorrectly installed because the file size is only ${file_size}
    ...                     AND     Dated Log               \t ===> Deleting bad McShark file...
    ...                     AND     run                     rm -f ${file_path}
    ...                     AND     Dated Log               \t ===> ${sw_build} McShark installation in progress...
    ...                     AND     analyzer.do_install_analyzer
    ...                     AND     Dated Log               \t ===> ${sw_build} McShark installation finished.
    # Check of mcshark re-installation:
    ${new_file_size}=               run                     stat -c "%s" ${file_path}
    Run Keyword If  ${new_file_size} <= 100
    ...             Run Keywords    Dated Log New Line      ERROR: McSHARK IS STILL INCORRECTLY INSTALLED AS THE FILE SIZE IS ONLY ${new_file_size}
    ...                     AND     Dated Log               ERROR: PLEASE CHECK THE LOG WHY THE INSTALLATION WAS NOT SUCCESSFUL.
    ...         ELSE                Dated Log New Line      ----INFO: McShark is correctly installed as the file size is: ${new_file_size}
