import time
import logging
from taf.hw.rf_switch import rf_switch


def set_rf_switch_output_ports(rfs_alias, vendor, ip_addr, model, output_ports, max_retries=5):
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

    rf = rf_switch()
    rf.setup_rf_switch(alias=rfs_alias, vendor=vendor, ip=ip_addr, model=model)
    logging.info(
        "Initial port status:{}".format(
            rf.get_connected_ports(rf_switch_device=rfs_alias)
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
                    logging.error("Last retry operation setting port IN{}:OUT{} failed!".format(in_port, out_port))
                    raise error
                logging.warning("Error '{}' occurred during setting port IN{}:OUT{}. Retrying operation...".format(
                    error, in_port, out_port))
    logging.info(
        "Current port status:{}".format(
            rf.get_connected_ports(rf_switch_device=rfs_alias)
        )
    )


def wait_for_unexpected_alarms_occur(timeout_for_alarms=3*60):
    time.sleep(int(timeout_for_alarms))
