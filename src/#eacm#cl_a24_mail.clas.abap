CLASS /eacm/cl_a24_mail DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_summary,
        requestid       TYPE /eacm/a24logh-requestid,
        file_name       TYPE /eacm/a24logh-file_name,
        status          TYPE /eacm/a24logh-status,
        total_records   TYPE i,
        success_records TYPE i,
        error_records   TYPE i,
        wait_records    TYPE i,
        not_relevant    TYPE i,
      END OF ty_summary,

      ty_t_summary TYPE STANDARD TABLE OF ty_summary
        WITH EMPTY KEY.

    METHODS send_summary
      IMPORTING
        it_summary    TYPE ty_t_summary
      EXPORTING
        ev_sent       TYPE abap_boolean
        ev_error_text TYPE string.

  PRIVATE SECTION.

    CONSTANTS:
      c_config_default  TYPE c LENGTH 20 VALUE 'DEFAULT',
      c_send_always     TYPE c LENGTH 1  VALUE 'A', "Sempre
      c_send_error_only TYPE c LENGTH 1  VALUE 'E'. "Solo se ci sono errori

    TYPES:
      BEGIN OF ty_config,
        found          TYPE abap_boolean,
        active         TYPE abap_boolean,
        send_mode      TYPE c LENGTH 1,
        recipient      TYPE c LENGTH 241,
        sender         TYPE c LENGTH 241,
        subject_prefix TYPE c LENGTH 100,
      END OF ty_config.

    METHODS read_config
      RETURNING VALUE(rs_config) TYPE ty_config.

    METHODS build_html
      IMPORTING
                it_summary         TYPE ty_t_summary
                iv_has_errors      TYPE abap_boolean
                iv_total_records   TYPE i
                iv_success_records TYPE i
                iv_error_records   TYPE i
                iv_wait_records    TYPE i
                iv_not_relevant    TYPE i
      RETURNING VALUE(rv_html)     TYPE string.

ENDCLASS.

CLASS /eacm/cl_a24_mail IMPLEMENTATION.

  METHOD read_config.

    SELECT SINGLE
           active,
           send_mode,
           recipient,
           sender,
           subject_prefix
      FROM /eacm/a24mailc
      WHERE config_id = @c_config_default
      INTO CORRESPONDING FIELDS OF @rs_config.

    IF sy-subrc = 0.
      rs_config-found = abap_true.
    ELSE.
      INSERT INTO /eacm/a24mailc VALUES @(
        VALUE #( config_id   = 'DEFAULT' ) ).
    ENDIF.

  ENDMETHOD.


  METHOD send_summary.

    CLEAR:
      ev_sent,
      ev_error_text.

    IF it_summary IS INITIAL.
      RETURN.
    ENDIF.

    DATA(ls_config) = read_config( ).

    IF ls_config-found = abap_false.
      ev_error_text =
        `Configurazione email A24 DEFAULT non trovata.`.
      RETURN.
    ENDIF.

    IF ls_config-active = abap_false.
      RETURN.
    ENDIF.

    IF ls_config-recipient IS INITIAL.
      ev_error_text =
        `Destinatario email A24 non configurato.`.
      RETURN.
    ENDIF.

    TRANSLATE ls_config-send_mode TO UPPER CASE.

    IF ls_config-send_mode <> c_send_always
       AND ls_config-send_mode <> c_send_error_only.
      ev_error_text =
        |Modalita' di invio email non valida: { ls_config-send_mode }.|.
      RETURN.
    ENDIF.

    DATA:
      lv_total_records   TYPE i,
      lv_success_records TYPE i,
      lv_error_records   TYPE i,
      lv_wait_records    TYPE i,
      lv_not_relevant    TYPE i,
      lv_has_errors      TYPE abap_boolean.

    LOOP AT it_summary ASSIGNING FIELD-SYMBOL(<summary>).

      lv_total_records += <summary>-total_records.
      lv_success_records += <summary>-success_records.
      lv_error_records += <summary>-error_records.
      lv_wait_records += <summary>-wait_records.
      lv_not_relevant += <summary>-not_relevant.

      IF <summary>-error_records > 0
         OR <summary>-wait_records > 0.
        lv_has_errors = abap_true.
      ENDIF.

    ENDLOOP.

    IF ls_config-send_mode = c_send_error_only
       AND lv_has_errors = abap_false.
      RETURN.
    ENDIF.

    DATA(lv_prefix) = COND string(
      WHEN ls_config-subject_prefix IS INITIAL
      THEN `[A24]`
      ELSE CONV string( ls_config-subject_prefix ) ).

    DATA(lv_outcome) = COND string(
      WHEN lv_has_errors = abap_true
      THEN `completata con anomalie`
      ELSE `completata correttamente` ).

    DATA(lv_subject) =
      |{ lv_prefix } Elaborazione { lv_outcome } - | &&
      |{ lines( it_summary ) } testate, | &&
      |{ lv_error_records } errori|.

    DATA(lv_html) = build_html(
      it_summary         = it_summary
      iv_has_errors      = lv_has_errors
      iv_total_records   = lv_total_records
      iv_success_records = lv_success_records
      iv_error_records   = lv_error_records
      iv_wait_records    = lv_wait_records
      iv_not_relevant    = lv_not_relevant ).

    TRY.
        DATA(lo_mail) =
          cl_bcs_mail_message=>create_instance( ).

        IF ls_config-sender IS NOT INITIAL.
          lo_mail->set_sender( CONV #( ls_config-sender ) ).
        ENDIF.


        DATA lt_recipients TYPE STANDARD TABLE OF string
                           WITH EMPTY KEY.
        DATA(lv_recipients) = CONV string( ls_config-recipient ).

        SPLIT lv_recipients AT ';'
          INTO TABLE lt_recipients.

        DATA lv_recipient_count TYPE i.

        LOOP AT lt_recipients INTO DATA(lv_recipient).

          " Elimina eventuali spazi intorno all'indirizzo
          CONDENSE lv_recipient.

          IF lv_recipient IS INITIAL.
            CONTINUE.
          ENDIF.

          lo_mail->add_recipient(
            CONV #( lv_recipient )
          ).

          lv_recipient_count += 1.

        ENDLOOP.

        IF lv_recipient_count = 0.
          ev_error_text =
            `Nessun destinatario email A24 configurato.`.
          RETURN.
        ENDIF.
*        lo_mail->add_recipient( CONV #( ls_config-recipient ) ).
        lo_mail->set_subject( CONV #( lv_subject ) ).

        lo_mail->set_main(
          cl_bcs_mail_textpart=>create_text_html(
            lv_html ) ).

        DATA(lo_status_monitor) = lo_mail->send( ).

        IF lo_status_monitor IS BOUND.
          ev_sent = abap_true.
        ENDIF.

      CATCH cx_bcs_mail INTO DATA(lx_mail).
        ev_error_text = lx_mail->get_text( ).
    ENDTRY.

  ENDMETHOD.


  METHOD build_html.

    DATA(lv_outcome) = COND string(
      WHEN iv_has_errors = abap_true
      THEN `Completata con anomalie`
      ELSE `Completata correttamente` ).

    rv_html =
      |<!DOCTYPE html>| &&
      |<html><body style="font-family:Arial,sans-serif;font-size:14px;">| &&
      |<h2>Riepilogo elaborazione A24</h2>| &&
      |<p>Esito: <strong>{ lv_outcome }</strong></p>| &&
      |<table style="border-collapse:collapse;width:100%;">| &&
      |<thead><tr style="background-color:#e8e8e8;">| &&
      |<th style="border:1px solid #999;padding:6px;">Request ID</th>| &&
      |<th style="border:1px solid #999;padding:6px;">File</th>| &&
      |<th style="border:1px solid #999;padding:6px;">Stato</th>| &&
      |<th style="border:1px solid #999;padding:6px;">Totali</th>| &&
      |<th style="border:1px solid #999;padding:6px;">Inseriti</th>| &&
      |<th style="border:1px solid #999;padding:6px;">Errori</th>| &&
      |<th style="border:1px solid #999;padding:6px;">In attesa</th>| &&
      |<th style="border:1px solid #999;padding:6px;">Non rilevanti</th>| &&
      |</tr></thead><tbody>|.

    LOOP AT it_summary ASSIGNING FIELD-SYMBOL(<summary>).

      DATA(lv_requestid) = escape(
        val    = |{ <summary>-requestid }|
        format = cl_abap_format=>e_html_text ).

      DATA(lv_file_name) = escape(
        val    = CONV string( <summary>-file_name )
        format = cl_abap_format=>e_html_text ).

      DATA(lv_status) = escape(
        val    = CONV string( <summary>-status )
        format = cl_abap_format=>e_html_text ).

      rv_html = rv_html &&
        |<tr>| &&
        |<td style="border:1px solid #999;padding:6px;">{ lv_requestid }</td>| &&
        |<td style="border:1px solid #999;padding:6px;">{ lv_file_name }</td>| &&
        |<td style="border:1px solid #999;padding:6px;">{ lv_status }</td>| &&
        |<td style="border:1px solid #999;padding:6px;text-align:right;">{ <summary>-total_records }</td>| &&
        |<td style="border:1px solid #999;padding:6px;text-align:right;">{ <summary>-success_records }</td>| &&
        |<td style="border:1px solid #999;padding:6px;text-align:right;">{ <summary>-error_records }</td>| &&
        |<td style="border:1px solid #999;padding:6px;text-align:right;">{ <summary>-wait_records }</td>| &&
        |<td style="border:1px solid #999;padding:6px;text-align:right;">{ <summary>-not_relevant }</td>| &&
        |</tr>|.

    ENDLOOP.

    rv_html = rv_html &&
      |<tr style="font-weight:bold;background-color:#f2f2f2;">| &&
      |<td colspan="3" style="border:1px solid #999;padding:6px;">| &&
      |Totale { lines( it_summary ) } testate</td>| &&
      |<td style="border:1px solid #999;padding:6px;text-align:right;">{ iv_total_records }</td>| &&
      |<td style="border:1px solid #999;padding:6px;text-align:right;">{ iv_success_records }</td>| &&
      |<td style="border:1px solid #999;padding:6px;text-align:right;">{ iv_error_records }</td>| &&
      |<td style="border:1px solid #999;padding:6px;text-align:right;">{ iv_wait_records }</td>| &&
      |<td style="border:1px solid #999;padding:6px;text-align:right;">{ iv_not_relevant }</td>| &&
      |</tr></tbody></table>| &&
      |</body></html>|.

  ENDMETHOD.

ENDCLASS.
