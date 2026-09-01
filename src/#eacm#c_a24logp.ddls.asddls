@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Process'
@Metadata.allowExtensions: true
define view entity /EACM/C_A24LOGP
  as projection on /EACM/I_A24LOGP
{
  key Requestid,
  key Tmsp,
      Status,
      StatusCriticality,
      TotalRecords,
      SuccessRecords,
      ErrorRecords,
      WaitRecords,
      NotRelevant,
      /* Associations */
      _Header : redirected to parent /EACM/C_A24LOGH
}
