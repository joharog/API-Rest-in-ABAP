*&---------------------------------------------------------------------*
*& Report  ZMMINGBL_ACTUALIZA_ADJUNTOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zmmingbl_actualiza_adjuntos.

*----------------------------------------------------------------------*
* Declaración de Includes.                                             *
*----------------------------------------------------------------------*
include zmmingbl_actualiza_adjunt_top.
include zmmingbl_actualiza_adjunt_form.

*----------------------------------------------------------------------*
*                START-OF-SELECTION                                    *
*----------------------------------------------------------------------*
start-of-selection.

*----------------------------------------------------------*
*           Load SLP OB Keys                               *
*----------------------------------------------------------*
  perform f_load_arbcig_tvarv.


  loop at lt_partner_pull into ls_partner_pull.
*----------------------------------------------------------*
*           Token Supplier Pagination                      *
*----------------------------------------------------------*
    perform f_token_supplier_pagination.
*----------------------------------------------------------*

*----------------------------------------------------------*
*           Token External Approval                        *
*----------------------------------------------------------*
    perform f_token_external_approval.
*----------------------------------------------------------*

*----------------------------------------------------------*
*           Get Vendor Data Request                        *
*----------------------------------------------------------*
    perform f_get_vendor_data_request.
*----------------------------------------------------------*

*----------------------------------------------------------*
*           Get Vendor Document URL                        *
*----------------------------------------------------------*
    perform f_get_vendor_document_url.
*----------------------------------------------------------*

*----------------------------------------------------------*
*           Get File to Save                               *
*----------------------------------------------------------*
    perform f_get_file_to_save.
*----------------------------------------------------------*

*----------------------------------------------------------*
*           Update zpartner_pull status                    *
*----------------------------------------------------------*
    perform f_update_zpartner.
*----------------------------------------------------------*

    clear: ls_partner_pull.
  endloop.
