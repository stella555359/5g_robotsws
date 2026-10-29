from taf.ul.sc.uesim.rtg.executor import Executor as RTGExecutor
from taf.ul.sc.uesim.cus.executor import Executor as CUSExecutor
from taf.ul.sc.perf.testline.generator import TestLineGenerator
from moler.config import load_config
from moler.device import DeviceFactory
import logging
import os


class ScenarioExecutor(object):
    def __init__(self):
        self.platform = 'CUS' if os.path.exists('/home/cus') else 'RTG'
        self.executor = {'RTG': RTGExecutor, 'CUS': CUSExecutor}[self.platform]()
        self.logger = logging.getLogger("scenario_executor")
        self.load_config()

    def start_scenario(self, scenario_name, timeout=300):

        if not self.executor.device:
            self.executor.device = DeviceFactory.get_device(name=self.platform)
        self._get_method('start')(scenario_name, timeout)

    def stop_scenario(self, timeout=180):
        if not self.executor.device:
            self.executor.device = DeviceFactory.get_device(name=self.platform)
        self._get_method('stop')(timeout)

    def _get_method(self, prefix):
        return getattr(self.executor, '{}_{}_scenario'.format(prefix, self.platform.lower()))

    def start_ue_mobile_session(self, session_name, timeout=60, **kwargs):
        if not self.executor.device:
            self.executor.device = DeviceFactory.get_device(name=self.platform)
        result = self.executor.start_ue_session(mobile_session=session_name, timeout=timeout, **kwargs)
        return result["SESSION_ID"]

    def stop_ue_mobile_session(self, ids, detach=False, timeout=60):
        ids = ids.encode('ascii', 'ignore') if isinstance(ids, unicode) else ids
        if isinstance(ids, str):
            ids = ids.split()
        elif not isinstance(ids, list):
            raise ValueError("Parameter 'ids' is not a list")
        if not self.executor.device:
            self.executor.device = DeviceFactory.get_device(name=self.platform)
        result = self.executor.stop_ue_session(ids=ids, detach=detach, timeout=timeout)
        if "WARNINGS" in result:
            for warning in result["WARNINGS"]:
                self.logger.warn(warning)

    def load_config(self):
        try:
            tl_generator = TestLineGenerator(conf={'ue': {'type': self.platform,
                                                          'workstation': {'host': 'localhost', 'login': 'ute',
                                                                          'password': 'ute', 'root_password': 'ute'}},
                                                   'btss': [], })
            tl_generator.prepare_moler_configuration()
            load_config(config=tl_generator.mlc._config, config_type='dict')
        except Exception:
            self.logger.error("Load config error")
