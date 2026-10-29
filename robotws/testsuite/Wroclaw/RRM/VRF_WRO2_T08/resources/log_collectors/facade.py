"""
Log collector facade which utilizes common log collector interface to provide a coherent way to
adjust and use each collector.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""


from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import \
    continue_on_failure
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger


class LogCollectorFacade:
    def __init__(self):
        self._collectors = []
        self._chosen_ue_log = None

    @property
    def used_aliases(self):
        return {collector.alias for collector in self._collectors}

    def add_collector(self, collector):
        if collector.alias in self.used_aliases:
            logger.info(f"Collector with alias {collector.alias} already added to facade!")
        else:
            self._collectors.append(collector)

    def setup_log_collectors(self):
        for collector in self._collectors:
            logger.info(f"Setting up {collector.alias} collector...")
            collector.setup()
            logger.info(f"{collector.alias} collector set up!")

    def start_log_collecting(self):
        for collector in self._collectors:
            logger.info(f"Starting collection of {collector.alias} log...")
            collector.start_log_collecting()
            logger.info(f"{collector.alias} log collection started!")

    def stop_log_collecting(self):
        failed_to_stop = []
        collectors = reversed(self._collectors)
        for collector in collectors:
            _, is_stopped = self._stop_log_collector(collector)
            if not is_stopped:
                failed_to_stop.append(collector.alias)
        assert not failed_to_stop, (
            f"Following log collectors could not stop: {failed_to_stop}. Inspect log for details"
        )

    @continue_on_failure()
    def _stop_log_collector(self, collector):
        logger.info(f"Stopping collection of {collector.alias} log...")
        collector.stop_log_collecting()
        logger.info(f"{collector.alias} log collection stopped!")

    def download_logs(self, log_prefix):
        returns = {}
        failed_downloads = []
        for collector in self._collectors:
            log_filepath, is_collected = self._download_collected_log(collector, log_prefix)
            if is_collected:
                returns[collector.alias] = log_filepath
            else:
                failed_downloads.append(collector.alias)
        assert not failed_downloads, (
            f"Following logs could not be downloaded: {failed_downloads}. Inspect log for details"
        )
        return returns

    @continue_on_failure()
    def _download_collected_log(self, collector, log_prefix):
        logger.info(f"Downloading {collector.alias} log...")
        log_filepath = collector.download_log(log_prefix)
        logger.info(f"{collector.alias} log downloaded!")
        return log_filepath

    def shutdown_log_collectors(self):
        failed_collectors = []
        for collector in self._collectors:
            logger.info(f"Shutting down {collector.alias} collector...")
            _, result = self._shutdown_collector(collector)
            if not result:
                failed_collectors.append(collector.alias)
        self._collectors = []
        assert not failed_collectors, (
            f"Following log collectors have not shutdown correctly: {failed_collectors}. Inspect log for details"
        )

    @continue_on_failure()
    def _shutdown_collector(self, collector):
        collector.shutdown()
        logger.info(f"{collector.alias} collector shut down!")
