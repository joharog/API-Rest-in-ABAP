*&---------------------------------------------------------------------*
*& Include          ZFI_PRG_UPDATE_EXCHRATE_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS: p_url       TYPE string DEFAULT 'https://www.banxico.org.mx/SieAPIRest/service/v1/series/:idSerie/datos/:fechaIni/:fechaFin' LOWER CASE OBLIGATORY.
  PARAMETERS: p_idser     TYPE string DEFAULT 'SF60653' LOWER CASE OBLIGATORY.
  PARAMETERS: P_header    TYPE string DEFAULT 'Bmx-Token'.
  PARAMETERS: p_token     TYPE string DEFAULT 'get tofem from: https://www.banxico.org.mx/SieAPIRest/service/v1/token' LOWER CASE OBLIGATORY.
  SELECT-OPTIONS: s_fecha FOR sy-datum DEFAULT sy-datum OBLIGATORY.
  PARAMETERS: p_medtyp    TYPE char10 DEFAULT 'JSON' LOWER CASE AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY MODIF ID med.
SELECTION-SCREEN END OF BLOCK b01.

PARAMETERS p_vis RADIOBUTTON GROUP gr1 DEFAULT 'X' USER-COMMAND mod.
PARAMETERS p_upd RADIOBUTTON GROUP gr1 .

INITIALIZATION.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_MEDTYP'
      values = VALUE vrm_values( ( key = 'JSON' text = 'JSON' ) ( key = 'HTML' text = 'HTML' ) ( key = 'XML' text = 'XML' ) ).

AT SELECTION-SCREEN OUTPUT.
  IF  p_upd = abap_true.
    p_medtyp = 'JSON'.
    LOOP AT SCREEN.
      IF screen-group1 = 'MED'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.


AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'ONLI' OR 'PRIN' OR 'SJOB'.
      IF p_upd = abap_true AND p_medtyp NE 'JSON'.
        SET CURSOR FIELD 'P_MEDTYP'.
        MESSAGE e200(/sapapo/om_error).
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
