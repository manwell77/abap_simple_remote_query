class ZCX_DYN_REMOTE definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants:
    begin of ZCX_DYN_REMOTE,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '000',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ZCX_DYN_REMOTE .
  constants:
    begin of RFC_READ,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '007',
      attr1 type scx_attrname value 'TABLE',
      attr2 type scx_attrname value 'RFC_DESTINATION',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of RFC_READ .
  constants:
    begin of NO_FIELD,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '006',
      attr1 type scx_attrname value 'FIELD',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of NO_FIELD .
  constants:
    begin of ASSIGN_COMP_FAILED,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '008',
      attr1 type scx_attrname value 'FIELD',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ASSIGN_COMP_FAILED .
  constants:
    begin of ASSIGN_FAILED,
      msgid type symsgid value 'ZDYNTYPEBUILDER',
      msgno type symsgno value '010',
      attr1 type scx_attrname value '',
      attr2 type scx_attrname value '',
      attr3 type scx_attrname value '',
      attr4 type scx_attrname value '',
    end of ASSIGN_FAILED .
  data RFC_DESTINATION type RFCDEST .
  data TABLE type STRUKNAME .
  data FIELD type FIELDNAME .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !RFC_DESTINATION type RFCDEST optional
      !TABLE type STRUKNAME optional
      !FIELD type FIELDNAME optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_DYN_REMOTE IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->RFC_DESTINATION = RFC_DESTINATION .
me->TABLE = TABLE .
me->FIELD = FIELD .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = ZCX_DYN_REMOTE .
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
endmethod.
ENDCLASS.
