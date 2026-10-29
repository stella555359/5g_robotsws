import xmltodict
import re
from pprint import pprint, pformat


class ScfFilter(object):

    @staticmethod
    def load_scf_text(scf_text):
        list_origin_mo = xmltodict.parse(scf_text).get('raml', {}).get('cmData', {}).get('managedObject', {})
        list_mos = []
        for mo in list_origin_mo:
            mo_1 = {}
            for k, v in mo.items():
                if k == 'p':
                    p_list = v if type(v) is list else [v]
                    for p in p_list:
                        mo_1[p['@name']] = p.get('#text', '')
                elif k == 'list':
                    cur_list = v if type(v) is list else [v]
                    for list_item in cur_list:
                        if list_item.get('p'):
                            mo_1[list_item['@name']] = list_item.get('p')
                        elif list_item.get('item'):
                            mo_1[list_item['@name']] = []
                            obj_list = list_item.get('item') if type(list_item.get('item')) is list else [
                                list_item.get('item')]
                            for obj in obj_list:
                                p_list = obj.get('p') if type(obj.get('p')) is list else [obj.get('p')]
                                mo_1[list_item['@name']].append(dict([(p['@name'], p.get('#text')) for p in p_list]))
                        else:
                            mo_1[list_item['@name']] = list_item.get('item')
                else:
                    mo_1[k[1:] if k.startswith('@') else k] = v
            list_mos.append(mo_1)
        return list_mos

    @staticmethod
    def load_scf_path(scf_path):
        with open(scf_path, "r", encoding="utf-8") as f:
            return ScfFilter.load_scf_text(f.read())

    def __init__(self, mo_object=[]):
        if not mo_object:
            mo_object = []

        self._mo_list = [mo_object] if type(mo_object) is not list else mo_object
        self._mo_dict = None
        self._index = 0

    def loads(self, scf_text):
        self._mo_dict = None
        self._mo_list = ScfFilter.load_scf_text(scf_text)

    def load(self, scf_path):
        with open(scf_path, "r", encoding="utf-8") as f:
            self.loads(f.read())

    @staticmethod
    def __match_by_dollar_oper(mo_v, oper_k, match_v):
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
            else:
                mo_list.append(mo)

        return ScfFilter(mo_list)._mo_list

    def __check_filter_condition_pass(self, mo, k_f, v_f):

        if k_f.startswith('$'):
            down_filter_k = k_f.split('/')[-1]
            if not down_filter_k:
                return False
            down_filter = {down_filter_k: v_f}
            down_path_regex = r"(\.{1,2}(\w+|\*)*)"
            sf = ScfFilter(mo)
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

        if type(v_f) is str:
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
            A New ScfFilter object, which level is lower that the old one
        """
        mo_list = []

        for mo in self._mo_list:
            if type(mo) is dict:
                if not selector or selector == '*':
                    mo_list += mo.values()
                elif selector.startswith("$"):
                    tmp = dict([tuple(eval('list(mo.items())[{}]'.format(selector[1:])))])
                    if type(tmp) is list:
                        mo_list += tmp
                    else:
                        mo_list.append(tmp)
                else:
                    mo_list += [v_mo for k_mo, v_mo in mo.items()
                                if not selector or re.search(selector, k_mo)]
                if recursive:
                    mo_list += ScfFilter(mo_object=list(mo.values())).down(selector, filter_dict, recursive)

            elif type(mo) is list:
                if not selector or selector == '*':
                    mo_list += mo[:]
                elif selector.startswith("$"):
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
                    mo_list += ScfFilter(mo).down(selector, filter_dict, recursive)
            else:
                pass
        return ScfFilter(mo_list).filter(filter_dict)

    def __str__(self):
        return pformat(self._mo_list, indent=1, width=80, depth=None)

    def __expr__(self):
        return pformat(self._mo_list, indent=1, width=80, depth=None)

    def __len__(self):
        return len(self._mo_list)

    def __bool__(self):
        return bool(self._mo_list)

    def __iter__(self):
        return iter(self._mo_list)

    def __getitem__(self, index):
        if type(index) is slice or type(index) is int:
            return self._mo_list[index] if self._mo_list else None
        if type(index) is str and index.startswith("$.."):
            return self.down(index[len("$.."):], recursive=True)
        if type(index) is str and index.startswith("$."):
            return self.down(index[len("$."):], recursive=False)

        return self.down(index, recursive=False)

    def __add__(self, mo_object):
        if not mo_object:
            mo_object = []
        if type(mo_object) is ScfFilter:
            return ScfFilter(mo_object=self._mo_list + mo_object.MO_List)

        elif type(mo_object) is list:
            return ScfFilter(mo_object=self._mo_list + mo_object)

        else:
            return ScfFilter(mo_object=self._mo_list + [mo_object])
