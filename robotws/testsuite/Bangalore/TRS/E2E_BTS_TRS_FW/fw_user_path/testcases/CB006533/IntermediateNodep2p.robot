*** Settings ***
Documentation
...     [Author]        "Shweta Naikodi"
...     [Maintenance]   "TRS ST Bangalore Team"
...     [Procedure]     "The test case is planned to verify traffic from SMO to Intermediate node and viceversa"
...     [Date]          "06-07-2024"
...     [Feature_ID]    "CB006533"
...     [Requirement ID]    "OM_GEN_SFS_RNWINT.6751;TT_IPT.3039;TT_IPT.3034;OAM_REQ_TRSSEC_144;TT_NCONF.2401"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 6533"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../CB006533/resources/Common_6533keyword.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

*** Test Cases ***
[1]CB006533-Q BTS to support Mplane IP traffic routing between FH and BH with IPv6 address configured for INT node eCPRI P2P case
     Perform Commissioning       scf_file=${INTNODE_scf}   verify_bts_status=${True}     timeout=350     alias=defaut
     Get IPS for Intnode
     check routes in int node and smo
     SMO initiated traffic verification
     intermediate node initiated traffic verification
     SMO initiated SSH traffic verification
     intermediatenode initiated SSH traffic verification
     [Teardown]      Reload BTS
