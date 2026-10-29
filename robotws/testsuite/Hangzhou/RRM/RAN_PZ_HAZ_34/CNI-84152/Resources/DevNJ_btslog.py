from robot.libraries.BuiltIn import BuiltIn


class DevNJ_btslog(object):
    """ Library btslog collector
    """

    """The Scope for the library imported in Robot Framework"""

    # The other 2 options is 'TEST CASE' and 'GLOBAL'
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${tl}')
        if self.tl.gnbs:
            from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import \
                GnbBtslogCollector as GnbBtslogCollector
            self.gnb_btslog = GnbBtslogCollector()
        if self.tl.enbs:
            from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import \
                EnbBtslogCollector as EnbBtslogCollector
            self.enb_btslog = EnbBtslogCollector()

    def _btslog_collector(self, func, bts_type='all', **kwargs):
        if self.tl.gnbs and bts_type.lower() == 'gnb':
            real_func = self.gnb_btslog.__getattribute__(func)
            real_func(**kwargs)
        elif self.tl.enbs and bts_type.lower() == 'enb':
            real_func = self.enb_btslog.__getattribute__(func)
            real_func(**kwargs)
        else:
            if self.tl.gnbs:
                for bts_id in range(0, len(self.tl.gnbs)):
                    kwargs['bts_id'] = bts_id
                    real_func = self.gnb_btslog.__getattribute__(func)
                    real_func(**kwargs)
            if self.tl.enbs:
                for bts_id in range(0, len(self.tl.enbs)):
                    kwargs['bts_id'] = bts_id
                    real_func = self.enb_btslog.__getattribute__(func)
                    real_func(**kwargs)

    def setup_sbts_btslog_collector(self, bts_type='all', bts_index=0, du_id=0, cu_id=0):
        """
        Setup BtsLog collector - using taf.collectors
        :param bts_type: means enb or gnb
        :param bts_index: BTS(eNB/gNB) index - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cu_id: Id of CommonUnit

        :return:
        """

        self._btslog_collector(func='setup_btslog_collector', bts_type=bts_type,
                               bts_id=bts_index, du_id=du_id, common_unit_id=cu_id)

    def start_collecting_sbts_btslog(self, bts_type='all', bts_index=0, du_id=0, cu_id=0):
        """
        Start collecting btslog - using taf.collectors
        :param bts_type: means enb or gnb
        :param bts_index: BTS(eNB/gNB) index - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param cu_id: Id of CommonUnit
        :return:
        """

        self._btslog_collector(func='start_collecting_btslog', bts_type=bts_type,
                               bts_id=bts_index, du_id=du_id, common_unit_id=cu_id)

    def stop_collecting_sbts_btslog(self, bts_type='all', bts_index=0, du_id=0, log_dir=None):
        """
        Stop collecting btslog - using taf.collectors
        :param bts_type: means enb or gnb
        :param bts_index: BTS(eNB/gNB) index - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param log_dir: Directory where btslog will be collected
        :return:
        """

        self._btslog_collector(func='stop_collecting_btslog', bts_type=bts_type,
                               bts_id=bts_index, du_id=du_id, log_dir=log_dir)

    def teardown_sbts_btslog_collector(self, bts_type='all', bts_index=0, du_id=0):
        """
        Teardown btslog collector - using taf.collectors
        :param bts_type: means enb or gnb
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """

        self._btslog_collector(func='teardown_btslog_collector', bts_type=bts_type,
                               bts_id=bts_index, du_id=du_id)
