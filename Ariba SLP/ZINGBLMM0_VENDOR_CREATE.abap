*&---------------------------------------------------------------------*
*& Report  ZBIGBLMM0_VENDOR_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zingblmm0_vendor_create.

include zingblmm0_vendor_create_a.
include zingblmm0_vendor_create_b.

start-of-selection.
  perform f_procesa_info.
