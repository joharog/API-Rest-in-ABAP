*&---------------------------------------------------------------------*
*& Report ZFI_PRG_UPDATE_EXCHRATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_prg_update_exchrate LINE-SIZE 255.

INCLUDE zfi_prg_update_exchrate_top.
INCLUDE zfi_prg_update_exchrate_sel.
INCLUDE zfi_prg_update_exchrate_f01.

START-OF-SELECTION.

  PERFORM process_url.
