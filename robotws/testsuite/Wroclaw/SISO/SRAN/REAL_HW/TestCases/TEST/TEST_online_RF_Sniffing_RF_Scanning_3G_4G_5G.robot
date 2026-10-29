*** Settings ***
Documentation
  ...  The purpose of this case is to verify proper functionality activation and reconfiguration Reduced NR GuardBand.
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-45202
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the RF Scan feature works properly for BTS OnAir state.
  ...  TC enables the RF Interference testing function in a BTS.
  ...  TC run all capture type (Composite Rx (HBF0), Carrier Rx (FIR9), Feedback Tx (PDRx)) for input radio module serial number
  ...  and collect RF scan data. TC checked if stored file are complited.
  ...  IMPORTANT:
  ...  TC works for RATs NR FDD, NR TDD, LTE FDD and WCDMA.
  ...
  ...  TC works with RU families: 5.1*, 6.2* tested on AHEGB, AHLOB.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 15.02.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-45202 - Initial creation
  ...  - 18.06.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49322 - Add support for NR TDD and refactor for robotws

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  RF_Scanning.resource

*** Variables ***

${USER_RAT_TO_LAUNCH}    # Possible input: 5G-4G-3G, 5G-4G, 4G-3G, 5_TDD.
${RMOD_SN}               #RU serial number
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password

*** Keywords ***
TC__TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    Set Tags
    ...  OWNER-lukasz.wystup@nokia.com
    ...  AUTHOR-lukasz.wystup@nokia.com
    ...  MAINTAINER-lukasz.wystup@nokia.com
    ...  FEATURE-CB009074

    Common Test Setup
    RF_Scanning.Step1: Preconditions
    RF_Scanning.Step2: Cells Mapping By Antenna Lines
    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step3: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step4: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step5: RF Scanning for NR Carrier RX (FIR9)
    ...  RF_Scanning.Step6: RF Scanning for NR Feedback Tx (PDRx) - Each Antenna Separately
    ...  RF_Scanning.Step7: Check Cancel Requests for NRFDD Composite Rx (HBF0)
    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step8: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step9: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step10: RF Scanning for LTE Carrier RX (FIR9)
    ...  RF_Scanning.Step11: RF Scanning for LTE Feedback Tx (PDRx) - Each Antenna Separately
    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step12: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step13: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step14: RF Scanning for WCDMA Carrier RX (FIR9)
    ...  RF_Scanning.Step15: RF Scanning for WCDMA Feedback Tx (PDRx) - Each Antenna Separately
    Run Keyword If  '5_TDD' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step16: RF Scanning for NRTDD Composite RX (HBFO) - Full Array
    ...  RF_Scanning.Step17: RF Scanning for NRTDD Carrier RX (FIR9)
    ...  RF_Scanning.Step18: RF Scanning for NRTDD Feedback Tx (PDRx)
    ...  RF_Scanning.Step19: Check Cancel Requests for NRTDD Composite Rx (HBF0)

    [Teardown]  Run Keywords
    ...  RF_Scanning.Postconditions
    ...  AND  Common Test Teardown
