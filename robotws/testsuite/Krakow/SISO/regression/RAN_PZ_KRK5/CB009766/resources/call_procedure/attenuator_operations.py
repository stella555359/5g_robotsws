import os
import json
import time
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from call_exceptions import AttenuatorVendorNotKnow
import taf.rfrl.utilities.logger.custom_logger as logger


def adjust_attenuation(cell_ids=None, attenuation_level="max"):
    attenuator_matrix = json.loads(os.environ.get("attenuator_matrix"))
    if cell_ids is None:
        perform_attenuation_for_all_cells(attenuator_matrix, attenuation_level)
    else:
        perform_attenuation_for_passing_cells(cell_ids, attenuator_matrix, attenuation_level)


def perform_attenuation_for_all_cells(attenuator_matrix, attenuation_level):
    logger.log_info_to_console(f"Performing attenuation for all cells. Att lev: {attenuation_level}", log_hierarchy=2)
    atten = attenuator()
    attenuator_values = json.loads(os.environ.get("ATTENUATOR_VALUES"))
    for cell_att in attenuator_matrix:
        for att in attenuator_matrix[cell_att]["attenuators"]:
            if att["vendor"].upper() == "RADIORACK":
                atten.setup_attenuator(ip_addr=att["ip_address"], port=att["att_port"],
                                       attenuation_port_numbers=att["ports"], vendor=att["vendor"],
                                       max_attenuation=attenuator_values[att["vendor"]][attenuation_level])
            elif att["vendor"].upper() == "TOPYOUNG":
                atten.setup_attenuator(ip_addr=att["ip_address"], port=att["att_port"], model=att["model"],
                                       attenuation_port_numbers=att["ports"], vendor=att["vendor"],
                                       max_attenuation=attenuator_values[att["vendor"]][attenuation_level])
            else:
                raise AttenuatorVendorNotKnow(f"Passing vendor: {att['vendor']} not known. Please contact KW owner")

            for port in att["ports"]:
                atten.set_attenuation(port=port, value=attenuator_values[att["vendor"].upper()][attenuation_level])
            time.sleep(5)


def perform_attenuation_for_passing_cells(cell_ids, attenuator_matrix, attenuation_level):
    logger.log_info_to_console(f"Performing attenuation for {cell_ids}", log_hierarchy=2)
    atten_device = attenuator()
    attenuator_values = json.loads(os.environ.get("ATTENUATOR_VALUES"))
    for cell in cell_ids:
        for atten in attenuator_matrix[cell]["attenuators"]:
            attenuation_ports = atten['ports']
            if atten["vendor"].upper() == "RADIORACK":
                atten_device.setup_attenuator(ip_addr=atten['ip_address'], port=atten["att_port"],
                                              attenuation_port_numbers=attenuation_ports,
                                              max_attenuation=attenuator_values[atten["vendor"].upper()]['max'],
                                              vendor=atten["vendor"].upper())
            elif atten["vendor"].upper() == "TOPYOUNG":
                atten_device.setup_attenuator(ip_addr=atten['ip_address'], port=atten["att_port"],
                                              attenuation_port_numbers=attenuation_ports,
                                              max_attenuation=attenuator_values[atten["vendor"].upper()]['max'],
                                              vendor=atten["vendor"].upper(), model=atten["model"])
            if attenuation_level == 'atten_ul':
                for atten_value in atten['atten_ul']:
                    for port in atten['atten_ul'][atten_value]:
                        atten_device.set_attenuation(port=port, value=int(atten_value))
            elif attenuation_level == 'atten_dl':
                for atten_value in atten['atten_dl']:
                    for port in atten['atten_dl'][atten_value]:
                        atten_device.set_attenuation(port=port, value=int(atten_value))
            else:
                attenuation_value = attenuator_values[atten["vendor"].upper()][attenuation_level]
                for port in attenuation_ports:
                    atten_device.set_attenuation(port=port, value=attenuation_value)
                time.sleep(5)
