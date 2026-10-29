import logging
from collections import OrderedDict

from parsers import BearerStats

import scenarios

logger = logging.getLogger(__name__)


class TrafficStatisticsError(Exception):
    ROBOT_CONTINUE_ON_FAILURE = True


class TrafficScenarioNotFound(RuntimeError):
    pass


class traffic(object):
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.capacity = {'dl': 60, 'ul': 30}
        self.max_loss_rate = 10

        self._scenarios = OrderedDict()
        self._results = OrderedDict()

    def set_expected_cell_capacity(self, dl=60, ul=30):
        self.capacity['dl'] = int(dl)
        self.capacity['ul'] = int(ul)

    def add_traffic_scenario(self, name, ue_id, direction, ue_count='1', mbps=None):
        if not mbps:
            mbps = self.capacity[direction] / int(ue_count)
        self._scenarios[name] = scenarios.get_traffic_scenario(ue_id, direction, mbps)

    def add_traffic_scenario_result(self, name, output):
        self._results[name] = BearerStats(output)

    def traffic_loss_rate_should_be_lower_than_threshold(self, name, max_loss_rate=None):
        if not max_loss_rate:
            max_loss_rate = self.max_loss_rate

        loss_rate = self._results.get(name).loss_rate
        logger.info('Calculated loss rate: {}%'.format(loss_rate))
        logger.info('Maximum permitted loss rate: {}%'.format(max_loss_rate))
        # logger.info(self._results.get(name)) # Debug

        if loss_rate > max_loss_rate:
            raise TrafficStatisticsError("Loss rate {} is higher than threshold {}".format(loss_rate, max_loss_rate))

    def log_traffic_results(self):
        logger.info(self._results)

    def traffic_average_data_rate_should_be_higher_than(self, name, threshold):
        data_rate = self._results.get(name).average_data_rate
        logger.info('Minimum permitted average data rate: {}'.format(threshold))
        if data_rate < threshold:
            raise TrafficStatisticsError("Average data rate {} is lower than threshold {}".format(data_rate, threshold))

    def get_cmd_traffic_start(self, scenario_name):
        return self._get_scenario(scenario_name).cmd_start

    def get_cmd_traffic_stop(self, scenario_name):
        return self._get_scenario(scenario_name).cmd_stop

    def get_cmd_traffic_check(self, scenario_name):
        return self._get_scenario(scenario_name).cmd_check

    def get_traffic_scenario_names(self):
        return self._scenarios.keys()

    def clear_traffic_scenarios(self):
        self._scenarios = {}
        self._results = {}

    def _get_scenario(self, name):
        sc = self._scenarios.get(name)
        if sc:
            logger.debug('Requested Traffic Scenario: {}'.format(sc))
            return sc
        raise TrafficScenarioNotFound('>>{}<< not in [ {} ]'.format(
            name, self.get_traffic_scenario_names()))
