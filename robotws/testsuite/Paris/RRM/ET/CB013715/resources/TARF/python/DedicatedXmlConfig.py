import sys
from lxml.etree import SubElement  # Import SubElement from lxml.etree
import StringTool
from lxml import etree
import copy
import re

XML_CONFIG_PREFIX = "DedicatedXmlCfg"


def whoami():
    return sys._getframe(2).f_code.co_name


def myDebug(str, deep=0, debug=True):
    if debug:
        StringTool.datedConsole("{}.{:15}:{}".format(XML_CONFIG_PREFIX, whoami(), str), deep)


def myDebug_wo_prefix(str, deep=0, debug=True):
    if debug:
        StringTool.datedConsole("{:15}:{}".format(whoami(), str), deep)


class DedicatedXmlConfig(object):
    """
    This class encapsulates a modificator object, that offers capabilities to
    - start a modification session on an XML config file
    - perform some get/set on some particular elements in the XML tree
    - Add/remove some particular elements in the tree
    - end modification session (flush modifications in file)

    Main concepts for those manipulations are:
    - tree      : this is logical tree representing all elements in their arborescency
    - element   : this is a particular object in the tree. It has a tag (its name),
                  and some attributes.
                  In case, this is a final element, it also has a "text", which is the value of the field
    - path      : this is the full sequence of element tags to reach a particular element
                  Each element in the path is separated by a "/"

    Example : Let consider following part of XML
        <config version="19A_V6.0">
            <l1HwConfig>
                <l1Hw index="0">
                    <l1UlNodeId>21085</l1UlNodeId>
    - l1Hw          : path = /config/l1HwConfig/l1Hw,  tag=l1Hw,  attributes : index (<elt>['index'] is "0")
    - l1UlNodeId    : path = /config/l1HwConfig/l1Hw/l1UlNodeId, tag=l1UlNodeId, text=21085

    Syntax for path specification (https://docs.python.org/3/library/xml.etree.elementtree.html):
    - //            : all elements
    - //<tag>       : all elements which path ends with <tag>
    - <tag>[nn]     : Nth element in the list of elements matching <tag> (starting from 1)
    - <tag>[@<field>] : all elements matching tag anf which has a field as attribute
    - <tag>[@<field>="<val>"] : all elements matching tag and which has a field as attribute equal to value

    Examples : all these examples are equivalent, and return the same element
    - getElt            /config/l1HwConfig/l1Hw/l1UlNodeId
    - getElt            /config//l1UlNodeId
    - getElt            //l1UlNodeId
    - getElt            /config//l1Hw/l1UlNodeId
    - getElt            /config//l1Hw[1]/l1UlNodeId
    - getElt            /config//l1Hw[@index="0"]/l1UlNodeId
    """

    def __init__(self):
        default_parser = etree.XMLParser(attribute_defaults=False)
        etree.set_default_parser(default_parser)
        pass

    def __setModified(self, elt, val):
        """
        Internal service to modify a field and update isModified global flag
        This flag is used to know if at least one modification was done during a session
        :param elt: element to set
        :param val: value to set
        """
        prevVal = elt.text
        if prevVal != val:
            self.isModified = True
        elt.text = val

    def __addTextElt(self, elt, name, val):
        """
        Internal service to add a field in an element and update isModified global flag
        This flag is used to know if at least one modification was done during a session
        :param elt: element in which the text element has to be added
        :param name: Name of the text element to add
        :param val: value of the text element to add
        """
        newElt = etree.Element(name)
        if val:
            newElt.text = val
        elt.append(newElt)
        self.isModified = True

    def startSession(self, path):
        """
        Start a modification session on a WTS XML file
        It will parse it to build its whole tree
        """
        self.local_path = path
        self.isModified = False
        self.root = etree.parse(self.local_path)
        self.getRoot = self.root.getroot()

    def stopSession(self):
        """
        End a modification session on the WTS XML config file
        This session should have been previously begun by a startSession() call
        It will flush all modifications in the local file
        """
        if self.isModified:
            with open(self.local_path, 'wb') as f:
                f.write(etree.tostring(self.root))
        return self.isModified

    def stopSessionInNewFile(self, newFile):
        """
        End a modification session on the WTS XML config file
        This session should have been previously begun by a startSession() call
        It will flush all modifications in new specified file
        """
        if self.isModified:
            with open(newFile, 'wb') as f:
                f.write(etree.tostring(self.root))
        return newFile

    def getListAllElt(self, debug=True):
        """
        Return list of all elements in WTS XML config file tree
        path for each element will be traces in console ONLY if debug flag is set to True
        :param debug:debug flag for display
        :return: List of elements (lxml elements)
        """
        list = self.root.iter()
        if debug:
            for idx, e in enumerate(list):
                myDebug_wo_prefix("Path[{}]={}".format(idx, self.root.getpath(e)), debug=debug)
        return list

    def getListElt(self, path, debug=True):
        """
        Get list of elements in tree matching a particular path
        :param path: path to search
        :param debug: debug flag for display
        :return: list of elements
        """
        for idx, e in enumerate(self.root.xpath(path)):
            myDebug_wo_prefix("Pattern={} Path[{}]={}".format(path, idx, self.root.getpath(e)), debug=debug)
        return self.root.xpath(path)

    def getFirstElt(self, path, debug=True):
        """
        Get first element of a list of elements matching a particular path
        :param path: path to search
        :param debug: debug flag for display
        :return: first element of list (or None if list is empty)
        """
        listElt = self.root.xpath(path)
        if len(listElt) == 0:
            myDebug_wo_prefix("Pattern={} No element found".format(path), debug=debug)
            return None
        firstElt = listElt[0]
        myDebug_wo_prefix("Pattern={} Path={}".format(path, self.root.getpath(firstElt)), debug=debug)
        return firstElt

    def getFirstEltAttrValue(self, path, attr_name, debug=True):

        """
        Get the value of an attribute associated with the first element of the list
        of elements matching a particular path
        :param path: path to search
        :param attr_name: name of the attribute to search
        :param debug: debug flag for display
        :return: value associated with the attribute of the first element of list (or None if list is empty)
        """
        firstElt = self.getFirstElt(path, debug)
        attr_value = firstElt.attrib[attr_name]
        myDebug_wo_prefix("Pattern={} Path={}".format(path, self.root.getpath(firstElt)), debug=debug)
        return attr_value

    def getAttrValByIndex(self, path, attr_name, index=-1, debug=True):

        """
        Get the value of an attribute associated with element of the list of elements
        matching a particular path and index
        :param path: path to search eg CPRI-Config/CPRI-RP1-RE_List/RE/identity
        :param attr_name: name of the attribute to search eg for iphy:"serialno"
        :param index: if multiple objects, search by index [1]
        :param debug: debug flag for display
        :return: value associated with the attribute of the first element of list (or None if list is empty)
        """
        eltList = self.getListElt(path=path, debug=debug)
        attr_value = eltList[index].find("{}".format(attr_name))
        return attr_value.text

    def addTextElt(self, path, name, val, debug=True):
        """
        Add a field/value at the end of an element
        :param path: path of the element in which the field will be added
        :param name: name of the field
        :param val: value of the field
        :param debug: debug flag for display
        """
        elt = self.getElt(path, False)
        myDebug_wo_prefix("Target element={} field to add={}, value={})".format(path, name, val), debug=debug)
        self.__addTextElt(elt, name, val)

    def getFirstEltTagValue(self, path, tag, debug=True):

        """
        Get the value of a tag associated with the first element of the list
        of elements matching a particular path
        :param path: path to search
        :param tag: tag to search
        :param debug: debug flag for display
        :return: value associated with the tag of the first element of list (or None if list is empty)
        """

        firstElt = self.getFirstElt(path, debug)

        subElt = firstElt.find("{}".format(tag))

        myDebug("Pattern={} Path={}".format(path, self.root.getpath(subElt)), debug=debug)

        return subElt.text

    def getLastElt(self, path, debug=True):
        """
        Get last element of a list of elements matching a particular path
        :param path: path to search
        :param debug: debug flag for display
        :return: last element of list (or None if list is empty)
        """
        listElt = self.root.xpath(path)
        if len(listElt) == 0:
            myDebug_wo_prefix("Pattern={} No element found".format(path), debug=debug)
            return None
        lastElt = listElt[-1]
        myDebug_wo_prefix("Pattern={} Path[{}]".format(path, self.root.getpath(lastElt)), debug=debug)
        return lastElt

    def countElt(self, path, debug=True):
        """
        Count the number of element matching a particular path
        :param path: path to search
        :param debug: debug flag for display
        :return: number of element matching path
        """
        listElt = self.root.xpath(path)
        myDebug_wo_prefix("Pattern={} : Found {} elements matching".format(path, len(listElt), debug=debug))
        return len(listElt)

    def getElt(self, path, debug=True):
        """
        Retrieve an element matching a particular path, assuming it is unique
        if not the case (unexisting or several occurences), an exception is raised
        :param path: path to search
        :param debug: debug flag for display
        :return: element matching path
        """
        listElt = self.root.xpath(path)
        if len(listElt) == 1:
            myDebug_wo_prefix("Pattern={} Path={}".format(path, self.root.getpath(listElt[0])), debug=debug)
            return listElt[0]
        assert len(listElt) == 1, "Found {} element when searching [{}] in {}".format(
            len(listElt), path, self.local_path)

    def getEltUsingIndex(self, path, idx, debug=True):
        """
        Retrieve an element matching a particular path and a given occurence (1st, 2nd, ...) in the file
        If the element is not found an exception is raised
        :param path: path to search
        :param eltIdx: the element index (occurence)
        :param debug: debug flag for display
        :return: element matching path
        """
        myDebug_wo_prefix("getEltUsingIndex: path={} idx={}".format(path, idx), debug=debug)
        listElt = self.root.xpath(path)
        tmpIdx = int(idx)
        if len(listElt) < tmpIdx:
            msg = "Found {} elements while searching for {}th element corresponding to [{}] in {}"
            assert len(listElt) < idx, msg.format(len(listElt), idx, path, self.local_path)
        myDebug_wo_prefix("path={} element path={}".format(path, self.root.getpath(listElt[tmpIdx-1])), debug=debug)
        return listElt[tmpIdx-1]

    def getEltUsingBrotherId(self, path,  brotherName, brotherVal, debug=True):
        """
        Retrieve an element matching a particular path and having a brother satisfying the given ID
        if the element is not found an exception is raised
        :param path: path to search
        :param brotherName: the identifier of the brother element
        :param brotherVal: the value assiciated with the brother element
        :param debug: debug flag for display
        :return: element matching path
        """
        # get the name of the element to search (i;e. the latest field in the path)
        pathList = path.split("/")
        eltName = pathList[len(pathList)-1]
        myDebug_wo_prefix("getEltUsingBrotherId: eltName = {}".format(eltName), debug=debug)
        # get parent list
        parentList = self.root.xpath(path+"/..")
        # loop through the parent list and get the element whose child satisfied the "brotherId"
        for elt in parentList:
            myDebug_wo_prefix("getEltUsingBrotherId: elt = {}".format(elt))
            val = elt.find(brotherName).text
            if val == brotherVal:
                foundElt = elt.find(eltName)
                myDebug_wo_prefix("getEltUsingBrotherId: found element = {}".format(foundElt), debug=debug)
                return foundElt
        msg = "No element satisfying the search crieria (path={}, brotherName={}, brotherVal={}) could be found"
        assert False, msg.format(path,  brotherName, brotherVal)

    def getText(self, path, debug=True):
        """
        Retrieve value of a field matching a particular path, assuming it is unique
        if not the case (unexisting or several occurences), an exception is raised
        :param path: path to search
        :param debug: debug flag for display
        :return: value of the text
        """
        listElt = self.root.xpath(path)
        if len(listElt) == 1:
            myDebug_wo_prefix("Pattern={} Path={} Value=({})".format(
                path, self.root.getpath(listElt[0]), listElt[0].text), debug=debug)
            return listElt[0].text
        assert len(listElt) == 1, "Found {} element when searching [{}] in {}".format(
            len(listElt), path, self.local_path)

    def getPathElt(self, elt):
        """
        return full path of an element
        :param elt: element to treat
        :return: path of the element
        """
        return self.root.getpath(elt)

    def addEmptyElt(self, pathElt, name, debug=True):
        """
        Add a field/value at the end of an element
        :param pathElt: path of the element in which the field will be added
        :param name: name of the empty object
        :param debug: debug flag for display
        """
        try:
            elt = self.getElt(pathElt, False)
            if debug:
                print("Target element={} empty object to add={})".format(pathElt, name))
            self.__addTextElt(elt, name, None)
        except AssertionError as e:
            print(f"AssertionError occurred: {e}")
        except Exception as e:
            print(f"An unexpected error occurred: {e}")

    def setText(self, path, val, debug=True):
        """
        Set a field (knowing its path) to a particular value. Retrieved element is supposed to be unique
        Otherwise, an exception will be raised
        :param path: path to search
        :param val: value to set
        :param debug: debug flag for display
        """
        elt = self.getElt(path, False)
        myDebug_wo_prefix("Pattern={} Path={} : ({})==>({})".format(path, self.root.getpath(elt), elt.text, val),
                          debug=debug)
        self.__setModified(elt, val)

    def setTextUsingIndex(self, path, val, idx, debug=True):
        """
        Set a field, knowing its path and its position in the file (1st, 2nd, ...), to a particular value.
        :param path: path to search
        :param val: value to set
        :param idx: value to set
        :param debug: debug flag for display
        """
        myDebug_wo_prefix("setTextUsingIndex: path={} val ={} idx={}".format(path, val, idx), debug=debug)
        elt = self.getEltUsingIndex(path, idx, debug)
        self.__setModified(elt, val)

    def setTextUsingBrotherId(self, path, val, brotherName, brotherVal, debug=True):
        """
        Set a field, knowing its path and its brother identifier, to a particular value.
        :param path: path to search
        :param val: value to set
        :param brotherName: name of the brother element
        :param brotherVal: value associated with the brother
        :param debug: debug flag for display
        """
        myDebug_wo_prefix("setTextUsingBrotherId: path={} val ={} brotherName={} brotherVal={}".format(
            path, val, brotherName, brotherVal), debug=debug)
        elt = self.getEltUsingBrotherId(path, brotherName, brotherVal, debug)
        self.__setModified(elt, val)

    def setListEltText(self, path, val, debug=True):
        """
        Set fields matching a particular path. Here, search may lead to a list of element
        Then, all elements will be updated with same new value
        :param path: path to search
        :param val: value to set
        :param debug: debug flag for display
        """
        listElt = self.getListElt(path, False)
        for elt in listElt:
            myDebug_wo_prefix("Pattern={} Path={}: ({})==>({})".format(
                path, self.root.getpath(elt), elt.text, val), debug=debug)
            self.__setModified(elt, val)

    def setSubEltText(self, elt, subEltName, value, debug=True):
        """
        Set a field from an element, knowing its name. This sub element is supposed to be unique
        Otherwise, an exception will be raised
        :param elt: reference to parent element
        :param subEltName: name of sub element to search
        :param value: value to set
        :param debug: debug flag for display
        """
        listSubElt = elt.xpath(subEltName)
        if len(listSubElt) == 1:
            sub = listSubElt[0]
            lastValue = sub.text
            myDebug_wo_prefix("Path={} SubElt={} ({})==>({})".format(
                self.root.getpath(elt), subEltName, lastValue, value), debug=debug)
            self.__setModified(sub, value)
        assert len(listSubElt) == 1, "Found {} element when searching [{}] in elt {}".format(
            len(listSubElt), subEltName, self.root.getpath(elt))

    def addItemsFromList(self, pathElt, supportlist, debug=True):
        """
        Add a list of elements in the tree, knowing the path of the parent element
        :param path: path of the parent element in which the new elements will be added
        :param supportlist: list of dict containing elements to add
        :param debug: debug flag for display
        """
        if isinstance(supportlist, bool):
            # Handle the case where supportlist is a boolean value
            # Replace the following line with the appropriate code
            return None

        elt = self.getElt(pathElt, False)
        for item_dict in supportlist:
            item_element = SubElement(elt, 'item')  # Create 'item' element using lxml.etree.SubElement
            for key, val in item_dict.items():
                self.__addTextElt(item_element, key, val)

        # Convert to string
        xml_string = etree.tostring(elt, pretty_print=True)
        myDebug_wo_prefix("addItems path={}".format(self.root.getpath(elt), debug=debug))

        self.isModified = True
        return xml_string

    def addTree(self, path, debug=True):
        """
        Add a sub tree by copy from an existing one. From a path, it will : retrieve the last element of the list,
        get the parent of it, add by copy a new element to the parent, then update the index
        :param path: path of element to search and copy
        :param debug: debug flag for display
        :return: new added element
        """
        count = self.countElt(path, debug)
        lastElt = self.getElt('{}[@index="{}"]'.format(path, count-1), debug)
        parentElt = lastElt.getparent()
        myDebug_wo_prefix("Path={} First={} Parent={}".format(
            path, self.getPathElt(lastElt), self.getPathElt(parentElt)), debug=debug)
        newElt = copy.deepcopy(lastElt)
        parentElt.append(newElt)
        newElt.attrib['index'] = "{}".format(count)
        self.isModified = True
        return newElt

    def removeTree(self, path, debug=True):
        """
        remove from global tree an element knowing its path (assuming it is unique)
        :param path: path of element to remove
        :param debug: debug flag for display
        """
        elt = self.getElt(path, False)
        myDebug_wo_prefix("Pattern={} Path={} will be removed".format(path, self.root.getpath(elt)), debug=debug)
        elt.getparent().remove(elt)
        self.isModified = True

    def AddNewTree(self, path, add_xml, pos="after", debug=True):
        """
        Add a particular tree structures following the desired position.if we want to add the tree after the following
        siblings use pos="after" else if we want to precede use pos="before"
        :param path: path of element to search
        :add_xml: data content xml we want to paste
        :pos : choose where you want to paste your data(it can be "after" or "before")
        param
        """
        elt = self.getElt(path, False)
        if re.compile("after").search(pos):    # pos == "after":
            myDebug_wo_prefix("Adding nodes after this Pattern={} Path={}".format(path, self.root.getpath(elt)),
                              debug=debug)
            elt.addnext(etree.XML(add_xml))
        else:
            myDebug_wo_prefix("Adding nodes before this Pattern={} Path={}".format(path, self.root.getpath(elt)),
                              debug=debug)
            elt.addprevious(etree.XML(add_xml))
        self.isModified = True

    def cloneTree(self, path, debug=False):
        """
        Add a sub tree by copy from an existing one. From a path, it will : retrieve the last element of the list,
        get the parent of it, add by copy a new element to the parent, then update the index
        :param path: path of element to search and copy : eg:"CPRI-Config/CPRI-RP1-RE_List/RE"
        :param debug: debug flag for display
        :return: new added element
        """
        lastElt = self.getLastElt(path=path, debug=debug)
        parentElt = lastElt.getparent()
        newElt = copy.deepcopy(lastElt)
        parentElt.append(newElt)
        self.isModified = True
        return newElt

    def stopSessionafteraddingnewtree(self):
        """
        End a modification session on the WTS XML config file
        This session should have been previously begun by a startSession() call
        It will flush all modifications in the local file
        """
        if self.isModified:
            self.indent(self.getRoot)
            with open(self.local_path, 'wb') as f:
                f.write(etree.tostring(self.root, method='c14n2'))
        return self.isModified

    def indent(self, elem, level=0):
        i = "\n" + level*"  "
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "  "
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                self.indent(elem, level+1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i

    def findAllElt(self, path, xmlRoot=None, debug=True):
        """
        Get list of elements in tree matching a particular path
        The path is relative to the provided xmlRoot (i.e. not beginning with "/")
        :param path: path to search
        :param debug: debug flag for display
        :return: list of elements
        """

        if xmlRoot is None:
            xmlTree = self.root
        else:
            xmlTree = xmlRoot

        # myDebug(etree.tostring(xmlTree, pretty_print=True, xml_declaration=True), debug=debug)

        return xmlTree.findall(path)

    def getAttrValue(self, attr_name, xmlRoot, debug=True):

        """
        Get the value of an attribute associated with the rootj
        :param attr_name: name of the attribute to search
        :param debug: debug flag for display
        :return: value associated with the attribute of the first element of list (or None if list is empty)
        """

        xmlTree = xmlRoot
        attr_value = xmlTree.attrib[attr_name]
        return attr_value

    def getNodeValue(self, xmlRoot=None, debug=True):
        """
        Retrieve value of a field matching a particular path, assuming it is unique
        if not the case (unexisting or several occurences), an exception is raised
        :param path: path to search
        :param debug: debug flag for display
        :return: value of the text
        """

        if xmlRoot is None:
            xmlTree = self.root
        else:
            xmlTree = xmlRoot

        return xmlTree.text
