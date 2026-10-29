*** Settings ***
Documentation     [SUITE PURPOSE] Entry points for CB012733 generic Testcase
...               Test Case Scenario author   : axel.gouilly-frossard@nokia.com
...               Test Case Scenario contact  : axel.gouilly-frossard@nokia.com
...               Test Case automation author : axel.gouilly-frossard@nokia.com
...               Test Case automation contact: axel.gouilly-frossard@nokia.com
...               Creation Date               : 1-february-2026
...               Last Modified by            :
...               Modification:
...                       1-february-2026   | Creation
...


Resource          ./resources/CB012733_A_keywords.robot
Resource          ../../../resources/SWENG/robot/Tools.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Suite Setup from scratch            listBackupFiles=${FD_ALL}
...               keepAllUeDataInCfgFile=${True}

###############  Attention pour tests reduction du suite setup  ###############
#Suite Setup       Suite Setup from scratch

Suite Teardown    Suite Teardown
Test Teardown     CB012733 Test Teardown

*** Variables ***
#${scf_delta_config_12733}    ${CURDIR}/config/custom/Delta_scf_CB012733-40MHz-Cell2-static.json
${scf_delta_config_12733}    ${CURDIR}/config/custom/Delta_scf_CB012733-40MHz-Cell2-dynamic.json
${basic_cf_12733}            ${CURDIR}/config/custom/basic_setup_12733_1_3.lua
${40MHZ_Cell2_SCF}           ${CURDIR}/config/custom/SCF-TL12-40MHz.xml

${gnb_alias}                 gnb_under_test



*** Test Cases ***
[1][1.0] CB012733-A1_1_Feature_activation_static_mode

    [Documentation]     This is a skeleton test case for CB012733-A.
    ...                 Actions:
    ...                     1. Define TL environment: Cell-2 with 40MHz BW, activate actThreeSymbolPdcch in static mode
    ...                     2. Prepare WTS configuration with 50 UEs on Cell2
    ...                     3. launch traffic on 50 UEs on cell2, traffic 2MB DL+2MB UL
    ...                     4. Take TTI trace
    ...                     5. Analyze TTI trace to check that actThreeSymbolPdcch is activated
    ...                 Postconditions:
    ...                     At least some pdch have start symbol equal to 2

    Dated Log      ${40MHZ_Cell2_SCF}


  #CB012733 Setup With Custom Config              SCF=${40MHZ_Cell2_SCF}

    CB012733 Configuration SCF Delta   ${scf_delta_config_12733}    gnb_alias=${gnb_alias}
    ${test_scf_file}             OAM Get SCF File            dir=${LOG_PATH}      file=SCF-modifiedviaJson.xml
    Dated Log                    New SCF ${test_scf_file}

    CB012733_A_Feature_activation_static


CB012733-A-TEST-TTI

    [Documentation]     This is ony a test to check the creation and analysis of a pcap located in /home/ute/Downloads.
    ...                 Actions:
    ...                     1. Convert Pacap to json and csv
    ...                     2. Filter csv and check that start symbol of pdch is equal to 2
    ...                 Postconditions:
    ...                     At least some pdch have start symbol equal to 2

    CB012733_A_TEST_TTI