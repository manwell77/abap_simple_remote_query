class ZCL_DYN_REMOTE_TYPE_BUILDER definition
  public
  final
  create public .

public section.

  constants OFFSET type STRING value 'OFFSET'. "#EC NOTEXT

  class-methods BUILD_DATA
    importing
      value(I_RFCDEST) type RFCDEST optional
      value(I_STRUCT) type STRUKNAME
    exporting
      value(E_STRUCDATA) type DATA
      value(E_TABLEDATA) type ref to DATA
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  class-methods GET_INTERNAL
    importing
      value(I_DATATYPE) type DATATYPE_D
    returning
      value(RESULT) type INTTYPE
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  class-methods CREATE_ELEM_TYPES
    importing
      value(RFC_DEST) type RFCDEST optional
      value(ELEM_LIST) type ZTT_ROLLNAME
    returning
      value(ELEM_TY_DESCR_COLLECTION) type ref to ZCL_ELEMDESCR_COLLECTION
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER
      CX_PARAMETER_INVALID_RANGE
      CX_SY_STRUCT_CREATION .
  class-methods CREATE_STRUCT_TYPES
    importing
      value(RFC_DEST) type RFCDEST optional
      value(STRUCT_LIST) type ZTT_STRUKNAME
    returning
      value(STRUCT_TY_DESCR_COLLECTION) type ref to ZCL_STRUCTDESCR_COLLECTION
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER
      CX_PARAMETER_INVALID_RANGE
      CX_SY_TABLE_CREATION
      CX_SY_STRUCT_CREATION .
  class-methods CREATE_TABLE_TYPES
    importing
      value(RFC_DEST) type RFCDEST optional
      value(STRUCT_LIST) type ZTT_STRUKNAME
    returning
      value(TABLE_TY_DESCR_COLLECTION) type ref to ZCL_TABLEDESCR_COLLECTION
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER
      CX_PARAMETER_INVALID_RANGE
      CX_SY_STRUCT_CREATION
      CX_SY_TABLE_CREATION .
  class-methods CREATE_ELEM_TYPE
    importing
      value(I_RFCDEST) type RFCDEST optional
      value(I_DELEM) type ROLLNAME
    returning
      value(RESULT) type ref to CL_ABAP_ELEMDESCR
    raising
      CX_PARAMETER_INVALID_RANGE
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  class-methods CREATE_STRUCT_TYPE
    importing
      value(I_RFCDEST) type RFCDEST optional
      value(I_STRUCT) type STRUKNAME
    returning
      value(RESULT) type ref to CL_ABAP_STRUCTDESCR
    raising
      CX_PARAMETER_INVALID_RANGE
      ZCX_DYN_REMOTE_TYPE_BUILDER
      CX_SY_STRUCT_CREATION
      CX_SY_TABLE_CREATION .
  class-methods CREATE_TABLE_TYPE
    importing
      value(I_RFCDEST) type RFCDEST optional
      value(I_STRUCT) type STRUKNAME
    returning
      value(RESULT) type ref to CL_ABAP_TABLEDESCR
    raising
      CX_PARAMETER_INVALID_RANGE
      CX_SY_TABLE_CREATION
      CX_SY_STRUCT_CREATION
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  type-pools ABAP .
  class-methods GET_COMPONENTS
    importing
      value(I_RFCDEST) type RFCDEST
      value(I_STRUCT) type STRUKNAME
    returning
      value(RESULT) type ABAP_COMPONENT_TAB
    raising
      CX_PARAMETER_INVALID_RANGE
      CX_SY_TABLE_CREATION
      CX_SY_STRUCT_CREATION
      ZCX_DYN_REMOTE_TYPE_BUILDER .
  class-methods GET_ELEMDESCR
    importing
      value(I_INTTYPE) type INTTYPE
      value(I_INTLEN) type I optional
      value(I_DECIMALS) type I optional
    returning
      value(RESULT) type ref to CL_ABAP_ELEMDESCR
    raising
      ZCX_DYN_REMOTE_TYPE_BUILDER
      CX_PARAMETER_INVALID_RANGE .
protected section.
private section.

  constants RFCTYPE3 type RFCTYPE_D value '3'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_DYN_REMOTE_TYPE_BUILDER IMPLEMENTATION.


method build_data.

  data: lo_abapstrucdescr type ref to cl_abap_structdescr,
        lo_abaptabledescr type ref to cl_abap_tabledescr,
        lx_root           type ref to cx_root.

  try.

      if e_strucdata is requested.
        lo_abapstrucdescr = zcl_dyn_remote_type_builder=>create_struct_type( i_rfcdest = i_rfcdest i_struct = i_struct ).
        create data: e_strucdata type handle lo_abapstrucdescr.
      endif.

      if e_tabledata is requested.
        lo_abaptabledescr = zcl_dyn_remote_type_builder=>create_table_type( i_rfcdest = i_rfcdest i_struct = i_struct  ).
        create data: e_tabledata type handle lo_abaptabledescr.
      endif.

    catch cx_parameter_invalid_range cx_sy_create_data_error cx_sy_struct_creation cx_sy_table_creation into lx_root.

      raise exception type zcx_dyn_remote_type_builder
        exporting
          textid   = zcx_dyn_remote_type_builder=>data_creation
          previous = lx_root.

  endtry.

endmethod.


method create_elem_type.

    data: ls_dd4 type dd04v,
          lv_dty type inttype,
          lv_dle type i,
          lv_dcs type i.

    data: lv_ownsys type logsys,
          lv_ownrfc type rfcdest.

    data: lx_parameter_invalid_range type ref to cx_parameter_invalid_range,
          lo_descr type ref to cl_abap_typedescr.

    try.

*       rfc destination check
        if not i_rfcdest is initial and not i_delem is initial.

          call function 'RFC_CHECK_DESTINATION'
            exporting
              mydest                        = i_rfcdest
              mytype                        = zcl_dyn_remote_type_builder=>rfctype3
            exceptions
              empty_destination             = 1
              invalid_logical_destination   = 2
              destination_with_special_char = 3
              internal_destination_id       = 4
              empty_rfctype                 = 5
              others                        = 6.

          if sy-subrc ne 0.

            raise exception type zcx_dyn_remote_type_builder
              exporting
                textid  = zcx_dyn_remote_type_builder=>rfc_unreachable
                rfcdest = i_rfcdest.

          endif.

        endif.

*       get owned logical system
        call function 'OWN_LOGICAL_SYSTEM_GET'
          importing
            own_logical_system             = lv_ownsys
          exceptions
            own_logical_system_not_defined = 1
            others                         = 2.

        if sy-subrc ne 0.

          raise exception type zcx_dyn_remote_type_builder
            exporting
              textid = zcx_dyn_remote_type_builder=>own_logsys_not_defined.

        endif.

*       get owned rfc destination (if defined)
        select single rfcdest from tblsysdest into lv_ownrfc where logsys = lv_ownsys.

        if i_rfcdest is initial or i_rfcdest eq lv_ownrfc.

*         local data element
          call method cl_abap_elemdescr=>describe_by_name
            exporting
              p_name         = i_delem
            receiving
              p_descr_ref    = lo_descr
            exceptions
              type_not_found = 1
              others         = 2.

          if sy-subrc ne 0.

            raise exception type zcx_dyn_remote_type_builder
              exporting
                textid = zcx_dyn_remote_type_builder=>no_delem
                delem  = i_delem.

          endif.

          result ?= lo_descr.

        else.

*         remote data element
          call function 'SRTT_GET_REMOTE_DTEL_DEF' destination i_rfcdest
            exporting
              iv_dtel_name = i_delem
            importing
              ev_dd04v     = ls_dd4
            exceptions
              invalid      = 1
              no_authority = 2
              not_found    = 3
              others       = 4.

          if sy-subrc ne 0.

            raise exception type zcx_dyn_remote_type_builder
              exporting
                textid = zcx_dyn_remote_type_builder=>no_delem
                delem  = i_delem.

          endif.

          lv_dty = ls_dd4-datatype.
          lv_dle = ls_dd4-leng.
          lv_dcs = ls_dd4-decimals.

          result = zcl_dyn_remote_type_builder=>get_elemdescr( i_inttype = lv_dty i_intlen = lv_dle i_decimals = lv_dcs ).

        endif.

      catch cx_parameter_invalid_range into lx_parameter_invalid_range.

        raise exception lx_parameter_invalid_range.

    endtry.

  endmethod.


method create_elem_types.

    data: lv_elem  type rollname,
          lo_descr type ref to cl_abap_elemdescr,
          lx_rng   type ref to cx_parameter_invalid_range,
          lx_str   type ref to cx_sy_struct_creation.

    try.

        sort elem_list.
        delete adjacent duplicates from elem_list comparing all fields.

        create object elem_ty_descr_collection.

        loop at elem_list into lv_elem.
          lo_descr = zcl_dyn_remote_type_builder=>create_elem_type( i_rfcdest = rfc_dest i_delem = lv_elem ).
          elem_ty_descr_collection->add( name = lv_elem descriptor = lo_descr ).
          clear: lv_elem.
        endloop.

      catch cx_parameter_invalid_range into lx_rng.

        raise exception lx_rng.

      catch cx_sy_struct_creation into lx_str.

        raise exception lx_str.

    endtry.

  endmethod.


method create_struct_type.

    data: lt_comp   type abap_component_tab,
          lo_descr  type ref to cl_abap_typedescr,
          lv_ownsys type logsys,
          lv_ownrfc type rfcdest.

    data: lx_parameter_invalid_range type ref to cx_parameter_invalid_range,
          lx_sy_struct_creation      type ref to cx_sy_struct_creation,
          lx_sy_table_creation       type ref to cx_sy_table_creation.

    try.

*       get owned logical system
        call function 'OWN_LOGICAL_SYSTEM_GET'
          importing
            own_logical_system             = lv_ownsys
          exceptions
            own_logical_system_not_defined = 1
            others                         = 2.

        if sy-subrc ne 0.

          raise exception type zcx_dyn_remote_type_builder
            exporting
              textid = zcx_dyn_remote_type_builder=>own_logsys_not_defined.

        endif.

*       get owned rfc destination (if defined)
        select single rfcdest from tblsysdest into lv_ownrfc where logsys = lv_ownsys.

        lt_comp = zcl_dyn_remote_type_builder=>get_components( i_rfcdest = i_rfcdest i_struct = i_struct ).

        if not ( i_rfcdest is initial or i_rfcdest eq lv_ownrfc ).
*         remote destination
          result = cl_abap_structdescr=>create( lt_comp ).
        else.
*         local structure
          call method cl_abap_structdescr=>describe_by_name
            exporting
              p_name         = i_struct
            receiving
              p_descr_ref    = lo_descr
            exceptions
              type_not_found = 1
              others         = 2.

          if sy-subrc ne 0.

            raise exception type zcx_dyn_remote_type_builder
              exporting
                textid = zcx_dyn_remote_type_builder=>no_struc
                struct = i_struct.

          endif.

          result ?= lo_descr.

        endif.

      catch cx_parameter_invalid_range into lx_parameter_invalid_range.

        raise exception lx_parameter_invalid_range.

      catch cx_sy_struct_creation into lx_sy_struct_creation.

        raise exception lx_sy_struct_creation.

      catch cx_sy_table_creation into lx_sy_table_creation.

        raise exception lx_sy_table_creation.

    endtry.

  endmethod.


method create_struct_types.

  data: lv_struct type strukname,
        lo_descr  type ref to cl_abap_structdescr,
        lx_rng    type ref to cx_parameter_invalid_range,
        lx_str    type ref to cx_sy_struct_creation,
        lx_tab    type ref to cx_sy_table_creation.

  try.

      sort struct_list.
      delete adjacent duplicates from struct_list comparing all fields.

      create object struct_ty_descr_collection.

      loop at struct_list into lv_struct.
        lo_descr = zcl_dyn_remote_type_builder=>create_struct_type( i_rfcdest = rfc_dest i_struct = lv_struct ).
        struct_ty_descr_collection->add( name = lv_struct descriptor = lo_descr ).
        clear: lv_struct.
      endloop.

    catch cx_parameter_invalid_range into lx_rng.

      raise exception lx_rng.

    catch cx_sy_struct_creation into lx_str.

      raise exception lx_str.

    catch cx_sy_table_creation into lx_tab.

      raise exception lx_tab.

  endtry.

endmethod.


method create_table_type.

  data: lo_ts type ref to cl_abap_structdescr.

  data: lx_parameter_invalid_range type ref to cx_parameter_invalid_range,
        lx_sy_struct_creation      type ref to cx_sy_struct_creation,
        lx_sy_table_creation       type ref to cx_sy_table_creation.

  try.

      lo_ts = zcl_dyn_remote_type_builder=>create_struct_type( i_rfcdest = i_rfcdest i_struct = i_struct ).

      result = cl_abap_tabledescr=>create( p_line_type = lo_ts p_table_kind = cl_abap_tabledescr=>tablekind_std p_unique = abap_false ).

    catch cx_parameter_invalid_range into lx_parameter_invalid_range.

      raise exception lx_parameter_invalid_range.

    catch cx_sy_struct_creation into lx_sy_struct_creation.

      raise exception lx_sy_struct_creation.

    catch cx_sy_table_creation into lx_sy_table_creation.

      raise exception lx_sy_table_creation.

  endtry.

endmethod.


method create_table_types.

  data: lv_struct type strukname,
        lo_descr  type ref to cl_abap_tabledescr,
        lx_rng    type ref to cx_parameter_invalid_range,
        lx_str    type ref to cx_sy_struct_creation,
        lx_tcr    type ref to cx_sy_table_creation.

  try.

      sort struct_list.
      delete adjacent duplicates from struct_list comparing all fields.

      create object table_ty_descr_collection.

      loop at struct_list into lv_struct.
        lo_descr = zcl_dyn_remote_type_builder=>create_table_type( i_rfcdest = rfc_dest i_struct = lv_struct ).
        table_ty_descr_collection->add( name = lv_struct descriptor = lo_descr ).
        clear: lv_struct.
      endloop.

    catch cx_parameter_invalid_range into lx_rng.

      raise exception lx_rng.

    catch cx_sy_struct_creation into lx_str.

      raise exception lx_str.

    catch cx_sy_table_creation into lx_tcr.

      raise exception lx_tcr.

  endtry.

endmethod.


method get_components.

* data declaration
  data: lo_elem      type ref to cl_abap_elemdescr,
        lo_struct    type ref to cl_abap_structdescr,
        lo_table     type ref to cl_abap_tabledescr.

  data: lt_fields    type standard table of dfies,
        lt_lines     type ddtypelist,
        ls_line      type ddtypedesc,
        ls_lfield    type dfies,
        ls_comp      type abap_componentdescr,
        ls_dfies     type dfies,
        ls_tmp_dfies type dfies,
        ls_x030l     type x030l,
        lv_intlen    type i,
        lv_decimals  type i,
        lv_off       type i,
        lv_count     type numc3.

  data: lx_parameter_invalid_range type ref to cx_parameter_invalid_range,
        lx_struc_creation          type ref to cx_sy_struct_creation,
        lx_table_creation          type ref to cx_sy_table_creation.

* rfc destination check
  if not i_rfcdest is initial.

    call function 'RFC_CHECK_DESTINATION'
      exporting
        mydest                        = i_rfcdest
        mytype                        = zcl_dyn_remote_type_builder=>rfctype3
      exceptions
        empty_destination             = 1
        invalid_logical_destination   = 2
        destination_with_special_char = 3
        internal_destination_id       = 4
        empty_rfctype                 = 5
        others                        = 6.

    if sy-subrc ne 0.

      raise exception type zcx_dyn_remote_type_builder
        exporting
          textid  = zcx_dyn_remote_type_builder=>rfc_unreachable
          rfcdest = i_rfcdest.

    endif.

  endif.

* get dictionary information from rfc destination
  call function 'DDIF_FIELDINFO_GET' destination i_rfcdest
    exporting
      tabname        = i_struct
      all_types      = 'X'
    importing
      x030l_wa       = ls_x030l
      lines_descr    = lt_lines
    tables
      dfies_tab      = lt_fields
    exceptions
      not_found      = 1
      internal_error = 2
      others         = 3.

  if sy-subrc ne 0.

    raise exception type zcx_dyn_remote_type_builder
      exporting
        textid = zcx_dyn_remote_type_builder=>no_struc
        struct = i_struct.

  endif.

* component table builder
  try.

*     build structure field by field (nested structures have lfieldname valued has struc-field)
      loop at lt_fields into ls_dfies where not lfieldname cs '-'.

*       internal length determination
        case ls_dfies-inttype.

          when cl_abap_elemdescr=>typekind_char or
               cl_abap_elemdescr=>typekind_date or
               cl_abap_elemdescr=>typekind_time or
               cl_abap_elemdescr=>typekind_num.

            lv_intlen   = ls_dfies-intlen / ls_x030l-unicodelg.

          when cl_abap_elemdescr=>typekind_table   or
               cl_abap_elemdescr=>typekind_struct1 or
               cl_abap_elemdescr=>typekind_struct2.
*              do nothing -> intlen doesn't matter when building elements!

          when others.

            lv_intlen   = ls_dfies-intlen.

        endcase.

*       decimals
        lv_decimals = ls_dfies-decimals.

*       offset management with a dummy fill to handle rfc return misplacement (if needed)
        lv_off = ls_dfies-offset - ( ls_tmp_dfies-offset + ls_tmp_dfies-intlen ).

        if lv_off gt 0.
*         build byte element
          lo_elem = cl_abap_elemdescr=>get_x( lv_off ).

          ls_comp-type = lo_elem.

          add 1 to lv_count.

          concatenate zcl_dyn_remote_type_builder=>offset '_' lv_count into ls_comp-name.

          append ls_comp to result.

          free: lo_elem.

        endif.

*       field management by means of internal abap types
        ls_comp-name = ls_dfies-fieldname.

*       build element
        case ls_dfies-inttype.

*         build table type
          when cl_abap_elemdescr=>typekind_table.

            read table lt_lines into ls_line with key typename = ls_dfies-rollname.
            read table ls_line-fields into ls_lfield with key tabname = ls_line-typename.
            lo_table = zcl_dyn_remote_type_builder=>create_table_type( i_rfcdest = i_rfcdest i_struct = ls_lfield-rollname ).
*           assign element
            ls_comp-type = lo_table.

*         build structure
          when cl_abap_elemdescr=>typekind_struct1 or
               cl_abap_elemdescr=>typekind_struct2.

            lo_struct = zcl_dyn_remote_type_builder=>create_struct_type( i_rfcdest = i_rfcdest i_struct = ls_dfies-rollname ).
*           assign element
            ls_comp-type = lo_struct.

*         build element (also for included structures)
          when others.
            lo_elem = zcl_dyn_remote_type_builder=>get_elemdescr( i_inttype = ls_dfies-inttype i_intlen = lv_intlen i_decimals = lv_decimals ).
*           assign element
            ls_comp-type = lo_elem.

        endcase.

        append ls_comp to result.

        ls_tmp_dfies = ls_dfies.

        clear: ls_dfies.
      endloop.

    catch cx_parameter_invalid_range into lx_parameter_invalid_range.

      raise exception lx_parameter_invalid_range.

    catch cx_sy_struct_creation into lx_struc_creation.

      raise exception lx_struc_creation.

    catch cx_sy_table_creation into lx_table_creation.

      raise exception lx_table_creation.

  endtry.

endmethod.


method GET_ELEMDESCR.

  data: lx_pir type ref to cx_parameter_invalid_range.
  data: lv_int2 type int2,
        lv_int1 type int1.

  try.

      case i_inttype.

        when cl_abap_elemdescr=>typekind_int.     result = cl_abap_elemdescr=>get_i( ).
        when cl_abap_elemdescr=>typekind_int1.    result ?= cl_abap_elemdescr=>describe_by_data( p_data = lv_int1 ). " no getters for int1
        when cl_abap_elemdescr=>typekind_int2.    result ?= cl_abap_elemdescr=>describe_by_data( p_data = lv_int2 ). " no getters for int2
        when cl_abap_elemdescr=>typekind_float.   result = cl_abap_elemdescr=>get_f( ).
        when cl_abap_elemdescr=>typekind_date.    result = cl_abap_elemdescr=>get_d( ).
        when cl_abap_elemdescr=>typekind_packed.  result = cl_abap_elemdescr=>get_p( p_length = i_intlen p_decimals = i_decimals ).
        when cl_abap_elemdescr=>typekind_char.    result = cl_abap_elemdescr=>get_c( p_length = i_intlen ).
        when cl_abap_elemdescr=>typekind_time.    result = cl_abap_elemdescr=>get_t( ).
        when cl_abap_elemdescr=>typekind_num.     result = cl_abap_elemdescr=>get_n( p_length = i_intlen ).
        when cl_abap_elemdescr=>typekind_hex.     result = cl_abap_elemdescr=>get_x( p_length = i_intlen ).
        when cl_abap_elemdescr=>typekind_string.  result = cl_abap_elemdescr=>get_string( ).
        when cl_abap_elemdescr=>typekind_xstring. result = cl_abap_elemdescr=>get_xstring( ).

        when others.

          raise exception type zcx_dyn_remote_type_builder
            exporting
              textid  = zcx_dyn_remote_type_builder=>no_inttype
              inttype = i_inttype.

      endcase.

    catch cx_parameter_invalid_range into lx_pir.

      raise exception lx_pir.

  endtry.

  endmethod.


method get_internal.

    case i_datatype.

      when 'ACCP'. result = cl_abap_elemdescr=>typekind_num.
      when 'CHAR'. result = cl_abap_elemdescr=>typekind_char.
      when 'CLNT'. result = cl_abap_elemdescr=>typekind_char.
      when 'CUKY'. result = cl_abap_elemdescr=>typekind_char.
      when 'CURR'. result = cl_abap_elemdescr=>typekind_packed.
      when 'DATS'. result = cl_abap_elemdescr=>typekind_date.
      when 'DEC'.  result = cl_abap_elemdescr=>typekind_packed.
      when 'FLTP'. result = cl_abap_elemdescr=>typekind_float.
      when 'INT1'. result = cl_abap_elemdescr=>typekind_int1.
      when 'INT2'. result = cl_abap_elemdescr=>typekind_int2.
      when 'INT4'. result = cl_abap_elemdescr=>typekind_int.
      when 'LANG'. result = cl_abap_elemdescr=>typekind_char.
      when 'LCHR'. result = cl_abap_elemdescr=>typekind_char.
      when 'LRAW'. result = cl_abap_elemdescr=>typekind_hex.
      when 'NUMC'. result = cl_abap_elemdescr=>typekind_num.
      when 'PREC'. result = cl_abap_elemdescr=>typekind_int2.
      when 'QUAN'. result = cl_abap_elemdescr=>typekind_packed.
      when 'RAW'.  result = cl_abap_elemdescr=>typekind_hex.
      when 'RSTR'. result = cl_abap_elemdescr=>typekind_xstring.
      when 'SSTR'. result = cl_abap_elemdescr=>typekind_string.
      when 'STRG'. result = cl_abap_elemdescr=>typekind_string.
      when 'TIMS'. result = cl_abap_elemdescr=>typekind_time.
      when 'UNIT'. result = cl_abap_elemdescr=>typekind_char.

      when others.

        raise exception type zcx_dyn_remote_type_builder
          exporting
            textid   = zcx_dyn_remote_type_builder=>no_datatype
            datatype = i_datatype.

    endcase.

  endmethod.
ENDCLASS.
