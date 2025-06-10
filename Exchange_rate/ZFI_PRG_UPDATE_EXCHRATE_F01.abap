*&---------------------------------------------------------------------*
*& Include          ZFI_PRG_UPDATE_EXCHRATE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form process_url
*&---------------------------------------------------------------------*
FORM process_url .

  DATA lv_fecha TYPE sy-datum.
  "Build URL
  DATA(url) = p_url.
  REPLACE `:idSerie` IN url WITH p_idser.

  IF s_fecha-low IS NOT INITIAL.
    DATA(d1) = |{ s_fecha-low DATE = ISO }|."YYYY-MM-DD
  ENDIF.

  IF s_fecha-high IS NOT INITIAL.
    DATA(d2) = |{ s_fecha-high DATE = ISO }|.
  ELSE.
    d2 = |{ s_fecha-low DATE = ISO }|.
  ENDIF.

  REPLACE `:fechaIni` IN url WITH d1.
  REPLACE `:fechaFin` IN url WITH d2.
  url = |{ url }?token={ p_token }&mediaType={ p_medtyp }|.

  "Create http request
  cl_http_client=>create_by_url(
  EXPORTING
    url                = url
*    proxy_host         = host
*    proxy_service      = service
  IMPORTING
    client             = lo_client
  EXCEPTIONS
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3 ).
  IF sy-subrc <> 0.
    lo_client->close( ).
  ELSE.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.

    lo_client->request->set_method( 'GET' ).

    lo_client->request->set_header_field( name  = p_header
                                          value = p_token ).

*Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2 ).
    IF sy-subrc IS NOT INITIAL.
*        Handle errors
    ENDIF.

*Receipt of HTTP Response
    lo_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).
    IF sy-subrc IS NOT INITIAL.
* Handle errors
    ENDIF.

    l_response = lo_client->response->get_cdata( ).

    CASE abap_true. "Display response

      WHEN p_vis.
        CASE p_medtyp.
          WHEN 'JSON'.
            cl_demo_output=>display_json( l_response ).
          WHEN 'HTML' .
            cl_demo_output=>display_html( l_response ).
          WHEN 'XML' .
            cl_demo_output=>display_xml( l_response ).
          WHEN OTHERS.
        ENDCASE.


      WHEN p_upd. "Update rate

        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = l_response
          CHANGING
            data        = ls_response ).

        CHECK ls_response-bmx-series IS NOT INITIAL.

        DATA(ls_serie) = ls_response-bmx-series[ 1 ].
        DATA(idx) = lines( ls_serie-datos ).
        IF idx GT 0.
          DATA: lt_exchrate TYPE TABLE OF bapi1093_0.
          DATA  lt_return   TYPE TABLE OF bapiret2.
          DATA(ls_dato) = ls_serie-datos[ idx ].

          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
            EXPORTING
              date      = sy-datum
              days      = 0
              months    = 0
              signum    = '+'
              years     = 0
            IMPORTING
              calc_date = lv_fecha.

          APPEND INITIAL LINE TO lt_exchrate ASSIGNING FIELD-SYMBOL(<fs_rate>).
          <fs_rate>-rate_type   = 'M'.
          <fs_rate>-from_curr   = 'USD'.
          <fs_rate>-to_currncy  = 'MXN'.
          <fs_rate>-valid_from  = |{ lv_fecha }|.
          <fs_rate>-exch_rate   = ls_dato-dato.
          <fs_rate>-from_factor = 1.
          <fs_rate>-to_factor   = 1.


          APPEND INITIAL LINE TO lt_exchrate ASSIGNING <fs_rate>.
          <fs_rate>-rate_type     = 'M'.
          <fs_rate>-from_curr     = 'MXN'.
          <fs_rate>-to_currncy    = 'USD'.
          <fs_rate>-valid_from    = |{ lv_fecha }|.
          <fs_rate>-exch_rate_v   = ls_dato-dato.
          <fs_rate>-from_factor_v = 1.
          <fs_rate>-to_factor_v   = 1.

          CALL FUNCTION 'BAPI_EXCHRATE_CREATEMULTIPLE'
            EXPORTING
              upd_allow     = 'X'
              chg_fixed     = 'X'
*             DEV_ALLOW     = '000'
            TABLES
              exchrate_list = lt_exchrate
              return        = lt_return.

          LOOP AT lt_return TRANSPORTING NO FIELDS WHERE type = 'E'.
            EXIT.
          ENDLOOP.
          IF sy-subrc EQ 0. "Error
          ELSE.
            INSERT VALUE #(
            type = 'I'
            id = 'FB'
            number = 0
            message_v1 = |{ <fs_rate>-valid_from DATE = ENVIRONMENT } { TEXT-l01 } { <fs_rate>-from_factor } { <fs_rate>-from_curr } = { <fs_rate>-exch_rate } { <fs_rate>-to_currncy }| )
            INTO lt_return INDEX 1.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.

*          zcl_abap_util=>log_create( lt_return ).
*          zcl_abap_util=>log_show( no_tree = abap_true ).

        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
ENDFORM.
