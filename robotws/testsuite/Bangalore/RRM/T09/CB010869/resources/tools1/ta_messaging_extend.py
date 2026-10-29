from ta_messaging.message_verifiers import message_verifier
from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_abstract_core.message import MsgFieldsList
from robot.libraries.BuiltIn import BuiltIn


class ta_messaging_extend(object):

    def __init__(self):
        self._setup_messaging_flag = False
        self.messaging_obj = ''

    def _setup_ta_messaging(self):
        if not self._setup_messaging_flag:
            self._setup_messaging_flag = True
            self.messaging_obj = BuiltIn().get_library_instance('ta_messaging')

    def get_message(self, flow_alias, msg_alias):
        self._setup_ta_messaging()
        message = aliases_registry()[flow_alias].get_message(msg_alias)
        return message

    # def should_be_equal_payload(self, msg1, msg2):
    #     self._setup_ta_messaging()
    #     print("msg_payload is {}".format(msg1.hex['msg_payload']))
    #     assert msg1.hex['msg_payload'] == msg2.hex['msg_payload']
    #
    # def should_be_equal_under_key(self, msg1, msg2, msg_type):
    #     self._setup_ta_messaging()
    #     print("{} is {}".format(msg_type, msg1.get(msg_type)))
    #     assert msg1.get(msg_type) == msg2.get(msg_type)

    def message_should_be_same(self, msg1, msg2):
        self._setup_ta_messaging()
        msg_type = msg1.hex["msg_type"]
        assert msg1.hex['msg_payload'] == msg2.hex['msg_payload']
        assert msg1.get(msg_type) == msg2.get(msg_type)

    def verify_at_least_one_flow_occurs_as_expected(self, flow1_alias, flow2_alias):
        self._setup_ta_messaging()
        assert (self._is_flow_occured_as_expected(flow1_alias) or
                self._is_flow_occured_as_expected(flow2_alias)) is True

    def _is_flow_occured_as_expected(self, flow_alias):
        self._setup_ta_messaging()
        try:
            self.messaging_obj.flow_occurred_as_expected(alias=flow_alias)
            return True
        except Exception:
            return False

    def _sort_list(self, list_in):
        """
        sort list in two dimension.
        for example list_in = [[2, 3, 1], [6, 4]]
        list_out = [[1, 2, 3], [4, 6]]
        """
        list_out = []
        for value in list_in:
            # print("{} type is {}".format(value, type(value)))
            if isinstance(value, MsgFieldsList) or isinstance(value, list):
                value = [int(i) if "{}".format(i).isdigit() else i for i in value]
                value.sort()
                list_out.append(value)
            else:
                value = int(value) if "{}".format(value).isdigit() else value
                list_out.append(value)
        list_out.sort()
        return list_out

    def verify_unique_field_equals_values_in_message(self, flow_alias, msg_alias, *field_values):
        """
        field_values format: field=value11,value12...;value21,value22,...
        example:
               n1PUCCH-AN-CS-List-r10 {
               {
                0,
                1,
                3,
                5
               },
               {
                6,
                7,
                9,
                11
               }
              }
        verify unique field equals values in_message | flow_alias | msg_alias | n1PUCCH-AN-CS-List-r10=0,1,3,5;6,7,9,11
        """
        msg = self.get_message(flow_alias, msg_alias)
        # print("msg={}".format(msg))
        for field_value in field_values:
            field, exp_values_str = field_value.split("=")
            # sort actual values
            act_values = msg.get_value_by_unique_key(field)
            act_values_sorted = self._sort_list(act_values)
            # sort expected values
            if exp_values_str.count(";"):
                exp_values = []
                for each in exp_values_str.split(";"):
                    exp_values.append(each.split(","))
            else:
                exp_values = exp_values_str.split(",")
            exp_values_sorted = self._sort_list(exp_values)
            # actual list should be equal to expected list
            print("field={}, act_values_sorted={}".format(field, act_values_sorted))
            print("field={}, exp_values_sorted={}".format(field, exp_values_sorted))
            assert act_values_sorted == exp_values_sorted
