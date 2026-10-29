*** Settings ***
Documentation
...  Feature Common DRX 5GC000772
...
...  author/contact: rafal.skrok@nokia.com

Library         testsuite.Wroclaw.SyVe.RRM.5GC000772.Res772
Library      testsuite.Wroclaw.SyVe.RRM.resources.StartupManager
Resource        testsuite/Wroclaw/SyVe/RRM/resources/reports/reporting_portal.robot

Suite Setup    Run Keywords    Confirm SW version and make sure BBU modules are enabled after installation
...                            Update swconfig for syslog flags
Test Setup     Prepare Environment and start logging for 772 feature
Test Teardown     Cleanup the setup and collect logs if the test fails
Suite Teardown   Cleanup Environment Collect snapshot if suite fails and block the site

Force Tags        CLOUD_5G_CLASSICAL_SA_2xANDROID_ASIBL_ABIOB1_AHLOA    STATE_SW_UPLOADED    CRT    RAN_5G    RAN_5G_MP
...               SBTS00    RAN_5G_MP_CUSTOMER    SBTS22R3    SBTS23R4    SBTS23R1    SBTS23R2

*** Test Cases ***

5GC000772_C_FDD_SA_014_10Mhz_CallSetup_FR1scheduling_DlTraffic_UeSupportsDRX

    Given Feature flag actCDrx is set to true with DRX profile configured Cell Setup in the SCF    bandwidth=10MHz    inactivity=40ms
      And gNB is up and running
      And Add scout external execution id to the reporting portal
      And UE supporting long DRX functionality is attached

    When Data traffic in DL for the UE is launched with maximum throughput

    Then DRX configuration is triggered for the UE after successful setup of the data bearer
      And the configured data rate is reached in DL


5GC000772_C_FDD_SA_011_5Mhz_CallSetup_counters_UeSupportsDRX

    Given Feature flag actCDrx is set to true with DRX profile configured Cell Setup in the SCF    bandwidth=5MHz    inactivity=80ms
      And gNB is up and running
      And Add scout external execution id to the reporting portal
      And UE supporting long DRX functionality is attached

    When Data Radio Bearer for UE is set up
      And The configured data rate is reached in UL and DL
      And BTS PM counters are collected

    Then PM Counter SLOTS_UE_DRX_ACTIVE is updated
      And PM Counter SLOTS_UE_DRX_SLEEP is updated


5GC000772_C_FDD_SA_007_5Mhz_online_DRXmodification

    Given Feature flag actCDrx is set to true with DRX profile configured Cell Setup in the SCF    bandwidth=5MHz    inactivity=40ms
      And gNB is up and running
      And Add scout external execution id to the reporting portal
      And UE supporting long DRX functionality is attached
      And Data traffic in dl for the ue is launched

    When Drx profile is modified online by changing the value of drxOnDurationTimer from 3ms to 10ms
      And DRX configuration is kept for the UE after online modification
      And Another UE supporting long DRX functionality is attached
      And Data radio bearer for the second ue is set up

    Then the second UE is attached and configured with updated CDRX profile
      But the first UE is configured with the initial DRX profile and keeps the profile even after modification
