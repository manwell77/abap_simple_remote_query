class ZCL_STRUCTDESCR_COLLECTION definition
  public
  final
  create public .

public section.

  methods ADD
    importing
      value(NAME) type STRUKNAME
      value(DESCRIPTOR) type ref to CL_ABAP_STRUCTDESCR .
  methods EMPTY .
  methods REMOVE_BY_INDEX
    importing
      value(INDEX) type I .
  methods REMOVE_BY_NAME
    importing
      value(NAME) type STRUKNAME .
  methods GET_BY_INDEX
    importing
      value(INDEX) type I
    returning
      value(STRUCTDESCR) type ZCS_ABAP_STRUCTDESCR .
  methods SIZE
    returning
      value(SIZE) type I .
  methods IS_EMPTY
    returning
      value(IS_EMPTY) type FLAG .
  methods GET_BY_NAME
    importing
      value(NAME) type STRUKNAME
    returning
      value(STRUCTDESCR) type ZCS_ABAP_STRUCTDESCR .
  methods GET_ITERATOR
    returning
      value(ITERATOR) type ref to ZCL_STRUCTDESCR_COLL_ITERATOR .
protected section.
private section.

  data COLLECTION type ZCT_ABAP_STRUCTDESCR .
ENDCLASS.



CLASS ZCL_STRUCTDESCR_COLLECTION IMPLEMENTATION.


method ADD.

  DATA: ls_structdescr TYPE zcs_abap_structdescr.

  ls_structdescr-name = name.
  ls_structdescr-descriptor = descriptor.

  APPEND ls_structdescr TO me->collection.

  endmethod.


method EMPTY.

  FIELD-SYMBOLS: <fs_structdescr> TYPE zcs_abap_structdescr.

  LOOP AT me->collection ASSIGNING <fs_structdescr>.
    FREE: <fs_structdescr>-descriptor.
  ENDLOOP.

  REFRESH: me->collection.

  endmethod.


method GET_BY_INDEX.

  READ TABLE me->collection INDEX index INTO structdescr.

  endmethod.


method GET_BY_NAME.

  READ TABLE me->collection INTO structdescr WITH KEY name = name.

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

  FIELD-SYMBOLS: <fs_structdescr> TYPE zcs_abap_structdescr.

  READ TABLE me->collection ASSIGNING <fs_structdescr> INDEX index.

  IF sy-subrc EQ 0.
    FREE: <fs_structdescr>-descriptor.
    DELETE me->collection INDEX index.
  ENDIF.

  endmethod.


method REMOVE_BY_NAME.

  FIELD-SYMBOLS: <fs_structdescr> TYPE zcs_abap_structdescr.

  READ TABLE me->collection ASSIGNING <fs_structdescr> WITH KEY name = name.

  IF sy-subrc EQ 0.
    FREE: <fs_structdescr>-descriptor.
    DELETE me->collection INDEX sy-tabix.
  ENDIF.

  endmethod.


method SIZE.

  size = LINES( me->collection ).

  endmethod.
ENDCLASS.
