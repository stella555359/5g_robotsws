# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import sys
import time
import re
import logging
import traceback
import signal


logging.basicConfig(
    format='%(asctime)s %(name)s: [%(levelname)5s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    level=logging.DEBUG,
    filename='proxy_server.log')

logger = logging.getLogger('ute_ue.uepc')
formatter = logging.Formatter('%(asctime)s [%(levelname)5s] %(message)s',  datefmt='%Y-%m-%d %H:%M:%S')
std_handle = logging.StreamHandler(sys.stdout)
std_handle.setFormatter(formatter)
logger.addHandler(std_handle)


try:
    from SimpleXMLRPCServer import SimpleXMLRPCServer
    from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler
    logger.info('Use Python2')
except Exception:
    from xmlrpc.server import SimpleXMLRPCServer
    from xmlrpc.server import SimpleXMLRPCRequestHandler
    logger.info('Use Python3')


class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)


def hex_string_to_bytes(hex_string):
    hex_string = hex_string.replace(" ", "")
    hex_bytes = ''.join(chr(int(hex_string[i:i+2], 16)) for i in range(0, len(hex_string), 2))
    return hex_bytes


def calculate_hex_sum_mod(hex_string):
    hex_values = hex_string.split()
    decimal_sum = 0

    for hex_val in hex_values:
        decimal_val = int(hex_val, 16)
        decimal_sum += decimal_val

    decimal_sum_mod = decimal_sum % 256
    hex_sum = hex(decimal_sum_mod)[2:].upper().zfill(2)

    return hex_sum


class ProxyServer(object):

    def __init__(self, **kwargs):
        self.logger = logger
        self.ues = {}
        signal.signal(signal.SIGINT, self.signal_handler)

    def get_ue(self, serial_no):
        if serial_no in self.ues:
            return self.ues[serial_no]
        else:
            self.logger.info('Add UE {}'.format(serial_no))
            from ta_ue_plugin_android.uepc.android_control import AndroidControl
            ue = AndroidControl()
            ue.start_ue_manager(sn_number=serial_no)
            self.ues[serial_no] = ue
            return ue

    def signal_handler(self, signal, frame):
        for ue in self.ues.values():
            ue.stop_ue_manager()
        sys.exit(0)

    def _return_ok(self, msg=''):
        return dict(succeed=True, msg=msg)

    def _return_fail(self, msg=''):
        return dict(succeed=False, msg=msg)

    def naa_ue(self, serial_no, funname, *args, **kwargs):
        ue = self.get_ue(serial_no)
        fun = getattr(ue, funname)
        result = fun(*args, **kwargs)
        return self._return_ok(str(result))

    def exec_os_command(self, command):
        self.logger.info('Run:  ' + command)
        lines = os.popen(command).read()
        self.logger.info(str(lines))
        return self._return_ok(lines)

    def exec_at_command(self, COM_port='', cmd='', data={}, delay=0):
        ser = None
        response = ''
        import serial
        try:
            COM_port = COM_port if 'COM' in str(COM_port).upper() else 'COM' + str(COM_port)
            self.logger.info('Execute command {} on COM port: {}'.format(cmd, COM_port))
            self.logger.info('data: {}'.format(data))
            ser = serial.Serial(port=COM_port, timeout=1)
            ser.write(cmd + '\r\n')
            if delay:
                time.sleep(delay)
            response = ser.read(512)
            self.logger.info('Execute command {} on port: {} done'.format(cmd, COM_port))
            self.logger.info('Output: {}'.format(response))
        except Exception as E:
            self.logger.error('Error happened {}'.format(E))
            return self._return_fail(str(E))
        finally:
            if ser:
                ser.close()
        return self._return_ok(response)

    def list_comports_of(self, keyword=''):
        import serial.tools.list_ports as ls
        result = []
        for p in ls.comports():
            if keyword:
                if keyword.lower() in p.description.lower():
                    result.append(dict(name=p.device, description=p.description))
            else:
                result.append(dict(name=p.device, description=p.description))
        return result

    def spark_mtu_power_control(self, constrol_port, port_index, op):
        import serial
        ser = None
        response = ''

        hello = hex_string_to_bytes("DB A9 00 70 04 01 00 F9")
        alloff = hex_string_to_bytes("DB A9 FF 70 07 08 01 02 03 04 05 06 07 08 26")
        allon = hex_string_to_bytes("DB A9 FF 70 06 08 01 02 03 04 05 06 07 08 25")
        if op.lower() == 'on':
            code = '06'
            allcode = allon
        else:
            code = '07'
            allcode = alloff

        try:
            self.logger.info('Execute command {} {} for port: {}'.format(constrol_port, op, port_index))
            ser = serial.Serial(constrol_port, baudrate=115200, timeout=1)
            ser.write(hello)
            time.sleep(0.2)

            if int(port_index) == -1:
                ser.write(allcode)
            else:
                txt = "DB A9 FF 70 {} 01 {}".format(code, '%02d' % (int(port_index)))
                txt = txt + ' ' + calculate_hex_sum_mod(txt)
                print(txt)
                ser.write(hex_string_to_bytes(txt))
        finally:
            if ser:
                ser.close()
        return response


if __name__ == '__main__':

    logger.info('Start Server ...')
    server = SimpleXMLRPCServer(("0.0.0.0", 30000), requestHandler=RequestHandler)
    server.register_introspection_functions()
    ps = ProxyServer()
    server.register_instance(ps)
    server.serve_forever()
