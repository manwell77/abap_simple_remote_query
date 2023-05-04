class ZCL_TABLEDESCR_COLL_ITERATOR definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      value(COLLECTION) type ref to ZCL_TABLEDESCR_COLLECTION .
  methods GET_INDEX
    returning
      value(INDEX) type INT4 .
  methods HAS_NEXT
    returning
      value(HAS_NEXT) type FLAG .
  methods GET_NEXT
    returning
      value(TABLEDESCR) type ZCS_ABAP_TABLEDESCR .
protected section.
private section.

  data COLLECTION type ref to ZCL_TABLEDESCR_COLLECTION .
  data INDEX type I .
ENDCLASS.



CLASS ZCL_TABLEDESCR_COLL_ITERATOR IMPLEMENTATION.


method CONSTRUCTOR.

  me->collection = collection.

  endmethod.


method GET_INDEX.

  index = me->index.

  endmethod.


method GET_NEXT.

  IF me->has_next( ) EQ 'X'.
    ADD 1 TO me->index.
    tabledescr = me->collection->get_by_index( me->index ).
  ENDIF.

  endmethod.


method HAS_NEXT.

  DATA: ls_tabledescr TYPE zcs_abap_tabledescr,
        lv_index       TYPE i.

  lv_index = me->index + 1.

  ls_tabledescr = me->collection->get_by_index( lv_index ).

  IF NOT ls_tabledescr IS INITIAL.
    has_next = 'X'.
  ENDIF.

  endmethod.
ENDCLASS.
