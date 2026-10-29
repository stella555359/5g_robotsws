#  Contanct : yonna.yao@nokia-sbell.com

import copy
import re
import os

try:
    from lxml import etree as lxml_etree
except ImportError:
    lxml_etree = None

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import (asserts, ET, ETSource, is_falsy, is_string, is_truthy,
                         plural_or_not as s)
from robot.version import get_version


should_be_equal = asserts.assert_equal
should_match = BuiltIn().should_match


class XML(object):

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = get_version()
    _xml_declaration = re.compile('^<\\?xml .*\\?>')

    def __init__(self, use_lxml=False):
        """Import library with optionally lxml mode enabled.

        By default this library uses Python's standard
        [http://docs.python.org/library/xml.etree.elementtree.html|ElementTree]
        module for parsing XML. If ``use_lxml`` argument is given a true value
        (see `Boolean arguments`), the library will use [http://lxml.de|lxml]
        module instead. See `Using lxml` section for benefits provided by lxml.

        Using lxml requires that the lxml module is installed on the system.
        If lxml mode is enabled but the module is not installed, this library
        will emit a warning and revert back to using the standard ElementTree.
        """
        use_lxml = is_truthy(use_lxml)
        if use_lxml and lxml_etree:
            self.etree = lxml_etree
            self.modern_etree = True
            self.lxml_etree = True
        else:
            self.etree = ET
            self.modern_etree = ET.VERSION >= '1.3'
            self.lxml_etree = False
        if use_lxml and not lxml_etree:
            logger.warn('XML library reverted to use standard ElementTree '
                        'because lxml module is not installed.')
        self._ns_stripper = NameSpaceStripper(self.etree, self.lxml_etree)

    def parse_xml(self, source, keep_clark_notation=False, strip_namespaces=False):
        with ETSource(source) as source:
            tree = self.etree.parse(source)
        if self.lxml_etree:
            strip = (lxml_etree.Comment, lxml_etree.ProcessingInstruction)
            lxml_etree.strip_elements(tree, *strip, **dict(with_tail=False))
        root = tree.getroot()
        if not is_truthy(keep_clark_notation):
            self._ns_stripper.strip(root, preserve=is_falsy(strip_namespaces))
        return root

    def get_element(self, source, xpath='.'):
        elements = self.get_elements(source, xpath)
        if len(elements) != 1:
            self._raise_wrong_number_of_matches(len(elements), xpath)
        return elements[0]

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

    def get_elements(self, source, xpath):
        if is_string(source):
            source = self.parse_xml(source)
        finder = ElementFinder(self.etree, self.modern_etree, self.lxml_etree)
        return finder.find_all(source, xpath)

    def get_child_elements(self, source, xpath='.'):
        return list(self.get_element(source, xpath))

    def get_element_count(self, source, xpath='.'):
        count = len(self.get_elements(source, xpath))
        logger.info("%d element%s matched '%s'." % (count, s(count), xpath))
        return count

    def element_should_exist(self, source, xpath='.', message=None):
        count = self.get_element_count(source, xpath)
        if not count:
            self._raise_wrong_number_of_matches(count, xpath, message)

    def element_should_not_exist(self, source, xpath='.', message=None):
        count = self.get_element_count(source, xpath)
        if count:
            self._raise_wrong_number_of_matches(count, xpath, message)

    def get_element_text(self, source, xpath='.', normalize_whitespace=False):
        element = self.get_element(source, xpath)
        text = ''.join(self._yield_texts(element))
        if is_truthy(normalize_whitespace):
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
        return ' '.join(text.split())

    def get_elements_texts(self, source, xpath, normalize_whitespace=False):
        return [self.get_element_text(elem, normalize_whitespace=normalize_whitespace)
                for elem in self.get_elements(source, xpath)]

    def element_text_should_be(self, source, expected, xpath='.',
                               normalize_whitespace=False, message=None):
        text = self.get_element_text(source, xpath, normalize_whitespace)
        should_be_equal(text, expected, message, values=False)

    def element_text_should_match(self, source, pattern, xpath='.',
                                  normalize_whitespace=False, message=None):
        text = self.get_element_text(source, xpath, normalize_whitespace)
        should_match(text, pattern, message, values=False)

    def get_element_attribute(self, source, name, xpath='.', default=None):
        return self.get_element(source, xpath).get(name, default)

    def get_element_attributes(self, source, xpath='.'):
        return dict(self.get_element(source, xpath).attrib)

    def element_attribute_should_be(self, source, name, expected, xpath='.',
                                    message=None):
        attr = self.get_element_attribute(source, name, xpath)
        should_be_equal(attr, expected, message, values=False)

    def element_attribute_should_match(self, source, name, pattern, xpath='.',
                                       message=None):
        attr = self.get_element_attribute(source, name, xpath)
        if attr is None:
            raise AssertionError("Attribute '%s' does not exist." % name)
        should_match(attr, pattern, message, values=False)

    def element_should_not_have_attribute(self, source, name, xpath='.', message=None):
        attr = self.get_element_attribute(source, name, xpath)
        if attr is not None:
            raise AssertionError(message or "Attribute '%s' exists and "
                                            "has value '%s'." % (name, attr))

    def elements_should_be_equal(self, source, expected, exclude_children=False,
                                 normalize_whitespace=False):
        self._compare_elements(source, expected, should_be_equal,
                               exclude_children, normalize_whitespace)

    def elements_should_match(self, source, expected, exclude_children=False,
                              normalize_whitespace=False):
        self._compare_elements(source, expected, should_match,
                               exclude_children, normalize_whitespace)

    def _compare_elements(self, source, expected, comparator, exclude_children,
                          normalize_whitespace):
        normalizer = self._normalize_whitespace \
            if is_truthy(normalize_whitespace) else None
        comparator = ElementComparator(comparator, normalizer, exclude_children)
        comparator.compare(self.get_element(source), self.get_element(expected))

    def set_element_tag(self, source, tag, xpath='.'):
        source = self.get_element(source)
        self.get_element(source, xpath).tag = tag
        return source

    def set_elements_tag(self, source, tag, xpath='.'):
        for elem in self.get_elements(source, xpath):
            self.set_element_tag(elem, tag)

    def set_element_text(self, source, text=None, tail=None, xpath='.'):
        source = self.get_element(source)
        element = self.get_element(source, xpath)
        if text is not None:
            element.text = text
        if tail is not None:
            element.tail = tail
        return source

    def set_elements_text(self, source, text=None, tail=None, xpath='.'):
        for elem in self.get_elements(source, xpath):
            self.set_element_text(elem, text, tail)

    def set_element_attribute(self, source, name, value, xpath='.'):
        if not name:
            raise RuntimeError('Attribute name can not be empty.')
        source = self.get_element(source)
        self.get_element(source, xpath).attrib[name] = value
        return source

    def set_elements_attribute(self, source, name, value, xpath='.'):
        for elem in self.get_elements(source, xpath):
            self.set_element_attribute(elem, name, value)

    def remove_element_attribute(self, source, name, xpath='.'):
        source = self.get_element(source)
        attrib = self.get_element(source, xpath).attrib
        if name in attrib:
            attrib.pop(name)
        return source

    def remove_elements_attribute(self, source, name, xpath='.'):
        for elem in self.get_elements(source, xpath):
            self.remove_element_attribute(elem, name)

    def remove_element_attributes(self, source, xpath='.'):
        source = self.get_element(source)
        self.get_element(source, xpath).attrib.clear()
        return source

    def remove_elements_attributes(self, source, xpath='.'):
        for elem in self.get_elements(source, xpath):
            self.remove_element_attributes(elem)

    def add_element(self, source, element, index=None, xpath='.'):
        source = self.get_element(source)
        parent = self.get_element(source, xpath)
        element = self.copy_element(element)
        if index is None:
            parent.append(element)
        else:
            parent.insert(int(index), element)
        return source

    def remove_element(self, source, xpath='', remove_tail=False):
        source = self.get_element(source)
        self._remove_element(source, self.get_element(source, xpath), remove_tail)
        return source

    def remove_elements(self, source, xpath='', remove_tail=False):
        source = self.get_element(source)
        for element in self.get_elements(source, xpath):
            self._remove_element(source, element, remove_tail)
        return source

    def _remove_element(self, root, element, remove_tail=False):
        parent = self._find_parent(root, element)
        if not is_truthy(remove_tail):
            self._preserve_tail(element, parent)
        parent.remove(element)

    def _find_parent(self, root, element):
        for parent in root.iter():
            for child in parent:
                if child is element:
                    return parent
        raise RuntimeError('Cannot remove root element.')

    def _preserve_tail(self, element, parent):
        if not element.tail:
            return
        index = list(parent).index(element)
        if index == 0:
            parent.text = (parent.text or '') + element.tail
        else:
            sibling = parent[index-1]
            sibling.tail = (sibling.tail or '') + element.tail

    def clear_element(self, source, xpath='.', clear_tail=False):
        source = self.get_element(source)
        element = self.get_element(source, xpath)
        tail = element.tail
        element.clear()
        if not is_truthy(clear_tail):
            element.tail = tail
        return source

    def copy_element(self, source, xpath='.'):
        return copy.deepcopy(self.get_element(source, xpath))

    def element_to_string(self, source, xpath='.', encoding=None):
        source = self.get_element(source, xpath)
        string = self.etree.tostring(source, encoding='UTF-8').decode('UTF-8')
        string = self._xml_declaration.sub('', string).strip()
        if encoding:
            string = string.encode(encoding)
        return string

    def log_element(self, source, level='INFO', xpath='.'):
        string = self.element_to_string(source, xpath)
        logger.write(string, level)
        return string

    def save_xml(self, source, path, encoding='UTF-8'):
        path = os.path.abspath(path.replace('/', os.sep))
        elem = self.get_element(source)
        tree = self.etree.ElementTree(elem)
        config = {'encoding': encoding}
        if self.modern_etree:
            config['xml_declaration'] = True
        if self.lxml_etree:
            elem = self._ns_stripper.unstrip(elem)
            # https://bugs.launchpad.net/lxml/+bug/1660433
            if tree.docinfo.doctype:
                config['doctype'] = tree.docinfo.doctype
            tree = self.etree.ElementTree(elem)
        with open(path, 'wb') as output:
            if 'doctype' in config:
                output.write(self.etree.tostring(tree, **config))
            else:
                tree.write(output, **config)
        logger.info('XML saved to <a href="file://%s">%s</a>.' % (path, path),
                    html=True)

    def evaluate_xpath(self, source, expression, context='.'):
        if not self.lxml_etree:
            raise RuntimeError("'Evaluate Xpath' keyword only works in lxml mode.")
        return self.get_element(source, context).xpath(expression)


class NameSpaceStripper(object):

    def __init__(self, etree, lxml_etree=False):
        self.etree = etree
        self.lxml_tree = lxml_etree

    def strip(self, elem, preserve=True, current_ns=None, top=True):
        if elem.tag.startswith('{') and '}' in elem.tag:
            ns, elem.tag = elem.tag[1:].split('}', 1)
            if preserve and ns != current_ns:
                elem.attrib['xmlns'] = ns
                current_ns = ns
        elif current_ns:
            elem.attrib['xmlns'] = ''
            current_ns = None
        for child in elem:
            self.strip(child, preserve, current_ns, top=False)
        if top and not preserve and self.lxml_tree:
            self.etree.cleanup_namespaces(elem)

    def unstrip(self, elem, current_ns=None, copied=False):
        if not copied:
            elem = copy.deepcopy(elem)
        ns = elem.attrib.pop('xmlns', current_ns)
        if ns:
            elem.tag = '{%s}%s' % (ns, elem.tag)
        for child in elem:
            self.unstrip(child, ns, copied=True)
        return elem


class ElementFinder(object):

    def __init__(self, etree, modern=True, lxml=False):
        self.etree = etree
        self.modern = modern
        self.lxml = lxml

    def find_all(self, elem, xpath):
        xpath = self._get_xpath(xpath)
        if xpath == '.':  # ET < 1.3 does not support '.' alone.
            return [elem]
        if not self.lxml:
            return elem.findall(xpath)
        finder = self.etree.ETXPath(xpath)
        return finder(elem)

    def _get_xpath(self, xpath):
        if not xpath:
            raise RuntimeError('No xpath given.')
        if self.modern:
            return xpath
        try:
            return str(xpath)
        except UnicodeError:
            if not xpath.replace('/', '').isalnum():
                logger.warn('XPATHs containing non-ASCII characters and '
                            'other than tag names do not always work with '
                            'Python versions prior to 2.7. Verify results '
                            'manually and consider upgrading to 2.7.')
            return xpath


class ElementComparator(object):

    def __init__(self, comparator, normalizer=None, exclude_children=False):
        self._comparator = comparator
        self._normalizer = normalizer or (lambda text: text)
        self._exclude_children = is_truthy(exclude_children)

    def compare(self, actual, expected, location=None):
        if not location:
            location = Location(actual.tag)
        self._compare_tags(actual, expected, location)
        self._compare_attributes(actual, expected, location)
        self._compare_texts(actual, expected, location)
        if location.is_not_root:
            self._compare_tails(actual, expected, location)
        if not self._exclude_children:
            self._compare_children(actual, expected, location)

    def _compare_tags(self, actual, expected, location):
        self._compare(actual.tag, expected.tag, 'Different tag name', location,
                      should_be_equal)

    def _compare(self, actual, expected, message, location, comparator=None):
        if location.is_not_root:
            message = "%s at '%s'" % (message, location.path)
        if not comparator:
            comparator = self._comparator
        comparator(actual, expected, message)

    def _compare_attributes(self, actual, expected, location):
        self._compare(sorted(actual.attrib), sorted(expected.attrib),
                      'Different attribute names', location, should_be_equal)
        for key in actual.attrib:
            self._compare(actual.attrib[key], expected.attrib[key],
                          "Different value for attribute '%s'" % key, location)

    def _compare_texts(self, actual, expected, location):
        self._compare(self._text(actual.text), self._text(expected.text),
                      'Different text', location)

    def _text(self, text):
        return self._normalizer(text or '')

    def _compare_tails(self, actual, expected, location):
        self._compare(self._text(actual.tail), self._text(expected.tail),
                      'Different tail text', location)

    def _compare_children(self, actual, expected, location):
        self._compare(len(actual), len(expected), 'Different number of child elements',
                      location, should_be_equal)
        for act, exp in zip(actual, expected):
            self.compare(act, exp, location.child(act.tag))


class Location(object):

    def __init__(self, path, is_root=True):
        self.path = path
        self.is_not_root = not is_root
        self._children = {}

    def child(self, tag):
        if tag not in self._children:
            self._children[tag] = 1
        else:
            self._children[tag] += 1
            tag += '[%d]' % self._children[tag]
        return Location('%s/%s' % (self.path, tag), is_root=False)


xml_obj = XML()


def parse_xml(source, keep_clark_notation=False, strip_namespaces=False):
    return xml_obj.parse_xml(source, keep_clark_notation, strip_namespaces)


def get_element(source, xpath='.'):
    return xml_obj.get_element(source, xpath)


def get_elements(source, xpath):
    return xml_obj.get_elements(source, xpath)


def set_element_text(source, text=None, tail=None, xpath='.'):
    return xml_obj.set_element_text(source, text, tail, xpath)


def add_element(source, element, index=None, xpath='.'):
    return xml_obj.add_element(source, element, index, xpath)


def element_should_exist(source, xpath='.', message=None):
    xml_obj.element_should_exist(source, xpath, message)


def element_should_not_exist(source, xpath='.', message=None):
    xml_obj.element_should_not_exist(source, xpath, message)


def remove_element(source, xpath='', remove_tail=False):
    return xml_obj.remove_element(source, xpath, remove_tail)


def save_xml(source, path, encoding='UTF-8'):
    xml_obj.save_xml(source, path, encoding)
