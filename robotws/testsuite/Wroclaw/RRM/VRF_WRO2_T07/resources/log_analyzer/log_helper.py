from os import remove

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.readers import \
    LineReader, TsharkOutputReader, TTIReader, PcapReader, IterableReader, ELTreader
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.finder import MessageFinder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_tmp_filepath
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher


@logged_keyword
def log_finder(pcap_file, tfilter, message_name_pattern, message_type_pattern='empty'):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_file, tshark_filter=tfilter, lua=None)
        return finder.find_all(PcapMessageMatcher(message_name_pattern, message_type_pattern=message_type_pattern))


class LogHelper(object):
    """
    This class is a convenience wrapper around message finder/log reader classes.
    If .pcap finder is used, creation and cleanup of temporary files is available.
    It is recommended to use this class as context manager (automatic cleanup will be performed).
    In short:
        LogHelper is the main entry point of the log utils. After initialization you can add different log finders.
        Each of these finders later needs you to pass a matcher for that specific log type. In result, the final call
        sequence might look like this:
            with LogHelper() as lh:
                finder = lh.add_syslog(log_file)
                msg = finder.find_next(SyslogMessageMatcher('*The message you're looking for*', regex_engine='re'))
                assert msg is not None, 'The message could not be found.'
    examples:
        syslog: feature 5GC002333, feature 5GC000774-A
        tti:
        pcap: feature 5GC000723
    """

    def __init__(self):
        self._cleanup_list = []

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.clean_up()

    def clean_up(self):
        for tmp_file in self._cleanup_list:
            try:
                remove(tmp_file)
            except OSError as e:
                m = ' removing {} caused error {}'
                em = self.__class__.__name__ + m
                blog(em.format(tmp_file, e))

    @staticmethod
    def _add_line_log(log_files):
        return MessageFinder(LineReader(log_files=log_files))

    add_syslog = _add_line_log

    @staticmethod
    def add_tti(log_files, additional_process_funcs=None, name_to_body_separator=': '):
        return MessageFinder(TTIReader(
            log_files=log_files, additional_process_funcs=additional_process_funcs,
            name_to_body_separator=name_to_body_separator
        ))

    @staticmethod
    def add_tshark_output(ts_output_file):
        return MessageFinder(TsharkOutputReader(log_file=ts_output_file))

    def add_pcap(self, pcap_file_path, lua=None, tshark_filter=None, output_log_file=None,
                 clean_up_tmp_file=True, tshark_options=None):
        if not output_log_file:
            m = self.__class__.__name__+': generating random tshark output data file path'
            blog(m, console=False)
            output_log_file = get_tmp_filepath(tail='.pcap')

        m = self.__class__.__name__+': tshark output data file path: {}'
        blog(m.format(output_log_file), console=False)

        if clean_up_tmp_file:
            self._cleanup_list.append(output_log_file)

        return MessageFinder(PcapReader(
            pcap_file_path=pcap_file_path,
            output_log_file=output_log_file,
            lua=lua, tshark_filter=tshark_filter,
            tshark_options=tshark_options
        ))

    @staticmethod
    def add_iterable(iterable):
        return MessageFinder(IterableReader(iterable))

    @staticmethod
    def add_elt(log_file):
        return MessageFinder(ELTreader(log_file))
