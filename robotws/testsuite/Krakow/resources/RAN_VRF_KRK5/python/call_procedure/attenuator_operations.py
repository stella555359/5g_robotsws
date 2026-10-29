import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.hw.rf_attenuator import rf_attenuator
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.call_exceptions import AttenuatorVendorNotKnow


def adjust_attenuation_for_cells(attenuator_matrix, cell_ids=None, attenuation_level="max", log_hierarchy=2):
    if not cell_ids:
        cell_ids = [key for key in attenuator_matrix.keys() if 'CEL' in key]
    logger.log_info_to_console(f"Adjusting attenuation for cells {cell_ids} to `{attenuation_level}` level",
                               log_hierarchy=log_hierarchy)
    atten_device = rf_attenuator()
    atten_default_levels = attenuator_matrix['atten_default_values']
    for cell in cell_ids:
        if 'attenuators' in attenuator_matrix[cell].keys():
            for atten in attenuator_matrix[cell]["attenuators"]:
                attenuation_ports = atten["ports"]
                vendor = atten["vendor"].upper()
                if vendor == "RADIORACK":
                    atten_device.setup_attenuator(ip_addr=atten["ip_address"], port=atten["att_port"],
                                                  attenuation_port_numbers=attenuation_ports,
                                                  max_attenuation=atten_default_levels[vendor]["max"],
                                                  vendor=vendor)
                elif vendor == "TOPYOUNG":
                    atten_device.setup_attenuator(ip_addr=atten['ip_address'], port=atten["att_port"],
                                                  attenuation_port_numbers=attenuation_ports,
                                                  max_attenuation=atten_default_levels[vendor]["max"],
                                                  vendor=vendor, model=atten["model"])
                else:
                    raise AttenuatorVendorNotKnow(f"Passing vendor: {vendor} not known."
                                                  f" Please contact KW owner")
                if attenuation_level.lower() == 'atten_ul':
                    for atten_value in atten['atten_ul']:
                        for port in atten['atten_ul'][atten_value]:
                            atten_device.set_attenuation(port=port, value=int(atten_value))
                elif attenuation_level.lower() == 'atten_dl':
                    for atten_value in atten['atten_dl']:
                        for port in atten['atten_dl'][atten_value]:
                            atten_device.set_attenuation(port=port, value=int(atten_value))
                elif attenuation_level.lower() == 'max':
                    for port in atten['ports']:
                        atten_device.set_attenuation(port=port, value=int(atten_default_levels[vendor]["max"]))
                elif attenuation_level.lower() == 'avg':
                    for port in atten['ports']:
                        atten_device.set_attenuation(port=port, value=int(atten_default_levels[vendor]["avg"]))
                time.sleep(5)
        else:
            logger.log_warn_to_console(f"No `attenuators` defined for {cell}", log_hierarchy=int(log_hierarchy)+1)
