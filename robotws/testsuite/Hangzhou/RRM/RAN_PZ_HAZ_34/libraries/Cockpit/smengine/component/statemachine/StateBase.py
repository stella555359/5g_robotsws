import xml.etree.ElementTree as ET
import json
import re


class StateBase:
    # static parameters

    # methods
    def __init__(self):
        self.stateParent_ = None
        self.stateMachinePool_ = None
        self.stateMachine_ = None
        self.isDebugMode_ = False
        self.isReportMode_ = True
        self.isVariableMode_ = True
        self.stateMachineDebug_ = None
        self.fullPath_ = ""
        self.sdnStr_ = ""
        self.name_ = ""

    def getName(self):
        return self.name_

    def setName(self, pName):
        self.name_ = pName

    def getFullPath(self):
        return self.fullPath_

    def setFullPath(self, pFullPath):
        self.fullPath_ = pFullPath

    def isDebugMode(self):
        return self.isDebugMode_

    def setIsDebugMode(self, pIsDebugMode):
        self.isDebugMode_ = pIsDebugMode

    def isReportMode(self):
        return self.isReportMode_

    def setIsReportMode(self, pIsReportMode):
        self.isReportMode_ = pIsReportMode

    def isVariableMode(self):
        return self.isReportMode_

    def setIsVariableMode(self, pIsVariableMode):
        self.isVariableMode_ = pIsVariableMode

    def getParent(self):
        return self.stateParent_

    def setParent(self, pStateParent):
        self.stateParent_ = pStateParent

    def getStateMachine(self):
        return self.stateMachine_

    def setStateMachine(self, pStateMachine):
        self.stateMachine_ = pStateMachine

    def getStateMachinePool(self):
        return self.stateMachinePool_

    def setStateMachinePool(self, pStateMachinePool):
        self.stateMachinePool_ = pStateMachinePool

    def update(self, pStateMachine):
        self.stateMachine_ = pStateMachine

    def testForExec(self, varName):
        var = self.stateMachine_.getVar(varName)
        if var is None:
            return False
        else:
            return var.isPresent()

    def XMLExtractNextNodeToExplore(self, string):
        index = 0
        char = string[index]
        markup = ''
        nameType = ''
        name = ''
        stop = False
        while char != '_':
            markup += char
            index += 1
            char = string[index]
        index += 1
        char = string[index]
        while char != ':':
            nameType += char
            index += 1
            char = string[index]
        index += 1
        char = string[index]
        while char != ';' and not stop:
            name += char
            index += 1
            char = string[index]
            if char == '?':
                stop = True
                index -= 1
        index += 1
        return (markup, nameType, name, string[index:])

    def XMLFinder(self, node, fieldString, namespace):
        if (fieldString[0] == '?'):
            if len(fieldString) < 2:
                return node.text
            else:
                return node.get(fieldString[1:])
        else:
            if (fieldString[0] == ';'):
                for subNode in node:
                    result = self.XMLFinder(
                        subNode, fieldString[1:], namespace)
                    if result is not None:
                        return result
            elif fieldString.startswith('...'):
                markup, nameType, name, newFieldString = self.XMLExtractNextNodeToExplore(
                    fieldString[4:])
                for subNode in node.iter(namespace + markup):
                    if subNode.get(nameType) == name:
                        result = self.XMLFinder(
                            subNode, newFieldString, namespace)
                        if result is not None:
                            return result
            else:
                markup, nameType, name, newFieldString = self.XMLExtractNextNodeToExplore(
                    fieldString)
                for subNode in node.findall(namespace + markup):
                    if subNode.get(nameType) == name:
                        result = self.XMLFinder(
                            subNode, newFieldString, namespace)
                        if result is not None:
                            return result

    def JSONExtractNextNodeToExplore(self, string):
        index = 0
        char = string[index]
        name = ''
        while char != ';':
            name += char
            index += 1
            try:
                char = string[index]
            except IndexError:
                index -= 1
                break
        index += 1
        return (name, string[index:])

    def JSONFinder(self, node, fieldString):
        try:
            result = node[fieldString]
            return str(result)
        except Exception:
            if (fieldString[0] == ';'):
                for key, subNode in node.items():
                    result = self.JSONFinder(subNode, fieldString[1:])
                    if result is not None:
                        return result
            elif fieldString.startswith('...'):
                name, newFieldString = self.JSONExtractNextNodeToExplore(
                    fieldString[4:])
                if isinstance(node, dict):
                    for key, subNode in node.items():
                        if name in subNode:
                            if len(newFieldString) == 0:
                                return subNode[name]
                            else:
                                result = self.JSONFinder(
                                    subNode[name], newFieldString)
                                if result is not None:
                                    return result
                        else:
                            result = self.JSONFinder(subNode, fieldString)
                            if result is not None:
                                return result
            else:
                name, newFieldString = self.JSONExtractNextNodeToExplore(
                    fieldString)
                if len(newFieldString) == 0:
                    try:
                        return node[name]
                    except Exception:
                        pass
                else:
                    return self.JSONFinder(node[name], newFieldString)

    def XMLGetField(self, var, fieldString):
        root = ET.fromstring(var)
        if '{' in root.tag:
            namespace = root.tag.split('}')[0] + '}'
        else:
            namespace = ''
        result = self.XMLFinder(root, fieldString, namespace)
        return result

    def parse_object_pairs(self, pairs):
        seen = {}
        lst_keys = []
        lst_value = []
        for element in pairs:
            lst_value.append(element[1])
        for element in pairs:
            if element[0] not in seen:
                seen[element[0]] = [0, len(lst_keys)]
                lst_keys.append(element[0])
            else:
                seen[element[0]][0] += 1
                lst_keys.append(element[0] + '_' + str(seen[element[0]][0]))
                if seen[element[0]][0] is 1:
                    lst_keys[seen[element[0]][1]] = element[0] + '_0'
        new_pair = {}
        for i in range(0, len(lst_keys)):
            new_pair[lst_keys[i]] = lst_value[i]
        return new_pair

    def JSONGetField(self, var, fieldString):
        # print(var)
        JSONData = json.loads(var, object_pairs_hook=self.parse_object_pairs)
        try:
            # print(JSONData)
            result = self.JSONFinder(JSONData, fieldString)
        except Exception:
            result = None
        return result

    def configGetField(self, var, fieldString):
        index = var.find(fieldString)
        try:
            result = int(var[index:].split('=')[1].split(';')[0])
        except Exception:
            result = None
        return result

    def syslogGetField(self, var, fieldString):
        stringToSearch = fieldString.replace('_', '[_ ]')
        m = re.search(stringToSearch + "[^:]*:\\D*(\\d+)", var)
        if m:
            try:
                result = int(m.group(1))
            except ValueError:
                result = None
        else:
            result = None
        return result

    def getField(self, varName, fieldString):
        result = None
        var = self.stateMachine_.getVarValue(varName)
        if var is not None:
            if var.startswith('<'):
                result = self.XMLGetField(var, fieldString)
            elif var.startswith('{'):
                # print('Json')
                result = self.JSONGetField(var, fieldString)
            elif fieldString[0] == '0':
                result = self.configGetField(var, fieldString)
            else:
                result = self.syslogGetField(var, fieldString)
            if (result is not None):
                try:
                    result = int(result, 0)
                except ValueError:
                    try:
                        result = float(result)
                    except ValueError:
                        pass
        return result

    def decodeGetField(self, sentence):
        """this function take a decoded string value
        and then return the original string value based on the characters dict """
        characters = {
            "+": "\\m",
            "-": "\\l",
            "*": "\\mul",
            "/": "\\div",
            "=": "\\eq",
            " ": "\\sp",
            "(": "\\op",
            ")": "\\cp",
            "[": "\\obk",
            "]": "\\cbk",
            "{": "\\cbe",
            "}": "\\cbe",
            ";": "\\sc",
            "'": "\\sq",
            '"': "\\dq",
            '%': "\\pe",
            '#': "\\ha",
            '?': "\\in",
            '!': "\\ex",
            '<': "\\lt",
            '>': "\\gt",
            '\t': "\\ta",
            '1': "\\o",
            '2': "\\tw",
            '3': "\\th",
            '4': "\\fo",
            '5': "\\fi",
            '6': "\\si",
            '7': "\\se",
            '8': "\\e",
            '9': "\\n",
            '0': "\\z",
        }
        for key, value in characters.items():
            codingCharLength = len(value)
            for currentChar in range(len(sentence) - codingCharLength + 1):
                if sentence[currentChar:currentChar +
                            codingCharLength] == value:
                    sentence = sentence[0:currentChar] + key + \
                        sentence[currentChar + codingCharLength:]
        return (sentence)
