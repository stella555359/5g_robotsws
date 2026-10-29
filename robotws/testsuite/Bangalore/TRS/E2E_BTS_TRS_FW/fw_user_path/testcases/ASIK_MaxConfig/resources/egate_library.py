import telnetlib
from robot.api import logger


def connect_and_execute_egate(port, variable_file):
    host = "0.0.0.0"  # Hard-coded host
    tn = telnetlib.Telnet(host, port)
    tn.read_until(b"EGATE>", timeout=60)  # Notice the 'b' before the string to indicate bytes

    command = "script file={}\n".format(variable_file).encode('utf-8')  # Encode to bytes
    tn.write(command)
    logger.info('Command: {}'.format(command.strip()))

    # Read and log the response for each command in the script file
    with open(variable_file, 'r') as file:
        num_commands = sum(1 for line in file)

    for _ in range(num_commands):
        response = tn.read_until(b"EGATE>", timeout=60)  # Notice the 'b' before the string
        if b"EGATE>" not in response:
            logger.warn('Unexpected response, expected "EGATE>" prompt: {}'.format(response.decode('utf-8')))
            break
        logger.info('Egate console response: {}'.format(response.decode('utf-8')))

    tn.close()
