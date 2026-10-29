# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:  Zhu baijie
:contact: baijie.zhu@nokia-sbell.com
"""
import re


def read_tti_trace(filename, selected_fieldnames=None):
    """
        Read TTI trace from csv file and return trace analyzer object

        :param string filename: ttitrace file name
        :param string selected_fieldnames: fieldnames
        :return: TtiTrace

        - Example::

              ${tti trace}=    Read tti trace    tti_trace_ul.txt
    """
    with open(filename, 'r') as tracefile:
        trace_text = tracefile.read()

    if selected_fieldnames and (
        isinstance(
            selected_fieldnames,
            unicode) or isinstance(
            selected_fieldnames,
            str)):
        expected_fieldnames_separators = [", ", "; ", " ", ",", ";"]
        fieldnames_separator = [
            i for i in expected_fieldnames_separators if i in selected_fieldnames][0]
        selected_fieldnames = [
            remove_char(s) for s in selected_fieldnames.split(fieldnames_separator)]
    return TtiTrace.create_from_text(
        trace_text, selected_fieldnames=selected_fieldnames)


def filter_trace(trace, condition):
    """
        Filters tti trace based on condition and returns a new
    trace object which contains only the lines which match the given
    condition.

        :param TtiTrace trace: TtiTrace object
        :param String condition: Match condition given as Python expression
                             Tti trace fields can be referred with their
                             names in tti trace heading, e.g. Time.
                             By default, fields are interpreted as strings
                             but can be converted to float, int by
                             e.g. actBufferThreshold.int.

        :return: TtiTrace

        - Example::

              ${filtered}=    Filter trace    ${TTI_TRACE}    actBufferThreshold.int == 53775
              and ulCurrentResult == 'ACTIVATE'
    """
    return trace.filter_trace(condition)


def create_subtrace(trace, start, end):
    """
        Creates subtrace by splicing the trace between start and end lines.
        :param TtiTrace trace: TtiTrace object
        :param Integer start: Start index for splicing
        :param Integer end: End index for splicing (open ended, similar to Python splice)
        :return: TtiTrace

        - Example::

              ${subtrace}=    Create subtrace    ${TTI_TRACE}    0    2
    """
    return trace.create_subtrace(int(start), int(end))


def get_line(trace, index):
    """
        Returns tti trace line from given index.

        :param TtiTrace trace: TtiTrace object
        :param Integer index: Line index in tti trace
                  (index 0 is the first line containing a real trace event)
        :return: TraceLine

        - Example::

              ${sixth line}=    Get line    ${TTI_TRACE}    5
    """
    return trace[int(index)]


def get_line_indices_matching(trace, condition):
    """
        Returns a list of line indices in trace which match given condition.

        :param TtiTrace trace: TtiTrace object
        :param String condition: Match condition given as Python expression
                             Tti trace fields can be referred with their
                             names in tti trace heading, e.g. Time.
                             By default, fields are interpreted as strings
                             but can be converted to float, int or time by
                             e.g. actBufferThreshold.int.
        :return: list of line indices

        - Example::

              ${line_numbers}=    Get line indices matching    ${TTI_TRACE}    actBufferThreshold.int == 53775
    """
    return trace.get_line_indices_matching(condition)


def search_bw_from(trace, start, condition):
    """
        Searches backwards from given index. Returns the index of first
    line which matches the given condition. Returns ${NONE} if no matching
    line is found. Line at index is not included to search, the search
    begins from line at start - 1.

        :param TtiTrace trace: TtiTrace object
        :param Integer start: Start index of the search
        :param String condition: Match condition given as Python expression
                             Tti trace fields can be referred with their
                             names in tti trace heading, e.g. Time.
                             By default, fields are interpreted as strings
                             but can be converted to float, int or time by
                             e.g. actBufferThreshold.int.
        :return: index of next mathching line, ${NONE} if not found

        - Example:

              ${prev_retx_index}=    Search bw from    ${TTI TRACE}    10    'ACTIVATE' in ulLatestResult
    """

    return trace.search_bw_from(int(start), condition)


def search_fw_from(trace, start, condition):
    """
        Searches forwards from given index. Returns the index of first
    line which matches the given condition. Returns ${NONE} if no matching
    line is found. Line at index is not included to search, the search
    begins from line at start + 1.

        :param TtiTrace trace: TtiTrace object
        :param Integer start: Start index of the search
        :param String condition: Match condition given as Python expression
                             Tti trace fields can be referred with their
                             names in tti trace heading, e.g. Time.
                             By default, fields are interpreted as strings
                             but can be converted to float, int or time by
                             e.g. ETtiTraceUlParUe_dataInLcg0.int.
        :return: index of next mathching line, ${NONE} if not found

        - Example:

              ${high ticks index}=  Search fw from    ${TTI_TRACE}    0    bufferLevel.int > actBufferThreshold.int
    """
    return trace.search_fw_from(int(start), condition)


class TtiTrace(object):

    FIELDNAMES_LINE = 0
    DATA_BEGIN_LINE = 1
    FW = 1
    BW = -1

    @classmethod
    def create_from_text(cls, text_trace, selected_fieldnames=None):
        selected_columns = None
        trace_lines = text_trace.splitlines()
        fieldnames = cls._read_fieldnames(trace_lines)
        if selected_fieldnames:
            selected_columns, fieldnames = match_columns_indexes_by_names(
                selected_fieldnames, fieldnames)
        trace_object_lines = [TraceLine(fieldnames, text_line, selected_columns)
                              for text_line in trace_lines[cls.DATA_BEGIN_LINE:]]
        return cls(trace_object_lines, fieldnames)

    @classmethod
    def _read_fieldnames(cls, trace_lines):
        return trace_lines[cls.FIELDNAMES_LINE].strip(',;').split(',')

    def __init__(self, trace_line_objects, fieldnames):
        self._fieldnames = fieldnames
        self._lines = trace_line_objects

    def __len__(self):
        return len(self._lines)

    def get_fieldnames(self):
        return self._fieldnames

    def get_line(self, index):
        return self._lines[index]

    def __getitem__(self, index):
        return self.get_line(index)

    def filter_trace(self, condition):
        condition_function, fields = make_condition_function(
            condition, self.get_fieldnames())
        return self.filter_trace_with_function(condition_function, *fields)

    def create_subtrace(self, start, end):
        return TtiTrace(self._lines[start:end], self.get_fieldnames())

    def filter_trace_with_function(
            self,
            match_function,
            *fieldnames_to_compare):
        def match_function_on_lines(line):
            return match_function(
                *
                self._get_fields_to_compare(
                    line,
                    fieldnames_to_compare))
        return TtiTrace(list(filter(match_function_on_lines, self._lines)),
                        self.get_fieldnames())

    def get_line_indices_matching(self, condition):
        condition_function, fields = make_condition_function(
            condition, self.get_fieldnames())
        return self._get_line_indices_matching_function(
            condition_function, *fields)

    def _get_line_indices_matching_function(
            self, match_function, *fieldnames_to_compare):
        def match_function_on_lines(line):
            return match_function(
                *
                self._get_fields_to_compare(
                    line,
                    fieldnames_to_compare))
        matching_indices = []
        for index, line in enumerate(self._lines):
            if match_function_on_lines(line):
                matching_indices.append(index)
        return matching_indices

    def search_bw_from(self, start, condition):
        condition_function, fields = make_condition_function(
            condition, self.get_fieldnames())
        return self._search_from(self.BW, start, condition_function, *fields)

    def search_fw_from(self, start, condition):
        condition_function, fields = make_condition_function(
            condition, self.get_fieldnames())
        return self._search_from(self.FW, start, condition_function, *fields)

    def _search_from(
            self,
            direction,
            start,
            match_function,
            *fieldnames_to_compare):
        end = len(self._lines) if direction == self.FW else -1
        for i in range((start + direction), end, direction):
            if match_function(
                *
                self._get_fields_to_compare(
                    self._lines[i],
                    fieldnames_to_compare)):
                return i

    def _get_fields_to_compare(self, line, fieldnames_to_compare):
        return [getattr(line, fieldname)
                for fieldname in fieldnames_to_compare]

    def __str__(self):
        return '\n'.join(str(line) for line in self._lines)


class TraceLine(object):

    def __init__(self, fieldnames, text_line, selected_columns=None):
        self._text_line = text_line
        fieldvalues = text_line.split(',')
        if isinstance(selected_columns, list):
            fieldvalues = [fieldvalues[i] for i in selected_columns]
        self._fields = dict(list(zip(fieldnames, fieldvalues)))

    def __getattr__(self, name):
        return TraceField(self._fields[name])

    def __str__(self):
        return self._text_line

    def __repr__(self):
        return self.__str__()


class TraceField(str):

    @property
    def int(self):
        try:
            return int(self)
        except BaseException:
            return 0

    @property
    def float(self):
        try:
            return float(self)
        except BaseException:
            return 0.0


class NonListException(Exception):
    pass


class AmbiguousFieldNameException(Exception):
    pass


class MultipleOccurenceOfSelectedColumnException(Exception):
    pass


class FieldnameNotFoundException(Exception):
    pass


def remove_char(string, char=' '):
    while char in string:
        string = string.replace(char, '')
    return string


def match_column_names(selected_names, fieldnames):
    if not isinstance(selected_names, list):
        raise NonListException(
            "List expected in {}, got {}".format(
                match_column_names.__name__,
                selected_names))
    filtered_names = []
    for i in selected_names:
        if i not in filtered_names:
            found_fields = []
            for f in fieldnames:
                if i == f:
                    found_fields.append(f)
                    filtered_names.append(f)
                    break
                elif i.upper() in f.upper():
                    found_fields.append(f)
                    filtered_names.append(f)
            if len(found_fields) > 1:
                ambiguous_list = (
                    len(found_fields) *
                    "{} or ").format(
                    *
                    found_fields)[
                    0:-
                    4]
                raise AmbiguousFieldNameException(
                    '''\
                    {selected_name} field name is ambiguous.
                    It mathces to: {ambiguous_list}.
                    Don't know which one did you mean.
                    If ambiguity can't be solved provide full match case name.'''.format(
                        selected_name=i, ambiguous_list=ambiguous_list))
            elif not found_fields:
                raise FieldnameNotFoundException(
                    "Can't match fieldname '{}' to any column".format(i))
        else:
            raise MultipleOccurenceOfSelectedColumnException(
                "Selected column: {} provided several times. There must be only one occurence.".format(i))
    return filtered_names


def reorder_list_according_to_pattern(source, pattern):
    reordered_list = []
    for p in pattern:
        for s in source:
            if s.upper() in p.upper():
                reordered_list.append(s)
    return reordered_list


def match_columns_indexes_by_names(selected_fieldnames, reordered_fieldnames):
    matched_columns_names = match_column_names(
        selected_fieldnames, reordered_fieldnames)
    selected_columns = [reordered_fieldnames.index(
        i) for i in matched_columns_names]
    reordered_fieldnames = reorder_list_according_to_pattern(
        selected_fieldnames, matched_columns_names)
    return selected_columns, reordered_fieldnames


def make_condition_function(expression, fieldnames):
    print(expression)
    print(fieldnames)
    variables = _find_variables(expression, fieldnames)
    print(variables)
    function = 'lambda %s: %s' % (', '.join(variables), expression)
    print(function)
    print(eval(function))
    print(tuple(variables))
    try:
        return eval(function), tuple(variables)
    except BaseException:
        raise SyntaxError('''\
    Cannot eval to a lambda function
    Expression: {}
    Generated function: {}
    Found fields in expression: {}'''.format(expression, function, variables))


def _find_variables(expression, fieldnames):
    variables = []
    for fieldname in fieldnames:
        to_match = r'\b%s\b' % fieldname
        if re.search(to_match, expression):
            variables.append(fieldname)
    return sorted(variables)
