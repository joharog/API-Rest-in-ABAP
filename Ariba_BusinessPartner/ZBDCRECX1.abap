*Include para Batch Input "silencioso"
*
*Ignacio Arango - VIVO Consulting

parameters: session no-display,
            ctu     no-display default 'X'.

parameters: group(12) no-display,
            ctumode   no-display default 'N'.

parameters: holddate like sy-datum no-display,
           e_user(12) default sy-uname no-display.

parameters: keep        no-display,
            e_group(12) no-display.

parameters: user(12) no-display default sy-uname,
            cupdate like ctu_params-updmode default 'L' no-display.

parameters: nodata default '/' lower case no-display.

parameters: smalllog no-display.

parameters: e_hdate like sy-datum no-display.

parameters: e_keep no-display.

*----------------------------------------------------------------------*
*   data definition
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
data:   bdcdata like bdcdata    occurs 0 with header line.
*       messages of call transaction
data:   messtab like bdcmsgcoll occurs 0 with header line.
*       error session opened (' ' or 'X')
data:   e_group_opened.
*       message texts
tables: t100.

*----------------------------------------------------------------------*
*   create batchinput session                                          *
*   (not for call transaction using...)                                *
*----------------------------------------------------------------------*
form open_group.
  if session = 'X'.
    skip.
    write: /(20) 'Create group'(i01), group.
    skip.
*   open batchinput group
    call function 'BDC_OPEN_GROUP'
      exporting
        client   = sy-mandt
        group    = group
        user     = user
        keep     = keep
        holddate = holddate.
    write: /(30) 'BDC_OPEN_GROUP'(i02),
            (12) 'returncode:'(i05),
                 sy-subrc.
  endif.
endform.

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*   (call transaction using...: error session)                         *
*----------------------------------------------------------------------*
form close_group.
  if session = 'X'.
*   close batchinput group
    call function 'BDC_CLOSE_GROUP'.
    write: /(30) 'BDC_CLOSE_GROUP'(i04),
            (12) 'returncode:'(i05),
                 sy-subrc.
  else.
    if e_group_opened = 'X'.
      call function 'BDC_CLOSE_GROUP'.
      write: /.
      write: /(30) 'Fehlermappe wurde erzeugt'(i06).
    endif.
  endif.
endform.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
form bdc_dynpro using program dynpro.
  clear bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  append bdcdata.
endform.
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
form bdc_field using fnam fval.
  if fval <> nodata.
    clear bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    append bdcdata.
  endif.
endform.

*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
form bdc_transaction using tcode.
  data: l_mstring(480).
  data: l_subrc like sy-subrc.
* batch input session
  if session = 'X'.
    call function 'BDC_INSERT'
      exporting
        tcode     = tcode
      tables
        dynprotab = bdcdata.
    if smalllog <> 'X'.
      write: / 'BDC_INSERT'(i03),
               tcode,
               'returncode:'(i05),
               sy-subrc,
               'RECORD:',
               sy-index.
    endif.
* call transaction using
  else.
    refresh messtab.
    call transaction tcode using bdcdata
                     mode   ctumode
                     update cupdate
                     messages into messtab.
    l_subrc = sy-subrc.
    if smalllog <> 'X'.
*      WRITE: / 'CALL_TRANSACTION',
*               TCODE,
*               'returncode:'(I05),
*               L_SUBRC,
*               'RECORD:',
*               SY-INDEX.
      if sy-subrc = 0.
        format color off.
        write:/ 'Successfully Process ', messtab.
      else.
        format color col_negative.
        write:/ 'Failed Process ', messtab.
      endif.
      loop at messtab.
        select single * from t100 where sprsl = messtab-msgspra
                                  and   arbgb = messtab-msgid
                                  and   msgnr = messtab-msgnr.
        if sy-subrc = 0.
          l_mstring = t100-text.
          if l_mstring cs '&1'.
            replace '&1' with messtab-msgv1 into l_mstring.
            replace '&2' with messtab-msgv2 into l_mstring.
            replace '&3' with messtab-msgv3 into l_mstring.
            replace '&4' with messtab-msgv4 into l_mstring.
          else.
            replace '&' with messtab-msgv1 into l_mstring.
            replace '&' with messtab-msgv2 into l_mstring.
            replace '&' with messtab-msgv3 into l_mstring.
            replace '&' with messtab-msgv4 into l_mstring.
          endif.
          condense l_mstring.
          write: / messtab-msgtyp, l_mstring(250).
        else.
          write: / messtab.
        endif.
      endloop.
      skip.
    endif.
** Erzeugen fehlermappe ************************************************
    if l_subrc <> 0 and e_group <> space.
      if e_group_opened = ' '.
        call function 'BDC_OPEN_GROUP'
          exporting
            client   = sy-mandt
            group    = e_group
            user     = e_user
            keep     = e_keep
            holddate = e_hdate.
        e_group_opened = 'X'.
      endif.
      call function 'BDC_INSERT'
        exporting
          tcode     = tcode
        tables
          dynprotab = bdcdata.
    endif.
  endif.
  refresh bdcdata.
endform.
