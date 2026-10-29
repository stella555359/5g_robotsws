#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
from types import MethodType
from datetime import datetime
import six
import logging
import signal
import json
import codecs
import os
from types import SimpleNamespace


class IpaMmlItem:
    """ base class for items contained in CommonDict """

    def __str__(self):
        """ support a nice string representation with all attribute values"""
        attrs = [x for x in dir(self) if not x.startswith('_') and
                 getattr(self, x) is not None and
                 type(getattr(self, x)) is not MethodType]
        attrs.sort()

        tmp = "\n".join(["    %-30s  =  [%s]  %s" % (
            item, getattr(self, item), str(type(getattr(self, item)).__name__))
            for item in attrs])

        for i in range(len(tmp)):
            if ord(tmp[i]) > 127:
                tmp = tmp.replace(tmp[i], " ")
        return str(self.__class__.__name__) + ':\n{\n' + tmp + '\n}\n'

    def __repr__(self):
        return self.__str__()

    def __unicode__(self):
        return self.__str__()

    def __getitem__(self, item):
        return getattr(self, item)


class c_global_store(object):

    def __init__(self):
        self._cpcs_ = {}
        self._proxy_list_ = {}
        self._mos = {}

    def add_mo(self, mo=None, alias=''):
        if alias in self._mos:
            return self._mos[alias]
        else:
            self._mos[alias] = mo
            return mo

    def get_mo(self, alias):
        if alias in self._mos:
            return self._mos[alias]
        else:
            return None

    def del_mo(self, alias):
        if alias in self._mos:
            del self._mos[alias]
        # else:
        #     logging.error('MO with alias {} does not exist'.format(alias))


global_store = c_global_store()


class IpaMmlDict(dict):
    def __init__(self, *args):
        dict.__init__(self, *args)
        self.ordered_keys = []

    def __str__(self):
        """ support a nice string representation """
        try:
            tmp = "\n".join(['%s:[%s]' % (str(key), str(self[key])) for key in
                            self.ordered_keys])
            for i in range(len(tmp)):
                if ord(tmp[i]) > 127:
                    tmp = tmp.replace(tmp[i], " ")
            return tmp
        except AttributeError:
            return ""

    def __repr__(self):
        return self.__str__()

    def __unicode__(self):
        return self.__str__()

    def __getitem__(self, key):
        if len(self) == 0:
            return None
        try:
            return dict.__getitem__(self, key)
        except KeyError:
            pass

        if isinstance(key, int):
            try:
                return dict.__getitem__(self, self.ordered_keys[key])
            except IndexError:
                pass
        return None

    def __setitem__(self, key, item):
        dict.__setitem__(self, key, item)
        try:
            if key in self.ordered_keys:
                self.ordered_keys.remove(key)
            self.ordered_keys.append(key)
        except AttributeError:
            self.ordered_keys = [key, ]

    def __delitem__(self, key):
        try:
            dict.__delitem__(self, key)
            self.ordered_keys.remove(key)
        except KeyError:
            if isinstance(key, int):
                dict.__delitem__(self, self.ordered_keys[key])
                del (self.ordered_keys[key])

    def __getattr__(self, name):
        if len(self) != 1:
            raise AttributeError
        return getattr(self.values()[0], name)

    def length(self):
        return len(self)

    def _get_empty_container(self):
        return {}

    def sort(self, *args):
        try:
            self.ordered_keys.sort(*args)
        except AttributeError:
            pass


class KeywordGroup(IpaMmlDict):
    def __init__(self):
        IpaMmlDict.__init__(self)
        time_now = datetime.now()
        self.id = time_now.strftime(
            '%Y%m%d%H%M%S') + ('%03d' % time_now.microsecond)[:3]

    def append(self, kw_name, *args):
        from robot.libraries import BuiltIn
        builtin = BuiltIn.BuiltIn()
        item = KeywordItem()
        item.name = kw_name
        item.args = list(args)
        try:
            result = builtin.run_keyword(kw_name, *args)
            item.status = 'PASS'
            item.result = result
        except Exception as e:
            item.status = 'FAILED'
            item.result = e
        item.end_time = datetime.now()
        self['%d' % len(self)] = item

    def __str__(self):
        return 'keywordgroup%s' % self.id


class KeywordItem(IpaMmlItem):
    def __init__(self):
        self.name = ''
        self.args = []
        self.result = None
        self.status = None
        self.start_time = datetime.now()
        self.end_time = None


def init_keyword_group():
    return KeywordGroup()


def run_keyword_in_group(group, kw_name, *args):
    group.append(kw_name, *args)


def finish_keyword_group(group):
    error_list = []
    for item in sorted(group.values(), key=lambda x: x.start_time):
        if item.status == 'FAILED':
            msg = ''
            if isinstance(item.result, six.string_types):
                msg = item.result
            elif (isinstance(item.result, list) or
                  isinstance(item.result, tuple)):
                msg = '\n'.join([str(e) for e in item.result])
            elif isinstance(item.result, dict):
                msg = str(item.result)
            else:
                msg = str(item.result)
            error_msg = ('Failed keyword: "%s"\nStart: %s, End: %s, '
                         'Duration: %s\nError message: %s\n' %
                         (item.name,
                          item.start_time,
                          item.end_time,
                          (item.end_time - item.start_time), msg))
            error_list.append(error_msg)

    if error_list:
        raise AssertionError('\n'.join(error_list))


def device_config(device_type, device_index):
    curr_path = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(os.sep.join(curr_path.split(os.sep)[:-5]), 'HAZ5', 'config')
    config_file = os.path.join(config_path, device_type, f'{device_type}_{device_index}.json')
    logging.info(f'Config file: {config_file}')
    if os.path.exists(config_file):
        with codecs.open(config_file, encoding='utf-8') as f:
            return json.loads(f.read(), object_hook=lambda d: SimpleNamespace(**d))
    else:
        raise Exception(f'Could not find the device config file {config_file}')


def run_command(command):
    import subprocess
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = proc.communicate()
    output = stdout.decode().splitlines()
    if output:
        logging.debug('CMD STDOUT ==>:')
        for line in output:
            logging.debug(f'           ==> {line}')
    output = stderr.decode().splitlines()
    if output:
        logging.debug('CMD STDOUT ==>:')
        for line in output:
            logging.debug(f'           ==> {line}')


class TimeoutError(Exception):
    pass


def timeout(seconds=10, error_message='TimeoutError'):
    def decorator(func):
        def _handle_timeout(signum, frame):
            raise TimeoutError(error_message)

        def wrapper(*args, **kwargs):
            signal.signal(signal.SIGALRM, _handle_timeout)
            signal.alarm(seconds)
            try:
                result = func(*args, **kwargs)
            finally:
                signal.alarm(0)
            return result
        return wrapper
    return decorator


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    # p = device_config('tm500', '27')
    p = device_config('ipsl', '32')
    # cmd = 'sshpass -p qqwweeRR0- ssh ute@10.106.200.66 pwd'
    # run_command(cmd)
    # print(p)
