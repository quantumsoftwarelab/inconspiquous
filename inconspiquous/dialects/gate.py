from __future__ import annotations
import math
from typing import ClassVar
from dataclasses import dataclass

from xdsl.dialects.builtin import (
    FloatAttr,
    Float64Type,
    IndexType,
    IntegerAttr,
    AnyFloatConstr,
    i1,
    IntegerType,
)
from xdsl.ir import (
    Dialect,
    Operation,
    ParametrizedAttribute,
    SSAValue,
    TypeAttribute,
    VerifyException,
    Attribute,
)
from xdsl.irdl import (
    AttrConstraint,
    ConstraintContext,
    ConstraintVariableType,
    GenericAttrConstraint,
    IRDLOperation,
    ParameterDef,
    VarConstraint,
    VarExtractor,
    base,
    irdl_attr_definition,
    irdl_op_definition,
    operand_def,
    prop_def,
    result_def,
    traits_def,
)
from xdsl.parser import AttrParser
from xdsl.printer import Printer
from xdsl.traits import ConstantLike, Pure

from inconspiquous.gates import GateAttr, SingleQubitGate, TwoQubitGate


@irdl_attr_definition
class AngleAttr(ParametrizedAttribute):
    """
    Attribute that wraps around a float attr, implicitly keeping it in the range
    [0, 2) and implicitly multiplying by pi
    """

    name = "gate.angle"
    data: ParameterDef[FloatAttr[Float64Type]]

    def __init__(self, f: float):
        f_attr: FloatAttr[Float64Type] = FloatAttr(f % 2, 64)
        super().__init__((f_attr,))

    @property
    def as_float_raw(self) -> float:
        return self.data.value.data

    @property
    def as_float(self) -> float:
        return self.as_float_raw * math.pi

    @classmethod
    def parse_parameters(cls, parser: AttrParser) -> tuple[FloatAttr[Float64Type]]:
        with parser.in_angle_brackets():
            is_negative = parser.parse_optional_punctuation("-") is not None
            f = parser.parse_optional_number()
            if f is None:
                f = 1.0
            if isinstance(f, int):
                f = float(f)
            if f == 0.0:
                parser.parse_optional_keyword("pi")
            else:
                parser.parse_keyword("pi")
            if is_negative:
                f = -f
            return (FloatAttr(f % 2, 64),)

    def print_parameters(self, printer: Printer) -> None:
        with printer.in_angle_brackets():
            f = self.as_float_raw
            if f == 0.0:
                printer.print_string("0")
            elif f == 1.0:
                printer.print_string("pi")
            else:
                printer.print_string(f"{f}pi")

    def __add__(self, other: AngleAttr) -> AngleAttr:
        return AngleAttr(self.data.value.data + other.data.value.data)

    def __sub__(self, other: AngleAttr) -> AngleAttr:
        return AngleAttr(self.data.value.data - other.data.value.data)

    def __neg__(self) -> AngleAttr:
        return AngleAttr(-self.data.value.data)


@irdl_attr_definition
class HadamardGate(SingleQubitGate):
    name = "gate.h"


@irdl_attr_definition
class XGate(SingleQubitGate):
    name = "gate.x"


@irdl_attr_definition
class YGate(SingleQubitGate):
    name = "gate.y"


@irdl_attr_definition
class ZGate(SingleQubitGate):
    name = "gate.z"


@irdl_attr_definition
class PhaseGate(SingleQubitGate):
    name = "gate.s"


@irdl_attr_definition
class PhaseDaggerGate(SingleQubitGate):
    name = "gate.s_dagger"


@irdl_attr_definition
class TGate(SingleQubitGate):
    name = "gate.t"


@irdl_attr_definition
class TDaggerGate(SingleQubitGate):
    name = "gate.t_dagger"


@irdl_attr_definition
class RZGate(SingleQubitGate):
    name = "gate.rz"

    angle: ParameterDef[AngleAttr]

    def __init__(self, angle: float | AngleAttr):
        if not isinstance(angle, AngleAttr):
            angle = AngleAttr(angle)

        super().__init__((angle,))

    @classmethod
    def parse_parameters(cls, parser: AttrParser) -> tuple[AngleAttr]:
        return (AngleAttr.new(AngleAttr.parse_parameters(parser)),)

    def print_parameters(self, printer: Printer) -> None:
        return self.angle.print_parameters(printer)


@irdl_attr_definition
class CNotGate(TwoQubitGate):
    name = "gate.cnot"


@irdl_attr_definition
class CZGate(TwoQubitGate):
    name = "gate.cz"


@irdl_attr_definition
class ToffoliGate(GateAttr):
    name = "gate.toffoli"

    @property
    def num_qubits(self) -> int:
        return 3


@irdl_attr_definition
class IdentityGate(SingleQubitGate):
    name = "gate.id"


@irdl_attr_definition
class GateType(ParametrizedAttribute, TypeAttribute):
    """
    Type for dynamic gate operations
    """

    name = "gate.type"

    num_qubits: ParameterDef[IntegerAttr[IndexType]]

    def __init__(self, num_qubits: int | IntegerAttr[IndexType]):
        if isinstance(num_qubits, int):
            num_qubits = IntegerAttr.from_index_int_value(num_qubits)
        super().__init__((num_qubits,))

    @classmethod
    def parse_parameters(cls, parser: AttrParser) -> tuple[IntegerAttr[IndexType]]:
        with parser.in_angle_brackets():
            i = parser.parse_integer(allow_boolean=False, allow_negative=False)
            return (IntegerAttr.from_index_int_value(i),)

    def print_parameters(self, printer: Printer) -> None:
        with printer.in_angle_brackets():
            printer.print_string(str(self.num_qubits.value.data))


@dataclass(frozen=True)
class GateTypeConstraint(GenericAttrConstraint[GateAttr]):
    """
    Put a constraint on the gate type of a gate.
    """

    type_constraint: GenericAttrConstraint[GateType]

    def verify(self, attr: Attribute, constraint_context: ConstraintContext) -> None:
        if not isinstance(attr, GateAttr):
            raise VerifyException(f"attribute {attr} expected to be a gate")
        self.type_constraint.verify(GateType(attr.num_qubits), constraint_context)

    @dataclass(frozen=True)
    class _Extractor(VarExtractor[GateAttr]):
        inner: VarExtractor[GateType]

        def extract_var(self, a: GateAttr) -> ConstraintVariableType:
            return self.inner.extract_var(GateType(a.num_qubits))

    def get_variable_extractors(self) -> dict[str, VarExtractor[GateAttr]]:
        return {
            v: self._Extractor(r)
            for v, r in self.type_constraint.get_variable_extractors().items()
        }


@irdl_op_definition
class ConstantGateOp(IRDLOperation):
    """
    Constant-like operation for producing gates
    """

    _T: ClassVar[AttrConstraint] = VarConstraint("T", base(GateType))

    name = "gate.constant"

    gate = prop_def(GateTypeConstraint(_T))

    out = result_def(_T)

    assembly_format = "$gate attr-dict"

    traits = traits_def(
        ConstantLike(),
        Pure(),
    )

    def __init__(self, gate: GateAttr):
        super().__init__(
            properties={
                "gate": gate,
            },
            result_types=(gate.get_type(),),
        )


@irdl_op_definition
class QuaternionGateOp(IRDLOperation):
    """
    A gate described by a quaternion.

    The action of the gate on the Bloch sphere is given by the rotation generated
    by conjugating by the quaternion.
    """

    _T: ClassVar = VarConstraint("T", base(IntegerType) | AnyFloatConstr)

    name = "gate.quaternion"

    real = operand_def(_T)
    i = operand_def(_T)
    j = operand_def(_T)
    k = operand_def(_T)

    out = result_def(GateType(1))

    assembly_format = (
        "`<` type($real) `>` $real `+` $i `i` `+` $j `j` `+` $k `k` attr-dict"
    )

    traits = traits_def(Pure())

    def __init__(
        self,
        real: Operation | SSAValue,
        i: Operation | SSAValue,
        j: Operation | SSAValue,
        k: Operation | SSAValue,
    ):
        real = SSAValue.get(real)
        super().__init__(
            operands=(real, i, j, k),
            result_types=(real.type,),
        )


@irdl_op_definition
class ComposeGateOp(IRDLOperation):
    name = "gate.compose"

    _T: ClassVar = VarConstraint("T", base(GateType))

    lhs = operand_def(_T)
    rhs = operand_def(_T)

    out = result_def(_T)

    assembly_format = "$lhs `,` $rhs attr-dict `:` type($out)"

    traits = traits_def(Pure())

    def __init__(self, lhs: SSAValue | Operation, rhs: SSAValue | Operation):
        lhs = SSAValue.get(lhs)
        super().__init__(operands=(lhs, rhs), result_types=(lhs.type,))


@irdl_op_definition
class XZSOp(IRDLOperation):
    """
    A gadget for describing combinations of X, Z, and (pi/2) phase gates.
    """

    name = "gate.xzs"

    x = operand_def(i1)
    z = operand_def(i1)
    phase = operand_def(i1)

    out = result_def(GateType(1))

    assembly_format = "$x `,` $z `,` $phase attr-dict"

    traits = traits_def(Pure())

    def __init__(
        self,
        x: Operation | SSAValue,
        z: Operation | SSAValue,
        phase: Operation | SSAValue,
    ):
        super().__init__(operands=(x, z, phase), result_types=(GateType(1),))


Gate = Dialect(
    "gate",
    [
        ConstantGateOp,
        QuaternionGateOp,
        ComposeGateOp,
        XZSOp,
    ],
    [
        AngleAttr,
        HadamardGate,
        XGate,
        YGate,
        ZGate,
        PhaseGate,
        PhaseDaggerGate,
        TGate,
        TDaggerGate,
        RZGate,
        CNotGate,
        CZGate,
        ToffoliGate,
        IdentityGate,
        GateType,
    ],
)
