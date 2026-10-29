# ---------invocation:  python delta_scfc_generator.py {path_to_goldenconfig_file}\golden_config_file.xml
# {path_to_delta_file}\delta_name.xml

import os
import re
import shutil
import sys
import string
import collections
import re
from lxml import etree
from copy import deepcopy
inserted = []
modified = []


def create_gc_copy(targetfolder, gcpath, gccopyname):
    if not os.path.exists(targetfolder):
        os.makedirs(targetfolder)
    os.chdir(targetfolder)
    shutil.copyfile(gcpath, gccopyname)


class ParseXML:
    def __init__(self, filepath):
        self.filepath = filepath
        self.tree = None
        self.root = None
        self.attributes = None
        try:
            xmlfile = open(self.filepath, "rb")
            self.tree = etree.parse(xmlfile)
            xmlfile.close()
            self.root = self.tree.getroot()
            self.attributes = self.root.attrib
        except Exception as e:
            print(e)
            raise Exception("Opening file failed!")

    def write_xml_file(self, filepath):
        # print "writing to scfc copy"
        etree.indent(self.tree, space='  ', level=1)
        self.tree.write(filepath, xml_declaration=True, encoding="UTF-8")

    def get_ele_parent(self, element, level=1):
        for i in range(level):
            element = element.getparent()
            if element == self.root:
                return self.root
        return element

    def get_ele_tag(self, element):
        return element.tag

    def get_element(self, tag, ele="ALL"):
        if "ALL" == ele:
            scope = self.root.iter()
        else:
            scope = ele.iter()
        for i in scope:
            if tag in i.tag:
                return i
        raise Exception("Can't find tag name as " + tag + "in " + self.filepath)

    def find_all_element_by_tag(self, tag):
        specific_ele = []
        for i in self.root.iter():
            if (0 <= i.tag.find(tag)) and (tag in i.tag):
                specific_ele.append(i)
        return specific_ele

    def find_ele_by_attribute(self, element, tag, attr_name, attr_text):
        # print "in find_ele_by_attribute for", tag, attr_name, attr_text
        specific_ele = []
        if attr_text is not None:

            for i in element.iter():
                if (0 <= i.tag.find(tag)) and (attr_text == i.get(attr_name)):
                    specific_ele.append(i)

        else:
            for i in element.iter():
                if (0 <= i.tag.find(tag)):
                    specific_ele.append(i)

        return specific_ele

    def find_ele_by_ele_text(self, element, tag, ele_text):
        specific_ele = []
        if ele_text is not None:

            for i in element.iter():
                if (0 <= i.tag.find(tag)) and (ele_text == i.text):
                    specific_ele.append(i)
        return specific_ele

    def has_children(self, ele):
        if len(ele) == 0:
            return 0
        else:
            return 1

    def get_ele_text_by_attr(self, element, attr_name, attr_value):
        for ele in element.iter():
            if attr_value == ele.get(attr_name):
                return ele, ele.text

    def set_ele_attr(self, ele, attr_name, attr_new_value):
        ele.set(attr_name, attr_new_value)

    def del_ele(self, moc, element):
        if self.has_children(element):
            for i in element.iterdescendants():
                print("Sub ", i.tag)
                to_del = self.find_ele_by_attribute(moc, i.tag, 'name', i.get('name'))
                parent = self.get_ele_parent(to_del[0])
                print("Parent", parent.tag)
                parent.remove(to_del[0])
                print("Del", to_del[0].tag)
                inserted.append(i.get('name'))
        else:
            parent = self.get_ele_parent(moc)
            parent.remove(moc)
            inserted.append(moc.get('distName'))

    def insert_moc(self, element):
        ele_attr = element.get('distName')
        ele_op = element.get('operation')
        ele_tag = element.tag
        attr_list = element.attrib
        moc = self.find_ele_by_attribute(self.root, ele_tag, 'distName', ele_attr)
        if ele_attr in inserted:
            print("element ", ele_attr, " is already inserted")
            return
        else:
            print("checking for ", ele_attr)
            if ele_op == "create":
                if not moc:
                    print("moc not found, will now be created")
                    self.insert_new_moc(element)
                else:
                    print("error, moc already found, cannot create", moc[0])
                    return

            elif ele_op == "update":
                if not moc:
                    print("error!moc not found, cannot be updated")
                    return
                else:
                    moc[0].set('operation', ele_op)
                    print("moc found!", moc[0].tag, moc[0].attrib)
                    self.modify_moc(moc[0], element, attr_list)  # moc in gc, element in delta
            elif ele_op == "delete":
                if not moc:
                    print("error!, moc to be deleted not found")
                    return
                else:
                    print("calling delete on the element")
                    self.del_ele(moc[0], element)

    def insert_new_moc(self, new_ele):
        node = etree.Element(new_ele.tag)
        node = deepcopy(new_ele)

        parent = self.get_ele_parent(new_ele)
        if parent.get('distName'):
            parent1 = self.find_ele_by_attribute(self.root, parent.tag, 'distName', parent.get('distName'))
        else:
            parent1 = self.find_ele_by_attribute(self.root, parent.tag, 'name', parent.get('name'))
        print("adding child", new_ele, "to parent", parent1[0].tag, parent.attrib)
        parent1[0].append(node)
        inserted.append(new_ele.get('distName'))

    def insert_new_item(self, new_item):
        node = etree.Element(new_item.tag)
        node = deepcopy(new_item)
        parent = new_item.getparent()
        index = parent.index(new_item)

        parent_item = self.find_ele_by_attribute(self.root, parent.tag, 'name', parent.get('name'))

        parent_item[0].insert(index, node)

        for i in node.iter():
            inserted.append(i)
            modified.append(i)
        for j in new_item.iter():
            modified.append(j)
            inserted.append(j)

    def find_for_no_attribute(self, moc_in_gc, id):
        for ele in moc_in_gc.iterdescendants():
            # first element of list where 2 list kind of instances are there, is always
            # unique, so search based on that ie id
            if ele.get('name'):
                if string.find(ele.get('name'), id) != -1:
                    return ele.getparent()
        return 0

    def modify_moc(self, moc, mod_ele, attr_list):
        add_par = dict()
        for subele in mod_ele.iterdescendants():
            # go through every subelement irrespective of parameter or list item
            if subele not in inserted:
                search_attrvalue = subele.get('name')
                search_tag = subele.tag
                i = 0
                present = self.find_ele_by_attribute(moc, search_tag, 'name', search_attrvalue)
                if present:
                    try:
                        while present[i] in modified:
                            # for cases with multiple instances of items, some to be updated and some to be added
                            i += 1
                            present[i].text = subele.text
                            modified.append(present[i])
                            modified.append(subele)
                    except Exception as e:
                        if subele not in inserted:
                            self.insert_new_item(subele)
                        continue
                else:
                    new_param = deepcopy(subele)
                    parent = subele.getparent()
                    if parent.get('distName'):
                        parent1 = self.find_ele_by_attribute(moc, parent.tag, 'distName', parent.get('distName'))
                        # how about having parent also, to get exactly one return value instead of a list
                        if parent1:
                            add_par[new_param] = parent1[0]
                        else:

                            if string.find(parent.tag, "item") != -1:

                                id = parent[0].get('name')
                                parent1 = self.find_for_no_attribute(moc, id)
                                if parent1:
                                    add_par[new_param] = parent1
                            else:
                                parent1 = self.find_ele_by_attribute(moc, parent.tag, 'name', parent.get('name'))
                                if parent1:
                                    add_par[new_param] = parent1[0]
                        for child in new_param.iterdescendants():
                            modified.append(child)
                        for child1 in subele.iterdescendants():
                            inserted.append(child1)
            for child, par in add_par.items():
                print("appending child ", child.attrib, "to parent ", par.tag, par.attrib, par)
                par.append(child)

            inserted.append(mod_ele.get('distName'))


def scf_generator(gcpath, delta_template):
    dirname = os.path.abspath(delta_template)
    deltafolder, name = os.path.split(os.path.abspath(delta_template))

    gcfolder, gcname = os.path.split(gcpath)

    gccopyname = "commissioning" + ".xml"
    create_gc_copy(deltafolder, gcpath, gccopyname)

    xml = ParseXML(gccopyname)

    moc = etree.parse(delta_template)
    mocroot = moc.getroot()

    del inserted[:]
    del modified[:]
    for ele in mocroot.getiterator():
        if ele.tag.find("managedObject") != -1:
            xml.insert_moc(ele)
    xml.write_xml_file(gccopyname)


if __name__ == "__main__":
    scf_generator(sys.argv[1], sys.argv[2])
