*&---------------------------------------------------------------------*
*& Include ZDYNSRQTOP                                        Report ZDYNSRQ
*&
*&---------------------------------------------------------------------*

report   zdynsrq.

##INCL_OK
include zsrq.

##NEEDED
data: go_textarea  type ref to cl_gui_textedit,
      go_container type ref to cl_gui_custom_container,
      go_table     type ref to data,
      go_alv       type ref to cl_gui_alv_grid,
      go_cntresult type ref to cl_gui_custom_container.

##NEEDED
data: gt_text   type soli_tab,
      gt_fcat   type lvc_t_fcat.

##NEEDED
data: gs_layout type lvc_s_layo.

##NEEDED
data: gv_rfc    type rfcdest,
      gv_table  type tabname16,
      gv_subrc  type sysubrc,
      gv_query  type string,
      gv_struk  type strukname.

##NEEDED
field-symbols: <gt_list> type standard table.
