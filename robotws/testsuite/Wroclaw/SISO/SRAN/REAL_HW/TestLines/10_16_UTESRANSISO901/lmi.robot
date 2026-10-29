*** Settings ***
Documentation    Suite description
...    Responsible tester:  patryk.niewiejski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../robotlte_legacy/tc_scenarios.robot
Library   ../../../resources/LMI.py  WITH NAME  lmi
Library    taf.hw.rf_diagnostic_card    WITH NAME    RDC

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            False     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
${SKIP_TRUCK_ROLL}    ${True}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=6450
#...  faultId=1901
...  faultId=10
...  faultId=4003
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
${CUSTOM_LMI_ENABLE_FLAG}  ${True}                                     # Set False to turn off LMI/MUMIN log collection for entire TS
@{CUSTOM_LMI_EXCLUDE_RM_LIST}  K9173100335  F7174613872   # List of RM's SN to exclude from logs collection
@{CUSTOM_LMI_ALLOWED_ALARMS}    faultId=2137  faultId=420  faultId=69  # List of faults to allowed for entire TS. Use format faultId=INSERT_FID_HERE
@{CUSTOM_LMI_FORCE_CHECK_ALARMS}  faultId=10  faultId=1901             # List of faults to exclude from allowed alarms for entire TS.
																	                                     # Overwrites CUSTOM_LMI_ALLOWED_ALARMS faults
${CUSTOM_LMI_ALLOW_POST_MORTEM_ACTION}  ${False}                       # Switch for Post Mortem action. Not implemented yet. Set False for now


${MAIN_LOG_DIRECTORY}    /home/ute/lmi_test                                                              # (1)
#LMI LIGHT
#${RU_OBJECT}              __import__('taf.config.testline').config.testline.RU(                            # (2)
#    ...                             ru_hw_group="cMAAr6.1_8T8R",
#    ...                             serial_number="1M203440037",                                           # (3)
#    ...                             radio_type="AZQP",
#    ...                             lmi=__import__('taf.config.testline').config.testline.SerialOverTcp(   # (4)
#    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Remote(
#    ...                                          addr="10.42.75.147", port=2003)]))
#MUMIN ETH
#${RU_OBJECT}              __import__('taf.config.testline').config.testline.RU(                            # (2)
#    ...                             ru_hw_group="FRMr6.2_4T4R",
#    ...                             serial_number="BL2221N4069",                                           # (3)
#    ...                             radio_type="AHFII",
#    ...                             lmi=__import__('taf.config.testline').config.testline.SerialOverTcp(   # (4)
#    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Remote(
#    ...                                          addr="10.255.32.176", port=2003)]))
# MUMIN USB
${RU_OBJECT}           __import__('taf.config.testline').config.testline.RU(                            # (2)
    ...                     ru_hw_group="FRMr6.2_4T4R",
    ...                     serial_number="L1190309149",                                           # (3)
    ...                     radio_type="AREA",
    ...                     lmi=__import__('taf.config.testline').config.testline.SerialOverHost(   # (4)
    ...                         uart_mapping=[
    ...                             __import__('taf.config.testline').config.testline.Local(port="COM21")
    ...                        ],
    ...                       host=__import__('taf.config.testline').config.testline.TestPc(
    ...                         default_ssh_connection_details=__import__('taf.config.testline').config.testline.connection_details.SshServiceDetails(
    ...                            addr="10.42.63.252",
    ...                            username="NOKLAB\\plwrranpz4",
    ...                            password="Ut3pa5s#1be1", port="22"
    ...                         )
    ...                      )
    ...                   ))
#LMI
#${RU_OBJECT}    __import__('taf.config.testline').config.testline.RU(                            # (2)
#    ...             ru_hw_group="FRMrRH5.1_6T6R",
#    ...             serial_number="EA192474384",                                           # (3)
#    ...             radio_type="AREA",
#    ...             lmi=__import__('taf.config.testline').config.testline.LMI(
#    ...                             product_code="088917A.X02",        # (4)
#    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Local(port="COM22")],
#    ...                             host=__import__('taf.config.testline').config.testline.TestPc(default_ssh_connection_details=
#    ...                             __import__('taf.config.testline').config.testline.connection_details.SshServiceDetails(addr="10.42.63.252",
#    ...                                                                            username="NOKLAB\\plwrranpz4",
#    ...                                                                        password="Ut3pa5s#1be1",
#    ...    port="22"
#    ...                                                                        ))))
*** Test Cases ***
#[DEV] LMI Development
#  [Setup]  Configuration Precondition  CN=REF_10_16_UTESRANSISO901_DEFAULT  N=1
#  Execute Test In Loop  TC_Dummy
#  [Teardown]  Configuration Postcondition

#mhm
#    Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=EA192474384  #Without MUMIN-ETH - testing only
#
Create RU Object Using Eval and test RDC Library keywords
    ${ru_object}=           Evaluate                      ${RU_OBJECT}
    Log To Console                                        ${ru_object.radio_type}
    RDC.Prepare Log Directory And Connection Setup        main_log_directory=${MAIN_LOG_DIRECTORY}
#    ...                                                   connection_setup=my_yaml.yaml
    RDC.setup_connections                                 ru_config=${ru_object}
    ...                                                   alias=TEST
    ...                                                   log_to_console=${FALSE}
    ...                                                   ignore_exceptions=${FALSE}
    RDC.take_snapshot                                     alias=TEST
    ...                                                   target_path_on_vm=/home/ute/lmi_test
    ${serial_number}=       RDC.get_rmod_serial_number    alias=TEST
    ${rmod_ip}=             RDC.get_rmod_ip               alias=TEST
    ${rmod_snapshot_path}   RDC.get_rmod_snapshot_path    alias=TEST
    RDC.download_log                                      alias=TEST
    ...                                                   target_filepath=/home/ute/lmi_test/log.log
    ${files}=               RDC.execute_command           alias=TEST
    ...                                                   cmd=ls /rom
    ...                                                   elevated=${FALSE}
    ...                                                   wait_time=${10}
    ...                                                   write_output_to_logs=${TRUE}
    RDC.send_command                                      alias=TEST
    ...                                                   cmd=echo 'this will be visible in serial console'
    RDC.disconnect                                        alias=TEST
    Log To console   SN:${serial_number}, IP:${rmod_ip} Snapshot path:${rmod_snapshot_path} files=${files}
#

#TEST
#       Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=BL2221N4069
*** Keywords ***
TC_Dummy

  Log    ${CFG}
  Common Test Setup  cells_check=False  scf_check=False  HW_check=False
  Logging With Timestamp
  ...  message=TC_Dummy for every node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      Wrapper For Dummy TC  ${bts_id}
  END
  [Teardown]    Common Test Teardown  cells_check=False  scf_check=False  HW_check=False  delay=5

Wrapper For Dummy TC
  [Arguments]  ${bts_id}
#  lmi.Setup LMI Flow
  # lmi.Get Current Running Build Name  EA192474384  # AREA     ->> tu ma być LMI
  # lmi.Get Current Running Build Name  L1190309149  # AREA (MUMIN_USB) (not configured yet)
  # lmi.Get Current Running Build Name  BL2221N4069  # AHFII
  # lmi.Get Current Running Build Name  6Q183043588  # AHDB (unsupported)
  # lmi.Get Current Running Build Name  6Q182525835  # AHEC (unsupported)
  # lmi.Get Current Running Build Name  K9173100335  # FHED (without lmi)
#   lmi.Get Rmod Serial Number    # AZQP
  # lmi.Get Current Running Build Name  F7174613872  # FXDB (without lmi)

  Sleep  1s
  Log To Console  TUTAJ JEST WRAPPER DLA ${bts_id}

#   Run Keyword And Continue on Failure  radio.Generate Fault  fault_id=1901  ru_serial_number=BL2221N4069
   Run Keyword And Continue on Failure  radio.Generate Fault  fault_id=1901  ru_serial_number=EA192474384
  # Run Keyword And Continue on Failure  radio.Generate Fault  fault_id=1901  ru_serial_number=6Q183043588
  # Run Keyword And Continue on Failure  radio.Generate Fault  fault_id=1901  ru_serial_number=6Q182525835
#   Run Keyword And Continue on Failure  radio.Generate Fault  fault_id=1901  ru_serial_number=L1190309149  #Without MUMIN-ETH - testing only
    Sleep    600
#   Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=BL2221N4069
  # Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=EA192474384
  # Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=6Q183043588
  # Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=6Q182525835
  # Run Keyword And Continue on Failure  radio.Recover Fault  fault_id=1901  ru_serial_number=L1190309149  #Without MUMIN-ETH - testing only


