# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
"""
import re
import six
import string
from .common_xml import CommonXML


def log(msg):
    'doc'
    from robot.libraries.BuiltIn import BuiltIn
    BuiltIn().log(msg)


def to_list(value, expected_type=None, skip_none=False):
    """Method to made conversion to integer.

    @param value: Some value to convert.
    @param expected_type: types every value need to convert.
    @param boolean skip_none: Skip conversion if value is None.

    @return: Converted value.
    @rtype: list.
    """
    if value is None and skip_none is True:
        return value
    if not callable(expected_type) and expected_type is not None:
        expected_type = eval(expected_type)
    result_list = []
    if isinstance(value, (six.string_types, int, float)):
        if expected_type is None:
            result_list.append(value)
        else:
            result_list.append(expected_type(value))
        return result_list

    for index, item in enumerate(value):
        if expected_type is None:
            result_list.append(item)
        else:
            try:
                result_list.append(expected_type(item))
            except ValueError:
                raise ValueError('Value (%s) with index (%d) cannot be \
converted to (%s)' % (str(item), index, expected_type.__name__))
    return result_list


def modify_xml(self, source_xml, target_xml, modify_parameters, **context):
    """This keyword could modify xml with given condition
    :param source_xml: source file  path or xml format string
    :param target_xml: target xml file path, if default return modified string
    :param modify_parameters: parameters need to modify
    :Returns target xml file path or modified xml string

    |<managedObject class="LNREL" distName="MRBTS-13/LNBTS-13/LCELL-1" version="LNT2.0">\n
    |    <p name="RxGain">0</p>\n
    |    <p name="antId">ANT1</p>       \n
    |</managedObject>
    | 1 | Basic | infomation about XML structure: | ==> | attribute_value | LNREL | LNT2.0  | antId |
    |    | a | What's attribute? | ==> | attribute_name | class | version | name  |
    |    | b | What's tag or nodename? | ==> | tag or nodename | manageObject | p |
    |    | c | What's text? | ==> | text | ANT1 |
    | Detail for argumente modify_parameters, format as 'xml_component|newvalue|xpath':
    | 1 | xml_component | 'text', 'attrib', 'tail', 'tag', '*'. |
    |   | 1) | attrib | return a dictionary for attribute's key and value. |
    |   | 2) | attrib=attrib_name | return string of attrib value. |
    |   | 3) | text | return string for element's text.  |
    |   | 4) | * | return string for whole element.  |
    | 2 | newvalue |  |
    |   | 1) | new value | whole string replace |
    |   | 2) | replace('old', 'new') | replace part string. such as "old_value" -> "new_value" |
    |   | 3) | sub('pattern', 'new') | replace part string with pattern  |
    | 3 |  xpath | way to find the unique target node/element. |
    |   | 1) | //managedObject  | by tag or nodename |
    |   | 2) | //*[@name\\='antId'] | by attribute |
    |   | 2) | //*[text()\\='ANT1'] | by text |
    |   | 3) | //*[contains(@distName, 'LCELL-1')] | by attr value contatin str |
    |   | 4) | //*[matches(@distName, '.*LCELL-\\d}'] | by attr value match str  |
    |   | 5) | //*[@name\\='antId' and text()\\='ANT1'] | by multi condition |
    |   | 6) | //*[@name\\='antId']/../*[@name\\='RxGain'] | by multi condition |
    |   | 7) | //list[@name\\='ulMuMimoMCSOffset']/p[2] | by position |
    """
    modify_parameters = to_list(modify_parameters)
    commonxml = CommonXML(source_xml)
    internal_func_pattern = re.compile(""".*?(?P<func_name>replace|sub)\\(
    \\s{0,2}\'(?P<old>.*?)\'\\s{0,2}\\,
    \\s{0,2}\'(?P<new>.*?)\'\\s{0,2}
    (\\,\\s{0,2}\'(?P<parameter_3>.*?)\'\\s{0,2})?
    \\)$""", re.I | re.M | re.X)
    for parameter in modify_parameters:
        parameter = str(parameter)
        if parameter == '':
            continue
        error_msg = "parameter need modify should given like:" + \
            " 'xml_component|value|xpath', your input '%s'" % parameter
        assert parameter.count("|") >= 2, error_msg
        element_component, parameter_value, xpath = parameter.split("|", 2)
        _pattern_result = internal_func_pattern.search(parameter_value)

        elements = commonxml.get_elements(xpath, **context)
        if not elements:
            raise Exception("the xpath you given '%s' can not find any xml element" % xpath)
        else:
            log("start to modify %s" % xpath)
        self._handle_ele(
            elements,
            element_component,
            _pattern_result,
            commonxml,
            parameter_value)
    if not target_xml:
        return commonxml.tree_string
    else:
        commonxml.save_xml(target_xml)
        return target_xml
