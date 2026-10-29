*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO

Documentation   :copyright: Nokia
...             :author   : keerti
...             :contact  : keerti.1.keerti@nokia.com
...             :Feature  : The purpose of this TC is to verify successful UE configuration of the
...                         Inter-band FDD - TDD FR1 UL CA feature for single UE with 2 aggregated
...                         PCell is TDD carrier and single SCell is FDD FR1 carrier in SA mode with
...                         FeatureSetDownlinkPerCC-v1700->supportedBandwidthDL-v1710 UECapability.

Resource    resources/Keywords/CB011075_KW.robot

Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables ***
${UE1}            21
${GW_ID1}         1
${UE2}            51
${UE3}            22
${UE4}            71
${TIMEOUT_SA}     100
${GW_ID3}         3
@{IDS}      1    2    3    4    5
${PATTERN1}       SCellIndex 1 activated successfully at airphone.
${PATTERN2}       sCellToAddModList
${NGAP_FILTER}      ngap.procedureCode == 21 and ngap.gNB_ID == 00:00:04
${FIELD_NAME}       frame.time_delta_displayed
${PCAP_FILE}        gnbTcpdump.pcap


*** Test Cases ***
[1][1.0] CB011075_G_IWK2_SA_Carrier_Aggregation_TDD-FDD_SCell_selection
       [Documentation]    :Feature  : The purpose of this TC is to verify successful UE configuration of the
       ...                  Inter-band FDD - TDD FR1 UL CA feature for single UE with 2 aggregated
       ...                  PCell is TDD carrier and single SCell is FDD FR1 carrier in SA mode with
       ...                  FeatureSetDownlinkPerCC-v1700->supportedBandwidthDL-v1710 UECapability.
#       [Tags]    QC_28334   QCD_MN_RAN    QCP_RAN_VRF
       [Setup]    Prepare For Test Case - CB011075
       Log To Console      \nStarting the test case
       Sleep        120s
       UE Register Should Be Successful For SA     ${UE1}
       UE Register Should Be Successful For SA     ${UE3}
       Sleep    30s
       Log To Console   \n Verification of Scell index addition and activation from EGATE LOG
       Run Keyword And Ignore Error    Check PATTERN In Egate Console Log      ${PATTERN2}
       Run Keyword And Ignore Error    Check PATTERN In Egate Console Log      ${PATTERN1}
       Log To Console      \n Starting DL and UL traffic for UE1
       FOR    ${id}    IN      @{ids}
           Log To Console      ${id}
           Start And Validate Traffic For CA       UE_ID=${UE1}    id=${id}
       END
       Sleep     30s
       Log To Console      Starting DL and UL traffic for UEs\n
       Start And Validate Traffic For SA    UE_ID=${UE3}
       Sleep    30s
       Verification Of Downlink Throughput     id=${UE1}
       Sleep    10s
       Log To Console      Registering UE ${UE4}\n
       UE Register Should Be Successful For SA     ${UE4}
       Sleep    30s
       Log To Console      Starting VONR Call\n
       Start VONR Call          UE_ID=${UE4}
       Log To Console      Starting UL traffic for VONR CALL\n
       Start Uplink Traffic For VONR        UE_ID=${UE4}
       Log To Console      activating test mode profile\n
       Activate Testmode Profile And Validate TP And SAG           UE_ID=${UE4}
       ${pcap_file}    Stop Pcap Collection In GNB CU
       Log To Console      ${pcap_file}
       Verification Of NgSetupResponse Timer   ${pcap_file}    ${ngap_filter}      ${field_name}
       Log To Console      validating PC1 support for n77 band
       ${pmax_value}    Check Pmax Is Correct For N77              ${pcap_file}
       Log    ${pmax_value}
       [Teardown]     Run Keyword And Ignore Error     Common Test Case Tear Down LO AP LO
