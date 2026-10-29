import os
import sys
import json
import subprocess
import shutil
from subprocess import CompletedProcess
from distutils.ccompiler import new_compiler

path_curr_file = os.path.abspath(__file__)
path_curr_dir = os.path.split(path_curr_file)[0]


def compile_the_stuff():
    compiler = new_compiler()
    os.chdir(path_curr_dir)
    compiler.compile(['XMLConverter/converter.c'])
    compiler.link_executable(
        [os.path.join('/', path_curr_dir, 'XMLConverter/converter.o')],
        os.path.join('/', path_curr_dir, 'XMLConverter/converter'))


def convert_to_json(xmlfile_path, jsondestdir_path=None):
    res2 = False
    res = None
    jsonfile_path = xmlfile_path.replace('.xml', '.json')
    if os.path.exists(jsonfile_path):
        shutil.os.remove(jsonfile_path)
        if not os.path.exists(jsonfile_path):
            print("previous JSON file removed successfully, or just not there")
    xmlfile_name = os.path.basename(xmlfile_path)
    jsonfile_name = xmlfile_name.replace('.xml', '.json')
    res = subprocess.run([os.path.join('/', path_curr_dir, 'XMLConverter/converter'), xmlfile_path])
    if os.path.exists(jsonfile_path):
        print("JSON file created successfully")
        res2 = True
        if jsondestdir_path:
            shutil.move(jsonfile_path, "{}/{}".format(jsondestdir_path, jsonfile_name))
    if isinstance(res, CompletedProcess):
        isOk = "OK" if res.returncode == 0 else "FAILED"
        print("Conversion {}".format(isOk))
    return res, res2


def print_indent(level, file):
    for i in range(level):
        if file:
            print('  ', end='', file=file)
        else:
            print('  ')


def print_toxmlfile(obj, level, filepath=None):
    print_indent(level, filepath)
    print_tofile_ornot('<%s' % obj['type'], file=filepath, noend=True)
    if obj['attributes'] is not None:
        for attr, val in obj['attributes'].items():
            print_tofile_ornot(' %s="%s"' % (attr, val), file=filepath, noend=True)
    if (obj['value'] is None) and (('elements' not in obj) or (obj['elements'] is None)
                                   or (len(obj['elements']) < 1)):
        print_tofile_ornot("/>", file=filepath)
    else:
        print_tofile_ornot('>', file=filepath, noend=True)
        if obj['type'] == 'list':
            print_tofile_ornot('', file=filepath)
            for item in obj['value']:
                if type(item) == list:
                    print_indent(level+1, file=filepath)
                    print_tofile_ornot("<item>", file=filepath)
                    for elt in item:
                        print_toxmlfile(elt, level+2, filepath=filepath)
                    print_indent(level+1, file=filepath)
                    print_tofile_ornot("</item>", file=filepath)
                elif type(item) == str:
                    print_indent(level+1, file=filepath)
                    print_tofile_ornot(item['value'], file=filepath)
                else:
                    print_toxmlfile(item, level+1, filepath=filepath)
            print_indent(level, file=filepath)
            print_tofile_ornot('</list>', file=filepath)
        elif obj['type'] == 'p':
            print_tofile_ornot('%s</p>' % obj['value'], file=filepath)
        else:
            print_tofile_ornot('', file=filepath)
            if obj['value'] is not None:
                print_tofile_ornot(obj['value'], file=filepath)
            for elt in obj['elements']:
                print_toxmlfile(elt, level+1, filepath=filepath)
            print_indent(level, file=filepath)
            print_tofile_ornot('</%s>' % obj['type'], file=filepath)


def print_tofile_ornot(mytext, file=None, noend=False):
    if file:
        print(mytext, end='', file=file) if noend else print(mytext, file=file)
    else:
        print(mytext)


def convert_xml(json_filename_toload="XMLConverter/vendor_1AE512BF.json"):
    compile_the_stuff()
    res1, res2 = convert_to_json(json_filename_toload.replace("json", "xml"))
    return res1, res2


def load_jsondata(json_filename_toload="XMLConverter/vendor_1AE512BF.json"):
    print("File {} exits: {}".format(json_filename_toload, os.path.exists(json_filename_toload)))
    with open(json_filename_toload, encoding='utf-8-sig', errors='ignore') as json_data:
        if json_data:
            print("DATA: {}".format(json_data))
            data_dict = json.loads(str(json_data.read()), strict=False)
    data_xml = data_dict['contents']
    return data_xml


def save_data_to_xmlfile(data_xml, file_path):
    with open(file_path, 'w') as xml_data_file:
        print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", file=xml_data_file)
        print_toxmlfile(data_xml, 0, filepath=xml_data_file)


if __name__ == "__main__":
    convert_xml()
    dataxml = load_jsondata()
