*&---------------------------------------------------------------------*
*&  Include       ZMMINGBL_ACTUALIZA_ADJUNT_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------*
*                     TABLAS                               *
*----------------------------------------------------------*
tables: arbcig_authparam, arbcig_tvarv.

*----------------------------------------------------------*
*                       TIPOS                              *
*----------------------------------------------------------*
types: begin of t_arbcig_tvarv,
    name      type  rvari_vnam,
    fieldname type  name_feld,
    low	      type  tvarv_val.
types: end of t_arbcig_tvarv.

"Token Operation Reporting
types: begin of t_token,
    timeupdated(50)   type c,
    access_token(50)  type c,
    refresh_token(50) type c,
    token_type(50)    type c,
    scope(50)         type c,
    expires_in(50)    type c.
types: end of t_token.

*----------------------------------------------------------*
*                     CONSTANTES                           *
*----------------------------------------------------------*
constants: lc_as(2) type c value 'AS',
           host type string value 'dfw1.sme.zscalertwo.net',
           service type string value '443',
           lc_apikey  type string value 'Apikey',
           lc_authorization type string value 'Authorization',
           lc_content_type type string value 'Content-Type',
           lc_application_json type string value 'application/json',
           c_200 type i value 200.

*----------------------------------------------------------*
*                  ESTRUCTURAS                             *
*----------------------------------------------------------*
*JSON Convert
data: lw_tvarv    type t_arbcig_tvarv,
      ls_tvarv    type arbcig_tvarv,
      lw_token_sd type t_token,
      lw_token_ea type t_token.

data: lw_answers        type zst_list_answers,
      ls_questions      type zst_questions,
      ls_answers        type zst_answers,
      ls_questionnaires type zst_list_questions,
      ls_partner_pull   type zpartner_pull,
      ls_ki_names       type zob_file_names.

data: ls_keywords type zgblst_keywords_onbase.

*----------------------------------------------------------*
*              TABLAS INTERNAS                             *
*----------------------------------------------------------*
data: i_tvarv type standard table of t_arbcig_tvarv,
      result_tab        type match_result_tab,
      lt_bin            type solix_tab,
      lt_questions      type ztt_questions,
      lt_answers        type ztt_answers,
      lt_questionnaires type ztt_list_questions,
      lt_partner_pull   type table of zpartner_pull,
      lt_ki_names       type table of zob_file_names.

data: lt_keywords type table of zgblst_keywords_onbase.

*----------------------------------------------------------*
*                   VARIABLES                              *
*----------------------------------------------------------*
data: lv_realm       type arbcig_realm,
      lv_realm_upper type arbcig_realm,
      lv_realm_lower type arbcig_realm,
      lv_body        type string.

data: ea_apikey   type string,
      ea_clientid type string,
      ea_secret   type string,
      sd_apikey   type string,
      sd_clientid type string,
      sd_secret   type string.

data: lv_authori type string,
      lv_docnum  type string,
      lv_count   type i.

data: lv_feed type abap_cr_lf value cl_abap_char_utilities=>cr_lf.

*Data variables for storing response in xstring and string
data  : lv_xstring type xstring,
        lv_string  type string,
        lv_string1 type string,
        lv_string2 type string,
        lv_string3 type string,
        lv_string4 type string,
        lv_new_string type string,
        lv_internal_id type string.

*----------------------------------------------------------*
*               AL11 / ONBASE                              *
*----------------------------------------------------------*
data: lv_filename type char255, "string,
      lv_ruta_in  type string,
      lv_ruta_out type string,
      lv_aux      type char200,
      lv_ext      type char200,
      lv_file     type xstring,
      lv_size     type i.

constants: lc_ruta_in(50) type c value '/usr/sap/work/Ariba/onbase/in/',
           lc_ruta_out(50) type c value '/usr/sap/work/Ariba/onbase/out/'.
*
data: lxs_file_bin type xstring,
      ls_file_base64 type string,
      lc_filename(255) type c,
      lv_respuesta type char20,
      pe_error     type text255.

data: it_keywords type table of zgblst_keywords_onbase,
      wa_keywords type zgblst_keywords_onbase.

*----------------------------------------------------------*
*              OBJETOS                                     *
*----------------------------------------------------------*
*HTTP Client Abstraction
data: lo_client type ref to if_http_client.
*DATA: b_request TYPE REF TO if_rest_entity.
data: lo_convt  type ref to cl_abap_conv_in_ce.
