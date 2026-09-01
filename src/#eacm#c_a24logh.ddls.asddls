@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'A24 Upload Header'
@Metadata.allowExtensions: true
define root view entity /EACM/C_A24LOGH
  provider contract transactional_query
  as projection on /EACM/I_A24LOGH
{
  key Requestid,
      CreatedBy,
      CreatedAt,
      CreatedAtDisplay,
      Status,
//      StatusIcon,
      StatusCriticality,
      /* Associations */
      _Items : redirected to composition child /EACM/C_A24LOGI,
      _Processes : redirected to composition child /EACM/C_A24LOGP
}
