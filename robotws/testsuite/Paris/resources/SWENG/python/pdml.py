
import subprocess
import StringTool
import xml.etree.ElementTree as ET


def extractItem(items, crit1, crit2, crit3, field1):
    result_list2 = []
    result_list3 = []
    res_dic_list = []
    xpath_relative_1 = f".//proto[@showname='{crit1}']"
    result_1 = items.findall(xpath_relative_1)
    nb_el = 0
    nb_f = 0

    for elementI in result_1:
        nb_el = nb_el + 1
        xpath_relative_2 = f".//field[@name='{crit2}']"
        f = elementI.find(xpath_relative_2)
        if f is not None:
            attribute_value = f.get(field1)
            nb_f = nb_f + 1
            result_list2.append(attribute_value)
        else:
            StringTool.datedConsole("extractItem crit2 {} not found".format(crit2))

        xpath_relative_3 = f".//field[@name='{crit3}']"
        f = elementI.find(xpath_relative_3)
        if f is not None:
            attribute_value = f.get(field1)
            result_list3.append(attribute_value)
        else:
            StringTool.datedConsole("extractItem crit3 {} not found".format(crit3))

    for i in range(len(result_list2)):
        new_dict = {crit2: result_list2[i], crit3: result_list3[i]}
        res_dic_list.append(new_dict)
    return res_dic_list


def extractSubCell(file, blocSubC1, critSubC2, critSubC3, valSubC3):
    file_path = file
    tree = ET.parse(file_path)
    root = tree.getroot()
    relative_xpath = f".//proto[@showname='{blocSubC1}']"
    result_1 = root.findall(relative_xpath)
    nb_el = 0
    nb_f = 0
    result_list = []
    foundS = False
    for element in result_1:
        nb_el = nb_el+1
        # check subscell
        xpath_relative_0 = f".//field[@name='{critSubC2}']"
        f = element.find(xpath_relative_0)

        if f is not None:
            attribute_value = f.get(critSubC3)
            if attribute_value == valSubC3:
                foundS = True
                nb_f = nb_f+1
                result_list.append(element)
            else:
                StringTool.datedConsole("extractSubCell critSubC3 {} not found".format(critSubC3))
        if foundS is False:
            StringTool.datedConsole("extractSubCell valSubC3 {} not found".format(valSubC3))

    return result_list


def feature50052_1(file, blocSubC1, critSubC2, critSubC3, valSubC3, crit1, crit2, crit3, field1):
    result_list = []
    output_list = []
    result_list = extractSubCell(file, blocSubC1, critSubC2, critSubC3, valSubC3)
    nb_f = 0
    for element in result_list:
        nb_f = nb_f+1
        res_dic_list_subCell0_itemX = []
        res_dic_list_subCell0_itemX = extractItem(element, crit1, crit2, crit3, field1)
        output_list.append(res_dic_list_subCell0_itemX)
    return output_list


def feature50052_2(file, crit1, crit2, crit3, crit4, field1):
    result_list2 = []
    result_list3 = []
    result_list4 = []
    res_dic_list = []
    tree = ET.parse(file)
    root = tree.getroot()
    relative_xpath = f".//proto[@showname='{crit1}']"
    result_1 = root.findall(relative_xpath)
    nb_el = 0
    nb_f = 0
    for element in result_1:
        nb_el = nb_el+1
        xpath_relative_0 = f".//field[@name='{crit2}']"
        f = element.find(xpath_relative_0)
        if f is not None:
            attribute_value = f.get(field1)
            result_list2.append(attribute_value)
        else:
            StringTool.datedConsole("extractItem crit2 {} not found".format(crit2))

        xpath_relative_1 = f".//field[@name='{crit3}']"
        f = element.find(xpath_relative_1)
        if f is not None:
            attribute_value = f.get(field1)
            result_list3.append(attribute_value)
        else:
            StringTool.datedConsole("extractItem crit3 {} not found".format(crit3))

        xpath_relative_1 = f".//field[@name='{crit4}']"
        f = element.find(xpath_relative_1)
        if f is not None:
            attribute_value = f.get(field1)
            result_list4.append(attribute_value)
        else:
            StringTool.datedConsole("extractItem crit4 {} not found".format(crit4))

    for i in range(len(result_list2)):
        new_dict = {crit2: result_list2[i], crit3: result_list3[i], crit4: result_list4[i]}
        res_dic_list.append(new_dict)
    return res_dic_list


def feature50052_2b(file, critList, field1):
    # example of critList
    #     'eCpriPucchResourceAllocationLowerDedicated (UlData_eCpriPucchResourceAllocationStructure_t)',
    #     'UlData_eCpriPucchResourceAllocationStructure_t.startPrb',
    #     'UlData_eCpriPucchResourceAllocationStructure_t.numPrb',
    #     'UlData_eCpriPucchResourceAllocationStructure_t.eCpriSectionId'
    res_dic_list = []
    tree = ET.parse(file)
    root = tree.getroot()

    relative_xpath = f".//proto[@showname='{critList[0]}']"
    result_1 = root.findall(relative_xpath)
    nb_el = 0
    for element in result_1:
        nb_el = nb_el+1
        for index in range(len(critList)):
            if index != 0:
                xpath_relative_0 = f".//field[@name='{critList[index]}']"
                f = element.find(xpath_relative_0)

                if f is not None:
                    attribute_value = f.get(field1)
                    new_dic = {critList[index]: attribute_value}
                    res_dic_list.append(new_dic)
                else:
                    StringTool.datedConsole("extractItem crit {} not found".format(critList[index]))
    return res_dic_list
