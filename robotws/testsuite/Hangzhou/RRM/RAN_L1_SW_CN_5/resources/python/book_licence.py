# -*- coding: utf-8 -*-
"""
:author: Charlotte Wu
:contact: charlotte.wu@nokia-sbell.com
:maintainer: None
:contact: None
"""

import threading
import time


class LicenceBooker(object):

    def __init__(self):
        self._timer_thread = None
        self._keep_secs = None
        self._book_interva = None
        self._loop_count = None
        self._licence_keeper = None

    def require_licence_keeper(self, licence_keeper):
        self._licence_keeper = licence_keeper

    def book_licence(self, keep_secs, book_interval=2):
        self._keep_secs = int(keep_secs)
        self._book_interval = int(book_interval)
        self._loop_count = int(int(keep_secs) / int(self._book_interval))
        self.__get_licence()

    def __get_licence(self):
        if self._loop_count <= 0:
            self._licence_keeper.get_licence_qxdm_5g()
            self._licence_keeper.get_licence_qcat_5g()
            self.release()
            return
        self._loop_count -= 1
        self._licence_keeper.get_licence_qxdm_5g()
        self._licence_keeper.get_licence_qcat_5g()
        print("have got licence")

        self._timer_thread = threading.Timer(self._book_interval, self.__get_licence)
        self._timer_thread.start()

    def release(self):
        self._licence_keeper.release_licence_qxdm_5g()
        self._licence_keeper.release_licence_qcat_5g()
        if self._timer_thread:
            self._timer_thread.cancel()
            self._timer_thread = None
