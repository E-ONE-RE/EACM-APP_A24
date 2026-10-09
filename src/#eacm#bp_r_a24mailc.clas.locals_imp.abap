CLASS lhc_/eacm/r_a24mailc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR /eacm/rA24mailc
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
       keys FOR /eacm/rA24mailc~validateMandatoryFields.
ENDCLASS.

CLASS lhc_/eacm/r_a24mailc IMPLEMENTATION.
  METHOD get_global_authorizations.
    IF requested_authorizations-%update = if_abap_behv=>mk-on
     OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on.

      result-%update =
        if_abap_behv=>auth-allowed.

      result-%action-Edit =
        if_abap_behv=>auth-allowed.

    ENDIF.
  ENDMETHOD.

  METHOD validateMandatoryFields.

    READ ENTITIES OF /eacm/r_a24mailc IN LOCAL MODE
      ENTITY /eacm/rA24mailc
        FIELDS ( SendMode Recipient Sender )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_configurations).

    LOOP AT lt_configurations ASSIGNING FIELD-SYMBOL(<ls_configuration>).

      DATA(lv_has_error) = abap_false.

      "Elimina eventuali messaggi precedenti della stessa validation
      APPEND VALUE #(
        %tky        = <ls_configuration>-%tky
        %state_area = 'REQUIRED_FIELDS'
      ) TO reported-/eacm/rA24mailc.

      IF <ls_configuration>-SendMode IS INITIAL.
        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky              = <ls_configuration>-%tky
          %state_area       = 'REQUIRED_FIELDS'
          %element-SendMode = if_abap_behv=>mk-on
          %msg              = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'La modalità di invio è obbligatoria' )
        ) TO reported-/eacm/rA24mailc.
      ENDIF.

      IF <ls_configuration>-Recipient IS INITIAL.
        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky               = <ls_configuration>-%tky
          %state_area        = 'REQUIRED_FIELDS'
          %element-Recipient = if_abap_behv=>mk-on
          %msg               = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Il destinatario è obbligatorio' )
        ) TO reported-/eacm/rA24mailc.
      ENDIF.

      IF <ls_configuration>-Sender IS INITIAL.
        lv_has_error = abap_true.

        APPEND VALUE #(
          %tky            = <ls_configuration>-%tky
          %state_area     = 'REQUIRED_FIELDS'
          %element-Sender = if_abap_behv=>mk-on
          %msg            = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'Il mittente è obbligatorio' )
        ) TO reported-/eacm/rA24mailc.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #(
          %tky = <ls_configuration>-%tky
        ) TO failed-/eacm/rA24mailc.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
