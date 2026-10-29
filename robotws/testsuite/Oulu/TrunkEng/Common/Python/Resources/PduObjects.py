class CommonUnit:

    def __init__(self, power_breaker_ip,
                 power_breaker_port,
                 smod_type,
                 serial_number,
                 product_code,
                 mplane_ip="",
                 power_breaker_type="ENICS"):

        """
        :param string power_breaker_ip: ip address of the power breaker
        :param int power_breaker_port: port number in power breaker, given as an integer
        :param string smod_type: type of SMOD (e.g. ASIA)
        :param string serial_number: serial number of SMOD
        :param string product_code: product code of SMOD
        :param string mplane_ip: (Optional) mplane ip address
        :param string power_breaker_type: (Optional) type of power breaker, ENICS by default
        """

        self.power_breaker_ip = power_breaker_ip
        self.power_breaker_port = power_breaker_port
        self.smod_type = smod_type
        self.serial_number = serial_number
        self.product_code = product_code

        if mplane_ip:
            self.mplane_ip = mplane_ip

        if power_breaker_type:
            self.power_breaker_type = power_breaker_type


class RU:

    def __init__(self, power_breaker_ip,
                 power_breaker_port,
                 ru_hw_group,
                 radio_type,
                 serial_number,
                 product_code,
                 mplane_ip="",
                 power_breaker_type="ENICS"):

        """
        :param string power_breaker_ip: ip address of the power breaker
        :param int power_breaker_port: port number in power breaker, given as an integer list (e.g. [2])
        :param string ru_hw_group: (e.g. LTE_RADIO)
        :param radio_type: type of RMOD (e.g. FRGS)
        :param string serial_number: serial number of RMOD
        :param string product_code: product code of RMOD
        :param string mplane_ip: (Optional) mplane ip address
        :param string power_breaker_type: (Optional) type of power breaker, ENICS by default
        """

        self.power_breaker_ip = power_breaker_ip
        self.power_breaker_port = power_breaker_port
        self.ru_hw_group = ru_hw_group
        self.radio_type = radio_type
        self.serial_number = serial_number
        self.product_code = product_code
        if mplane_ip:
            self.mplane_ip = mplane_ip

        if power_breaker_type:
            self.power_breaker_type = power_breaker_type


class PduInformation:

    def __init__(self, smod, radios):
        """
        :param CommonUnit smod: SMOD
        :param list[RU] radios: list of RUs
        """
        self.smod = smod
        self.radios = radios
