*&---------------------------------------------------------------------*
*& Report  ZINGBLMM0_VENDOR_PROCESS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zingblmm0_vendor_process.

call transaction 'ZARIBA_VENDOR_PULL'.

call transaction 'ZARIBA_VENDOR_CREATE'.

call transaction 'ZARIBA_VENDOR_RESULT'.
