*&---------------------------------------------------------------------*
*&  Include           ZDYNSRQF01
*&---------------------------------------------------------------------*
form build_fieldcatalog using value(vv_rfc)   type rfcdest
                              value(vv_struk) type strukname

                        changing ct_fcat      type lvc_t_fcat
                                 cv_subrc     type sysubrc.

  clear: cv_subrc.
  refresh: ct_fcat.

  data: ls_field type dfies,
        ls_fcat  type lvc_s_fcat,
        lt_field type standard table of dfies.

  call function 'DDIF_FIELDINFO_GET' destination vv_rfc
    exporting
      tabname        = vv_struk
      langu          = sy-langu
    tables
      dfies_tab      = lt_field
    exceptions
      not_found      = 1
      internal_error = 2
      others         = 3.

  if sy-subrc ne 0.
    cv_subrc = 4.
    return.
  endif.

  loop at lt_field into ls_field.
    ls_fcat-col_pos    = ls_field-position.
    ls_fcat-coltext    = ls_field-fieldname.
    ls_fcat-key        = ls_field-keyflag.
    ls_fcat-fieldname  = ls_field-fieldname.
    ls_fcat-seltext    = ls_field-fieldtext.
    ls_fcat-reptext    = ls_field-reptext.
    ls_fcat-scrtext_s  = ls_field-scrtext_s.
    ls_fcat-scrtext_m  = ls_field-scrtext_m.
    ls_fcat-scrtext_l  = ls_field-scrtext_l.
    append ls_fcat to ct_fcat.
    clear: ls_field, ls_fcat.
  endloop.

endform.                    "build_fieldcatalog

*&--------------------------------------------------------------------*
*&      Form  alv_create
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VV_COtextME)
*      -->CO_CONTAINEtext
*      -->CO_ALV     text
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form alv_create using value(vv_contname)    type char10

                      changing co_container type ref to cl_gui_custom_container
                               co_alv       type ref to cl_gui_alv_grid
                               cv_subrc     type sysubrc.

  clear cv_subrc.

  create object co_container
    exporting
      container_name              = vv_contname
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6.

  if sy-subrc ne 0.
    add sy-subrc to cv_subrc.
    return.
  endif.

  create object  co_alv
    exporting
      i_parent                    = co_container->screen0
    exceptions
      error_cntl_create           = 1
      error_cntl_init             = 2
      error_cntl_link             = 3
      error_dp_create             = 4
      others                      = 5.

  if sy-subrc ne 0.
    add sy-subrc to cv_subrc.
    return.
  endif.

  co_alv->set_graphics_container( i_graphics_container = co_container ).

endform.                    "alv_create

*&--------------------------------------------------------------------*
*&      Form  alv_destroy
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->CO_ALV     text
*      -->CO_CONTAINEtext
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form alv_destroy changing co_alv       type ref to cl_gui_alv_grid
                          co_container type ref to cl_gui_custom_container
                          cv_subrc     type sysubrc.

  clear cv_subrc.

  if co_alv is bound.

    co_alv->free( exceptions
                    cntl_error              = 1
                    cntl_system_error       = 2
                    others                  = 3 ).

    if sy-subrc ne 0.
      add sy-subrc to cv_subrc.
      return.
    endif.

    free: co_alv.

  endif.

  if co_container is bound.

    co_container->free( exceptions
                          cntl_error        = 1
                          cntl_system_error = 2
                          others            = 3 ).

    if sy-subrc ne 0.
      add sy-subrc to cv_subrc.
      return.
    endif.

    free: co_container.

  endif.

endform.                    "alv_destroy

*&--------------------------------------------------------------------*
*&      Form  build_query_string
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VT_TEtext
*      -->CV_QUERY   text
*---------------------------------------------------------------------*
form build_query_string using value(vt_text) type soli_tab changing cv_query type string.

  clear: cv_query.

  data: ls_text type soli.

  loop at vt_text into ls_text-line where not line is initial or not line co ' '.
    condense ls_text-line.
    concatenate cv_query ls_text-line into cv_query separated by space.
  endloop.

  condense cv_query.

endform.                    "build_query_string

*&--------------------------------------------------------------------*
*&      Form  get_textarea_content
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VO_TEtextEA)
*      -->CT_TEXT    text
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form get_textarea_content using value(vo_textarea) type ref to cl_gui_textedit

                          changing ct_text         type soli_tab
                                   cv_subrc        type sysubrc.

  clear cv_subrc.

  refresh ct_text.

  call method vo_textarea->get_text_as_r3table
    importing
      table                  = ct_text
    exceptions
      error_dp               = 1
      error_cntl_call_method = 2
      error_dp_create        = 3
      potential_data_loss    = 4
      others                 = 5.

  cv_subrc = sy-subrc.

endform.                    "get_textarea_content

*&--------------------------------------------------------------------*
*&      Form  create_textarea
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VO_COtextNER)
*      -->CO_TEXTAREAtext
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form create_textarea using value(vo_container) type ref to cl_gui_custom_container

                     changing co_textarea      type ref to cl_gui_textedit
                              cv_subrc         type sysubrc.

  clear cv_subrc.

  create object co_textarea
    exporting
       parent                     = vo_container
       wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
       wordwrap_position          = '115'
       wordwrap_to_linebreak_mode = cl_gui_textedit=>true
    exceptions
        others                    = 1.

  cv_subrc = sy-subrc.

endform.                    "create_textarea

*&--------------------------------------------------------------------*
*&      Form  create_container
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->CO_CONTAINEtext
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form create_container changing co_container type ref to cl_gui_custom_container cv_subrc type sysubrc.

  clear cv_subrc.

  create object co_container
      exporting
          container_name              = 'TEXTAREA_QUERY'
      exceptions
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.

  cv_subrc = sy-subrc.

endform.                    "create_container

*&--------------------------------------------------------------------*
*&      Form  set_screen_layout
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VV_TAtextUT)
*      -->VALUE(VV_TAtextP)
*      -->VALUE(VV_STtextNPUT)
*---------------------------------------------------------------------*
form set_screen_layout using value(vv_tabinput)   type i
                             value(vv_tabhelp)    type i
                             value(vv_startinput) type i.

  loop at screen.
    if screen-name eq 'GV_TABLE'.
      screen-input      = vv_tabinput.
      screen-value_help = vv_tabhelp.
    endif.
    if screen-name eq 'BUTTON_START'.
      screen-input      = vv_startinput.
    endif.
    modify screen.
  endloop.

endform.                    "set_screen_layout

*&--------------------------------------------------------------------*
*&      Form  rfc_close
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VV_RFtext
*---------------------------------------------------------------------*
form rfc_close using value(vv_rfc) type rfcdest.

  call function 'RFC_CONNECTION_CLOSE'
    exporting
      destination          = vv_rfc
    exceptions
      destination_not_open = 0
      others               = 0.

endform.                    "rfc_close

*&--------------------------------------------------------------------*
*&      Form  verify_destination
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VV_RFtext
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form verify_destination using value(vv_rfc) type rfcdest changing cv_subrc type sysubrc.

  data: lv_rfc type string.

  clear cv_subrc.

  lv_rfc = vv_rfc.

  call function 'RFC_VERIFY_DESTINATION'
    exporting
      destination                = lv_rfc
    exceptions
      internal_failure           = 1
      timeout                    = 2
      dest_communication_failure = 3
      dest_system_failure        = 4
      update_failure             = 5
      no_update_authority        = 6
      others                     = 7.

  cv_subrc = sy-subrc.

endform.                    "verify_destination

*&--------------------------------------------------------------------*
*&      Form  set_textarea_readonly
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->VALUE(VV_BOtext
*      -->CO_TEXTAREAtext
*      -->CV_SUBRC   text
*---------------------------------------------------------------------*
form set_textarea_readonly using value(vv_bool) type i

                           changing co_textarea type ref to cl_gui_textedit
                                    cv_subrc    type sysubrc.

  clear cv_subrc.

  call method co_textarea->set_readonly_mode
    exporting
      readonly_mode          = vv_bool
    exceptions
      error_cntl_call_method = 1
      invalid_parameter      = 2
      others                 = 3.

  cv_subrc = sy-subrc.

endform.                    "set_textarea_readonly
