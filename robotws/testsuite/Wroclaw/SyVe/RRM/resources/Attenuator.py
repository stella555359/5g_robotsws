from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from taf.hw.rf_attenuator import rf_attenuator
from time import sleep
from threading import Thread
from retrying import retry

MIN_ATTENUATION = 0
MAX_ATTENUATION = 63


def telnet_connection(action):
    def perform_action(*args, **kwargs):
        connection = rf_attenuator().setup_attenuator(Env.TESTLINE.attenuator[args[0].attenuator_id])
        try:
            action(_connection=connection, *args, **kwargs)
        finally:
            connection.disconnect()

    return perform_action


class Attenuator(object):

    def __init__(self, attenuator_id=0):
        self.attenuator_id = attenuator_id

    @property
    def attenuator_ports(self):
        return Env.TESTLINE.attenuator[self.attenuator_id].attenuator_ports

    @retry(stop_max_attempt_number=3, wait_fixed=1000)
    @telnet_connection
    def set_port_attenuation(self, port, target_attenuation, _connection):
        """
        Sets port attenuation on attenuator
        :param port: target attenuator port for attenuation change
        :param target_attenuation: new attenuation value in dB
        :param _connection: wrapped telnet connection
        :return: None
        """
        Logger.info("Setting attenuator port:{} with attenuation:{}dB".format(port, target_attenuation))
        _connection.set_port_attenuation(port=port, attenuation_value=target_attenuation)

    @telnet_connection
    def set_ports_attenuation(self, target_attenuation, _connection):
        """
        Sets all ports declared in TL initialization attenuation on attenuator
        :param target_attenuation: new attenuation value in dB
        :param _connection: wrapped telnet connection
        :return: None
        """
        for port in self.attenuator_ports:
            Logger.info("Setting attenuator port:{} with attenuation:{}dB".format(port, target_attenuation))
            _connection.set_port_attenuation(port=port, attenuation_value=target_attenuation)

    def restore_no_attenuation_on_all_ports(self):
        """
        Sets all ports declared in TL initialization attenuation on attenuator to no attenuation (0dB)
        :return: None
        """
        self.set_ports_attenuation(MIN_ATTENUATION)

    @telnet_connection
    def increase_port_attenuation_periodically(
            self, port, delta_attenuation, interval, number_of_repetition, _connection):
        """
        Periodically increases attenuation on given port
        :param port: The port for attenuation increase
        :param delta_attenuation: how many decibels to increase attenuation
        :param interval: repetition time in seconds
        :param number_of_repetition: how many times repeat the action
        :param _connection: wrapped telnet connection
        :return: None
        """
        Logger.info("Periodical attenuation increase on port {}".format(port))
        for repetition in range(1, number_of_repetition+1):
            self._increase_attenuation_on_port(port, delta_attenuation, _connection)
            Logger.info("Increased port {} attenuation: +{}dB, repetition "
                        "{}/{}".format(port, delta_attenuation*repetition, repetition, number_of_repetition))
            sleep(interval)

    @telnet_connection
    def increase_ports_attenuation_periodically(self, delta_attenuation, interval, number_of_repetition, _connection):
        """
        Periodically increases attenuation on all ports
        :param delta_attenuation: how many decibels to increase attenuation
        :param interval: repetition time in seconds
        :param number_of_repetition: how many times repeat the action
        :param _connection: wrapped telnet connection
        :return:
        """
        Logger.info("Periodical attenuation increase on all ports")
        for repetition in range(1, number_of_repetition+1):
            for port in self.attenuator_ports:
                self._increase_attenuation_on_port(port, delta_attenuation, _connection)
            Logger.info("Increased all ports attenuation: +{}dB,"
                        " repetition {}/{}".format(delta_attenuation*repetition, repetition, number_of_repetition))
            sleep(interval)

    @telnet_connection
    def decrease_port_attenuation_periodically(
            self, port, delta_attenuation, interval, number_of_repetition, _connection):
        """
        Periodically increases attenuation on given port
        :param port: The port for attenuation increase
        :param delta_attenuation: how many decibels to decrease attenuation
        :param interval: repetition time in seconds
        :param number_of_repetition: how many times repeat the action
        :param _connection: wrapped telnet connection
        :return: None
        """
        Logger.info("Periodical attenuation decrease on port {}".format(port))
        for repetition in range(1, number_of_repetition+1):
            self._decrease_attenuation_on_port(port, delta_attenuation, _connection)
            Logger.info("Decreased port {} attenuation: -{}dB, repetition "
                        "{}/{}".format(port, delta_attenuation*repetition, repetition, number_of_repetition))
            sleep(interval)

    @telnet_connection
    def decrease_ports_attenuation_periodically(self, delta_attenuation, interval, number_of_repetition, _connection):
        """
        Periodically increases attenuation on all ports
        :param delta_attenuation: how many decibels to decrease attenuation
        :param interval: repetition time in seconds
        :param number_of_repetition: how many times repeat the action
        :param _connection: wrapped telnet connection
        :return: None
        """
        Logger.info("Periodical attenuation decrease on all ports")
        for repetition in range(1, number_of_repetition+1):
            for port in self.attenuator_ports:
                self._decrease_attenuation_on_port(port, delta_attenuation, _connection)
            Logger.info("Decreased all ports attenuation: -{}dB,"
                        " repetition {}/{}".format(delta_attenuation*repetition, repetition, number_of_repetition))
            sleep(interval)

    @telnet_connection
    def perform_handover(self, ports_to_increase_attenuation, ports_to_decrease_attenuation, _connection,
                         target_bts_db_decrase_factor=1):
        """
        Performs handover form one cell to another on defined ports
        :param ports_to_increase_attenuation: list of ports to increase attenuation from MIN to MAX
        :param ports_to_decrease_attenuation: list of ports to decrease attenuation form MAX to MIN
        :param _connection: wrapped telnet connection
        :param target_bts_db_decrase_factor: speeds up good conditions on target BTS for handover when value > 1
        :return: None
        """
        thread_delay = 1
        step_increase = 2
        step_decrease = -2 * target_bts_db_decrase_factor
        Logger.info("Starting attenuation change for a handover")
        increase = Thread(target=self._change_attenuation_gradually,
                          args=(MIN_ATTENUATION, MAX_ATTENUATION, step_increase, ports_to_increase_attenuation,
                                _connection))
        decrease = Thread(target=self._change_attenuation_gradually,
                          args=(MAX_ATTENUATION, MIN_ATTENUATION, step_decrease, ports_to_decrease_attenuation,
                                _connection))
        increase.start()
        sleep(thread_delay)
        decrease.start()
        increase.join()
        decrease.join()

    @staticmethod
    def _change_attenuation_gradually(start_value, stop_value, step, ports, _connection):
        for attenuation in range(start_value, stop_value, step):
            for port in ports:
                _connection.set_port_attenuation(port, attenuation)

    @staticmethod
    def _increase_attenuation_on_port(port, delta_attenuation, _connection):
        current_attenuation = int(_connection.read_port_attenuation(port))
        new_attenuation = current_attenuation + delta_attenuation
        Logger.debug("Setting attenuator port:{} with attenuation:{}dB".format(port, new_attenuation))
        _connection.set_port_attenuation(port=port, attenuation_value=new_attenuation)

    @staticmethod
    def _decrease_attenuation_on_port(port, delta_attenuation, _connection):
        new_attenuation = int(_connection.read_port_attenuation(port)) - delta_attenuation
        if new_attenuation < 0:
            Logger.warning("There is MIN attenuation already set!! Setting to zero!!")
            new_attenuation = 0
        Logger.debug("Setting attenuator port:{} with attenuation:{}dB".format(port, new_attenuation))
        _connection.set_port_attenuation(port=port, attenuation_value=new_attenuation)
