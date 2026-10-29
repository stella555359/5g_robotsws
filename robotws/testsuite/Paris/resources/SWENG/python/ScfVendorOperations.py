import sys
import traceback
import re
import os
import json
import XMLConverter_wrapper
from StringTool import *


class ScfVendorOperations(object):
    """
    == Purpose ==
    Library to manipulate XML file as format of SCF or VENDOR files used in gNB configuration.

    == Description ==
        The keyword 'ScfVendorOperations.setup reader' allows to load a VENDOR file used in gNB configuraiton.
        After
        The keyword 'ScfVendorOperations.setup reader' allows to load the VENDOR file used for gNB configuration.
         Then it is possible to view the content and modify it as well.
         In the case of modifications to the VENDOR file, do not forget to save it using
         the keyword 'ScfVendorOperations.save_back_toxml'.

       *Example:*
       | ### Settings ###
       | Library        ../../python/ScfVendorOperations.py
       |
       | ### Test Cases ###
       | My test
       |     ScfVendorOperations.setup reader
       |     ...               vendor_1AE512BF_ori.xml
       |     ${mo_dict}        ScfVendorOperations.get moelements byclass
       |     ...               LNBTS
       |     Log to Console    ${mo_dict}
       |     ${modified_mo}    ScfVendorOperations.add parameter toManagedObject
       |     ...               ${param_toadd}
       |     ...               ${mo_dict}
       |     ScfVendorOperations.save back toxml
       |     ...               /tmp/vendor_test.xml
    """

    mrbtsObjs = None
    res1 = None
    res2 = None
    data_xml = None
    elements_list = None        # list of dicts containing header and managed objects

    def __init__(self):
        self.res1 = None
        self.res2 = None
        self.data_xml = None
        self.original_xml_path = ""
        self.elements_list = ""
        self.mo_list = None

    def setup_reader(self, xmlPath=None):
        """
        Load the XML file wmlpath.
        :param xmlPath: Filename of XML file.
        """
        try:
            self.res1, self.res2 = XMLConverter_wrapper.convert_xml(xmlPath)
            self.data_xml = XMLConverter_wrapper.load_jsondata(xmlPath.replace('.xml', '.json'))
            self.original_xml_path = xmlPath
            self.elements_list = self.data_xml['elements'][0]['elements']
            # print("Elements list: {}".format(self.elements_list))
            self.mo_list = list(filter(lambda d: d['type'] == 'managedObject', self.elements_list))
            # print("Managed objects are: {}".format(self.mo_list))
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))

    def save_back_toxml(self, dest_filepath=None):
        """
        Write xml_data to xml file. Commented lines are not loaded in xml_data so they are not saved
        if dest_filepath is not specidfied, the destination file is the original XML file
        :param dest_filepath:    the destination file path
        """
        XMLConverter_wrapper.save_data_to_xmlfile(self.data_xml,
                                                  dest_filepath if dest_filepath else self.original_xml_path)

    def get_moelements_byclass(self, mo_classname):
        """
        Returns the demanded managedObject
        :param mo_classname:    the demanded managedObject class name to look for
        :return:        a dict containing a JSON structure describing the requested mo content, \
                        or None if not found
        """
        result = None
        try:
            result = list(filter(lambda d: d['attributes']['class'] == mo_classname, self.mo_list))
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        return result[0]

    def get_namedlist_fromManagedObject(self, list_name, resmo):
        """
        Returns the demanded list content and indicates if the list has items
        :param list_name:   the demanded list name to look for
        :param resmo:       the <managedObject> in which the list is searched
        :return:            a couple of values:
                        - a dict containing a JSON structure describing the requested list content, \
                        or None if not found
                        - a boolean indicating if the list contains Items
        """
        result = None
        is_itemlist = False
        try:
            result = list(filter(lambda d: d['type'] == 'list' and
                                 d['attributes']['name'] == list_name, resmo['elements']))
            if result and 'value' in result[0]:
                is_itemlist = type(result[0]['value'][0]) is list
                # print("\nList is Item: {}".format(is_itemlist))
                # print("\nList is: {}".format(result[0]))
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        res = result[0] if len(result) >= 1 else None
        return res, is_itemlist

    def get_namedParameters_fromManagedObject(self, paramnames, resmo):
        """
        Returns the demanded parameters content
        :param paramnames:  the demanded parameter name list to look for
        :param resmo:       the <managedObject> in which the parameters are searched
        :return:            a couple:
                        - a list containing a JSON structure describing the requested parameters content, \
                            or an empty list if none of them is found
                        - a list of missing element from paramnames
        """
        result = []
        missing = []
        for element in paramnames:
            elemlist = None
            try:
                elemlist = list(filter(lambda d: d['type'] == 'p' and d['attributes']['name'] == element,
                                       resmo['elements']))
            except Exception as exc:
                print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
            if elemlist and elemlist[0]:
                result.append(elemlist[0])
            else:
                missing.append(element)
        return result, missing

    def remove_namedParameters_fromManagedObject(self, element_toremove, resmo):
        """
        Returns the modified managedObject
        :param element_toremove:    the param to be removed from managedObject
        :param resmo:               the managedObject in which the parameter is searched
        :return:                    the resulting managedObject
        """
        try:
            resmo['elements'] = list(filter(lambda d: d['attributes']['name'] != element_toremove, resmo['elements']))
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        return resmo

    def remove_items_fromList(self, items_toremove, list_name, resmo):
        """
        Returns the modified managedObject modifying a list contained
        :param items_toremove:      the items to be removed from the list
        :param list_name            the list where the removal has to happen
        :param resmo:               the managedObject to which the list belong
        :return:                    the resulting managedObject
        """
        try:
            list_totreat = list(filter(lambda d: d['type'] == 'list' and d['attributes']['name'] == list_name,
                                       resmo['elements']))
            dict_totreat = list_totreat[0]
            # print("\ndict_totreat is:\n{}".format(dict_totreat))
            result_value = [internal_list for internal_list in dict_totreat['value']
                            if self.match_items_toremove(internal_list, items_toremove)]
            print("\nresult_value is:\n{}".format(result_value))
            resulting_list = {'type': dict_totreat['type'],
                              'attributes': dict_totreat['attributes'],
                              'value': result_value}
            resmo['elements'] = [resulting_list if item['attributes']['name'] == list_name
                                 else item for item in resmo['elements']]
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        # if result:
        #     print("\n\nResulting List is: {}".format((result)))
        return resmo

    def match_items_toremove(self, my_dict, my_list):
        """
        INTERNAL USAGE
        """
        tmp_dict = dict()
        # print("\nitems to remove is:\n{}".format(my_list))
        # print("\ndictstuff is:\n{}".format(my_dict))
        for ele in my_dict:
            checking_elem = dict()
            mykey = ele['attributes']['name']
            myval = ele['value']
            checking_elem.update({mykey: myval})
            tmp_dict.update(checking_elem)
        return tmp_dict not in my_list

    def add_parameter_toManagedObject(self, element_toadd, resmo):
        """
        Returns the modified managedObject
        :param element_toadd:       the param to be added to managedObject
        :param resmo:               the managedObject in which the parameter is searched
        :return:                    the resulting managedObject
        """
        try:
            resmo['elements'].append(
                {
                    "type": "p",
                    "attributes": {
                        "name": element_toadd[0]
                    },
                    "value": element_toadd[1]
                }
            )
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        return resmo

    def add_items_toList(self, elements_toadd, list_name, resmo):
        """
        Returns the modified managedObject modifying a contained list items
        :param elements_toadd:      the list of items to be added to the list
        :param list_name            the list where the item has to be added
        :param resmo:               the managedObject to which the list belong
        :return:                    the resulting managedObject
        """
        result = None
        try:
            list_totreat = list(filter(lambda d: d['type'] == 'list' and d['attributes']['name'] == list_name,
                                       resmo['elements']))
            dict_totreat = list_totreat[0]
            # print("\nLIST before adding:\n{}".format(dict_totreat))
            # print("\nAdding list of dict defining Items: {}".format(elements_toadd))
            for elem in elements_toadd:
                item_content_list = list()
                for cur_key, myval in elem.items():
                    item_dict = {
                        "type": "p",
                        "attributes": {
                            "name": cur_key
                        },
                        "value": myval
                    }
                    item_content_list.append(item_dict)
                dict_totreat['value'].append(item_content_list)
            # print("\nADDING modified LIST:\n{}".format(dict_totreat))
            resmo['elements'] = [dict_totreat if item['attributes']['name'] == list_name
                                 else item for item in resmo['elements']]
            result = resmo
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        # if result:
        #     print("\n\nResulting mo is: {}".format((result)))
        return result

    def replace_items_inList(self, elements_toremove, elements_toadd, list_name, resmo):
        """
        Returns the modified managedObject modifying a contained list items
        :param elements_toremove:   the items to be replaced in the list
        :param elements_toadd:      the items to be added in the list
        :param list_name            the list where the item has to be added
        :param resmo:               the managedObject to which the list belong
        :return:                    the resulting managedObject
        """
        try:
            resmo = self.remove_items_fromList(elements_toremove, list_name, resmo)
            print("\nAdding:\n{}".format(elements_toadd))
            resmo = self.add_items_toList(elements_toadd, list_name, resmo)
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        # if result:
        #     print("\n\nResulting mo is: {}".format((result)))
        return resmo

    def replace_params_inMo(self, params_toreplace, resmo):
        """
        Returns the modified managedObject modifying a contained list items
        :param params_toreplace:    the parameters to be replaced with new values
        :param resmo:               the managedObject to which the list belong
        :return:                    the resulting managedObject
        """
        result = None
        try:
            for elem in params_toreplace:
                print("\nCurrent elem:{}".format(elem))
                resmo = self.remove_namedParameters_fromManagedObject(elem[0], resmo)
                # list_filtered, missing_params = self.get_namedParameters_fromManagedObject(
                #     [x for (x,v) in params_toreplace], resmo)
                # print("\nExisting: {}".format(list_filtered))
                # print("\nMissing: {}".format(missing_params))
                resmo = self.add_parameter_toManagedObject(elem, resmo)
            result = resmo
        except Exception as exc:
            print('exception is:\n{},\ntraceback is:\n{}'.format(exc, traceback.format_exc()))
        # if result:
        #     print("\n\nResulting mo is: {}".format((result)))
        return result
