*---------------------------------------------------------------------*
*  MODULE after_input_9001 INPUT
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
module after_input_9001 input.

  case sy-ucomm.

    when 'BACK' or 'CANCEL' or 'EXIT'.

      leave program.

    when 'START'.

*     check rfc and tablle
      perform verify_destination using gv_rfc changing gv_subrc.

      if gv_subrc ne 0.
        message w050(zdyntypebuilder) with gv_rfc.
        return.
      endif.

      concatenate `TABNAME EQ '` gv_table `' AND AS4LOCAL EQ 'A' AND AS4VERS EQ '0000'` into gv_query.

      _srq_build-structure gv_rfc 'DD02L' go_table.

      if sy-subrc ne 0.
        message w055(zdyntypebuilder) with gv_table gv_rfc.
        return.
      endif.

      ##WRITE_OK
      _srq_select-single gv_rfc 'DD02L' gv_query go_table.

      if sy-subrc ne 0.
        message w055(zdyntypebuilder) with gv_table gv_rfc.
        return.
      endif.

*     query mustn't be initial
      perform get_textarea_content using go_textarea changing gt_text gv_subrc.

      if gv_subrc ne 0 or gt_text is initial.
        message w056(zdyntypebuilder).
        return.
      endif.

*     build remote query
      perform build_query_string using gt_text changing gv_query.

      free: go_table.
      gv_struk = gv_table.

*     perform remote query
      _srq_build-itab gv_rfc gv_struk go_table.

      if sy-subrc ne 0.
        message w059(zdyntypebuilder).
        return.
      endif.

      ##WRITE_OK
      _srq_select gv_rfc gv_struk gv_query go_table.

      if sy-subrc ne 0.
        message s057(zdyntypebuilder).
        return.
      endif.

      assign go_table->* to <gt_list>.

*     build field catalog
      perform build_fieldcatalog using gv_rfc gv_struk changing gt_fcat gv_subrc.

      if sy-subrc ne 0.
        message s060(zdyntypebuilder).
        return.
      endif.

      set screen '9002'.

  endcase.

endmodule.                    "after_input_9001 INPUT
*&---------------------------------------------------------------------*
*&      Module  after_input_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module after_input_9002 input.

  case sy-ucomm.

    when 'BACK' or 'CANCEL' or 'EXIT'.

      perform alv_destroy changing go_alv go_cntresult gv_subrc.

      refresh <gt_list>.
      set screen '9001'.

  endcase.

endmodule.                 " after_input_9002  INPUT
