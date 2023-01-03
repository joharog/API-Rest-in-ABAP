FUNCTION zfm_email_prov.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_LIFNR)  TYPE  LIFNR
*"     VALUE(I_MAIL_M) TYPE  AD_SMTPADR
*"     VALUE(I_MAIL_S) TYPE  AD_SMTPADR OPTIONAL
*"  TABLES
*"      T_REGISTROS STRUCTURE  ZST_EMAIL_RESP
*"                             ESTATUS	  1 Type  CHAR100
*"                             MENSAJE	  1 Type  CHAR100
*"                             RESPUESTA  1 Type  CHAR100
*"----------------------------------------------------------------------

  "Declarations for BAPI_BUPA_ADDRESS_CHANGE
  DATA: lv_businesspartner LIKE bapibus1006_head-bpartner,
        lt_return          TYPE TABLE OF bapiret2 WITH HEADER LINE,
        lt_bapiadsmtp      TYPE TABLE OF bapiadsmtp,
        wa_bapiadsmtp      LIKE bapiadsmtp,
        lt_bapiadsmt_x     TYPE TABLE OF bapiadsmtx,
        wa_bapiadsmt_x     LIKE bapiadsmtx.

  DATA: wa_registros      LIKE zst_email_resp.


  IF i_lifnr IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = i_lifnr
      IMPORTING
        output = lv_businesspartner.

    CONDENSE lv_businesspartner.

    CLEAR: wa_bapiadsmtp, wa_bapiadsmt_x.

    IF i_mail_m IS NOT INITIAL.
      wa_bapiadsmtp-e_mail = i_mail_m.
      APPEND wa_bapiadsmtp TO lt_bapiadsmtp.
      wa_bapiadsmt_x-e_mail = 'X'.
      APPEND wa_bapiadsmt_x TO lt_bapiadsmt_x.
    ENDIF.

    IF i_mail_s IS NOT INITIAL.
      wa_bapiadsmtp-e_mail = i_mail_s.
      APPEND wa_bapiadsmtp TO lt_bapiadsmtp.
      wa_bapiadsmt_x-e_mail = 'X'.
      APPEND wa_bapiadsmt_x TO lt_bapiadsmt_x.
    ENDIF.

  ENDIF.

  CALL FUNCTION 'BAPI_BUPA_ADDRESS_CHANGE'
    EXPORTING
      businesspartner = lv_businesspartner
    TABLES
      bapiadsmtp      = lt_bapiadsmtp
      bapiadsmt_x     = lt_bapiadsmt_x
      return          = lt_return.

  READ TABLE lt_return WITH KEY type = 'E'.
  IF sy-subrc EQ 0.
*         An error was found, no update was done
    wa_registros-mensaje   = lt_return-message.
    wa_registros-estatus   = lt_return-type.
    wa_registros-respuesta = lt_return-id.
    APPEND wa_registros TO t_registros.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CONCATENATE 'Se actualizo el correo del proveedor' i_lifnr INTO wa_registros-mensaje SEPARATED BY space.
    wa_registros-estatus   = 'OK'.
    wa_registros-respuesta = 'Datos Actualizados'.
    APPEND wa_registros TO t_registros.

  ENDIF.

ENDFUNCTION.
