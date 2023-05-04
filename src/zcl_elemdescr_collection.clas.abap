class ZCL_ELEMDESCR_COLLECTION definition
  public
  final
  create public .

public section.

  methods ADD
    importing
      value(NAME) type ROLLNAME
      value(DESCRIPTOR) type ref to CL_ABAP_ELEMDESCR .
  methods EMPTY .
  methods REMOVE_BY_INDEX
    importing
      value(INDEX) type I .
  methods REMOVE_BY_NAME
    importing
      value(NAME) type ROLLNAME .
  methods GET_BY_INDEX
    importing
      value(INDEX) type I
    returning
      value(ELEMDESCR) type ZCS_ABAP_ELEMDESCR .
  methods SIZE
    returning
      value(SIZE) type I .
  methods IS_EMPTY
    returning
      value(IS_EMPTY) type FLAG .
  methods GET_BY_NAME
    importing
      value(NAME) type ROLLNAME
    returning
      value(ELEMDESCR) type ZCS_ABAP_ELEMDESCR .
  methods GET_ITERATOR
    returning
      value(ITERATOR) type ref to ZCL_ELEMDESCR_COLL_ITERATOR .
protected section.
private section.

  data COLLECTION type ZCT_ABAP_ELEMDESCR .
ENDCLASS.



CLASS ZCL_ELEMDESCR_COLLECTION IMPLEMENTATION.


method ADD.

  DATA: ls_elemdescr TYPE zcs_abap_elemdescr.

  ls_elemdescr-name = name.
  ls_elemdescr-descriptor = descriptor.

  APPEND ls_elemdescr TO me->collection.

  endmethod.


method EMPTY.

  FIELD-SYMBOLS: <fs_elemdescr> TYPE zcs_abap_elemdescr.

  LOOP AT me->collection ASSIGNING <fs_elemdescr>.
    FREE: <fs_elemdescr>-descriptor.
  ENDLOOP.

  REFRESH: me->collection.

  endmethod.


method GET_BY_INDEX.

  READ TABLE me->collection INDEX index INTO elemdescr.

  endmethod.


method GET_BY_NAME.

  READ TABLE me->collection INTO elemdescr WITH KEY name = name.

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

  FIELD-SYMBOLS: <fs_elemdescr> TYPE zcs_abap_elemdescr.

  READ TABLE me->collection ASSIGNING <fs_elemdescr> INDEX index.

  IF sy-subrc EQ 0.
    FREE: <fs_elemdescr>-descriptor.
    DELETE me->collection INDEX index.
  ENDIF.

  endmethod.


method REMOVE_BY_NAME.

  FIELD-SYMBOLS: <fs_elemdescr> TYPE zcs_abap_elemdescr.

  READ TABLE me->collection ASSIGNING <fs_elemdescr> WITH KEY name = name.

  IF sy-subrc EQ 0.
    FREE: <fs_elemdescr>-descriptor.
    DELETE me->collection INDEX sy-tabix.
  ENDIF.

  endmethod.


method SIZE.

  size = LINES( me->collection ).

  endmethod.
ENDCLASS.
