*&---------------------------------------------------------------------*
*& Include          ZFI_PRG_UPDATE_EXCHRATE_TOP
*&---------------------------------------------------------------------*
DATA: lo_client   TYPE REF TO if_http_client,
      l_xresponse TYPE xstring,
      l_response  TYPE string.

TYPES:
  BEGIN OF ty_dato,
    fecha TYPE string,
    dato  TYPE string,
  END OF ty_dato,

  tt_datos TYPE TABLE OF ty_dato WITH EMPTY KEY,

  BEGIN OF ty_serie,
    idserie TYPE string,
    titulo  TYPE string,
    datos   TYPE tt_datos,
  END OF ty_serie,

  tt_series TYPE TABLE OF ty_serie WITH EMPTY KEY,

  ty_r_datum  TYPE RANGE OF sy-datum,
  ty_rs_datum TYPE LINE OF ty_r_datum,

  BEGIN OF ty_bmx,
    series TYPE tt_series,
  END OF ty_bmx,

  BEGIN OF ty_response,
    bmx TYPE ty_bmx,
  END OF ty_response.

DATA: ls_response TYPE ty_response.

CONSTANTS: c_proxy TYPE string   VALUE 'proxy'.
CONSTANTS: c_service TYPE string VALUE '3128'.
