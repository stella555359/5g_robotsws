# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: amaand li
:contact: amaand.li@nokia.com
"""
import copy
import re
import os

from io import BytesIO
from lxml import etree as et


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
    if isinstance(value, (str, int, float)):
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


class OperateXml(object):

    def read_xml(self, source_xml, read_parameters, **context):
        """This keyword return string or list or dictionary base on given condition.

        :param source_xml source: xml file or xml format string
        :param read_parameters: string or list contain specified format
        :returns  string or list or dictionary

        | <managedObject class="LNREL" distName="MRBTS-13/LNBTS-13/LCELL-1" version="LNT2.0">\n
        |    <p name="RxGain">0</p>\n
        |    <p name="antId">ANT1</p>       \n
        | </managedObject>

        | 1 | Basic | infomation about XML structure: | ==> | attribute_value | LNREL | LNT2.0  | antId |
        |    | a | What's attribute? | ==> | attribute_name | class | version | name  |
        |    | b | What's tag or nodename? | ==> | tag or nodename | manageObject | p |
        |    | c | What's text? | ==> | text | ANT1 |

        | Detail for argument2 read_parameters, format as 'xml_component|xpath':
        |    | 1 | xml_component | 'text', 'attrib', 'tail', 'tag', '*'. |
        |    |   | 1) | attrib | return a dictionary for attribute's key and value. |
        |    |   | 2) | attrib=attrib_name | return string of attrib value. |
        |    |   | 3) | text | return string for element's text.  |
        |    |   | 4) | * | return string for whole element.  |
        |    | 2 |  xpath | way to find the unique target node/element. |
        |    |   | 1) | //managedObject  | by tag or nodename |
        |    |   | 2) | //*[@name='antId'] | by attribute |
        |    |   | 2) | //*[text()='ANT1'] | by text |
        |    |   | 3) | //*[contains(@distName, 'LCELL-1')] | by attr value contatin str |
        |    |   | 4) | //*[matches(@distName, '.r"*LCELL-\\d}"] | by attr value match str  |
        |    |   | 5) | //*[@name='antId' and text()='ANT1'] | by multi condition |
        |    |   | 6) | //*[@name='antId']/../*[@name='RxGain'] | by multi condition |
        """
        read_parameters = to_list(read_parameters)
        commonxml = CommonXML(source_xml)
        result = []

        for parameter in read_parameters:
            parameter = str(parameter)
            error_msg = "parameter need read should given like:" + \
                        " 'xml_component|xpath', your input '%s'" % parameter
            assert parameter.count("|") >= 1, error_msg
            element_component, xpath = parameter.split("|", 1)
            element = commonxml.get_element(xpath, **context)
            if element_component.upper().strip() == "TEXT":
                result.append(commonxml.get_element_text(element))
            elif element_component.upper().strip() == "TAG":
                result.append(commonxml.get_element_tag(element))
            elif element_component.upper().strip() == "*":
                result.append(commonxml.element_to_string(element))
            elif element_component.upper().strip().startswith("ATTRIB"):
                if element_component.upper().strip() == "ATTRIB":
                    result.append(
                        commonxml.get_element_all_attributes(element))
                else:
                    _, attrib_name = element_component.split("=")
                    result.append(commonxml.get_element_attribute(element,
                                                                  attrib_name))
            else:
                result.append(getattr(element, element_component))
        return result[0] if len(result) == 1 else result

    def _sub(self, orignal_string, pattern, replace_str):
        'sub function'
        return re.sub(pattern, replace_str, orignal_string)

    def _replace(self, orignal_string, old_str, replace_str):
        'replace function'
        return orignal_string.replace(old_str, replace_str)

    def _handle_ele(self, elements, element_component,
                    _pattern_result, commonxml, parameter_value):
        internal_func = {'replace': self._replace,
                         'sub': self._sub
                         }
        _func = None
        if _pattern_result:
            _func = internal_func[_pattern_result.group("func_name")]
        for element in elements:
            if element_component.upper().strip() == "TEXT":
                if _pattern_result:
                    parameter_value = _func(
                        commonxml.get_element_text(element),
                        _pattern_result.group("old"),
                        _pattern_result.group("new"))
                commonxml.set_element_text(element, parameter_value)
            elif element_component.upper().strip().startswith("ATTRIB"):
                _, attrib_name = element_component.split("=", 1)
                attrib_value = parameter_value
                if _pattern_result:
                    old_attrib_value = commonxml.get_element_attribute(
                        element, attrib_name)
                    attrib_value = _func(old_attrib_value,
                                         _pattern_result.group("old"),
                                         _pattern_result.group("new"))
                commonxml.set_element_attribute(element, attrib_name,
                                                attrib_value)
            elif element_component.upper().strip() == "TAG":
                if _pattern_result:
                    parameter_value = _func(commonxml.get_element_tag(element),
                                            _pattern_result.group("old"),
                                            _pattern_result.group("new"))
                commonxml.set_element_tag(element, parameter_value)
            elif element_component.upper().strip() == "*":
                _element_parent = commonxml.get_parent_element(element)
                commonxml.remove_element(element)
                if _pattern_result:
                    parameter_value = _func(
                        commonxml.element_to_string(element),
                        _pattern_result.group("old"),
                        _pattern_result.group("new"))
                commonxml.add_element(_element_parent, parameter_value)
            else:
                setattr(element, element_component, parameter_value)

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
        \\s{0,2}\\'(?P<old>.*?)\\'\\s{0,2},
        \\s{0,2}\\'(?P<new>.*?)\'\\s{0,2}
        (,\\s{0,2}\'(?P<parameter_3>.*?)\'\\s{0,2})?
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
                # log("start to modify %s" % xpath)
                print("start to modify %s" % xpath)
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

    def add_xml_element(self, source_xml, target_xml, add_parameters):
        """This keyword add content to xml with given conditon.

        :param source_xml: source xml file or xml format string
        :param target_xml: target xml file will save to, if False value given will return the modified string
        :param add_parameters: parameters you want add
        :Return the target xml file path or modified xml string

        |<managedObject class="LNREL" distName="MRBTS-13/LNBTS-13/LCELL-1" version="LNT2.0">\n
        |    <p name="RxGain">0</p>\n
        |    <p name="antId">ANT1</p>       \n
        |</managedObject>

        | 1 | Basic | infomation about XML structure: | ==> | attribute_value | LNREL | LNT2.0  | antId |
        |    | a | What's attribute? | ==> | attribute_name | class | version | name  |
        |    | b | What's tag or nodename? | ==> | tag or nodename | manageObject | p |
        |    | c | What's text? | ==> | text | ANT1 |

        | Detail for argumente add_parameters, format as 'add_content|xpath':
        | 1 | add_content |  |
        |   | 1) | <a>added</a> | add content, should match xml format. |
        | 2 |  xpath | way to find the unique target parent node/element. |
        |   | 1) | //managedObject  | by tag or nodename |
        |   | 2) | //*[@name='antId'] | by attribute |
        |   | 2) | //*[text()='ANT1'] | by text |
        |   | 3) | //*[contains(@distName, 'LCELL-1')] | by attr value contatin str |
        |   | 4) | //*[matches(@distName, '.*LCELL-\\d}'] | by attr value match str  |
        |   | 5) | //*[@name='antId' and text()='ANT1'] | by multi condition |
        |   | 6) | //*[@name='antId']/../*[@name='RxGain'] | by multi condition |
        """
        add_parameters = to_list(add_parameters)

        commonxml = CommonXML(source_xml)
        for parameter in add_parameters:
            parameter = str(parameter)
            error_msg = "parameter need add should given like:" + \
                        " 'element_string|xpath', your input '%s'" % parameter
            assert parameter.count("|") >= 1, error_msg
            element_string, xpath = parameter.split("|", 1)
            commonxml.add_element(xpath,
                                  CommonXML().string_to_element(element_string))
        if not target_xml:
            return commonxml.tree_string
        else:
            commonxml.save_xml(target_xml)
            return target_xml

    def remove_xml_element(self, source_xml, target_xml, xpaths):
        """This keyword remove element from xml with given xpath.
        :param source_xml: source xml file or xml format string
        :param target_xml: target xml file will save to, if False value given will return the modified string
        :param xpaths: string or list xpath
        "Return: the target xml file path or modified xml string

        |<managedObject class="LNREL" distName="MRBTS-13/LNBTS-13/LCELL-1" version="LNT2.0">\n
        |    <p name="RxGain">0</p>\n
        |    <p name="antId">ANT1</p>       \n
        |</managedObject>

        | 1 | Basic | infomation about XML structure: | ==> | attribute_value | LNREL | LNT2.0  | antId |
        |    | a | What's attribute? | ==> | attribute_name | class | version | name  |
        |    | b | What's tag or nodename? | ==> | tag or nodename | manageObject | p |
        |    | c | What's text? | ==> | text | ANT1 |

        | Detail for argumente xpaths:
        | 1 |  xpath | way to find the unique target node/element. |
        |   | 1) | //managedObject  | by tag or nodename |
        |   | 2) | //*[@name='antId'] | by attribute |
        |   | 2) | //*[text()='ANT1'] | by text |
        |   | 3) | //*[contains(@distName, 'LCELL-1')] | by attr value contatin str |
        |   | 4) | //*[matches(@distName, '.*LCELL-\\d}'] | by attr value match str  |
        |   | 5) | //*[@name='antId' and text()='ANT1'] | by multi condition |
        |   | 6) | //*[@name='antId']/../*[@name='RxGain'] | by multi condition |

        | Example:
        | ${xpath_1} | set variable | //*[@distName\\='MRBTS-21/ANTL-1'] |
        | ${xpath_2} | set variable | //*[@name\\='unitList'] |
        | remove_xml_element | SCFC_1.xml | SCFC_1_removed.xml | ${xpath_1} |
        | ${remove_parameters} | create list |  ${xpath_1} | ${xpath_2} |
        | remove_xml_element | SCFC_1.xml | SCFC_1_removed.xml | ${remove_parameters} |
        """
        xpaths = to_list(xpaths)

        commonxml = CommonXML(source_xml)
        for xpath in xpaths:
            commonxml.remove_elements(xpath)
        if target_xml is None:
            return commonxml.tree_string
        else:
            commonxml.save_xml(target_xml)
            return target_xml

    def evaluate_xml_xpath(self, source_xml, xpath, **context):
        """evaluate xpath with given source xml.

        :param source_xml: source xml file or xml format string
        :param xpath: xpath expression
        :Return: the xpath evaluate result

        The xpath expression to evaluate is given as `expression` argument.
        The result of the evaluation is returned as-is.

        | Example:
        | ${count} =      | evaluate_xml_xpath | ${XML}  | count(third/*) |
        | Should Be Equal | ${count}       | ${3}    |
        | ${text} =       | evaluate_xml_xpath | ${XML}  | string(descendant::second[last()]/@id) |
        | Should Be Equal | ${text}        | child   |
        | ${bold} =  | evaluate_xml_xpath | ${XML}  | boolean(preceding-sibling::*[1] \\= 'bold') | context\\=html/p/i |
        | Should Be Equal | ${bold}        | ${True} |
        """

        commonxml = CommonXML(source_xml)
        return commonxml.evaluate_xpath(source_xml, xpath, **context)


class CommonXML(object):
    """ basic xml operation
    """
    _whitespace = re.compile('\\s+')
    _xml_declaration = re.compile('^<\\?xml .*\\?>\n')

    def __init__(self, source_xml=None, **context):
        self.tree = None
        self.root = None

        self.pretty_print = True
        self.with_tail = True
        self.encoding = "UTF-8"
        self.xml_declaration = True

        _context = {  # "encoding" : context.get("encoding", self.encoding),
            "remove_blank_text": context.get("remove_blank_text", True),
            "remove_comments": context.get("remove_comments", False),
            "recover": context.get("recover", True),
            "ns_clean": context.get("ns_clean", False),
        }
        default_parser = et.XMLParser(**_context)
        et.set_default_parser(default_parser)
        self.__register_fn_matchs_in_xpath()
        self.parse_xml(
            source_xml,
            keep_clark_notation=context.get(
                "keep_clark_notation",
                False))

    def __register_fn_matchs_in_xpath(self):
        def matches(context, string, pattern):
            """ for extra function
            """
            if isinstance(string, list):
                if len(string) == 1:
                    string = string[0]
            pattern = str(pattern)
            string = str(string)
            regexp = re.match(pattern, string)
            if regexp:
                result = True
            else:
                result = False
            return result

        ns = et.FunctionNamespace(None)
        ns["matches"] = matches

    @property
    def tree_string(self):
        """ tree
        """
        _context = {"encoding": self.encoding,
                    "xml_declaration": self.xml_declaration,
                    "pretty_print": self.pretty_print,
                    "with_tail": self.with_tail}
        return et.tostring(self.tree, **_context).decode('utf-8')

    def parse_xml(self, source_xml, keep_clark_notation=False):
        """ parse xml
        """
        if not source_xml:
            return
        self.tree = et.parse(self._open_source_if_necessary(source_xml))
        self.root = self.tree.getroot()
        if not keep_clark_notation:
            self._strip_namespaces(self.root)
        return self.root

    def _open_source_if_necessary(self, source):
        """ open
        """
        if isinstance(
                source,
                str) and not source.lstrip().startswith('<'):
            if os.path.exists(source):
                return source.strip()  # open(source, 'rb')
            else:
                raise IOError(2, 'No such file', source)
        # source is string
        if isinstance(source, str) and source.lstrip().startswith('<'):
            return BytesIO(source.strip().encode(self.encoding))

    def _strip_namespaces(self, elem, current_ns=None):
        if not (hasattr(elem, 'tag') and isinstance(elem.tag, str)):
            return
        if elem.tag.startswith('{') and '}' in elem.tag:
            ns, elem.tag = elem.tag[1:].split('}', 1)
            if ns != current_ns:
                current_ns = ns
        for child in elem:
            self._strip_namespaces(child, current_ns)

    def get_element(self, xpath, **context):
        """ get element
        """
        elements = self.get_elements(xpath, **context)
        if len(elements) != 1:
            self._raise_wrong_number_of_matches(len(elements), xpath)
        return elements[0]

    def get_elements(self, xpath, **context):
        """ get elements
        """
        if not xpath:
            raise RuntimeError('No xpath given.')
        if xpath == '.':
            return [self.root]
        xpath = str(xpath)

        _variables = context.copy()
        allow_empty = _variables.get("allow_empty", True)
        for varname in ["namespaces", "extensions",
                        "smart_strings", "allow_empty"]:
            if varname in _variables:
                _variables.pop(varname)

        result = self.tree.xpath(xpath, namespaces=context.get("namespaces", None),
                                 extensions=context.get("extensions", None),
                                 smart_strings=context.get(
                                     "smart_strings", True),
                                 **_variables)
        if not allow_empty and not result:
            self._raise_wrong_number_of_matches(len(result), xpath)
        return result

    def _raise_wrong_number_of_matches(self, count, xpath, message=None):
        if not message:
            message = self._wrong_number_of_matches(count, xpath)
        raise AssertionError(message)

    def _wrong_number_of_matches(self, count, xpath):
        if not count:
            return "No element matching '%s' found." % xpath
        if count == 1:
            return "One element matching '%s' found." % xpath
        return "Multiple elements (%d) matching '%s' found." % (count, xpath)

    def get_child_elements(self, element):
        """ get child
        """
        return list(element)

    def get_element_text(self, element, descendants_text=False,
                         normalize_whitespace=False):
        """ get text
        """
        if descendants_text:
            text = ''.join(self._yield_texts(element))
        else:
            text = element.text
        if normalize_whitespace:
            text = self._normalize_whitespace(text)
        return text

    def _yield_texts(self, element, top=True):
        if element.text:
            yield element.text
        for child in element:
            for text in self._yield_texts(child, top=False):
                yield text
        if element.tail and not top:
            yield element.tail

    def _normalize_whitespace(self, text):
        return self._whitespace.sub(' ', text.strip())

    def get_element_attribute(self, element, attrib_name, default=None):
        """get attribute
        """
        return element.get(attrib_name, default)

    def get_element_all_attributes(self, element):
        """ get attributes
        """
        return copy.copy(element.attrib)

    def set_element_tag(self, element, tag):
        """ set tag
        """
        old_element_tag = element.tag
        element.tag = tag
        return old_element_tag

    def get_element_tag(self, element):
        """get tag
        """
        return element.tag

    def set_element_text(self, element, text=None, tail=None):
        """ set text
        """
        old_element_text = element.text
        if text is not None:
            element.text = text
        if tail is not None:
            element.tail = tail
        return old_element_text

    def set_element_attribute(self, element, attrib_name, attrib_value):
        """ set attribute
        """
        if not attrib_name:
            raise RuntimeError('Attribute name can not be empty.')
        element.attrib[attrib_name] = attrib_value
        return element

    def remove_element_attribute(self, element, *attrib_names):
        """ remove attribute
        """
        attrib = element.attrib
        for attrib_name in attrib_names:
            if attrib_name in attrib:
                attrib.pop(attrib_name)
        return element

    def remove_element_attributes(self, element):
        """ remove element
        """
        element.attrib.clear()
        return element

    def add_element(self, xpath, element, index=None):
        """ add element
        """
        parent_elements = self.get_elements(xpath)
        for parent_element in parent_elements:
            element = self.copy_element(element)
            if index is None:
                parent_element.append(element)
            else:
                parent_element.insert(int(index), element)
        return parent_elements

    def remove_elements(self, xpath='', remove_tail=False):
        """ remove elements
        """
        for element in self.get_elements(xpath):
            self._remove_element(element, remove_tail)

    def remove_element(self, element, remove_tail=False):
        """ remove elment
        """
        self._remove_element(element, remove_tail)

    def _remove_element(self, element, remove_tail=False):
        parent = self.get_parent_element(element)
        if element.tail and not remove_tail:
            self._preserve_tail(element, parent)
        parent.remove(element)

    def get_parent_element(self, element):
        """ get parent ele
        """
        for parent in self.root.getiterator():
            for child in parent:
                if child is element:
                    return parent
        raise RuntimeError('Cannot remove root element.')

    def _preserve_tail(self, element, parent):
        index = list(parent).index(element)
        if index == 0:
            parent.text = (parent.text or '') + element.tail
        else:
            sibling = parent[index - 1]
            sibling.tail = (sibling.tail or '') + element.tail

    def copy_element(self, element):
        """ copy ele
        """
        return copy.deepcopy(element)

    def element_to_string(self, element, **context):
        """ ele to str
        """
        #  TODO remove the xmlns attribute added to element
        kwargs = {"encoding": context.get("encoding", self.encoding),
                  "xml_declaration": context.get("xml_declaration",
                                                 self.xml_declaration),
                  "pretty_print": context.get("pretty_print",
                                              self.pretty_print),
                  "with_tail": context.get("with_tail", self.with_tail)}

        element_string = et.tostring(element, **kwargs)
        return self._xml_declaration. \
            sub('', element_string.decode(self.encoding)).strip()

    def string_to_element(self, element_string):
        """ str to ele
        """
        return et.fromstring(element_string.encode('utf-8'))

    def save_xml(self, file_path, source=None, **context):
        """ save xml
        """
        _context = {"encoding": context.get("encoding", self.encoding),
                    "xml_declaration": context.get("xml_declaration",
                                                   self.xml_declaration),
                    "pretty_print": context.get("pretty_print",
                                                self.pretty_print),
                    "with_tail": context.get("with_tail", self.with_tail)}
        if source:
            self.parse_xml(source)
        source = self.tree
        with open(file_path, 'wb') as output:
            source.write(output, **_context)

    def evaluate_xpath(self, source, expression, **context):
        """ evaluate xpath
        """
        return self.get_element(xpath=".", **context).xpath(expression)
