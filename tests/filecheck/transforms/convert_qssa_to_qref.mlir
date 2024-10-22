// RUN: quopt -p convert-qssa-to-qref %s | filecheck %s

%q0 = qubit.alloc
%q1 = qubit.alloc
%q2 = qssa.gate<#gate.h> %q0 : !qubit.bit
%q3 = qssa.gate<#gate.rz<0.5pi>> %q1 : !qubit.bit
%q4, %q5 = qssa.gate<#gate.cnot> %q2, %q3 : !qubit.bit, !qubit.bit
%0, %q6 = qssa.measure %q4
%1, %q7 = qssa.measure %q6

// CHECK:      %q0 = qubit.alloc
// CHECK-NEXT: %q1 = qubit.alloc
// CHECK-NEXT: qref.gate<#gate.h> %q0 : !qubit.bit
// CHECK-NEXT: qref.gate<#gate.rz<0.5pi>> %q1 : !qubit.bit
// CHECK-NEXT: qref.gate<#gate.cnot> %q0, %q1 : !qubit.bit, !qubit.bit
// CHECK-NEXT: %{{.*}} = qref.measure %q0
// CHECK-NEXT: %{{.*}} = qref.measure %q0
