class ZCL_DYN_REMOTE definition
  public
  final
  create public .

public section.

  class-methods BUILD_QUERY
    importing
      value(I_QUERY) type STRING
    returning
      value(R_QUERY) type ZRFC_DB_OPT_T .
  class-methods GET_FIELD_VALUE
    importing
      value(I_FIELDNAME) type FIELDNAME
      value(I_STRUCTURE) type ANY
    exporting
      value(E_FIELDVALUE) type ANY
    raising
      ZCX_DYN_REMOTE .
  class-methods GET_FIELD_VALUES
    importing
      value(I_STRUCTURE) type ANY
      value(I_FIELDNAME1) type FIELDNAME
      value(I_FIELDNAME2) type FIELDNAME optional
      value(I_FIELDNAME3) type FIELDNAME optional
      value(I_FIELDNAME4) type FIELDNAME optional
      value(I_FIELDNAME5) type FIELDNAME optional
      value(I_FIELDNAME6) type FIELDNAME optional
      value(I_FIELDNAME7) type FIELDNAME optional
      value(I_FIELDNAME8) type FIELDNAME optional
      value(I_FIELDNAME9) type FIELDNAME optional
    exporting
      value(E_FIELDVALUE1) type ANY
      value(E_FIELDVALUE2) type ANY
      value(E_FIELDVALUE3) type ANY
      value(E_FIELDVALUE4) type ANY
      value(E_FIELDVALUE5) type ANY
      value(E_FIELDVALUE6) type ANY
      value(E_FIELDVALUE7) type ANY
      value(E_FIELDVALUE8) type ANY
      value(E_FIELDVALUE9) type ANY
    raising
      ZCX_DYN_REMOTE .
  class-methods SET_FIELD_VALUE
    importing
      value(I_FIELDNAME) type FIELDNAME
      value(I_FIELDVALUE) type ANY
    changing
      !C_STRUCTURE type ANY
    raising
      ZCX_DYN_REMOTE .
  class-methods SET_FIELD_VALUES
    importing
      value(I_FIELDNAME1) type FIELDNAME
      value(I_FIELDNAME2) type FIELDNAME optional
      value(I_FIELDNAME3) type FIELDNAME optional
      value(I_FIELDNAME4) type FIELDNAME optional
      value(I_FIELDNAME5) type FIELDNAME optional
      value(I_FIELDNAME6) type FIELDNAME optional
      value(I_FIELDNAME7) type FIELDNAME optional
      value(I_FIELDNAME8) type FIELDNAME optional
      value(I_FIELDNAME9) type FIELDNAME optional
      value(I_FIELDVALUE1) type ANY
      value(I_FIELDVALUE2) type ANY optional
      value(I_FIELDVALUE3) type ANY optional
      value(I_FIELDVALUE4) type ANY optional
      value(I_FIELDVALUE5) type ANY optional
      value(I_FIELDVALUE6) type ANY optional
      value(I_FIELDVALUE7) type ANY optional
      value(I_FIELDVALUE8) type ANY optional
      value(I_FIELDVALUE9) type ANY optional
    changing
      !C_STRUCTURE type ANY
    raising
      ZCX_DYN_REMOTE .
  class-methods BUILD_RUNTIME_DATA
    importing
      value(I_TABLE) type STANDARD TABLE
    returning
      value(R_DATA) type ref to DATA .
  class-methods GET_REMOTE_TABLE_FIELDS
    importing
      value(I_RFC_DESTINATION) type RFCDEST
      value(I_TABLE) type STRUKNAME
    returning
      value(R_FIELD) type ZRFC_DB_FLD_T
    raising
      CX_PARAMETER_INVALID_RANGE
      CX_SY_STRUCT_CREATION
      CX_SY_TABLE_CREATION
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  class-methods RFC_READ_TABLE
    importing
      value(I_RFC_DESTINATION) type RFCDEST
      value(I_TABLE) type STRUKNAME
      value(I_OPTION) type ZRFC_DB_OPT_T
    changing
      value(C_FIELD) type ZRFC_DB_FLD_T
      value(C_DATA) type ZTAB512_T
    raising
      ZCX_DYN_REMOTE .
  class-methods GET_REMOTE_STRUC_DATA
    importing
      value(I_RFC_DESTINATION) type RFCDEST
      value(I_TABLE) type STRUKNAME
      value(I_QUERY) type ZRFC_DB_OPT_T
      value(I_DATA_LENGTH) type I default 100
    exporting
      value(E_STRUC) type ANY
    raising
      CX_PARAMETER_INVALID_RANGE
      ZCX_DYN_REMOTE_TYPE_BUILDER
      ZCX_DYN_REMOTE
      CX_SY_STRUCT_CREATION
      CX_SY_TABLE_CREATION .
  class-methods GET_REMOTE_TABLE_DATA
    importing
      value(I_RFC_DESTINATION) type RFCDEST
      value(I_TABLE) type STRUKNAME
      value(I_QUERY) type ZRFC_DB_OPT_T
      value(I_DATA_LENGTH) type I default 512
    exporting
      value(E_TABLE) type STANDARD TABLE
    raising
      CX_PARAMETER_INVALID_RANGE
      ZCX_DYN_REMOTE_TYPE_BUILDER
      ZCX_DYN_REMOTE
      CX_SY_TABLE_CREATION
      CX_SY_STRUCT_CREATION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DYN_REMOTE IMPLEMENTATION.


method build_query.

    constants: gc_72 type i value 72.

    data: lt_split type standard table of string,
          ls_query type rfc_db_opt,
          lv_split type string,
          lv_slen  type i,
          lv_qlen  type i,
          lv_tlen  type i.

    split i_query at space into table lt_split.

    loop at lt_split into lv_split.

      lv_slen = strlen( lv_split ).
      lv_qlen = strlen( ls_query-text ).

      lv_tlen = lv_slen + lv_qlen + 1.

      if lv_tlen gt gc_72.
        append ls_query to r_query.
        clear: ls_query.
      endif.

      concatenate ls_query-text lv_split into ls_query-text separated by space.
      condense ls_query-text.

      clear: lv_slen, lv_qlen, lv_tlen, lv_split.
    endloop.

* last one
    if not ls_query is initial.
      append ls_query to r_query.
    endif.

  endmethod.


method BUILD_RUNTIME_DATA.

  data: lo_table type ref to cl_abap_tabledescr,
        lo_struc type ref to cl_abap_structdescr.

  lo_table ?= cl_abap_tabledescr=>describe_by_data( i_table ).
  lo_struc ?= lo_table->get_table_line_type( ).

  create data: r_data type handle lo_struc.

  endmethod.


method GET_FIELD_VALUE.

  field-symbols: <fs_field> type any.

  try.

      assign component i_fieldname of structure i_structure to <fs_field>.

      if sy-subrc ne 0.

        raise exception type zcx_dyn_remote
          exporting
            textid = zcx_dyn_remote=>no_field
            field  = i_fieldname.

      endif.

      e_fieldvalue = <fs_field>.

    catch cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range.

      raise exception type zcx_dyn_remote
        exporting
          textid = zcx_dyn_remote=>assign_comp_failed
          field  = i_fieldname.

  endtry.

  endmethod.


method GET_FIELD_VALUES.

  if e_fieldvalue1 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname1 i_structure = i_structure importing e_fieldvalue = e_fieldvalue1 ).
  endif.

  if e_fieldvalue2 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname2 i_structure = i_structure importing e_fieldvalue = e_fieldvalue2 ).
  endif.

  if e_fieldvalue3 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname3 i_structure = i_structure importing e_fieldvalue = e_fieldvalue3 ).
  endif.

  if e_fieldvalue4 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname4 i_structure = i_structure importing e_fieldvalue = e_fieldvalue4 ).
  endif.

  if e_fieldvalue5 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname5 i_structure = i_structure importing e_fieldvalue = e_fieldvalue5 ).
  endif.

  if e_fieldvalue6 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname6 i_structure = i_structure importing e_fieldvalue = e_fieldvalue6 ).
  endif.

  if e_fieldvalue7 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname7 i_structure = i_structure importing e_fieldvalue = e_fieldvalue7 ).
  endif.

  if e_fieldvalue8 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname8 i_structure = i_structure importing e_fieldvalue = e_fieldvalue8 ).
  endif.

  if e_fieldvalue9 is requested.
    zcl_dyn_remote=>get_field_value( exporting i_fieldname = i_fieldname9 i_structure = i_structure importing e_fieldvalue = e_fieldvalue9 ).
  endif.

  endmethod.


method get_remote_struc_data.

  data: lx_pir type ref to cx_parameter_invalid_range.

  data: lt_field    type standard table of rfc_db_fld,
        lt_rfcfield type standard table of rfc_db_fld,
        lt_data     type standard table of tab512,
        ls_data     type tab512,
        ls_rfcfield type rfc_db_fld,
        ls_field    type rfc_db_fld,
        lv_tabix    type sytabix,
        lv_len      type i,
        lv_tot      type i.

  data: lo_strucdata type ref to data,
        lx_scr       type ref to cx_sy_struct_creation,
        lx_tcr       type ref to cx_sy_table_creation,
        lx_root      type ref to cx_root.

  field-symbols: <fs_line>   type any,
                 <fs_efield> type any,
                 <fs_field>  type any.

  try.

*     prepare output
      zcl_dyn_remote_type_builder=>build_data( exporting i_rfcdest = i_rfc_destination i_struct = i_table importing e_strucdata = lo_strucdata ).

      assign: lo_strucdata->* to <fs_line>.

*     get fields
      lt_field = zcl_dyn_remote=>get_remote_table_fields( i_rfc_destination = i_rfc_destination i_table = i_table ).

      describe table lt_field lines lv_tot.

      loop at lt_field into ls_field.

*       get line index
        lv_tabix = sy-tabix.

*       get total fields length
        lv_len = lv_len + ls_field-length.

*       check limit of data line in rfc_read_data (real 512)
        if lv_len lt i_data_length.
          clear: ls_field-length.
          append ls_field to lt_rfcfield.
        endif.

*       over limit or last line -> start getting data for this fields
        if lv_len ge i_data_length or lv_tabix eq lv_tot.

*         remote read table
          zcl_dyn_remote=>rfc_read_table( exporting i_rfc_destination = i_rfc_destination i_table = i_table i_option = i_query changing c_field = lt_rfcfield c_data = lt_data ).

*         map data
          read table lt_data index 1 into ls_data.

          if sy-subrc ne 0.
            exit.
          endif.

          loop at lt_rfcfield into ls_rfcfield.

            assign component ls_rfcfield-fieldname of structure <fs_line> to <fs_field>.

            if sy-subrc ne 0.

              raise exception type zcx_dyn_remote
                exporting
                  textid = zcx_dyn_remote=>no_field
                  table  = i_table
                  field  = ls_field-fieldname.

            endif.

            <fs_field> = ls_data+ls_rfcfield-offset(ls_rfcfield-length).

*           transfer result - dynamically typed and moved to prevent misfield association - could dump if se24 tested without a concrete local data type specified
            assign component ls_rfcfield-fieldname of structure e_struc to <fs_efield>.

            if sy-subrc eq 0.
              <fs_efield> = <fs_field>.
            endif.

            clear: ls_rfcfield.
          endloop.

          refresh: lt_rfcfield.

          if lv_tabix ne lv_tot.
            lv_len = ls_field-length.
            clear: ls_field-length.
            append ls_field to lt_rfcfield.
          endif.

        endif.

        refresh: lt_data.
        clear: ls_field.
      endloop.

    catch cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range

          into lx_root.

      raise exception type zcx_dyn_remote
        exporting
          textid   = zcx_dyn_remote=>assign_failed
          previous = lx_root.

    catch cx_parameter_invalid_range into lx_pir.

      raise exception lx_pir.

    catch cx_sy_struct_creation into lx_scr.

      raise exception lx_scr.

    catch cx_sy_table_creation into lx_tcr.

      raise exception lx_tcr.

  endtry.

endmethod.


method get_remote_table_data.

    data: lx_pir type ref to cx_parameter_invalid_range.

    data: lt_field    type standard table of rfc_db_fld,
          lt_rfcfield type standard table of rfc_db_fld,
          lt_data     type standard table of tab512,
          ls_data     type tab512,
          ls_field    type rfc_db_fld,
          ls_rfcfield type rfc_db_fld,
          lv_len      type i,
          lv_times    type i,
          lv_tabix    type sytabix,
          lv_databix  type sytabix,
          lv_fgroup   type i,
          lv_tot      type i.

    data: lo_strucdata  type ref to data,
          lo_rstrucdata type ref to data,
          lx_scr        type ref to cx_sy_struct_creation,
          lx_tcr        type ref to cx_sy_table_creation,
          lx_root       type ref to cx_root.

    field-symbols: <fs_line>  type any,
                   <fs_rline> type any,
                   <fs_field> type any.

    try.

*       build runtime structure of table passed
        lo_rstrucdata = zcl_dyn_remote=>build_runtime_data( i_table = e_table ).

        assign lo_rstrucdata->* to <fs_rline>.

*       prepare output
        zcl_dyn_remote_type_builder=>build_data( exporting i_rfcdest = i_rfc_destination i_struct = i_table importing e_strucdata = lo_strucdata ).

        assign: lo_strucdata->* to <fs_line>.

*       get fields
        lt_field = zcl_dyn_remote=>get_remote_table_fields( i_rfc_destination = i_rfc_destination i_table = i_table ).

        describe table lt_field lines lv_tot.

        loop at lt_field into ls_field.

*         get line index
          lv_tabix = sy-tabix.

*         get total fields length
          lv_len = lv_len + ls_field-length.

*         check limit of data line in rfc_read_data (real 512)
          if lv_len lt i_data_length.
            clear: ls_field-length.
            append ls_field to lt_rfcfield.
          endif.

          if lv_len ge i_data_length and lv_tabix eq lv_tot.
            lv_times = 2.
          else.
            lv_times = 1.
          endif.

*         over limit or last line -> start getting data for this fields
          if lv_len ge i_data_length or lv_tabix eq lv_tot.

            do lv_times times.

              if sy-index gt 1.
                refresh: lt_rfcfield, lt_data.
                clear: ls_field-length.
                append ls_field to lt_rfcfield.
              endif.

*             increase field group index (nb: initialized to 0!)
              add 1 to lv_fgroup.

*             remote read table
              zcl_dyn_remote=>rfc_read_table( exporting i_rfc_destination = i_rfc_destination i_table = i_table i_option = i_query changing c_field = lt_rfcfield c_data = lt_data ).

*             map data
              loop at lt_data into ls_data.

                lv_databix = sy-tabix.

                loop at lt_rfcfield into ls_rfcfield.

                  assign component ls_rfcfield-fieldname of structure <fs_line> to <fs_field>.

                  if sy-subrc ne 0.

                    raise exception type zcx_dyn_remote
                      exporting
                        textid = zcx_dyn_remote=>no_field
                        table  = i_table
                        field  = ls_rfcfield-fieldname.

                  endif.

                  <fs_field> = ls_data+ls_rfcfield-offset(ls_rfcfield-length).

                  clear: ls_rfcfield.
                endloop.

*               transfer result - dynamically typed and moved to prevent misfield association - could dump if se24 tested without a concrete local data type specified
                move-corresponding <fs_line> to <fs_rline>.

*               first field group -> append
                if lv_fgroup eq 1.
                  append <fs_rline> to e_table.
*               get line index & map new fields
                else.

                  loop at lt_rfcfield into ls_rfcfield.
*                 transfer result - dynamically typed and moved to prevent misfield association - could dump if se24 tested without a concrete local data type specified
                    modify e_table index lv_databix from <fs_rline> transporting (ls_rfcfield-fieldname).
                    clear: ls_rfcfield.
                  endloop.

                endif.

                clear: ls_data.
              endloop.

              refresh: lt_rfcfield.

              if lv_tabix ne lv_tot.
                lv_len = ls_field-length.
                clear: ls_field-length.
                append ls_field to lt_rfcfield.
              endif.

            enddo.

          endif.

          refresh: lt_data.
          clear: ls_field.
        endloop.

      catch cx_sy_assign_cast_illegal_cast
            cx_sy_assign_cast_unknown_type
            cx_sy_assign_out_of_range

            into lx_root.

        raise exception type zcx_dyn_remote
          exporting
            textid   = zcx_dyn_remote=>assign_failed
            previous = lx_root.

      catch cx_parameter_invalid_range into lx_pir.

        raise exception lx_pir.

    catch cx_sy_struct_creation into lx_scr.

      raise exception lx_scr.

    catch cx_sy_table_creation into lx_tcr.

      raise exception lx_tcr.

    endtry.

  endmethod.


method get_remote_table_fields.

  data: lx_pir type ref to cx_parameter_invalid_range,
        lx_tcr type ref to cx_sy_table_creation,
        lx_scr type ref to cx_sy_struct_creation.

  data: lt_comp  type abap_component_tab,
        ls_comp  type abap_componentdescr,
        ls_field type rfc_db_fld.

  data: lv_offset_pattern type string.

  concatenate zcl_dyn_remote_type_builder=>offset '*' into lv_offset_pattern.

  try.

*     get components
      lt_comp = zcl_dyn_remote_type_builder=>get_components( i_rfcdest = i_rfc_destination  i_struct = i_table ).

*     prepare fields of interest
      loop at lt_comp into ls_comp where name np lv_offset_pattern.
        ls_field-fieldname = ls_comp-name.
        ls_field-length    = ls_comp-type->length.
        append ls_field to r_field.
        clear: ls_field, ls_comp.
      endloop.

    catch cx_parameter_invalid_range into lx_pir.

      raise exception lx_pir.

    catch cx_sy_table_creation into lx_tcr.

      raise exception lx_tcr.

    catch cx_sy_struct_creation into lx_scr.

      raise exception lx_scr.

  endtry.

endmethod.


method RFC_READ_TABLE.

* remote read table
  call function 'RFC_READ_TABLE' destination i_rfc_destination
    exporting
      query_table          = i_table
    tables
      options              = i_option
      fields               = c_field
      data                 = c_data
    exceptions
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      others               = 7.

  if sy-subrc ne 0.

    raise exception type zcx_dyn_remote
       exporting
         textid          = zcx_dyn_remote=>rfc_read
         rfc_destination = i_rfc_destination
         table           = i_table.

  endif.

  endmethod.


method SET_FIELD_VALUE.

  field-symbols: <fs_field> type any.

  assign component i_fieldname of structure c_structure to <fs_field>.

  if sy-subrc ne 0.

    raise exception type zcx_dyn_remote
      exporting
        textid = zcx_dyn_remote=>no_field
        field  = i_fieldname.

  endif.

  <fs_field> = i_fieldvalue.

  endmethod.


method SET_FIELD_VALUES.

  if not i_fieldname1 is initial and not i_fieldvalue1 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname1 i_fieldvalue = i_fieldvalue1 changing c_structure = c_structure ).
  endif.

  if not i_fieldname2 is initial and not i_fieldvalue2 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname2 i_fieldvalue = i_fieldvalue2 changing c_structure = c_structure ).
  endif.

  if not i_fieldname3 is initial and not i_fieldvalue3 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname3 i_fieldvalue = i_fieldvalue3 changing c_structure = c_structure ).
  endif.

  if not i_fieldname4 is initial and not i_fieldvalue4 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname4 i_fieldvalue = i_fieldvalue4 changing c_structure = c_structure ).
  endif.

  if not i_fieldname5 is initial and not i_fieldvalue5 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname5 i_fieldvalue = i_fieldvalue5 changing c_structure = c_structure ).
  endif.

  if not i_fieldname6 is initial and not i_fieldvalue6 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname6 i_fieldvalue = i_fieldvalue6 changing c_structure = c_structure ).
  endif.

  if not i_fieldname7 is initial and not i_fieldvalue7 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname7 i_fieldvalue = i_fieldvalue7 changing c_structure = c_structure ).
  endif.

  if not i_fieldname8 is initial and not i_fieldvalue8 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname8 i_fieldvalue = i_fieldvalue8 changing c_structure = c_structure ).
  endif.

  if not i_fieldname9 is initial and not i_fieldvalue9 is initial.
    zcl_dyn_remote=>set_field_value( exporting i_fieldname = i_fieldname9 i_fieldvalue = i_fieldvalue9 changing c_structure = c_structure ).
  endif.

  endmethod.
ENDCLASS.
