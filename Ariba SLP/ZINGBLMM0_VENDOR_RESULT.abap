*&---------------------------------------------------------------------*
*& Report  ZINGBLMM0_VENDOR_RESULT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zingblmm0_vendor_result.

data: zco_mdg_bp_rplctco type ref to co_mdg_bp_rplctco,
      l_output type mdg_bp_bp_suitebulk_repl_conf.

data: lt_partner_pull type table of zpartner_pull,
      ls_partner_pull type zpartner_pull,
      l_message type string,
      lt_zpartner_msgs type table of zpartner_msgs,
      ls_zpartner_msgs type zpartner_msgs.

data: lt_bp_suitereplicat type line of mdg_bp_bpsuiterplct_conf_m_tab,
      lt_item type mdg_fnd_log_item,
      lo_ai_system_fault   type ref to cx_ai_system_fault,
      lo_ai_appl_fault     type ref to cx_ai_application_fault,
      lo_mdg_std_msg_fault type ref to cx_mdg_fnd_standard_msg_fault,
      lo_uuid type zdegblmm0_msg_uuid_content,
      lo_id type zdegblmm0_msg_uuid_content,
      lo_creation_date_time type zdegblmm0_global_date_time.


select *
  from zpartner_pull
  into table lt_partner_pull
  where ariba_status eq ' '.

create object zco_mdg_bp_rplctco.


loop at lt_partner_pull into ls_partner_pull. "WHERE ariba_status = ' '.

  clear lt_bp_suitereplicat.
  clear lt_item.
  clear l_output.

  cl_arbcig_common_util=>get_uuid_proxy(
  importing
    uuid   = lo_uuid         ).

  lo_id = lo_uuid.

  replace all occurrences of substring '-' in lo_id with ''.

  lt_bp_suitereplicat-message_header-id-content = lo_id. "Gen 1
  ls_partner_pull-generated_id = lo_id.
  lt_bp_suitereplicat-message_header-uuid-content = lo_uuid. "Gen 2
  ls_partner_pull-generated_uuid = lo_id.
  lt_bp_suitereplicat-message_header-reference_id-content = ls_partner_pull-id. "Referencia 1
  lt_bp_suitereplicat-message_header-reference_uuid-content = ls_partner_pull-uuid. "Referencia 2


*  GET TIME STAMP FIELD lo_creation_date_time.
*  lt_bp_suitereplicat-message_header-creation_date_time = lo_creation_date_time.
*  ls_partner_pull-creation_date_time_gen = lo_creation_date_time. "OJO GENERAR TIMESTAMP

  lt_bp_suitereplicat-message_header-sender_business_system_id = ls_partner_pull-sender_business_system_id.
  lt_bp_suitereplicat-message_header-recipient_business_system_id = ls_partner_pull-recipient_business_system_id. "Referencia 3
  lt_bp_suitereplicat-business_partner-uuid-content = ls_partner_pull-bp_uuid. "Referencia 4
  lt_bp_suitereplicat-business_partner-internal_id = ls_partner_pull-internal_id. "Referencia 5

  lt_bp_suitereplicat-business_partner-supplier-internal_id = ls_partner_pull-internal_id. "Referencia 5

  call function 'CONVERSION_EXIT_ALPHA_INPUT'
    exporting
      input  = ls_partner_pull-lifnr
    importing
      output = ls_partner_pull-lifnr.


*  SELECT * FROM zpartner_msgs INTO TABLE lt_zpartner_msgs.

*  LOOP AT lt_zpartner_msgs INTO ls_zpartner_msgs WHERE internal_id = ls_partner_pull-internal_id.
*    lt_item-note = ls_zpartner_msgs-message.

  lt_item-note = ls_partner_pull-status_msg.

  if ls_partner_pull-process_status <> 4.
    lt_item-severity_code = '3'.
    lt_item-type_id = 'Error en la creación'.

  else.

    lt_item-type_id = 'S018(MDG_BS_BP_DATAREPL)'.
    concatenate 'Proveedor generado con código ' ls_partner_pull-lifnr into lt_item-note.
    lt_item-log_item_note_placeholder_subs-first_placeholder_subst_text = ls_partner_pull-lifnr.
    lt_bp_suitereplicat-business_partner-receiver_internal_id = ls_partner_pull-lifnr.
    lt_bp_suitereplicat-business_partner-supplier-receiver_internal_id = ls_partner_pull-lifnr.

  endif.
  append lt_item to lt_bp_suitereplicat-log-item.
  clear lt_item.

*  ENDLOOP.




  append lt_bp_suitereplicat to l_output-bp_suitebulk_replct_conf-business_partner_suitereplicat.




  if zco_mdg_bp_rplctco is bound.
    try.

        zco_mdg_bp_rplctco->bp_suitebulk_replct_conf( output = l_output   ).

        commit work and wait.

        if sy-subrc = 0.
          ls_partner_pull-ariba_status = 'X'.
          modify zpartner_pull from ls_partner_pull.
          commit work and wait.
        endif.

      catch cx_ai_system_fault .
        message 'System Error'(006) type 'E'.
      catch cx_mdg_fnd_standard_msg_fault .
        message 'Error in executing Enterprise Service'(007) type 'E'.
      catch cx_ai_application_fault .
        message 'Application Error'(008) type 'E'.
    endtry.

  endif.







endloop.

delete from zpartner_msgs.

** AMM INC0081045 31.07.2023 dump en delete table [
call function 'BAPI_TRANSACTION_COMMIT'
  exporting
    wait = 'X'
      " IMPORTING
  ."   RETURN        = RETURN
wait up to 5 seconds.
** AMM INC0081045 31.07.2023 dump en delete table  ]


write: 'Done.'.
