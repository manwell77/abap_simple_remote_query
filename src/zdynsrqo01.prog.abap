*---------------------------------------------------------------------*
*  MODULE before_output_9001 OUTPUT
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
module before_output_9001 output.

  set pf-status 'GS_9001'.

  if not go_container is bound.

    perform create_container changing go_container gv_subrc.

    if gv_subrc ne 0.
      message a054(zdyntypebuilder).
    endif.

  endif.

  if not go_textarea is bound.

    perform create_textarea using go_container changing go_textarea gv_subrc.

    if gv_subrc ne 0.
      message a053(zdyntypebuilder).
    endif.

  endif.

  if not gv_rfc is initial.

    perform verify_destination using gv_rfc changing gv_subrc.

    if gv_subrc ne 0.
      clear gv_rfc.
      message w050(zdyntypebuilder) with gv_rfc.
    endif.

  endif.

  if not gv_rfc is initial.

    perform set_textarea_readonly using cl_gui_textedit=>false changing go_textarea gv_subrc.

    if gv_subrc ne 0.
      message a051(zdyntypebuilder).
    endif.

    perform set_screen_layout using cl_gui_textedit=>true cl_gui_textedit=>true cl_gui_textedit=>true.

  else.

    perform set_textarea_readonly using cl_gui_textedit=>true changing go_textarea gv_subrc.

    if gv_subrc ne 0.
      message a052(zdyntypebuilder).
    endif.

    perform set_screen_layout using cl_gui_textedit=>false cl_gui_textedit=>false cl_gui_textedit=>false.

  endif.

  perform rfc_close using gv_rfc.

endmodule.                    "before_output_9001 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  before_output_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module before_output_9002 output.

  set pf-status 'GS_9002'.

  perform alv_destroy changing go_alv go_cntresult gv_subrc.

  if gv_subrc ne 0.
    message a058(zdyntypebuilder).
    return.
  endif.

  perform alv_create using 'CONTRESULT' changing go_cntresult go_alv gv_subrc.

  if gv_subrc ne 0.
    message a058(zdyntypebuilder).
    return.
  endif.

  go_alv->set_table_for_first_display( exporting
                                       is_layout                      = gs_layout
                                     changing
                                       it_outtab                      = <gt_list>
                                       it_fieldcatalog                = gt_fcat
                                     exceptions
                                       invalid_parameter_combination  = 1
                                       program_error                  = 2
                                       too_many_lines                 = 3
                                       others                         = 4 ).

  if sy-subrc ne 0.
    message a058(zdyntypebuilder).
    leave to screen 0.
  endif.

endmodule.                 " before_output_9002  OUTPUT
