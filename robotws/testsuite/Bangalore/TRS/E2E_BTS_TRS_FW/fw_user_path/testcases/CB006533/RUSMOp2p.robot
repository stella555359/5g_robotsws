*** Settings ***
Documentation
...     [Author]        "Shweta Naikodi"
...     [Maintenance]   "TRS ST Bangalore Team"
...     [Procedure]     "The test case is planned to verify TCP traffic from SMO to ORU and  SSH traffic from ORU"
...     [Date]          "20-05-2024"
...     [Feature_ID]    "CB006533"
...     [Requirement ID]    "OM_GEN_SFS_RNWINT.6751;TT_IPT.3039;TT_IPT.3034;OAM_REQ_TRSSEC_144;TT_NCONF.2401"
...     [Config]    "This script requires ORU configuration,CB006533, CB008016, CB007255 flags to be enabled."
...     [RunTime Parameters]    "bts_id used is 6533"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Topology]              "ASIL+ABIO+ORU ASIL+ABIL+ORU Dual core setup with ORU"
...     [Function_Hash_Tags]    "Traffic, SSH , TCP"

Resource        ${CURDIR}/../CB006533/resources/Common_6533keyword.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops




*** Test Cases ***
[1]CB006533_Q_Verify BTS supports M-plane IP traffic routing between FH and BH at BTS with IPv6 address configured for O-RU_eCPRI P2P case
     Perform Commissioning       scf_file=${RUSMO_scf}   verify_bts_status=${True}     timeout=350     alias=defaut
     GET IPS
     check routes in smo
     SMO initiated traffic verification on 1st ORU
     SMO initiated traffic verification on 2nd ORU
     ORU initiated traffic verification
     SSH traffic verification
     RU reset
     SSH traffic verification after RU reset
     [Teardown]  Reload BTS

