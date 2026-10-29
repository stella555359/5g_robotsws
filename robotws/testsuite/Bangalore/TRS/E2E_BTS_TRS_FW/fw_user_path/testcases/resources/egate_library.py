# egate_library.py
# egate_library.py
import telnetlib
from robot.api import logger


def connect_and_execute_egate(port, variable_file):
    host = "0.0.0.0"  # Hard-coded host
    tn = telnetlib.Telnet(host, port)
    tn.read_until("EGATE>", timeout=60)
    command = "script file={}\n".format(variable_file)
    tn.write(command)
    logger.info('Command: {}'.format(command.strip()))
    # Read and log the response for each command in the script file
    with open(variable_file, 'r') as file:
        num_commands = sum(1 for line in file)
    for _ in range(num_commands):
        response = tn.read_until("EGATE>", timeout=60)
        if "EGATE>" not in response:
            logger.warn('Unexpected response, expected "EGATE>" prompt: {}'.format(response))
            break
        logger.info('Egate console response: {}'.format(response))
    tn.close()
