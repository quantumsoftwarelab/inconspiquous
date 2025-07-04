// RUN: QUOPT_ROUNDTRIP
// RUN: QUOPT_GENERIC_ROUNDTRIP

// CHECK: %q0 = qu.alloc
// CHECK-GENERIC: %q0 = "qu.alloc"() <{alloc = #qu.zero}> : () -> !qu.bit
%q0 = qu.alloc

// CHECK: %q1 = qu.alloc
// CHECK-GENERIC: %q1 = "qu.alloc"() <{alloc = #qu.zero}> : () -> !qu.bit
%q1 = qu.alloc

// CHECK: %q2 = qssa.gate<#gate.h> %q0
// CHECK-GENERIC: %q2 = "qssa.gate"(%q0) <{gate = #gate.h}> : (!qu.bit) -> !qu.bit
%q2 = qssa.gate<#gate.h> %q0

// CHECK: %q3 = qssa.gate<#gate.rz<0.5pi>> %q1
// CHECK-GENERIC: %q3 = "qssa.gate"(%q1) <{gate = #gate.rz<0.5pi>}> : (!qu.bit) -> !qu.bit
%q3 = qssa.gate<#gate.rz<0.5pi>> %q1

// CHECK: %q4, %q5 = qssa.gate<#gate.cx> %q2, %q3
// CHECK-GENERIC: %q4, %q5 = "qssa.gate"(%q2, %q3) <{gate = #gate.cx}> : (!qu.bit, !qu.bit) -> (!qu.bit, !qu.bit)
%q4, %q5 = qssa.gate<#gate.cx> %q2, %q3

%g1 = "test.op"() : () -> !gate.type<1>

// CHECK: %q6 = qssa.dyn_gate<%g1> %q5
// CHECK-GENERIC: %q6 = "qssa.dyn_gate"(%g1, %q5) : (!gate.type<1>, !qu.bit) -> !qu.bit
%q6 = qssa.dyn_gate<%g1> %q5

// CHECK: %{{.*}} = qssa.measure %q4
// CHECK-GENERIC: %{{.*}} = "qssa.measure"(%q4) <{measurement = #measurement.comp_basis}> : (!qu.bit) -> i1
%0 = qssa.measure %q4

// CHECK: %{{.*}} = qssa.measure<#measurement.xy<0.5pi>> %q6
// CHECK-GENERIC: %{{.*}} = "qssa.measure"(%q6) <{measurement = #measurement.xy<0.5pi>}> : (!qu.bit) -> i1
%1 = qssa.measure<#measurement.xy<0.5pi>> %q6

%q7 = qu.alloc

%m = "test.op"() : () -> !measurement.type<1>

// CHECK: %{{.*}} = qssa.dyn_measure<%m> %q7
// CHECK-GENERIC: %{{.*}} = "qssa.dyn_measure"(%m, %q7) : (!measurement.type<1>, !qu.bit) -> i1
%2 = qssa.dyn_measure<%m> %q7

// CHECK: %{{.*}} = qssa.circuit() ({
// CHECK-NEXT: ^{{.*}}(%{{.*}} : !qu.bit):
// CHECK-NEXT:   qssa.return %{{.*}}
// CHECK-NEXT: }) : () -> !gate.type<1>
// CHECK-GENERIC: %{{.*}} = "qssa.circuit"() ({
// CHECK-GENERIC-NEXT: ^{{[0-9]+}}(%{{.*}} : !qu.bit):
// CHECK-GENERIC-NEXT:   "qssa.return"(%{{.*}}) : (!qu.bit) -> ()
// CHECK-GENERIC-NEXT: }) : () -> !gate.type<1>
%circuit1 = qssa.circuit() ({
^bb0(%arg0 : !qu.bit):
  qssa.return %arg0
}) : () -> !gate.type<1>

// CHECK: %{{.*}} = qssa.circuit() ({
// CHECK-NEXT: ^{{.*}}(%{{.*}} : !qu.bit):
// CHECK-NEXT:   %{{.*}} = qssa.gate<#gate.x> %{{.*}}
// CHECK-NEXT:   qssa.return %{{.*}}
// CHECK-NEXT: }) : () -> !gate.type<1>
// CHECK-GENERIC: %{{.*}} = "qssa.circuit"() ({
// CHECK-GENERIC-NEXT: ^{{[0-9]+}}(%{{.*}} : !qu.bit):
// CHECK-GENERIC-NEXT:   %{{.*}} = "qssa.gate"(%{{.*}}) <{gate = #gate.x}> : (!qu.bit) -> !qu.bit
// CHECK-GENERIC-NEXT:   "qssa.return"(%{{.*}}) : (!qu.bit) -> ()
// CHECK-GENERIC-NEXT: }) : () -> !gate.type<1>
%circuit2 = qssa.circuit() ({
^bb0(%arg0 : !qu.bit):
  %q8 = qssa.gate<#gate.x> %arg0
  qssa.return %q8
}) : () -> !gate.type<1>

// CHECK: %{{.*}} = qssa.circuit() ({
// CHECK-NEXT: ^{{.*}}(%{{.*}} : !qu.bit, %{{.*}} : !qu.bit):
// CHECK-NEXT:   %{{.*}}, %{{.*}} = qssa.gate<#gate.cx> %{{.*}}, %{{.*}}
// CHECK-NEXT:   qssa.return %{{.*}}, %{{.*}}
// CHECK-NEXT: }) : () -> !gate.type<2>
// CHECK-GENERIC: %{{.*}} = "qssa.circuit"() ({
// CHECK-GENERIC-NEXT: ^{{[0-9]+}}(%{{.*}} : !qu.bit, %{{.*}} : !qu.bit):
// CHECK-GENERIC-NEXT:   %{{.*}}, %{{.*}} = "qssa.gate"(%{{.*}}, %{{.*}}) <{gate = #gate.cx}> : (!qu.bit, !qu.bit) -> (!qu.bit, !qu.bit)
// CHECK-GENERIC-NEXT:   "qssa.return"(%{{.*}}, %{{.*}}) : (!qu.bit, !qu.bit) -> ()
// CHECK-GENERIC-NEXT: }) : () -> !gate.type<2>
%circuit3 = qssa.circuit() ({
^bb0(%arg0 : !qu.bit, %arg1 : !qu.bit):
  %q9, %q10 = qssa.gate<#gate.cx> %arg0, %arg1
  qssa.return %q9, %q10
}) : () -> !gate.type<2>
