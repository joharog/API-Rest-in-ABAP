method process.
*---------------------------------------------------------------------*
* Local Type Declaration                                              *
*---------------------------------------------------------------------*

* Internal Table Declaration
  data: lt_polling_message   type /arba/polling_message_tab,
* Structure Declaration
        ls_response          type /arba/polling_response1,
* Work Area Declaration
        lw_polling_message   type /arba/polling_message,
* Variable Declaration
        lv_fault_msg         type string,
* Object Declaration
        lo_ai_system_fault   type ref to cx_ai_system_fault,
        lo_ai_appl_fault     type ref to cx_ai_application_fault,
        lo_mdg_std_msg_fault type ref to cx_mdg_fnd_standard_msg_fault.

* Constant Declaration
  constants:
    lc_bp_replicate_request type /arba/inbound_service_name
                            value  'BusinessPartnerSUITEBulkReplicateRequest_In',
    lc_bp_replicate_confirm type /arba/inbound_service_name
                            value  'BusinessPartnerSUITEBulkReplicateConfirmation_In',
    lc_bp_relatnshp_request type /arba/inbound_service_name
                            value  'BusinessPartnerRelationshipSUITEBulkReplicateRequest_In',
    lc_bp_relatnshp_confirm type /arba/inbound_service_name
                            value  'BusinessPartnerRelationshipSUITEBulkReplicateConfirmation_In'.

* Ariba SLP Integration Custom Declartions
  data: ls_suitereplicat           type mdg_bp_bpsuiterplct_req_msg,
        ls_common                  type mdg_bp_bpsuiterplct_req_com,
        ls_bank_details            type mdg_bp_bpsuiterplct_req_bk_det,
        ls_procurement_arrangement type mdg_bp_bpsuiterplrq_procmt_arr,
        ls_tax_number              type mdg_bp_bpsuiterplct_req_tx_no,
        ls_adress_information      type mdg_bp_bpsuiterplct_req_addr_i,
        ls_postal_adress           type mdg_bp_bpsuiterplrq_ai_postl_a,
        ls_telephone               type mdg_bp_bpsuiterplrq_ai_tel,
        ls_generic_custom_field    type /arba/generic_custom_field.

  constants: ct_zterm type char4 value 'Z060',
             ct_abtnr type char4 value '003',
             ct_taxbs type char1 value '0',
             ct_actss type char2 value 'PG',
             ct_bstae type char4 value '0001',
             ct_parvw type char2 value 'PR',
             ct_orgtx type char1 value '2',
             ct_role1 type char6 value 'FLVN00',
             ct_role2 type char6 value 'FLVN01'.

  data: ls_partner_pull type zpartner_pull,
        lt_partner_pull type table of zpartner_pull.

  data: lt_t024w  type table of t024w,
        lt_t001w  type table of t001w,
        lt_t001k  type table of t001k,
        lt_t001b  type table of t001b,
        lt_lfa1   type table of lfa1,
        aux_t001b type table of t001b.

  data: ls_t001b  type t001b,
        ls_t001k  type t001k,
        ls_ramo   type zmmvap_ramo.

  data: lv_year  type char4,
        lv_land1 type land1,
        lv_waers type waers,
        lv_gbdat type char10.
* Ariba SLP Integration Custom Declartions

  free ls_response.

  try.
*Pull the BP Data from Ariba SM
      me->pull_data_from_sm(
        exporting
          is_request    = is_request
        importing
          es_response   = ls_response ).
    catch cx_ai_system_fault into lo_ai_system_fault.
      lv_fault_msg  = lo_ai_system_fault->errortext.
    catch cx_ai_application_fault into lo_ai_appl_fault.
      lv_fault_msg  = lo_ai_appl_fault->get_text( ).
  endtry.

  if ls_response is not initial.
    try.
        free: lt_polling_message[].
*Reading the response from Supplier Manager for BP Request Message
        lt_polling_message = ls_response-polling_response-polling_message.

        loop at lt_polling_message into lw_polling_message.
**
***BusinessPartnerSUITEBulkReplicateRequest_In - JARV
**          IF lw_polling_message-inbound_service_name = lc_bp_replicate_request.
***Trigger Business Partner SUITE Bulk Replicate Request ES
**            me->post_bp_replicate_request(
**              EXPORTING
**                is_polling_message = lw_polling_message ).
*

          read table lw_polling_message-business_partner_suitebulk_rep-business_partner_suitereplicat into ls_suitereplicat index 1.
          if sy-subrc eq 0.

            ls_partner_pull-id                           = ls_suitereplicat-message_header-id-content.
            ls_partner_pull-uuid                         = ls_suitereplicat-message_header-uuid-content.
            ls_partner_pull-creation_date_time_gen       = ls_suitereplicat-message_header-creation_date_time.
            ls_partner_pull-sender_business_system_id    = ls_suitereplicat-message_header-sender_business_system_id.
            ls_partner_pull-recipient_business_system_id = ls_suitereplicat-message_header-recipient_business_system_id.
            ls_partner_pull-internal_id                  = ls_suitereplicat-business_partner-internal_id.

            read table ls_suitereplicat-business_partner-common into ls_common index 1.
            if sy-subrc eq 0.
              ls_partner_pull-anred = ls_common-organisation-name-form_of_address_code-content. "Tratamiento
              ls_partner_pull-name1 = ls_common-organisation-name-first_line_name(35).          "Supplier Name 1
              ls_partner_pull-name2 = ls_common-organisation-name-second_line_name(35).         "Supplier Name 2
              ls_partner_pull-name3 = ls_common-organisation-name-third_line_name(35).          "Supplier Name 3
              ls_partner_pull-name4 = ls_common-organisation-name-fourth_line_name(35).         "Supplier Name 4
              ls_partner_pull-sortl = ls_common-organisation-name-first_line_name(25).          "Concepto de Búsqueda
            endif.

            read table  ls_suitereplicat-business_partner-bank_details into ls_bank_details index 1.
            if sy-subrc eq 0.
              ls_partner_pull-banks = ls_bank_details-bank_directory_reference-bank_country_code.         "Pais de Banco
              ls_partner_pull-bankl = ls_bank_details-bank_directory_reference-bank_internal_id-content.  "Clave de Banco (Bank Name)
              ls_partner_pull-bankn = ls_bank_details-bank_account_id.                                    "Bank Account #
              ls_partner_pull-koinh = ls_bank_details-bank_account_holder_name.                           "Bank Account Holder Name
              ls_partner_pull-waers = ls_bank_details-id.                                                 "Moneda
              ls_partner_pull-bvtyp = ls_bank_details-id.                                                 "ID datos bancarios
              ls_partner_pull-iban  = ls_bank_details-bank_account_standard_id.                           "IBAN

            endif.

            read table  ls_suitereplicat-business_partner-supplier-procurement_arrangement into ls_procurement_arrangement index 1.
            if sy-subrc eq 0.
              ls_partner_pull-ekorg = ls_procurement_arrangement-purchasing_organisation_id.                        "Organización de compras
              ls_partner_pull-inco1 = ls_procurement_arrangement-purchasing_terms-incoterms-classification_code.    "Incoterms 1
              ls_partner_pull-inco2 = ls_procurement_arrangement-purchasing_terms-incoterms-transfer_location_name. "Incoterms 2
*              ls_partner_pull-vsbed = ls_procurement_arrangement-purchasing_terms-transport_service_level_code.     "Condición expedición


              "Integration Logic for Company Code
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
                   where mkoar eq 'K'
                     and toye1 lt lv_year.

                  loop at lt_t001b into ls_t001b.
                    ls_t001b-bukrs = ls_t001b-bukrs+1(3).
                    append ls_t001b to aux_t001b.
                  endloop.

                  clear: ls_t001b.

                  sort lt_t001k by bukrs.
                  delete adjacent duplicates from lt_t001k comparing bukrs.
                  sort lt_t001b by bukrs.
*                  DELETE ADJACENT DUPLICATES FROM LT_T001K COMPARING BUKRS.
                  loop at lt_t001k into ls_t001k.
                    read table aux_t001b into ls_t001b with key bukrs = ls_t001k-bukrs.
                    if sy-subrc eq 0.
                      ls_partner_pull-bukrs = ls_t001b-bukrs.  "Company Code - Sociedad
                      exit.
                    endif.
                  endloop.

                endif.
              endif.
            endif.

            read table ls_suitereplicat-business_partner-tax_number into ls_tax_number index 1.
            if sy-subrc eq 0.
              ls_partner_pull-stcd1_taxid = ls_tax_number-party_tax_id-content. "Tax ID
            endif.

            read table ls_suitereplicat-business_partner-address_information into ls_adress_information index 1.
            if sy-subrc eq 0.

              ls_partner_pull-spras = ls_adress_information-address-communication_preference-correspondence_language_code.

              read table ls_adress_information-address-postal_address into ls_postal_adress index 1.
              if sy-subrc eq 0.
                ls_partner_pull-stras      = ls_postal_adress-street_name.         "Street
                ls_partner_pull-str_suppl1 = ls_postal_adress-street_prefix_name.  "Street2
                ls_partner_pull-pstlz      = ls_postal_adress-street_postal_code.  "Postal Code
                ls_partner_pull-ort01      = ls_postal_adress-district_name.       "City  "ls_postal_adress-city_name
                ls_partner_pull-land1      = ls_postal_adress-country_code.        "Country
                ls_partner_pull-regio      = ls_postal_adress-region_code-content. "State
                ls_partner_pull-time_zone  = ls_postal_adress-time_zone_code.      "Time zone
              endif.

              read table ls_adress_information-address-telephone into ls_telephone index 1.
              if sy-subrc eq 0.
                ls_partner_pull-telf1_phone = ls_telephone-number-subscriber_id.    "Phone
              endif.

            endif.


            data: split01 type char30.
            "Get Custom Fields
            loop at ls_suitereplicat-business_partner-/arba/generic_custom_field into ls_generic_custom_field.
              case ls_generic_custom_field-name.
                when 'XK01ContactTitle'. "Contact Title
*                  DATA: lv_anred1 TYPE anred,
*                        lv_anred2 TYPE anred.
*                  SPLIT ls_generic_custom_field-content AT '(' INTO lv_anred1
*                                                                    ls_partner_pull-anred.
*                  REPLACE ALL OCCURRENCES OF ')' IN ls_partner_pull-anred WITH ''.
                  ls_partner_pull-anred = ls_generic_custom_field-content.
                when 'XK01ContactName'. "Contact First Name
                  ls_partner_pull-namev = ls_generic_custom_field-content.
                when 'XK01ContactLastName'. "Contact Last Name
                  ls_partner_pull-name1_contact = ls_generic_custom_field-content.
                when 'XK01ContactEmail'.
                  ls_partner_pull-smtp_addr = ls_generic_custom_field-content.
                when 'XK01ContactPhone'. "Contact Phone
                  ls_partner_pull-telf1_contact = ls_generic_custom_field-content.

                when 'XK01BankRegion'. "Bank region
                  ls_partner_pull-bkprovz = ls_generic_custom_field-content.

                when 'XK01BankCity'. "Bank city
                  ls_partner_pull-bkort01 = ls_generic_custom_field-content.


                when 'XK01BankAddress'. "Bank address
                  ls_partner_pull-bkstras = ls_generic_custom_field-content.

                when 'TaxNumberType'. "Tax number type - Tipo de identificación fiscal
                  if ls_partner_pull-land1 eq 'CO'.
                    ls_partner_pull-stcd1_taxtype = ls_generic_custom_field-content.
                  endif.
                when 'XK01Industry'. "Ramo
                  clear: split01.
                  split ls_generic_custom_field-content at '(' into split01
                                                               ls_partner_pull-brsch.
                  replace all occurrences of ')' in ls_partner_pull-brsch with ''.
*                  ls_partner_pull-brsch = ls_generic_custom_field-content.
                when others.
              endcase.
            endloop.

            select single brtxt from t016t into ls_partner_pull-mcod2  "Concepto de Búsqueda 2
              where brsch eq ls_partner_pull-brsch.

            "Integration Logic for TE de / Recon. Account - Cuenta asociada / Cash mgmnt group - Grupo de Tesorería
            select single land1 waers
              from t001
              into (lv_land1, lv_waers)
              where bukrs eq ls_partner_pull-bukrs.

            select single *
              from zmmvap_ramo
              into ls_ramo
              where brsch eq ls_partner_pull-brsch.

            if lv_land1 eq ls_partner_pull-land1.
              "Nacionales
              ls_partner_pull-fdgrv = 'A1'. "Domestic

              if ls_partner_pull-land1 ne 'CO'.
                ls_partner_pull-stcd1_taxtype = '04'. "Tax number type - Tipo de identificación fiscal
              endif.


              if ls_ramo-tipo eq 'P'.
                ls_partner_pull-ktokk = 'VPRN'.     "Proveedores Nacionales
                ls_partner_pull-akont = '21041001'. "Proveedores Nacionales Otro
              else.
                ls_partner_pull-ktokk = 'VADN'.     "Acreedores Div Nacionales
                ls_partner_pull-akont = '21051001'. "Acreedores diversos Nacionales Otros
              endif.
            else.
              "Extranjeros
              ls_partner_pull-fdgrv = 'A2'. "Foreign

              if ls_partner_pull-land1 ne 'CO'.
                ls_partner_pull-stcd1_taxtype = '05'. "Tax number type - Tipo de identificación fiscal
              endif.

              if ls_ramo-tipo eq 'P'.
                ls_partner_pull-ktokk = 'VPRE'.     "Proveedores Extranjeros
                ls_partner_pull-akont = '21041002'. "Proveedores Extranjeros Otros
              else.
                ls_partner_pull-ktokk = 'VADE'.     "Acreedores Div Extranjeros
                ls_partner_pull-akont = '21051002'. "Acreedores diversos Extranjeros Otros
              endif.
            endif.

            ls_partner_pull-stkzu = abap_true. "Sales/pur.tax - Imp. Vol neg.
            ls_partner_pull-zterm = ct_zterm.  "Condición de Pago (50,59)
            ls_partner_pull-reprf = abap_true. "Chk double inv. - Verif. Fact. Dup.
*            ls_partner_pull-waers = lv_waers.  "Moneda de pedido - Order currency
            ls_partner_pull-abtnr = ct_abtnr.  "Department
            ls_partner_pull-taxbs = ct_taxbs.  "Tax base - Base Imp
            ls_partner_pull-actss = ct_actss.  "Soc. Ins. Code - Cód.Seg.Social
            write sy-datum to lv_gbdat.
            ls_partner_pull-gbdat = lv_gbdat.  "Date of birth - Fe.nacimiento
            ls_partner_pull-xersy = abap_true. "Autofacturac.entrega
            ls_partner_pull-kzaut = abap_true. "Pedido automático
            ls_partner_pull-webre = abap_true. "Verific.fact.base EM
            ls_partner_pull-bstae = ct_bstae.  "Control confirmación
            ls_partner_pull-parvw = ct_parvw.  "Función interlocutor
            ls_partner_pull-orgtx = ct_orgtx.  "Tipo BP
            ls_partner_pull-role1 = ct_role1.  "rol FLVN00
            ls_partner_pull-role2 = ct_role2.  "rol FLVN01


            "Type of Industry
            if ls_partner_pull-land1 eq 'MX'.
*            ls_partner_pull-j_1kftind = vendor.vendorinfoext.industrytypename.
            else.
              case ls_partner_pull-anred.
                when '002'.
                  ls_partner_pull-j_1kftind = 'Personas Físicas'.
                when '003'.
                  ls_partner_pull-j_1kftind = 'Personas Morales'.
              endcase.
            endif.

            "Tax type - Clase impuesto
            if ls_partner_pull-land1 eq 'CO'.
              case ls_partner_pull-anred.
                when '002'.
                  ls_partner_pull-fityp = 'PN'. "Persona Natural
                when '003'.
                  ls_partner_pull-fityp = 'PJ'. "Persona Jurídica
              endcase.
            else.
              ls_partner_pull-fityp = '85'. "Otros
            endif.

            "Persona Física
            case ls_partner_pull-anred.
              when '002'.
                ls_partner_pull-stkzn = abap_true.  "Señor
              when '003'.
                ls_partner_pull-stkzn = abap_false. "Empresa
            endcase.

            "Integration Logic for Bank Payment Methods
            select single zwels hbkid
              from zpayment_methods
              into (ls_partner_pull-zwels, "Payment methods - Vía de Pago
                    ls_partner_pull-hbkid) "House Bank - Banco propio
              where bukrs eq ls_partner_pull-bukrs
                and ekorg eq ls_partner_pull-ekorg.

          endif.

          if ls_partner_pull is not initial.
            ls_partner_pull-process_status = '1'. "Vendor creation status 1:New rec
            append ls_partner_pull to lt_partner_pull.
          endif.

          clear: ls_partner_pull,
                 ls_suitereplicat,
                 ls_common,
                 ls_bank_details,
                 ls_procurement_arrangement,
                 ls_tax_number,
                 ls_adress_information,
                 ls_postal_adress,
                 ls_telephone,
                 ls_generic_custom_field,
                 ls_t001b,
                 ls_t001k,
                 ls_ramo,
                 lv_year,
                 lv_land1,
                 lv_waers.

          refresh: lt_t001w,
                   lt_t001k,
                   lt_t001b,
                   lt_lfa1,
                   aux_t001b.

*Reading the response from Supplier Manager for BP Confirmation Message
*
*          IF lw_polling_message-inbound_service_name = lc_bp_replicate_confirm.
**Trigger Business Partner SUITE Bulk Replicate Confirmation ES
*            me->post_bp_replicate_confirm(
*              EXPORTING
*                is_polling_message = lw_polling_message ).
*          ENDIF.
*
**Reading the response from Supplier Manager for Relationship Request message
*
*          IF lw_polling_message-inbound_service_name = lc_bp_relatnshp_request.
**Trigger Business Partner Relationship SUITE Bulk Replicate Request ES
*            me->post_bp_relatnshp_request(
*              EXPORTING
*                      is_polling_message = lw_polling_message ).
*          ENDIF.
*
**Reading the response from Supplier Manager for Relationship Confirmation Message
*
*          IF lw_polling_message-inbound_service_name = lc_bp_relatnshp_confirm.
**Trigger Business Partner Relationship SUITE Bulk Replicate Confirmation ES
*            me->post_bp_relatnshp_confirm(
*             EXPORTING
*               is_polling_message = lw_polling_message ) .
*          ENDIF.
          clear : lw_polling_message.

        endloop.

        if lt_partner_pull[] is not initial.

          modify zpartner_pull from table lt_partner_pull.
          wait up to 1 seconds.
          commit work and wait.
          wait up to 1 seconds.
          refresh lt_partner_pull.

*          IF sy-subrc EQ 0.
*            SUBMIT zcreatevendor AND RETURN.
*          ENDIF.

        endif.




      catch cx_mdg_fnd_standard_msg_fault into lo_mdg_std_msg_fault.
        lv_fault_msg  = lo_mdg_std_msg_fault->get_text( ).
        raise exception type cx_mdg_fnd_standard_msg_fault.
    endtry.
  endif.

endmethod.
