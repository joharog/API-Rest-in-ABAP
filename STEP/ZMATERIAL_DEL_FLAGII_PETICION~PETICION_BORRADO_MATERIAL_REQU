  METHOD zmaterial_del_flagii_peticion~peticion_borrado_material_requ.
*** **** INSERT IMPLEMENTATION HERE **** ***

    DATA: head_data  TYPE bapimathead,
          plantdata  TYPE bapi_marc,
          plantdatax TYPE bapi_marcx,
          salesdata  TYPE bapi_mvke,
          salesdatax TYPE bapi_mvkex,
          ls_return  TYPE bapiret2,
          lv_matnr   TYPE mara-matnr,
          return_msg TYPE TABLE OF bapi_matreturn2,
          flag_error TYPE flag,
          message    TYPE string.

    CLEAR: flag_error, message, lv_matnr.

    TRY.

        lv_matnr = |{ input-peticion_borrado_material_requ-matnr ALPHA = IN }|.

        SELECT SINGLE * FROM mara INTO @DATA(ls_mara)
          WHERE matnr EQ @lv_matnr.

        IF sy-subrc EQ 0.
          head_data = VALUE #( material     = lv_matnr
                               ind_sector   = ls_mara-mbrsh
                               matl_type    = ls_mara-mtart
                               storage_view = abap_true ).

          LOOP AT input-peticion_borrado_material_requ-sales_data INTO DATA(sales_data).

            salesdata = VALUE #( sales_org  = sales_data-vkorg
                                 distr_chan = sales_data-vtweg
                                 del_flag   = COND #( WHEN sales_data-lvorm NE 'X' THEN abap_false ELSE abap_true ) ).


            salesdatax = VALUE #( sales_org  = sales_data-vkorg
                                  distr_chan = sales_data-vtweg
                                  del_flag   = COND #( WHEN sales_data-lvorm NE 'X' THEN abap_false ELSE abap_true ) ).

            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
              EXPORTING
                headdata       = head_data
                salesdata      = salesdata
                salesdatax     = salesdatax
              IMPORTING
                return         = ls_return
              TABLES
                returnmessages = return_msg.

            IF ls_return IS NOT INITIAL.
              IF ls_return-type EQ 'E'.
                flag_error = abap_true.
                CONCATENATE message ls_return-message '#' INTO message.

              ELSE.
                CONCATENATE message ls_return-message '#' INTO message.
              ENDIF.
            ENDIF.

            CLEAR: ls_return, salesdata, salesdatax.
          ENDLOOP.

          LOOP AT input-peticion_borrado_material_requ-werks_data INTO DATA(werks_data).

            plantdata = VALUE #( plant    = werks_data-werks
                                 del_flag = COND #( WHEN werks_data-lvorm NE 'X' THEN abap_false ELSE abap_true ) ).

            plantdatax = VALUE #( plant    = werks_data-werks
                                  del_flag = COND #( WHEN werks_data-lvorm NE 'X' THEN abap_false ELSE abap_true ) ).

            CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
              EXPORTING
                headdata       = head_data
                plantdata      = plantdata
                plantdatax     = plantdatax
              IMPORTING
                return         = ls_return
              TABLES
                returnmessages = return_msg.

            IF ls_return IS NOT INITIAL.
              IF ls_return-type EQ 'E'.
                flag_error = abap_true.
                CONCATENATE message ls_return-message '#' INTO message.

              ELSE.
                CONCATENATE message ls_return-message '#' INTO message.
              ENDIF.
            ENDIF.

            CLEAR: ls_return, plantdata, plantdatax.
          ENDLOOP.

          CONDENSE message.
          output-peticion_borrado_material_resp = VALUE #( matnr         = input-peticion_borrado_material_requ-matnr
                                                           error_code    = COND #( WHEN flag_error EQ abap_true THEN 1 ELSE 0 )
                                                           error_message = message ).

        ELSE.

          flag_error = abap_true.
          output-peticion_borrado_material_resp = VALUE #( matnr         = input-peticion_borrado_material_requ-matnr
                                                           error_code    = COND #( WHEN flag_error EQ abap_true THEN 1 ELSE 0 )
                                                           error_message = COND #( WHEN message IS INITIAL THEN 'No existe material' ) ).

        ENDIF.

      CATCH cx_root INTO DATA(ls_error).

        output-peticion_borrado_material_resp = VALUE #( matnr         = input-peticion_borrado_material_requ-matnr
                                                         error_code    = 1
                                                         error_message = ls_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
