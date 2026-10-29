from __future__ import print_function
from builtins import object
import os
import sys
import pytest
import difflib
# decomment to run tests: be careful, this solution does NOT pass SANITY! So put in comment
#
# path_test_file = os.path.abspath(__file__)
# path_test_dir = os.path.split(path_test_file)[0]
# project_path = os.path.split(path_test_dir)[0]
# sys.path.insert(0, project_path)
# comment previous line before pushing your code
from ..ScfVendorOperations import ScfVendorOperations


class TestScfVendorOperations(object):
    listop = ScfVendorOperations()
    listop.setup_reader("{}/{}".format(
        os.path.dirname(os.path.realpath(__file__)),
        "NIDD/vendor_1AE512BF_ori.xml"))

    def test_ListOperations(self):
        assert self.listop.res1 is not None
        assert self.listop.res2 is not None
        assert self.listop.data_xml is not None
        assert self.listop.elements_list is not None
        assert type(self.listop.mo_list) is list
        print("\nMO list length is: {}".format(len(self.listop.mo_list)))
        assert len(self.listop.mo_list) is 3

    def test_moFiltering(self):
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        # print("\nMO is: {}".format(res_mo))
        assert res_mo is not None
        assert type(res_mo) is dict

    def test_get_namedlist(self):
        list_name = "sonReportTextList"
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        print("\ncontent from list named {} is: {}".format(list_name, list_filtered))
        assert list_filtered is not None
        assert len(list_filtered) is 3
        assert isItemList

    def test_get_namedlist_noitems(self):
        list_name = "mMimoHorizontalGob"
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        print("\ncontent from list named {} is: {}".format(list_name, list_filtered))
        assert list_filtered is not None
        assert len(list_filtered) is 3
        assert not isItemList

    def test_get_namedParameters(self):
        list_params = ["anrLTEIntraRscReportAmount", "anrUtraInactivityTimer", "badChEstPer",
                       "cycPrefix", "JamesTheKiller"]
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_params, missing_params = self.listop.get_namedParameters_fromManagedObject(list_params, res_mo)
        print("\nparams list is:\n{}\nmissing params are:\n{}".format(list_params, missing_params))
        assert len(list_params) is 4
        assert len(missing_params) is 1

    def test_remove_namedParameters(self):
        list_params = ["anrLTEIntraRscReportAmount", "anrUtraInactivityTimer"]
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        # print("\nMO before removing:\n{}".format(res_mo))
        nr_elements = len(res_mo['elements'])
        for element_toremove in list_params:
            res_mo = self.listop.remove_namedParameters_fromManagedObject(element_toremove, res_mo)
        # print("\nMO **AFTER** removing:\n{}".format(res_mo))
        list_params, missing_params = self.listop.get_namedParameters_fromManagedObject(list_params, res_mo)
        assert len(res_mo['elements']) is nr_elements-2
        assert len(list_params) is 0
        assert len(missing_params) is 2

    def test_remove_items(self):
        items_toremove = [{"text": "CentrCellOutTriggReset", "textId": "8"},
                          {"text": "CentrEnbAutoConfig", "textId": "18"}]
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_name = "sonReportTextList"
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        prev_len = len(list_filtered['value'])
        assert len(list_filtered['value']) is 10
        print("\nlist before filtering has {} items!".format(prev_len))
        res_mo = self.listop.remove_items_fromList(items_toremove, list_name, res_mo)
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        post_len = len(list_filtered['value'])
        print("\nlist_filtered has {} items!".format(post_len))
        assert res_mo
        assert len(list_filtered['value']) is 8
        assert prev_len - post_len == 2

    def write_toxml(self, dest_file="pytest/NIDD/vendor_test.xml"):
        lines_xml = 0
        lines_xml_ori = 0
        difflines = []
        vendor_test_file = dest_file
        if os.path.exists(vendor_test_file):
            os.remove(vendor_test_file)
        self.listop.save_back_toxml(vendor_test_file)
        with open(vendor_test_file, 'r') as f:
            lines_xml = sum(1 for _ in f)
        with open("pytest/NIDD/vendor_1AE512BF_ori.xml", 'r') as f:
            lines_xml_ori = sum(1 for _ in f)
        with open("pytest/NIDD/vendor_1AE512BF_ori.xml", 'r') as f:
            with open(vendor_test_file, 'r') as compare_it:
                diff = difflib.unified_diff(f.readlines(), compare_it.readlines(),
                                            fromfile='f', tofile='compare_it')
            print("\nTHE DIFF is:\n")
            for line in diff:
                if line.startswith('- ') or line.startswith('+ '):
                    sys.stdout.write(line)
                    difflines.append(line)
        assert os.path.exists(vendor_test_file)
        print("\nXML generated file has {} lines".format(lines_xml))
        print("\nXML original file has {} lines".format(lines_xml_ori))
        if os.path.exists(vendor_test_file):
            os.remove(vendor_test_file)
        return lines_xml, difflines

    def test_write_thestuff_back_toxml(self):
        lines_xml, difflines = self.write_toxml()
        assert lines_xml == 477
        assert len(difflines) == 12

    def test_add_namedParameter(self):
        param_toadd = ("pipiLTEIntraRscReportAmount", "5")
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        # print("\nMO before removing:\n{}".format(res_mo))
        nr_elements = len(res_mo['elements'])
        res_mo = self.listop.add_parameter_toManagedObject(param_toadd, res_mo)
        # print("\nMO **AFTER** removing:\n{}".format(res_mo))
        list_params = ["pipiLTEIntraRscReportAmount"]
        matching_params, missing_params = self.listop.get_namedParameters_fromManagedObject(list_params, res_mo)
        print("\nParams nr Before and After: {} ==> {}".format(nr_elements, len(res_mo['elements'])))
        assert len(res_mo['elements']) is nr_elements + 1
        assert len(matching_params) is 1

    def test_add_item_tolist(self):
        items_toadd = [{"text": "CentrCellOutTriggReset", "textId": "8"}]
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_name = "sonReportTextList"
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        nr_elements_ori = len(list_filtered['value'])
        res_mo = self.listop.add_items_toList(items_toadd, list_name, res_mo)
        list_filtered, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        print("\nItems list:\n{}".format(list_filtered))
        nr_elements = len(list_filtered['value'])
        print("\nItems before and after modification: {} ==> {}".format(nr_elements_ori, nr_elements))
        assert nr_elements - nr_elements_ori is 1

    def test_replace_item_list(self):
        list_name = "dlInterferenceBFWeightSet"
        old_items_list = list()
        new_items_list = list()
        new_val1 = {
            "beamIdOfWeight": "1",
            "imagPartofWeighforAnt0": "3",
            "imagPartofWeighforAnt1": "2",
            "imagPartofWeighforAnt2": "1",
            "imagPartofWeighforAnt3": "4",
            "realPartofWeighforAnt0": "25000",
            "realPartofWeighforAnt1": "10000",
            "realPartofWeighforAnt2": "25000",
            "realPartofWeighforAnt3": "10000"
        }
        new_val2 = {
            "beamIdOfWeight": "2",
            "imagPartofWeighforAnt0": "3",
            "imagPartofWeighforAnt1": "2",
            "imagPartofWeighforAnt2": "1",
            "imagPartofWeighforAnt3": "4",
            "realPartofWeighforAnt0": "25000",
            "realPartofWeighforAnt1": "10000",
            "realPartofWeighforAnt2": "25000",
            "realPartofWeighforAnt3": "10000"
        }
        old_val1 = {
            "beamIdOfWeight": "1",
            "imagPartofWeighforAnt0": "0",
            "imagPartofWeighforAnt1": "0",
            "imagPartofWeighforAnt2": "0",
            "imagPartofWeighforAnt3": "0",
            "realPartofWeighforAnt0": "10000",
            "realPartofWeighforAnt1": "10000",
            "realPartofWeighforAnt2": "10000",
            "realPartofWeighforAnt3": "10000"
        }
        old_val2 = {
            "beamIdOfWeight": "2",
            "imagPartofWeighforAnt0": "0",
            "imagPartofWeighforAnt1": "0",
            "imagPartofWeighforAnt2": "0",
            "imagPartofWeighforAnt3": "0",
            "realPartofWeighforAnt0": "10000",
            "realPartofWeighforAnt1": "10000",
            "realPartofWeighforAnt2": "10000",
            "realPartofWeighforAnt3": "10000"
        }
        old_items_list.append(old_val1)
        old_items_list.append(old_val2)
        new_items_list.append(new_val1)
        new_items_list.append(new_val2)
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        list_filtered1, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        print("\nOriginal Item list:\n{}".format(list_filtered1))
        res_mo = self.listop.replace_items_inList(old_items_list, new_items_list, list_name, res_mo)
        list_filtered2, isItemList = self.listop.get_namedlist_fromManagedObject(list_name, res_mo)
        print("\nModified Item list:\n{}".format(list_filtered2))
        assert len(list_filtered1['value']) == len(list_filtered2['value'])
        diff_list = [x for x in list_filtered2['value'] if x not in list_filtered1['value']]
        print("\nDIFF Items list:\n{}".format(diff_list))
        test_elem = {
            'type': 'p',
            'attributes': {
                'name': 'realPartofWeighforAnt2'
            },
            'value': '25000'}
        assert test_elem in diff_list[0]
        assert test_elem in diff_list[1]

    def test_replace_parameters_list(self):
        replacement_params_list = list()
        new_val1 = ("actIntTrigOnFaultCancellation", "false")
        new_val2 = ("allowExceedAnrMOI", "2")
        new_val3 = ("anrUtraTRCGI", "10400ms")
        replacement_params_list.append(new_val1)
        replacement_params_list.append(new_val2)
        replacement_params_list.append(new_val3)
        res_mo = self.listop.get_moelements_byclass('LNBTS')
        res_mo = self.listop.replace_params_inMo(replacement_params_list, res_mo)
        names_list = [new_val1[0], new_val2[0], new_val3[0]]
        list_filtered, missing_params = self.listop.get_namedParameters_fromManagedObject(names_list, res_mo)
        print("\nModified Parameters list:\n{}".format(list_filtered))
        assert len(missing_params) == 0
        assert list_filtered[0]['value'] == 'false'
        assert list_filtered[1]['value'] == '2'
        assert list_filtered[2]['value'] == '10400ms'

    def test_write_thestuff_back_toxml2(self):
        lines_xml, difflines = self.write_toxml()
        assert lines_xml == 482
        assert len(difflines) == 75
