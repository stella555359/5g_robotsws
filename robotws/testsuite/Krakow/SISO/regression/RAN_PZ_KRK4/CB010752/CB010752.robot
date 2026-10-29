*** Settings ***
Documentation
...    author: Szymon Misiolek
...    contact: szymon.misiolek@nokia.com
...    Description: CB010752 testsuite

Library     BuiltIn
Library     taf.rfrl.utilities.test_config.DefaultFileLocation        WITH NAME    dfl
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot
Resource    taf/rfrl/bts/robot/common/gnb_alarm.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library     ./resources/CB010752_keywords.py
Library     taf.ul.alarms_watchdog  WITH NAME  alarms_watchdog
Library     taf.ue
Library     taf.hw.rf_attenuator
Variables   ./resources/data_transfer_configuration.py
Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations
Library     SeleniumLibrary


Test Timeout  24 hours

Suite Setup         Run Keywords
...                 gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
...                 AND    Common Suite Setup With Commissioning    prefix_tag=CB010971    asir_hub=${True}
##Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
##Test Setup          Common Preconditions With Watching Alarms
Test Setup    Common Preconditions
Test Teardown    Common Postconditions
##Test Teardown       Common Postconditions With Watching Alarms


*** Variables ***
${gnb_id}      ${tl.gnbs[0].dus[0].global_bts_id}
${ue}=       ${tl.ues}
${logs_path}    /home/ute
${SEND_TRUCK_ROLL_EMAIL}         ${False}
@{additional_allowed_alarms}      Cell blocked      WiFi Configuration Issue

*** Test Cases ***
General_SiSo_load_ASiR_config_from_file_via_ASiR_WebEM
      ##setup CB010752A
      ##Common Preconditions With Watching Alarms
      [Setup]     Common Preconditions With Commissioning    asir_hub=${True}    prefix_tag=CB010752A
      ${RELEASE}=      dfl.Get Commissioning Branch
      ${RELEASE}=      Set Variable If    '${RELEASE}'=='TRUNK'    SBTS00    ${RELEASE}
      ${main_path}=    asir_scf_A_path
#      Run       ps -ef | grep -v 'grep' | grep chrome | awk '{print $2}' | sudo xargs kill -9
#      Prepare webdriver
      Load Asir Configuration
      ...    scf_path=${main_path}/${CONFIGURATION.replace('.', '/')}/${RELEASE}/CB010752A_GNB0_ASIR_SCF.xml
#      ...    browser=${webdriver}
      gnbcell.wait_for_all_cells_to_be_onair    timeout=${2400}
      Check All Cells    ${data_transfer_configuration_A}


General_SiSo_reset_ASiR_HUB_via_ASiR_WebEM
      ##setup CB010752B
      ##Common Preconditions With Watching Alarms
      [Setup]     Common Preconditions With Commissioning    asir_hub=${True}    prefix_tag=CB010752B
      gnb_asir.Reset Hub    bts_id=0    hub_id=1
      gnb_asir.Reset Hub    bts_id=0    hub_id=2
      gnbcell.wait_for_all_cells_to_be_onair    timeout=${2400}
      Check All Cells    ${data_transfer_configuration_B}


General_SiSo_Cell_block_and_unblock
      ##setup CB010752C
      ##Common Preconditions With Watching Alarms
      [Setup]     Common Preconditions With Commissioning    asir_hub=${True}    prefix_tag=CB010752C
      ##gnb_asir.Reset Configuration      bts_id=0
      ##gnb_alarm.Allow Alarm    Cell blocked
      Lock All Cells
      Unlock All Cells
      gnbcell.wait_for_all_cells_to_be_onair    timeout=${2400}
      ##gnb_alarm.Disallow Alarm    Cell blocked
      Check All Cells      ${data_transfer_configuration_C}


*** Keywords ***
Common Preconditions With Commissioning
    [Arguments]    ${asir_hub}    ${prefix_tag}
    gnb_asir.Reset Configuration      bts_id=0
    Perform Full Commissioning and Wait for onAir
    ...                         prefix_tag=${prefix_tag}
    ...                         asir_hub=${asir_hub}
#    taf.ue.Require Ue      ue_alias=QUECTEL_UE      capabilities=QUECTEL_UE
    Common Preconditions

Check All Cells
    [Arguments]      ${data_transfer_configuration}
    sleep    5
    taf.ue.Require Ue      ue_alias=QUECTEL_UE      capabilities=QUECTEL_UE
    FOR    ${cell}    IN    @{data_transfer_configuration}
         Attenuator Setup
         ...    attenuator=${cell['attenuator']}
         ...    attenuator_ports=${cell['attenuator_ports']}
         ...    attenuator_values=${cell['attenuator_values']}
         ...    cell_id=${cell['cell_id']}
         ...    ue_index=${cell['ue_index']}

         sleep    5

         Tput Check
         ...    duration=${cell['duration']}
         ...    dl_throughput=${cell['dl_throughput']}
         ...    ul_throughput=${cell['ul_throughput']}
         ...    max_deviation=${cell['max_deviation']}
    END
    taf.ue.Stop Using Ue    QUECTEL_UE

Attenuator Setup
    [Arguments]    ${attenuator}    ${attenuator_ports}    ${attenuator_values}    ${cell_id}    ${ue_index}
    Log      ${cell_id} ${ue_index}
    setup_attenuator    attenuator=${attenuator}  alias=att
    set_ports_attenuation    ports=${attenuator_ports}  values=${attenuator_values}  attenuator_device=att
    Sleep    5

Tput Check
    [Arguments]      ${duration}     ${dl_throughput}    ${ul_throughput}    ${max_deviation}
    Log      ${max_deviation}

    taf.ue.Attach Ue      QUECTEL_UE
    Sleep     5

    taf.ue.Start Data Transfer    dt_name=DT_DL    ue_alias=QUECTEL_UE    direction=dl    protocol=tcp    duration=${duration}
    ...    tput=${dl_throughput}
    ...    size_packet=1400B
#    ...    parallel_streams=4
#    ...    parallel_streams=2
    ...    parallel_streams=1
    ...    max_segment_size=1300

#    Wait for truput stabilization
    taf.ue.Await Data Transfer Finish       dt_name=DT_DL
    taf.ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${dl_throughput}   deviation=${max_deviation}
    ...    from_last=30

    sleep    5
    taf.ue.Start Data Transfer    dt_name=DT_UL    ue_alias=QUECTEL_UE    direction=ul    protocol=tcp    duration=${duration}
    ...    tput=${ul_throughput}
    ...    size_packet=1400B
#    ...    parallel_streams=4
#    ...    parallel_streams=2
    ...    parallel_streams=1
    ...    max_segment_size=1300
    ...    linux_congestion=cubic

#    Wait for truput stabilization
    taf.ue.Await Data Transfer Finish    dt_name=DT_UL
    taf.ue.Verify Average Throughput With Deviation    dt_name=DT_UL    tput=${ul_throughput}    deviation=${max_deviation}
    ...    from_last=30

    taf.ue.Detach Ue      QUECTEL_UE
#    taf.ue.Stop Using Ue    QUECTEL_UE

#Prepare webdriver
#    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
#    Call Method    ${chrome options}    add_argument    --ignore-certificate-errors
#    Call Method    ${chrome options}    add_argument    --maximized
#    Call Method    ${chrome options}    add_argument    --headless
#    Call Method    ${chrome options}    add_argument    --no-sandbox
#    Call Method    ${chrome options}    add_argument    --disable-extensions
#    Call Method    ${chrome options}    add_argument    --disable-dev-shm-usage
#    ${webdriver}=    Create Webdriver    Chrome    alias=chromedriver    chrome_options=${chrome options}
#    ${sl}=    BuiltIn.get_library_instance    SeleniumLibrary
#    ${webdriver} =    Set Variable    ${sl.driver}
#    set global variable    ${webdriver}
