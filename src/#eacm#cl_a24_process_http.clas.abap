CLASS /eacm/cl_a24_process_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_request,
        request_id TYPE string,
      END OF ty_request,

      BEGIN OF ty_response,
        success    TYPE xsdboolean,
        message    TYPE string,
        request_id TYPE string,
        file_name  TYPE /eacm/a24logh-file_name,
        status     TYPE /eacm/a24logh-status,
      END OF ty_response.

    METHODS set_json_response
      IMPORTING
        io_response  TYPE REF TO if_web_http_response
        iv_http_code TYPE i
        iv_reason    TYPE string
        is_body      TYPE ty_response
      RAISING
        cx_web_message_error.
ENDCLASS.


CLASS /eacm/cl_a24_process_http IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

    TRY.
        "Gestisce sia il recupero sia la validazione del token CSRF.
        DATA(lv_csrf_valid) =
          cl_http_service_utility=>handle_csrf(
            request  = request
            response = response ).

        "Nel GET con X-CSRF-Token: Fetch la risposta è già stata prodotta.
        CHECK lv_csrf_valid = abap_true.

        DATA ls_request  TYPE ty_request.
        DATA ls_response TYPE ty_response.
        DATA lv_requestid TYPE /eacm/a24logh-requestid.

        DATA(lv_http_code) = 200.
        DATA(lv_reason)    = `OK`.

        DO 1 TIMES.

          "Il servizio ammette soltanto POST.
          IF request->get_method( )
             <> CONV string( if_web_http_client=>post ).

            lv_http_code = 405.
            lv_reason = `Method Not Allowed`.
            ls_response-message = `Utilizzare il metodo HTTP POST`.

            response->set_header_field(
              i_name  = `Allow`
              i_value = `POST` ).
            EXIT.
          ENDIF.

          DATA(lv_payload) = request->get_text( ).

          IF lv_payload IS INITIAL.
            lv_http_code = 400.
            lv_reason = `Bad Request`.
            ls_response-message = `Payload JSON mancante`.
            EXIT.
          ENDIF.

          "Converte {"RequestId":"..."} nella struttura ABAP REQUEST_ID.
          TRY.
              xco_cp_json=>data->from_string( lv_payload
                )->apply( VALUE #(
                  ( xco_cp_json=>transformation->pascal_case_to_underscore )
                ) )->write_to( REF #( ls_request ) ).

            CATCH cx_root INTO DATA(lx_json).
              lv_http_code = 400.
              lv_reason = `Bad Request`.
              ls_response-message =
                |Payload JSON non valido: { lx_json->get_text( ) }|.
              EXIT.
          ENDTRY.

          DATA(lv_requestid_text) = ls_request-request_id.
          CONDENSE lv_requestid_text NO-GAPS.
          TRANSLATE lv_requestid_text TO UPPER CASE.
          REPLACE ALL OCCURRENCES OF `-`
            IN lv_requestid_text WITH ``.

          IF strlen( lv_requestid_text ) <> 32
             OR lv_requestid_text CN `0123456789ABCDEF`.

            lv_http_code = 400.
            lv_reason = `Bad Request`.
            ls_response-message =
              `RequestId deve essere un UUID C32 o C36 valido`.
            EXIT.
          ENDIF.

          TRY.
              lv_requestid =
                xco_cp_uuid=>format->c32->to_uuid(
                  CONV sysuuid_c32( lv_requestid_text )
                )->value.

            CATCH cx_root INTO DATA(lx_uuid).
              lv_http_code = 400.
              lv_reason = `Bad Request`.
              ls_response-message =
                |RequestId non valido: { lx_uuid->get_text( ) }|.
              EXIT.
          ENDTRY.

          ls_response-request_id = lv_requestid_text.

          SELECT SINGLE FROM /eacm/a24logh
            FIELDS file_name,
                   status
            WHERE requestid = @lv_requestid
            INTO @DATA(ls_header).

          IF sy-subrc <> 0.
            lv_http_code = 404.
            lv_reason = `Not Found`.
            ls_response-message = `Testata A24 non trovata`.
            EXIT.
          ENDIF.

          ls_response-file_name = ls_header-file_name.
          ls_response-status    = ls_header-status.

          IF ls_header-status <> /eacm/cl_a24=>c_h_received
             AND ls_header-status <> /eacm/cl_a24=>c_h_partially.

            lv_http_code = 409.
            lv_reason = `Conflict`.
            ls_response-message =
              |Elaborazione non ammessa per lo stato { ls_header-status }|.
            EXIT.
          ENDIF.

          TRY.
              NEW /eacm/cl_a24( )->process_request(
                i_requestid = lv_requestid
                i_commit    = abap_true ).

              "Conferma anche eventuali aggiornamenti finali.
              COMMIT WORK AND WAIT.

            CATCH cx_root INTO DATA(lx_process).
              "Non annulla gli eventuali commit già eseguiti da CL_A24.
              ROLLBACK WORK.

              lv_http_code = 500.
              lv_reason = `Internal Server Error`.
              ls_response-message =
                |Errore durante l'elaborazione: { lx_process->get_text( ) }|.
              EXIT.
          ENDTRY.

          SELECT SINGLE FROM /eacm/a24logh
            FIELDS status
            WHERE requestid = @lv_requestid
            INTO @DATA(lv_final_status).

          ls_response-status = lv_final_status.

          IF lv_final_status = /eacm/cl_a24=>c_h_inprogress.
            lv_http_code = 409.
            lv_reason = `Conflict`.
            ls_response-message =
              `La richiesta è stata acquisita da un'altra elaborazione`.
            EXIT.
          ENDIF.

          ls_response-success = abap_true.
          ls_response-message =
            |Elaborazione terminata. Stato: { lv_final_status }|.

        ENDDO.

        set_json_response(
          io_response  = response
          iv_http_code = lv_http_code
          iv_reason    = lv_reason
          is_body      = ls_response ).

      CATCH cx_web_message_error.
        "La risposta HTTP non può più essere modificata.
    ENDTRY.

  ENDMETHOD.


  METHOD set_json_response.

    DATA(lv_json) =
      xco_cp_json=>data->from_abap( is_body
        )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->to_string( ).

    io_response->set_status(
      i_code   = iv_http_code
      i_reason = iv_reason ).

    io_response->set_header_field(
      i_name  = `Content-Type`
      i_value = `application/json; charset=utf-8` ).

    io_response->set_header_field(
      i_name  = `Cache-Control`
      i_value = `no-store` ).

    io_response->set_text( lv_json ).

  ENDMETHOD.

ENDCLASS.
