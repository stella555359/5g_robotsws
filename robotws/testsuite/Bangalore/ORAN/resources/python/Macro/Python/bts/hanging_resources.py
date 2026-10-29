import logging


class HangingResources(object):
    def __init__(self, device, process='RROMexe'):
        """
        Class for checking if BTS has hanging resources via AASHELL.

        :param device: instance of ENB moler device
        :param process: name of process on which checks hanging resources
        """

        self.device = device
        self.process = process
        self.node = self._get_node()

    def _get_node(self):
        """
        Get node name on which is running passed process.
        """

        self.device.goto_state('AASHELL')
        nodes_cmd = self.device.get_cmd(cmd_name='nodes', cmd_params={
            'options': '-p'})
        nodes = nodes_cmd()

        for node in nodes:
            if self.process in nodes[node]['processes']:
                return node

    def _get_resource_usage(self):
        """
        Get resources usage for given process and node.

        :return: results of command get_resources_usage
        {'ResourcesUsageInfoResponses': [{'ENBC ': {
                                       'contextInfoList': [],
                                     'numContextInfo': 0,
                                     'numEnbUeS1APIds': 0,
                                     'numEnbUeX2APIds': 0,
                                     'numTeIds': 0}},
                          {'TUPC ': {'connectionInfoList': [],
                                     'numS1Connections': 0,
                                     'numS1Links': 1,
                                     'numX2Connections': 0,
                                     'numX2Links': 0}},
...
...
...
                          {'MAC 0': {'contextInfoList': [],
                                     'numCells': 0,
                                     'numContextInfos': 0,
                                     'poolId': 1,
                                     'userResourcesPerCell': [],
                                     'userResourcesPerPool': {
                                         'contextType': 'EContextType_L2Pcell',
                                         'numContexts': 0,
                                         'numDRbs': 0}}}]}
        """

        self.device.goto_state('AASHELL')
        get_resources_cmd = self.device.get_cmd(cmd_name='get_resources_usage',
                                                cmd_params={
                                                    'options':
                                                        '-a -j @{} #{}'.format(
                                                            self.process,
                                                            self.node)})
        return get_resources_cmd()

    def get_hanging_resources(self):
        """
        Get Hanging resources.

        :return: list of hanging_resources
        """

        hanging_resources = []
        resources = self._get_resource_usage()
        logging.debug(msg="All Resources: {}".format(resources))
        for path_to_resource in self.__dict_generator(resources):
            parameter = path_to_resource[-2]
            value = path_to_resource[-1]
            try:
                if "num" in parameter and parameter not in ['numCells',
                                                            'numS1Links',
                                                            'numX2Links']:
                    if value > 0:
                        hanging_resources.append(hanging_resources)
                        logging.debug(msg="Possibly hanging users: {}".
                                      format(path_to_resource))
            except TypeError:
                pass

        return hanging_resources

    def verify_hanging_resources(self, raise_exception=False):
        """
        Verify if hanging resources exist on BTS.

        :param raise_exception: If set to True - raise
                HangingResourcesDetected exception. Otherwise log warning
        """

        hanging_resources = self.get_hanging_resources()
        if hanging_resources:
            msg = "Hanging users detected: {}".format(hanging_resources)
            if raise_exception:
                raise HangingResourcesDetected(msg)
            else:
                logging.warn(msg)
        else:
            logging.info("No hanging users detected")

    def __dict_generator(self, dict_obj, prefix=None):
        """
        Get full path to the most nested value.
        :param dict_obj: dict object
        :param prefix: prefix to path
        :return: Full path to the most nested value
                 eg: ['ResourcesUsageInfoResponses', 'MAC 0',
                 'userResourcesPerPool', 'numDRbs', 0]
        """
        prefix = prefix[:] if prefix else []
        if isinstance(dict_obj, dict):
            for key, value in dict_obj.items():
                if isinstance(value, dict):
                    for d in self.__dict_generator(value, prefix + [key]):
                        yield d
                elif isinstance(value, (list, tuple)):
                    for v in value:
                        for d in self.__dict_generator(v, prefix + [key]):
                            yield d
                else:
                    yield prefix + [key, value]
        else:
            yield dict_obj


class HangingResourcesDetected(Exception):
    pass
