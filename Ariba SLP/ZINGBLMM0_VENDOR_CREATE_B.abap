*&---------------------------------------------------------------------*
*&  Include           ZINGBLMM0_VENDOR_CREATE_B
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROCESA_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_procesa_info .

  select * from zpartner_pull into table lt_partner_pull
    where process_status ne '4'
      and ariba_status   ne 'X'.

  read table lt_zpartner_msgs into ls_zpartner_msgs index 1.
  if ls_zpartner_msgs is initial.
    ls_zpartner_msgs-sequence = 0.
  endif.

  loop at lt_partner_pull into ls_partner_pull where process_status <> 4 and ariba_status <> 'X'.

    perform f_range_internal_id.
    perform f_centraldata_central.
    perform f_centraldata_address.
    perform f_centraldata_bank_v1.
    perform f_centraldata_contact.
    perform f_companydata.
    perform f_purchasingdata.

    s_vendor-header-object_task = 'I'.

    append s_vendor to i_vendor.

    perform f_exec_class. " class create vendor.

    "Limpieza de estructuras y tablas
    clear: s_vendor, s_master_data, s_master_data_correct, s_message_defective, error_commit.
    free: i_vendor, s_master_data, s_master_data_correct, s_message_defective.

    clear: ls_partner_pull.

    "Timpo de espera entre creacion de proveedores
    wait up to 60 seconds.
  endloop.
endform.                    " F_PROCESA_INFO
*&---------------------------------------------------------------------*
*&      Form  F_CENTRALDATA_CENTRAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_centraldata_central .

  s_vendor-central_data-central-data-ktokk = ls_partner_pull-ktokk.
  s_vendor-central_data-central-data-stcd1 = ls_partner_pull-stcd1_taxid.
  s_vendor-central_data-central-data-stcdt = ls_partner_pull-stcd1_taxtype.
  s_vendor-central_data-central-data-stcd2 = ls_partner_pull-lfa1_stcd2.
  s_vendor-central_data-central-data-fityp = ls_partner_pull-fityp.
  s_vendor-central_data-central-data-stkzn = ls_partner_pull-stkzn.
  s_vendor-central_data-central-data-stkzu = ls_partner_pull-stkzu.
  s_vendor-central_data-central-data-actss = ls_partner_pull-actss.
  s_vendor-central_data-central-data-j_1kftind = ls_partner_pull-j_1kftind.
  s_vendor-central_data-central-data-brsch = ls_partner_pull-brsch.
  s_vendor-central_data-central-data-gbdat = ls_partner_pull-gbdat.

  if s_vendor-central_data-central-data-ktokk is not initial.
    s_vendor-central_data-central-datax-ktokk = lc_x.
  endif.

  if s_vendor-central_data-central-data-stcd1 is not initial.
    s_vendor-central_data-central-datax-stcd1 = lc_x.
  endif.

  if s_vendor-central_data-central-data-stcdt is not initial.
    s_vendor-central_data-central-datax-stcdt = lc_x.
  endif.

  if s_vendor-central_data-central-data-stcd2 is not initial.
    s_vendor-central_data-central-datax-stcd2 = lc_x.
  endif.

  if s_vendor-central_data-central-data-fityp is not initial.
    s_vendor-central_data-central-datax-fityp = lc_x.
  endif.

  if s_vendor-central_data-central-data-stkzn is not initial.
    s_vendor-central_data-central-datax-stkzn = lc_x.
  endif.

  if  s_vendor-central_data-central-data-stkzu is not initial.
    s_vendor-central_data-central-datax-stkzu = lc_x.
  endif.

  if s_vendor-central_data-central-data-actss is not initial.
    s_vendor-central_data-central-datax-actss = lc_x.
  endif.

  if s_vendor-central_data-central-data-j_1kftind is not initial.
    s_vendor-central_data-central-datax-j_1kftind = lc_x.
  endif.

  if s_vendor-central_data-central-data-brsch is not initial.
    s_vendor-central_data-central-datax-brsch = lc_x.
  endif.

  if s_vendor-central_data-central-data-gbdat is not initial.
    s_vendor-central_data-central-datax-gbdat = lc_x.
  endif.

endform.                    " F_CENTRALDATA_CENTRAL
*&---------------------------------------------------------------------*
*&      Form  F_CENTRALDATA_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_centraldata_address .

  clear: s_phone, s_smtp.
  refresh: i_phone, i_smtp.

  s_vendor-central_data-address-postal-data-title = ls_partner_pull-anred.
  s_vendor-central_data-address-postal-data-name = ls_partner_pull-name1.
  s_vendor-central_data-address-postal-data-name_2 = ls_partner_pull-name2.
  s_vendor-central_data-address-postal-data-name_3 = ls_partner_pull-name3.
  s_vendor-central_data-address-postal-data-name_4 = ls_partner_pull-name4.
  s_vendor-central_data-address-postal-data-sort1 = ls_partner_pull-sortl.
  s_vendor-central_data-address-postal-data-sort2 = ls_partner_pull-mcod2.

  s_vendor-central_data-address-postal-data-street     = ls_partner_pull-stras.              "Street/HouseNum
  s_vendor-central_data-address-postal-data-str_suppl1 = ls_partner_pull-street_prefix_name. "Street 2
  s_vendor-central_data-address-postal-data-str_suppl3 = ls_partner_pull-street_suffix_name. "Street 4

  s_vendor-central_data-address-postal-data-time_zone = ls_partner_pull-time_zone.
  s_vendor-central_data-address-postal-data-langu = ls_partner_pull-spras.
  s_vendor-central_data-address-postal-data-comm_type = lc_int.
  s_vendor-central_data-address-postal-data-house_no = ls_partner_pull-house_id.
  s_vendor-central_data-address-postal-data-city = ls_partner_pull-city_name. "ort01.
  s_vendor-central_data-address-postal-data-postl_cod1 = ls_partner_pull-pstlz.
  s_vendor-central_data-address-postal-data-district = ls_partner_pull-district_name. "ort02.
  s_vendor-central_data-address-postal-data-country = ls_partner_pull-land1.
  s_vendor-central_data-address-postal-data-region = ls_partner_pull-regio.

  if s_vendor-central_data-address-postal-data-title is not initial.
    s_vendor-central_data-address-postal-datax-title = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-name is not initial.
    s_vendor-central_data-address-postal-datax-name = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-name_2 is not initial.
    s_vendor-central_data-address-postal-datax-name_2 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-name_3 is not initial.
    s_vendor-central_data-address-postal-datax-name_3 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-name_4 is not initial.
    s_vendor-central_data-address-postal-datax-name_4 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-sort1 is not initial.
    s_vendor-central_data-address-postal-datax-sort1 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-sort2 is not initial.
    s_vendor-central_data-address-postal-datax-sort2 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-str_suppl1 is not initial.
    s_vendor-central_data-address-postal-datax-str_suppl1 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-street is not initial.
    s_vendor-central_data-address-postal-datax-street = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-house_no is not initial.
    s_vendor-central_data-address-postal-datax-house_no = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-city is not initial.
    s_vendor-central_data-address-postal-datax-city = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-postl_cod1 is not initial.
    s_vendor-central_data-address-postal-datax-postl_cod1 = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-district is not initial.
    s_vendor-central_data-address-postal-datax-district = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-country is not initial.
    s_vendor-central_data-address-postal-datax-country = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-region is not initial.
    s_vendor-central_data-address-postal-datax-region = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-time_zone is not initial.
    s_vendor-central_data-address-postal-datax-time_zone = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-langu is not initial.
    s_vendor-central_data-address-postal-datax-langu = lc_x.
  endif.

  if s_vendor-central_data-address-postal-data-comm_type is not initial.
    s_vendor-central_data-address-postal-datax-comm_type = lc_x.
  endif.

  "Telefono
  s_phone-contact-data-telephone = ls_partner_pull-telf1_phone.
  if s_phone-contact-data-telephone is not initial.
    s_phone-contact-datax-telephone = lc_x.
  endif.

  append s_phone to i_phone.
  s_vendor-central_data-address-communication-phone-phone = i_phone.

  "Obtener Correo General
  clear: ls_partner_contact.
  refresh: lt_partner_contact.

  select *
    from zpartner_contact
    into table lt_partner_contact
    where internal_id in lt_id.


  loop at lt_partner_contact into ls_partner_contact.

    if ls_partner_contact-department ne '0001'.

      if ls_partner_contact-email is not initial.
        s_smtp-contact-task = 'I'.
        s_smtp-contact-data-e_mail = ls_partner_contact-email.

        s_smtp-contact-data-consnumber = s_smtp-contact-data-consnumber + 1.
        s_smtp-contact-data-home_flag  = 'X'.

        case ls_partner_contact-department.
          when '0001'.
            s_remark-data-comm_notes = 'Dirección'.
          when '0003'.
            s_remark-data-comm_notes = 'Ventas'.
          when '0007'.
            s_remark-data-comm_notes = 'Contro de Calidad'.
          when '0011'.
            s_remark-data-comm_notes = 'Cuentas por Pagar'.
        endcase.

        if s_remark-data-comm_notes is not initial.
          s_remark-task = 'I'.
          s_remark-data-consnumber = s_remark-data-consnumber + 1.

          case ls_partner_pull-ekorg. "ls_partner_pull-brsch.
            when 'ABMX' or 'ABVC'.
              s_remark-data-langu = 'S'. "debería ser el langu de concepto de búsqeuda 2
            when others.
              s_remark-data-langu = 'E'.
          endcase.

          s_remark-datax-langu      = lc_x.
          s_remark-datax-comm_notes = lc_x.
          s_remark-datax-consnumber = lc_x.

          append s_remark to i_remark.
*          CLEAR: s_remark.
          s_smtp-remark-remarks = i_remark.
          refresh: i_remark.
        endif.

        append s_smtp to i_smtp.
*        CLEAR: s_smtp.
      endif.
    endif.
  endloop.

*  s_smtp-contact-data-e_mail = ls_partner_pull-smtp_addr.
*  IF s_smtp-contact-data-e_mail IS NOT INITIAL.
*    s_smtp-contact-datax-e_mail = lc_x.
*  ENDIF.
*  APPEND s_smtp TO i_smtp.

  s_vendor-central_data-address-communication-smtp-smtp = i_smtp.

  clear: s_smtp, s_remark.
  refresh: i_smtp.

endform.                    " F_CENTRALDATA_ADDRESS
*&---------------------------------------------------------------------*
*&      Form  F_CENTRALDATA_BANK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_centraldata_bank .

  clear: ls_bank_log, s_bank, s_vendor, ls_partner_bank, ls_bank_address, error_commit, ls_messages_bk.
  refresh: lt_bank_log, i_vendor, i_bank.
  clear: s_master_data, s_master_data_correct, s_message_defective.

*  CLEAR: s_bank, ls_partner_bank, ls_partner_future.
*  REFRESH: i_bank,  lt_partner_bank.

  select *
    from zpartner_bank
    into table lt_partner_bank
    where internal_id in lt_id.

  "Insertar Bancos de Ordering Adress.
  if ls_partner_pull-fut_credit eq 'X'.
    select single *
      from zpartner_future
      into ls_partner_future
      where internal_id eq ls_partner_pull-internal_id.

    "Agregar banco para future credit
    if sy-subrc eq 0.

      select single bankl
        from bnka
        into lv_bankl
        where banks = ls_partner_future-banks
          and bankl = ls_partner_future-bankl.

      if sy-subrc <> 0. "No existe, se debería crear primero.
        ls_bank_address-bank_name  = ls_partner_future-banka.
        ls_bank_address-street     = ls_partner_future-stras.
        ls_bank_address-city       = ls_partner_future-ort01.
        ls_bank_address-region     = ls_partner_future-banks.
*        ls_bank_address-swift_code = ls_partner_future-swift.

        call function 'BAPI_BANK_CREATE'
          exporting
            bank_ctry    = ls_partner_future-banks
            bank_key     = ls_partner_future-bankl
            bank_address = ls_bank_address
          importing
            return       = error_commit.

        if error_commit-number = '000'.
          call function 'BAPI_TRANSACTION_COMMIT'
            importing
              return = error_commit.
        endif.

      endif.

      s_vendor-header-object_task = 'M'.
      s_vendor-header-object_instance-lifnr = lv_lifnr.

      s_bank-task = 'I'.
      s_bank-data_key-banks = ls_partner_future-banks.
      s_bank-data_key-bankl = ls_partner_future-bankl.
      s_bank-data_key-bankn = ls_partner_future-bankn.

*      IF ls_partner_bank-iban IS NOT INITIAL.
*        s_bank-data-iban  = ls_partner_bank-iban.
*        s_bank-datax-iban = lc_x.
*      ENDIF.

      s_bank-data-koinh = ls_partner_future-koinh.  "Account Holder Name
      if s_bank-data-koinh is not initial.
        s_bank-datax-koinh = lc_x.
      endif.

      s_bank-data-bvtyp = ls_partner_future-waers(3).  "Currency
      if s_bank-data-bvtyp is not initial.
        s_bank-datax-bvtyp = lc_x.
      endif.

      append s_bank to i_bank.

      s_vendor-central_data-bankdetail-bankdetails = i_bank.
      append s_vendor to i_vendor.

      s_master_data-vendors = i_vendor.

      call method vmd_ei_api=>maintain_bapi(
        exporting
          iv_test_run            = ''
          is_master_data         = s_master_data
        importing
          es_master_data_correct = s_master_data_correct
          es_message_defective   = s_message_defective ).

      if s_message_defective-is_error is initial.

        call function 'BAPI_TRANSACTION_COMMIT'
          exporting
            wait   = 'X'
          importing
            return = error_commit.

*      ELSE.

      endif.
    endif.
  endif.


  clear: ls_bank_log, s_bank, s_vendor, ls_partner_bank, ls_bank_address, error_commit, ls_messages_bk.
  refresh: lt_bank_log, i_vendor, i_bank.
  clear: s_master_data, s_master_data_correct, s_message_defective.
  clear: lv_bankl.

  "Insertar Bancos
  loop at lt_partner_bank into ls_partner_bank.

    s_vendor-header-object_task = 'M'.
    s_vendor-header-object_instance-lifnr = lv_lifnr.

    select single bankl
      from bnka
      into lv_bankl
      where banks = ls_partner_bank-banks
        and bankl = ls_partner_bank-bankl.

    if sy-subrc <> 0. "No existe, se debería crear primero.
      ls_bank_address-bank_name  = ls_partner_bank-name.
      ls_bank_address-street     = ls_partner_bank-address."bkstras.
      ls_bank_address-city       = ls_partner_bank-city.
      ls_bank_address-region     = ls_partner_bank-banks.
      ls_bank_address-swift_code = ls_partner_bank-swift.

      call function 'BAPI_BANK_CREATE'
        exporting
          bank_ctry    = ls_partner_bank-banks
          bank_key     = ls_partner_bank-bankl
          bank_address = ls_bank_address
        importing
          return       = error_commit.

      if error_commit-number = '000'.
        call function 'BAPI_TRANSACTION_COMMIT'
          importing
            return = error_commit.
      endif.

    endif.

    if ls_partner_bank-iban is not initial.
      s_bank-data-iban  = ls_partner_bank-iban.
      s_bank-datax-iban = lc_x.
    endif.

    if ls_partner_bank-koinh is not initial.
      s_bank-data-koinh = ls_partner_bank-koinh.
      s_bank-datax-koinh = lc_x.
    endif.

    if ls_partner_bank-bvtyp is not initial.
      s_bank-data-bvtyp = ls_partner_bank-bvtyp.
      s_bank-datax-bvtyp = lc_x.
    endif.

    s_bank-data_key-banks = ls_partner_bank-banks.
    s_bank-data_key-bankl = ls_partner_bank-bankl.
    s_bank-data_key-bankn = ls_partner_bank-bankn.

    s_bank-task = 'M'.
    append s_bank to i_bank.

    s_vendor-central_data-bankdetail-bankdetails = i_bank.
    append s_vendor to i_vendor.

    s_master_data-vendors = i_vendor.

    call method vmd_ei_api=>maintain_bapi(
      exporting
        iv_test_run            = ''
        is_master_data         = s_master_data
      importing
        es_master_data_correct = s_master_data_correct
        es_message_defective   = s_message_defective ).

    if s_message_defective-is_error is initial.

      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait   = 'X'
        importing
          return = error_commit.

    else.

      "Guardar log de errores en bancos
      loop at s_message_defective-messages into ls_messages_bk where type eq 'E' and id eq 'VMD_API'.
        ls_bank_log-internal_id  = ls_partner_pull-internal_id.
        ls_bank_log-vendor       = lv_lifnr.
        ls_bank_log-bank_country = ls_partner_bank-banks.
        ls_bank_log-bank_key     = ls_partner_bank-bankl.
        ls_bank_log-bank_account = ls_partner_bank-bankn.
        ls_bank_log-message      = ls_messages_bk-message.
        append ls_bank_log to lt_bank_log.

        modify zbank_log from table lt_bank_log.
        commit work and wait.
      endloop.

    endif.

    clear: ls_bank_log, s_bank, ls_partner_bank, ls_bank_address, error_commit, ls_messages_bk.
    refresh: lt_bank_log, i_vendor, i_bank.
    clear: s_master_data, s_master_data_correct, s_message_defective.

  endloop.

  clear: lv_bankl.

endform.                    " F_CENTRALDATA_BANK
*&---------------------------------------------------------------------*
*&      Form  F_CENTRALDATA_CONTACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_centraldata_contact .

  clear: s_contacts, ls_partner_contact.
  refresh: i_contacts, lt_partner_contact.

  select *
    from zpartner_contact
    into table lt_partner_contact
    where internal_id in lt_id.

  loop at lt_partner_contact into ls_partner_contact.
    s_contacts-task = 'I'.
    s_contacts-address_type_3-postal-data-title_p    = ls_partner_contact-title.
    s_contacts-address_type_3-postal-data-firstname  = ls_partner_contact-firstname.
    s_contacts-address_type_3-postal-data-lastname   = ls_partner_contact-lastname.
    s_contacts-data-abtnr                            = ls_partner_contact-department.

    if ls_partner_contact-email is not initial.
      s_cont_comm_smtp-contact-task = 'I'.
      s_cont_comm_smtp-contact-data-e_mail = ls_partner_contact-email.
      s_cont_comm_smtp-contact-data-consnumber = '001'.
      s_cont_comm_smtp-contact-data-home_flag  = 'X'.

      case ls_partner_contact-department.
        when '0001'.
          s_cont_comm_notes-data-comm_notes = 'Dirección'.
        when '0003'.
          s_cont_comm_notes-data-comm_notes = 'Ventas'.
        when '0007'.
          s_cont_comm_notes-data-comm_notes = 'Contro de Calidad'.
        when '0011'.
          s_cont_comm_notes-data-comm_notes = 'Cuentas por Pagar'.
      endcase.

      if s_cont_comm_notes-data-comm_notes is not initial.
        s_cont_comm_notes-task = 'I'.
        s_cont_comm_notes-data-consnumber = '001'.

        case ls_partner_pull-ekorg. "ls_partner_pull-brsch.
          when 'ABMX' or 'ABVC'.
            s_cont_comm_notes-data-langu = 'S'. "debería ser el langu de concepto de búsqeuda 2.
          when others.
            s_cont_comm_notes-data-langu = 'E'.
        endcase.

        s_cont_comm_notes-datax-langu = lc_x.
        s_cont_comm_notes-datax-comm_notes = lc_x.
        s_cont_comm_notes-datax-consnumber = lc_x.

        append s_cont_comm_notes to i_cont_comm_notes.
        s_cont_comm_smtp-remark-remarks = i_cont_comm_notes.
        clear: s_cont_comm_notes.
      endif.

      s_cont_comm_smtp-contact-datax-e_mail = lc_x.
      s_cont_comm_smtp-contact-datax-home_flag = lc_x.
      s_cont_comm_smtp-contact-datax-consnumber = lc_x.
      append s_cont_comm_smtp to i_cont_comm_smtp.
    endif.


    if ls_partner_contact-telephone is not initial.
      s_cont_comm_phone-contact-task = 'I'.
      s_cont_comm_phone-contact-data-telephone = ls_partner_contact-telephone.
      s_cont_comm_phone-contact-datax-telephone =  lc_x.
      append s_cont_comm_phone to i_cont_comm_phone.
    endif.

    s_contacts-address_type_3-communication-smtp-smtp = i_cont_comm_smtp.
    s_contacts-address_type_3-communication-phone-phone = i_cont_comm_phone.


    append s_contacts to i_contacts.
    clear: s_cont_comm_smtp, s_cont_comm_phone, s_cont_comm_notes, s_contacts.
    refresh: i_cont_comm_smtp, i_cont_comm_phone, i_cont_comm_notes.
  endloop.

  s_vendor-central_data-contact-contacts = i_contacts.

  clear: s_cont_comm_smtp, s_cont_comm_phone, s_cont_comm_notes.
  refresh: i_cont_comm_smtp, i_cont_comm_phone, i_cont_comm_notes.

endform.                    " F_CENTRALDATA_CONTACT
*&---------------------------------------------------------------------*
*&      Form  F_EXEC_CLASS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_exec_class .

  if flag_bank is initial.

    s_master_data-vendors = i_vendor.

    call method vmd_ei_api=>maintain_bapi(
      exporting
        iv_test_run            = ''
        is_master_data         = s_master_data " TYPE VMDS_EI_MAIN
      importing
*       es_error               = s_error_metodo
        es_master_data_correct = s_master_data_correct
        es_message_defective   = s_message_defective ).

    if s_message_defective-is_error is initial.
*  IF s_message_defective IS INITIAL.
      read table s_master_data_correct-vendors into s_lifnr index 1.
      if sy-subrc = 0.
        lv_lifnr = s_lifnr-header-object_instance-lifnr.
      endif.

      call function 'BAPI_TRANSACTION_COMMIT'
        exporting
          wait   = 'X'
        importing
          return = error_commit.

*      IF sy-uname EQ 'IARANGOV'.
*Insertar Bancos a Proveedor
*        PERFORM f_centraldata_bank.
*      ENDIF.

*Adiciones SLP001
      clear: flag_oa.
      if ls_partner_pull-ordadd eq abap_true.
        perform f_ordering_address_v2.    "f_ordering_address.
      endif.
*End SLP001

*Adiciones SLP006
      if ls_partner_pull-fut_credit eq abap_true.
        perform f_future_credit.
      endif.
*End SLP006

*Adiciones SLP009

      clear: ls_header.
      refresh: lt_lines.

      loop at lt_partner_bank into ls_partner_bank.

        if sy-tabix < 4.
          if ls_partner_bank-bankn = '9999999999'.

            ls_lines-tdformat = '*'.
            concatenate 'CUENTA BANCARIA EN' ls_partner_bank-bvtyp into ls_lines-tdline separated by ' '.
            append ls_lines to lt_lines.

            ls_lines-tdformat = '/'.
            concatenate 'NUMERO DE LA CUENTA:' ls_partner_bank-bankn_ext into ls_lines-tdline separated by ' '.
            append ls_lines to lt_lines.

            ls_lines-tdformat = '/'.
            concatenate 'TITULAR DE LA CUENTA:' ls_partner_bank-koinh_ext into ls_lines-tdline separated by ' '.
            append ls_lines to lt_lines.

            ls_lines-tdformat = '*'.
            ls_lines-tdline = ' '.
            append ls_lines to lt_lines.
          endif.
        endif.
      endloop.

      if lt_lines is not initial.

        ls_header-tdobject = 'LFA1'.
        ls_header-tdname   = lv_lifnr.
        ls_header-tdid     = '0005'.
        ls_header-tdspras  = 'S'.

        call function 'SAVE_TEXT'
          exporting
            client          = sy-mandt
            header          = ls_header
            insert          = 'X'
            savemode_direct = 'X'
          tables
            lines           = lt_lines.
      endif.

*End SLP009
      if error_commit is initial.
        commit work and wait.
        ls_partner_pull-process_status = 4.
        ls_partner_pull-lifnr = lv_lifnr.
        concatenate 'Vendor ' lv_lifnr ' creado exitosamente.' into ls_partner_pull-status_msg respecting blanks.

        if flag_oa is not initial.
          concatenate ls_partner_pull-status_msg ' Ocurrio error al crear los Ordering Addresses. Revisar ZLOG_OA' into ls_partner_pull-status_msg respecting blanks.
        endif.

        update lfa1 set zz_ult_act_docs = sy-datum where lifnr = lv_lifnr.

*Adiciones SLP005 actualización ARBCIG_AN_VENDOR
        clear lt_arbcig_an_vendor.
        clear lt_arbcig_systidmap.
        clear lt_ztagfin_alt_adrc.

        loop at it_bukrs into ls_bukrs.
          clear ls_arbcig_an_vendor.
          clear ls_arbcig_systidmap.
          clear ls_ztagfin_alt_adrc.

          ls_arbcig_an_vendor-bukrs = ls_bukrs-bukrs.
          ls_arbcig_an_vendor-lifnr = lv_lifnr.
          ls_arbcig_systidmap-vendorid = lv_lifnr.
          if ls_partner_pull-check_add eq abap_true.
            ls_ztagfin_alt_adrc-bukrs = ls_bukrs-bukrs.
            ls_ztagfin_alt_adrc-id_adrc = '1'.
            ls_ztagfin_alt_adrc-activo = 'X'.
            ls_ztagfin_alt_adrc-lifnr = lv_lifnr.
            ls_ztagfin_alt_adrc-name1 = ls_partner_pull-name1.
            ls_ztagfin_alt_adrc-street = ls_partner_pull-ztag_street.
            ls_ztagfin_alt_adrc-house_num1 = ls_partner_pull-ztag_house_num1.
            ls_ztagfin_alt_adrc-city1 = ls_partner_pull-ztag_city1.
            ls_ztagfin_alt_adrc-country = ls_partner_pull-ztag_country.
            ls_ztagfin_alt_adrc-region = ls_partner_pull-ztag_region.
            ls_ztagfin_alt_adrc-post_code = ls_partner_pull-ztag_post_code.
            append ls_ztagfin_alt_adrc to lt_ztagfin_alt_adrc.
          endif.

          call function 'CONVERSION_EXIT_ALPHA_INPUT'
            exporting
              input  = lv_lifnr
            importing
              output = ls_arbcig_systidmap-systemid.

          lv_offset = strlen( ls_arbcig_systidmap-systemid ).
          ls_arbcig_systidmap-systemid = ls_arbcig_systidmap-systemid + lv_offset(3).

          append ls_arbcig_systidmap to lt_arbcig_systidmap.
          append ls_arbcig_an_vendor to lt_arbcig_an_vendor.
        endloop.

        modify arbcig_systidmap from table lt_arbcig_systidmap.
        commit work and wait.

        modify arbcig_an_vendor from table lt_arbcig_an_vendor.
        commit work and wait.

        if ls_partner_pull-check_add eq abap_true.
          modify ztagfin_alt_adrc from table lt_ztagfin_alt_adrc.
          commit work and wait.
        endif.
*END SLP005

      else.
        rollback work.
        ls_partner_pull-process_status = 2.
        ls_partner_pull-status_msg = 'Error committing work'.
      endif.

    else.


*      IF sy-uname EQ 'IARANGOV'.
*        lv_lifnr = '0005028290'.
*        PERFORM f_ordering_address_v2.
*      ENDIF.

      s_error_metodo = s_message_defective.

      delete s_message_defective-messages where type = 'W'.

      loop at s_message_defective-messages into i_messages where type eq 'E'.

        if sy-tabix eq 1.
          ls_partner_pull-status_msg = i_messages-message.
          ls_partner_pull-process_status = 2.
        endif.

        if sy-tabix eq 2.
          concatenate ls_partner_pull-status_msg i_messages-message into ls_partner_pull-status_msg  separated by space.
          ls_partner_pull-process_status = 2.
        endif.


*      ls_zpartner_msgs-sequence = ls_zpartner_msgs-sequence + 1.
*      ls_zpartner_msgs-internal_id = ls_partner_pull-internal_id.
*      ls_zpartner_msgs-type = i_messages-type.
*      ls_zpartner_msgs-msg_id = i_messages-id.
*      ls_zpartner_msgs-msg_number = i_messages-number.
*      ls_zpartner_msgs-message = ls_partner_pull-status_msg.
*      ls_zpartner_msgs-log_no = i_messages-log_no.
*      ls_zpartner_msgs-log_msg_no = i_messages-log_msg_no.
*      ls_zpartner_msgs-message_v1 = i_messages-message_v1.
*      ls_zpartner_msgs-message_v2 = i_messages-message_v2.
*      ls_zpartner_msgs-message_v3 = i_messages-message_v3.
*      ls_zpartner_msgs-message_v4 = i_messages-message_v4.
      endloop.

    endif.

  else.

    concatenate 'Partner Bank Type' lv_bvtyp 'cannot be repeated.' into ls_partner_pull-status_msg separated by space.
    ls_partner_pull-process_status = 2.

  endif.

  modify zpartner_pull from ls_partner_pull.
  commit work and wait.

endform.                    " F_EXEC_CLASS
*&---------------------------------------------------------------------*
*&      Form  F_COMPANYDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_companydata .

  clear: ls_partner_pull-akont, ls_partner_pull-fdgrv, lv_year,
         ls_t001b, ls_aux_t001b, ls_bukrs, s_payment, s_company,
         ls_partner_whtax.

  refresh: lt_t024w, lt_t001w, lt_t001k, lt_t001b,
           aux_t001b, it_bukrs, i_payment, i_company,
           lt_partner_whtax.

  select single akont fdgrv
    into (ls_partner_pull-akont, ls_partner_pull-fdgrv)
    from zmmvap_akont
    where ktokk = ls_partner_pull-ktokk.

  lv_year = sy-datum(4) - 2 .

  select * from t024w into table lt_t024w
    where ekorg eq ls_partner_pull-ekorg.

  select * from t001w into table lt_t001w
    for all entries in lt_t024w
    where bwkey eq lt_t024w-werks.

  if lt_t001w is not initial.

    select * from t001k into table lt_t001k
      for all entries in lt_t001w
      where bwkey eq lt_t001w-bwkey.

    if lt_t001k is not initial.

      select * from t001b into table lt_t001b
       where mkoar eq lc_k and
             toye1 ge lv_year.

      loop at lt_t001b into ls_t001b.
        ls_t001b-bukrs = ls_t001b-bukrs+1(3).
        append ls_t001b to aux_t001b.
      endloop.

      sort lt_t001k by bukrs.
      delete adjacent duplicates from lt_t001k comparing bukrs.
      sort lt_t001b by bukrs.
*              DELETE ADJACENT DUPLICATES FROM LT_T001K COMPARING BUKRS.
      loop at lt_t001k into ls_t001k.
        read table aux_t001b into ls_aux_t001b with key bukrs = ls_t001k-bukrs.
        if sy-subrc eq 0.
          ls_bukrs-bukrs = ls_aux_t001b-bukrs.  "Company Code - Sociedad
          append ls_bukrs to it_bukrs.
        endif.
      endloop.

    endif.
  endif.

  select bukrs zwels hbkid
    into table i_payment
    from zpayment_methods
    for all entries in it_bukrs
    where bukrs eq it_bukrs-bukrs.

  select *
    from zpartner_whtax
    into table lt_partner_whtax
    where internal_id in lt_id.

  loop at it_bukrs into ls_bukrs.

*LOGICA NAL EXTRANJERO AKONT Y FDGRV

    select single *
      from zmmvap_ramo
      into ls_ramo
      where brsch eq ls_partner_pull-brsch.

    select single land1 waers
      from t001
      into (lv_land1, lv_waers)
      where bukrs eq ls_bukrs-bukrs.

    if lv_land1 <> ls_partner_pull-land1. "Extranjero
      lv_nal = ' '.
    else.
      lv_nal = 'X'.
    endif.

    if lv_nal = 'X' and ls_ramo-tipo = 'P'.
      ls_partner_pull-akont = '0021041001'. "Proveedores Nacionales Otro
    endif.

    if lv_nal = ' ' and ls_ramo-tipo = 'P'.
      ls_partner_pull-akont = '0021041002'. "Proveedores Extranjeros Otros
    endif.

    if lv_nal = 'X' and ls_ramo-tipo = 'A'.
      ls_partner_pull-akont = '0021051001'. "Acreedores diversos Nacionales Otros
    endif.

    if lv_nal = ' ' and ls_ramo-tipo = 'A'.
      ls_partner_pull-akont = '0021051002'. "Acreedores diversos Extranjeros Otros
    endif.

    if lv_nal = 'X'.
      ls_partner_pull-fdgrv = 'A1'. "Domestic
    else.
      ls_partner_pull-fdgrv = 'A2'. "Foreign
    endif.


    s_company-data_key-bukrs = ls_bukrs-bukrs.
    s_company-data-akont = ls_partner_pull-akont.
    s_company-data-fdgrv = ls_partner_pull-fdgrv.
    s_company-data-zterm = ls_partner_pull-zterm.
    s_company-data-reprf = ls_partner_pull-reprf.

    read table i_payment into s_payment with key bukrs = ls_bukrs-bukrs.
    if sy-subrc = 0.
      s_company-data-zwels = s_payment-zwels.
      s_company-data-hbkid = s_payment-hbkid.
    endif.

    s_company-data-xedip = lc_x.
    s_company-datax-xedip = lc_x.

    if s_company-data-akont is not initial.
      s_company-datax-akont = lc_x.
    endif.

    if s_company-data-fdgrv is not initial.
      s_company-datax-fdgrv = lc_x.
    endif.

    if s_company-data-zterm is not initial.
      s_company-datax-zterm = lc_x.
    endif.

    if s_company-data-reprf is not initial.
      s_company-datax-reprf = lc_x.
    endif.

    if s_company-data-zwels is not initial.
      s_company-datax-zwels = lc_x.
    endif.

    if s_company-data-hbkid is not initial.
      s_company-datax-hbkid = lc_x.
    endif.

    s_company-task = 'I'.

    "Withholding Tax
    loop at lt_partner_whtax into ls_partner_whtax.

      s_wtax_type-task = 'I'.

      if ls_partner_whtax-taxtype is not initial.
        s_wtax_type-data_key-witht = ls_partner_whtax-taxtype.
      endif.

      if ls_partner_whtax-taxcode is not initial.
        s_wtax_type-data-wt_withcd = ls_partner_whtax-taxcode.
        s_wtax_type-datax-wt_withcd = lc_x.
      endif.

      if ls_partner_whtax-subjectto is not initial.
        s_wtax_type-data-wt_subjct = ls_partner_whtax-subjectto.
        s_wtax_type-datax-wt_subjct = lc_x.
      endif.

      if s_wtax_type-data_key-witht is not initial.
        append s_wtax_type to i_wtax_type.
      endif.

      "Pais Banco
      s_company-data-qland = ls_partner_whtax-countrycode.
      if s_company-data-qland is not initial.
        s_company-datax-qland = lc_x.
      endif.
      clear: ls_partner_whtax, s_wtax_type.
    endloop.

    s_company-wtax_type-wtax_type = i_wtax_type.
    "Withholding Tax

*Vías de pago son obligatorias. Si no existe la vía de pago en la tabal zpayment_methods NO se procesa

    if s_company-datax-zwels eq lc_x.
      append s_company to i_company.
    endif.

    clear: s_company, s_payment.
    refresh: i_wtax_type.
  endloop.
  s_vendor-company_data-company = i_company.
endform.                    " F_COMPANYDATA
*&---------------------------------------------------------------------*
*&      Form  F_PURCHASINGDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_purchasingdata .

  clear: s_purchasing, s_functions.
  refresh: i_purchasing, i_functions.

  s_purchasing-data_key-ekorg = ls_partner_pull-ekorg.
  if ls_partner_pull-waers is not initial.
    s_purchasing-data-waers = ls_partner_pull-waers(3).
  else.
    s_purchasing-data-waers = ls_partner_pull-bvtyp.
  endif.
  s_purchasing-data-zterm = ls_partner_pull-zterm.
  s_purchasing-data-inco1 = ls_partner_pull-inco1.
  s_purchasing-data-inco2 = ls_partner_pull-inco2.
  s_purchasing-data-webre = ls_partner_pull-webre.
  s_purchasing-data-xersy = ls_partner_pull-xersy.
  s_purchasing-data-kzaut = ls_partner_pull-kzaut.
  s_purchasing-data-vsbed = ls_partner_pull-vsbed.
  s_purchasing-data-bstae = ls_partner_pull-bstae.

  s_functions-data_key-parvw = 'LF'.
  s_functions-task = 'I'.
  append s_functions to i_functions.

  s_purchasing-functions-functions = i_functions.

  if s_purchasing-data-waers is not initial.
    s_purchasing-datax-waers = lc_x.
  endif.

  if s_purchasing-data-zterm is not initial.
    s_purchasing-datax-zterm = lc_x.
  endif.

  if s_purchasing-data-inco1 is not initial.
    s_purchasing-datax-inco1 = lc_x.
  endif.

  if  s_purchasing-data-inco2 is not initial.
    s_purchasing-datax-inco2 = lc_x.
  endif.

  if s_purchasing-data-webre is not initial.
    s_purchasing-datax-webre = lc_x.
  endif.

  if s_purchasing-data-xersy is not initial.
    s_purchasing-datax-xersy = lc_x.
  endif.

  if s_purchasing-data-kzaut is not initial.
    s_purchasing-datax-kzaut = lc_x.
  endif.

  if s_purchasing-data-vsbed is not initial.
    s_purchasing-datax-vsbed = lc_x.
  endif.

  if s_purchasing-data-bstae is not initial.
    s_purchasing-datax-bstae = lc_x.
  endif.

  s_purchasing-task = 'I'.

  append s_purchasing to i_purchasing.
  s_vendor-purchasing_data-purchasing = i_purchasing.
endform.                    " F_PURCHASINGDATA

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_INTERNAL_ID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_range_internal_id .

*  Range table for Conctact, Bank, Withholding tax, Ordering Addresses
  clear: ls_id.
  refresh: lt_id.

  ls_id-sign = 'I'.
  ls_id-option = 'BT'.
  concatenate ls_partner_pull-internal_id '1' into ls_id-low separated by '-'.
  concatenate ls_partner_pull-internal_id '6' into ls_id-high separated by '-'.
  append ls_id to lt_id.

endform.                    " F_RANGE_INTERNAL_ID

*&---------------------------------------------------------------------*
*&      Form  F_ORDERING_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_ordering_address.

  "Limpiar estructura PADRE
  clear: s_vendor,  s_functions, s_purchasing,s_master_data, s_master_data_correct, s_message_defective.
  refresh: i_vendor, i_functions, i_purchasing.

  "Limpiar estructura HIJO
  clear: s_vendor_oa, s_master_data_oa, s_master_data_correct_oa, s_message_defective_oa, ls_partner_ordadd.
  refresh: i_vendor_oa, lt_partner_ordadd.

  select *
    from zpartner_ordadd
    into table lt_partner_ordadd
    where internal_id in lt_id.

  loop at lt_partner_ordadd into ls_partner_ordadd.

    s_vendor_oa-central_data-central-data-ktokk             = 'VADD'.
    s_vendor_oa-central_data-address-task                   = 'I'.

    s_vendor_oa-central_data-address-postal-data-title      = ls_partner_pull-anred.
    s_vendor_oa-central_data-central-data-brsch             = ls_partner_pull-brsch.
    s_vendor_oa-central_data-address-postal-data-name       = ls_partner_pull-name1.
    s_vendor_oa-central_data-address-postal-data-sort1      = ls_partner_pull-sortl.
    s_vendor_oa-central_data-address-postal-data-langu      = ls_partner_pull-spras.
    s_vendor_oa-central_data-central-data-stkzu             = ls_partner_pull-stkzu.

    s_vendor_oa-central_data-address-postal-data-street     = ls_partner_ordadd-street.
    s_vendor_oa-central_data-address-postal-data-city       = ls_partner_ordadd-city.
    s_vendor_oa-central_data-address-postal-data-country    = ls_partner_ordadd-country.
    s_vendor_oa-central_data-address-postal-data-region     = ls_partner_ordadd-region.
    s_vendor_oa-central_data-address-postal-data-postl_cod1 = ls_partner_ordadd-postcode.

    if s_vendor_oa-central_data-central-data-ktokk is not initial.
      s_vendor_oa-central_data-central-datax-ktokk = lc_x.
    endif.

    if s_vendor_oa-central_data-central-data-brsch is not initial.
      s_vendor_oa-central_data-central-datax-brsch = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-name is not initial.
      s_vendor_oa-central_data-address-postal-datax-name = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-sort1 is not initial.
      s_vendor_oa-central_data-address-postal-datax-sort1 = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-langu is not initial.
      s_vendor_oa-central_data-address-postal-datax-langu = lc_x.
    endif.

    if s_vendor_oa-central_data-central-data-stkzu is not initial.
      s_vendor_oa-central_data-central-datax-stkzu = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-street is not initial.
      s_vendor_oa-central_data-address-postal-datax-street = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-city is not initial.
      s_vendor_oa-central_data-address-postal-datax-city = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-country is not initial.
      s_vendor_oa-central_data-address-postal-datax-country = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-region is not initial.
      s_vendor_oa-central_data-address-postal-datax-region = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-postl_cod1 is not initial.
      s_vendor_oa-central_data-address-postal-datax-postl_cod1 = lc_x.
    endif.

    s_vendor_oa-header-object_task = 'I'.

    append s_vendor_oa to i_vendor_oa.

  endloop.

  "Crear Vendor HIJO
  s_master_data_oa-vendors = i_vendor_oa.

  call method vmd_ei_api=>maintain_bapi(
    exporting
      iv_test_run            = ''
      is_master_data         = s_master_data_oa
    importing
      es_master_data_correct = s_master_data_correct_oa
      es_message_defective   = s_message_defective_oa ).

  if s_master_data_correct_oa-vendors is not initial.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = error_commit.

    "LLenado de estructura para MODIFICAR PADRE con HIJO
    loop at s_master_data_correct_oa-vendors into s_lifnr_oa.

      s_vendor-header-object_task = 'M'.
      s_vendor-header-object_instance-lifnr = lv_lifnr.

      s_functions-task           = 'I'.
      s_functions-data_key-parvw = 'BA'.
      s_functions-data-partner   = s_lifnr_oa-header-object_instance-lifnr.
      s_functions-datax-partner  = lc_x.
      append s_functions to i_functions.

      s_purchasing-functions-functions = i_functions.
      s_purchasing-task = 'M'.
      s_purchasing-data_key-ekorg = ls_partner_pull-ekorg.
      append s_purchasing to i_purchasing.
      s_vendor-purchasing_data-purchasing = i_purchasing.

      append s_vendor to i_vendor.

      "Actualizar Vendor PADRE
      s_master_data-vendors = i_vendor.

      call method vmd_ei_api=>maintain_bapi(
        exporting
          iv_test_run            = ''
          is_master_data         = s_master_data
        importing
          es_master_data_correct = s_master_data_correct
          es_message_defective   = s_message_defective ).

      if s_message_defective-is_error is initial.
        call function 'BAPI_TRANSACTION_COMMIT'
          exporting
            wait   = 'X'
          importing
            return = error_commit.
      endif.

      clear: s_master_data, s_functions, s_purchasing, s_vendor.
      refresh: i_functions, i_purchasing, i_vendor.

    endloop.

  endif.

  "Guardar log de errores OA correlativo row
  loop at s_message_defective_oa-messages into ls_messages_oa where type eq 'E'.
    ls_log_oa-internal_id = ls_partner_pull-internal_id.
    ls_log_oa-lifnr       = lv_lifnr.
    ls_log_oa-oa_row      = ls_messages_oa-row.
    ls_log_oa-message     = ls_messages_oa-message.
    append ls_log_oa to lt_log_oa.

    modify zordadd_log from table lt_log_oa.
    commit work and wait.
    flag_oa = 'X'.
  endloop.
  clear: ls_log_oa.
  refresh: lt_log_oa.


  "Limpieza para procesar correctamente el siguiente PADRE
  refresh: i_functions, i_purchasing, i_vendor.
  clear: s_vendor, s_master_data, s_message_defective, s_master_data_correct, error_commit.
  free: s_master_data, s_master_data_correct, s_message_defective.

endform.                    " F_ORDERING_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  F_FUTURE_CREDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_future_credit.



  clear: ls_partner_future, ls_header.
  refresh: lt_lines.

  select single *
    from zpartner_future
    into ls_partner_future
    where internal_id eq ls_partner_pull-internal_id.

  if sy-subrc eq 0.

    ls_header-tdobject = 'LFA1'.
    ls_header-tdname   = lv_lifnr.
    ls_header-tdid     = '0003'.
    ls_header-tdspras  = 'S'.

    ls_lines-tdformat = '*'.
    ls_lines-tdline   = 'BANCO INTERMEDIARIO'.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-interbank_line1.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-interbank_line2.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-interbank_line3.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-interbank_line4.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-interbank_line5.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ''.
    append ls_lines to lt_lines.

    ls_lines-tdformat = '/'.
    ls_lines-tdline   = 'BANCO RECEPTOR'.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-recbank_line1.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-recbank_line2.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-recbank_line3.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-recbank_line4.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ''.
    append ls_lines to lt_lines.

    ls_lines-tdformat = '/'.
    ls_lines-tdline   = 'BENEFICIARIO FINAL'.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-finalben_line1.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-finalben_line2.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-finalben_line3.
    append ls_lines to lt_lines.
    ls_lines-tdformat = '/'.
    ls_lines-tdline   = ls_partner_future-finalben_line4.
    append ls_lines to lt_lines.

    call function 'SAVE_TEXT'
      exporting
        client          = sy-mandt
        header          = ls_header
        insert          = 'X'
        savemode_direct = 'X'
      tables
        lines           = lt_lines.

  endif.

endform.                    " F_FUTURE_CREDIT


form f_centraldata_bank_v1.

  clear: s_bank, ls_partner_bank.
  refresh: i_bank, lt_partner_bank.

  data: lv_count type char1.

  select *
    from zpartner_bank
    into table lt_partner_bank
    where internal_id in lt_id.

  "Agregar banco para future credit
  if ls_partner_pull-fut_credit eq 'X'.

    select single *
      from zpartner_future
      into ls_partner_future
      where internal_id eq ls_partner_pull-internal_id.

    if sy-subrc eq 0.
      select single bankl
        from bnka
        into lv_bankl
        where banks = ls_partner_future-banks
          and bankl = ls_partner_future-bankl.

      if sy-subrc <> 0. "No existe, se debería crear primero.
        ls_bank_address-bank_name  = ls_partner_future-banka.
        ls_bank_address-street     = ls_partner_future-stras.
        ls_bank_address-city       = ls_partner_future-ort01.
        ls_bank_address-region     = ls_partner_future-banks.
*        ls_bank_address-swift_code = ls_partner_future-swift.

        call function 'BAPI_BANK_CREATE'
          exporting
            bank_ctry    = ls_partner_future-banks
            bank_key     = ls_partner_future-bankl
            bank_address = ls_bank_address
          importing
            return       = error_commit.

        if error_commit-number = '000'.
          call function 'BAPI_TRANSACTION_COMMIT'
            importing
              return = error_commit.
        endif.

      endif.

      s_bank-task = 'I'.
      s_bank-data_key-banks = ls_partner_future-banks.
      s_bank-data_key-bankl = ls_partner_future-bankl.
      s_bank-data_key-bankn = ls_partner_future-bankn.

      s_bank-data-koinh = ls_partner_future-koinh.  "Account Holder Name
      if s_bank-data-koinh is not initial.
        s_bank-datax-koinh = lc_x.
      endif.

      s_bank-data-bvtyp = ls_partner_future-waers(3).  "Currency
      if s_bank-data-bvtyp is not initial.
        s_bank-datax-bvtyp = lc_x.
      endif.

      append s_bank to i_bank.

    endif.
  endif.

  clear: s_bank, lv_bankl.

  loop at lt_partner_bank into ls_partner_bank.

    select single bankl
      from bnka
      into lv_bankl
      where banks = ls_partner_bank-banks
        and bankl = ls_partner_bank-bankl.

    if sy-subrc <> 0. "No existe, se debería crear primero.
      ls_bank_address-bank_name  = ls_partner_bank-name.
      ls_bank_address-street     = ls_partner_bank-address.
      ls_bank_address-city       = ls_partner_bank-city.
      ls_bank_address-region     = ls_partner_bank-banks.
      ls_bank_address-swift_code = ls_partner_bank-swift.

      call function 'BAPI_BANK_CREATE'
        exporting
          bank_ctry    = ls_partner_bank-banks
          bank_key     = ls_partner_bank-bankl
          bank_address = ls_bank_address
        importing
          return       = error_commit.

      if error_commit-number = '000'.
        call function 'BAPI_TRANSACTION_COMMIT'
          importing
            return = error_commit.
      endif.

    endif.

    if ls_partner_bank-iban is not initial.
      s_bank-data-iban  = ls_partner_bank-iban.
      s_bank-datax-iban = lc_x.
    endif.

*CR SLP009 - Bank acount > 18 caracteres

*f s_bank-data_key-bankn

    s_bank-data_key-banks = ls_partner_bank-banks.
    s_bank-data_key-bankl = ls_partner_bank-bankl.
    s_bank-data_key-bankn = ls_partner_bank-bankn.

    s_bank-data-koinh = ls_partner_bank-koinh.
    s_bank-data-bvtyp = ls_partner_bank-bvtyp.

    if s_bank-data-koinh is not initial.
      s_bank-datax-koinh = lc_x.
    endif.

    if s_bank-data-bvtyp is not initial.
      s_bank-datax-bvtyp = lc_x.
    endif.

    s_bank-task = 'I'.

    "Solo permitir maixmo 3 bancos
    if lv_count le '2'.
      append s_bank to i_bank.
*       s_vendor-central_data-bankdetail-bankdetails = i_bank.
    endif.

    lv_count = lines( i_bank ).

    clear: s_bank, s_bank-data-iban, s_bank-datax-iban.

  endloop.

  s_vendor-central_data-bankdetail-bankdetails = i_bank.

  "Verficia si repetite la misma moneda en los bancos.
  clear: ls_currency, lv_bvtyp, flag_bank.
  refresh: lt_currency.

  "Toma todas las monedas de i_bank.
  loop at i_bank into s_bank.
    ls_currency-bvtyp = s_bank-data-bvtyp.
    append ls_currency to lt_currency.
  endloop.

  "Filtra hasta encontrar 2 monedas iguales seguidas
  if lt_currency is not initial.
    sort lt_currency.
    loop at lt_currency into ls_currency.
      if lv_bvtyp eq ls_currency-bvtyp.
        flag_bank = 'X'.
        exit.
      endif.
      lv_bvtyp = ls_currency-bvtyp.
    endloop.
  endif.

  refresh: i_bank.
  free: i_bank.
  clear: lv_bankl, lv_count.

endform.


form f_ordering_address_v2.

  "Limpiar estructura HIJO
  clear: s_vendor_oa, s_master_data_oa, s_master_data_correct_oa, s_message_defective_oa, ls_partner_ordadd.
  refresh: i_vendor_oa, lt_partner_ordadd.

  select * from zpartner_ordadd into table lt_partner_ordadd
    where internal_id in lt_id.

  loop at lt_partner_ordadd into ls_partner_ordadd.

    s_vendor_oa-central_data-central-data-ktokk             = 'VADD'.
    s_vendor_oa-central_data-address-task                   = 'I'.

    s_vendor_oa-central_data-address-postal-data-title      = ls_partner_pull-anred.
    s_vendor_oa-central_data-central-data-brsch             = ls_partner_pull-brsch.
    s_vendor_oa-central_data-address-postal-data-name       = ls_partner_pull-name1.
    s_vendor_oa-central_data-address-postal-data-sort1      = ls_partner_pull-sortl.
    s_vendor_oa-central_data-address-postal-data-langu      = ls_partner_pull-spras.
    s_vendor_oa-central_data-central-data-stkzu             = ls_partner_pull-stkzu.

    s_vendor_oa-central_data-address-postal-data-street     = ls_partner_ordadd-street.
    s_vendor_oa-central_data-address-postal-data-city       = ls_partner_ordadd-city.
    s_vendor_oa-central_data-address-postal-data-country    = ls_partner_ordadd-country.
    s_vendor_oa-central_data-address-postal-data-region     = ls_partner_ordadd-region.
    s_vendor_oa-central_data-address-postal-data-postl_cod1 = ls_partner_ordadd-postcode.

    if s_vendor_oa-central_data-central-data-ktokk is not initial.
      s_vendor_oa-central_data-central-datax-ktokk = lc_x.
    endif.

    if s_vendor_oa-central_data-central-data-brsch is not initial.
      s_vendor_oa-central_data-central-datax-brsch = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-name is not initial.
      s_vendor_oa-central_data-address-postal-datax-name = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-sort1 is not initial.
      s_vendor_oa-central_data-address-postal-datax-sort1 = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-langu is not initial.
      s_vendor_oa-central_data-address-postal-datax-langu = lc_x.
    endif.

    if s_vendor_oa-central_data-central-data-stkzu is not initial.
      s_vendor_oa-central_data-central-datax-stkzu = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-street is not initial.
      s_vendor_oa-central_data-address-postal-datax-street = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-city is not initial.
      s_vendor_oa-central_data-address-postal-datax-city = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-country is not initial.
      s_vendor_oa-central_data-address-postal-datax-country = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-region is not initial.
      s_vendor_oa-central_data-address-postal-datax-region = lc_x.
    endif.

    if s_vendor_oa-central_data-address-postal-data-postl_cod1 is not initial.
      s_vendor_oa-central_data-address-postal-datax-postl_cod1 = lc_x.
    endif.

    s_vendor_oa-header-object_task = 'I'.

    append s_vendor_oa to i_vendor_oa.

  endloop.

  "Crear Vendor HIJO
  s_master_data_oa-vendors = i_vendor_oa.

  call method vmd_ei_api=>maintain_bapi(
    exporting
      iv_test_run            = ''
      is_master_data         = s_master_data_oa
    importing
      es_master_data_correct = s_master_data_correct_oa
      es_message_defective   = s_message_defective_oa ).

  if s_master_data_correct_oa-vendors is not initial.

    call function 'BAPI_TRANSACTION_COMMIT'
      exporting
        wait   = 'X'
      importing
        return = error_commit.

    "LLenado de estructura para MODIFICAR PADRE con HIJO
    loop at s_master_data_correct_oa-vendors into s_lifnr_oa.

      s_vendor_oa_m-header-object_task = 'M'.
      s_vendor_oa_m-header-object_instance-lifnr = lv_lifnr.

      s_functions_oa_m-task           = 'I'.
      s_functions_oa_m-data_key-parvw = 'BA'.
      s_functions_oa_m-data-partner   = s_lifnr_oa-header-object_instance-lifnr.
      s_functions_oa_m-datax-partner  = lc_x.
      append s_functions_oa_m to i_functions_oa_m.

      s_purchasing_oa_m-functions-functions = i_functions_oa_m.
      s_purchasing_oa_m-task = 'M'.
      s_purchasing_oa_m-data_key-ekorg = ls_partner_pull-ekorg.
      append s_purchasing_oa_m to i_purchasing_oa_m.
      s_vendor_oa_m-purchasing_data-purchasing = i_purchasing_oa_m.

      append s_vendor_oa_m to i_vendor_oa_m.

      "Actualizar Vendor PADRE
      s_master_data_oa_m-vendors = i_vendor_oa_m.

      call method vmd_ei_api=>maintain_bapi(
        exporting
          iv_test_run            = ''
          is_master_data         = s_master_data_oa_m
        importing
          es_master_data_correct = s_master_data_correct_oa_m
          es_message_defective   = s_message_defective_oa_m ).

      if s_message_defective_oa_m-is_error is initial.
        call function 'BAPI_TRANSACTION_COMMIT'
          exporting
            wait   = 'X'
          importing
            return = error_commit.
      endif.

      "En este punto no debe ocurrir ningun error, solo es insertar datos al PADRE.
      clear:   s_vendor_oa_m, s_functions_oa_m, s_purchasing_oa_m.
      refresh: i_vendor_oa_m, i_functions_oa_m, i_purchasing_oa_m.

      clear: s_master_data_oa_m, s_master_data_correct_oa_m, s_message_defective_oa_m.
      free:  s_master_data_oa_m, s_master_data_correct_oa_m, s_message_defective_oa_m.

    endloop.

  endif.

  "Guardar log de errores OA correlativo row
  loop at s_message_defective_oa-messages into ls_messages_oa where type eq 'E'.
    ls_log_oa-internal_id = ls_partner_pull-internal_id.
    ls_log_oa-lifnr       = lv_lifnr.
    ls_log_oa-oa_row      = ls_messages_oa-row.
    ls_log_oa-message     = ls_messages_oa-message.
    append ls_log_oa to lt_log_oa.

    modify zordadd_log from table lt_log_oa.
    commit work and wait.
    flag_oa = 'X'.
  endloop.

  clear: ls_log_oa.
  refresh: lt_log_oa.

*  "Limpieza para procesar correctamente el siguiente PADRE
*  REFRESH: i_functions, i_purchasing, i_vendor.
*  CLEAR: s_vendor, s_master_data, s_message_defective, s_master_data_correct, error_commit.
*  FREE: s_master_data, s_master_data_correct, s_message_defective.

endform.                    " F_ORDERING_ADDRESS_V2
