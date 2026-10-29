from builtins import object
import os
import sys
import re
import logging
import linux_cmds as linux
import luashark_tools as luashark

global ListOp


def isBracedWith(str, start, end):
    res = str.startswith(start) and str.endswith(end)
    return str.startswith(start) and str.endswith(end)


def unbrace(str):
    return str[1:-1]

# ======================================================================================


class OpOrFnDef(object):
    def __init__(self, str, inType, fn):
        self.str = str
        self.inType = inType
        self.fn = fn
        self.nbOperand = 2


class OpDef(OpOrFnDef):
    def __init__(self, str, inType, prio, fn):
        super(OpDef, self).__init__(str, inType, fn)
        self.prio = prio

    def isMorePrio(self, other):
        return self.prio >= other.prio


class FnDef(OpOrFnDef):
    def __init__(self, str, inType, nb, fn):
        super(FnDef, self).__init__(str, inType, fn)
        self.nbOperand = nb

# ======================================================================================


class Field(object):
    def __init__(self, exp):
        self.filter = filter
        self.exp = exp.strip()
        self.str = exp
        self.value = self.str
        self.decode(self.str)
        self.path = None
        self.errors = []
        self.check()

    def toInt(self, str):
        try:
            self.value = int(str)
            return True
        except Exception:
            return False

    def toHexa(self, str):
        try:
            self.value = int(str, 16)
            return True
        except Exception:
            return False

    def toFloat(self, str):
        try:
            self.value = float(str)
            return True
        except Exception:
            return False

    def decode(self, str):
        if self.toInt(str):
            self.type = "INT"
        elif self.toHexa(str):
            self.type = "HEX"
        elif self.toFloat(str):
            self.type = "FLT"
        else:
            self.type = "STR"

    def __str__(self):
        return self.exp

    def isOK(self):
        return len(self.errors) == 0

    def check(self):
        pass

    def checkChars(self, unallowed):
        for c in unallowed:
            if c in self.str:
                self.addError("Char '{}' not allowed for {}:[{}]".format(c, type(self).__name__, self.str))

    def addError(self, str):
        self.errors.append(str)

# ======================================================================================


class Op(Field):
    def __init__(self, str):
        super(Op, self).__init__(str)
        self.pos = -1
        self.opDef = OP_NONE
        deep = 0
        inStr = False
        for i, c in enumerate(self.str):
            if c == '(':
                deep = deep + 1
            elif c == ')':
                deep = deep - 1
            elif c == '\'':
                inStr = not inStr
            elif deep == 0 and not inStr:
                opDefTmp = self.getOpFromStr(self.str[i:-1])
                if opDefTmp is not OP_NONE and opDefTmp.isMorePrio(self.opDef):
                    self.opDef = opDefTmp
                    self.pos = i
        self.value = self.str = self.opDef.str

    def __str__(self):
        return self.opDef.str

    def getOpFromStr(self, str):
        for opDef in ListOpDef:
            if str.startswith(opDef.str):
                return opDef
        return OP_NONE

    def left(self):
        return self.exp[0:self.pos]

    def right(self):
        return self.exp[self.pos+len(self.opDef.str):]

# ======================================================================================


class Fn(Field):
    def __init__(self, str):
        super(Fn, self).__init__(str)
        self.pos = -1
        self.fnDef = None
        deep = 0
        inStr = False
        for i, c in enumerate(self.str):
            if c == '(':
                deep = deep + 1
            elif c == ')':
                deep = deep - 1
            elif c == '\'':
                inStr = not inStr
            elif deep == 0 and not inStr:
                self.fnDef = self.getFnFromStr(self.str[i:-1])
                if self.fnDef is not None:
                    self.pos = i
            if self.pos >= 0:
                break
        if self.fnDef is not None:
            self.value = self.str = self.fnDef.str
            self.computeMembers(i + len(self.fnDef.str) + 1)
            # for member in self.members:linux.console("MEMBER:{}".format(member))
            if len(self.members) != self.fnDef.nbOperand:
                self.addError("ERROR:Function {}:{} arguments found instead of {}".format(
                    self.fnDef.str, len(self.members), self.fnDef.nbOperand))

    def computeMembers(self, pos):
        str = self.exp[pos:]
        deep = 0
        inStr = False
        self.members = []
        curMember = ""
        for i, c in enumerate(str):
            toTake = True
            if c == '(':
                deep = deep + 1
            elif c == ')':
                deep = deep - 1
                if deep == -1:
                    break
            elif c == '\'':
                inStr = not inStr
            elif deep == 0:
                if c == ',' and not inStr:
                    self.members.append(curMember)
                    curMember = ""
                    toTake = False
            if toTake:
                curMember = "{}{}".format(curMember, c)
        if len(curMember) > 0:
            self.members.append(curMember)

    def __str__(self):
        return self.fnDef.str

    def getFnFromStr(self, str):
        for fnDef in ListFnDef:
            if str.startswith("{}(".format(fnDef.str)):
                return fnDef
        return None

# ======================================================================================


class PathExp(Field):
    def __init__(self, str):
        super(PathExp, self).__init__(str)

    def __str__(self):
        return super(PathExp, self).__str__()

    def check(self):
        # ALL :()[]{}<>%+-*/|\=_.,;:!?^$@#~&"'`
        # OK  :()[]{}<>%+-*/|\=_.,;:!?^$@#~&"'`
        # KO  :()    <>%   /| =  ,;:!   @#~&"'`
        self.checkChars(" ()<>%/|=,;:!@#~&\"'`")

# ======================================================================================


class Scalar(Field):
    def __init__(self, str):
        super(Scalar, self).__init__(str)

    def __str__(self):
        return super(Scalar, self).__str__()

    def check(self):
        # ALL :()[]{}<>%+-*/|\=_.,;:!?^$@#~&"'`
        # OK  :()[]{}<>%+-*/|\=_.,;:!?^$@#~&"'`
        # KO  :()[]{}<>%+ */| =   ; !?^$@#~&"'`
        self.checkChars(" ()[]{}<>%+*/|=;!?^$@#~&\"'`")

# ======================================================================================


class Bool(Field):
    def __init__(self, value=False):
        super(Bool, self).__init__("Bool")
        self.value = value
        self.type = "BOL"

    def __str__(self):
        return super(Bool, self).__str__()

# ======================================================================================


class Filter(object):
    def __init__(self, filterStr):
        self.name = filterStr
        self.stack = []
        self.errors = []
        self.debug = False
        self.addToStack(filterStr)
        self.postCheckStack()
        linux.info(self.stackToStr(self.stack))
        if self.isKO():
            linux.fatal(self.errorsToStr())

    def errorsToStr(self):
        str = ""
        for error in self.errors:
            if len(str) > 0:
                str = str + "\n"
            str = "{}\tERROR:{}".format(str, error)
        return str

    def stackToStr(self, stack):
        str = "\tSTACK:"
        for idx, elt in enumerate(stack):
            pathStr = ""
            valueStr = "{}".format(elt.value)
            eltExp = "{}".format(elt)
            if type(elt) is PathExp:
                pathStr = " Path:{}".format(elt.path)
            str = "{}\n\t  {:3} Type:{:7} Val:{:15} {:3}:{:15} Exp:{:20}{}".\
                format(str, idx+1, type(elt).__name__, valueStr, elt.type, elt.str, eltExp, pathStr)
        return str

    def isKO(self):
        return len(self.errors) != 0

    def isOK(self):
        return len(self.errors) == 0

    def addToStack(self, str):
        # Step 1 : empty string
        if len(str) == 0:
            return
        str = str.strip()
        # Step 2 : Intercept negative numbers
        attemptScalar = Scalar(str)
        if attemptScalar.isOK() and attemptScalar.type != "STR":
            self.addEltToStack(attemptScalar)
            return
        # Step 3 : attempting to find an operator
        op = Op(str)
        if op.opDef is not OP_NONE:
            self.addToStack(op.left())
            self.addToStack(op.right())
            self.addEltToStack(op)
            return
        # Step 4 : attempting to find function
        fn = Fn(str)
        if fn.fnDef is not None:
            for i in range(fn.fnDef.nbOperand):
                self.addToStack(fn.members[i])
            self.addEltToStack(fn)
            return
        # Step 5 : remove unuseful parenthesis
        if isBracedWith(str, '(', ')'):
            self.addToStack(unbrace(str))
            return
        # Step 6 : Is is a path expression
        if isBracedWith(str, '\'', '\''):
            self.addEltToStack(PathExp(unbrace(str)))
            return
        # Step 7 : is it a scalar
        attemptScalar = Scalar(str)
        if attemptScalar.isOK():
            self.addEltToStack(attemptScalar)
        else:
            self.addEltToStack(Field(str))

    def addEltToStack(self, field):
        self.stack.append(field)
        for error in field.errors:
            self.errors.append(error)

    def postCheckStack(self):
        for elt in self.stack:
            if type(elt) is Field:
                self.errors.append("Stack ERROR:Field [{}] is not a scalar".format(elt.str))

    def apply(self, listSubPacket):
        if self.debug:
            self.traceDebug(self.stackToStr(self.stack))
        newListSubPacket = []
        for subPacket in listSubPacket:
            if self.isPacketMatch(subPacket):
                newListSubPacket.append(subPacket)
            else:
                if self.debug and len(self.errors) > 0:
                    self.traceDebug(self.errorsToStr())
                self.errors = []
        return newListSubPacket

    def isPacketMatch(self, subPacket):
        if self.debug:
            self.traceDebug("  START: Packet={}: FILTER={}".format(subPacket.namedPacket, self.name))
        # First collect paths in packet, and associated values
        for field in self.stack:
            if type(field) is PathExp:
                listPathFound = subPacket.namedPacket.packet.paths(field.exp)
                if len(listPathFound) != 1:
                    self.errors.append("Packet:{} {} field found for PathExp:{}".
                                       format(subPacket.namedPacket, len(listPathFound), field.exp))
                    return False
                pathFound = listPathFound[0]
                listField = subPacket.namedPacket.packet.xpath(pathFound)
                value = luashark.get_value_from_kind(listField[0], "show")
                field.str = value
                field.decode(field.str)
                field.path = pathFound
        # Now, computing stack
        res = True
        if len(self.stack) > 0:
            # self.stack[:] is for copy() (for python2.7 compliancy)
            res = self.computeStack(self.stack[:])
        if self.debug:
            self.traceDebug("  END  : Packet={}: RES={}".format(subPacket.namedPacket, res))
        return res

    def initStub(self, stub):
        self.stub = stub

    def computeStack(self, stack):
        # Treating last element of the stack
        if self.debug:
            self.traceDebug(self.stackToStr(stack))
        if len(stack) == 1:
            if type(stack[0]) is Bool:
                return stack[0].value
            else:
                self.errors.append("Stack ERROR:remaining {} at stack computation end".format(type(stack[0])))
                return False
        # More than one element in the stack
        indOpOrFn = self.getFirstOp(stack)
        if indOpOrFn is None:
            self.errors.append("Stack ERROR:remaining {} fields and no more operator".format(len(stack)))
            return False
        if type(stack[indOpOrFn]) is Op:
            stack = self.applyOp(stack, indOpOrFn)
        else:
            stack = self.applyFn(stack, indOpOrFn)
        if self.isOK():
            return self.computeStack(stack)
        return False

    def getFirstOp(self, stack):
        for i, field in enumerate(stack):
            if type(field) is Op or type(field) is Fn:
                return i
        return None

    def applyOp(self, stack, indOp):
        op = stack[indOp]
        if indOp < 2:
            self.errors.append("Stack ERROR:Unable to apply Operator {}:{} operand found instead of {}".
                               format(stack[indOp].opDef.str, indOp, op.opDef.nbOperand))
            return stack
        left = stack[indOp-2]
        right = stack[indOp-1]
        if not self.isOperandTypeMatchsWithOp("right", right, op.opDef):
            return stack
        if not self.isOperandTypeMatchsWithOp("left", left, op.opDef):
            return stack
        stack[indOp] = op.opDef.fn(left, right)
        stack.pop(indOp-2)
        stack.pop(indOp-2)
        return stack

    def applyFn(self, stack, indFn):
        fn = stack[indFn]
        # Check we can pop operands upon function
        if indFn < fn.fnDef.nbOperand:
            self.errors.append("Stack ERROR:Unable to apply Function {}:{} operand found instead of {}".
                               format(stack[indFn].fnDef.str, indFn, fn.fnDef.nbOperand))
            return stack
        # Check each member as a type upon fn type
        for idx in range(indFn-fn.fnDef.nbOperand, indFn):
            member = stack[idx]
            if not self.isOperandTypeMatchsWithOp("{}".format(idx), member, fn.fnDef):
                return stack
        # Compute result and put in stack (in replacement of function)
        stack[indFn] = fn.fnDef.fn(stack[indFn-fn.fnDef.nbOperand:indFn])
        # Remove from stack all previous members used by function
        for index in range(indFn-fn.fnDef.nbOperand, indFn):
            stack.pop(indFn-fn.fnDef.nbOperand)
        return stack

    def isOperandTypeMatchsWithOp(self, name, operand, opOrFnDef):
        if type(opOrFnDef.inType) is Bool:
            if type(operand) is not Bool:
                self.errors.append("Stack ERROR:{} member [{}] is not a boolean".format(name, operand.value))
            return False
        if type(opOrFnDef.inType) is Scalar:
            if type(operand) is not Scalar or type(operand) is not PathExp:
                self.errors.append("Stack ERROR:{} member [{}] is not a scalar".format(name, operand.value))
            return False
        return True

    def initDebugFile(self, filename):
        self.handle = open(filename, 'a')
        self.debug = True
        self.traceDebug("\n"+"=" * 80)
        return self.handle

    def traceDebug(self, str):
        self.handle.write(str+"\n")
        # linux.console(str)

# ======================================================================================


def IsTypeCompliant(f1, f2):
    if f1.type == "STR" and f2.type != "STR":
        return False
    if f2.type == "STR" and f1.type != "STR":
        return False
    return True


def OpLe(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value <= right.value)


def OpLt(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value < right.value)


def OpGe(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value >= right.value)


def OpGt(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value > right.value)


def OpEq(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value == right.value)


def OpNe(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value != right.value)


def OpAnd(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value and right.value)


def OpOr(left, right):
    if not IsTypeCompliant(left, right):
        return Bool(False)
    return Bool(left.value or right.value)


def OpAdd(left, right):
    if not IsTypeCompliant(left, right):
        return Scalar("ERR_ADD")
    return Scalar("{}".format(left.value + right.value))


def OpSub(left, right):
    if not IsTypeCompliant(left, right):
        return Scalar("ERR_SUB")
    return Scalar("{}".format(left.value - right.value))


def OpMul(left, right):
    if not IsTypeCompliant(left, right):
        return Scalar("ERR_MUL")
    return Scalar("{}".format(left.value * right.value))


def OpDiv(left, right):
    if not IsTypeCompliant(left, right):
        return Scalar("ERR_DIV")
    res = "ERR_DIV_0"
    try:
        res = left.value/right.value
    except Exception:
        pass
    return Scalar("{}".format(res))


def OpMod(left, right):
    if not IsTypeCompliant(left, right):
        return Scalar("ERR_MOD")
    return Scalar("{}".format(left.value % right.value))


def OpNone(left, right):
    return False


ListOpDef = [
            OpDef(str="<=", inType=Scalar, prio=5, fn=OpLe),
            OpDef(str=">=", inType=Scalar, prio=5, fn=OpGe),
            OpDef(str="<", inType=Scalar, prio=5, fn=OpLt),
            OpDef(str=">", inType=Scalar, prio=5, fn=OpGt),
            OpDef(str="==", inType=Scalar, prio=6, fn=OpEq),
            OpDef(str="!=", inType=Scalar, prio=6, fn=OpNe),
            OpDef(str="or", inType=Bool, prio=7, fn=OpOr),
            OpDef(str="and", inType=Bool, prio=7, fn=OpAnd),
            OpDef(str="+", inType=Scalar, prio=4, fn=OpAdd),
            OpDef(str="-", inType=Scalar, prio=4, fn=OpSub),
            OpDef(str="*", inType=Scalar, prio=3, fn=OpMul),
            OpDef(str="/", inType=Scalar, prio=3, fn=OpDiv),
            OpDef(str="%", inType=Scalar, prio=3, fn=OpMod),
            ]

OP_NONE = OpDef(str="<NONE>", inType=Scalar, prio=0, fn=OpNone)


def InRange(listField):
    field = listField[0]
    min = listField[1]
    max = listField[2]
    return Bool(field.value >= min.value and field.value <= max.value)


def Min(listField):
    field1 = listField[0]
    field2 = listField[1]
    if not IsTypeCompliant(field1, field2):
        return Scalar("ERR_MIN")
    return Scalar("{}".format(min(field1.value, field2.value)))


def Max(listField):
    field1 = listField[0]
    field2 = listField[1]
    if not IsTypeCompliant(field1, field2):
        return Scalar("ERR_MIN")
    return Scalar("{}".format(max(field1.value, field2.value)))


ListFnDef = [
            FnDef(str="Min", inType=Scalar, nb=2, fn=Min),
            FnDef(str="Max", inType=Scalar, nb=2, fn=Max),
            FnDef(str="InRange", inType=Scalar, nb=3, fn=InRange)
            ]
