# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import fields_config as fields


class TtiParser(object):
    """Class used for parsing .txt TTI file"""

    def __init__(self):
        self._headers_line_index = None
        self._headers = None

    def parse_traces(self, file_path, filter_broken_traces=True):
        """Parses file with collected TTI traces.

        :param str file_path: path to file with TTI traces
        :param bool filter_broken_traces: If set to True, can filter out broken traces (those without cRnti)
        :return: list of parsed TTI traces, each trace is a dictionary
        :rtype: list[dict]
        """
        file_content = self._read_file_content(file_path)
        self._headers = self._read_headers(file_content)
        traces = self._parse_traces(file_content, filter_broken_traces)
        return traces

    def get_headers(self, file_path):
        """Gets headers for each column from file with TTI traces

        :param str file_path: path to file with TTI traces
        :return: headers for each column
        :rtype: list[str]
        """
        file_content = self._read_file_content(file_path)
        headers = self._read_headers(file_content)
        return headers

    def _read_file_content(self, file_path):
        """Reads content of TTI file as list of lines

        :param str file_path: path to file with TTI traces
        :return: list of lines
        :rtype: list[str]
        """
        with open(file_path, "r") as f:
            return [line.strip() for line in f]

    def _read_headers(self, file_content):
        """Reads headers (name of each column) from TTI traces

        :param list[str] file_content: list of lines from TTI traces file
        :return: list of names
        :rtype: list[str]
        """
        headers_line = ""
        for line in file_content:
            if "time" in line.lower():
                headers_line = line
                break
        self._headers_line_index = file_content.index(headers_line)
        return headers_line.split(",")

    def _parse_traces(self, file_content, filter_broken_traces):
        """Parses traces basing on found headers

        :param list[str] file_content: list of lines from TTI traces file
        :param bool filter_broken_traces: If set to True, can filter out broken traces (those without cRnti)
        :return: list of parsed traces
        :rtype: list[dict]
        """
        index = self._headers_line_index + 1
        traces_content = file_content[index:]
        output_traces = [
            {header: field for header, field in zip(self._headers, trace.split(","))} for trace in traces_content
        ]
        if filter_broken_traces:
            output_traces = self._filter_broken_traces(output_traces)
        return output_traces

    def _filter_broken_traces(self, traces_list):
        """Filters out broken traces (without cRnti)

        :param list[dict] traces_list: list of parsed traces
        :return: filtered traces
        :rtype: list[dict]
        """
        crnti_key = fields.UL_CRNTI if fields.UL_CRNTI in self._headers else fields.DL_CRNTI
        return [trace for trace in traces_list if trace[crnti_key] != "-"]
