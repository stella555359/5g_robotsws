import logging
from taf.hw.optical_attenuator.client import client


class AttenuatorManagement:
    def __init__(self):
        self.att_client = client()

    def setup_attenuator_client(self, attenuator):
        """
        Setup attenuation client which can be used to set attenuation
        :param location: 1.1-4/1
        :return: None
        """
        self.att_client.setup_attenuator(server_ip=attenuator.ip_addr, vendor='kingfisher', location=attenuator.port)

    def set_attenuation(self, value, port=1):
        """
        Applies given attenuation
        :param value: attenuation value to be applied in dB, type: Union[str,int,float]
        :param port: attenuator port, currently only 1 is supported, type: int
        :return: None
        """
        logging.info("Setting attenuation: {} dB".format(value))
        self.att_client.set_attenuation(attenuator_port=port, attenuation_value=value)
