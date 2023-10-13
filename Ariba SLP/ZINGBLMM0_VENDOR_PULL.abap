*&---------------------------------------------------------------------*
*& Report  /ARBA/SM_BUSINESS_PARTNER_PULL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zingblmm0_vendor_pull.
*---------------------------------------------------------------------*
* Local Data Declaration                                              *
*---------------------------------------------------------------------*
* Structure Declaration
data: ls_request                type /arba/polling_request1, "#EC NEEDED
* Object Declaration
      lo_sm_bp_pull             type ref to zzarba_cl_sm_biz_partner_pull. "#EC NEEDED "/arba/cl_sm_biz_partner_pull. "#EC NEEDED
* Constant Declaration
constants:
      lc_bp_replicate_request   type name_feld
                                value 'BP_REPLICATE_REQUEST',
      lc_bp_replicate_confirm   type name_feld
                                value 'BP_REPLICATE_CONFIRM',
      lc_bp_relatnshp_request   type name_feld
                                value 'BP_RELATNSHP_REQUEST',
      lc_bp_relatnshp_confirm   type name_feld
                                value 'BP_RELATNSHP_CONFIRM'.

*---------------------------------------------------------------------*
* Selection Screen                                                    *
*---------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK sm WITH FRAME TITLE text-001.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS p_bpbrr AS CHECKBOX.
*SELECTION-SCREEN COMMENT 3(39) text-002 FOR FIELD p_bpbrr.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS p_bpbrc AS CHECKBOX.
*SELECTION-SCREEN COMMENT 3(44) text-003 FOR FIELD p_bpbrc.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS p_bprbrr AS CHECKBOX.
*SELECTION-SCREEN COMMENT 3(52) text-004 FOR FIELD p_bprbrr.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS p_bprbrc AS CHECKBOX.
*SELECTION-SCREEN COMMENT 3(57) text-005 FOR FIELD p_bprbrc.
*SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN END OF BLOCK sm.

*---------------------------------------------------------------------*
* Start of Selection                                                  *
*---------------------------------------------------------------------*
start-of-selection.

  free: lo_sm_bp_pull.
  create object lo_sm_bp_pull.

*Get Parameters from /ARBA/SM_SEQNUM
  lo_sm_bp_pull->get_sm_parameters( ).

  free: ls_request.
  if lo_sm_bp_pull is bound.
* Map the Outbound message for BP Request message
    lo_sm_bp_pull->map_outbound_data(
      exporting
        iv_eventname = lc_bp_replicate_request
        changing
        cs_request   = ls_request ).
  endif.

*  IF p_bpbrc EQ abap_true AND lo_sm_bp_pull IS BOUND.
** Map the Outbound message for BP Confirmation message
*    lo_sm_bp_pull->map_outbound_data(
*      EXPORTING
*        iv_eventname = lc_bp_replicate_confirm
*      CHANGING
*        cs_request   = ls_request ).
*  ENDIF.

*  IF p_bprbrr EQ abap_true AND lo_sm_bp_pull IS BOUND.
** Map the Outbound message for BP Relationship Request message
*    lo_sm_bp_pull->map_outbound_data(
*      EXPORTING
*        iv_eventname = lc_bp_relatnshp_request
*      CHANGING
*        cs_request   = ls_request ).
*  ENDIF.

*  IF p_bprbrc EQ abap_true AND lo_sm_bp_pull IS BOUND.
** Map the Outbound message for BP Relationship Confirmation message
*    lo_sm_bp_pull->map_outbound_data(
*      EXPORTING
*        iv_eventname = lc_bp_relatnshp_confirm
*      CHANGING
*        cs_request   = ls_request ).
*  ENDIF.

  if lo_sm_bp_pull is bound.
    try.
* Pull the data from Ariba Supplier Management and
* Post BP Replicate Request/BP Confirmation/BP Relationship Request
* BP Relationship Confirmation based on the response message
        lo_sm_bp_pull->process(
          exporting
            is_request = ls_request ).
* Commit the LUW
        lo_sm_bp_pull->commit( ).
        if lo_sm_bp_pull->gv_count is not initial.
          lo_sm_bp_pull->display_message( ).
        else.
          write : text-010.
        endif.
      catch cx_ai_system_fault .
        message 'System Error'(006) type 'E'.
      catch cx_mdg_fnd_standard_msg_fault .
        message 'Error in executing Enterprise Service'(007) type 'E'.
      catch cx_ai_application_fault .
        message 'Application Error'(008) type 'E'.
    endtry.

  endif.
