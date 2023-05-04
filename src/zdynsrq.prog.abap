*&---------------------------------------------------------------------*
*& Report  ZDYNSRQ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

include zdynsrqtop.

initialization.

  gs_layout-zebra      = 'X'.
  gs_layout-sel_mode   = 'D'.
  gs_layout-cwidth_opt = 'X'.

start-of-selection.

  call screen 9001.

  include zdynsrqf01.

  include zdynsrqi01.

  include zdynsrqo01.
