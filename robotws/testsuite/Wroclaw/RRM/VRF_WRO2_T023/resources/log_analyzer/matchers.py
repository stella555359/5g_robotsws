from functools import partial
from abc import ABCMeta, abstractmethod

from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.common.regex import get_regex_match


def _not(f):
    def _f(*args, **kargs):
        return not f(*args, **kargs)

    return _f


class MessageMatcher(object):

    __metaclass__ = ABCMeta

    @abstractmethod
    def __init__(self, tag):
        """Only tag parameter, which is used by finder is required."""
        pass

    @abstractmethod
    def __call__(self, frame):
        """Expected to return True for frame matching conditions, False otherwise."""
        pass


class SyslogMessageMatcher(MessageMatcher):
    """
    This matcher is designed for matching syslog messages (plain text).
    Implements call method, which returns matches.
    """

    def __init__(self, pattern, tag=None, regex_engine='fnmatch'):
        self.regex_match = get_regex_match(regex_engine)
        self.tag = {None: pattern}.get(tag, tag)
        self.pattern = pattern

    def __call__(self, syslog_line):
        return self.regex_match(syslog_line, self.pattern)


class PcapMessageMatcher(MessageMatcher):

    # fnmatch compatible patterns
    name_line_patterns = {
        'empty': '{}',
        'structure': '*{}*(Structure)*',
    }

    def __init__(self, message_name_pattern, value_pattern=None, tag=None, path_filter=None,
                 regex_engine='fnmatch', message_type_pattern='structure'):
        """
        message_name_pattern is meant to be the whole name of the message, e.g. 'SlotTypeReq'.
        message_type_pattern is the type of the message, e.g. (Structure, empty, Object, float...).
        Tag is used to identify message [check PcapMessageFinder to find out how].
        If tag is not provided message_name_pattern is used as tag value.

        :param message_name_pattern: Name of the message you want to search for in .pcap, e.g. 'PucchReceive' (str).
        :param value_pattern: Value of the message you are searching for (str).
        :param tag: check PcapMessageFinder for more info.
        :param path_filter: This is a StrPatternDict filter used for filtering paths (List<str>).
        :param regex_engine: Search engine used for matching the messages (callable, str).
        :param message_type_pattern: The pattern of message type in .pcap, e.g. '<msg> (Structure)'.
        """

        self.tag = tag
        if not tag:
            self.tag = message_name_pattern

        self.chain = []

        name_line_regex = self.name_line_patterns.\
            get(message_type_pattern, message_type_pattern).format(message_name_pattern)

        self.containing(key_pattern=name_line_regex, value_pattern=value_pattern,
                        path_filter=path_filter, regex_engine=regex_engine)

    @staticmethod
    def _contains(frame, key_pattern, value_pattern=None, path_filter=None, regex_engine=None):
        """
        Check whether frame contains a given key_pattern (message) and a given value_pattern if provided.
        If path_filter is provided, the resulting StrPatternDict will be filtered.
        :param path_filter: This is a StrPatternDict path filter (List<str).
        :returns True if matching entry found, False otherwise.
        """

        if frame is None:
            return False
        found_paths = frame.find(key_pattern, regex_engine)
        if path_filter:
            found_paths = found_paths.filter(part_pattern_path=path_filter, engine=regex_engine)
        if not found_paths:
            return False

        if value_pattern:
            regex_match = get_regex_match(regex_engine)
            for dictionary in found_paths:
                if regex_match(dictionary['val'], value_pattern):
                    return True
            return False

        return True

    def _append_contains_function(self, key_pattern, value_pattern=None, path_filter=None,
                                  regex_engine=None, negate=False):
        f = pf = partial(
            self._contains,
            key_pattern=key_pattern,
            value_pattern=value_pattern,
            path_filter=path_filter,
            regex_engine=regex_engine
        )

        if negate:
            f = _not(pf)

        self.chain.append(f)

    def containing(self, key_pattern, value_pattern=None, path_filter=None, regex_engine='fnmatch'):
        self._append_contains_function(
            key_pattern=key_pattern,
            value_pattern=value_pattern,
            path_filter=path_filter,
            regex_engine=regex_engine
        )
        return self

    def not_containing(self, key_pattern, value_pattern=None, path_filter=None, regex_engine='fnmatch'):
        self._append_contains_function(
            key_pattern=key_pattern,
            value_pattern=value_pattern,
            path_filter=path_filter,
            regex_engine=regex_engine,
            negate=True
        )
        return self

    def check(self, frame):
        for f in self.chain:
            if f(frame) is False:
                return False
        return True

    def __call__(self, frame):
        return self.check(frame)


class TTIMessageMatcher(MessageMatcher):
    """
    This is a similar implementation to PcapMessageMatcher.
    TTI messages are by their nature StrPatternDicts, e.g. [{'message': 'message_name', ....}].
    The matcher is iterating over the 'message' key by default,
    but this can be changed by setting the 'message_key_pattern' parameter.
    usage:
        TTIMessageMatcher('1', message_key_pattern='sfn')
        will find all messages with parameter 'sfn' == '1'
    """

    def __init__(self, message_value_pattern, tag=None, engine='fnmatch', message_key_pattern='message'):
        self.tag = tag
        if not tag:
            self.tag = message_value_pattern

        self.chain = []

        self.containing(message_key_pattern, message_value_pattern, engine)

    @staticmethod
    def _contains(message, key_pattern, val_pattern=None, regex_engine=None):
        try:
            val = message(key_pattern)
            if val_pattern:
                regex_match = get_regex_match(regex_engine)
                return regex_match(val, val_pattern)
            return True
        except KeyError:
            return False

    def _append_contains_function(
            self, key_pattern, val_pattern=None, regex_engine=None, negate=False
    ):
        f = pf = partial(
            self._contains,
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
        )

        if negate:
            f = _not(pf)

        self.chain.append(f)

    def containing(self, key_pattern, val_pattern=None, regex_engine='fnmatch'):
        self._append_contains_function(
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
        )
        return self

    c = containing

    def not_containing(self, key_pattern, val_pattern=None, regex_engine='fnmatch'):
        self._append_contains_function(
            key_pattern=key_pattern, val_pattern=val_pattern, regex_engine=regex_engine,
            negate=True
        )
        return self

    nc = not_containing

    def check(self, frame):
        for f in self.chain:
            if f(frame) is False:
                return False
        return True

    def __call__(self, frame):
        return self.check(frame)
