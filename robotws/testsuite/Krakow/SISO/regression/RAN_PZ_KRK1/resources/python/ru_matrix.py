import time
import logging
from pathlib import Path
from taf.hw.rf_switch import rf_switch
from common import load_variables_for_configuration


def set_rf_matrix_output_ports(rfs_alias, vendor, ip_addr, model, output_ports, max_retries=5):
    """
    Connects input ports: IN1:IN2:IN3:IN4 with chosen output ports: OUT1:OUT2:OUT3:OUT4

    :param rfs_alias: alias for rf switch used in keywords, str
    :param vendor: rf switch vendor, str
    :param ip_addr: IP address of rf switch, str
    :param model: RF switch model, str
    :param output_ports: output ports in format OUT1:OUT2:OUT3:OUT4
           where OUT1 is a channel connected to input1, OUT2 to input2 etc, str
    :param max_retries: number of performed retry operations before function raises an exception
    Return: None
    """
    def get_connected_port_with_max_retry(rf, rfs_alias, max_retries=5):
        connected_ports = None
        for iter_counter in range(max_retries):
            try:
                connected_ports = rf.get_connected_ports(rf_switch_device=rfs_alias)
                return connected_ports
            except Exception as error:
                if iter_counter == max_retries - 1:
                    logging.error("Last retry operation of getting connected port failed!")
                    raise error
                logging.warning(
                    "Error '{}' occurred during getting connected port. Retrying operation...".format(error))
                time.sleep(1)

    rf = rf_switch()
    max_retries = int(max_retries)
    for iter_counter in range(max_retries):
        try:
            rf.setup_rf_switch(alias=rfs_alias, vendor=vendor, ip=ip_addr, model=model)
            break
        except Exception as error:
            if iter_counter == max_retries - 1:
                logging.error("Last retry operation of setup socket failed!")
                raise error
            logging.warning("Error '{}' occurred during setup socket. Retrying operation...".format(error))
            time.sleep(1)

    logging.info(
        "Initial port status:{}".format(
            get_connected_port_with_max_retry(rf=rf, rfs_alias=rfs_alias, max_retries=max_retries)
        )
    )

    logging.info("Changing output ports to:{}".format(output_ports))
    output_ports = output_ports.split(':')
    max_retries = int(max_retries)
    for in_port in range(1, len(output_ports) + 1):
        out_port = output_ports[in_port - 1]
        logging.debug("Setting IN{} to OUT{}".format(in_port, out_port))
        for iter_counter in range(max_retries):
            try:
                rf.connect_ports(rf_switch_device=rfs_alias, port_in=in_port, port_out=out_port)
                break
            except Exception as error:
                if iter_counter == max_retries - 1:
                    logging.error("Last retry operation of setting port IN{}:OUT{} failed!".format(in_port, out_port))
                    raise error
                logging.warning("Error '{}' occurred during setting port IN{}:OUT{}. Retrying operation...".format(
                    error, in_port, out_port))
                time.sleep(1)
    logging.info(
        "Current port status:{}".format(
            get_connected_port_with_max_retry(rf=rf, rfs_alias=rfs_alias, max_retries=max_retries)
        )
    )


def load_ru_matrix(configuration_prefix_tag):
    """
    Import variable file with RF matrix configuration based on prefix_tag.
    Author/Contact: agnieszka.bylica@nokia.com
    :param configuration_prefix_tag: prefix_tag of configuration from commissionings directory
    :return: None
    """
    logging.info("Loading RU matrix...")
    load_variables_for_configuration(configuration_prefix_tag)
    logging.info("RU matrix successfully loaded")
