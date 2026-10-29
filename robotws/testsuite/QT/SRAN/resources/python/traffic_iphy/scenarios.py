import logging


class TrafficScenario(object):

    def __init__(self, ue_id, direction, mbps):
        self.ue_id = ue_id
        self.bearer_id = 1
        self.direction = direction
        self.mbps = mbps
        logging.debug('Created Traffic Scenario:\n'
                      'ue  : {}\n'
                      'dir : {}\n'
                      'mbps: {}'.format(ue_id, direction, mbps))

    @property
    def cmd_start(self):
        return "data_start ue={} id={} dir={} mbps={} cl_bearer_stats=on".format(
            self.ue_id, self.bearer_id, self.direction, self.mbps)

    @property
    def cmd_stop(self):
        return 'data_stop ue={}'.format(self.ue_id)

    @property
    def cmd_check(self):
        return "bearer_stats ue={} id={} dir={}".format(
            self.ue_id, self.bearer_id, self.direction)


def get_traffic_scenario(ue_id, direction, mbps):
    return TrafficScenario(ue_id, direction, mbps)
