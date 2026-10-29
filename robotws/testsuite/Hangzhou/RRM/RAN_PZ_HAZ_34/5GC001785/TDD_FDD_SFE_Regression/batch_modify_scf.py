import functools
import threading
from concurrent.futures import ThreadPoolExecutor

from taf.config.scf import scf

# from object_parameter_variables import *
from object_parameter_variables import all_required_mos


class TestLine:
    def __init__(self):
        self.scf = scf()

    @staticmethod
    def add_mo_to_scf(class_name, dist_name, version, start_index=1, end_index=10, step=1):
        para_mo_list = []
        for index in range(start_index, end_index, step):
            para_mo = dict(class_name=class_name, dist_name=dist_name, version=version)
            para_mo_list.append(para_mo)
        return para_mo_list

    def modify_scf(self, params):
        self.scf.remove_list_from_scf(dist_name=params["dist_name"], list_name=params["list_name"])

    """
    1. add mo to scf
    2. add parameters
    3. check if para is list/item/p name or not
    4. check if para is list/p or not
    e.g.
    <managedObject class="com.nokia.srbts.nrbts:NRBTS" distName="MRBTS-35811/NRBTS-35811"
    version="NRBTSCL24R1_2322_120" operation="create">      add_object_to_scf
        <p name="xnSetupRespTmr">60</p>    add_element_to_scf
        <list name="actDrbProfileForCellAggrLevel">     add_list_to_scf
            <p>disabled</p>     add_elements_to_list
        </list>
        <list name="actMeasBasedSCellAdditionSa">
            <p>disabled</p>
        </list>
        <list name="actVoiceFallbackDuringHOPrep">
            <p>disabled</p>
        </list>
        <list name="cipherPrefL">
            <item>      add_item_to_list
              <p name="nea0">1</p>
              <p name="nea1_128">3</p>
              <p name="nea2_128">4</p>
              <p name="nea3_128">2</p>
            </item>
        </list>
    """

    def add_mos_to_scf(self):
        def outer_func(func):
            def inner_func(*args, **kwargs):
                self.scf.add_object_to_scf(class_name=kwargs['class_name'], dist_name=kwargs['dist_name'],
                                           version=kwargs['version'], operation='create')
                func()

            return inner_func

        return outer_func

    def add_p_name_to_dist_name(self, *args, **kwargs):
        self.scf.add_element_to_scf(dist_name=kwargs['dist_name'], p_name=kwargs['p_name'], value=kwargs['value'])

    def add_p_value_to_list_name(self, *args, **kwargs):
        self.scf.add_elements_to_list(dist_name=kwargs['dist_name'], list_name=kwargs['list_name'],
                                      elements=kwargs['elements'])

    def add_list_to_dist_name(self, *args, **kwargs):
        self.scf.add_list_to_scf(dist_name=kwargs['dist_name'], list_name=kwargs['list_name'])

    def add_item_to_list_name(self, *args, **kwargs):
        self.scf.add_item_to_list(dist_name=kwargs['dist_name'], list_name=kwargs['list_name'],
                                  elements=kwargs['elements'])

    def add_all_required_parameters(self, source_file_path, target_file_path):
        self.scf.load_scf(source_file_path)

        self.scf.add_element_to_scf(dist_name='MRBTS-35811/NRBTS-35811', p_name='xnSetupRespTmr', value='60')

        self.scf.add_list_to_scf(dist_name='MRBTS-35811/NRBTS-35811', list_name='actDrbProfileForCellAggrLevel')
        self.scf.add_elements_to_list(dist_name='MRBTS-35811/NRBTS-35811', list_name='actDrbProfileForCellAggrLevel',
                                      elements=['disabled'])

        self.scf.add_list_to_scf(dist_name='MRBTS-35811/NRBTS-35811', list_name='actMeasBasedSCellAdditionSa')
        self.scf.add_elements_to_list(dist_name='MRBTS-35811/NRBTS-35811', list_name='actMeasBasedSCellAdditionSa',
                                      elements=['disabled'])

        self.scf.add_list_to_scf(dist_name='MRBTS-35811/NRBTS-35811', list_name='actVoiceFallbackDuringHOPrep')
        self.scf.add_elements_to_list(dist_name='MRBTS-35811/NRBTS-35811', list_name='actVoiceFallbackDuringHOPrep',
                                      elements=['disabled'])

        self.scf.add_list_to_scf(dist_name='MRBTS-35811/NRBTS-35811', list_name='cipherPrefL')
        self.scf.add_item_to_list(dist_name='MRBTS-35811/NRBTS-35811', list_name='cipherPrefL',
                                  elements={"nea0": "1", "nea1_128": "3", "nea2_128": "4", "nea3_128": "2"})

        self.scf.save_scf(target_file_path, xml_declaration=True, encoding='UTF-8', standalone=True)

    def copy_all_parameters_with_dist_name(self, source_mo_dist_name, target_mo_dist_name):
        self.scf.clone_mo_with_descendant_mos(source_mo_dist_name, target_mo_dist_name)

    def copy_paras_all(self, **kwargs):
        # print(kwargs['start_index'])
        # print(kwargs['end_index'])
        for i in range(kwargs['start_index'], kwargs['end_index'] + 1):
            print(f"MRBTS-35811/{kwargs['bts_name']}-35821/{kwargs['mo_name']}-{kwargs['cp_i']}")
            # print(self.scf.is_object_in_scf(f"MRBTS-35811/{kwargs['bts_name']}-35821/{kwargs['mo_name']}-{i}"))
            if not self.scf.is_object_in_scf(f"MRBTS-35811/{kwargs['bts_name']}-35821/{kwargs['mo_name']}-{i}"):
                self.copy_all_parameters_with_dist_name(
                    source_mo_dist_name=f"MRBTS-35811/{kwargs['bts_name']}-35821/{kwargs['mo_name']}-{kwargs['cp_i']}",
                    target_mo_dist_name=f"MRBTS-35811/{kwargs['bts_name']}-35821/{kwargs['mo_name']}-{i}")

    def copy_paras_all_via_thread_pool(self, source_file_path, target_file_path):
        self.scf.load_scf(source_file_path)
        # with ThreadPoolExecutor(max_workers=256) as executor:
        #     executor.map(self.copy_paras_all, [para for para in all_required_mos])
        th = []
        for para in all_required_mos:
            th.append(threading.Thread(target=self.copy_paras_all, kwargs=para))
        for t in th:
            t.start()
        for t in th:
            t.join()
        self.scf.save_scf(target_file_path, xml_declaration=True, encoding='UTF-8', standalone=True)

    def change_scf_file(self, class_name, dist_name, version):
        self.scf.add_object_to_scf(class_name, dist_name, version, operation='create')

    def change_scf_file_via_threading(self, para_mo_list, file_path):
        th = []
        self.scf.load_scf(file_path)
        for mo_value in para_mo_list:
            th.append(threading.Thread(target=self.change_scf_file,
                                       args=(mo_value["class_name"], mo_value["dist_name"], mo_value["version"])))

        for t in th:
            t.start()
        for t in th:
            t.join()

        self.scf.save_scf(file_path, xml_declaration=True, encoding='UTF-8', standalone=True)


def modify_scf(para_mo_list, file_path):
    testline = TestLine()
    testline.change_scf_file_via_threading(para_mo_list, file_path)


def add_all_required_parameters_to_scf(source_file_path, target_file_path):
    testline = TestLine()
    testline.add_all_required_parameters(source_file_path=source_file_path, target_file_path=target_file_path)


def clone_all_required_paras(source_file_path, target_file_path):
    testline = TestLine()
    testline.copy_paras_all_via_thread_pool(source_file_path=source_file_path, target_file_path=target_file_path)
