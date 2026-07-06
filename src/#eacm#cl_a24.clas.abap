CLASS /eacm/cl_a24 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_rt_run.

    "stato testata
    CONSTANTS c_h_received TYPE c LENGTH 20 VALUE 'RECEIVED'.
    CONSTANTS c_h_inprogress TYPE c LENGTH 20 VALUE 'IN_PROGRESS'.
    CONSTANTS c_h_partially TYPE c LENGTH 20 VALUE 'PARTIALLY'.
    CONSTANTS c_h_complete TYPE c LENGTH 20 VALUE 'COMPLETE'.
    "stato linea
    CONSTANTS c_i_uploaded TYPE c LENGTH 20 VALUE 'UPLOADED'.
    CONSTANTS c_i_notrelevant TYPE c LENGTH 20 VALUE 'NOT_RELEVANT'.
    CONSTANTS c_i_error TYPE c LENGTH 20 VALUE 'ERROR'.
    CONSTANTS c_i_wait TYPE c LENGTH 20 VALUE 'WAIT'.

*    METHODS run RAISING cx_apj_rt.
    METHODS run RAISING cx_apj_rt_content.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES BEGIN OF tp_condm.
    TYPES rbslx(004)            TYPE c.
    TYPES rbk1x(001)            TYPE c.
    TYPES rbk9x(001)            TYPE c.
    TYPES rbbex(009)            TYPE n.
    TYPES rbbex_sign(001)       TYPE c.
    TYPES rbwex(009)            TYPE n.
    TYPES rbawx(011)            TYPE n.
    TYPES END OF tp_condm.
    TYPES BEGIN OF tp_condn.
    TYPES rbslz(004)            TYPE c.
    TYPES rbk1x(001)            TYPE c.
    TYPES rbk9x(001)            TYPE c.
    TYPES rbbex(009)            TYPE n.
    TYPES  rbbex_sign(001)       TYPE c.
    TYPES rbwex(009)            TYPE n.
    TYPES rbawx(011)            TYPE n.
    TYPES END OF tp_condn.
    CONSTANTS pa_rbsl1(004) TYPE c VALUE 'A0  '.
    CONSTANTS pa_rbsl2(004) TYPE c VALUE 'A1  '.
    CONSTANTS pa_rbsl3(004) TYPE c  VALUE 'AM  '.
    CONSTANTS pa_rbsl4(004) TYPE c VALUE 'BX  '.
    CONSTANTS pa_rbk9x TYPE c VALUE 'M'.
    CONSTANTS pa_rbsl5(004) TYPE c VALUE 'CO  '.
    CONSTANTS pa_rbsl6(004) TYPE c VALUE 'SC  '.
    CONSTANTS pa_cond1(4)   TYPE c VALUE 'ZLA1'.
    CONSTANTS pa_cond2(4)   TYPE c VALUE 'ZLA5'.
    TYPES BEGIN OF tp_dosum.
    TYPES vkorg TYPE /eacm/prdo-vkorg.
    TYPES vtweg TYPE /eacm/prdo-vtweg.
    TYPES zclpr TYPE /eacm/prdo-zclpr.
    TYPES vbeln TYPE /eacm/prdo-vbeln.
    TYPES END OF tp_dosum.

    METHODS get_items RETURNING VALUE(r_items) TYPE /eacm/tt_a24logi.
    METHODS scrittura_record
      IMPORTING
        i_record TYPE /eacm/a24_scheme
        i_condm  TYPE /eacm/cl_a24=>tp_condm
        i_condn  TYPE /eacm/cl_a24=>tp_condn
      CHANGING
        e_comm   TYPE /eacm/st_a24_commission.
    METHODS parse
      IMPORTING
        i_item          TYPE /eacm/a24logi-record
      RETURNING
        VALUE(r_result) TYPE /eacm/a24_scheme.
    METHODS duplicate
      IMPORTING
        i_item          TYPE /eacm/a24logi
        i_record        TYPE /eacm/a24_scheme
      RETURNING
        VALUE(r_result) TYPE abap_bool.

    METHODS make_commission
      IMPORTING i_item          TYPE /eacm/a24logi
                i_record        TYPE /eacm/a24_scheme
      RETURNING VALUE(r_result) TYPE /eacm/st_a24_commission.

    METHODS lettura_condizioni
      IMPORTING
                i_item    TYPE /eacm/a24logi
                i_record  TYPE /eacm/a24_scheme
      EXPORTING e_condm   TYPE tp_condm
                e_condn   TYPE tp_condn
                e_comm    TYPE /eacm/st_a24_commission
      CHANGING  c_status  TYPE /eacm/a24logi-status
                c_message TYPE /eacm/a24logi-message.
    METHODS lettura_condsd
      IMPORTING i_vkorg   TYPE vkorg
                i_rbslx   TYPE clike
      EXPORTING e_kschl   TYPE  /eacm/condsd-kschl1
      CHANGING  c_status  TYPE /eacm/a24logi-status
                c_message TYPE /eacm/a24logi-message.
    METHODS fill_zprdo
      IMPORTING
        i_item   TYPE /eacm/a24logi
*        i_record TYPE /eacm/a24_scheme
        i_comm   TYPE /eacm/st_a24_commission
        i_zestra TYPE /eacm/prdo-zestra.
    METHODS get_no_estra RETURNING VALUE(r_result) TYPE /eacm/prdo-zestra.
    METHODS monthly_commissions IMPORTING i_prdo TYPE /eacm/prdo.
    METHODS provvigione_specialist_ew
      CHANGING
        i_record TYPE /eacm/a24_scheme.
    METHODS crete_new_item
      IMPORTING
        i_item          TYPE /eacm/a24logi
      RETURNING
        VALUE(r_result) TYPE /eacm/a24logi.
    METHODS aggiornamento_importi
      IMPORTING
        i_headers TYPE /eacm/tt_a24logi.

ENDCLASS.



CLASS /eacm/cl_a24 IMPLEMENTATION.

  METHOD if_apj_rt_run~execute.

    TRY.
        run( ).
      CATCH cx_apj_rt_content INTO DATA(lo_cx).
        "handle exception
        RAISE EXCEPTION TYPE cx_apj_rt_content EXPORTING previous = lo_cx.
    ENDTRY.


  ENDMETHOD.

  METHOD get_items.
    "segno i record come IN_PROGRESS per fare in modo che un JOB sovrapposto possa estrarlo e lavorarlo
    "Solo i record RECEIVED e WAIT sono da elaborare
    CLEAR r_items[].

    SELECT FROM /eacm/a24logh
    FIELDS requestid
    WHERE status = @c_h_received OR status = @c_h_partially
    INTO TABLE @DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).
      UPDATE /eacm/a24logh
      SET status = @c_h_inprogress
      WHERE requestid =  @ls_header-requestid
      AND ( status = @c_h_received OR status = @c_h_partially ).
      IF sy-dbcnt = 1.
        "testata libera e bloccata
        UPDATE /eacm/a24logi
        SET status = @c_h_inprogress
        WHERE requestid = @ls_header-requestid
        AND ( status = @c_i_wait OR status = @c_h_received ). "DA VERIFICARE
        IF sy-subrc <> 0.
          UPDATE /eacm/a24logh
          SET status = @c_h_complete
          WHERE requestid =  @ls_header-requestid.
        ENDIF.
        COMMIT WORK AND WAIT.

        SELECT FROM /eacm/a24logi
        FIELDS requestid, zlineno, status, message, record
        WHERE requestid = @ls_header-requestid
        AND status = @c_h_inprogress
        APPENDING CORRESPONDING FIELDS OF TABLE @r_items.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD parse.
    r_result = i_item.
  ENDMETHOD.


  METHOD duplicate.

    SELECT COUNT( * )
      FROM /eacm/prdo
      WHERE vkorg = @i_record-vkorg
        AND vtweg = '01'
        AND zclpr = 'SB'
        AND vbeln = @i_record-nfat
        AND posnr = @i_record-posnr.
    IF sy-subrc = 0.
      "Double record
      MESSAGE w001(/eacm/a24) INTO DATA(lv_msg).
      UPDATE /eacm/a24logi
      SET status = @c_i_notrelevant,
      message = @lv_msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      r_result = abap_true.
    ELSE.
      r_result = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD make_commission.
    CLEAR r_result.

*    IF wk_ind_file = 2.
*        CLEAR <a24a>-vrtnr.
*        IF <a24a>-vrtnr_2 CO '0 '.
*          CONTINUE.
*        ENDIF.
*        = <a24a>-vrtnr_2         TO <a24a>-vrtnr.
*        PERFORM px_provvigione_specialist_ew CHANGING <a24a>.
*      ENDIF.
    IF i_record-bukrs IS INITIAL.
      MESSAGE e005(/eacm/a24) INTO DATA(msg).
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
        message = @msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-vkorg IS INITIAL.
      MESSAGE e006(/eacm/a24) INTO msg.
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
        message = @msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-spart IS INITIAL.
      MESSAGE e007(/eacm/a24) INTO msg.
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
        message = @msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-fkart IS INITIAL.
      MESSAGE e010(/eacm/a24) INTO msg.
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
        message = @msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-vrtnr = space.  "Cliente/Agente
      UPDATE /eacm/a24logi
      SET status = @c_i_notrelevant
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    "org. comm. escluse
    SELECT SINGLE COUNT( * )
    FROM /eacm/a24exvk
    WHERE vkorg = @i_record-vkorg..
    IF sy-subrc = 0.
      UPDATE /eacm/a24logi
      SET status = @c_i_notrelevant
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-pstyp <> 'N'.
      UPDATE /eacm/a24logi
      SET status = @c_i_notrelevant
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-fkart IS INITIAL.
      UPDATE /eacm/a24logi
        SET status = @c_i_notrelevant
        WHERE requestid = @i_item-requestid
        AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    IF i_record-zflg+001(001) <> abap_true.
      UPDATE /eacm/a24logi
        SET status = @c_i_notrelevant
        WHERE requestid = @i_item-requestid
        AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    SELECT SINGLE
    FROM /eacm/tdsdfi
    FIELDS blart
     WHERE vkorg = @i_record-vkorg
       AND fkart = @i_record-fkart
       AND blart <> @space
       INTO @DATA(lv_blart).
    IF sy-subrc <> 0.
      SELECT SINGLE
      FROM /eacm/tdsdfi
      FIELDS blart
      WHERE vkorg EQ '++++'
      AND fkart = @i_record-fkart
      AND blart <> @space
      INTO @lv_blart.
      IF sy-subrc <> 0.
        "No entrys in /EACM/TDSDFI for: &1, &2
        MESSAGE w002(/eacm/a24) WITH i_record-vkorg i_record-fkart
        INTO DATA(lv_msg).

        UPDATE /eacm/a24logi
        SET status = @c_i_error,
        message = @lv_msg
        WHERE requestid = @i_item-requestid
        AND zlineno = @i_item-zlineno.
        COMMIT WORK AND WAIT.
        RETURN.

      ENDIF.
    ENDIF.

    DATA ls_condm TYPE tp_condm.
    DATA ls_condn TYPE tp_condn.
    DATA lv_status TYPE /eacm/a24logi-status.
    DATA lv_message TYPE /eacm/a24logi-message.


    lettura_condizioni(
      EXPORTING
        i_item    = i_item
        i_record  = i_record
      IMPORTING
        e_condm   = ls_condm
        e_condn   = ls_condn
        e_comm    = r_result
      CHANGING
        c_status  = lv_status
        c_message = lv_message
    ).
    IF lv_status IS NOT INITIAL.
      UPDATE /eacm/a24logi
         SET status = @lv_status,
         message = @lv_message
         WHERE requestid = @i_item-requestid
         AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      CLEAR r_result.
      RETURN.
    ENDIF.

    r_result-kndnr+000(004) = '0011'.
    r_result-blart = lv_blart.

    scrittura_record(
        EXPORTING
            i_record  = i_record
            i_condm   = ls_condm
            i_condn   = ls_condn
        CHANGING
            e_comm    = r_result
     ).

  ENDMETHOD.

  METHOD lettura_condizioni.

* Struttura per lettura condizioni
    DATA: BEGIN OF wk_condizioni,
            rbslx(004)      TYPE c,
            rbk1x(001)      TYPE c,
            rbk9x(001)      TYPE c,
            rbbex(009)      TYPE n,
            rbbex_sign(001) TYPE c,
            rbwex(009)      TYPE n,
            rbawx(011)      TYPE n,
            rbsl2(004)      TYPE c,
            rbk12(001)      TYPE c,
            rbk92(001)      TYPE c,
            rbbe2(009)      TYPE n,
            rbbe2_sign(001) TYPE c,
            rbwe2(009)      TYPE n,
            rbaw2(011)      TYPE n,
            rbsl3(004)      TYPE c,
            rbk13(001)      TYPE c,
            rbk93(001)      TYPE c,
            rbbe3(009)      TYPE n,
            rbbe3_sign(001) TYPE c,
            rbwe3(009)      TYPE n,
            rbaw3(011)      TYPE n,
            rbsl4(004)      TYPE c,
            rbk14(001)      TYPE c,
            rbk94(001)      TYPE c,
            rbbe4(009)      TYPE n,
            rbbe4_sign(001) TYPE c,
            rbwe4(009)      TYPE n,
            rbaw4(011)      TYPE n,
            rbsl5(004)      TYPE c,
            rbk15(001)      TYPE c,
            rbk95(001)      TYPE c,
            rbbe5(009)      TYPE n,
            rbbe5_sign(001) TYPE c,
            rbwe5(009)      TYPE n,
            rbaw5(011)      TYPE n,
            rbsl6(004)      TYPE c,
            rbk16(001)      TYPE c,
            rbk96(001)      TYPE c,
            rbbe6(009)      TYPE n,
            rbbe6_sign(001) TYPE c,
            rbwe6(009)      TYPE n,
            rbaw6(011)      TYPE n,
            rbsl7(004)      TYPE c,
            rbk17(001)      TYPE c,
            rbk97(001)      TYPE c,
            rbbe7(009)      TYPE n,
            rbbe7_sign(001) TYPE c,
            rbwe7(009)      TYPE n,
            rbaw7(011)      TYPE n,
            rbsl8(004)      TYPE c,
            rbk18(001)      TYPE c,
            rbk98(001)      TYPE c,
            rbbe8(009)      TYPE n,
            rbbe8_sign(001) TYPE c,
            rbwe8(009)      TYPE n,
            rbaw8(011)      TYPE n,
            rbsl9(004)      TYPE c,
            rbk19(001)      TYPE c,
            rbk99(001)      TYPE c,
            rbbe9(009)      TYPE n,
            rbbe9_sign(001) TYPE c,
            rbwe9(009)      TYPE n,
            rbaw9(011)      TYPE n,
            rbslf(004)      TYPE c,
            rbk1f(001)      TYPE c,
            rbk9f(001)      TYPE c,
            rbbef(009)      TYPE n,
            rbbef_sign(001) TYPE c,
            rbwef(009)      TYPE n,
            rbawf(011)      TYPE n,
            rbslg(004)      TYPE c,
            rbk1g(001)      TYPE c,
            rbk9g(001)      TYPE c,
            rbbeg(009)      TYPE n,
            rbbeg_sign(001) TYPE c,
            rbweg(009)      TYPE n,
            rbawg(011)      TYPE n,
            rbslh(004)      TYPE c,
            rbk1h(001)      TYPE c,
            rbk9h(001)      TYPE c,
            rbbeh(009)      TYPE n,
            rbbeh_sign(001) TYPE c,
            rbweh(009)      TYPE n,
            rbawh(011)      TYPE n,
            rbsli(004)      TYPE c,
            rbk1i(001)      TYPE c,
            rbk9i(001)      TYPE c,
            rbbei(009)      TYPE n,
            rbbei_sign(001) TYPE c,
            rbwei(009)      TYPE n,
            rbawi(011)      TYPE n,
            rbslj(004)      TYPE c,
            rbk1j(001)      TYPE c,
            rbk9j(001)      TYPE c,
            rbbej(009)      TYPE n,
            rbbej_sign(001) TYPE c,
            rbwej(009)      TYPE n,
            rbawj(011)      TYPE n,
            rbslk(004)      TYPE c,
            rbk1k(001)      TYPE c,
            rbk9k(001)      TYPE c,
            rbbek(009)      TYPE n,
            rbbek_sign(001) TYPE c,
            rbwek(009)      TYPE n,
            rbawk(011)      TYPE n,
            rbsll(004)      TYPE c,
            rbk1l(001)      TYPE c,
            rbk9l(001)      TYPE c,
            rbbel(009)      TYPE n,
            rbbel_sign(001) TYPE c,
            rbwel(009)      TYPE n,
            rbawl(011)      TYPE n,
          END   OF wk_condizioni.

    DATA: wk_bxval    TYPE n LENGTH 11,
*          ls_condsd   TYPE /eacm/condsd,
          wk_rbk1x    TYPE c,
          ww_rbbex    TYPE n LENGTH 9,
          ctr_cond_a0 TYPE p LENGTH 5,
          ctr_cond_am TYPE p LENGTH 5.
    DATA lv_kschl TYPE /eacm/condsd-kschl1.

    CLEAR: e_condm, e_condn, e_comm.
    CLEAR: wk_bxval, wk_rbk1x.

    DATA(ls_record) = i_record.

    wk_condizioni = ls_record+501.

* Calcolo BX
    DO 16 TIMES.
      IF  wk_condizioni-rbslx IS INITIAL.
        EXIT.
      ENDIF.
      e_condm = wk_condizioni(036).

      lettura_condsd(
        EXPORTING
          i_vkorg   = ls_record-vkorg
          i_rbslx   = e_condm-rbslx
        IMPORTING
          e_kschl   = lv_kschl
        CHANGING
          c_status  = c_status
          c_message = c_message
      ).
*      IF c_status IS NOT INITIAL.
*        RETURN.
*      ENDIF.
      IF lv_kschl EQ pa_rbsl4.
        wk_bxval = e_condm-rbwex.
      ENDIF.
      SHIFT wk_condizioni BY 36 PLACES.
    ENDDO.

    IF  ls_record-netw2_segno EQ '-'  OR ls_record-vrwrt_segno EQ '-'.
      e_comm-netw2_segno = e_comm-iprov_segno = '-'.
    ENDIF.

    ls_record-netw2 += wk_bxval.

* Calcolo Addizionale Piombo
    CLEAR wk_bxval.

    wk_condizioni = ls_record+501.

    DO 16 TIMES.
      IF  wk_condizioni-rbslx IS INITIAL.
        EXIT.
      ENDIF.
      e_condm = wk_condizioni(036).
      lettura_condsd(
        EXPORTING
          i_vkorg   = ls_record-vkorg
          i_rbslx   = e_condm-rbslx
        IMPORTING
          e_kschl   = lv_kschl
        CHANGING
          c_status  = c_status
          c_message = c_message
      ).
*      IF c_status IS NOT INITIAL.
*        RETURN.
*      ENDIF.
      IF  lv_kschl = pa_rbsl5.
        wk_bxval = e_condm-rbwex.
        wk_rbk1x = e_condm-rbk1x.
      ENDIF.
      SHIFT wk_condizioni BY 36 PLACES.
    ENDDO.

    IF  ls_record-netw2_segno EQ '-' OR ls_record-vrwrt_segno EQ '-'.
      e_comm-netw2_segno = e_comm-iprov_segno = '-'.
    ENDIF.

    IF  ls_record-netw2 EQ 0.
      IF  wk_rbk1x EQ 'C'.
        ls_record-netw2 += wk_bxval.
      ENDIF.
    ELSE.
      ls_record-netw2 += wk_bxval.
    ENDIF.

* GESTIONE SCONTO 100%
    wk_condizioni = wk_condizioni.

    DO 16 TIMES.
      IF  wk_condizioni-rbslx IS INITIAL.
        EXIT.
      ENDIF.
      e_condm = wk_condizioni(036).
      lettura_condsd(
        EXPORTING
          i_vkorg   = ls_record-vkorg
          i_rbslx   = e_condm-rbslx
        IMPORTING
          e_kschl   = lv_kschl
        CHANGING
          c_status  = c_status
          c_message = c_message
      ).
*      IF c_status IS NOT INITIAL.
*        RETURN.
*      ENDIF.
      IF  lv_kschl EQ pa_rbsl6.
        ls_record-netw2 = 0.
        ls_record-netw2_segno =  '+'.
      ENDIF.
      SHIFT wk_condizioni BY 36 PLACES.
    ENDDO.

* Calcolo provvigioni
    CLEAR e_condm.
    CLEAR e_condn.
    CLEAR wk_condizioni.
    c_status = c_i_notrelevant. "Pulisco se trovo la provvigione

    wk_condizioni = ls_record+501.

    DO 16 TIMES.

      IF  wk_condizioni-rbslx IS INITIAL.
        EXIT.
      ENDIF.

      lettura_condsd(
        EXPORTING
          i_vkorg   = ls_record-vkorg
          i_rbslx   = wk_condizioni-rbslx
        IMPORTING
          e_kschl   = lv_kschl
        CHANGING
          c_status  = c_status
          c_message = c_message
      ).
*      IF c_status IS NOT INITIAL.
*        RETURN.
*      ENDIF.

      IF  lv_kschl EQ pa_rbsl1
       OR lv_kschl EQ pa_rbsl2
       OR lv_kschl EQ pa_rbsl3.
        CLEAR c_status.
        ww_rbbex = wk_condizioni-rbbex.
        CLEAR wk_condizioni-rbwex.
        ww_rbbex = ( ls_record-netw2 * ww_rbbex ) / 100000.
        wk_condizioni-rbwex = ww_rbbex.

        IF  lv_kschl EQ pa_rbsl1
         OR lv_kschl EQ pa_rbsl2.
          ctr_cond_a0 += 1.
          IF  wk_condizioni-rbk9x EQ pa_rbk9x.
            CLEAR e_condm.
            e_condm = wk_condizioni(036).
          ELSE.
            CLEAR e_condn.
            e_condn = wk_condizioni(036).
          ENDIF.
        ENDIF.

        IF  lv_kschl EQ pa_rbsl3.
          ctr_cond_am += 1.
          CLEAR e_condm.
          CLEAR e_condn.
          e_condm = wk_condizioni(036).
        ENDIF.
      ENDIF.

      SHIFT wk_condizioni BY 36 PLACES.
    ENDDO.
  ENDMETHOD.


  METHOD lettura_condsd.
    CLEAR e_kschl.
    SELECT SINGLE FROM /eacm/condsd
    FIELDS kschl1
    WHERE vkorg = @i_vkorg
    AND kschl = @i_rbslx
    INTO @e_kschl.
    IF  sy-subrc <> 0.
      SELECT SINGLE FROM /eacm/condsd
      FIELDS kschl1
      WHERE vkorg = '++++'
      AND kschl = @i_rbslx
      INTO @e_kschl.
      IF  sy-subrc <> 0.
        c_status = c_i_error.
        "No entrys in /EACM/CONDSD for: &1, &2
        MESSAGE e003(/eacm/a24) WITH i_vkorg i_rbslx INTO c_message.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD scrittura_record.

    DATA lv_name TYPE name1_gp.
    DATA wkcodcli TYPE kunnr.

    e_comm-bukrs = i_record-bukrs.
    e_comm-vkorg = i_record-vkorg.
    e_comm-zcdaz = i_record-vrtnr.
    e_comm-kndnr = i_record-kndnr.
    e_comm-fkdat = i_record-dtfat.
    e_comm-fkart = i_record-fkart.
    e_comm-belnr = i_record-nfat.
    e_comm-matnr = i_record-artnr.
    e_comm-arktx = i_record-arktx.
    e_comm-menge = i_record-fkimg.
    e_comm-vtweg = i_record-vtweg.
    e_comm-spart = i_record-spart.

    IF wkcodcli <> i_record-kndnr.
      CLEAR lv_name.
      SELECT SINGLE FROM /eacm/bp_cache
      FIELDS last_name && ' ' &&  first_name AS name
      WHERE business_partner = @i_record-kndnr
      INTO @lv_name.
      IF sy-subrc <> 0.
        TRY.
            DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
            DATA(ls_address) = lo_api->read_with_addresses( i_record-kndnr ).
            IF ls_address IS NOT INITIAL.
              DATA ls_bp_cache TYPE /eacm/bp_cache.
              ls_bp_cache-business_partner = i_record-kndnr.
              ls_bp_cache-first_name = ls_address-bp-first_name.
              ls_bp_cache-last_name = ls_address-bp-last_name.
              ls_bp_cache-land1 = ls_address-addresses[ 1 ]-country.
              ls_bp_cache-city = ls_address-addresses[ 1 ]-city_name.
              ls_bp_cache-post_code = ls_address-addresses[ 1 ]-postal_code.
              ls_bp_cache-street = ls_address-addresses[ 1 ]-street_name.
              ls_bp_cache-house_num = ls_address-addresses[ 1 ]-house_number.
              ls_bp_cache-region = ls_address-addresses[ 1 ]-region.
*              ls_bp_cache-stceg = ls_address-bp-.
*              ls_bp_cache-stcd1 = .
              ls_bp_cache-last_change_date = ls_address-bp-last_change_date.
              INSERT /eacm/bp_cache FROM  @ls_bp_cache.
              lv_name = ls_bp_cache-last_name && ' ' &&  ls_bp_cache-first_name.
            ENDIF.
          CATCH /eacm/cx_api_error INTO DATA(lx).
            DATA(msg) = lx->get_text( ).
        ENDTRY.
      ENDIF.
    ENDIF.
    e_comm-name1 = lv_name.

    IF i_condm-rbbex NE 0.
      e_comm-pprov = i_condm-rbbex.
      e_comm-iprov = i_condm-rbwex.
    ELSE.
      e_comm-pprov = i_condn-rbbex.
      e_comm-iprov = i_condn-rbwex.
    ENDIF.

    e_comm-netw2 = i_record-netw2.
    e_comm-bsark = i_record-bsark.
    e_comm-waers = i_record-waerl.

    IF  e_comm-blart EQ 'RG'.
      e_comm-netw2_segno = e_comm-iprov_segno = '-'.
    ENDIF.

    e_comm-posnr = i_record-posnr.
    wkcodcli  = i_record-kndnr.


  ENDMETHOD.


  METHOD fill_zprdo.

    IF i_comm-iprov = 0.
      UPDATE /eacm/a24logi
      SET status = @c_i_notrelevant
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    DATA ls_zprdo TYPE /eacm/prdo.
    CLEAR ls_zprdo.


    ls_zprdo-zclpr = 'SB'.
    ls_zprdo-fkdat = i_comm-fkdat.
    ls_zprdo-zvgdt = ls_zprdo-fkdat.
    ls_zprdo-gjahr = ls_zprdo-fkdat(4).
    ls_zprdo-posnr = i_comm-posnr.
    ls_zprdo-belnr = i_comm-belnr.
    ls_zprdo-vbeln = i_comm-belnr.
    ls_zprdo-matnr = i_comm-matnr.
    ls_zprdo-maktx = i_comm-arktx.
    ls_zprdo-menge = i_comm-menge.
    ls_zprdo-fkart = i_comm-fkart.
    ls_zprdo-bukrs = i_comm-bukrs.

    ls_zprdo-zcdaz = |{ i_comm-zcdaz ALPHA = IN }|.

    "Agente
    SELECT SINGLE FROM /eacm/zpraa                      "#EC CI_NOORDER
    FIELDS zcdaz
    WHERE kunnr EQ @i_comm-zcdaz
      AND vkorg EQ @i_comm-vkorg
      INTO @ls_zprdo-zcdaz.
*    IF  sy-subrc <> 0.
*      ls_zprdo-zcdaz = i_comm-zcdaz.
*    ENDIF.

*   ZTPAG (e controllo esistenza Codice Agente)
    SELECT SINGLE FROM /eacm/zpraa
    FIELDS ztpag, erdat
    WHERE zcdaz = @ls_zprdo-zcdaz
    INTO @DATA(ls_zpraa).
    IF sy-subrc <> 0.
      MESSAGE e008(/eacm/a24) WITH ls_zprdo-zcdaz INTO DATA(lv_msg).
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
      message = @lv_msg
      WHERE requestid = @i_item-requestid
        AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

    "Controllo esistenza Contratto Agente
    SELECT FROM /eacm/prcn
    FIELDS ztprv
    WHERE zcdaz = @ls_zprdo-zcdaz
    AND zdtin  <= @ls_zprdo-fkdat
    AND bukrs   = @ls_zprdo-bukrs
    AND zstre  = @space
    ORDER BY zdtin
    INTO @ls_zprdo-ztprv.
    ENDSELECT.
    IF Sy-subrc <> 0.
      MESSAGE e009(/eacm/a24) WITH ls_zprdo-zcdaz ls_zprdo-fkdat INTO lv_msg.
      UPDATE /eacm/a24logi
      SET status = @c_i_error,
      message = @lv_msg
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.
      RETURN.
    ENDIF.

**********************************************************************
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*****    SELECT SINGLE FROM bkpf
*****    FIELDS blart, bldat
*****      WHERE bukrs = @ls_zprdo-bukrs
*****        AND belnr = @ls_zprdo-belnr
*****        AND gjahr = @ls_zprdo-gjahr
*****        INTO (@ls_zprdo-blart, @ls_zprdo-bldat).
*****    IF sy-subrc NE 0.
*****      APPEND i_comm TO tb_err.
*****      PERFORM a0100_error USING i_comm ca_err_bkpf space.
*****      CONTINUE.
*****    ENDIF.
*****
*****    IF ls_zprdo-blart NE i_comm-blart.
*****      APPEND i_comm TO tb_err.
*****      PERFORM a0100_error USING i_comm ca_err_zi9ce space.
*****      CONTINUE.
*****    ENDIF.
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    SELECT COUNT( * )
     FROM /eacm/bp_cache
     WHERE business_partner = @i_comm-kndnr.
    IF sy-subrc = 0.
      "Codice della Filiale in caso di gruppo d'acquisto
      ls_zprdo-kunrg = i_comm-kndnr.
    ELSE.
      TRY.
          DATA(lo_api) = NEW /eacm/cl_api_business_partner( ).
          DATA(ls_address) = lo_api->read_with_addresses( i_comm-kndnr ).
          IF ls_address IS NOT INITIAL.
            DATA ls_bp_cache TYPE /eacm/bp_cache.
            ls_bp_cache-business_partner = ls_address-bp-business_partner.
            ls_bp_cache-first_name = ls_address-bp-first_name.
            ls_bp_cache-last_name = ls_address-bp-last_name.
            ls_bp_cache-land1 = ls_address-addresses[ 1 ]-country.
            ls_bp_cache-city = ls_address-addresses[ 1 ]-city_name.
            ls_bp_cache-post_code = ls_address-addresses[ 1 ]-postal_code.
            ls_bp_cache-street = ls_address-addresses[ 1 ]-street_name.
            ls_bp_cache-house_num = ls_address-addresses[ 1 ]-house_number.
            ls_bp_cache-region = ls_address-addresses[ 1 ]-region.
*              ls_bp_cache-stceg = ls_address-bp-.
*              ls_bp_cache-stcd1 = .
            ls_bp_cache-last_change_date = ls_address-bp-last_change_date.
            INSERT /eacm/bp_cache FROM  @ls_bp_cache.
            ls_zprdo-kunrg = i_comm-kndnr.
          ELSE.
            "Customer &1 not found"
            MESSAGE e011(/eacm/a24) WITH i_comm-kndnr INTO lv_msg.
            UPDATE /eacm/a24logi
            SET status = @c_i_error,
            message = @lv_msg
            WHERE requestid = @i_item-requestid
            AND zlineno = @i_item-zlineno.
            COMMIT WORK AND WAIT.
            RETURN.
          ENDIF.
        CATCH /eacm/cx_api_error INTO DATA(lx).
          DATA(msg) = lx->get_text( ).
      ENDTRY.
    ENDIF.

    "Valuta
    SELECT SINGLE FROM /eacm/t001
    FIELDS waers, waers
    WHERE bukrs = @ls_zprdo-bukrs
    INTO (@ls_zprdo-zwaer, @ls_zprdo-waerk ).
    ls_zprdo-zwaer = i_comm-waers.

*    vn_foreign_factor = ca_foreign_factor.   "100 -> Due decimali
    DATA(vn_foreign_factor) = 100.

    ls_zprdo-zimcd = i_comm-iprov / vn_foreign_factor.
    ls_zprdo-zimpd = i_comm-netw2 / vn_foreign_factor.

    TRY.
        cl_exchange_rates=>convert_to_local_currency(
          EXPORTING
            date              = ls_zprdo-fkdat
            foreign_amount    = ls_zprdo-zimcd
            foreign_currency  = ls_zprdo-zwaer
            local_currency    = ls_zprdo-waerk
          IMPORTING
            exchange_rate = ls_zprdo-kurrf
            local_amount      = ls_zprdo-zimco
        ).

        cl_exchange_rates=>convert_to_local_currency(
          EXPORTING
            date              = ls_zprdo-fkdat
            foreign_amount    = ls_zprdo-zimpd
            foreign_currency  = ls_zprdo-zwaer
            local_currency    = ls_zprdo-waerk
          IMPORTING
            exchange_rate = ls_zprdo-kurrf
            local_amount      = ls_zprdo-zimpp
        ).

      CATCH cx_exchange_rates INTO DATA(lo_ex).
        ls_zprdo-zimco = ls_zprdo-zimcd.
        ls_zprdo-zimpp = ls_zprdo-zimpd.
    ENDTRY.

**XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*    CLEAR ls_zprdo-zlord.
*    CLEAR ls_zprdo-zimlr.
*
*    TRY.
*        DATA(lo_api) = NEW /eacm/cl_api_acct_doc_read( ).
*        DATA(lt_fi_items) = lo_api->read_document(
*            iv_company_code = ls_zprdo-bukrs
*            iv_fiscal_year = CONV string( ls_zprdo-gjahr )
*            iv_accounting_document = ls_zprdo-belnr ).
*      CATCH /eacm/cx_api_error INTO DATA(lo_cx).
*        "FI document not found: &1-&2-&3
*        MESSAGE e012(/eacm/a24) WITH ls_zprdo-bukrs ls_zprdo-gjahr ls_zprdo-belnr INTO lv_msg.
*        UPDATE /eacm/a24logi
*        SET status = @c_i_wait,
*        message = @lv_msg
*        WHERE requestid = @i_item-requestid.
*        COMMIT WORK AND WAIT.
*        RETURN.
*    ENDTRY.
*
**    LOOP AT lt_fi_items INTO DATA(ls_fi_item)
**    WHERE .
**
***    ho bisogno che alla classe /eacm/cl_api_acct_doc_read la struttura della tabella restituita dal metodo read_document venga arricchita dai campi:
***    FinancialAccountType e Customer
***In più ho bisogno di recuperare BSEG-ZTERM e BSEG-ZFBDT che sono disponibili sulla vista I_OperationalAcctgDocItem come:
***zfbdt               as  DueCalculationBaseDate,
***zterm               as  PaymentTerms,
**
**è necessario attivare anche API_ACC_DOCUMENT_SRV
**Header documento        -> API_ACC_DOCUMENT_SRV / A_AccountingDocument
**Righe contabili base    -> API_ACC_DOCUMENT_SRV / A_OperationalAcctgDocItem
**Campi ZFBDT, ZTERM      -> meglio via I_OperationalAcctgDocItem o custom CDS/API
**Cube analitico ACDOCA   -> API_OPLACCTGDOCITEMCUBE_SRV
**
***koart                                                                                            as FinancialAccountType,
***kunnr                                                                                            as Customer,
***DMBTR importo con segno = hsl                                                                                              as AmountInCompanyCodeCurrency,
***WRBTR importo con segno = wsl                                                                                              as AmountInTransactionCurrency,
**        company_code              TYPE c LENGTH 4,
**        fiscal_year               TYPE c LENGTH 4,
**        accounting_document       TYPE c LENGTH 10,
**        accounting_document_item  TYPE c LENGTH 6,
**        gl_account                TYPE c LENGTH 10,
**        debit_credit_code         TYPE c LENGTH 1,
**        amount_in_company_curr    TYPE ty_amount,   *DMBTR
**        company_currency          TYPE c LENGTH 5,
**        amount_in_trans_currency  TYPE ty_amount,   *WRBTR
**        transaction_currency      TYPE c LENGTH 5,
**        document_type             TYPE c LENGTH 2,
**        posting_date              TYPE d,
**        document_date             TYPE d,
**        clearing_date             TYPE d,
**        clearing_document         TYPE c LENGTH 10,
**        cost_center               TYPE c LENGTH 10,
**        profit_center             TYPE c LENGTH 10,
**        assignment_reference      TYPE c LENGTH 18,
**        document_item_text        TYPE c LENGTH 50,
**        document_reference_id     TYPE c LENGTH 16,
**        accounting_doc_created_by TYPE c LENGTH 12,
**        creation_date             TYPE d,
**
**    ENDLOOP.
*
**define view I_GLAccountLineItemRawData
**  as select from P_ACDOCA
*    CLEAR vd_zfbdt.
*    CLEAR va_shkzg.
*    CLEAR: vn_kunnr, fl_knrza.
*    SELECT dmbtr wrbtr zfbdt shkzg zterm kunnr
*       FROM bseg
*       INTO (vn_dmbtr, vn_wrbtr, vd_zfbdt_tmp, va_shkzg, va_zterm,
*             vn_kunnr)
*                       WHERE bukrs = ls_zprdo-bukrs
*                         AND belnr = ls_zprdo-belnr
*                         AND gjahr = ls_zprdo-gjahr
**                         AND koart = ca_cl_cliente.
*                         AND koart = 'D'.
*      ADD vn_dmbtr TO ls_zprdo-zlord.
*      ADD vn_wrbtr TO ls_zprdo-zimlr.
*      IF vd_zfbdt_tmp > vd_zfbdt.
*        vd_zfbdt = vd_zfbdt_tmp.
*      ENDIF.
*      IF NOT ( vn_kunnr IS INITIAL ).
**   KNRZA (Cliente Pagatore)
*        "cliente Centrale in caso di gruppi d'acquisto
*        ls_zprdo-knrza = vn_kunnr.
*        fl_knrza = 'X'.
*      ENDIF.
*    ENDSELECT.
*    IF sy-subrc <> 0.
*      APPEND i_comm TO tb_err.
*      PERFORM a0100_error USING i_comm ca_err_bkpf space.
*      CONTINUE.
*    ELSEIF fl_knrza IS INITIAL.
*      APPEND i_comm TO tb_err.
*      PERFORM a0100_error USING i_comm ca_err_knrza space.
*      CONTINUE.
*    ENDIF.
*    vbtyp
*     case va_shkzg.
*  WHEN 'S'.
*    ls_zprdo-vbtyp = ca_negativo.
*  WHEN 'H'.
*    ls_zprdo-vbtyp = ca_positivo.
*ENDCASE.
*ls_zprdo-zutmx = vd_zfbdt.
*ls_zprdo-zterm = va_zterm.
**XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


    ls_zprdo-zpcpr = i_comm-pprov / 1000.
    ls_zprdo-zestra = i_zestra.
    ls_zprdo-zdtag = cl_abap_context_info=>get_system_date( ).
    ls_zprdo-zaucr = cl_abap_context_info=>get_user_technical_name( ).
    ls_zprdo-zdtcr = cl_abap_context_info=>get_system_date( ).
    ls_zprdo-zorcr = cl_abap_context_info=>get_system_time( ).
    ls_zprdo-tcode = 'A24'.
    CLEAR: ls_zprdo-zcamd, ls_zprdo-zdtmd, ls_zprdo-zormd.
    ls_zprdo-vtweg = '01'.

    "Numero progressivo agente
    SELECT FROM /eacm/prdo
    FIELDS MAX( zidag )
    WHERE   vkorg = @ls_zprdo-vkorg
        AND vtweg = @ls_zprdo-vtweg
        AND zclpr = @ls_zprdo-zclpr
        AND vbeln = @ls_zprdo-vbeln
        AND posnr = @ls_zprdo-posnr
        AND zcdaz = @ls_zprdo-zcdaz
    INTO @ls_zprdo-zidag.
    ls_zprdo-zidag += 1.

    INSERT /eacm/prdo FROM @ls_zprdo.
    IF sy-subrc = 0.
      UPDATE /eacm/a24logi
      SET   status = @c_i_uploaded,
            vkorg = @ls_zprdo-vkorg,
            vtweg = @ls_zprdo-vtweg,
            zclpr = @ls_zprdo-zclpr,
            vbeln = @ls_zprdo-vbeln,
            posnr = @ls_zprdo-posnr,
            zcdaz = @ls_zprdo-zcdaz,
            zidag = @ls_zprdo-zidag
      WHERE requestid = @i_item-requestid
      AND zlineno = @i_item-zlineno.
      COMMIT WORK AND WAIT.

*    "Se il record è arrivato fin qui non ha errori e può andare a valorizzare
*    "la tabella dei progressivi mensili
      monthly_commissions( ls_zprdo ).
    ENDIF.

  ENDMETHOD.

  METHOD get_no_estra.
    DATA lv_object   TYPE cl_numberrange_objects=>nr_attributes-object.
    lv_object = '/EACM/AGEB'.
    TRY.
        CALL METHOD cl_numberrange_runtime=>number_get
          EXPORTING
            nr_range_nr = '01'
            object      = lv_object
          IMPORTING
            number      = DATA(lv_number)
            returncode  = DATA(lv_rcode).
        IF lv_rcode IS INITIAL.
          r_result = lv_number.
        ENDIF.
      CATCH cx_root INTO DATA(lo_cx).
        DATA(meg) = lo_cx->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD monthly_commissions.

    DATA ls_prmon TYPE /eacm/pragepg.
*        ln_it913 TYPE /eacm/it_913,
*        l_zpr48  TYPE /eacm/zpr48.

    CLEAR ls_prmon.
    ls_prmon-bukrs = i_prdo-bukrs.
    ls_prmon-vkorg = i_prdo-vkorg.
    ls_prmon-zcodag = i_prdo-zcdaz.
    ls_prmon-anno = i_prdo-fkdat(4).
    ls_prmon-mese = i_prdo-fkdat+4(2).
    ls_prmon-waers = i_prdo-waerk.
    ls_prmon-zprovv = i_prdo-zimco.

    SELECT SINGLE FROM /eacm/it_913
    FIELDS zf07
    WHERE bukrs  = @i_prdo-bukrs
    AND blart  = @i_prdo-blart
    INTO @DATA(lv_zf07).
    CASE lv_zf07.
      WHEN '4'. "note credito
        ls_prmon-zimpncre = i_prdo-zimpp.
      WHEN '2'. "fatture
        ls_prmon-zimpfatt = i_prdo-zimpp.
      WHEN '3'. "Note debito
        ls_prmon-zimpndeb = i_prdo-zimpp.
    ENDCASE.

    SELECT SINGLE COUNT(*)
    FROM /eacm/zpr48
    WHERE vbtyp = @i_prdo-vbtyp
    AND zsegn = '-1'.
    IF sy-subrc NE 0.
      ls_prmon-zprovv *= -1.
      ls_prmon-zprovv *= -1.
      ls_prmon-zimpncre  *= -1.
      ls_prmon-zimpfatt  *= -1.
      ls_prmon-zimpndeb  *= -1.
    ENDIF.


    SELECT SINGLE FROM /eacm/pragepg
    FIELDS *
    WHERE bukrs   = @ls_prmon-bukrs
      AND vkorg   = @ls_prmon-vkorg
      AND zcodag = @ls_prmon-zcodag
      AND anno    = @ls_prmon-anno
      AND mese    = @ls_prmon-mese
      AND waers   = @ls_prmon-waers
      INTO @DATA(ls_pragepg).
    IF sy-subrc = 0.
      ls_pragepg-zimpfatt += ls_prmon-zimpfatt.
      ls_pragepg-zimpncre += ls_prmon-zimpncre.
      ls_pragepg-zimpndeb += ls_prmon-zimpndeb.
      ls_pragepg-zprovv += ls_prmon-zprovv.
    ENDIF.

*    "salvo il progressivo sul DB. Il record viene aggiunto o modificato
    MODIFY /eacm/pragepg FROM @ls_pragepg.
    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD provvigione_specialist_ew.
    DATA l_rbsl LIKE i_record-rbsl1.
    DATA l_rbbe LIKE i_record-rbbe1.
    DATA l_rbk1 LIKE i_record-rbk11.
    DATA l_rbk9 LIKE i_record-rbk91.
    DATA l_rbbs LIKE i_record-rbbe1_sign.
    DATA l_rbwe LIKE i_record-rbwe1.
    DATA l_rbaw LIKE i_record-rbaw1.

*  RICERCA DELLA PROVVIGIONE DELLO SPECIALIST
*  SE TROVATA VIENE MESSA NELLA PRIMA CONDIZIONE
    DO 16 TIMES VARYING l_rbsl
                        FROM i_record-rbsl1
                        NEXT i_record-rbsl2
                VARYING l_rbbe
                        FROM i_record-rbbe1
                        NEXT i_record-rbbe2
                VARYING l_rbk1
                        FROM i_record-rbk11
                        NEXT i_record-rbk12
                VARYING l_rbk9
                        FROM i_record-rbk91
                        NEXT i_record-rbk92
                VARYING l_rbbs
                        FROM i_record-rbbe1_sign
                        NEXT i_record-rbbe2_sign
                VARYING l_rbwe
                        FROM i_record-rbwe1
                        NEXT i_record-rbwe2
                VARYING l_rbaw
                        FROM i_record-rbaw1
                        NEXT i_record-rbaw2.

      IF  l_rbsl EQ pa_cond2.
        i_record-rbsl1      = l_rbsl.
        i_record-rbbe1      = l_rbbe.
        i_record-rbk11      = l_rbk1.
        i_record-rbk91      = l_rbk9.
        i_record-rbbe1_sign = l_rbbs.
        i_record-rbwe1      = l_rbwe.
        i_record-rbaw1      = l_rbaw.
        EXIT.
      ENDIF.

    ENDDO.

*  PULIZIA DI TUTTE LE ALTRE CONDIZIONI
    DO 15 TIMES VARYING l_rbsl
                        FROM i_record-rbsl2
                        NEXT i_record-rbsl3
                VARYING l_rbbe
                        FROM i_record-rbbe2
                        NEXT i_record-rbbe3
                VARYING l_rbk1
                        FROM i_record-rbk12
                        NEXT i_record-rbk13
                VARYING l_rbk9
                        FROM i_record-rbk92
                        NEXT i_record-rbk93
                VARYING l_rbbs
                        FROM i_record-rbbe2_sign
                        NEXT i_record-rbbe3_sign
                VARYING l_rbwe
                        FROM i_record-rbwe2
                        NEXT i_record-rbwe3
                VARYING l_rbaw
                        FROM i_record-rbaw2
                        NEXT i_record-rbaw3.

      CLEAR l_rbsl.
      CLEAR l_rbbe.
      CLEAR l_rbk1.
      CLEAR l_rbk9.
      CLEAR l_rbbs.
      CLEAR l_rbwe.
      CLEAR l_rbaw.

    ENDDO.

*  VERIFICA SE TROVATA LA CONDIZIONE DELLO SPECIALIST
*  SE TROVATA VIENE FORZATA CON IL CODICE PROVVIGIONE NORMALE
*  ALTRIMENTI VIENE PULITA
    IF  i_record-rbsl1 EQ pa_cond2.
      i_record-rbsl1 = pa_cond1.
    ELSE.
      CLEAR i_record-rbsl1.
      CLEAR i_record-rbbe1.
      CLEAR i_record-rbk11.
      CLEAR i_record-rbk91.
      CLEAR i_record-rbbe1_sign.
      CLEAR i_record-rbwe1.
      CLEAR i_record-rbaw1.
    ENDIF.
  ENDMETHOD.


  METHOD crete_new_item.

    r_result = i_item.

    SELECT SINGLE FROM /eacm/a24logi
    FIELDS MAX( zlineno )
    WHERE requestid = @i_item-requestid
    INTO @r_result-zlineno.

    r_result-zlineno += 1.

    INSERT /eacm/a24logi FROM @r_result.
    IF sy-subrc <> 0.
      CLEAR r_result.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD aggiornamento_importi.

    IF i_headers[] IS INITIAL.
      RETURN.
    ENDIF.

    "calcolo dell'importo totale netto della fattura (ZIMFAT e ZIMPF)
    DATA lt_dosum TYPE STANDARD TABLE OF tp_dosum.
    CLEAR lt_dosum[].
    LOOP AT i_headers INTO DATA(ls_header) .
      SELECT DISTINCT
             vkorg,
             vtweg,
             zclpr,
             vbeln
        FROM /eacm/a24logi
        WHERE requestid = @ls_header-requestid
        AND status = @/eacm/cl_a24=>c_i_uploaded
        APPENDING TABLE @lt_dosum.
    ENDLOOP.

    SORT lt_dosum.
    DELETE ADJACENT DUPLICATES FROM lt_dosum.
    LOOP AT lt_dosum INTO DATA(ls_dosum).

      SELECT FROM /eacm/prdo
      FIELDS SUM( zimpp ) AS zimpp, SUM( zimpd ) AS zimpd
      WHERE vkorg = @ls_dosum-vkorg
          AND vtweg = @ls_dosum-vtweg
          AND zclpr = @ls_dosum-zclpr
          AND vbeln = @ls_dosum-vbeln
          INTO @DATA(ls_sum).

      UPDATE /eacm/prdo
      SET zimfat = @ls_sum-zimpp,
          zimpf = @ls_sum-zimpd
      WHERE vkorg = @ls_dosum-vkorg
        AND vtweg = @ls_dosum-vtweg
        AND zclpr = @ls_dosum-zclpr
        AND vbeln = @ls_dosum-vbeln.
    ENDLOOP.


  ENDMETHOD.

  METHOD run.
    DATA lv_zestra TYPE /eacm/prdo-zestra.
    CLEAR lv_zestra.

    DATA(lt_items) = get_items( ).

    LOOP AT lt_items INTO DATA(ls_items).
      DATA(lv_parsed_records) = parse( ls_items-record ).

      IF duplicate(
           i_item   = ls_items
           i_record = lv_parsed_records
         ) = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_commission) = make_commission(
                              i_item   = ls_items
                              i_record = lv_parsed_records
                            ).
      IF ls_commission IS NOT INITIAL.
        IF lv_zestra IS INITIAL.
          lv_zestra = get_no_estra( ).
          IF lv_zestra IS INITIAL.
            RAISE EXCEPTION TYPE cx_apj_rt_content
              MESSAGE e004(/eacm/a24) .
          ENDIF.
        ENDIF.
        fill_zprdo( i_item   = ls_items
                    i_comm = ls_commission
                    i_zestra = lv_zestra ).
      ENDIF.

      "provvigione speciale
      IF lv_parsed_records-vrtnr_2 CN '0 '.
        lv_parsed_records-vrtnr = lv_parsed_records-vrtnr_2.
        provvigione_specialist_ew( CHANGING i_record = lv_parsed_records ).
        "Pulisco linea perché se c'è nuova DO devo aggiungere nuovo logi
        DATA(new_item) = crete_new_item( ls_items ).
        IF new_item IS NOT INITIAL.
          ls_commission = make_commission(
                            i_item   = new_item
                            i_record = lv_parsed_records
                          ).
          IF ls_commission IS NOT INITIAL.
            IF lv_zestra IS INITIAL.
              lv_zestra = get_no_estra( ).
              IF lv_zestra IS INITIAL.
                RAISE EXCEPTION TYPE cx_apj_rt_content
                  MESSAGE e004(/eacm/a24) .
              ENDIF.
            ENDIF.
            fill_zprdo( i_item   = new_item
                        i_comm = ls_commission
                        i_zestra = lv_zestra ).
          ENDIF.
        ENDIF.

      ENDIF.
    ENDLOOP.

*a24=>send_mail( ).

    DATA(lt_header) = lt_items[].
    SORT lt_header BY requestid.
    DELETE ADJACENT DUPLICATES FROM lt_header COMPARING requestid.
    CLEAR lt_items[].
    LOOP AT lt_header INTO DATA(ls_header).

      "aggiorna log /eacm/a24logp
      DATA ls_a24logp TYPE /eacm/a24logp.
      GET TIME STAMP FIELD ls_a24logp-tmsp.

      SELECT SINGLE                                     "#EC CI_NOORDER
      FROM /eacm/a24logi
      FIELDS requestid,
      COUNT( * ) AS total_records,
      SUM( CASE WHEN status =  @/eacm/cl_a24=>c_i_uploaded THEN 1 ELSE 0 END ) AS success_records,
      SUM( CASE WHEN status = @/eacm/cl_a24=>c_i_error THEN 1 ELSE 0 END ) AS error_records,
      SUM( CASE WHEN status = @/eacm/cl_a24=>c_i_wait THEN 1 ELSE 0 END ) AS wait_records
      WHERE requestid = @ls_header-requestid
      GROUP BY requestid
      INTO CORRESPONDING FIELDS OF @ls_a24logp.

      "calcolo dello stato finale
      "se ci sono wait_records allora è parziale altrimenti l'elaborazione è completa
      IF ls_a24logp-wait_records = 0.
        ls_a24logp-status = /eacm/cl_a24=>c_h_complete.
      ELSE.
        ls_a24logp-status = /eacm/cl_a24=>c_h_partially.
      ENDIF.

      "aggiorna log /eacm/a24logp
      ls_a24logp-requestid = ls_header-requestid.
      INSERT /eacm/a24logp FROM @ls_a24logp.

      "aggiorna stato testata
      UPDATE /eacm/a24logh SET status = @ls_a24logp-status WHERE requestid = @ls_header-requestid.

    ENDLOOP.
    COMMIT WORK AND WAIT.

    "aggiornamento importi
    aggiornamento_importi( lt_header ).
  ENDMETHOD.

ENDCLASS.
