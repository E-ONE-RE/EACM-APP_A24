@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Process'
@Metadata.ignorePropagatedAnnotations: true
define view entity /EACM/I_A24LOGP
  as select from /eacm/a24logp
  association to parent /EACM/I_A24LOGH as _Header on $projection.Requestid = _Header.Requestid
{
  key requestid       as Requestid,
  key tmsp            as Tmsp,
      status          as Status,
      case status
        when 'RECEIVED'    then 0 //Information blue
        when 'PROCESSING' then 1 //rosso
        when 'PARTIALLY'  then 2 //Critical Arancione/Giallo
        when 'COMPLETE' then 3  // Positive verde
        else 0 // Neutral
      end             as StatusCriticality,
      total_records   as TotalRecords,
      success_records as SuccessRecords,
      error_records   as ErrorRecords,
      wait_records    as WaitRecords,
      not_relevante   as NotRelevant,
      _Header
}
