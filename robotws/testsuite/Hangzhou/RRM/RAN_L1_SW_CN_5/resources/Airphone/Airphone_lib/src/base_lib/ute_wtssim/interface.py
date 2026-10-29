# -*- coding: utf-8 -*-

from .interfaces.wts import WtsInterface
from .interfaces.egate import WTSEgateInterface
from .interfaces.edaemon import WTSEdaemonInterface


class ute_wtssim(WtsInterface, WTSEgateInterface, WTSEdaemonInterface):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def _teardown_all_aliases(self):
        self.teardown_all_aliases_for_egate()
        self.teardown_all_aliases_for_edaemon()

    def _out_of_scope(self):
        try:
            if not self.save_egate:
                self._teardown_all_aliases()
        except AttributeError:
            self._teardown_all_aliases()
