*** Settings ***
Documentation
...        [Procedure]        "CB006436_Stateless_and_stateful_packet_filtering_on_th_ fronthaul_interface_ASIM"
...        [Date]             "28-05-2023"
...        [Author]           "Anshu Bhat"
...        [Feature_ID]       "CB005833"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Validated_TestLine]     "IAV_BLR_2020"
...        [Precondition]             "ENodeB should be integrated to Netact"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops

*** Variables ***
${rf_pswd}      KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=


***Test Cases***
[2][1.0] CB007308_CB006436_Stateless_and_stateful_packet_filtering_on_th_ fronthaul_interface_ASIM
  Preconditions
  Enable FH Firewall
  verify FH counters
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005

*** Keywords ***

Preconditions
    Perform Commissioning       scf_file=${Master_scf}     timeout=1800     alias=default      wait_for_bts_to_be_ready=600
    Setup Ems  config_device=netact2005   alias=lab2005
    Cm Upload   config_device=netact2005     alias=lab2005

Enable FH Firewall
    Perform Recommissioning     type=param    rat=lte     param_path=MNLENT-1/FEATCADM-1:actMplaneFronthaulFirewall    operation=update
    ...      value=true    timeout=600
    sleep   500
    Verify Bts Status     should_be_onair=${True}
    Verify Alarm    faultid=6450       should_exist=${False}

verify FH counters
    Pm Counters Start       analysis=FH_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Verify Pm Counters       analysis=FH_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Pm Counters Start       analysis=BBMOD_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Verify Pm Counters       analysis=BBMOD_counter         counter_analysis_file=${FH_analysis}        pm_interval=5