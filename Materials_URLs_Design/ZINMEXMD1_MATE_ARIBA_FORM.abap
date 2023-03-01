*&---------------------------------------------------------------------*
*&  Include    ZINMEXMD1_MATE_ARIBA_FORM
*&---------------------------------------------------------------------*
"----------------------------------------------------------------------"
"       FORM f_token_operation_reporting.                              "
"----------------------------------------------------------------------"
form f_token_operation_reporting.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  clear: lv_string.
  lv_string = |https://api.ariba.com/v2/oauth/token?grant_type=openapi_2lo|.

  cl_http_client=>create_by_url(
  exporting
    url                = lv_string
    proxy_host         = host
    proxy_service      = service
  importing
    client             = lo_client
  exceptions
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3 ).
  if sy-subrc <> 0.
    lo_client->close( ).
  else.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.
    lo_client->request->set_method( 'POST' ).
    lo_client->authenticate( username = or_clientid password = or_secret ).

*Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2 ).
    if sy-subrc is not initial.
*        Handle errors
    endif.

*Receipt of HTTP Response
    lo_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).
    if sy-subrc is not initial.
* Handle errors
    endif.

    lv_xstring = lo_client->response->get_data( ).

    clear: lv_string.
    lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
    lo_convt->read( importing data = lv_string ).

    replace all occurrences of lv_feed in lv_string with space.
    condense lv_string no-gaps.

    lo_client->response->get_status(
     importing
       code   = lv_code
       reason = lv_reason ).

    if lv_code ne c_200.
      lv_msg = text-004 && space && lv_string.
      message lv_msg type 'E'.
    else.
      "JSON -> Estructura
      zcl_json_to_data=>json_to_data(
            exporting
               json  = lv_string
            changing
               data  = lw_token_or  ).
    endif.
  endif.

endform.
"----------------------------------------------------------------------"
"       FORM f_token_event_management.                                 "
"----------------------------------------------------------------------"
form f_token_event_management.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  lo_client->close( ).
  clear: lv_string.
  lv_string = |https://api.ariba.com/v2/oauth/token?grant_type=openapi_2lo|.

  cl_http_client=>create_by_url(
  exporting
    url                = lv_string
    proxy_host         = host
    proxy_service      = service
  importing
    client             = lo_client
  exceptions
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3 ).

  if sy-subrc <> 0.
* Handle errors
    lo_client->close( ).

  else.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.
    lo_client->request->set_method( 'POST' ).
    lo_client->authenticate( username = em_clientid password = em_secret ).

*Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2 ).
    if sy-subrc is not initial.
*        Handle errors
    endif.

*Receipt of HTTP Response
    lo_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).
    if sy-subrc is not initial.
* Handle errors
    endif.

    lv_xstring = lo_client->response->get_data( ).

    clear: lv_string.
    lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
    lo_convt->read( importing data = lv_string ).

    replace all occurrences of lv_feed in lv_string with space.
    condense lv_string no-gaps.

    lo_client->response->get_status(
     importing
       code   = lv_code
       reason = lv_reason ).

    if lv_code ne c_200.
      lv_msg = text-005 && space && lv_string.
      message lv_msg type 'E'.
    else.
      "JSON -> Estructura
      zcl_json_to_data=>json_to_data(
            exporting
               json  = lv_string
            changing
               data  = lw_token_em ).
    endif.
  endif.

endform.
"----------------------------------------------------------------------"
"       FORM f_obtener_proyectos_sourcing.                             "
"----------------------------------------------------------------------"
form f_obtener_proyectos_sourcing.

  constants: lc_cst type tzonref-tzone value 'CST',
             lc_error_records(14) type c value '{"Records":[]}'.

  data: lv_fecha type sydatum,
        lv_hora  type syuzeit,
        lv_time_stamp type timestamp,
        lv_fecha_hora type string,
        lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  lo_client->close( ).
  clear: lv_string.


  "Concatenar: Token de Autorizacion
  lv_authori = |{ lw_token_or-token_type } { lw_token_or-access_token }|.

  "Convertir zona horaria (fecha,hora) del servidor  a zona horaria (fecha,hora) de Ariba
  convert date sy-datum time sy-uzeit into time stamp lv_time_stamp time zone lc_cst."sy-zonlo.
  lv_fecha_hora = lv_time_stamp.
  lv_fecha = lv_fecha_hora(8).
  lv_hora  = lv_fecha_hora+8(6).
  "updatedDateTo
  lv_dateto = |{ lv_fecha(4) }-{ lv_fecha+4(2) }-{ lv_fecha+6(2) }T{ lv_hora(2) }:{ lv_hora+2(2) }:{ lv_hora+4(2) }Z|.

  lv_filter_ps = '{"updatedDateTo":"' && lv_dateto  && '","updatedDateFrom":"' && last_execution && '"}'.

  "Convertir: Encode to URL
  lv_filter_ps = cl_http_utility=>if_http_utility~escape_url( lv_filter_ps ).

  lv_string = |https://openapi.ariba.com/api/sourcing-reporting-details/v1/prod/views/{ or_template }?realm={ lv_realm }&filters={ lv_filter_ps }|.

  cl_http_client=>create_by_url(
  exporting
    url                = lv_string
    proxy_host         = host
    proxy_service      = service
  importing
    client             = lo_client
  exceptions
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3 ).

  if sy-subrc <> 0.
    "Handle errors
    lo_client->close( ).
  else.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.

    lo_client->request->set_method( 'GET' ).

    lo_client->request->set_header_field( name = lc_apikey
                                          value = or_apikey ).

    lo_client->request->set_header_field( name = lc_authorization
                                          value = lv_authori ).

    "Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2 ).
    if sy-subrc is not initial.
      "Handle errors
    endif.

    "Receipt of HTTP Response
    lo_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others = 4 ).
    if sy-subrc is not initial.
      lo_client->get_last_error( importing message = lv_msg ).
      message lv_msg type 'E'.
    endif.


    lv_xstring = lo_client->response->get_data( ).

    clear: lv_string.
    lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
    lo_convt->read( importing data = lv_string ).

    replace all occurrences of lv_feed in lv_string with space.
    condense lv_string no-gaps.

    lo_client->response->get_status(
      importing
        code   = lv_code
        reason = lv_reason ).



    if lv_code ne c_200 or
       lv_string eq lc_error_records.

      lv_msg = text-003.
      message lv_msg type 'I'.
    else.
      "JSON -> tabla interna
      zcl_json_to_data=>json_to_data(
        exporting
         json  = lv_string
        changing
         data  = lt_records ).
    endif.

  endif.

endform.
"----------------------------------------------------------------------"
"              FORM f_sourcing_event.                                  "
"----------------------------------------------------------------------"
form f_sourcing_event.

  data: lv_matnr type matnr,
        lv_flag type char1,
        lv_code type  i,
        lv_msg type string,
        lv_code_eve type  i,
        lv_reason type  string.

  constants: lc_p(1) type c value 'P'.

  sort lt_records-records[] stable by timeupdated ascending.
  loop at lt_records-records[] into ls_records.

*----------------------------------------------------------*
*           Obtener Sourcing Event                         *
*----------------------------------------------------------*
    lo_client->close( ).
    clear: lv_string.

    "Concatenar: Token de Autorizacion
    lv_authori = |{ lw_token_em-token_type } { lw_token_em-access_token }|.

    lv_string = |https://openapi.ariba.com/api/sourcing-event/v2/prod/events/{ ls_records-documentid-internalid }?realm={ lv_realm }&user={ em_user }&passwordAdapter={ em_user_pa }|.

    cl_http_client=>create_by_url(
    exporting
      url                = lv_string
      proxy_host         = host
      proxy_service      = service
    importing
      client             = lo_client
    exceptions
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3 ).

    if sy-subrc <> 0.
      "Handle errors
      lo_client->close( ).
    else.

      lo_client->propertytype_logon_popup = lo_client->co_disabled.

      lo_client->request->set_method( 'GET' ).


      lo_client->request->set_header_field( name = lc_apikey
                                            value = em_apikey ).

      lo_client->request->set_header_field( name = lc_authorization
                                            value = lv_authori ).


      "Structure of HTTP Connection and Dispatch of Data
      lo_client->send(
        exceptions
          http_communication_failure = 1
          http_invalid_state         = 2 ).
      if sy-subrc is not initial.
        "Handle errors
      endif.

      "Receipt of HTTP Response
      lo_client->receive(
        exceptions
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3 ).
      if sy-subrc is not initial.
        "Handle errors
      endif.

      lv_xstring = lo_client->response->get_data( ).

      clear: lv_string.
      lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
      lo_convt->read( importing data = lv_string ).


      replace all occurrences of cl_abap_char_utilities=>newline in lv_string with space.
      condense lv_string no-gaps.

      split lv_string at lc_owner into lv_string lv_string_b.
      lv_string = |{ lv_string }{ lc_close }|.


      lo_client->response->get_status(
       importing
         code   = lv_code_eve
         reason = lv_reason ).

      if lv_code_eve ne c_200.
        lv_msg = text-003 && space && lv_string.
        message lv_msg type 'I'.
      else.
        "JSON -> Estructura
        zcl_json_to_data=>json_to_data(
           exporting
            json  = lv_string
          changing
            data  = ls_events ).
      endif.

      if ( ls_events-status eq lc_draft or ls_events-status eq lc_borrador )
           and ls_events-eventtypename eq lc_rfp.
*----------------------------------------------------------*
*             Obtener Items del Evento                     *
*----------------------------------------------------------*
        lo_client->close( ).
        clear: lv_string.

        "Concatenar: Token de Autorizacion
        lv_authori = |{ lw_token_em-token_type } { lw_token_em-access_token }|.

        lv_string = |https://openapi.ariba.com/api/sourcing-event/v2/prod/events/{ ls_records-documentid-internalid }/items?realm={ lv_realm }&user={ em_user }&passwordAdapter={ em_user_pa }|.

        cl_http_client=>create_by_url(
        exporting
          url                = lv_string
          proxy_host         = host
          proxy_service      = service
        importing
          client             = lo_client
        exceptions
          argument_not_found = 1
          plugin_not_active  = 2
          internal_error     = 3 ).

        if sy-subrc <> 0.
          "Handle errors
          lo_client->close( ).
        else.

          lo_client->propertytype_logon_popup = lo_client->co_disabled.

          lo_client->request->set_method( 'GET' ).

          lo_client->request->set_header_field( name = lc_apikey
                                                value = em_apikey ).

          lo_client->request->set_header_field( name = lc_authorization
                                                value = lv_authori ).

          "Structure of HTTP Connection and Dispatch of Data
          lo_client->send(
            exceptions
              http_communication_failure = 1
              http_invalid_state         = 2 ).
          if sy-subrc is not initial.
            "Handle errors
          endif.

          "Receipt of HTTP Response
          lo_client->receive(
            exceptions
              http_communication_failure = 1
              http_invalid_state         = 2
              http_processing_failed     = 3 ).
          if sy-subrc is not initial.
            "Handle errors
          endif.

          lv_xstring = lo_client->response->get_data( ).

          clear: lv_string.
          lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
          lo_convt->read( importing data = lv_string ).


          replace all occurrences of cl_abap_char_utilities=>newline in lv_string with space.
          "CONDENSE lv_string NO-GAPS.

          "Se separan todos los TERMS por medio de los itemId en una tabla interna(cada registros contiene un itemId).
          split lv_string at lc_itemid into table i_payload.

          "Se elimina la linea 1 que contiene solo el payload
          delete i_payload[] index 1.


          clear: v_request_cdata.
          "Recorrer el payload
          loop at i_payload[] assigning <f_payload>.

            lw_payload = <f_payload>.
            condense  <f_payload> no-gaps.

            "Se obtiene el valor del campo "itemType" para validar si es igual a 4 y continuar con el proceso
            split <f_payload> at lc_itemtype into lw_no_itemtype lw_itemtype_str.

            if lw_itemtype_str is not initial.
              lv_itemtype = lw_itemtype_str(1).
            endif.

            if lv_itemtype ne '4'.
              clear: lw_no_itemtype,
                     lw_itemtype_str,
                     lv_itemtype.
              continue.
            endif.


            "Se busca existencia del elemento "fieldId":"MaterialCode" en el terms que se esta recorriendo
            search <f_payload> for '"fieldId":"MaterialNumber"'.
            if sy-subrc eq 0.
              split <f_payload> at '"fieldId":"MaterialNumber"' into lv_no_materialcode lv_materialcode.

              if lv_materialcode is not initial.
                "Se busca el elemento "isEditable"' solo como referencia para limitar la busqueda del simpleValue.
                search lv_materialcode for ',"isEditable"'.
                if sy-subrc eq 0.
                  split lv_materialcode at ',"isEditable"' into lv_simplevalue lv_no_simplevalue.
                  if lv_simplevalue is not initial.
                    search lv_simplevalue for '"value":{"simpleValue":"'.
                    if sy-subrc eq 0.
                      split lv_simplevalue at '"value":{"simpleValue":"' into lv_no_simplevalue lv_simplevalue.

                      if lv_simplevalue is not initial.
                        lv_int = strlen( lv_simplevalue ).
                        lv_int = lv_int - 2.
                        lv_simplevalue = lv_simplevalue(lv_int).

                        "Material
                        lv_matnr = lv_simplevalue.
                        if lv_matnr is not initial.
                          "Completar con ceros a la izquierda
                          call function 'CONVERSION_EXIT_ALPHA_INPUT'
                            exporting
                              input  = lv_matnr
                            importing
                              output = lv_matnr.

                          clear: v_tdline,
                                 v_url_consulta,
                                 lv_flag.

                          perform f_validar_comment using <f_payload>
                                                 changing lv_flag.

                          if lv_flag eq abap_false.

                            "Validar Material en la tabla MARA
                            perform f_get_data_mara using lv_matnr
                                                 changing v_tdline
                                                          v_url_consulta.


                            if v_tdline is not initial or
                               v_url_consulta is not initial.

                              perform f_consolidar_itemid using v_tdline
                                                                v_url_consulta
                                                       changing v_request_cdata.

                            endif.

                          endif.

                        endif.

                      endif.
                    endif.
                  endif.
                endif.
              endif.
            endif.

          endloop.

          if v_request_cdata is not initial.
            perform f_update_item_event using v_tdline
                                              v_url_consulta
                                     changing v_request_cdata
                                              lv_code.

            if lv_code eq c_200.
              "Se actualiza tabla arbcig_tvarv
              ls_tvarv-name      = 'SRC_URL_LAST_EXECUTION'.
              ls_tvarv-fieldname = lv_realm.
              ls_tvarv-low       = ls_records-timeupdated.
              ls_tvarv-type      = lc_p.
              modify arbcig_tvarv from ls_tvarv.
              commit work and wait.
              clear: ls_tvarv.
            endif.


          endif.

        endif.

      endif.

    endif.


  endloop.

endform.
"----------------------------------------------------------------------"
"              FORM f_get_data_mara.                                   "
"----------------------------------------------------------------------"
form f_get_data_mara    using p_i_matnr  type matnr
                     changing p_c_tdline type string
                              p_c_url_consulta type text255.

  constants: lc_proceso_adn type char5 value 'ADN',
             lc_kt_material type char20 value 'KT_MATERIAL'.

  types: begin of t_mara,
        matnr type matnr,
        mtart type mtart.
  types: end of t_mara.
  data: lw_mara type t_mara,
        lt_input type table of zmmes_ordered,
        lw_input type zmmes_ordered,
        lw_output type zmmes_text,
        lw_data type zmmes_text_matnr,
        lw_line type tline,
        lv_lines type i,
        lt_keywords type table of zgblst_keywords_onbase,
        lw_keywords type zgblst_keywords_onbase,
        lv_pe_url_consulta type text255.

  clear: p_c_tdline,
         p_c_url_consulta.

  "Obtener datos mara
  select single matnr mtart
  into lw_mara
  from mara
  where matnr eq p_i_matnr.
  if sy-subrc eq 0.

    if lw_mara-mtart eq lc_zve5.
      refresh: lt_input[].
      lw_input-matnr = lw_mara-matnr.
      append lw_input to lt_input.
      clear: lw_input.

      call function 'ZMMMF_READ_TEXT_MATNR'
        importing
          e_output = lw_output
        tables
          t_input  = lt_input.

      read table lw_output-data into lw_data index 1.
      if sy-subrc eq 0.
        "Se concatena los registros que vienen en TDLINE
        loop at lw_data-lines[] into lw_line.
          if p_c_tdline is initial.
            p_c_tdline = lw_line-tdline.
          else.
            concatenate p_c_tdline lw_line-tdline into p_c_tdline separated by space.
          endif.
        endloop.
      endif.
    endif.


    if lw_mara-mtart eq lc_zfe7.
      refresh: lt_keywords.
      clear: lw_keywords,
             lv_pe_url_consulta.
      lw_keywords-keyword = lc_kt_material.
      lw_keywords-value   = lw_mara-matnr.
      append lw_keywords to lt_keywords.

      call function 'ZFMGBLAR_GET_FILES_ONBASE'
        exporting
          pi_proceso      = lc_proceso_adn
        importing
          pe_url_consulta = lv_pe_url_consulta
        tables
          it_keywords     = lt_keywords.
      if lv_pe_url_consulta is not initial.
        p_c_url_consulta  = lv_pe_url_consulta.
      endif.
    endif.

  endif.

endform.
"----------------------------------------------------------------------"
"              FORM f_update_item_event                                "
"----------------------------------------------------------------------"
form f_update_item_event using p_i_tdline       type string
                               p_i_url_consulta type text255
                     changing  p_c_request_cdata type string
                               p_c_code type  i.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  clear: p_c_code.

  p_c_request_cdata = p_c_request_cdata && ']'.

*----------------------------------------------------------*
*        Actualizar el Item del Evento                     *
*----------------------------------------------------------*
  lo_client->close( ).
  clear: lv_string,
         lv_authori.


  "Concatenar: Token de Autorizacion
  lv_authori = |{ lw_token_em-token_type } { lw_token_em-access_token }|.

  lv_string = |https://openapi.ariba.com/api/sourcing-event/v2/prod/events/{ ls_records-documentid-internalid }/items?realm={ lv_realm }&user={ em_user }&passwordAdapter={ em_user_pa }|.

  cl_http_client=>create_by_url(
  exporting
    url                = lv_string
    proxy_host         = host
    proxy_service      = service
  importing
    client             = lo_client
  exceptions
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3 ).

  if sy-subrc <> 0.
    "Handle errors
    lo_client->close( ).
  else.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.

    lo_client->request->set_method( 'PUT' ).

    lo_client->request->set_header_field( name = lc_apikey
                                          value = em_apikey ).

    lo_client->request->set_header_field( name = lc_authorization
                                          value = lv_authori ).

    lo_client->request->set_header_field( name = lc_content_type
                                         value = lc_application_json ).



    lo_client->request->set_cdata( p_c_request_cdata ).

    "Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed = 3
        http_invalid_timeout = 4
        others = 5 ).
    if sy-subrc is not initial.
      lo_client->get_last_error( importing message = lv_msg ).
    endif.

    "Receipt of HTTP Response
    lo_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others = 4 ).
    if sy-subrc is not initial.
      lo_client->get_last_error( importing message = lv_msg ).
    endif.


    lo_client->response->get_status(
     importing
       code   = p_c_code
       reason = lv_reason ).


    "lv_response_cdata = lo_client->response->get_data( ).
    "lv_response_cdata = lo_client->response->get_cdata( ).

  endif.

endform.
"----------------------------------------------------------------------"
"            FORM f_consolidar_itemId.                                 "
"----------------------------------------------------------------------"
form f_consolidar_itemid using p_i_tdline       type string
                               p_i_url_consulta type text255
                     changing  p_c_request_cdata type string.

  data: lv_request_cdata type string,
        lv_i type i,
        lv_antes_comment type string,
        lv_despues_comment type string,
        lv_antes_iseditable type string,
        lv_despues_iseditable type string.

  lv_i = strlen( lw_payload ).
  lv_i = lv_i - 7.

  lv_request_cdata = lw_payload(lv_i).


  "Se desarma JSON para insertar "value-simpleValue" en la sección de "fieldId = COMMENT" entre los elementos
  "references" y "isEditable"
  split lv_request_cdata at '"fieldId" : "COMMENT"' into lv_antes_comment lv_despues_comment.
  split lv_despues_comment at  '"isEditable"' into lv_antes_iseditable lv_despues_iseditable.

  if p_i_tdline is not initial.
    lv_request_cdata = lv_antes_comment && '"fieldId" : "COMMENT"' && lv_antes_iseditable && '"value": {"simpleValue": "' && p_i_tdline && '"}' &&
                      ',      "isEditable"' && lv_despues_iseditable.
  elseif p_i_url_consulta is not initial.
    lv_request_cdata = lv_antes_comment && '"fieldId" : "COMMENT"' && lv_antes_iseditable && '"value": {"simpleValue": "' && p_i_url_consulta && '"}' &&
                      ',"isEditable"' && lv_despues_iseditable.
  endif.



  if p_c_request_cdata is initial.
    p_c_request_cdata = '[{"itemId"' && lv_request_cdata.
  else.
    p_c_request_cdata = p_c_request_cdata && ',{"itemId"' && lv_request_cdata.
  endif.


endform.
"----------------------------------------------------------------------"
"              FORM f_validar_comment                                  "
"----------------------------------------------------------------------"
form f_validar_comment using p_i_payload type string
                    changing p_c_flag type char1.

  data: lv_antes_comment type string,
        lv_despues_comment type string,
        lv_antes_iseditable type string,
        lv_despues_iseditable type string.

  "Se desarma JSON para validar si existe "value":{"simpleValue" en la sección de "fieldId = COMMENT" entre los elementos
  "references" y "isEditable".
  split p_i_payload at '"fieldId":"COMMENT"' into lv_antes_comment lv_despues_comment.
  split lv_despues_comment at  '"isEditable"' into lv_antes_iseditable lv_despues_iseditable.

  search lv_antes_iseditable for '"value":{"simpleValue"'.
  if sy-subrc eq 0.
    "Si existe.
    p_c_flag = abap_true.
  endif.

endform.
