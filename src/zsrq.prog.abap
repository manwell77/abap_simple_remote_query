*&---------------------------------------------------------------------*
*&  Include           ZSRQ
*&---------------------------------------------------------------------*

*************************************
* See ZDYNSRQDEMO report for a demo *
*************************************

* globals
##needed
data: _lv_count  type i,
      _ls_comp1  type cl_abap_structdescr=>component,
      _ls_comp2  type cl_abap_structdescr=>component,
      _lt_query  type zrfc_db_opt_t,
      _lt_comp1  type cl_abap_structdescr=>component_table,
      _lt_comp2  type cl_abap_structdescr=>component_table.

##needed
data: _lo_struc1 type ref to cl_abap_structdescr,
      _lo_struc2 type ref to cl_abap_structdescr.

##needed
field-symbols: <_fs_field1> type any,
               <_fs_field2> type any,
               <_fs_struc>  type any,
               <_ft_itab>   type standard table.

##needed
define _srq_build-structure.

* &1: rfc destination
* &2: structure name
* &3: result (structure data)

* sy-subrc set to 8 if error occurred

  try.

*     build internal table data
      call method zcl_dyn_remote_type_builder=>build_data
        exporting
          i_rfcdest   = &1
          i_struct    = &2
        importing
          e_strucdata = &3.

      if not &3 is bound.
        ##write_ok
        sy-subrc = 8.
      else.
        ##write_ok
        sy-subrc = 0.
      endif.

    catch zcx_dyn_remote_type_builder.

      sy-subrc = 8.

  endtry.

end-of-definition.

##needed
define _srq_build-itab.

* &1: rfc destination
* &2: structure name
* &3: result (internal table data)

* sy-subrc set to 8 if error occurred

  try.

*     build internal table data
      call method zcl_dyn_remote_type_builder=>build_data
        exporting
          i_rfcdest   = &1
          i_struct    = &2
        importing
          e_tabledata = &3.

      if not &3 is bound.
        ##write_ok
        sy-subrc = 8.
      else.
        ##write_ok
        sy-subrc = 0.
      endif.

    catch zcx_dyn_remote_type_builder.

      sy-subrc = 8.

  endtry.

end-of-definition.

##needed
define _srq_select-single.

* &1: rfc destination
* &2: table name
* &3: query as string
* &4: result (structure data)

* sy-subrc set to 4 if nothing is found
* sy-subrc set to 8 if error occured
* sy-dbcnt set to 1

* clear globals
  refresh: _lt_query.

  if <_fs_struc> is assigned.
    unassign <_fs_struc>.
  endif.

  try.

*     encode queries
      _lt_query = zcl_dyn_remote=>build_query( i_query = &3 ).

      assign &4->* to <_fs_struc>.

      if not <_fs_struc> is assigned.
        ##write_ok
        sy-subrc = 8.
      else.

*       get data
        call method zcl_dyn_remote=>get_remote_struc_data
          exporting
            i_rfc_destination = &1
            i_table           = &2
            i_query           = _lt_query
          importing
            e_struc           = <_fs_struc>.

        if not <_fs_struc> is initial.
          ##write_ok
          sy-subrc = 0.
          ##write_ok
          sy-dbcnt = 1.
        else.
          ##write_ok
          sy-subrc = 4.
        endif.

      endif.

    catch zcx_dyn_remote_type_builder
          zcx_dyn_remote
          cx_sy_struct_creation
          cx_sy_table_creation
          cx_parameter_invalid_range
          cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range.

      ##write_ok
      sy-subrc = 8.

  endtry.

end-of-definition.

##needed
define _srq_select.

* &1: rfc destination
* &2: table name
* &3: query as string
* &4: result (internal table data)

* sy-subrc set to 4 if nothing is found
* sy-subrc set to 8 if error occured
* sy-dbcnt set to record(s) found

* clear globals
  refresh: _lt_query.

  if <_ft_itab> is assigned.
    unassign <_ft_itab>.
  endif.

  try.

*     encode queries
      _lt_query = zcl_dyn_remote=>build_query( i_query = &3 ).

      assign &4->* to <_ft_itab>.

      if not <_ft_itab> is assigned.
        ##write_ok
        sy-subrc = 8.
      else.

*       get data
        call method zcl_dyn_remote=>get_remote_table_data
          exporting
            i_rfc_destination = &1
            i_table           = &2
            i_query           = _lt_query
          importing
            e_table           = <_ft_itab>.

        if not <_ft_itab> is initial.
          ##write_ok
          sy-subrc = 0.
          ##write_ok
          sy-dbcnt = lines( <_ft_itab> ).
        else.
          ##write_ok
          sy-subrc = 4.
        endif.

      endif.

    catch zcx_dyn_remote_type_builder
          zcx_dyn_remote
          cx_sy_struct_creation
          cx_sy_table_creation
          cx_parameter_invalid_range
          cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range.

      ##write_ok
      sy-subrc = 8.

  endtry.

end-of-definition.

##needed
define _srq_get-field.

* &1: structure
* &2: field name
* &3: field value

* sy-subrc set to 8 if error occurred

  try.

*     get field
      call method zcl_dyn_remote=>get_field_value
        exporting
          i_fieldname  = &2
          i_structure  = &1
        importing
          e_fieldvalue = &3.

    catch zcx_dyn_remote.

      ##write_ok
      sy-subrc = 8.

  endtry.

  sy-subrc = 0.

end-of-definition.

##needed
define _srq_set-field.

* &1: structure
* &2: field name
* &3: field value

* sy-subrc set to 8 if error occurred

  try.

*     set field
      call method zcl_dyn_remote=>set_field_value
        exporting
          i_fieldname  = &2
          i_fieldvalue = &3
        changing
          c_structure  = &1.

    catch zcx_dyn_remote.

      ##write_ok
      sy-subrc = 8.

  endtry.

  sy-subrc = 0.

end-of-definition.

##needed
define _srq_move-corresponding.

* &1: structure from
* &2: structure to

* sy-subrc set to 8 if error occurred
* sy-dbcnt set to number of corresponding fields moved

* clear globals
  refresh: _lt_comp1, _lt_comp2.
  clear: _lv_count.
  free: _lo_struc1, _lo_struc2.

* describe local structure
  _lo_struc1 ?= cl_abap_structdescr=>describe_by_data( &1 ).
  _lo_struc2 ?= cl_abap_structdescr=>describe_by_data( &2 ).

* get local structure components
  _lt_comp1 = _lo_struc1->get_components( ).
  _lt_comp2 = _lo_struc2->get_components( ).

  try.

*     map components
      loop at _lt_comp1 into _ls_comp1.

        if <_fs_field1> is assigned.
          unassign <_fs_field1>.
        endif.

        if <_fs_field2> is assigned.
          unassign <_fs_field2>.
        endif.

        read table _lt_comp2 into _ls_comp2 with key name = _ls_comp1-name.

        if sy-subrc ne 0.
          continue.
        endif.

        assign component: _ls_comp1-name of structure &1 to <_fs_field1>,
                          _ls_comp2-name of structure &2 to <_fs_field2>.

        if <_fs_field2> is assigned and <_fs_field1> is assigned.
          <_fs_field2> = <_fs_field1>.
          add 1 to _lv_count.
        else.
          ##write_ok
          sy-subrc = 8.
          exit.
        endif.

      endloop.

      ##write_ok
      sy-subrc = 0.
      ##write_ok
      sy-dbcnt = _lv_count.

    catch cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range.

      ##write_ok
      sy-subrc = 8.

  endtry.

end-of-definition.

##needed
define _srq_move-mapping.

* &1: structure from
* &2: structure to
* &3: field from
* &4: field to

* sy-subrc set to 8 if error occurred

* clear globals

  try.

      if <_fs_field1> is assigned.
        unassign <_fs_field1>.
      endif.

      if <_fs_field2> is assigned.
        unassign <_fs_field2>.
      endif.

      assign component: &3 of structure &1 to <_fs_field1>,
                        &4 of structure &2 to <_fs_field2>.

      if <_fs_field2> is assigned and <_fs_field1> is assigned.
        <_fs_field2> = <_fs_field1>.
        ##write_ok
        sy-subrc = 0.
      else.
        ##write_ok
        sy-subrc = 8.
      endif.

    catch cx_sy_assign_cast_illegal_cast
          cx_sy_assign_cast_unknown_type
          cx_sy_assign_out_of_range.

      ##write_ok
      sy-subrc = 8.

  endtry.

end-of-definition.
