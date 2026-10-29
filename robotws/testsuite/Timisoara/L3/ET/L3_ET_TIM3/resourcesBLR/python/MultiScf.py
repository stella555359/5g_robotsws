import StringTool
import string
import XmlScf as localScf
import taf.config.scf as scf
from ReadConfig import TLConfig

localScfFunc = localScf.XmlScf()
VDU = "vdu"
VCU = "vcu"
VDUVCU = "vduvcu"
VCUVDU = "vcuvdu"
CLASSICAL = "classical"


class MultiScf(object):
    """
    == Purpose ==
    Library capable of managing 1 or 2 SCF files depending on the type of gNB.

    == Description ==
    This library is a layer above the taf.config.scf library. It allows modifying the SCF file(s) according to
    the type of gNB. This library offers the same interface as the taf.config.scf library with an additional
    argument, named scope, to specify in which file to act. The principle is as follows:
    - If type of gNB is a gNB Classical then the library does not take into account the aicListEntity argument and \
      acts on the unique SCF file.
    - If gNB type is a vRAN2.0 gNB then depending on the aicListEntity argument and the library acts on one or both \
      of the SCF files.

       *Example:*
       | ### Settings ###
       | Library             ../../python/MultiScf.py    WITH NAME    scf
       |
       | ### Test Cases ###
       | Test
       |     log to console     START
       |     scf.load scf       ../../python/SCF_DU_Setup.xml
       |     log to console     get version for VDU
       |     ${toto}            scf.get mo attribute
       |     ...                scope=both    aicListEntity=Vdu
       |     ...                dn=MRBTS-10684
       |     ...                attrib=version
       |     log to console     version is ${toto}
       |
       | log to console         get version for VCU
       |     scf.load scf       ../../python/SCF_CU_Setup.xml
       |     ${toto}            scf.get mo attribute
       |     ...                scope=both    aicListEntity=Vcu
       |     ...                dn=MRBTS-10684
       |     ...                attrib=version
       |     log to console     version is ${toto}
       |
       |     ${toto}            scf.is_object_in_scf
       |     ...                scope=both    aicListEntity=Vdu
       |     ...                dist_name=MRBTS-10684/MNL-1/AMGR-1/LUAC-1
       |     log to console     in VDU: ${toto}
       |     ${toto}            scf.is_object_in_scf
       |     ...                scope=both    aicListEntity=Vcu
       |     ...                dist_name="MRBTS-10684/MNL-1/AMGR-1/LUAC-1
       |     log to console     in VCU: ${toto}
       |     ${toto}            scf.is_object_in_scf
       |     ...                scope=both    aicListEntity=VduVcu
       |     ...                dist_name="MRBTS-10684/MNL-1/AMGR-1/LUAC-1
       |     log to console     in VCU & VDU: ${toto}
       |     # tant que je fais du readonly sur scf, pas besoin de faire save scf
       |
       |     scf.modify_scf_element    scope=both    aicListEntity=VduVcu
       |     ...                       value=TEST2535
       |     ...                       dist_name=MRBTS-10684
       |     ...                       p_name=btsName
       |     # on vient de modifier un param dans les 2 scf donc la on doit sauver :
       |     scf.save scf              type=Vcu
       |     ...                       file_path=./SCF_CU_Setup_modified.xml
       |     scf.save scf              type=Vdu
       |     ...                       file_path=./SCF_DU_Setup_modified.xml
    """

    def __init__(self):
        self.tafScfFuncVdu = None
        self.tafScfFuncVcu = None
        self.tafScfFuncClassical = None

    def load_scf(self, scf_path=None, second_scf_path=None):
        """
        Load .xml one or two files known as Site Configuration File. Data will be stored in volatile memory,
        loaded files will not be edited until 'save_scf' keyword call.

        *Argument details:*
        :param scf_path: Filename of first SCF file (default value: None).
        :param second_scf_path: Filename of second SCF file (default value: None).
        """
        if scf_path is None and second_scf_path is None:
            raise Exception("No SCF provided. Please give scf file path")
        if TLConfig.topo.archi.isAic() and scf_path is not None and second_scf_path is not None:
            # scftype1 = self.getScfType(scf_path)
            # scftype2 = self.getScfType(second_scf_path)
            # if scftype1 == scftype2:
            #     raise Exception("Both SCF have same type {} == {}. And must be different".format(scftype1, scftype2))
            # else:
            self.create_scftaf_instance(scf_path, VDU)
            self.create_scftaf_instance(second_scf_path, "cu")
        elif TLConfig.topo.archi.isAic() and second_scf_path is not None:
            self.create_scftaf_instance(second_scf_path, "cu")
        elif TLConfig.topo.archi.isAic() and scf_path is not None:
            self.create_scftaf_instance(scf_path, VDU)
        if not TLConfig.topo.archi.isAic() and scf_path is not None:
            self.create_scftaf_instance(scf_path, "srbts")

    def getScfType(self, path):
        """
        INTERNAL USAGE
        """
        localScfFunc.startSession(path)
        return localScfFunc.getScfType()

    def create_scftaf_instance(self, scf_path, scftype):
        """
        INTERNAL USAGE
        """
        if scftype == VDU:
            self.tafScfFuncVdu = scf.scf()
            self.tafScfFuncVdu.load_scf(scf_path)
            self.vdu_versions = self.getDefaultVersion(scf_path)
        if scftype == "cu":
            self.tafScfFuncVcu = scf.scf()
            self.tafScfFuncVcu.load_scf(scf_path)
            self.vcu_versions = self.getDefaultVersion(scf_path)
        if scftype == "srbts":
            self.tafScfFuncClassical = scf.scf()
            self.tafScfFuncClassical.load_scf(scf_path)
            self.classical_versions = self.getDefaultVersion(scf_path)

    def nodeTypeCalculator(self, scope="Classical", listEntity="None"):
        if not TLConfig.topo.archi.isAic() and scope.lower() == "aic":
            return "skip"
        # if not TLConfig.topo.archi.isAic() and scope.lower() == "both" and listEntity.lower() == "vdu":
        #     return "skip"
        if not TLConfig.topo.archi.isAic():
            return CLASSICAL
        if TLConfig.topo.archi.isAic() and scope.lower() == "classical":
            return "skip"
        if TLConfig.topo.archi.isAic():
            if scope.lower() == "both" or scope.lower() == "aic":
                if listEntity.lower() != "none":
                    return listEntity
                else:
                    raise Exception("in case of AIC please specify listEntity")
            else:
                raise Exception("in case of aic scope must be both or aic")

    def getDefaultVersion(self, scf_path):
        """
        INTERNAL USAGE
        """
        localScfFunc.startSession(scf_path)
        return localScfFunc.getAllVersions()

    def save_scf(self, file_path, second_file_path=None, xml_declaration=True, encoding='UTF-8', standalone=True):
        """
        Save all changes, if another path than one during load operation given then new files will be created,
        old one remains without changes.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param file_path: VDU path as string.
        :param second_file_path: VCU path as string.
        :param xml_declaration: (Default value: True)
        :param encoding: (Default value: 'UTF-8')
        :param standalone: (Default value: True)
        """
        saved = False
        if not TLConfig.topo.archi.isAic() and self.tafScfFuncClassical is not None:
            self.tafScfFuncClassical.save_scf(file_path=file_path, xml_declaration=xml_declaration, encoding=encoding,
                                              standalone=standalone)
            self.tafScfFuncClassical = None
            saved = True
        if TLConfig.topo.archi.isAic() and self.tafScfFuncVdu is not None and file_path is not None:
            self.tafScfFuncVdu.save_scf(file_path=file_path, xml_declaration=xml_declaration, encoding=encoding,
                                        standalone=standalone)
            self.tafScfFuncVdu = None
            saved = True
        if TLConfig.topo.archi.isAic() and self.tafScfFuncVcu is not None and second_file_path is not None:
            self.tafScfFuncVcu.save_scf(file_path=second_file_path, xml_declaration=xml_declaration, encoding=encoding,
                                        standalone=standalone)
            self.tafScfFuncVcu = None
            saved = True
        if not saved:
            raise Exception("MultiScf.py inside save_scf :No scf saved, please check load was done before")

    def getInstance(self, nodeType):
        """
        INTERNAL USAGE
        """
        if nodeType.lower() == VDU:
            if self.tafScfFuncVdu is not None:
                return [self.tafScfFuncVdu]
            else:
                raise Exception("You need to perform first loadSCF for {}".format(nodeType))
        elif nodeType.lower() == VCU:
            if self.tafScfFuncVcu is not None:
                return [self.tafScfFuncVcu]
            else:
                raise Exception("You need to perform first loadSCF for {}".format(nodeType))
        elif nodeType.lower() == VDUVCU or nodeType.lower() == VCUVDU:
            if self.tafScfFuncVdu is not None and self.tafScfFuncVcu is not None:
                return [self.tafScfFuncVdu, self.tafScfFuncVcu]
            else:
                raise Exception("You need to perform first loadSCF for {}".format(nodeType))
        else:
            if self.tafScfFuncClassical is not None:
                return [self.tafScfFuncClassical]
            else:
                raise Exception("You need to perform first loadSCF for {}".format(nodeType))

    def modify_scf_element(self, value, aicListEntity='VDU', scope='Classical', bestEffort=False, **kwargs):
        """
        Reads single value. Attributes are mapped to SCF element's attributes. Raises exception if more or less
        than one element found. If there is not direct way to point at specific element (some of them are not named
        properly or there are duplicated names), and one can avoid exception if multiple matches found, index
        attribute can be used to modify specific element from list of matches.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param value: New value.
        :param bestEffort: If bestEffort is true, the value will be modified where we can find it - vdu, vcu or both.
            No need to specify the node type , it is considered to be only for vduvcu.
            For classical it should be set to False
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent. None is default value.
        :param p_name: 'name' attribute in <p> tag, None is default value.
        :param list_name: 'name' attribute in <list> tag, None is default value.
        :param index: Optional parameter, should be castable to int (int or str). Should be used if more than one \
                      match expected. Indexing starts from 0.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if TLConfig.topo.archi.isAic() and bestEffort is True:
            if self.tafScfFuncVdu is not None:
                if "p_name" in kwargs:
                    if self.tafScfFuncVdu.is_element_in_object(kwargs.get('dist_name'),
                                                               kwargs.get('p_name')) is not False:
                        self.tafScfFuncVdu.modify_scf_element(value, **kwargs)
                    else:
                        StringTool.datedConsole("INFO: Element not found in vdu scf: {}, in dist name: {}"
                                                .format(kwargs.get('p_name'), kwargs.get('dist_name')))
                else:
                    if self.tafScfFuncVdu.is_element_in_object(kwargs.get('dist_name'),
                                                               kwargs.get('list_name')) is not False:
                        self.tafScfFuncVdu.modify_scf_element(value, **kwargs)
                    else:
                        StringTool.datedConsole("INFO: Element not found in vdu scf: {}, in dist name: {}"
                                                .format(kwargs.get('list_name'), kwargs.get('dist_name')))
            else:
                StringTool.datedConsole("INFO: no vdu scf loaded")
            if self.tafScfFuncVcu is not None:
                if "p_name" in kwargs:
                    if self.tafScfFuncVcu.is_element_in_object(kwargs.get('dist_name'),
                                                               kwargs.get('p_name')) is not False:
                        self.tafScfFuncVcu.modify_scf_element(value, **kwargs)
                    else:
                        StringTool.datedConsole("INFO: Element not found in vcu scf: {}, in dist name: {}"
                                                .format(kwargs.get('p_name'), kwargs.get('dist_name')))
                else:
                    if self.tafScfFuncVcu.is_element_in_object(kwargs.get('dist_name'),
                                                               kwargs.get('list_name')) is not False:
                        self.tafScfFuncVcu.modify_scf_element(value, **kwargs)
                    else:
                        StringTool.datedConsole("INFO: Element not found in vcu scf: {}, in dist name: {}"
                                                .format(kwargs.get('list_name'), kwargs.get('dist_name')))
            else:
                StringTool.datedConsole("INFO: no vcu scf loaded")
        else:
            instance = self.getInstance(nodeType)
            instance[0].modify_scf_element(value, **kwargs)
            if len(instance) == 2:
                instance[1].modify_scf_element(value, **kwargs)

    # mo attribute will be get for one of VDU or VCU; if needed on both, you must give this command 2 times
    def get_mo_attribute(self, dn, attrib, aicListEntity='VDU', scope='Classical'):
        """
        Returns value of parameter 'attribute' of managed object indicated in 'dist_name'. Raises KeyError: when
        managed object named 'dist_name' does not have proper attribute.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, None. VCUVDU not supported.
        :param scope: CLASSICAL, AIC, Both.
        :param dn: DistName of managed object.
        :param attrib: Attribute name of indicated managed object.
        :return: Value of 'attribute' (string)
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if nodeType.lower() == VDUVCU or nodeType.lower() == VCUVDU:
            raise Exception("get_mo_attribute - VDUVCU aicListEntity not supported - must be one of them:VCU or VDU")
        instance = self.getInstance(nodeType)
        val = instance[0].get_mo_attribute(dn, attrib)
        return val

    # if your nodeType is VDUVCU it will return true only if object in both
    def is_object_in_scf(self, dist_name, aicListEntity='VDU', scope='Classical'):
        """
        Checks whether given object exists in loaded SCF. The object is mapped by the attribute distName.
        If your nodeType is VDUVCU or it VCUVDU will return true only if object in both.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: DistName of checked object.
        :return: True if object exists, False otherwise. (rtype: bool)
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if nodeType.lower() == VDUVCU or nodeType.lower() == VCUVDU:
            raise Exception("is_object_in_scf - VDUVCU aicListEntity not supported - must be one of them:VCU or VDU")
        instance = self.getInstance(nodeType)
        return instance[0].is_object_in_scf(dist_name)

    def is_list_in_object(self, dist_name, list_name, aicListEntity='VDU', scope='Classical'):
        """
        Checks whether given list exists in given object. The object is mapped by the attribute distName.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: DistName of checked object.
        :param list_name: Name of the checked list.
        :return: True if list exists, False otherwise. (rtype: bool)
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if nodeType.lower() == VDUVCU or nodeType.lower() == VCUVDU:
            raise Exception("is_list_in_object - VDUVCU aicListEntity not supported - must be one of them:VCU or VDU")
        instance = self.getInstance(nodeType)
        return instance[0].is_list_in_object(dist_name, list_name)

    def remove_list_from_scf(self, dist_name, list_name, aicListEntity='VDU', scope='Classical'):
        """
        Removes list from loaded SCF inside managed object indicated in 'dist_name'.
        Raise ElementNotFound: when 'dist_name' not found inside given SCF.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param list_name: 'name' attribute in <list> tag.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].remove_list_from_scf(dist_name, list_name)
        if len(instance) == 2:
            instance[1].remove_list_from_scf(dist_name, list_name)

    def add_object_to_scf(self, class_name, dist_name, aicListEntity='VDU', scope='Classical', operation='create',
                          version=None):
        """
        Adds whole managedObject to loaded SCF. All parameters are mandatory and are addded as attributes to
        the object. Changes are saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param class_name: Added as attribute 'class'.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param operation: Added as attribute 'operation' (Default value: 'create').
        :param version:   kept for compatibility - unused.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        if nodeType.lower() == VCUVDU or nodeType.lower() == VDUVCU:
            version = self._get_needed_version('vdu', class_name)
        else:
            version = self._get_needed_version(nodeType, class_name)
        instance[0].add_object_to_scf(class_name, dist_name, version, operation)
        if len(instance) == 2:
            version_vcu = self._get_needed_version('vcu', class_name)
            instance[1].add_object_to_scf(class_name, dist_name, version_vcu, operation)

    def add_list_to_scf(self, dist_name, list_name, aicListEntity='VDU', scope='Classical'):
        """
        Adds an empty list to object in loaded SCF. The object is mapped by the attribute distName. Changes are
         saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param list_name: Name of the new list.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].add_list_to_scf(dist_name, list_name)
        if len(instance) == 2:
            instance[1].add_list_to_scf(dist_name, list_name)

    def add_item_to_list(self, dist_name, list_name, elements, aicListEntity='VDU', scope='Classical'):
        """
        Adds the items from elements dictionary (name, value) to the list in object in loaded SCF. The object
        is mapped by the attribute distName. Changes are saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param list_name: Name of the target list.
        :param elements: Dictionary of elements added to the list, key is an element name, value is an element value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].add_item_to_list(dist_name, list_name, elements)
        if len(instance) == 2:
            instance[1].add_item_to_list(dist_name, list_name, elements)

    def add_elements_to_list(self, dist_name, list_name, elements, aicListEntity='VDU', scope='Classical'):
        """
        Adds the elements from elements list to the list in object in loaded SCF. The object is mapped by
        the attribute distName. Changes are saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param list_name: Name of the target list.
        :param elements: List of elements to add to the target list.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].add_elements_to_list(dist_name, list_name, elements)
        if len(instance) == 2:
            instance[1].add_elements_to_list(dist_name, list_name, elements)

    def add_element_to_scf(self, dist_name, p_name, value, aicListEntity='VDU', scope='Classical'):
        """
        Adds element to object in loaded SCF. The object is mapped by the attribute distName.
        The element is added at the end of list of objects children. Changes are saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param p_name: Name of attribute of new element.
        :param value: Value of new element.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].add_element_to_scf(dist_name, p_name, value)
        if len(instance) == 2:
            instance[1].add_element_to_scf(dist_name, p_name, value)

    def get_value_from_scf(self, dist_name, aicListEntity='VDU', scope='Classical', p_name=None, list_name=None):
        """
        Reads single value of p element. If one scf returns string.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param p_name: name attribute in <p> tag, None is default value.
        :param list_name: name attribute in <list> tag, None is default value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if aicListEntity.lower() == VDUVCU or aicListEntity.lower() == VCUVDU:
            raise Exception("get_mo_attribute - VDUVCU aicListEntity not supported - must be: VCU or VDU")
        instance = self.getInstance(nodeType)
        val = instance[0].get_value_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name)
        return val

    def get_all_values_from_scf(self, dist_name, aicListEntity='VDU', scope='Classical', p_name=None, list_name=None):
        """
        Returns list of all matched values of p elements, does expect any specific number of matches. For values of
        managed objects attributes keyword get_mo_attribute should be used.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param p_name: name attribute in <p> tag, None is default value.
        :param list_name: name attribute in <list> tag, None is default value.
        return: read value as string.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if aicListEntity.lower() == VDUVCU or aicListEntity.lower() == VCUVDU:
            raise Exception("get_mo_attribute - VDUVCU aicListEntity not supported - must be: VCU or VDU")
        instance = self.getInstance(nodeType)
        val = instance[0].get_all_values_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name)
        return val

    def get_all_values_from_scf_by_pattern(self, aicListEntity='VDU', scope='Classical', dist_name=None, p_name=None,
                                           list_name=None):
        """
        Same as get_all_values_from_scf but expects regular expressions in dist_name, p_name or list_name.

        *Argument details from get_all_values_from_scf:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        :param p_name: name attribute in <p> tag, None is default value.
        :param list_name: name attribute in <list> tag, None is default value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        v = instance[0].get_all_values_from_scf_by_pattern(dist_name=dist_name, p_name=p_name, list_name=list_name)
        return v

    def remove_mo_with_descendant_mos(self, aicListEntity='VDU', scope='Classical', dist_name=None):
        """
        Removes managed object with given distName together with all its descendant managed objects. Changes are
        saved only after save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].remove_mo_with_descendant_mos(dist_name=dist_name)
        if len(instance) == 2:
            instance[1].remove_mo_with_descendant_mos(dist_name=dist_name)

    def remove_element_from_scf(self, aicListEntity='VDU', scope='Classical', dist_name=None, p_name=None,
                                list_name=None, index=None):
        """
        Removes element from loaded SCF. Attributes are mapped to SCF elements attributes. If p_name or index given
        it removes only single element. If not the whole managedObject is removed. Changes are saved only after
        save_scf keyword.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent. None is default value.
        :param p_name: name attribute in <p> tag, None is default value.
        :param list_name: name attribute in <list> tag, None is default value.
        :param index: optional parameter, should be castable to int (int or str). Should be used if more than one \
                      match expected. Indexing starts from 0. If not given and param p_name not given the whole \
                      managedObject is removed. None is default value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].remove_element_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name, index=index)
        if len(instance) == 2:
            instance[1].remove_element_from_scf(dist_name=dist_name, p_name=p_name, list_name=list_name, index=index)

    def check_for_objects(self, aicListEntity='VDU', scope='Classical'):
        """
        Checks if loaded SCF file contains any objects (markers of managedObject type) inside.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        res = instance[0].check_for_objects()
        if len(instance) == 2:
            res2 = instance[1].check_for_objects()
            return res and res2
        else:
            return res

    def check_for_lists(self, aicListEntity='VDU', scope='Classical'):
        """
        Checks if loaded SCF file contains any lists (markers of list type) inside.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        res = instance[0].check_for_lists()
        if len(instance) == 2:
            res2 = instance[1].check_for_lists()
            return res and res2
        else:
            return res

    def check_for_items(self, aicListEntity='VDU', scope='Classical'):
        """
        CChecks if loaded SCF file contains any items (markers of item type) inside.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        res = instance[0].check_for_items()
        if len(instance) == 2:
            res2 = instance[1].check_for_items()
            return res and res2
        else:
            return res

    def check_for_elements(self, aicListEntity='VDU', scope='Classical'):
        """
        Checks if loaded SCF file contains any nonempty list inside.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        res = instance[0].check_for_elements()
        if len(instance) == 2:
            res2 = instance[1].check_for_elements()
            return res and res2
        else:
            return res

    def is_element_in_object(self, dist_name, p_name, aicListEntity='VDU', scope='Classical'):
        """
        Checks whether given element exists directly under given object.The object is mapped by the attribute distName.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: of checked object - In <managedObject> as 'distName', SBTS prefix can be ommited e.g.: both \
                          'SBTS-1900/NGNODEB-1' and 'NGNODE-1' are valid and equivalent. None is default value.
        :param p_name: name of the checked element.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        if nodeType.lower() == VDUVCU or nodeType.lower() == VCUVDU:
            raise Exception("is_element_in_object - VDUVCU not supported - must be one of them:VCU or VDU")
        instance = self.getInstance(nodeType)
        return instance[0].is_element_in_object(dist_name=dist_name, p_name=p_name)

    def clone_mo_with_descendant_mos(self, source_mo_distname, target_mo_distname, aicListEntity='VDU',
                                     scope='Classical'):
        """
        Copies managed object of given source distName and all managed objects that have it in distName and creates
        all these managed objects with source name replaced by target name.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param source_mo_distname: distName of parent managed object to be cloned.
        :param target_mo_distname: dn that new managed object & its children will get in place of source distName.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].clone_mo_with_descendant_mos(source_mo_dist_name=source_mo_distname,
                                                 target_mo_dist_name=target_mo_distname)
        if len(instance) == 2:
            instance[1].clone_mo_with_descendant_mos(source_mo_dist_name=source_mo_distname,
                                                     target_mo_dist_name=target_mo_distname)

    def set_mo_attribute(self, dist_name, attribute, value, aicListEntity='VDU', scope='Classical'):
        """
        Sets parameter attribute of managed object indicated in dist_name to value.

        Example:
         - Data:           <managedObject distName="SBTS-1900/RAP-1" version="5G17_1707_001">.
         - Function call:  set_mo_attribute("SBTS-1900/RAP-1", "version", "new_version").
         - Updated data:   <managedObject distName="SBTS-1900/RAP-1" version="new_version">.
         - Return value:   "new_version".

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: distName of managed object to be updated.
        :param attribute: attribute to be changed (or set if attribute doesnt exist in indicated managed object).
        :param value: new value of "attribute".
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].set_mo_attribute(dist_name=dist_name, attribute=attribute, value=value)
        if len(instance) == 2:
            instance[1].set_mo_attribute(dist_name=dist_name, attribute=attribute, value=value)

    def calculate_delta_scf(self, target_scf_path, actual_scf_path, delta_scf_path, oam_type='COAM',
                            aicListEntity='VDU', scope='Classical'):
        """
        Calculates a delta SCF from two full SCFs, that can be used to revert the current gNB configuration back to
        the original one.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param target_scf_path:  path to the target SCF file with gNB configuration.
        :param actual_scf_path: path to the actual SCF file with gNB configuration.
        :param delta_scf_path: output path for the delta SCF file. Expect .json format in case of oam_type=COAM.
        :param oam_type:  string for choosing COAM or MZ. COAM is default value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].calculate_delta_scf(target_scf_path=target_scf_path, actual_scf_path=actual_scf_path,
                                        delta_scf_path=delta_scf_path, oam_type=oam_type)
        if len(instance) == 2:
            instance[1].calculate_delta_scf(target_scf_path=target_scf_path, actual_scf_path=actual_scf_path,
                                            delta_scf_path=delta_scf_path, oam_type=oam_type)

    def perform_scf_modification(self, modification_strings, aicListEntity='VDU', scope='Classical'):
        """
        Perform SCF modifications.
        There are 3 possible operations: add, delete, and modify. Each of them has different possibilities,
        please refer to explanation here:
        https://docs.taf.nsn-rdnet.net/taf.config.scf/#taf.config.scf.interface.scf.perform_scf_modification
        Multiple operations can be added at the same time via string entries in modification_strings list.
        Modifications are performed based on provided ManagedObject name(s).

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param modification_strings: it consist of modification strings. (list).

        Example:
         - To add parameter to ManagedObject
         - (add shareOfHSDPAUser=100 to WNCELG-1):   'add:WNCELG-1:shareOfHSDPAUser=100'.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        instance = self.getInstance(nodeType)
        instance[0].perform_scf_modification(modification_strings=modification_strings)
        if len(instance) == 2:
            instance[1].perform_scf_modification(modification_strings=modification_strings)

    def empty_list(self, aicListEntity='VDU', scope='Classical', dist_name=None, list_name=None):
        """
        Deletes list_name list and then re-adds. This is equivalent to emptying the list.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: mo distname containing the list (ex: "MRBTS-10684/NRBTS-10684/NRCELL-1").
        :param list_name: name of the target list (ex: cellBwpList).
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        self.remove_list_from_scf(aicListEntity=aicListEntity, scope=scope, dist_name=dist_name, list_name=list_name)
        self.add_list_to_scf(aicListEntity=aicListEntity, scope=scope, dist_name=dist_name, list_name=list_name)

    def add_several_items_to_list(self, aicListEntity='VDU', scope='Classical', dist_name=None, list_name=None,
                                  items=None):
        """
        Add items to a list via a list of dictionaries. Each of the dictionaries being the parameters of each item.
        The list has the following structure:

            [{'param_name_01': 'value_param_01', 'param_name_02':'value_param_02'},
             {'param_name_11': 'value_param_11', 'param_name_12':'value_param_12'}]

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: mo distname containing the list (ex: "MRBTS-10684/NRBTS-10684/NRCELL-1").
        :param list_name: name of the target list (ex: cellBwpList).
        :param items: List of dictionary of elements added to the list. In the dictionnary, key is an element name,
                      value is an element value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        for i in items:
            self.add_item_to_list(aicListEntity=aicListEntity, scope=scope, dist_name=dist_name, list_name=list_name,
                                  elements=i)

    def replace_items_in_list(self, aicListEntity='VDU', scope='Classical', dist_name=None, list_name=None,
                              items=None):
        """
        Destroy the list then recreate it by setting with item list defined by the parameter 'items'.

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param dist_name: mo distname containing the list (ex: "MRBTS-10684/NRBTS-10684/NRCELL-1").
        :param list_name: name of the target list (ex: cellBwpList).
        :param items: List of dictionary of elements added to the list. In the dictionnary, key is an element name,
                      value is an element value.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        self.empty_list(aicListEntity=aicListEntity, scope=scope, dist_name=dist_name, list_name=list_name)
        self.add_several_items_to_list(aicListEntity=aicListEntity, scope=scope, dist_name=dist_name,
                                       list_name=list_name, items=items)

    def add_several_elements(self, elements, aicListEntity='VDU', scope='Classical'):
        """
        Adds several parameters to the SCF file from the elements parameter which has the following structure:

        [{'dist_name': <dist_name of parameter>, 'p_name': <p_name of parameter>, 'value': <value of parameter>}, ... ]

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param elements:  List of dictionary of elements to be added to the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(elements, list)
        for e in elements:
            self.add_element_to_scf(dist_name=e['dist_name'], p_name=e['p_name'], value=e['value'],
                                    aicListEntity=aicListEntity, scope=scope)

    def modify_several_elements(self, elements, aicListEntity='VDU', scope='Classical'):
        """
        This method does not apply to the modification of parameters contained in an item of a list.
        Modifies several parameters to the SCF file from the elements parameter which has the following structure:

        [{'dist_name': <dist_name of parameter>, 'p_name': <p_name of parameter>, 'value': <value of parameter>}, ... ]

        ('list_name': <list_name of parameter>  //  optional: used if the parameter is in a list)

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param elements:  List of dictionary of elements to be added to the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(elements, list)
        for e in elements:
            self.modify_scf_element(dist_name=e['dist_name'], p_name=e['p_name'], value=e['value'],
                                    aicListEntity=aicListEntity, scope=scope)

    def remove_several_elements(self, elements, aicListEntity='VDU', scope='Classical'):
        """
        Delete several elements (parameters) defined in the elements parameter which has the following structure:

        [{'dist_name': <dn of parameter>, 'p_name': <name of parameter>, 'list_name': <list with parameter>}, ... ]

        ('list_name' is the list name which contains parameter>  //  optional: used if the parameter is in a list)

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param elements:  List of dictionary of elements to be added to the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(elements, list)
        for e in elements:
            listname = e['list_name'] if 'list_name' in e else None
            self.remove_element_from_scf(dist_name=e['dist_name'], p_name=e['p_name'], list_name=listname,
                                         aicListEntity=aicListEntity, scope=scope)

    def add_several_objects(self, objects, aicListEntity='VDU', scope='Classical'):
        """
        Add several managedObject from objects list which has the following structure:

        [{ 'class_name': '<class_name of managedObject>', 'dist_name': '<dist_name of managedObject>' } ... ]

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param objects:  List of dictionary of objects to be added to the scf.
        The value of version parameter is automatically retrieved.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(objects, list)
        for o in objects:
            self.add_object_to_scf(class_name=o['class_name'], dist_name=o['dist_name'], aicListEntity=aicListEntity,
                                   scope=scope, operation='create')

    def _get_needed_version(self, nodeType, class_name):
        """ INTERNAL USAGE """
        version_dict = {}
        if nodeType.lower() == CLASSICAL:
            version_dict = self.classical_versions
        elif nodeType.lower() == VDU:
            version_dict = self.vdu_versions
        elif nodeType.lower() == VCU:
            version_dict = self.vcu_versions
        try:
            if 'mnl' in class_name:
                version = version_dict['MNL']
            elif 'eqm' in class_name:
                version = version_dict['EQM']
            elif 'tnl' in class_name:
                version = version_dict['TNL']
            elif 'nrbts' in class_name:
                version = version_dict['NRBTS']
            else:
                version = version_dict['MRBTS']
        except KeyError:
            raise Exception("No version found in base scf for node: {} for {}".format(nodeType, class_name))
        return version

    def remove_several_objects(self, objects, aicListEntity='VDU', scope='Classical'):
        """ remove several managedObject and all its components from objects list which has the following structure:
            [['dist_name': <dist_name of managedObject>}, ... ]

        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param objects:  List of objects to be removed from the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(objects, list)
        for o in objects:
            self.remove_mo_with_descendant_mos(dist_name=o['dist_name'], aicListEntity=aicListEntity, scope=scope)

    def add_several_any_things(self, things, aicListEntity='VDU', scope='Classical'):
        """
        Add several things, params, lists et item from things list which has the structure described here:
        https://confluence.ext.net.nokia.com/display/5GFTPARIS/SCF+files+study
        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param things:  List of objects to be removed from the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(things, list)
        for o in things:
            if o['type'] == 'object':
                self.add_object_to_scf(class_name=o['class_name'], dist_name=o['dist_name'],
                                       aicListEntity=aicListEntity, scope=scope, operation='create')
                if 'elements' in o:
                    for param, val in o['elements'].items():
                        self.add_element_to_scf(aicListEntity=aicListEntity, scope=scope, dist_name=o['dist_name'],
                                                p_name=param, value=val)
            elif o['type'] == 'element':
                if 'list_name' not in o:
                    self.add_element_to_scf(dist_name=o['dist_name'], aicListEntity=aicListEntity, scope=scope,
                                            p_name=o['p_name'], value=o['value'])
                else:
                    elem = {o['p_name']: o['value']}
                    self.add_item_to_list(dist_name=o['dist_name'], list_name=o['list_name'], elements=elem,
                                          aicListEntity=aicListEntity, scope=scope)
            elif o['type'] == 'list':
                if 'items' in o:
                    for i in o['items']:
                        self.add_item_to_list(dist_name=o['dist_name'], list_name=o['list_name'], elements=i,
                                              aicListEntity=aicListEntity, scope=scope)
                elif 'elements' in o:
                    self.add_elements_to_list(dist_name=o['dist_name'], list_name=o['list_name'],
                                              elements=o['elements'], aicListEntity=aicListEntity, scope=scope)
            else:
                raise Exception("Error Unknown type: {}".format(o['type']))

    def remove_several_any_things(self, things, aicListEntity='VDU', scope='Classical'):
        """
        Remove several any things, params, lists & item from things list which has the structure described here:
        https://confluence.ext.net.nokia.com/display/5GFTPARIS/SCF+files+study
        *Argument details:*
        :param aicListEntity: Type of node: VCU or VDU, VDUVCU, None.
        :param scope: CLASSICAL, AIC, Both.
        :param things:   List of objects to be removed from the scf.
        """
        nodeType = self.nodeTypeCalculator(scope=scope, listEntity=aicListEntity)
        if nodeType == "skip":
            return None
        assert isinstance(things, list)
        for o in things:
            if o['type'] == 'object':
                self.remove_mo_with_descendant_mos(dist_name=o['dist_name'], aicListEntity=aicListEntity, scope=scope)
            elif o['type'] == 'element':
                if 'list_name' not in o:
                    self.remove_element_from_scf(aicListEntity=aicListEntity, scope=scope, dist_name=o['dist_name'],
                                                 p_name=o['p_name'], list_name=None, index=None)
                else:
                    self.remove_element_from_scf(dist_name=o['dist_name'], list_name=o['list_name'],
                                                 p_name=o['p_name'], aicListEntity=aicListEntity, scope=scope,
                                                 index=None)
            elif o['type'] == 'list':
                self.remove_list_from_scf(dist_name=o['dist_name'], list_name=o['list_name'],
                                          aicListEntity=aicListEntity, scope=scope)
            else:
                raise Exception("Error Unknown type: {}".format(o['type']))
