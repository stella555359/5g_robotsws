import os
import sys
import pytest
from unittest.mock import MagicMock
import logging

# multiScfDir = os.path.abspath(__file__).split("pytest")[0]
# sys.path.insert(0, multiScfDir)
import MultiScf

logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())

pathDU = multiScfDir+"/pytest/testMultiCell/SCF_DU_Setup.xml"
pathCU = multiScfDir+"/pytest/testMultiCell/SCF_CU_Setup.xml"
pathClassical = multiScfDir+"/pytest/testMultiCell/SCF_1cell.xml"
VDU = "vdu"
VCU = "vcu"
VDUVCU = "vduvcu"
CLASSICAL = "classical"

TLConfig = MagicMock()
TLConfig.topo.archi.isAic.return_value = True
MultiScf.TLConfig = TLConfig


def test_get_mo_attribute():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    val = scf.get_mo_attribute(aicListEntity='VDU', scope='Aic', dn='MRBTS-10684/MNL-1', attrib='version')
    print("{}".format(val))
    assert val == "MNLVDU22R2_2113_100"


def test_modify_scf_element():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.modify_scf_element(aicListEntity='VDUVCU', scope='Aic', value="laurent", dist_name="MRBTS-10684",
                           p_name="btsName")
    scf.save_scf(file_path=multiScfDir+"/pytest/testMultiCell/SCF_DU_Setup_modified.xml",
                 second_file_path=multiScfDir+"/pytest/testMultiCell/SCF_CU_Setup_modified.xml")
    assert os.path.isfile(multiScfDir+"/pytest/testMultiCell/SCF_DU_Setup_modified.xml") is True


def test_is_object_in_scf():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(aicListEntity='VCU', scope='Aic', dist_name="MRBTS-10684/MNL-1/AMGR-1/LUAC-1") is \
           True


def my_is_list_in_object(path1, nodeType):
    scf = MultiScf.MultiScf()
    if nodeType.lower() == VDU:
        scf.load_scf(scf_path=path1)
    elif nodeType.lower() == VCU:
        scf.load_scf(second_scf_path=path1)
    val = scf.is_list_in_object(aicListEntity=nodeType, scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                                list_name='cellBwpList')
    return val


def test_is_list_in_object():
    val = my_is_list_in_object(pathDU, "Vdu")
    assert val is True


def test_remove_list_and_add_list_and_add_item():
    scf = MultiScf.MultiScf()
    scf.load_scf(pathDU, pathCU)
    scf.remove_list_from_scf(aicListEntity='VDUVCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                             list_name='cellBwpList')
    scf_removed1 = multiScfDir + "/pytest/testMultiCell/SCF_DU_Setup_removed.xml"
    scf_removed2 = multiScfDir + "/pytest/testMultiCell/SCF_CU_Setup_removed.xml"
    scf.save_scf(file_path=scf_removed1, second_file_path=scf_removed2)

    val = my_is_list_in_object(scf_removed1, "Vdu")
    val2 = my_is_list_in_object(scf_removed2, "Vcu")
    assert val is False
    assert val2 is False
    scf.load_scf(scf_removed1, scf_removed2)
    scf.add_list_to_scf(aicListEntity='VDUVCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                        list_name='cellBwpList')
    scf.save_scf(file_path=scf_removed1, second_file_path=scf_removed2)
    val = my_is_list_in_object(scf_removed1, "Vdu")
    val2 = my_is_list_in_object(scf_removed2, "Vcu")
    assert val is True
    assert val2 is True
    scf.load_scf(scf_removed1, scf_removed2)
    elem = dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-9', cellBwpId='2')
    elem2 = ['toto', 'titi']
    scf.add_item_to_list(aicListEntity='VDUVCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                         list_name='cellBwpList',
                         elements=elem)
    scf.add_elements_to_list(aicListEntity='VDUVCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                             list_name='cellBwpList',
                             elements=elem2)
    scf.add_element_to_scf(aicListEntity='VDUVCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                           p_name='newElem',
                           value="newVal")
    scf.add_object_to_scf(aicListEntity='VDUVCU', scope='Aic', class_name="mnl:new_class", dist_name="New_Dist_Name")
    scf.save_scf(file_path=scf_removed1, second_file_path=scf_removed2)


def test_get_value_from_scf():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    val = scf.get_value_from_scf(aicListEntity='VCU', scope='Aic', dist_name="MRBTS-10684", p_name="btsName")
    # print(val)
    assert len(val) > 1
    val = scf.get_value_from_scf(aicListEntity='VCU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/SNSSAI-1",
                                 list_name="nrPlmnDNList")
    # print(val)
    assert isinstance(val, str)
    val = scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", p_name="btsName")
    print(val)
    assert isinstance(val, str)


def test_get_all_values_from_scf():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    val = scf.get_all_values_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/MNL-1")
    print(val)
    assert len(val) == 1
    val = scf.get_all_values_from_scf(aicListEntity='VCU', scope='Aic', dist_name=None, list_name="staticRoutes")
    print(val)
    assert len(val) > 1


def test_get_all_values_from_scf_by_pattern():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    dn = 'MRBTS-10684/TNLSVC-./TNL-2/IPNO-./IPRT-.'     # our regexp !!
    val = scf.get_all_values_from_scf_by_pattern(aicListEntity='VCU', scope='Aic', dist_name=dn)
    assert len(val) > 1


def test_remove_mo_with_descendant_mos():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(aicListEntity='VCU', scope='Aic',
                                dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1") is True
    scf.remove_mo_with_descendant_mos(aicListEntity='VCU', scope='Aic',
                                      dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1")
    assert scf.is_object_in_scf(aicListEntity='VCU', scope='Aic',
                                dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1") is False


def test_remove_element_from_scf():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(aicListEntity='VDU', scope='Aic',
                                dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1") is True
    scf.remove_element_from_scf(aicListEntity='VDU', scope='Aic',
                                dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1")
    assert scf.is_object_in_scf(aicListEntity='VDU', scope='Aic',
                                dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1") is False


def test_check_for_objects():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.check_for_objects(aicListEntity='VDU', scope='Aic') is True


def test_check_for_lists():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.check_for_lists(aicListEntity='VDU', scope='Aic') is True


def test_check_for_items():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.check_for_items(aicListEntity='VDU', scope='Aic') is True


def test_check_for_elements():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.check_for_elements(aicListEntity='VDU', scope='Aic') is True


def test_is_element_in_object():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_element_in_object(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", p_name="btsName") \
           is True
    assert scf.is_element_in_object(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/EQM-1/APEQM-1/RMOD-1",
                                    p_name="actPimCancellation") is True
    assert scf.is_element_in_object(aicListEntity='VCU', scope='Aic',
                                    dist_name="MRBTS-10684/TNLSVC-1/TNL-5/IPNO-1/IPIF-2/IPADDRESSV4-1",
                                    p_name="uniqueIpAddressIdentifier") is True


def test_clone_mo_with_descendant_mos():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/EQM-TOTO") is False
    scf.clone_mo_with_descendant_mos(aicListEntity='VDU', scope='Aic', source_mo_distname="MRBTS-10684/EQM-1",
                                     target_mo_distname="MRBTS-10684/EQM-TOTO")
    assert scf.is_object_in_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/EQM-TOTO") is True
    # scf.save_scf(aicListEntity='VDU', scope='Aic', file_path="./python/pytest/testMultiCell/TESTSCF.xml")


def test_set_mo_attribute():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.set_mo_attribute(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", attribute="version",
                         value="test")
    scf.set_mo_attribute(aicListEntity='VCU', scope='Aic', dist_name="MRBTS-10684", attribute="version",
                         value="test")
    assert scf.get_mo_attribute(aicListEntity='VDU', scope='Aic', dn="MRBTS-10684", attrib="version") == "test"
    assert scf.get_mo_attribute(aicListEntity='VCU', scope='Aic', dn="MRBTS-10684", attrib="version") == "test"


def test_calculate_delta_scf():
    out = multiScfDir+"/pytest/testMultiCell/SCF_CU_Setup_delta.json"
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.calculate_delta_scf(aicListEntity='VCU', scope='Aic',
                            target_scf_path=multiScfDir+"/pytest/testMultiCell/SCF_CU_Setup_diff.xml",
                            actual_scf_path=multiScfDir+"/pytest/testMultiCell/SCF_CU_Setup.xml", delta_scf_path=out)
    assert os.stat(out).st_size != 0


def test_perform_scf_modification():
    strlist = ['delete:MRBTS-10684/MNL-1']
    strlist.append('add:MRBTS-10684:test=100')
    strlist.append('add:TNL-2/IPNO-1/IPRT-1:staticRoutes:ALINA=9999999')
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.perform_scf_modification(aicListEntity='VDU', scope='Aic', modification_strings=strlist)
    scf.perform_scf_modification(aicListEntity='VCU', scope='Aic', modification_strings=strlist)
    assert scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", p_name="test") == '100'
    assert scf.get_value_from_scf(aicListEntity='VCU', scope='Aic', dist_name="MRBTS-10684", p_name="test") == '100'


def test_empty_list():
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.empty_list(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                   list_name='cellBwpList')


def test_add_several_items_to_list():
    i = [{'nom': 'bbbb', 'prenom': 'toto'}, {'nom2': 'YYYYY', 'prenom2': 'XXXXX'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.add_several_items_to_list(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                                  list_name='cellBwpList', items=i)
    val = scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                                 p_name="prenom")
    assert val == 'toto'


def test_replace_items_in_list():
    i = [{'nom1': 'DUPONT', 'prenom1': 'titi'}, {'nom2': 'MARTIN', 'prenom2': 'toto'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.replace_items_in_list(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                              list_name='cellBwpList',
                              items=i)
    val = scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684/NRBTS-10684/NRCELL-1",
                                 p_name="prenom2")
    assert val == 'toto'


def test_add_several_elements():
    e = [{'dist_name': 'MRBTS-10684', 'p_name': 'titi', 'value': 'blabla'}, {'dist_name': 'MRBTS-10684/MNL-1',
                                                                             'p_name': 'tititi', 'value': 'blablabla'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.add_several_elements(aicListEntity='VDU', scope='Aic', elements=e)
    val = scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", p_name="titi")
    assert val == 'blabla'


def test_modify_several_elements():
    e = [{'dist_name': 'MRBTS-10684', 'p_name': 'btsName', 'value': 'bla..bla'},
         {'dist_name': 'MRBTS-10684/MNL-1/AMGR-1', 'p_name': 'btsEMRestrictedAccess', 'value': 'true'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.modify_several_elements(aicListEntity='VDU', scope='Aic', elements=e)
    val = scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name="MRBTS-10684", p_name="btsName")
    assert val == 'bla..bla'


def test_remove_several_elements():
    e = [{'dist_name': 'MRBTS-10684/NRBTS-10684/NRCELL-1', 'p_name': 'drxLongCycle', 'lit_name': 'drxProfile1'},
         {'dist_name': 'MRBTS-10684/MNL-1/AMGR-1', 'p_name': 'btsEMRestrictedAccess'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name='MRBTS-10684/NRBTS-10684/NRCELL-1',
                           p_name="drxLongCycle", list_name='drxProfile1')

    assert scf.is_element_in_object(aicListEntity='VDU', scope='Aic', dist_name='MRBTS-10684/MNL-1/AMGR-1',
                                    p_name="btsEMRestrictedAccess") is True
    scf.remove_several_elements(aicListEntity='VDU', scope='Aic', elements=e)
    assert scf.is_element_in_object(aicListEntity='VDU', scope='Aic', dist_name='MRBTS-10684/MNL-1/AMGR-1',
                                    p_name="btsEMRestrictedAccess") is False
    with pytest.raises(Exception) as e_info:
        scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name='MRBTS-10684/NRBTS-10684/NRCELL-1',
                               p_name="drxLongCycle", list_name='drxProfile1')
    assert 'No match found' in str(e_info.value)


def test_add_several_objects():
    o = [{'dist_name': 'MRBTS-10684/NRBTS-10684/NRCELL-1/TITI', 'class_name': 'com.nokia.srbts.5g:CCCCCC'},
         {'dist_name': 'MRBTS-10684/MNL-1/AMGR-1/TOTO', 'class_name': 'com.nokia.srbts.tnl:my_new_class'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    scf.add_several_objects(o, aicListEntity='VDU', scope='Aic')
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/MNL-1/AMGR-1/TOTO', aicListEntity='VDU', scope='Aic') is True


def test_remove_several_objects():
    o = [{'dist_name': 'MRBTS-10684/NRBTS-10684/NRCELL-1'}, {'dist_name': 'MRBTS-10684/MNL-1/AMGR-1'}]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/NRBTS-10684/NRCELL-1', aicListEntity='VDU', scope='Aic') is True
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/MNL-1/AMGR-1', aicListEntity='VDU', scope='Aic') is True
    scf.remove_several_objects(o, aicListEntity='VDU', scope='Aic')
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/NRBTS-10684/NRCELL-1', aicListEntity='VDU', scope='Aic') \
           is False
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/MNL-1/AMGR-1', aicListEntity='VDU', scope='Aic') is False


def test_add_several_any_things():
    t = [{'type': 'object', 'class_name': 'com.nokia.srbts.nrbts:NRCELL', 'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1111',
          'elements': {'a1MeashoEnabledTOTO': 'None', 'a1MeashoEnabledTOTO2': 'None', 'a1MeashoEnabledTITI': True}},
         {'type': 'object', 'class_name': 'com.nokia.srbts.tln:NRCELL', 'dist_name': 'MRBTS-9999'},
         {'type': 'object', 'class_name': 'com.nokia.srbts.tln:NRCELL', 'dist_name': 'MRBTS-9999/BIDULE',
          'elements': {'a1MeashoEnabledTOTO': 'None', 'a1MeashoEnabledTOTO2': 'None', 'a1MeashoEnabledTITI': True}},
         {'type': 'element', 'dist_name': 'MRBTS-9999/BIDULE', 'p_name': 'btsEMRestrictedBLABLA', 'value': 55555},
         {'type': 'element', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
          'p_name': 'ipBLABLA', 'value': 4444},
         {'type': 'list', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
          'items': [{'param1': 'value1'}, {'param2': 'value2'}]},
         {'type': 'list', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
          'elements': ['val101', 'val102', 'val103']},
         ]
    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(dist_name='MRBTS-1/NRBTS-1/NRCELL-1111', aicListEntity='VDU', scope='Aic') is False
    assert scf.is_element_in_object(dist_name='MRBTS-9999/BIDULE', p_name='btsEMRestrictedBLABLA',
                                    aicListEntity='VDU', scope='Aic') is False
    scf.add_several_any_things(t, aicListEntity='VDU', scope='Aic')
    assert scf.is_object_in_scf(dist_name='MRBTS-1/NRBTS-1/NRCELL-1111', aicListEntity='VDU', scope='Aic') is True
    assert scf.is_element_in_object(dist_name='MRBTS-9999/BIDULE', p_name='btsEMRestrictedBLABLA',
                                    aicListEntity='VDU', scope='Aic') is True
    assert scf.get_value_from_scf(aicListEntity='VDU', scope='Aic',
                                  dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
                                  p_name="param1", list_name='staticRoutes') == 'value1'
    res = scf.get_all_values_from_scf(dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", list_name='staticRoutes',
                                      aicListEntity='VDU', scope='Aic')
    assert 'val102' in res[8]


def test_remove_several_any_things():
    # t = [{'type': 'object', 'class_name': 'com.nokia.srbts.nrbts:NRCELL', 'dist_name': 'MRBTS-1/NRBTS-1/NRCELL-1111',
    #       'elements': {'a1MeashoEnabledTOTO': 'None', 'a1MeashoEnabledTOTO2': 'None', 'a1MeashoEnabledTITI': True}},
    #      {'type': 'object', 'class_name': 'com.nokia.srbts.tln:NRCELL', 'dist_name': 'MRBTS-9999'},
    #      {'type': 'object', 'class_name': 'com.nokia.srbts.tln:NRCELL', 'dist_name': 'MRBTS-9999/BIDULE',
    #       'elements': {'a1MeashoEnabledTOTO': 'None', 'a1MeashoEnabledTOTO2': 'None', 'a1MeashoEnabledTITI': True}},
    #      {'type': 'element', 'dist_name': 'MRBTS-9999/BIDULE', 'p_name': 'btsEMRestrictedBLABLA', 'value': 55555},
    #      {'type': 'element', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
    #       'p_name': 'ipBLABLA', 'value': 4444},
    #      {'type': 'list', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
    #       'items': [{'param1': 'value1'}, {'param2': 'value2'}]},
    #      {'type': 'list', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes',
    #       'elements': ['val101', 'val102', 'val103']},
    #      ]
    # t = [{'type': 'object', 'class_name': 'com.nokia.srbts.mnl:MNL', 'dist_name': 'MRBTS-10684/MNL-1',
    #       },
    #      ]
    t = [{'type': 'element', 'dist_name': 'MRBTS-10684/MNL-1', 'p_name': 'productVariantPlanned', 'value': '5gvDU'},
         {'type': 'element', 'dist_name': 'NRBTS-10684/NRCELL-1', 'p_name': 'drxLongCycle',
          'list_name': 'drxProfile1'},
         {'type': 'object', 'class_name': 'com.nokia.srbts.mnl:MNL', 'dist_name': 'MRBTS-10684/MNL-1'},
         {'type': 'list', 'dist_name': "MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1", 'list_name': 'staticRoutes'}]

    scf = MultiScf.MultiScf()
    scf.load_scf(scf_path=pathDU, second_scf_path=pathCU)
    assert scf.is_object_in_scf(dist_name='MRBTS-10684/MNL-1', aicListEntity='VDU', scope='Aic') is True
    assert scf.is_list_in_object(aicListEntity='VDU', scope='Aic',
                                 dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
                                 list_name='staticRoutes') is True
    val = scf.get_value_from_scf(aicListEntity='VCU', scope='Aic', dist_name="NRBTS-10684/NRCELL-1",
                                 list_name="drxProfile1",
                                 p_name="drxLongCycle")
    assert val == '40ms'
    scf.remove_several_any_things(t, aicListEntity='VDU', scope='Aic')
    with pytest.raises(Exception) as e_info:
        scf.get_value_from_scf(aicListEntity='VDU', scope='Aic', dist_name='NRBTS-10684/NRCELL-1',
                               p_name="drxLongCycle", list_name='drxProfile1')
    assert 'No match found' in str(e_info.value)
    assert scf.is_object_in_scf(aicListEntity='VDU', scope='Aic', dist_name='NRBTS-10684/MNL-1') is False
    assert scf.is_list_in_object(aicListEntity='VDU', scope='Aic',
                                 dist_name="MRBTS-10684/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
                                 list_name='staticRoutes') is False


test_get_mo_attribute()
test_modify_scf_element()
test_is_object_in_scf()
test_is_list_in_object()
test_remove_list_and_add_list_and_add_item()
test_get_value_from_scf()
test_get_all_values_from_scf()
test_get_all_values_from_scf_by_pattern()
test_remove_mo_with_descendant_mos()
test_remove_element_from_scf()
test_check_for_objects()
test_check_for_lists()
test_check_for_items()
test_check_for_elements()
test_is_element_in_object()
test_clone_mo_with_descendant_mos()
test_set_mo_attribute()
test_calculate_delta_scf()
test_perform_scf_modification()
test_empty_list()
test_add_several_items_to_list()
test_replace_items_in_list()
test_add_several_elements()
test_modify_several_elements()
test_remove_several_elements()
test_add_several_objects()
test_remove_several_objects()
test_add_several_any_things()
test_remove_several_any_things()
