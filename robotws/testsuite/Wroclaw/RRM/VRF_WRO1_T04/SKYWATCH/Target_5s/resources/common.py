import asyncio
import telnetlib
# import time
# from functools import wraps
from random import randint
from robot.api import logger
from datetime import datetime
# from asyncio_scenario_runner import START_TIME
from ute_wtssim import ute_wtssim
from ue_profiles import activate_bler_profile, deactivate_bler_profile

ue_capa_path = (f'/home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/'
                f'Target_5s/config_65/skywatch_ue_nr_capa.cfg')
wtssim = ute_wtssim()


def setup_ute_egate():
    wtssim.setup_egate(egate_port=20000)


# def measure_time(func):
#     @wraps(func)
#     async def wrapper(*args, **kwargs):
#         start = time.perf_counter()
#         result = await func(*args, **kwargs)
#         end = time.perf_counter()
#         print(f"{func.__name__} finished in {end - start:.4f} seconds")
#         return result
#     return wrapper


def pdu_id_pair_generator(max_id):
    while True:
        for i in range(1, max_id, 2):
            yield [i, (i + 1) % max_id]


def ue_id_generator(start_id, max_id):
    while True:
        for i in range(start_id, max_id):
            yield i


async def prepare_and_register_ue_with_pdu_sessions(ue_id, target_cell, watcher=None, nwslice=1,
                                                    cause='mo-Signalling'):
    await ue_change_location(ue_id=ue_id, cell=target_cell, watcher=watcher)
    await modify_rrc_setup_cause(ue_id=ue_id, cause=cause, watcher=watcher)
    await watcher.send_command(f"ue_register id={ue_id}")
    await watcher.wait_for_pattern(fr"UE{ue_id}: UE performed Registration type", timeout=5)
    await asyncio.sleep(0.01)
    await watcher.send_command(f"ue_pdu_session_setup ue={ue_id} pdu=1 nwslice={nwslice}")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Established PDU session ID=1", timeout=5)
    await asyncio.sleep(1)
    await watcher.send_command(f"ue_pdu_session_setup ue={ue_id} pdu=2 nwslice=1")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Established PDU session ID=2", timeout=5)


async def attach_ue(ue_id, watcher=None):
    await watcher.send_command(f"ue_attach id={ue_id}")
    await watcher.wait_for_pattern(fr"UE{ue_id}: === UE IS ACTIVE", timeout=4)


async def perform_sgnb_addition_procedure(ue_id, target_cell, watcher=None):
    await watcher.send_command(f"ue_dc_enb_start ue={ue_id} target_gnb=2 "
                               f"target_cells={target_cell} bearer=2 type=split_scg")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Successfully reconfigured dual connectivity", timeout=4)


async def register_ue(ue_id, watcher=None):
    if watcher:
        await watcher.send_command(f"ue_register id={ue_id}")
    else:
        execute_wts_command(cmd=f"ue_register id={ue_id}",
                            wait_for_regex=f"UE{ue_id}: UE performed Registration type INITIAL_REGISTRATION")


def modify_ue_capabilities(ue_id, ue_capa_name):
    execute_wts_command(cmd=f"ue_param capability_file={ue_capa_path} id={ue_id} ue_nr_capabilities={ue_capa_name}")


def trigger_handover_by_a3(ue_id, phy_cell_id='50',
                           srsrp_part='srsrp_nr=11 srsrq_nr=11 ssinr_nr=11',
                           nrsrp_part='nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30'):
    execute_wts_command(cmd=f"ue_measurement_send_nr id={ue_id} meas_id=1 "
                            f"event=A3 {srsrp_part} phycell_id={phy_cell_id} {nrsrp_part}")
    logger.info(f"HO ue:{ue_id} to cell{phy_cell_id} using A3 ", also_console=True)


async def deregister_ue_by_switch_off(ue_id, watcher=None):
    await watcher.send_command(f"ue_deregister id={ue_id} ue_deregister_type=switch_off")
    await watcher.wait_for_pattern(fr"UE{ue_id}: detached", timeout=4)
    # await watcher.send_command(f"ue_kill id={ue_id}")


def transfer_file_with_udp(ue_id=1, pdu=1, qfi=1, direction='dl',
                           file_size='1G', speed='mbps=100', wait_time_sec='12'):
    execute_wts_command(cmd=f"trf_data_start ue={ue_id}, pdu={pdu} qfi={qfi} dir={direction} {speed} bytes={file_size}")
    logger.info(f"Transferring file {file_size} with speed {speed} ", also_console=True)
    # time.sleep(int(wait_time_sec))


def start_continuous_udp_traffic(ue_id=1, pdu=1, qfi=1, direction='dl',
                                 speed='mbps=100'):
    execute_wts_command(cmd=f"trf_data_start ue={ue_id}, pdu={pdu} qfi={qfi} dir={direction} {speed}")
    logger.info(f"Start continuous udp traffic to ue {ue_id}", also_console=True)


async def modify_rrc_setup_cause(ue_id, cause, watcher=None):
    await watcher.send_command(f"ue_nr_rrc_setup_param id={ue_id} establishment_cause={cause}")


def execute_wts_command(cmd='', wait_for_regex=None):
    host = '0'
    port = 20000
    timeout = 10

    try:
        if wait_for_regex:
            send_time = datetime.now()
            wtssim.execute_egate_command_and_wait_for_data(cmd, pass_regexp=wait_for_regex, timeout=4)
        else:
            telnet = telnetlib.Telnet(host, port, timeout)
            telnet.read_until(b"EGATE")
            telnet.write(cmd.encode('ascii') + b"\n")
            telnet.read_until(b"EGATE")
            send_time = datetime.now()
            telnet.close()
            # time.sleep(0.1)
    except Exception as e:
        print(f"An error occurred: {e}")
    logger.info(f"{send_time} cmd: {cmd}", also_console=True)
    # with open(f"CMD_LOG_{START_TIME}.txt", "a") as file:
    #     file.write(f"{send_time} cmd: {cmd}\n")


async def add_fiveqi_1_to_pdu_2(ue_id, watcher=None):
    await watcher.send_command(f"ue_pdu_session_modify ue={ue_id} pdu=2 qosflows_to_add=3")
    await watcher.wait_for_pattern(fr"UE{ue_id}: Ue {ue_id} PduId 2 Created FiveQi:Qfi mapping fiveQi 1 qfi 2",
                                   timeout=4)
    await asyncio.sleep(0.5)


async def add_delay_to_scenario(delay_from=3, delay_to=100):
    await random_delay_within_range(delay_from=delay_from, delay_to=delay_to)


async def add_exact_delay_to_scenario(delay=0):
    await asyncio.sleep(delay)


async def random_delay_within_range(delay_from=1, delay_to=5):
    random_sleep_time = randint(delay_from, delay_to)
    # print('Random delay: ', random_sleep_time)
#    time.sleep(random_sleep_time)
    await asyncio.sleep(random_sleep_time)


async def ue_change_location(ue_id, cell, enb=2, watcher=None):
    await watcher.send_command(f"ue_change_location id={ue_id} cell={cell} enb={enb}")


def modify_ue_capa(ue_id):
    execute_wts_command(cmd=f"ue_param capability_file=/home/ute/Desktop/ue_nr_capa_s24.cfg id={ue_id}"
                            f" ue_nr_capabilities=s24_ue_nr")
