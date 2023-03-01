*Batch Input para creación de VENDOR
*Tx XK01
*
*Ignacio Arango - VIVO Consulting


report zbigblmm0_vendor_create.

include zbdcrecx1.

*INCLUDE bdcrecx1.

data: lt_partner_pull type table of zpartner_pull,
      ls_partner_pull type zpartner_pull,
      lt_zpartner_msgs type table of zpartner_msgs,
      ls_zpartner_msgs type zpartner_msgs.

data: bankl like bnka-bankl.

data: lw_return type bapireturn1,
      l_msgno   type syst-msgno.

data: lt_t024w  type table of t024w,
      lt_t001w  type table of t001w,
      lt_t001k  type table of t001k,
      ls_t001k  type t001k,
      lt_t001b  type table of t001b,
      ls_t001b  type t001b,
      lt_lfa1   type table of lfa1,
      aux_t001b type table of t001b,
      ls_aux_t001b type t001b,
      lv_year  type char4.

data : begin of it_bukrs occurs 10,
  bukrs like zpartner_pull-bukrs,
end of it_bukrs.

start-of-selection.

  select *
    from zpartner_pull
    into table lt_partner_pull.

  read table lt_zpartner_msgs into ls_zpartner_msgs index 1.

  if ls_zpartner_msgs is initial.
    ls_zpartner_msgs-sequence = 0.
  endif.



  loop at lt_partner_pull into ls_partner_pull where process_status <> 4 and ariba_status <> 'X'.

    if ls_partner_pull-process_status = 1. "New rec hace el BI 1

*Primer llamado a XK01 - datos generales.

*SAPMF02K                                	0100
      perform open_group.

      perform bdc_dynpro      using 'SAPMF02K' '0100'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RF02K-KTOKK'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'RF02K-KTOKK'
                                      ls_partner_pull-ktokk.

*SAPMF02K                                	0110
      perform bdc_dynpro      using 'SAPMF02K' '0110'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LFA1-SPRAS'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'LFA1-ANRED'
                                     ls_partner_pull-anred.
      perform bdc_field       using 'LFA1-NAME1'
                                     ls_partner_pull-name1.
      perform bdc_field       using 'LFA1-SORTL'
                                     ls_partner_pull-sortl.
      perform bdc_field       using 'LFA1-NAME2'
                                     ls_partner_pull-name2.
      perform bdc_field       using 'LFA1-NAME3'
                                     ls_partner_pull-name3.
      perform bdc_field       using 'LFA1-NAME4'
                                    ls_partner_pull-name4.
      perform bdc_field       using 'LFA1-STRAS'
                                    ls_partner_pull-stras.
      perform bdc_field       using 'LFA1-ORT01'
                                    ls_partner_pull-ort01.
      perform bdc_field       using 'LFA1-PSTLZ'
                                    ls_partner_pull-pstlz.
      perform bdc_field       using 'LFA1-ORT02'
                                    ls_partner_pull-lfa1_ort02.
      perform bdc_field       using 'LFA1-LAND1'
                                    ls_partner_pull-land1.
      perform bdc_field       using 'LFA1-REGIO'
                                    ls_partner_pull-regio.
      perform bdc_field       using 'LFA1-SPRAS'
                                    ls_partner_pull-spras.

*SAPMF02K                                	0120
      perform bdc_dynpro      using 'SAPMF02K' '0120'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LFA1-GBDAT'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'LFA1-STCD1'
                                ls_partner_pull-stcd1_taxid.
      perform bdc_field       using 'LFA1-STCDT'
                                ls_partner_pull-stcd1_taxtype.
      perform bdc_field   using 'LFA1-STCD2'
                                ls_partner_pull-lfa1_stcd2.
      perform bdc_field       using 'LFA1-FITYP'
                                ls_partner_pull-fityp.
      perform bdc_field       using 'LFA1-STKZN'
                                ls_partner_pull-stkzn.
      perform bdc_field       using 'LFA1-STKZU'
                                ls_partner_pull-stkzu.
      perform bdc_field       using 'LFA1-ACTSS'
                                ls_partner_pull-actss.
      perform bdc_field       using 'LFA1-J_1KFTIND'
                                ls_partner_pull-j_1kftind.
      perform bdc_field       using 'LFA1-BRSCH'
                                ls_partner_pull-brsch.
      perform bdc_field       using 'LFA1-GBDAT'
                                ls_partner_pull-gbdat.


*SAPMF02K                                  0130
      perform bdc_dynpro      using 'SAPMF02K' '0130'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'IBAN(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BANK'.
      perform bdc_field       using 'LFBK-BANKS(01)'
                                ls_partner_pull-banks.
      perform bdc_field       using 'LFBK-BANKL(01)'
                                ls_partner_pull-bankl.
      perform bdc_field       using 'LFBK-BANKN(01)'
                                ls_partner_pull-bankn.
      perform bdc_field       using 'LFBK-KOINH(01)'
                                ls_partner_pull-koinh.
      perform bdc_field   using 'LFBK-BKONT(01)'
                                ls_partner_pull-lfbk_bkont.
      perform bdc_field       using 'LFBK-BVTYP(01)'
                                ls_partner_pull-bvtyp.


*SAPLBANK                                  0100
      perform bdc_dynpro      using 'SAPLBANK' '0100'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'BNKA-BANKA'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.
      perform bdc_field       using 'BNKA-BANKA'
                                    'Fancy Bank Name'.
      perform bdc_field       using 'BNKA-PROVZ'
                                    ls_partner_pull-bkprovz.
      perform bdc_field       using 'BNKA-STRAS'
                                   ls_partner_pull-bkstras.
      perform bdc_field       using 'BNKA-ORT01'
                                    ls_partner_pull-bkort01.
*    PERFORM bdc_field       USING 'BNKA-SWIFT'
*                                  'BANDESSSXXX'.
*    PERFORM bdc_field       USING 'BNKA-BNKLZ'
*                                  '00043004'.

      if ls_partner_pull-iban is not initial.
*SAPMF02K                                  0130
        perform bdc_dynpro      using 'SAPMF02K' '0130'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'LFBK-BKONT(01)'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=IBAN'.



*SAPLIBMA                                	0100
        perform bdc_dynpro      using 'SAPLIBMA' '0100'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'IBAN01'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=ENTR'.
        perform bdc_field       using 'IBAN01'
                                      ls_partner_pull-iban(4).
        perform bdc_field       using 'IBAN02'
                                      ls_partner_pull-iban+4(4).
        perform bdc_field       using 'IBAN03'
                                      ls_partner_pull-iban+8(4).
        perform bdc_field       using 'IBAN04'
                                      ls_partner_pull-iban+12(4).
        perform bdc_field       using 'IBAN05'
                                      ls_partner_pull-iban+16(4).
        perform bdc_field       using 'IBAN06'
                                      ls_partner_pull-iban+20(4).
*      PERFORM bdc_field       USING 'TIBAN-VALID_FROM'
*                                    '22.02.2023'.


      endif.

*SAPMF02K                                  0130
      perform bdc_dynpro      using 'SAPMF02K' '0130'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LFBK-BKONT(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.


      perform bdc_dynpro      using 'SAPMF02K' '0380'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'KNVK-TELF1(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=LSDP'.
      perform bdc_field       using 'KNVK-NAMEV(01)'
                                  ls_partner_pull-namev_contact.
      perform bdc_field       using 'KNVK-NAME1(01)'
                                  ls_partner_pull-name1.
      perform bdc_field       using 'KNVK-TELF1(01)'
                                  ls_partner_pull-telf1_contact.


*SAPMF02K                                  1380
      perform bdc_dynpro      using 'SAPMF02K' '1380'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'KNVK-ABTNR'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BACK'.
      perform bdc_field       using 'KNVK-NAME1'
                                  ls_partner_pull-name1.
      perform bdc_field       using 'KNVK-NAMEV'
                                  ls_partner_pull-namev.
      perform bdc_field       using 'KNVK-TITEL_AP'
                                    ls_partner_pull-namev_titel_contact.
      perform bdc_field       using 'KNVK-TELF1'
                                  ls_partner_pull-telf1_contact.
      perform bdc_field       using 'KNVK-ABTNR'
                                    '0003'.

*SAPMF02K                                  0380
      perform bdc_dynpro      using 'SAPMF02K' '0380'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'KNVK-NAMEV(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENTR'.

      perform bdc_transaction using 'XK01'.

      perform close_group.

      loop at messtab.

        call function 'CHAR_NUMC_CONVERSION'
          exporting
            input   = messtab-msgnr
          importing
            numcstr = l_msgno.



        call function 'WRF_MESSAGE_TEXT_BUILD'
          exporting
            p_msgid   = messtab-msgid
            p_msgno   = l_msgno
            p_msgty   = messtab-msgtyp
*     P_LOG_NO  = ' '
*     P_LOG_MSG_NO       = '0'
            p_msgv1   = messtab-msgv1
            p_msgv2   = messtab-msgv2
            p_msgv3   = messtab-msgv3
            p_msgv4   = ' '
*     P_MATNR   = ' '
          importing
            es_return = lw_return
*     ES_RETURN2         = ES_RETURN2
*     ES_MATRETURN       = ES_MATRETURN
* TABLES
*     PT_RETURN = PT_RETURN
*     PT_MATRETURN       = PT_MATRETURN
          .


        concatenate 'BI1-' lw_return-message ' - ' messtab-fldname ' ' into ls_partner_pull-status_msg.

        ls_zpartner_msgs-sequence = ls_zpartner_msgs-sequence + 1.
        ls_zpartner_msgs-internal_id = ls_partner_pull-internal_id.
        ls_zpartner_msgs-type = lw_return-type.
        ls_zpartner_msgs-msg_id = lw_return-id.
        ls_zpartner_msgs-msg_number = lw_return-number.
        ls_zpartner_msgs-message = ls_partner_pull-status_msg.
        ls_zpartner_msgs-log_no = lw_return-log_no.
        ls_zpartner_msgs-log_msg_no = lw_return-log_msg_no.
        ls_zpartner_msgs-message_v1 = lw_return-message_v1.
        ls_zpartner_msgs-message_v2 = lw_return-message_v2.
        ls_zpartner_msgs-message_v3 = lw_return-message_v3.
        ls_zpartner_msgs-message_v4 = lw_return-message_v4.

        insert zpartner_msgs from ls_zpartner_msgs.

      endloop.
*Se debe capturar LIFNR como resultado


      if lw_return-type = 'S' and lw_return-id = 'F2' and lw_return-number = 170.

        ls_partner_pull-lifnr = messtab-msgv1.
        ls_partner_pull-process_status = 2.
        ls_partner_pull-ariba_status = ' '.

        clear: messtab, lw_return.
      endif.
    endif.
*Inicio segundo llamado

    if ls_partner_pull-process_status = 2. "Hace el BI 2

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
              it_bukrs-bukrs = ls_aux_t001b-bukrs.  "Company Code - Sociedad
              append it_bukrs.
            endif.
          endloop.

        endif.
      endif.

      loop at it_bukrs.

        perform open_group.

*SAPMF02K                                  0100
        perform bdc_dynpro      using 'SAPMF02K' '0100'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RF02K-BUKRS'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'RF02K-LIFNR'
                                          ls_partner_pull-lifnr.
        perform bdc_field       using 'RF02K-BUKRS'
                                      it_bukrs-bukrs.
*                                        ls_partner_pull-bukrs.

*SAPMF02K                                  0210
        perform bdc_dynpro      using 'SAPMF02K' '0210'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'T035T-TEXTK'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'LFB1-AKONT'
                                          ls_partner_pull-akont.
        perform bdc_field       using 'LFB1-FDGRV'
                                          ls_partner_pull-fdgrv.


        select single zwels hbkid
          from zpayment_methods
          into (ls_partner_pull-zwels, "Payment methods - Vía de Pago
                ls_partner_pull-hbkid) "House Bank - Banco propio
          where bukrs eq it_bukrs-bukrs
            and ekorg eq ls_partner_pull-ekorg.





*SAPMF02K                                  0215
        perform bdc_dynpro      using 'SAPMF02K' '0215'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'LFB1-HBKID'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'LFB1-ZTERM'
                                          ls_partner_pull-zterm.
        perform bdc_field       using 'LFB1-REPRF'
                                        ls_partner_pull-reprf.
        perform bdc_field       using 'LFB1-ZWELS'
                                      ls_partner_pull-zwels.
        perform bdc_field       using 'LFB1-HBKID'
                                      ls_partner_pull-hbkid.

*SAPMF02K                                  0220
        perform bdc_dynpro      using 'SAPMF02K' '0220'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'LFB5-MAHNA'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.

*SAPMF02K                                  0610
        perform bdc_dynpro      using 'SAPMF02K' '0610'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '=ENTR'.

        perform bdc_field       using 'BDC_CURSOR'
                                      'LFB1-QLAND'.

        perform bdc_transaction using 'XK01'.

        perform close_group.

        loop at messtab.

          call function 'CHAR_NUMC_CONVERSION'
            exporting
              input   = messtab-msgnr
            importing
              numcstr = l_msgno.



          call function 'WRF_MESSAGE_TEXT_BUILD'
            exporting
              p_msgid   = messtab-msgid
              p_msgno   = l_msgno
              p_msgty   = messtab-msgtyp
*     P_LOG_NO  = ' '
*     P_LOG_MSG_NO       = '0'
              p_msgv1   = messtab-msgv1
              p_msgv2   = messtab-msgv2
              p_msgv3   = messtab-msgv3
              p_msgv4   = ' '
*     P_MATNR   = ' '
            importing
              es_return = lw_return
*     ES_RETURN2         = ES_RETURN2
*     ES_MATRETURN       = ES_MATRETURN
* TABLES
*     PT_RETURN = PT_RETURN
*     PT_MATRETURN       = PT_MATRETURN
            .


          concatenate 'BI2-' lw_return-message ' - ' messtab-fldname ' ' into ls_partner_pull-status_msg.

          ls_zpartner_msgs-sequence = ls_zpartner_msgs-sequence + 1.
          ls_zpartner_msgs-internal_id = ls_partner_pull-internal_id.
          ls_zpartner_msgs-type = lw_return-type.
          ls_zpartner_msgs-msg_id = lw_return-id.
          ls_zpartner_msgs-msg_number = lw_return-number.
          ls_zpartner_msgs-message = ls_partner_pull-status_msg.
          ls_zpartner_msgs-log_no = lw_return-log_no.
          ls_zpartner_msgs-log_msg_no = lw_return-log_msg_no.
          ls_zpartner_msgs-message_v1 = lw_return-message_v1.
          ls_zpartner_msgs-message_v2 = lw_return-message_v2.
          ls_zpartner_msgs-message_v3 = lw_return-message_v3.
          ls_zpartner_msgs-message_v4 = lw_return-message_v4.

          modify zpartner_msgs from ls_zpartner_msgs.

        endloop.

*endloop.
* OJO OJO OJO ENDLOOP AT BUKRS

*Fin segundo llamado

        if lw_return-type = 'S' and lw_return-id = 'F2' and lw_return-number = 271.

          ls_partner_pull-process_status = 3.
          ls_partner_pull-ariba_status = ' '.

          clear: messtab, lw_return.
        endif.
      endloop.
    endif.


    if ls_partner_pull-process_status = 3.  "Hace el BI 3

*Inicio tercer llamado
* OJO OJO OJO LOOP AT KTOKK


      perform open_group.

*SAPMF02K                                  0100
      perform bdc_dynpro      using 'SAPMF02K' '0100'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'RF02K-EKORG'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'RF02K-LIFNR'
                                              ls_partner_pull-lifnr.
      perform bdc_field       using 'RF02K-EKORG'
                                              ls_partner_pull-ekorg.



      perform bdc_dynpro      using 'SAPMF02K'  '0310'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LFM1-VSBED'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '/00'.
      perform bdc_field       using 'LFM1-WAERS'
                                    ls_partner_pull-waers.
      perform bdc_field       using 'LFM1-ZTERM'
                                    ls_partner_pull-zterm.
      perform bdc_field       using 'LFM1-INCO1'
                                    ls_partner_pull-inco1.
      perform bdc_field       using 'LFM1-INCO2'
                                    ls_partner_pull-inco2.
      perform bdc_field       using 'LFM1-WEBRE'
                                    ls_partner_pull-webre.
      perform bdc_field       using 'LFM1-XERSY'
                                    ls_partner_pull-xersy.
      perform bdc_field       using 'LFM1-KZAUT'
                                    ls_partner_pull-kzaut.
      perform bdc_field       using 'LFM1-VSBED'
                                    ls_partner_pull-vsbed.
      perform bdc_field       using 'LFM1-BSTAE'
                                    ls_partner_pull-bstae.


      perform bdc_dynpro      using 'SAPMF02K'  '0320'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'WYT3-PARVW(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=ENRT'.

      perform bdc_transaction using 'XK01'.

      perform close_group.

* OJO OJO OJO ENDLOOP AT KTOKK
* Fin tercer llamado
      loop at messtab.

        call function 'CHAR_NUMC_CONVERSION'
          exporting
            input   = messtab-msgnr
          importing
            numcstr = l_msgno.



        call function 'WRF_MESSAGE_TEXT_BUILD'
          exporting
            p_msgid   = messtab-msgid
            p_msgno   = l_msgno
            p_msgty   = messtab-msgtyp
*     P_LOG_NO  = ' '
*     P_LOG_MSG_NO       = '0'
            p_msgv1   = messtab-msgv1
            p_msgv2   = messtab-msgv2
            p_msgv3   = messtab-msgv3
            p_msgv4   = ' '
*     P_MATNR   = ' '
          importing
            es_return = lw_return
*     ES_RETURN2         = ES_RETURN2
*     ES_MATRETURN       = ES_MATRETURN
* TABLES
*     PT_RETURN = PT_RETURN
*     PT_MATRETURN       = PT_MATRETURN
          .


        concatenate 'BI3-' lw_return-message ' - ' messtab-fldname ' ' into ls_partner_pull-status_msg.

        ls_zpartner_msgs-sequence = ls_zpartner_msgs-sequence + 1.
        ls_zpartner_msgs-internal_id = ls_partner_pull-internal_id.
        ls_zpartner_msgs-type = lw_return-type.
        ls_zpartner_msgs-msg_id = lw_return-id.
        ls_zpartner_msgs-msg_number = lw_return-number.
        ls_zpartner_msgs-message = ls_partner_pull-status_msg.
        ls_zpartner_msgs-log_no = lw_return-log_no.
        ls_zpartner_msgs-log_msg_no = lw_return-log_msg_no.
        ls_zpartner_msgs-message_v1 = lw_return-message_v1.
        ls_zpartner_msgs-message_v2 = lw_return-message_v2.
        ls_zpartner_msgs-message_v3 = lw_return-message_v3.
        ls_zpartner_msgs-message_v4 = lw_return-message_v4.

        modify zpartner_msgs from ls_zpartner_msgs.

      endloop.

      if lw_return-type = 'S' and lw_return-id = 'F2' and lw_return-number = 173.
        ls_partner_pull-ariba_status = 4.
      endif.
    endif. "BI 3


    modify zpartner_pull from ls_partner_pull.


    write: lw_return-message.
  endloop.
