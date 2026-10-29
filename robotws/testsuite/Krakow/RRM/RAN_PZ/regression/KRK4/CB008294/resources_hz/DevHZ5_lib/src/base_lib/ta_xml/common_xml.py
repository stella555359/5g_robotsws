# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import copy
import re
import os
import six

try:
    from StringIO import StringIO, BytesIO
except Exception:
    from io import StringIO, BytesIO
from lxml import etree as ET


class CommonXML(object):
    """ basic xml operation
    """
    _whitespace = re.compile(r'\s+')
    _xml_declaration = re.compile(r'^<\?xml .*\?>\n')

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
        default_parser = ET.XMLParser(**_context)
        ET.set_default_parser(default_parser)
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
            if isinstance(string, (list)):
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

        ns = ET.FunctionNamespace(None)
        ns["matches"] = matches

    @property
    def tree_string(self):
        """ tree
        """
        _context = {"encoding": self.encoding,
                    "xml_declaration": self.xml_declaration,
                    "pretty_print": self.pretty_print,
                    "with_tail": self.with_tail}
        return ET.tostring(self.tree, **_context).decode('utf-8')

    def parse_xml(self, source_xml, keep_clark_notation=False):
        """ parse xml
        """
        if not source_xml:
            return
        self.tree = ET.parse(self._open_source_if_necessary(source_xml))
        self.root = self.tree.getroot()
        if not keep_clark_notation:
            self._strip_namespaces(self.root)
        return self.root

    def _open_source_if_necessary(self, source):
        """ open
        """
        if isinstance(
                source,
                six.string_types) and not source.lstrip().startswith('<'):
            if os.path.exists(source):
                return source.strip()  # open(source, 'rb')
            else:
                raise IOError(2, 'No such file', source)
        # source is string
        if isinstance(source, six.string_types) and source.lstrip().startswith('<'):
            return BytesIO(source.strip().encode(self.encoding))

    def _strip_namespaces(self, elem, current_ns=None):
        if not (hasattr(elem, 'tag') and isinstance(elem.tag, six.string_types)):
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

        element_string = ET.tostring(element, **kwargs)
        return self._xml_declaration.\
            sub('', element_string.decode(self.encoding)).strip()

    def string_to_element(self, element_string):
        """ str to ele
        """
        return ET.fromstring(element_string.encode('utf-8'))

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
