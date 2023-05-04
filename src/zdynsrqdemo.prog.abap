*&---------------------------------------------------------------------*
*& Report  ZDYNSRQDEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

include zdynsrqdemotop.

parameters: p_rfc type rfcdest obligatory.

parameters: p_single type xfeld radiobutton group gr1 user-command ucom,
            p_multi  type xfeld radiobutton group gr1 default 'X'.

parameters: p_adr type ad_addrnum modif id sin.
select-options: so_adr for gs_subadrc-addrnumber no intervals modif id mul.

at selection-screen output.

  loop at screen.
    if screen-group1 eq 'SIN' and p_single eq 'X'.
      refresh so_adr[].
      screen-input = '1'.
    elseif screen-group1 eq 'SIN'.
      screen-input = '0'.
    endif.
    if screen-group1 eq 'MUL' and p_multi eq 'X'.
      clear p_adr.
      screen-input = '1'.
    elseif screen-group1 eq 'MUL'.
      screen-input = '0'.
    endif.
    modify screen.
  endloop.

start-of-selection.

* check rfc specified
  if p_rfc is initial.
    message text-004 type 'E'.
  endif.

*****************
* REMOTE SELECT *
*****************
  if p_multi eq 'X'.

*   prepare queries
    loop at so_adr into gs_soadr where sign eq 'I' and option eq 'EQ'.
      if sy-tabix eq lines( so_adr[] ).
        concatenate gv_adrc_query `( ADDRNUMBER EQ '` gs_soadr-low `' AND DATE_FROM LE '` sy-datum `' AND DATE_TO GE '` sy-datum `' )` into gv_adrc_query.
        concatenate gv_adr2_query `( ADDRNUMBER EQ '` gs_soadr-low `' )` into gv_adr2_query.
      else.
        concatenate gv_adrc_query `( ADDRNUMBER EQ '` gs_soadr-low `' AND DATE_FROM LE '` sy-datum `' AND DATE_TO GE '` sy-datum `' ) OR ` into gv_adrc_query.
        concatenate gv_adr2_query `( ADDRNUMBER EQ '` gs_soadr-low `' ) OR ` into gv_adr2_query.
      endif.
    endloop.

*   input check
    if gv_adrc_query is initial.
      write: / text-003.
    endif.

*   dynamically build internal table data for result
    _srq_build-itab p_rfc: 'ADRC' go_adrc_itab, 'ADR2' go_adr2_itab.

*   perform query on backend
    _srq_select p_rfc: 'ADRC' gv_adrc_query go_adrc_itab, 'ADR2' gv_adr2_query go_adr2_itab.

*   for a friendly management of data
    assign: go_adrc_itab->* to <gt_adrc>, go_adr2_itab->* to <gt_adr2>.

*   static corresponding field-map
    write at: /1(1023) text-001 color col_heading intensified on.
    loop at <gt_adrc> assigning <gs_line>.
      _srq_move-corresponding <gs_line> gs_subadrc.
      _srq_move-mapping <gs_line> gs_subadrc: 'NAME1' 'NAME', 'HOUSE_NUM1' 'HOUSE_NO', 'CITY1' 'CITY'.
      write: / gs_subadrc-addrnumber, '|', gs_subadrc-name, '|', gs_subadrc-street, '|', gs_subadrc-city, '|', gs_subadrc-region, '|', gs_subadrc-country.
      clear: gs_subadrc.
    endloop.

*   dynamic field get
    write at: /1(1023) text-002 color col_heading intensified on.
    loop at <gt_adr2> assigning <gs_line>.
      _srq_get-field <gs_line>: 'ADDRNUMBER' gv_adrno, 'PERSNUMBER' gv_perno, 'TEL_NUMBER' gv_telno.
      write: / gv_adrno, '|', gv_perno, '|', gv_telno.
    endloop.

  endif.

************************
* REMOTE SELECT SINGLE *
************************
  if p_single eq 'X'.

*   prepare query
    concatenate `ADDRNUMBER EQ '` p_adr `' AND DATE_FROM LE '` sy-datum `' AND DATE_TO GE '` sy-datum `'` into gv_adrc_query.

*   dynamically build structure data for result
    _srq_build-structure p_rfc 'ADRC' go_adrc_struc.

*   perform query on backend
    _srq_select-single p_rfc 'ADRC' gv_adrc_query go_adrc_struc.

    if sy-subrc ne 0. write: / text-005. endif.

*   for a friendly management of data
    assign go_adrc_struc->* to <gs_line>.

*   static corresponding field-map
    write at: /1(1023) text-001 color col_heading intensified on.
    _srq_move-corresponding <gs_line> gs_subadrc.
    _srq_move-mapping <gs_line> gs_subadrc: 'NAME1' 'NAME', 'HOUSE_NUM1' 'HOUSE_NO', 'CITY1' 'CITY'.
    write: / gs_subadrc-addrnumber, '|', gs_subadrc-name, '|', gs_subadrc-street, '|', gs_subadrc-city, '|', gs_subadrc-region, '|', gs_subadrc-country.

*   dynamic field get
    write at: /1(1023) text-002 color col_heading intensified on.
    _srq_get-field <gs_line> : 'ADDRNUMBER' gs_subadrc-addrnumber, 'NAME1' gs_subadrc-name, 'STREET' gs_subadrc-street, 'CITY1' gs_subadrc-city, 'REGION' gs_subadrc-region, 'COUNTRY' gs_subadrc-country.
    write: / gs_subadrc-addrnumber, '|', gs_subadrc-name, '|', gs_subadrc-street, '|', gs_subadrc-city, '|', gs_subadrc-region, '|', gs_subadrc-country.

  endif.
