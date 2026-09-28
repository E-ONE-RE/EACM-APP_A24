CLASS lhc_I_A24_UPLOAD DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    CLASS-DATA gt_header TYPE STANDARD TABLE OF /eacm/a24logh.
    CLASS-DATA gt_items TYPE STANDARD TABLE OF /eacm/a24logi.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_cid_request,
        cid       TYPE string,
        requestid TYPE sysuuid_x16,
      END OF ty_cid_request.

*    CLASS-DATA gt_cid_request TYPE HASHED TABLE OF ty_cid_request WITH UNIQUE KEY cid.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR /eacm/i_a24_upload RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR /eacm/i_a24_upload RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE /eacm/i_a24_upload.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/i_a24_upload.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/i_a24_upload.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/i_a24_upload RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK /eacm/i_a24_upload.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ /eacm/i_a24_upload\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE /eacm/i_a24_upload\_Items.

*    METHODS get_requestid_for_cba
*      IMPORTING
*                iv_cid_ref          TYPE string
*                iv_requestid        TYPE sysuuid_x16
*      RETURNING VALUE(rv_requestid) TYPE sysuuid_x16.

ENDCLASS.

CLASS lhc_I_A24_UPLOAD IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

*      DATA lv_requestid TYPE sysuuid_x16.
*      TRY.
*          lv_requestid = cl_system_uuid=>create_uuid_x16_static( ).
*        CATCH cx_uuid_error.
*          APPEND VALUE #( %cid = <entity>-%cid ) TO failed-/eacm/i_a24_upload.
*          CONTINUE.
*      ENDTRY.

      SELECT SINGLE COUNT( * )
      FROM /eacm/a24logh
      WHERE requestid = @<entity>-requestid.
      IF sy-subrc = 0.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-/eacm/i_a24_upload.

        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'DUPLICATE UUID'
              ) )
          TO reported-/eacm/i_a24_upload.
        CONTINUE.
      ENDIF.

      DATA lv_timestamp TYPE timestampl.
      GET TIME STAMP FIELD lv_timestamp.

      INSERT VALUE #(
          requestid  = <entity>-requestid
          created_by = sy-uname
          created_at = lv_timestamp
          file_name  = <entity>-FileName
          status     = /eacm/cl_a24=>c_h_received
      ) INTO TABLE gt_header.
      IF sy-subrc <> 0.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-/eacm/i_a24_upload.
        CONTINUE.
      ENDIF.

*      IF <entity>-%cid IS NOT INITIAL.
*        INSERT VALUE ty_cid_request(
*          cid       = CONV string( <entity>-%cid )
*          requestid = <entity>-requestid
*        ) INTO TABLE gt_cid_request.
*      ENDIF.

      APPEND VALUE #(
        %cid      = <entity>-%cid
        RequestId = <entity>-requestid
      ) TO mapped-/eacm/i_a24_upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT RequestId,
           CreatedBy,
           CreatedAt,
           FileName,
           Status,
           MimeType
      FROM /eacm/i_a24_upload
      FOR ALL ENTRIES IN @keys
      WHERE RequestId = @keys-RequestId
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

  METHOD cba_Items.
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<cba>).

*      DATA(lv_requestid) = get_requestid_for_cba(
*        iv_cid_ref   = CONV string( <cba>-%cid_ref )
*        iv_requestid = <cba>-RequestId
*      ).
*
      IF <cba>-Requestid IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_total) = 0.
      DATA(lv_lineno) = 0.

      LOOP AT <cba>-%target ASSIGNING FIELD-SYMBOL(<item>).
        lv_lineno = COND #( WHEN <item>-Zlineno IS INITIAL THEN lv_lineno + 1 ELSE <item>-Zlineno ).

        INSERT VALUE #(
            requestid  = <cba>-Requestid
            zlineno = lv_lineno
            record = <item>-Record
            status     = /eacm/cl_a24=>c_h_received
        ) INTO TABLE gt_items.
        IF sy-subrc = 0.
          lv_total = lv_total + 1.
          APPEND VALUE #(
            %cid      = <item>-%cid
            RequestId = <cba>-Requestid
            Zlineno    = lv_lineno
          ) TO mapped-/eacm/i_a24_upload_item.
        ELSE.
          APPEND VALUE #(
            %cid      = <item>-%cid
            RequestId = <cba>-Requestid
            Zlineno    = lv_lineno
          ) TO failed-/eacm/i_a24_upload_item.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

*  METHOD get_requestid_for_cba.
*    rv_requestid = iv_requestid.
*
*    IF rv_requestid IS INITIAL AND iv_cid_ref IS NOT INITIAL.
*      READ TABLE gt_cid_request
*        WITH TABLE KEY cid = iv_cid_ref
*        INTO DATA(ls_cid_request).
*      IF sy-subrc = 0.
*        rv_requestid = ls_cid_request-requestid.
*      ENDIF.
*    ENDIF.
*  ENDMETHOD.

ENDCLASS.

CLASS lhc_I_A24_UPLOAD_ITEM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE /eacm/i_a24_upload_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE /eacm/i_a24_upload_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ /eacm/i_a24_upload_item RESULT result.

    METHODS rba_Upload FOR READ
      IMPORTING keys_rba FOR READ /eacm/i_a24_upload_item\_Upload FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_I_A24_UPLOAD_ITEM IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT RequestId,
           Zlineno,
           Status,
           Message,
           Record
      FROM /eacm/i_a24_upload_item
      FOR ALL ENTRIES IN @keys
      WHERE RequestId = @keys-RequestId
        AND Zlineno    = @keys-Zlineno
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD rba_Upload.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_I_A24_UPLOAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_A24_UPLOAD IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    INSERT /eacm/a24logh FROM TABLE @lhc_I_A24_UPLOAD=>gt_header.
    INSERT /eacm/a24logi FROM TABLE @lhc_I_A24_UPLOAD=>gt_items.

    "/schedulazione job
    GET TIME STAMP FIELD DATA(lv_now).

    DATA(ls_start_info) =
      VALUE cl_apj_rt_api=>ty_start_info(
        timestamp = cl_abap_tstmp=>add_to_short(
          tstmp = lv_now
          secs  = 60 ) ).

    TRY.
        cl_apj_rt_api=>schedule_job(
          EXPORTING
            iv_job_template_name   = '/EACM/TMPL_A24_JOB'
            iv_job_text            = 'A24'
            is_start_info          = ls_start_info
        ).
      CATCH cx_apj_rt INTO DATA(lo_apj).
        "handle exception
*        DATA(msg) = lo_apj->get_longtext( ).
        DATA(ls_return) = lo_apj->get_bapiret2( ).
        DATA lv_msg TYPE /eacm/a24logh-mimetype.
        MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
            WITH ls_return-message_v1 ls_return-message_v2 ls_return-message_v3 ls_return-message_v4
            INTO lv_msg.
*        LOOP AT lhc_I_A24_UPLOAD=>gt_header INTO DATA(ls_logh).
*          UPDATE /eacm/a24logh
*          SET status = @/eacm/cl_a24=>c_i_error, mimetype = @lv_msg
*          WHERE requestid = @ls_logh-requestid.
*        ENDLOOP.
    ENDTRY.
    "\schedulazione job

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
