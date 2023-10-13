function zfmgblar_carga_files_onbase.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_DOC_TYPE) TYPE  CHAR50
*"     VALUE(PI_GRUPO) TYPE  CHAR25
*"     VALUE(PI_FILENAME) TYPE  CHAR255
*"     VALUE(PI_ARCHIVOXSTRING) TYPE  XSTRING OPTIONAL
*"     VALUE(PI_ARCHIVOB64) TYPE  STRING OPTIONAL
*"     VALUE(PI_PASSWORD_ONBASE) TYPE  CHAR50
*"     VALUE(PI_USER_ONBASE) TYPE  CHAR50
*"  EXPORTING
*"     VALUE(PE_RESULT) TYPE  CHAR20
*"     VALUE(PE_MENSAJE_ERROR) TYPE  TEXT255
*"  TABLES
*"      IT_KEYWORDS STRUCTURE  ZGBLST_KEYWORDS_ONBASE
*"----------------------------------------------------------------------
  constants:
    lc_999(3)             type c  value '999',
    lc_00000(5)           type c  value '00000',
    lc_ariba_ord(11)      type c  value 'ARIBA-ORDEN',
    lc_ariba_pos(14)      type c  value 'ARIBA-POSICION',
    lc_ariba_nom_docu(14) type c  value 'ARIBA-NOM_DOCU',
    lc_ariba_soc(14)      type c  value 'ARIBA-SOCIEDAD',
    lc_prov_nom_arch(14)  type c  value 'Nombre Archivo',
    lc_prov_sap(23)       type c  value 'Numero de Proveedor SAP',
    lc_tipo_doc_prov(38)  type c  value 'ADM_EXPEDIENTES PROVEEDORES/ACREEDORES'.

  data: len type i.

  clear: lc_logical_port.
  clear: lt_tvarvc[], wa_keywords, lc_keywords, lc_parametros,len, lc_extension,
         ls_file_base64,lr_sys_exception,ls_output, pe_result, pe_mensaje_error.

  select single default_lp_name from srt_cfg_def_asgn
    into lc_logical_port
      where proxy_class eq co_zbdclco_soap_onbase.

  if sy-subrc eq 0.
    refresh: lt_tvarvc[].
    select * from tvarvc
      into table lt_tvarvc[]
        where name eq co_zvargblfin_onbase.

    if sy-subrc eq 0.
      sort lt_tvarvc[] by name low ascending.

      clear: ls_tvarvc, lc_password.
      read table lt_tvarvc[] into ls_tvarvc
        with key name = co_zvargblfin_onbase
                  low = pi_password_onbase"co_password
                  binary search.

      if sy-subrc eq 0.
        lc_password = ls_tvarvc-high.
      endif.

      clear: ls_tvarvc, lc_user.
      read table lt_tvarvc[] into ls_tvarvc
        with key name = co_zvargblfin_onbase
                  low = pi_user_onbase"co_user
                  binary search.

      if sy-subrc eq 0.
        lc_user = ls_tvarvc-high.
      endif.

      clear: ls_tvarvc, lc_doc_type.
      read table lt_tvarvc[] into ls_tvarvc
        with key name = co_zvargblfin_onbase
                  low = pi_doc_type"
                  binary search.

      if sy-subrc eq 0.
        lc_doc_type = ls_tvarvc-high.
      endif.

      clear: ls_tvarvc, lc_module.
      read table lt_tvarvc[] into ls_tvarvc
        with key name = co_zvargblfin_onbase
                  low = pi_grupo"
                  binary search.

      if sy-subrc eq 0.
        lc_module = ls_tvarvc-high.
      endif.


      if lc_password is initial or
         lc_user is initial.
        message s032(zmc_soporte_abap) display like co_e.
      endif.
    else.
      message s032(zmc_soporte_abap) display like co_e.
    endif.

    "leer tabla de parametros IT_KEYWORDS y burcar cada parametro en la tabla TVARVC

    loop at it_keywords into wa_keywords.
      clear: ls_tvarvc.
      read table lt_tvarvc[] into ls_tvarvc
        with key name = co_zvargblfin_onbase
                  low = wa_keywords-keyword
                  binary search.
      if sy-subrc eq 0.
        concatenate lc_keywords ls_tvarvc-high '|' into lc_keywords.
        concatenate lc_parametros wa_keywords-value '|' into lc_parametros.

        case wa_keywords-keyword.
          when lc_ariba_soc.
            gwa_onbase-sociedad      = wa_keywords-value.
          when lc_ariba_ord.
            gwa_onbase-orden         = wa_keywords-value.
          when lc_ariba_pos.
            gwa_onbase-posicion      = wa_keywords-value.
          when lc_ariba_nom_docu.
            gwa_onbase-nom_docu      = wa_keywords-value.
          when lc_prov_sap.
            gwa_onbase-sociedad      = lc_999.
            gwa_onbase-orden         = wa_keywords-value.
            gwa_onbase-posicion      = lc_00000.
          when lc_prov_nom_arch.
            gwa_onbase-nom_docu      = wa_keywords-value.
          when others.
        endcase.

*        IF wa_keywords-keyword     = 'ARIBA-SOCIEDAD'.
*          gwa_onbase-sociedad      = wa_keywords-value.
*        ELSEIF wa_keywords-keyword = 'ARIBA-ORDEN'.
*          gwa_onbase-orden         = wa_keywords-value.
*        ELSEIF wa_keywords-keyword = 'ARIBA-POSICION'.
*          gwa_onbase-posicion      = wa_keywords-value.
*        ELSEIF wa_keywords-keyword = 'ARIBA-NOM_DOCU'.
*          gwa_onbase-nom_docu      = wa_keywords-value.
*        ENDIF.

      endif.
      clear wa_keywords.
    endloop.
    len = strlen( lc_keywords ) - 1.
    lc_keywords+len =  ''.
    clear len.
    len = strlen( lc_parametros ) - 1.
    lc_parametros+len =  ''.

    clear: lc_filename.
    lc_filename = pi_filename."ls_file_path.".
*
    call function 'TRINT_FILE_GET_EXTENSION'
      exporting
        filename  = lc_filename
        uppercase = abap_true
      importing
        extension = lc_extension.
    if pi_archivob64 is initial.
      if pi_archivoxstring is not initial.

        call function 'SCMS_BASE64_ENCODE_STR'
          exporting
            input  = pi_archivoxstring"lxs_file_bin
          importing
            output = ls_file_base64.
      endif.
    else.
      ls_file_base64 = pi_archivob64.
    endif.
    if ls_file_base64 is not initial.

      clear: ls_input.
      ls_input-entrada-base-contrasena = lc_password.
      ls_input-entrada-base-keywords = lc_keywords.
      ls_input-entrada-base-modulo = lc_module.
      ls_input-entrada-base-parametros = lc_parametros.
      ls_input-entrada-base-usuario = lc_user.
      ls_input-entrada-tipo_de_documento = lc_doc_type.
      ls_input-entrada-objeto = ls_file_base64.

*      gwa_onbase-base64 = ls_file_base64.

      if lc_extension is not initial.
        ls_input-entrada-extension =  lc_extension.
      endif.
    endif.

    try.
        create object lr_onbase
          exporting
            logical_port_name = lc_logical_port.
      catch cx_ai_system_fault into lr_sys_exception.
        clear: ls_text.
        ls_text = lr_sys_exception->get_text( ).
    endtry.

    if ls_text is not initial.
      message ls_text type co_i display like co_e.
      check ls_text is initial.
    endif.

    try.
        call method lr_onbase->carga_documento(
          exporting
            input  = ls_input
          importing
            output = ls_output ).

      catch cx_ai_system_fault into lr_sys_exception.
        clear: ls_text.
        ls_text = lr_sys_exception->get_text( ).
    endtry.

    if ls_text is not initial.
*      MESSAGE ls_text TYPE co_i DISPLAY LIKE co_e.
*      CHECK ls_text IS INITIAL.

      " PE_MENSAJE =

    endif.

    if ls_output-carga_documento_result-handle_id is not initial.
      pe_result = ls_output-carga_documento_result-handle_id."text-101."'No fue posible guardar el archivo en OnBase, Contacte al Administrador.'.

      gwa_onbase-handle_id = ls_output-carga_documento_result-handle_id.

      "CONCATENATE text-101
      "           INTO
      "           PE_MENSAJE SEPARATED BY space.
    else.
      pe_result = text-104.
      pe_mensaje_error = ls_output-carga_documento_result-base-error."'No fue posible guardar el archivo en OnBase, Contacte al Administrador.'.
      "MESSAGE s021(zmc_soporte_abap) DISPLAY LIKE co_e.
    endif.
  else.

    pe_result = text-104.
    pe_mensaje_error = text-103."'No existe ningún Puerto Lógico para esta Clase Proxy, contactar a BASIS.'.
    "MESSAGE s035(zmc_soporte_abap) DISPLAY LIKE co_e.
  endif.

  gwa_onbase-uname = sy-uname.
  gwa_onbase-datum = sy-datum.
  gwa_onbase-timlo = sy-timlo.
  modify ztagblar_onbase from gwa_onbase.


endfunction.
