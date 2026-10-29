import re
import os
import taf.converters.tshark as tshark


class tsharkConversion():
    def __init__(self, f):
        self.f = f

    def __call__(self, **kwargs):
        path = kwargs["path"]
        option = str(kwargs["option"])

        tshark.tshark().create_tshark_converter(name="tshark",
                                                file_path_pattern=path,
                                                options=option,
                                                output_extension=".txt")
        tshark.tshark().setup("tshark")
        tshark.tshark().convert("tshark")
        tshark.tshark().teardown("tshark")


class Tshark_Validation():
    def __init__(self):
        pass

    def Validate_Tshark(self, folder_path='', filter='', message='', field='',
                        value='', fetch='', search=''):
        filteredmsgs = []
        flag = False
        path = os.path.join(folder_path, "*.pcap")
        if fetch or search or message:
            tsharkfiles = self.__wireshark(path=path, option="-Vx ", name='')
            Convertedfiles = [os.path.join(folder_path, f)
                              for f in os.listdir(folder_path)
                              if os.path.isfile(os.path.join(folder_path, f))
                              and f.endswith('.txt')]
            for i in Convertedfiles:
                with open(i, "r") as f:
                    lines = f.read()
                    if fetch:
                        if "(" not in fetch:
                            fetch = (fetch.replace("(", "(")).replace(")", ")")
                        filteredmsgs.extend([i[1]
                                             for i in re.findall
                                             (fetch + r'.*(:|=)\s+(.*)\n',
                                              lines,
                                              re.IGNORECASE)])
                    elif search:
                        filteredmsgs.extend(re.findall(r'(.*'+search+'.*)',
                                                       lines,
                                                       re.IGNORECASE))
                    elif message:
                        for line in lines.splitlines():
                            if (message.lower() in str(line.lower())):
                                flag = True
                            if flag:
                                if field:
                                    regex = re.match(r'(.*?=\s+)' +
                                                     field.lower() +
                                                     r'(\s+.*? | \W*)\:\s+(.*'
                                                     + value.lower() + '.*)',
                                                     line.lower())
                                    if regex:
                                        if value.lower() in regex.group(3):
                                            filteredmsgs.append(regex.group(3))
                            elif "\n" in line:
                                flag = False
        else:
            tsharkfiles = self.__wireshark(path=path,
                                           option="-Y \""+filter+"\"")
            Convertedfilterfiles = [os.path.join(root, f) for root, dirs,
                                    files in os.walk(folder_path)
                                    for f in files if (f.endswith('.txt'))]
            for i in Convertedfilterfiles:
                with open(i, "rb") as f:
                    totallines = f.read()
                filteredmsgs.extend([i for i in totallines.splitlines() if i])
        return filteredmsgs

    @tsharkConversion
    def __wireshark(**kwargs):
        pass
