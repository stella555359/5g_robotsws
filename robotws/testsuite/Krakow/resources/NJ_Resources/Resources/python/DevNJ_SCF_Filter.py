import json
import xmltodict
import re
from pprint import pprint, pformat


class DevNJ_SCF_Filter(object):
    """
    Main Function:
        This Library DevNJ_SCF_Filter provides functions:
        1. load SCF XML file or text and transfer to Json formatted data.
        2. load Json formatted data.
        3. Filter, Drill Down and projection on loaded Json formatted data.

    Version:
        | Author | Version | Delivery Date | Comments |
        | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

    """

    @staticmethod
    def load_scf_text(scf_text):
        """
        Main Function:
            static method load_scf_text
            Load a SCF XML text, and transfer to MO list

        Arguments:
            :param scf_text: Text content of SCF XML File

        Return Value:
            List of MOs

        Examples:
            with open(scf_path, "r") as f:
                mo_list = DevNJ_SCF_Filter.load_scf_text(f.read())

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        list_origin_mo = xmltodict.parse(scf_text).get('raml', {}).get('cmData', {}).get('managedObject', {})
        list_mos = []
        for mo in list_origin_mo:
            mo_1 = {}
            for k, v in mo.items():
                if k == 'p':
                    # serveral <p> or only 1 <p>
                    p_list = v if type(v) is list else [v]
                    for p in p_list:
                        mo_1[p['@name']] = p.get('#text', '')
                elif k == 'list':
                    # mo has several list or has only 1 list
                    cur_list = v if type(v) is list else [v]
                    for list_item in cur_list:
                        if list_item.get('p'):  # plain string list
                            mo_1[list_item['@name']] = list_item.get('p')
                        elif list_item.get('item'):  # object list with item
                            mo_1[list_item['@name']] = []
                            obj_list = list_item.get('item') if type(list_item.get('item')) is list else [
                                list_item.get('item')]
                            for obj in obj_list:
                                p_list = obj.get('p') if type(obj.get('p')) is list else [obj.get('p')]
                                mo_1[list_item['@name']].append(dict([(p['@name'], p['#text']) for p in p_list]))
                        else:
                            mo_1[list_item['@name']] = list_item.get('item')
                else:
                    mo_1[k[1:] if k.startswith('@') else k] = v
            list_mos.append(mo_1)
        return list_mos

    @staticmethod
    def load_scf_path(scf_path):
        """
        Main Function:
            static method load_scf_path
            Load a SCF XML file, and transfer to MO list

        Arguments:
            :param scf_path: Path of SCF XML File

        Return Value:
            List of MOs

        Examples:
            scf_path = "xxx.xml"
            mo_list = DevNJ_SCF_Filter.load_scf_path(scf_path)

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        with open(scf_path, "r", encoding="utf-8") as f:
            return DevNJ_SCF_Filter.load_scf_text(f.read())

    def __init__(self, mo_object=[]):
        """
        Main Function:
            Used to create a DevNJ_SCF_Filter Object

        Arguments:
            :param mo_object: A dict or list, for create the SCF_Path object as kernel list data

        Return Value:
            None

        Examples:
            Example 1:
            sf =  DevNJ_SCF_Filter()
            Example 2:
            channel_list = [...]
            sf_channel_list =  DevNJ_SCF_Filter(mo_object = channel_list)
            Example 3:
            channel_dict = {...}
            sf_channel_dict =  DevNJ_SCF_Filter(mo_object = channel_dict)

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """

        if not mo_object:
            mo_object = []

        self._mo_list = [mo_object] if type(mo_object) is not list else mo_object
        self._mo_dict = None
        self._index = 0

    def loads(self, scf_text):
        """
        Main Function:
            Load a Text content of SCF XML File and replace the kernel list data

        Arguments:
            :param scf_text: string of SCF XML File text

        Return Value:
            None

        Examples:
            with open("./test.xml", "r") as f:
                sf = DevNJ_SCF_Filter()
                sf.loads(f.read())

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """

        self._mo_dict = None
        self._mo_list = DevNJ_SCF_Filter.load_scf_text(scf_text)

    def load(self, scf_path):
        """
        Main Function:
            Load a SCF XML File and replace the kernel list data

        Arguments:
            :param scf_path: Path of SCF XML File

        Return Value:
            None

        Examples:
            sf = DevNJ_SCF_Filter()
            sf.load("./test.xml")

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        with open(scf_path, "r", encoding="utf-8") as f:
            self.loads(f.read())

    def load_from_object(self, mo_object):
        """
        Main Function:
            Load a dict or list, and replace the kernel list data, similar to __init__

        Arguments:
            :param mo_object: a list or dict

        Return Value:
            None

        Examples:
            sf = DevNJ_SCF_Filter()
            # load a list, will replace the kernel list data
            sf.load_from_object([...])
            # load a dict, will create the list with item {k,v}
            sf.load_from_object({...})

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        self._mo_dict = None
        if not mo_object:
            mo_object = []

        self._mo_list = [mo_object] if type(mo_object) is not list else mo_object

    def append_object(self, mo_object):
        """
        Main Function:
            Append a MO list or dict to the kernel list data

        Arguments:
            :param mo_object: a list or dict

        Return Value:
            None

        Examples:
            sf = DevNJ_SCF_Filter()
            sf.load_from_object([...])
            sf.append_object({...})

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        if not mo_object:
            mo_object = []
        if type(mo_object) is dict:
            mo_object = [{k: v} for k, v in mo_object.items()]
        self._mo_list += [mo_object] if type(mo_object) is not list else mo_object

    def dump(self, json_path):
        """
        Main Function:
            Dump kernal data (mo_list) to a json file

        Arguments:
            :param json_path: path of destination file

        Return Value:
            None

        Examples:
            sf = DevNJ_SCF_Filter()
            sf.load_from_object([...])
            sf.dump('./test.json')

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        with open(json_path, "w+", encoding="utf-8") as f:
            f.write(json.dumps(self._mo_list))

    def mo_dict(self, key_attr='distName', key_attr_deco_func=None):
        """
        Main Function:
            Create a dict from the kernel list data, from which pick the specified key attributes of each object
            out and create a list of dict.

        Arguments:
            :param key_attr: the key attribute inside the object, pick out as the object's key
            :param key_attr_deco_func: A function or lambda, to decorate the key_attr
        Return Value:
            Dict

        Examples:
            Example 1: Create dict without decorate function
            sf = DevNJ_SCF_Filter([{'distName':'111', 'b':'222', 'c':'333'}, {'distName':'777', 'b':'888', 'c':'999'}])
            pprint(sf.mo_dict(key_attr = "distName"))
            >>
            {'111': {'b': '222', 'c': '333', 'distName': '111'},
            '777': {'b': '888', 'c': '999', 'distName': '777'}}

            Example 2: Create dict without decorate function
            sf = DevNJ_SCF_Filter([{'distName':'dist_111', 'b':'222'}, {'distName':'dist_777', 'b':'888'}])
            pprint(sf.mo_dict(key_attr = "distName", key_attr_deco_func=lambda k: k.split('_')[-1]))
            >>
            {'111': {'b': '222', 'distName': 'dist_111'},
            '777': {'b': '888', 'distName': 'dist_777'}}

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        if key_attr_deco_func and not callable(key_attr_deco_func):
            raise Exception("Parameter attr_deco_func should be function or lambda expression")

        if self._mo_dict is None:
            self._mo_dict = {}

        for mo in self._mo_list:
            if type(mo) is dict and mo.get(key_attr):
                k = key_attr_deco_func(str(mo.get(key_attr))) if key_attr_deco_func else str(mo.get(key_attr))
                if k in self._mo_dict.keys():
                    raise Exception("key '{}' has already exist".format(k))
                self._mo_dict[k] = mo

        return self._mo_dict

    def mo_list(self):
        """
        mo_list method
        Just return the kernel list data _mo_list
        """

        """
        Main Function:
            Return the kernel list data _mo_list
            in case called by RobotFramework, property may not be used

        Return Value:
            List of MO

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        return self._mo_list

    @property
    def MO_List(self):
        """
        Main Function:
            Return the kernel list data _mo_list

        Return Value:
            List of MO

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        return self._mo_list

    @property
    def MO_Dict(self):
        """
        Main Function:
            Property, same as mo_dict() function

        Return Value:
            List of MO

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |

        """
        return self.mo_dict()

    def __match_by_dollar_oper(self, mo_v, oper_k, match_v):
        if oper_k == '$in':
            match_v = match_v if type(match_v) is list else [match_v]
            return str(mo_v) in [str(m_v) for m_v in match_v]
        if oper_k == '$!in':
            match_v = match_v if type(match_v) is list else [match_v]
            return str(mo_v) not in [str(m_v) for m_v in match_v]
        if oper_k == '$in_regex':
            regex_list = match_v if type(match_v) is list else [match_v]
            for regex in regex_list:
                if re.search(regex, mo_v):
                    return True
            else:
                return False
        if oper_k == '$!in_regex':
            regex_list = match_v if type(match_v) is list else [match_v]
            for regex in regex_list:
                if re.search(regex, mo_v):
                    return False
            else:
                return True
        if oper_k == '$regex':
            if type(match_v) is str:
                return re.search(match_v, mo_v)

        return None

    def filter(self, filter_dict={}):
        """
        Main Function:
            Most important method in this class.
            Used to filter the kernel list, according to given dictionary of filter conditions.

        Arguments:
            :param filter_dict: the dict of filter conditions, dict values is regex string
                filter_dict is a flexible condition combination.
                filter_dict's key is the attribute of the object
                filter_dict's value is the conditions to match

                The items in filter_dict are of "AND" relationship, rather than "OR"
                here given a complicate filter condition dict:

                filter_dict = {
                    # filter key is 'attr1', filter value is a regex '^ABC(.*)XYZ$'
                    # The filtered object's attr1 value should be starts with ABC and ends with XYZ

                    'attr1':'^ABC(.*)XYZ$',

                    # filter key is 'attr2', filter value is a dict {'$in':["abc", "def"]}
                    # '$in' is a match operator, means the attr2's value should be in the match value list
                    #  means, the filter object's attr2 value should be 1 or ["abc", "def" ]

                    'attr2': {'$in':["abc", "def"]},

                    # filter key is 'attr3', filter value is a dict {'$!in':["abc", "def"]}
                    # '$!in' is a match operator, means the attr3's value should NOT be in the match value list
                    #  means, the filter object's attr2 value should NOT be in ["abc", "def" ]

                    'attr3': {'$!in':["abc", "def"]},

                    # filter key is 'attr4', filter value is a dict {'$in_regex':["abc\\d+", r"^def"]}
                    # '$in_regex' is a match operator, means the attr4's value should be
                    #  at least matched by 1 regex in the list
                    #  means, if the filter object's attr4 value is "abc123" or "456def", it can match the requirement

                    'attr4': {'$in_regex':["^abc\\d+", "\\d+def$"]},

                    # filter key is 'attr5', filter value is a dict {'$!in_regex':["abc\\d+", "^def"]}
                    # '$!in_regex' is a match operator, means the attr5's value should NOT be
                    #  matched by any regex in the list
                    #  means, if the filter object's attr5 value is "abc123" or "456def",
                    #  it can NOT match the requirement

                    'attr5': {'$!in_regex':["^abc\\d+", "\\d+def$"]},

                    # ADVANCED FILTER, FILTER ON DESENDANTS' KEY
                    # Filter's key starts with '$", means drill down filter
                    #    String between '$' and '/' is the drill down path, in which '.' means drill down 1 level,
                    #       hile '..' means drill down recursively
                    #       word after each '.' or '..' is the key path, if empty or '*' means all key will drill down
                    # Final filter attribute is the word after '/',
                    # to check if the attribute's value match the filter value

                    # Take an object for examale, there is several ways to match the object,
                    #   by check the antAntlId is 3 or 4

                    # "ASI-1/ASI_R-1/RFC_R-1/RFCCELL_R-1/RFCHUBGROUP_R-1/RFCCHANNEL_R-8": {
                    #     "class": "com.nokia.asi:RFCCHANNEL_R",
                    #     "distName": "ASI-1/ASI_R-1/RFC_R-1/RFCCELL_R-1/RFCHUBGROUP_R-1/RFCCHANNEL_R-8",
                    #     "operation": "create",
                    #     "version": "ASI22R3_2206_100",
                    #     "antResources": [
                    #         {
                    #             "antAntlId": "4",
                    #             "antAntlRDN": "ASI-1/ASI_R-1/ANTMOD_R-2/ANTRFSM_R-1/ANTANTL_R-4",
                    #             "antPortId": "5",
                    #             "antRfsmId": "1",
                    #             "operationalState": "enabled"
                    #         }
                    #     ],
                    #     "configDN": "ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1/RFCCHANNEL-8",
                    #     "operationalState": "enabled",
                    #     "targetDirection": "RX"
                    # }

                    # filter key is '$.antResources./antAntlId'
                    #   means, drill down 1 level into antResources,
                    #   then drill down 1 level into all objects ('.*' or '.') in antResources list,
                    #   to check antAntlId can match the filter value
                    # filter value is a dict {'$in':[3,"4"]}

                    {"$.antResources.*/antAntlId": {'$in':[3,"4"]}}

                    # filter key is '$.*.*/antAntlId'
                    #   means, drill down 1 level into all objects,
                    #   then drill down 1 level into all objects ('.' or '.*'),
                    #   to check antAntlId can match the filter value
                    # filter value is a dict {'$in':[3,"4"]}

                    {"$.*./antAntlId": {'$in':[3,"4"]}

                    # filter key is '$../antAntlId': {'$in':[3,"4"]}}'
                    #   means, drill down recursively
                    #   to check desendants' antAntlId can match the filter value
                    # filter value is a dict {'$in':[3,"4"]}

                    {"$../antAntlId": {'$in':[3,"4"]}

        Return Value:
            A New DevNJ_SCF_Filter object, same level with old one

        Examples:

            scf_xml_file = './Configuration_asir_MRBTS-682041_SBTS22R3_ENB_9999_220311_000020_20220425-1445.xml'
            sf = DevNJ_SCF_Filter()
            sf.load(scf_xml_file)

            example 1: filter on class that ends with :CELL_R or :RFCCELL_R
            sf_new = sf.filter({'class':':(CELL_R|RFCCELL_R)$'})

            example 2: filter class endswith :CELL_R and distName endswith /CELL_R-1
            sf_new = sf.filter({'class':':CELL_R$', 'distName': '/CELL_R-1$'})

            example 3: filter class endswith :CELL_R and distName endswith /CELL_R-1 or /CELL_R-2
            sf_new = sf.filter({'class':':CELL_R$', 'distName':{'$in_regex':['/CELL_R-1$','/CELL_R-2$']}})

            example 4: filter class endswith :CELL_R and distName not endswith /CELL_R-1 or /CELL_R-2
            sf_new = sf.filter({'class':':CELL_R$', 'distName':{'$!in_regex':['/CELL_R-1$','/CELL_R-2$']}})

            example 5: filter class endswith :CELL_R and distName is accurately in list
                        ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']
            sf_new = sf.filter({'class':':CELL_R$',
                    'distName':{'$in':['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']}})

            example 6: filter class endswith :CELL_R and distName is accurately not in list
                ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']
            sf_new = sf.filter({'class':':CELL_R$',
                    'distName':{'$!in':['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']}})

            example 7: filter class endswith :CELL_R and id is between 3-5
            sf_new = sf.filter({'class':':CELL_R$', 'distName': '/CELL_R-[3-5]$'})

            example 8: filter class endswith :CELL_R and then filter the distName id is between 3-5
            sf_new = sf.filter({'class':':CELL_R$'}).filter({'distName': '/CELL_R-[3-5]$' })

            example 9: filter class endswith :CHANNEL_R,
                    and which antResources[].antAntlId is 3 or 4, with accurate level name
            sf_new = sf.filter({'class':':CHANNEL_R$'}).filter({"$.antResources./antAntlId": {'$in':[3,"4"]}})

            example 10: filter class endswith :CHANNEL_R, and which antResources[].antAntlId is 3 or 4, with only level
            sf_new = sf.filter({'class':':CHANNEL_R$'}).filter({"$.*./antAntlId": {'$in':[3,"4"]}})

            example 11: filter class endswith :CHANNEL_R,
                    and which antResources[].antAntlId is 1 or 2, with recursive level
            sf_new = sf.filter({'class':':CHANNEL_R$', '$../antAntlId': {'$in':[1,"2"]}})

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        for k_s in filter_dict.keys():
            if type(k_s) is not str or not k_s:
                raise Exception("filter key show be str")
        for v_s in filter_dict.values():
            if type(v_s) not in [str, int, dict]:
                raise Exception("filter value show be number or regex str")

        mo_list = []

        for mo in self._mo_list:
            for k_f, v_f in filter_dict.items():
                if not self.__check_filter_condition_pass(mo, k_f, v_f):
                    break
            else:  # all search conditions match
                mo_list.append(mo)

        return DevNJ_SCF_Filter(mo_list)

    def __check_filter_condition_pass(self, mo, k_f, v_f):

        if k_f.startswith('$'):
            down_filter_k = k_f.split('/')[-1]
            if not down_filter_k:
                return False
            down_filter = {down_filter_k: v_f}
            down_path_regex = r"(\.{1,2}(\w+|\*)*)"
            sf = DevNJ_SCF_Filter(mo)
            for down_str in [m[0] for m in re.findall(down_path_regex, k_f)]:
                sf = sf.down(down_str.split('.')[-1], recursive=down_str.startswith('..'))
            return sf.filter(down_filter)

        if type(mo) is not dict:
            return False
        if type(v_f) is dict:
            for oper_k, oper_v in v_f.items():
                if not self.__match_by_dollar_oper(mo.get(k_f, ''), oper_k, oper_v):
                    return False
            else:
                return True

        if type(v_f) is str:  # treat as regex
            return re.search(v_f, str(mo.get(k_f, '')))
        return mo.get(k_f, '') == str(v_f)

    def down(self, selector, filter_dict={}, recursive=True):
        """
        Main Function:
            Used to drill down the kernel list data

        Arguments:
            :param selector: regex str for matching dict's keys, or '$5' style string for locate in list
            :param filter_dict
            :param recursive: drill down recursively, if false, only down 1 level

        Return Value:
            A New DevNJ_SCF_Filter object, which level is lower that the old one

        Examples:
            User usually use sf["distName"] style to drill down, so see the example of __getitem__

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        mo_list = []

        for mo in self._mo_list:
            if type(mo) is dict:
                if not selector or selector == '*':
                    mo_list += mo.values()
                elif selector.startswith("$"):  # [$1] or [$3:-1]
                    tmp = dict([tuple(eval('list(mo.items())[{}]'.format(selector[1:])))])
                    if type(tmp) is list:
                        mo_list += tmp
                    else:
                        mo_list.append(tmp)
                else:
                    mo_list += [v_mo for k_mo, v_mo in mo.items()
                                if not selector or re.search(selector, k_mo)]
                if recursive:
                    mo_list += DevNJ_SCF_Filter(mo_object=list(mo.values())).down(selector, filter_dict, recursive)

            elif type(mo) is list:
                if not selector or selector == '*':  # all
                    mo_list += mo[:]
                elif selector.startswith("$"):  # [$1] or [$3:-1]
                    try:
                        tmp = eval('mo[{}]'.format(selector[1:]))
                    except Exception:
                        tmp = None
                        pass
                    if type(tmp) is list:
                        mo_list += tmp
                    elif tmp is not None:
                        mo_list.append(tmp)
                if recursive:
                    mo_list += DevNJ_SCF_Filter(mo).down(selector, filter_dict, recursive)
            else:
                pass
        return DevNJ_SCF_Filter(mo_list).filter(filter_dict)

    def project(self, display_keys=[], hidden_keys=[]):
        """
        Main Function:
            Used to display or hide attributes of the object in the list,
             display_keys and hidden_keys can not both specified

        Arguments:
            :param display_keys: attributes names that should be displayed
            :param hidden_keys:  attributes names that should be hidden

        Return Value:
            A new DevNJ_SCF_Filter object, same level with old one

        Examples:
            scf_xml_file = './Configuration_asir_MRBTS-682041_SBTS22R3_ENB_9999_220311_000020_20220425-1445.xml'
            sf = DevNJ_SCF_Filter()
            sf.load(scf_xml_file)
            # example 1: filter class endswith :CELL_R only display distNames and class
            sf_new = sf.filter({'class':':CELL_R$'}).project(display_keys=['distName','class'])

            # example 2: filter class endswith :CELL_R and hide distNames and class
            sf_new = sf.filter({'class':':CELL_R$'}).project(hidden_keys=['distName','class'])

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        if display_keys and hidden_keys:
            raise Exception("Cannot specify both display keys and hidden keys")
        if display_keys or hidden_keys:
            mo_list = json.loads(json.dumps(self._mo_list))
            for mo in mo_list:
                if type(mo) is dict:
                    mo_keys = list(mo.keys())
                    [mo.pop(k) for k in mo_keys if
                     (hidden_keys and k in hidden_keys) or (display_keys and k not in display_keys)]
            return DevNJ_SCF_Filter(mo_list, )
        else:
            return DevNJ_SCF_Filter(self._mo_list)

    def __str__(self):
        return pformat(self._mo_list, indent=1, width=80, depth=None)

    def __expr__(self):
        return pformat(self._mo_list, indent=1, width=80, depth=None)

    def __len__(self):
        return len(self._mo_list)

    def __bool__(self):
        return bool(self.MO_List)

    def __iter__(self):
        return iter(self._mo_list)

    def __getitem__(self, index):
        """
        Main Function:
            AKA. [] operator
            Used to iterate in the SCF_Path Object or drill down

        Arguments:
            :param index: list index or slice, drill down regex str or drill down operator str.
        Return Value:
            An object if list index or slice, otherwise a new drill-down DevNJ_SCF_Filter object

        Examples:
            scf_xml_file = './Configuration_asir_MRBTS-682041_SBTS22R3_ENB_9999_220311_000020_20220425-1445.xml'
            sf = DevNJ_SCF_Filter()
            sf.load(scf_xml_file)

            # example 1: filter class endswith :CELL_R and then locate item 2
            mo_object = sf.filter({'class':':CELL_R$'})[2]

            # example 2: filter class endswith :CELL_R and then locate item 2 to 5
            mo_object = sf.filter({'class':':CELL_R$'})[2:5]

            # example 3: filter class endswith :CELL_R
                        and drill down for picking all distNames as a new SCF_Path object
            mo_object = sf.filter({'class':':CELL_R$'})[2:5]

            # example 4: filter class endswith :CHANNEL_R
                        and drill down to antResources[0].antAntlRDN as new SCF_PATH object
            sf_new = sf.filter({'class':':CHANNEL_R$'})["antResources"]["$0"]["antAntlRDN"]

            # example 5: filter class endswith :CHANNEL_R
                        and drill down to antResources[1].antAntlRDN as new SCF_PATH object
            sf_new = sf.filter({'class':':CHANNEL_R$'})["antResources"]["$1"]["antAntlRDN"]

            # example 6: filter class endswith :CHANNEL_R
                        and drill down to antResources[0:2].antAntlRDN as new SCF_PATH object
            sf_new = sf.filter({'class':':CHANNEL_R$'})["antResources"]["$0:2"]["antAntlRDN"]

            # example 7: filter class endswith :CHANNEL_R
                        and drill down to antResources[*].antAntlRDN as new SCF_PATH object
            sf_new = sf.filter({'class':':CHANNEL_R$'})["antResources"][""]["antAntlRDN"]

            # example 8: filter class endswith :CHANNEL_R
                        and drill down recusively .. antAntlRDN as new SCF_PATH object
            sf_new = sf.filter({'class':':CHANNEL_R$'})["$..antAntlRDN"]

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        if type(index) is slice or type(index) is int:
            return self._mo_list[index] if self._mo_list else None
        if type(index) is str and index.startswith("$.."):
            return self.down(index[len("$.."):], recursive=True)
        if type(index) is str and index.startswith("$."):
            return self.down(index[len("$."):], recursive=False)

        return self.down(index, recursive=False)

    def __add__(self, mo_object):
        """
        Main Function:
            AKA. + operator
            Add 2 SCF_Path Object, by merging their kernel list data

        Return Value:
            DevNJ_SCF_Filter object

        Examples:
            scf_xml_file = './Configuration_asir_MRBTS-682041_SBTS22R3_ENB_9999_220311_000020_20220425-1445.xml'
            sf = DevNJ_SCF_Filter()
            sf.load(scf_xml_file)

            example 1: filter class endswith :CELL_R, filter class endswith :RFCCELL_R,
                    and add them to a new SCF_Path object
            sf_new = sf.filter({'class':':CELL_R$'}) + sf.filter({'class':':RFCCELL_R$'})

            example 2: filter class endswith :CELL_R, then self-add filter class endswith :RFCCELL_R
            sf_new = sf.filter({'class':':CELL_R$'})
            sf_new += sf.filter({'class':':RFCCELL_R$'})

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/04/26 | First draft version |
        """
        if not mo_object:
            mo_object = []
        if type(mo_object) is DevNJ_SCF_Filter:
            return DevNJ_SCF_Filter(mo_object=self._mo_list + mo_object.MO_List)

        elif type(mo_object) is list:
            return DevNJ_SCF_Filter(mo_object=self._mo_list + mo_object)

        else:
            return DevNJ_SCF_Filter(mo_object=self._mo_list + [mo_object])


if __name__ == '__main__':
    """
    Examples
    """
    scf_xml_file = './Configuration_asir_MRBTS-68203_SBTS22R3_ENB_9999_220406_000006_20220407-1838.xml'

    sf = DevNJ_SCF_Filter()
    sf.load(scf_xml_file)
    sf.dump('./test/test.json')

    case_title = "========== case {}: {} ============"

    case_num = 1
    case_name = "filter class endswith :CELLR or :RFCCELL_R"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':(CELL_R|RFCCELL_R)$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 2
    case_name = "filter class endswith :CELL_R and distName endswith /CELL_R-1"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$', 'distName': '/CELL_R-1$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 3
    case_name = "filter class endswith :CELL_R and distName endswith /CELL_R-1 or /CELL_R-2"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$', 'distName': {'$in_regex': ['/CELL_R-1$', '/CELL_R-2$']}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 4
    case_name = "filter class endswith :CELL_R and distName not endswith /CELL_R-1 or /CELL_R-2"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$', 'distName': {'$!in_regex': ['/CELL_R-1$', '/CELL_R-2$']}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 5
    case_name = "filter class endswith :CELL_R and distName is accurately " \
                "in list ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$',
                        'distName': {'$in': ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 6
    case_name = "filter class endswith :CELL_R and distName is accurately " \
                "not in list ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$',
                        'distName': {'$!in': ['ASI-1/ASI_R-1/BTS_R-2/CELL_R-4', 'ASI-1/ASI_R-1/BTS_R-2/CELL_R-5']}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 7
    case_name = "filter class endswith :CELL_R and id is between 3-5"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$', 'distName': '/CELL_R-[3-5]$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 8
    case_name = "filter class endswith :CELL_R and then filter the distName id is between 3-5"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$'}).filter({'distName': '/CELL_R-[3-5]$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 9
    case_name = "filter class endswith :CHANNEL_R, " \
                "and which antResources.antAntlId is 3 or 4, with accurate level name"
    sf_new = sf.filter({'class': ':CHANNEL_R$'}).filter({"$.antResources./antAntlId": {'$in': [3, "4"]}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 10
    case_name = "filter class endswith :CHANNEL_R, and which antResources.antAntlId is 3 or 4, with only level "
    sf_new = sf.filter({'class': ':CHANNEL_R$'}).filter({"$.*./antAntlId": {'$in': [3, "4"]}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 11
    case_name = "filter class endswith :CHANNEL_R, and which antResources.antAntlId is 1 or 2, with recursive level "
    sf_new = sf.filter({'class': ':CHANNEL_R$', '$../antAntlId': {'$in': [1, "2"]}})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 12
    case_name = "filter class endswith :CELL_R only display distNames and class"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$'}).project(display_keys=['distName', 'class'])
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 13
    case_name = "filter class endswith :CELL_R and hide distNames and class"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$'}).project(hidden_keys=['distName', 'class'])
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 14
    case_name = "filter class endswith :CELL_R and then locate item 2"
    print(case_title.format(case_num, case_name))
    mo_object = sf.filter({'class': ':CELL_R$'})[2]
    with open('./test/{}.json'.format(case_num), 'w+') as f:
        json.dump(mo_object, f)
    pprint(mo_object)

    case_num = 15
    case_name = "filter class endswith :CELL_R and then locate item 2 to 5"
    print(case_title.format(case_num, case_name))
    mo_object = sf.filter({'class': ':CELL_R$'})[2:5]
    with open('./test/{}.json'.format(case_num), 'w+') as f:
        json.dump(mo_object, f)
    pprint(mo_object)

    case_num = 16
    case_name = "filter class endswith :CELL_R and drill down for picking all distNames as a new SCF_Path object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CELL_R$'})['distName']
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 17
    case_name = "filter class endswith :CHANNEL_R and drill down to antResources[0].antAntlRDN as new SCF_PATH object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CHANNEL_R$'})["antResources"]["$0"]["antAntlRDN"]
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 18
    case_name = "filter class endswith :CHANNEL_R and drill down to antResources[1].antAntlRDN as new SCF_PATH object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CHANNEL_R$'})["antResources"]["$1"]["antAntlRDN"]
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 19
    case_name = "filter class endswith :CHANNEL_R " \
                "and drill down to antResources[0:2].antAntlRDN as new SCF_PATH object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CHANNEL_R$'})["antResources"]["$0:2"]["antAntlRDN"]
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 20
    case_name = "filter class endswith :CHANNEL_R and drill down to antResources[*].antAntlRDN as new SCF_PATH object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CHANNEL_R$'})["antResources"][""]["antAntlRDN"]
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 21
    case_name = "filter class endswith :CHANNEL_R and drill down recusively .. antAntlRDN as new SCF_PATH object"
    print(case_title.format(case_num, case_name))
    sf_new = sf.filter({'class': ':CHANNEL_R$'})["$..antAntlRDN"]
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 22
    case_name = "filter class endswith :CELL_R, filter class endswith :RFCCELL_R, " \
                "and add them to a new SCF_Path object"
    sf_new = sf.filter({'class': ':CELL_R$'}) + sf.filter({'class': ':RFCCELL_R$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 23
    case_name = "filter class endswith :CELL_R, then self-add filter class endswith :RFCCELL_R"
    sf_new = sf.filter({'class': ':CELL_R$'})
    sf_new += sf.filter({'class': ':RFCCELL_R$'})
    sf_new.dump('./test/{}.json'.format(case_num))
    print(sf_new)

    case_num = 24
    case_name = "Call mo_dict() with decorate function"
    sf = DevNJ_SCF_Filter([{'distName': 'dist_111', 'b': '222'}, {'distName': 'dist_777', 'b': '888'}])
    pprint(sf.mo_dict(key_attr="distName", key_attr_deco_func=lambda k: k.split('_')[-1]))
