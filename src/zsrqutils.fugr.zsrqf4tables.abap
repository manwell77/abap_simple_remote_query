FUNCTION ZSRQF4TABLES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
##NEEDED
  data: lt_selopt     type standard table of ddshselopt,
        lt_fld        type standard table of dynpread,
        ls_fld        type dynpread,
        ls_selopt     type ddshselopt,
        ls_record     type seahlpres,
        lv_query      type string,
        lv_rfc        type rfcdest,
        lv_tabname    type tabname16,
        lv_ddtext     type as4text,
        lv_rfcs       type string.

  ##NEEDED
  data: lo_dd02t_itab type ref to data.

  ##NEEDED
  constants: gc_11 type i value 11.

  field-symbols: <lt_dd02t> type standard table,
                 <ls_dd02t> type any.

* on selection only
  if callcontrol-step ne 'DISP'.
    return.
  endif.

* get dynpro fields
  ls_fld-fieldname = 'GV_TABLE'.
  append ls_fld to lt_fld.
  ls_fld-fieldname = 'GV_RFC'.
  append ls_fld to lt_fld.

  call function 'DYNP_VALUES_READ'
    exporting
      dyname                   = 'ZDYNSRQ'
      dynumb                   = '9001'
      translate_to_upper       = 'X'
      perform_conversion_exits = 'X'
    tables
      dynpfields               = lt_fld
    exceptions
      invalid_abapworkarea     = 1
      invalid_dynprofield      = 2
      invalid_dynproname       = 3
      invalid_dynpronummer     = 4
      invalid_request          = 5
      no_fielddescription      = 6
      invalid_parameter        = 7
      undefind_error           = 8
      double_conversion        = 9
      stepl_not_found          = 10
      others                   = gc_11.

  if sy-subrc ne 0.
    return.
  endif.

  read table lt_fld into ls_fld with key fieldname = 'GV_RFC'.

  if sy-subrc eq 0.
    lv_rfc = ls_fld-fieldvalue.
  endif.

  read table lt_fld into ls_fld with key fieldname = 'GV_TABLE'.

  if sy-subrc eq 0.
    lv_tabname = ls_fld-fieldvalue.
    replace all occurrences of '*' in lv_tabname with '%'.
  endif.

* must be unique
  if lv_rfc is initial or lv_tabname is initial.
    return.
  endif.

  lv_rfcs = lv_rfc.

  call function 'RFC_VERIFY_DESTINATION'
    exporting
      destination                = lv_rfcs
    exceptions
      internal_failure           = 1
      timeout                    = 2
      dest_communication_failure = 3
      dest_system_failure        = 4
      update_failure             = 5
      no_update_authority        = 6
      others                     = 7.

  if sy-subrc ne 0.
    return.
  endif.

  _srq_build-itab lv_rfc 'DD02T' lo_dd02t_itab.

  if sy-subrc ne 0.
    return.
  endif.

* condition for text and active
  concatenate `TABNAME LIKE '` lv_tabname `' AND AS4LOCAL EQ 'A' AND AS4VERS EQ '0000' AND DDLANGUAGE EQ '` sy-langu `'` into lv_query.

  ##WRITE_OK
  _srq_select lv_rfc 'DD02T' lv_query lo_dd02t_itab.

  if sy-subrc ne 0.
    return.
  endif.

  assign lo_dd02t_itab->* to <lt_dd02t>.

* map result
  loop at <lt_dd02t> assigning <ls_dd02t>.

    _srq_get-field <ls_dd02t>: 'TABNAME' lv_tabname, 'DDTEXT' lv_ddtext.

    if sy-subrc eq 0.

      ls_record(16)    = lv_tabname(16).
      ls_record+16(60) = lv_ddtext(60).

      append ls_record to record_tab.

    endif.

  endloop.

* close connection
  call function 'RFC_CONNECTION_CLOSE'
    exporting
      destination          = lv_rfc
    exceptions
      destination_not_open = 0
      others               = 0.





ENDFUNCTION.
