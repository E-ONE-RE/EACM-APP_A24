@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Upload Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_A24LOGI
  as select from /eacm/a24logi
  association to parent /EACM/I_A24LOGH as _Header on $projection.Requestid = _Header.Requestid
{
  key requestid as Requestid,
  key zlineno   as Zlineno,
      status    as Status,
      case status
        when 'UPLOADED'    then 3  // Positive verde
        when 'NOT_RELEVANT' then 4 //Information blue
        when 'ERROR'  then 1 //rosso
        when 'WAIT' then 2 //Critical Arancione/Giallo
        else 0 // Neutral
      end        as StatusCriticality,
      message   as Message,
      record    as Record,
      vkorg     as Vkorg,
      vtweg     as Vtweg,
      zclpr     as Zclpr,
      vbeln     as Vbeln,
      posnr     as Posnr,
      zcdaz     as Zcdaz,
      zidag     as Zidag,
      _Header
}

