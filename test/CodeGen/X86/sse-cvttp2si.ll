; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=sse4.1           | FileCheck %s --check-prefixes=SSE
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx              | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx512f,avx512vl | FileCheck %s --check-prefixes=AVX,AVX512

; PR37551 - https://bugs.llvm.org/show_bug.cgi?id=37751
; We can't combine into 'round' instructions because the behavior is different for out-of-range values.

declare <4 x i32> @llvm.x86.sse2.cvttps2dq(<4 x float>)
declare <4 x i32> @llvm.x86.sse2.cvttpd2dq(<2 x double>)

define <4 x float> @float_to_int_to_float_mem_v4f32(<4 x float>* %p) {
; SSE-LABEL: float_to_int_to_float_mem_v4f32:
; SSE:       # %bb.0:
; SSE-NEXT:    roundps $11, (%rdi), %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: float_to_int_to_float_mem_v4f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vroundps $11, (%rdi), %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: float_to_int_to_float_mem_v4f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovaps (%rdi), %xmm0
; AVX512-NEXT:    vroundps $11, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %x = load <4 x float>, <4 x float>* %p, align 16
  %fptosi = tail call <4 x i32> @llvm.x86.sse2.cvttps2dq(<4 x float> %x)
  %sitofp = sitofp <4 x i32> %fptosi to <4 x float>
  ret <4 x float> %sitofp
}

define <4 x float> @float_to_int_to_float_reg_v4f32(<4 x float> %x) {
; SSE-LABEL: float_to_int_to_float_reg_v4f32:
; SSE:       # %bb.0:
; SSE-NEXT:    roundps $11, %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: float_to_int_to_float_reg_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vroundps $11, %xmm0, %xmm0
; AVX-NEXT:    retq
  %fptosi = tail call <4 x i32> @llvm.x86.sse2.cvttps2dq(<4 x float> %x)
  %sitofp = sitofp <4 x i32> %fptosi to <4 x float>
  ret <4 x float> %sitofp
}

define <2 x double> @float_to_int_to_float_mem_v2f64(<2 x double>* %p) {
; SSE-LABEL: float_to_int_to_float_mem_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    cvttpd2dq (%rdi), %xmm0
; SSE-NEXT:    cvtdq2pd %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: float_to_int_to_float_mem_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvttpd2dqx (%rdi), %xmm0
; AVX-NEXT:    vcvtdq2pd %xmm0, %xmm0
; AVX-NEXT:    retq
  %x = load <2 x double>, <2 x double>* %p, align 16
  %fptosi = tail call <4 x i32> @llvm.x86.sse2.cvttpd2dq(<2 x double> %x)
  %concat = shufflevector <4 x i32> %fptosi, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %sitofp = sitofp <2 x i32> %concat to <2 x double>
  ret <2 x double> %sitofp
}

define <2 x double> @float_to_int_to_float_reg_v2f64(<2 x double> %x) {
; SSE-LABEL: float_to_int_to_float_reg_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    cvttpd2dq %xmm0, %xmm0
; SSE-NEXT:    cvtdq2pd %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: float_to_int_to_float_reg_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvttpd2dq %xmm0, %xmm0
; AVX-NEXT:    vcvtdq2pd %xmm0, %xmm0
; AVX-NEXT:    retq
  %fptosi = tail call <4 x i32> @llvm.x86.sse2.cvttpd2dq(<2 x double> %x)
  %concat = shufflevector <4 x i32> %fptosi, <4 x i32> undef, <2 x i32> <i32 0, i32 1>
  %sitofp = sitofp <2 x i32> %concat to <2 x double>
  ret <2 x double> %sitofp
}
