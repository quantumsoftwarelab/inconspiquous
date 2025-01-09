// RUN: quopt %s -p convert-to-xzs,cse | filecheck %s

// CHECK:      func.func @id(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %g = gate.xzs %cFalse, %cFalse, %cFalse
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @id(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.id> %q
  %g = gate.constant #gate.id
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}

// CHECK:      func.func @x(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %cTrue = arith.constant true
// CHECK-NEXT:   %g = gate.xzs %cTrue, %cFalse, %cFalse
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @x(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.x> %q
  %g = gate.constant #gate.x
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}

// CHECK:      func.func @y(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %cTrue = arith.constant true
// CHECK-NEXT:   %g = gate.xzs %cTrue, %cTrue, %cFalse
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @y(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.y> %q
  %g = gate.constant #gate.y
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}

// CHECK:      func.func @z(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %cTrue = arith.constant true
// CHECK-NEXT:   %g = gate.xzs %cFalse, %cTrue, %cFalse
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @z(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.z> %q
  %g = gate.constant #gate.z
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}

// CHECK:      func.func @phase(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %cTrue = arith.constant true
// CHECK-NEXT:   %g = gate.xzs %cFalse, %cFalse, %cTrue
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @phase(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.s> %q
  %g = gate.constant #gate.s
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}

// CHECK:      func.func @phase_dagger(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %cFalse = arith.constant false
// CHECK-NEXT:   %cTrue = arith.constant true
// CHECK-NEXT:   %g = gate.xzs %cFalse, %cTrue, %cTrue
// CHECK-NEXT:   %q_1 = qssa.dyn_gate<%g> %q : !qubit.bit
// CHECK-NEXT:   %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
// CHECK-NEXT:   func.return %q_2 : !qubit.bit
// CHECK-NEXT: }
func.func @phase_dagger(%q: !qubit.bit) -> !qubit.bit {
  %q_1 = qssa.gate<#gate.s_dagger> %q
  %g = gate.constant #gate.s_dagger
  %q_2 = qssa.dyn_gate<%g> %q_1 : !qubit.bit
  func.return %q_2 : !qubit.bit
}