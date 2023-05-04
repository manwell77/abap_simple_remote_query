class ZCX_DYN_REMOTE_TYPE_BUILDER definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_DYN_REMOTE_TYPE_BUILDER,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_DYN_REMOTE_TYPE_BUILDER .
  constants:
    begin of RFC_UNREACHABLE,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '001',
      attr1 type scx_attrname value 'RFCDEST',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RFC_UNREACHABLE .
  constants:
    begin of NO_STRUC,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '002',
      attr1 type scx_attrname value 'STRUCT',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_STRUC .
  constants:
    begin of NO_DATATYPE,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '003',
      attr1 type scx_attrname value 'DATATYPE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_DATATYPE .
  constants:
    begin of NO_INTTYPE,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '004',
      attr1 type scx_attrname value 'INTTYPE',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_INTTYPE .
  constants:
    begin of NO_DELEM,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '005',
      attr1 type scx_attrname value 'DELEM',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_DELEM .
  constants:
    begin of OWN_LOGSYS_NOT_DEFINED,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '011',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of OWN_LOGSYS_NOT_DEFINED .
  constants:
    begin of DATA_CREATION,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '009',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of DATA_CREATION .
  data RFCDEST type RFCDEST .
  data STRUCT type STRUKNAME .
  data DATATYPE type DATATYPE_D .
  data INTTYPE type INTTYPE .
  data DELEM type ROLLNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !RFCDEST type RFCDEST optional
      !STRUCT type STRUKNAME optional
      !DATATYPE type DATATYPE_D optional
      !INTTYPE type INTTYPE optional
      !DELEM type ROLLNAME optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_DYN_REMOTE_TYPE_BUILDER IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->RFCDEST = RFCDEST .
me->STRUCT = STRUCT .
me->DATATYPE = DATATYPE .
me->INTTYPE = INTTYPE .
me->DELEM = DELEM .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_DYN_REMOTE_TYPE_BUILDER .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
