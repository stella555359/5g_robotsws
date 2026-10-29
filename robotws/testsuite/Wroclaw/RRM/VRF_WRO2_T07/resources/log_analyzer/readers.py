import json
from abc import ABCMeta, abstractmethod
from itertools import chain

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.tshark import TSharkHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.str_pattern_dict import StrPatternDict
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import yield_lines_from_file
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.split_tshark_output_into_frames import \
    split_tshark_output_into_frames
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.tti_body_process_func import \
    tti_body_process_functions, \
    default_tti_process_message


class LogReader(object):

    __metaclass__ = ABCMeta

    @abstractmethod
    def generator(self):
        """  """
        pass

    @abstractmethod
    def reset_generator(self):
        """  """
        pass


class LogReaderBase(LogReader):
    """Base class for log reader."""

    def __init__(self, log_file):
        self.log_file = log_file
        self._gen = self._create_gen()

    def _create_gen(self):
        return yield_lines_from_file(self.log_file, skip_empty=True)

    def generator(self):
        return self._gen

    def reset_generator(self):
        self._gen = self._create_gen()
        return self._gen


class LineReader(LogReaderBase):
    """
    This reader is designed for reading text files line by line (e.g. Ue logs, btslog, plain text).
    You can pass a single file or multiple files in a list.
    The files' contents are converted to generators and chained together to form a single chunk.
    """

    def __init__(self, log_files):
        if not isinstance(log_files, list):
            log_files = [log_files]
        self.log_files = log_files
        self._gen = self._create_gen()

    def _create_gen(self):
        return chain(*[yield_lines_from_file(f, skip_empty=True) for f in self.log_files])


class TTIReader(LogReaderBase):
    """
    This reader is designed for reading TTI logs (.csv legacy format).
    You can pass a single file or multiple files in a list.
    The files' contents are converted to generators and chained together to form a single chunk.
    """

    def __init__(self, log_files, additional_process_funcs=None, name_to_body_separator=': '):
        if not isinstance(log_files, list):
            log_files = [log_files]
        self.log_files = log_files
        self.separator = name_to_body_separator
        additions = additional_process_funcs if additional_process_funcs else {}
        self.process_funcs = dict(tti_body_process_functions, **additions)
        self._gen = self._create_gen()

    def _process_message(self, line_number, line):
        try:
            message_name, message_body = line.split(self.separator, maxsplit=1)
        except ValueError:
            raise Exception('Could not read TTI properly. Incorrect tti-dec installed or corrupted logs.\n'
                            'Error in line: {}'.format(line))

        message = StrPatternDict()
        message['message'] = message_name
        message['line_number'] = line_number

        process = self.process_funcs.get(message_name, default_tti_process_message)
        message_body = process(message_body)
        message.update(message_body)
        return message

    def _create_gen(self):
        return (self._process_message(line_number, line)
                for line_number, line
                in enumerate(chain(*[yield_lines_from_file(f, strip=True) for f in self.log_files])))


class TsharkOutputReader(LogReaderBase):
    """This reader is designed for reading tshark output files obtained using the Tshark command."""

    def __init__(self, log_file):
        self.log_file = log_file
        self._gen = self._create_gen()

    def _create_gen(self):
        """Read tshark output and return frames."""
        return split_tshark_output_into_frames(
            yield_lines_from_file(
                self.log_file, skip_empty=True))


class PcapReader(TsharkOutputReader):
    """This reader is designed for reading .pcap files obtained using tcpdump."""

    def __init__(self, pcap_file_path, output_log_file, lua=None, tshark_filter=None, tshark_options=None):
        """
        Read .pcap file and turn it into frames.
        :param pcap_file_path: Path to .pcap file (str).
        :param output_log_file: File to store tshark output in (str).
        :param lua: Path to lua (str), None or boolean.
                for lua=None,        no lua will be used
                for lua=True,        attached lua will be used
                for lua=script_path, script_path lua will be used.
        :param tshark_filter: tshark filter, e.g. 'sctp' (str).
        :param tshark_options: list of tuple e.g. [('-o', 'someparam:TRUE'), ('-o', 'otherparam:TRUE')]
        """

        self.log_file = output_log_file
        self.lua = lua
        self.shark_filter = tshark_filter
        self.pcap_file_path = pcap_file_path
        self.output_log_file = output_log_file
        self.shark_options = tshark_options
        self._prepare_log_file()  # prepares data file for TsharkOutputReader generator
        self._gen = self._create_gen()

    def _prepare_log_file(self):
        """Assemble and run tshark command. Write its output to a tmp file, from which the generator reads frames."""
        m = self.__class__.__name__+': writing tshark output from .pcap file to {}'
        blog(m.format(self.output_log_file), console=False)
        tshark = TSharkHelper()
        tshark.add_pcap(self.pcap_file_path)
        if self.lua is not None:
            tshark.add_luascript(lua_path={True: None}.get(self.lua, self.lua))
        if self.shark_filter:
            tshark.add_filter(self.shark_filter)
        if self.shark_options:
            for param, value in self.shark_options:
                tshark.add(param, value)
        tshark.run(self.output_log_file)


class IterableReader(LogReaderBase):
    """
    This reader is designed in case you have many messages and don't know the exact order, in which they are received
    so we use any other finder then pass list of messages to IterableReader so we can search through them again.
    """

    def __init__(self, iterable):
        """Take an iterable and convert it to a generator"""
        self.iterable = iterable
        self._gen = self._create_gen()

    def _create_gen(self):
        return (i for i in self.iterable)


class ELTreader(LogReaderBase):

    def __init__(self, log_files):
        if not isinstance(log_files, list):
            log_files = [log_files]
        self.log_files = log_files
        self._gen = self._create_gen()

    def _create_gen(self):
        return (StrPatternDict(json_obj)
                for json_obj
                in chain(*[self.load_json(f) for f in self.log_files]))

    def load_json(self, log_file):
        with open(log_file) as log_data:
            return json.load(log_data)
