*&---------------------------------------------------------------------*
*& Include ZDYNSRQDEMOTOP                                    Report ZDYNSRQDEMO
*&
*&---------------------------------------------------------------------*

report zdynsrqdemo line-size 1023.

* simple remote query macros
##INCL_OK
include: zsrq.

* subfield selection of ADRC structure
##NEEDED
types: begin of ts_subadrc,
         addrnumber type ad_addrnum,
         date_from  type ad_date_fr,
         nation     type ad_nation,
         name       type ad_name1,
         street     type ad_street,
         house_no   type ad_hsnm1,
         city       type ad_city1,
         region     type regio,
         country    type land1,
       end of ts_subadrc,

       begin of ts_so_adr,
         sign   type tvarv_sign,
         option type tvarv_opti,
         low    type ad_addrnum,
         high   type ad_addrnum,
       end of ts_so_adr.

* global data
##NEEDED
data: gs_soadr      type ts_so_adr,
      gv_adrc_query type string,
      gv_adr2_query type string,
      gs_subadrc    type ts_subadrc,
      gv_adrno      type ad_addrnum,
      gv_perno      type ad_persnum,
      gv_telno      type ad_tlnmbr.

* global field-symbols
##NEEDED
field-symbols: <gt_adr2>  type standard table,
               <gt_adrc>  type standard table,
               <gs_line>  type any.

* global objects
##NEEDED
data: go_adrc_itab  type ref to data,
      go_adr2_itab  type ref to data,
      go_adrc_struc type ref to data.
