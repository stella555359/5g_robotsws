import xml.etree.ElementTree as ET
import json


def get_managed_objects(root):
    """Konwertuje managedObject na słownik, obsługując przestrzenie nazw i zagnieżdżone listy."""
    ns = {'ns': root.tag.split("}")[0][1:]} if "}" in root.tag else {}
    managed_objects = {}

    for mo in root.findall(".//ns:managedObject", namespaces=ns):
        mo_data = {attr: mo.attrib[attr] for attr in mo.attrib}
        mo_data['params'] = {}

        for param in mo.findall("ns:p", namespaces=ns):
            mo_data['params'][param.attrib['name']] = param.text

        for list_element in mo.findall("ns:list", namespaces=ns):
            list_name = list_element.attrib['name']
            items = []
            for item in list_element.findall("ns:item", namespaces=ns):
                item_data = {p.attrib['name']: p.text for p in item.findall("ns:p", namespaces=ns)}
                items.append(item_data)
            mo_data['params'][list_name] = (
                items if items
                else [p.text for p in list_element.findall("ns:p", namespaces=ns)]
            )

        managed_objects[mo.attrib.get("distName", "")] = mo_data
    return managed_objects


def compare_xml(xml1, xml2):
    """Porównuje dwa pliki XML i zwraca różnice w JSON"""
    tree1 = ET.parse(xml1)
    tree2 = ET.parse(xml2)

    dict1 = get_managed_objects(tree1.getroot())
    dict2 = get_managed_objects(tree2.getroot())

    changes = []

    for key in dict1:
        if key in dict2:
            diff = []
            for param, value in dict1[key]['params'].items():
                if param in dict2[key]['params'] and dict1[key]['params'][param] != dict2[key]['params'][param]:
                    diff.append({
                        "parameterName": param,
                        "value": dict2[key]['params'][param],
                        "operation": "update"
                    })
            if diff:
                changes.append({
                    "distName": key,
                    "operation": "update",
                    "parameters": diff
                })
        else:
            changes.append({
                "distName": key,
                "operation": "delete",
                "parameters": []
            })

    for key in dict2:
        if key not in dict1:
            new_params = [
                {"parameterName": param, "value": value, "operation": "update"}  # Zmiana z "create" na "update"
                for param, value in dict2[key]['params'].items()
            ]
            changes.append({
                "distName": key,
                "operation": "create",
                "parameters": new_params
            })

    delta_json = json.dumps(changes, indent=4, ensure_ascii=False)
    with open("delta.json", "w", encoding="utf-8") as f:
        f.write(delta_json)

    return delta_json


xml_file1 = "old.xml"
xml_file2 = "new.xml"
delta_json = compare_xml(xml_file1, xml_file2)
print(delta_json)
