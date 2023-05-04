class ZCL_TABLEDESCR_COLLECTION definition
  public
  final
  create public .

public section.

  methods ADD
    importing
      value(NAME) type STRUKNAME
      value(DESCRIPTOR) type ref to CL_ABAP_TABLEDESCR .
  methods EMPTY .
  methods REMOVE_BY_INDEX
    importing
      value(INDEX) type I .
  methods REMOVE_BY_NAME
    importing
      value(NAME) type TABNAME .
  methods GET_BY_INDEX
    importing
      value(INDEX) type I
    returning
      value(TABLEDESCR) type ZCS_ABAP_TABLEDESCR .
  methods SIZE
    returning
      value(SIZE) type I .
  methods IS_EMPTY
    returning
      value(IS_EMPTY) type FLAG .
  methods GET_BY_NAME
    importing
      value(NAME) type TABNAME
    returning
      value(TABLEDESCR) type ZCS_ABAP_TABLEDESCR .
  methods GET_ITERATOR
    returning
      value(ITERATOR) type ref to ZCL_TABLEDESCR_COLL_ITERATOR .
protected section.
private section.

  data COLLECTION type ZCT_ABAP_TABLEDESCR .
ENDCLASS.



CLASS ZCL_TABLEDESCR_COLLECTION IMPLEMENTATION.


method ADD.

  DATA: ls_tabledescr TYPE zcs_abap_tabledescr.

  ls_tabledescr-name = name.
  ls_tabledescr-descriptor = descriptor.

  APPEND ls_tabledescr TO me->collection.

  endmethod.


method EMPTY.

  FIELD-SYMBOLS: <fs_tabledescr> TYPE zcs_abap_tabledescr.

  LOOP AT me->collection ASSIGNING <fs_tabledescr>.
    FREE: <fs_tabledescr>-descriptor.
  ENDLOOP.

  REFRESH: me->collection.

  endmethod.


method GET_BY_INDEX.

  READ TABLE me->collection INDEX index INTO tabledescr.

  endmethod.


method GET_BY_NAME.

  READ TABLE me->collection INTO tabledescr WITH KEY name = name.

  endmethod.


method GET_ITERATOR.

  CREATE OBJECT iterator EXPORTING collection = me.

  endmethod.


method IS_EMPTY.

  IF LINES( me->collection ) EQ 0.
    is_empty = 'X'.
  ENDIF.

  endmethod.


method REMOVE_BY_INDEX.

  FIELD-SYMBOLS: <fs_tabledescr> TYPE zcs_abap_tabledescr.

  READ TABLE me->collection ASSIGNING <fs_tabledescr> INDEX index.

  IF sy-subrc EQ 0.
    FREE: <fs_tabledescr>-descriptor.
    DELETE me->collection INDEX index.
  ENDIF.

  endmethod.


method REMOVE_BY_NAME.

  FIELD-SYMBOLS: <fs_tabledescr> TYPE zcs_abap_tabledescr.

  READ TABLE me->collection ASSIGNING <fs_tabledescr> WITH KEY name = name.

  IF sy-subrc EQ 0.
    FREE: <fs_tabledescr>-descriptor.
    DELETE me->collection INDEX sy-tabix.
  ENDIF.

  endmethod.


method SIZE.

  size = LINES( me->collection ).

  endmethod.
ENDCLASS.
