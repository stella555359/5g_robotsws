*** Settings ***

Documentation

...        [Procedure]        "TRS_CB007290_alarm_MacSec_connection_lost_alarm_verification_and_connection_restablishment_and_counter_verification"
...        [Date]             "05-03-2024"
...        [Author]           "Harsimran"
...        [Feature_ID]       "CB007290"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "MacSec"
...        [Validated_TestLine]     "IAV_BLR_2020"
...        [Config_Comments]         "MacSec establishment"
...        [Precondition]             "ENodeB should be integrated to Netact"

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/CB007290_Keywords.robot

Force Tags      CA_E2ET_BTSTRSPZ        SBTS00        SBTS21B     SBTS25R1   SBTS25R2   4G_FDD       QCD_MN_RAN        QCP_RAN_VRF       CRT

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

***Test Cases***
[1][1.0] Verification_of_CB007290C_MacSec_termination_at_CellSiteSwitch_with_RU_without_MacSec_capability
    Preconditions
    Enable MACSecWithPSKNoMPlane and Verify MacSec session is up
    Verify FH IPSEC status for RuProtectEnabled
    Configure Wrong cipher suite
    Verify MacSec Connection Setup Failure alarm
    Revert cipersuite value
    verify MacSec Connection Setup Failure alarm should not exist
    Poweroff_AEQE     AEQE_RRB       6
    verify No connection to unit alarm should exist
    Poweron_AEQE      AEQE_RRB       6
    Verify_MacSec_counters   verify_macsec_counters_integrity_confidentiality
    Modify macSecProtectionMode to intigrity and verify macsec session is success
    Verify_MacSec_counters_integrity   verify_macsec_counters_integrity
   Change actEcpriRuMPlaneSecurity as RuProtectOptional
   Verify actLbmOnFronthaul paremeter should be enabled
   Verify Loopback msg and reply
   Enable FH Firewall
   Enable MACSecWithPSK and Verify MacSec session is success
   Verify actLbmOnFronthaul paremeter should be enabled
   Verify Loopback msg and reply
   Configure Wrong cipher suite
   Verify MacSec Connection Setup Failure alarm
   Revert cipersuite value
  verify MacSec Connection Setup Failure alarm should not exist
   Perform BBMOD Reset and verify BTS status
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005