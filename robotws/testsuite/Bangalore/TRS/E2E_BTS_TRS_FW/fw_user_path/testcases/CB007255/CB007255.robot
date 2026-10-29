*** Settings ***
Documentation

...        [Procedure]        "[1][1.0] CB007255-B_verification of VLAN, PCP & DSCP check for M-Plane & CU-Plane configuriton."
...        [Date]             "11-10-2022"
...        [Author]           "Harsimran"
...        [Feature_ID]       "CB007255"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "DSCP,VLAN,PCP delta modification"
...        [DELTA_FILE_DEPENDENCY]  ""
...        [Validated_TestLine]     "IAV_BLR_2019"
...        [Config_Comments]         ""
...        [Precondition]             "ENodeB should be integrated to Netact"

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/CB007255_Keywords.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00      SBTS21B    SBTS23R1    SBTS23R2      4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

***Test Cases***
[1][1.0] CB007255-B_verification of VLAN, PCP & DSCP check for M-Plane & CU-Plane configuriton.
  Perform Commissioning       scf_file=${Master-scfc}     verify_bts_status=True        timeout=1200      wait_for_bts_to_be_ready=500
  Setup Ems  config_device=netact2005   alias=lab2005
  Cm Upload   config_device=netact2005 	alias=lab2005
  Check Mplane is tagged with configured vlan with feature enabled
  Modify vlan in ETHIF Moc
  Modify vlan,dscp,pcp in mplanefhnw and verify in BBMOD
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005
