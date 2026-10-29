#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: NOKIA
:author: Cezary Miącz
:contact: cezary.miacz@nokia.com
:edit: Krystian Gordziejewski
:contact: krystian.gordziejewski@nokia.com
"""

import os
import json

from lxml import etree


class ExtendedDict(dict):

    def __init__(self, *args, **kwargs):
        super(ExtendedDict, self).__init__(*args, **kwargs)

    def __getattr__(self, attr):
        return self.get(attr)

    def __setattr__(self, attr, value):
        if value is not None:
            self[attr] = value


class Parameter(ExtendedDict):

    def __init__(self, element):
        super(Parameter, self).__init__()
        self.parameterName = element.attrib.get('name')
        self.operation = element.attrib.get('operation') or 'update'


class SimpleParameter(Parameter):

    def __init__(self, element):
        super(SimpleParameter, self).__init__(element)
        self.value = element.text
        if self.value is None:
            self.operation = 'delete'


class ListParameter(Parameter):

    def __init__(self, element):
        super(ListParameter, self).__init__(element)
        simple_items = [item_elem.text for item_elem in element.iterfind('{*}p')]
        complex_items = [item for item in self._generate_complex_items(element)]
        if len(simple_items) > 0 or len(complex_items) > 0:
            self.value = simple_items + complex_items
        else:
            self.operation = 'delete'

    def _generate_complex_items(self, element):
        for item_elem in element.iterfind('{*}item'):
            yield {p.attrib.get("name"): p.text for p in item_elem.iterfind('{*}p')}


class ManagedObject(ExtendedDict):

    def __init__(self, element):
        super(ManagedObject, self).__init__()
        self.distName = element.attrib.get('distName')
        self.operation = element.attrib.get('operation') or 'update'

        simple_parameters = [SimpleParameter(p_elem) for p_elem in element.iterfind('{*}p')]
        list_parameters = [ListParameter(list_elem) for list_elem in element.iterfind('{*}list')]
        self.parameters = simple_parameters + list_parameters


def _get_default_output_file(input_file):
    input_dir, input_file_name = os.path.split(input_file)
    name, ext = os.path.splitext(input_file_name)
    return os.path.join(input_dir, '{}.json'.format(name))


def convert_delta_xml_to_json(input_file, output_file=None):
    doc_root = etree.parse(input_file)
    managed_objects = [ManagedObject(elem) for elem in doc_root.iter('{*}managedObject')]
    output_file = output_file or _get_default_output_file(input_file)
    json_output = json.dumps(managed_objects, sort_keys=True, indent=4, separators=(',', ': '))
    return json_output
