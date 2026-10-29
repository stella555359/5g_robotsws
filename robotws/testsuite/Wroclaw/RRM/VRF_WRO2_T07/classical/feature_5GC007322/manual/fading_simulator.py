import io
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.manual.logs_collector import logs_collector
from time import sleep
from six import ensure_str
import telnetlib
from datetime import datetime

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


def setup_fading_simulator(host, start_value_A, start_value_B):
    tn = telnetlib.Telnet(host, 3000)
    blog(tn)
    sleep(5)
    port_b = 'PORT:B1:LOSS {}\r\n'.format(start_value_B)
    tn.write(bytes(port_b, encoding='utf8'))
    sleep(0.5)
    port_a = 'PORT:A1:LOSS {}\r\n'.format(start_value_A)
    tn.write(bytes(port_a, encoding='utf8'))
    blog('Command sent B={}, A={}  dBm'.format(start_value_B, start_value_A))

    return tn


def start_simulation(host='10.42.221.77', start_value_A=80, end_value_A=90, step=1, start_value_B=80, end_value_B=90,
                     time_interval=180):
    tn = setup_fading_simulator(host, start_value_A, start_value_B)
    current_value_A = start_value_A
    current_value_B = start_value_B

    with open('/home/ute/time.txt', 'w') as f:
        while current_value_A <= end_value_A and current_value_B <= end_value_B:
            port_b = 'PORT:B1:LOSS {}\r\n'.format(current_value_B)
            tn.write(bytes(port_b, encoding='utf8'))
            sleep(0.5)
            port_a = 'PORT:A1:LOSS {}\r\n'.format(current_value_A)
            tn.write(bytes(port_a, encoding='utf8'))
            date = datetime.now().strftime('%Y_%m_%d-%I:%M:%S_%p')
            f.write('{} PORT:B1:LOSS {} PORT:A1:LOSS {}\n'.format(date, current_value_B, current_value_A))
            blog('Values: A: {} dBm B: {} dBm'.format(current_value_A, current_value_B))

            if end_value_A is not None:
                current_value_A += step
            if end_value_B is not None:
                current_value_B += step

            # collect_logs()
            # sleep(20)
            # collect_logs()
            sleep(time_interval)
    simulation_teardown(tn, start_value_A, start_value_B)


def simulation_teardown(tn, start_value_A, start_value_B):
    port_b = 'PORT:B1:LOSS {}\r\n'.format(start_value_B)
    tn.write(bytes(port_b, encoding='utf8'))
    sleep(0.5)
    port_a = 'PORT:A1:LOSS {}\r\n'.format(start_value_A)
    tn.write(bytes(port_a, encoding='utf8'))
    blog('Command sent B={}, A={}  dBm'.format(start_value_B, start_value_A))

    tn.write(b'quit\r\n')
    blog('QUIT sent')


def collect_logs():
    logs_collector(output_dir=None, log_name='logs_collector', duration=10, collect_l1l2=False, smod_lte=False,
                   smod_master=False, smod_slave=False, collect_tti=True, collect_btslog=False,
                   collect_snapshot=False)


def get_ue_battery_state(sn):
    _cm = ConnectionManager()
    with _cm.uepc_connection(autoconnect=False) as connection:
        cmd = f"adb {'-s ' + sn + ' ' if sn else ''}shell dumpsys battery"
        output = ensure_str(connection.execute_command(cmd))
        logger.info("Output of 'adb shell dumpsys battery':", also_to_console=False)
        logger.info(output, also_to_console=False)
    temperature = output.splitlines()
    for temperature in output.splitlines():
        temperature = temperature.strip()
        if temperature.startswith("temperature:"):

            value = temperature.split(":")[1].strip()
            try:
                temp_c = float(value) / 10.0
                blog(temp_c)
                return temp_c
            except ValueError:
                return None


def check_temperature(temperature):
    temperature = int(temperature)
    blog(temperature)
    if temperature is None:
        blog("lack of information about temperature")
        return False
    if temperature > 30:
        blog("Temperature to high.")
        a = 1
        return a
    elif temperature < 11:
        blog("Temperature to low")
        a = 0
        return a
    return False
