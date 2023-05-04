class ZCL_ELEMDESCR_COLL_ITERATOR definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      value(COLLECTION) type ref to ZCL_ELEMDESCR_COLLECTION .
  methods GET_INDEX
    returning
      value(INDEX) type INT4 .
  methods HAS_NEXT
    returning
      value(HAS_NEXT) type FLAG .
  methods GET_NEXT
    returning
      value(ELEMDESCR) type ZCS_ABAP_ELEMDESCR .
protected section.
private section.

  data COLLECTION type ref to ZCL_ELEMDESCR_COLLECTION .
  data INDEX type I .
ENDCLASS.



CLASS ZCL_ELEMDESCR_COLL_ITERATOR IMPLEMENTATION.


method CONSTRUCTOR.

  me->collection = collection.

  endmethod.


method GET_INDEX.

  index = me->index.

  endmethod.


method GET_NEXT.

  IF me->has_next( ) EQ 'X'.
    ADD 1 TO me->index.
    elemdescr = me->collection->get_by_index( me->index ).
  ENDIF.

  endmethod.


method HAS_NEXT.

  DATA: ls_elemdescr TYPE zcs_abap_elemdescr,
        lv_index     TYPE i.

  lv_index = me->index + 1.

  ls_elemdescr = me->collection->get_by_index( lv_index ).

  IF NOT ls_elemdescr IS INITIAL.
    has_next = 'X'.
  ENDIF.

  endmethod.
ENDCLASS.
