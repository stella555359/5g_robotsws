from robot.utils import ConnectionCache


class UEControl():
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self._ues = ConnectionCache()

    @property
    def current(self):
        return self._ues.current

    def create_ue(self, alias=None):
        ue = UE()
        ue_index = self._ues.register(ue, alias)
        return ue_index

    def add_bearer_to_ue(self, bearer_id, qci, weight):
        return self.current.add_bearer(bearer_id, qci, weight)

    def get_all_bearer_ids(self):
        return self.current.get_all_bearer_ids()

    def add_throughput_to_bearer(self, bearer_id, throughput):
        return self.current.add_throughput(bearer_id, throughput)

    def get_sum_of_throughput_of_bearers(self):
        return self.current.get_sum_of_throughput()

    def get_sum_of_scheduling_weight_of_bearers(self):
        return self.current.get_sum_of_scheduling_weights()

    def delete_bearer_from_ue(self, bearer_id):
        return self.current.delete_bearer(bearer_id)

    def get_scheduling_weight_throughput_dict(self):
        scheduling_weight_throughput = {}
        sum_of_throughput = self.get_sum_of_throughput_of_bearers()
        sum_of_scheduling = self.get_sum_of_scheduling_weight_of_bearers()
        scheduling_weight_throughput[sum_of_scheduling] = sum_of_throughput
        return scheduling_weight_throughput

    def store_scheduling_weight_throughput_dict_for_both_ues(self, ue_1_dict, ue_2_dict):
        ue_1_dict.update(ue_2_dict)
        return ue_1_dict

    def switch_ue(self, index_or_alias):
        old_index = self._ues.current_index
        self._ues.switch(index_or_alias)
        return old_index


class UE():
    def __init__(self):
        self.bearers = {}

    def add_bearer(self, bearer_id, qci, weight):
        self.bearers[bearer_id] = Bearer(bearer_id, qci, weight)
        return

    def get_all_bearer_ids(self):
        return ",".join(list(self.bearers.keys()))

    def add_throughput(self, bearer_id, value):
        self.bearers[bearer_id].add_throughput(value)

    def get_sum_of_throughput(self):
        return sum([int(bearer.throughput) for bearer in self.bearers.values()])

    def get_sum_of_scheduling_weights(self):
        return sum([int(bearer.scheduling_weight) for bearer in self.bearers.values()])

    def delete_bearer(self, bearer_id):
        del self.bearers[bearer_id]


class Bearer():
    def __init__(self, bearer_id, qci, weight):
        self.bearer_id = bearer_id
        self.qci = qci
        self.scheduling_weight = weight
        self.throughput = 0

    def add_throughput(self, value):
        self.throughput = int(value)
