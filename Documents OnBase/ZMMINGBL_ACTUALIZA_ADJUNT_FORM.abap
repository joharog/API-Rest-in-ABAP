*&---------------------------------------------------------------------*
*&  Include    ZMMINGBL_ACTUALIZA_ADJUNT_TOP
*&---------------------------------------------------------------------*

"----------------------------------------------------------------------"
"       FORM f_load_arbcig_tvarv.                                      "
"----------------------------------------------------------------------"
form f_load_arbcig_tvarv.

  clear : lv_xstring, lv_string.

  "Direct Connectivity Parameters
  select single realm from arbcig_authparam into lv_realm
    where solution eq lc_as.

  if sy-subrc eq 0.

    lv_realm_lower = lv_realm.
    lv_realm_upper = lv_realm.

    translate lv_realm_upper to upper case.

    select name fieldname low from arbcig_tvarv into table i_tvarv
      where fieldname eq lv_realm_upper
      and name in ('SLP_OB_EA_APIKEY', 'SLP_OB_EA_CLIENTID',
                    'SLP_OB_EA_SECRET', 'SLP_OB_SD_APIKEY',
                    'SLP_OB_SD_CLIENTID', 'SLP_OB_SD_SECRET').

    if sy-subrc eq 0.

      "Clasificar datos del campo low tabla arbcig_tvarv
      loop at i_tvarv into lw_tvarv.
        case lw_tvarv-name.
          when 'SLP_OB_EA_APIKEY'.
            ea_apikey = lw_tvarv-low.
          when 'SLP_OB_EA_CLIENTID'.
            ea_clientid = lw_tvarv-low.
          when 'SLP_OB_EA_SECRET'.
            ea_secret  = lw_tvarv-low.
          when 'SLP_OB_SD_APIKEY'.
            sd_apikey = lw_tvarv-low.
          when 'SLP_OB_SD_CLIENTID'.
            sd_clientid = lw_tvarv-low.
          when 'SLP_OB_SD_SECRET'.
            sd_secret = lw_tvarv-low.
        endcase.
      endloop.

      select * from zpartner_pull into table lt_partner_pull
        where process_status eq '4'
          and ariba_status   eq 'X'
          and lifnr          ne ''.

      select * from zob_file_names into table lt_ki_names.

    endif.

  endif.



endform.


"----------------------------------------------------------------------"
"       FORM f_token_supplier_pagination.                              "
"----------------------------------------------------------------------"
form f_token_supplier_pagination.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  clear: lv_string, lv_xstring.

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
    lo_client->authenticate( username = sd_clientid password = sd_secret ).

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
               data  = lw_token_sd  ).
    endif.
  endif.

endform.


"----------------------------------------------------------------------"
"       FORM f_token_external_approval.                                "
"----------------------------------------------------------------------"
form f_token_external_approval.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  lo_client->close( ).
  clear: lv_string, lv_xstring.

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
    lo_client->authenticate( username = ea_clientid password = ea_secret ).

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
               data  = lw_token_ea ).
    endif.
  endif.

endform.


"----------------------------------------------------------------------"
"       FORM  f_get_vendor_data_request.                               "
"----------------------------------------------------------------------"
form  f_get_vendor_data_request.

  data: lv_msg type string,
        lv_code type  i,
        lv_reason type  string.

  lo_client->close( ).
  clear: lv_string, lv_internal_id.
  refresh: lt_questions.

  "Concatenar: Token de Autorizacion
  lv_authori = |{ lw_token_sd-token_type } { lw_token_sd-access_token }|.

  lv_string = |https://openapi.ariba.com/api/supplierdatapagination/v4/prod/vendorDataRequests/?realm={ lv_realm_lower }|.

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

    lo_client->request->set_header_field( name = lc_apikey
                                          value = sd_apikey ).

    lo_client->request->set_header_field( name = lc_authorization
                                          value = lv_authori ).

    lo_client->request->set_header_field( name = lc_content_type
                                          value = lc_application_json ).

    concatenate '"' ls_partner_pull-internal_id  '"' into lv_internal_id.
*    lv_internal_id = '"S64622224"'.

    lv_body = |\{ "smVendorIds": [ { lv_internal_id } ], "registrationStatusList": [ "Registered" ], "outputFormat": "JSON", "withQuestionnaire": true, "withGenericCustomFields": "true" \} |.

    lo_client->request->set_cdata( lv_body ).

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

*    REPLACE ALL OCCURRENCES OF lv_feed IN lv_string WITH space.
*    REPLACE ALL OCCURRENCES OF 'businessPartnerGenericCustomField' IN lv_string WITH 'businessPartnerGenericCustomFi'.
*    REPLACE ALL OCCURRENCES OF '{}' IN lv_string WITH '{ "mandt": "000" }'.
*    CONDENSE lv_string NO-GAPS.

    perform filter_questionnaireid.

    lo_client->response->get_status(
      importing
        code   = lv_code
        reason = lv_reason ).

    if lv_code ne c_200.
      lv_msg = text-003 && space && lv_string.
      message lv_msg type 'E'.
    else.
      "JSON -> tabla interna
      zcl_json_to_data=>json_to_data(
        exporting
         json  = lv_string
        changing
         data  = lt_questions ).
    endif.

  endif.

endform.


"----------------------------------------------------------------------"
"       FORM f_get_vendor_document_url                                 "
"----------------------------------------------------------------------"
form f_get_vendor_document_url.

  data: lv_msg type string,
        lv_code_eve type  i,
        lv_reason type  string.

  clear: ls_questions.
  refresh: lt_questionnaires, lt_answers.

  read table lt_questions into ls_questions index 1.

  if sy-subrc eq 0.

    lt_questionnaires[] = ls_questions-questionnaires[].
    sort: lt_questionnaires by questionnaireid.

    delete lt_questionnaires where workspacetype eq 'SUPPLIER_REQUEST'.

    loop at lt_questionnaires into ls_questionnaires.

      lo_client->close( ).
      clear: lv_string, lv_xstring, lv_docnum, lv_authori.
      clear: lw_answers, ls_answers.

      "Concatenar: Token de Autorizacion
      lv_authori = |{ lw_token_ea-token_type } { lw_token_ea-access_token }|.

      lv_docnum = ls_questionnaires-questionnaireid.

      lv_string = |https://openapi.ariba.com/api/sourcing-approval/v2/prod/RFXDocument/{ lv_docnum }?realm={ lv_realm_lower }|.

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
                                              value = ea_apikey ).

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

        perform filter_table_answers.

        perform filter_correlationid.

        if lv_new_string is initial.
          continue.
        else.
          lv_string = lv_new_string.
        endif.


*        CLEAR: lv_count.
*        REFRESH: result_tab.
*        SEARCH lv_string FOR 'questionLabel'.
*        IF sy-subrc EQ 0.
*          FIND ALL OCCURRENCES OF 'questionLabel' IN lv_string RESULTS result_tab.
*          lv_count = lines( result_tab ).
*
*          DO lv_count TIMES.
*            PERFORM remove_questionlabel.
*          ENDDO.
*        ENDIF.


*        START CODING

*        END CODING

*        CLEAR: lv_count.
*        REFRESH: result_tab.
*        SEARCH lv_string FOR 'externalSystemCorrelationId'.
*        IF sy-subrc EQ 0.
*          FIND ALL OCCURRENCES OF 'externalSystemCorrelationId' IN lv_string RESULTS result_tab.
*          lv_count = lines( result_tab ).
*
*          DO lv_count TIMES.
*            PERFORM filter_correlationid.
*          ENDDO.
*        ENDIF.

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
              data  = ls_answers ).
        endif.


        loop at ls_answers-answers into lw_answers.
          if lw_answers-attachmentanswer is not initial.
            lw_answers-templatedocumentid = lv_docnum.
            append lw_answers to lt_answers.
          endif.
        endloop.

      endif.

    endloop.

  endif.

endform.


"----------------------------------------------------------------------"
"       FORM f_get_file_to_save.                                       "
"----------------------------------------------------------------------"
form f_get_file_to_save.

  data: lv_msg type string,
        lv_code_eve type  i,
        lv_reason type  string.

  loop at lt_answers into lw_answers.

    lo_client->close( ).
    clear: lv_string, lv_xstring.

    "Concatenar: Token de Autorizacion
    lv_authori = |{ lw_token_ea-token_type } { lw_token_ea-access_token }|.

    lv_string = |https://openapi.ariba.com/api/sourcing-approval/v2/prod/RFXDocument/{ lw_answers-templatedocumentid }/attachments/{ lw_answers-attachmentanswer-id }?realm={ lv_realm }|.

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
                                            value = ea_apikey ).

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

*      CLEAR: lv_string.
*      lo_convt = cl_abap_conv_in_ce=>create( input = lv_xstring ).
*      lo_convt->read( IMPORTING data = lv_string ).
*
*      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN lv_string WITH space.
*      CONDENSE lv_string NO-GAPS.

      lo_client->response->get_status(
      importing
      code   = lv_code_eve
      reason = lv_reason ).

      if lv_code_eve ne c_200.
        lv_msg = text-003 && space && lv_string.
        message lv_msg type 'I'.
      endif.

      "Save files in server application
      perform dataset_al11.

    endif.

  endloop.

endform.

"----------------------------------------------------------------------"
"              dataset_al11.                                   "
"----------------------------------------------------------------------"
form dataset_al11.

  clear: lv_aux, lv_ext,
         lv_size, lv_file, lv_filename,
         lv_ruta_in, lv_ruta_out,
         lc_filename, lxs_file_bin, ls_file_base64.

  clear: wa_keywords.
  refresh: it_keywords.

  read table lt_ki_names into ls_ki_names with key ki_id = lw_answers-externalsystemcorrelationid.
  if sy-subrc eq 0.

    lv_filename = ls_ki_names-file_name.
    lv_aux      = lw_answers-attachmentanswer-filename.
    lv_size     = lw_answers-attachmentanswer-filesize.

    call function 'TRINT_FILE_GET_EXTENSION'
      exporting
        filename  = lv_aux
*       UPPERCASE = 'X'
      importing
        extension = lv_ext.

*    SPLIT lw_answers-attachmentanswer-mimetype AT '/' INTO lv_aux
*                                                           lv_ext.

    concatenate lv_filename '.' lv_ext into lv_filename.

    concatenate lc_ruta_in lv_filename into lv_ruta_in.

    open dataset lv_ruta_in for output in binary mode.
    if sy-subrc eq 0.
      lv_file = lv_xstring+0(lv_size).
      transfer lv_file to lv_ruta_in.
      close dataset lv_ruta_in.
    endif.

    call function 'SCMS_BASE64_ENCODE_STR'
      exporting
        input  = lv_xstring
      importing
        output = ls_file_base64.

    if ls_file_base64 is not initial.

      move lv_filename to lc_filename.

      call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  = ls_partner_pull-lifnr
        importing
          output = ls_partner_pull-lifnr.

      wa_keywords-keyword = 'PROV-ID'.
      wa_keywords-value   = ls_partner_pull-lifnr.
      append wa_keywords to it_keywords.
      clear wa_keywords.
      wa_keywords-keyword = 'PROV-RFC'.
      wa_keywords-value   = ls_partner_pull-stcd1_taxid.
      append wa_keywords to it_keywords.
      clear wa_keywords.
      wa_keywords-keyword = 'PROV-TEXP'.
      wa_keywords-value   = 'Alta'.
      append wa_keywords to it_keywords.
      clear wa_keywords.
      wa_keywords-keyword = 'PROV-FILE'.
      wa_keywords-value   = lc_filename.
      append wa_keywords to it_keywords.

      "Send file to OnBase.
      call function 'ZFMGBLAR_CARGA_FILES_ONBASE'
        exporting
          pi_doc_type        = 'PROV-DOC_TYPE'
          pi_grupo           = 'PROV-GRUPO'
          pi_filename        = lc_filename
*         PI_ARCHIVOXSTRING  =
          pi_archivob64      = ls_file_base64
          pi_password_onbase = 'PROV-PASSWORD'
          pi_user_onbase     = 'PROV-USER'
        importing
          pe_result          = lv_respuesta
          pe_mensaje_error   = pe_error
        tables
          it_keywords        = it_keywords.

      if pe_error is initial.

        concatenate lc_ruta_out lv_filename into lv_ruta_out.

        open dataset lv_ruta_out for output in binary mode.
        if sy-subrc eq 0.
          lv_file = lv_xstring+0(lv_size).
          transfer lv_file to lv_ruta_out.
          close dataset lv_ruta_out.
        endif.

        ls_partner_pull-process_status = '5'.

      endif.
    endif.

  endif.

endform.


"----------------------------------------------------------------------"
"              f_update_zpartner.                                   "
"----------------------------------------------------------------------"
form f_update_zpartner.

  if ls_partner_pull-process_status eq '5'.
    modify zpartner_pull from ls_partner_pull.
    commit work and wait.
  endif.

endform.

"----------------------------------------------------------------------"
"              filter_table_answers.                                   "
"----------------------------------------------------------------------"
form filter_table_answers.

  clear: lv_string1, lv_string2, lv_string3, lv_string4.

  search lv_string for 'answers'.
  if sy-subrc eq 0.
    split lv_string at 'answers' into lv_string1 lv_string2.

    concatenate '{"answers' lv_string2 into lv_string.

  endif.

endform.

"----------------------------------------------------------------------"
"              filter_questionnaireid.                                   "
"----------------------------------------------------------------------"
form filter_questionnaireid.

  clear: lv_string1, lv_string2, lv_string3, lv_string4.


  clear: lv_count.
  refresh: result_tab.
  search lv_string for 'questionnaireId'.
  if sy-subrc eq 0.
    find all occurrences of 'questionnaireId' in lv_string results result_tab.
    lv_count = lines( result_tab ).

    do lv_count times.

      search lv_string for '"questionnaireId":'.
      if sy-subrc eq 0.
        split lv_string at '"questionnaireId":' into lv_string1 lv_string2.

        search lv_string2 for ','.
        if sy-subrc eq 0.
          split lv_string2 at ',' into lv_string3 lv_string4.

          if lv_new_string is initial .
            concatenate '{"questionnaireId":' lv_string3 '}' into lv_new_string.
          else.
            concatenate lv_new_string ',' '{"questionnaireId":' lv_string3 '}' into lv_new_string.
          endif.

          lv_string = lv_string4.

        endif.

      endif.

    enddo.

    if lv_new_string is not initial.

      concatenate '[{"questionnaires":[' lv_new_string ']}]' into lv_string.

    endif.

  endif.

endform.


"----------------------------------------------------------------------"
"              filter_correlationid                                    "
"----------------------------------------------------------------------"
form filter_correlationid.

  data: lv_string1 type string,
        lv_string2 type string,
        lv_string3 type string,
        lv_string4 type string,
        lv_string5 type string,
        lv_string6 type string.

  data: lv_ki type char50,
        ki_id type string.

  clear: lv_ki, ki_id, lv_new_string.
  clear: lv_string1, lv_string2, lv_string3, lv_string4, lv_string5, lv_string6.


  loop at lt_ki_names into ls_ki_names.

    concatenate '"externalSystemCorrelationId":"' ls_ki_names-ki_id '",'into lv_ki.

    ki_id = ls_ki_names-ki_id.

    search lv_string for lv_ki.

    if sy-subrc eq 0.
      split lv_string at ki_id into lv_string1 lv_string2.

      search lv_string2 for '}'.
      if sy-subrc eq 0.
        split lv_string2 at '}' into lv_string3 lv_string4.


        search lv_string3 for '"attachmentAnswer":'.
        if sy-subrc eq 0.
          split lv_string3 at '"attachmentAnswer":' into lv_string5 lv_string6.

          if lv_new_string is initial.

            concatenate '{"answers":[{' lv_ki '"attachmentAnswer":' lv_string6 '}' into lv_new_string.

          else.

            concatenate lv_new_string '},{' lv_ki '"attachmentAnswer":' lv_string6 '}' into lv_new_string.

          endif.

        endif.
      endif.

    endif.
    clear: ls_ki_names.
  endloop.

  if lv_new_string is not initial.
    concatenate lv_new_string '}]}' into lv_new_string.
  endif.

endform.
