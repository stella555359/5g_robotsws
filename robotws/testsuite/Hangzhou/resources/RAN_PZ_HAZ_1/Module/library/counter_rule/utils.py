# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Przemyslaw Daniel - initial version
        Grzegorz Latuszek - code cleanup, documentation, exceptions handling refactored
:contact: pawel.nogiec@nokia.com, maciej.malczyk@nokia.com
:maintainers: Pawel Nogiec, Maciej Malczyk
created: 2015-03-17
"""
import importlib

from robot.libraries.BuiltIn import BuiltIn
import functools
import signal
import re


def get_library_instance(library_name):
    """Gets instance of library in order: instance from robot or import lib if not found"""
    try:
        lib_instance = BuiltIn().get_library_instance(library_name)
    except Exception:
        library = importlib.import_module(library_name)
        if hasattr(library, library_name):
            instance = getattr(library, library_name)
            lib_instance = instance()
        else:
            lib_instance = library()
    return lib_instance


class NotFoundKeyError(KeyError):
    """
    NotFoundKeyError
    :returns: NotFoundKeyError class
    """

    def __init__(self, key, container):
        """
        Creates instance NotFoundKeyError
        :param key:
        :param container:
        """
        super(NotFoundKeyError, self).__init__()
        self.key = key
        self.container = container

    def __str__(self):
        container_dump = container_truncated_dump(self.container)
        err = "Key '%s' doesn't exist inside container:\n%s" % (
            self.key, container_dump)
        return err


def container_truncated_dump(container):
    """
    Truncates container
    :param container:
    :return:
    """
    container_dump = str(container)
    if len(container_dump) > 220:  # don't print whole container if it is big
        parts = container_dump.split()  # we don't want to see truncated keys if possible
        start = ' '.join(parts[:10])
        if len(start) > 150:
            start = start[:150]
        end = ' '.join(parts[-4:])
        if len(end) > 50:
            end = end[-50:]
        container_dump = "%s\n   ...\n   %s" % (start, end)
    return container_dump


class AmbiguousKeyError(KeyError):
    """
    AmbiguousKeyError class
    :returns: AmbiguousKeyError class
    """

    def __init__(self, key, container, possible_access):
        """
        Creates instance
        :param key:
        :param container:
        :param possible_access:
        """
        super(AmbiguousKeyError, self).__init__()
        self.key = key
        self.container = container
        self.possible_access = possible_access

    def __str__(self):
        access_parts = '\n'.join(self.possible_access)
        access = "Container's value access via key '%s' has following possibilities:\n%s" % (
            self.key, access_parts)
        container_dump = container_truncated_dump(self.container)
        err = "Key '%s' is not unique inside container:\n%s;\n%s" % (
            self.key, container_dump, access)
        return err


def get_value_by_unique_key(input, key, debug=False, raise_on_not_found_key=False):  # noqa
    """
    Search deep inside input container for value of given key.

    If key exists in container and is unique we get value.
    If multiple such keys exist in container - AmbiguousKeyError is raised
    If given key doesn't exist inside container we return None or raise NotFoundKeyError

    :param input:                  container to be searched
    :param key:                    key to search value by
    :param debug:                  lets return path to given key
    :param raise_on_not_found_key: should we raise NotFoundKeyError or just return None
    :return:                       value under key  or  None
    """
    key_list = []

    def walk(container, key, key_path=""):
        """
        Own walk method
        :param container:
        :param key:
        :param key_path:
        :return:
        """
        if isinstance(container, list):
            for (index, elem) in enumerate(container):
                walk(elem, key, "%s[%s]" % (key_path, index))
        if isinstance(container, dict):
            for key_of_container in container.keys():
                if key_of_container == key:
                    key_list.append("%s['%s']" % (key_path, key_of_container))
                walk(
                    container[key_of_container], key, "%s['%s']" %
                    (key_path, key_of_container))

    param_name = "input"

    walk(input, key, param_name)
    if len(key_list) > 1:
        raise AmbiguousKeyError(
            key=key,
            container=input,
            possible_access=key_list)
    elif len(key_list) == 1:
        ret = key_list[0]
        if not debug:
            ret = eval(ret)
        return ret
    else:
        if raise_on_not_found_key:
            raise NotFoundKeyError(key=key, container=input)
        else:
            return None


def get_all_values_by_key(input, key, raise_on_not_found_key=False):  # noqa
    """
    Search deep inside input container for all values under given key.

    If key exists in container and is unique we get list with single value.
    If multiple such keys exist in container - we gat list of all that values
    If given key doesn't exist inside container we return empty list or raise NotFoundKeyError

    :param input:                  container to be searched
    :param key:                    key to search value by
    :param raise_on_not_found_key: should we raise NotFoundKeyError or just return []
    :return:                       all values under key  or  []
    """
    key_list = []

    def walk(input, key, key_path=""):
        """
        Own walk method
        :param input:
        :param key:
        :param key_path:
        :return:
        """
        if isinstance(input, list):
            index = 0
            for elem in input:
                walk(elem, key, "%s[%s]" % (key_path, index))
                index += 1
        if isinstance(input, dict):
            for key_of_container in input.keys():
                if re.match(key, key_of_container) is not None:
                    key_list.append("%s['%s']" % (key_path, key_of_container))
                walk(
                    input[key_of_container], key, "%s['%s']" %
                    (key_path, key_of_container))

    walk(input, key, "input")
    all_values = {}
    for key_path in key_list:
        k = re.search(r"(\[[\'a-zA-Z0-9\-\_]+\])+", key_path)
        all_values["".join(k.group())] = eval(key_path)
        # all_values.append(eval(key_path))

    if (all_values == []) and raise_on_not_found_key:
        raise NotFoundKeyError(key=key, container=input)

    return all_values


def timeout_for_python(sec):
    """
    timeout decorator
    :param sec: function raise TimeoutError after ? seconds
    """
    def decorator(func):
        @functools.wraps(func)
        def wrapped_func(*args, **kwargs):

            def _handle_timeout(signum, frame):
                err_msg = 'Function {} timed out after {} seconds'.format(
                    func.__name__, sec)
                raise TimeoutError(err_msg)

            signal.signal(signal.SIGALRM, _handle_timeout)
            signal.alarm(sec)
            try:
                result = func(*args, **kwargs)
            finally:
                signal.alarm(0)
            return result

        return wrapped_func
    return decorator
