class ZCL_STRUCTDESCR_COLL_ITERATOR definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      value(COLLECTION) type ref to ZCL_STRUCTDESCR_COLLECTION .
  methods GET_INDEX
    returning
      value(INDEX) type INT4 .
  methods HAS_NEXT
    returning
      value(HAS_NEXT) type FLAG .
  methods GET_NEXT
    returning
      value(STRUCTDESCR) type ZCS_ABAP_STRUCTDESCR .
protected section.
private section.

  data COLLECTION type ref to ZCL_STRUCTDESCR_COLLECTION .
  data INDEX type I .
ENDCLASS.



CLASS ZCL_STRUCTDESCR_COLL_ITERATOR IMPLEMENTATION.


method CONSTRUCTOR.

  me->collection = collection.

  endmethod.


method GET_INDEX.

  index = me->index.

  endmethod.


method GET_NEXT.

  IF me->has_next( ) EQ 'X'.
    ADD 1 TO me->index.
    structdescr = me->collection->get_by_index( me->index ).
  ENDIF.

  endmethod.


method HAS_NEXT.

  DATA: ls_structdescr TYPE zcs_abap_structdescr,
        lv_index       TYPE i.

  lv_index = me->index + 1.

  ls_structdescr = me->collection->get_by_index( lv_index ).

  IF NOT ls_structdescr IS INITIAL.
    has_next = 'X'.
  ENDIF.

  endmethod.
ENDCLASS.
