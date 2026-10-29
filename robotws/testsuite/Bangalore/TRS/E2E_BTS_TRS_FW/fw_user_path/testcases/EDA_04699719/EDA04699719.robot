*** Settings ***
Documentation
...     [Procedure]             "EDA_04699719Validation of uplane traffic other than 2152"
...     [Author]                "Sahana TC"
...     [Maintenance]           "TRS VRF BLR2"
...     [Procedure]             "The test case is planned to verify c-u-m plane traffic other than sport 2152 via scapy"
...     [Date]                  "25-06-2025"
...     [Feature_ID]            "EDA Action Task For 04699719"
...     [Requirement ID]        ""
...     [Config]                "This script requires basic SCF loading"
...     [RunTime Parameters]    "bts_id used is 2222"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/additional_cert.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/resources/common_eda_keywords.robot


Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][1.0] Verify traffic for M_C_U_plane over IPv4 and IPv6 using source ports other than 2152

      Configure Switch    device=L3switch    command_profile=add_eda_routes
      Install BTS Certificates
      Perform Commissioning       scf_file=${base_scf_b}     verify_bts_status=${True}   timeout=400     alias=default
      Log    Verify BTS condition before sending traffic
      Verify BTS Precondition
      Verify tunnel status with Additional CA
      Scapy initiated traffic
      Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
      Verify Drop Counters
      Log    Verify BTS condition after sending traffic
      Verify BTS Precondition
      Configure Switch    device=L3switch    command_profile=remove_eda_routes
