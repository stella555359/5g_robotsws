*** Settings ***
Documentation
  ...  The purpose of this case is to verify the RF Scan feature works properly for BTS in TDS state.
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46098
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this case is to verify the RF Scan feature works properly for BTS in TDS state.
  ...  TC enables the RF Interference testing function in a BTS.
  ...  TC enables the TDS function in a BTS.
  ...  TC run all capture type (Composite Rx (HBF0), Carrier Rx (FIR9), Feedback Tx (PDRx)) for input radio module serial number
  ...  and collect RF scan data. TC checked if stored file are complited.
  ...  After complited test case BTS is set to OnAir state.
  ...  IMPORTANT:
  ...  TC works for RATs NR FDD, LTE FDD and WCDMA.
  ...
  ...  TC works with RU families: 5.1*, 6.2* tested on AHEGB, AHLOB, AHIB.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 13.03.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46098
  ...  - 18.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49322 - Refactor for robotws

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  RF_Scanning.resource

*** Variables ***

${USER_RAT_TO_LAUNCH}   # Possible input: 5G-4G-3G, 5G-4G, 4G-3G.
${RMOD_SN}              #RU serial number
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password

*** Keywords ***
TC__TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    Set Tags
    ...  OWNER-lukasz.wystup@nokia.com
    ...  AUTHOR-lukasz.wystup@nokia.com
    ...  MAINTAINER-lukasz.wystup@nokia.com
    ...  FEATURE-CB009074

    Common Test Setup
    RF_Scanning.Step1: Preconditions
    RF_Scanning.Step2: Enter To Test Dedicated State
    RF_Scanning.Step3: Cells Mapping By Antenna Lines
    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step4: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step5: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step6: RF Scanning for NR Carrier RX (FIR9)
    ...  RF_Scanning.Step7: RF Scanning for NR Feedback Tx (PDRx) - Each Antenna Separately
    ...  RF_Scanning.Step8: Check Cancel Requests For NRFDD Composite Rx (HBF0)
    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step9: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step10: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step11: RF Scanning for LTE Carrier RX (FIR9)
    ...  RF_Scanning.Step12: RF Scanning for LTE Feedback Tx (PDRx) - Each Antenna Separately
    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  RF_Scanning.Step13: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    ...  RF_Scanning.Step14: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    ...  RF_Scanning.Step15: RF Scanning for WCDMA Carrier RX (FIR9)
    RF_Scanning.Step16: Exit From Test Dedicated State

    [Teardown]  Run Keywords
    ...  RF_Scanning.Postconditions
    ...  AND  Common Test Teardown
