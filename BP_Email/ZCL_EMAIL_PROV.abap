 "* IF_HTTP_EXTENSION~HANDLE_REQUEST *"
   METHOD if_http_extension~handle_request.

    "Declaracion de variables
    DATA: lv_metodo    TYPE string,
          lv_xstring   TYPE xstring,
          lv_string    TYPE string,
          lv_cliente   TYPE kunnr,
          lv_error     TYPE char70,
          lv_test      TYPE c,
          lv_feed      TYPE abap_cr_lf VALUE cl_abap_char_utilities=>cr_lf,
          lv_mod       TYPE c,
          ls_crea_resp TYPE zsds_wsresp,
*          ls_bukrs     TYPE TABLE OF zesbukrs,
          ls_resp_json TYPE zes_lista_prov,
          lv_char      TYPE c.


    DATA: lt_lista_datos TYPE TABLE OF zst_email_resp. "zes_lista_prov.
    DATA: ls_lista_prov TYPE zst_email_resp. "zes_lista_prov.


    DATA:lo_json       TYPE REF TO cl_trex_json_serializer.
    DATA:lo_conv       TYPE REF TO cl_abap_conv_in_ce.
    DATA:lt_burks      TYPE TABLE OF zesbukrs.
    DATA:cl_oops       TYPE REF TO cx_dynamic_check.
    DATA:lc_fdt_json   TYPE REF TO cl_fdt_json.
    DATA:lv_json_body  TYPE string.
    DATA:lt_portal     TYPE zwst_email_json. "zwsty_portal2.
    DATA:lcl_string_writer TYPE REF TO cl_sxml_string_writer.
    DATA:ls_datos      TYPE zws_i_datos.


    lv_metodo = server->request->get_header_field( name = '~request-method' ).
    server->response->set_header_field( name = 'Content-Type' value = 'application/json; charset=UTF-8' ).
    lv_xstring = server->request->get_data( ).

    CALL METHOD cl_abap_conv_in_ce=>create
      EXPORTING
        encoding    = 'UTF-8'
        endian      = 'L'
        ignore_cerr = 'X'
        replacement = '#'
        input       = lv_xstring
      RECEIVING
        conv        = lo_conv.

    CALL METHOD lo_conv->read
      IMPORTING
        data = lv_string.

    REPLACE ALL OCCURRENCES OF lv_feed IN lv_string WITH space.
    CONDENSE lv_string NO-GAPS.

* Method to Convert JSON to DATA
    me->convert_json_to_data(
      EXPORTING
        lv_string = lv_string
      IMPORTING
        pt_datos  = ls_datos ).

* Funcion cambio de email portal
    CALL FUNCTION 'ZFM_EMAIL_PROV'
      EXPORTING
        i_lifnr     = ls_datos-i_lifnr
        i_mail_m    = ls_datos-i_mail_m
        i_mail_s    = ls_datos-i_mail_s
      TABLES
        t_registros = lt_lista_datos.

    TRY.

*        APPEND VALUE #( item = lt_lista_prov ) TO lt_portal.

*     Instance JSON Class
        lcl_string_writer = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).

        CALL TRANSFORMATION id
          SOURCE t_registros = lt_lista_datos "lt_portal
          RESULT XML lcl_string_writer.

*     Get JSON xstring
        lv_xstring = lcl_string_writer->get_output( ).

        CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
          EXPORTING
            im_xstring = lv_xstring
          IMPORTING
            ex_string  = lv_string.

        IF sy-subrc EQ 0.

        ENDIF.

      CATCH cx_root.

    ENDTRY.


    REPLACE ALL OCCURRENCES OF 'estatus'   IN lv_string WITH 'ESTATUS'.
    REPLACE ALL OCCURRENCES OF 'mensaje'   IN lv_string WITH 'MENSAJE'.
    REPLACE ALL OCCURRENCES OF 'respuesta' IN lv_string WITH 'RESPUESTA'.

    "Enviar respuesta a WS -> JSON
    server->response->set_cdata( data = lv_string ).


  ENDMETHOD.
 
 
 
 "* CONVERT_JSON_TO_DATA *"
 "* LV_STRING	Importing	Type	STRING
 "* PT_DATOS	Exporting	Type	ZWS_I_DATOS
 "*I_LIFNR	1 Type	LIFNR


 "*I_MAIL_M	1 Type	AD_SMTPADR
 "*I_MAIL_S	1 Type	AD_SMTPADR
 
  METHOD convert_json_to_data.

    DATA:ls_datos     TYPE zws_i_datos. "zws_i_bukrs. "zwses_bukrs.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_string
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_datos ).

    IF ls_datos IS NOT INITIAL.

      pt_datos = ls_datos.

    ENDIF.

  ENDMETHOD.
