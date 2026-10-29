# Author: wojciech.kaleta@nokia.com

import telnetlib3 as telnetlib
import time
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger


class Fader:
    def __init__(self):
        """Initialize the fader connection object."""

        self.connection: telnetlib.Telnet = telnetlib.Telnet()
        self.timeout: float = 1.0

    def setup(self, ip: str, port: int = 3000) -> None:
        """Open telnet connection to the fader.

        :param ip: IP address of the fader.
        :param port: TCP port used for the telnet connection.
        """
        self.connection.open(ip, port)

    def teardown(self) -> None:
        """Close telnet connection to the fader."""
        self.connection.close()

    def set_vertex_attenuation(self, atten: float, ch_ports: str) -> None:
        """Set attenuation for a given vertex and channel ports.

        :param atten: Attenuation value in dB.
        :param ch_ports: Channel port identifier used in the fader command.
        """
        self.connection.write(f"PORT:B{ch_ports}:LOSS {atten}\r\n".encode('ascii'))
        self.connection.write(f"PORT:A{ch_ports}:LOSS {atten}\r\n".encode('ascii'))
        time.sleep(1)
        for i in range(5):
            line = self.connection.read_until(b"\n", timeout=self.timeout)  # Read one line
            if line == b'\n':
                break
            logger.info(f"Read from fader: {line}", also_to_console=True)
