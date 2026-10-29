import inspect
import os
import TtiAnalysis as single_analist


def Make_myClass(path_to_json, events_list=None):
    """
    Used to create an instance of the MultipleTtiAnalysis class in RobotFramework interfaces to this mdoule.
    """
    myinstance = MultipleTtiAnalysis(path_to_json, events_list)
    return myinstance


class MultipleTtiAnalysis:
    def __init__(self, json_file=None, tti_events_list=None, load_the_stuff=False):
        self.tti_events_list = tti_events_list
        self.analysis_dict = {}
        self.json_file = json_file
        self.basepath = os.path.dirname(json_file) if json_file else None
        if load_the_stuff:
            self._load_the_stuff()

    def _load_the_stuff(self):
        if self.analysis_dict == {}:
            for tti in self.tti_events_list:
                print(f"creating analyzer for tti: {tti}")
                one_elem_list = [tti]
                self.analysis_dict[tti] = single_analist.TtiAnalysis(self.json_file, one_elem_list,
                                                                     load_the_stuff=True)

    def apply_analyzer_method_to_all_events(self, method_name, parameters, column_name_index):
        """
        Apply a specific analyzer method to all events.

        Args:
            method_name: The name of the method to be called in the TtiAnalysis class.
            parameters: The list of parameters for the method.
            column_name_index: The index of the column name in the parameters list.
        Returns:
            A dict containing the results of applying the method to each event. The key are the event names.
        """
        self._load_the_stuff()
        return self.apply_analyser_method_to_event_list(self.tti_events_list, method_name, parameters,
                                                        column_name_index)

    def apply_analyzer_method_to_event_list(self, event_list, method_name, parameters, column_name_index):
        """
        Apply a specific analyzer method to a list of events.

        Args:
            event_list: The list of events to apply the method to.
            method_name: The name of the method to be called in the TtiAnalysis class.
            parameters: The list of parameters for the method.
            column_name_index: The index of the column name in the parameters list.

        Returns:
            A dict containing the results of applying the method to each event. The key are the event names.
        """
        self._load_the_stuff()
        results = {}
        instance = self.analysis_dict[event_list[0]]
        # Create a dictionary of method names and method objects
        methods = {attr: value for attr, value in inspect.getmembers(instance) if inspect.ismethod(value)}
        if method_name not in methods.keys():
            print(f"WARNING Method {method_name} not found in instance {instance}")
            return results
        else:
            method = methods[method_name]
            print(f"Running method: {method}")
            param_names = inspect.getfullargspec(method).args
            print(f"with param_names: {param_names}")
        if 'column_name' not in param_names:
            print(f"WARNING Method {method_name} does not have a 'column_name' parameter.")
        else:
            for event in event_list:
                parameters[column_name_index] = f"{event}.{parameters[column_name_index]}"
                result = self.apply_analyzer_method_to_event(event, method_name, parameters)
                results[event] = result
        return results

    def apply_analyzer_method_to_event(self, event, method_name, parameters):
        """
        Apply a specific analyzer method to an event.

        Args:
            event: The event to apply the method to.
            method_name: The name of the method to be called in the TtiAnalysis class.
            parameters: The list of parameters for the method.

        Returns:
            The result of applying the method to the event.
        """
        self._load_the_stuff()
        result = self.analysis_dict[event].__getattribute__(method_name)(*parameters)
        return result

    def save_tocsv_for_all_events(self):
        """
        Save the dataframe content to a CSV file for each event.
        The file are saved in the same directory as the input JSON file.
        They are named as the event name with the prefix 'TTI_' and the suffix '.csv'.
        """
        self._load_the_stuff()
        res = []
        for tti in self.tti_events_list:
            filename = f"TTI_{tti}.csv"
            self.analysis_dict[tti].export_dataframe_to_csv(os.path.join(self.basepath, filename))
            res.append(filename)
        return res

    def save_tojson_for_all_events(self):
        """
        Save the dataframe content to a JSON file for each event.
        The file are saved in the same directory as the input JSON file.
        They are named as the event name with the prefix 'TTI_' and the suffix '.json'.
        """
        self._load_the_stuff()
        res = []
        for tti in self.tti_events_list:
            filename = f"TTI_{tti}.json"
            self.analysis_dict[tti].export_dataframe_to_json(os.path.join(self.basepath, filename))
            res.append(filename)
        return res
