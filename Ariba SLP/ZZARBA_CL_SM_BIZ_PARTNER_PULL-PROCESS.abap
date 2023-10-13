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
        ls_zterm                   type dzterm,
        ls_bank_details            type mdg_bp_bpsuiterplct_req_bk_det,
        ls_procurement_arrangement type mdg_bp_bpsuiterplrq_procmt_arr,
        ls_tax_number              type mdg_bp_bpsuiterplct_req_tx_no,
        ls_adress_information      type mdg_bp_bpsuiterplct_req_addr_i,
        ls_postal_adress           type mdg_bp_bpsuiterplrq_ai_postl_a,
        ls_telephone               type mdg_bp_bpsuiterplrq_ai_tel,
        ls_generic_custom_field    type /arba/generic_custom_field,
        ls_accounting_information  type mdg_bp_bpsuiterplrq_acctg_info.

  constants: ct_zterm type char4 value 'Z060',
             ct_abtnr type char4 value '0003',
             ct_taxbs type char1 value '0',
             ct_actss type char2 value 'PG',
             ct_bstae type char4 value '0001',
             ct_parvw type char2 value 'PR',
             ct_orgtx type char1 value '2',
             ct_role1 type char6 value 'FLVN00',
             ct_role2 type char6 value 'FLVN01'.

  data: ls_partner_pull    type zpartner_pull,
        ls_partner_whtax   type zpartner_whtax,
        ls_partner_bank    type zpartner_bank,
        ls_partner_contact type zpartner_contact,
        ls_partner_ordadd  type zpartner_ordadd,
        ls_partner_future  type zpartner_future,
        lt_partner_pull    type table of zpartner_pull,
        lt_partner_whtax   type table of zpartner_whtax,
        lt_partner_bank    type table of zpartner_bank,
        lt_partner_contact type table of zpartner_contact,
        lt_partner_ordadd  type table of zpartner_ordadd,
        lt_partner_future  type table of zpartner_future.

  data: lt_t024w  type table of t024w,
        lt_t001w  type table of t001w,
        lt_t001k  type table of t001k,
        lt_t001b  type table of t001b,
        lt_lfa1   type table of lfa1,
        aux_t001b type table of t001b,
        ls_aux_t001b type t001b.

  data :  begin of t_bukrs,
              bukrs type bukrs,
              land1 type land1,
              conteo type i,
            end of t_bukrs.

  data: it_bukrs like table of t_bukrs,
        it_bukrs_c like table of t_bukrs,
        wa_bukrs like t_bukrs,
        wa1_bukrs like t_bukrs,
        lv_max_land_cont type i,
        lv_max_land type land1,
        lv_nal type c.

  data: ls_t001b  type t001b,
        ls_t001k  type t001k,
        ls_ramo   type zmmvap_ramo,
        ls_stcd1_col type stcd1.

  data: lv_year  type char4,
        lv_land1 type land1,
        lv_waers type waers,
        lv_gbdat type gbdat,
        lv_tabix type string.

  data: lv_bankkey1 type bankl,
        lv_bankkey2 type bankl,
        lv_bankkey3 type bankl.

  data: ls_ordadd1 type zpartner_ordadd,
        ls_ordadd2 type zpartner_ordadd,
        ls_ordadd3 type zpartner_ordadd,
        ls_ordadd4 type zpartner_ordadd,
        ls_ordadd5 type zpartner_ordadd,
        ls_whtax1 type zpartner_whtax,
        ls_whtax2 type zpartner_whtax,
        ls_whtax3 type zpartner_whtax,
        ls_whtax4 type zpartner_whtax,
        ls_whtax5 type zpartner_whtax,
        ls_whtax6 type zpartner_whtax,
        ls_contact1 type zpartner_contact,
        ls_contact2 type zpartner_contact,
        ls_contact3 type zpartner_contact,
        ls_contact4 type zpartner_contact.

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
          clear: ls_stcd1_col.

          read table lw_polling_message-business_partner_suitebulk_rep-business_partner_suitereplicat into ls_suitereplicat index 1.
          if sy-subrc eq 0.

            "Revisa que el registro exista
            select single * from zpartner_pull
              into ls_partner_pull
              where internal_id = ls_suitereplicat-business_partner-internal_id.

            "Si no existe, se crea como nuevo Status 1
            if sy-subrc = 0.
              ls_partner_pull-process_status = '1'.
              ls_partner_pull-ariba_status = ' '.
            endif.

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

            read table  ls_suitereplicat-business_partner-supplier-procurement_arrangement into ls_procurement_arrangement index 1.
            if sy-subrc eq 0.
              ls_partner_pull-ekorg = ls_procurement_arrangement-purchasing_organisation_id.                        "Organización de compras
              ls_partner_pull-inco1 = ls_procurement_arrangement-purchasing_terms-incoterms-classification_code.    "Incoterms 1
              ls_partner_pull-inco2 = ls_procurement_arrangement-purchasing_terms-incoterms-transfer_location_name. "Incoterms 2
              ls_partner_pull-vsbed = ls_procurement_arrangement-purchasing_terms-transport_service_level_code.     "Condición expedición

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
                   where mkoar eq 'K' and
                         toye1 ge lv_year.

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
                    read table aux_t001b into ls_aux_t001b with key bukrs = ls_t001k-bukrs.
                    if sy-subrc eq 0.
                      wa_bukrs-bukrs = ls_aux_t001b-bukrs.  "Company Code - Sociedad
                      append wa_bukrs to it_bukrs.
                    endif.
                  endloop.

                endif.
              endif.

            endif.

            read table ls_suitereplicat-business_partner-tax_number into ls_tax_number index 1.
            if sy-subrc eq 0.
              ls_partner_pull-stcd1_taxid = ls_tax_number-party_tax_id-content. "Tax ID
            endif.

            read table ls_suitereplicat-business_partner-tax_number into ls_tax_number index 2.
            if sy-subrc eq 0.
              ls_partner_pull-lfa1_stcd2 = ls_tax_number-party_tax_id-content. "Tax ID
            endif.

            read table ls_suitereplicat-business_partner-address_information into ls_adress_information index 1.
            if sy-subrc eq 0.

              call function 'CONVERSION_EXIT_ISOLA_INPUT'
                exporting
                  input  = ls_adress_information-address-communication_preference-correspondence_language_code
                importing
                  output = ls_partner_pull-spras.

              read table ls_adress_information-address-postal_address into ls_postal_adress index 1.
              if sy-subrc eq 0.
                ls_partner_pull-street_suffix_name = ls_postal_adress-street_suffix_name. "Calle4
                ls_partner_pull-street_prefix_name = ls_postal_adress-street_prefix_name. "Calle1
                ls_partner_pull-district_name = ls_postal_adress-district_name.
                ls_partner_pull-city_name     = ls_postal_adress-city_name.
                ls_partner_pull-stras      = ls_postal_adress-street_name.         "Street
                ls_partner_pull-house_id   = ls_postal_adress-house_id.            "Street
                ls_partner_pull-pstlz      = ls_postal_adress-street_postal_code.  "Postal Code
                ls_partner_pull-ort01      = ls_postal_adress-district_name.       "City  "ls_postal_adress-city_name
                ls_partner_pull-land1      = ls_postal_adress-country_code.        "Country
                ls_partner_pull-regio      = ls_postal_adress-region_code-content. "State
                ls_partner_pull-time_zone  = ls_postal_adress-time_zone_code.      "Time zone
                ls_partner_pull-ort02      = ls_postal_adress-district_name.       "Time zone
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
                  ls_partner_pull-anred_contact = ls_generic_custom_field-content.
                when 'XK01ContactName'. "Contact First Name
                  ls_partner_pull-namev_contact = ls_generic_custom_field-content.
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
                when 'XK01BankName'. "Bank name
                  ls_partner_pull-banka = ls_generic_custom_field-content.
                when 'XK01BankAddress'. "Bank address
                  ls_partner_pull-bkstras = ls_generic_custom_field-content.

                when 'XK01BankKey1'. "Bank Key1
                  lv_bankkey1 = ls_generic_custom_field-content.
                when 'XK01BankKey2'. "Bank Key2
                  lv_bankkey2 = ls_generic_custom_field-content.
                when 'XK01BankKey3'. "Bank Key3
                  lv_bankkey3 = ls_generic_custom_field-content.

                when 'TaxNumberType'. "Tax number type - Tipo de identificación fiscal
                  if ls_partner_pull-land1 eq 'CO'.
                    ls_stcd1_col = ls_generic_custom_field-content.
                  endif.

                when 'XK01IndustryType'. "Tax number type - Tipo de identificación fiscal
                  if ls_partner_pull-land1 eq 'MX'.
                    ls_partner_pull-j_1kftind = ls_generic_custom_field-content.
                  endif.

                when 'XK01Industry'. "Ramo
*                  CLEAR: split01.
*                  SPLIT ls_generic_custom_field-content AT '(' INTO split01
*                                                               ls_partner_pull-brsch.
*                  REPLACE ALL OCCURRENCES OF ')' IN ls_partner_pull-brsch WITH ''.
                  ls_partner_pull-brsch = ls_generic_custom_field-content.

                when 'XK01PaymentTerm'.
                  ls_zterm = ls_generic_custom_field-content.


                when 'CheckAdd'.
                  if ls_generic_custom_field-content eq 'false'.
                    ls_partner_pull-check_add = 'X'.            "Se va marcado para guarda en ZTCGFIN_DIR_ALTERNA
                  else.
                    ls_partner_pull-check_add = ''.
                  endif.

                when 'CheckAddStreet'.
                  ls_partner_pull-ztag_street = ls_generic_custom_field-content.

                when 'CheckAddHouse'.
                  ls_partner_pull-ztag_house_num1 = ls_generic_custom_field-content.

                when 'CheckAddCity'.
                  ls_partner_pull-ztag_city1 = ls_generic_custom_field-content.

                when 'CheckAddCountry'.
                  ls_partner_pull-ztag_country = ls_generic_custom_field-content.

                when 'CheckAddRegion'.
                  ls_partner_pull-ztag_region = ls_generic_custom_field-content.

                when 'CheckAddPostC'.
                  ls_partner_pull-ztag_post_code = ls_generic_custom_field-content.


*SLP006
                when 'FutCredit'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_partner_pull-fut_credit = 'X'.
                  else.
                    ls_partner_pull-fut_credit = ''.
                  endif.

                when 'FutCreditAcctHold'.
                  ls_partner_future-koinh = ls_generic_custom_field-content.
                when 'FutCreditBankAcc'.
                  ls_partner_future-bankn = ls_generic_custom_field-content.
                when 'FutCreditBankAddress'.
                  ls_partner_future-stras = ls_generic_custom_field-content.
                when 'FutCreditBankCity'.
                  ls_partner_future-ort01 = ls_generic_custom_field-content.
                when 'FutCreditBankKey'.
                  ls_partner_future-bankl = ls_generic_custom_field-content.
                when 'FutCreditBankName'.
                  ls_partner_future-banka = ls_generic_custom_field-content.
                when 'FutCreditCountry'.
                  ls_partner_future-banks = ls_generic_custom_field-content.
                when 'FutCreditCurrency'.
                  ls_partner_future-waers = ls_generic_custom_field-content(3).

                when 'FutCreditInterBank'.
                  split ls_generic_custom_field-content at cl_abap_char_utilities=>newline
                  into  ls_partner_future-interbank_line1
                        ls_partner_future-interbank_line2
                        ls_partner_future-interbank_line3
                        ls_partner_future-interbank_line4
                        ls_partner_future-interbank_line5.

                when 'FutCreditRecBank'.
                  split ls_generic_custom_field-content at cl_abap_char_utilities=>newline
                  into  ls_partner_future-recbank_line1
                        ls_partner_future-recbank_line2
                        ls_partner_future-recbank_line3
                        ls_partner_future-recbank_line4.

                when 'FutCreditFinalBen'.
                  split ls_generic_custom_field-content at cl_abap_char_utilities=>newline
                  into  ls_partner_future-finalben_line1
                        ls_partner_future-finalben_line2
                        ls_partner_future-finalben_line3
                        ls_partner_future-finalben_line4.
*SLP006

*SLP001
                when 'OrdAdd'.
                  if ls_generic_custom_field-content eq 'true'.
                    ls_partner_pull-ordadd = 'X'.
                  endif.
                when 'OrdAddStreet1'.
                  ls_ordadd1-street = ls_generic_custom_field-content.
                when 'OrdAddStreet2'.
                  ls_ordadd2-street = ls_generic_custom_field-content.
                when 'OrdAddStreet3'.
                  ls_ordadd3-street = ls_generic_custom_field-content.
                when 'OrdAddStreet4'.
                  ls_ordadd4-street = ls_generic_custom_field-content.
                when 'OrdAddStreet5'.
                  ls_ordadd5-street = ls_generic_custom_field-content.
                when 'OrdAddCity1'.
                  ls_ordadd1-city = ls_generic_custom_field-content.
                when 'OrdAddCity2'.
                  ls_ordadd2-city = ls_generic_custom_field-content.
                when 'OrdAddCity3'.
                  ls_ordadd3-city = ls_generic_custom_field-content.
                when 'OrdAddCity4'.
                  ls_ordadd4-city = ls_generic_custom_field-content.
                when 'OrdAddCity5'.
                  ls_ordadd5-city = ls_generic_custom_field-content.
                when 'OrdAddCountry1'.
                  ls_ordadd1-country = ls_generic_custom_field-content.
                when 'OrdAddCountry2'.
                  ls_ordadd2-country = ls_generic_custom_field-content.
                when 'OrdAddCountry3'.
                  ls_ordadd3-country = ls_generic_custom_field-content.
                when 'OrdAddCountry4'.
                  ls_ordadd4-country = ls_generic_custom_field-content.
                when 'OrdAddCountry5'.
                  ls_ordadd5-country = ls_generic_custom_field-content.
                when 'OrdAddRegion1'.
                  ls_ordadd1-region = ls_generic_custom_field-content.
                when 'OrdAddRegion2'.
                  ls_ordadd2-region = ls_generic_custom_field-content.
                when 'OrdAddRegion3'.
                  ls_ordadd3-region = ls_generic_custom_field-content.
                when 'OrdAddRegion4'.
                  ls_ordadd4-region = ls_generic_custom_field-content.
                when 'OrdAddRegion5'.
                  ls_ordadd5-region = ls_generic_custom_field-content.
                when 'OrdAddPostCode1'.
                  ls_ordadd1-postcode = ls_generic_custom_field-content.
                when 'OrdAddPostCode2'.
                  ls_ordadd2-postcode = ls_generic_custom_field-content.
                when 'OrdAddPostCode3'.
                  ls_ordadd3-postcode = ls_generic_custom_field-content.
                when 'OrdAddPostCode4'.
                  ls_ordadd4-postcode = ls_generic_custom_field-content.
                when 'OrdAddPostCode5'.
                  ls_ordadd5-postcode = ls_generic_custom_field-content.
*SLP001

                when 'WithholdingCountry'.
                  ls_whtax1-countrycode = ls_generic_custom_field-content.
                  ls_whtax2-countrycode = ls_generic_custom_field-content.
                  ls_whtax3-countrycode = ls_generic_custom_field-content.
                  ls_whtax4-countrycode = ls_generic_custom_field-content.
                  ls_whtax5-countrycode = ls_generic_custom_field-content.
                  ls_whtax6-countrycode = ls_generic_custom_field-content.
                when 'WithholdingSubjectTo1'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax1-subjectto = 'X'.
                  endif.
                when 'WithholdingSubjectTo2'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax2-subjectto = 'X'.
                  endif.
                when 'WithholdingSubjectTo3'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax3-subjectto = 'X'.
                  endif.
                when 'WithholdingSubjectTo4'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax4-subjectto = 'X'.
                  endif.

                when 'WithholdingSubjectTo5'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax5-subjectto = 'X'.
                  endif.
                when 'WithholdingSubjectTo6'.
                  if ls_generic_custom_field-content = 'true'.
                    ls_whtax6-subjectto = 'X'.
                  endif.

                when 'WithholdingTaxCode1'.
                  ls_whtax1-taxcode = ls_generic_custom_field-content.
                when 'WithholdingTaxCode2'.
                  ls_whtax2-taxcode = ls_generic_custom_field-content.
                when 'WithholdingTaxCode3'.
                  ls_whtax3-taxcode = ls_generic_custom_field-content.
                when 'WithholdingTaxCode4'.
                  ls_whtax4-taxcode = ls_generic_custom_field-content.
                when 'WithholdingTaxCode5'.
                  ls_whtax5-taxcode = ls_generic_custom_field-content.
                when 'WithholdingTaxCode6'.
                  ls_whtax6-taxcode = ls_generic_custom_field-content.

                when 'WithholdingTaxType1'.
                  ls_whtax1-taxtype = ls_generic_custom_field-content.
                when 'WithholdingTaxType2'.
                  ls_whtax2-taxtype = ls_generic_custom_field-content.
                when 'WithholdingTaxType3'.
                  ls_whtax3-taxtype = ls_generic_custom_field-content.
                when 'WithholdingTaxType4'.
                  ls_whtax4-taxtype = ls_generic_custom_field-content.
                when 'WithholdingTaxType5'.
                  ls_whtax5-taxtype = ls_generic_custom_field-content.
                when 'WithholdingTaxType6'.
                  ls_whtax6-taxtype = ls_generic_custom_field-content.


                when 'ContactTitle1'.
                  ls_contact1-title = ls_generic_custom_field-content.
                when 'ContactTitle2'.
                  ls_contact2-title = ls_generic_custom_field-content.
                when 'ContactTitle3'.
                  ls_contact3-title = ls_generic_custom_field-content.
                when 'ContactTitle4'.
                  ls_contact4-title = ls_generic_custom_field-content.
                when 'FirstName1'.
                  ls_contact1-firstname = ls_generic_custom_field-content.
                when 'FirstName2'.
                  ls_contact2-firstname = ls_generic_custom_field-content.
                when 'FirstName3'.
                  ls_contact3-firstname = ls_generic_custom_field-content.
                when 'FirstName4'.
                  ls_contact4-firstname = ls_generic_custom_field-content.
                when 'LastName1'.
                  ls_contact1-lastname = ls_generic_custom_field-content.
                when 'LastName2'.
                  ls_contact2-lastname = ls_generic_custom_field-content.
                when 'LastName3'.
                  ls_contact3-lastname = ls_generic_custom_field-content.
                when 'LastName4'.
                  ls_contact4-lastname = ls_generic_custom_field-content.
                when 'email1'.
                  ls_contact1-email = ls_generic_custom_field-content.
                when 'email2'.
                  ls_contact2-email = ls_generic_custom_field-content.
                when 'email3'.
                  ls_contact3-email = ls_generic_custom_field-content.
                when 'email4'.
                  ls_contact4-email = ls_generic_custom_field-content.
                when 'Telephone1'.
                  ls_contact1-telephone = ls_generic_custom_field-content.
                when 'Telephone2'.
                  ls_contact2-telephone  = ls_generic_custom_field-content.
                when 'Telephone3'.
                  ls_contact3-telephone = ls_generic_custom_field-content.
                when 'Telephone4'.
                  ls_contact4-telephone = ls_generic_custom_field-content.
                when 'Department1'.
                  ls_contact1-department = ls_generic_custom_field-content.
                when 'Department2'.
                  ls_contact2-department = ls_generic_custom_field-content.
                when 'Department3'.
                  ls_contact3-department = ls_generic_custom_field-content.
                when 'Department4'.
                  ls_contact4-department = ls_generic_custom_field-content.
                when others.
              endcase.
            endloop.

            if ls_partner_future is not initial.
              ls_partner_future-internal_id = ls_suitereplicat-business_partner-internal_id.
              append ls_partner_future to lt_partner_future.
            endif.

            "Fill Table Partner Ordering Addresses
            if ls_ordadd1 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '1' into ls_ordadd1-internal_id separated by '-'.
              append ls_ordadd1 to lt_partner_ordadd.
            endif.
            if ls_ordadd2 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '2' into ls_ordadd2-internal_id separated by '-'.
              append ls_ordadd2 to lt_partner_ordadd.
            endif.
            if ls_ordadd3 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '3' into ls_ordadd3-internal_id separated by '-'.
              append ls_ordadd3 to lt_partner_ordadd.
            endif.
            if ls_ordadd4 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '4' into ls_ordadd4-internal_id separated by '-'.
              append ls_ordadd4 to lt_partner_ordadd.
            endif.
            if ls_ordadd5 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '5' into ls_ordadd5-internal_id separated by '-'.
              append ls_ordadd5 to lt_partner_ordadd.
            endif.


            "Fill Table Partner Withholding Tax
            if ls_whtax1-taxtype is not initial and ls_whtax1-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '1' into ls_whtax1-internal_id separated by '-'.
              append ls_whtax1 to lt_partner_whtax.
            endif.
            if ls_whtax2-taxtype is not initial and ls_whtax2-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '2' into ls_whtax2-internal_id separated by '-'.
              append ls_whtax2 to lt_partner_whtax.
            endif.
            if ls_whtax3-taxtype is not initial and ls_whtax3-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '3' into ls_whtax3-internal_id separated by '-'.
              append ls_whtax3 to lt_partner_whtax.
            endif.
            if ls_whtax4-taxtype is not initial and ls_whtax4-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '4' into ls_whtax4-internal_id separated by '-'.
              append ls_whtax4 to lt_partner_whtax.
            endif.
            if ls_whtax5-taxtype is not initial and ls_whtax5-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '5' into ls_whtax5-internal_id separated by '-'.
              append ls_whtax5 to lt_partner_whtax.
            endif.
            if ls_whtax6-taxtype is not initial and ls_whtax6-taxcode is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '6' into ls_whtax6-internal_id separated by '-'.
              append ls_whtax6 to lt_partner_whtax.
            endif.

            "Fill Table Partner Contact
            if ls_contact1 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '1' into ls_contact1-internal_id separated by '-'.
              append ls_contact1 to lt_partner_contact.
            endif.
            if ls_contact2 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '2' into ls_contact2-internal_id separated by '-'.
              append ls_contact2 to lt_partner_contact.
            endif.
            if ls_contact3 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '3' into ls_contact3-internal_id separated by '-'.
              append ls_contact3 to lt_partner_contact.
            endif.
            if ls_contact4 is not initial.
              concatenate ls_suitereplicat-business_partner-internal_id '4' into ls_contact4-internal_id separated by '-'.
              append ls_contact4 to lt_partner_contact.
            endif.
            clear: ls_contact1, ls_contact2, ls_contact3, ls_contact4.

            "Fill Table Partner Bank
            read table lw_polling_message-business_partner_suitebulk_rep-business_partner_suitereplicat into ls_suitereplicat index 1.
            if sy-subrc eq 0.

              loop at ls_suitereplicat-business_partner-bank_details into ls_bank_details.
                move sy-tabix to lv_tabix.

                if sy-tabix eq '1' and lv_bankkey1 is not initial.                                            "Clave Banco
                  ls_partner_bank-bankl = lv_bankkey1.
                elseif sy-tabix eq '2' and lv_bankkey2 is not initial.
                  ls_partner_bank-bankl = lv_bankkey2.
                elseif sy-tabix eq '3' and lv_bankkey3 is not initial.
                  ls_partner_bank-bankl = lv_bankkey3.
                else.
                  ls_partner_bank-bankl = ls_bank_details-bank_directory_reference-bank_internal_id-content.
                endif.

                "Get currency GENERAL DATA / CHEQUE
                if sy-tabix eq '1'.
                  loop at ls_bank_details-/arba/generic_custom_field into ls_generic_custom_field.
                    case ls_generic_custom_field-name.
*                        ls_partner_pull-waers = ls_bank_details-id(3). "Moneda
                      when 'BankType'.
                        ls_partner_pull-waers = ls_generic_custom_field-content(3).
                    endcase.
                  endloop.
                endif.

                if ls_partner_bank is not initial.
                  concatenate ls_suitereplicat-business_partner-internal_id lv_tabix into ls_partner_bank-internal_id separated by '-'.
                  ls_partner_bank-banks = ls_bank_details-bank_directory_reference-bank_country_code.         "Pais de Banco

*SLP CR SLP009

                  if strlen( ls_bank_details-bank_account_id ) > 18.
                    ls_partner_bank-bankn = '9999999999'.
                    ls_partner_bank-bankn_ext = ls_bank_details-bank_account_id.
                    ls_partner_bank-koinh = 'CUENTA EXCEDE 18 DIGITOS'.
                    ls_partner_bank-koinh_ext = ls_bank_details-bank_account_holder_name.
                  else.
                    ls_partner_bank-bankn = ls_bank_details-bank_account_id.
                    ls_partner_bank-koinh = ls_bank_details-bank_account_holder_name.
                  endif.

                  "Bank Account #
                  "Bank Account Holder Name
*                  ls_partner_bank-bvtyp = ls_bank_details-id(3).                                              "ID datos bancarios
                  ls_partner_bank-iban  = ls_bank_details-bank_account_standard_id.                           "IBAN


                  loop at ls_bank_details-/arba/generic_custom_field into ls_generic_custom_field.
                    case ls_generic_custom_field-name.
                      when 'BankName'.
                        ls_partner_bank-name = ls_generic_custom_field-content.
                      when 'BankAddress'.
                        ls_partner_bank-address = ls_generic_custom_field-content.
                      when 'BankCity'.
                        ls_partner_bank-city = ls_generic_custom_field-content.
                      when 'BankType'.
                        ls_partner_bank-bvtyp = ls_generic_custom_field-content(3).
                    endcase.
                  endloop.

                  loop at ls_suitereplicat-business_partner-/arba/generic_custom_field into ls_generic_custom_field.
                    case ls_generic_custom_field-name.
                      when 'XK01BankRegion'. "Bank region
                        ls_partner_bank-region = ls_generic_custom_field-content.
                    endcase.
                  endloop.

                  append ls_partner_bank to lt_partner_bank.
                endif.
              endloop.
            endif.

            case ls_partner_pull-ekorg. "ls_partner_pull-brsch.
              when 'ABMX' or 'ABVC'.
                ls_partner_pull-zterm = ls_zterm.  "Condición de Pago (50,59)
              when 'ABFG'.
                ls_partner_pull-zterm = ct_zterm.  "Condición de Pago (50,59)
            endcase.

            case ls_partner_pull-ekorg. "ls_partner_pull-brsch.
              when 'ABMX' or 'ABVC'.
                select single brtxt from t016t into ls_partner_pull-mcod2  "Concepto de Búsqueda 2
                  where brsch = ls_partner_pull-brsch and spras = 'S'.
              when 'ABFG'.
                select single brtxt from t016t into ls_partner_pull-mcod2  "Concepto de Búsqueda 2
                  where brsch = ls_partner_pull-brsch and spras = 'E'.
            endcase.
            "Integration Logic for TE de / Recon. Account - Cuenta asociada / Cash mgmnt group - Grupo de Tesorería

*Se debe averiguar que BUKRS usar de la tabla it_bukrs



            loop at it_bukrs into wa_bukrs.

              select single land1 waers
                from t001
                into (lv_land1, lv_waers)
                where bukrs eq wa_bukrs-bukrs.

              wa_bukrs-land1 = lv_land1.
              wa_bukrs-conteo = 1.

              modify it_bukrs from wa_bukrs.

            endloop.

            loop at it_bukrs into wa_bukrs.
              wa_bukrs-bukrs = ''.
              collect wa_bukrs into it_bukrs_c.
            endloop.

            lv_max_land_cont = 0.

            loop at it_bukrs_c into wa_bukrs.
              if wa_bukrs-conteo > lv_max_land_cont.
                lv_max_land = wa_bukrs-land1.
                lv_max_land_cont = wa_bukrs-conteo.
              endif.
            endloop.

            if ls_partner_pull-land1 = lv_max_land.
              lv_nal = 'X'.
            else.
              lv_nal = ' '.
            endif.


            clear: it_bukrs,
                   it_bukrs_c.



*ACA ACA ACA
            select single *
              from zmmvap_ramo
              into ls_ramo
              where brsch eq ls_partner_pull-brsch.

*            IF lv_land1 EQ ls_partner_pull-land1.
            "Nacionales
*              ls_partner_pull-fdgrv = 'A1'. "Domestic

*              IF ls_partner_pull-land1 NE 'CO'.
*                ls_partner_pull-stcd1_taxtype = '04'. "Tax number type - Tipo de identificación fiscal
*              ENDIF.

*              IF ls_ramo-tipo EQ 'P'.
*                ls_partner_pull-ktokk = 'VPRN'.     "Proveedores Nacionales
*                ls_partner_pull-akont = '21041001'. "Proveedores Nacionales Otro
*              ELSE.
*                ls_partner_pull-ktokk = 'VADN'.     "Acreedores Div Nacionales
*                ls_partner_pull-akont = '21051001'. "Acreedores diversos Nacionales Otros
*              ENDIF.
*            ELSE.
            "Extranjeros
*              ls_partner_pull-fdgrv = 'A2'. "Foreign

*              IF ls_partner_pull-land1 NE 'CO'.
*                ls_partner_pull-stcd1_taxtype = '05'. "Tax number type - Tipo de identificación fiscal
*              ENDIF.

*              IF ls_ramo-tipo EQ 'P'.
*                ls_partner_pull-ktokk = 'VPRE'.     "Proveedores Extranjeros
*                ls_partner_pull-akont = '21041002'. "Proveedores Extranjeros Otros
*              ELSE.
*                ls_partner_pull-ktokk = 'VADE'.     "Acreedores Div Extranjeros
*                ls_partner_pull-akont = '21051002'. "Acreedores diversos Extranjeros Otros
*              ENDIF.
*            ENDIF.


*              IF ls_partner_pull-land1 = 'CO'.
*                 ls_partner_pull-lfa1_stcd2 = '04'. "Tax number type - Tipo de identificación fiscal
*              ENDIF.

*NUEVA LOGICA NAL EXTRANJERO

            if lv_nal = 'X'.
              ls_partner_pull-stcd1_taxtype = '04'. "Tax number type - Tipo de identificación fiscal
              ls_partner_pull-fdgrv = 'A1'. "Domestic
            else.
              ls_partner_pull-stcd1_taxtype = '05'. "Tax number type - Tipo de identificación fiscal
              ls_partner_pull-fdgrv = 'A2'. "Foreign
            endif.

            if ls_stcd1_col is not initial.
              ls_partner_pull-stcd1_taxtype = ls_stcd1_col.
            endif.

            if lv_nal = 'X' and ls_ramo-tipo = 'P'.
              ls_partner_pull-akont = '21041001'. "Proveedores Nacionales Otro
              ls_partner_pull-ktokk = 'VPRN'.     "Proveedores Nacionales
            endif.

            if lv_nal = ' ' and ls_ramo-tipo = 'P'.
              ls_partner_pull-akont = '21041002'. "Proveedores Extranjeros Otros
              ls_partner_pull-ktokk = 'VPRE'.     "Proveedores Extranjeros
            endif.

            if lv_nal = 'X' and ls_ramo-tipo = 'A'.
              ls_partner_pull-akont = '21051001'. "Acreedores diversos Nacionales Otros
              ls_partner_pull-ktokk = 'VADN'.     "Acreedores Div Nacionales
            endif.

            if lv_nal = ' ' and ls_ramo-tipo = 'A'.
              ls_partner_pull-akont = '21051002'. "Acreedores diversos Extranjeros Otros
              ls_partner_pull-ktokk = 'VADE'.     "Acreedores Div Extranjeros
            endif.
*FIN NUEVA LOGICA NAL EXTRANJERO

*GET CUSTOM FIELDS
*            LOOP AT ls_suitereplicat-business_partner-/arba/generic_custom_field INTO ls_generic_custom_field.
*              CASE ls_generic_custom_field-name.
*                WHEN 'XK01ContactTitle'. "Contact Title
**                  DATA: lv_anred1 TYPE anred,
**                        lv_anred2 TYPE anred.
**                  SPLIT ls_generic_custom_field-content AT '(' INTO lv_anred1
**                                                                    ls_partner_pull-anred.
**                  REPLACE ALL OCCURRENCES OF ')' IN ls_partner_pull-anred WITH ''.
*                  ls_partner_pull-anred_contact = ls_generic_custom_field-content.
*                WHEN 'XK01ContactName'. "Contact First Name
*                  ls_partner_pull-namev_contact = ls_generic_custom_field-content.
*                WHEN 'XK01ContactLastName'. "Contact Last Name
*                  ls_partner_pull-name1_contact = ls_generic_custom_field-content.
*                WHEN 'XK01ContactEmail'.
*                  ls_partner_pull-smtp_addr = ls_generic_custom_field-content.
*                WHEN 'XK01ContactPhone'. "Contact Phone
*                  ls_partner_pull-telf1_contact = ls_generic_custom_field-content.
*
*                WHEN 'XK01BankRegion'. "Bank region
*                  ls_partner_pull-bkprovz = ls_generic_custom_field-content.
*
*                WHEN 'XK01BankCity'. "Bank city
*                  ls_partner_pull-bkort01 = ls_generic_custom_field-content.
*
*                WHEN 'XK01BankName'. "Bank name
*                  ls_partner_pull-banka = ls_generic_custom_field-content.
*
*                WHEN 'XK01BankAddress'. "Bank address
*                  ls_partner_pull-bkstras = ls_generic_custom_field-content.
*
*                WHEN 'TaxNumberType'. "Tax number type - Tipo de identificación fiscal
*                  IF ls_partner_pull-land1 EQ 'CO'.
*                    ls_partner_pull-stcd1_taxtype = ls_generic_custom_field-content.
*                  ENDIF.
*
*                WHEN 'XK01IndustryType'. "Tax number type - Tipo de identificación fiscal
*                  IF ls_partner_pull-land1 EQ 'MX'.
*                    ls_partner_pull-j_1kftind = ls_generic_custom_field-content.
*                  ENDIF.
*
*                WHEN 'XK01Industry'. "Ramo
*                  CLEAR: split01.
*                  SPLIT ls_generic_custom_field-content AT '(' INTO split01
*                                                               ls_partner_pull-brsch.
*                  REPLACE ALL OCCURRENCES OF ')' IN ls_partner_pull-brsch WITH ''.
**                  ls_partner_pull-brsch = ls_generic_custom_field-content.
*                WHEN OTHERS.
*              ENDCASE.
*            ENDLOOP.

            ls_partner_pull-stkzu = abap_true. "Sales/pur.tax - Imp. Vol neg.






            ls_partner_pull-reprf = abap_true. "Chk double inv. - Verif. Fact. Dup.
*            ls_partner_pull-waers = lv_waers.  "Moneda de pedido - Order currency
*            ls_partner_pull-abtnr = ct_abtnr.  "Department
            ls_partner_pull-taxbs = ct_taxbs.  "Tax base - Base Imp
            ls_partner_pull-actss = ct_actss.  "Soc. Ins. Code - Cód.Seg.Social
            lv_gbdat = sy-datum.
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
            if ls_partner_pull-land1 <> 'MX'.
              case ls_partner_pull-anred.
                when '0002'.
                  ls_partner_pull-j_1kftind = 'Personas Físicas'.
                when '0003'.
                  ls_partner_pull-j_1kftind = 'Personas Morales'.
              endcase.
            endif.

            "Tax type - Clase impuesto
            if ls_partner_pull-land1 eq 'CO'.
              case ls_partner_pull-anred.
                when '0002'.
                  ls_partner_pull-fityp = 'PN'. "Persona Natural
                when '0003'.
                  ls_partner_pull-fityp = 'PJ'. "Persona Jurídica
              endcase.
            else.
              ls_partner_pull-fityp = '85'. "Otros
            endif.

            "Persona Física
            case ls_partner_pull-anred.
              when '0002'.
                ls_partner_pull-stkzn = abap_true.  "Señor
              when '0003'.
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

*          IF ls_partner_pull IS NOT INITIAL.
*            ls_partner_pull-process_status = '1'. "Vendor creation status 1:New rec
          append ls_partner_pull to lt_partner_pull.
*          ENDIF.

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
                 lv_waers,

                 lv_tabix,
                 ls_partner_contact,
                 ls_partner_bank,
                 ls_partner_whtax,
                 ls_partner_ordadd,
                 ls_partner_future,
                 lv_bankkey1,
                 lv_bankkey2,
                 lv_bankkey3,
                 ls_contact1,
                 ls_contact2,
                 ls_contact3,
                 ls_contact4,
                 ls_whtax1,
                 ls_whtax2,
                 ls_whtax3,
                 ls_whtax4,
                 ls_whtax5,
                 ls_whtax6,
                 ls_ordadd1,
                 ls_ordadd2,
                 ls_ordadd3,
                 ls_ordadd4,
                 ls_ordadd5.

          refresh: lt_t001w,
                   lt_t001k,
                   lt_t001b,
                   lt_lfa1,
                   aux_t001b.

*Reading the response from Supplier Manager for BP Confirmation Message
*
*          if lw_polling_message-inbound_service_name = lc_bp_replicate_confirm.
*Trigger Business Partner SUITE Bulk Replicate Confirmation ES
*            me->post_bp_replicate_confirm(
*              exporting
*                is_polling_message = lw_polling_message ).
*          endif.
*
*Reading the response from Supplier Manager for Relationship Request message
*
*          if lw_polling_message-inbound_service_name = lc_bp_relatnshp_request.
*Trigger Business Partner Relationship SUITE Bulk Replicate Request ES
*            me->post_bp_relatnshp_request(
*              exporting
*                      is_polling_message = lw_polling_message ).
*          endif.
*
*Reading the response from Supplier Manager for Relationship Confirmation Message
*
*          if lw_polling_message-inbound_service_name = lc_bp_relatnshp_confirm.
*Trigger Business Partner Relationship SUITE Bulk Replicate Confirmation ES
*            me->post_bp_relatnshp_confirm(
*             exporting
*               is_polling_message = lw_polling_message ) .
*          endif.
          me->update_timestamp(
            exporting
              iv_eventname = 'BP_REPLICATE_REQUEST'
              iv_seqnum    = lw_polling_message-timestamp ).

          clear : lw_polling_message.

        endloop.

        if lt_partner_pull[] is not initial.

          modify zpartner_pull from table lt_partner_pull.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_pull.

          modify zpartner_contact from table lt_partner_contact.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_contact.

          modify zpartner_bank from table lt_partner_bank.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_bank.

          modify zpartner_whtax from table lt_partner_whtax.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_whtax.

          modify zpartner_ordadd from table lt_partner_ordadd.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_ordadd.

          modify zpartner_future from table lt_partner_future.
          wait up to 1 seconds.
          commit work and wait.
          refresh lt_partner_ordadd.
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
