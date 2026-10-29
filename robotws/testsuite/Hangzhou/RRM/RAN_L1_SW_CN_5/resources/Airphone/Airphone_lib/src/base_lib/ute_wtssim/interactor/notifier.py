# -*- coding: utf-8 -*-

import logging

from ..exception import CannotAddNotificationClient
from .importer import DotClientImporter, NonDotClientImporter


def catch_client_errors(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except CannotAddNotificationClient:
            raise
        except Exception as e:
            log = logging.getLogger(__name__)
            log.debug("It was not possible to initialize client library because of {}".format(e))
    return wrapper


class Notifier(object):
    def __init__(self):
        self._clients = {}

    @property
    def clients(self):
        return self._clients

    @catch_client_errors
    def egate_created(self, egate, alias, *args):
        if alias in self._clients:
            raise CannotAddNotificationClient("Provided alias exists and cannot be overridden. "
                                              "Please execute teardown method.")
        self._clients[alias] = []
        for each in args:
            client = self._import_client(each)
            if not client or not hasattr(client, 'egate_created'):
                continue
            client.egate_created(egate, alias)
            self._clients[alias].append(client)
        if not self._clients[alias]:
            self._clients.pop(alias)

    @catch_client_errors
    def egate_deleted(self, alias):
        if alias not in self._clients:
            return
        for each in self._clients[alias]:
            if not hasattr(each, 'egate_deleted'):
                continue
            each.egate_deleted(alias)
        self._clients.pop(alias)

    def _import_client(self, path):
        if '.' in path:
            return DotClientImporter().import_client(path)
        return NonDotClientImporter().import_client(path)
