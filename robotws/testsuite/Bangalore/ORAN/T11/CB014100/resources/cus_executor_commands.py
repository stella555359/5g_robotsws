# -*- coding: utf-8 -*-
"""
Copyright: Nokia

"""

import asyncio
import logging
import re
from robot.api import logger
import telnetlib3
from typing import Union, Tuple

RU_TRACES_TIME = 'mplane ctrl-1 ru traces_time'
CM_CONNECT = 'cm connect'
CONFIG_UPDATE = 'config update'
UPDATE_KNIFE = 'config remote knife'
REVERT_KNIFE = 'config remote knife revert'
RESTART_CUS = 'config remote restart'
UPDATE_TGRS = 'config remote update tgr-1 tgr-2'

CUS_EXECUTOR_HOST = "0"
CUS_EXECUTOR_PORT = 1234


async def open_cus_executor_conn(host: str = CUS_EXECUTOR_HOST,
                                 port: int = CUS_EXECUTOR_PORT) -> Tuple[asyncio.StreamReader, asyncio.StreamWriter]:
    """ Open cus-executor session. """
    reader, writer = await telnetlib3.open_connection(host, port)
    await asyncio.wait_for(reader.readuntil(b'CUS>'), 20)  # always skip first line in reader
    return reader, writer


async def close_telnet_command(writer: asyncio.StreamWriter):
    logger.info('Close telnet connection')
    writer.close()


async def run_cus_executor_command(command: str, phrase: bytes = None, timeout: int = 30,
                                   get_full_output: bool = None) -> Union[bytes]:
    reader, writer = await open_cus_executor_conn()
    try:
        writer.write(command + '\n')
        logger.info(f'Run cus-executor command: {command}')
        if 'mplane' in command:
            first_line = await reader.readuntil(b'CUS>')
            if get_full_output is True:
                full_command_output = await reader.readuntil(b'CUS>')
                return full_command_output
        command_output = await wait_for_phrase(reader, phrase, timeout)
        return command_output
    finally:
        await close_telnet_command(writer)


async def wait_for_phrase(reader: asyncio.StreamReader, phrase: bytes, timeout) -> Union[bytes, bool]:
    start_time = asyncio.get_event_loop().time()
    while True:
        try:
            output = await asyncio.wait_for(reader.readuntil(phrase), timeout)
            return output
        except asyncio.IncompleteReadError:
            logging.error(f'IncompleteReadError for {phrase}')
            return False
        except asyncio.TimeoutError:
            if asyncio.get_event_loop().time() - start_time > timeout:
                logging.error(f'TimeoutError: {phrase} not found in {timeout} sec')
                return False


async def cm_connect(command: str = CM_CONNECT) -> Union[bytes, bool]:
    phrase = b'Connection Manager: All SECTORs and TGRs connected'
    command_output = await run_cus_executor_command(command, phrase)
    return command_output


async def restart_cus(command: str = RESTART_CUS) -> Union[bytes, bool]:
    phrase = b'[ctrl_1] RETURN CODE: 0'
    tgr1 = b'[tgr_1] RETURN CODE: 0'
    tgr2 = b'[tgr_2] RETURN CODE: 0'
    command_output = await run_cus_executor_command(command, phrase)
    return command_output


async def update_knife(command: str = UPDATE_KNIFE, timeout: int = 600) -> Union[bytes, bool]:
    """ Return None when the same knife is already on CUS """
    phrase = b'SUM|   [ctrl_1]'
    command_output = await run_cus_executor_command(command, phrase, timeout)
    if b'SUM| SKIPPED:' not in command_output:
        logging.info('Knife update| SUCCESS')
        return command_output
    else:
        logging.info('Knife update| SKIPPED')


async def revert_knife(command: str = REVERT_KNIFE, timeout: int = 600) -> Union[bytes, bool]:
    phrase = b'SUM| SUCCESS:'
    command_output = await run_cus_executor_command(command, phrase, timeout)
    logging.info('Knife revert| SUCCESS')
    return command_output


async def update_tgrs(command: str = UPDATE_TGRS) -> Union[bytes, bool]:
    phrase1 = b'[tgr_1] RETURN CODE: 0'
    phrase2 = b'[tgr_2] RETURN CODE: 0'
    command_output1 = await run_cus_executor_command(command, phrase1)
    command_output2 = await run_cus_executor_command(command, phrase2)
    return command_output2


async def ru_traces_time(command: str = RU_TRACES_TIME) -> Union[bytes, bool]:
    phrase = b'CUS>'
    command_output = await run_cus_executor_command(command, phrase)
    return command_output


async def config_update(command: str = CONFIG_UPDATE) -> Union[bytes, bool]:
    phrase = b'New configuration applied'
    coco_yaml_path: str = '/home/ute/MN/UTE/robotlte/testsuite/IHT/suites/CUS2/CLOUD_LO_CUS_LO/EntityTests/' \
                          'intra_board_bb_forwarding_ecpri_3_cells/resources/' \
                          'coco_intra_board_bb_forwarding_ecpri_3_cells.yaml'
    command = f"{CONFIG_UPDATE} {coco_yaml_path}"
    command_output = await run_cus_executor_command(command, phrase)
    return command_output


async def parse_ru_traces_time() -> str:
    """
    Function gets total time of radio setup for each radio between following messages:
    RU_CONTAINER_STARTUP -> ESTABLISHED_CONNECTION
    """
    output: bytes = await ru_traces_time()
    if isinstance(output, bytes):
        output: str = output.decode('utf-8').replace('\r', '\n')
        ru_serial_numbers = re.findall(r'\[CUS([^]]+)]', output)
        ru_total_times = re.findall(r'Total time:\s+([\d.]+)\s+s', output)
        last_ru_id = len(ru_serial_numbers)
        ru_total_time = ""
        ru_id = 0
        while ru_id < last_ru_id:
            ru_total_time += f"[CUS{ru_serial_numbers[ru_id]}] RU{ru_id + 1} - {ru_total_times[ru_id]} sec\n\n"
            ru_id = ru_id + 1
    else:
        logging.error('Something gone wrong. Could not get proper result from cus-executor.')
        return 'Data from cus-executor missing.'
    return ru_total_time


def get_ru_traces_time_parsed():
    return asyncio.run(parse_ru_traces_time())


def run_cus_command(func):
    """ Helper function to run command """
    return asyncio.run(func)


if __name__ == '__main__':
    """ commands without controller restart """
    run_cus_command(cm_connect())
    run_cus_command(config_update())
    run_cus_command(update_tgrs())
    run_cus_command(ru_traces_time())
    run_cus_command(parse_ru_traces_time())
    run_cus_command(config_update())
    """ commands with controller restart """
    # run_cus_command(restart_cus())
    # run_cus_command(update_knife())
    # run_cus_command(revert_knife())
