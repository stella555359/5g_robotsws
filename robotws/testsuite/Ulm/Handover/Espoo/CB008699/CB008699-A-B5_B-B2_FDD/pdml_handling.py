#!/usr/bin/python3

import xml.etree.ElementTree as ET
import re


def handle_children(element, searchfieldlist):

    searchlist = searchfieldlist[0].split("&&")
    tempsearchfieldlist = list(searchfieldlist)
    elementvalues = get_ements_child_parameters_with_values(element)

    found = check_fields(elementvalues, searchlist)
    if found:
        # children = element.getchildren()
        # py39 format:
        children = list(element)
        tempsearchfieldlist.pop(0)
        for child in children:
            if len(tempsearchfieldlist) == 0:
                return "AllFound"

            found = handle_children(child, tempsearchfieldlist)
            if found == "AllFound":
                break

    return found


def get_ements_child_parameters_with_values(element):
    # children = element.getchildren()
    # py39 format:
    children = list(element)
    attribute = []

    for child in children:
        name = child.get("showname")
        print(name)
        attribute.append(name)

    return attribute


def check_fields(elementvalues, searchlist):
    found = False

    foundlist = []
    for searchstring in searchlist:
        ret = check_if_seachstring_is_found_from_list(elementvalues, searchstring)
        if ret:
            print(str(searchstring)+" Found")
            foundlist.append(True)

    if len(foundlist) >= len(searchlist):
        print("All Parameters In List Found")
        found = True

    if not found:
        print("No Match Found")
    print("----------------------------")

    return found


def check_if_seachstring_is_found_from_list(elementvalues, searchstring):
    found = False

    # ${EMPTY} robot variable handling:
    if searchstring == "":
        return True

    try:
        for value in elementvalues:
            if re.search(searchstring, value):
                found = True
    except TypeError:
        pass

    return found


def find_msgpath_with_searchfields_from_pdml(PDML, msgpath, searchfields):
    print("Handling File "+str(PDML))
    print("With XPATH "+str(msgpath))
    print("Using Search Fields "+str(searchfields))

    tree = ET.parse(PDML)
    root = tree.getroot()
    elements = tree.findall(msgpath)
    print("Found "+str(len(elements))+" Elements")
    elementsfound = 0
    for element in elements:
        found = handle_children(element, searchfields)
        if found:
            print("Match Found")
            elementsfound = elementsfound + 1

    print("Match Found In " + str(elementsfound) + " Elements")

    return elementsfound
