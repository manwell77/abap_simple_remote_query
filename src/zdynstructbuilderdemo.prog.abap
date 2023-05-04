*&---------------------------------------------------------------------*
*& Report  ZDYNSTRUCTBUILDERDEMO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  zdynstructbuilderdemo.

parameters: p_uname type xubname,
            p_dest  type rfcdest obligatory,
            p_alv   type xfeld as checkbox.

start-of-selection.

  type-pools: slis.

  ##needed
  constants: gc_30 type i value 30.

* declare field symbols of type any or standard table
  ##needed
  field-symbols: <fs_ts_address> type any,
                 <fs_tt_profile> type standard table,
                 <fs_tt_return>  type standard table.

* declare line field symbols fore managing data
  ##needed
  field-symbols: <fs_line>       type any,
                 <fs_any>        type any.

* declare structure and type table descriptor
  ##needed
  data: lo_address_ts type ref to cl_abap_structdescr,
        lo_profile_tt type ref to cl_abap_tabledescr,
        lo_return_tt  type ref to cl_abap_tabledescr.

* declare generic data type ref
  ##needed
  data: lo_address_wa type ref to data,
        lo_profile_it type ref to data,
        lo_return_it  type ref to data.

* declare for getting components when parsing result
  ##needed
  data: lt_comp type abap_component_tab,
        ls_comp type abap_componentdescr.

* for output writing
  ##needed
  data: lv_text type string.

* for alv grid
  ##needed
  data: lt_fcat   type slis_t_fieldcat_alv,
        ls_fcat   type slis_fieldcat_alv,
        ls_layout type slis_layout_alv.

* create dynamic builders for each structure
  try.

      lo_address_ts = zcl_dyn_remote_type_builder=>create_struct_type( i_rfcdest = p_dest i_struct = 'BAPIADDR3' ).
      lo_profile_tt = zcl_dyn_remote_type_builder=>create_table_type( i_rfcdest = p_dest i_struct = 'BAPIPROF' ).
      lo_return_tt  = zcl_dyn_remote_type_builder=>create_table_type( i_rfcdest = p_dest i_struct = 'BAPIRET2' ).

    catch zcx_dyn_remote_type_builder cx_parameter_invalid_range cx_sy_struct_creation cx_sy_table_creation.

      message text-005 type 'E'.

  endtry.


* create generic data objects handling desired type descriptor
  create data: lo_address_wa type handle lo_address_ts,
               lo_profile_it type handle lo_profile_tt,
               lo_return_it  type handle lo_return_tt.

* assign derefrenciated objects to a generic field-symbol
  assign: lo_address_wa->* to <fs_ts_address>,
          lo_profile_it->* to <fs_tt_profile>,
          lo_return_it->*  to <fs_tt_return>.

* call remote module
  call function 'BAPI_USER_GET_DETAIL' destination p_dest
    exporting
      username              = p_uname
    importing
      address               = <fs_ts_address>
    tables
      profiles              = <fs_tt_profile>
      return                = <fs_tt_return>
    exceptions
      communication_failure = 0
      system_failure        = 0
      others                = 0.

  if <fs_tt_return> is initial.

*   get profile table components
    lt_comp = zcl_dyn_remote_type_builder=>get_components( i_rfcdest = p_dest i_struct = 'BAPIPROF' ).

    try.

        if p_alv is initial.

*         write fullname
          assign component 'FULLNAME' of structure <fs_ts_address> to <fs_any>.
          concatenate text-002 <fs_any> into lv_text separated by space.
          write: / lv_text.
          write: / text-003.

          clear: lv_text.

          loop at <fs_tt_profile> assigning <fs_line>.
            loop at lt_comp into ls_comp.
              assign component ls_comp-name of structure <fs_line> to <fs_any>.
              write: / ls_comp-name.
              write: at gc_30 ':', <fs_any>.
              clear: ls_comp, lv_text.
            endloop.
            write: / text-003.
            clear: lv_text.
          endloop.

        else.

*         build field catalog
          loop at lt_comp into ls_comp.
            ls_fcat-col_pos   = sy-tabix.
            ls_fcat-fieldname = ls_comp-name.
            ls_fcat-seltext_s = ls_comp-name.
            ls_fcat-ddictxt   = 'S'.
            append ls_fcat to lt_fcat.
            clear: ls_comp, ls_fcat.
          endloop.

*         optimize column width
          ls_layout-colwidth_optimize = 'X'.

*         show alv
          call function 'REUSE_ALV_GRID_DISPLAY'
            exporting
              is_layout     = ls_layout
              it_fieldcat   = lt_fcat
            tables
              t_outtab      = <fs_tt_profile>
            exceptions
              program_error = 1
              others        = 2.

          if sy-subrc ne 0.
            message text-006 type 'E'.
          endif.

        endif.

      catch cx_parameter_invalid_range zcx_dyn_remote_type_builder.

        message text-005 type 'E'.

    endtry.


  else.

    loop at <fs_tt_return> assigning <fs_line>.
      assign component 'MESSAGE' of structure <fs_line> to <fs_any>.
      write: / <fs_any>.
    endloop.

  endif.
