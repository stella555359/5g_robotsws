*** Settings ***
Documentation
...  The purpose of this case is to verify the RF Scan feature works properly for BTS in TDS state.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_RF_Scanning.robot

*** Variables ***

${USER_RAT_TO_LAUNCH}  5G-4G  # Possible input: 5G-4G-3G, 5G-4G, 4G-3G.
${RMOD_SN}    #RU serial number
${node}    default
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password

*** Keywords ***
TC__SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Documentation]
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
    ...  TC works with RU families: 5.1*, 6.2* tested on AHEGB, AHLOB.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.03.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-46098

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB009074

    ca_BSRF_RF_Scanning.step1: Preconditions
    ca_BSRF_RF_Scanning.step2: Enter To Test Dedicated State
    ca_BSRF_RF_Scanning.step3: Cells Mapping By Antenna Lines
    Run Keyword If  '5G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_RF_Scanning.step4: RF Scanning for NR Composite RX (HBFO) - All Antenna Lines
    ...  ca_BSRF_RF_Scanning.step5: RF Scanning for NR Composite RX (HBFO) - Each Antenna Separately
    ...  ca_BSRF_RF_Scanning.step6: RF Scanning for NR Carrier RX (FIR9)
    ...  ca_BSRF_RF_Scanning.step7: RF Scanning for NR Feedback Tx (PDRx)
    ...  ca_BSRF_RF_Scanning.step8: Check Cancel Requests for NR Composite Rx (HBF0)
    Run Keyword If  '4G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_RF_Scanning.step9: RF Scanning for LTE Composite RX (HBFO) - All Antenna Lines
    ...  ca_BSRF_RF_Scanning.step10: RF Scanning for LTE Composite RX (HBFO) - Each Antenna Separately
    ...  ca_BSRF_RF_Scanning.step11: RF Scanning for LTE Carrier RX (FIR9)
    ...  ca_BSRF_RF_Scanning.step12: RF Scanning for LTE Feedback Tx (PDRx)
    Run Keyword If  '3G' in '${USER_RAT_TO_LAUNCH}'  Run Keywords
    ...  ca_BSRF_RF_Scanning.step13: RF Scanning for WCDMA Composite RX (HBFO) - All Antenna Lines
    ...  ca_BSRF_RF_Scanning.step14: RF Scanning for WCDMA Composite RX (HBFO) - Each Antenna Separately
    ...  ca_BSRF_RF_Scanning.step15: RF Scanning for WCDMA Carrier RX (FIR9)
    ca_BSRF_RF_Scanning.step16: Exit From Test Dedicated State
    ca_BSRF_RF_Scanning.step17: Postconditions

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Timeout Occurred  Run Keywords
    ...  ca_BSRF_RF_Scanning.step16: Exit From Test Dedicated State
    ...  AND  ca_BSRF_RF_Scanning.step17: Postconditions
    Run Keyword If Test Failed  Run Keyword If  ${ACTIVE_TDS}  Run Keywords
    ...  ca_BSRF_RF_Scanning.step16: Exit From Test Dedicated State
    ...  AND  ca_BSRF_RF_Scanning.step17: Postconditions
    Common Test Teardown
