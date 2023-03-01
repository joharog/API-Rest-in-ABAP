*&---------------------------------------------------------------------*
*&  Include       ZINMEXMD1_MATE_ARIBA_TOP
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

types: begin of t_payload,
    itemid type string.
types: end of t_payload.

*----------------------------------------------------------*
*                     CONSTANTES                           *
*----------------------------------------------------------*
constants: lc_as(2) type c value 'AS',
           host type string value 'dfw1.sme.zscalertwo.net',
           service type string value '443',
           lc_owner(8) type c value ',"owner"',
           lc_close(1) type c value '}',
           lc_draft(5)  type c value 'Draft',
           lc_borrador(8) type c value 'Borrador',
           lc_rfp(3)    type c value 'RFP',
           lc_itemid(8) type c value '"itemId"',
           lc_itemtype(11) type c value '"itemType":',
           lc_zve5 type mtart value 'ZVE5',
           lc_zfe7 type mtart value 'ZFE7',
           lc_apikey  type string value 'Apikey',
           lc_authorization type string value 'Authorization',
           lc_content_type type string value 'Content-Type',
           lc_application_json type string value 'application/json',
           c_200 type i value 200.

*----------------------------------------------------------*
*                  ESTRUCTURAS                             *
*----------------------------------------------------------*
*JSON Convert
data: ls_reporting type zws_reporting.

data: lw_tvarv    type t_arbcig_tvarv,
      lw_token_or type t_token,
      lw_token_em type t_token,
      ls_token01  type  t_token,
      ls_events   type zevents,
      ls_tvarv type arbcig_tvarv,
      lw_itemtype_str type string,
      lw_no_itemtype  type string,
      lw_payload type string.

*----------------------------------------------------------*
*              TABLAS INTERNAS                             *
*----------------------------------------------------------*
data: i_tvarv type standard table of t_arbcig_tvarv,
      i_payload type table of string,
      lt_records type zrecords,
      ls_records type zlist_records.

*----------------------------------------------------------*
*              TABLAS INTERNAS                             *
*----------------------------------------------------------*
field-symbols: <f_payload> type string.

*----------------------------------------------------------*
*                   VARIABLES                              *
*----------------------------------------------------------*
data: lv_realm type  arbcig_realm.
data: em_apikey      type string, "tvarv_val,
      em_clientid    type string, "tvarv_val,
      em_secret      type string, "tvarv_val,
      em_user        type string, "tvarv_val,
      em_user_pa     type string, "tvarv_val,
      last_execution type string, "tvarv_val,
      or_apikey      type string, "tvarv_val,
      or_clientid    type string, "tvarv_val,
      or_secret      type string, "tvarv_val,
      or_template    type string. "tvarv_val.

data: lv_no_materialcode type string,
      lv_materialcode type string,
      lv_no_simplevalue type string,
      lv_simplevalue type string,
      lv_int     type i.


data: lv_filter_ps type string,
      lv_dateto(20) type c.
data: lv_authori type string.

data: lv_feed   type abap_cr_lf value cl_abap_char_utilities=>cr_lf.

*Data variables for storing response in xstring and string
data  : lv_xstring   type xstring,
        lv_string    type string,
        lv_string_b    type string,
        lv_node_name type string,
        lv_itemtype(1)  type c,
        v_tdline type string,
        v_url_consulta type text255,
        v_request_cdata type string.


*----------------------------------------------------------*
*              OBJETOS                                     *
*----------------------------------------------------------*
*HTTP Client Abstraction
data: lo_client type ref to if_http_client.
data: lo_convt  type ref to cl_abap_conv_in_ce.
