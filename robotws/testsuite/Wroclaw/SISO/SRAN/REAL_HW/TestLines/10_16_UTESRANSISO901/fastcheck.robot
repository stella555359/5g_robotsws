*** Settings ***
Documentation    Suite description

Library   ../../../resources/LMI.py  WITH NAME  lmi
Library    taf.hw.rf_diagnostic_card    WITH NAME    RDC

#TODO:    To test each type of board (LMI, LMI light, MUMIN USB, MUMIN ETH), uncomment code in variable section for ${RU_OBJECT} for specific card
#TODO:    and update each value. Then run the test with normal robot command. If everything is OK, snapshot and
#TODO:    other RM files should be located in ${MAIN_LOG_DIRECTORY}

*** Variables ***
${MAIN_LOG_DIRECTORY}    /home/ute/lmi_check

#TODO: TEST OF LMI LIGHT
#${RU_OBJECT}              __import__('taf.config.testline').config.testline.RU(
#    ...                             ru_hw_group="cMAAr6.1_8T8R",
#    ...                             serial_number="1M204457006",
#    ...                             radio_type="AZQP",
#    ...                             lmi=__import__('taf.config.testline').config.testline.SerialOverTcp(
#    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Remote(
#    ...                                          addr="10.255.30.109", port=2003)]))

#TODO: TEST OF MUMIN ETH
#${RU_OBJECT}              __import__('taf.config.testline').config.testline.RU(
#    ...                             ru_hw_group="FRMr6.2_4T4R",
#    ...                             serial_number="BL2221N4069",
#    ...                             radio_type="AHFII",
#    ...                             lmi=__import__('taf.config.testline').config.testline.SerialOverTcp(
#    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Remote(
#    ...                                          addr="10.255.30.112", port=2003)]))

#TODO: TEST OF MUMIN USB
#${RU_OBJECT}           __import__('taf.config.testline').config.testline.RU(
#    ...                     ru_hw_group="FRMr6.2_4T4R",
#    ...                     serial_number="L1190309149",
#    ...                     radio_type="AREA",
#    ...                     lmi=__import__('taf.config.testline').config.testline.SerialOverHost(
#    ...                         uart_mapping=[
#    ...                             __import__('taf.config.testline').config.testline.Local(port="COM21")
#    ...                        ],
#    ...                       host=__import__('taf.config.testline').config.testline.TestPc(
#    ...                         default_ssh_connection_details=
#    ...                             __import__('taf.config.testline').config.testline.connection_details.SshServiceDetails(
#    ...                            addr="10.42.172.131",
#    ...                            username="NOKLAB\\plwrranpz4",
#    ...                            password="Ut3pa5s#1be1", port="22"
#    ...                         )
#    ...                      )
#    ...                   ))

#TODO: TEST OF LMI
${RU_OBJECT}    __import__('taf.config.testline').config.testline.RU(
    ...             ru_hw_group="FRMrRH5.1_6T6R",
    ...             serial_number="EA192474384",
    ...             radio_type="AREA",
    ...             lmi=__import__('taf.config.testline').config.testline.LMI(
    ...                             product_code="088917A.X02",
    ...                             uart_mapping=[__import__('taf.config.testline').config.testline.Local(port="COM22")],
    ...                             host=__import__('taf.config.testline').config.testline.TestPc(default_ssh_connection_details=
    ...                             __import__('taf.config.testline').config.testline.connection_details.SshServiceDetails(addr="10.42.172.131",
    ...                                                                            username="NOKLAB\\plwrranpz4",
    ...                                                                        password="Ut3pa5s#1be1",
    ...    port="22"
    ...                                                                        ))))

*** Test Cases ***
Create RU Object Using Eval and test RDC Library keywords
    ${ru_object}=           Evaluate                      ${RU_OBJECT}
    Log To Console                                        ${ru_object.radio_type}  console=True
    RDC.Prepare Log Directory And Connection Setup        main_log_directory=${MAIN_LOG_DIRECTORY}
    ...    connection_setup=/home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/resources/common_setup_LMI.yaml
    RDC.setup_connections                                 ru_config=${ru_object}
    ...                                                   alias=TEST
    ...                                                   log_to_console=${FALSE}
    ...                                                   ignore_exceptions=${FALSE}
    RDC.take_snapshot                                     alias=TEST
    ...                                                   target_path_on_vm=${MAIN_LOG_DIRECTORY}
    ${serial_number}=       RDC.get_rmod_serial_number    alias=TEST
    ${rmod_ip}=             RDC.get_rmod_ip               alias=TEST
    ${rmod_snapshot_path}   RDC.get_rmod_snapshot_path    alias=TEST
    RDC.download_log                                      alias=TEST
    ...                                                   target_filepath=${MAIN_LOG_DIRECTORY}log.log
    ${files}=               RDC.execute_command           alias=TEST
    ...                                                   cmd=ls /rom
    ...                                                   elevated=${FALSE}
    ...                                                   wait_time=${10}
    ...                                                   write_output_to_logs=${TRUE}
    RDC.send_command                                      alias=TEST
    ...                                                   cmd=echo 'this will be visible in serial console'
    RDC.disconnect                                        alias=TEST
    Log To console   SN:${serial_number}, IP:${rmod_ip} Snapshot path:${rmod_snapshot_path} files=${files}
