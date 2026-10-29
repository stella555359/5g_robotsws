from robot.libraries.BuiltIn import BuiltIn
from taf.hw.pdu import pdu
from taf.hw.pdu.device_status import DeviceStatus
from time import sleep
builtin = BuiltIn()


def get_testline_pdus(tl, enb_pdus=False):
    pdu_dus = {}
    pdu_rus = {}
    pdu_vendors = {}

    # eNB
    if enb_pdus and tl.enbs is not None:
        for enb_id, enb in enumerate(tl.enbs, 0):
            ip = enb.system_module.common_units[0].pdu_port.pdu.addr
            port_no = enb.system_module.common_units[0].pdu_port.port_no
            vendor = enb.system_module.common_units[0].pdu_port.pdu.vendor
            if ip:
                if pdu_dus.get(ip, None) is None:
                    pdu_dus.update({ip: [port_no]})
                    pdu_vendors.update({ip: vendor})
                elif port_no not in pdu_dus[ip]:
                    pdu_dus[ip].append(port_no)
            for ru_id, ru in enumerate(enb.rms, 0):
                ip = ru.pdu_port.pdu.addr
                port_no = ru.pdu_port.port_no
                vendor = ru.pdu_port.pdu.vendor
                if ip:
                    if pdu_rus.get(ip, None) is None:
                        pdu_rus.update({ip: [port_no]})
                        pdu_vendors.update({ip: vendor})
                    elif port_no not in pdu_rus[ip]:
                        pdu_rus[ip].append(port_no)
    # gNB
    if tl.gnbs is not None:
        for gnb_id, gnb in enumerate(tl.gnbs, 0):
            for du_id, du in enumerate(gnb.dus, 0):
                ip = du.airscale.common_units[0].pdu_port.pdu.addr
                port_no = du.airscale.common_units[0].pdu_port.port_no
                vendor = du.airscale.common_units[0].pdu_port.pdu.vendor
                if ip:
                    if pdu_dus.get(ip, None) is None:
                        pdu_dus.update({ip: [port_no]})
                        pdu_vendors.update({ip: vendor})
                    elif port_no not in pdu_dus[ip]:
                        pdu_dus[ip].append(port_no)
                rus = du.rus
                if rus is None:
                    for fct_id, fct in enumerate(du.airscale.common_units, 0):
                        for fsp_id, fsp in enumerate(fct.capacity_units, 0):
                            for ru_id, ru in enumerate(fsp.rus, 0):
                                ip = ru.pdu_port.pdu.addr
                                port_no = ru.pdu_port.port_no
                                vendor = ru.pdu_port.pdu.vendor
                                if ip:
                                    if pdu_rus.get(ip, None) is None:
                                        pdu_rus.update({ip: [port_no]})
                                        pdu_vendors.update({ip: vendor})
                                    elif port_no not in pdu_rus[ip]:
                                        pdu_rus[ip].append(port_no)
                else:
                    for ru in rus:
                        ip = ru.pdu_port.pdu.addr
                        port_no = ru.pdu_port.port_no
                        vendor = ru.pdu_port.pdu.vendor
                        if ip:
                            if pdu_rus.get(ip, None) is None:
                                pdu_rus.update({ip: [port_no]})
                                pdu_vendors.update({ip: vendor})
                            elif port_no not in pdu_rus[ip]:
                                pdu_rus[ip].append(port_no)

    return pdu_vendors, pdu_dus, pdu_rus


def power_on_off_pdu(pdu_vendors={}, pdu_infos={}, Power=DeviceStatus.ON):
    for ip in pdu_infos:
        vendor = pdu_vendors.get(ip, None)
        ports_no = pdu_infos.get(ip, [])
        if vendor and ports_no:
            pdu_device = pdu()
            pdu_device.setup_pdu(
                model=vendor,
                host=ip
            )
            builtin.log(pdu_device)
            builtin.log("getting status of pdu device ip: %s | ports %s" % (ip, ports_no))
            ports_status = _get_pdu_device_ports_status(pdu_device, ports_no)
            builtin.log("status before operation, port: %s | status %s" % (ports_no, ports_status))
            for i, port_no in enumerate(ports_no):
                builtin.log("Power != ports_status[i]: %s | Power %s" % ((Power != ports_status[i]), Power), 'DEBUG')
                if Power != ports_status[i]:
                    if Power == DeviceStatus.ON:
                        pdu_device.power_on(port_no)
                    elif Power == DeviceStatus.OFF:
                        pdu_device.power_off(port_no)
            sleep(5)
            ports_status = _get_pdu_device_ports_status(pdu_device, ports_no)
            builtin.log("status after operation, port: %s | status %s" % (ports_no, ports_status))
            del pdu_device
    return


def _get_pdu_device_ports_status(pdu_device, ports_no):
    ports_status = []
    for port_no in ports_no:
        count = 0
        pdu_status = None
        while True:
            pdu_status = pdu_device.get_port_status(
                port_no,
            )
            if pdu_status != DeviceStatus.PENDING or count > 5:
                break
            count += 1
            sleep(5)
        ports_status.append(pdu_status)
    return ports_status


def switch_on_testline(testline, with_enb=False):
    # Collecte PDUs information
    pdu_vendors, pdu_dus, pdu_rus = get_testline_pdus(testline, enb_pdus=with_enb)

    # Power On/Off RU first
    builtin.log("************ RUs pdu device ************")
    power_on_off_pdu(pdu_vendors, pdu_rus, Power=DeviceStatus.ON)

    # Power On/Off DU
    builtin.log("************ DUs pdu device ************")
    power_on_off_pdu(pdu_vendors, pdu_dus, Power=DeviceStatus.ON)


def switch_off_testline(testline, with_enb=False):
    # Collecte PDUs information
    pdu_vendors, pdu_dus, pdu_rus = get_testline_pdus(testline, enb_pdus=with_enb)

    # Power On/Off RU first
    builtin.log("************ RUs pdu device ************")
    power_on_off_pdu(pdu_vendors, pdu_rus, Power=DeviceStatus.OFF)

    # Power On/Off DU
    builtin.log("************ DUs pdu device ************")
    power_on_off_pdu(pdu_vendors, pdu_dus, Power=DeviceStatus.OFF)
