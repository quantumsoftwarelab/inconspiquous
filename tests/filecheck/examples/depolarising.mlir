// RUN: QUOPT_ROUNDTRIP

// CHECK:      func.func @depolarising_scf(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %p = prob.bernoulli 1.000000e-01 : f64
// CHECK-NEXT:   %q3 = scf.if %p -> (!qubit.bit) {
// CHECK-NEXT:     %p2 = prob.uniform : i4
// CHECK-NEXT:     %p3 = arith.index_cast %p2 : i4 to index
// CHECK-NEXT:     %q2 = scf.index_switch %p3 -> !qubit.bit
// CHECK-NEXT:     case 1 {
// CHECK-NEXT:       %q1 = qssa.gate<#gate.x> %q : !qubit.bit
// CHECK-NEXT:       scf.yield %q1 : !qubit.bit
// CHECK-NEXT:     }
// CHECK-NEXT:     case 2 {
// CHECK-NEXT:       %q1_1 = qssa.gate<#gate.y> %q : !qubit.bit
// CHECK-NEXT:       scf.yield %q1_1 : !qubit.bit
// CHECK-NEXT:     }
// CHECK-NEXT:     case 3 {
// CHECK-NEXT:       %q1_2 = qssa.gate<#gate.z> %q : !qubit.bit
// CHECK-NEXT:       scf.yield %q1_2 : !qubit.bit
// CHECK-NEXT:     }
// CHECK-NEXT:     default {
// CHECK-NEXT:       scf.yield %q : !qubit.bit
// CHECK-NEXT:     }
// CHECK-NEXT:     scf.yield %q2 : !qubit.bit
// CHECK-NEXT:   } else {
// CHECK-NEXT:     scf.yield %q : !qubit.bit
// CHECK-NEXT:   }
// CHECK-NEXT:   func.return %q3 : !qubit.bit
// CHECK-NEXT: }
func.func @depolarising_scf(%q : !qubit.bit) -> !qubit.bit {
  %p = prob.bernoulli 0.1
  %q3 = scf.if %p -> (!qubit.bit) {
    %p2 = prob.uniform : i4
    %p3 = arith.index_cast %p2 : i4 to index
    %q2 = scf.index_switch %p3 -> !qubit.bit
    case 1 {
      %q1 = qssa.gate<#gate.x> %q : !qubit.bit
      scf.yield %q1 : !qubit.bit
    }
    case 2 {
      %q1 = qssa.gate<#gate.y> %q : !qubit.bit
      scf.yield %q1 : !qubit.bit
    }
    case 3 {
      %q1 = qssa.gate<#gate.z> %q : !qubit.bit
      scf.yield %q1 : !qubit.bit
    }
    default {
      scf.yield %q : !qubit.bit
    }
    scf.yield %q2 : !qubit.bit
  } else {
    scf.yield %q : !qubit.bit
  }
  func.return %q3 : !qubit.bit
}

// CHECK:      func.func @depolarising_cf(%q : !qubit.bit) -> !qubit.bit {
// CHECK-NEXT:   %p = prob.bernoulli 1.000000e-01 : f64
// CHECK-NEXT:   cf.cond_br %p, ^0, ^1(%q : !qubit.bit)
// CHECK-NEXT: ^0:
// CHECK-NEXT:   %p2 = prob.uniform : i4
// CHECK-NEXT:   cf.switch %p2 : i4, [
// CHECK-NEXT:     default: ^2(%q : !qubit.bit),
// CHECK-NEXT:     1: ^1,
// CHECK-NEXT:     2: ^3,
// CHECK-NEXT:     3: ^4
// CHECK-NEXT:   ]
// CHECK-NEXT: ^1:
// CHECK-NEXT:   %q1 = qssa.gate<#gate.x> %q : !qubit.bit
// CHECK-NEXT:   cf.br ^2(%q1 : !qubit.bit)
// CHECK-NEXT: ^3:
// CHECK-NEXT:   %q2 = qssa.gate<#gate.y> %q : !qubit.bit
// CHECK-NEXT:   cf.br ^2(%q2 : !qubit.bit)
// CHECK-NEXT: ^4:
// CHECK-NEXT:   %q3 = qssa.gate<#gate.z> %q : !qubit.bit
// CHECK-NEXT:   cf.br ^2(%q3 : !qubit.bit)
// CHECK-NEXT: ^2(%q4 : !qubit.bit):
// CHECK-NEXT:   func.return %q4 : !qubit.bit
// CHECK-NEXT: }
func.func @depolarising_cf(%q : !qubit.bit) -> !qubit.bit {
  %p = prob.bernoulli 0.1
  cf.cond_br %p, ^0, ^1(%q: !qubit.bit)
^0:
  %p2 = prob.uniform : i4
  cf.switch %p2 : i4, [
    default: ^4(%q: !qubit.bit),
    1: ^1,
    2: ^2,
    3: ^3
  ]
^1:
  %q1 = qssa.gate<#gate.x> %q : !qubit.bit
  cf.br ^4(%q1: !qubit.bit)
^2:
  %q2 = qssa.gate<#gate.y> %q : !qubit.bit
  cf.br ^4(%q2: !qubit.bit)
^3:
  %q3 = qssa.gate<#gate.z> %q : !qubit.bit
  cf.br ^4(%q3: !qubit.bit)
^4(%q4 : !qubit.bit):
  func.return %q4 : !qubit.bit
}