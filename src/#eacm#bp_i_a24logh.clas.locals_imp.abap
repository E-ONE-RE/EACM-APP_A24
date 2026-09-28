CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    CLASS-DATA gt_requestids TYPE SORTED TABLE OF /eacm/a24logh-requestid
      WITH UNIQUE KEY table_line.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Header RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Header RESULT result.

    METHODS create FOR MODIFY
       entities FOR CREATE Header.

    METHODS update FOR MODIFY
       entities FOR UPDATE Header.

    METHODS delete FOR MODIFY
       keys FOR DELETE Header.

    METHODS read FOR READ
       keys FOR READ Header RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK Header.

    METHODS rba_Items FOR READ
       keys_rba FOR READ Header\_Items FULL result_requested RESULT result LINK association_links.

    METHODS rba_Processes FOR READ
       keys_rba FOR READ Header\_Processes FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
       entities_cba FOR CREATE Header\_Items.

    METHODS cba_Processes FOR MODIFY
       entities_cba FOR CREATE Header\_Processes.

    METHODS ProcessOnline FOR MODIFY
       keys FOR ACTION Header~ProcessOnline RESULT result.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF /eacm/i_a24logh IN LOCAL MODE
      ENTITY Header FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    result = VALUE #(
      FOR ls_header IN lt_headers
      ( %tky = ls_header-%tky
        %action-ProcessOnline = COND #(
          WHEN ls_header-Status = /eacm/cl_a24=>c_h_received
            OR ls_header-Status = /eacm/cl_a24=>c_h_partially
          THEN if_abap_behv=>fc-o-enabled
          ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT Requestid,
           Filename,
           CreatedBy,
           CreatedAt,
           CreatedAtDisplay,
           Status,
           StatusCriticality
      FROM /eacm/i_a24logh
      FOR ALL ENTRIES IN @keys
      WHERE Requestid = @keys-Requestid
      INTO CORRESPONDING FIELDS OF TABLE @result.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      IF NOT line_exists(
               result[ KEY id COMPONENTS %tky = <key>-%tky ] ).
        APPEND VALUE #(
          %tky        = <key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Header.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Items.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_existing_headers
      TYPE SORTED TABLE OF /eacm/a24logh-requestid
      WITH UNIQUE KEY table_line.

    DATA lt_items TYPE STANDARD TABLE OF /eacm/i_a24logi
      WITH EMPTY KEY.

    SELECT Requestid
      FROM /eacm/i_a24logh
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO TABLE @lt_existing_headers.

    SELECT Requestid,
           Zlineno,
           Status,
           StatusCriticality,
           Message,
           Record,
           Vkorg,
           Vtweg,
           Zclpr,
           Vbeln,
           Posnr,
           Zcdaz,
           Zidag
      FROM /eacm/i_a24logi
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<header>).
      IF NOT line_exists(
           lt_existing_headers[ table_line = <header>-Requestid ] ).
        APPEND VALUE #(
          %tky        = <header>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Header.
        CONTINUE.
      ENDIF.

      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<item>)
           WHERE Requestid = <header>-Requestid.

        INSERT VALUE #(
          source-%tky = <header>-%tky
          target-%tky = VALUE #(
            Requestid = <item>-Requestid
            Zlineno   = <item>-Zlineno )
        ) INTO TABLE association_links.

        IF result_requested = abap_true.
          APPEND CORRESPONDING #( <item> ) TO result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT association_links BY source target.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.
    SORT result BY %tky.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.

  METHOD rba_Processes.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_existing_headers
      TYPE SORTED TABLE OF /eacm/a24logh-requestid
      WITH UNIQUE KEY table_line.

    DATA lt_processes TYPE STANDARD TABLE OF /eacm/i_a24logp
      WITH EMPTY KEY.

    SELECT Requestid
      FROM /eacm/i_a24logh
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO TABLE @lt_existing_headers.

    SELECT Requestid,
           Tmsp,
           Status,
           StatusCriticality,
           TotalRecords,
           SuccessRecords,
           ErrorRecords,
           WaitRecords,
           NotRelevant
      FROM /eacm/i_a24logp
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO CORRESPONDING FIELDS OF TABLE @lt_processes.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<header>).
      IF NOT line_exists(
           lt_existing_headers[ table_line = <header>-Requestid ] ).
        APPEND VALUE #(
          %tky        = <header>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Header.
        CONTINUE.
      ENDIF.

      LOOP AT lt_processes ASSIGNING FIELD-SYMBOL(<process>)
           WHERE Requestid = <header>-Requestid.

        INSERT VALUE #(
          source-%tky = <header>-%tky
          target-%tky = VALUE #(
            Requestid = <process>-Requestid
            Tmsp      = <process>-Tmsp )
        ) INTO TABLE association_links.

        IF result_requested = abap_true.
          APPEND CORRESPONDING #( <process> ) TO result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    SORT association_links BY source target.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.
    SORT result BY %tky.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.

  METHOD cba_Items.
  ENDMETHOD.

  METHOD cba_Processes.
  ENDMETHOD.

  METHOD ProcessOnline.
    READ ENTITIES OF /eacm/i_a24logh IN LOCAL MODE
        ENTITY Header ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_headers).

    LOOP AT lt_headers INTO DATA(ls_header).
      IF ls_header-Status <> /eacm/cl_a24=>c_h_received
         AND ls_header-Status <> /eacm/cl_a24=>c_h_partially.
        APPEND VALUE #(
          %tky        = ls_header-%tky
          %fail-cause = if_abap_behv=>cause-disabled )
          TO failed-Header.

        APPEND VALUE #(
          %tky = ls_header-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Elaborazione online non ammessa per stato { ls_header-Status }| ) )
          TO reported-Header.
        CONTINUE.
      ENDIF.

      INSERT ls_header-Requestid INTO TABLE gt_requestids.

      APPEND VALUE #(
        %tky   = ls_header-%tky
        %param = ls_header )
        TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
       entities FOR UPDATE Item.

    METHODS delete FOR MODIFY
       keys FOR DELETE Item.

    METHODS read FOR READ
       keys FOR READ Item RESULT result.

    METHODS rba_Header FOR READ
       keys_rba FOR READ Item\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT Requestid,
           Zlineno,
           Status,
           StatusCriticality,
           Message,
           Record,
           Vkorg,
           Vtweg,
           Zclpr,
           Vbeln,
           Posnr,
           Zcdaz,
           Zidag
      FROM /eacm/i_a24logi
      FOR ALL ENTRIES IN @keys
      WHERE Requestid = @keys-Requestid
        AND Zlineno   = @keys-Zlineno
      INTO CORRESPONDING FIELDS OF TABLE @result.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      IF NOT line_exists(
*           result[ Requestid = <key>-Requestid
*                   Zlineno   = <key>-Zlineno ] ).
            result[ KEY id COMPONENTS %tky = <key>-%tky ] ).
        APPEND VALUE #(
          %tky        = <key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Header.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_existing_items TYPE SORTED TABLE OF /eacm/a24logi
      WITH UNIQUE KEY requestid zlineno.

    DATA lt_headers TYPE STANDARD TABLE OF /eacm/i_a24logh
      WITH EMPTY KEY.

    SELECT Requestid,
           Zlineno
      FROM /eacm/a24logi
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
        AND Zlineno   = @keys_rba-Zlineno
      INTO CORRESPONDING FIELDS OF TABLE @lt_existing_items.

    SELECT Requestid,
           Filename,
           CreatedBy,
           CreatedAt,
           CreatedAtDisplay,
           Status,
           StatusCriticality
      FROM /eacm/i_a24logh
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO CORRESPONDING FIELDS OF TABLE @lt_headers.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<item_key>).
      IF NOT line_exists(
           lt_existing_items[
             requestid = <item_key>-Requestid
             zlineno   = <item_key>-Zlineno ] ).
        APPEND VALUE #(
          %tky        = <item_key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Item.
        CONTINUE.
      ENDIF.

      READ TABLE lt_headers ASSIGNING FIELD-SYMBOL(<header>)
        WITH KEY Requestid = <item_key>-Requestid.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          %tky        = <item_key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Item.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        source-%tky = <item_key>-%tky
        target-%tky = VALUE #(
          Requestid = <header>-Requestid )
      ) INTO TABLE association_links.

      IF result_requested = abap_true.
        APPEND CORRESPONDING #( <header> ) TO result.
      ENDIF.
    ENDLOOP.

    SORT association_links BY source target.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.
    SORT result BY %tky.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Process DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
       entities FOR UPDATE Process.

    METHODS delete FOR MODIFY
       keys FOR DELETE Process.

    METHODS read FOR READ
       keys FOR READ Process RESULT result.

    METHODS rba_Header FOR READ
       keys_rba FOR READ Process\_Header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Process IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT Requestid,
           Tmsp,
           Status,
           StatusCriticality,
           TotalRecords,
           SuccessRecords,
           ErrorRecords,
           WaitRecords,
           NotRelevant
      FROM /eacm/i_a24logp
      FOR ALL ENTRIES IN @keys
      WHERE Requestid = @keys-Requestid
        AND Tmsp      = @keys-Tmsp
      INTO CORRESPONDING FIELDS OF TABLE @result.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      IF NOT line_exists(
*           result[ Requestid = <key>-Requestid
*                   Tmsp      = <key>-Tmsp ] ).
           result[ KEY id COMPONENTS %tky = <key>-%tky ] ).
        APPEND VALUE #(
          %tky        = <key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Process.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Header.
    IF keys_rba IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_existing_processes TYPE SORTED TABLE OF /eacm/a24logp
      WITH UNIQUE KEY requestid tmsp.

    DATA lt_headers TYPE STANDARD TABLE OF /eacm/i_a24logh
      WITH EMPTY KEY.

    SELECT Requestid,
           Tmsp
      FROM /eacm/a24logp
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
        AND Tmsp      = @keys_rba-Tmsp
      INTO CORRESPONDING FIELDS OF TABLE @lt_existing_processes.

    SELECT Requestid,
           Filename,
           CreatedBy,
           CreatedAt,
           CreatedAtDisplay,
           Status,
           StatusCriticality
      FROM /eacm/i_a24logh
      FOR ALL ENTRIES IN @keys_rba
      WHERE Requestid = @keys_rba-Requestid
      INTO CORRESPONDING FIELDS OF TABLE @lt_headers.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<process_key>).
      IF NOT line_exists(
           lt_existing_processes[
             requestid = <process_key>-Requestid
             tmsp      = <process_key>-Tmsp ] ).
        APPEND VALUE #(
          %tky        = <process_key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Process.
        CONTINUE.
      ENDIF.

      READ TABLE lt_headers ASSIGNING FIELD-SYMBOL(<header>)
        WITH KEY Requestid = <process_key>-Requestid.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          %tky        = <process_key>-%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-Process.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        source-%tky = <process_key>-%tky
        target-%tky = VALUE #(
          Requestid = <header>-Requestid )
      ) INTO TABLE association_links.

      IF result_requested = abap_true.
        APPEND CORRESPONDING #( <header> ) TO result.
      ENDIF.
    ENDLOOP.

    SORT association_links BY source target.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.
    SORT result BY %tky.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_I_A24LOGH DEFINITION INHERITING FROM cl_abap_behavior_saver_failed.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_I_A24LOGH IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    LOOP AT lhc_header=>gt_requestids INTO DATA(lv_requestid).

      TRY.
          NEW /eacm/cl_a24( )->process_request(
            i_requestid = lv_requestid
            i_commit    = abap_false ).

        CATCH cx_apj_rt_content INTO DATA(lx_error).

          APPEND VALUE #(
            %tky = VALUE #( RequestId = lv_requestid )
            %fail-cause = if_abap_behv=>cause-unspecific
          ) TO failed-header.

          APPEND VALUE #(
            %tky = VALUE #( RequestId = lv_requestid )
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = lx_error->get_text( ) )
          ) TO reported-header.

          "Un errore nella late save annulla tutto il changeset
          EXIT.

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup.
    CLEAR lhc_header=>gt_requestids.
  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR lhc_header=>gt_requestids.
  ENDMETHOD.

ENDCLASS.
